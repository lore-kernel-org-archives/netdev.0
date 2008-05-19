From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH] WAN: protect HDLC proto list while insmod/rmmod
Date: Mon, 19 May 2008 19:00:51 +0200
Message-ID: <m3ve1agrek.fsf_-_@maximus.localdomain>
References: <20080424.065555.30390704.davem@davemloft.net>
	<m3ve27nfpx.fsf@maximus.localdomain>
	<20080424214457.1d5a1655@the-village.bc.nu>
	<20080512.033244.153113922.davem@davemloft.net>
	<m3lk2djbq3.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: alan@lxorguk.ukuu.org.uk, David Miller <davem@davemloft.net>,
	paulkf@microgate.com, jchapman@katalix.com,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:35892 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751717AbYESRAx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2008 13:00:53 -0400
In-Reply-To: <m3lk2djbq3.fsf@maximus.localdomain> (Krzysztof Halasa's message of "Wed\, 14 May 2008 14\:45\:24 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

WAN: protect protocol list in hdlc.c with RTNL.
   =20
Signed-off-by: Krzysztof Ha=B3asa <khc@pm.waw.pl>

--- a/drivers/net/wan/hdlc.c
+++ b/drivers/net/wan/hdlc.c
@@ -42,8 +42,7 @@ static const char* version =3D "HDLC support module r=
evision 1.22";
=20
 #undef DEBUG_LINK
=20
-static struct hdlc_proto *first_proto =3D NULL;
-
+static struct hdlc_proto *first_proto;
=20
 static int hdlc_change_mtu(struct net_device *dev, int new_mtu)
 {
@@ -313,21 +312,25 @@ void detach_hdlc_protocol(struct net_device *dev)
=20
 void register_hdlc_protocol(struct hdlc_proto *proto)
 {
+	rtnl_lock();
 	proto->next =3D first_proto;
 	first_proto =3D proto;
+	rtnl_unlock();
 }
=20
=20
 void unregister_hdlc_protocol(struct hdlc_proto *proto)
 {
-	struct hdlc_proto **p =3D &first_proto;
-	while (*p) {
-		if (*p =3D=3D proto) {
-			*p =3D proto->next;
-			return;
-		}
+	struct hdlc_proto **p;
+
+	rtnl_lock();
+	p =3D &first_proto;
+	while (*p !=3D proto) {
+		BUG_ON(!*p);
 		p =3D &((*p)->next);
 	}
+	*p =3D proto->next;
+	rtnl_unlock();
 }
=20
=20

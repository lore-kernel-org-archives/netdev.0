From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?= <remi@remlab.net>
Subject: [PATCH net-next 1/2] Phonet: put protocols array under RCU
Date: Fri, 13 Nov 2009 17:01:18 +0200
Message-ID: <1258124479-1167-1-git-send-email-remi@remlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:42995 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755097AbZKMPBO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Nov 2009 10:01:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 net/phonet/af_phonet.c |   20 +++++++++++---------
 1 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/net/phonet/af_phonet.c b/net/phonet/af_phonet.c
index 8d3a55b..ed65da2 100644
--- a/net/phonet/af_phonet.c
+++ b/net/phonet/af_phonet.c
@@ -35,7 +35,6 @@
=20
 /* Transport protocol registration */
 static struct phonet_protocol *proto_tab[PHONET_NPROTO] __read_mostly;
-static DEFINE_SPINLOCK(proto_tab_lock);
=20
 static struct phonet_protocol *phonet_proto_get(int protocol)
 {
@@ -44,11 +43,11 @@ static struct phonet_protocol *phonet_proto_get(int=
 protocol)
 	if (protocol >=3D PHONET_NPROTO)
 		return NULL;
=20
-	spin_lock(&proto_tab_lock);
+	rcu_read_lock();
 	pp =3D proto_tab[protocol];
 	if (pp && !try_module_get(pp->prot->owner))
 		pp =3D NULL;
-	spin_unlock(&proto_tab_lock);
+	rcu_read_unlock();
=20
 	return pp;
 }
@@ -439,6 +438,8 @@ static struct packet_type phonet_packet_type __read=
_mostly =3D {
 	.func =3D phonet_rcv,
 };
=20
+static DEFINE_MUTEX(proto_tab_lock);
+
 int __init_or_module phonet_proto_register(int protocol,
 						struct phonet_protocol *pp)
 {
@@ -451,12 +452,12 @@ int __init_or_module phonet_proto_register(int pr=
otocol,
 	if (err)
 		return err;
=20
-	spin_lock(&proto_tab_lock);
+	mutex_lock(&proto_tab_lock);
 	if (proto_tab[protocol])
 		err =3D -EBUSY;
 	else
-		proto_tab[protocol] =3D pp;
-	spin_unlock(&proto_tab_lock);
+		rcu_assign_pointer(proto_tab[protocol], pp);
+	mutex_unlock(&proto_tab_lock);
=20
 	return err;
 }
@@ -464,10 +465,11 @@ EXPORT_SYMBOL(phonet_proto_register);
=20
 void phonet_proto_unregister(int protocol, struct phonet_protocol *pp)
 {
-	spin_lock(&proto_tab_lock);
+	mutex_lock(&proto_tab_lock);
 	BUG_ON(proto_tab[protocol] !=3D pp);
-	proto_tab[protocol] =3D NULL;
-	spin_unlock(&proto_tab_lock);
+	rcu_assign_pointer(proto_tab[protocol], NULL);
+	mutex_unlock(&proto_tab_lock);
+	synchronize_rcu();
 	proto_unregister(pp->prot);
 }
 EXPORT_SYMBOL(phonet_proto_unregister);
--=20
1.6.3.3


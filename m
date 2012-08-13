From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net 3/3] llc: Fix races between llc2 handler use and
 (un)registration
Date: Mon, 13 Aug 2012 13:50:55 +0100
Message-ID: <1344862255.824.142.camel@deadeye.wl.decadent.org.uk>
References: <1344862120.824.139.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-P+FGSQgLItr9NoODFTts"
Cc: netdev@vger.kernel.org
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:39149 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750975Ab2HMMvA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Aug 2012 08:51:00 -0400
In-Reply-To: <1344862120.824.139.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-P+FGSQgLItr9NoODFTts
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

When registering the handlers, any state they rely on must be
completely initialised first.  When unregistering, we must wait until
they are definitely no longer running.  llc_rcv() must also avoid
reading the handler pointers again after checking for NULL.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 net/llc/llc_input.c   |   21 +++++++++++++++++----
 net/llc/llc_station.c |    2 +-
 2 files changed, 18 insertions(+), 5 deletions(-)

diff --git a/net/llc/llc_input.c b/net/llc/llc_input.c
index e32cab4..dd3e833 100644
--- a/net/llc/llc_input.c
+++ b/net/llc/llc_input.c
@@ -42,6 +42,7 @@ static void (*llc_type_handlers[2])(struct llc_sap *sap,
 void llc_add_pack(int type, void (*handler)(struct llc_sap *sap,
 					    struct sk_buff *skb))
 {
+	smp_wmb(); /* ensure initialisation is complete before it's called */
 	if (type =3D=3D LLC_DEST_SAP || type =3D=3D LLC_DEST_CONN)
 		llc_type_handlers[type - 1] =3D handler;
 }
@@ -50,11 +51,19 @@ void llc_remove_pack(int type)
 {
 	if (type =3D=3D LLC_DEST_SAP || type =3D=3D LLC_DEST_CONN)
 		llc_type_handlers[type - 1] =3D NULL;
+	synchronize_net();
 }
=20
 void llc_set_station_handler(void (*handler)(struct sk_buff *skb))
 {
+	/* Ensure initialisation is complete before it's called */
+	if (handler)
+		smp_wmb();
+
 	llc_station_handler =3D handler;
+
+	if (!handler)
+		synchronize_net();
 }
=20
 /**
@@ -150,6 +159,8 @@ int llc_rcv(struct sk_buff *skb, struct net_device *dev=
,
 	int dest;
 	int (*rcv)(struct sk_buff *, struct net_device *,
 		   struct packet_type *, struct net_device *);
+	void (*sta_handler)(struct sk_buff *skb);
+	void (*sap_handler)(struct llc_sap *sap, struct sk_buff *skb);
=20
 	if (!net_eq(dev_net(dev), &init_net))
 		goto drop;
@@ -182,7 +193,8 @@ int llc_rcv(struct sk_buff *skb, struct net_device *dev=
,
 	 */
 	rcv =3D rcu_dereference(sap->rcv_func);
 	dest =3D llc_pdu_type(skb);
-	if (unlikely(!dest || !llc_type_handlers[dest - 1])) {
+	sap_handler =3D dest ? ACCESS_ONCE(llc_type_handlers[dest - 1]) : NULL;
+	if (unlikely(!sap_handler)) {
 		if (rcv)
 			rcv(skb, dev, pt, orig_dev);
 		else
@@ -193,7 +205,7 @@ int llc_rcv(struct sk_buff *skb, struct net_device *dev=
,
 			if (cskb)
 				rcv(cskb, dev, pt, orig_dev);
 		}
-		llc_type_handlers[dest - 1](sap, skb);
+		sap_handler(sap, skb);
 	}
 	llc_sap_put(sap);
 out:
@@ -202,9 +214,10 @@ drop:
 	kfree_skb(skb);
 	goto out;
 handle_station:
-	if (!llc_station_handler)
+	sta_handler =3D ACCESS_ONCE(llc_station_handler);
+	if (!sta_handler)
 		goto drop;
-	llc_station_handler(skb);
+	sta_handler(skb);
 	goto out;
 }
=20
diff --git a/net/llc/llc_station.c b/net/llc/llc_station.c
index 45ddbb9..81da71a 100644
--- a/net/llc/llc_station.c
+++ b/net/llc/llc_station.c
@@ -696,9 +696,9 @@ void __init llc_station_init(void)
 			(unsigned long)&llc_main_station);
 	llc_main_station.ack_timer.expires  =3D jiffies +
 						sysctl_llc_station_ack_timeout;
-	llc_set_station_handler(llc_station_rcv);
 	llc_main_station.maximum_retry	=3D 1;
 	llc_main_station.state		=3D LLC_STATION_STATE_UP;
+	llc_set_station_handler(llc_station_rcv);
 }
=20
 void __exit llc_station_exit(void)


--=-P+FGSQgLItr9NoODFTts
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUCj4L+e/yOyVhhEJAQqJ9RAAtOIFW0KRkYmreAp03fxvJM5Y6b+qXC1h
qVvE2yp+VKdq7hgubtzOxQ6PrpxdmJ1qjuNyNuR88MZCqT9aKTilGZeAuSSS5KE1
9XStgY/n8Q3zjzFv6oNEhnZeVX0RJn9NoLkg3QiXynnk57iI6GqGtOj7RhdrqVuo
j68/dqmDwm4Ku6JTTM8KbW+MlEZ+A+eYkSEQ17hehgRWV63Qygvj1k5tD0yqeJJn
9pFwIrUrgR/RVa7o+ujJOIis6S78WhDerntcNllxd9T7rgcwKBX18PYJWxIzjd4R
Uc0oMCfDItDgMn4dflFotxcMtmVzQ3pUVUp9xfcSn+8LsmrCzxTH3dRGuT/208Dt
ZWEOaeoa1Uxo3I8ypk7gDVA7PYCzV6WSZYUkvrYEsyqpXLh8Bjh4xU5qN0fx9THZ
uQcOpubRA7oI9/YNOACQOCFHXjSgCPSF3TQxNwimzJzxQMT1US/j9gojF+Xvyg24
Zu3fwnhrjZj8fl2hVLNbXI1d1AaX2nVjqWSmUle878PTzQYyTvzA6g8Dws2d3OTn
LK6H5pr61gtDB5mSahAiKEuoR6iADgoqHpPPCHdGBICc4g7eox01714cJ6wAHkDG
BZxJbVug8Zd204vmkS/6jEo75yis4sXSdfHU1NKSTOMMiaPSj5oFcoVXfiN75oTU
PjeAylQeF/E=
=z0WF
-----END PGP SIGNATURE-----

--=-P+FGSQgLItr9NoODFTts--

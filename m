From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net 1/3] llc2: Fix silent failure of llc_station_init()
Date: Mon, 13 Aug 2012 13:49:59 +0100
Message-ID: <1344862199.824.140.camel@deadeye.wl.decadent.org.uk>
References: <1344862120.824.139.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-PoaiOjyGNVLNWAlXYf+X"
Cc: netdev@vger.kernel.org
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:39135 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750975Ab2HMMuC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Aug 2012 08:50:02 -0400
In-Reply-To: <1344862120.824.139.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-PoaiOjyGNVLNWAlXYf+X
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

llc_station_init() creates and processes an event skb with no effect
other than to change the state from DOWN to UP.  Allocation failure is
reported, but then ignored by its caller, llc2_init().  Remove this
possibility by simply initialising the state as UP.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 include/net/llc.h     |    2 +-
 net/llc/llc_station.c |   19 ++-----------------
 2 files changed, 3 insertions(+), 18 deletions(-)

diff --git a/include/net/llc.h b/include/net/llc.h
index 226c846..f2d0fc5 100644
--- a/include/net/llc.h
+++ b/include/net/llc.h
@@ -133,7 +133,7 @@ extern int llc_build_and_send_ui_pkt(struct llc_sap *sa=
p, struct sk_buff *skb,
 extern void llc_sap_handler(struct llc_sap *sap, struct sk_buff *skb);
 extern void llc_conn_handler(struct llc_sap *sap, struct sk_buff *skb);
=20
-extern int llc_station_init(void);
+extern void llc_station_init(void);
 extern void llc_station_exit(void);
=20
 #ifdef CONFIG_PROC_FS
diff --git a/net/llc/llc_station.c b/net/llc/llc_station.c
index 6828e39..45ddbb9 100644
--- a/net/llc/llc_station.c
+++ b/net/llc/llc_station.c
@@ -687,12 +687,8 @@ static void llc_station_rcv(struct sk_buff *skb)
 	llc_station_state_process(skb);
 }
=20
-int __init llc_station_init(void)
+void __init llc_station_init(void)
 {
-	int rc =3D -ENOBUFS;
-	struct sk_buff *skb;
-	struct llc_station_state_ev *ev;
-
 	skb_queue_head_init(&llc_main_station.mac_pdu_q);
 	skb_queue_head_init(&llc_main_station.ev_q.list);
 	spin_lock_init(&llc_main_station.ev_q.lock);
@@ -700,20 +696,9 @@ int __init llc_station_init(void)
 			(unsigned long)&llc_main_station);
 	llc_main_station.ack_timer.expires  =3D jiffies +
 						sysctl_llc_station_ack_timeout;
-	skb =3D alloc_skb(0, GFP_ATOMIC);
-	if (!skb)
-		goto out;
-	rc =3D 0;
 	llc_set_station_handler(llc_station_rcv);
-	ev =3D llc_station_ev(skb);
-	memset(ev, 0, sizeof(*ev));
 	llc_main_station.maximum_retry	=3D 1;
-	llc_main_station.state		=3D LLC_STATION_STATE_DOWN;
-	ev->type	=3D LLC_STATION_EV_TYPE_SIMPLE;
-	ev->prim_type	=3D LLC_STATION_EV_ENABLE_WITHOUT_DUP_ADDR_CHECK;
-	rc =3D llc_station_next_state(skb);
-out:
-	return rc;
+	llc_main_station.state		=3D LLC_STATION_STATE_UP;
 }
=20
 void __exit llc_station_exit(void)



--=-PoaiOjyGNVLNWAlXYf+X
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUCj39+e/yOyVhhEJAQqZsBAAyXVR7b96qZecUcOSHzLOC+ft+AaItwru
fsoMb9PJuBW/GTrv/x9Jwk6FMqLDVlh9D6A7qTfxSIbISPhUwldrVX8/KpxCpYNB
JUORz6DZ8W07Z6tAfQhUtXn8MTS382gX0iVQWAcznPNdcyNqm+9QL1cvXxsjvVln
zG3rxlX9OreaDT6ZgfGo+3Av0xkL6xXI09bJmdvRyhrOsmoWEdPnrQSjNkJmg1g9
x6JoWcZid0b3oB8AswwbMTmSC9cvFu0U7V5hQ5JQyjelpxSdPKVf+Jyua9+lYkHK
mesr7hNU0Z9cy4/CsAJYVLiRBFJE73iFiXeO7QFUw7tTAtVjdbA9FalwCR98/9ew
5lic9VbaBubqYeaWN/OqihZYm9AMXg7OUrtE2ASWNSTLLKN/oYAA4uOaQSBKWZlo
32XUXR8onDvOgsSZFbl6hED2Dsg0zNYBEUGiTOaUskqxI/GxwnZZHbw9nbsNMxUx
wgCD8tF9GVAMDMat3kDRGkXyosyYi3y0CjTdoKwfsedy37pe07mmqQSEwQyQIM6u
jrBWXOltctGcGFro1OGax008ScZD9QGQbfs7UM6xaihep7CrICrBPYAiOPgeJiiN
q87p3WeIaD7qlufYf9KRbc0xtERkeJJUWlcBRDu6gm1ONDx20Dph0BtGYuNpPVmO
3MqK0blEEyQ=
=JQwA
-----END PGP SIGNATURE-----

--=-PoaiOjyGNVLNWAlXYf+X--

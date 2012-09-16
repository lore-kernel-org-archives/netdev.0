From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next 4/6] llc2: Remove the station send queue
Date: Sun, 16 Sep 2012 04:11:32 +0100
Message-ID: <1347765092.13258.212.camel@deadeye.wl.decadent.org.uk>
References: <1347764982.13258.207.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-4EYmXUfA4tE1deb3t7jD"
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:53025 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751133Ab2IPDLg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Sep 2012 23:11:36 -0400
In-Reply-To: <1347764982.13258.207.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-4EYmXUfA4tE1deb3t7jD
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

We only ever put one skb on the send queue, and then immediately
send it.  Remove the queue and call dev_queue_xmit() directly.

This leaves struct llc_station empty, so remove that as well.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 net/llc/llc_station.c |   34 ++--------------------------------
 1 file changed, 2 insertions(+), 32 deletions(-)

diff --git a/net/llc/llc_station.c b/net/llc/llc_station.c
index 3bdb888..48c2118 100644
--- a/net/llc/llc_station.c
+++ b/net/llc/llc_station.c
@@ -25,19 +25,6 @@
 #include <net/llc_s_st.h>
 #include <net/llc_pdu.h>
=20
-/**
- * struct llc_station - LLC station component
- *
- * SAP and connection resource manager, one per adapter.
- *
- * @mac_sa: MAC source address
- * @sap_list: list of related SAPs
- * @mac_pdu_q: PDUs ready to send to MAC
- */
-struct llc_station {
-	struct sk_buff_head	    mac_pdu_q;
-};
-
 typedef int (*llc_station_ev_t)(struct sk_buff *skb);
=20
 typedef int (*llc_station_action_t)(struct sk_buff *skb);
@@ -48,8 +35,6 @@ struct llc_station_state_trans {
 	llc_station_action_t *ev_actions;
 };
=20
-static struct llc_station llc_main_station;
-
 static int llc_stat_ev_rx_null_dsap_xid_c(struct sk_buff *skb)
 {
 	struct llc_pdu_un *pdu =3D llc_pdu_un_hdr(skb);
@@ -70,20 +55,6 @@ static int llc_stat_ev_rx_null_dsap_test_c(struct sk_buf=
f *skb)
 	       !pdu->dsap ? 0 : 1;			/* NULL DSAP */
 }
=20
-/**
- *	llc_station_send_pdu - queues PDU to send
- *	@skb: Address of the PDU
- *
- *	Queues a PDU to send to the MAC layer.
- */
-static void llc_station_send_pdu(struct sk_buff *skb)
-{
-	skb_queue_tail(&llc_main_station.mac_pdu_q, skb);
-	while ((skb =3D skb_dequeue(&llc_main_station.mac_pdu_q)) !=3D NULL)
-		if (dev_queue_xmit(skb))
-			break;
-}
-
 static int llc_station_ac_send_xid_r(struct sk_buff *skb)
 {
 	u8 mac_da[ETH_ALEN], dsap;
@@ -101,7 +72,7 @@ static int llc_station_ac_send_xid_r(struct sk_buff *skb=
)
 	rc =3D llc_mac_hdr_init(nskb, skb->dev->dev_addr, mac_da);
 	if (unlikely(rc))
 		goto free;
-	llc_station_send_pdu(nskb);
+	dev_queue_xmit(nskb);
 out:
 	return rc;
 free:
@@ -130,7 +101,7 @@ static int llc_station_ac_send_test_r(struct sk_buff *s=
kb)
 	rc =3D llc_mac_hdr_init(nskb, skb->dev->dev_addr, mac_da);
 	if (unlikely(rc))
 		goto free;
-	llc_station_send_pdu(nskb);
+	dev_queue_xmit(nskb);
 out:
 	return rc;
 free:
@@ -228,7 +199,6 @@ static void llc_station_rcv(struct sk_buff *skb)
=20
 void __init llc_station_init(void)
 {
-	skb_queue_head_init(&llc_main_station.mac_pdu_q);
 	llc_set_station_handler(llc_station_rcv);
 }
=20



--=-4EYmXUfA4tE1deb3t7jD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUFVDZOe/yOyVhhEJAQr6Sw//aJkpd3XG+gRmM7iHpVl9HLK3Ap+90H8A
K6iwBGv9DO77LxhuCnfN0GiPW4hCuQf8vxf+x0WiTeQEGOpz3Xzefn92JbWcLnAX
QA1oVlDGztHmoCy4cWhhjXiO0pIMbuyLd3YW0sHWpCg4yR+DS5URwumFnUC6x7iG
xagNBJYtlsyMZuCuqZrI5JPB+CGZunqDwz0DLsJjiEBrPYSQnyMsMFti0c/QA1ls
kUzIGi3pj8bmM+xpRNvbMSTmW2QLWiG68SDW+Vux/Hzmt25i0+JppCE8afMebex+
kM+ZfXYXOs/kjlmb/on+zm8xZ9p7XEbAO3dnV8e5fmms7clZ5GewrdRXJYvXdo5o
xhn8UjSYBxhp3fjNttc+oAtNw6vTcgho9UUcQEpOnW163c9801b6OFE3XZq/SbIc
2QpWV7ruBubRsHN9tlpBQVQ/iEC3puQA+ONsoeBN/Zbmh/eEk60YNtAiKKag363w
yTCmBNzCe1hoyFng2h/FW7Be/XZJauCfQPooIiEztkl7to1DpRsZxj8FvOeJkFHz
JfQs0gHZQGa+kmCPKXBxpxPQnt5/fWj1O8qt0nOc0iatfHg8dH77gONmF4Ufq34f
ExiMMXIp0kpuu16XMDybHfYRiSi/2PEfkPjOabZDd0byWmt9YV23IrxpEmlEYKzT
8k2zCUC5VO4=
=I9E/
-----END PGP SIGNATURE-----

--=-4EYmXUfA4tE1deb3t7jD--

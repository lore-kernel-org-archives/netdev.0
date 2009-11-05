From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] pktgen: tx_bytes might be slightly wrong
Date: Thu, 05 Nov 2009 06:20:59 +0100
Message-ID: <4AF260BB.6070607@gmail.com>
References: <4AF236D1.7020006@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: NetDev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:36455 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751956AbZKEFU5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2009 00:20:57 -0500
In-Reply-To: <4AF236D1.7020006@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Ben Greear <greearb@candelatech.com>

Ben Greear a =E9crit :
> There is a subtle bug in pktgen tx_bytes accounting.
>=20
> If one is using clone_skb, then the cur_pkt_size may be modified
> without a new skb actually being created (quite yet) by setting
> min_pkt_size through the proc fs.
>=20
> I think if you just saved pkt_dev->skb->len before transmitting and u=
sed
> that to increment pkt_dev->tx_bytes that would fix the counter
> problem.
>=20
>     if (unlikely(netif_tx_queue_stopped(txq) ||
> netif_tx_queue_frozen(txq)))
>         ret =3D NETDEV_TX_BUSY;
>     else
>         ret =3D (*xmit)(pkt_dev->skb, odev);
>=20
>     switch (ret) {
>     case NETDEV_TX_OK:
>         txq_trans_update(txq);
>         pkt_dev->last_ok =3D 1;
>         pkt_dev->sofar++;
>         pkt_dev->seq_num++;
>         pkt_dev->tx_bytes +=3D pkt_dev->cur_pkt_size;
>         break;
>=20
>=20

Hi Ben

Nice catch :)

Note that clone_skb>0 makes the race window bigger, but its also racy f=
or clone_skb=3D0

Instead of storing pkt_dev->skb->len in a temporary variable,
we could store it in pkt_dev->last_pkt_size, it'll be a bit faster.

[PATCH net-next-2.6] pktgen: tx_bytes might be slightly wrong

cur_pkt_size can be changed in proc fs while pktgen is running,
we better use a private field to get precise tx-bytes counter.

Signed-off-by: Ben Greear <greearb@candelatech.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 5ce017b..d38470a 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -340,6 +340,7 @@ struct pktgen_dev {
 	__u16 cur_udp_src;
 	__u16 cur_queue_map;
 	__u32 cur_pkt_size;
+	__u32 last_pkt_size;
=20
 	__u8 hh[14];
 	/* =3D {
@@ -3434,7 +3435,7 @@ static void pktgen_xmit(struct pktgen_dev *pkt_de=
v)
 			pkt_dev->clone_count--;	/* back out increment, OOM */
 			return;
 		}
-
+		pkt_dev->last_pkt_size =3D pkt_dev->skb->len;
 		pkt_dev->allocated_skbs++;
 		pkt_dev->clone_count =3D 0;	/* reset counter */
 	}
@@ -3461,7 +3462,7 @@ static void pktgen_xmit(struct pktgen_dev *pkt_de=
v)
 		pkt_dev->last_ok =3D 1;
 		pkt_dev->sofar++;
 		pkt_dev->seq_num++;
-		pkt_dev->tx_bytes +=3D pkt_dev->cur_pkt_size;
+		pkt_dev->tx_bytes +=3D pkt_dev->last_pkt_size;
 		break;
 	default: /* Drivers are not supposed to return other values! */
 		if (net_ratelimit())

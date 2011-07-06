From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] veth: Kill unused tx_dropped
Date: Wed, 06 Jul 2011 10:17:20 +0200
Message-ID: <1309940240.2292.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20110705.234930.2282002049899864045.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:58590 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751622Ab1GFIRe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2011 04:17:34 -0400
Received: by wyg8 with SMTP id 8so4492741wyg.19
        for <netdev@vger.kernel.org>; Wed, 06 Jul 2011 01:17:33 -0700 (PDT)
In-Reply-To: <20110705.234930.2282002049899864045.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 05 juillet 2011 =C3=A0 23:49 -0700, David Miller a =C3=A9crit =
:

> -tx_drop:
> -	kfree_skb(skb);
> -	u64_stats_update_begin(&stats->syncp);
> -	stats->tx_dropped++;
> -	u64_stats_update_end(&stats->syncp);
> -	return NETDEV_TX_OK;
> -
>  rx_drop:
>  	u64_stats_update_begin(&rcv_stats->syncp);
>  	rcv_stats->rx_dropped++;


Then we should also kill tx_dropped from percpu stats ?

Here is a patch on top of yours

[PATCH] veth: Kill unused tx_dropped

=46ollowup to commit f82528bc13a (Exclude duplicated checking for
iface-up) : We no longer need percpu tx_dropped field.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/veth.c |    5 +----
 1 files changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 19e0b0c..7f78db7 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -30,7 +30,6 @@ struct veth_net_stats {
 	u64			rx_bytes;
 	u64			tx_bytes;
 	u64			rx_dropped;
-	u64			tx_dropped;
 	struct u64_stats_sync	syncp;
 };
=20
@@ -168,7 +167,7 @@ static struct rtnl_link_stats64 *veth_get_stats64(s=
truct net_device *dev,
 	for_each_possible_cpu(cpu) {
 		struct veth_net_stats *stats =3D per_cpu_ptr(priv->stats, cpu);
 		u64 rx_packets, rx_bytes, rx_dropped;
-		u64 tx_packets, tx_bytes, tx_dropped;
+		u64 tx_packets, tx_bytes;
 		unsigned int start;
=20
 		do {
@@ -178,14 +177,12 @@ static struct rtnl_link_stats64 *veth_get_stats64=
(struct net_device *dev,
 			rx_bytes =3D stats->rx_bytes;
 			tx_bytes =3D stats->tx_bytes;
 			rx_dropped =3D stats->rx_dropped;
-			tx_dropped =3D stats->tx_dropped;
 		} while (u64_stats_fetch_retry_bh(&stats->syncp, start));
 		tot->rx_packets +=3D rx_packets;
 		tot->tx_packets +=3D tx_packets;
 		tot->rx_bytes   +=3D rx_bytes;
 		tot->tx_bytes   +=3D tx_bytes;
 		tot->rx_dropped +=3D rx_dropped;
-		tot->tx_dropped +=3D tx_dropped;
 	}
=20
 	return tot;



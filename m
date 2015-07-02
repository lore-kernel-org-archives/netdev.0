From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] mlx4: TCP/UDP packets have L4 hash
Date: Thu, 02 Jul 2015 13:24:44 +0200
Message-ID: <1435836284.11970.16.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Amir Vadai <amirv@mellanox.com>,
	Ido Shamay <idos@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:35206 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751497AbbGBLYs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2015 07:24:48 -0400
Received: by wiga1 with SMTP id a1so149950195wig.0
        for <netdev@vger.kernel.org>; Thu, 02 Jul 2015 04:24:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Mellanox driver has the knowledge if rxhash is a L4 hash,
if it receives a non fragmented TCP or UDP frame and
NETIF_F_RXCSUM is enabled on netdev.

ip_summed value is CHECKSUM_UNNECESSARY in this case.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Amir Vadai <amirv@mellanox.com>
Cc: Ido Shamay <idos@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 7a4f20bb7fcb..12c65e1ad6a9 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -917,7 +917,9 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 			if (dev->features & NETIF_F_RXHASH)
 				skb_set_hash(gro_skb,
 					     be32_to_cpu(cqe->immed_rss_invalid),
-					     PKT_HASH_TYPE_L3);
+					     (ip_summed == CHECKSUM_UNNECESSARY) ?
+						PKT_HASH_TYPE_L4 :
+						PKT_HASH_TYPE_L3);
 
 			skb_record_rx_queue(gro_skb, cq->ring);
 			skb_mark_napi_id(gro_skb, &cq->napi);
@@ -963,7 +965,9 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 		if (dev->features & NETIF_F_RXHASH)
 			skb_set_hash(skb,
 				     be32_to_cpu(cqe->immed_rss_invalid),
-				     PKT_HASH_TYPE_L3);
+				     (ip_summed == CHECKSUM_UNNECESSARY) ?
+					PKT_HASH_TYPE_L4 :
+					PKT_HASH_TYPE_L3);
 
 		if ((be32_to_cpu(cqe->vlan_my_qpn) &
 		    MLX4_CQE_VLAN_PRESENT_MASK) &&

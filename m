From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 8/8] net/mlx5e: Count LRO packets correctly
Date: Tue, 21 Mar 2017 15:59:19 +0200
Message-ID: <20170321135919.25018-9-saeedm@mellanox.com>
References: <20170321135919.25018-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Gal Pressman <galp@mellanox.com>, kernel-team@fb.com,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:38175 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1757609AbdCUN7y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 09:59:54 -0400
In-Reply-To: <20170321135919.25018-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gal Pressman <galp@mellanox.com>

RX packets statistics ('rx_packets' counter) used to count LRO packets
as one, even though it contains multiple segments.
This patch will increment the counter by the number of segments, and
align the driver with the behavior of other drivers in the stack.

Note that no information is lost in this patch due to 'rx_lro_packets'
counter existence.

Before, ethtool showed:
$ ethtool -S ens6 | egrep "rx_packets|rx_lro_packets"
     rx_packets: 435277
     rx_lro_packets: 35847
     rx_packets_phy: 1935066

Now, we will see the more logical statistics:
$ ethtool -S ens6 | egrep "rx_packets|rx_lro_packets"
     rx_packets: 1935066
     rx_lro_packets: 35847
     rx_packets_phy: 1935066

Fixes: e586b3b0baee ("net/mlx5: Ethernet Datapath files")
Signed-off-by: Gal Pressman <galp@mellanox.com>
Cc: kernel-team@fb.com
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index 3d371688fbbb..bafcb349a50c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -601,6 +601,10 @@ static inline void mlx5e_build_rx_skb(struct mlx5_cqe64 *cqe,
 	if (lro_num_seg > 1) {
 		mlx5e_lro_update_hdr(skb, cqe, cqe_bcnt);
 		skb_shinfo(skb)->gso_size = DIV_ROUND_UP(cqe_bcnt, lro_num_seg);
+		/* Subtract one since we already counted this as one
+		 * "regular" packet in mlx5e_complete_rx_cqe()
+		 */
+		rq->stats.packets += lro_num_seg - 1;
 		rq->stats.lro_packets++;
 		rq->stats.lro_bytes += cqe_bcnt;
 	}
-- 
2.11.0

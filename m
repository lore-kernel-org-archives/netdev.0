From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 7/8] net/mlx5e: Count GSO packets correctly
Date: Tue, 21 Mar 2017 15:59:18 +0200
Message-ID: <20170321135919.25018-8-saeedm@mellanox.com>
References: <20170321135919.25018-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Gal Pressman <galp@mellanox.com>, kernel-team@fb.com,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:38166 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1757611AbdCUN7y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 09:59:54 -0400
In-Reply-To: <20170321135919.25018-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gal Pressman <galp@mellanox.com>

TX packets statistics ('tx_packets' counter) used to count GSO packets
as one, even though it contains multiple segments.
This patch will increment the counter by the number of segments, and
align the driver with the behavior of other drivers in the stack.

Note that no information is lost in this patch due to 'tx_tso_packets'
counter existence.

Before, ethtool showed:
$ ethtool -S ens6 | egrep "tx_packets|tx_tso_packets"
     tx_packets: 61340
     tx_tso_packets: 60954
     tx_packets_phy: 2451115

Now, we will see the more logical statistics:
$ ethtool -S ens6 | egrep "tx_packets|tx_tso_packets"
     tx_packets: 2451115
     tx_tso_packets: 60954
     tx_packets_phy: 2451115

Fixes: e586b3b0baee ("net/mlx5: Ethernet Datapath files")
Signed-off-by: Gal Pressman <galp@mellanox.com>
Cc: kernel-team@fb.com
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
index f193128bac4b..57f5e2d7ebd1 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
@@ -274,15 +274,18 @@ static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_sq *sq, struct sk_buff *skb)
 			sq->stats.tso_bytes += skb->len - ihs;
 		}
 
+		sq->stats.packets += skb_shinfo(skb)->gso_segs;
 		num_bytes = skb->len + (skb_shinfo(skb)->gso_segs - 1) * ihs;
 	} else {
 		bf = sq->bf_budget &&
 		     !skb->xmit_more &&
 		     !skb_shinfo(skb)->nr_frags;
 		ihs = mlx5e_get_inline_hdr_size(sq, skb, bf);
+		sq->stats.packets++;
 		num_bytes = max_t(unsigned int, skb->len, ETH_ZLEN);
 	}
 
+	sq->stats.bytes += num_bytes;
 	wi->num_bytes = num_bytes;
 
 	ds_cnt = sizeof(*wqe) / MLX5_SEND_WQE_DS;
@@ -381,8 +384,6 @@ static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_sq *sq, struct sk_buff *skb)
 	if (bf)
 		sq->bf_budget--;
 
-	sq->stats.packets++;
-	sq->stats.bytes += num_bytes;
 	return NETDEV_TX_OK;
 
 dma_unmap_wqe_err:
-- 
2.11.0

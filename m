From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 04/12] net/mlx5e: Use skb_shinfo(skb)->gso_segs rather than counting them
Date: Wed, 17 Jun 2015 18:26:21 +0300
Message-ID: <1434554789-13758-5-git-send-email-ogerlitz@mellanox.com>
References: <1434554789-13758-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:53977 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756776AbbFQP1I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jun 2015 11:27:08 -0400
In-Reply-To: <1434554789-13758-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>

Instead of counting number of gso fragments, we can use
skb_shinfo(skb)->gso_segs.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
index 471babd..c0566b6 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
@@ -143,16 +143,13 @@ static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_sq *sq, struct sk_buff *skb)
 
 	if (skb_is_gso(skb)) {
 		u32 payload_len;
-		int num_pkts;
 
 		eseg->mss    = cpu_to_be16(skb_shinfo(skb)->gso_size);
 		opcode       = MLX5_OPCODE_LSO;
 		ihs          = skb_transport_offset(skb) + tcp_hdrlen(skb);
 		payload_len  = skb->len - ihs;
-		num_pkts     =    (payload_len / skb_shinfo(skb)->gso_size) +
-				!!(payload_len % skb_shinfo(skb)->gso_size);
 		MLX5E_TX_SKB_CB(skb)->num_bytes = skb->len +
-						  (num_pkts - 1) * ihs;
+					(skb_shinfo(skb)->gso_segs - 1) * ihs;
 		sq->stats.tso_packets++;
 		sq->stats.tso_bytes += payload_len;
 	} else {
-- 
2.3.7

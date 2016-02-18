From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V1 11/12] net/mlx5e: Add TX stateless offloads for tunneling
Date: Thu, 18 Feb 2016 12:32:52 +0200
Message-ID: <1455791573-5270-12-git-send-email-saeedm@mellanox.com>
References: <1455791573-5270-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Rana Shahout <ranas@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Matthew Finlay <matt@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:34168 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1945989AbcBRKlx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Feb 2016 05:41:53 -0500
In-Reply-To: <1455791573-5270-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Finlay <matt@mellanox.com>

Add support for TSO and TX checksum when using hw assisted,
tunneled offloads.

Signed-off-by: Matt Finlay <matt@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c |   22 ++++++++++++++++------
 1 files changed, 16 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
index 00d855a..6ce2884 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2015, Mellanox Technologies. All rights reserved.
+ * Copyright (c) 2015-2016, Mellanox Technologies. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
@@ -185,9 +185,14 @@ static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_sq *sq, struct sk_buff *skb)
 
 	memset(wqe, 0, sizeof(*wqe));
 
-	if (likely(skb->ip_summed == CHECKSUM_PARTIAL))
-		eseg->cs_flags	= MLX5_ETH_WQE_L3_CSUM | MLX5_ETH_WQE_L4_CSUM;
-	else
+	if (likely(skb->ip_summed == CHECKSUM_PARTIAL)) {
+		eseg->cs_flags = MLX5_ETH_WQE_L3_CSUM;
+		if (skb->encapsulation)
+			eseg->cs_flags |= MLX5_ETH_WQE_L3_INNER_CSUM |
+					  MLX5_ETH_WQE_L4_INNER_CSUM;
+		else
+			eseg->cs_flags |= MLX5_ETH_WQE_L4_CSUM;
+	} else
 		sq->stats.csum_offload_none++;
 
 	if (sq->cc != sq->prev_cc) {
@@ -200,8 +205,13 @@ static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_sq *sq, struct sk_buff *skb)
 
 		eseg->mss    = cpu_to_be16(skb_shinfo(skb)->gso_size);
 		opcode       = MLX5_OPCODE_LSO;
-		ihs          = skb_transport_offset(skb) + tcp_hdrlen(skb);
-		payload_len  = skb->len - ihs;
+
+		if (skb->encapsulation)
+			ihs = skb_inner_transport_offset(skb) + inner_tcp_hdrlen(skb);
+		else
+			ihs = skb_transport_offset(skb) + tcp_hdrlen(skb);
+
+		payload_len   = skb->len - ihs;
 		wi->num_bytes = skb->len +
 				(skb_shinfo(skb)->gso_segs - 1) * ihs;
 		sq->stats.tso_packets++;
-- 
1.7.1

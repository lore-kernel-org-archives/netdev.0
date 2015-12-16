From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 1/2] net/mlx5_en: Restore the skb data pointer after xmit is finished
Date: Wed, 16 Dec 2015 18:46:33 +0200
Message-ID: <1450284394-32386-2-git-send-email-saeedm@mellanox.com>
References: <1450284394-32386-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:51495 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S933012AbbLPQrE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Dec 2015 11:47:04 -0500
In-Reply-To: <1450284394-32386-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eran Ben Elisha <eranbe@mellanox.com>

Restore the skb data pointer after coping the data to the HW, so the skb
can be cloned with correct headers for future use (e.g timestamping).

Fixes: e586b3b0baee ("net/mlx5: Ethernet Datapath files")
Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
index 1341b1d..0fcfe64 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
@@ -165,6 +165,7 @@ static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_sq *sq, struct sk_buff *skb)
 	struct mlx5_wqe_eth_seg  *eseg = &wqe->eth;
 	struct mlx5_wqe_data_seg *dseg;
 
+	unsigned char *skb_data_orig = skb->data;
 	u8  opcode = MLX5_OPCODE_SEND;
 	dma_addr_t dma_addr = 0;
 	bool bf = false;
@@ -263,6 +264,7 @@ static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_sq *sq, struct sk_buff *skb)
 	cseg->opmod_idx_opcode = cpu_to_be32((sq->pc << 8) | opcode);
 	cseg->qpn_ds           = cpu_to_be32((sq->sqn << 8) | ds_cnt);
 
+	skb_push(skb, skb->data - skb_data_orig);
 	sq->skb[pi] = skb;
 
 	MLX5E_TX_SKB_CB(skb)->num_wqebbs = DIV_ROUND_UP(ds_cnt,
-- 
1.7.1

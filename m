From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 2/3] net/mlx4_en: Notify user when TX ring in error state
Date: Mon, 19 Aug 2013 09:42:21 +0300
Message-ID: <1376894542-27854-3-git-send-email-amirv@mellanox.com>
References: <1376894542-27854-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:42175 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750989Ab3HSGmu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Aug 2013 02:42:50 -0400
In-Reply-To: <1376894542-27854-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When hardware gets into error state, must notify user about it.
When QP in error state no traffic will be tx'ed from the attached
tx_ring.

Driver should know how to recover from this unexpected state. I will send later
on the recovery flow, but having the print shouldn't be delayed.

Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 6dcca98..157bcd1 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -362,6 +362,14 @@ static void mlx4_en_process_tx_cq(struct net_device *dev, struct mlx4_en_cq *cq)
 		 */
 		rmb();
 
+		if (unlikely((cqe->owner_sr_opcode & MLX4_CQE_OPCODE_MASK) ==
+			     MLX4_CQE_OPCODE_ERROR)) {
+			struct mlx4_err_cqe *cqe_err = (struct mlx4_err_cqe *)cqe;
+			en_err(priv, "CQE error - vendor syndrom: 0x%x syndrom: 0x%x\n",
+			       cqe_err->vendor_err_syndrome,
+			       cqe_err->syndrome);
+		}
+
 		/* Skip over last polled CQE */
 		new_index = be16_to_cpu(cqe->wqe_index) & size_mask;
 
-- 
1.8.3.4

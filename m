From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 1/7] net/mlx4_core: Fix mpt_entry initialization in mlx4_mr_rereg_mem_write()
Date: Tue,  3 Feb 2015 17:57:15 +0200
Message-ID: <1422979041-25208-2-git-send-email-amirv@mellanox.com>
References: <1422979041-25208-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Maor Gottlieb <maorg@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:40264 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756053AbbBCP6G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Feb 2015 10:58:06 -0500
In-Reply-To: <1422979041-25208-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maor Gottlieb <maorg@mellanox.com>

a) Previously, mlx4_mr_rereg_write filled the MPT's start
   and length with the old MPT's values.
   Fixing the initialization to take the new start and length.

b) In addition access flags in mpt_status were initialized instead of
   status due to bad boolean operation. Fixing the operation.

c) Initialization of pd_slave caused a protection error.
   Fix - removing this initialization.

d) In resource_tracker.c: Fixing vf encoding to be one-based.

Fixes: e630664c ('mlx4_core: Add helper functions to support MR re-registration')
Signed-off-by: Maor Gottlieb <maorg@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/mr.c               | 13 +++++--------
 drivers/net/ethernet/mellanox/mlx4/resource_tracker.c |  2 +-
 2 files changed, 6 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/mr.c b/drivers/net/ethernet/mellanox/mlx4/mr.c
index d21e884..78f51e1 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mr.c
+++ b/drivers/net/ethernet/mellanox/mlx4/mr.c
@@ -598,14 +598,11 @@ int mlx4_mr_rereg_mem_write(struct mlx4_dev *dev, struct mlx4_mr *mr,
 	if (err)
 		return err;
 
-	mpt_entry->start       = cpu_to_be64(mr->iova);
-	mpt_entry->length      = cpu_to_be64(mr->size);
-	mpt_entry->entity_size = cpu_to_be32(mr->mtt.page_shift);
-
-	mpt_entry->pd_flags &= cpu_to_be32(MLX4_MPT_PD_MASK |
-					   MLX4_MPT_PD_FLAG_EN_INV);
-	mpt_entry->flags    &= cpu_to_be32(MLX4_MPT_FLAG_FREE |
-					   MLX4_MPT_FLAG_SW_OWNS);
+	mpt_entry->start       = cpu_to_be64(iova);
+	mpt_entry->length      = cpu_to_be64(size);
+	mpt_entry->entity_size = cpu_to_be32(page_shift);
+	mpt_entry->flags    &= ~(cpu_to_be32(MLX4_MPT_FLAG_FREE |
+					   MLX4_MPT_FLAG_SW_OWNS));
 	if (mr->mtt.order < 0) {
 		mpt_entry->flags |= cpu_to_be32(MLX4_MPT_FLAG_PHYSICAL);
 		mpt_entry->mtt_addr = 0;
diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index 79feeb6..628c2e8 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -2541,7 +2541,7 @@ int mlx4_SW2HW_MPT_wrapper(struct mlx4_dev *dev, int slave,
 	/* Make sure that the PD bits related to the slave id are zeros. */
 	pd = mr_get_pd(inbox->buf);
 	pd_slave = (pd >> 17) & 0x7f;
-	if (pd_slave != 0 && pd_slave != slave) {
+	if (pd_slave != 0 && --pd_slave != slave) {
 		err = -EPERM;
 		goto ex_abort;
 	}
-- 
1.9.3

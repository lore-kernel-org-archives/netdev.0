From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH net-next 7/8] net/mlx4: remove unused functions
Date: Tue, 6 Mar 2012 16:04:54 +0200
Message-ID: <4F561986.4010400@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog119.obsmtp.com ([207.126.144.147]:39296 "HELO
	eu1sys200aog119.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1030359Ab2CFOFB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2012 09:05:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

Removing functions that are no longer in use, but still exist

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/fw.c |   10 ----
 drivers/net/ethernet/mellanox/mlx4/mr.c |   75 -------------------------------
 2 files changed, 0 insertions(+), 85 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 9ea7cab..2a02ba5 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -685,16 +685,6 @@ int mlx4_QUERY_PORT_wrapper(struct mlx4_dev *dev, int slave,
 	return err;
 }
 
-int mlx4_QUERY_PORT(struct mlx4_dev *dev, void *ptr, u8 port)
-{
-	struct mlx4_cmd_mailbox *outbox = ptr;
-
-	return mlx4_cmd_box(dev, 0, outbox->dma, port, 0,
-			    MLX4_CMD_QUERY_PORT, MLX4_CMD_TIME_CLASS_B,
-			    MLX4_CMD_WRAPPED);
-}
-EXPORT_SYMBOL_GPL(mlx4_QUERY_PORT);
-
 int mlx4_map_cmd(struct mlx4_dev *dev, u16 op, struct mlx4_icm *icm, u64 virt)
 {
 	struct mlx4_cmd_mailbox *mailbox;
diff --git a/drivers/net/ethernet/mellanox/mlx4/mr.c b/drivers/net/ethernet/mellanox/mlx4/mr.c
index 25a80d7..9f693e1 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mr.c
+++ b/drivers/net/ethernet/mellanox/mlx4/mr.c
@@ -304,29 +304,6 @@ static int mlx4_HW2SW_MPT(struct mlx4_dev *dev, struct mlx4_cmd_mailbox *mailbox
 			    MLX4_CMD_TIME_CLASS_B, MLX4_CMD_WRAPPED);
 }
 
-int mlx4_mr_reserve_range(struct mlx4_dev *dev, int cnt, int align,
-			  u32 *base_mridx)
-{
-	struct mlx4_priv *priv = mlx4_priv(dev);
-	u32 mridx;
-
-	mridx = mlx4_bitmap_alloc_range(&priv->mr_table.mpt_bitmap, cnt, align);
-	if (mridx == -1)
-		return -ENOMEM;
-
-	*base_mridx = mridx;
-	return 0;
-
-}
-EXPORT_SYMBOL_GPL(mlx4_mr_reserve_range);
-
-void mlx4_mr_release_range(struct mlx4_dev *dev, u32 base_mridx, int cnt)
-{
-	struct mlx4_priv *priv = mlx4_priv(dev);
-	mlx4_bitmap_free_range(&priv->mr_table.mpt_bitmap, base_mridx, cnt);
-}
-EXPORT_SYMBOL_GPL(mlx4_mr_release_range);
-
 int mlx4_mr_alloc_reserved(struct mlx4_dev *dev, u32 mridx, u32 pd,
 			   u64 iova, u64 size, u32 access, int npages,
 			   int page_shift, struct mlx4_mr *mr)
@@ -852,46 +829,6 @@ err_free:
 }
 EXPORT_SYMBOL_GPL(mlx4_fmr_alloc);
 
-int mlx4_fmr_alloc_reserved(struct mlx4_dev *dev, u32 mridx,
-			    u32 pd, u32 access, int max_pages,
-			    int max_maps, u8 page_shift, struct mlx4_fmr *fmr)
-{
-	struct mlx4_priv *priv = mlx4_priv(dev);
-	int err = -ENOMEM;
-
-	if (page_shift < (ffs(dev->caps.page_size_cap) - 1) || page_shift >= 32)
-		return -EINVAL;
-
-	/* All MTTs must fit in the same page */
-	if (max_pages * sizeof *fmr->mtts > PAGE_SIZE)
-		return -EINVAL;
-
-	fmr->page_shift = page_shift;
-	fmr->max_pages  = max_pages;
-	fmr->max_maps   = max_maps;
-	fmr->maps = 0;
-
-	err = mlx4_mr_alloc_reserved(dev, mridx, pd, 0, 0, access, max_pages,
-				     page_shift, &fmr->mr);
-	if (err)
-		return err;
-
-	fmr->mtts = mlx4_table_find(&priv->mr_table.mtt_table,
-				    fmr->mr.mtt.offset,
-				    &fmr->dma_handle);
-	if (!fmr->mtts) {
-		err = -ENOMEM;
-		goto err_free;
-	}
-
-	return 0;
-
-err_free:
-	mlx4_mr_free_reserved(dev, &fmr->mr);
-	return err;
-}
-EXPORT_SYMBOL_GPL(mlx4_fmr_alloc_reserved);
-
 int mlx4_fmr_enable(struct mlx4_dev *dev, struct mlx4_fmr *fmr)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
@@ -954,18 +891,6 @@ int mlx4_fmr_free(struct mlx4_dev *dev, struct mlx4_fmr *fmr)
 }
 EXPORT_SYMBOL_GPL(mlx4_fmr_free);
 
-int mlx4_fmr_free_reserved(struct mlx4_dev *dev, struct mlx4_fmr *fmr)
-{
-	if (fmr->maps)
-		return -EBUSY;
-
-	mlx4_mr_free_reserved(dev, &fmr->mr);
-	fmr->mr.enabled = MLX4_MR_DISABLED;
-
-	return 0;
-}
-EXPORT_SYMBOL_GPL(mlx4_fmr_free_reserved);
-
 int mlx4_SYNC_TPT(struct mlx4_dev *dev)
 {
 	return mlx4_cmd(dev, 0, 0, 0, MLX4_CMD_SYNC_TPT, 1000,
-- 
1.7.7

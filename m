From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V2 9/9] net/mlx5: Fix global UAR mapping
Date: Tue,  1 Mar 2016 17:42:22 +0200
Message-ID: <1456846942-15082-10-git-send-email-saeedm@mellanox.com>
References: <1456846942-15082-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Majd Dibbiny <majd@mellanox.com>,
	Moshe Lazer <moshel@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:50656 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754157AbcCAPrA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Mar 2016 10:47:00 -0500
In-Reply-To: <1456846942-15082-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Moshe Lazer <moshel@mellanox.com>

Avoid double mapping of io mapped memory, Device page may be
mapped to non-cached(NC) or to write-combining(WC).
The code before this fix tries to map it both to WC and NC
contrary to what stated in Intel's software developer manual.

Here we remove the global WC mapping of all UARS
"dev->priv.bf_mapping", since UAR mapping should be decided
per UAR (e.g we want different mappings for EQs, CQs vs QPs).

Caller will now have to choose whether to map via
write-combining API or not.

mlx5e SQs will choose write-combining in order to perform
BlueFlame writes.

Fixes: 88a85f99e51f ('TX latency optimization to save DMA reads')
Signed-off-by: Moshe Lazer <moshel@mellanox.com>
Reviewed-by: Achiad Shochat <achiad@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |   16 ++++-------
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |   12 ++++++---
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c   |    2 +-
 drivers/net/ethernet/mellanox/mlx5/core/main.c    |   28 +-------------------
 drivers/net/ethernet/mellanox/mlx5/core/uar.c     |   29 +++++++++++++--------
 include/linux/mlx5/driver.h                       |    5 +--
 6 files changed, 36 insertions(+), 56 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index b289660..9c0e80e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -388,6 +388,7 @@ struct mlx5e_sq_dma {
 
 enum {
 	MLX5E_SQ_STATE_WAKE_TXQ_ENABLE,
+	MLX5E_SQ_STATE_BF_ENABLE,
 };
 
 struct mlx5e_sq {
@@ -416,7 +417,6 @@ struct mlx5e_sq {
 	struct mlx5_wq_cyc         wq;
 	u32                        dma_fifo_mask;
 	void __iomem              *uar_map;
-	void __iomem              *uar_bf_map;
 	struct netdev_queue       *txq;
 	u32                        sqn;
 	u16                        bf_buf_size;
@@ -664,16 +664,12 @@ static inline void mlx5e_tx_notify_hw(struct mlx5e_sq *sq,
 	 * doorbell
 	 */
 	wmb();
-
-	if (bf_sz) {
-		__iowrite64_copy(sq->uar_bf_map + ofst, &wqe->ctrl, bf_sz);
-
-		/* flush the write-combining mapped buffer */
-		wmb();
-
-	} else {
+	if (bf_sz)
+		__iowrite64_copy(sq->uar_map + ofst, &wqe->ctrl, bf_sz);
+	else
 		mlx5_write64((__be32 *)&wqe->ctrl, sq->uar_map + ofst, NULL);
-	}
+	/* flush the write-combining mapped buffer */
+	wmb();
 
 	sq->bf_offset ^= sq->bf_buf_size;
 }
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index b20a35b..5063c0e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -548,7 +548,7 @@ static int mlx5e_create_sq(struct mlx5e_channel *c,
 	int txq_ix;
 	int err;
 
-	err = mlx5_alloc_map_uar(mdev, &sq->uar);
+	err = mlx5_alloc_map_uar(mdev, &sq->uar, true);
 	if (err)
 		return err;
 
@@ -560,8 +560,12 @@ static int mlx5e_create_sq(struct mlx5e_channel *c,
 		goto err_unmap_free_uar;
 
 	sq->wq.db       = &sq->wq.db[MLX5_SND_DBR];
-	sq->uar_map     = sq->uar.map;
-	sq->uar_bf_map  = sq->uar.bf_map;
+	if (sq->uar.bf_map) {
+		set_bit(MLX5E_SQ_STATE_BF_ENABLE, &sq->state);
+		sq->uar_map = sq->uar.bf_map;
+	} else {
+		sq->uar_map = sq->uar.map;
+	}
 	sq->bf_buf_size = (1 << MLX5_CAP_GEN(mdev, log_bf_reg_size)) / 2;
 	sq->max_inline  = param->max_inline;
 
@@ -2418,7 +2422,7 @@ static void *mlx5e_create_netdev(struct mlx5_core_dev *mdev)
 
 	priv = netdev_priv(netdev);
 
-	err = mlx5_alloc_map_uar(mdev, &priv->cq_uar);
+	err = mlx5_alloc_map_uar(mdev, &priv->cq_uar, false);
 	if (err) {
 		mlx5_core_err(mdev, "alloc_map uar failed, %d\n", err);
 		goto err_free_netdev;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
index a05c070..c34f4f3 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
@@ -303,7 +303,7 @@ static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_sq *sq, struct sk_buff *skb)
 	if (!skb->xmit_more || netif_xmit_stopped(sq->txq)) {
 		int bf_sz = 0;
 
-		if (bf && sq->uar_bf_map)
+		if (bf && test_bit(MLX5E_SQ_STATE_BF_ENABLE, &sq->state))
 			bf_sz = wi->num_wqebbs << 3;
 
 		cseg->fm_ce_se = MLX5_WQE_CTRL_CQ_UPDATE;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index 1545a94..8b7133d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -767,22 +767,6 @@ static int mlx5_core_set_issi(struct mlx5_core_dev *dev)
 	return -ENOTSUPP;
 }
 
-static int map_bf_area(struct mlx5_core_dev *dev)
-{
-	resource_size_t bf_start = pci_resource_start(dev->pdev, 0);
-	resource_size_t bf_len = pci_resource_len(dev->pdev, 0);
-
-	dev->priv.bf_mapping = io_mapping_create_wc(bf_start, bf_len);
-
-	return dev->priv.bf_mapping ? 0 : -ENOMEM;
-}
-
-static void unmap_bf_area(struct mlx5_core_dev *dev)
-{
-	if (dev->priv.bf_mapping)
-		io_mapping_free(dev->priv.bf_mapping);
-}
-
 static void mlx5_add_device(struct mlx5_interface *intf, struct mlx5_priv *priv)
 {
 	struct mlx5_device_context *dev_ctx;
@@ -1103,14 +1087,9 @@ static int mlx5_load_one(struct mlx5_core_dev *dev, struct mlx5_priv *priv)
 		goto err_stop_eqs;
 	}
 
-	if (map_bf_area(dev))
-		dev_err(&pdev->dev, "Failed to map blue flame area\n");
-
 	err = mlx5_irq_set_affinity_hints(dev);
-	if (err) {
+	if (err)
 		dev_err(&pdev->dev, "Failed to alloc affinity hint cpumask\n");
-		goto err_unmap_bf_area;
-	}
 
 	MLX5_INIT_DOORBELL_LOCK(&priv->cq_uar_lock);
 
@@ -1169,10 +1148,6 @@ err_fs:
 	mlx5_cleanup_qp_table(dev);
 	mlx5_cleanup_cq_table(dev);
 	mlx5_irq_clear_affinity_hints(dev);
-
-err_unmap_bf_area:
-	unmap_bf_area(dev);
-
 	free_comp_eqs(dev);
 
 err_stop_eqs:
@@ -1242,7 +1217,6 @@ static int mlx5_unload_one(struct mlx5_core_dev *dev, struct mlx5_priv *priv)
 	mlx5_cleanup_qp_table(dev);
 	mlx5_cleanup_cq_table(dev);
 	mlx5_irq_clear_affinity_hints(dev);
-	unmap_bf_area(dev);
 	free_comp_eqs(dev);
 	mlx5_stop_eqs(dev);
 	mlx5_free_uuars(dev, &priv->uuari);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/uar.c b/drivers/net/ethernet/mellanox/mlx5/core/uar.c
index eb05c84..8ba080e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/uar.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/uar.c
@@ -226,7 +226,8 @@ int mlx5_free_uuars(struct mlx5_core_dev *dev, struct mlx5_uuar_info *uuari)
 	return 0;
 }
 
-int mlx5_alloc_map_uar(struct mlx5_core_dev *mdev, struct mlx5_uar *uar)
+int mlx5_alloc_map_uar(struct mlx5_core_dev *mdev, struct mlx5_uar *uar,
+		       bool map_wc)
 {
 	phys_addr_t pfn;
 	phys_addr_t uar_bar_start;
@@ -240,20 +241,26 @@ int mlx5_alloc_map_uar(struct mlx5_core_dev *mdev, struct mlx5_uar *uar)
 
 	uar_bar_start = pci_resource_start(mdev->pdev, 0);
 	pfn           = (uar_bar_start >> PAGE_SHIFT) + uar->index;
-	uar->map      = ioremap(pfn << PAGE_SHIFT, PAGE_SIZE);
-	if (!uar->map) {
-		mlx5_core_warn(mdev, "ioremap() failed, %d\n", err);
-		err = -ENOMEM;
-		goto err_free_uar;
-	}
 
-	if (mdev->priv.bf_mapping)
-		uar->bf_map = io_mapping_map_wc(mdev->priv.bf_mapping,
-						uar->index << PAGE_SHIFT);
+	if (map_wc) {
+		uar->bf_map = ioremap_wc(pfn << PAGE_SHIFT, PAGE_SIZE);
+		if (!uar->bf_map) {
+			mlx5_core_warn(mdev, "ioremap_wc() failed\n");
+			uar->map = ioremap(pfn << PAGE_SHIFT, PAGE_SIZE);
+			if (!uar->map)
+				goto err_free_uar;
+		}
+	} else {
+		uar->map = ioremap(pfn << PAGE_SHIFT, PAGE_SIZE);
+		if (!uar->map)
+			goto err_free_uar;
+	}
 
 	return 0;
 
 err_free_uar:
+	mlx5_core_warn(mdev, "ioremap() failed\n");
+	err = -ENOMEM;
 	mlx5_cmd_free_uar(mdev, uar->index);
 
 	return err;
@@ -262,8 +269,8 @@ EXPORT_SYMBOL(mlx5_alloc_map_uar);
 
 void mlx5_unmap_free_uar(struct mlx5_core_dev *mdev, struct mlx5_uar *uar)
 {
-	io_mapping_unmap(uar->bf_map);
 	iounmap(uar->map);
+	iounmap(uar->bf_map);
 	mlx5_cmd_free_uar(mdev, uar->index);
 }
 EXPORT_SYMBOL(mlx5_unmap_free_uar);
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index 3388a43..bb1a880 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -460,8 +460,6 @@ struct mlx5_priv {
 	struct mlx5_uuar_info	uuari;
 	MLX5_DECLARE_DOORBELL_LOCK(cq_uar_lock);
 
-	struct io_mapping	*bf_mapping;
-
 	/* pages stuff */
 	struct workqueue_struct *pg_wq;
 	struct rb_root		page_root;
@@ -719,7 +717,8 @@ int mlx5_cmd_alloc_uar(struct mlx5_core_dev *dev, u32 *uarn);
 int mlx5_cmd_free_uar(struct mlx5_core_dev *dev, u32 uarn);
 int mlx5_alloc_uuars(struct mlx5_core_dev *dev, struct mlx5_uuar_info *uuari);
 int mlx5_free_uuars(struct mlx5_core_dev *dev, struct mlx5_uuar_info *uuari);
-int mlx5_alloc_map_uar(struct mlx5_core_dev *mdev, struct mlx5_uar *uar);
+int mlx5_alloc_map_uar(struct mlx5_core_dev *mdev, struct mlx5_uar *uar,
+		       bool map_wc);
 void mlx5_unmap_free_uar(struct mlx5_core_dev *mdev, struct mlx5_uar *uar);
 void mlx5_health_cleanup(struct mlx5_core_dev *dev);
 int mlx5_health_init(struct mlx5_core_dev *dev);
-- 
1.7.1

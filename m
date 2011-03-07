From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 13/17] mlx4: Add blue flame support for kernel consumers
Date: Mon, 7 Mar 2011 12:17:54 +0200
Message-ID: <4D74B0D2.1000907@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>,
	<eli@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:40347 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755386Ab1CGKR4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Mar 2011 05:17:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eli Cohen <eli@mellanox.co.il>

Using blue flame can improve latency by allowing the HW to more efficiently
access the WQE. This patch presents two functions that are used to allocate or
release HW resources for using blue flame; the caller need to supply a struct
mlx4_bf object when allocating resources. Consumers that make use of this API
should post doorbells to the UAR object pointed by the initialized struct
mlx4_bf;

Signed-off-by: Eli Cohen <eli@mellanox.co.il>
Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/main.c     |   31 ++++++++++++++
 drivers/net/mlx4/mlx4.h     |    3 +
 drivers/net/mlx4/pd.c       |   94 +++++++++++++++++++++++++++++++++++++++++++
 include/linux/mlx4/device.h |   13 ++++++
 include/linux/mlx4/qp.h     |    1 +
 5 files changed, 142 insertions(+), 0 deletions(-)

diff --git a/drivers/net/mlx4/main.c b/drivers/net/mlx4/main.c
index c8e2761..34581d2 100644
--- a/drivers/net/mlx4/main.c
+++ b/drivers/net/mlx4/main.c
@@ -39,6 +39,7 @@
 #include <linux/pci.h>
 #include <linux/dma-mapping.h>
 #include <linux/slab.h>
+#include <linux/io-mapping.h>
 
 #include <linux/mlx4/device.h>
 #include <linux/mlx4/doorbell.h>
@@ -721,8 +722,31 @@ static void mlx4_free_icms(struct mlx4_dev *dev)
 	mlx4_free_icm(dev, priv->fw.aux_icm, 0);
 }
 
+static int map_bf_area(struct mlx4_dev *dev)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	resource_size_t bf_start;
+	resource_size_t bf_len;
+	int err = 0;
+
+	bf_start = pci_resource_start(dev->pdev, 2) + (dev->caps.num_uars << PAGE_SHIFT);
+	bf_len = pci_resource_len(dev->pdev, 2) - (dev->caps.num_uars << PAGE_SHIFT);
+	priv->bf_mapping = io_mapping_create_wc(bf_start, bf_len);
+	if (!priv->bf_mapping)
+		err = -ENOMEM;
+
+	return err;
+}
+
+static void unmap_bf_area(struct mlx4_dev *dev)
+{
+	if (mlx4_priv(dev)->bf_mapping)
+		io_mapping_free(mlx4_priv(dev)->bf_mapping);
+}
+
 static void mlx4_close_hca(struct mlx4_dev *dev)
 {
+	unmap_bf_area(dev);
 	mlx4_CLOSE_HCA(dev, 0);
 	mlx4_free_icms(dev);
 	mlx4_UNMAP_FA(dev);
@@ -775,6 +799,9 @@ static int mlx4_init_hca(struct mlx4_dev *dev)
 		goto err_stop_fw;
 	}
 
+	if (map_bf_area(dev))
+		mlx4_dbg(dev, "Kernel support for blue flame is not available for kernels < 2.6.28\n");
+
 	init_hca.log_uar_sz = ilog2(dev->caps.num_uars);
 
 	err = mlx4_init_icm(dev, &dev_cap, &init_hca, icm_size);
@@ -805,6 +832,7 @@ err_free_icm:
 	mlx4_free_icms(dev);
 
 err_stop_fw:
+	unmap_bf_area(dev);
 	mlx4_UNMAP_FA(dev);
 	mlx4_free_icm(dev, priv->fw.fw_icm, 0);
 
@@ -1196,6 +1224,9 @@ static int __mlx4_init_one(struct pci_dev *pdev, const struct pci_device_id *id)
 
 	pci_read_config_byte(pdev, PCI_REVISION_ID, &dev->rev_id);
 
+	INIT_LIST_HEAD(&priv->bf_list);
+	mutex_init(&priv->bf_mutex);
+
 	/*
 	 * Now reset the HCA before we touch the PCI capabilities or
 	 * attempt a firmware command, since a boot ROM may have left
diff --git a/drivers/net/mlx4/mlx4.h b/drivers/net/mlx4/mlx4.h
index a50923a..008bf95 100644
--- a/drivers/net/mlx4/mlx4.h
+++ b/drivers/net/mlx4/mlx4.h
@@ -353,6 +353,9 @@ struct mlx4_priv {
 	struct mutex		port_mutex;
 	struct mlx4_msix_ctl	msix_ctl;
 	struct mlx4_steer	*steer;
+	struct list_head	bf_list;
+	struct mutex		bf_mutex;
+	struct io_mapping	*bf_mapping;
 };
 
 static inline struct mlx4_priv *mlx4_priv(struct mlx4_dev *dev)
diff --git a/drivers/net/mlx4/pd.c b/drivers/net/mlx4/pd.c
index c4988d6..5210a0f 100644
--- a/drivers/net/mlx4/pd.c
+++ b/drivers/net/mlx4/pd.c
@@ -32,6 +32,7 @@
  */
 
 #include <linux/errno.h>
+#include <linux/io-mapping.h>
 
 #include <asm/page.h>
 
@@ -77,6 +78,7 @@ int mlx4_uar_alloc(struct mlx4_dev *dev, struct mlx4_uar *uar)
 		return -ENOMEM;
 
 	uar->pfn = (pci_resource_start(dev->pdev, 2) >> PAGE_SHIFT) + uar->index;
+	uar->map = NULL;
 
 	return 0;
 }
@@ -88,6 +90,98 @@ void mlx4_uar_free(struct mlx4_dev *dev, struct mlx4_uar *uar)
 }
 EXPORT_SYMBOL_GPL(mlx4_uar_free);
 
+int mlx4_bf_alloc(struct mlx4_dev *dev, struct mlx4_bf *bf)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	struct mlx4_uar *uar;
+	int err = 0;
+	int idx;
+
+	if (!priv->bf_mapping)
+		return -ENOMEM;
+
+	mutex_lock(&priv->bf_mutex);
+	if (!list_empty(&priv->bf_list))
+		uar = list_entry(priv->bf_list.next, struct mlx4_uar, bf_list);
+	else {
+		uar = kmalloc(sizeof *uar, GFP_KERNEL);
+		if (!uar) {
+			err = -ENOMEM;
+			goto out;
+		}
+		err = mlx4_uar_alloc(dev, uar);
+		if (err)
+			goto free_kmalloc;
+
+		uar->map = ioremap(uar->pfn << PAGE_SHIFT, PAGE_SIZE);
+		if (!uar->map) {
+			err = -ENOMEM;
+			goto free_uar;
+		}
+
+		uar->bf_map = io_mapping_map_wc(priv->bf_mapping, uar->index << PAGE_SHIFT);
+		if (!uar->bf_map) {
+			err = -ENOMEM;
+			goto unamp_uar;
+		}
+		uar->free_bf_bmap = 0;
+		list_add(&uar->bf_list, &priv->bf_list);
+	}
+
+	bf->uar = uar;
+	idx = ffz(uar->free_bf_bmap);
+	uar->free_bf_bmap |= 1 << idx;
+	bf->uar = uar;
+	bf->offset = 0;
+	bf->buf_size = dev->caps.bf_reg_size / 2;
+	bf->reg = uar->bf_map + idx * dev->caps.bf_reg_size;
+	if (uar->free_bf_bmap == (1 << dev->caps.bf_regs_per_page) - 1)
+		list_del_init(&uar->bf_list);
+
+	goto out;
+
+unamp_uar:
+	bf->uar = NULL;
+	iounmap(uar->map);
+
+free_uar:
+	mlx4_uar_free(dev, uar);
+
+free_kmalloc:
+	kfree(uar);
+
+out:
+	mutex_unlock(&priv->bf_mutex);
+	return err;
+}
+EXPORT_SYMBOL_GPL(mlx4_bf_alloc);
+
+void mlx4_bf_free(struct mlx4_dev *dev, struct mlx4_bf *bf)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	int idx;
+
+	if (!bf->uar || !bf->uar->bf_map)
+		return;
+
+	mutex_lock(&priv->bf_mutex);
+	idx = (bf->reg - bf->uar->bf_map) / dev->caps.bf_reg_size;
+	bf->uar->free_bf_bmap &= ~(1 << idx);
+	if (!bf->uar->free_bf_bmap) {
+		if (!list_empty(&bf->uar->bf_list))
+			list_del(&bf->uar->bf_list);
+
+		io_mapping_unmap(bf->uar->bf_map);
+		iounmap(bf->uar->map);
+		mlx4_uar_free(dev, bf->uar);
+		kfree(bf->uar);
+	} else if (list_empty(&bf->uar->bf_list))
+		list_add(&bf->uar->bf_list, &priv->bf_list);
+
+	mutex_unlock(&priv->bf_mutex);
+}
+EXPORT_SYMBOL_GPL(mlx4_bf_free);
+
 int mlx4_init_uar_table(struct mlx4_dev *dev)
 {
 	if (dev->caps.num_uars <= 128) {
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index f1cb31b..229cd65 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -351,6 +351,17 @@ struct mlx4_fmr {
 struct mlx4_uar {
 	unsigned long		pfn;
 	int			index;
+	struct list_head	bf_list;
+	unsigned		free_bf_bmap;
+	void __iomem	       *map;
+	void __iomem	       *bf_map;
+};
+
+struct mlx4_bf {
+	unsigned long		offset;
+	int			buf_size;
+	struct mlx4_uar	       *uar;
+	void __iomem	       *reg;
 };
 
 struct mlx4_cq {
@@ -478,6 +489,8 @@ void mlx4_pd_free(struct mlx4_dev *dev, u32 pdn);
 
 int mlx4_uar_alloc(struct mlx4_dev *dev, struct mlx4_uar *uar);
 void mlx4_uar_free(struct mlx4_dev *dev, struct mlx4_uar *uar);
+int mlx4_bf_alloc(struct mlx4_dev *dev, struct mlx4_bf *bf);
+void mlx4_bf_free(struct mlx4_dev *dev, struct mlx4_bf *bf);
 
 int mlx4_mtt_init(struct mlx4_dev *dev, int npages, int page_shift,
 		  struct mlx4_mtt *mtt);
diff --git a/include/linux/mlx4/qp.h b/include/linux/mlx4/qp.h
index 0eeb2a1..9e9eb21 100644
--- a/include/linux/mlx4/qp.h
+++ b/include/linux/mlx4/qp.h
@@ -303,6 +303,7 @@ struct mlx4_wqe_data_seg {
 
 enum {
 	MLX4_INLINE_ALIGN	= 64,
+	MLX4_INLINE_SEG		= 1 << 31,
 };
 
 struct mlx4_wqe_inline_seg {
-- 
1.6.0.2





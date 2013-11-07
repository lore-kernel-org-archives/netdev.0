From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 5/6] net/mlx4_core: ICM pages are allocated on device NUMA node
Date: Thu,  7 Nov 2013 12:19:53 +0200
Message-ID: <1383819594-24070-6-git-send-email-amirv@mellanox.com>
References: <1383819594-24070-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:33158 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751591Ab3KGKUT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Nov 2013 05:20:19 -0500
In-Reply-To: <1383819594-24070-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.com>

>From now ICM pages will be allocated on device NUMA node.
This is done to optimize FW/HW access to host memory.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.com>
Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Reviewed-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/icm.c  | 42 ++++++++++++++++++++++---------
 drivers/net/ethernet/mellanox/mlx4/main.c |  1 +
 include/linux/mlx4/device.h               |  1 +
 3 files changed, 32 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/icm.c b/drivers/net/ethernet/mellanox/mlx4/icm.c
index 31d0264..5fbf492 100644
--- a/drivers/net/ethernet/mellanox/mlx4/icm.c
+++ b/drivers/net/ethernet/mellanox/mlx4/icm.c
@@ -93,13 +93,17 @@ void mlx4_free_icm(struct mlx4_dev *dev, struct mlx4_icm *icm, int coherent)
 	kfree(icm);
 }
 
-static int mlx4_alloc_icm_pages(struct scatterlist *mem, int order, gfp_t gfp_mask)
+static int mlx4_alloc_icm_pages(struct scatterlist *mem, int order,
+				gfp_t gfp_mask, int node)
 {
 	struct page *page;
 
-	page = alloc_pages(gfp_mask, order);
-	if (!page)
-		return -ENOMEM;
+	page = alloc_pages_node(node, gfp_mask, order);
+	if (!page) {
+		page = alloc_pages(gfp_mask, order);
+		if (!page)
+			return -ENOMEM;
+	}
 
 	sg_set_page(mem, page, PAGE_SIZE << order, 0);
 	return 0;
@@ -130,9 +134,15 @@ struct mlx4_icm *mlx4_alloc_icm(struct mlx4_dev *dev, int npages,
 	/* We use sg_set_buf for coherent allocs, which assumes low memory */
 	BUG_ON(coherent && (gfp_mask & __GFP_HIGHMEM));
 
-	icm = kmalloc(sizeof *icm, gfp_mask & ~(__GFP_HIGHMEM | __GFP_NOWARN));
-	if (!icm)
-		return NULL;
+	icm = kmalloc_node(sizeof(*icm),
+			   gfp_mask & ~(__GFP_HIGHMEM | __GFP_NOWARN),
+			   dev->numa_node);
+	if (!icm) {
+		icm = kmalloc(sizeof(*icm),
+			      gfp_mask & ~(__GFP_HIGHMEM | __GFP_NOWARN));
+		if (!icm)
+			return NULL;
+	}
 
 	icm->refcount = 0;
 	INIT_LIST_HEAD(&icm->chunk_list);
@@ -141,10 +151,17 @@ struct mlx4_icm *mlx4_alloc_icm(struct mlx4_dev *dev, int npages,
 
 	while (npages > 0) {
 		if (!chunk) {
-			chunk = kmalloc(sizeof *chunk,
-					gfp_mask & ~(__GFP_HIGHMEM | __GFP_NOWARN));
-			if (!chunk)
-				goto fail;
+			chunk = kmalloc_node(sizeof(*chunk),
+					     gfp_mask & ~(__GFP_HIGHMEM |
+							  __GFP_NOWARN),
+					     dev->numa_node);
+			if (!chunk) {
+				chunk = kmalloc(sizeof(*chunk),
+						gfp_mask & ~(__GFP_HIGHMEM |
+							     __GFP_NOWARN));
+				if (!chunk)
+					goto fail;
+			}
 
 			sg_init_table(chunk->mem, MLX4_ICM_CHUNK_LEN);
 			chunk->npages = 0;
@@ -161,7 +178,8 @@ struct mlx4_icm *mlx4_alloc_icm(struct mlx4_dev *dev, int npages,
 						      cur_order, gfp_mask);
 		else
 			ret = mlx4_alloc_icm_pages(&chunk->mem[chunk->npages],
-						   cur_order, gfp_mask);
+						   cur_order, gfp_mask,
+						   dev->numa_node);
 
 		if (ret) {
 			if (--cur_order < 0)
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 7d2628d..5789ea2 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -2191,6 +2191,7 @@ static int __mlx4_init_one(struct pci_dev *pdev, int pci_dev_data)
 	mutex_init(&priv->bf_mutex);
 
 	dev->rev_id = pdev->revision;
+	dev->numa_node = dev_to_node(&pdev->dev);
 	/* Detect if this device is a virtual function */
 	if (pci_dev_data & MLX4_PCI_DEV_IS_VF) {
 		/* When acting as pf, we normally skip vfs unless explicitly
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index f6f5927..4cf0b01 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -662,6 +662,7 @@ struct mlx4_dev {
 	u8			rev_id;
 	char			board_id[MLX4_BOARD_ID_LEN];
 	int			num_vfs;
+	int			numa_node;
 	int			oper_log_mgm_entry_size;
 	u64			regid_promisc_array[MLX4_MAX_PORTS + 1];
 	u64			regid_allmulti_array[MLX4_MAX_PORTS + 1];
-- 
1.8.3.4

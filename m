From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH for-next 11/11] IB/mlx5: Improve MR check
Date: Sun,  1 Jan 2017 23:10:27 +0200
Message-ID: <1483305027-2573-12-git-send-email-saeedm@mellanox.com>
References: <1483305027-2573-1-git-send-email-saeedm@mellanox.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Ilya Lesokhin <ilyal-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Artemy Kovalyov <artemyko-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1483305027-2573-1-git-send-email-saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Artemy Kovalyov <artemyko-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

Add "type" field to mlx5_core MKEY struct.
Check whether page fault happens on MKEY corresponding to MR.

Signed-off-by: Artemy Kovalyov <artemyko-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Signed-off-by: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 drivers/infiniband/hw/mlx5/mr.c  | 5 +++++
 drivers/infiniband/hw/mlx5/odp.c | 9 +++++++--
 include/linux/mlx5/driver.h      | 6 ++++++
 3 files changed, 18 insertions(+), 2 deletions(-)

diff --git a/drivers/infiniband/hw/mlx5/mr.c b/drivers/infiniband/hw/mlx5/mr.c
index e4333c8..f56b249 100644
--- a/drivers/infiniband/hw/mlx5/mr.c
+++ b/drivers/infiniband/hw/mlx5/mr.c
@@ -129,6 +129,7 @@ static void reg_mr_callback(int status, void *context)
 		return;
 	}
 
+	mr->mmkey.type = MLX5_MKEY_MR;
 	spin_lock_irqsave(&dev->mdev->priv.mkey_lock, flags);
 	key = dev->mdev->priv.mkey_key++;
 	spin_unlock_irqrestore(&dev->mdev->priv.mkey_lock, flags);
@@ -728,6 +729,7 @@ struct ib_mr *mlx5_ib_get_dma_mr(struct ib_pd *pd, int acc)
 		goto err_in;
 
 	kfree(in);
+	mr->mmkey.type = MLX5_MKEY_MR;
 	mr->ibmr.lkey = mr->mmkey.key;
 	mr->ibmr.rkey = mr->mmkey.key;
 	mr->umem = NULL;
@@ -1088,6 +1090,7 @@ static struct mlx5_ib_mr *reg_create(struct ib_mr *ibmr, struct ib_pd *pd,
 		mlx5_ib_warn(dev, "create mkey failed\n");
 		goto err_2;
 	}
+	mr->mmkey.type = MLX5_MKEY_MR;
 	mr->umem = umem;
 	mr->dev = dev;
 	mr->live = 1;
@@ -1533,6 +1536,7 @@ struct ib_mr *mlx5_ib_alloc_mr(struct ib_pd *pd,
 	if (err)
 		goto err_destroy_psv;
 
+	mr->mmkey.type = MLX5_MKEY_MR;
 	mr->ibmr.lkey = mr->mmkey.key;
 	mr->ibmr.rkey = mr->mmkey.key;
 	mr->umem = NULL;
@@ -1613,6 +1617,7 @@ struct ib_mw *mlx5_ib_alloc_mw(struct ib_pd *pd, enum ib_mw_type type,
 	if (err)
 		goto free;
 
+	mw->mmkey.type = MLX5_MKEY_MW;
 	mw->ibmw.rkey = mw->mmkey.key;
 
 	resp.response_length = min(offsetof(typeof(resp), response_length) +
diff --git a/drivers/infiniband/hw/mlx5/odp.c b/drivers/infiniband/hw/mlx5/odp.c
index 971b288..e5bc267 100644
--- a/drivers/infiniband/hw/mlx5/odp.c
+++ b/drivers/infiniband/hw/mlx5/odp.c
@@ -155,9 +155,14 @@ static struct mlx5_ib_mr *mlx5_ib_odp_find_mr_lkey(struct mlx5_ib_dev *dev,
 {
 	u32 base_key = mlx5_base_mkey(key);
 	struct mlx5_core_mkey *mmkey = __mlx5_mr_lookup(dev->mdev, base_key);
-	struct mlx5_ib_mr *mr = container_of(mmkey, struct mlx5_ib_mr, mmkey);
+	struct mlx5_ib_mr *mr;
+
+	if (!mmkey || mmkey->key != key || mmkey->type != MLX5_MKEY_MR)
+		return NULL;
+
+	mr = container_of(mmkey, struct mlx5_ib_mr, mmkey);
 
-	if (!mmkey || mmkey->key != key || !mr->live)
+	if (!mr->live)
 		return NULL;
 
 	return container_of(mmkey, struct mlx5_ib_mr, mmkey);
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index b52d074..cfa49bc 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -394,11 +394,17 @@ struct mlx5_core_sig_ctx {
 	u32			sigerr_count;
 };
 
+enum {
+	MLX5_MKEY_MR = 1,
+	MLX5_MKEY_MW,
+};
+
 struct mlx5_core_mkey {
 	u64			iova;
 	u64			size;
 	u32			key;
 	u32			pd;
+	u32			type;
 };
 
 #define MLX5_24BIT_MASK		((1 << 24) - 1)
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

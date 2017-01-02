From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH for-next V2 03/11] IB/mlx5: Add helper mlx5_ib_post_send_wait
Date: Mon,  2 Jan 2017 11:37:40 +0200
Message-ID: <1483349868-11716-4-git-send-email-saeedm@mellanox.com>
References: <1483349868-11716-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        Leon Romanovsky <leonro@mellanox.com>,
        Ilya Lesokhin <ilyal@mellanox.com>,
        Artemy Kovalyov <artemyko@mellanox.com>,
        Binoy Jayan <binoy.jayan@linaro.org>,
        Leon Romanovsky <leon@kernel.org>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
        Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:34468 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932520AbdABJiX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2017 04:38:23 -0500
In-Reply-To: <1483349868-11716-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Binoy Jayan <binoy.jayan@linaro.org>

Clean up the following common code (to post a list of work requests to the
send queue of the specified QP) at various places and add a helper function
'mlx5_ib_post_send_wait' to implement the same.

 - Initialize 'mlx5_ib_umr_context' on stack
 - Assign "mlx5_umr_wr:wr:wr_cqe to umr_context.cqe
 - Acquire the semaphore
 - call ib_post_send with a single ib_send_wr
 - wait_for_completion()
 - Check for umr_context.status
 - Release the semaphore

Signed-off-by: Binoy Jayan <binoy.jayan@linaro.org>
Signed-off-by: Leon Romanovsky <leon@kernel.org>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/infiniband/hw/mlx5/mr.c | 115 +++++++++++-----------------------------
 1 file changed, 32 insertions(+), 83 deletions(-)

diff --git a/drivers/infiniband/hw/mlx5/mr.c b/drivers/infiniband/hw/mlx5/mr.c
index 8f608deb..7ab9b67 100644
--- a/drivers/infiniband/hw/mlx5/mr.c
+++ b/drivers/infiniband/hw/mlx5/mr.c
@@ -891,16 +891,40 @@ static inline void mlx5_ib_init_umr_context(struct mlx5_ib_umr_context *context)
 	init_completion(&context->done);
 }
 
+static int mlx5_ib_post_send_wait(struct mlx5_ib_dev *dev,
+				  struct mlx5_umr_wr *umrwr)
+{
+	struct umr_common *umrc = &dev->umrc;
+	struct ib_send_wr *bad;
+	int err;
+	struct mlx5_ib_umr_context umr_context;
+
+	mlx5_ib_init_umr_context(&umr_context);
+	umrwr->wr.wr_cqe = &umr_context.cqe;
+
+	down(&umrc->sem);
+	err = ib_post_send(umrc->qp, &umrwr->wr, &bad);
+	if (err) {
+		mlx5_ib_warn(dev, "UMR post send failed, err %d\n", err);
+	} else {
+		wait_for_completion(&umr_context.done);
+		if (umr_context.status != IB_WC_SUCCESS) {
+			mlx5_ib_warn(dev, "reg umr failed (%u)\n",
+				     umr_context.status);
+			err = -EFAULT;
+		}
+	}
+	up(&umrc->sem);
+	return err;
+}
+
 static struct mlx5_ib_mr *reg_umr(struct ib_pd *pd, struct ib_umem *umem,
 				  u64 virt_addr, u64 len, int npages,
 				  int page_shift, int order, int access_flags)
 {
 	struct mlx5_ib_dev *dev = to_mdev(pd->device);
 	struct device *ddev = dev->ib_dev.dma_device;
-	struct umr_common *umrc = &dev->umrc;
-	struct mlx5_ib_umr_context umr_context;
 	struct mlx5_umr_wr umrwr = {};
-	struct ib_send_wr *bad;
 	struct mlx5_ib_mr *mr;
 	struct ib_sge sg;
 	int size;
@@ -929,24 +953,12 @@ static struct mlx5_ib_mr *reg_umr(struct ib_pd *pd, struct ib_umem *umem,
 	if (err)
 		goto free_mr;
 
-	mlx5_ib_init_umr_context(&umr_context);
-
-	umrwr.wr.wr_cqe = &umr_context.cqe;
 	prep_umr_reg_wqe(pd, &umrwr.wr, &sg, dma, npages, mr->mmkey.key,
 			 page_shift, virt_addr, len, access_flags);
 
-	down(&umrc->sem);
-	err = ib_post_send(umrc->qp, &umrwr.wr, &bad);
-	if (err) {
-		mlx5_ib_warn(dev, "post send failed, err %d\n", err);
+	err = mlx5_ib_post_send_wait(dev, &umrwr);
+	if (err && err != -EFAULT)
 		goto unmap_dma;
-	} else {
-		wait_for_completion(&umr_context.done);
-		if (umr_context.status != IB_WC_SUCCESS) {
-			mlx5_ib_warn(dev, "reg umr failed\n");
-			err = -EFAULT;
-		}
-	}
 
 	mr->mmkey.iova = virt_addr;
 	mr->mmkey.size = len;
@@ -955,7 +967,6 @@ static struct mlx5_ib_mr *reg_umr(struct ib_pd *pd, struct ib_umem *umem,
 	mr->live = 1;
 
 unmap_dma:
-	up(&umrc->sem);
 	dma_unmap_single(ddev, dma, size, DMA_TO_DEVICE);
 
 	kfree(mr_pas);
@@ -975,13 +986,10 @@ int mlx5_ib_update_mtt(struct mlx5_ib_mr *mr, u64 start_page_index, int npages,
 {
 	struct mlx5_ib_dev *dev = mr->dev;
 	struct device *ddev = dev->ib_dev.dma_device;
-	struct umr_common *umrc = &dev->umrc;
-	struct mlx5_ib_umr_context umr_context;
 	struct ib_umem *umem = mr->umem;
 	int size;
 	__be64 *pas;
 	dma_addr_t dma;
-	struct ib_send_wr *bad;
 	struct mlx5_umr_wr wr;
 	struct ib_sge sg;
 	int err = 0;
@@ -1046,10 +1054,7 @@ int mlx5_ib_update_mtt(struct mlx5_ib_mr *mr, u64 start_page_index, int npages,
 
 		dma_sync_single_for_device(ddev, dma, size, DMA_TO_DEVICE);
 
-		mlx5_ib_init_umr_context(&umr_context);
-
 		memset(&wr, 0, sizeof(wr));
-		wr.wr.wr_cqe = &umr_context.cqe;
 
 		sg.addr = dma;
 		sg.length = ALIGN(npages * sizeof(u64),
@@ -1066,19 +1071,7 @@ int mlx5_ib_update_mtt(struct mlx5_ib_mr *mr, u64 start_page_index, int npages,
 		wr.mkey = mr->mmkey.key;
 		wr.target.offset = start_page_index;
 
-		down(&umrc->sem);
-		err = ib_post_send(umrc->qp, &wr.wr, &bad);
-		if (err) {
-			mlx5_ib_err(dev, "UMR post send failed, err %d\n", err);
-		} else {
-			wait_for_completion(&umr_context.done);
-			if (umr_context.status != IB_WC_SUCCESS) {
-				mlx5_ib_err(dev, "UMR completion failed, code %d\n",
-					    umr_context.status);
-				err = -EFAULT;
-			}
-		}
-		up(&umrc->sem);
+		err = mlx5_ib_post_send_wait(dev, &wr);
 	}
 	dma_unmap_single(ddev, dma, size, DMA_TO_DEVICE);
 
@@ -1248,39 +1241,14 @@ struct ib_mr *mlx5_ib_reg_user_mr(struct ib_pd *pd, u64 start, u64 length,
 static int unreg_umr(struct mlx5_ib_dev *dev, struct mlx5_ib_mr *mr)
 {
 	struct mlx5_core_dev *mdev = dev->mdev;
-	struct umr_common *umrc = &dev->umrc;
-	struct mlx5_ib_umr_context umr_context;
 	struct mlx5_umr_wr umrwr = {};
-	struct ib_send_wr *bad;
-	int err;
 
 	if (mdev->state == MLX5_DEVICE_STATE_INTERNAL_ERROR)
 		return 0;
 
-	mlx5_ib_init_umr_context(&umr_context);
-
-	umrwr.wr.wr_cqe = &umr_context.cqe;
 	prep_umr_unreg_wqe(dev, &umrwr.wr, mr->mmkey.key);
 
-	down(&umrc->sem);
-	err = ib_post_send(umrc->qp, &umrwr.wr, &bad);
-	if (err) {
-		up(&umrc->sem);
-		mlx5_ib_dbg(dev, "err %d\n", err);
-		goto error;
-	} else {
-		wait_for_completion(&umr_context.done);
-		up(&umrc->sem);
-	}
-	if (umr_context.status != IB_WC_SUCCESS) {
-		mlx5_ib_warn(dev, "unreg umr failed\n");
-		err = -EFAULT;
-		goto error;
-	}
-	return 0;
-
-error:
-	return err;
+	return mlx5_ib_post_send_wait(dev, &umrwr);
 }
 
 static int rereg_umr(struct ib_pd *pd, struct mlx5_ib_mr *mr, u64 virt_addr,
@@ -1289,19 +1257,13 @@ static int rereg_umr(struct ib_pd *pd, struct mlx5_ib_mr *mr, u64 virt_addr,
 {
 	struct mlx5_ib_dev *dev = to_mdev(pd->device);
 	struct device *ddev = dev->ib_dev.dma_device;
-	struct mlx5_ib_umr_context umr_context;
-	struct ib_send_wr *bad;
 	struct mlx5_umr_wr umrwr = {};
 	struct ib_sge sg;
-	struct umr_common *umrc = &dev->umrc;
 	dma_addr_t dma = 0;
 	__be64 *mr_pas = NULL;
 	int size;
 	int err;
 
-	mlx5_ib_init_umr_context(&umr_context);
-
-	umrwr.wr.wr_cqe = &umr_context.cqe;
 	umrwr.wr.send_flags = MLX5_IB_SEND_UMR_FAIL_IF_FREE;
 
 	if (flags & IB_MR_REREG_TRANS) {
@@ -1329,21 +1291,8 @@ static int rereg_umr(struct ib_pd *pd, struct mlx5_ib_mr *mr, u64 virt_addr,
 	}
 
 	/* post send request to UMR QP */
-	down(&umrc->sem);
-	err = ib_post_send(umrc->qp, &umrwr.wr, &bad);
+	err = mlx5_ib_post_send_wait(dev, &umrwr);
 
-	if (err) {
-		mlx5_ib_warn(dev, "post send failed, err %d\n", err);
-	} else {
-		wait_for_completion(&umr_context.done);
-		if (umr_context.status != IB_WC_SUCCESS) {
-			mlx5_ib_warn(dev, "reg umr failed (%u)\n",
-				     umr_context.status);
-			err = -EFAULT;
-		}
-	}
-
-	up(&umrc->sem);
 	if (flags & IB_MR_REREG_TRANS) {
 		dma_unmap_single(ddev, dma, size, DMA_TO_DEVICE);
 		kfree(mr_pas);
-- 
2.7.4

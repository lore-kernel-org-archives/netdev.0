From: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Subject: mlx5: don't duplicate kvfree()
Date: Thu, 20 Nov 2014 08:13:57 +0000
Message-ID: <20141120081357.GI7996@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
---
 drivers/infiniband/hw/mlx5/cq.c                     |    8 ++++----
 drivers/infiniband/hw/mlx5/mr.c                     |    4 ++--
 drivers/infiniband/hw/mlx5/qp.c                     |    8 ++++----
 drivers/infiniband/hw/mlx5/srq.c                    |    6 +++---
 drivers/net/ethernet/mellanox/mlx5/core/eq.c        |    4 ++--
 drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c |    4 ++--
 drivers/net/ethernet/mellanox/mlx5/core/port.c      |    4 ++--
 include/linux/mlx5/driver.h                         |    8 --------
 9 files changed, 21 insertions(+), 35 deletions(-)

diff --git a/drivers/infiniband/hw/mlx5/cq.c b/drivers/infiniband/hw/mlx5/cq.c
index 10cfce5..c463e7b 100644
--- a/drivers/infiniband/hw/mlx5/cq.c
+++ b/drivers/infiniband/hw/mlx5/cq.c
@@ -805,14 +805,14 @@ struct ib_cq *mlx5_ib_create_cq(struct ib_device *ibdev, int entries,
 		}
 
 
-	mlx5_vfree(cqb);
+	kvfree(cqb);
 	return &cq->ibcq;
 
 err_cmd:
 	mlx5_core_destroy_cq(dev->mdev, &cq->mcq);
 
 err_cqb:
-	mlx5_vfree(cqb);
+	kvfree(cqb);
 	if (context)
 		destroy_cq_user(cq, context);
 	else
@@ -1159,11 +1159,11 @@ int mlx5_ib_resize_cq(struct ib_cq *ibcq, int entries, struct ib_udata *udata)
 	}
 	mutex_unlock(&cq->resize_mutex);
 
-	mlx5_vfree(in);
+	kvfree(in);
 	return 0;
 
 ex_alloc:
-	mlx5_vfree(in);
+	kvfree(in);
 
 ex_resize:
 	if (udata)
diff --git a/drivers/infiniband/hw/mlx5/mr.c b/drivers/infiniband/hw/mlx5/mr.c
index 8ee7cb4..4c89b64 100644
--- a/drivers/infiniband/hw/mlx5/mr.c
+++ b/drivers/infiniband/hw/mlx5/mr.c
@@ -853,14 +853,14 @@ static struct mlx5_ib_mr *reg_create(struct ib_pd *pd, u64 virt_addr,
 		goto err_2;
 	}
 	mr->umem = umem;
-	mlx5_vfree(in);
+	kvfree(in);
 
 	mlx5_ib_dbg(dev, "mkey = 0x%x\n", mr->mmr.key);
 
 	return mr;
 
 err_2:
-	mlx5_vfree(in);
+	kvfree(in);
 
 err_1:
 	kfree(mr);
diff --git a/drivers/infiniband/hw/mlx5/qp.c b/drivers/infiniband/hw/mlx5/qp.c
index e261a53..0e2ef9f 100644
--- a/drivers/infiniband/hw/mlx5/qp.c
+++ b/drivers/infiniband/hw/mlx5/qp.c
@@ -647,7 +647,7 @@ err_unmap:
 	mlx5_ib_db_unmap_user(context, &qp->db);
 
 err_free:
-	mlx5_vfree(*in);
+	kvfree(*in);
 
 err_umem:
 	if (qp->umem)
@@ -761,7 +761,7 @@ err_wrid:
 	kfree(qp->rq.wrid);
 
 err_free:
-	mlx5_vfree(*in);
+	kvfree(*in);
 
 err_buf:
 	mlx5_buf_free(dev->mdev, &qp->buf);
@@ -971,7 +971,7 @@ static int create_qp_common(struct mlx5_ib_dev *dev, struct ib_pd *pd,
 		goto err_create;
 	}
 
-	mlx5_vfree(in);
+	kvfree(in);
 	/* Hardware wants QPN written in big-endian order (after
 	 * shifting) for send doorbell.  Precompute this value to save
 	 * a little bit when posting sends.
@@ -988,7 +988,7 @@ err_create:
 	else if (qp->create_type == MLX5_QP_KERNEL)
 		destroy_qp_kernel(dev, qp);
 
-	mlx5_vfree(in);
+	kvfree(in);
 	return err;
 }
 
diff --git a/drivers/infiniband/hw/mlx5/srq.c b/drivers/infiniband/hw/mlx5/srq.c
index 97cc1ba..41fec66 100644
--- a/drivers/infiniband/hw/mlx5/srq.c
+++ b/drivers/infiniband/hw/mlx5/srq.c
@@ -141,7 +141,7 @@ static int create_srq_user(struct ib_pd *pd, struct mlx5_ib_srq *srq,
 	return 0;
 
 err_in:
-	mlx5_vfree(*in);
+	kvfree(*in);
 
 err_umem:
 	ib_umem_release(srq->umem);
@@ -209,7 +209,7 @@ static int create_srq_kernel(struct mlx5_ib_dev *dev, struct mlx5_ib_srq *srq,
 	return 0;
 
 err_in:
-	mlx5_vfree(*in);
+	kvfree(*in);
 
 err_buf:
 	mlx5_buf_free(dev->mdev, &srq->buf);
@@ -306,7 +306,7 @@ struct ib_srq *mlx5_ib_create_srq(struct ib_pd *pd,
 	in->ctx.pd = cpu_to_be32(to_mpd(pd)->pdn);
 	in->ctx.db_record = cpu_to_be64(srq->db.dma);
 	err = mlx5_core_create_srq(dev->mdev, &srq->msrq, in, inlen);
-	mlx5_vfree(in);
+	kvfree(in);
 	if (err) {
 		mlx5_ib_dbg(dev, "create SRQ failed, err %d\n", err);
 		goto err_usr_kern_srq;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eq.c b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
index a278238..eb3aa15 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
@@ -391,7 +391,7 @@ int mlx5_create_map_eq(struct mlx5_core_dev *dev, struct mlx5_eq *eq, u8 vecidx,
 	 */
 	eq_update_ci(eq, 1);
 
-	mlx5_vfree(in);
+	kvfree(in);
 	return 0;
 
 err_irq:
@@ -401,7 +401,7 @@ err_eq:
 	mlx5_cmd_destroy_eq(dev, eq->eqn);
 
 err_in:
-	mlx5_vfree(in);
+	kvfree(in);
 
 err_buf:
 	mlx5_buf_free(dev, &eq->buf);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c b/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
index d476918..4fdaae9 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
@@ -349,7 +349,7 @@ out_4k:
 	for (i--; i >= 0; i--)
 		free_4k(dev, be64_to_cpu(in->pas[i]));
 out_free:
-	mlx5_vfree(in);
+	kvfree(in);
 	return err;
 }
 
@@ -400,7 +400,7 @@ static int reclaim_pages(struct mlx5_core_dev *dev, u32 func_id, int npages,
 	}
 
 out_free:
-	mlx5_vfree(out);
+	kvfree(out);
 	return err;
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/port.c b/drivers/net/ethernet/mellanox/mlx5/core/port.c
index 3139658..72c2d00 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/port.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/port.c
@@ -68,9 +68,9 @@ int mlx5_core_access_reg(struct mlx5_core_dev *dev, void *data_in,
 		memcpy(data_out, out->data, size_out);
 
 ex2:
-	mlx5_vfree(out);
+	kvfree(out);
 ex1:
-	mlx5_vfree(in);
+	kvfree(in);
 	return err;
 }
 EXPORT_SYMBOL_GPL(mlx5_core_access_reg);
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index 246310d..b1bf415 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -633,14 +633,6 @@ static inline void *mlx5_vzalloc(unsigned long size)
 	return rtn;
 }
 
-static inline void mlx5_vfree(const void *addr)
-{
-	if (addr && is_vmalloc_addr(addr))
-		vfree(addr);
-	else
-		kfree(addr);
-}
-
 static inline u32 mlx5_base_mkey(const u32 key)
 {
 	return key & 0xffffff00u;
-- 
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

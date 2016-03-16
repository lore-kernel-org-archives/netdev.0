From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V1 01/13] net/mlx5: Refactor mlx5_core_mr to mkey
Date: Wed, 16 Mar 2016 08:41:09 +0200
Message-ID: <1458110481-18080-2-git-send-email-saeedm@mellanox.com>
References: <1458110481-18080-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Matan Barak <matanb@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:38388 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S965175AbcCPGm4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Mar 2016 02:42:56 -0400
In-Reply-To: <1458110481-18080-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matan Barak <matanb@mellanox.com>

Mlx5's mkey mechanism is also used for memory windows.
The current code base uses MR (memory region) naming, which is
inaccurate. Changing MR to mkey in order to represent its different
usages more accurately.

Signed-off-by: Matan Barak <matanb@mellanox.com>
Reviewed-by: Yishai Hadas <yishaih@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/infiniband/hw/mlx5/cq.c                   |   16 +++---
 drivers/infiniband/hw/mlx5/mlx5_ib.h              |    6 +-
 drivers/infiniband/hw/mlx5/mr.c                   |   50 ++++++++++----------
 drivers/infiniband/hw/mlx5/odp.c                  |   10 ++--
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |    2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |   12 ++--
 drivers/net/ethernet/mellanox/mlx5/core/main.c    |    6 +-
 drivers/net/ethernet/mellanox/mlx5/core/mr.c      |   54 +++++++++++----------
 include/linux/mlx5/driver.h                       |   24 +++++----
 include/linux/mlx5/qp.h                           |    4 +-
 10 files changed, 94 insertions(+), 90 deletions(-)

diff --git a/drivers/infiniband/hw/mlx5/cq.c b/drivers/infiniband/hw/mlx5/cq.c
index fd1de31..28b69b4 100644
--- a/drivers/infiniband/hw/mlx5/cq.c
+++ b/drivers/infiniband/hw/mlx5/cq.c
@@ -431,7 +431,7 @@ static int mlx5_poll_one(struct mlx5_ib_cq *cq,
 	struct mlx5_core_qp *mqp;
 	struct mlx5_ib_wq *wq;
 	struct mlx5_sig_err_cqe *sig_err_cqe;
-	struct mlx5_core_mr *mmr;
+	struct mlx5_core_mkey *mmkey;
 	struct mlx5_ib_mr *mr;
 	uint8_t opcode;
 	uint32_t qpn;
@@ -536,17 +536,17 @@ repoll:
 	case MLX5_CQE_SIG_ERR:
 		sig_err_cqe = (struct mlx5_sig_err_cqe *)cqe64;
 
-		read_lock(&dev->mdev->priv.mr_table.lock);
-		mmr = __mlx5_mr_lookup(dev->mdev,
-				       mlx5_base_mkey(be32_to_cpu(sig_err_cqe->mkey)));
-		if (unlikely(!mmr)) {
-			read_unlock(&dev->mdev->priv.mr_table.lock);
+		read_lock(&dev->mdev->priv.mkey_table.lock);
+		mmkey = __mlx5_mr_lookup(dev->mdev,
+					 mlx5_base_mkey(be32_to_cpu(sig_err_cqe->mkey)));
+		if (unlikely(!mmkey)) {
+			read_unlock(&dev->mdev->priv.mkey_table.lock);
 			mlx5_ib_warn(dev, "CQE@CQ %06x for unknown MR %6x\n",
 				     cq->mcq.cqn, be32_to_cpu(sig_err_cqe->mkey));
 			return -EINVAL;
 		}
 
-		mr = to_mibmr(mmr);
+		mr = to_mibmr(mmkey);
 		get_sig_err_item(sig_err_cqe, &mr->sig->err_item);
 		mr->sig->sig_err_exists = true;
 		mr->sig->sigerr_count++;
@@ -558,7 +558,7 @@ repoll:
 			     mr->sig->err_item.expected,
 			     mr->sig->err_item.actual);
 
-		read_unlock(&dev->mdev->priv.mr_table.lock);
+		read_unlock(&dev->mdev->priv.mkey_table.lock);
 		goto repoll;
 	}
 
diff --git a/drivers/infiniband/hw/mlx5/mlx5_ib.h b/drivers/infiniband/hw/mlx5/mlx5_ib.h
index d2b9737..b1cad93 100644
--- a/drivers/infiniband/hw/mlx5/mlx5_ib.h
+++ b/drivers/infiniband/hw/mlx5/mlx5_ib.h
@@ -413,7 +413,7 @@ struct mlx5_ib_mr {
 	int			ndescs;
 	int			max_descs;
 	int			desc_size;
-	struct mlx5_core_mr	mmr;
+	struct mlx5_core_mkey	mmkey;
 	struct ib_umem	       *umem;
 	struct mlx5_shared_mr_info	*smr_info;
 	struct list_head	list;
@@ -558,9 +558,9 @@ static inline struct mlx5_ib_qp *to_mibqp(struct mlx5_core_qp *mqp)
 	return container_of(mqp, struct mlx5_ib_qp_base, mqp)->container_mibqp;
 }
 
-static inline struct mlx5_ib_mr *to_mibmr(struct mlx5_core_mr *mmr)
+static inline struct mlx5_ib_mr *to_mibmr(struct mlx5_core_mkey *mmkey)
 {
-	return container_of(mmr, struct mlx5_ib_mr, mmr);
+	return container_of(mmkey, struct mlx5_ib_mr, mmkey);
 }
 
 static inline struct mlx5_ib_pd *to_mpd(struct ib_pd *ibpd)
diff --git a/drivers/infiniband/hw/mlx5/mr.c b/drivers/infiniband/hw/mlx5/mr.c
index 6000f7a..fbcccc8 100644
--- a/drivers/infiniband/hw/mlx5/mr.c
+++ b/drivers/infiniband/hw/mlx5/mr.c
@@ -57,7 +57,7 @@ static int clean_mr(struct mlx5_ib_mr *mr);
 
 static int destroy_mkey(struct mlx5_ib_dev *dev, struct mlx5_ib_mr *mr)
 {
-	int err = mlx5_core_destroy_mkey(dev->mdev, &mr->mmr);
+	int err = mlx5_core_destroy_mkey(dev->mdev, &mr->mmkey);
 
 #ifdef CONFIG_INFINIBAND_ON_DEMAND_PAGING
 	/* Wait until all page fault handlers using the mr complete. */
@@ -86,7 +86,7 @@ static void reg_mr_callback(int status, void *context)
 	struct mlx5_cache_ent *ent = &cache->ent[c];
 	u8 key;
 	unsigned long flags;
-	struct mlx5_mr_table *table = &dev->mdev->priv.mr_table;
+	struct mlx5_mkey_table *table = &dev->mdev->priv.mkey_table;
 	int err;
 
 	spin_lock_irqsave(&ent->lock, flags);
@@ -113,7 +113,7 @@ static void reg_mr_callback(int status, void *context)
 	spin_lock_irqsave(&dev->mdev->priv.mkey_lock, flags);
 	key = dev->mdev->priv.mkey_key++;
 	spin_unlock_irqrestore(&dev->mdev->priv.mkey_lock, flags);
-	mr->mmr.key = mlx5_idx_to_mkey(be32_to_cpu(mr->out.mkey) & 0xffffff) | key;
+	mr->mmkey.key = mlx5_idx_to_mkey(be32_to_cpu(mr->out.mkey) & 0xffffff) | key;
 
 	cache->last_add = jiffies;
 
@@ -124,10 +124,10 @@ static void reg_mr_callback(int status, void *context)
 	spin_unlock_irqrestore(&ent->lock, flags);
 
 	write_lock_irqsave(&table->lock, flags);
-	err = radix_tree_insert(&table->tree, mlx5_base_mkey(mr->mmr.key),
-				&mr->mmr);
+	err = radix_tree_insert(&table->tree, mlx5_base_mkey(mr->mmkey.key),
+				&mr->mmkey);
 	if (err)
-		pr_err("Error inserting to mr tree. 0x%x\n", -err);
+		pr_err("Error inserting to mkey tree. 0x%x\n", -err);
 	write_unlock_irqrestore(&table->lock, flags);
 }
 
@@ -168,7 +168,7 @@ static int add_keys(struct mlx5_ib_dev *dev, int c, int num)
 		spin_lock_irq(&ent->lock);
 		ent->pending++;
 		spin_unlock_irq(&ent->lock);
-		err = mlx5_core_create_mkey(dev->mdev, &mr->mmr, in,
+		err = mlx5_core_create_mkey(dev->mdev, &mr->mmkey, in,
 					    sizeof(*in), reg_mr_callback,
 					    mr, &mr->out);
 		if (err) {
@@ -657,14 +657,14 @@ struct ib_mr *mlx5_ib_get_dma_mr(struct ib_pd *pd, int acc)
 	seg->qpn_mkey7_0 = cpu_to_be32(0xffffff << 8);
 	seg->start_addr = 0;
 
-	err = mlx5_core_create_mkey(mdev, &mr->mmr, in, sizeof(*in), NULL, NULL,
+	err = mlx5_core_create_mkey(mdev, &mr->mmkey, in, sizeof(*in), NULL, NULL,
 				    NULL);
 	if (err)
 		goto err_in;
 
 	kfree(in);
-	mr->ibmr.lkey = mr->mmr.key;
-	mr->ibmr.rkey = mr->mmr.key;
+	mr->ibmr.lkey = mr->mmkey.key;
+	mr->ibmr.rkey = mr->mmkey.key;
 	mr->umem = NULL;
 
 	return &mr->ibmr;
@@ -813,7 +813,7 @@ static struct mlx5_ib_mr *reg_umr(struct ib_pd *pd, struct ib_umem *umem,
 
 	memset(&umrwr, 0, sizeof(umrwr));
 	umrwr.wr.wr_id = (u64)(unsigned long)&umr_context;
-	prep_umr_reg_wqe(pd, &umrwr.wr, &sg, dma, npages, mr->mmr.key,
+	prep_umr_reg_wqe(pd, &umrwr.wr, &sg, dma, npages, mr->mmkey.key,
 			 page_shift, virt_addr, len, access_flags);
 
 	mlx5_ib_init_umr_context(&umr_context);
@@ -830,9 +830,9 @@ static struct mlx5_ib_mr *reg_umr(struct ib_pd *pd, struct ib_umem *umem,
 		}
 	}
 
-	mr->mmr.iova = virt_addr;
-	mr->mmr.size = len;
-	mr->mmr.pd = to_mpd(pd)->pdn;
+	mr->mmkey.iova = virt_addr;
+	mr->mmkey.size = len;
+	mr->mmkey.pd = to_mpd(pd)->pdn;
 
 	mr->live = 1;
 
@@ -944,7 +944,7 @@ int mlx5_ib_update_mtt(struct mlx5_ib_mr *mr, u64 start_page_index, int npages,
 		wr.wr.opcode = MLX5_IB_WR_UMR;
 		wr.npages = sg.length / sizeof(u64);
 		wr.page_shift = PAGE_SHIFT;
-		wr.mkey = mr->mmr.key;
+		wr.mkey = mr->mmkey.key;
 		wr.target.offset = start_page_index;
 
 		mlx5_ib_init_umr_context(&umr_context);
@@ -1013,7 +1013,7 @@ static struct mlx5_ib_mr *reg_create(struct ib_pd *pd, u64 virt_addr,
 	in->seg.qpn_mkey7_0 = cpu_to_be32(0xffffff << 8);
 	in->xlat_oct_act_size = cpu_to_be32(get_octo_len(virt_addr, length,
 							 1 << page_shift));
-	err = mlx5_core_create_mkey(dev->mdev, &mr->mmr, in, inlen, NULL,
+	err = mlx5_core_create_mkey(dev->mdev, &mr->mmkey, in, inlen, NULL,
 				    NULL, NULL);
 	if (err) {
 		mlx5_ib_warn(dev, "create mkey failed\n");
@@ -1024,7 +1024,7 @@ static struct mlx5_ib_mr *reg_create(struct ib_pd *pd, u64 virt_addr,
 	mr->live = 1;
 	kvfree(in);
 
-	mlx5_ib_dbg(dev, "mkey = 0x%x\n", mr->mmr.key);
+	mlx5_ib_dbg(dev, "mkey = 0x%x\n", mr->mmkey.key);
 
 	return mr;
 
@@ -1091,13 +1091,13 @@ struct ib_mr *mlx5_ib_reg_user_mr(struct ib_pd *pd, u64 start, u64 length,
 		goto error;
 	}
 
-	mlx5_ib_dbg(dev, "mkey 0x%x\n", mr->mmr.key);
+	mlx5_ib_dbg(dev, "mkey 0x%x\n", mr->mmkey.key);
 
 	mr->umem = umem;
 	mr->npages = npages;
 	atomic_add(npages, &dev->mdev->priv.reg_pages);
-	mr->ibmr.lkey = mr->mmr.key;
-	mr->ibmr.rkey = mr->mmr.key;
+	mr->ibmr.lkey = mr->mmkey.key;
+	mr->ibmr.rkey = mr->mmkey.key;
 
 #ifdef CONFIG_INFINIBAND_ON_DEMAND_PAGING
 	if (umem->odp_data) {
@@ -1141,7 +1141,7 @@ static int unreg_umr(struct mlx5_ib_dev *dev, struct mlx5_ib_mr *mr)
 
 	memset(&umrwr.wr, 0, sizeof(umrwr));
 	umrwr.wr.wr_id = (u64)(unsigned long)&umr_context;
-	prep_umr_unreg_wqe(dev, &umrwr.wr, mr->mmr.key);
+	prep_umr_unreg_wqe(dev, &umrwr.wr, mr->mmkey.key);
 
 	mlx5_ib_init_umr_context(&umr_context);
 	down(&umrc->sem);
@@ -1236,7 +1236,7 @@ static int clean_mr(struct mlx5_ib_mr *mr)
 		err = destroy_mkey(dev, mr);
 		if (err) {
 			mlx5_ib_warn(dev, "failed to destroy mkey 0x%x (%d)\n",
-				     mr->mmr.key, err);
+				     mr->mmkey.key, err);
 			return err;
 		}
 	} else {
@@ -1362,13 +1362,13 @@ struct ib_mr *mlx5_ib_alloc_mr(struct ib_pd *pd,
 	}
 
 	in->seg.flags = MLX5_PERM_UMR_EN | access_mode;
-	err = mlx5_core_create_mkey(dev->mdev, &mr->mmr, in, sizeof(*in),
+	err = mlx5_core_create_mkey(dev->mdev, &mr->mmkey, in, sizeof(*in),
 				    NULL, NULL, NULL);
 	if (err)
 		goto err_destroy_psv;
 
-	mr->ibmr.lkey = mr->mmr.key;
-	mr->ibmr.rkey = mr->mmr.key;
+	mr->ibmr.lkey = mr->mmkey.key;
+	mr->ibmr.rkey = mr->mmkey.key;
 	mr->umem = NULL;
 	kfree(in);
 
diff --git a/drivers/infiniband/hw/mlx5/odp.c b/drivers/infiniband/hw/mlx5/odp.c
index b8d7636..34e79e7 100644
--- a/drivers/infiniband/hw/mlx5/odp.c
+++ b/drivers/infiniband/hw/mlx5/odp.c
@@ -142,13 +142,13 @@ static struct mlx5_ib_mr *mlx5_ib_odp_find_mr_lkey(struct mlx5_ib_dev *dev,
 						   u32 key)
 {
 	u32 base_key = mlx5_base_mkey(key);
-	struct mlx5_core_mr *mmr = __mlx5_mr_lookup(dev->mdev, base_key);
-	struct mlx5_ib_mr *mr = container_of(mmr, struct mlx5_ib_mr, mmr);
+	struct mlx5_core_mkey *mmkey = __mlx5_mr_lookup(dev->mdev, base_key);
+	struct mlx5_ib_mr *mr = container_of(mmkey, struct mlx5_ib_mr, mmkey);
 
-	if (!mmr || mmr->key != key || !mr->live)
+	if (!mmkey || mmkey->key != key || !mr->live)
 		return NULL;
 
-	return container_of(mmr, struct mlx5_ib_mr, mmr);
+	return container_of(mmkey, struct mlx5_ib_mr, mmkey);
 }
 
 static void mlx5_ib_page_fault_resume(struct mlx5_ib_qp *qp,
@@ -232,7 +232,7 @@ static int pagefault_single_data_segment(struct mlx5_ib_qp *qp,
 	io_virt += pfault->mpfault.bytes_committed;
 	bcnt -= pfault->mpfault.bytes_committed;
 
-	start_idx = (io_virt - (mr->mmr.iova & PAGE_MASK)) >> PAGE_SHIFT;
+	start_idx = (io_virt - (mr->mmkey.iova & PAGE_MASK)) >> PAGE_SHIFT;
 
 	if (mr->umem->writable)
 		access_mask |= ODP_WRITE_ALLOWED_BIT;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 0cb4a09..879e627 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -553,7 +553,7 @@ struct mlx5e_priv {
 	struct mlx5_uar            cq_uar;
 	u32                        pdn;
 	u32                        tdn;
-	struct mlx5_core_mr        mr;
+	struct mlx5_core_mkey      mkey;
 	struct mlx5e_rq            drop_rq;
 
 	struct mlx5e_channel     **channel;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index ac58078..e0adb60 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -979,7 +979,7 @@ static int mlx5e_open_channel(struct mlx5e_priv *priv, int ix,
 	c->cpu      = cpu;
 	c->pdev     = &priv->mdev->pdev->dev;
 	c->netdev   = priv->netdev;
-	c->mkey_be  = cpu_to_be32(priv->mr.key);
+	c->mkey_be  = cpu_to_be32(priv->mkey.key);
 	c->num_tc   = priv->params.num_tc;
 
 	mlx5e_build_channeltc_to_txq_map(priv, ix);
@@ -2418,7 +2418,7 @@ static void mlx5e_build_netdev(struct net_device *netdev)
 }
 
 static int mlx5e_create_mkey(struct mlx5e_priv *priv, u32 pdn,
-			     struct mlx5_core_mr *mr)
+			     struct mlx5_core_mkey *mkey)
 {
 	struct mlx5_core_dev *mdev = priv->mdev;
 	struct mlx5_create_mkey_mbox_in *in;
@@ -2434,7 +2434,7 @@ static int mlx5e_create_mkey(struct mlx5e_priv *priv, u32 pdn,
 	in->seg.flags_pd = cpu_to_be32(pdn | MLX5_MKEY_LEN64);
 	in->seg.qpn_mkey7_0 = cpu_to_be32(0xffffff << 8);
 
-	err = mlx5_core_create_mkey(mdev, mr, in, sizeof(*in), NULL, NULL,
+	err = mlx5_core_create_mkey(mdev, mkey, in, sizeof(*in), NULL, NULL,
 				    NULL);
 
 	kvfree(in);
@@ -2485,7 +2485,7 @@ static void *mlx5e_create_netdev(struct mlx5_core_dev *mdev)
 		goto err_dealloc_pd;
 	}
 
-	err = mlx5e_create_mkey(priv, priv->pdn, &priv->mr);
+	err = mlx5e_create_mkey(priv, priv->pdn, &priv->mkey);
 	if (err) {
 		mlx5_core_err(mdev, "create mkey failed, %d\n", err);
 		goto err_dealloc_transport_domain;
@@ -2575,7 +2575,7 @@ err_destroy_tises:
 	mlx5e_destroy_tises(priv);
 
 err_destroy_mkey:
-	mlx5_core_destroy_mkey(mdev, &priv->mr);
+	mlx5_core_destroy_mkey(mdev, &priv->mkey);
 
 err_dealloc_transport_domain:
 	mlx5_core_dealloc_transport_domain(mdev, priv->tdn);
@@ -2611,7 +2611,7 @@ static void mlx5e_destroy_netdev(struct mlx5_core_dev *mdev, void *vpriv)
 	mlx5e_destroy_rqt(priv, MLX5E_INDIRECTION_RQT);
 	mlx5e_close_drop_rq(priv);
 	mlx5e_destroy_tises(priv);
-	mlx5_core_destroy_mkey(priv->mdev, &priv->mr);
+	mlx5_core_destroy_mkey(priv->mdev, &priv->mkey);
 	mlx5_core_dealloc_transport_domain(priv->mdev, priv->tdn);
 	mlx5_core_dealloc_pd(priv->mdev, priv->pdn);
 	mlx5_unmap_free_uar(priv->mdev, &priv->cq_uar);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index 8b7133d..72a94e7 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -1096,7 +1096,7 @@ static int mlx5_load_one(struct mlx5_core_dev *dev, struct mlx5_priv *priv)
 	mlx5_init_cq_table(dev);
 	mlx5_init_qp_table(dev);
 	mlx5_init_srq_table(dev);
-	mlx5_init_mr_table(dev);
+	mlx5_init_mkey_table(dev);
 
 	err = mlx5_init_fs(dev);
 	if (err) {
@@ -1143,7 +1143,7 @@ err_sriov:
 err_reg_dev:
 	mlx5_cleanup_fs(dev);
 err_fs:
-	mlx5_cleanup_mr_table(dev);
+	mlx5_cleanup_mkey_table(dev);
 	mlx5_cleanup_srq_table(dev);
 	mlx5_cleanup_qp_table(dev);
 	mlx5_cleanup_cq_table(dev);
@@ -1212,7 +1212,7 @@ static int mlx5_unload_one(struct mlx5_core_dev *dev, struct mlx5_priv *priv)
 #endif
 
 	mlx5_cleanup_fs(dev);
-	mlx5_cleanup_mr_table(dev);
+	mlx5_cleanup_mkey_table(dev);
 	mlx5_cleanup_srq_table(dev);
 	mlx5_cleanup_qp_table(dev);
 	mlx5_cleanup_cq_table(dev);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/mr.c b/drivers/net/ethernet/mellanox/mlx5/core/mr.c
index 6fa22b5..77a7293 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/mr.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/mr.c
@@ -36,25 +36,26 @@
 #include <linux/mlx5/cmd.h>
 #include "mlx5_core.h"
 
-void mlx5_init_mr_table(struct mlx5_core_dev *dev)
+void mlx5_init_mkey_table(struct mlx5_core_dev *dev)
 {
-	struct mlx5_mr_table *table = &dev->priv.mr_table;
+	struct mlx5_mkey_table *table = &dev->priv.mkey_table;
 
 	memset(table, 0, sizeof(*table));
 	rwlock_init(&table->lock);
 	INIT_RADIX_TREE(&table->tree, GFP_ATOMIC);
 }
 
-void mlx5_cleanup_mr_table(struct mlx5_core_dev *dev)
+void mlx5_cleanup_mkey_table(struct mlx5_core_dev *dev)
 {
 }
 
-int mlx5_core_create_mkey(struct mlx5_core_dev *dev, struct mlx5_core_mr *mr,
+int mlx5_core_create_mkey(struct mlx5_core_dev *dev,
+			  struct mlx5_core_mkey *mkey,
 			  struct mlx5_create_mkey_mbox_in *in, int inlen,
 			  mlx5_cmd_cbk_t callback, void *context,
 			  struct mlx5_create_mkey_mbox_out *out)
 {
-	struct mlx5_mr_table *table = &dev->priv.mr_table;
+	struct mlx5_mkey_table *table = &dev->priv.mkey_table;
 	struct mlx5_create_mkey_mbox_out lout;
 	int err;
 	u8 key;
@@ -83,34 +84,35 @@ int mlx5_core_create_mkey(struct mlx5_core_dev *dev, struct mlx5_core_mr *mr,
 		return mlx5_cmd_status_to_err(&lout.hdr);
 	}
 
-	mr->iova = be64_to_cpu(in->seg.start_addr);
-	mr->size = be64_to_cpu(in->seg.len);
-	mr->key = mlx5_idx_to_mkey(be32_to_cpu(lout.mkey) & 0xffffff) | key;
-	mr->pd = be32_to_cpu(in->seg.flags_pd) & 0xffffff;
+	mkey->iova = be64_to_cpu(in->seg.start_addr);
+	mkey->size = be64_to_cpu(in->seg.len);
+	mkey->key = mlx5_idx_to_mkey(be32_to_cpu(lout.mkey) & 0xffffff) | key;
+	mkey->pd = be32_to_cpu(in->seg.flags_pd) & 0xffffff;
 
 	mlx5_core_dbg(dev, "out 0x%x, key 0x%x, mkey 0x%x\n",
-		      be32_to_cpu(lout.mkey), key, mr->key);
+		      be32_to_cpu(lout.mkey), key, mkey->key);
 
-	/* connect to MR tree */
+	/* connect to mkey tree */
 	write_lock_irq(&table->lock);
-	err = radix_tree_insert(&table->tree, mlx5_base_mkey(mr->key), mr);
+	err = radix_tree_insert(&table->tree, mlx5_base_mkey(mkey->key), mkey);
 	write_unlock_irq(&table->lock);
 	if (err) {
-		mlx5_core_warn(dev, "failed radix tree insert of mr 0x%x, %d\n",
-			       mlx5_base_mkey(mr->key), err);
-		mlx5_core_destroy_mkey(dev, mr);
+		mlx5_core_warn(dev, "failed radix tree insert of mkey 0x%x, %d\n",
+			       mlx5_base_mkey(mkey->key), err);
+		mlx5_core_destroy_mkey(dev, mkey);
 	}
 
 	return err;
 }
 EXPORT_SYMBOL(mlx5_core_create_mkey);
 
-int mlx5_core_destroy_mkey(struct mlx5_core_dev *dev, struct mlx5_core_mr *mr)
+int mlx5_core_destroy_mkey(struct mlx5_core_dev *dev,
+			   struct mlx5_core_mkey *mkey)
 {
-	struct mlx5_mr_table *table = &dev->priv.mr_table;
+	struct mlx5_mkey_table *table = &dev->priv.mkey_table;
 	struct mlx5_destroy_mkey_mbox_in in;
 	struct mlx5_destroy_mkey_mbox_out out;
-	struct mlx5_core_mr *deleted_mr;
+	struct mlx5_core_mkey *deleted_mkey;
 	unsigned long flags;
 	int err;
 
@@ -118,16 +120,16 @@ int mlx5_core_destroy_mkey(struct mlx5_core_dev *dev, struct mlx5_core_mr *mr)
 	memset(&out, 0, sizeof(out));
 
 	write_lock_irqsave(&table->lock, flags);
-	deleted_mr = radix_tree_delete(&table->tree, mlx5_base_mkey(mr->key));
+	deleted_mkey = radix_tree_delete(&table->tree, mlx5_base_mkey(mkey->key));
 	write_unlock_irqrestore(&table->lock, flags);
-	if (!deleted_mr) {
-		mlx5_core_warn(dev, "failed radix tree delete of mr 0x%x\n",
-			       mlx5_base_mkey(mr->key));
+	if (!deleted_mkey) {
+		mlx5_core_warn(dev, "failed radix tree delete of mkey 0x%x\n",
+			       mlx5_base_mkey(mkey->key));
 		return -ENOENT;
 	}
 
 	in.hdr.opcode = cpu_to_be16(MLX5_CMD_OP_DESTROY_MKEY);
-	in.mkey = cpu_to_be32(mlx5_mkey_to_idx(mr->key));
+	in.mkey = cpu_to_be32(mlx5_mkey_to_idx(mkey->key));
 	err = mlx5_cmd_exec(dev, &in, sizeof(in), &out, sizeof(out));
 	if (err)
 		return err;
@@ -139,7 +141,7 @@ int mlx5_core_destroy_mkey(struct mlx5_core_dev *dev, struct mlx5_core_mr *mr)
 }
 EXPORT_SYMBOL(mlx5_core_destroy_mkey);
 
-int mlx5_core_query_mkey(struct mlx5_core_dev *dev, struct mlx5_core_mr *mr,
+int mlx5_core_query_mkey(struct mlx5_core_dev *dev, struct mlx5_core_mkey *mkey,
 			 struct mlx5_query_mkey_mbox_out *out, int outlen)
 {
 	struct mlx5_query_mkey_mbox_in in;
@@ -149,7 +151,7 @@ int mlx5_core_query_mkey(struct mlx5_core_dev *dev, struct mlx5_core_mr *mr,
 	memset(out, 0, outlen);
 
 	in.hdr.opcode = cpu_to_be16(MLX5_CMD_OP_QUERY_MKEY);
-	in.mkey = cpu_to_be32(mlx5_mkey_to_idx(mr->key));
+	in.mkey = cpu_to_be32(mlx5_mkey_to_idx(mkey->key));
 	err = mlx5_cmd_exec(dev, &in, sizeof(in), out, outlen);
 	if (err)
 		return err;
@@ -161,7 +163,7 @@ int mlx5_core_query_mkey(struct mlx5_core_dev *dev, struct mlx5_core_mr *mr,
 }
 EXPORT_SYMBOL(mlx5_core_query_mkey);
 
-int mlx5_core_dump_fill_mkey(struct mlx5_core_dev *dev, struct mlx5_core_mr *mr,
+int mlx5_core_dump_fill_mkey(struct mlx5_core_dev *dev, struct mlx5_core_mkey *_mkey,
 			     u32 *mkey)
 {
 	struct mlx5_query_special_ctxs_mbox_in in;
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index bb1a880..7e39338 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -340,7 +340,7 @@ struct mlx5_core_sig_ctx {
 	u32			sigerr_count;
 };
 
-struct mlx5_core_mr {
+struct mlx5_core_mkey {
 	u64			iova;
 	u64			size;
 	u32			key;
@@ -428,7 +428,7 @@ struct mlx5_srq_table {
 	struct radix_tree_root	tree;
 };
 
-struct mlx5_mr_table {
+struct mlx5_mkey_table {
 	/* protect radix tree
 	 */
 	rwlock_t		lock;
@@ -484,9 +484,9 @@ struct mlx5_priv {
 	struct mlx5_cq_table	cq_table;
 	/* end: cq staff */
 
-	/* start: mr staff */
-	struct mlx5_mr_table	mr_table;
-	/* end: mr staff */
+	/* start: mkey staff */
+	struct mlx5_mkey_table	mkey_table;
+	/* end: mkey staff */
 
 	/* start: alloc staff */
 	/* protect buffer alocation according to numa node */
@@ -740,16 +740,18 @@ int mlx5_core_query_srq(struct mlx5_core_dev *dev, struct mlx5_core_srq *srq,
 			struct mlx5_query_srq_mbox_out *out);
 int mlx5_core_arm_srq(struct mlx5_core_dev *dev, struct mlx5_core_srq *srq,
 		      u16 lwm, int is_srq);
-void mlx5_init_mr_table(struct mlx5_core_dev *dev);
-void mlx5_cleanup_mr_table(struct mlx5_core_dev *dev);
-int mlx5_core_create_mkey(struct mlx5_core_dev *dev, struct mlx5_core_mr *mr,
+void mlx5_init_mkey_table(struct mlx5_core_dev *dev);
+void mlx5_cleanup_mkey_table(struct mlx5_core_dev *dev);
+int mlx5_core_create_mkey(struct mlx5_core_dev *dev,
+			  struct mlx5_core_mkey *mkey,
 			  struct mlx5_create_mkey_mbox_in *in, int inlen,
 			  mlx5_cmd_cbk_t callback, void *context,
 			  struct mlx5_create_mkey_mbox_out *out);
-int mlx5_core_destroy_mkey(struct mlx5_core_dev *dev, struct mlx5_core_mr *mr);
-int mlx5_core_query_mkey(struct mlx5_core_dev *dev, struct mlx5_core_mr *mr,
+int mlx5_core_destroy_mkey(struct mlx5_core_dev *dev,
+			   struct mlx5_core_mkey *mkey);
+int mlx5_core_query_mkey(struct mlx5_core_dev *dev, struct mlx5_core_mkey *mkey,
 			 struct mlx5_query_mkey_mbox_out *out, int outlen);
-int mlx5_core_dump_fill_mkey(struct mlx5_core_dev *dev, struct mlx5_core_mr *mr,
+int mlx5_core_dump_fill_mkey(struct mlx5_core_dev *dev, struct mlx5_core_mkey *_mkey,
 			     u32 *mkey);
 int mlx5_core_alloc_pd(struct mlx5_core_dev *dev, u32 *pdn);
 int mlx5_core_dealloc_pd(struct mlx5_core_dev *dev, u32 pdn);
diff --git a/include/linux/mlx5/qp.h b/include/linux/mlx5/qp.h
index 5b8c89f..f46324e 100644
--- a/include/linux/mlx5/qp.h
+++ b/include/linux/mlx5/qp.h
@@ -621,9 +621,9 @@ static inline struct mlx5_core_qp *__mlx5_qp_lookup(struct mlx5_core_dev *dev, u
 	return radix_tree_lookup(&dev->priv.qp_table.tree, qpn);
 }
 
-static inline struct mlx5_core_mr *__mlx5_mr_lookup(struct mlx5_core_dev *dev, u32 key)
+static inline struct mlx5_core_mkey *__mlx5_mr_lookup(struct mlx5_core_dev *dev, u32 key)
 {
-	return radix_tree_lookup(&dev->priv.mr_table.tree, key);
+	return radix_tree_lookup(&dev->priv.mkey_table.tree, key);
 }
 
 struct mlx5_page_fault_resume_mbox_in {
-- 
1.7.1

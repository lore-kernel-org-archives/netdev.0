From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: [PATCH] mlx4: Use GFP_NOFS calls during the ipoib TX path when
 creating the QP
Date: Tue, 25 Feb 2014 23:11:05 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1402252307130.5180@pobox.suse.cz>
References: <alpine.LNX.2.00.1402211450410.1192@pobox.suse.cz> <CAJZOPZK4Ah+nKPWnX3=yM43jbf586GYJ+fh0-OL4bOnqKK8v8A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Roland Dreier <roland@kernel.org>, Amir Vadai <amirv@mellanox.com>,
	Eli Cohen <eli@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Mel Gorman <mgorman@suse.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAJZOPZK4Ah+nKPWnX3=yM43jbf586GYJ+fh0-OL4bOnqKK8v8A@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 25 Feb 2014, Or Gerlitz wrote:

> > This was originally a patch from Matthew Finlay <matt@mellanox.com> that
> > addressed a problem whereby NFS writes would enter uninterruptible sleep
> > forever.  The issue happened when using NFS over IPoIB. This is not a
> > recommended configuration as RDMA is preferred but it is still a valid
> > configuration and is important to have in situations where the NFS server
> > does not support RDMA. The problem encountered was described as follows:
> >
> And what happens if you use IPoIB datagram mode, is/why the patch is needed
> there?

First, thanks a lot for looking into this.

I admittedly am no infiniband expert, but my understanding is that in 
principle Connected/Datagram mode is about MTU and checksum offloading, 
but the TX path is the same. Please correct me if I am wrong.

> Also the patch uses a new QP creatiob flag IB_QP_CREATE_USE_GFP_NOFS but 
> it doesn't touch include/rdma/ib_verbs.h nor I see this flag defined 
> anywhere on the patch, does it compile? how?

That's my fault, I forgot 'git add', therefore my tree was building, but 
include/rdma/ib_verbs.h was missing in git index. Updated patch below, 
sorry for the noise.




From: Jiri Kosina <jkosina@suse.cz>
Subject: [PATCH] mlx4: Use all GFP_NOFS calls during the ipoib TX path when creating the QP

This was a patch from Matthew Finlay <matt@mellanox.com> that addressed a
problem whereby NFS writes would enter uninterruptible sleep forever.  The
issue happened when using NFS over IPoIB. This is not a recommended
configuration as RDMA is preferred but it is still a valid configuration and is
important to have in situations where the NFS server does not support RDMA.
The problem encountered was described as follows:

	It's not memory reclamation that is the problem as such. There is
	an indirect dependency between network filesystems writing back
	pages and ipoib_cm_tx_init() due to how a kworker is used. Page
	reclaim cannot make forward progress until ipoib_cm_tx_init()
	succeeds and it is stuck in page reclaim itself waiting for network
	transmission. Ordinarily this sitaution may be avoided by having
	the caller use GFP_NOFS but ipoib_cm_tx_init() does not have
	that information.

The patch has been ported to newer kernels by Mel Gorman and later
ported further by Jiri Kosina.
I'd like to get confirmation from Matt that he's fine with having
his Signed-off-by: on this, but he's not responding to my queries.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Signed-off-by: Jiri Kosina <jkosina@suse.cz>
---
 drivers/infiniband/hw/mlx4/cq.c                    |    6 ++--
 drivers/infiniband/hw/mlx4/qp.c                    |   36 +++++++++++++++-----
 drivers/infiniband/hw/mlx4/srq.c                   |    7 ++--
 drivers/infiniband/ulp/ipoib/ipoib_cm.c            |   16 ++++++++-
 drivers/net/ethernet/mellanox/mlx4/alloc.c         |   35 ++++++++++++-------
 drivers/net/ethernet/mellanox/mlx4/cq.c            |    4 +-
 drivers/net/ethernet/mellanox/mlx4/en_rx.c         |    6 ++--
 drivers/net/ethernet/mellanox/mlx4/en_tx.c         |    2 +-
 drivers/net/ethernet/mellanox/mlx4/icm.c           |   10 ++++--
 drivers/net/ethernet/mellanox/mlx4/icm.h           |    3 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4.h          |    4 +-
 drivers/net/ethernet/mellanox/mlx4/mr.c            |   17 +++++----
 drivers/net/ethernet/mellanox/mlx4/qp.c            |   21 ++++++-----
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |    4 +-
 drivers/net/ethernet/mellanox/mlx4/srq.c           |    4 +-
 include/linux/mlx4/device.h                        |   10 +++--
 include/rdma/ib_verbs.h                            |    1 +
 17 files changed, 118 insertions(+), 68 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/cq.c b/drivers/infiniband/hw/mlx4/cq.c
index cc40f08..661185a 100644
--- a/drivers/infiniband/hw/mlx4/cq.c
+++ b/drivers/infiniband/hw/mlx4/cq.c
@@ -102,7 +102,7 @@ static int mlx4_ib_alloc_cq_buf(struct mlx4_ib_dev *dev, struct mlx4_ib_cq_buf *
 	int err;
 
 	err = mlx4_buf_alloc(dev->dev, nent * dev->dev->caps.cqe_size,
-			     PAGE_SIZE * 2, &buf->buf);
+			     PAGE_SIZE * 2, &buf->buf, 0);
 
 	if (err)
 		goto out;
@@ -113,7 +113,7 @@ static int mlx4_ib_alloc_cq_buf(struct mlx4_ib_dev *dev, struct mlx4_ib_cq_buf *
 	if (err)
 		goto err_buf;
 
-	err = mlx4_buf_write_mtt(dev->dev, &buf->mtt, &buf->buf);
+	err = mlx4_buf_write_mtt(dev->dev, &buf->mtt, &buf->buf, 0);
 	if (err)
 		goto err_mtt;
 
@@ -209,7 +209,7 @@ struct ib_cq *mlx4_ib_create_cq(struct ib_device *ibdev, int entries, int vector
 
 		uar = &to_mucontext(context)->uar;
 	} else {
-		err = mlx4_db_alloc(dev->dev, &cq->db, 1);
+		err = mlx4_db_alloc(dev->dev, &cq->db, 1, 0);
 		if (err)
 			goto err_cq;
 
diff --git a/drivers/infiniband/hw/mlx4/qp.c b/drivers/infiniband/hw/mlx4/qp.c
index d8f4d1f..1379ee7 100644
--- a/drivers/infiniband/hw/mlx4/qp.c
+++ b/drivers/infiniband/hw/mlx4/qp.c
@@ -744,14 +744,18 @@ static int create_qp_common(struct mlx4_ib_dev *dev, struct ib_pd *pd,
 			goto err;
 
 		if (qp_has_rq(init_attr)) {
-			err = mlx4_db_alloc(dev->dev, &qp->db, 0);
+			err = mlx4_db_alloc(dev->dev, &qp->db, 0,
+					init_attr->create_flags &
+						IB_QP_CREATE_USE_GFP_NOFS);
 			if (err)
 				goto err;
 
 			*qp->db.db = 0;
 		}
 
-		if (mlx4_buf_alloc(dev->dev, qp->buf_size, PAGE_SIZE * 2, &qp->buf)) {
+		if (mlx4_buf_alloc(dev->dev, qp->buf_size, PAGE_SIZE * 2, &qp->buf,
+					init_attr->create_flags &
+						IB_QP_CREATE_USE_GFP_NOFS)) {
 			err = -ENOMEM;
 			goto err_db;
 		}
@@ -761,12 +765,20 @@ static int create_qp_common(struct mlx4_ib_dev *dev, struct ib_pd *pd,
 		if (err)
 			goto err_buf;
 
-		err = mlx4_buf_write_mtt(dev->dev, &qp->mtt, &qp->buf);
+		err = mlx4_buf_write_mtt(dev->dev, &qp->mtt, &qp->buf,
+				init_attr->create_flags &
+					IB_QP_CREATE_USE_GFP_NOFS);
 		if (err)
 			goto err_mtt;
 
-		qp->sq.wrid  = kmalloc(qp->sq.wqe_cnt * sizeof (u64), GFP_KERNEL);
-		qp->rq.wrid  = kmalloc(qp->rq.wqe_cnt * sizeof (u64), GFP_KERNEL);
+		qp->sq.wrid  = kmalloc(qp->sq.wqe_cnt * sizeof (u64),
+					init_attr->create_flags &
+						IB_QP_CREATE_USE_GFP_NOFS ?
+							GFP_NOFS : GFP_KERNEL);
+		qp->rq.wrid  = kmalloc(qp->rq.wqe_cnt * sizeof (u64),
+					init_attr->create_flags &
+						IB_QP_CREATE_USE_GFP_NOFS ?
+							GFP_NOFS : GFP_KERNEL);
 
 		if (!qp->sq.wrid || !qp->rq.wrid) {
 			err = -ENOMEM;
@@ -797,7 +809,8 @@ static int create_qp_common(struct mlx4_ib_dev *dev, struct ib_pd *pd,
 			goto err_proxy;
 	}
 
-	err = mlx4_qp_alloc(dev->dev, qpn, &qp->mqp);
+	err = mlx4_qp_alloc(dev->dev, qpn, &qp->mqp,
+			init_attr->create_flags & IB_QP_CREATE_USE_GFP_NOFS);
 	if (err)
 		goto err_qpn;
 
@@ -1024,10 +1037,12 @@ struct ib_qp *mlx4_ib_create_qp(struct ib_pd *pd,
 					MLX4_IB_QP_BLOCK_MULTICAST_LOOPBACK |
 					MLX4_IB_SRIOV_TUNNEL_QP |
 					MLX4_IB_SRIOV_SQP |
-					MLX4_IB_QP_NETIF))
+					MLX4_IB_QP_NETIF |
+					IB_QP_CREATE_USE_GFP_NOFS))
 		return ERR_PTR(-EINVAL);
 
-	if (init_attr->create_flags & IB_QP_CREATE_NETIF_QP) {
+	if (init_attr->create_flags & IB_QP_CREATE_NETIF_QP &&
+	    init_attr->create_flags & ~IB_QP_CREATE_USE_GFP_NOFS) {
 		if (init_attr->qp_type != IB_QPT_UD)
 			return ERR_PTR(-EINVAL);
 	}
@@ -1054,7 +1069,10 @@ struct ib_qp *mlx4_ib_create_qp(struct ib_pd *pd,
 	case IB_QPT_RC:
 	case IB_QPT_UC:
 	case IB_QPT_RAW_PACKET:
-		qp = kzalloc(sizeof *qp, GFP_KERNEL);
+		qp = kzalloc(sizeof *qp,
+				init_attr->create_flags &
+				IB_QP_CREATE_USE_GFP_NOFS ?
+					GFP_NOFS : GFP_KERNEL);
 		if (!qp)
 			return ERR_PTR(-ENOMEM);
 		/* fall through */
diff --git a/drivers/infiniband/hw/mlx4/srq.c b/drivers/infiniband/hw/mlx4/srq.c
index 60c5fb0..17552c0 100644
--- a/drivers/infiniband/hw/mlx4/srq.c
+++ b/drivers/infiniband/hw/mlx4/srq.c
@@ -134,13 +134,14 @@ struct ib_srq *mlx4_ib_create_srq(struct ib_pd *pd,
 		if (err)
 			goto err_mtt;
 	} else {
-		err = mlx4_db_alloc(dev->dev, &srq->db, 0);
+		err = mlx4_db_alloc(dev->dev, &srq->db, 0, 0);
 		if (err)
 			goto err_srq;
 
 		*srq->db.db = 0;
 
-		if (mlx4_buf_alloc(dev->dev, buf_size, PAGE_SIZE * 2, &srq->buf)) {
+		if (mlx4_buf_alloc(dev->dev, buf_size, PAGE_SIZE * 2,
+					&srq->buf, 0)) {
 			err = -ENOMEM;
 			goto err_db;
 		}
@@ -165,7 +166,7 @@ struct ib_srq *mlx4_ib_create_srq(struct ib_pd *pd,
 		if (err)
 			goto err_buf;
 
-		err = mlx4_buf_write_mtt(dev->dev, &srq->mtt, &srq->buf);
+		err = mlx4_buf_write_mtt(dev->dev, &srq->mtt, &srq->buf, 0);
 		if (err)
 			goto err_mtt;
 
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_cm.c b/drivers/infiniband/ulp/ipoib/ipoib_cm.c
index 1377f85..b6dd279 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_cm.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_cm.c
@@ -48,6 +48,13 @@ MODULE_PARM_DESC(max_nonsrq_conn_qp,
 		 "Max number of connected-mode QPs per interface "
 		 "(applied only if shared receive queue is not available)");
 
+int ipoib_use_gfp_nofs = 0;
+
+module_param_named(use_gfp_nofs, ipoib_use_gfp_nofs, int, 0444);
+MODULE_PARM_DESC(use_gfp_nofs,
+		 "Use GFP_NOFS flags when allocating memory during the TX "
+		 "path for CM.  This should be used when running NFS over IPoIB.");
+
 #ifdef CONFIG_INFINIBAND_IPOIB_DEBUG_DATA
 static int data_debug_level;
 
@@ -1030,7 +1037,9 @@ static struct ib_qp *ipoib_cm_create_tx_qp(struct net_device *dev, struct ipoib_
 		.cap.max_send_sge	= 1,
 		.sq_sig_type		= IB_SIGNAL_ALL_WR,
 		.qp_type		= IB_QPT_RC,
-		.qp_context		= tx
+		.qp_context		= tx,
+		.create_flags		= ipoib_use_gfp_nofs ?
+						IB_QP_CREATE_USE_GFP_NOFS : 0
 	};
 
 	return ib_create_qp(priv->pd, &attr);
@@ -1104,12 +1113,15 @@ static int ipoib_cm_tx_init(struct ipoib_cm_tx *p, u32 qpn,
 	struct ipoib_dev_priv *priv = netdev_priv(p->dev);
 	int ret;
 
-	p->tx_ring = vzalloc(ipoib_sendq_size * sizeof *p->tx_ring);
+	p->tx_ring = __vmalloc(ipoib_sendq_size * sizeof *p->tx_ring,
+				ipoib_use_gfp_nofs ? GFP_NOFS : GFP_KERNEL,
+				PAGE_KERNEL);
 	if (!p->tx_ring) {
 		ipoib_warn(priv, "failed to allocate tx ring\n");
 		ret = -ENOMEM;
 		goto err_tx;
 	}
+	memset(p->tx_ring, 0, ipoib_sendq_size * sizeof *p->tx_ring);
 
 	p->qp = ipoib_cm_create_tx_qp(p->dev, p);
 	if (IS_ERR(p->qp)) {
diff --git a/drivers/net/ethernet/mellanox/mlx4/alloc.c b/drivers/net/ethernet/mellanox/mlx4/alloc.c
index c3ad464..60ca7f1 100644
--- a/drivers/net/ethernet/mellanox/mlx4/alloc.c
+++ b/drivers/net/ethernet/mellanox/mlx4/alloc.c
@@ -171,7 +171,7 @@ void mlx4_bitmap_cleanup(struct mlx4_bitmap *bitmap)
  */
 
 int mlx4_buf_alloc(struct mlx4_dev *dev, int size, int max_direct,
-		   struct mlx4_buf *buf)
+		   struct mlx4_buf *buf, int use_gfp_nofs)
 {
 	dma_addr_t t;
 
@@ -180,7 +180,9 @@ int mlx4_buf_alloc(struct mlx4_dev *dev, int size, int max_direct,
 		buf->npages       = 1;
 		buf->page_shift   = get_order(size) + PAGE_SHIFT;
 		buf->direct.buf   = dma_alloc_coherent(&dev->pdev->dev,
-						       size, &t, GFP_KERNEL);
+						       size, &t,
+						       use_gfp_nofs ?
+							GFP_NOFS : GFP_KERNEL);
 		if (!buf->direct.buf)
 			return -ENOMEM;
 
@@ -200,14 +202,16 @@ int mlx4_buf_alloc(struct mlx4_dev *dev, int size, int max_direct,
 		buf->npages      = buf->nbufs;
 		buf->page_shift  = PAGE_SHIFT;
 		buf->page_list   = kcalloc(buf->nbufs, sizeof(*buf->page_list),
-					   GFP_KERNEL);
+					   use_gfp_nofs ? GFP_NOFS : GFP_KERNEL);
 		if (!buf->page_list)
 			return -ENOMEM;
 
 		for (i = 0; i < buf->nbufs; ++i) {
 			buf->page_list[i].buf =
 				dma_alloc_coherent(&dev->pdev->dev, PAGE_SIZE,
-						   &t, GFP_KERNEL);
+						   &t,
+						   use_gfp_nofs ?
+							GFP_NOFS : GFP_KERNEL);
 			if (!buf->page_list[i].buf)
 				goto err_free;
 
@@ -218,7 +222,8 @@ int mlx4_buf_alloc(struct mlx4_dev *dev, int size, int max_direct,
 
 		if (BITS_PER_LONG == 64) {
 			struct page **pages;
-			pages = kmalloc(sizeof *pages * buf->nbufs, GFP_KERNEL);
+			pages = kmalloc(sizeof *pages * buf->nbufs,
+					use_gfp_nofs ? GFP_NOFS : GFP_KERNEL);
 			if (!pages)
 				goto err_free;
 			for (i = 0; i < buf->nbufs; ++i)
@@ -260,11 +265,12 @@ void mlx4_buf_free(struct mlx4_dev *dev, int size, struct mlx4_buf *buf)
 }
 EXPORT_SYMBOL_GPL(mlx4_buf_free);
 
-static struct mlx4_db_pgdir *mlx4_alloc_db_pgdir(struct device *dma_device)
+static struct mlx4_db_pgdir *mlx4_alloc_db_pgdir(struct device *dma_device,
+						 int use_gfp_nofs)
 {
 	struct mlx4_db_pgdir *pgdir;
 
-	pgdir = kzalloc(sizeof *pgdir, GFP_KERNEL);
+	pgdir = kzalloc(sizeof *pgdir, use_gfp_nofs ? GFP_NOFS : GFP_KERNEL);
 	if (!pgdir)
 		return NULL;
 
@@ -272,7 +278,9 @@ static struct mlx4_db_pgdir *mlx4_alloc_db_pgdir(struct device *dma_device)
 	pgdir->bits[0] = pgdir->order0;
 	pgdir->bits[1] = pgdir->order1;
 	pgdir->db_page = dma_alloc_coherent(dma_device, PAGE_SIZE,
-					    &pgdir->db_dma, GFP_KERNEL);
+					    &pgdir->db_dma,
+					    use_gfp_nofs ?
+						GFP_NOFS : GFP_KERNEL);
 	if (!pgdir->db_page) {
 		kfree(pgdir);
 		return NULL;
@@ -312,7 +320,8 @@ found:
 	return 0;
 }
 
-int mlx4_db_alloc(struct mlx4_dev *dev, struct mlx4_db *db, int order)
+int mlx4_db_alloc(struct mlx4_dev *dev, struct mlx4_db *db, int order,
+		  int use_gfp_nofs)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
 	struct mlx4_db_pgdir *pgdir;
@@ -324,7 +333,7 @@ int mlx4_db_alloc(struct mlx4_dev *dev, struct mlx4_db *db, int order)
 		if (!mlx4_alloc_db_from_pgdir(pgdir, db, order))
 			goto out;
 
-	pgdir = mlx4_alloc_db_pgdir(&(dev->pdev->dev));
+	pgdir = mlx4_alloc_db_pgdir(&(dev->pdev->dev), use_gfp_nofs);
 	if (!pgdir) {
 		ret = -ENOMEM;
 		goto out;
@@ -376,13 +385,13 @@ int mlx4_alloc_hwq_res(struct mlx4_dev *dev, struct mlx4_hwq_resources *wqres,
 {
 	int err;
 
-	err = mlx4_db_alloc(dev, &wqres->db, 1);
+	err = mlx4_db_alloc(dev, &wqres->db, 1, 0);
 	if (err)
 		return err;
 
 	*wqres->db.db = 0;
 
-	err = mlx4_buf_alloc(dev, size, max_direct, &wqres->buf);
+	err = mlx4_buf_alloc(dev, size, max_direct, &wqres->buf, 0);
 	if (err)
 		goto err_db;
 
@@ -391,7 +400,7 @@ int mlx4_alloc_hwq_res(struct mlx4_dev *dev, struct mlx4_hwq_resources *wqres,
 	if (err)
 		goto err_buf;
 
-	err = mlx4_buf_write_mtt(dev, &wqres->mtt, &wqres->buf);
+	err = mlx4_buf_write_mtt(dev, &wqres->mtt, &wqres->buf, 0);
 	if (err)
 		goto err_mtt;
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/cq.c b/drivers/net/ethernet/mellanox/mlx4/cq.c
index 0487121..9727175 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cq.c
@@ -173,11 +173,11 @@ int __mlx4_cq_alloc_icm(struct mlx4_dev *dev, int *cqn)
 	if (*cqn == -1)
 		return -ENOMEM;
 
-	err = mlx4_table_get(dev, &cq_table->table, *cqn);
+	err = mlx4_table_get(dev, &cq_table->table, *cqn, 0);
 	if (err)
 		goto err_out;
 
-	err = mlx4_table_get(dev, &cq_table->cmpt_table, *cqn);
+	err = mlx4_table_get(dev, &cq_table->cmpt_table, *cqn, 0);
 	if (err)
 		goto err_put;
 	return 0;
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 890922c..ee77284 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -944,7 +944,7 @@ static int mlx4_en_config_rss_qp(struct mlx4_en_priv *priv, int qpn,
 	if (!context)
 		return -ENOMEM;
 
-	err = mlx4_qp_alloc(mdev->dev, qpn, qp);
+	err = mlx4_qp_alloc(mdev->dev, qpn, qp, 0);
 	if (err) {
 		en_err(priv, "Failed to allocate qp #%x\n", qpn);
 		goto out;
@@ -984,7 +984,7 @@ int mlx4_en_create_drop_qp(struct mlx4_en_priv *priv)
 		en_err(priv, "Failed reserving drop qpn\n");
 		return err;
 	}
-	err = mlx4_qp_alloc(priv->mdev->dev, qpn, &priv->drop_qp);
+	err = mlx4_qp_alloc(priv->mdev->dev, qpn, &priv->drop_qp, 0);
 	if (err) {
 		en_err(priv, "Failed allocating drop qp\n");
 		mlx4_qp_release_range(priv->mdev->dev, qpn, 1);
@@ -1043,7 +1043,7 @@ int mlx4_en_config_rss_steer(struct mlx4_en_priv *priv)
 	}
 
 	/* Configure RSS indirection qp */
-	err = mlx4_qp_alloc(mdev->dev, priv->base_qpn, &rss_map->indir_qp);
+	err = mlx4_qp_alloc(mdev->dev, priv->base_qpn, &rss_map->indir_qp, 0);
 	if (err) {
 		en_err(priv, "Failed to allocate RSS indirection QP\n");
 		goto rss_err;
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 1345703..2f123bf 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -124,7 +124,7 @@ int mlx4_en_create_tx_ring(struct mlx4_en_priv *priv,
 	       ring->buf_size, (unsigned long long) ring->wqres.buf.direct.map);
 
 	ring->qpn = qpn;
-	err = mlx4_qp_alloc(mdev->dev, ring->qpn, &ring->qp);
+	err = mlx4_qp_alloc(mdev->dev, ring->qpn, &ring->qp, 0);
 	if (err) {
 		en_err(priv, "Failed allocating qp %d\n", ring->qpn);
 		goto err_map;
diff --git a/drivers/net/ethernet/mellanox/mlx4/icm.c b/drivers/net/ethernet/mellanox/mlx4/icm.c
index 5fbf492..c83b4e6 100644
--- a/drivers/net/ethernet/mellanox/mlx4/icm.c
+++ b/drivers/net/ethernet/mellanox/mlx4/icm.c
@@ -245,7 +245,8 @@ int mlx4_UNMAP_ICM_AUX(struct mlx4_dev *dev)
 			MLX4_CMD_TIME_CLASS_B, MLX4_CMD_NATIVE);
 }
 
-int mlx4_table_get(struct mlx4_dev *dev, struct mlx4_icm_table *table, u32 obj)
+int mlx4_table_get(struct mlx4_dev *dev, struct mlx4_icm_table *table, u32 obj,
+		   int use_gfp_nofs)
 {
 	u32 i = (obj & (table->num_obj - 1)) /
 			(MLX4_TABLE_CHUNK_SIZE / table->obj_size);
@@ -259,7 +260,10 @@ int mlx4_table_get(struct mlx4_dev *dev, struct mlx4_icm_table *table, u32 obj)
 	}
 
 	table->icm[i] = mlx4_alloc_icm(dev, MLX4_TABLE_CHUNK_SIZE >> PAGE_SHIFT,
-				       (table->lowmem ? GFP_KERNEL : GFP_HIGHUSER) |
+				       (table->lowmem ?
+						(use_gfp_nofs ?
+							GFP_NOFS : GFP_KERNEL) :
+					GFP_HIGHUSER) |
 				       __GFP_NOWARN, table->coherent);
 	if (!table->icm[i]) {
 		ret = -ENOMEM;
@@ -356,7 +360,7 @@ int mlx4_table_get_range(struct mlx4_dev *dev, struct mlx4_icm_table *table,
 	u32 i;
 
 	for (i = start; i <= end; i += inc) {
-		err = mlx4_table_get(dev, table, i);
+		err = mlx4_table_get(dev, table, i, 0);
 		if (err)
 			goto fail;
 	}
diff --git a/drivers/net/ethernet/mellanox/mlx4/icm.h b/drivers/net/ethernet/mellanox/mlx4/icm.h
index dee67fa..2be6ac5 100644
--- a/drivers/net/ethernet/mellanox/mlx4/icm.h
+++ b/drivers/net/ethernet/mellanox/mlx4/icm.h
@@ -71,7 +71,8 @@ struct mlx4_icm *mlx4_alloc_icm(struct mlx4_dev *dev, int npages,
 				gfp_t gfp_mask, int coherent);
 void mlx4_free_icm(struct mlx4_dev *dev, struct mlx4_icm *icm, int coherent);
 
-int mlx4_table_get(struct mlx4_dev *dev, struct mlx4_icm_table *table, u32 obj);
+int mlx4_table_get(struct mlx4_dev *dev, struct mlx4_icm_table *table, u32 obj,
+		   int use_gfp_nofs);
 void mlx4_table_put(struct mlx4_dev *dev, struct mlx4_icm_table *table, u32 obj);
 int mlx4_table_get_range(struct mlx4_dev *dev, struct mlx4_icm_table *table,
 			 u32 start, u32 end);
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index 6b65f77..2d73e12 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -882,7 +882,7 @@ void mlx4_cleanup_cq_table(struct mlx4_dev *dev);
 void mlx4_cleanup_qp_table(struct mlx4_dev *dev);
 void mlx4_cleanup_srq_table(struct mlx4_dev *dev);
 void mlx4_cleanup_mcg_table(struct mlx4_dev *dev);
-int __mlx4_qp_alloc_icm(struct mlx4_dev *dev, int qpn);
+int __mlx4_qp_alloc_icm(struct mlx4_dev *dev, int qpn, int use_gfp_nofs);
 void __mlx4_qp_free_icm(struct mlx4_dev *dev, int qpn);
 int __mlx4_cq_alloc_icm(struct mlx4_dev *dev, int *cqn);
 void __mlx4_cq_free_icm(struct mlx4_dev *dev, int cqn);
@@ -890,7 +890,7 @@ int __mlx4_srq_alloc_icm(struct mlx4_dev *dev, int *srqn);
 void __mlx4_srq_free_icm(struct mlx4_dev *dev, int srqn);
 int __mlx4_mpt_reserve(struct mlx4_dev *dev);
 void __mlx4_mpt_release(struct mlx4_dev *dev, u32 index);
-int __mlx4_mpt_alloc_icm(struct mlx4_dev *dev, u32 index);
+int __mlx4_mpt_alloc_icm(struct mlx4_dev *dev, u32 index, int use_gfp_nofs);
 void __mlx4_mpt_free_icm(struct mlx4_dev *dev, u32 index);
 u32 __mlx4_alloc_mtt_range(struct mlx4_dev *dev, int order);
 void __mlx4_free_mtt_range(struct mlx4_dev *dev, u32 first_seg, int order);
diff --git a/drivers/net/ethernet/mellanox/mlx4/mr.c b/drivers/net/ethernet/mellanox/mlx4/mr.c
index 2483585..5fa9371 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mr.c
+++ b/drivers/net/ethernet/mellanox/mlx4/mr.c
@@ -364,14 +364,14 @@ static void mlx4_mpt_release(struct mlx4_dev *dev, u32 index)
 	__mlx4_mpt_release(dev, index);
 }
 
-int __mlx4_mpt_alloc_icm(struct mlx4_dev *dev, u32 index)
+int __mlx4_mpt_alloc_icm(struct mlx4_dev *dev, u32 index, int use_gfp_nofs)
 {
 	struct mlx4_mr_table *mr_table = &mlx4_priv(dev)->mr_table;
 
-	return mlx4_table_get(dev, &mr_table->dmpt_table, index);
+	return mlx4_table_get(dev, &mr_table->dmpt_table, index, use_gfp_nofs);
 }
 
-static int mlx4_mpt_alloc_icm(struct mlx4_dev *dev, u32 index)
+static int mlx4_mpt_alloc_icm(struct mlx4_dev *dev, u32 index, int use_gfp_nofs)
 {
 	u64 param = 0;
 
@@ -382,7 +382,7 @@ static int mlx4_mpt_alloc_icm(struct mlx4_dev *dev, u32 index)
 							MLX4_CMD_TIME_CLASS_A,
 							MLX4_CMD_WRAPPED);
 	}
-	return __mlx4_mpt_alloc_icm(dev, index);
+	return __mlx4_mpt_alloc_icm(dev, index, use_gfp_nofs);
 }
 
 void __mlx4_mpt_free_icm(struct mlx4_dev *dev, u32 index)
@@ -469,7 +469,7 @@ int mlx4_mr_enable(struct mlx4_dev *dev, struct mlx4_mr *mr)
 	struct mlx4_mpt_entry *mpt_entry;
 	int err;
 
-	err = mlx4_mpt_alloc_icm(dev, key_to_hw_index(mr->key));
+	err = mlx4_mpt_alloc_icm(dev, key_to_hw_index(mr->key), 0);
 	if (err)
 		return err;
 
@@ -627,13 +627,14 @@ int mlx4_write_mtt(struct mlx4_dev *dev, struct mlx4_mtt *mtt,
 EXPORT_SYMBOL_GPL(mlx4_write_mtt);
 
 int mlx4_buf_write_mtt(struct mlx4_dev *dev, struct mlx4_mtt *mtt,
-		       struct mlx4_buf *buf)
+		       struct mlx4_buf *buf, int use_gfp_nofs)
 {
 	u64 *page_list;
 	int err;
 	int i;
 
-	page_list = kmalloc(buf->npages * sizeof *page_list, GFP_KERNEL);
+	page_list = kmalloc(buf->npages * sizeof *page_list,
+			    use_gfp_nofs ? GFP_NOFS : GFP_KERNEL);
 	if (!page_list)
 		return -ENOMEM;
 
@@ -680,7 +681,7 @@ int mlx4_mw_enable(struct mlx4_dev *dev, struct mlx4_mw *mw)
 	struct mlx4_mpt_entry *mpt_entry;
 	int err;
 
-	err = mlx4_mpt_alloc_icm(dev, key_to_hw_index(mw->key));
+	err = mlx4_mpt_alloc_icm(dev, key_to_hw_index(mw->key), 0);
 	if (err)
 		return err;
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/qp.c b/drivers/net/ethernet/mellanox/mlx4/qp.c
index 61d64eb..c6db326 100644
--- a/drivers/net/ethernet/mellanox/mlx4/qp.c
+++ b/drivers/net/ethernet/mellanox/mlx4/qp.c
@@ -272,29 +272,29 @@ void mlx4_qp_release_range(struct mlx4_dev *dev, int base_qpn, int cnt)
 }
 EXPORT_SYMBOL_GPL(mlx4_qp_release_range);
 
-int __mlx4_qp_alloc_icm(struct mlx4_dev *dev, int qpn)
+int __mlx4_qp_alloc_icm(struct mlx4_dev *dev, int qpn, int use_gfp_nofs)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
 	struct mlx4_qp_table *qp_table = &priv->qp_table;
 	int err;
 
-	err = mlx4_table_get(dev, &qp_table->qp_table, qpn);
+	err = mlx4_table_get(dev, &qp_table->qp_table, qpn, use_gfp_nofs);
 	if (err)
 		goto err_out;
 
-	err = mlx4_table_get(dev, &qp_table->auxc_table, qpn);
+	err = mlx4_table_get(dev, &qp_table->auxc_table, qpn, use_gfp_nofs);
 	if (err)
 		goto err_put_qp;
 
-	err = mlx4_table_get(dev, &qp_table->altc_table, qpn);
+	err = mlx4_table_get(dev, &qp_table->altc_table, qpn, use_gfp_nofs);
 	if (err)
 		goto err_put_auxc;
 
-	err = mlx4_table_get(dev, &qp_table->rdmarc_table, qpn);
+	err = mlx4_table_get(dev, &qp_table->rdmarc_table, qpn, use_gfp_nofs);
 	if (err)
 		goto err_put_altc;
 
-	err = mlx4_table_get(dev, &qp_table->cmpt_table, qpn);
+	err = mlx4_table_get(dev, &qp_table->cmpt_table, qpn, use_gfp_nofs);
 	if (err)
 		goto err_put_rdmarc;
 
@@ -316,7 +316,7 @@ err_out:
 	return err;
 }
 
-static int mlx4_qp_alloc_icm(struct mlx4_dev *dev, int qpn)
+static int mlx4_qp_alloc_icm(struct mlx4_dev *dev, int qpn, int use_gfp_nofs)
 {
 	u64 param = 0;
 
@@ -326,7 +326,7 @@ static int mlx4_qp_alloc_icm(struct mlx4_dev *dev, int qpn)
 				    MLX4_CMD_ALLOC_RES, MLX4_CMD_TIME_CLASS_A,
 				    MLX4_CMD_WRAPPED);
 	}
-	return __mlx4_qp_alloc_icm(dev, qpn);
+	return __mlx4_qp_alloc_icm(dev, qpn, use_gfp_nofs);
 }
 
 void __mlx4_qp_free_icm(struct mlx4_dev *dev, int qpn)
@@ -355,7 +355,8 @@ static void mlx4_qp_free_icm(struct mlx4_dev *dev, int qpn)
 		__mlx4_qp_free_icm(dev, qpn);
 }
 
-int mlx4_qp_alloc(struct mlx4_dev *dev, int qpn, struct mlx4_qp *qp)
+int mlx4_qp_alloc(struct mlx4_dev *dev, int qpn, struct mlx4_qp *qp,
+		  int use_gfp_nofs)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
 	struct mlx4_qp_table *qp_table = &priv->qp_table;
@@ -366,7 +367,7 @@ int mlx4_qp_alloc(struct mlx4_dev *dev, int qpn, struct mlx4_qp *qp)
 
 	qp->qpn = qpn;
 
-	err = mlx4_qp_alloc_icm(dev, qpn);
+	err = mlx4_qp_alloc_icm(dev, qpn, use_gfp_nofs);
 	if (err)
 		return err;
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index 57428a0..007434d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -1490,7 +1490,7 @@ static int qp_alloc_res(struct mlx4_dev *dev, int slave, int op, int cmd,
 			return err;
 
 		if (!fw_reserved(dev, qpn)) {
-			err = __mlx4_qp_alloc_icm(dev, qpn);
+			err = __mlx4_qp_alloc_icm(dev, qpn, 0);
 			if (err) {
 				res_abort_move(dev, slave, RES_QP, qpn);
 				return err;
@@ -1577,7 +1577,7 @@ static int mpt_alloc_res(struct mlx4_dev *dev, int slave, int op, int cmd,
 		if (err)
 			return err;
 
-		err = __mlx4_mpt_alloc_icm(dev, mpt->key);
+		err = __mlx4_mpt_alloc_icm(dev, mpt->key, 0);
 		if (err) {
 			res_abort_move(dev, slave, RES_MPT, id);
 			return err;
diff --git a/drivers/net/ethernet/mellanox/mlx4/srq.c b/drivers/net/ethernet/mellanox/mlx4/srq.c
index 98faf87..2cd51a3 100644
--- a/drivers/net/ethernet/mellanox/mlx4/srq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/srq.c
@@ -103,11 +103,11 @@ int __mlx4_srq_alloc_icm(struct mlx4_dev *dev, int *srqn)
 	if (*srqn == -1)
 		return -ENOMEM;
 
-	err = mlx4_table_get(dev, &srq_table->table, *srqn);
+	err = mlx4_table_get(dev, &srq_table->table, *srqn, 0);
 	if (err)
 		goto err_out;
 
-	err = mlx4_table_get(dev, &srq_table->cmpt_table, *srqn);
+	err = mlx4_table_get(dev, &srq_table->cmpt_table, *srqn, 0);
 	if (err)
 		goto err_put;
 	return 0;
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 5edd2c6..de2fcf5 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -826,7 +826,7 @@ static inline int mlx4_is_slave(struct mlx4_dev *dev)
 }
 
 int mlx4_buf_alloc(struct mlx4_dev *dev, int size, int max_direct,
-		   struct mlx4_buf *buf);
+		   struct mlx4_buf *buf, int use_gfp_nofs);
 void mlx4_buf_free(struct mlx4_dev *dev, int size, struct mlx4_buf *buf);
 static inline void *mlx4_buf_offset(struct mlx4_buf *buf, int offset)
 {
@@ -863,9 +863,10 @@ int mlx4_mw_enable(struct mlx4_dev *dev, struct mlx4_mw *mw);
 int mlx4_write_mtt(struct mlx4_dev *dev, struct mlx4_mtt *mtt,
 		   int start_index, int npages, u64 *page_list);
 int mlx4_buf_write_mtt(struct mlx4_dev *dev, struct mlx4_mtt *mtt,
-		       struct mlx4_buf *buf);
+		       struct mlx4_buf *buf, int use_gfp_nofs);
 
-int mlx4_db_alloc(struct mlx4_dev *dev, struct mlx4_db *db, int order);
+int mlx4_db_alloc(struct mlx4_dev *dev, struct mlx4_db *db, int order,
+		  int use_gfp_nofs);
 void mlx4_db_free(struct mlx4_dev *dev, struct mlx4_db *db);
 
 int mlx4_alloc_hwq_res(struct mlx4_dev *dev, struct mlx4_hwq_resources *wqres,
@@ -881,7 +882,8 @@ void mlx4_cq_free(struct mlx4_dev *dev, struct mlx4_cq *cq);
 int mlx4_qp_reserve_range(struct mlx4_dev *dev, int cnt, int align, int *base);
 void mlx4_qp_release_range(struct mlx4_dev *dev, int base_qpn, int cnt);
 
-int mlx4_qp_alloc(struct mlx4_dev *dev, int qpn, struct mlx4_qp *qp);
+int mlx4_qp_alloc(struct mlx4_dev *dev, int qpn, struct mlx4_qp *qp,
+		  int use_gfp_nofs);
 void mlx4_qp_free(struct mlx4_dev *dev, struct mlx4_qp *qp);
 
 int mlx4_srq_alloc(struct mlx4_dev *dev, u32 pdn, u32 cqn, u16 xrcdn,
diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
index 6793f32..f39001c 100644
--- a/include/rdma/ib_verbs.h
+++ b/include/rdma/ib_verbs.h
@@ -643,6 +643,7 @@ enum ib_qp_type {
 enum ib_qp_create_flags {
 	IB_QP_CREATE_IPOIB_UD_LSO		= 1 << 0,
 	IB_QP_CREATE_BLOCK_MULTICAST_LOOPBACK	= 1 << 1,
+	IB_QP_CREATE_USE_GFP_NOFS		= 1 << 2,
 	IB_QP_CREATE_NETIF_QP			= 1 << 5,
 	/* reserve bits 26-31 for low level drivers' internal use */
 	IB_QP_CREATE_RESERVED_START		= 1 << 26,
-- 
Jiri Kosina
SUSE Labs

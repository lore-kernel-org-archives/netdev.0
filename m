From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [net-next][PATCH v2 11/13] RDS: IB: add Fastreg MR (FRMR) detection support
Date: Sat, 27 Feb 2016 18:19:48 -0800
Message-ID: <1456625990-4739-12-git-send-email-santosh.shilimkar@oracle.com>
References: <1456625990-4739-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-kernel@vger.kernel.org,
	Santosh Shilimkar <santosh.shilimkar@oracle.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1456625990-4739-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Discovere Fast Memmory Registration support using IB device
IB_DEVICE_MEM_MGT_EXTENSIONS. Certain HCA might support just FRMR
or FMR or both FMR and FRWR. In case both mr type are supported,
default FMR is used.

Default MR is still kept as FMR against what everyone else
is following. Default will be changed to FRMR once the
RDS performance with FRMR is comparable with FMR. The
work is in progress for the same.

Signed-off-by: Santosh Shilimkar <ssantosh@kernel.org>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
v2: Dropped the module parameter as suggested by David Miller

 net/rds/ib.c    | 10 ++++++++++
 net/rds/ib.h    |  4 ++++
 net/rds/ib_mr.h |  1 +
 3 files changed, 15 insertions(+)

diff --git a/net/rds/ib.c b/net/rds/ib.c
index bb32cb9..b5342fd 100644
--- a/net/rds/ib.c
+++ b/net/rds/ib.c
@@ -140,6 +140,12 @@ static void rds_ib_add_one(struct ib_device *device)
 	rds_ibdev->max_wrs = device->attrs.max_qp_wr;
 	rds_ibdev->max_sge = min(device->attrs.max_sge, RDS_IB_MAX_SGE);
 
+	rds_ibdev->has_fr = (device->attrs.device_cap_flags &
+				  IB_DEVICE_MEM_MGT_EXTENSIONS);
+	rds_ibdev->has_fmr = (device->alloc_fmr && device->dealloc_fmr &&
+			    device->map_phys_fmr && device->unmap_fmr);
+	rds_ibdev->use_fastreg = (rds_ibdev->has_fr && !rds_ibdev->has_fmr);
+
 	rds_ibdev->fmr_max_remaps = device->attrs.max_map_per_fmr?: 32;
 	rds_ibdev->max_1m_mrs = device->attrs.max_mr ?
 		min_t(unsigned int, (device->attrs.max_mr / 2),
@@ -178,6 +184,10 @@ static void rds_ib_add_one(struct ib_device *device)
 		 rds_ibdev->fmr_max_remaps, rds_ibdev->max_1m_mrs,
 		 rds_ibdev->max_8k_mrs);
 
+	pr_info("RDS/IB: %s: %s supported and preferred\n",
+		device->name,
+		rds_ibdev->use_fastreg ? "FRMR" : "FMR");
+
 	INIT_LIST_HEAD(&rds_ibdev->ipaddr_list);
 	INIT_LIST_HEAD(&rds_ibdev->conn_list);
 
diff --git a/net/rds/ib.h b/net/rds/ib.h
index 62fe7d5..c5eddc2 100644
--- a/net/rds/ib.h
+++ b/net/rds/ib.h
@@ -200,6 +200,10 @@ struct rds_ib_device {
 	struct list_head	conn_list;
 	struct ib_device	*dev;
 	struct ib_pd		*pd;
+	bool                    has_fmr;
+	bool                    has_fr;
+	bool                    use_fastreg;
+
 	unsigned int		max_mrs;
 	struct rds_ib_mr_pool	*mr_1m_pool;
 	struct rds_ib_mr_pool   *mr_8k_pool;
diff --git a/net/rds/ib_mr.h b/net/rds/ib_mr.h
index add7725..2f9b9c3 100644
--- a/net/rds/ib_mr.h
+++ b/net/rds/ib_mr.h
@@ -93,6 +93,7 @@ struct rds_ib_mr_pool {
 extern struct workqueue_struct *rds_ib_mr_wq;
 extern unsigned int rds_ib_mr_1m_pool_size;
 extern unsigned int rds_ib_mr_8k_pool_size;
+extern bool prefer_frmr;
 
 struct rds_ib_mr_pool *rds_ib_create_mr_pool(struct rds_ib_device *rds_dev,
 					     int npages);
-- 
1.9.1

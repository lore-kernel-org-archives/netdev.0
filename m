From: Vipul Pandya <vipul@chelsio.com>
Subject: [PATCH v2 net-next 14/22] RDMA/cxgb4: Add module_params to enable DB FC & Coalescing on T5
Date: Thu, 14 Mar 2013 20:39:00 +0530
Message-ID: <1363273748-25330-15-git-send-email-vipul@chelsio.com>
References: <1363273748-25330-1-git-send-email-vipul@chelsio.com>
Cc: davem@davemloft.net, roland@purestorage.com,
	JBottomley@parallels.com, dm@chelsio.com,
	swise@opengridcomputing.com, leedom@chelsio.com,
	naresh@chelsio.com, divy@chelsio.com, santosh@chelsio.com,
	arvindb@chelsio.com, abhishek@chelsio.com, vipul@chelsio.com
To: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
	linux-scsi@vger.kernel.org
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1363273748-25330-1-git-send-email-vipul@chelsio.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Both DB Flow-Control and DB Coalescing are disabled by default on T5

Signed-off-by: Vipul Pandya <vipul@chelsio.com>
---
v2: Replaced #ifdef with portable interface wmb in ring_tx_db

 drivers/infiniband/hw/cxgb4/device.c   |   25 +++++++++++++++++++++++--
 drivers/infiniband/hw/cxgb4/iw_cxgb4.h |    1 +
 drivers/infiniband/hw/cxgb4/qp.c       |   10 ++++++----
 3 files changed, 30 insertions(+), 6 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/device.c b/drivers/infiniband/hw/cxgb4/device.c
index 3487c08..ae65601 100644
--- a/drivers/infiniband/hw/cxgb4/device.c
+++ b/drivers/infiniband/hw/cxgb4/device.c
@@ -45,6 +45,16 @@ MODULE_DESCRIPTION("Chelsio T4/T5 RDMA Driver");
 MODULE_LICENSE("Dual BSD/GPL");
 MODULE_VERSION(DRV_VERSION);
 
+static int allow_db_fc_on_t5;
+module_param(allow_db_fc_on_t5, int, 0644);
+MODULE_PARM_DESC(allow_db_fc_on_t5,
+		 "Allow DB Flow Control on T5 (default = 0)");
+
+static int allow_db_coalescing_on_t5;
+module_param(allow_db_coalescing_on_t5, int, 0644);
+MODULE_PARM_DESC(allow_db_coalescing_on_t5,
+		 "Allow DB Coalescing on T5 (default = 0)");
+
 struct uld_ctx {
 	struct list_head entry;
 	struct cxgb4_lld_info lldi;
@@ -630,8 +640,19 @@ static struct c4iw_dev *c4iw_alloc(const struct cxgb4_lld_info *infop)
 	if (!ocqp_supported(infop))
 		pr_info("%s: On-Chip Queues not supported on this device.\n",
 			pci_name(infop->pdev));
-	if (!is_t4(infop->adapter_type))
-		db_fc_threshold = 100000;
+
+	if (!is_t4(infop->adapter_type)) {
+		if (!allow_db_fc_on_t5) {
+			db_fc_threshold = 100000;
+			pr_info("DB Flow Control Disabled.\n");
+		}
+
+		if (!allow_db_coalescing_on_t5) {
+			db_coalescing_threshold = -1;
+			pr_info("DB Coalescing Disabled.\n");
+		}
+	}
+
 	devp = (struct c4iw_dev *)ib_alloc_device(sizeof(*devp));
 	if (!devp) {
 		printk(KERN_ERR MOD "Cannot allocate ib device\n");
diff --git a/drivers/infiniband/hw/cxgb4/iw_cxgb4.h b/drivers/infiniband/hw/cxgb4/iw_cxgb4.h
index 34c7e62..4dbe96a 100644
--- a/drivers/infiniband/hw/cxgb4/iw_cxgb4.h
+++ b/drivers/infiniband/hw/cxgb4/iw_cxgb4.h
@@ -939,6 +939,7 @@ extern struct cxgb4_client t4c_client;
 extern c4iw_handler_func c4iw_handlers[NUM_CPL_CMDS];
 extern int c4iw_max_read_depth;
 extern int db_fc_threshold;
+extern int db_coalescing_threshold;
 
 
 #endif
diff --git a/drivers/infiniband/hw/cxgb4/qp.c b/drivers/infiniband/hw/cxgb4/qp.c
index da4869f..28592d4 100644
--- a/drivers/infiniband/hw/cxgb4/qp.c
+++ b/drivers/infiniband/hw/cxgb4/qp.c
@@ -1455,8 +1455,9 @@ int c4iw_destroy_qp(struct ib_qp *ib_qp)
 		rhp->db_state = NORMAL;
 		idr_for_each(&rhp->qpidr, enable_qp_db, NULL);
 	}
-	if (rhp->qpcnt <= db_coalescing_threshold)
-		cxgb4_enable_db_coalescing(rhp->rdev.lldi.ports[0]);
+	if (db_coalescing_threshold >= 0)
+		if (rhp->qpcnt <= db_coalescing_threshold)
+			cxgb4_enable_db_coalescing(rhp->rdev.lldi.ports[0]);
 	spin_unlock_irq(&rhp->lock);
 	atomic_dec(&qhp->refcnt);
 	wait_event(qhp->wait, !atomic_read(&qhp->refcnt));
@@ -1574,8 +1575,9 @@ struct ib_qp *c4iw_create_qp(struct ib_pd *pd, struct ib_qp_init_attr *attrs,
 		rhp->db_state = FLOW_CONTROL;
 		idr_for_each(&rhp->qpidr, disable_qp_db, NULL);
 	}
-	if (rhp->qpcnt > db_coalescing_threshold)
-		cxgb4_disable_db_coalescing(rhp->rdev.lldi.ports[0]);
+	if (db_coalescing_threshold >= 0)
+		if (rhp->qpcnt > db_coalescing_threshold)
+			cxgb4_disable_db_coalescing(rhp->rdev.lldi.ports[0]);
 	ret = insert_handle_nolock(rhp, &rhp->qpidr, qhp, qhp->wq.sq.qid);
 	spin_unlock_irq(&rhp->lock);
 	if (ret)
-- 
1.7.1


From: Anish Bhatt <anish@chelsio.com>
Subject: [PATCH net v2] cxgb4: Fix race condition in cleanup
Date: Wed, 20 Aug 2014 13:44:06 -0700
Message-ID: <1408567446-6598-1-git-send-email-anish@chelsio.com>
Cc: davem@davemloft.net, hariprasad@chelsio.com, leedom@chelsio.com,
	svemuri@chelsio.com, nhorman@redhat.com,
	Anish Bhatt <anish@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:59950
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752960AbaHTUoR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Aug 2014 16:44:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a possible race condition when we unregister the PCI Driver and then
flush/destroy the global "workq". This could lead to situations where there
are tasks on the Work Queue with references to now deleted adapter data
structures. Instead, have per-adapter Work Queues which were instantiated and
torn down in init_one() and remove_one(), respectively.

v2: Remove unnecessary call to flush_workqueue() before destroy_workqueue()

Signed-off-by: Anish Bhatt <anish@chelsio.com>
Signed-off-by: Casey Leedom <leedom@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |  1 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 32 ++++++++++++++-----------
 2 files changed, 19 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index d572821..c067b78 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -652,6 +652,7 @@ struct adapter {
 	struct tid_info tids;
 	void **tid_release_head;
 	spinlock_t tid_release_lock;
+	struct workqueue_struct *workq;
 	struct work_struct tid_release_task;
 	struct work_struct db_full_task;
 	struct work_struct db_drop_task;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 1afee70..18fb9c6 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -643,8 +643,6 @@ static int set_rxmode(struct net_device *dev, int mtu, bool sleep_ok)
 	return ret;
 }
 
-static struct workqueue_struct *workq;
-
 /**
  *	link_start - enable a port
  *	@dev: the port to enable
@@ -3340,7 +3338,7 @@ static void cxgb4_queue_tid_release(struct tid_info *t, unsigned int chan,
 	adap->tid_release_head = (void **)((uintptr_t)p | chan);
 	if (!adap->tid_release_task_busy) {
 		adap->tid_release_task_busy = true;
-		queue_work(workq, &adap->tid_release_task);
+		queue_work(adap->workq, &adap->tid_release_task);
 	}
 	spin_unlock_bh(&adap->tid_release_lock);
 }
@@ -4140,7 +4138,7 @@ void t4_db_full(struct adapter *adap)
 		notify_rdma_uld(adap, CXGB4_CONTROL_DB_FULL);
 		t4_set_reg_field(adap, SGE_INT_ENABLE3,
 				 DBFIFO_HP_INT | DBFIFO_LP_INT, 0);
-		queue_work(workq, &adap->db_full_task);
+		queue_work(adap->workq, &adap->db_full_task);
 	}
 }
 
@@ -4150,7 +4148,7 @@ void t4_db_dropped(struct adapter *adap)
 		disable_dbs(adap);
 		notify_rdma_uld(adap, CXGB4_CONTROL_DB_FULL);
 	}
-	queue_work(workq, &adap->db_drop_task);
+	queue_work(adap->workq, &adap->db_drop_task);
 }
 
 static void uld_attach(struct adapter *adap, unsigned int uld)
@@ -6517,6 +6515,12 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto out_disable_device;
 	}
 
+	adapter->workq = create_singlethread_workqueue("cxgb4");
+	if (!adapter->workq) {
+		err = -ENOMEM;
+		goto out_free_adapter;
+	}
+
 	/* PCI device has been enabled */
 	adapter->flags |= DEV_ENABLED;
 
@@ -6715,6 +6719,9 @@ sriov:
  out_unmap_bar0:
 	iounmap(adapter->regs);
  out_free_adapter:
+	if (adapter->workq)
+		destroy_workqueue(adapter->workq);
+
 	kfree(adapter);
  out_disable_device:
 	pci_disable_pcie_error_reporting(pdev);
@@ -6736,6 +6743,11 @@ static void remove_one(struct pci_dev *pdev)
 	if (adapter) {
 		int i;
 
+		/* Tear down per-adapter Work Queue first since it can contain
+		 * references to our adapter data structure.
+		 */
+		destroy_workqueue(adapter->workq);
+
 		if (is_offload(adapter))
 			detach_ulds(adapter);
 
@@ -6788,20 +6800,14 @@ static int __init cxgb4_init_module(void)
 {
 	int ret;
 
-	workq = create_singlethread_workqueue("cxgb4");
-	if (!workq)
-		return -ENOMEM;
-
 	/* Debugfs support is optional, just warn if this fails */
 	cxgb4_debugfs_root = debugfs_create_dir(KBUILD_MODNAME, NULL);
 	if (!cxgb4_debugfs_root)
 		pr_warn("could not create debugfs entry, continuing\n");
 
 	ret = pci_register_driver(&cxgb4_driver);
-	if (ret < 0) {
+	if (ret < 0)
 		debugfs_remove(cxgb4_debugfs_root);
-		destroy_workqueue(workq);
-	}
 
 	register_inet6addr_notifier(&cxgb4_inet6addr_notifier);
 
@@ -6813,8 +6819,6 @@ static void __exit cxgb4_cleanup_module(void)
 	unregister_inet6addr_notifier(&cxgb4_inet6addr_notifier);
 	pci_unregister_driver(&cxgb4_driver);
 	debugfs_remove(cxgb4_debugfs_root);  /* NULL ok */
-	flush_workqueue(workq);
-	destroy_workqueue(workq);
 }
 
 module_init(cxgb4_init_module);
-- 
2.1.0

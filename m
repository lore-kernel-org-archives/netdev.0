From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH v2 net-next 5/7] qed*: Set rdma generic functions prefix
Date: Sun, 18 Jun 2017 14:50:33 +0300
Message-ID: <20170618115035.2156-6-Yuval.Mintz@cavium.com>
References: <20170618115035.2156-1-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Michal.Kalderon@cavium.com>, <linux-rdma@vger.kernel.org>,
        Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0047.outbound.protection.outlook.com ([104.47.38.47]:36864
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752981AbdFRLvb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 18 Jun 2017 07:51:31 -0400
In-Reply-To: <20170618115035.2156-1-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Kalderon <Michal.Kalderon@cavium.com>

Rename the functions common to both iWARP and RoCE to have a prefix of
_rdma_ instead of _roce_.

Signed-off-by: Michal Kalderon <Michal.Kalderon@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/infiniband/hw/qedr/main.c            |   6 +-
 drivers/net/ethernet/qlogic/qede/qede.h      |   4 +-
 drivers/net/ethernet/qlogic/qede/qede_main.c |  12 +--
 drivers/net/ethernet/qlogic/qede/qede_rdma.c | 142 +++++++++++++--------------
 include/linux/qed/qede_rdma.h                |  37 +++----
 5 files changed, 101 insertions(+), 100 deletions(-)

diff --git a/drivers/infiniband/hw/qedr/main.c b/drivers/infiniband/hw/qedr/main.c
index 714eb0c..b5851fd 100644
--- a/drivers/infiniband/hw/qedr/main.c
+++ b/drivers/infiniband/hw/qedr/main.c
@@ -902,7 +902,7 @@ static void qedr_mac_address_change(struct qedr_dev *dev)
  * initialization done before RoCE driver notifies
  * event to stack.
  */
-static void qedr_notify(struct qedr_dev *dev, enum qede_roce_event event)
+static void qedr_notify(struct qedr_dev *dev, enum qede_rdma_event event)
 {
 	switch (event) {
 	case QEDE_UP:
@@ -931,12 +931,12 @@ static struct qedr_driver qedr_drv = {
 
 static int __init qedr_init_module(void)
 {
-	return qede_roce_register_driver(&qedr_drv);
+	return qede_rdma_register_driver(&qedr_drv);
 }
 
 static void __exit qedr_exit_module(void)
 {
-	qede_roce_unregister_driver(&qedr_drv);
+	qede_rdma_unregister_driver(&qedr_drv);
 }
 
 module_init(qedr_init_module);
diff --git a/drivers/net/ethernet/qlogic/qede/qede.h b/drivers/net/ethernet/qlogic/qede/qede.h
index 2d6b30c..4dfb238 100644
--- a/drivers/net/ethernet/qlogic/qede/qede.h
+++ b/drivers/net/ethernet/qlogic/qede/qede.h
@@ -154,8 +154,8 @@ struct qede_vlan {
 struct qede_rdma_dev {
 	struct qedr_dev *qedr_dev;
 	struct list_head entry;
-	struct list_head roce_event_list;
-	struct workqueue_struct *roce_wq;
+	struct list_head rdma_event_list;
+	struct workqueue_struct *rdma_wq;
 };
 
 struct qede_ptp;
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index e9eaa38..06ca13d 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -262,7 +262,7 @@ static int qede_netdev_event(struct notifier_block *this, unsigned long event,
 		break;
 	case NETDEV_CHANGEADDR:
 		edev = netdev_priv(ndev);
-		qede_roce_event_changeaddr(edev);
+		qede_rdma_event_changeaddr(edev);
 		break;
 	}
 
@@ -977,7 +977,7 @@ static int __qede_probe(struct pci_dev *pdev, u32 dp_module, u8 dp_level,
 
 	qede_init_ndev(edev);
 
-	rc = qede_roce_dev_add(edev);
+	rc = qede_rdma_dev_add(edev);
 	if (rc)
 		goto err3;
 
@@ -1013,7 +1013,7 @@ static int __qede_probe(struct pci_dev *pdev, u32 dp_module, u8 dp_level,
 	return 0;
 
 err4:
-	qede_roce_dev_remove(edev);
+	qede_rdma_dev_remove(edev);
 err3:
 	free_netdev(edev->ndev);
 err2:
@@ -1064,7 +1064,7 @@ static void __qede_remove(struct pci_dev *pdev, enum qede_remove_mode mode)
 
 	qede_ptp_disable(edev);
 
-	qede_roce_dev_remove(edev);
+	qede_rdma_dev_remove(edev);
 
 	edev->ops->common->set_power_state(cdev, PCI_D0);
 
@@ -1964,7 +1964,7 @@ static void qede_unload(struct qede_dev *edev, enum qede_unload_mode mode,
 
 	edev->state = QEDE_STATE_CLOSED;
 
-	qede_roce_dev_event_close(edev);
+	qede_rdma_dev_event_close(edev);
 
 	/* Close OS Tx */
 	netif_tx_disable(edev->ndev);
@@ -2069,7 +2069,7 @@ static int qede_load(struct qede_dev *edev, enum qede_load_mode mode,
 	link_params.link_up = true;
 	edev->ops->common->set_link(edev->cdev, &link_params);
 
-	qede_roce_dev_event_open(edev);
+	qede_rdma_dev_event_open(edev);
 
 	edev->state = QEDE_STATE_OPEN;
 
diff --git a/drivers/net/ethernet/qlogic/qede/qede_rdma.c b/drivers/net/ethernet/qlogic/qede/qede_rdma.c
index 9837ee2..50b142f 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_rdma.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_rdma.c
@@ -40,12 +40,12 @@ static struct qedr_driver *qedr_drv;
 static LIST_HEAD(qedr_dev_list);
 static DEFINE_MUTEX(qedr_dev_list_lock);
 
-bool qede_roce_supported(struct qede_dev *dev)
+bool qede_rdma_supported(struct qede_dev *dev)
 {
 	return dev->dev_info.common.rdma_supported;
 }
 
-static void _qede_roce_dev_add(struct qede_dev *edev)
+static void _qede_rdma_dev_add(struct qede_dev *edev)
 {
 	if (!qedr_drv)
 		return;
@@ -54,11 +54,11 @@ static void _qede_roce_dev_add(struct qede_dev *edev)
 						 edev->ndev);
 }
 
-static int qede_roce_create_wq(struct qede_dev *edev)
+static int qede_rdma_create_wq(struct qede_dev *edev)
 {
-	INIT_LIST_HEAD(&edev->rdma_info.roce_event_list);
-	edev->rdma_info.roce_wq = create_singlethread_workqueue("roce_wq");
-	if (!edev->rdma_info.roce_wq) {
+	INIT_LIST_HEAD(&edev->rdma_info.rdma_event_list);
+	edev->rdma_info.rdma_wq = create_singlethread_workqueue("rdma_wq");
+	if (!edev->rdma_info.rdma_wq) {
 		DP_NOTICE(edev, "qedr: Could not create workqueue\n");
 		return -ENOMEM;
 	}
@@ -66,14 +66,14 @@ static int qede_roce_create_wq(struct qede_dev *edev)
 	return 0;
 }
 
-static void qede_roce_cleanup_event(struct qede_dev *edev)
+static void qede_rdma_cleanup_event(struct qede_dev *edev)
 {
-	struct list_head *head = &edev->rdma_info.roce_event_list;
-	struct qede_roce_event_work *event_node;
+	struct list_head *head = &edev->rdma_info.rdma_event_list;
+	struct qede_rdma_event_work *event_node;
 
-	flush_workqueue(edev->rdma_info.roce_wq);
+	flush_workqueue(edev->rdma_info.rdma_wq);
 	while (!list_empty(head)) {
-		event_node = list_entry(head->next, struct qede_roce_event_work,
+		event_node = list_entry(head->next, struct qede_rdma_event_work,
 					list);
 		cancel_work_sync(&event_node->work);
 		list_del(&event_node->list);
@@ -81,85 +81,85 @@ static void qede_roce_cleanup_event(struct qede_dev *edev)
 	}
 }
 
-static void qede_roce_destroy_wq(struct qede_dev *edev)
+static void qede_rdma_destroy_wq(struct qede_dev *edev)
 {
-	qede_roce_cleanup_event(edev);
-	destroy_workqueue(edev->rdma_info.roce_wq);
+	qede_rdma_cleanup_event(edev);
+	destroy_workqueue(edev->rdma_info.rdma_wq);
 }
 
-int qede_roce_dev_add(struct qede_dev *edev)
+int qede_rdma_dev_add(struct qede_dev *edev)
 {
 	int rc = 0;
 
-	if (qede_roce_supported(edev)) {
-		rc = qede_roce_create_wq(edev);
+	if (qede_rdma_supported(edev)) {
+		rc = qede_rdma_create_wq(edev);
 		if (rc)
 			return rc;
 
 		INIT_LIST_HEAD(&edev->rdma_info.entry);
 		mutex_lock(&qedr_dev_list_lock);
 		list_add_tail(&edev->rdma_info.entry, &qedr_dev_list);
-		_qede_roce_dev_add(edev);
+		_qede_rdma_dev_add(edev);
 		mutex_unlock(&qedr_dev_list_lock);
 	}
 
 	return rc;
 }
 
-static void _qede_roce_dev_remove(struct qede_dev *edev)
+static void _qede_rdma_dev_remove(struct qede_dev *edev)
 {
 	if (qedr_drv && qedr_drv->remove && edev->rdma_info.qedr_dev)
 		qedr_drv->remove(edev->rdma_info.qedr_dev);
 	edev->rdma_info.qedr_dev = NULL;
 }
 
-void qede_roce_dev_remove(struct qede_dev *edev)
+void qede_rdma_dev_remove(struct qede_dev *edev)
 {
-	if (!qede_roce_supported(edev))
+	if (!qede_rdma_supported(edev))
 		return;
 
-	qede_roce_destroy_wq(edev);
+	qede_rdma_destroy_wq(edev);
 	mutex_lock(&qedr_dev_list_lock);
-	_qede_roce_dev_remove(edev);
+	_qede_rdma_dev_remove(edev);
 	list_del(&edev->rdma_info.entry);
 	mutex_unlock(&qedr_dev_list_lock);
 }
 
-static void _qede_roce_dev_open(struct qede_dev *edev)
+static void _qede_rdma_dev_open(struct qede_dev *edev)
 {
 	if (qedr_drv && edev->rdma_info.qedr_dev && qedr_drv->notify)
 		qedr_drv->notify(edev->rdma_info.qedr_dev, QEDE_UP);
 }
 
-static void qede_roce_dev_open(struct qede_dev *edev)
+static void qede_rdma_dev_open(struct qede_dev *edev)
 {
-	if (!qede_roce_supported(edev))
+	if (!qede_rdma_supported(edev))
 		return;
 
 	mutex_lock(&qedr_dev_list_lock);
-	_qede_roce_dev_open(edev);
+	_qede_rdma_dev_open(edev);
 	mutex_unlock(&qedr_dev_list_lock);
 }
 
-static void _qede_roce_dev_close(struct qede_dev *edev)
+static void _qede_rdma_dev_close(struct qede_dev *edev)
 {
 	if (qedr_drv && edev->rdma_info.qedr_dev && qedr_drv->notify)
 		qedr_drv->notify(edev->rdma_info.qedr_dev, QEDE_DOWN);
 }
 
-static void qede_roce_dev_close(struct qede_dev *edev)
+static void qede_rdma_dev_close(struct qede_dev *edev)
 {
-	if (!qede_roce_supported(edev))
+	if (!qede_rdma_supported(edev))
 		return;
 
 	mutex_lock(&qedr_dev_list_lock);
-	_qede_roce_dev_close(edev);
+	_qede_rdma_dev_close(edev);
 	mutex_unlock(&qedr_dev_list_lock);
 }
 
-static void qede_roce_dev_shutdown(struct qede_dev *edev)
+static void qede_rdma_dev_shutdown(struct qede_dev *edev)
 {
-	if (!qede_roce_supported(edev))
+	if (!qede_rdma_supported(edev))
 		return;
 
 	mutex_lock(&qedr_dev_list_lock);
@@ -168,7 +168,7 @@ static void qede_roce_dev_shutdown(struct qede_dev *edev)
 	mutex_unlock(&qedr_dev_list_lock);
 }
 
-int qede_roce_register_driver(struct qedr_driver *drv)
+int qede_rdma_register_driver(struct qedr_driver *drv)
 {
 	struct qede_dev *edev;
 	u8 qedr_counter = 0;
@@ -184,52 +184,52 @@ int qede_roce_register_driver(struct qedr_driver *drv)
 		struct net_device *ndev;
 
 		qedr_counter++;
-		_qede_roce_dev_add(edev);
+		_qede_rdma_dev_add(edev);
 		ndev = edev->ndev;
 		if (netif_running(ndev) && netif_oper_up(ndev))
-			_qede_roce_dev_open(edev);
+			_qede_rdma_dev_open(edev);
 	}
 	mutex_unlock(&qedr_dev_list_lock);
 
-	pr_notice("qedr: discovered and registered %d RoCE funcs\n",
+	pr_notice("qedr: discovered and registered %d RDMA funcs\n",
 		  qedr_counter);
 
 	return 0;
 }
-EXPORT_SYMBOL(qede_roce_register_driver);
+EXPORT_SYMBOL(qede_rdma_register_driver);
 
-void qede_roce_unregister_driver(struct qedr_driver *drv)
+void qede_rdma_unregister_driver(struct qedr_driver *drv)
 {
 	struct qede_dev *edev;
 
 	mutex_lock(&qedr_dev_list_lock);
 	list_for_each_entry(edev, &qedr_dev_list, rdma_info.entry) {
 		if (edev->rdma_info.qedr_dev)
-			_qede_roce_dev_remove(edev);
+			_qede_rdma_dev_remove(edev);
 	}
 	qedr_drv = NULL;
 	mutex_unlock(&qedr_dev_list_lock);
 }
-EXPORT_SYMBOL(qede_roce_unregister_driver);
+EXPORT_SYMBOL(qede_rdma_unregister_driver);
 
-static void qede_roce_changeaddr(struct qede_dev *edev)
+static void qede_rdma_changeaddr(struct qede_dev *edev)
 {
-	if (!qede_roce_supported(edev))
+	if (!qede_rdma_supported(edev))
 		return;
 
 	if (qedr_drv && edev->rdma_info.qedr_dev && qedr_drv->notify)
 		qedr_drv->notify(edev->rdma_info.qedr_dev, QEDE_CHANGE_ADDR);
 }
 
-static struct qede_roce_event_work *
-qede_roce_get_free_event_node(struct qede_dev *edev)
+static struct qede_rdma_event_work *
+qede_rdma_get_free_event_node(struct qede_dev *edev)
 {
-	struct qede_roce_event_work *event_node = NULL;
+	struct qede_rdma_event_work *event_node = NULL;
 	struct list_head *list_node = NULL;
 	bool found = false;
 
-	list_for_each(list_node, &edev->rdma_info.roce_event_list) {
-		event_node = list_entry(list_node, struct qede_roce_event_work,
+	list_for_each(list_node, &edev->rdma_info.rdma_event_list) {
+		event_node = list_entry(list_node, struct qede_rdma_event_work,
 					list);
 		if (!work_pending(&event_node->work)) {
 			found = true;
@@ -241,74 +241,74 @@ qede_roce_get_free_event_node(struct qede_dev *edev)
 		event_node = kzalloc(sizeof(*event_node), GFP_KERNEL);
 		if (!event_node) {
 			DP_NOTICE(edev,
-				  "qedr: Could not allocate memory for roce work\n");
+				  "qedr: Could not allocate memory for rdma work\n");
 			return NULL;
 		}
 		list_add_tail(&event_node->list,
-			      &edev->rdma_info.roce_event_list);
+			      &edev->rdma_info.rdma_event_list);
 	}
 
 	return event_node;
 }
 
-static void qede_roce_handle_event(struct work_struct *work)
+static void qede_rdma_handle_event(struct work_struct *work)
 {
-	struct qede_roce_event_work *event_node;
-	enum qede_roce_event event;
+	struct qede_rdma_event_work *event_node;
+	enum qede_rdma_event event;
 	struct qede_dev *edev;
 
-	event_node = container_of(work, struct qede_roce_event_work, work);
+	event_node = container_of(work, struct qede_rdma_event_work, work);
 	event = event_node->event;
 	edev = event_node->ptr;
 
 	switch (event) {
 	case QEDE_UP:
-		qede_roce_dev_open(edev);
+		qede_rdma_dev_open(edev);
 		break;
 	case QEDE_DOWN:
-		qede_roce_dev_close(edev);
+		qede_rdma_dev_close(edev);
 		break;
 	case QEDE_CLOSE:
-		qede_roce_dev_shutdown(edev);
+		qede_rdma_dev_shutdown(edev);
 		break;
 	case QEDE_CHANGE_ADDR:
-		qede_roce_changeaddr(edev);
+		qede_rdma_changeaddr(edev);
 		break;
 	default:
-		DP_NOTICE(edev, "Invalid roce event %d", event);
+		DP_NOTICE(edev, "Invalid rdma event %d", event);
 	}
 }
 
-static void qede_roce_add_event(struct qede_dev *edev,
-				enum qede_roce_event event)
+static void qede_rdma_add_event(struct qede_dev *edev,
+				enum qede_rdma_event event)
 {
-	struct qede_roce_event_work *event_node;
+	struct qede_rdma_event_work *event_node;
 
 	if (!edev->rdma_info.qedr_dev)
 		return;
 
-	event_node = qede_roce_get_free_event_node(edev);
+	event_node = qede_rdma_get_free_event_node(edev);
 	if (!event_node)
 		return;
 
 	event_node->event = event;
 	event_node->ptr = edev;
 
-	INIT_WORK(&event_node->work, qede_roce_handle_event);
-	queue_work(edev->rdma_info.roce_wq, &event_node->work);
+	INIT_WORK(&event_node->work, qede_rdma_handle_event);
+	queue_work(edev->rdma_info.rdma_wq, &event_node->work);
 }
 
-void qede_roce_dev_event_open(struct qede_dev *edev)
+void qede_rdma_dev_event_open(struct qede_dev *edev)
 {
-	qede_roce_add_event(edev, QEDE_UP);
+	qede_rdma_add_event(edev, QEDE_UP);
 }
 
-void qede_roce_dev_event_close(struct qede_dev *edev)
+void qede_rdma_dev_event_close(struct qede_dev *edev)
 {
-	qede_roce_add_event(edev, QEDE_DOWN);
+	qede_rdma_add_event(edev, QEDE_DOWN);
 }
 
-void qede_roce_event_changeaddr(struct qede_dev *edev)
+void qede_rdma_event_changeaddr(struct qede_dev *edev)
 {
-	qede_roce_add_event(edev, QEDE_CHANGE_ADDR);
+	qede_rdma_add_event(edev, QEDE_CHANGE_ADDR);
 }
diff --git a/include/linux/qed/qede_rdma.h b/include/linux/qed/qede_rdma.h
index a1a9b81..1348a16 100644
--- a/include/linux/qed/qede_rdma.h
+++ b/include/linux/qed/qede_rdma.h
@@ -41,18 +41,18 @@ struct qedr_dev;
 struct qed_dev;
 struct qede_dev;
 
-enum qede_roce_event {
+enum qede_rdma_event {
 	QEDE_UP,
 	QEDE_DOWN,
 	QEDE_CHANGE_ADDR,
 	QEDE_CLOSE
 };
 
-struct qede_roce_event_work {
+struct qede_rdma_event_work {
 	struct list_head list;
 	struct work_struct work;
 	void *ptr;
-	enum qede_roce_event event;
+	enum qede_rdma_event event;
 };
 
 struct qedr_driver {
@@ -62,32 +62,33 @@ struct qedr_driver {
 				struct net_device *);
 
 	void (*remove)(struct qedr_dev *);
-	void (*notify)(struct qedr_dev *, enum qede_roce_event);
+	void (*notify)(struct qedr_dev *, enum qede_rdma_event);
 };
 
-/* APIs for RoCE driver to register callback handlers,
+/* APIs for RDMA driver to register callback handlers,
  * which will be invoked when device is added, removed, ifup, ifdown
  */
-int qede_roce_register_driver(struct qedr_driver *drv);
-void qede_roce_unregister_driver(struct qedr_driver *drv);
+int qede_rdma_register_driver(struct qedr_driver *drv);
+void qede_rdma_unregister_driver(struct qedr_driver *drv);
 
-bool qede_roce_supported(struct qede_dev *dev);
+bool qede_rdma_supported(struct qede_dev *dev);
 
 #if IS_ENABLED(CONFIG_QED_RDMA)
-int qede_roce_dev_add(struct qede_dev *dev);
-void qede_roce_dev_event_open(struct qede_dev *dev);
-void qede_roce_dev_event_close(struct qede_dev *dev);
-void qede_roce_dev_remove(struct qede_dev *dev);
-void qede_roce_event_changeaddr(struct qede_dev *qedr);
+int qede_rdma_dev_add(struct qede_dev *dev);
+void qede_rdma_dev_event_open(struct qede_dev *dev);
+void qede_rdma_dev_event_close(struct qede_dev *dev);
+void qede_rdma_dev_remove(struct qede_dev *dev);
+void qede_rdma_event_changeaddr(struct qede_dev *edr);
+
 #else
-static inline int qede_roce_dev_add(struct qede_dev *dev)
+static inline int qede_rdma_dev_add(struct qede_dev *dev);
 {
 	return 0;
 }
 
-static inline void qede_roce_dev_event_open(struct qede_dev *dev) {}
-static inline void qede_roce_dev_event_close(struct qede_dev *dev) {}
-static inline void qede_roce_dev_remove(struct qede_dev *dev) {}
-static inline void qede_roce_event_changeaddr(struct qede_dev *qedr) {}
+static inline void qede_rdma_dev_event_open(struct qede_dev *dev) {}
+static inline void qede_rdma_dev_event_close(struct qede_dev *dev) {}
+static inline void qede_rdma_dev_remove(struct qede_dev *dev) {}
+static inline void qede_rdma_event_changeaddr(struct qede_dev *edr) {}
 #endif
 #endif
-- 
2.9.4

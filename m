From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: [PATCH] ehea: use kernel event queue
Date: Mon, 8 Oct 2007 16:01:33 +0200
Message-ID: <200710081601.34067.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	"Jan-Bernd Themann" <themann@de.ibm.com>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"linux-ppc" <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>,
	Stefan Roscher <stefan.roscher@de.ibm.com>,
	Anton Blanchard <anton@samba.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.29.153]:57204 "EHLO
	mtagate4.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751725AbXJHOBg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 10:01:36 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

eHEA recovery and DLPAR functions are called seldomly. The eHEA workqueues
are replaced by the kernel event queue.

Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>

---
The patch has been built against upstream git

 drivers/net/ehea/ehea.h      |    3 +--
 drivers/net/ehea/ehea_main.c |   28 ++++++++--------------------
 drivers/net/ehea/ehea_qmr.c  |    3 +--
 3 files changed, 10 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ehea/ehea.h b/drivers/net/ehea/ehea.h
index 3022089..ac21526 100644
--- a/drivers/net/ehea/ehea.h
+++ b/drivers/net/ehea/ehea.h
@@ -40,7 +40,7 @@
 #include <asm/io.h>
 
 #define DRV_NAME	"ehea"
-#define DRV_VERSION	"EHEA_0077"
+#define DRV_VERSION	"EHEA_0078"
 
 /* eHEA capability flags */
 #define DLPAR_PORT_ADD_REM 1
@@ -391,7 +391,6 @@ struct ehea_adapter {
 	struct ibmebus_dev *ebus_dev;
 	struct ehea_port *port[EHEA_MAX_PORTS];
 	struct ehea_eq *neq;       /* notification event queue */
-	struct workqueue_struct *ehea_wq;
 	struct tasklet_struct neq_tasklet;
 	struct ehea_mr mr;
 	u32 pd;                    /* protection domain */
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 5bc0a15..2ba57e6 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -94,7 +94,6 @@ MODULE_PARM_DESC(use_lro, " Large Receive Offload, 1: enable, 0: disable, "
 static int port_name_cnt = 0;
 static LIST_HEAD(adapter_list);
 u64 ehea_driver_flags = 0;
-struct workqueue_struct *ehea_driver_wq;
 struct work_struct ehea_rereg_mr_task;
 
 struct semaphore dlpar_mem_lock;
@@ -421,7 +420,7 @@ static int ehea_treat_poll_error(struct ehea_port_res *pr, int rq,
 
 	if (cqe->status & EHEA_CQE_STAT_FAT_ERR_MASK) {
 		ehea_error("Critical receive error. Resetting port.");
-		queue_work(pr->port->adapter->ehea_wq, &pr->port->reset_task);
+		schedule_work(&pr->port->reset_task);
 		return 1;
 	}
 
@@ -596,8 +595,7 @@ static struct ehea_cqe *ehea_proc_cqes(struct ehea_port_res *pr, int my_quota)
 			ehea_error("Send Completion Error: Resetting port");
 			if (netif_msg_tx_err(pr->port))
 				ehea_dump(cqe, sizeof(*cqe), "Send CQE");
-			queue_work(pr->port->adapter->ehea_wq,
-				   &pr->port->reset_task);
+			schedule_work(&pr->port->reset_task);
 			break;
 		}
 
@@ -716,7 +714,7 @@ static irqreturn_t ehea_qp_aff_irq_handler(int irq, void *param)
 		eqe = ehea_poll_eq(port->qp_eq);
 	}
 
-	queue_work(port->adapter->ehea_wq, &port->reset_task);
+	schedule_work(&port->reset_task);
 
 	return IRQ_HANDLED;
 }
@@ -2395,7 +2393,7 @@ static int ehea_stop(struct net_device *dev)
 	if (netif_msg_ifdown(port))
 		ehea_info("disabling port %s", dev->name);
 
-	flush_workqueue(port->adapter->ehea_wq);
+	flush_scheduled_work();
 	down(&port->port_lock);
 	netif_stop_queue(dev);
 	ret = ehea_down(dev);
@@ -2710,7 +2708,7 @@ static void ehea_tx_watchdog(struct net_device *dev)
 
 	if (netif_carrier_ok(dev) &&
 	    !test_bit(__EHEA_STOP_XFER, &ehea_driver_flags))
-		queue_work(port->adapter->ehea_wq, &port->reset_task);
+		schedule_work(&port->reset_task);
 }
 
 int ehea_sense_adapter_attr(struct ehea_adapter *adapter)
@@ -3243,15 +3241,9 @@ static int __devinit ehea_probe_adapter(struct ibmebus_dev *dev,
 		goto out_kill_eq;
 	}
 
-	adapter->ehea_wq = create_workqueue("ehea_wq");
-	if (!adapter->ehea_wq) {
-		ret = -EIO;
-		goto out_free_irq;
-	}
-
 	ret = ehea_create_device_sysfs(dev);
 	if (ret)
-		goto out_kill_wq;
+		goto out_free_irq;
 
 	ret = ehea_setup_ports(adapter);
 	if (ret) {
@@ -3265,9 +3257,6 @@ static int __devinit ehea_probe_adapter(struct ibmebus_dev *dev,
 out_rem_dev_sysfs:
 	ehea_remove_device_sysfs(dev);
 
-out_kill_wq:
-	destroy_workqueue(adapter->ehea_wq);
-
 out_free_irq:
 	ibmebus_free_irq(NULL, adapter->neq->attr.ist1, adapter);
 
@@ -3293,7 +3282,7 @@ static int __devexit ehea_remove(struct ibmebus_dev *dev)
 
 	ehea_remove_device_sysfs(dev);
 
-	destroy_workqueue(adapter->ehea_wq);
+	flush_scheduled_work();
 
 	ibmebus_free_irq(NULL, adapter->neq->attr.ist1, adapter);
 	tasklet_kill(&adapter->neq_tasklet);
@@ -3351,7 +3340,6 @@ int __init ehea_module_init(void)
 	printk(KERN_INFO "IBM eHEA ethernet device driver (Release %s)\n",
 	       DRV_VERSION);
 
-	ehea_driver_wq = create_workqueue("ehea_driver_wq");
 
 	INIT_WORK(&ehea_rereg_mr_task, ehea_rereg_mrs);
 	sema_init(&dlpar_mem_lock, 1);
@@ -3385,7 +3373,7 @@ out:
 
 static void __exit ehea_module_exit(void)
 {
-	destroy_workqueue(ehea_driver_wq);
+	flush_scheduled_work();
 	driver_remove_file(&ehea_driver.driver, &driver_attr_capabilities);
 	ibmebus_unregister_driver(&ehea_driver);
 	ehea_destroy_busmap();
diff --git a/drivers/net/ehea/ehea_qmr.c b/drivers/net/ehea/ehea_qmr.c
index 329a252..83b7643 100644
--- a/drivers/net/ehea/ehea_qmr.c
+++ b/drivers/net/ehea/ehea_qmr.c
@@ -34,7 +34,6 @@
 
 struct ehea_busmap ehea_bmap = { 0, 0, NULL };
 extern u64 ehea_driver_flags;
-extern struct workqueue_struct *ehea_driver_wq;
 extern struct work_struct ehea_rereg_mr_task;
 
 
@@ -618,7 +617,7 @@ u64 ehea_map_vaddr(void *caddr)
 
 	if (unlikely(mapped_addr == -1))
 		if (!test_and_set_bit(__EHEA_STOP_XFER, &ehea_driver_flags))
-			queue_work(ehea_driver_wq, &ehea_rereg_mr_task);
+			schedule_work(&ehea_rereg_mr_task);
 
 	return mapped_addr;
 }
-- 
1.5.2


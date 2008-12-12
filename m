From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 06/33] sfc: Make reset_workqueue driver-global rather than per-NIC
Date: Fri, 12 Dec 2008 12:50:38 +0000
Message-ID: <20081212125037.GF10372@solarflare.com>
References: <cover.1229085672.git.bhutchings@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:59722 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756831AbYLLMul (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 07:50:41 -0500
Content-Disposition: inline
In-Reply-To: <20081212124622.GK32518@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Hodgson <shodgson@solarflare.com>

Each reset is serialised by the rtnl_lock anyway, so there's no win
per-NIC.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c        |   45 ++++++++++++++++++-----------------------
 drivers/net/sfc/net_driver.h |    2 -
 2 files changed, 20 insertions(+), 27 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index bbc8402..127b4da 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -39,6 +39,12 @@
  */
 static struct workqueue_struct *refill_workqueue;
 
+/* Reset workqueue. If any NIC has a hardware failure then a reset will be
+ * queued onto this work queue. This is not a per-nic work queue, because
+ * efx_reset_work() acquires the rtnl lock, so resets are naturally serialised.
+ */
+static struct workqueue_struct *reset_workqueue;
+
 /**************************************************************************
  *
  * Configurable values
@@ -1697,7 +1703,7 @@ void efx_schedule_reset(struct efx_nic *efx, enum reset_type type)
 
 	efx->reset_pending = method;
 
-	queue_work(efx->reset_workqueue, &efx->reset_work);
+	queue_work(reset_workqueue, &efx->reset_work);
 }
 
 /**************************************************************************
@@ -1763,7 +1769,7 @@ static int efx_init_struct(struct efx_nic *efx, struct efx_nic_type *type,
 	struct efx_channel *channel;
 	struct efx_tx_queue *tx_queue;
 	struct efx_rx_queue *rx_queue;
-	int i, rc;
+	int i;
 
 	/* Initialise common structures */
 	memset(efx, 0, sizeof(*efx));
@@ -1832,33 +1838,14 @@ static int efx_init_struct(struct efx_nic *efx, struct efx_nic_type *type,
 				  interrupt_mode);
 
 	efx->workqueue = create_singlethread_workqueue("sfc_work");
-	if (!efx->workqueue) {
-		rc = -ENOMEM;
-		goto fail1;
-	}
-
-	efx->reset_workqueue = create_singlethread_workqueue("sfc_reset");
-	if (!efx->reset_workqueue) {
-		rc = -ENOMEM;
-		goto fail2;
-	}
+	if (!efx->workqueue)
+		return -ENOMEM;
 
 	return 0;
-
- fail2:
-	destroy_workqueue(efx->workqueue);
-	efx->workqueue = NULL;
-
- fail1:
-	return rc;
 }
 
 static void efx_fini_struct(struct efx_nic *efx)
 {
-	if (efx->reset_workqueue) {
-		destroy_workqueue(efx->reset_workqueue);
-		efx->reset_workqueue = NULL;
-	}
 	if (efx->workqueue) {
 		destroy_workqueue(efx->workqueue);
 		efx->workqueue = NULL;
@@ -1923,7 +1910,7 @@ static void efx_pci_remove(struct pci_dev *pci_dev)
 	 * scheduled from this point because efx_stop_all() has been
 	 * called, we are no longer registered with driverlink, and
 	 * the net_device's have been removed. */
-	flush_workqueue(efx->reset_workqueue);
+	cancel_work_sync(&efx->reset_work);
 
 	efx_pci_remove_main(efx);
 
@@ -2045,7 +2032,7 @@ static int __devinit efx_pci_probe(struct pci_dev *pci_dev,
 		 * scheduled since efx_stop_all() has been called, and we
 		 * have not and never have been registered with either
 		 * the rtnetlink or driverlink layers. */
-		flush_workqueue(efx->reset_workqueue);
+		cancel_work_sync(&efx->reset_work);
 
 		/* Retry if a recoverably reset event has been scheduled */
 		if ((efx->reset_pending != RESET_TYPE_INVISIBLE) &&
@@ -2121,6 +2108,11 @@ static int __init efx_init_module(void)
 		rc = -ENOMEM;
 		goto err_refill;
 	}
+	reset_workqueue = create_singlethread_workqueue("sfc_reset");
+	if (!reset_workqueue) {
+		rc = -ENOMEM;
+		goto err_reset;
+	}
 
 	rc = pci_register_driver(&efx_pci_driver);
 	if (rc < 0)
@@ -2129,6 +2121,8 @@ static int __init efx_init_module(void)
 	return 0;
 
  err_pci:
+	destroy_workqueue(reset_workqueue);
+ err_reset:
 	destroy_workqueue(refill_workqueue);
  err_refill:
 	unregister_netdevice_notifier(&efx_netdev_notifier);
@@ -2141,6 +2135,7 @@ static void __exit efx_exit_module(void)
 	printk(KERN_INFO "Solarflare NET driver unloading\n");
 
 	pci_unregister_driver(&efx_pci_driver);
+	destroy_workqueue(reset_workqueue);
 	destroy_workqueue(refill_workqueue);
 	unregister_netdevice_notifier(&efx_netdev_notifier);
 
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index e596c9a..f910609 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -635,7 +635,6 @@ union efx_multicast_hash {
  * @legacy_irq: IRQ number
  * @workqueue: Workqueue for port reconfigures and the HW monitor.
  *	Work items do not hold and must not acquire RTNL.
- * @reset_workqueue: Workqueue for resets.  Work item will acquire RTNL.
  * @reset_work: Scheduled reset workitem
  * @monitor_work: Hardware monitor workitem
  * @membase_phys: Memory BAR value as physical address
@@ -711,7 +710,6 @@ struct efx_nic {
 	const struct efx_nic_type *type;
 	int legacy_irq;
 	struct workqueue_struct *workqueue;
-	struct workqueue_struct *reset_workqueue;
 	struct work_struct reset_work;
 	struct delayed_work monitor_work;
 	resource_size_t membase_phys;
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

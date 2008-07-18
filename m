From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 2/4] sfc: Use a separate workqueue for resets
Date: Fri, 18 Jul 2008 19:01:20 +0100
Message-ID: <20080718180119.GG10471@solarflare.com>
References: <20080718175911.GF10471@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.mbr-roch.zen.net.uk ([212.23.3.140]:34897 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755718AbYGRSBX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2008 14:01:23 -0400
Content-Disposition: inline
In-Reply-To: <20080718175911.GF10471@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This avoids deadlock in case a reset is triggered during self-test.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c        |   20 +++++++++++++++++---
 drivers/net/sfc/net_driver.h |    5 ++++-
 2 files changed, 21 insertions(+), 4 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 0e5fecf..4e89c89 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -2046,7 +2046,7 @@ void efx_schedule_reset(struct efx_nic *efx, enum reset_type type)
 
 	efx->reset_pending = method;
 
-	queue_work(efx->workqueue, &efx->reset_work);
+	queue_work(efx->reset_workqueue, &efx->reset_work);
 }
 
 /**************************************************************************
@@ -2204,14 +2204,28 @@ static int efx_init_struct(struct efx_nic *efx, struct efx_nic_type *type,
 		goto fail1;
 	}
 
+	efx->reset_workqueue = create_singlethread_workqueue("sfc_reset");
+	if (!efx->reset_workqueue) {
+		rc = -ENOMEM;
+		goto fail2;
+	}
+
 	return 0;
 
+ fail2:
+	destroy_workqueue(efx->workqueue);
+	efx->workqueue = NULL;
+
  fail1:
 	return rc;
 }
 
 static void efx_fini_struct(struct efx_nic *efx)
 {
+	if (efx->reset_workqueue) {
+		destroy_workqueue(efx->reset_workqueue);
+		efx->reset_workqueue = NULL;
+	}
 	if (efx->workqueue) {
 		destroy_workqueue(efx->workqueue);
 		efx->workqueue = NULL;
@@ -2281,7 +2295,7 @@ static void efx_pci_remove(struct pci_dev *pci_dev)
 	 * scheduled from this point because efx_stop_all() has been
 	 * called, we are no longer registered with driverlink, and
 	 * the net_device's have been removed. */
-	flush_workqueue(efx->workqueue);
+	flush_workqueue(efx->reset_workqueue);
 
 	efx_pci_remove_main(efx);
 
@@ -2418,7 +2432,7 @@ static int __devinit efx_pci_probe(struct pci_dev *pci_dev,
 		 * scheduled since efx_stop_all() has been called, and we
 		 * have not and never have been registered with either
 		 * the rtnetlink or driverlink layers. */
-		cancel_work_sync(&efx->reset_work);
+		flush_workqueue(efx->reset_workqueue);
 
 		/* Retry if a recoverably reset event has been scheduled */
 		if ((efx->reset_pending != RESET_TYPE_INVISIBLE) &&
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 535807b..c9ce460 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -733,7 +733,9 @@ struct efx_nic_errors {
  * @pci_dev: The PCI device
  * @type: Controller type attributes
  * @legacy_irq: IRQ number
- * @workqueue: Workqueue for resets, port reconfigures and the HW monitor
+ * @workqueue: Workqueue for port reconfigures and the HW monitor.
+ *	Work items do not hold and must not acquire RTNL.
+ * @reset_workqueue: Workqueue for resets.  Work item will acquire RTNL.
  * @reset_work: Scheduled reset workitem
  * @monitor_work: Hardware monitor workitem
  * @membase_phys: Memory BAR value as physical address
@@ -821,6 +823,7 @@ struct efx_nic {
 	const struct efx_nic_type *type;
 	int legacy_irq;
 	struct workqueue_struct *workqueue;
+	struct workqueue_struct *reset_workqueue;
 	struct work_struct reset_work;
 	struct delayed_work monitor_work;
 	unsigned long membase_phys;

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.

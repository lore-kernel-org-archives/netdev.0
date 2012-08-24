From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 06/16] sfc: Change state names to be clearer, and
 comment them
Date: Fri, 24 Aug 2012 20:50:52 +0100
Message-ID: <1345837852.2694.28.camel@bwh-desktop.uk.solarflarecom.com>
References: <1345837574.2694.22.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:56740 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1758130Ab2HXTu4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 15:50:56 -0400
In-Reply-To: <1345837574.2694.22.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

STATE_INIT and STATE_FINI are equivalent and represent incompletely
initialised states; combine them as STATE_UNINIT.

Rename STATE_RUNNING to STATE_READY, to avoid confusion with
netif_running() and IFF_RUNNING.

The comments do not quite match current usage, but this will be
corrected in subsequent fixes.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c           |   24 +++++++++++-------------
 drivers/net/ethernet/sfc/ethtool.c       |    2 +-
 drivers/net/ethernet/sfc/falcon_boards.c |    2 +-
 drivers/net/ethernet/sfc/net_driver.h    |   10 ++++------
 4 files changed, 17 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 3b3f084..9f88ad8 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -202,7 +202,7 @@ static void efx_stop_all(struct efx_nic *efx);
 
 #define EFX_ASSERT_RESET_SERIALISED(efx)		\
 	do {						\
-		if ((efx->state == STATE_RUNNING) ||	\
+		if ((efx->state == STATE_READY) ||	\
 		    (efx->state == STATE_DISABLED))	\
 			ASSERT_RTNL();			\
 	} while (0)
@@ -1556,7 +1556,7 @@ static void efx_start_all(struct efx_nic *efx)
 	 * of these flags are safe to read under just the rtnl lock */
 	if (efx->port_enabled)
 		return;
-	if ((efx->state != STATE_RUNNING) && (efx->state != STATE_INIT))
+	if ((efx->state != STATE_READY) && (efx->state != STATE_UNINIT))
 		return;
 	if (!netif_running(efx->net_dev))
 		return;
@@ -2286,11 +2286,11 @@ static void efx_reset_work(struct work_struct *data)
 	if (!pending)
 		return;
 
-	/* If we're not RUNNING then don't reset. Leave the reset_pending
+	/* If we're not READY then don't reset. Leave the reset_pending
 	 * flags set so that efx_pci_probe_main will be retried */
-	if (efx->state != STATE_RUNNING) {
+	if (efx->state != STATE_READY) {
 		netif_info(efx, drv, efx->net_dev,
-			   "scheduled reset quenched. NIC not RUNNING\n");
+			   "scheduled reset quenched; NIC not ready\n");
 		return;
 	}
 
@@ -2402,7 +2402,7 @@ static int efx_init_struct(struct efx_nic *efx, const struct efx_nic_type *type,
 	INIT_DELAYED_WORK(&efx->selftest_work, efx_selftest_async_work);
 	efx->pci_dev = pci_dev;
 	efx->msg_enable = debug;
-	efx->state = STATE_INIT;
+	efx->state = STATE_UNINIT;
 	strlcpy(efx->name, pci_name(pci_dev), sizeof(efx->name));
 
 	efx->net_dev = net_dev;
@@ -2490,7 +2490,7 @@ static void efx_pci_remove(struct pci_dev *pci_dev)
 
 	/* Mark the NIC as fini, then stop the interface */
 	rtnl_lock();
-	efx->state = STATE_FINI;
+	efx->state = STATE_UNINIT;
 	dev_close(efx->net_dev);
 
 	/* Allow any queued efx_resets() to complete */
@@ -2684,9 +2684,9 @@ static int __devinit efx_pci_probe(struct pci_dev *pci_dev,
 		goto fail4;
 	}
 
-	/* Switch to the running state before we expose the device to the OS,
+	/* Switch to the READY state before we expose the device to the OS,
 	 * so that dev_open()|efx_start_all() will actually start the device */
-	efx->state = STATE_RUNNING;
+	efx->state = STATE_READY;
 
 	rc = efx_register_netdev(efx);
 	if (rc)
@@ -2727,7 +2727,7 @@ static int efx_pm_freeze(struct device *dev)
 {
 	struct efx_nic *efx = pci_get_drvdata(to_pci_dev(dev));
 
-	efx->state = STATE_FINI;
+	efx->state = STATE_UNINIT;
 
 	netif_device_detach(efx->net_dev);
 
@@ -2741,8 +2741,6 @@ static int efx_pm_thaw(struct device *dev)
 {
 	struct efx_nic *efx = pci_get_drvdata(to_pci_dev(dev));
 
-	efx->state = STATE_INIT;
-
 	efx_start_interrupts(efx, false);
 
 	mutex_lock(&efx->mac_lock);
@@ -2753,7 +2751,7 @@ static int efx_pm_thaw(struct device *dev)
 
 	netif_device_attach(efx->net_dev);
 
-	efx->state = STATE_RUNNING;
+	efx->state = STATE_READY;
 
 	efx->type->resume_wol(efx);
 
diff --git a/drivers/net/ethernet/sfc/ethtool.c b/drivers/net/ethernet/sfc/ethtool.c
index 8cba2df..5d0e2a3 100644
--- a/drivers/net/ethernet/sfc/ethtool.c
+++ b/drivers/net/ethernet/sfc/ethtool.c
@@ -531,7 +531,7 @@ static void efx_ethtool_self_test(struct net_device *net_dev,
 

 	ASSERT_RTNL();
-	if (efx->state != STATE_RUNNING) {
+	if (efx->state != STATE_READY) {
 		rc = -EIO;
 		goto fail1;
 	}
diff --git a/drivers/net/ethernet/sfc/falcon_boards.c b/drivers/net/ethernet/sfc/falcon_boards.c
index 8687a6c..ec1e99d 100644
--- a/drivers/net/ethernet/sfc/falcon_boards.c
+++ b/drivers/net/ethernet/sfc/falcon_boards.c
@@ -380,7 +380,7 @@ static ssize_t set_phy_flash_cfg(struct device *dev,
 		new_mode = PHY_MODE_SPECIAL;
 	if (!((old_mode ^ new_mode) & PHY_MODE_SPECIAL)) {
 		err = 0;
-	} else if (efx->state != STATE_RUNNING || netif_running(efx->net_dev)) {
+	} else if (efx->state != STATE_READY || netif_running(efx->net_dev)) {
 		err = -EBUSY;
 	} else {
 		/* Reset the PHY, reconfigure the MAC and enable/disable
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index a4fe9a7..7ab1232 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -430,11 +430,9 @@ enum efx_int_mode {
 #define EFX_INT_MODE_USE_MSI(x) (((x)->interrupt_mode) <= EFX_INT_MODE_MSI)
 
 enum nic_state {
-	STATE_INIT = 0,
-	STATE_RUNNING = 1,
-	STATE_FINI = 2,
-	STATE_DISABLED = 3,
-	STATE_MAX,
+	STATE_UNINIT = 0,	/* device being probed/removed or is frozen */
+	STATE_READY = 1,	/* hardware ready and netdev registered */
+	STATE_DISABLED = 2,	/* device disabled due to hardware errors */
 };
 
 /*
@@ -654,7 +652,7 @@ struct vfdi_status;
  * @irq_rx_adaptive: Adaptive IRQ moderation enabled for RX event queues
  * @irq_rx_moderation: IRQ moderation time for RX event queues
  * @msg_enable: Log message enable flags
- * @state: Device state flag. Serialised by the rtnl_lock.
+ * @state: Device state number (%STATE_*). Serialised by the rtnl_lock.
  * @reset_pending: Bitmask for pending resets
  * @tx_queue: TX DMA queues
  * @rx_queue: RX DMA queues
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

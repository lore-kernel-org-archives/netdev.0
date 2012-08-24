From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 12/16] sfc: Fix reset vs probe/remove/PM races
 involving efx_nic::state
Date: Fri, 24 Aug 2012 20:52:25 +0100
Message-ID: <1345837945.2694.34.camel@bwh-desktop.uk.solarflarecom.com>
References: <1345837574.2694.22.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:56824 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1760132Ab2HXTw2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 15:52:28 -0400
In-Reply-To: <1345837574.2694.22.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We try to defer resets while the device is not READY, but we're not
doing this quite correctly.  In particular, changes to efx_nic::state
are documented as serialised by the RTNL lock, but they aren't.

1. We check whether a reset was requested during probe (suggesting
broken hardware) before we allow requested resets to be scheduled.
This leaves a window where a requested reset would be deferred
indefinitely.

2. Although we cancel the reset work item during device removal,
there are still later operations that can cause it to be scheduled
again.  We need to check the state before scheduling it.

3. Since the state can change between scheduling and running of
the work item, we still need to check it there, and we need to
do so *after* acquiring the RTNL lock which serialises state
changes.

4. We must cancel the reset work item during device removal, if the
state could ever have been READY.  This wasn't done in some of the
failure paths from efx_pci_probe().  Move the cancellation to
efx_pci_remove_main().

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c |   84 ++++++++++++++++++++-------------------
 1 files changed, 43 insertions(+), 41 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 5555e9f..d065340 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -2112,6 +2112,19 @@ static int efx_register_netdev(struct efx_nic *efx)
 
 	rtnl_lock();
 
+	/* Enable resets to be scheduled and check whether any were
+	 * already requested.  If so, the NIC is probably hosed so we
+	 * abort.
+	 */
+	efx->state = STATE_READY;
+	smp_mb(); /* ensure we change state before checking reset_pending */
+	if (efx->reset_pending) {
+		netif_err(efx, probe, efx->net_dev,
+			  "aborting probe due to scheduled reset\n");
+		rc = -EIO;
+		goto fail_locked;
+	}
+
 	rc = dev_alloc_name(net_dev, net_dev->name);
 	if (rc < 0)
 		goto fail_locked;
@@ -2141,14 +2154,14 @@ static int efx_register_netdev(struct efx_nic *efx)
 
 	return 0;
 
+fail_registered:
+	rtnl_lock();
+	unregister_netdevice(net_dev);
 fail_locked:
+	efx->state = STATE_UNINIT;
 	rtnl_unlock();
 	netif_err(efx, drv, efx->net_dev, "could not register net dev\n");
 	return rc;
-
-fail_registered:
-	unregister_netdev(net_dev);
-	return rc;
 }
 
 static void efx_unregister_netdev(struct efx_nic *efx)
@@ -2171,7 +2184,11 @@ static void efx_unregister_netdev(struct efx_nic *efx)
 
 	strlcpy(efx->name, pci_name(efx->pci_dev), sizeof(efx->name));
 	device_remove_file(&efx->pci_dev->dev, &dev_attr_phy_type);
-	unregister_netdev(efx->net_dev);
+
+	rtnl_lock();
+	unregister_netdevice(efx->net_dev);
+	efx->state = STATE_UNINIT;
+	rtnl_unlock();
 }
 
 /**************************************************************************
@@ -2309,13 +2326,15 @@ static void efx_reset_work(struct work_struct *data)
 	if (!pending)
 		return;
 
-	/* If we're not READY then don't reset. Leave the reset_pending
-	 * flags set so that efx_pci_probe_main will be retried */
-	if (efx->state != STATE_READY)
-		return;
-
 	rtnl_lock();
-	(void)efx_reset(efx, fls(pending) - 1);
+
+	/* We checked the state in efx_schedule_reset() but it may
+	 * have changed by now.  Now that we have the RTNL lock,
+	 * it cannot change again.
+	 */
+	if (efx->state == STATE_READY)
+		(void)efx_reset(efx, fls(pending) - 1);
+
 	rtnl_unlock();
 }
 
@@ -2341,6 +2360,13 @@ void efx_schedule_reset(struct efx_nic *efx, enum reset_type type)
 	}
 
 	set_bit(method, &efx->reset_pending);
+	smp_mb(); /* ensure we change reset_pending before checking state */
+
+	/* If we're not READY then just leave the flags set as the cue
+	 * to abort probing or reschedule the reset later.
+	 */
+	if (ACCESS_ONCE(efx->state) != STATE_READY)
+		return;
 
 	/* efx_process_channel() will no longer read events once a
 	 * reset is scheduled. So switch back to poll'd MCDI completions. */
@@ -2485,6 +2511,12 @@ static void efx_fini_struct(struct efx_nic *efx)
  */
 static void efx_pci_remove_main(struct efx_nic *efx)
 {
+	/* Flush reset_work. It can no longer be scheduled since we
+	 * are not READY.
+	 */
+	BUG_ON(efx->state == STATE_READY);
+	cancel_work_sync(&efx->reset_work);
+
 #ifdef CONFIG_RFS_ACCEL
 	free_irq_cpu_rmap(efx->net_dev->rx_cpu_rmap);
 	efx->net_dev->rx_cpu_rmap = NULL;
@@ -2510,11 +2542,8 @@ static void efx_pci_remove(struct pci_dev *pci_dev)
 
 	/* Mark the NIC as fini, then stop the interface */
 	rtnl_lock();
-	efx->state = STATE_UNINIT;
 	dev_close(efx->net_dev);
 	efx_stop_interrupts(efx, false);
-
-	/* Allow any queued efx_resets() to complete */
 	rtnl_unlock();
 
 	efx_sriov_fini(efx);
@@ -2522,12 +2551,6 @@ static void efx_pci_remove(struct pci_dev *pci_dev)
 
 	efx_mtd_remove(efx);
 
-	/* Wait for any scheduled resets to complete. No more will be
-	 * scheduled from this point because efx_stop_all() has been
-	 * called, we are no longer registered with driverlink, and
-	 * the net_device's have been removed. */
-	cancel_work_sync(&efx->reset_work);
-
 	efx_pci_remove_main(efx);
 
 	efx_fini_io(efx);
@@ -2686,30 +2709,9 @@ static int __devinit efx_pci_probe(struct pci_dev *pci_dev,
 		goto fail2;
 
 	rc = efx_pci_probe_main(efx);
-
-	/* Serialise against efx_reset(). No more resets will be
-	 * scheduled since efx_stop_all() has been called, and we have
-	 * not and never have been registered.
-	 */
-	cancel_work_sync(&efx->reset_work);
-
 	if (rc)
 		goto fail3;
 
-	/* If there was a scheduled reset during probe, the NIC is
-	 * probably hosed anyway.
-	 */
-	if (efx->reset_pending) {
-		netif_err(efx, probe, efx->net_dev,
-			  "aborting probe due to scheduled reset\n");
-		rc = -EIO;
-		goto fail4;
-	}
-
-	/* Switch to the READY state before we expose the device to the OS,
-	 * so that dev_open()|efx_start_all() will actually start the device */
-	efx->state = STATE_READY;
-
 	rc = efx_register_netdev(efx);
 	if (rc)
 		goto fail4;
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2/3] bnx2: Prevent "scheduling while atomic" warning
 with cnic, bonding and vlan.
Date: Tue, 27 Apr 2010 14:28:10 -0700
Message-ID: <1272403691-2934-2-git-send-email-mchan@broadcom.com>
References: <1272403691-2934-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, jfeeney@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3202 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753915Ab0D0VRD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Apr 2010 17:17:03 -0400
In-Reply-To: <1272403691-2934-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bonding driver calls ndo_vlan_rx_register() while holding bond->lock.
The bnx2 driver calls bnx2_netif_stop() to stop the rx handling while
changing the vlgrp.  The call also stops the cnic driver which sleeps
while the bond->lock is held and cause the warning.

This code path only needs to stop the NAPI rx handling while we are
changing the vlgrp.  Since no reset is going to occur, there is no need
to stop cnic in this case.  By adding a parameter to bnx2_netif_stop()
to skip stopping cnic, we can avoid the warning.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c |   38 ++++++++++++++++++++------------------
 1 files changed, 20 insertions(+), 18 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 4c1e51e..35eec2d 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -651,9 +651,10 @@ bnx2_napi_enable(struct bnx2 *bp)
 }
 
 static void
-bnx2_netif_stop(struct bnx2 *bp)
+bnx2_netif_stop(struct bnx2 *bp, bool stop_cnic)
 {
-	bnx2_cnic_stop(bp);
+	if (stop_cnic)
+		bnx2_cnic_stop(bp);
 	if (netif_running(bp->dev)) {
 		int i;
 
@@ -671,14 +672,15 @@ bnx2_netif_stop(struct bnx2 *bp)
 }
 
 static void
-bnx2_netif_start(struct bnx2 *bp)
+bnx2_netif_start(struct bnx2 *bp, bool start_cnic)
 {
 	if (atomic_dec_and_test(&bp->intr_sem)) {
 		if (netif_running(bp->dev)) {
 			netif_tx_wake_all_queues(bp->dev);
 			bnx2_napi_enable(bp);
 			bnx2_enable_int(bp);
-			bnx2_cnic_start(bp);
+			if (start_cnic)
+				bnx2_cnic_start(bp);
 		}
 	}
 }
@@ -6277,12 +6279,12 @@ bnx2_reset_task(struct work_struct *work)
 		return;
 	}
 
-	bnx2_netif_stop(bp);
+	bnx2_netif_stop(bp, true);
 
 	bnx2_init_nic(bp, 1);
 
 	atomic_set(&bp->intr_sem, 1);
-	bnx2_netif_start(bp);
+	bnx2_netif_start(bp, true);
 	rtnl_unlock();
 }
 
@@ -6324,7 +6326,7 @@ bnx2_vlan_rx_register(struct net_device *dev, struct vlan_group *vlgrp)
 	struct bnx2 *bp = netdev_priv(dev);
 
 	if (netif_running(dev))
-		bnx2_netif_stop(bp);
+		bnx2_netif_stop(bp, false);
 
 	bp->vlgrp = vlgrp;
 
@@ -6335,7 +6337,7 @@ bnx2_vlan_rx_register(struct net_device *dev, struct vlan_group *vlgrp)
 	if (bp->flags & BNX2_FLAG_CAN_KEEP_VLAN)
 		bnx2_fw_sync(bp, BNX2_DRV_MSG_CODE_KEEP_VLAN_UPDATE, 0, 1);
 
-	bnx2_netif_start(bp);
+	bnx2_netif_start(bp, false);
 }
 #endif
 
@@ -7055,9 +7057,9 @@ bnx2_set_coalesce(struct net_device *dev, struct ethtool_coalesce *coal)
 	bp->stats_ticks &= BNX2_HC_STATS_TICKS_HC_STAT_TICKS;
 
 	if (netif_running(bp->dev)) {
-		bnx2_netif_stop(bp);
+		bnx2_netif_stop(bp, true);
 		bnx2_init_nic(bp, 0);
-		bnx2_netif_start(bp);
+		bnx2_netif_start(bp, true);
 	}
 
 	return 0;
@@ -7087,7 +7089,7 @@ bnx2_change_ring_size(struct bnx2 *bp, u32 rx, u32 tx)
 		/* Reset will erase chipset stats; save them */
 		bnx2_save_stats(bp);
 
-		bnx2_netif_stop(bp);
+		bnx2_netif_stop(bp, true);
 		bnx2_reset_chip(bp, BNX2_DRV_MSG_CODE_RESET);
 		bnx2_free_skbs(bp);
 		bnx2_free_mem(bp);
@@ -7115,7 +7117,7 @@ bnx2_change_ring_size(struct bnx2 *bp, u32 rx, u32 tx)
 			bnx2_setup_cnic_irq_info(bp);
 		mutex_unlock(&bp->cnic_lock);
 #endif
-		bnx2_netif_start(bp);
+		bnx2_netif_start(bp, true);
 	}
 	return 0;
 }
@@ -7368,7 +7370,7 @@ bnx2_self_test(struct net_device *dev, struct ethtool_test *etest, u64 *buf)
 	if (etest->flags & ETH_TEST_FL_OFFLINE) {
 		int i;
 
-		bnx2_netif_stop(bp);
+		bnx2_netif_stop(bp, true);
 		bnx2_reset_chip(bp, BNX2_DRV_MSG_CODE_DIAG);
 		bnx2_free_skbs(bp);
 
@@ -7387,7 +7389,7 @@ bnx2_self_test(struct net_device *dev, struct ethtool_test *etest, u64 *buf)
 			bnx2_shutdown_chip(bp);
 		else {
 			bnx2_init_nic(bp, 1);
-			bnx2_netif_start(bp);
+			bnx2_netif_start(bp, true);
 		}
 
 		/* wait for link up */
@@ -8381,7 +8383,7 @@ bnx2_suspend(struct pci_dev *pdev, pm_message_t state)
 		return 0;
 
 	flush_scheduled_work();
-	bnx2_netif_stop(bp);
+	bnx2_netif_stop(bp, true);
 	netif_device_detach(dev);
 	del_timer_sync(&bp->timer);
 	bnx2_shutdown_chip(bp);
@@ -8403,7 +8405,7 @@ bnx2_resume(struct pci_dev *pdev)
 	bnx2_set_power_state(bp, PCI_D0);
 	netif_device_attach(dev);
 	bnx2_init_nic(bp, 1);
-	bnx2_netif_start(bp);
+	bnx2_netif_start(bp, true);
 	return 0;
 }
 
@@ -8430,7 +8432,7 @@ static pci_ers_result_t bnx2_io_error_detected(struct pci_dev *pdev,
 	}
 
 	if (netif_running(dev)) {
-		bnx2_netif_stop(bp);
+		bnx2_netif_stop(bp, true);
 		del_timer_sync(&bp->timer);
 		bnx2_reset_nic(bp, BNX2_DRV_MSG_CODE_RESET);
 	}
@@ -8487,7 +8489,7 @@ static void bnx2_io_resume(struct pci_dev *pdev)
 
 	rtnl_lock();
 	if (netif_running(dev))
-		bnx2_netif_start(bp);
+		bnx2_netif_start(bp, true);
 
 	netif_device_attach(dev);
 	rtnl_unlock();
-- 
1.6.4.GIT



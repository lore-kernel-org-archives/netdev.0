From: Jakub Kicinski <kubakici@wp.pl>
Subject: [PATCH net-next] ixgbe: stop PTP before suspending
Date: Thu, 20 Mar 2014 20:14:32 +0100
Message-ID: <1395342872-13496-1-git-send-email-kubakici@wp.pl>
Cc: Jakub Kicinski <kubakici@wp.pl>, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.wp.pl ([212.77.101.10]:55721 "EHLO mx3.wp.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756651AbaCTTO7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Mar 2014 15:14:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Resume path calls .open but suspend path cannot call .stop because
fdirs should not be freed and control over hardware should not be
released until WoL is configured.  To avoid having to duplicate all
changes made in .stop on suspend path split out part of .stop that
is relevant during suspend and call it from .stop and during suspend.

This fixes ixgbe_ptp_stop() not being called on suspend and helps
to avoid similar bugs in the future.

Signed-off-by: Jakub Kicinski <kubakici@wp.pl>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 27 ++++++++++++++-------------
 1 file changed, 14 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 5029aa9..92bda78 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -5530,6 +5530,17 @@ err_setup_tx:
 	return err;
 }
 
+static void ixgbe_close_suspend(struct ixgbe_adapter *adapter)
+{
+	ixgbe_ptp_stop(adapter);
+
+	ixgbe_down(adapter);
+	ixgbe_free_irq(adapter);
+
+	ixgbe_free_all_tx_resources(adapter);
+	ixgbe_free_all_rx_resources(adapter);
+}
+
 /**
  * ixgbe_close - Disables a network interface
  * @netdev: network interface device structure
@@ -5545,16 +5556,10 @@ static int ixgbe_close(struct net_device *netdev)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 
-	ixgbe_ptp_stop(adapter);
-
-	ixgbe_down(adapter);
-	ixgbe_free_irq(adapter);
+	ixgbe_close_suspend(adapter);
 
 	ixgbe_fdir_filter_exit(adapter);
 
-	ixgbe_free_all_tx_resources(adapter);
-	ixgbe_free_all_rx_resources(adapter);
-
 	ixgbe_release_hw_control(adapter);
 
 	return 0;
@@ -5619,12 +5624,8 @@ static int __ixgbe_shutdown(struct pci_dev *pdev, bool *enable_wake)
 	netif_device_detach(netdev);
 
 	rtnl_lock();
-	if (netif_running(netdev)) {
-		ixgbe_down(adapter);
-		ixgbe_free_irq(adapter);
-		ixgbe_free_all_tx_resources(adapter);
-		ixgbe_free_all_rx_resources(adapter);
-	}
+	if (netif_running(netdev))
+		ixgbe_close_suspend(adapter);
 	rtnl_unlock();
 
 	ixgbe_clear_interrupt_scheme(adapter);
-- 
1.8.5.3

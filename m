From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/15] ixgbe: avoid duplicate code in suspend and stop paths
Date: Tue, 27 May 2014 02:12:23 -0700
Message-ID: <1401181951-31358-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1401181951-31358-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jakub Kicinski <kubakici@wp.pl>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:17026 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751879AbaE0JMm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 May 2014 05:12:42 -0400
In-Reply-To: <1401181951-31358-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Resume path calls .open but suspend path cannot call .stop because
fdirs should not be freed and control over hardware should not be
released until WoL is configured.  To avoid having to duplicate all
changes made in .stop on suspend path split out part of .stop that
is relevant during suspend and call it from .stop and during suspend.

This fix also ensures that ixgbe_ptp_suspend is called during the
suspend path, and helps avoid similar errors. We can't call
ixgbe_ptp_stop, since it will free the PTP clock device, which we
shouldn't be doing during a suspend path.

Signed-off-by: Jakub Kicinski <kubakici@wp.pl>
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 25 ++++++++++++++-----------
 1 file changed, 14 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index cf9956a..ea11e2c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -5659,6 +5659,17 @@ err_setup_tx:
 	return err;
 }
 
+static void ixgbe_close_suspend(struct ixgbe_adapter *adapter)
+{
+	ixgbe_ptp_suspend(adapter);
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
@@ -5676,14 +5687,10 @@ static int ixgbe_close(struct net_device *netdev)
 
 	ixgbe_ptp_stop(adapter);
 
-	ixgbe_down(adapter);
-	ixgbe_free_irq(adapter);
+	ixgbe_close_suspend(adapter);
 
 	ixgbe_fdir_filter_exit(adapter);
 
-	ixgbe_free_all_tx_resources(adapter);
-	ixgbe_free_all_rx_resources(adapter);
-
 	ixgbe_release_hw_control(adapter);
 
 	return 0;
@@ -5750,12 +5757,8 @@ static int __ixgbe_shutdown(struct pci_dev *pdev, bool *enable_wake)
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
1.9.3

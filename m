From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 11/16] ixgbe: DCB, remove RESET bit it is no longer needed
Date: Tue,  8 Feb 2011 04:29:22 -0800
Message-ID: <1297168167-15755-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1297168167-15755-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:47702 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753960Ab1BHM3i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Feb 2011 07:29:38 -0500
In-Reply-To: <1297168167-15755-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

This removes the RESET bit previously used to force a device
reset when DCB bandwidth configurations were changed. This can
now be done dynamically without a reset so the bit is no longer
needed. The only remaining operations that force a device reset
are DCB enable/disable and FCoE application priority changes.
DCB enable/disable is a hardware requirement.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_dcb_nl.c |   37 ++++++++++++-------------------------
 1 files changed, 12 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ixgbe/ixgbe_dcb_nl.c
index b3a8d24..c94adec 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_nl.c
@@ -37,7 +37,6 @@
 #define BIT_PG_RX	0x04
 #define BIT_PG_TX	0x08
 #define BIT_APP_UPCHG	0x10
-#define BIT_RESETLINK   0x40
 #define BIT_LINKSPEED   0x80
 
 /* Responses for the DCB_C_SET_ALL command */
@@ -345,7 +344,6 @@ static void ixgbe_dcbnl_get_pfc_cfg(struct net_device *netdev, int priority,
 static u8 ixgbe_dcbnl_set_all(struct net_device *netdev)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
-	bool do_reset;
 	int ret;
 
 	if (!adapter->dcb_set_bitmap)
@@ -358,23 +356,17 @@ static u8 ixgbe_dcbnl_set_all(struct net_device *netdev)
 		return DCB_NO_HW_CHG;
 
 	/*
-	 * Only take down the adapter if the configuration change
-	 * requires a reset.
+	 * Only take down the adapter if an app change occured. FCoE
+	 * may shuffle tx rings in this case and this can not be done
+	 * without a reset currently.
 	 */
-	do_reset = adapter->dcb_set_bitmap & (BIT_RESETLINK | BIT_APP_UPCHG);
-
-	if (do_reset) {
+	if (adapter->dcb_set_bitmap & BIT_APP_UPCHG) {
 		while (test_and_set_bit(__IXGBE_RESETTING, &adapter->state))
 			msleep(1);
 
-		if (adapter->dcb_set_bitmap & BIT_APP_UPCHG) {
-			if (netif_running(netdev))
-				netdev->netdev_ops->ndo_stop(netdev);
-			ixgbe_clear_interrupt_scheme(adapter);
-		} else {
-			if (netif_running(netdev))
-				ixgbe_down(adapter);
-		}
+		if (netif_running(netdev))
+			netdev->netdev_ops->ndo_stop(netdev);
+		ixgbe_clear_interrupt_scheme(adapter);
 	}
 
 	if (adapter->dcb_cfg.pfc_mode_enable) {
@@ -403,15 +395,10 @@ static u8 ixgbe_dcbnl_set_all(struct net_device *netdev)
 		}
 	}
 
-	if (do_reset) {
-		if (adapter->dcb_set_bitmap & BIT_APP_UPCHG) {
-			ixgbe_init_interrupt_scheme(adapter);
-			if (netif_running(netdev))
-				netdev->netdev_ops->ndo_open(netdev);
-		} else {
-			if (netif_running(netdev))
-				ixgbe_up(adapter);
-		}
+	if (adapter->dcb_set_bitmap & BIT_APP_UPCHG) {
+		ixgbe_init_interrupt_scheme(adapter);
+		if (netif_running(netdev))
+			netdev->netdev_ops->ndo_open(netdev);
 		ret = DCB_HW_CHG_RST;
 	}
 
@@ -456,7 +443,7 @@ static u8 ixgbe_dcbnl_set_all(struct net_device *netdev)
 	if (adapter->dcb_cfg.pfc_mode_enable)
 		adapter->hw.fc.current_mode = ixgbe_fc_pfc;
 
-	if (do_reset)
+	if (adapter->dcb_set_bitmap & BIT_APP_UPCHG)
 		clear_bit(__IXGBE_RESETTING, &adapter->state);
 	adapter->dcb_set_bitmap = 0x00;
 	return ret;
-- 
1.7.4


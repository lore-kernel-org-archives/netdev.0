From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/6] ixgbe: DCBnl set_all, order of operations fix
Date: Sat,  3 Dec 2011 03:44:29 -0800
Message-ID: <1322912671-6903-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1322912671-6903-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:2643 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754743Ab1LCLoh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Dec 2011 06:44:37 -0500
In-Reply-To: <1322912671-6903-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

The order of operations is important in DCBnl set_all(). When FCoE
is configured it uses the up2tc map to learn which queues to configure
the hardware offloads on. Therefore we need to setup the map before
configuring FCoE.

This is only seen when the both up2tc mappings and APP info are
configured simultaneously.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c |   77 +++++++++--------------
 1 files changed, 29 insertions(+), 48 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
index 33b93ff..8c056c0 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
@@ -309,6 +309,27 @@ static void ixgbe_dcbnl_get_pfc_cfg(struct net_device *netdev, int priority,
 	*setting = adapter->dcb_cfg.tc_config[priority].dcb_pfc;
 }
 
+#ifdef IXGBE_FCOE
+static void ixgbe_dcbnl_devreset(struct net_device *dev)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(dev);
+
+	while (test_and_set_bit(__IXGBE_RESETTING, &adapter->state))
+		usleep_range(1000, 2000);
+
+	if (netif_running(dev))
+		dev->netdev_ops->ndo_stop(dev);
+
+	ixgbe_clear_interrupt_scheme(adapter);
+	ixgbe_init_interrupt_scheme(adapter);
+
+	if (netif_running(dev))
+		dev->netdev_ops->ndo_open(dev);
+
+	clear_bit(__IXGBE_RESETTING, &adapter->state);
+}
+#endif
+
 static u8 ixgbe_dcbnl_set_all(struct net_device *netdev)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
@@ -338,27 +359,6 @@ static u8 ixgbe_dcbnl_set_all(struct net_device *netdev)
 	if (ret)
 		return DCB_NO_HW_CHG;
 
-#ifdef IXGBE_FCOE
-	if (up && !(up & (1 << adapter->fcoe.up)))
-		adapter->dcb_set_bitmap |= BIT_APP_UPCHG;
-
-	/*
-	 * Only take down the adapter if an app change occurred. FCoE
-	 * may shuffle tx rings in this case and this can not be done
-	 * without a reset currently.
-	 */
-	if (adapter->dcb_set_bitmap & BIT_APP_UPCHG) {
-		while (test_and_set_bit(__IXGBE_RESETTING, &adapter->state))
-			usleep_range(1000, 2000);
-
-		adapter->fcoe.up = ffs(up) - 1;
-
-		if (netif_running(netdev))
-			netdev->netdev_ops->ndo_stop(netdev);
-		ixgbe_clear_interrupt_scheme(adapter);
-	}
-#endif
-
 	if (adapter->dcb_cfg.pfc_mode_enable) {
 		switch (adapter->hw.mac.type) {
 		case ixgbe_mac_82599EB:
@@ -385,15 +385,6 @@ static u8 ixgbe_dcbnl_set_all(struct net_device *netdev)
 		}
 	}
 
-#ifdef IXGBE_FCOE
-	if (adapter->dcb_set_bitmap & BIT_APP_UPCHG) {
-		ixgbe_init_interrupt_scheme(adapter);
-		if (netif_running(netdev))
-			netdev->netdev_ops->ndo_open(netdev);
-		ret = DCB_HW_CHG_RST;
-	}
-#endif
-
 	if (adapter->dcb_set_bitmap & (BIT_PG_TX|BIT_PG_RX)) {
 		u16 refill[MAX_TRAFFIC_CLASS], max[MAX_TRAFFIC_CLASS];
 		u8 bwg_id[MAX_TRAFFIC_CLASS], prio_type[MAX_TRAFFIC_CLASS];
@@ -442,8 +433,14 @@ static u8 ixgbe_dcbnl_set_all(struct net_device *netdev)
 	if (adapter->dcb_cfg.pfc_mode_enable)
 		adapter->hw.fc.current_mode = ixgbe_fc_pfc;
 
-	if (adapter->dcb_set_bitmap & BIT_APP_UPCHG)
-		clear_bit(__IXGBE_RESETTING, &adapter->state);
+#ifdef IXGBE_FCOE
+	if (up && !(up & (1 << adapter->fcoe.up))) {
+		adapter->fcoe.up = ffs(up) - 1;
+		ixgbe_dcbnl_devreset(netdev);
+		ret = DCB_HW_CHG_RST;
+	}
+#endif
+
 	adapter->dcb_set_bitmap = 0x00;
 	return ret;
 }
@@ -661,22 +658,6 @@ static int ixgbe_dcbnl_ieee_setpfc(struct net_device *dev,
 	return ixgbe_dcb_hw_pfc_config(&adapter->hw, pfc->pfc_en, prio_tc);
 }
 
-#ifdef IXGBE_FCOE
-static void ixgbe_dcbnl_devreset(struct net_device *dev)
-{
-	struct ixgbe_adapter *adapter = netdev_priv(dev);
-
-	if (netif_running(dev))
-		dev->netdev_ops->ndo_stop(dev);
-
-	ixgbe_clear_interrupt_scheme(adapter);
-	ixgbe_init_interrupt_scheme(adapter);
-
-	if (netif_running(dev))
-		dev->netdev_ops->ndo_open(dev);
-}
-#endif
-
 static int ixgbe_dcbnl_ieee_setapp(struct net_device *dev,
 				   struct dcb_app *app)
 {
-- 
1.7.6.4

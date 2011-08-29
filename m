From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/10] ixgbe: consolidate, setup for multiple traffic classes
Date: Mon, 29 Aug 2011 01:41:03 -0700
Message-ID: <1314607268-26958-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1314607268-26958-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:35897 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753334Ab1H2IlP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Aug 2011 04:41:15 -0400
In-Reply-To: <1314607268-26958-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

This consolidates setup code for multiple traffic classes in
the setup_tc routine.

Prep work to allow IEEE DCBX to optimize for number of traffic
classes. Also simplifies code paths.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c |   46 ++---------------------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   |   30 +++++++++++---
 2 files changed, 27 insertions(+), 49 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
index da6d53e..0422e35 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
@@ -118,49 +118,11 @@ static u8 ixgbe_dcbnl_set_state(struct net_device *netdev, u8 state)
 	if (!!state != !(adapter->flags & IXGBE_FLAG_DCB_ENABLED))
 		return err;
 
-	if (state > 0) {
-		/* Turn on DCB */
-		if (!(adapter->flags & IXGBE_FLAG_MSIX_ENABLED)) {
-			e_err(drv, "Enable failed, needs MSI-X\n");
-			err = 1;
-			goto out;
-		}
-
-		adapter->flags |= IXGBE_FLAG_DCB_ENABLED;
-
-		switch (adapter->hw.mac.type) {
-		case ixgbe_mac_82598EB:
-			adapter->last_lfc_mode = adapter->hw.fc.current_mode;
-			adapter->hw.fc.requested_mode = ixgbe_fc_none;
-			break;
-		case ixgbe_mac_82599EB:
-		case ixgbe_mac_X540:
-			adapter->flags &= ~IXGBE_FLAG_FDIR_HASH_CAPABLE;
-			break;
-		default:
-			break;
-		}
-
-		ixgbe_setup_tc(netdev, MAX_TRAFFIC_CLASS);
-	} else {
-		/* Turn off DCB */
-		adapter->hw.fc.requested_mode = adapter->last_lfc_mode;
-		adapter->temp_dcb_cfg.pfc_mode_enable = false;
-		adapter->dcb_cfg.pfc_mode_enable = false;
-		adapter->flags &= ~IXGBE_FLAG_DCB_ENABLED;
-		switch (adapter->hw.mac.type) {
-		case ixgbe_mac_82599EB:
-		case ixgbe_mac_X540:
-			if (!(adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE))
-				adapter->flags |= IXGBE_FLAG_FDIR_HASH_CAPABLE;
-			break;
-		default:
-			break;
-		}
-		ixgbe_setup_tc(netdev, 0);
-	}
+	if (state > 0)
+		err = ixgbe_setup_tc(netdev, MAX_TRAFFIC_CLASS);
+	else
+		err = ixgbe_setup_tc(netdev, 0);
 
-out:
 	return err;
 }
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 2b1bb60..3932cd0 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7065,11 +7065,11 @@ int ixgbe_setup_tc(struct net_device *dev, u8 tc)
 	struct ixgbe_adapter *adapter = netdev_priv(dev);
 	struct ixgbe_hw *hw = &adapter->hw;
 
-	/* If DCB is anabled do not remove traffic classes, multiple
-	 * traffic classes are required to implement DCB
-	 */
-	if (!tc && (adapter->flags & IXGBE_FLAG_DCB_ENABLED))
-		return 0;
+	/* Multiple traffic classes requires multiple queues */
+	if (!(adapter->flags & IXGBE_FLAG_MSIX_ENABLED)) {
+		e_err(drv, "Enable failed, needs MSI-X\n");
+		return -EINVAL;
+	}
 
 	/* Hardware supports up to 8 traffic classes */
 	if (tc > MAX_TRAFFIC_CLASS ||
@@ -7084,11 +7084,27 @@ int ixgbe_setup_tc(struct net_device *dev, u8 tc)
 		ixgbe_close(dev);
 	ixgbe_clear_interrupt_scheme(adapter);
 
-	if (tc)
+	if (tc) {
 		netdev_set_num_tc(dev, tc);
-	else
+		adapter->last_lfc_mode = adapter->hw.fc.current_mode;
+
+		adapter->flags |= IXGBE_FLAG_DCB_ENABLED;
+		adapter->flags &= ~IXGBE_FLAG_FDIR_HASH_CAPABLE;
+
+		if (adapter->hw.mac.type == ixgbe_mac_82598EB)
+			adapter->hw.fc.requested_mode = ixgbe_fc_none;
+	} else {
 		netdev_reset_tc(dev);
 
+		adapter->hw.fc.requested_mode = adapter->last_lfc_mode;
+
+		adapter->flags &= ~IXGBE_FLAG_DCB_ENABLED;
+		adapter->flags |= IXGBE_FLAG_FDIR_HASH_CAPABLE;
+
+		adapter->temp_dcb_cfg.pfc_mode_enable = false;
+		adapter->dcb_cfg.pfc_mode_enable = false;
+	}
+
 	ixgbe_init_interrupt_scheme(adapter);
 	ixgbe_validate_rtr(adapter, tc);
 	if (netif_running(dev))
-- 
1.7.6

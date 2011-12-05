From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 5/6] ixgbe: DCB: IEEE transitions may fail to reprogram hardware.
Date: Mon,  5 Dec 2011 00:20:40 -0800
Message-ID: <1323073241-21144-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1323073241-21144-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:55396 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753716Ab1LEIUt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Dec 2011 03:20:49 -0500
In-Reply-To: <1323073241-21144-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

Transitioning through an IEEE DCBX version from a CEE DCBX
and back (CEE->IEEE->CEE) may leave IEEE attributes programmed
in the hardware. DCB uses a bit field in the set routines to
determine which attributes PG, PFC, APP need to be reprogrammed.
This is needed because user flow allows queueing a series
of changes and then reprogramming the hardware with the
entire set in one operation.

When transitioning from IEEE DCBX mode back into CEE DCBX
mode the PG and PFC bits need to be set so the possibly

different CEE attributes get programmed into the device.

This patch fixes broken logic that was evaluating to 0
and never setting any bits. Further this removes some
checks for num_tc in set routines. This logic only worked
when the number of traffic classes and user priorities
were equal. This is no longer the case for X540 devices.
Besides we can trust user input in this case if the
device is incorrectly configured the DCB bandwidths will
be incorrectly mapped but no OOPs, BUG, or hardware
failure will occur.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c |   21 ++++++++++-----------
 1 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
index 8c056c0..da31735 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
@@ -158,10 +158,6 @@ static void ixgbe_dcbnl_set_pg_tc_cfg_tx(struct net_device *netdev, int tc,
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 
-	/* Abort a bad configuration */
-	if (ffs(up_map) > adapter->dcb_cfg.num_tcs.pg_tcs)
-		return;
-
 	if (prio != DCB_ATTR_VALUE_UNDEFINED)
 		adapter->temp_dcb_cfg.tc_config[tc].path[0].prio_type = prio;
 	if (bwg_id != DCB_ATTR_VALUE_UNDEFINED)
@@ -185,7 +181,7 @@ static void ixgbe_dcbnl_set_pg_tc_cfg_tx(struct net_device *netdev, int tc,
 
 	if (adapter->temp_dcb_cfg.tc_config[tc].path[0].up_to_tc_bitmap !=
 	     adapter->dcb_cfg.tc_config[tc].path[0].up_to_tc_bitmap)
-		adapter->dcb_set_bitmap |= BIT_PFC;
+		adapter->dcb_set_bitmap |= BIT_PFC | BIT_APP_UPCHG;
 }
 
 static void ixgbe_dcbnl_set_pg_bwg_cfg_tx(struct net_device *netdev, int bwg_id,
@@ -206,10 +202,6 @@ static void ixgbe_dcbnl_set_pg_tc_cfg_rx(struct net_device *netdev, int tc,
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 
-	/* Abort bad configurations */
-	if (ffs(up_map) > adapter->dcb_cfg.num_tcs.pg_tcs)
-		return;
-
 	if (prio != DCB_ATTR_VALUE_UNDEFINED)
 		adapter->temp_dcb_cfg.tc_config[tc].path[1].prio_type = prio;
 	if (bwg_id != DCB_ATTR_VALUE_UNDEFINED)
@@ -434,7 +426,12 @@ static u8 ixgbe_dcbnl_set_all(struct net_device *netdev)
 		adapter->hw.fc.current_mode = ixgbe_fc_pfc;
 
 #ifdef IXGBE_FCOE
-	if (up && !(up & (1 << adapter->fcoe.up))) {
+	/* Reprogam FCoE hardware offloads when the traffic class
+	 * FCoE is using changes. This happens if the APP info
+	 * changes or the up2tc mapping is updated.
+	 */
+	if ((up && !(up & (1 << adapter->fcoe.up))) ||
+	    (adapter->dcb_set_bitmap & BIT_APP_UPCHG)) {
 		adapter->fcoe.up = ffs(up) - 1;
 		ixgbe_dcbnl_devreset(netdev);
 		ret = DCB_HW_CHG_RST;
@@ -742,7 +739,9 @@ static u8 ixgbe_dcbnl_setdcbx(struct net_device *dev, u8 mode)
 		ixgbe_dcbnl_ieee_setets(dev, &ets);
 		ixgbe_dcbnl_ieee_setpfc(dev, &pfc);
 	} else if (mode & DCB_CAP_DCBX_VER_CEE) {
-		adapter->dcb_set_bitmap |= (BIT_PFC & BIT_PG_TX & BIT_PG_RX);
+		u8 mask = BIT_PFC | BIT_PG_TX | BIT_PG_RX | BIT_APP_UPCHG;
+
+		adapter->dcb_set_bitmap |= mask;
 		ixgbe_dcbnl_set_all(dev);
 	} else {
 		/* Drop into single TC mode strict priority as this
-- 
1.7.6.4

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 06/16] ixgbe: DCB, only reprogram HW if the FCoE priority is changed
Date: Tue,  8 Feb 2011 04:29:17 -0800
Message-ID: <1297168167-15755-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1297168167-15755-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:30096 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753935Ab1BHM3f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Feb 2011 07:29:35 -0500
In-Reply-To: <1297168167-15755-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

If the FCoE priority is not changing do not set the RESET and
APP_UPCHG bits. This causes unneeded HW resets and which can
cause unneeded LLDP frames and negotiations.

The current check is not sufficient because the FCoE priority
can change twice during a negotiation which results in the
bits being set. This occurs when the switch changes the
priority or when the link is reset with switches that do not
include the APP priority until after PFC has been negotiated.

This results in set_app being called with the local APP
priority. Then the negotiation completes and set_app
is called again with the peer APP priority. The check
fails so the device is reset and the above occurs again
resulting in an endless loop of resets.

By only resetting the device if the APP priority has really
changed we short circuit the loop.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_dcb_nl.c |   38 ++++++++++++++++++++++++++------------
 1 files changed, 26 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ixgbe/ixgbe_dcb_nl.c
index bf566e8..4805835 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_nl.c
@@ -353,6 +353,7 @@ static void ixgbe_dcbnl_get_pfc_cfg(struct net_device *netdev, int priority,
 static u8 ixgbe_dcbnl_set_all(struct net_device *netdev)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	bool do_reset;
 	int ret;
 
 	if (!adapter->dcb_set_bitmap)
@@ -368,7 +369,9 @@ static u8 ixgbe_dcbnl_set_all(struct net_device *netdev)
 	 * Only take down the adapter if the configuration change
 	 * requires a reset.
 	 */
-	if (adapter->dcb_set_bitmap & BIT_RESETLINK) {
+	do_reset = adapter->dcb_set_bitmap & (BIT_RESETLINK | BIT_APP_UPCHG);
+
+	if (do_reset) {
 		while (test_and_set_bit(__IXGBE_RESETTING, &adapter->state))
 			msleep(1);
 
@@ -408,7 +411,7 @@ static u8 ixgbe_dcbnl_set_all(struct net_device *netdev)
 		}
 	}
 
-	if (adapter->dcb_set_bitmap & BIT_RESETLINK) {
+	if (do_reset) {
 		if (adapter->dcb_set_bitmap & BIT_APP_UPCHG) {
 			ixgbe_init_interrupt_scheme(adapter);
 			if (netif_running(netdev))
@@ -430,7 +433,7 @@ static u8 ixgbe_dcbnl_set_all(struct net_device *netdev)
 	if (adapter->dcb_cfg.pfc_mode_enable)
 		adapter->hw.fc.current_mode = ixgbe_fc_pfc;
 
-	if (adapter->dcb_set_bitmap & BIT_RESETLINK)
+	if (do_reset)
 		clear_bit(__IXGBE_RESETTING, &adapter->state);
 	adapter->dcb_set_bitmap = 0x00;
 	return ret;
@@ -568,18 +571,29 @@ static u8 ixgbe_dcbnl_setapp(struct net_device *netdev,
 	case DCB_APP_IDTYPE_ETHTYPE:
 #ifdef IXGBE_FCOE
 		if (id == ETH_P_FCOE) {
-			u8 tc;
-			struct ixgbe_adapter *adapter;
+			u8 old_tc;
+			struct ixgbe_adapter *adapter = netdev_priv(netdev);
 
-			adapter = netdev_priv(netdev);
-			tc = adapter->fcoe.tc;
+			/* Get current programmed tc */
+			old_tc = adapter->fcoe.tc;
 			rval = ixgbe_fcoe_setapp(adapter, up);
-			if ((!rval) && (tc != adapter->fcoe.tc) &&
-			    (adapter->flags & IXGBE_FLAG_DCB_ENABLED) &&
-			    (adapter->flags & IXGBE_FLAG_FCOE_ENABLED)) {
+
+			if (rval ||
+			   !(adapter->flags & IXGBE_FLAG_DCB_ENABLED) ||
+			   !(adapter->flags & IXGBE_FLAG_FCOE_ENABLED))
+				break;
+
+			/* The FCoE application priority may be changed multiple
+			 * times in quick sucession with switches that build up
+			 * TLVs. To avoid creating uneeded device resets this
+			 * checks the actual HW configuration and clears
+			 * BIT_APP_UPCHG if a HW configuration change is not
+			 * need
+			 */
+			if (old_tc == adapter->fcoe.tc)
+				adapter->dcb_set_bitmap &= ~BIT_APP_UPCHG;
+			else
 				adapter->dcb_set_bitmap |= BIT_APP_UPCHG;
-				adapter->dcb_set_bitmap |= BIT_RESETLINK;
-			}
 		}
 #endif
 		break;
-- 
1.7.4


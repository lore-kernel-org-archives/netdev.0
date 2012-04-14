From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 2/2] ixgbe: fix WoL issue with fiber
Date: Sat, 14 Apr 2012 01:51:18 -0700
Message-ID: <1334393478-31885-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1334393478-31885-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:49685 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750956Ab2DNIvX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Apr 2012 04:51:23 -0400
In-Reply-To: <1334393478-31885-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

There are times we turn of the laser before shutdown.  This is a bad thing
if we want to wake on lan to work so now we make sure the laser is on
before shutdown if we support WoL.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 3e26b1f..dac7c01 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -4893,6 +4893,16 @@ static int __ixgbe_shutdown(struct pci_dev *pdev, bool *enable_wake)
 	if (wufc) {
 		ixgbe_set_rx_mode(netdev);
 
+		/*
+		 * enable the optics for both mult-speed fiber and
+		 * 82599 SFP+ fiber as we can WoL.
+		 */
+		if (hw->mac.ops.enable_tx_laser &&
+		    (hw->phy.multispeed_fiber ||
+		    (hw->mac.ops.get_media_type(hw) == ixgbe_media_type_fiber &&
+		     hw->mac.type == ixgbe_mac_82599EB)))
+			hw->mac.ops.enable_tx_laser(hw);
+
 		/* turn on all-multi mode if wake on multicast is enabled */
 		if (wufc & IXGBE_WUFC_MC) {
 			fctrl = IXGBE_READ_REG(hw, IXGBE_FCTRL);
-- 
1.7.7.6

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 1/4] ixgbe: fix issues with failing to detect insert
	of unsupported module
Date: Thu, 02 Jul 2009 15:50:12 -0700
Message-ID: <20090702225012.22746.57218.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta10.emeryville.ca.mail.comcast.net ([76.96.30.17]:59779 "EHLO
	QMTA10.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752214AbZGBWu1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2009 18:50:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

Several small fixes around negative test case of the insertion of a
IXGBE_ERR_NOT_SUPPORTED module.

- mdio45_probe call was always failing due to mdio.prtad not being
set.  The function set to mdio.mdio_read was still working as we just
happen to always be at prtad == 0.  This will allow us to set the phy_id
and phy.type correctly now.

- There was timing issue with i2c calls when initiated from a tasklet.
A small delay was added to allow the electrical oscillation to calm down.

- Logic change in ixgbe_sfp_task that allows NOT_SUPPORTED condition
to be recognized.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    8 ++++++--
 drivers/net/ixgbe/ixgbe_phy.c  |    3 +++
 2 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 5588ef4..aaf482c 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3724,7 +3724,7 @@ static void ixgbe_sfp_task(struct work_struct *work)
 	if ((hw->phy.type == ixgbe_phy_nl) &&
 	    (hw->phy.sfp_type == ixgbe_sfp_type_not_present)) {
 		s32 ret = hw->phy.ops.identify_sfp(hw);
-		if (ret)
+		if (ret == IXGBE_ERR_SFP_NOT_PRESENT)
 			goto reschedule;
 		ret = hw->phy.ops.reset(hw);
 		if (ret == IXGBE_ERR_SFP_NOT_SUPPORTED) {
@@ -4534,13 +4534,17 @@ static void ixgbe_sfp_config_module_task(struct work_struct *work)
 	u32 err;
 
 	adapter->flags |= IXGBE_FLAG_IN_SFP_MOD_TASK;
+
+	/* Time for electrical oscillations to settle down */
+	msleep(100);
 	err = hw->phy.ops.identify_sfp(hw);
+
 	if (err == IXGBE_ERR_SFP_NOT_SUPPORTED) {
 		dev_err(&adapter->pdev->dev, "failed to initialize because "
 			"an unsupported SFP+ module type was detected.\n"
 			"Reload the driver after installing a supported "
 			"module.\n");
-		ixgbe_down(adapter);
+		unregister_netdev(adapter->netdev);
 		return;
 	}
 	hw->mac.ops.setup_sfp(hw);
diff --git a/drivers/net/ixgbe/ixgbe_phy.c b/drivers/net/ixgbe/ixgbe_phy.c
index 453e966..9ecad17 100644
--- a/drivers/net/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ixgbe/ixgbe_phy.c
@@ -60,6 +60,7 @@ s32 ixgbe_identify_phy_generic(struct ixgbe_hw *hw)
 
 	if (hw->phy.type == ixgbe_phy_unknown) {
 		for (phy_addr = 0; phy_addr < IXGBE_MAX_PHY_ADDR; phy_addr++) {
+			hw->phy.mdio.prtad = phy_addr;
 			if (mdio45_probe(&hw->phy.mdio, phy_addr) == 0) {
 				ixgbe_get_phy_id(hw);
 				hw->phy.type =
@@ -68,6 +69,8 @@ s32 ixgbe_identify_phy_generic(struct ixgbe_hw *hw)
 				break;
 			}
 		}
+		/* clear value if nothing found */
+		hw->phy.mdio.prtad = 0;
 	} else {
 		status = 0;
 	}


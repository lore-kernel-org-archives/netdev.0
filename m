From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 11/15] ixgbe: Wait for master disable to be set
Date: Thu,  3 Dec 2015 03:07:19 -0800
Message-ID: <1449140843-118580-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449140843-118580-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:27448 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759883AbbLCLHc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2015 06:07:32 -0500
In-Reply-To: <1449140843-118580-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

According to the datasheets, the driver should wait for the master
disable bit to read as being set before checking the status
register for master disable.

Reported-by: Dan Streetman <dan.streetman@canonical.com>
Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Darin Miller <darin.j.miller@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c | 14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
index ce61b36..daec6ae 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2014 Intel Corporation.
+  Copyright(c) 1999 - 2015 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -2454,6 +2454,17 @@ static s32 ixgbe_disable_pcie_master(struct ixgbe_hw *hw)
 	/* Always set this bit to ensure any future transactions are blocked */
 	IXGBE_WRITE_REG(hw, IXGBE_CTRL, IXGBE_CTRL_GIO_DIS);
 
+	/* Poll for bit to read as set */
+	for (i = 0; i < IXGBE_PCI_MASTER_DISABLE_TIMEOUT; i++) {
+		if (IXGBE_READ_REG(hw, IXGBE_CTRL) & IXGBE_CTRL_GIO_DIS)
+			break;
+		usleep_range(100, 120);
+	}
+	if (i >= IXGBE_PCI_MASTER_DISABLE_TIMEOUT) {
+		hw_dbg(hw, "GIO disable did not set - requesting resets\n");
+		goto gio_disable_fail;
+	}
+
 	/* Exit if master requests are blocked */
 	if (!(IXGBE_READ_REG(hw, IXGBE_STATUS) & IXGBE_STATUS_GIO) ||
 	    ixgbe_removed(hw->hw_addr))
@@ -2475,6 +2486,7 @@ static s32 ixgbe_disable_pcie_master(struct ixgbe_hw *hw)
 	 * again to clear out any effects they may have had on our device.
 	 */
 	hw_dbg(hw, "GIO Master Disable bit didn't clear - requesting resets\n");
+gio_disable_fail:
 	hw->mac.flags |= IXGBE_FLAGS_DOUBLE_RESET_REQUIRED;
 
 	if (hw->mac.type >= ixgbe_mac_X550)
-- 
2.5.0

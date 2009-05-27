From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 1/4] ixgbe: fix 82598 SFP initialization after
	driver load.
Date: Tue, 26 May 2009 17:54:04 -0700
Message-ID: <20090527005403.28535.8727.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Don Skidmore <donald.c.skidmore@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta10.westchester.pa.mail.comcast.net ([76.96.62.17]:47613
	"EHLO QMTA10.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751153AbZE0AyV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2009 20:54:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

If we loaded the driver with out a SFP module plugged in it would
leave it in a state that make it later unable to link when a module
was plugged in.  This patch corrects that by:

ixgbe_probe() - moving the check for IXGBE_ERR_SFP_NOT_PRESENT from
after get_invariants() to after reset_hw() as now reset_hw() is
where this condition will be indentified.

ixgbe_reset_hw_82598() - Enable this function to now return
IXGBE_ERR_SFP_NOT_PRESENT.

ixgbe_identify_sfp_module_generic() - This where the lack of SFP
module is detected.  Modifications are added to allow a different
return value for modules that just haven't been plugged in yet.

Other functions were updated to allow correct logging.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_82598.c |   12 ++++++++++--
 drivers/net/ixgbe/ixgbe_main.c  |   33 +++++++++++++++++----------------
 drivers/net/ixgbe/ixgbe_phy.c   |   13 ++++++++++++-
 3 files changed, 39 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82598.c b/drivers/net/ixgbe/ixgbe_82598.c
index afc9fe3..88e8350 100644
--- a/drivers/net/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ixgbe/ixgbe_82598.c
@@ -698,6 +698,7 @@ static s32 ixgbe_setup_copper_link_speed_82598(struct ixgbe_hw *hw,
 static s32 ixgbe_reset_hw_82598(struct ixgbe_hw *hw)
 {
 	s32 status = 0;
+	s32 phy_status = 0;
 	u32 ctrl;
 	u32 gheccr;
 	u32 i;
@@ -745,13 +746,17 @@ static s32 ixgbe_reset_hw_82598(struct ixgbe_hw *hw)
 		/* PHY ops must be identified and initialized prior to reset */
 
 		/* Init PHY and function pointers, perform SFP setup */
-		status = hw->phy.ops.init(hw);
-		if (status == IXGBE_ERR_SFP_NOT_SUPPORTED)
+		phy_status = hw->phy.ops.init(hw);
+		if (phy_status == IXGBE_ERR_SFP_NOT_SUPPORTED)
 			goto reset_hw_out;
+		else if (phy_status == IXGBE_ERR_SFP_NOT_PRESENT)
+			goto no_phy_reset;
+
 
 		hw->phy.ops.reset(hw);
 	}
 
+no_phy_reset:
 	/*
 	 * Prevent the PCI-E bus from from hanging by disabling PCI-E master
 	 * access and verify no pending requests before reset
@@ -811,6 +816,9 @@ static s32 ixgbe_reset_hw_82598(struct ixgbe_hw *hw)
 	hw->mac.ops.get_mac_addr(hw, hw->mac.perm_addr);
 
 reset_hw_out:
+	if (phy_status)
+		status = phy_status;
+
 	return status;
 }
 
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index e52798c..f9223ac 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2599,7 +2599,10 @@ int ixgbe_up(struct ixgbe_adapter *adapter)
 void ixgbe_reset(struct ixgbe_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
-	if (hw->mac.ops.init_hw(hw))
+	int err;
+
+	err = hw->mac.ops.init_hw(hw);
+	if (err && (err != IXGBE_ERR_SFP_NOT_PRESENT))
 		dev_err(&adapter->pdev->dev, "Hardware Error\n");
 
 	/* reprogram the RAR[0] in case user changed it. */
@@ -5167,20 +5170,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	INIT_WORK(&adapter->sfp_config_module_task,
 	          ixgbe_sfp_config_module_task);
 
-	err = ii->get_invariants(hw);
-	if (err == IXGBE_ERR_SFP_NOT_PRESENT) {
-		/* start a kernel thread to watch for a module to arrive */
-		set_bit(__IXGBE_SFP_MODULE_NOT_FOUND, &adapter->state);
-		mod_timer(&adapter->sfp_timer,
-		          round_jiffies(jiffies + (2 * HZ)));
-		err = 0;
-	} else if (err == IXGBE_ERR_SFP_NOT_SUPPORTED) {
-		DPRINTK(PROBE, ERR, "failed to load because an "
-		        "unsupported SFP+ module type was detected.\n");
-		goto err_hw_init;
-	} else if (err) {
-		goto err_hw_init;
-	}
+	ii->get_invariants(hw);
 
 	/* setup the private structure */
 	err = ixgbe_sw_init(adapter);
@@ -5200,7 +5190,18 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 
 	/* reset_hw fills in the perm_addr as well */
 	err = hw->mac.ops.reset_hw(hw);
-	if (err == IXGBE_ERR_SFP_NOT_SUPPORTED) {
+	if (err == IXGBE_ERR_SFP_NOT_PRESENT &&
+	    hw->mac.type == ixgbe_mac_82598EB) {
+		/*
+		 * Start a kernel thread to watch for a module to arrive.
+		 * Only do this for 82598, since 82599 will generate
+		 * interrupts on module arrival.
+		 */
+		set_bit(__IXGBE_SFP_MODULE_NOT_FOUND, &adapter->state);
+		mod_timer(&adapter->sfp_timer,
+			  round_jiffies(jiffies + (2 * HZ)));
+		err = 0;
+	} else if (err == IXGBE_ERR_SFP_NOT_SUPPORTED) {
 		dev_err(&adapter->pdev->dev, "failed to load because an "
 		        "unsupported SFP+ module type was detected.\n");
 		goto err_sw_init;
diff --git a/drivers/net/ixgbe/ixgbe_phy.c b/drivers/net/ixgbe/ixgbe_phy.c
index 8210b49..e43d624 100644
--- a/drivers/net/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ixgbe/ixgbe_phy.c
@@ -530,11 +530,22 @@ s32 ixgbe_identify_sfp_module_generic(struct ixgbe_hw *hw)
 	u8 cable_tech = 0;
 	u16 enforce_sfp = 0;
 
+	if (hw->mac.ops.get_media_type(hw) != ixgbe_media_type_fiber) {
+		hw->phy.sfp_type = ixgbe_sfp_type_not_present;
+		status = IXGBE_ERR_SFP_NOT_PRESENT;
+		goto out;
+	}
+
 	status = hw->phy.ops.read_i2c_eeprom(hw, IXGBE_SFF_IDENTIFIER,
 	                                     &identifier);
 
-	if (status == IXGBE_ERR_SFP_NOT_PRESENT) {
+	if (status == IXGBE_ERR_SFP_NOT_PRESENT || status == IXGBE_ERR_I2C) {
+		status = IXGBE_ERR_SFP_NOT_PRESENT;
 		hw->phy.sfp_type = ixgbe_sfp_type_not_present;
+		if (hw->phy.type != ixgbe_phy_nl) {
+			hw->phy.id = 0;
+			hw->phy.type = ixgbe_phy_unknown;
+		}
 		goto out;
 	}
 


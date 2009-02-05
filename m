From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 2/3] ixgbe: Update link setup code to better support
	autonegotiation of speed
Date: Wed, 04 Feb 2009 17:39:23 -0800
Message-ID: <20090205013923.29241.30152.stgit@lost.foo-projects.org>
References: <20090205013900.29241.77746.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.emeryville.ca.mail.comcast.net ([76.96.30.64]:59823 "EHLO
	QMTA07.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1762288AbZBEBjn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2009 20:39:43 -0500
In-Reply-To: <20090205013900.29241.77746.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>

The current code has some flaws in it when performing autonegotiation,
especially on KX/KX4 links.  This patch updates the code to better handle
the autonegotiation states on link setup.  The patch also removes a redundant
link configuration call on driver load, and moves link configuration to
the ->open() path.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_82598.c  |  114 +++++++++++++++-----------------------
 drivers/net/ixgbe/ixgbe_common.c |    3 -
 drivers/net/ixgbe/ixgbe_main.c   |    3 -
 drivers/net/ixgbe/ixgbe_type.h   |    9 ++-
 4 files changed, 49 insertions(+), 80 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82598.c b/drivers/net/ixgbe/ixgbe_82598.c
index 8e7315e..f726a14 100644
--- a/drivers/net/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ixgbe/ixgbe_82598.c
@@ -146,18 +146,12 @@ static s32 ixgbe_get_link_capabilities_82598(struct ixgbe_hw *hw,
                                              bool *autoneg)
 {
 	s32 status = 0;
-	s32 autoc_reg;
 
-	autoc_reg = IXGBE_READ_REG(hw, IXGBE_AUTOC);
-
-	if (hw->mac.link_settings_loaded) {
-		autoc_reg &= ~IXGBE_AUTOC_LMS_ATTACH_TYPE;
-		autoc_reg &= ~IXGBE_AUTOC_LMS_MASK;
-		autoc_reg |= hw->mac.link_attach_type;
-		autoc_reg |= hw->mac.link_mode_select;
-	}
-
-	switch (autoc_reg & IXGBE_AUTOC_LMS_MASK) {
+	/*
+	 * Determine link capabilities based on the stored value of AUTOC,
+	 * which represents EEPROM defaults.
+	 */
+	switch (hw->mac.orig_autoc & IXGBE_AUTOC_LMS_MASK) {
 	case IXGBE_AUTOC_LMS_1G_LINK_NO_AN:
 		*speed = IXGBE_LINK_SPEED_1GB_FULL;
 		*autoneg = false;
@@ -176,9 +170,9 @@ static s32 ixgbe_get_link_capabilities_82598(struct ixgbe_hw *hw,
 	case IXGBE_AUTOC_LMS_KX4_AN:
 	case IXGBE_AUTOC_LMS_KX4_AN_1G_AN:
 		*speed = IXGBE_LINK_SPEED_UNKNOWN;
-		if (autoc_reg & IXGBE_AUTOC_KX4_SUPP)
+		if (hw->mac.orig_autoc & IXGBE_AUTOC_KX4_SUPP)
 			*speed |= IXGBE_LINK_SPEED_10GB_FULL;
-		if (autoc_reg & IXGBE_AUTOC_KX_SUPP)
+		if (hw->mac.orig_autoc & IXGBE_AUTOC_KX_SUPP)
 			*speed |= IXGBE_LINK_SPEED_1GB_FULL;
 		*autoneg = true;
 		break;
@@ -390,27 +384,17 @@ static s32 ixgbe_setup_mac_link_82598(struct ixgbe_hw *hw)
 	u32 i;
 	s32 status = 0;
 
-	autoc_reg = IXGBE_READ_REG(hw, IXGBE_AUTOC);
-
-	if (hw->mac.link_settings_loaded) {
-		autoc_reg &= ~IXGBE_AUTOC_LMS_ATTACH_TYPE;
-		autoc_reg &= ~IXGBE_AUTOC_LMS_MASK;
-		autoc_reg |= hw->mac.link_attach_type;
-		autoc_reg |= hw->mac.link_mode_select;
-
-		IXGBE_WRITE_REG(hw, IXGBE_AUTOC, autoc_reg);
-		IXGBE_WRITE_FLUSH(hw);
-		msleep(50);
-	}
-
 	/* Restart link */
+	autoc_reg = IXGBE_READ_REG(hw, IXGBE_AUTOC);
 	autoc_reg |= IXGBE_AUTOC_AN_RESTART;
 	IXGBE_WRITE_REG(hw, IXGBE_AUTOC, autoc_reg);
 
 	/* Only poll for autoneg to complete if specified to do so */
 	if (hw->phy.autoneg_wait_to_complete) {
-		if (hw->mac.link_mode_select == IXGBE_AUTOC_LMS_KX4_AN ||
-		    hw->mac.link_mode_select == IXGBE_AUTOC_LMS_KX4_AN_1G_AN) {
+		if ((autoc_reg & IXGBE_AUTOC_LMS_MASK) ==
+		     IXGBE_AUTOC_LMS_KX4_AN ||
+		    (autoc_reg & IXGBE_AUTOC_LMS_MASK) ==
+		     IXGBE_AUTOC_LMS_KX4_AN_1G_AN) {
 			links_reg = 0; /* Just in case Autoneg time = 0 */
 			for (i = 0; i < IXGBE_AUTO_NEG_TIME; i++) {
 				links_reg = IXGBE_READ_REG(hw, IXGBE_LINKS);
@@ -534,37 +518,43 @@ out:
  *  Set the link speed in the AUTOC register and restarts link.
  **/
 static s32 ixgbe_setup_mac_link_speed_82598(struct ixgbe_hw *hw,
-                                            ixgbe_link_speed speed, bool autoneg,
-                                            bool autoneg_wait_to_complete)
+                                           ixgbe_link_speed speed, bool autoneg,
+                                           bool autoneg_wait_to_complete)
 {
-	s32 status = 0;
+	s32              status            = 0;
+	ixgbe_link_speed link_capabilities = IXGBE_LINK_SPEED_UNKNOWN;
+	u32              curr_autoc        = IXGBE_READ_REG(hw, IXGBE_AUTOC);
+	u32              autoc             = curr_autoc;
+	u32              link_mode         = autoc & IXGBE_AUTOC_LMS_MASK;
 
-	/* If speed is 10G, then check for CX4 or XAUI. */
-	if ((speed == IXGBE_LINK_SPEED_10GB_FULL) &&
-	    (!(hw->mac.link_attach_type & IXGBE_AUTOC_10G_KX4))) {
-		hw->mac.link_mode_select = IXGBE_AUTOC_LMS_10G_LINK_NO_AN;
-	} else if ((speed == IXGBE_LINK_SPEED_1GB_FULL) && (!autoneg)) {
-		hw->mac.link_mode_select = IXGBE_AUTOC_LMS_1G_LINK_NO_AN;
-	} else if (autoneg) {
-		/* BX mode - Autonegotiate 1G */
-		if (!(hw->mac.link_attach_type & IXGBE_AUTOC_1G_PMA_PMD))
-			hw->mac.link_mode_select = IXGBE_AUTOC_LMS_1G_AN;
-		else /* KX/KX4 mode */
-			hw->mac.link_mode_select = IXGBE_AUTOC_LMS_KX4_AN_1G_AN;
-	} else {
+	/* Check to see if speed passed in is supported. */
+	ixgbe_get_link_capabilities_82598(hw, &link_capabilities, &autoneg);
+	speed &= link_capabilities;
+
+	if (speed == IXGBE_LINK_SPEED_UNKNOWN)
 		status = IXGBE_ERR_LINK_SETUP;
+
+	/* Set KX4/KX support according to speed requested */
+	else if (link_mode == IXGBE_AUTOC_LMS_KX4_AN ||
+	         link_mode == IXGBE_AUTOC_LMS_KX4_AN_1G_AN) {
+		autoc &= ~IXGBE_AUTOC_KX4_KX_SUPP_MASK;
+		if (speed & IXGBE_LINK_SPEED_10GB_FULL)
+			autoc |= IXGBE_AUTOC_KX4_SUPP;
+		if (speed & IXGBE_LINK_SPEED_1GB_FULL)
+			autoc |= IXGBE_AUTOC_KX_SUPP;
+		if (autoc != curr_autoc)
+			IXGBE_WRITE_REG(hw, IXGBE_AUTOC, autoc);
 	}
 
 	if (status == 0) {
 		hw->phy.autoneg_wait_to_complete = autoneg_wait_to_complete;
 
-		hw->mac.link_settings_loaded = true;
 		/*
 		 * Setup and restart the link based on the new values in
 		 * ixgbe_hw This will write the AUTOC register based on the new
 		 * stored values
 		 */
-		ixgbe_setup_mac_link_82598(hw);
+		status = ixgbe_setup_mac_link_82598(hw);
 	}
 
 	return status;
@@ -587,10 +577,6 @@ static s32 ixgbe_setup_copper_link_82598(struct ixgbe_hw *hw)
 	/* Restart autonegotiation on PHY */
 	status = hw->phy.ops.setup_link(hw);
 
-	/* Set MAC to KX/KX4 autoneg, which defaults to Parallel detection */
-	hw->mac.link_attach_type = (IXGBE_AUTOC_10G_KX4 | IXGBE_AUTOC_1G_KX);
-	hw->mac.link_mode_select = IXGBE_AUTOC_LMS_KX4_AN;
-
 	/* Set up MAC */
 	ixgbe_setup_mac_link_82598(hw);
 
@@ -617,10 +603,6 @@ static s32 ixgbe_setup_copper_link_speed_82598(struct ixgbe_hw *hw,
 	status = hw->phy.ops.setup_link_speed(hw, speed, autoneg,
 	                                      autoneg_wait_to_complete);
 
-	/* Set MAC to KX/KX4 autoneg, which defaults to Parallel detection */
-	hw->mac.link_attach_type = (IXGBE_AUTOC_10G_KX4 | IXGBE_AUTOC_1G_KX);
-	hw->mac.link_mode_select = IXGBE_AUTOC_LMS_KX4_AN;
-
 	/* Set up MAC */
 	ixgbe_setup_mac_link_82598(hw);
 
@@ -720,24 +702,16 @@ static s32 ixgbe_reset_hw_82598(struct ixgbe_hw *hw)
 	IXGBE_WRITE_REG(hw, IXGBE_GHECCR, gheccr);
 
 	/*
-	 * AUTOC register which stores link settings gets cleared
-	 * and reloaded from EEPROM after reset. We need to restore
-	 * our stored value from init in case SW changed the attach
-	 * type or speed.  If this is the first time and link settings
-	 * have not been stored, store default settings from AUTOC.
+	 * Store the original AUTOC value if it has not been
+	 * stored off yet.  Otherwise restore the stored original
+	 * AUTOC value since the reset operation sets back to deaults.
 	 */
 	autoc = IXGBE_READ_REG(hw, IXGBE_AUTOC);
-	if (hw->mac.link_settings_loaded) {
-		autoc &= ~(IXGBE_AUTOC_LMS_ATTACH_TYPE);
-		autoc &= ~(IXGBE_AUTOC_LMS_MASK);
-		autoc |= hw->mac.link_attach_type;
-		autoc |= hw->mac.link_mode_select;
-		IXGBE_WRITE_REG(hw, IXGBE_AUTOC, autoc);
-	} else {
-		hw->mac.link_attach_type =
-		                         (autoc & IXGBE_AUTOC_LMS_ATTACH_TYPE);
-		hw->mac.link_mode_select = (autoc & IXGBE_AUTOC_LMS_MASK);
-		hw->mac.link_settings_loaded = true;
+	if (hw->mac.orig_link_settings_stored == false) {
+		hw->mac.orig_autoc = autoc;
+		hw->mac.orig_link_settings_stored = true;
+	} else if (autoc != hw->mac.orig_autoc) {
+		IXGBE_WRITE_REG(hw, IXGBE_AUTOC, hw->mac.orig_autoc);
 	}
 
 	/* Store the permanent mac address */
diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index 05f0e87..13ad5ba 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -80,9 +80,6 @@ s32 ixgbe_start_hw_generic(struct ixgbe_hw *hw)
 	/* Clear the VLAN filter table */
 	hw->mac.ops.clear_vfta(hw);
 
-	/* Set up link */
-	hw->mac.ops.setup_link(hw);
-
 	/* Clear statistics registers */
 	hw->mac.ops.clear_hw_cntrs(hw);
 
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index d396c6e..5db82b5 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2799,9 +2799,6 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 	hw->fc.pause_time = IXGBE_DEFAULT_FCPAUSE;
 	hw->fc.send_xon = true;
 
-	/* select 10G link by default */
-	hw->mac.link_mode_select = IXGBE_AUTOC_LMS_10G_LINK_NO_AN;
-
 	/* enable itr by default in dynamic mode */
 	adapter->itr_setting = 1;
 	adapter->eitr_param = 20000;
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index c49ba8a..984b4ed 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -721,6 +721,7 @@
 #define IXGBE_LED_OFF           0xF
 
 /* AUTOC Bit Masks */
+#define IXGBE_AUTOC_KX4_KX_SUPP_MASK 0xC0000000
 #define IXGBE_AUTOC_KX4_SUPP    0x80000000
 #define IXGBE_AUTOC_KX_SUPP     0x40000000
 #define IXGBE_AUTOC_PAUSE       0x30000000
@@ -1456,11 +1457,11 @@ struct ixgbe_mac_info {
 	u32                             max_tx_queues;
 	u32                             max_rx_queues;
 	u32                             max_msix_vectors;
-	u32                             link_attach_type;
-	u32                             link_mode_select;
-	bool                            link_settings_loaded;
+	u32                             orig_autoc;
+	u32                             orig_autoc2;
+	bool                            orig_link_settings_stored;
 	bool                            autoneg;
-	bool                            autoneg_failed;
+	bool                            autoneg_succeeded;
 };
 
 struct ixgbe_phy_info {


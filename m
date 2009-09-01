From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 1/3] ixgbe: refactor link setup code
Date: Tue, 01 Sep 2009 16:49:35 -0700
Message-ID: <20090901234916.4617.73579.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta15.emeryville.ca.mail.comcast.net ([76.96.27.228]:58430
	"EHLO QMTA15.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752713AbZIAXtw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 19:49:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>

Link code cleanup: a number of redundant functions and MAC variables are cleaned up,
with some functions being consolidated into a single-purpose code path.
Removed following deprecated link functions and mac variables
 * ixgbe_setup_copper_link_speed_82598
 * ixgbe_setup_mac_link_speed_multispeed_fiber
 * ixgbe_setup_mac_link_speed_82599
 * mac.autoneg, mac.autoneg_succeeded, phy.autoneg_wait_to_complete

Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_82598.c   |   49 +++----------
 drivers/net/ixgbe/ixgbe_82599.c   |  135 ++++++++++++-------------------------
 drivers/net/ixgbe/ixgbe_ethtool.c |    4 +
 drivers/net/ixgbe/ixgbe_main.c    |   17 ++---
 drivers/net/ixgbe/ixgbe_type.h    |    7 --
 5 files changed, 67 insertions(+), 145 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82598.c b/drivers/net/ixgbe/ixgbe_82598.c
index 916430f..cb7f0c3 100644
--- a/drivers/net/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ixgbe/ixgbe_82598.c
@@ -41,8 +41,7 @@
 static s32 ixgbe_get_copper_link_capabilities_82598(struct ixgbe_hw *hw,
                                              ixgbe_link_speed *speed,
                                              bool *autoneg);
-static s32 ixgbe_setup_copper_link_82598(struct ixgbe_hw *hw);
-static s32 ixgbe_setup_copper_link_speed_82598(struct ixgbe_hw *hw,
+static s32 ixgbe_setup_copper_link_82598(struct ixgbe_hw *hw,
                                                ixgbe_link_speed speed,
                                                bool autoneg,
                                                bool autoneg_wait_to_complete);
@@ -156,8 +155,6 @@ static s32 ixgbe_init_phy_ops_82598(struct ixgbe_hw *hw)
 	/* Overwrite the link function pointers if copper PHY */
 	if (mac->ops.get_media_type(hw) == ixgbe_media_type_copper) {
 		mac->ops.setup_link = &ixgbe_setup_copper_link_82598;
-		mac->ops.setup_link_speed =
-		                     &ixgbe_setup_copper_link_speed_82598;
 		mac->ops.get_link_capabilities =
 		                  &ixgbe_get_copper_link_capabilities_82598;
 	}
@@ -465,13 +462,14 @@ out:
 }
 
 /**
- *  ixgbe_setup_mac_link_82598 - Configures MAC link settings
+ *  ixgbe_start_mac_link_82598 - Configures MAC link settings
  *  @hw: pointer to hardware structure
  *
  *  Configures link settings based on values in the ixgbe_hw struct.
  *  Restarts the link.  Performs autonegotiation if needed.
  **/
-static s32 ixgbe_setup_mac_link_82598(struct ixgbe_hw *hw)
+static s32 ixgbe_start_mac_link_82598(struct ixgbe_hw *hw,
+                                      bool autoneg_wait_to_complete)
 {
 	u32 autoc_reg;
 	u32 links_reg;
@@ -484,7 +482,7 @@ static s32 ixgbe_setup_mac_link_82598(struct ixgbe_hw *hw)
 	IXGBE_WRITE_REG(hw, IXGBE_AUTOC, autoc_reg);
 
 	/* Only poll for autoneg to complete if specified to do so */
-	if (hw->phy.autoneg_wait_to_complete) {
+	if (autoneg_wait_to_complete) {
 		if ((autoc_reg & IXGBE_AUTOC_LMS_MASK) ==
 		     IXGBE_AUTOC_LMS_KX4_AN ||
 		    (autoc_reg & IXGBE_AUTOC_LMS_MASK) ==
@@ -600,7 +598,7 @@ out:
 
 
 /**
- *  ixgbe_setup_mac_link_speed_82598 - Set MAC link speed
+ *  ixgbe_setup_mac_link_82598 - Set MAC link speed
  *  @hw: pointer to hardware structure
  *  @speed: new link speed
  *  @autoneg: true if auto-negotiation enabled
@@ -608,7 +606,7 @@ out:
  *
  *  Set the link speed in the AUTOC register and restarts link.
  **/
-static s32 ixgbe_setup_mac_link_speed_82598(struct ixgbe_hw *hw,
+static s32 ixgbe_setup_mac_link_82598(struct ixgbe_hw *hw,
                                            ixgbe_link_speed speed, bool autoneg,
                                            bool autoneg_wait_to_complete)
 {
@@ -638,14 +636,12 @@ static s32 ixgbe_setup_mac_link_speed_82598(struct ixgbe_hw *hw,
 	}
 
 	if (status == 0) {
-		hw->phy.autoneg_wait_to_complete = autoneg_wait_to_complete;
-
 		/*
 		 * Setup and restart the link based on the new values in
 		 * ixgbe_hw This will write the AUTOC register based on the new
 		 * stored values
 		 */
-		status = ixgbe_setup_mac_link_82598(hw);
+		status = ixgbe_start_mac_link_82598(hw, autoneg_wait_to_complete);
 	}
 
 	return status;
@@ -653,29 +649,7 @@ static s32 ixgbe_setup_mac_link_speed_82598(struct ixgbe_hw *hw,
 
 
 /**
- *  ixgbe_setup_copper_link_82598 - Setup copper link settings
- *  @hw: pointer to hardware structure
- *
- *  Configures link settings based on values in the ixgbe_hw struct.
- *  Restarts the link.  Performs autonegotiation if needed.  Restart
- *  phy and wait for autonegotiate to finish.  Then synchronize the
- *  MAC and PHY.
- **/
-static s32 ixgbe_setup_copper_link_82598(struct ixgbe_hw *hw)
-{
-	s32 status;
-
-	/* Restart autonegotiation on PHY */
-	status = hw->phy.ops.setup_link(hw);
-
-	/* Set up MAC */
-	ixgbe_setup_mac_link_82598(hw);
-
-	return status;
-}
-
-/**
- *  ixgbe_setup_copper_link_speed_82598 - Set the PHY autoneg advertised field
+ *  ixgbe_setup_copper_link_82598 - Set the PHY autoneg advertised field
  *  @hw: pointer to hardware structure
  *  @speed: new link speed
  *  @autoneg: true if autonegotiation enabled
@@ -683,7 +657,7 @@ static s32 ixgbe_setup_copper_link_82598(struct ixgbe_hw *hw)
  *
  *  Sets the link speed in the AUTOC register in the MAC and restarts link.
  **/
-static s32 ixgbe_setup_copper_link_speed_82598(struct ixgbe_hw *hw,
+static s32 ixgbe_setup_copper_link_82598(struct ixgbe_hw *hw,
                                                ixgbe_link_speed speed,
                                                bool autoneg,
                                                bool autoneg_wait_to_complete)
@@ -695,7 +669,7 @@ static s32 ixgbe_setup_copper_link_speed_82598(struct ixgbe_hw *hw,
 	                                      autoneg_wait_to_complete);
 
 	/* Set up MAC */
-	ixgbe_setup_mac_link_82598(hw);
+	ixgbe_start_mac_link_82598(hw, autoneg_wait_to_complete);
 
 	return status;
 }
@@ -1163,7 +1137,6 @@ static struct ixgbe_mac_operations mac_ops_82598 = {
 	.read_analog_reg8	= &ixgbe_read_analog_reg8_82598,
 	.write_analog_reg8	= &ixgbe_write_analog_reg8_82598,
 	.setup_link		= &ixgbe_setup_mac_link_82598,
-	.setup_link_speed	= &ixgbe_setup_mac_link_speed_82598,
 	.check_link		= &ixgbe_check_mac_link_82598,
 	.get_link_capabilities	= &ixgbe_get_link_capabilities_82598,
 	.led_on			= &ixgbe_led_on_generic,
diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index 364b6d2..5ee5608 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -38,23 +38,23 @@
 #define IXGBE_82599_MC_TBL_SIZE   128
 #define IXGBE_82599_VFT_TBL_SIZE  128
 
-static s32 ixgbe_setup_mac_link_multispeed_fiber(struct ixgbe_hw *hw);
-static s32 ixgbe_setup_mac_link_speed_multispeed_fiber(struct ixgbe_hw *hw,
-                                     ixgbe_link_speed speed, bool autoneg,
-                                     bool autoneg_wait_to_complete);
-static s32 ixgbe_setup_mac_link_82599(struct ixgbe_hw *hw);
-static s32 ixgbe_setup_mac_link_speed_82599(struct ixgbe_hw *hw,
-                                            ixgbe_link_speed speed,
-                                            bool autoneg,
-                                            bool autoneg_wait_to_complete);
+s32 ixgbe_setup_mac_link_multispeed_fiber(struct ixgbe_hw *hw,
+                                          ixgbe_link_speed speed,
+                                          bool autoneg,
+                                          bool autoneg_wait_to_complete);
+s32 ixgbe_start_mac_link_82599(struct ixgbe_hw *hw,
+                               bool autoneg_wait_to_complete);
+s32 ixgbe_setup_mac_link_82599(struct ixgbe_hw *hw,
+                               ixgbe_link_speed speed,
+                               bool autoneg,
+                               bool autoneg_wait_to_complete);
 static s32 ixgbe_get_copper_link_capabilities_82599(struct ixgbe_hw *hw,
                                              ixgbe_link_speed *speed,
                                              bool *autoneg);
-static s32 ixgbe_setup_copper_link_82599(struct ixgbe_hw *hw);
-static s32 ixgbe_setup_copper_link_speed_82599(struct ixgbe_hw *hw,
-                                               ixgbe_link_speed speed,
-                                               bool autoneg,
-                                               bool autoneg_wait_to_complete);
+static s32 ixgbe_setup_copper_link_82599(struct ixgbe_hw *hw,
+                                         ixgbe_link_speed speed,
+                                         bool autoneg,
+                                         bool autoneg_wait_to_complete);
 static s32 ixgbe_verify_fw_version_82599(struct ixgbe_hw *hw);
 
 static void ixgbe_init_mac_link_ops_82599(struct ixgbe_hw *hw)
@@ -62,15 +62,9 @@ static void ixgbe_init_mac_link_ops_82599(struct ixgbe_hw *hw)
 	struct ixgbe_mac_info *mac = &hw->mac;
 	if (hw->phy.multispeed_fiber) {
 		/* Set up dual speed SFP+ support */
-		mac->ops.setup_link =
-		          &ixgbe_setup_mac_link_multispeed_fiber;
-		mac->ops.setup_link_speed =
-		          &ixgbe_setup_mac_link_speed_multispeed_fiber;
+		mac->ops.setup_link = &ixgbe_setup_mac_link_multispeed_fiber;
 	} else {
-		mac->ops.setup_link =
-		          &ixgbe_setup_mac_link_82599;
-		mac->ops.setup_link_speed =
-		          &ixgbe_setup_mac_link_speed_82599;
+		mac->ops.setup_link = &ixgbe_setup_mac_link_82599;
 	}
 }
 
@@ -178,8 +172,6 @@ static s32 ixgbe_init_phy_ops_82599(struct ixgbe_hw *hw)
 	/* If copper media, overwrite with copper function pointers */
 	if (mac->ops.get_media_type(hw) == ixgbe_media_type_copper) {
 		mac->ops.setup_link = &ixgbe_setup_copper_link_82599;
-		mac->ops.setup_link_speed =
-		                     &ixgbe_setup_copper_link_speed_82599;
 		mac->ops.get_link_capabilities =
 		                  &ixgbe_get_copper_link_capabilities_82599;
 	}
@@ -354,13 +346,15 @@ out:
 }
 
 /**
- *  ixgbe_setup_mac_link_82599 - Setup MAC link settings
+ *  ixgbe_start_mac_link_82599 - Setup MAC link settings
  *  @hw: pointer to hardware structure
+ *  @autoneg_wait_to_complete: true when waiting for completion is needed
  *
  *  Configures link settings based on values in the ixgbe_hw struct.
  *  Restarts the link.  Performs autonegotiation if needed.
  **/
-static s32 ixgbe_setup_mac_link_82599(struct ixgbe_hw *hw)
+s32 ixgbe_start_mac_link_82599(struct ixgbe_hw *hw,
+                               bool autoneg_wait_to_complete)
 {
 	u32 autoc_reg;
 	u32 links_reg;
@@ -373,7 +367,7 @@ static s32 ixgbe_setup_mac_link_82599(struct ixgbe_hw *hw)
 	IXGBE_WRITE_REG(hw, IXGBE_AUTOC, autoc_reg);
 
 	/* Only poll for autoneg to complete if specified to do so */
-	if (hw->phy.autoneg_wait_to_complete) {
+	if (autoneg_wait_to_complete) {
 		if ((autoc_reg & IXGBE_AUTOC_LMS_MASK) ==
 		     IXGBE_AUTOC_LMS_KX4_KX_KR ||
 		    (autoc_reg & IXGBE_AUTOC_LMS_MASK) ==
@@ -401,25 +395,7 @@ static s32 ixgbe_setup_mac_link_82599(struct ixgbe_hw *hw)
 }
 
 /**
- *  ixgbe_setup_mac_link_multispeed_fiber - Setup MAC link settings
- *  @hw: pointer to hardware structure
- *
- *  Configures link settings based on values in the ixgbe_hw struct.
- *  Restarts the link for multi-speed fiber at 1G speed, if link
- *  fails at 10G.
- *  Performs autonegotiation if needed.
- **/
-static s32 ixgbe_setup_mac_link_multispeed_fiber(struct ixgbe_hw *hw)
-{
-	s32 status = 0;
-	ixgbe_link_speed link_speed = IXGBE_LINK_SPEED_82599_AUTONEG;
-	status = ixgbe_setup_mac_link_speed_multispeed_fiber(hw, link_speed,
-	                                                     true, true);
-	return status;
-}
-
-/**
- *  ixgbe_setup_mac_link_speed_multispeed_fiber - Set MAC link speed
+ *  ixgbe_setup_mac_link_multispeed_fiber - Set MAC link speed
  *  @hw: pointer to hardware structure
  *  @speed: new link speed
  *  @autoneg: true if autonegotiation enabled
@@ -427,10 +403,10 @@ static s32 ixgbe_setup_mac_link_multispeed_fiber(struct ixgbe_hw *hw)
  *
  *  Set the link speed in the AUTOC register and restarts link.
  **/
-static s32 ixgbe_setup_mac_link_speed_multispeed_fiber(struct ixgbe_hw *hw,
-                                                ixgbe_link_speed speed,
-                                                bool autoneg,
-                                                bool autoneg_wait_to_complete)
+s32 ixgbe_setup_mac_link_multispeed_fiber(struct ixgbe_hw *hw,
+                                          ixgbe_link_speed speed,
+                                          bool autoneg,
+                                          bool autoneg_wait_to_complete)
 {
 	s32 status = 0;
 	ixgbe_link_speed phy_link_speed;
@@ -485,10 +461,10 @@ static s32 ixgbe_setup_mac_link_speed_multispeed_fiber(struct ixgbe_hw *hw,
 		/* Allow module to change analog characteristics (1G->10G) */
 		msleep(40);
 
-		status = ixgbe_setup_mac_link_speed_82599(hw,
-		                                     IXGBE_LINK_SPEED_10GB_FULL,
-		                                     autoneg,
-		                                     autoneg_wait_to_complete);
+		status = ixgbe_setup_mac_link_82599(hw,
+		                               IXGBE_LINK_SPEED_10GB_FULL,
+		                               autoneg,
+		                               autoneg_wait_to_complete);
 		if (status != 0)
 			goto out;
 
@@ -539,7 +515,7 @@ static s32 ixgbe_setup_mac_link_speed_multispeed_fiber(struct ixgbe_hw *hw,
 		/* Allow module to change analog characteristics (10G->1G) */
 		msleep(40);
 
-		status = ixgbe_setup_mac_link_speed_82599(hw,
+		status = ixgbe_setup_mac_link_82599(hw,
 		                                      IXGBE_LINK_SPEED_1GB_FULL,
 		                                      autoneg,
 		                                      autoneg_wait_to_complete);
@@ -576,10 +552,10 @@ static s32 ixgbe_setup_mac_link_speed_multispeed_fiber(struct ixgbe_hw *hw,
 	 * single highest speed that the user requested.
 	 */
 	if (speedcnt > 1)
-		status = ixgbe_setup_mac_link_speed_multispeed_fiber(hw,
-		                                     highest_link_speed,
-		                                     autoneg,
-		                                     autoneg_wait_to_complete);
+		status = ixgbe_setup_mac_link_multispeed_fiber(hw,
+		                                               highest_link_speed,
+		                                               autoneg,
+		                                               autoneg_wait_to_complete);
 
 out:
 	return status;
@@ -640,7 +616,7 @@ static s32 ixgbe_check_mac_link_82599(struct ixgbe_hw *hw,
 }
 
 /**
- *  ixgbe_setup_mac_link_speed_82599 - Set MAC link speed
+ *  ixgbe_setup_mac_link_82599 - Set MAC link speed
  *  @hw: pointer to hardware structure
  *  @speed: new link speed
  *  @autoneg: true if autonegotiation enabled
@@ -648,10 +624,9 @@ static s32 ixgbe_check_mac_link_82599(struct ixgbe_hw *hw,
  *
  *  Set the link speed in the AUTOC register and restarts link.
  **/
-static s32 ixgbe_setup_mac_link_speed_82599(struct ixgbe_hw *hw,
-                                            ixgbe_link_speed speed,
-                                            bool autoneg,
-                                            bool autoneg_wait_to_complete)
+s32 ixgbe_setup_mac_link_82599(struct ixgbe_hw *hw,
+                               ixgbe_link_speed speed, bool autoneg,
+                               bool autoneg_wait_to_complete)
 {
 	s32 status = 0;
 	u32 autoc = IXGBE_READ_REG(hw, IXGBE_AUTOC);
@@ -751,26 +726,7 @@ out:
 }
 
 /**
- *  ixgbe_setup_copper_link_82599 - Setup copper link settings
- *  @hw: pointer to hardware structure
- *
- *  Restarts the link on PHY and then MAC. Performs autonegotiation if needed.
- **/
-static s32 ixgbe_setup_copper_link_82599(struct ixgbe_hw *hw)
-{
-	s32 status;
-
-	/* Restart autonegotiation on PHY */
-	status = hw->phy.ops.setup_link(hw);
-
-	/* Set up MAC */
-	ixgbe_setup_mac_link_82599(hw);
-
-	return status;
-}
-
-/**
- *  ixgbe_setup_copper_link_speed_82599 - Set the PHY autoneg advertised field
+ *  ixgbe_setup_copper_link_82599 - Set the PHY autoneg advertised field
  *  @hw: pointer to hardware structure
  *  @speed: new link speed
  *  @autoneg: true if autonegotiation enabled
@@ -778,10 +734,10 @@ static s32 ixgbe_setup_copper_link_82599(struct ixgbe_hw *hw)
  *
  *  Restarts link on PHY and MAC based on settings passed in.
  **/
-static s32 ixgbe_setup_copper_link_speed_82599(struct ixgbe_hw *hw,
-                                               ixgbe_link_speed speed,
-                                               bool autoneg,
-                                               bool autoneg_wait_to_complete)
+static s32 ixgbe_setup_copper_link_82599(struct ixgbe_hw *hw,
+                                         ixgbe_link_speed speed,
+                                         bool autoneg,
+                                         bool autoneg_wait_to_complete)
 {
 	s32 status;
 
@@ -789,7 +745,7 @@ static s32 ixgbe_setup_copper_link_speed_82599(struct ixgbe_hw *hw,
 	status = hw->phy.ops.setup_link_speed(hw, speed, autoneg,
 	                                      autoneg_wait_to_complete);
 	/* Set up MAC */
-	ixgbe_setup_mac_link_82599(hw);
+	ixgbe_start_mac_link_82599(hw, autoneg_wait_to_complete);
 
 	return status;
 }
@@ -2470,7 +2426,6 @@ static struct ixgbe_mac_operations mac_ops_82599 = {
 	.read_analog_reg8       = &ixgbe_read_analog_reg8_82599,
 	.write_analog_reg8      = &ixgbe_write_analog_reg8_82599,
 	.setup_link             = &ixgbe_setup_mac_link_82599,
-	.setup_link_speed       = &ixgbe_setup_mac_link_speed_82599,
 	.check_link             = &ixgbe_check_mac_link_82599,
 	.get_link_capabilities  = &ixgbe_get_link_capabilities_82599,
 	.led_on                 = &ixgbe_led_on_generic,
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 1444ec5..026e94a 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -233,11 +233,11 @@ static int ixgbe_set_settings(struct net_device *netdev,
 			return err;
 		/* this sets the link speed and restarts auto-neg */
 		hw->mac.autotry_restart = true;
-		err = hw->mac.ops.setup_link_speed(hw, advertised, true, true);
+		err = hw->mac.ops.setup_link(hw, advertised, true, true);
 		if (err) {
 			DPRINTK(PROBE, INFO,
 			        "setup link failed with code %d\n", err);
-			hw->mac.ops.setup_link_speed(hw, old, true, true);
+			hw->mac.ops.setup_link(hw, old, true, true);
 		}
 	} else {
 		/* in this case we currently only support 10Gb/FULL */
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index f907836..4042d87 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2516,7 +2516,7 @@ static void ixgbe_sfp_link_config(struct ixgbe_adapter *adapter)
 static int ixgbe_non_sfp_link_config(struct ixgbe_hw *hw)
 {
 	u32 autoneg;
-	bool link_up = false;
+	bool negotiation, link_up = false;
 	u32 ret = IXGBE_ERR_LINK_SETUP;
 
 	if (hw->mac.ops.check_link)
@@ -2526,13 +2526,12 @@ static int ixgbe_non_sfp_link_config(struct ixgbe_hw *hw)
 		goto link_cfg_out;
 
 	if (hw->mac.ops.get_link_capabilities)
-		ret = hw->mac.ops.get_link_capabilities(hw, &autoneg,
-		                                        &hw->mac.autoneg);
+		ret = hw->mac.ops.get_link_capabilities(hw, &autoneg, &negotiation);
 	if (ret)
 		goto link_cfg_out;
 
-	if (hw->mac.ops.setup_link_speed)
-		ret = hw->mac.ops.setup_link_speed(hw, autoneg, true, link_up);
+	if (hw->mac.ops.setup_link)
+		ret = hw->mac.ops.setup_link(hw, autoneg, negotiation, link_up);
 link_cfg_out:
 	return ret;
 }
@@ -4517,14 +4516,14 @@ static void ixgbe_multispeed_fiber_task(struct work_struct *work)
 	                                             multispeed_fiber_task);
 	struct ixgbe_hw *hw = &adapter->hw;
 	u32 autoneg;
+	bool negotiation;
 
 	adapter->flags |= IXGBE_FLAG_IN_SFP_LINK_TASK;
 	autoneg = hw->phy.autoneg_advertised;
 	if ((!autoneg) && (hw->mac.ops.get_link_capabilities))
-		hw->mac.ops.get_link_capabilities(hw, &autoneg,
-		                                  &hw->mac.autoneg);
-	if (hw->mac.ops.setup_link_speed)
-		hw->mac.ops.setup_link_speed(hw, autoneg, true, true);
+		hw->mac.ops.get_link_capabilities(hw, &autoneg, &negotiation);
+	if (hw->mac.ops.setup_link)
+		hw->mac.ops.setup_link(hw, autoneg, negotiation, true);
 	adapter->flags |= IXGBE_FLAG_NEED_LINK_UPDATE;
 	adapter->flags &= ~IXGBE_FLAG_IN_SFP_LINK_TASK;
 }
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index f0f3406..8ba90ee 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -2332,9 +2332,7 @@ struct ixgbe_mac_operations {
 	s32 (*enable_rx_dma)(struct ixgbe_hw *, u32);
 
 	/* Link */
-	s32 (*setup_link)(struct ixgbe_hw *);
-	s32 (*setup_link_speed)(struct ixgbe_hw *, ixgbe_link_speed, bool,
-	                        bool);
+	s32 (*setup_link)(struct ixgbe_hw *, ixgbe_link_speed, bool, bool);
 	s32 (*check_link)(struct ixgbe_hw *, ixgbe_link_speed *, bool *, bool);
 	s32 (*get_link_capabilities)(struct ixgbe_hw *, ixgbe_link_speed *,
 	                             bool *);
@@ -2406,8 +2404,6 @@ struct ixgbe_mac_info {
 	u32                             orig_autoc;
 	u32                             orig_autoc2;
 	bool                            orig_link_settings_stored;
-	bool                            autoneg;
-	bool                            autoneg_succeeded;
 	bool                            autotry_restart;
 };
 
@@ -2422,7 +2418,6 @@ struct ixgbe_phy_info {
 	enum ixgbe_media_type           media_type;
 	bool                            reset_disable;
 	ixgbe_autoneg_advertised        autoneg_advertised;
-	bool                            autoneg_wait_to_complete;
 	bool                            multispeed_fiber;
 };
 


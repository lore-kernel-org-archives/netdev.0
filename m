From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 4/6] ixgbe: Harden the 82599 multispeed fiber autotry
	mechanism
Date: Thu, 04 Jun 2009 14:10:53 -0700
Message-ID: <20090604211052.5011.29962.stgit@localhost.localdomain>
References: <20090604210941.5011.31995.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.emeryville.ca.mail.comcast.net ([76.96.30.80]:33772 "EHLO
	QMTA08.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752523AbZFDVLK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2009 17:11:10 -0400
In-Reply-To: <20090604210941.5011.31995.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>

82599 supports multispeed fiber optical modules (10Gbps/1Gbps).  Some
scenarios can cause the autotry mechanism to not negotiate link properly.
What needs to happen is the driver must flap the Tx laser to induce an Rx
Loss of Signal on the link partner.  This will restart the autotry
mechanism to get link into a known state.  The software definable pin (SDP)
3 on the 0x10fb NIC is wired to cause a Tx LOS event, which triggers the
Rx LOS we require.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Acked-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_82599.c  |  120 +++++++++++++++++++++++++++++++-------
 drivers/net/ixgbe/ixgbe_common.c |    1 
 drivers/net/ixgbe/ixgbe_phy.c    |    1 
 drivers/net/ixgbe/ixgbe_type.h   |    7 ++
 4 files changed, 106 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index a7611bb..84b83f7 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -461,12 +461,23 @@ s32 ixgbe_setup_mac_link_speed_multispeed_fiber(struct ixgbe_hw *hw,
 	u32 esdp_reg = IXGBE_READ_REG(hw, IXGBE_ESDP);
 	bool link_up = false;
 	bool negotiation;
+	int i;
 
 	/* Mask off requested but non-supported speeds */
 	hw->mac.ops.get_link_capabilities(hw, &phy_link_speed, &negotiation);
 	speed &= phy_link_speed;
 
 	/*
+	 * When the driver changes the link speeds that it can support,
+	 * it sets autotry_restart to true to indicate that we need to
+	 * initiate a new autotry session with the link partner.  To do
+	 * so, we set the speed then disable and re-enable the tx laser, to
+	 * alert the link partner that it also needs to restart autotry on its
+	 * end.  This is consistent with true clause 37 autoneg, which also
+	 * involves a loss of signal.
+	 */
+
+	/*
 	 * Try each speed one by one, highest priority first.  We do this in
 	 * software because 10gb fiber doesn't support speed autonegotiation.
 	 */
@@ -474,21 +485,52 @@ s32 ixgbe_setup_mac_link_speed_multispeed_fiber(struct ixgbe_hw *hw,
 		speedcnt++;
 		highest_link_speed = IXGBE_LINK_SPEED_10GB_FULL;
 
-		/* Set hardware SDP's */
+		/* If we already have link at this speed, just jump out */
+		hw->mac.ops.check_link(hw, &phy_link_speed, &link_up, false);
+
+		if ((phy_link_speed == IXGBE_LINK_SPEED_10GB_FULL) && link_up)
+			goto out;
+
+		/* Set the module link speed */
 		esdp_reg |= (IXGBE_ESDP_SDP5_DIR | IXGBE_ESDP_SDP5);
 		IXGBE_WRITE_REG(hw, IXGBE_ESDP, esdp_reg);
 
-		ixgbe_setup_mac_link_speed_82599(hw,
-		                                 IXGBE_LINK_SPEED_10GB_FULL,
-		                                 autoneg,
-		                                 autoneg_wait_to_complete);
-
-		msleep(50);
+		/* Allow module to change analog characteristics (1G->10G) */
+		msleep(40);
 
-		/* If we have link, just jump out */
-		hw->mac.ops.check_link(hw, &phy_link_speed, &link_up, false);
-		if (link_up)
+		status = ixgbe_setup_mac_link_speed_82599(hw,
+		                                     IXGBE_LINK_SPEED_10GB_FULL,
+		                                     autoneg,
+		                                     autoneg_wait_to_complete);
+		if (status != 0)
 			goto out;
+
+		/* Flap the tx laser if it has not already been done */
+		if (hw->mac.autotry_restart) {
+			/* Disable tx laser; allow 100us to go dark per spec */
+			esdp_reg |= IXGBE_ESDP_SDP3;
+			IXGBE_WRITE_REG(hw, IXGBE_ESDP, esdp_reg);
+			udelay(100);
+
+			/* Enable tx laser; allow 2ms to light up per spec */
+			esdp_reg &= ~IXGBE_ESDP_SDP3;
+			IXGBE_WRITE_REG(hw, IXGBE_ESDP, esdp_reg);
+			msleep(2);
+
+			hw->mac.autotry_restart = false;
+		}
+
+		/* The controller may take up to 500ms at 10g to acquire link */
+		for (i = 0; i < 5; i++) {
+			/* Wait for the link partner to also set speed */
+			msleep(100);
+
+			/* If we have link, just jump out */
+			hw->mac.ops.check_link(hw, &phy_link_speed,
+			                       &link_up, false);
+			if (link_up)
+				goto out;
+		}
 	}
 
 	if (speed & IXGBE_LINK_SPEED_1GB_FULL) {
@@ -496,16 +538,44 @@ s32 ixgbe_setup_mac_link_speed_multispeed_fiber(struct ixgbe_hw *hw,
 		if (highest_link_speed == IXGBE_LINK_SPEED_UNKNOWN)
 			highest_link_speed = IXGBE_LINK_SPEED_1GB_FULL;
 
-		/* Set hardware SDP's */
+		/* If we already have link at this speed, just jump out */
+		hw->mac.ops.check_link(hw, &phy_link_speed, &link_up, false);
+
+		if ((phy_link_speed == IXGBE_LINK_SPEED_1GB_FULL) && link_up)
+			goto out;
+
+		/* Set the module link speed */
 		esdp_reg &= ~IXGBE_ESDP_SDP5;
 		esdp_reg |= IXGBE_ESDP_SDP5_DIR;
 		IXGBE_WRITE_REG(hw, IXGBE_ESDP, esdp_reg);
 
-		ixgbe_setup_mac_link_speed_82599(
-			hw, IXGBE_LINK_SPEED_1GB_FULL, autoneg,
-			autoneg_wait_to_complete);
+		/* Allow module to change analog characteristics (10G->1G) */
+		msleep(40);
 
-		msleep(50);
+		status = ixgbe_setup_mac_link_speed_82599(hw,
+		                                      IXGBE_LINK_SPEED_1GB_FULL,
+		                                      autoneg,
+		                                      autoneg_wait_to_complete);
+		if (status != 0)
+			goto out;
+
+		/* Flap the tx laser if it has not already been done */
+		if (hw->mac.autotry_restart) {
+			/* Disable tx laser; allow 100us to go dark per spec */
+			esdp_reg |= IXGBE_ESDP_SDP3;
+			IXGBE_WRITE_REG(hw, IXGBE_ESDP, esdp_reg);
+			udelay(100);
+
+			/* Enable tx laser; allow 2ms to light up per spec */
+			esdp_reg &= ~IXGBE_ESDP_SDP3;
+			IXGBE_WRITE_REG(hw, IXGBE_ESDP, esdp_reg);
+			msleep(2);
+
+			hw->mac.autotry_restart = false;
+		}
+
+		/* Wait for the link partner to also set speed */
+		msleep(100);
 
 		/* If we have link, just jump out */
 		hw->mac.ops.check_link(hw, &phy_link_speed, &link_up, false);
@@ -591,6 +661,7 @@ s32 ixgbe_setup_mac_link_speed_82599(struct ixgbe_hw *hw,
 	s32 status = 0;
 	u32 autoc = IXGBE_READ_REG(hw, IXGBE_AUTOC);
 	u32 autoc2 = IXGBE_READ_REG(hw, IXGBE_AUTOC2);
+	u32 start_autoc = autoc;
 	u32 orig_autoc = 0;
 	u32 link_mode = autoc & IXGBE_AUTOC_LMS_MASK;
 	u32 pma_pmd_1g = autoc & IXGBE_AUTOC_1G_PMA_PMD_MASK;
@@ -603,6 +674,11 @@ s32 ixgbe_setup_mac_link_speed_82599(struct ixgbe_hw *hw,
 	hw->mac.ops.get_link_capabilities(hw, &link_capabilities, &autoneg);
 	speed &= link_capabilities;
 
+	if (speed == IXGBE_LINK_SPEED_UNKNOWN) {
+		status = IXGBE_ERR_LINK_SETUP;
+		goto out;
+	}
+
 	/* Use stored value (EEPROM defaults) of AUTOC to find KR/KX4 support*/
 	if (hw->mac.orig_link_settings_stored)
 		orig_autoc = hw->mac.orig_autoc;
@@ -610,11 +686,9 @@ s32 ixgbe_setup_mac_link_speed_82599(struct ixgbe_hw *hw,
 		orig_autoc = autoc;
 
 
-	if (speed == IXGBE_LINK_SPEED_UNKNOWN) {
-		status = IXGBE_ERR_LINK_SETUP;
-	} else if (link_mode == IXGBE_AUTOC_LMS_KX4_KX_KR ||
-	           link_mode == IXGBE_AUTOC_LMS_KX4_KX_KR_1G_AN ||
-	           link_mode == IXGBE_AUTOC_LMS_KX4_KX_KR_SGMII) {
+	if (link_mode == IXGBE_AUTOC_LMS_KX4_KX_KR ||
+	    link_mode == IXGBE_AUTOC_LMS_KX4_KX_KR_1G_AN ||
+	    link_mode == IXGBE_AUTOC_LMS_KX4_KX_KR_SGMII) {
 		/* Set KX4/KX/KR support according to speed requested */
 		autoc &= ~(IXGBE_AUTOC_KX4_KX_SUPP_MASK | IXGBE_AUTOC_KR_SUPP);
 		if (speed & IXGBE_LINK_SPEED_10GB_FULL)
@@ -646,7 +720,7 @@ s32 ixgbe_setup_mac_link_speed_82599(struct ixgbe_hw *hw,
 		}
 	}
 
-	if (status == 0) {
+	if (autoc != start_autoc) {
 		/* Restart link */
 		autoc |= IXGBE_AUTOC_AN_RESTART;
 		IXGBE_WRITE_REG(hw, IXGBE_AUTOC, autoc);
@@ -680,6 +754,7 @@ s32 ixgbe_setup_mac_link_speed_82599(struct ixgbe_hw *hw,
 		msleep(50);
 	}
 
+out:
 	return status;
 }
 
@@ -1144,6 +1219,9 @@ s32 ixgbe_start_hw_82599(struct ixgbe_hw *hw)
 	}
 	IXGBE_WRITE_FLUSH(hw);
 
+	/* We need to run link autotry after the driver loads */
+	hw->mac.autotry_restart = true;
+
 	return 0;
 }
 
diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index 6f79409..4d36cd3 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -2068,6 +2068,7 @@ s32 ixgbe_blink_led_start_generic(struct ixgbe_hw *hw, u32 index)
 	hw->mac.ops.check_link(hw, &speed, &link_up, false);
 
 	if (!link_up) {
+		autoc_reg |= IXGBE_AUTOC_AN_RESTART;
 		autoc_reg |= IXGBE_AUTOC_FLU;
 		IXGBE_WRITE_REG(hw, IXGBE_AUTOC, autoc_reg);
 		msleep(10);
diff --git a/drivers/net/ixgbe/ixgbe_phy.c b/drivers/net/ixgbe/ixgbe_phy.c
index e43d624..453e966 100644
--- a/drivers/net/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ixgbe/ixgbe_phy.c
@@ -606,6 +606,7 @@ s32 ixgbe_identify_sfp_module_generic(struct ixgbe_hw *hw)
 			hw->phy.sfp_setup_needed = true;
 
 		/* Determine if the SFP+ PHY is dual speed or not. */
+		hw->phy.multispeed_fiber = false;
 		if (((comp_codes_1g & IXGBE_SFF_1GBASESX_CAPABLE) &&
 		   (comp_codes_10g & IXGBE_SFF_10GBASESR_CAPABLE)) ||
 		   ((comp_codes_1g & IXGBE_SFF_1GBASELX_CAPABLE) &&
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index a8a8243..199b288 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -1265,8 +1265,10 @@
 #define IXGBE_STATUS_LAN_ID_1   0x00000004 /* LAN ID 1 */
 
 /* ESDP Bit Masks */
-#define IXGBE_ESDP_SDP0 0x00000001
-#define IXGBE_ESDP_SDP1 0x00000002
+#define IXGBE_ESDP_SDP0 0x00000001 /* SDP0 Data Value */
+#define IXGBE_ESDP_SDP1 0x00000002 /* SDP1 Data Value */
+#define IXGBE_ESDP_SDP2 0x00000004 /* SDP2 Data Value */
+#define IXGBE_ESDP_SDP3 0x00000008 /* SDP3 Data Value */
 #define IXGBE_ESDP_SDP4 0x00000010 /* SDP4 Data Value */
 #define IXGBE_ESDP_SDP5 0x00000020 /* SDP5 Data Value */
 #define IXGBE_ESDP_SDP6 0x00000040 /* SDP6 Data Value */
@@ -2281,6 +2283,7 @@ struct ixgbe_mac_info {
 	bool                            orig_link_settings_stored;
 	bool                            autoneg;
 	bool                            autoneg_succeeded;
+	bool                            autotry_restart;
 };
 
 struct ixgbe_phy_info {


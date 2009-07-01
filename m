From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 2/6] e1000e: delay after LCD reset and proper checks
	for PHY configuration done
Date: Wed, 01 Jul 2009 16:27:55 -0700
Message-ID: <20090701232755.20555.18081.stgit@localhost.localdomain>
References: <20090701232731.20555.63487.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.emeryville.ca.mail.comcast.net ([76.96.30.40]:55513 "EHLO
	QMTA04.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752755AbZGAX2K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jul 2009 19:28:10 -0400
In-Reply-To: <20090701232731.20555.63487.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

A previous workaround for 82578 to avoid link stall causes some PHY
registers to get cleared inadvertently.  Add a delay after all LCD resets
to make sure PHY registers are in a stable state before continuing.  Also,
after resets check the EEC register for the state of PHY configuration
performed by the MAC for ICH9 and earlier parts (as done before), but check
the LAN_INIT_DONE bit in the STATUS register for ICH10 and newer parts (EEC
doesn't exist in these newer parts).


Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/defines.h |    1 
 drivers/net/e1000e/ich8lan.c |  125 +++++++++++++++++++++++++++---------------
 2 files changed, 82 insertions(+), 44 deletions(-)

diff --git a/drivers/net/e1000e/defines.h b/drivers/net/e1000e/defines.h
index 4329ec3..c0f185b 100644
--- a/drivers/net/e1000e/defines.h
+++ b/drivers/net/e1000e/defines.h
@@ -238,6 +238,7 @@
 #define E1000_STATUS_SPEED_100  0x00000040      /* Speed 100Mb/s */
 #define E1000_STATUS_SPEED_1000 0x00000080      /* Speed 1000Mb/s */
 #define E1000_STATUS_LAN_INIT_DONE 0x00000200   /* Lan Init Completion by NVM */
+#define E1000_STATUS_PHYRA      0x00000400      /* PHY Reset Asserted */
 #define E1000_STATUS_GIO_MASTER_ENABLE 0x00080000 /* Status of Master requests. */
 
 /* Constants used to interpret the masked PCI-X bus speed. */
diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index 9e23f50..438778f 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -694,6 +694,38 @@ static s32 e1000_hv_phy_workarounds_ich8lan(struct e1000_hw *hw)
 }
 
 /**
+ *  e1000_lan_init_done_ich8lan - Check for PHY config completion
+ *  @hw: pointer to the HW structure
+ *
+ *  Check the appropriate indication the MAC has finished configuring the
+ *  PHY after a software reset.
+ **/
+static void e1000_lan_init_done_ich8lan(struct e1000_hw *hw)
+{
+	u32 data, loop = E1000_ICH8_LAN_INIT_TIMEOUT;
+
+	/* Wait for basic configuration completes before proceeding */
+	do {
+		data = er32(STATUS);
+		data &= E1000_STATUS_LAN_INIT_DONE;
+		udelay(100);
+	} while ((!data) && --loop);
+
+	/*
+	 * If basic configuration is incomplete before the above loop
+	 * count reaches 0, loading the configuration from NVM will
+	 * leave the PHY in a bad state possibly resulting in no link.
+	 */
+	if (loop == 0)
+		hw_dbg(hw, "LAN_INIT_DONE not set, increase timeout\n");
+
+	/* Clear the Init Done bit for the next init event */
+	data = er32(STATUS);
+	data &= ~E1000_STATUS_LAN_INIT_DONE;
+	ew32(STATUS, data);
+}
+
+/**
  *  e1000_phy_hw_reset_ich8lan - Performs a PHY reset
  *  @hw: pointer to the HW structure
  *
@@ -707,13 +739,15 @@ static s32 e1000_phy_hw_reset_ich8lan(struct e1000_hw *hw)
 	u32 i;
 	u32 data, cnf_size, cnf_base_addr, sw_cfg_mask;
 	s32 ret_val;
-	u16 loop = E1000_ICH8_LAN_INIT_TIMEOUT;
 	u16 word_addr, reg_data, reg_addr, phy_page = 0;
 
 	ret_val = e1000e_phy_hw_reset_generic(hw);
 	if (ret_val)
 		return ret_val;
 
+	/* Allow time for h/w to get to a quiescent state after reset */
+	mdelay(10);
+
 	if (hw->mac.type == e1000_pchlan) {
 		ret_val = e1000_hv_phy_workarounds_ich8lan(hw);
 		if (ret_val)
@@ -741,26 +775,8 @@ static s32 e1000_phy_hw_reset_ich8lan(struct e1000_hw *hw)
 		if (!(data & sw_cfg_mask))
 			return 0;
 
-		/* Wait for basic configuration completes before proceeding*/
-		do {
-			data = er32(STATUS);
-			data &= E1000_STATUS_LAN_INIT_DONE;
-			udelay(100);
-		} while ((!data) && --loop);
-
-		/*
-		 * If basic configuration is incomplete before the above loop
-		 * count reaches 0, loading the configuration from NVM will
-		 * leave the PHY in a bad state possibly resulting in no link.
-		 */
-		if (loop == 0) {
-			hw_dbg(hw, "LAN_INIT_DONE not set, increase timeout\n");
-		}
-
-		/* Clear the Init Done bit for the next init event */
-		data = er32(STATUS);
-		data &= ~E1000_STATUS_LAN_INIT_DONE;
-		ew32(STATUS, data);
+		/* Wait for basic configuration completes before proceeding */
+		e1000_lan_init_done_ich8lan(hw);
 
 		/*
 		 * Make sure HW does not configure LCD from PHY
@@ -2143,6 +2159,12 @@ static s32 e1000_reset_hw_ich8lan(struct e1000_hw *hw)
 	ctrl = er32(CTRL);
 
 	if (!e1000_check_reset_block(hw)) {
+		/* Clear PHY Reset Asserted bit */
+		if (hw->mac.type >= e1000_pchlan) {
+			u32 status = er32(STATUS);
+			ew32(STATUS, status & ~E1000_STATUS_PHYRA);
+		}
+
 		/*
 		 * PHY HW reset requires MAC CORE reset at the same
 		 * time to make sure the interface between MAC and the
@@ -2156,21 +2178,24 @@ static s32 e1000_reset_hw_ich8lan(struct e1000_hw *hw)
 	ew32(CTRL, (ctrl | E1000_CTRL_RST));
 	msleep(20);
 
-	if (!ret_val) {
-		/* release the swflag because it is not reset by
-		 * hardware reset
-		 */
+	if (!ret_val)
 		e1000_release_swflag_ich8lan(hw);
-	}
 
-	ret_val = e1000e_get_auto_rd_done(hw);
-	if (ret_val) {
-		/*
-		 * When auto config read does not complete, do not
-		 * return with an error. This can happen in situations
-		 * where there is no eeprom and prevents getting link.
-		 */
-		hw_dbg(hw, "Auto Read Done did not complete\n");
+	if (ctrl & E1000_CTRL_PHY_RST)
+		ret_val = hw->phy.ops.get_cfg_done(hw);
+
+	if (hw->mac.type >= e1000_ich10lan) {
+		e1000_lan_init_done_ich8lan(hw);
+	} else {
+		ret_val = e1000e_get_auto_rd_done(hw);
+		if (ret_val) {
+			/*
+			 * When auto config read does not complete, do not
+			 * return with an error. This can happen in situations
+			 * where there is no eeprom and prevents getting link.
+			 */
+			hw_dbg(hw, "Auto Read Done did not complete\n");
+		}
 	}
 
 	ew32(IMC, 0xffffffff);
@@ -2222,6 +2247,18 @@ static s32 e1000_init_hw_ich8lan(struct e1000_hw *hw)
 	for (i = 0; i < mac->mta_reg_count; i++)
 		E1000_WRITE_REG_ARRAY(hw, E1000_MTA, i, 0);
 
+	/*
+	 * The 82578 Rx buffer will stall if wakeup is enabled in host and
+	 * the ME.  Reading the BM_WUC register will clear the host wakeup bit.
+	 * Reset the phy after disabling host wakeup to reset the Rx buffer.
+	 */
+	if (hw->phy.type == e1000_phy_82578) {
+		hw->phy.ops.read_phy_reg(hw, BM_WUC, &i);
+		ret_val = e1000_phy_hw_reset_ich8lan(hw);
+		if (ret_val)
+			return ret_val;
+	}
+
 	/* Setup link and flow control */
 	ret_val = e1000_setup_link_ich8lan(hw);
 
@@ -2254,16 +2291,6 @@ static s32 e1000_init_hw_ich8lan(struct e1000_hw *hw)
 	ew32(CTRL_EXT, ctrl_ext);
 
 	/*
-	 * The 82578 Rx buffer will stall if wakeup is enabled in host and
-	 * the ME.  Reading the BM_WUC register will clear the host wakeup bit.
-	 * Reset the phy after disabling host wakeup to reset the Rx buffer.
-	 */
-	if (hw->phy.type == e1000_phy_82578) {
-		e1e_rphy(hw, BM_WUC, &i);
-		e1000e_phy_hw_reset_generic(hw);
-	}
-
-	/*
 	 * Clear all of the statistics registers (clear on read).  It is
 	 * important that we do this after we have tried to establish link
 	 * because the symbol error count will increment wildly if there
@@ -2850,6 +2877,16 @@ static s32 e1000_get_cfg_done_ich8lan(struct e1000_hw *hw)
 {
 	u32 bank = 0;
 
+	if (hw->mac.type >= e1000_pchlan) {
+		u32 status = er32(STATUS);
+
+		if (status & E1000_STATUS_PHYRA)
+			ew32(STATUS, status & ~E1000_STATUS_PHYRA);
+		else
+			hw_dbg(hw,
+			       "PHY Reset Asserted not set - needs delay\n");
+	}
+
 	e1000e_get_cfg_done(hw);
 
 	/* If EEPROM is not marked present, init the IGP 3 PHY manually */


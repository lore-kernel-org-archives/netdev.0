From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 12/15] igb: move the generic copper link setup
	code into e1000_phy.c
Date: Mon, 05 Oct 2009 09:35:03 -0700
Message-ID: <20091005163502.32487.1493.stgit@localhost.localdomain>
References: <20091005163058.32487.10125.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta02.westchester.pa.mail.comcast.net ([76.96.62.24]:40201
	"EHLO QMTA02.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754018AbZJEQhO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 12:37:14 -0400
In-Reply-To: <20091005163058.32487.10125.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch moves the generic portion of the copper link setup into a
seperate function in e1000_phy.c.  This helps to reduce the size of
copper_link_setup_82575 and make it a bit more readable.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_82575.c |   40 +--------------------------
 drivers/net/igb/e1000_phy.c   |   61 ++++++++++++++++++++++++++++++++++++++++-
 drivers/net/igb/e1000_phy.h   |    2 +
 3 files changed, 62 insertions(+), 41 deletions(-)

diff --git a/drivers/net/igb/e1000_82575.c b/drivers/net/igb/e1000_82575.c
index 45063c2..5d345e3 100644
--- a/drivers/net/igb/e1000_82575.c
+++ b/drivers/net/igb/e1000_82575.c
@@ -907,7 +907,6 @@ static s32 igb_setup_copper_link_82575(struct e1000_hw *hw)
 {
 	u32 ctrl;
 	s32  ret_val;
-	bool link;
 
 	ctrl = rd32(E1000_CTRL);
 	ctrl |= E1000_CTRL_SLU;
@@ -940,44 +939,7 @@ static s32 igb_setup_copper_link_82575(struct e1000_hw *hw)
 	if (ret_val)
 		goto out;
 
-	if (hw->mac.autoneg) {
-		/*
-		 * Setup autoneg and flow control advertisement
-		 * and perform autonegotiation.
-		 */
-		ret_val = igb_copper_link_autoneg(hw);
-		if (ret_val)
-			goto out;
-	} else {
-		/*
-		 * PHY will be set to 10H, 10F, 100H or 100F
-		 * depending on user settings.
-		 */
-		hw_dbg("Forcing Speed and Duplex\n");
-		ret_val = hw->phy.ops.force_speed_duplex(hw);
-		if (ret_val) {
-			hw_dbg("Error Forcing Speed and Duplex\n");
-			goto out;
-		}
-	}
-
-	/*
-	 * Check link status. Wait up to 100 microseconds for link to become
-	 * valid.
-	 */
-	ret_val = igb_phy_has_link(hw, COPPER_LINK_UP_LIMIT, 10, &link);
-	if (ret_val)
-		goto out;
-
-	if (link) {
-		hw_dbg("Valid link established!!!\n");
-		/* Config the MAC and PHY after link is up */
-		igb_config_collision_dist(hw);
-		ret_val = igb_config_fc_after_link_up(hw);
-	} else {
-		hw_dbg("Unable to establish link!!!\n");
-	}
-
+	ret_val = igb_setup_copper_link(hw);
 out:
 	return ret_val;
 }
diff --git a/drivers/net/igb/e1000_phy.c b/drivers/net/igb/e1000_phy.c
index d4c928c..b27275d 100644
--- a/drivers/net/igb/e1000_phy.c
+++ b/drivers/net/igb/e1000_phy.c
@@ -669,7 +669,7 @@ out:
  *  and restart the negotiation process between the link partner.  If
  *  autoneg_wait_to_complete, then wait for autoneg to complete before exiting.
  **/
-s32 igb_copper_link_autoneg(struct e1000_hw *hw)
+static s32 igb_copper_link_autoneg(struct e1000_hw *hw)
 {
 	struct e1000_phy_info *phy = &hw->phy;
 	s32 ret_val;
@@ -893,6 +893,65 @@ out:
 }
 
 /**
+ *  igb_setup_copper_link - Configure copper link settings
+ *  @hw: pointer to the HW structure
+ *
+ *  Calls the appropriate function to configure the link for auto-neg or forced
+ *  speed and duplex.  Then we check for link, once link is established calls
+ *  to configure collision distance and flow control are called.  If link is
+ *  not established, we return -E1000_ERR_PHY (-2).
+ **/
+s32 igb_setup_copper_link(struct e1000_hw *hw)
+{
+	s32 ret_val;
+	bool link;
+
+
+	if (hw->mac.autoneg) {
+		/*
+		 * Setup autoneg and flow control advertisement and perform
+		 * autonegotiation.
+		 */
+		ret_val = igb_copper_link_autoneg(hw);
+		if (ret_val)
+			goto out;
+	} else {
+		/*
+		 * PHY will be set to 10H, 10F, 100H or 100F
+		 * depending on user settings.
+		 */
+		hw_dbg("Forcing Speed and Duplex\n");
+		ret_val = hw->phy.ops.force_speed_duplex(hw);
+		if (ret_val) {
+			hw_dbg("Error Forcing Speed and Duplex\n");
+			goto out;
+		}
+	}
+
+	/*
+	 * Check link status. Wait up to 100 microseconds for link to become
+	 * valid.
+	 */
+	ret_val = igb_phy_has_link(hw,
+	                           COPPER_LINK_UP_LIMIT,
+	                           10,
+	                           &link);
+	if (ret_val)
+		goto out;
+
+	if (link) {
+		hw_dbg("Valid link established!!!\n");
+		igb_config_collision_dist(hw);
+		ret_val = igb_config_fc_after_link_up(hw);
+	} else {
+		hw_dbg("Unable to establish link!!!\n");
+	}
+
+out:
+	return ret_val;
+}
+
+/**
  *  igb_phy_force_speed_duplex_igp - Force speed/duplex for igp PHY
  *  @hw: pointer to the HW structure
  *
diff --git a/drivers/net/igb/e1000_phy.h b/drivers/net/igb/e1000_phy.h
index 4c49803..adb9436 100644
--- a/drivers/net/igb/e1000_phy.h
+++ b/drivers/net/igb/e1000_phy.h
@@ -43,7 +43,6 @@ enum e1000_smart_speed {
 
 s32  igb_check_downshift(struct e1000_hw *hw);
 s32  igb_check_reset_block(struct e1000_hw *hw);
-s32  igb_copper_link_autoneg(struct e1000_hw *hw);
 s32  igb_copper_link_setup_igp(struct e1000_hw *hw);
 s32  igb_copper_link_setup_m88(struct e1000_hw *hw);
 s32  igb_phy_force_speed_duplex_igp(struct e1000_hw *hw);
@@ -57,6 +56,7 @@ s32  igb_phy_sw_reset(struct e1000_hw *hw);
 s32  igb_phy_hw_reset(struct e1000_hw *hw);
 s32  igb_read_phy_reg_igp(struct e1000_hw *hw, u32 offset, u16 *data);
 s32  igb_set_d3_lplu_state(struct e1000_hw *hw, bool active);
+s32  igb_setup_copper_link(struct e1000_hw *hw);
 s32  igb_write_phy_reg_igp(struct e1000_hw *hw, u32 offset, u16 data);
 s32  igb_phy_has_link(struct e1000_hw *hw, u32 iterations,
 				u32 usec_interval, bool *success);


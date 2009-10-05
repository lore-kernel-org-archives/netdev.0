From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 14/15] igb: add additional error handling to the
	phy code
Date: Mon, 05 Oct 2009 09:35:42 -0700
Message-ID: <20091005163541.32487.2008.stgit@localhost.localdomain>
References: <20091005163058.32487.10125.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta01.westchester.pa.mail.comcast.net ([76.96.62.16]:36631
	"EHLO QMTA01.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754037AbZJEQhx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 12:37:53 -0400
In-Reply-To: <20091005163058.32487.10125.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This update adds additional exception handling to the phy code to handle
situations where it may be called incorrectly.  In addition it adds some
bounds checking to the cable length checks to prevent an array overrun in
the event that the hardware returned a different value than expected.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_phy.c |   39 +++++++++++++++++++++++++--------------
 1 files changed, 25 insertions(+), 14 deletions(-)

diff --git a/drivers/net/igb/e1000_phy.c b/drivers/net/igb/e1000_phy.c
index 5fe03e1..83b706c 100644
--- a/drivers/net/igb/e1000_phy.c
+++ b/drivers/net/igb/e1000_phy.c
@@ -39,6 +39,9 @@ static s32  igb_wait_autoneg(struct e1000_hw *hw);
 /* Cable length tables */
 static const u16 e1000_m88_cable_length_table[] =
 	{ 0, 50, 80, 110, 140, 140, E1000_CABLE_LENGTH_UNDEFINED };
+#define M88E1000_CABLE_LENGTH_TABLE_SIZE \
+                (sizeof(e1000_m88_cable_length_table) / \
+                 sizeof(e1000_m88_cable_length_table[0]))
 
 static const u16 e1000_igp_2_cable_length_table[] =
     { 0, 0, 0, 0, 0, 0, 0, 0, 3, 5, 8, 11, 13, 16, 18, 21,
@@ -109,7 +112,10 @@ out:
  **/
 static s32 igb_phy_reset_dsp(struct e1000_hw *hw)
 {
-	s32 ret_val;
+	s32 ret_val = 0;
+
+	if (!(hw->phy.ops.write_reg))
+		goto out;
 
 	ret_val = hw->phy.ops.write_reg(hw, M88E1000_PHY_GEN_CONTROL, 0xC1);
 	if (ret_val)
@@ -1059,22 +1065,19 @@ s32 igb_phy_force_speed_duplex_m88(struct e1000_hw *hw)
 
 	igb_phy_force_speed_duplex_setup(hw, &phy_data);
 
-	/* Reset the phy to commit changes. */
-	phy_data |= MII_CR_RESET;
-
 	ret_val = phy->ops.write_reg(hw, PHY_CONTROL, phy_data);
 	if (ret_val)
 		goto out;
 
-	udelay(1);
+	/* Reset the phy to commit changes. */
+	ret_val = igb_phy_sw_reset(hw);
+	if (ret_val)
+		goto out;
 
 	if (phy->autoneg_wait_to_complete) {
 		hw_dbg("Waiting for forced speed/duplex link on M88 phy.\n");
 
-		ret_val = igb_phy_has_link(hw,
-						     PHY_FORCE_LIMIT,
-						     100000,
-						     &link);
+		ret_val = igb_phy_has_link(hw, PHY_FORCE_LIMIT, 100000, &link);
 		if (ret_val)
 			goto out;
 
@@ -1084,8 +1087,8 @@ s32 igb_phy_force_speed_duplex_m88(struct e1000_hw *hw)
 			 * Reset the DSP and cross our fingers.
 			 */
 			ret_val = phy->ops.write_reg(hw,
-						      M88E1000_PHY_PAGE_SELECT,
-						      0x001d);
+						     M88E1000_PHY_PAGE_SELECT,
+						     0x001d);
 			if (ret_val)
 				goto out;
 			ret_val = igb_phy_reset_dsp(hw);
@@ -1095,7 +1098,7 @@ s32 igb_phy_force_speed_duplex_m88(struct e1000_hw *hw)
 
 		/* Try once more */
 		ret_val = igb_phy_has_link(hw, PHY_FORCE_LIMIT,
-					     100000, &link);
+					   100000, &link);
 		if (ret_val)
 			goto out;
 	}
@@ -1207,9 +1210,12 @@ static void igb_phy_force_speed_duplex_setup(struct e1000_hw *hw,
 s32 igb_set_d3_lplu_state(struct e1000_hw *hw, bool active)
 {
 	struct e1000_phy_info *phy = &hw->phy;
-	s32 ret_val;
+	s32 ret_val = 0;
 	u16 data;
 
+	if (!(hw->phy.ops.read_reg))
+		goto out;
+
 	ret_val = phy->ops.read_reg(hw, IGP02E1000_PHY_POWER_MGMT, &data);
 	if (ret_val)
 		goto out;
@@ -1495,8 +1501,13 @@ s32 igb_get_cable_length_m88(struct e1000_hw *hw)
 
 	index = (phy_data & M88E1000_PSSR_CABLE_LENGTH) >>
 		M88E1000_PSSR_CABLE_LENGTH_SHIFT;
+	if (index >= M88E1000_CABLE_LENGTH_TABLE_SIZE - 1) {
+		ret_val = -E1000_ERR_PHY;
+		goto out;
+	}
+
 	phy->min_cable_length = e1000_m88_cable_length_table[index];
-	phy->max_cable_length = e1000_m88_cable_length_table[index+1];
+	phy->max_cable_length = e1000_m88_cable_length_table[index + 1];
 
 	phy->cable_length = (phy->min_cable_length + phy->max_cable_length) / 2;
 


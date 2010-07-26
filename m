From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 1/2] igb: add support for SGMII-based MDIO PHYs
Date: Mon, 26 Jul 2010 16:15:06 -0700
Message-ID: <20100726231456.23941.67606.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Nicholas Nunley <nicholas.d.nunley@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta10.westchester.pa.mail.comcast.net ([76.96.62.17]:44909
	"EHLO qmta10.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751201Ab0GZXP0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jul 2010 19:15:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nick Nunley <nicholas.d.nunley@intel.com>

This patch adds support for external MDIO PHYs, in addition to
the standard SFP support for SGMII PHYs over the I2C interface.

Signed-off-by: Nicholas Nunley <nicholas.d.nunley@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_82575.c   |   82 +++++++++++++++++++++++++++++++--------
 drivers/net/igb/e1000_defines.h |   10 +++++
 2 files changed, 75 insertions(+), 17 deletions(-)

diff --git a/drivers/net/igb/e1000_82575.c b/drivers/net/igb/e1000_82575.c
index 06251a9..2971438 100644
--- a/drivers/net/igb/e1000_82575.c
+++ b/drivers/net/igb/e1000_82575.c
@@ -70,6 +70,35 @@ static const u16 e1000_82580_rxpbs_table[] =
 #define E1000_82580_RXPBS_TABLE_SIZE \
 	(sizeof(e1000_82580_rxpbs_table)/sizeof(u16))
 
+/**
+ *  igb_sgmii_uses_mdio_82575 - Determine if I2C pins are for external MDIO
+ *  @hw: pointer to the HW structure
+ *
+ *  Called to determine if the I2C pins are being used for I2C or as an
+ *  external MDIO interface since the two options are mutually exclusive.
+ **/
+static bool igb_sgmii_uses_mdio_82575(struct e1000_hw *hw)
+{
+	u32 reg = 0;
+	bool ext_mdio = false;
+
+	switch (hw->mac.type) {
+	case e1000_82575:
+	case e1000_82576:
+		reg = rd32(E1000_MDIC);
+		ext_mdio = !!(reg & E1000_MDIC_DEST);
+		break;
+	case e1000_82580:
+	case e1000_i350:
+		reg = rd32(E1000_MDICNFG);
+		ext_mdio = !!(reg & E1000_MDICNFG_EXT_MDIO);
+		break;
+	default:
+		break;
+	}
+	return ext_mdio;
+}
+
 static s32 igb_get_invariants_82575(struct e1000_hw *hw)
 {
 	struct e1000_phy_info *phy = &hw->phy;
@@ -144,13 +173,6 @@ static s32 igb_get_invariants_82575(struct e1000_hw *hw)
 
 	wr32(E1000_CTRL_EXT, ctrl_ext);
 
-	/*
-	 * if using i2c make certain the MDICNFG register is cleared to prevent
-	 * communications from being misrouted to the mdic registers
-	 */
-	if ((ctrl_ext & E1000_CTRL_I2C_ENA) && (hw->mac.type == e1000_82580))
-		wr32(E1000_MDICNFG, 0);
-
 	/* Set mta register count */
 	mac->mta_reg_count = 128;
 	/* Set rar entry count */
@@ -229,18 +251,20 @@ static s32 igb_get_invariants_82575(struct e1000_hw *hw)
 	phy->reset_delay_us      = 100;
 
 	/* PHY function pointers */
-	if (igb_sgmii_active_82575(hw)) {
-		phy->ops.reset              = igb_phy_hw_reset_sgmii_82575;
-		phy->ops.read_reg           = igb_read_phy_reg_sgmii_82575;
-		phy->ops.write_reg          = igb_write_phy_reg_sgmii_82575;
+	if (igb_sgmii_active_82575(hw))
+		phy->ops.reset      = igb_phy_hw_reset_sgmii_82575;
+	else
+		phy->ops.reset      = igb_phy_hw_reset;
+
+	if (igb_sgmii_active_82575(hw) && !igb_sgmii_uses_mdio_82575(hw)) {
+		phy->ops.read_reg   = igb_read_phy_reg_sgmii_82575;
+		phy->ops.write_reg  = igb_write_phy_reg_sgmii_82575;
 	} else if (hw->mac.type >= e1000_82580) {
-		phy->ops.reset              = igb_phy_hw_reset;
-		phy->ops.read_reg           = igb_read_phy_reg_82580;
-		phy->ops.write_reg          = igb_write_phy_reg_82580;
+		phy->ops.read_reg   = igb_read_phy_reg_82580;
+		phy->ops.write_reg  = igb_write_phy_reg_82580;
 	} else {
-		phy->ops.reset              = igb_phy_hw_reset;
-		phy->ops.read_reg           = igb_read_phy_reg_igp;
-		phy->ops.write_reg          = igb_write_phy_reg_igp;
+		phy->ops.read_reg   = igb_read_phy_reg_igp;
+		phy->ops.write_reg  = igb_write_phy_reg_igp;
 	}
 
 	/* set lan id */
@@ -400,6 +424,7 @@ static s32 igb_get_phy_id_82575(struct e1000_hw *hw)
 	s32  ret_val = 0;
 	u16 phy_id;
 	u32 ctrl_ext;
+	u32 mdic;
 
 	/*
 	 * For SGMII PHYs, we try the list of possible addresses until
@@ -414,6 +439,29 @@ static s32 igb_get_phy_id_82575(struct e1000_hw *hw)
 		goto out;
 	}
 
+	if (igb_sgmii_uses_mdio_82575(hw)) {
+		switch (hw->mac.type) {
+		case e1000_82575:
+		case e1000_82576:
+			mdic = rd32(E1000_MDIC);
+			mdic &= E1000_MDIC_PHY_MASK;
+			phy->addr = mdic >> E1000_MDIC_PHY_SHIFT;
+			break;
+		case e1000_82580:
+		case e1000_i350:
+			mdic = rd32(E1000_MDICNFG);
+			mdic &= E1000_MDICNFG_PHY_MASK;
+			phy->addr = mdic >> E1000_MDICNFG_PHY_SHIFT;
+			break;
+		default:
+			ret_val = -E1000_ERR_PHY;
+			goto out;
+			break;
+		}
+		ret_val = igb_get_phy_id(hw);
+		goto out;
+	}
+
 	/* Power on sgmii phy if it is disabled */
 	ctrl_ext = rd32(E1000_CTRL_EXT);
 	wr32(E1000_CTRL_EXT, ctrl_ext & ~E1000_CTRL_EXT_SDP3_DATA);
diff --git a/drivers/net/igb/e1000_defines.h b/drivers/net/igb/e1000_defines.h
index 90bc29d..1d4767f 100644
--- a/drivers/net/igb/e1000_defines.h
+++ b/drivers/net/igb/e1000_defines.h
@@ -468,6 +468,11 @@
 
 #define E1000_TIMINCA_16NS_SHIFT 24
 
+#define E1000_MDICNFG_EXT_MDIO    0x80000000      /* MDI ext/int destination */
+#define E1000_MDICNFG_COM_MDIO    0x40000000      /* MDI shared w/ lan 0 */
+#define E1000_MDICNFG_PHY_MASK    0x03E00000
+#define E1000_MDICNFG_PHY_SHIFT   21
+
 /* PCI Express Control */
 #define E1000_GCR_CMPL_TMOUT_MASK       0x0000F000
 #define E1000_GCR_CMPL_TMOUT_10ms       0x00001000
@@ -698,12 +703,17 @@
 #define M88EC018_EPSCR_DOWNSHIFT_COUNTER_5X    0x0800
 
 /* MDI Control */
+#define E1000_MDIC_DATA_MASK 0x0000FFFF
+#define E1000_MDIC_REG_MASK  0x001F0000
 #define E1000_MDIC_REG_SHIFT 16
+#define E1000_MDIC_PHY_MASK  0x03E00000
 #define E1000_MDIC_PHY_SHIFT 21
 #define E1000_MDIC_OP_WRITE  0x04000000
 #define E1000_MDIC_OP_READ   0x08000000
 #define E1000_MDIC_READY     0x10000000
+#define E1000_MDIC_INT_EN    0x20000000
 #define E1000_MDIC_ERROR     0x40000000
+#define E1000_MDIC_DEST      0x80000000
 
 /* SerDes Control */
 #define E1000_GEN_CTL_READY             0x80000000


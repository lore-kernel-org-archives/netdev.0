From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH] igb: Program MDICNFG register prior to PHY init
Date: Tue, 03 Aug 2010 14:50:08 -0700
Message-ID: <20100803215005.5948.63055.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta06.westchester.pa.mail.comcast.net ([76.96.62.56]:38440
	"EHLO qmta06.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757266Ab0HCVu3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Aug 2010 17:50:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch addresses an issue seen on 82580 in which the MDICNFG
register will be reset during a single function reset and as a
result we will be unable to communicate with the PHY.  To correct
the issue, added a call to reset_mdicnfg just prior to the first
access of the MDICNFG register in sgnii_uses_mdio.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_82575.c |   18 +++++++++++-------
 1 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/drivers/net/igb/e1000_82575.c b/drivers/net/igb/e1000_82575.c
index cc58227..187622f 100644
--- a/drivers/net/igb/e1000_82575.c
+++ b/drivers/net/igb/e1000_82575.c
@@ -63,6 +63,7 @@ static bool igb_sgmii_active_82575(struct e1000_hw *);
 static s32  igb_reset_init_script_82575(struct e1000_hw *);
 static s32  igb_read_mac_addr_82575(struct e1000_hw *);
 static s32  igb_set_pcie_completion_timeout(struct e1000_hw *hw);
+static s32  igb_reset_mdicnfg_82580(struct e1000_hw *hw);
 
 static const u16 e1000_82580_rxpbs_table[] =
 	{ 36, 72, 144, 1, 2, 4, 8, 16,
@@ -159,20 +160,15 @@ static s32 igb_get_invariants_82575(struct e1000_hw *hw)
 	switch (ctrl_ext & E1000_CTRL_EXT_LINK_MODE_MASK) {
 	case E1000_CTRL_EXT_LINK_MODE_SGMII:
 		dev_spec->sgmii_active = true;
-		ctrl_ext |= E1000_CTRL_I2C_ENA;
 		break;
 	case E1000_CTRL_EXT_LINK_MODE_1000BASE_KX:
 	case E1000_CTRL_EXT_LINK_MODE_PCIE_SERDES:
 		hw->phy.media_type = e1000_media_type_internal_serdes;
-		ctrl_ext |= E1000_CTRL_I2C_ENA;
 		break;
 	default:
-		ctrl_ext &= ~E1000_CTRL_I2C_ENA;
 		break;
 	}
 
-	wr32(E1000_CTRL_EXT, ctrl_ext);
-
 	/* Set mta register count */
 	mac->mta_reg_count = 128;
 	/* Set rar entry count */
@@ -250,11 +246,19 @@ static s32 igb_get_invariants_82575(struct e1000_hw *hw)
 	phy->autoneg_mask        = AUTONEG_ADVERTISE_SPEED_DEFAULT;
 	phy->reset_delay_us      = 100;
 
+	ctrl_ext = rd32(E1000_CTRL_EXT);
+
 	/* PHY function pointers */
-	if (igb_sgmii_active_82575(hw))
+	if (igb_sgmii_active_82575(hw)) {
 		phy->ops.reset      = igb_phy_hw_reset_sgmii_82575;
-	else
+		ctrl_ext |= E1000_CTRL_I2C_ENA;
+	} else {
 		phy->ops.reset      = igb_phy_hw_reset;
+		ctrl_ext &= ~E1000_CTRL_I2C_ENA;
+	}
+
+	wr32(E1000_CTRL_EXT, ctrl_ext);
+	igb_reset_mdicnfg_82580(hw);
 
 	if (igb_sgmii_active_82575(hw) && !igb_sgmii_uses_mdio_82575(hw)) {
 		phy->ops.read_reg   = igb_read_phy_reg_sgmii_82575;


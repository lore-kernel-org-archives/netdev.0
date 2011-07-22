From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/10] igb: Fix for DH89xxCC near end loopback test
Date: Thu, 21 Jul 2011 19:01:10 -0700
Message-ID: <1311300078-12876-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1311300078-12876-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Robert Healy <robert.healy@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:44276 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752398Ab1GVCBW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jul 2011 22:01:22 -0400
In-Reply-To: <1311300078-12876-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Healy <robert.healy@intel.com>

On this chipset it is required to configure the MPHY block for loopback tests. If MPHY is not configured then all loopback tests will report failures.

Signed-off-by: Robert Healy <robert.healy@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/igb/e1000_defines.h |   10 ++++++++++
 drivers/net/igb/igb_ethtool.c   |   33 +++++++++++++++++++++++++++++++++
 2 files changed, 43 insertions(+), 0 deletions(-)

diff --git a/drivers/net/igb/e1000_defines.h b/drivers/net/igb/e1000_defines.h
index 2cd4082..7b8ddd8 100644
--- a/drivers/net/igb/e1000_defines.h
+++ b/drivers/net/igb/e1000_defines.h
@@ -512,6 +512,16 @@
 #define E1000_GCR_CMPL_TMOUT_RESEND     0x00010000
 #define E1000_GCR_CAP_VER2              0x00040000
 
+/* mPHY Address Control and Data Registers */
+#define E1000_MPHY_ADDR_CTL          0x0024 /* mPHY Address Control Register */
+#define E1000_MPHY_ADDR_CTL_OFFSET_MASK 0xFFFF0000
+#define E1000_MPHY_DATA                 0x0E10 /* mPHY Data Register */
+
+/* mPHY PCS CLK Register */
+#define E1000_MPHY_PCS_CLK_REG_OFFSET  0x0004 /* mPHY PCS CLK AFE CSR Offset */
+/* mPHY Near End Digital Loopback Override Bit */
+#define E1000_MPHY_PCS_CLK_REG_DIGINELBEN 0x10
+
 /* PHY Control Register */
 #define MII_CR_FULL_DUPLEX      0x0100  /* FDX =1, half duplex =0 */
 #define MII_CR_RESTART_AUTO_NEG 0x0200  /* Restart auto negotiation */
diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index ed63ff4..ff244ce 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -1461,6 +1461,22 @@ static int igb_setup_loopback_test(struct igb_adapter *adapter)
 
 	/* use CTRL_EXT to identify link type as SGMII can appear as copper */
 	if (reg & E1000_CTRL_EXT_LINK_MODE_MASK) {
+		if ((hw->device_id == E1000_DEV_ID_DH89XXCC_SGMII) ||
+		(hw->device_id == E1000_DEV_ID_DH89XXCC_SERDES) ||
+		(hw->device_id == E1000_DEV_ID_DH89XXCC_BACKPLANE) ||
+		(hw->device_id == E1000_DEV_ID_DH89XXCC_SFP)) {
+
+			/* Enable DH89xxCC MPHY for near end loopback */
+			reg = rd32(E1000_MPHY_ADDR_CTL);
+			reg = (reg & E1000_MPHY_ADDR_CTL_OFFSET_MASK) |
+			E1000_MPHY_PCS_CLK_REG_OFFSET;
+			wr32(E1000_MPHY_ADDR_CTL, reg);
+
+			reg = rd32(E1000_MPHY_DATA);
+			reg |= E1000_MPHY_PCS_CLK_REG_DIGINELBEN;
+			wr32(E1000_MPHY_DATA, reg);
+		}
+
 		reg = rd32(E1000_RCTL);
 		reg |= E1000_RCTL_LBM_TCVR;
 		wr32(E1000_RCTL, reg);
@@ -1502,6 +1518,23 @@ static void igb_loopback_cleanup(struct igb_adapter *adapter)
 	u32 rctl;
 	u16 phy_reg;
 
+	if ((hw->device_id == E1000_DEV_ID_DH89XXCC_SGMII) ||
+	(hw->device_id == E1000_DEV_ID_DH89XXCC_SERDES) ||
+	(hw->device_id == E1000_DEV_ID_DH89XXCC_BACKPLANE) ||
+	(hw->device_id == E1000_DEV_ID_DH89XXCC_SFP)) {
+		u32 reg;
+
+		/* Disable near end loopback on DH89xxCC */
+		reg = rd32(E1000_MPHY_ADDR_CTL);
+		reg = (reg & E1000_MPHY_ADDR_CTL_OFFSET_MASK) |
+		E1000_MPHY_PCS_CLK_REG_OFFSET;
+		wr32(E1000_MPHY_ADDR_CTL, reg);
+
+		reg = rd32(E1000_MPHY_DATA);
+		reg &= ~E1000_MPHY_PCS_CLK_REG_DIGINELBEN;
+		wr32(E1000_MPHY_DATA, reg);
+	}
+
 	rctl = rd32(E1000_RCTL);
 	rctl &= ~(E1000_RCTL_LBM_TCVR | E1000_RCTL_LBM_MAC);
 	wr32(E1000_RCTL, rctl);
-- 
1.7.6


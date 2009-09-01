From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 17/18] tg3: Add MDIO bus address assignments
Date: Tue, 1 Sep 2009 16:21:36 -0700
Message-ID: <1251867316.5962@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4125 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932145AbZIBEz0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Sep 2009 00:55:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 5717 is a dual port chip that has a shared MDIO bus design.  While
it is impossible for one function to interface with the wrong phy, that
function still needs to know which MDIO bus address to use when
interfacing with its own phy.  This patch adds code to determine which
MDIO bus address to use.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.c |   23 +++++++++++++++++++----
 drivers/net/tg3.h |    3 +++
 2 files changed, 22 insertions(+), 4 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index bc9c13a..a7eb6a0 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -782,7 +782,7 @@ static int tg3_readphy(struct tg3 *tp, int reg, u32 *val)
 
 	*val = 0x0;
 
-	frame_val  = ((PHY_ADDR << MI_COM_PHY_ADDR_SHIFT) &
+	frame_val  = ((tp->phy_addr << MI_COM_PHY_ADDR_SHIFT) &
 		      MI_COM_PHY_ADDR_MASK);
 	frame_val |= ((reg << MI_COM_REG_ADDR_SHIFT) &
 		      MI_COM_REG_ADDR_MASK);
@@ -833,7 +833,7 @@ static int tg3_writephy(struct tg3 *tp, int reg, u32 val)
 		udelay(80);
 	}
 
-	frame_val  = ((PHY_ADDR << MI_COM_PHY_ADDR_SHIFT) &
+	frame_val  = ((tp->phy_addr << MI_COM_PHY_ADDR_SHIFT) &
 		      MI_COM_PHY_ADDR_MASK);
 	frame_val |= ((reg << MI_COM_REG_ADDR_SHIFT) &
 		      MI_COM_REG_ADDR_MASK);
@@ -1021,6 +1021,21 @@ static void tg3_mdio_start(struct tg3 *tp)
 	tw32_f(MAC_MI_MODE, tp->mi_mode);
 	udelay(80);
 
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717) {
+		u32 funcnum, is_serdes;
+
+		funcnum = tr32(TG3_CPMU_STATUS) & TG3_CPMU_STATUS_PCIE_FUNC;
+		if (funcnum)
+			tp->phy_addr = 2;
+		else
+			tp->phy_addr = 1;
+
+		is_serdes = tr32(SG_DIG_STATUS) & SG_DIG_IS_SERDES;
+		if (is_serdes)
+			tp->phy_addr += 7;
+	} else
+		tp->phy_addr = PHY_ADDR;
+
 	if ((tp->tg3_flags3 & TG3_FLG3_MDIOBUS_INITED) &&
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785)
 		tg3_mdio_config_5785(tp);
@@ -9266,7 +9281,7 @@ static int tg3_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		cmd->speed = tp->link_config.active_speed;
 		cmd->duplex = tp->link_config.active_duplex;
 	}
-	cmd->phy_address = PHY_ADDR;
+	cmd->phy_address = tp->phy_addr;
 	cmd->transceiver = XCVR_INTERNAL;
 	cmd->autoneg = tp->link_config.autoneg;
 	cmd->maxtxpkt = 0;
@@ -10570,7 +10585,7 @@ static int tg3_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 
 	switch(cmd) {
 	case SIOCGMIIPHY:
-		data->phy_id = PHY_ADDR;
+		data->phy_id = tp->phy_addr;
 
 		/* fallthru */
 	case SIOCGMIIREG: {
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index ea57a3a..82b45d8 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -694,6 +694,7 @@
 #define  SG_DIG_PARTNER_FULL_DUPLEX	 0x00020000 /* If !MRADV_CRC16_SELECT */
 #define  SG_DIG_PARTNER_NEXT_PAGE	 0x00010000 /* If !MRADV_CRC16_SELECT */
 #define  SG_DIG_AUTONEG_STATE_MASK	 0x00000ff0
+#define  SG_DIG_IS_SERDES		 0x00000100
 #define  SG_DIG_COMMA_DETECTOR		 0x00000008
 #define  SG_DIG_MAC_ACK_STATUS		 0x00000004
 #define  SG_DIG_AUTONEG_COMPLETE	 0x00000002
@@ -2805,6 +2806,8 @@ struct tg3 {
 	struct mii_bus			*mdio_bus;
 	int				mdio_irq[PHY_MAX_ADDR];
 
+	u8				phy_addr;
+
 	/* PHY info */
 	u32				phy_id;
 #define PHY_ID_MASK			0xfffffff0
-- 
1.6.3.3



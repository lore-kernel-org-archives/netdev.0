From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 4/7] sky2: PHY page register fixes
Date: Thu, 24 May 2007 15:22:46 -0700
Message-ID: <20070524222538.637936263@linux-foundation.org>
References: <20070524222242.555399884@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([207.189.120.13]:37622 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752297AbXEXWa7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2007 18:30:59 -0400
Content-Disposition: inline; filename=sky2-phy-page.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Several of the PHY registers are multiplexed; access to
register must be proceeded by setting page register.

The driver setup is safer if this is done before the access
rather than depending on the last value.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/sky2.c |   25 ++++---------------------
 1 file changed, 4 insertions(+), 21 deletions(-)

--- a/drivers/net/sky2.c	2007-05-22 10:44:32.000000000 -0700
+++ b/drivers/net/sky2.c	2007-05-22 10:44:34.000000000 -0700
@@ -252,6 +252,7 @@ static void sky2_gmac_reset(struct sky2_
 	/* disable all GMAC IRQ's */
 	sky2_write8(hw, SK_REG(port, GMAC_IRQ_MSK), 0);
 	/* disable PHY IRQs */
+	gm_phy_write(hw, port, PHY_MARV_EXT_ADR, 0);
 	gm_phy_write(hw, port, PHY_MARV_INT_MASK, 0);
 
 	gma_write16(hw, port, GM_MC_ADDR_H1, 0);	/* clear MC hash */
@@ -292,7 +293,7 @@ static const u16 gm_fc_disable[] = {
 static void sky2_phy_init(struct sky2_hw *hw, unsigned port)
 {
 	struct sky2_port *sky2 = netdev_priv(hw->dev[port]);
-	u16 ctrl, ct1000, adv, pg, ledctrl, ledover, reg;
+	u16 ctrl, ct1000, adv, ledctrl, ledover, reg;
 
 	if (sky2->autoneg == AUTONEG_ENABLE
 	    && !(hw->chip_id == CHIP_ID_YUKON_XL
@@ -315,6 +316,7 @@ static void sky2_phy_init(struct sky2_hw
 		gm_phy_write(hw, port, PHY_MARV_EXT_CTRL, ectrl);
 	}
 
+	gm_phy_write(hw, port, PHY_MARV_EXT_ADR, 0);
 	ctrl = gm_phy_read(hw, port, PHY_MARV_PHY_CTRL);
 	if (sky2_is_copper(hw)) {
 		if (hw->chip_id == CHIP_ID_YUKON_FE) {
@@ -348,8 +350,6 @@ static void sky2_phy_init(struct sky2_hw
 
 	/* special setup for PHY 88E1112 Fiber */
 	if (hw->chip_id == CHIP_ID_YUKON_XL && !sky2_is_copper(hw)) {
-		pg = gm_phy_read(hw, port, PHY_MARV_EXT_ADR);
-
 		/* Fiber: select 1000BASE-X only mode MAC Specific Ctrl Reg. */
 		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, 2);
 		ctrl = gm_phy_read(hw, port, PHY_MARV_PHY_CTRL);
@@ -367,7 +367,6 @@ static void sky2_phy_init(struct sky2_hw
 			gm_phy_write(hw, port, PHY_MARV_PHY_CTRL, ctrl);
 		}
 
-		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, pg);
 	}
 
 	ctrl = PHY_CT_RESET;
@@ -463,8 +462,6 @@ static void sky2_phy_init(struct sky2_hw
 		break;
 
 	case CHIP_ID_YUKON_XL:
-		pg = gm_phy_read(hw, port, PHY_MARV_EXT_ADR);
-
 		/* select page 3 to access LED control register */
 		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, 3);
 
@@ -483,15 +480,10 @@ static void sky2_phy_init(struct sky2_hw
 			      PHY_M_POLC_INIT_CTRL(2) |
 			      PHY_M_POLC_STA1_CTRL(2) |
 			      PHY_M_POLC_STA0_CTRL(2)));
-
-		/* restore page register */
-		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, pg);
 		break;
 
 	case CHIP_ID_YUKON_EC_U:
 	case CHIP_ID_YUKON_EX:
-		pg = gm_phy_read(hw, port, PHY_MARV_EXT_ADR);
-
 		/* select page 3 to access LED control register */
 		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, 3);
 
@@ -505,8 +497,7 @@ static void sky2_phy_init(struct sky2_hw
 		/* set Blink Rate in LED Timer Control Register */
 		gm_phy_write(hw, port, PHY_MARV_INT_MASK,
 			     ledctrl | PHY_M_LED_BLINK_RT(BLINK_84MS));
-		/* restore page register */
-		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, pg);
+
 		break;
 
 	default:
@@ -529,8 +520,6 @@ static void sky2_phy_init(struct sky2_hw
 		gm_phy_write(hw, port, 0x18, 0xa204);
 		gm_phy_write(hw, port, 0x17, 0x2002);
 
-		/* set page register to 0 */
-		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, 0);
 	} else if (hw->chip_id != CHIP_ID_YUKON_EX) {
 		gm_phy_write(hw, port, PHY_MARV_LED_CTRL, ledctrl);
 
@@ -545,6 +534,7 @@ static void sky2_phy_init(struct sky2_hw
 	}
 
 	/* Enable phy interrupt on auto-negotiation complete (or link up) */
+	gm_phy_write(hw, port, PHY_MARV_EXT_ADR, 0);
 	if (sky2->autoneg == AUTONEG_ENABLE)
 		gm_phy_write(hw, port, PHY_MARV_INT_MASK, PHY_M_IS_AN_COMPL);
 	else
@@ -663,6 +653,7 @@ static void sky2_mac_init(struct sky2_hw
 	sky2_write8(hw, SK_REG(port, GMAC_CTRL), GMC_RST_CLR);
 
 	if (hw->chip_id == CHIP_ID_YUKON_XL && hw->chip_rev == 0 && port == 1) {
+		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, 0);
 		/* WA DEV_472 -- looks like crossed wires on port 2 */
 		/* clear GMAC 1 Control reset */
 		sky2_write8(hw, SK_REG(0, GMAC_CTRL), GMC_RST_CLR);
@@ -1690,6 +1681,7 @@ static void sky2_link_up(struct sky2_por
 	reg |= GM_GPCR_RX_ENA | GM_GPCR_TX_ENA;
 	gma_write16(hw, port, GM_GP_CTRL, reg);
 
+	gm_phy_write(hw, port, PHY_MARV_EXT_ADR, 0);
 	gm_phy_write(hw, port, PHY_MARV_INT_MASK, PHY_M_DEF_MSK);
 
 	netif_carrier_on(sky2->netdev);
@@ -1738,6 +1730,7 @@ static void sky2_link_down(struct sky2_p
 	unsigned port = sky2->port;
 	u16 reg;
 
+	gm_phy_write(hw, port, PHY_MARV_EXT_ADR, 0);
 	gm_phy_write(hw, port, PHY_MARV_INT_MASK, 0);
 
 	reg = gma_read16(hw, port, GM_GP_CTRL);
@@ -1838,6 +1831,7 @@ static void sky2_phy_intr(struct sky2_hw
 		return;
 
 	spin_lock(&sky2->phy_lock);
+	gm_phy_write(hw, port, PHY_MARV_EXT_ADR, 0);
 	istatus = gm_phy_read(hw, port, PHY_MARV_INT_STAT);
 	phystat = gm_phy_read(hw, port, PHY_MARV_PHY_STAT);
 
@@ -3085,11 +3079,9 @@ static void sky2_set_multicast(struct ne
  */
 static void sky2_led(struct sky2_hw *hw, unsigned port, int on)
 {
-	u16 pg;
 
 	switch (hw->chip_id) {
 	case CHIP_ID_YUKON_XL:
-		pg = gm_phy_read(hw, port, PHY_MARV_EXT_ADR);
 		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, 3);
 		gm_phy_write(hw, port, PHY_MARV_PHY_CTRL,
 			     on ? (PHY_M_LEDC_LOS_CTRL(1) |
@@ -3098,7 +3090,6 @@ static void sky2_led(struct sky2_hw *hw,
 				   PHY_M_LEDC_STA0_CTRL(7))
 			     : 0);
 
-		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, pg);
 		break;
 
 	default:
@@ -3127,10 +3118,8 @@ static int sky2_phys_id(struct net_devic
 	/* save initial values */
 	spin_lock_bh(&sky2->phy_lock);
 	if (hw->chip_id == CHIP_ID_YUKON_XL) {
-		u16 pg = gm_phy_read(hw, port, PHY_MARV_EXT_ADR);
 		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, 3);
 		ledctrl = gm_phy_read(hw, port, PHY_MARV_PHY_CTRL);
-		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, pg);
 	} else {
 		ledctrl = gm_phy_read(hw, port, PHY_MARV_LED_CTRL);
 		ledover = gm_phy_read(hw, port, PHY_MARV_LED_OVER);
@@ -3150,10 +3139,8 @@ static int sky2_phys_id(struct net_devic
 
 	/* resume regularly scheduled programming */
 	if (hw->chip_id == CHIP_ID_YUKON_XL) {
-		u16 pg = gm_phy_read(hw, port, PHY_MARV_EXT_ADR);
 		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, 3);
 		gm_phy_write(hw, port, PHY_MARV_PHY_CTRL, ledctrl);
-		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, pg);
 	} else {
 		gm_phy_write(hw, port, PHY_MARV_LED_CTRL, ledctrl);
 		gm_phy_write(hw, port, PHY_MARV_LED_OVER, ledover);

-- 
Stephen Hemminger <shemminger@linux-foundation.org>


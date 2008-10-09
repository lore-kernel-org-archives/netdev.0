From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 8/8 2.6.28] cxgb3 - Add 1G fiber support
Date: Wed, 08 Oct 2008 17:34:35 -0700
Message-ID: <20081009003435.13510.77967.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:19205 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757456AbYJIAem (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 20:34:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>

Add support for 1G optical Vitesse PHY.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/common.h  |    1 
 drivers/net/cxgb3/t3_hw.c   |   23 +++++
 drivers/net/cxgb3/vsc8211.c |  196 ++++++++++++++++++++++++++++++++++++++++---
 3 files changed, 208 insertions(+), 12 deletions(-)

diff --git a/drivers/net/cxgb3/common.h b/drivers/net/cxgb3/common.h
index 416d3dd..593fb64 100644
--- a/drivers/net/cxgb3/common.h
+++ b/drivers/net/cxgb3/common.h
@@ -691,6 +691,7 @@ int t3_mdio_change_bits(struct cphy *phy, int mmd, int reg, unsigned int clear,
 			unsigned int set);
 int t3_phy_reset(struct cphy *phy, int mmd, int wait);
 int t3_phy_advertise(struct cphy *phy, unsigned int advert);
+int t3_phy_advertise_fiber(struct cphy *phy, unsigned int advert);
 int t3_set_phy_speed_duplex(struct cphy *phy, int speed, int duplex);
 int t3_phy_lasi_intr_enable(struct cphy *phy);
 int t3_phy_lasi_intr_disable(struct cphy *phy);
diff --git a/drivers/net/cxgb3/t3_hw.c b/drivers/net/cxgb3/t3_hw.c
index 9d9c0ba..4da5b09 100644
--- a/drivers/net/cxgb3/t3_hw.c
+++ b/drivers/net/cxgb3/t3_hw.c
@@ -408,6 +408,29 @@ int t3_phy_advertise(struct cphy *phy, unsigned int advert)
 }
 
 /**
+ *	t3_phy_advertise_fiber - set fiber PHY advertisement register
+ *	@phy: the PHY to operate on
+ *	@advert: bitmap of capabilities the PHY should advertise
+ *
+ *	Sets a fiber PHY's advertisement register to advertise the
+ *	requested capabilities.
+ */
+int t3_phy_advertise_fiber(struct cphy *phy, unsigned int advert)
+{
+	unsigned int val = 0;
+
+	if (advert & ADVERTISED_1000baseT_Half)
+		val |= ADVERTISE_1000XHALF;
+	if (advert & ADVERTISED_1000baseT_Full)
+		val |= ADVERTISE_1000XFULL;
+	if (advert & ADVERTISED_Pause)
+		val |= ADVERTISE_1000XPAUSE;
+	if (advert & ADVERTISED_Asym_Pause)
+		val |= ADVERTISE_1000XPSE_ASYM;
+	return mdio_write(phy, 0, MII_ADVERTISE, val);
+}
+
+/**
  *	t3_set_phy_speed_duplex - force PHY speed and duplex
  *	@phy: the PHY to operate on
  *	@speed: requested PHY speed
diff --git a/drivers/net/cxgb3/vsc8211.c b/drivers/net/cxgb3/vsc8211.c
index 68e6334..306c2dc 100644
--- a/drivers/net/cxgb3/vsc8211.c
+++ b/drivers/net/cxgb3/vsc8211.c
@@ -33,28 +33,40 @@
 
 /* VSC8211 PHY specific registers. */
 enum {
+	VSC8211_SIGDET_CTRL = 19,
+	VSC8211_EXT_CTRL = 23,
 	VSC8211_INTR_ENABLE = 25,
 	VSC8211_INTR_STATUS = 26,
+	VSC8211_LED_CTRL = 27,
 	VSC8211_AUX_CTRL_STAT = 28,
+	VSC8211_EXT_PAGE_AXS = 31,
 };
 
 enum {
 	VSC_INTR_RX_ERR = 1 << 0,
-	VSC_INTR_MS_ERR = 1 << 1,	/* master/slave resolution error */
-	VSC_INTR_CABLE = 1 << 2,	/* cable impairment */
-	VSC_INTR_FALSE_CARR = 1 << 3,	/* false carrier */
-	VSC_INTR_MEDIA_CHG = 1 << 4,	/* AMS media change */
-	VSC_INTR_RX_FIFO = 1 << 5,	/* Rx FIFO over/underflow */
-	VSC_INTR_TX_FIFO = 1 << 6,	/* Tx FIFO over/underflow */
-	VSC_INTR_DESCRAMBL = 1 << 7,	/* descrambler lock-lost */
-	VSC_INTR_SYMBOL_ERR = 1 << 8,	/* symbol error */
-	VSC_INTR_NEG_DONE = 1 << 10,	/* autoneg done */
-	VSC_INTR_NEG_ERR = 1 << 11,	/* autoneg error */
-	VSC_INTR_LINK_CHG = 1 << 13,	/* link change */
-	VSC_INTR_ENABLE = 1 << 15,	/* interrupt enable */
+	VSC_INTR_MS_ERR = 1 << 1,  /* master/slave resolution error */
+	VSC_INTR_CABLE = 1 << 2,  /* cable impairment */
+	VSC_INTR_FALSE_CARR = 1 << 3,  /* false carrier */
+	VSC_INTR_MEDIA_CHG = 1 << 4,  /* AMS media change */
+	VSC_INTR_RX_FIFO = 1 << 5,  /* Rx FIFO over/underflow */
+	VSC_INTR_TX_FIFO = 1 << 6,  /* Tx FIFO over/underflow */
+	VSC_INTR_DESCRAMBL = 1 << 7,  /* descrambler lock-lost */
+	VSC_INTR_SYMBOL_ERR = 1 << 8,  /* symbol error */
+	VSC_INTR_NEG_DONE = 1 << 10, /* autoneg done */
+	VSC_INTR_NEG_ERR = 1 << 11, /* autoneg error */
+	VSC_INTR_DPLX_CHG = 1 << 12, /* duplex change */
+	VSC_INTR_LINK_CHG = 1 << 13, /* link change */
+	VSC_INTR_SPD_CHG = 1 << 14, /* speed change */
+	VSC_INTR_ENABLE = 1 << 15, /* interrupt enable */
+};
+
+enum {
+	VSC_CTRL_CLAUSE37_VIEW = 1 << 4,   /* Switch to Clause 37 view */
+	VSC_CTRL_MEDIA_MODE_HI = 0xf000    /* High part of media mode select */
 };
 
 #define CFG_CHG_INTR_MASK (VSC_INTR_LINK_CHG | VSC_INTR_NEG_ERR | \
+			   VSC_INTR_DPLX_CHG | VSC_INTR_SPD_CHG | \
 	 		   VSC_INTR_NEG_DONE)
 #define INTR_MASK (CFG_CHG_INTR_MASK | VSC_INTR_TX_FIFO | VSC_INTR_RX_FIFO | \
 		   VSC_INTR_ENABLE)
@@ -184,6 +196,112 @@ static int vsc8211_get_link_status(struct cphy *cphy, int *link_ok,
 	return 0;
 }
 
+static int vsc8211_get_link_status_fiber(struct cphy *cphy, int *link_ok,
+					 int *speed, int *duplex, int *fc)
+{
+	unsigned int bmcr, status, lpa, adv;
+	int err, sp = -1, dplx = -1, pause = 0;
+
+	err = mdio_read(cphy, 0, MII_BMCR, &bmcr);
+	if (!err)
+		err = mdio_read(cphy, 0, MII_BMSR, &status);
+	if (err)
+		return err;
+
+	if (link_ok) {
+		/*
+		 * BMSR_LSTATUS is latch-low, so if it is 0 we need to read it
+		 * once more to get the current link state.
+		 */
+		if (!(status & BMSR_LSTATUS))
+			err = mdio_read(cphy, 0, MII_BMSR, &status);
+		if (err)
+			return err;
+		*link_ok = (status & BMSR_LSTATUS) != 0;
+	}
+	if (!(bmcr & BMCR_ANENABLE)) {
+		dplx = (bmcr & BMCR_FULLDPLX) ? DUPLEX_FULL : DUPLEX_HALF;
+		if (bmcr & BMCR_SPEED1000)
+			sp = SPEED_1000;
+		else if (bmcr & BMCR_SPEED100)
+			sp = SPEED_100;
+		else
+			sp = SPEED_10;
+	} else if (status & BMSR_ANEGCOMPLETE) {
+		err = mdio_read(cphy, 0, MII_LPA, &lpa);
+		if (!err)
+			err = mdio_read(cphy, 0, MII_ADVERTISE, &adv);
+		if (err)
+			return err;
+
+		if (adv & lpa & ADVERTISE_1000XFULL) {
+			dplx = DUPLEX_FULL;
+			sp = SPEED_1000;
+		} else if (adv & lpa & ADVERTISE_1000XHALF) {
+			dplx = DUPLEX_HALF;
+			sp = SPEED_1000;
+		}
+
+		if (fc && dplx == DUPLEX_FULL) {
+			if (lpa & adv & ADVERTISE_1000XPAUSE)
+				pause = PAUSE_RX | PAUSE_TX;
+			else if ((lpa & ADVERTISE_1000XPAUSE) &&
+				 (adv & lpa & ADVERTISE_1000XPSE_ASYM))
+				pause = PAUSE_TX;
+			else if ((lpa & ADVERTISE_1000XPSE_ASYM) &&
+				 (adv & ADVERTISE_1000XPAUSE))
+				pause = PAUSE_RX;
+		}
+	}
+	if (speed)
+		*speed = sp;
+	if (duplex)
+		*duplex = dplx;
+	if (fc)
+		*fc = pause;
+	return 0;
+}
+
+/*
+ * Enable/disable auto MDI/MDI-X in forced link speed mode.
+ */
+static int vsc8211_set_automdi(struct cphy *phy, int enable)
+{
+	int err;
+
+	err = mdio_write(phy, 0, VSC8211_EXT_PAGE_AXS, 0x52b5);
+	if (err)
+		return err;
+
+	err = mdio_write(phy, 0, 18, 0x12);
+	if (err)
+		return err;
+
+	err = mdio_write(phy, 0, 17, enable ? 0x2803 : 0x3003);
+	if (err)
+		return err;
+
+	err = mdio_write(phy, 0, 16, 0x87fa);
+	if (err)
+		return err;
+
+	err = mdio_write(phy, 0, VSC8211_EXT_PAGE_AXS, 0);
+	if (err)
+		return err;
+
+	return 0;
+}
+
+int vsc8211_set_speed_duplex(struct cphy *phy, int speed, int duplex)
+{
+	int err;
+
+	err = t3_set_phy_speed_duplex(phy, speed, duplex);
+	if (!err)
+		err = vsc8211_set_automdi(phy, 1);
+	return err;
+}
+
 static int vsc8211_power_down(struct cphy *cphy, int enable)
 {
 	return t3_mdio_change_bits(cphy, 0, MII_BMCR, BMCR_PDOWN,
@@ -221,12 +339,66 @@ static struct cphy_ops vsc8211_ops = {
 	.power_down = vsc8211_power_down,
 };
 
+static struct cphy_ops vsc8211_fiber_ops = {
+	.reset = vsc8211_reset,
+	.intr_enable = vsc8211_intr_enable,
+	.intr_disable = vsc8211_intr_disable,
+	.intr_clear = vsc8211_intr_clear,
+	.intr_handler = vsc8211_intr_handler,
+	.autoneg_enable = vsc8211_autoneg_enable,
+	.autoneg_restart = vsc8211_autoneg_restart,
+	.advertise = t3_phy_advertise_fiber,
+	.set_speed_duplex = t3_set_phy_speed_duplex,
+	.get_link_status = vsc8211_get_link_status_fiber,
+	.power_down = vsc8211_power_down,
+};
+
 int t3_vsc8211_phy_prep(struct cphy *phy, struct adapter *adapter,
 			int phy_addr, const struct mdio_ops *mdio_ops)
 {
+	int err;
+	unsigned int val;
+
 	cphy_init(phy, adapter, phy_addr, &vsc8211_ops, mdio_ops,
 		  SUPPORTED_10baseT_Full | SUPPORTED_100baseT_Full |
 		  SUPPORTED_1000baseT_Full | SUPPORTED_Autoneg | SUPPORTED_MII |
 		  SUPPORTED_TP | SUPPORTED_IRQ, "10/100/1000BASE-T");
+	msleep(20);       /* PHY needs ~10ms to start responding to MDIO */
+
+	err = mdio_read(phy, 0, VSC8211_EXT_CTRL, &val);
+	if (err)
+		return err;
+	if (val & VSC_CTRL_MEDIA_MODE_HI) {
+		/* copper interface, just need to configure the LEDs */
+		return mdio_write(phy, 0, VSC8211_LED_CTRL, 0x100);
+	}
+
+	phy->caps = SUPPORTED_1000baseT_Full | SUPPORTED_Autoneg |
+		    SUPPORTED_MII | SUPPORTED_FIBRE | SUPPORTED_IRQ;
+	phy->desc = "1000BASE-X";
+	phy->ops = &vsc8211_fiber_ops;
+
+	err = mdio_write(phy, 0, VSC8211_EXT_PAGE_AXS, 1);
+	if (err)
+		return err;
+
+	err = mdio_write(phy, 0, VSC8211_SIGDET_CTRL, 1);
+	if (err)
+		return err;
+
+	err = mdio_write(phy, 0, VSC8211_EXT_PAGE_AXS, 0);
+	if (err)
+		return err;
+
+	err = mdio_write(phy, 0, VSC8211_EXT_CTRL,
+			 val | VSC_CTRL_CLAUSE37_VIEW);
+	if (err)
+		return err;
+
+	err = vsc8211_reset(phy, 0);
+	if (err)
+		return err;
+
+	udelay(5); /* delay after reset before next SMI */
 	return 0;
 }


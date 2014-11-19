From: Johan Hovold <johan@kernel.org>
Subject: [PATCH 09/10] net: phy: micrel: refactor interrupt config
Date: Wed, 19 Nov 2014 12:59:22 +0100
Message-ID: <1416398363-32306-10-git-send-email-johan@kernel.org>
References: <1416398363-32306-1-git-send-email-johan@kernel.org>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Bruno Thomsen <bth@kamstrup.dk>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Mark Rutland <mark.rutland@arm.com>,
	Johan Hovold <johan@kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1416398363-32306-1-git-send-email-johan@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add generic interrupt-config callback and store interrupt-level bitmask
in type data for PHY types not using bit 9.

Signed-off-by: Johan Hovold <johan@kernel.org>
---
 drivers/net/phy/micrel.c | 71 ++++++++++++++++++++----------------------------
 1 file changed, 29 insertions(+), 42 deletions(-)

diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index 04fbee846b66..d7eb7b0e6d4e 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -55,8 +55,6 @@
 #define	MII_KSZPHY_CTRL				MII_KSZPHY_CTRL_2
 /* bitmap of PHY register to set interrupt mode */
 #define KSZPHY_CTRL_INT_ACTIVE_HIGH		BIT(9)
-#define KSZ9021_CTRL_INT_ACTIVE_HIGH		BIT(14)
-#define KS8737_CTRL_INT_ACTIVE_HIGH		BIT(14)
 #define KSZPHY_RMII_REF_CLK_SEL			BIT(7)
 
 /* Write/read to/from extended registers */
@@ -75,6 +73,7 @@
 
 struct kszphy_type {
 	u32 led_mode_reg;
+	u16 interrupt_level_mask;
 	bool has_broadcast_disable;
 	bool has_rmii_ref_clk_sel;
 };
@@ -105,6 +104,14 @@ static const struct kszphy_type ksz8081_type = {
 	.has_rmii_ref_clk_sel	= true,
 };
 
+static const struct kszphy_type ks8737_type = {
+	.interrupt_level_mask	= BIT(14),
+};
+
+static const struct kszphy_type ksz9021_type = {
+	.interrupt_level_mask	= BIT(14),
+};
+
 static int kszphy_extended_write(struct phy_device *phydev,
 				u32 regnum, u16 val)
 {
@@ -129,54 +136,31 @@ static int kszphy_ack_interrupt(struct phy_device *phydev)
 	return (rc < 0) ? rc : 0;
 }
 
-static int kszphy_set_interrupt(struct phy_device *phydev)
-{
-	int temp;
-	temp = (PHY_INTERRUPT_ENABLED == phydev->interrupts) ?
-		KSZPHY_INTCS_ALL : 0;
-	return phy_write(phydev, MII_KSZPHY_INTCS, temp);
-}
-
 static int kszphy_config_intr(struct phy_device *phydev)
 {
-	int temp, rc;
-
-	/* set the interrupt pin active low */
-	temp = phy_read(phydev, MII_KSZPHY_CTRL);
-	if (temp < 0)
-		return temp;
-	temp &= ~KSZPHY_CTRL_INT_ACTIVE_HIGH;
-	phy_write(phydev, MII_KSZPHY_CTRL, temp);
-	rc = kszphy_set_interrupt(phydev);
-	return rc < 0 ? rc : 0;
-}
+	const struct kszphy_type *type = phydev->drv->driver_data;
+	int temp;
+	u16 mask;
 
-static int ksz9021_config_intr(struct phy_device *phydev)
-{
-	int temp, rc;
+	if (type && type->interrupt_level_mask)
+		mask = type->interrupt_level_mask;
+	else
+		mask = KSZPHY_CTRL_INT_ACTIVE_HIGH;
 
 	/* set the interrupt pin active low */
 	temp = phy_read(phydev, MII_KSZPHY_CTRL);
 	if (temp < 0)
 		return temp;
-	temp &= ~KSZ9021_CTRL_INT_ACTIVE_HIGH;
+	temp &= ~mask;
 	phy_write(phydev, MII_KSZPHY_CTRL, temp);
-	rc = kszphy_set_interrupt(phydev);
-	return rc < 0 ? rc : 0;
-}
 
-static int ks8737_config_intr(struct phy_device *phydev)
-{
-	int temp, rc;
+	/* enable / disable interrupts */
+	if (phydev->interrupts == PHY_INTERRUPT_ENABLED)
+		temp = KSZPHY_INTCS_ALL;
+	else
+		temp = 0;
 
-	/* set the interrupt pin active low */
-	temp = phy_read(phydev, MII_KSZPHY_CTRL);
-	if (temp < 0)
-		return temp;
-	temp &= ~KS8737_CTRL_INT_ACTIVE_HIGH;
-	phy_write(phydev, MII_KSZPHY_CTRL, temp);
-	rc = kszphy_set_interrupt(phydev);
-	return rc < 0 ? rc : 0;
+	return phy_write(phydev, MII_KSZPHY_INTCS, temp);
 }
 
 static int kszphy_rmii_clk_sel(struct phy_device *phydev, bool val)
@@ -581,11 +565,12 @@ static struct phy_driver ksphy_driver[] = {
 	.name		= "Micrel KS8737",
 	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause),
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
+	.driver_data	= &ks8737_type,
 	.config_init	= kszphy_config_init,
 	.config_aneg	= genphy_config_aneg,
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= kszphy_ack_interrupt,
-	.config_intr	= ks8737_config_intr,
+	.config_intr	= kszphy_config_intr,
 	.suspend	= genphy_suspend,
 	.resume		= genphy_resume,
 	.driver		= { .owner = THIS_MODULE,},
@@ -726,11 +711,12 @@ static struct phy_driver ksphy_driver[] = {
 	.name		= "Micrel KSZ9021 Gigabit PHY",
 	.features	= (PHY_GBIT_FEATURES | SUPPORTED_Pause),
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
+	.driver_data	= &ksz9021_type,
 	.config_init	= ksz9021_config_init,
 	.config_aneg	= genphy_config_aneg,
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= kszphy_ack_interrupt,
-	.config_intr	= ksz9021_config_intr,
+	.config_intr	= kszphy_config_intr,
 	.suspend	= genphy_suspend,
 	.resume		= genphy_resume,
 	.read_mmd_indirect = ksz9021_rd_mmd_phyreg,
@@ -742,11 +728,12 @@ static struct phy_driver ksphy_driver[] = {
 	.name		= "Micrel KSZ9031 Gigabit PHY",
 	.features	= (PHY_GBIT_FEATURES | SUPPORTED_Pause),
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
+	.driver_data	= &ksz9021_type,
 	.config_init	= ksz9031_config_init,
 	.config_aneg	= genphy_config_aneg,
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= kszphy_ack_interrupt,
-	.config_intr	= ksz9021_config_intr,
+	.config_intr	= kszphy_config_intr,
 	.suspend	= genphy_suspend,
 	.resume		= genphy_resume,
 	.driver		= { .owner = THIS_MODULE, },
-- 
2.0.4

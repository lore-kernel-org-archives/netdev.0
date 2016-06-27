From: Harini Katakam <harini.katakam@xilinx.com>
Subject: [PATCH] net: marvell: Add separate config ANEG function for Marvell 88E1111
Date: Mon, 27 Jun 2016 13:09:59 +0530
Message-ID: <1467013199-26925-1-git-send-email-harinik@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<harinik@xilinx.com>, <punnaia@xilinx.com>, <michals@xilinx.com>
To: <f.fainelli@gmail.com>, <harinikatakamlinux@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Marvell 88E1111 currently uses the generic marvell config ANEG function.
This function has a sequence accessing Page 5 and Register 31,
both of which are not defined or reserved for this PHY.
Hence this patch adds a new config ANEG function for Marvell 88E1111
without these erroneous accesses.

Signed-off-by: Harini Katakam <harinik@xilinx.com>
---
 drivers/net/phy/marvell.c |   44 +++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 43 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index 280e879..783d0ca 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -285,6 +285,48 @@ static int marvell_config_aneg(struct phy_device *phydev)
 	return 0;
 }
 
+static int m88e1111_config_aneg(struct phy_device *phydev)
+{
+	int err;
+
+	/* The Marvell PHY has an errata which requires
+	 * that certain registers get written in order
+	 * to restart autonegotiation
+	 */
+	err = phy_write(phydev, MII_BMCR, BMCR_RESET);
+
+	err = marvell_set_polarity(phydev, phydev->mdix);
+	if (err < 0)
+		return err;
+
+	err = phy_write(phydev, MII_M1111_PHY_LED_CONTROL,
+			MII_M1111_PHY_LED_DIRECT);
+	if (err < 0)
+		return err;
+
+	err = genphy_config_aneg(phydev);
+	if (err < 0)
+		return err;
+
+	if (phydev->autoneg != AUTONEG_ENABLE) {
+		int bmcr;
+
+		/* A write to speed/duplex bits (that is performed by
+		 * genphy_config_aneg() call above) must be followed by
+		 * a software reset. Otherwise, the write has no effect.
+		 */
+		bmcr = phy_read(phydev, MII_BMCR);
+		if (bmcr < 0)
+			return bmcr;
+
+		err = phy_write(phydev, MII_BMCR, bmcr | BMCR_RESET);
+		if (err < 0)
+			return err;
+	}
+
+	return 0;
+}
+
 #ifdef CONFIG_OF_MDIO
 /*
  * Set and/or override some configuration registers based on the
@@ -1161,7 +1203,7 @@ static struct phy_driver marvell_drivers[] = {
 		.flags = PHY_HAS_INTERRUPT,
 		.probe = marvell_probe,
 		.config_init = &m88e1111_config_init,
-		.config_aneg = &marvell_config_aneg,
+		.config_aneg = &m88e1111_config_aneg,
 		.read_status = &marvell_read_status,
 		.ack_interrupt = &marvell_ack_interrupt,
 		.config_intr = &marvell_config_intr,
-- 
1.7.9.5

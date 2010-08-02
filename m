From: Cyril Chemparathy <cyril@ti.com>
Subject: [PATCH 2/2] phy/marvell: add 88ec048 support
Date: Mon,  2 Aug 2010 15:44:54 -0400
Message-ID: <1280778294-2993-3-git-send-email-cyril@ti.com>
References: <1280778294-2993-1-git-send-email-cyril@ti.com>
Cc: Cyril Chemparathy <cyril@ti.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:53544 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754611Ab0HBTo7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Aug 2010 15:44:59 -0400
Received: from dlep33.itg.ti.com ([157.170.170.112])
	by bear.ext.ti.com (8.13.7/8.13.7) with ESMTP id o72JiwNi017525
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 2 Aug 2010 14:44:58 -0500
In-Reply-To: <1280778294-2993-1-git-send-email-cyril@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marvell 88ec048 is a derivative of its 88e1121r device.  From the programmer's
perspective, the one major difference is the addition of an additional control
bit in Page 2 Register 16 - used to control the padding of odd nibble
preambles.

This patch adds support for this new device, while inheriting as much code as
possible from the existing 88e1121r implementation.

Signed-off-by: Cyril Chemparathy <cyril@ti.com>
---
 drivers/net/phy/marvell.c |   41 +++++++++++++++++++++++++++++++++++++++++
 1 files changed, 41 insertions(+), 0 deletions(-)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index b1413ae..0887218 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -75,6 +75,9 @@
 #define MII_88E1121_PHY_MSCR_TX_DELAY	BIT(4)
 #define MII_88E1121_PHY_MSCR_DELAY_MASK	(~(0x3 << 4))
 
+#define MII_88EC048_PHY_MSCR1_REG	16
+#define MII_88EC048_PHY_MSCR1_PAD_ODD	BIT(6)
+
 #define MII_88E1121_PHY_LED_CTRL	16
 #define MII_88E1121_PHY_LED_PAGE	3
 #define MII_88E1121_PHY_LED_DEF		0x0030
@@ -231,6 +234,31 @@ static int m88e1121_config_aneg(struct phy_device *phydev)
 	return err;
 }
 
+static int m88ec048_config_aneg(struct phy_device *phydev)
+{
+	int err, oldpage, mscr;
+
+	oldpage = phy_read(phydev, MII_88E1121_PHY_PAGE);
+
+	err = phy_write(phydev, MII_88E1121_PHY_PAGE,
+			MII_88E1121_PHY_MSCR_PAGE);
+	if (err < 0)
+		return err;
+
+	mscr = phy_read(phydev, MII_88EC048_PHY_MSCR1_REG);
+	mscr |= MII_88EC048_PHY_MSCR1_PAD_ODD;
+
+	err = phy_write(phydev, MII_88E1121_PHY_MSCR_REG, mscr);
+	if (err < 0)
+		return err;
+
+	err = phy_write(phydev, MII_88E1121_PHY_PAGE, oldpage);
+	if (err < 0)
+		return err;
+
+	return m88e1121_config_aneg(phydev);
+}
+
 static int m88e1111_config_init(struct phy_device *phydev)
 {
 	int err;
@@ -622,6 +650,19 @@ static struct phy_driver marvell_drivers[] = {
 		.driver = { .owner = THIS_MODULE },
 	},
 	{
+		.phy_id = 0x01410e90,
+		.phy_id_mask = 0xfffffff0,
+		.name = "Marvell 88EC048",
+		.features = PHY_GBIT_FEATURES,
+		.flags = PHY_HAS_INTERRUPT,
+		.config_aneg = &m88ec048_config_aneg,
+		.read_status = &marvell_read_status,
+		.ack_interrupt = &marvell_ack_interrupt,
+		.config_intr = &marvell_config_intr,
+		.did_interrupt = &m88e1121_did_interrupt,
+		.driver = { .owner = THIS_MODULE },
+	},
+	{
 		.phy_id = 0x01410cd0,
 		.phy_id_mask = 0xfffffff0,
 		.name = "Marvell 88E1145",
-- 
1.7.0.4


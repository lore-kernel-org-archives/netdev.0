From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 2/2] phy: marvell: Add support for phy packet generator
Date: Wed, 17 Feb 2016 21:32:07 +0100
Message-ID: <1455741127-25453-3-git-send-email-andrew@lunn.ch>
References: <1455741127-25453-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:50602 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422737AbcBQUcW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 15:32:22 -0500
In-Reply-To: <1455741127-25453-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Most of the Marvell PHYs include a packet generator, for sending up to
255 packets, of size 64 or 1518 bytes. Packets can either contain
repeated 0x5a 0xa5, or random bytes. Packets can contain CRC errors or
symbol errors. Some PHYs allow the inter packet gap to be changed.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/phy/marvell.c | 92 +++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 92 insertions(+)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index e3eb96443c97..1c42aef6dcf3 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -133,6 +133,15 @@
 #define MII_88E3016_DISABLE_SCRAMBLER	0x0200
 #define MII_88E3016_AUTO_MDIX_CROSSOVER	0x0030
 
+#define MII_88E1540_PKT_GEN		16
+#define MII_88E1540_PKT_GEN_BURST_SHIFT	8
+#define MII_88E1540_PKT_GEN_ENABLE	BIT(3)
+#define MII_88E1540_PKT_GEN_FIXED	BIT(2)
+#define MII_88E1540_PKT_GEN_LEN_1518	BIT(1)
+#define MII_88E1540_PKT_GEN_ERROR	BIT(0)
+
+#define MII_88E1540_PKT_GEN_IPG		19
+
 MODULE_DESCRIPTION("Marvell PHY driver");
 MODULE_AUTHOR("Andy Fleming");
 MODULE_LICENSE("GPL");
@@ -1057,6 +1066,83 @@ static void marvell_get_stats(struct phy_device *phydev,
 		data[i] = marvell_get_stat(phydev, i);
 }
 
+static int marvell_pkt_gen(struct phy_device *phydev,
+			   struct ethtool_phy_pkt_gen *pkt_gen)
+{
+	int err, oldpage, reg, max_loop = 100;
+	u32 phy_id = phydev->drv->phy_id;
+	bool has_ipg = false;
+
+	switch (phy_id) {
+	case MARVELL_PHY_ID_88E1510:
+	case MARVELL_PHY_ID_88E1540:
+		has_ipg = true;
+	}
+
+	if (pkt_gen->count < 1 || pkt_gen->count > 255)
+		return -EINVAL;
+
+	if (pkt_gen->len == 0)
+		pkt_gen->len = 64;
+
+	if (pkt_gen->len != 64 && pkt_gen->len != 1518)
+		return -EINVAL;
+
+	if (has_ipg) {
+		if (pkt_gen->ipg == 0)
+			pkt_gen->ipg = 12;
+
+		if (pkt_gen->ipg > 256)
+			return -EINVAL;
+	} else {
+		if (pkt_gen->ipg != 0)
+			return -EINVAL;
+	}
+
+	oldpage = phy_read(phydev, MII_MARVELL_PHY_PAGE);
+	if (oldpage < 0) {
+		err = oldpage;
+		goto out;
+	}
+
+	err = phy_write(phydev, MII_MARVELL_PHY_PAGE, 6);
+	if (err)
+		goto out;
+
+	if (has_ipg) {
+		err = phy_write(phydev, MII_88E1540_PKT_GEN_IPG,
+				pkt_gen->ipg - 1);
+		if (err)
+			goto out;
+	}
+
+	reg = MII_88E1540_PKT_GEN_ENABLE;
+	reg |= pkt_gen->count << MII_88E1540_PKT_GEN_BURST_SHIFT;
+	if (pkt_gen->len == 1518)
+		reg |= MII_88E1540_PKT_GEN_LEN_1518;
+	if (!(pkt_gen->flags & ETH_PKT_RANDOM))
+		reg |= MII_88E1540_PKT_GEN_FIXED;
+	if (pkt_gen->flags & ETH_PKT_ERROR)
+		reg |= MII_88E1540_PKT_GEN_ERROR;
+
+	err = phy_write(phydev, MII_88E1540_PKT_GEN, reg);
+	if (err)
+		goto out;
+
+	do {
+		usleep_range(3000, 4000);
+		reg = phy_read(phydev, MII_88E1540_PKT_GEN);
+	} while (max_loop-- && (reg & MII_88E1540_PKT_GEN_ENABLE));
+
+	if (!max_loop)
+		err = -ETIMEDOUT;
+
+out:
+	phy_write(phydev, MII_MARVELL_PHY_PAGE, oldpage);
+
+	return err;
+}
+
 static int marvell_probe(struct phy_device *phydev)
 {
 	struct marvell_priv *priv;
@@ -1102,6 +1188,7 @@ static struct phy_driver marvell_drivers[] = {
 		.config_intr = &marvell_config_intr,
 		.resume = &genphy_resume,
 		.suspend = &genphy_suspend,
+		.pkt_gen = marvell_pkt_gen,
 		.get_sset_count = marvell_get_sset_count,
 		.get_strings = marvell_get_strings,
 		.get_stats = marvell_get_stats,
@@ -1156,6 +1243,7 @@ static struct phy_driver marvell_drivers[] = {
 		.did_interrupt = &m88e1121_did_interrupt,
 		.resume = &genphy_resume,
 		.suspend = &genphy_suspend,
+		.pkt_gen = marvell_pkt_gen,
 		.get_sset_count = marvell_get_sset_count,
 		.get_strings = marvell_get_strings,
 		.get_stats = marvell_get_stats,
@@ -1212,6 +1300,7 @@ static struct phy_driver marvell_drivers[] = {
 		.config_intr = &marvell_config_intr,
 		.resume = &genphy_resume,
 		.suspend = &genphy_suspend,
+		.pkt_gen = marvell_pkt_gen,
 		.get_sset_count = marvell_get_sset_count,
 		.get_strings = marvell_get_strings,
 		.get_stats = marvell_get_stats,
@@ -1248,6 +1337,7 @@ static struct phy_driver marvell_drivers[] = {
 		.config_intr = &marvell_config_intr,
 		.resume = &genphy_resume,
 		.suspend = &genphy_suspend,
+		.pkt_gen = marvell_pkt_gen,
 		.get_sset_count = marvell_get_sset_count,
 		.get_strings = marvell_get_strings,
 		.get_stats = marvell_get_stats,
@@ -1284,6 +1374,7 @@ static struct phy_driver marvell_drivers[] = {
 		.did_interrupt = &m88e1121_did_interrupt,
 		.resume = &genphy_resume,
 		.suspend = &genphy_suspend,
+		.pkt_gen = marvell_pkt_gen,
 		.get_sset_count = marvell_get_sset_count,
 		.get_strings = marvell_get_strings,
 		.get_stats = marvell_get_stats,
@@ -1304,6 +1395,7 @@ static struct phy_driver marvell_drivers[] = {
 		.did_interrupt = &m88e1121_did_interrupt,
 		.resume = &genphy_resume,
 		.suspend = &genphy_suspend,
+		.pkt_gen = marvell_pkt_gen,
 		.get_sset_count = marvell_get_sset_count,
 		.get_strings = marvell_get_strings,
 		.get_stats = marvell_get_stats,
-- 
2.7.0

From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCHv2 net-next 2/3] phy: marvell: Add ethtool statistics counters
Date: Sun, 27 Dec 2015 12:58:27 +0100
Message-ID: <1451217508-22276-3-git-send-email-andrew@lunn.ch>
References: <1451217508-22276-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:50846 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751158AbbL0L6i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Dec 2015 06:58:38 -0500
In-Reply-To: <1451217508-22276-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PHY counters receiver errors and errors while idle.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/phy/marvell.c | 135 ++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 135 insertions(+)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index 0240552b50f3..50b5eac75854 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -137,6 +137,22 @@ MODULE_DESCRIPTION("Marvell PHY driver");
 MODULE_AUTHOR("Andy Fleming");
 MODULE_LICENSE("GPL");
 
+struct marvell_hw_stat {
+	const char *string;
+	u8 page;
+	u8 reg;
+	u8 bits;
+};
+
+static struct marvell_hw_stat marvell_hw_stats[] = {
+	{ "phy_receive_errors", 0, 21, 16},
+	{ "phy_idle_errors", 0, 10, 8 },
+};
+
+struct marvell_priv {
+	u64 stats[ARRAY_SIZE(marvell_hw_stats)];
+};
+
 static int marvell_ack_interrupt(struct phy_device *phydev)
 {
 	int err;
@@ -986,12 +1002,80 @@ static int m88e1318_set_wol(struct phy_device *phydev, struct ethtool_wolinfo *w
 	return 0;
 }
 
+static int marvell_get_sset_count(struct phy_device *phydev)
+{
+	return ARRAY_SIZE(marvell_hw_stats);
+}
+
+static void marvell_get_strings(struct phy_device *phydev, u8 *data)
+{
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(marvell_hw_stats); i++) {
+		memcpy(data + i * ETH_GSTRING_LEN,
+		       marvell_hw_stats[i].string, ETH_GSTRING_LEN);
+	}
+}
+
+#ifndef UINT64_MAX
+#define UINT64_MAX              (u64)(~((u64)0))
+#endif
+static u64 marvell_get_stat(struct phy_device *phydev, int i)
+{
+	struct marvell_hw_stat stat = marvell_hw_stats[i];
+	struct marvell_priv *priv = phydev->priv;
+	int err, oldpage;
+	u64 val;
+
+	oldpage = phy_read(phydev, MII_MARVELL_PHY_PAGE);
+	err = phy_write(phydev, MII_MARVELL_PHY_PAGE,
+			stat.page);
+	if (err < 0)
+		return UINT64_MAX;
+
+	val = phy_read(phydev, stat.reg);
+	if (val < 0) {
+		val = UINT64_MAX;
+	} else {
+		val = val & ((1 << stat.bits) - 1);
+		priv->stats[i] += val;
+		val = priv->stats[i];
+	}
+
+	phy_write(phydev, MII_MARVELL_PHY_PAGE, oldpage);
+
+	return val;
+}
+
+static void marvell_get_stats(struct phy_device *phydev,
+			      struct ethtool_stats *stats, u64 *data)
+{
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(marvell_hw_stats); i++)
+		data[i] = marvell_get_stat(phydev, i);
+}
+
+static int marvell_probe(struct phy_device *phydev)
+{
+	struct marvell_priv *priv;
+
+	priv = devm_kzalloc(&phydev->dev, sizeof(*priv), GFP_KERNEL);
+	if (!priv)
+		return -ENOMEM;
+
+	phydev->priv = priv;
+
+	return 0;
+}
+
 static struct phy_driver marvell_drivers[] = {
 	{
 		.phy_id = MARVELL_PHY_ID_88E1101,
 		.phy_id_mask = MARVELL_PHY_ID_MASK,
 		.name = "Marvell 88E1101",
 		.features = PHY_GBIT_FEATURES,
+		.probe = marvell_probe,
 		.flags = PHY_HAS_INTERRUPT,
 		.config_aneg = &marvell_config_aneg,
 		.read_status = &genphy_read_status,
@@ -999,6 +1083,9 @@ static struct phy_driver marvell_drivers[] = {
 		.config_intr = &marvell_config_intr,
 		.resume = &genphy_resume,
 		.suspend = &genphy_suspend,
+		.get_sset_count = marvell_get_sset_count,
+		.get_strings = marvell_get_strings,
+		.get_stats = marvell_get_stats,
 		.driver = { .owner = THIS_MODULE },
 	},
 	{
@@ -1007,6 +1094,7 @@ static struct phy_driver marvell_drivers[] = {
 		.name = "Marvell 88E1112",
 		.features = PHY_GBIT_FEATURES,
 		.flags = PHY_HAS_INTERRUPT,
+		.probe = marvell_probe,
 		.config_init = &m88e1111_config_init,
 		.config_aneg = &marvell_config_aneg,
 		.read_status = &genphy_read_status,
@@ -1014,6 +1102,9 @@ static struct phy_driver marvell_drivers[] = {
 		.config_intr = &marvell_config_intr,
 		.resume = &genphy_resume,
 		.suspend = &genphy_suspend,
+		.get_sset_count = marvell_get_sset_count,
+		.get_strings = marvell_get_strings,
+		.get_stats = marvell_get_stats,
 		.driver = { .owner = THIS_MODULE },
 	},
 	{
@@ -1022,6 +1113,7 @@ static struct phy_driver marvell_drivers[] = {
 		.name = "Marvell 88E1111",
 		.features = PHY_GBIT_FEATURES,
 		.flags = PHY_HAS_INTERRUPT,
+		.probe = marvell_probe,
 		.config_init = &m88e1111_config_init,
 		.config_aneg = &marvell_config_aneg,
 		.read_status = &marvell_read_status,
@@ -1029,6 +1121,9 @@ static struct phy_driver marvell_drivers[] = {
 		.config_intr = &marvell_config_intr,
 		.resume = &genphy_resume,
 		.suspend = &genphy_suspend,
+		.get_sset_count = marvell_get_sset_count,
+		.get_strings = marvell_get_strings,
+		.get_stats = marvell_get_stats,
 		.driver = { .owner = THIS_MODULE },
 	},
 	{
@@ -1037,6 +1132,7 @@ static struct phy_driver marvell_drivers[] = {
 		.name = "Marvell 88E1118",
 		.features = PHY_GBIT_FEATURES,
 		.flags = PHY_HAS_INTERRUPT,
+		.probe = marvell_probe,
 		.config_init = &m88e1118_config_init,
 		.config_aneg = &m88e1118_config_aneg,
 		.read_status = &genphy_read_status,
@@ -1044,6 +1140,9 @@ static struct phy_driver marvell_drivers[] = {
 		.config_intr = &marvell_config_intr,
 		.resume = &genphy_resume,
 		.suspend = &genphy_suspend,
+		.get_sset_count = marvell_get_sset_count,
+		.get_strings = marvell_get_strings,
+		.get_stats = marvell_get_stats,
 		.driver = {.owner = THIS_MODULE,},
 	},
 	{
@@ -1052,6 +1151,7 @@ static struct phy_driver marvell_drivers[] = {
 		.name = "Marvell 88E1121R",
 		.features = PHY_GBIT_FEATURES,
 		.flags = PHY_HAS_INTERRUPT,
+		.probe = marvell_probe,
 		.config_aneg = &m88e1121_config_aneg,
 		.read_status = &marvell_read_status,
 		.ack_interrupt = &marvell_ack_interrupt,
@@ -1059,6 +1159,9 @@ static struct phy_driver marvell_drivers[] = {
 		.did_interrupt = &m88e1121_did_interrupt,
 		.resume = &genphy_resume,
 		.suspend = &genphy_suspend,
+		.get_sset_count = marvell_get_sset_count,
+		.get_strings = marvell_get_strings,
+		.get_stats = marvell_get_stats,
 		.driver = { .owner = THIS_MODULE },
 	},
 	{
@@ -1067,6 +1170,7 @@ static struct phy_driver marvell_drivers[] = {
 		.name = "Marvell 88E1318S",
 		.features = PHY_GBIT_FEATURES,
 		.flags = PHY_HAS_INTERRUPT,
+		.probe = marvell_probe,
 		.config_aneg = &m88e1318_config_aneg,
 		.read_status = &marvell_read_status,
 		.ack_interrupt = &marvell_ack_interrupt,
@@ -1076,6 +1180,9 @@ static struct phy_driver marvell_drivers[] = {
 		.set_wol = &m88e1318_set_wol,
 		.resume = &genphy_resume,
 		.suspend = &genphy_suspend,
+		.get_sset_count = marvell_get_sset_count,
+		.get_strings = marvell_get_strings,
+		.get_stats = marvell_get_stats,
 		.driver = { .owner = THIS_MODULE },
 	},
 	{
@@ -1084,6 +1191,7 @@ static struct phy_driver marvell_drivers[] = {
 		.name = "Marvell 88E1145",
 		.features = PHY_GBIT_FEATURES,
 		.flags = PHY_HAS_INTERRUPT,
+		.probe = marvell_probe,
 		.config_init = &m88e1145_config_init,
 		.config_aneg = &marvell_config_aneg,
 		.read_status = &genphy_read_status,
@@ -1091,6 +1199,9 @@ static struct phy_driver marvell_drivers[] = {
 		.config_intr = &marvell_config_intr,
 		.resume = &genphy_resume,
 		.suspend = &genphy_suspend,
+		.get_sset_count = marvell_get_sset_count,
+		.get_strings = marvell_get_strings,
+		.get_stats = marvell_get_stats,
 		.driver = { .owner = THIS_MODULE },
 	},
 	{
@@ -1099,6 +1210,7 @@ static struct phy_driver marvell_drivers[] = {
 		.name = "Marvell 88E1149R",
 		.features = PHY_GBIT_FEATURES,
 		.flags = PHY_HAS_INTERRUPT,
+		.probe = marvell_probe,
 		.config_init = &m88e1149_config_init,
 		.config_aneg = &m88e1118_config_aneg,
 		.read_status = &genphy_read_status,
@@ -1106,6 +1218,9 @@ static struct phy_driver marvell_drivers[] = {
 		.config_intr = &marvell_config_intr,
 		.resume = &genphy_resume,
 		.suspend = &genphy_suspend,
+		.get_sset_count = marvell_get_sset_count,
+		.get_strings = marvell_get_strings,
+		.get_stats = marvell_get_stats,
 		.driver = { .owner = THIS_MODULE },
 	},
 	{
@@ -1114,6 +1229,7 @@ static struct phy_driver marvell_drivers[] = {
 		.name = "Marvell 88E1240",
 		.features = PHY_GBIT_FEATURES,
 		.flags = PHY_HAS_INTERRUPT,
+		.probe = marvell_probe,
 		.config_init = &m88e1111_config_init,
 		.config_aneg = &marvell_config_aneg,
 		.read_status = &genphy_read_status,
@@ -1121,6 +1237,9 @@ static struct phy_driver marvell_drivers[] = {
 		.config_intr = &marvell_config_intr,
 		.resume = &genphy_resume,
 		.suspend = &genphy_suspend,
+		.get_sset_count = marvell_get_sset_count,
+		.get_strings = marvell_get_strings,
+		.get_stats = marvell_get_stats,
 		.driver = { .owner = THIS_MODULE },
 	},
 	{
@@ -1129,6 +1248,7 @@ static struct phy_driver marvell_drivers[] = {
 		.name = "Marvell 88E1116R",
 		.features = PHY_GBIT_FEATURES,
 		.flags = PHY_HAS_INTERRUPT,
+		.probe = marvell_probe,
 		.config_init = &m88e1116r_config_init,
 		.config_aneg = &genphy_config_aneg,
 		.read_status = &genphy_read_status,
@@ -1136,6 +1256,9 @@ static struct phy_driver marvell_drivers[] = {
 		.config_intr = &marvell_config_intr,
 		.resume = &genphy_resume,
 		.suspend = &genphy_suspend,
+		.get_sset_count = marvell_get_sset_count,
+		.get_strings = marvell_get_strings,
+		.get_stats = marvell_get_stats,
 		.driver = { .owner = THIS_MODULE },
 	},
 	{
@@ -1144,6 +1267,7 @@ static struct phy_driver marvell_drivers[] = {
 		.name = "Marvell 88E1510",
 		.features = PHY_GBIT_FEATURES,
 		.flags = PHY_HAS_INTERRUPT,
+		.probe = marvell_probe,
 		.config_aneg = &m88e1510_config_aneg,
 		.read_status = &marvell_read_status,
 		.ack_interrupt = &marvell_ack_interrupt,
@@ -1151,6 +1275,9 @@ static struct phy_driver marvell_drivers[] = {
 		.did_interrupt = &m88e1121_did_interrupt,
 		.resume = &genphy_resume,
 		.suspend = &genphy_suspend,
+		.get_sset_count = marvell_get_sset_count,
+		.get_strings = marvell_get_strings,
+		.get_stats = marvell_get_stats,
 		.driver = { .owner = THIS_MODULE },
 	},
 	{
@@ -1159,6 +1286,7 @@ static struct phy_driver marvell_drivers[] = {
 		.name = "Marvell 88E1540",
 		.features = PHY_GBIT_FEATURES,
 		.flags = PHY_HAS_INTERRUPT,
+		.probe = marvell_probe,
 		.config_aneg = &m88e1510_config_aneg,
 		.read_status = &marvell_read_status,
 		.ack_interrupt = &marvell_ack_interrupt,
@@ -1166,6 +1294,9 @@ static struct phy_driver marvell_drivers[] = {
 		.did_interrupt = &m88e1121_did_interrupt,
 		.resume = &genphy_resume,
 		.suspend = &genphy_suspend,
+		.get_sset_count = marvell_get_sset_count,
+		.get_strings = marvell_get_strings,
+		.get_stats = marvell_get_stats,
 		.driver = { .owner = THIS_MODULE },
 	},
 	{
@@ -1174,6 +1305,7 @@ static struct phy_driver marvell_drivers[] = {
 		.name = "Marvell 88E3016",
 		.features = PHY_BASIC_FEATURES,
 		.flags = PHY_HAS_INTERRUPT,
+		.probe = marvell_probe,
 		.config_aneg = &genphy_config_aneg,
 		.config_init = &m88e3016_config_init,
 		.aneg_done = &marvell_aneg_done,
@@ -1183,6 +1315,9 @@ static struct phy_driver marvell_drivers[] = {
 		.did_interrupt = &m88e1121_did_interrupt,
 		.resume = &genphy_resume,
 		.suspend = &genphy_suspend,
+		.get_sset_count = marvell_get_sset_count,
+		.get_strings = marvell_get_strings,
+		.get_stats = marvell_get_stats,
 		.driver = { .owner = THIS_MODULE },
 	},
 };
-- 
2.6.4

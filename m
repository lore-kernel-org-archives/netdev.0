From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCHv2 net-next] net: phy: smsc: Implement PHY statistics
Date: Sat,  3 Jun 2017 20:00:36 +0200
Message-ID: <1496512836-22198-1-git-send-email-andrew@lunn.ch>
Cc: Woojung Huh <Woojung.Huh@microchip.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:35451 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750991AbdFCSA6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 3 Jun 2017 14:00:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Most of the PHYs supported by the SMSC driver have a counter of symbol
errors. This is 16 bit wide and wraps around when it reaches its
maximum value.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
Reviewed-By: Woojung Huh <Woojung.Huh@microchip.com>
---
v2:
	Align members
	Add Reviewed-by's
---
 drivers/net/phy/smsc.c | 72 ++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 72 insertions(+)

diff --git a/drivers/net/phy/smsc.c b/drivers/net/phy/smsc.c
index 67c9f2b26c8e..1b8204be064c 100644
--- a/drivers/net/phy/smsc.c
+++ b/drivers/net/phy/smsc.c
@@ -25,6 +25,16 @@
 #include <linux/netdevice.h>
 #include <linux/smscphy.h>
 
+struct smsc_hw_stat {
+	const char *string;
+	u8 reg;
+	u8 bits;
+};
+
+static struct smsc_hw_stat smsc_hw_stats[] = {
+	{ "phy_symbol_errors", 26, 16},
+};
+
 struct smsc_phy_priv {
 	bool energy_enable;
 };
@@ -143,6 +153,48 @@ static int lan87xx_read_status(struct phy_device *phydev)
 	return err;
 }
 
+static int smsc_get_sset_count(struct phy_device *phydev)
+{
+	return ARRAY_SIZE(smsc_hw_stats);
+}
+
+static void smsc_get_strings(struct phy_device *phydev, u8 *data)
+{
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(smsc_hw_stats); i++) {
+		memcpy(data + i * ETH_GSTRING_LEN,
+		       smsc_hw_stats[i].string, ETH_GSTRING_LEN);
+	}
+}
+
+#ifndef UINT64_MAX
+#define UINT64_MAX              (u64)(~((u64)0))
+#endif
+static u64 smsc_get_stat(struct phy_device *phydev, int i)
+{
+	struct smsc_hw_stat stat = smsc_hw_stats[i];
+	int val;
+	u64 ret;
+
+	val = phy_read(phydev, stat.reg);
+	if (val < 0)
+		ret = UINT64_MAX;
+	else
+		ret = val;
+
+	return ret;
+}
+
+static void smsc_get_stats(struct phy_device *phydev,
+			   struct ethtool_stats *stats, u64 *data)
+{
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(smsc_hw_stats); i++)
+		data[i] = smsc_get_stat(phydev, i);
+}
+
 static int smsc_phy_probe(struct phy_device *phydev)
 {
 	struct device *dev = &phydev->mdio.dev;
@@ -206,6 +258,11 @@ static struct phy_driver smsc_phy_driver[] = {
 	.ack_interrupt	= smsc_phy_ack_interrupt,
 	.config_intr	= smsc_phy_config_intr,
 
+	/* Statistics */
+	.get_sset_count = smsc_get_sset_count,
+	.get_strings	= smsc_get_strings,
+	.get_stats	= smsc_get_stats,
+
 	.suspend	= genphy_suspend,
 	.resume		= genphy_resume,
 }, {
@@ -228,6 +285,11 @@ static struct phy_driver smsc_phy_driver[] = {
 	.ack_interrupt	= smsc_phy_ack_interrupt,
 	.config_intr	= smsc_phy_config_intr,
 
+	/* Statistics */
+	.get_sset_count = smsc_get_sset_count,
+	.get_strings	= smsc_get_strings,
+	.get_stats	= smsc_get_stats,
+
 	.suspend	= genphy_suspend,
 	.resume		= genphy_resume,
 }, {
@@ -271,6 +333,11 @@ static struct phy_driver smsc_phy_driver[] = {
 	.ack_interrupt	= smsc_phy_ack_interrupt,
 	.config_intr	= smsc_phy_config_intr,
 
+	/* Statistics */
+	.get_sset_count = smsc_get_sset_count,
+	.get_strings	= smsc_get_strings,
+	.get_stats	= smsc_get_stats,
+
 	.suspend	= genphy_suspend,
 	.resume		= genphy_resume,
 }, {
@@ -293,6 +360,11 @@ static struct phy_driver smsc_phy_driver[] = {
 	.ack_interrupt	= smsc_phy_ack_interrupt,
 	.config_intr	= smsc_phy_config_intr,
 
+	/* Statistics */
+	.get_sset_count = smsc_get_sset_count,
+	.get_strings	= smsc_get_strings,
+	.get_stats	= smsc_get_stats,
+
 	.suspend	= genphy_suspend,
 	.resume		= genphy_resume,
 } };
-- 
2.11.0

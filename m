From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCHv2 net-next 3/3] phy: micrel: Add ethtool statistics counters
Date: Sun, 27 Dec 2015 12:58:28 +0100
Message-ID: <1451217508-22276-4-git-send-email-andrew@lunn.ch>
References: <1451217508-22276-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:50851 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753873AbbL0L6p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Dec 2015 06:58:45 -0500
In-Reply-To: <1451217508-22276-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PHY counters receiver errors and errors while idle.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/phy/micrel.c | 96 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 96 insertions(+)

diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index e13ad6cdcc22..1a6048a8c29d 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -73,6 +73,17 @@
 
 #define PS_TO_REG				200
 
+struct kszphy_hw_stat {
+	const char *string;
+	u8 reg;
+	u8 bits;
+};
+
+static struct kszphy_hw_stat kszphy_hw_stats[] = {
+	{ "phy_receive_errors", 21, 16},
+	{ "phy_idle_errors", 10, 8 },
+};
+
 struct kszphy_type {
 	u32 led_mode_reg;
 	u16 interrupt_level_mask;
@@ -86,6 +97,7 @@ struct kszphy_priv {
 	int led_mode;
 	bool rmii_ref_clk_sel;
 	bool rmii_ref_clk_sel_val;
+	u64 stats[ARRAY_SIZE(kszphy_hw_stats)];
 };
 
 static const struct kszphy_type ksz8021_type = {
@@ -569,6 +581,51 @@ ksz9021_wr_mmd_phyreg(struct phy_device *phydev, int ptrad, int devnum,
 {
 }
 
+static int kszphy_get_sset_count(struct phy_device *phydev)
+{
+	return ARRAY_SIZE(kszphy_hw_stats);
+}
+
+static void kszphy_get_strings(struct phy_device *phydev, u8 *data)
+{
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(kszphy_hw_stats); i++) {
+		memcpy(data + i * ETH_GSTRING_LEN,
+		       kszphy_hw_stats[i].string, ETH_GSTRING_LEN);
+	}
+}
+
+#ifndef UINT64_MAX
+#define UINT64_MAX              (u64)(~((u64)0))
+#endif
+static u64 kszphy_get_stat(struct phy_device *phydev, int i)
+{
+	struct kszphy_hw_stat stat = kszphy_hw_stats[i];
+	struct kszphy_priv *priv = phydev->priv;
+	u64 val;
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
+	return val;
+}
+
+static void kszphy_get_stats(struct phy_device *phydev,
+			     struct ethtool_stats *stats, u64 *data)
+{
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(kszphy_hw_stats); i++)
+		data[i] = kszphy_get_stat(phydev, i);
+}
+
 static int kszphy_probe(struct phy_device *phydev)
 {
 	const struct kszphy_type *type = phydev->drv->driver_data;
@@ -642,6 +699,9 @@ static struct phy_driver ksphy_driver[] = {
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= kszphy_ack_interrupt,
 	.config_intr	= kszphy_config_intr,
+	.get_sset_count = kszphy_get_sset_count,
+	.get_strings	= kszphy_get_strings,
+	.get_stats	= kszphy_get_stats,
 	.suspend	= genphy_suspend,
 	.resume		= genphy_resume,
 	.driver		= { .owner = THIS_MODULE,},
@@ -659,6 +719,9 @@ static struct phy_driver ksphy_driver[] = {
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= kszphy_ack_interrupt,
 	.config_intr	= kszphy_config_intr,
+	.get_sset_count = kszphy_get_sset_count,
+	.get_strings	= kszphy_get_strings,
+	.get_stats	= kszphy_get_stats,
 	.suspend	= genphy_suspend,
 	.resume		= genphy_resume,
 	.driver		= { .owner = THIS_MODULE,},
@@ -676,6 +739,9 @@ static struct phy_driver ksphy_driver[] = {
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= kszphy_ack_interrupt,
 	.config_intr	= kszphy_config_intr,
+	.get_sset_count = kszphy_get_sset_count,
+	.get_strings	= kszphy_get_strings,
+	.get_stats	= kszphy_get_stats,
 	.suspend	= genphy_suspend,
 	.resume		= genphy_resume,
 	.driver		= { .owner = THIS_MODULE,},
@@ -693,6 +759,9 @@ static struct phy_driver ksphy_driver[] = {
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= kszphy_ack_interrupt,
 	.config_intr	= kszphy_config_intr,
+	.get_sset_count = kszphy_get_sset_count,
+	.get_strings	= kszphy_get_strings,
+	.get_stats	= kszphy_get_stats,
 	.suspend	= genphy_suspend,
 	.resume		= genphy_resume,
 	.driver		= { .owner = THIS_MODULE,},
@@ -710,6 +779,9 @@ static struct phy_driver ksphy_driver[] = {
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= kszphy_ack_interrupt,
 	.config_intr	= kszphy_config_intr,
+	.get_sset_count = kszphy_get_sset_count,
+	.get_strings	= kszphy_get_strings,
+	.get_stats	= kszphy_get_stats,
 	.suspend	= genphy_suspend,
 	.resume		= genphy_resume,
 	.driver		= { .owner = THIS_MODULE,},
@@ -727,6 +799,9 @@ static struct phy_driver ksphy_driver[] = {
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= kszphy_ack_interrupt,
 	.config_intr	= kszphy_config_intr,
+	.get_sset_count = kszphy_get_sset_count,
+	.get_strings	= kszphy_get_strings,
+	.get_stats	= kszphy_get_stats,
 	.suspend	= genphy_suspend,
 	.resume		= genphy_resume,
 	.driver		= { .owner = THIS_MODULE,},
@@ -743,6 +818,9 @@ static struct phy_driver ksphy_driver[] = {
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= kszphy_ack_interrupt,
 	.config_intr	= kszphy_config_intr,
+	.get_sset_count = kszphy_get_sset_count,
+	.get_strings	= kszphy_get_strings,
+	.get_stats	= kszphy_get_stats,
 	.suspend	= genphy_suspend,
 	.resume		= genphy_resume,
 	.driver		= { .owner = THIS_MODULE,},
@@ -759,6 +837,9 @@ static struct phy_driver ksphy_driver[] = {
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= kszphy_ack_interrupt,
 	.config_intr	= kszphy_config_intr,
+	.get_sset_count = kszphy_get_sset_count,
+	.get_strings	= kszphy_get_strings,
+	.get_stats	= kszphy_get_stats,
 	.suspend	= genphy_suspend,
 	.resume		= genphy_resume,
 	.driver		= { .owner = THIS_MODULE,},
@@ -773,6 +854,9 @@ static struct phy_driver ksphy_driver[] = {
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= kszphy_ack_interrupt,
 	.config_intr	= kszphy_config_intr,
+	.get_sset_count = kszphy_get_sset_count,
+	.get_strings	= kszphy_get_strings,
+	.get_stats	= kszphy_get_stats,
 	.suspend	= genphy_suspend,
 	.resume		= genphy_resume,
 	.driver		= { .owner = THIS_MODULE,},
@@ -788,6 +872,9 @@ static struct phy_driver ksphy_driver[] = {
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= kszphy_ack_interrupt,
 	.config_intr	= kszphy_config_intr,
+	.get_sset_count = kszphy_get_sset_count,
+	.get_strings	= kszphy_get_strings,
+	.get_stats	= kszphy_get_stats,
 	.suspend	= genphy_suspend,
 	.resume		= genphy_resume,
 	.read_mmd_indirect = ksz9021_rd_mmd_phyreg,
@@ -805,6 +892,9 @@ static struct phy_driver ksphy_driver[] = {
 	.read_status	= ksz9031_read_status,
 	.ack_interrupt	= kszphy_ack_interrupt,
 	.config_intr	= kszphy_config_intr,
+	.get_sset_count = kszphy_get_sset_count,
+	.get_strings	= kszphy_get_strings,
+	.get_stats	= kszphy_get_stats,
 	.suspend	= genphy_suspend,
 	.resume		= genphy_resume,
 	.driver		= { .owner = THIS_MODULE, },
@@ -817,6 +907,9 @@ static struct phy_driver ksphy_driver[] = {
 	.config_init	= kszphy_config_init,
 	.config_aneg	= ksz8873mll_config_aneg,
 	.read_status	= ksz8873mll_read_status,
+	.get_sset_count = kszphy_get_sset_count,
+	.get_strings	= kszphy_get_strings,
+	.get_stats	= kszphy_get_stats,
 	.suspend	= genphy_suspend,
 	.resume		= genphy_resume,
 	.driver		= { .owner = THIS_MODULE, },
@@ -829,6 +922,9 @@ static struct phy_driver ksphy_driver[] = {
 	.config_init	= kszphy_config_init,
 	.config_aneg	= genphy_config_aneg,
 	.read_status	= genphy_read_status,
+	.get_sset_count = kszphy_get_sset_count,
+	.get_strings	= kszphy_get_strings,
+	.get_stats	= kszphy_get_stats,
 	.suspend	= genphy_suspend,
 	.resume		= genphy_resume,
 	.driver		= { .owner = THIS_MODULE, },
-- 
2.6.4

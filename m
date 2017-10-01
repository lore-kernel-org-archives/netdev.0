From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [RFC net-next 3/5] net: dsa: b53: Add support for LAG
Date: Sun,  1 Oct 2017 12:46:37 -0700
Message-ID: <20171001194639.8647-4-f.fainelli@gmail.com>
References: <20171001194639.8647-1-f.fainelli@gmail.com>
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        jiri@resnulli.us, idosch@mellanox.com, Woojung.Huh@microchip.com,
        john@phrozen.org, sean.wang@mediatek.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:38750 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751355AbdJATqx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Oct 2017 15:46:53 -0400
Received: by mail-oi0-f67.google.com with SMTP id s145so2115553oie.5
        for <netdev@vger.kernel.org>; Sun, 01 Oct 2017 12:46:53 -0700 (PDT)
In-Reply-To: <20171001194639.8647-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for LAG in the b53 driver by implementing the port_lag_join,
port_lag_leave and port_lag_member operations. port_lag_change is not supported
since the HW does not let us change anyting regarding tx_enabled or not.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/b53/b53_common.c | 94 +++++++++++++++++++++++++++++++++++++++-
 drivers/net/dsa/b53/b53_priv.h   |  6 +++
 2 files changed, 99 insertions(+), 1 deletion(-)

diff --git a/drivers/net/dsa/b53/b53_common.c b/drivers/net/dsa/b53/b53_common.c
index d4ce092def83..e9903947f050 100644
--- a/drivers/net/dsa/b53/b53_common.c
+++ b/drivers/net/dsa/b53/b53_common.c
@@ -1603,6 +1603,58 @@ int b53_set_mac_eee(struct dsa_switch *ds, int port, struct ethtool_eee *e)
 }
 EXPORT_SYMBOL(b53_set_mac_eee);
 
+bool b53_lag_member(struct dsa_switch *ds, int port, u8 lag_id)
+{
+	struct b53_device *dev = ds->priv;
+	u16 reg;
+
+	b53_read16(dev, B53_TRUNK_PAGE, B53_MAC_TRUNK_GROUP(lag_id), &reg);
+
+	return !!(BIT(port) & reg);
+}
+EXPORT_SYMBOL(b53_lag_member);
+
+int b53_lag_join(struct dsa_switch *ds, int port, u8 lag_id)
+{
+	struct b53_device *dev = ds->priv;
+	u8 trunk_ctl;
+	u16 lag;
+
+	/* Program this port and the CPU port in this trunking group */
+	b53_read16(dev, B53_TRUNK_PAGE, B53_MAC_TRUNK_GROUP(lag_id), &lag);
+	lag |= BIT(port);
+	b53_write16(dev, B53_TRUNK_PAGE, B53_MAC_TRUNK_GROUP(lag_id), lag);
+
+	/* Enable MAC DA,SA hashing, enable trunking */
+	b53_read8(dev, B53_TRUNK_PAGE, B53_MAC_TRUNK_CTRL, &trunk_ctl);
+	trunk_ctl &= ~TRK_HASH_IDX_MASK;
+	trunk_ctl |= MAC_BASE_TRNK_EN;
+	b53_write8(dev, B53_TRUNK_PAGE, B53_MAC_TRUNK_CTRL, trunk_ctl);
+
+	return 0;
+}
+EXPORT_SYMBOL(b53_lag_join);
+
+void b53_lag_leave(struct dsa_switch *ds, int port, u8 lag_id, bool lag_disable)
+{
+	struct b53_device *dev = ds->priv;
+	u8 trunk_ctl;
+	u16 lag;
+
+	/* Remove this port from the trunking group */
+	b53_read16(dev, B53_TRUNK_PAGE, B53_MAC_TRUNK_GROUP(lag_id), &lag);
+	lag &= ~BIT(port);
+	b53_write16(dev, B53_TRUNK_PAGE, B53_MAC_TRUNK_GROUP(lag_id), lag);
+
+	/* Disable trunking if the lag group is being removed */
+	if (lag_disable) {
+		b53_read8(dev, B53_TRUNK_PAGE, B53_MAC_TRUNK_CTRL, &trunk_ctl);
+		trunk_ctl &= ~(TRK_HASH_IDX_MASK | MAC_BASE_TRNK_EN);
+		b53_write8(dev, B53_TRUNK_PAGE, B53_MAC_TRUNK_CTRL, trunk_ctl);
+	}
+}
+EXPORT_SYMBOL(b53_lag_leave);
+
 static const struct dsa_switch_ops b53_switch_ops = {
 	.get_tag_protocol	= b53_get_tag_protocol,
 	.setup			= b53_setup,
@@ -1629,6 +1681,9 @@ static const struct dsa_switch_ops b53_switch_ops = {
 	.port_fdb_del		= b53_fdb_del,
 	.port_mirror_add	= b53_mirror_add,
 	.port_mirror_del	= b53_mirror_del,
+	.port_lag_member	= b53_lag_member,
+	.port_lag_join		= b53_lag_join,
+	.port_lag_leave		= b53_lag_leave,
 };
 
 struct b53_chip_data {
@@ -1642,6 +1697,8 @@ struct b53_chip_data {
 	u8 duplex_reg;
 	u8 jumbo_pm_reg;
 	u8 jumbo_size_reg;
+	unsigned int num_lags;
+	unsigned int max_lag_members;
 };
 
 #define B53_VTA_REGS	\
@@ -1681,6 +1738,8 @@ static const struct b53_chip_data b53_switch_chips[] = {
 		.duplex_reg = B53_DUPLEX_STAT_GE,
 		.jumbo_pm_reg = B53_JUMBO_PORT_MASK,
 		.jumbo_size_reg = B53_JUMBO_MAX_SIZE,
+		.num_lags = 2,
+		.max_lag_members = 4,
 	},
 	{
 		.chip_id = BCM5397_DEVICE_ID,
@@ -1693,6 +1752,8 @@ static const struct b53_chip_data b53_switch_chips[] = {
 		.duplex_reg = B53_DUPLEX_STAT_GE,
 		.jumbo_pm_reg = B53_JUMBO_PORT_MASK,
 		.jumbo_size_reg = B53_JUMBO_MAX_SIZE,
+		.num_lags = 2,
+		.max_lag_members = 4,
 	},
 	{
 		.chip_id = BCM5398_DEVICE_ID,
@@ -1705,6 +1766,8 @@ static const struct b53_chip_data b53_switch_chips[] = {
 		.duplex_reg = B53_DUPLEX_STAT_GE,
 		.jumbo_pm_reg = B53_JUMBO_PORT_MASK,
 		.jumbo_size_reg = B53_JUMBO_MAX_SIZE,
+		.num_lags = 2,
+		.max_lag_members = 4,
 	},
 	{
 		.chip_id = BCM53115_DEVICE_ID,
@@ -1717,6 +1780,8 @@ static const struct b53_chip_data b53_switch_chips[] = {
 		.duplex_reg = B53_DUPLEX_STAT_GE,
 		.jumbo_pm_reg = B53_JUMBO_PORT_MASK,
 		.jumbo_size_reg = B53_JUMBO_MAX_SIZE,
+		.num_lags = 2,
+		.max_lag_members = 4,
 	},
 	{
 		.chip_id = BCM53125_DEVICE_ID,
@@ -1729,6 +1794,8 @@ static const struct b53_chip_data b53_switch_chips[] = {
 		.duplex_reg = B53_DUPLEX_STAT_GE,
 		.jumbo_pm_reg = B53_JUMBO_PORT_MASK,
 		.jumbo_size_reg = B53_JUMBO_MAX_SIZE,
+		.num_lags = 2,
+		.max_lag_members = 4,
 	},
 	{
 		.chip_id = BCM53128_DEVICE_ID,
@@ -1741,6 +1808,8 @@ static const struct b53_chip_data b53_switch_chips[] = {
 		.duplex_reg = B53_DUPLEX_STAT_GE,
 		.jumbo_pm_reg = B53_JUMBO_PORT_MASK,
 		.jumbo_size_reg = B53_JUMBO_MAX_SIZE,
+		.num_lags = 2,
+		.max_lag_members = 4,
 	},
 	{
 		.chip_id = BCM63XX_DEVICE_ID,
@@ -1753,6 +1822,8 @@ static const struct b53_chip_data b53_switch_chips[] = {
 		.duplex_reg = B53_DUPLEX_STAT_63XX,
 		.jumbo_pm_reg = B53_JUMBO_PORT_MASK_63XX,
 		.jumbo_size_reg = B53_JUMBO_MAX_SIZE_63XX,
+		.num_lags = 2,
+		.max_lag_members = 4,
 	},
 	{
 		.chip_id = BCM53010_DEVICE_ID,
@@ -1765,6 +1836,8 @@ static const struct b53_chip_data b53_switch_chips[] = {
 		.duplex_reg = B53_DUPLEX_STAT_GE,
 		.jumbo_pm_reg = B53_JUMBO_PORT_MASK,
 		.jumbo_size_reg = B53_JUMBO_MAX_SIZE,
+		.num_lags = 2,
+		.max_lag_members = 4,
 	},
 	{
 		.chip_id = BCM53011_DEVICE_ID,
@@ -1777,6 +1850,8 @@ static const struct b53_chip_data b53_switch_chips[] = {
 		.duplex_reg = B53_DUPLEX_STAT_GE,
 		.jumbo_pm_reg = B53_JUMBO_PORT_MASK,
 		.jumbo_size_reg = B53_JUMBO_MAX_SIZE,
+		.num_lags = 2,
+		.max_lag_members = 4,
 	},
 	{
 		.chip_id = BCM53012_DEVICE_ID,
@@ -1789,6 +1864,8 @@ static const struct b53_chip_data b53_switch_chips[] = {
 		.duplex_reg = B53_DUPLEX_STAT_GE,
 		.jumbo_pm_reg = B53_JUMBO_PORT_MASK,
 		.jumbo_size_reg = B53_JUMBO_MAX_SIZE,
+		.num_lags = 2,
+		.max_lag_members = 4,
 	},
 	{
 		.chip_id = BCM53018_DEVICE_ID,
@@ -1801,6 +1878,8 @@ static const struct b53_chip_data b53_switch_chips[] = {
 		.duplex_reg = B53_DUPLEX_STAT_GE,
 		.jumbo_pm_reg = B53_JUMBO_PORT_MASK,
 		.jumbo_size_reg = B53_JUMBO_MAX_SIZE,
+		.num_lags = 2,
+		.max_lag_members = 4,
 	},
 	{
 		.chip_id = BCM53019_DEVICE_ID,
@@ -1813,6 +1892,8 @@ static const struct b53_chip_data b53_switch_chips[] = {
 		.duplex_reg = B53_DUPLEX_STAT_GE,
 		.jumbo_pm_reg = B53_JUMBO_PORT_MASK,
 		.jumbo_size_reg = B53_JUMBO_MAX_SIZE,
+		.num_lags = 2,
+		.max_lag_members = 4,
 	},
 	{
 		.chip_id = BCM58XX_DEVICE_ID,
@@ -1825,6 +1906,8 @@ static const struct b53_chip_data b53_switch_chips[] = {
 		.duplex_reg = B53_DUPLEX_STAT_GE,
 		.jumbo_pm_reg = B53_JUMBO_PORT_MASK,
 		.jumbo_size_reg = B53_JUMBO_MAX_SIZE,
+		.num_lags = 2,
+		.max_lag_members = 4,
 	},
 	{
 		.chip_id = BCM7445_DEVICE_ID,
@@ -1837,6 +1920,8 @@ static const struct b53_chip_data b53_switch_chips[] = {
 		.duplex_reg = B53_DUPLEX_STAT_GE,
 		.jumbo_pm_reg = B53_JUMBO_PORT_MASK,
 		.jumbo_size_reg = B53_JUMBO_MAX_SIZE,
+		.num_lags = 2,
+		.max_lag_members = 4,
 	},
 	{
 		.chip_id = BCM7278_DEVICE_ID,
@@ -1849,11 +1934,14 @@ static const struct b53_chip_data b53_switch_chips[] = {
 		.duplex_reg = B53_DUPLEX_STAT_GE,
 		.jumbo_pm_reg = B53_JUMBO_PORT_MASK,
 		.jumbo_size_reg = B53_JUMBO_MAX_SIZE,
+		.num_lags = 2,
+		.max_lag_members = 4,
 	},
 };
 
 static int b53_switch_init(struct b53_device *dev)
 {
+	struct dsa_switch *ds = dev->ds;
 	unsigned int i;
 	int ret;
 
@@ -1872,6 +1960,8 @@ static int b53_switch_init(struct b53_device *dev)
 			dev->cpu_port = chip->cpu_port;
 			dev->num_vlans = chip->vlans;
 			dev->num_arl_entries = chip->arl_entries;
+			dev->num_lags = chip->num_lags;
+			dev->max_lag_members = chip->max_lag_members;
 			break;
 		}
 	}
@@ -1933,7 +2023,9 @@ static int b53_switch_init(struct b53_device *dev)
 			return ret;
 	}
 
-	return 0;
+	ds->max_lag_members = dev->max_lag_members;
+
+	return dsa_switch_alloc_lags(ds, dev->num_lags);
 }
 
 struct b53_device *b53_switch_alloc(struct device *base,
diff --git a/drivers/net/dsa/b53/b53_priv.h b/drivers/net/dsa/b53/b53_priv.h
index 603c66d240d8..0f48184c9b54 100644
--- a/drivers/net/dsa/b53/b53_priv.h
+++ b/drivers/net/dsa/b53/b53_priv.h
@@ -118,6 +118,9 @@ struct b53_device {
 	struct b53_vlan *vlans;
 	unsigned int num_ports;
 	struct b53_port *ports;
+
+	unsigned int num_lags;
+	unsigned int max_lag_members;
 };
 
 #define b53_for_each_port(dev, i) \
@@ -318,5 +321,8 @@ void b53_eee_enable_set(struct dsa_switch *ds, int port, bool enable);
 int b53_eee_init(struct dsa_switch *ds, int port, struct phy_device *phy);
 int b53_get_mac_eee(struct dsa_switch *ds, int port, struct ethtool_eee *e);
 int b53_set_mac_eee(struct dsa_switch *ds, int port, struct ethtool_eee *e);
+bool b53_lag_member(struct dsa_switch *ds, int port, u8 lag_id);
+int b53_lag_join(struct dsa_switch *ds, int port, u8 lag_id);
+void b53_lag_leave(struct dsa_switch *ds, int port, u8 lag_id, bool lag_disable);
 
 #endif
-- 
2.11.0

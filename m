From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH v2 09/15] net: dsa: Add support for switch EEPROM access
Date: Sun, 26 Oct 2014 09:52:39 -0700
Message-ID: <1414342365-27191-10-git-send-email-linux@roeck-us.net>
References: <1414342365-27191-1-git-send-email-linux@roeck-us.net>
Cc: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>, linux-kernel@vger.kernel.org,
	Guenter Roeck <linux@roeck-us.net>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1414342365-27191-1-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On some chips it is possible to access the switch eeprom.
Add infrastructure support for it.

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
v2:
- Add support for configuring switch EEPROM size through platform data
  or devicetree data
- Do not compare new pointers against NULL
- Check if get_eeprom pointer is set before calling it

 include/net/dsa.h | 10 ++++++++++
 net/dsa/dsa.c     |  4 ++++
 net/dsa/slave.c   | 41 +++++++++++++++++++++++++++++++++++++++++
 3 files changed, 55 insertions(+)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 55e75e7..37856a2 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -38,6 +38,9 @@ struct dsa_chip_data {
 	struct device	*host_dev;
 	int		sw_addr;
 
+	/* set to size of eeprom if supported by the switch */
+	int		eeprom_len;
+
 	/* Device tree node pointer for this specific switch chip
 	 * used during switch setup in case additional properties
 	 * and resources needs to be used
@@ -258,6 +261,13 @@ struct dsa_switch_driver {
 	int	(*set_temp_limit)(struct dsa_switch *ds, int temp);
 	int	(*get_temp_alarm)(struct dsa_switch *ds, bool *alarm);
 #endif
+
+	/* EEPROM access */
+	int	(*get_eeprom_len)(struct dsa_switch *ds);
+	int	(*get_eeprom)(struct dsa_switch *ds,
+			      struct ethtool_eeprom *eeprom, u8 *data);
+	int	(*set_eeprom)(struct dsa_switch *ds,
+			      struct ethtool_eeprom *eeprom, u8 *data);
 };
 
 void register_switch_driver(struct dsa_switch_driver *type);
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 5edbbca..1c1b925 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -575,6 +575,7 @@ static int dsa_of_probe(struct platform_device *pdev)
 	const char *port_name;
 	int chip_index, port_index;
 	const unsigned int *sw_addr, *port_reg;
+	u32 eeprom_length;
 	int ret;
 
 	mdio = of_parse_phandle(np, "dsa,mii-bus", 0);
@@ -603,6 +604,9 @@ static int dsa_of_probe(struct platform_device *pdev)
 	if (pd->nr_chips > DSA_MAX_SWITCHES)
 		pd->nr_chips = DSA_MAX_SWITCHES;
 
+	if (!of_property_read_u32(np, "eeprom-length", &eeprom_length))
+		pd->eeprom_length = eeprom_length;
+
 	pd->chip = kzalloc(pd->nr_chips * sizeof(struct dsa_chip_data),
 			GFP_KERNEL);
 	if (!pd->chip) {
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 6d18174..ff2fbe7 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -271,6 +271,44 @@ static u32 dsa_slave_get_link(struct net_device *dev)
 	return -EOPNOTSUPP;
 }
 
+static int dsa_slave_get_eeprom_len(struct net_device *dev)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_switch *ds = p->parent;
+
+	if (ds->pd->eeprom_len)
+		return ds->pd->eeprom_len;
+
+	if (ds->drv->get_eeprom_len)
+		return ds->drv->get_eeprom_len(ds);
+
+	return 0;
+}
+
+static int dsa_slave_get_eeprom(struct net_device *dev,
+				struct ethtool_eeprom *eeprom, u8 *data)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_switch *ds = p->parent;
+
+	if (ds->drv->get_eeprom)
+		return ds->drv->get_eeprom(ds, eeprom, data);
+
+	return -EOPNOTSUPP;
+}
+
+static int dsa_slave_set_eeprom(struct net_device *dev,
+				struct ethtool_eeprom *eeprom, u8 *data)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_switch *ds = p->parent;
+
+	if (ds->drv->set_eeprom)
+		return ds->drv->set_eeprom(ds, eeprom, data);
+
+	return -EOPNOTSUPP;
+}
+
 static void dsa_slave_get_strings(struct net_device *dev,
 				  uint32_t stringset, uint8_t *data)
 {
@@ -387,6 +425,9 @@ static const struct ethtool_ops dsa_slave_ethtool_ops = {
 	.get_drvinfo		= dsa_slave_get_drvinfo,
 	.nway_reset		= dsa_slave_nway_reset,
 	.get_link		= dsa_slave_get_link,
+	.get_eeprom_len		= dsa_slave_get_eeprom_len,
+	.get_eeprom		= dsa_slave_get_eeprom,
+	.set_eeprom		= dsa_slave_set_eeprom,
 	.get_strings		= dsa_slave_get_strings,
 	.get_ethtool_stats	= dsa_slave_get_ethtool_stats,
 	.get_sset_count		= dsa_slave_get_sset_count,
-- 
1.9.1

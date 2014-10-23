From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH 11/14] net: dsa: Add support for reading switch registers with ethtool
Date: Wed, 22 Oct 2014 21:03:19 -0700
Message-ID: <1414037002-25528-12-git-send-email-linux@roeck-us.net>
References: <1414037002-25528-1-git-send-email-linux@roeck-us.net>
Cc: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>, linux-kernel@vger.kernel.org,
	Guenter Roeck <linux@roeck-us.net>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1414037002-25528-1-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add support for reading switch registers with 'ethtool -d'.

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 include/net/dsa.h |  7 +++++++
 net/dsa/slave.c   | 22 ++++++++++++++++++++++
 2 files changed, 29 insertions(+)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 73146b7..edc5e71 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -255,6 +255,13 @@ struct dsa_switch_driver {
 			      struct ethtool_eeprom *eeprom, u8 *data);
 	int	(*set_eeprom)(struct dsa_switch *ds,
 			      struct ethtool_eeprom *eeprom, u8 *data);
+
+	/*
+	 * Register access.
+	 */
+	int	(*get_regs_len)(struct dsa_switch *ds, int port);
+	void	(*get_regs)(struct dsa_switch *ds, int port,
+			    struct ethtool_regs *regs, void *p);
 };
 
 void register_switch_driver(struct dsa_switch_driver *type);
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index a54ee43..e988d07 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -249,6 +249,26 @@ static void dsa_slave_get_drvinfo(struct net_device *dev,
 	strlcpy(drvinfo->bus_info, "platform", sizeof(drvinfo->bus_info));
 }
 
+static int dsa_slave_get_regs_len(struct net_device *dev)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_switch *ds = p->parent;
+
+	if (ds->drv->get_regs_len != NULL)
+		return ds->drv->get_regs_len(ds, p->port);
+
+	return -EOPNOTSUPP;
+}
+
+static void
+dsa_slave_get_regs(struct net_device *dev, struct ethtool_regs *regs, void *_p)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_switch *ds = p->parent;
+
+	ds->drv->get_regs(ds, p->port, regs, _p);
+}
+
 static int dsa_slave_nway_reset(struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
@@ -420,6 +440,8 @@ static const struct ethtool_ops dsa_slave_ethtool_ops = {
 	.get_settings		= dsa_slave_get_settings,
 	.set_settings		= dsa_slave_set_settings,
 	.get_drvinfo		= dsa_slave_get_drvinfo,
+	.get_regs_len		= dsa_slave_get_regs_len,
+	.get_regs		= dsa_slave_get_regs,
 	.nway_reset		= dsa_slave_nway_reset,
 	.get_link		= dsa_slave_get_link,
 	.get_eeprom_len		= dsa_slave_get_eeprom_len,
-- 
1.9.1

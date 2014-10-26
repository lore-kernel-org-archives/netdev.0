From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH v2 12/15] net: dsa: Add support for reading switch registers with ethtool
Date: Sun, 26 Oct 2014 09:52:42 -0700
Message-ID: <1414342365-27191-13-git-send-email-linux@roeck-us.net>
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

Add support for reading switch registers with 'ethtool -d'.

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
v2:
- Do not compare new function pointers against NULL
- Check if get_regs is set before calling it

 include/net/dsa.h |  7 +++++++
 net/dsa/slave.c   | 23 +++++++++++++++++++++++
 2 files changed, 30 insertions(+)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 37856a2..ed3c34b 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -268,6 +268,13 @@ struct dsa_switch_driver {
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
index ff2fbe7..474f296 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -249,6 +249,27 @@ static void dsa_slave_get_drvinfo(struct net_device *dev,
 	strlcpy(drvinfo->bus_info, "platform", sizeof(drvinfo->bus_info));
 }
 
+static int dsa_slave_get_regs_len(struct net_device *dev)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_switch *ds = p->parent;
+
+	if (ds->drv->get_regs_len)
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
+	if (ds->drv->get_regs)
+		ds->drv->get_regs(ds, p->port, regs, _p);
+}
+
 static int dsa_slave_nway_reset(struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
@@ -423,6 +444,8 @@ static const struct ethtool_ops dsa_slave_ethtool_ops = {
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

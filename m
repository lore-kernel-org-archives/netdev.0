From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH 09/14] net: dsa: Add support for switch EEPROM access
Date: Wed, 22 Oct 2014 21:03:17 -0700
Message-ID: <1414037002-25528-10-git-send-email-linux@roeck-us.net>
References: <1414037002-25528-1-git-send-email-linux@roeck-us.net>
Cc: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>, linux-kernel@vger.kernel.org,
	Guenter Roeck <linux@roeck-us.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:49464 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751410AbaJWEDs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2014 00:03:48 -0400
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1Xh9cq-002c18-BE
	for netdev@vger.kernel.org; Thu, 23 Oct 2014 04:03:48 +0000
In-Reply-To: <1414037002-25528-1-git-send-email-linux@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On some chips it is possible to access the switch eeprom.
Add infrastructure support for it.

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 include/net/dsa.h |  7 +++++++
 net/dsa/slave.c   | 38 ++++++++++++++++++++++++++++++++++++++
 2 files changed, 45 insertions(+)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index d8b3057..73146b7 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -248,6 +248,13 @@ struct dsa_switch_driver {
 	int	(*get_temp_limit)(struct dsa_switch *ds, int *temp);
 	int	(*set_temp_limit)(struct dsa_switch *ds, int temp);
 	int	(*get_temp_alarm)(struct dsa_switch *ds, bool *alarm);
+
+	/* EEPROM access */
+	int	(*get_eeprom_len)(struct dsa_switch *ds);
+	int	(*get_eeprom)(struct dsa_switch *ds,
+			      struct ethtool_eeprom *eeprom, u8 *data);
+	int	(*set_eeprom)(struct dsa_switch *ds,
+			      struct ethtool_eeprom *eeprom, u8 *data);
 };
 
 void register_switch_driver(struct dsa_switch_driver *type);
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 6d18174..a54ee43 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -271,6 +271,41 @@ static u32 dsa_slave_get_link(struct net_device *dev)
 	return -EOPNOTSUPP;
 }
 
+static int dsa_slave_get_eeprom_len(struct net_device *dev)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_switch *ds = p->parent;
+
+	if (ds->drv->get_eeprom_len != NULL)
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
+	if (ds->drv->get_eeprom != NULL)
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
+	if (ds->drv->set_eeprom != NULL)
+		return ds->drv->set_eeprom(ds, eeprom, data);
+
+	return -EOPNOTSUPP;
+}
+
 static void dsa_slave_get_strings(struct net_device *dev,
 				  uint32_t stringset, uint8_t *data)
 {
@@ -387,6 +422,9 @@ static const struct ethtool_ops dsa_slave_ethtool_ops = {
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

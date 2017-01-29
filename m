From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 1/4] net: dsa: Hook {get,set}_rxnfc ethtool operations
Date: Sat, 28 Jan 2017 19:13:22 -0800
Message-ID: <20170129031325.21911-2-f.fainelli@gmail.com>
References: <20170129031325.21911-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, cphealy@gmail.com,
        vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:34128 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752148AbdA2FqD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Jan 2017 00:46:03 -0500
Received: by mail-oi0-f68.google.com with SMTP id w144so23664908oiw.1
        for <netdev@vger.kernel.org>; Sat, 28 Jan 2017 21:45:07 -0800 (PST)
In-Reply-To: <20170129031325.21911-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for adding support for CFP/TCAMP in the bcm_sf2 driver add the
plumbing to call into driver specific {get,set}_rxnfc operations.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/net/dsa.h |  8 ++++++++
 net/dsa/slave.c   | 26 ++++++++++++++++++++++++++
 2 files changed, 34 insertions(+)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 92fd795e9573..bcad7cc906d9 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -370,6 +370,14 @@ struct dsa_switch_ops {
 	int	(*port_mdb_dump)(struct dsa_switch *ds, int port,
 				 struct switchdev_obj_port_mdb *mdb,
 				 int (*cb)(struct switchdev_obj *obj));
+
+	/*
+	 * RXNFC
+	 */
+	int	(*get_rxnfc)(struct dsa_switch *ds, int port,
+			     struct ethtool_rxnfc *nfc, u32 *rule_locs);
+	int	(*set_rxnfc)(struct dsa_switch *ds, int port,
+			     struct ethtool_rxnfc *nfc);
 };
 
 struct dsa_switch_driver {
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 9750dd6f8c17..bdae70f40a8a 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -1001,6 +1001,30 @@ void dsa_cpu_port_ethtool_init(struct ethtool_ops *ops)
 	ops->get_strings = dsa_cpu_port_get_strings;
 }
 
+static int dsa_slave_get_rxnfc(struct net_device *dev,
+			       struct ethtool_rxnfc *nfc, u32 *rule_locs)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_switch *ds = p->parent;
+
+	if (!ds->ops->get_rxnfc)
+		return -EOPNOTSUPP;
+
+	return ds->ops->get_rxnfc(ds, p->port, nfc, rule_locs);
+}
+
+static int dsa_slave_set_rxnfc(struct net_device *dev,
+			       struct ethtool_rxnfc *nfc)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_switch *ds = p->parent;
+
+	if (!ds->ops->set_rxnfc)
+		return -EOPNOTSUPP;
+
+	return ds->ops->set_rxnfc(ds, p->port, nfc);
+}
+
 static const struct ethtool_ops dsa_slave_ethtool_ops = {
 	.get_drvinfo		= dsa_slave_get_drvinfo,
 	.get_regs_len		= dsa_slave_get_regs_len,
@@ -1019,6 +1043,8 @@ static const struct ethtool_ops dsa_slave_ethtool_ops = {
 	.get_eee		= dsa_slave_get_eee,
 	.get_link_ksettings	= dsa_slave_get_link_ksettings,
 	.set_link_ksettings	= dsa_slave_set_link_ksettings,
+	.get_rxnfc		= dsa_slave_get_rxnfc,
+	.set_rxnfc		= dsa_slave_set_rxnfc,
 };
 
 static const struct net_device_ops dsa_slave_netdev_ops = {
-- 
2.9.3

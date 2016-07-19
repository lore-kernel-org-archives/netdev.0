From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v3 10/12] net: dsa: support switchdev ageing time attr
Date: Mon, 18 Jul 2016 20:45:38 -0400
Message-ID: <20160719004540.1066-11-vivien.didelot@savoirfairelinux.com>
References: <20160719004540.1066-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:34981 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752318AbcGSApz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 20:45:55 -0400
In-Reply-To: <20160719004540.1066-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a new function for DSA drivers to handle the switchdev
SWITCHDEV_ATTR_ID_BRIDGE_AGEING_TIME attribute.

The ageing time is passed as milliseconds.

Also because we can have multiple logical bridges on top of a physical
switch and ageing time are switch-wide, call the driver function with
the fastest ageing time in use on the chip instead of the requested one.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 include/net/dsa.h |  2 ++
 net/dsa/slave.c   | 41 +++++++++++++++++++++++++++++++++++++++++
 2 files changed, 43 insertions(+)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 52ab18b..2217a3f 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -141,6 +141,7 @@ struct dsa_switch_tree {
 struct dsa_port {
 	struct net_device	*netdev;
 	struct device_node	*dn;
+	unsigned int		ageing_time;
 };
 
 struct dsa_switch {
@@ -329,6 +330,7 @@ struct dsa_switch_driver {
 	/*
 	 * Bridge integration
 	 */
+	int	(*set_ageing_time)(struct dsa_switch *ds, unsigned int msecs);
 	int	(*port_bridge_join)(struct dsa_switch *ds, int port,
 				    struct net_device *bridge);
 	void	(*port_bridge_leave)(struct dsa_switch *ds, int port);
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 7236eb2..fc91967 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -333,6 +333,44 @@ static int dsa_slave_vlan_filtering(struct net_device *dev,
 	return 0;
 }
 
+static int dsa_fastest_ageing_time(struct dsa_switch *ds,
+				   unsigned int ageing_time)
+{
+	int i;
+
+	for (i = 0; i < DSA_MAX_PORTS; ++i) {
+		struct dsa_port *dp = &ds->ports[i];
+
+		if (dp && dp->ageing_time && dp->ageing_time < ageing_time)
+			ageing_time = dp->ageing_time;
+	}
+
+	return ageing_time;
+}
+
+static int dsa_slave_ageing_time(struct net_device *dev,
+				 const struct switchdev_attr *attr,
+				 struct switchdev_trans *trans)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_switch *ds = p->parent;
+	unsigned long ageing_jiffies = clock_t_to_jiffies(attr->u.ageing_time);
+	unsigned int ageing_time = jiffies_to_msecs(ageing_jiffies);
+
+	/* bridge skips -EOPNOTSUPP, so skip the prepare phase */
+	if (switchdev_trans_ph_prepare(trans))
+		return 0;
+
+	/* Keep the fastest ageing time in case of multiple bridges */
+	ds->ports[p->port].ageing_time = ageing_time;
+	ageing_time = dsa_fastest_ageing_time(ds, ageing_time);
+
+	if (ds->drv->set_ageing_time)
+		return ds->drv->set_ageing_time(ds, ageing_time);
+
+	return 0;
+}
+
 static int dsa_slave_port_attr_set(struct net_device *dev,
 				   const struct switchdev_attr *attr,
 				   struct switchdev_trans *trans)
@@ -346,6 +384,9 @@ static int dsa_slave_port_attr_set(struct net_device *dev,
 	case SWITCHDEV_ATTR_ID_BRIDGE_VLAN_FILTERING:
 		ret = dsa_slave_vlan_filtering(dev, attr, trans);
 		break;
+	case SWITCHDEV_ATTR_ID_BRIDGE_AGEING_TIME:
+		ret = dsa_slave_ageing_time(dev, attr, trans);
+		break;
 	default:
 		ret = -EOPNOTSUPP;
 		break;
-- 
2.9.0

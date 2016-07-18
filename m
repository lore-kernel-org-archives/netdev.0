From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH v2 net-next v2 10/12] net: dsa: support switchdev ageing time attr
Date: Mon, 18 Jul 2016 14:46:26 -0400
Message-ID: <20160718184628.13103-11-vivien.didelot@savoirfairelinux.com>
References: <20160718184628.13103-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160718184628.13103-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a new function for DSA drivers to implement to handle the switchdev
SWITCHDEV_ATTR_ID_BRIDGE_AGEING_TIME attribute.

The ageing time is passed as milliseconds.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 include/net/dsa.h |  1 +
 net/dsa/slave.c   | 22 ++++++++++++++++++++++
 2 files changed, 23 insertions(+)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 52ab18b..238fad9 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -329,6 +329,7 @@ struct dsa_switch_driver {
 	/*
 	 * Bridge integration
 	 */
+	int	(*set_ageing_time)(struct dsa_switch *ds, unsigned int msecs);
 	int	(*port_bridge_join)(struct dsa_switch *ds, int port,
 				    struct net_device *bridge);
 	void	(*port_bridge_leave)(struct dsa_switch *ds, int port);
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 7236eb2..1074cb6 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -333,6 +333,25 @@ static int dsa_slave_vlan_filtering(struct net_device *dev,
 	return 0;
 }
 
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
+	if (ds->drv->set_ageing_time)
+		return ds->drv->set_ageing_time(ds, ageing_time);
+
+	return 0;
+}
+
 static int dsa_slave_port_attr_set(struct net_device *dev,
 				   const struct switchdev_attr *attr,
 				   struct switchdev_trans *trans)
@@ -346,6 +365,9 @@ static int dsa_slave_port_attr_set(struct net_device *dev,
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

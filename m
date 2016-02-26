From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 1/9] net: dsa: support VLAN filtering switchdev attr
Date: Fri, 26 Feb 2016 13:16:00 -0500
Message-ID: <1456510568-13679-2-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1456510568-13679-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Neil Armstrong <narmstrong@baylibre.com>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Russell King <rmk+kernel@arm.linux.org.uk>,
	Kevin Smith <kevin.smith@elecsyscorp.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1456510568-13679-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When a user explicitly requests VLAN filtering with something like:

    # echo 1 > /sys/class/net/<bridge>/bridge/vlan_filtering

Switchdev propagates a SWITCHDEV_ATTR_ID_BRIDGE_VLAN_FILTERING port
attribute.

Add support for it in the DSA layer with a new port_vlan_filtering
function to let drivers toggle 802.1Q filtering on user demand.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 include/net/dsa.h |  2 ++
 net/dsa/slave.c   | 21 +++++++++++++++++++++
 2 files changed, 23 insertions(+)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 3dd5486..26c0a3f 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -305,6 +305,8 @@ struct dsa_switch_driver {
 	/*
 	 * VLAN support
 	 */
+	int	(*port_vlan_filtering)(struct dsa_switch *ds, int port,
+				       bool vlan_filtering);
 	int	(*port_vlan_prepare)(struct dsa_switch *ds, int port,
 				     const struct switchdev_obj_port_vlan *vlan,
 				     struct switchdev_trans *trans);
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index cde2923..27bf03d 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -317,6 +317,24 @@ static int dsa_slave_stp_update(struct net_device *dev, u8 state)
 	return ret;
 }
 
+static int dsa_slave_vlan_filtering(struct net_device *dev,
+				    const struct switchdev_attr *attr,
+				    struct switchdev_trans *trans)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_switch *ds = p->parent;
+
+	/* bridge skips -EOPNOTSUPP, so skip the prepare phase */
+	if (switchdev_trans_ph_prepare(trans))
+		return 0;
+
+	if (ds->drv->port_vlan_filtering)
+		return ds->drv->port_vlan_filtering(ds, p->port,
+						    attr->u.vlan_filtering);
+
+	return 0;
+}
+
 static int dsa_slave_port_attr_set(struct net_device *dev,
 				   const struct switchdev_attr *attr,
 				   struct switchdev_trans *trans)
@@ -333,6 +351,9 @@ static int dsa_slave_port_attr_set(struct net_device *dev,
 			ret = ds->drv->port_stp_update(ds, p->port,
 						       attr->u.stp_state);
 		break;
+	case SWITCHDEV_ATTR_ID_BRIDGE_VLAN_FILTERING:
+		ret = dsa_slave_vlan_filtering(dev, attr, trans);
+		break;
 	default:
 		ret = -EOPNOTSUPP;
 		break;
-- 
2.7.1

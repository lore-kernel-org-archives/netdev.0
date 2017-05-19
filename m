From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 07/20] net: dsa: change scope of VLAN filtering setter
Date: Fri, 19 May 2017 17:00:42 -0400
Message-ID: <20170519210055.9366-8-vivien.didelot@savoirfairelinux.com>
References: <20170519210055.9366-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170519210055.9366-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Change the scope of the switchdev VLAN filtering attribute setter from
the DSA slave device to the generic DSA port, so that the future
port-wide API can also be used for other port types, such as CPU and DSA
links.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/slave.c | 15 +++++++--------
 1 file changed, 7 insertions(+), 8 deletions(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index de39da69fd33..216eb38a847d 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -388,20 +388,18 @@ static int dsa_slave_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	return -EOPNOTSUPP;
 }
 
-static int dsa_slave_vlan_filtering(struct net_device *dev,
-				    const struct switchdev_attr *attr,
-				    struct switchdev_trans *trans)
+static int dsa_port_vlan_filtering(struct dsa_port *dp, bool vlan_filtering,
+				   struct switchdev_trans *trans)
 {
-	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->dp->ds;
+	struct dsa_switch *ds = dp->ds;
 
 	/* bridge skips -EOPNOTSUPP, so skip the prepare phase */
 	if (switchdev_trans_ph_prepare(trans))
 		return 0;
 
 	if (ds->ops->port_vlan_filtering)
-		return ds->ops->port_vlan_filtering(ds, p->dp->index,
-						    attr->u.vlan_filtering);
+		return ds->ops->port_vlan_filtering(ds, dp->index,
+						    vlan_filtering);
 
 	return 0;
 }
@@ -461,7 +459,8 @@ static int dsa_slave_port_attr_set(struct net_device *dev,
 		ret = dsa_port_set_state(dp, attr->u.stp_state, trans);
 		break;
 	case SWITCHDEV_ATTR_ID_BRIDGE_VLAN_FILTERING:
-		ret = dsa_slave_vlan_filtering(dev, attr, trans);
+		ret = dsa_port_vlan_filtering(dp, attr->u.vlan_filtering,
+					      trans);
 		break;
 	case SWITCHDEV_ATTR_ID_BRIDGE_AGEING_TIME:
 		ret = dsa_slave_ageing_time(dev, attr, trans);
-- 
2.13.0

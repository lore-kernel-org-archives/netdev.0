From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 08/20] net: dsa: change scope of ageing time setter
Date: Fri, 19 May 2017 17:00:43 -0400
Message-ID: <20170519210055.9366-9-vivien.didelot@savoirfairelinux.com>
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

Change the scope of the switchdev bridge ageing time attribute setter
from the DSA slave device to the generic DSA port, so that the future
port-wide API can also be used for other port types, such as CPU and DSA
links.

Also ds->ports is now a contiguous array of dsa_port structures, thus
their addresses cannot be NULL. Remove the useless check in
dsa_fastest_ageing_time.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/slave.c | 16 +++++++---------
 1 file changed, 7 insertions(+), 9 deletions(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 216eb38a847d..b0150f79dcdd 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -412,21 +412,19 @@ static unsigned int dsa_fastest_ageing_time(struct dsa_switch *ds,
 	for (i = 0; i < ds->num_ports; ++i) {
 		struct dsa_port *dp = &ds->ports[i];
 
-		if (dp && dp->ageing_time && dp->ageing_time < ageing_time)
+		if (dp->ageing_time && dp->ageing_time < ageing_time)
 			ageing_time = dp->ageing_time;
 	}
 
 	return ageing_time;
 }
 
-static int dsa_slave_ageing_time(struct net_device *dev,
-				 const struct switchdev_attr *attr,
-				 struct switchdev_trans *trans)
+static int dsa_port_ageing_time(struct dsa_port *dp, clock_t ageing_clock,
+				struct switchdev_trans *trans)
 {
-	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->dp->ds;
-	unsigned long ageing_jiffies = clock_t_to_jiffies(attr->u.ageing_time);
+	unsigned long ageing_jiffies = clock_t_to_jiffies(ageing_clock);
 	unsigned int ageing_time = jiffies_to_msecs(ageing_jiffies);
+	struct dsa_switch *ds = dp->ds;
 
 	if (switchdev_trans_ph_prepare(trans)) {
 		if (ds->ageing_time_min && ageing_time < ds->ageing_time_min)
@@ -437,7 +435,7 @@ static int dsa_slave_ageing_time(struct net_device *dev,
 	}
 
 	/* Keep the fastest ageing time in case of multiple bridges */
-	p->dp->ageing_time = ageing_time;
+	dp->ageing_time = ageing_time;
 	ageing_time = dsa_fastest_ageing_time(ds, ageing_time);
 
 	if (ds->ops->set_ageing_time)
@@ -463,7 +461,7 @@ static int dsa_slave_port_attr_set(struct net_device *dev,
 					      trans);
 		break;
 	case SWITCHDEV_ATTR_ID_BRIDGE_AGEING_TIME:
-		ret = dsa_slave_ageing_time(dev, attr, trans);
+		ret = dsa_port_ageing_time(dp, attr->u.ageing_time, trans);
 		break;
 	default:
 		ret = -EOPNOTSUPP;
-- 
2.13.0

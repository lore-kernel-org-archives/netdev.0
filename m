From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [RFC 02/20] net: dsa: be consistent with NETDEV_CHANGEUPPER
Date: Wed, 27 Apr 2016 18:29:59 -0400
Message-ID: <1461796217-18893-3-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1461796217-18893-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>, Jiri Pirko <jiri@resnulli.us>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1461796217-18893-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Once NETDEV_CHANGEUPPER is emitted, the device is already (un)bridged.

If an error is returned on port_bridge_join, the bridge layer will
rollback the operation and unbridge the port.

Respect this by setting bridge_dev to NULL on error.

Also the DSA layer shouldn't assume that the drivers know about the
bridge device a port was previously bridged to. So pass the bridge
device to port_bridge_leave.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/bcm_sf2.c   |  4 ++--
 drivers/net/dsa/mv88e6xxx.c |  4 ++--
 drivers/net/dsa/mv88e6xxx.h |  3 ++-
 include/net/dsa.h           |  3 ++-
 net/dsa/slave.c             | 13 +++++++++----
 5 files changed, 17 insertions(+), 10 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 448deb5..f394ea9 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -525,10 +525,10 @@ static int bcm_sf2_sw_br_join(struct dsa_switch *ds, int port,
 	return 0;
 }
 
-static void bcm_sf2_sw_br_leave(struct dsa_switch *ds, int port)
+static void bcm_sf2_sw_br_leave(struct dsa_switch *ds, int port,
+				struct net_device *bridge)
 {
 	struct bcm_sf2_priv *priv = ds_to_priv(ds);
-	struct net_device *bridge = priv->port_sts[port].bridge_dev;
 	unsigned int i;
 	u32 reg, p_ctl;
 
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 028f92f..86f8f2f 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -2227,10 +2227,10 @@ int mv88e6xxx_port_bridge_join(struct dsa_switch *ds, int port,
 	return err;
 }
 
-void mv88e6xxx_port_bridge_leave(struct dsa_switch *ds, int port)
+void mv88e6xxx_port_bridge_leave(struct dsa_switch *ds, int port,
+				 struct net_device *bridge)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	struct net_device *bridge = ps->ports[port].bridge_dev;
 	int i;
 
 	mutex_lock(&ps->smi_mutex);
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 0dbe2d1..2eb9a82 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -492,7 +492,8 @@ int mv88e6xxx_set_eee(struct dsa_switch *ds, int port,
 		      struct phy_device *phydev, struct ethtool_eee *e);
 int mv88e6xxx_port_bridge_join(struct dsa_switch *ds, int port,
 			       struct net_device *bridge);
-void mv88e6xxx_port_bridge_leave(struct dsa_switch *ds, int port);
+void mv88e6xxx_port_bridge_leave(struct dsa_switch *ds, int port,
+				 struct net_device *bridge);
 void mv88e6xxx_port_stp_state_set(struct dsa_switch *ds, int port, u8 state);
 int mv88e6xxx_port_vlan_filtering(struct dsa_switch *ds, int port,
 				  bool vlan_filtering);
diff --git a/include/net/dsa.h b/include/net/dsa.h
index 255c108..ed33500 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -305,7 +305,8 @@ struct dsa_switch_driver {
 	 */
 	int	(*port_bridge_join)(struct dsa_switch *ds, int port,
 				    struct net_device *bridge);
-	void	(*port_bridge_leave)(struct dsa_switch *ds, int port);
+	void	(*port_bridge_leave)(struct dsa_switch *ds, int port,
+				     struct net_device *bridge);
 	void	(*port_stp_state_set)(struct dsa_switch *ds, int port,
 				      u8 state);
 
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 6115444..f2ec13d 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -443,19 +443,24 @@ static int dsa_slave_bridge_port_join(struct net_device *dev,
 	if (ds->drv->port_bridge_join)
 		ret = ds->drv->port_bridge_join(ds, p->dp->port, br);
 
-	return ret == -EOPNOTSUPP ? 0 : ret;
+	if (ret && ret != -EOPNOTSUPP) {
+		p->bridge_dev = NULL;
+		return ret;
+	}
+
+	return 0;
 }
 
 static void dsa_slave_bridge_port_leave(struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct dsa_switch *ds = p->dp->ds;
+	struct net_device *br = p->bridge_dev;
 
+	p->bridge_dev = NULL;
 
 	if (ds->drv->port_bridge_leave)
-		ds->drv->port_bridge_leave(ds, p->dp->port);
-
-	p->bridge_dev = NULL;
+		ds->drv->port_bridge_leave(ds, p->dp->port, br);
 
 	/* Port left the bridge, put in BR_STATE_DISABLED by the bridge layer,
 	 * so allow it to be in BR_STATE_FORWARDING to be kept functional
-- 
2.8.0

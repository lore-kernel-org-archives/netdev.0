From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 11/20] net: dsa: move VLAN filtering setter
Date: Fri, 19 May 2017 17:00:46 -0400
Message-ID: <20170519210055.9366-12-vivien.didelot@savoirfairelinux.com>
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

Move the DSA port code which sets VLAN filtering on a port in port.c,
where it belongs.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/dsa_priv.h |  2 ++
 net/dsa/port.c     | 16 ++++++++++++++++
 net/dsa/slave.c    | 16 ----------------
 3 files changed, 18 insertions(+), 16 deletions(-)

diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index f0b6cd3c8a65..c145223247c5 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -66,6 +66,8 @@ int dsa_port_set_state(struct dsa_port *dp, u8 state,
 void dsa_port_set_state_now(struct dsa_port *dp, u8 state);
 int dsa_port_bridge_join(struct dsa_port *dp, struct net_device *br);
 void dsa_port_bridge_leave(struct dsa_port *dp, struct net_device *br);
+int dsa_port_vlan_filtering(struct dsa_port *dp, bool vlan_filtering,
+			    struct switchdev_trans *trans);
 
 /* slave.c */
 extern const struct dsa_device_ops notag_netdev_ops;
diff --git a/net/dsa/port.c b/net/dsa/port.c
index da8577fb3d07..c9f95aaf25f1 100644
--- a/net/dsa/port.c
+++ b/net/dsa/port.c
@@ -111,3 +111,19 @@ void dsa_port_bridge_leave(struct dsa_port *dp, struct net_device *br)
 	 */
 	dsa_port_set_state_now(dp, BR_STATE_FORWARDING);
 }
+
+int dsa_port_vlan_filtering(struct dsa_port *dp, bool vlan_filtering,
+			    struct switchdev_trans *trans)
+{
+	struct dsa_switch *ds = dp->ds;
+
+	/* bridge skips -EOPNOTSUPP, so skip the prepare phase */
+	if (switchdev_trans_ph_prepare(trans))
+		return 0;
+
+	if (ds->ops->port_vlan_filtering)
+		return ds->ops->port_vlan_filtering(ds, dp->index,
+						    vlan_filtering);
+
+	return 0;
+}
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index ab298c41b8e7..32e7e78313ba 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -338,22 +338,6 @@ static int dsa_slave_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	return -EOPNOTSUPP;
 }
 
-static int dsa_port_vlan_filtering(struct dsa_port *dp, bool vlan_filtering,
-				   struct switchdev_trans *trans)
-{
-	struct dsa_switch *ds = dp->ds;
-
-	/* bridge skips -EOPNOTSUPP, so skip the prepare phase */
-	if (switchdev_trans_ph_prepare(trans))
-		return 0;
-
-	if (ds->ops->port_vlan_filtering)
-		return ds->ops->port_vlan_filtering(ds, dp->index,
-						    vlan_filtering);
-
-	return 0;
-}
-
 static unsigned int dsa_fastest_ageing_time(struct dsa_switch *ds,
 					    unsigned int ageing_time)
 {
-- 
2.13.0

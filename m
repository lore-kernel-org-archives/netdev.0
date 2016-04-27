From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [RFC 06/20] net: dsa: move bridge device in dsa_port
Date: Wed, 27 Apr 2016 18:30:03 -0400
Message-ID: <1461796217-18893-7-git-send-email-vivien.didelot@savoirfairelinux.com>
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

Move the pointer to the bridge device in the DSA port structure instead
of cluttering the dsa_slave_priv structure.

This can later be used by drivers to help them configuring their bridge
group ports membership.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 include/net/dsa.h  |  2 ++
 net/dsa/dsa_priv.h |  1 -
 net/dsa/slave.c    | 16 +++++-----------
 3 files changed, 7 insertions(+), 12 deletions(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 08a9536..69e467c 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -125,6 +125,8 @@ struct dsa_switch_tree {
 struct dsa_port {
 	struct dsa_switch	*ds;
 	int			port;
+
+	struct net_device	*br;
 };
 
 struct dsa_switch {
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index c7d5df0..c5afddd 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -35,7 +35,6 @@ struct dsa_slave_priv {
 	int			old_pause;
 	int			old_duplex;
 
-	struct net_device	*bridge_dev;
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	struct netpoll		*netpoll;
 #endif
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index d6b6019..b90caf8 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -64,18 +64,12 @@ static int dsa_slave_get_iflink(const struct net_device *dev)
 	return p->dp->ds->dst->master_netdev->ifindex;
 }
 
-static inline bool dsa_port_is_bridged(struct dsa_slave_priv *p)
-{
-	return !!p->bridge_dev;
-}
-
 static int dsa_slave_open(struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct dsa_switch *ds = p->dp->ds;
 	struct net_device *master = ds->dst->master_netdev;
-	u8 stp_state = dsa_port_is_bridged(p) ?
-			BR_STATE_BLOCKING : BR_STATE_FORWARDING;
+	u8 stp_state = p->dp->br ? BR_STATE_BLOCKING : BR_STATE_FORWARDING;
 	int err;
 
 	if (!(master->flags & IFF_UP))
@@ -438,13 +432,13 @@ static int dsa_slave_bridge_port_join(struct net_device *dev,
 	struct dsa_switch *ds = p->dp->ds;
 	int ret = -EOPNOTSUPP;
 
-	p->bridge_dev = br;
+	p->dp->br = br;
 
 	if (ds->drv->port_bridge_join)
 		ret = ds->drv->port_bridge_join(ds, p->dp, br);
 
 	if (ret && ret != -EOPNOTSUPP) {
-		p->bridge_dev = NULL;
+		p->dp->br = NULL;
 		return ret;
 	}
 
@@ -455,9 +449,9 @@ static void dsa_slave_bridge_port_leave(struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct dsa_switch *ds = p->dp->ds;
-	struct net_device *br = p->bridge_dev;
+	struct net_device *br = p->dp->br;
 
-	p->bridge_dev = NULL;
+	p->dp->br = NULL;
 
 	if (ds->drv->port_bridge_leave)
 		ds->drv->port_bridge_leave(ds, p->dp, br);
-- 
2.8.0

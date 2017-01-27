From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 5/9] net: dsa: move bridge device in dsa_port
Date: Fri, 27 Jan 2017 15:29:40 -0500
Message-ID: <20170127202944.28598-6-vivien.didelot@savoirfairelinux.com>
References: <20170127202944.28598-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>, John Crispin <john@phrozen.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170127202944.28598-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move the bridge_dev pointer from dsa_slave_priv to dsa_port so that DSA
drivers can access this information and remove the need to cache it.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 include/net/dsa.h  |  1 +
 net/dsa/dsa_priv.h |  1 -
 net/dsa/slave.c    | 10 +++++-----
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 6bd1f8b05dbd..924533fd4425 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -146,6 +146,7 @@ struct dsa_port {
 	struct device_node	*dn;
 	unsigned int		ageing_time;
 	u8			stp_state;
+	struct net_device	*bridge_dev;
 };
 
 struct dsa_switch {
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index c519bd0e9206..3022f2e42cdc 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -38,7 +38,6 @@ struct dsa_slave_priv {
 	int			old_pause;
 	int			old_duplex;
 
-	struct net_device	*bridge_dev;
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	struct netpoll		*netpoll;
 #endif
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 2ea220bc4bba..3a7c28d64bd5 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -64,9 +64,9 @@ static int dsa_slave_get_iflink(const struct net_device *dev)
 	return p->dp->ds->dst->master_netdev->ifindex;
 }
 
-static inline bool dsa_port_is_bridged(struct dsa_slave_priv *p)
+static inline bool dsa_port_is_bridged(struct dsa_port *dp)
 {
-	return !!p->bridge_dev;
+	return !!dp->bridge_dev;
 }
 
 static void dsa_port_set_stp_state(struct dsa_switch *ds, int port, u8 state)
@@ -98,7 +98,7 @@ static int dsa_slave_open(struct net_device *dev)
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct net_device *master = p->dp->ds->dst->master_netdev;
 	struct dsa_switch *ds = p->dp->ds;
-	u8 stp_state = dsa_port_is_bridged(p) ?
+	u8 stp_state = dsa_port_is_bridged(p->dp) ?
 			BR_STATE_BLOCKING : BR_STATE_FORWARDING;
 	int err;
 
@@ -557,7 +557,7 @@ static int dsa_slave_bridge_port_join(struct net_device *dev,
 	struct dsa_switch *ds = p->dp->ds;
 	int ret = -EOPNOTSUPP;
 
-	p->bridge_dev = br;
+	p->dp->bridge_dev = br;
 
 	if (ds->ops->port_bridge_join)
 		ret = ds->ops->port_bridge_join(ds, p->dp->index, br);
@@ -574,7 +574,7 @@ static void dsa_slave_bridge_port_leave(struct net_device *dev)
 	if (ds->ops->port_bridge_leave)
 		ds->ops->port_bridge_leave(ds, p->dp->index);
 
-	p->bridge_dev = NULL;
+	p->dp->bridge_dev = NULL;
 
 	/* Port left the bridge, put in BR_STATE_DISABLED by the bridge layer,
 	 * so allow it to be in BR_STATE_FORWARDING to be kept functional
-- 
2.11.0

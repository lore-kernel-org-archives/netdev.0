From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 3/3] net: dsa: remove useless args of dsa_slave_create
Date: Fri,  4 Aug 2017 18:23:20 -0400
Message-ID: <20170804222320.10986-4-vivien.didelot@savoirfairelinux.com>
References: <20170804222320.10986-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170804222320.10986-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

dsa_slave_create currently takes 4 arguments while it only needs the
related dsa_port and its name. Remove all other arguments.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/dsa2.c     |  2 +-
 net/dsa/dsa_priv.h |  3 +--
 net/dsa/legacy.c   |  2 +-
 net/dsa/slave.c    | 14 +++++++-------
 4 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index 2a0120493cf1..cceaa4dd9f53 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -275,7 +275,7 @@ static int dsa_user_port_apply(struct dsa_port *port)
 	if (!name)
 		name = "eth%d";
 
-	err = dsa_slave_create(ds, ds->dev, port->index, name);
+	err = dsa_slave_create(port, name);
 	if (err) {
 		dev_warn(ds->dev, "Failed to create slave %d: %d\n",
 			 port->index, err);
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 46851c91c7fe..73426f9c2cca 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -148,8 +148,7 @@ int dsa_port_vlan_dump(struct dsa_port *dp,
 extern const struct dsa_device_ops notag_netdev_ops;
 void dsa_slave_mii_bus_init(struct dsa_switch *ds);
 void dsa_cpu_port_ethtool_init(struct ethtool_ops *ops);
-int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
-		     int port, const char *name);
+int dsa_slave_create(struct dsa_port *port, const char *name);
 void dsa_slave_destroy(struct net_device *slave_dev);
 int dsa_slave_suspend(struct net_device *slave_dev);
 int dsa_slave_resume(struct net_device *slave_dev);
diff --git a/net/dsa/legacy.c b/net/dsa/legacy.c
index 05be0bc10735..db7c1eaad078 100644
--- a/net/dsa/legacy.c
+++ b/net/dsa/legacy.c
@@ -194,7 +194,7 @@ static int dsa_switch_setup_one(struct dsa_switch *ds,
 		if (!(ds->enabled_port_mask & (1 << i)))
 			continue;
 
-		ret = dsa_slave_create(ds, ds->dev, i, cd->port_names[i]);
+		ret = dsa_slave_create(&ds->ports[i], cd->port_names[i]);
 		if (ret < 0)
 			netdev_err(master, "[%d]: can't create dsa slave device for port %d(%s): %d\n",
 				   index, i, cd->port_names[i], ret);
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index e196562035b1..c8eb33746850 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -1165,9 +1165,9 @@ int dsa_slave_resume(struct net_device *slave_dev)
 	return 0;
 }
 
-int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
-		     int port, const char *name)
+int dsa_slave_create(struct dsa_port *port, const char *name)
 {
+	struct dsa_switch *ds = port->ds;
 	struct dsa_switch_tree *dst = ds->dst;
 	struct net_device *master;
 	struct net_device *slave_dev;
@@ -1197,13 +1197,13 @@ int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 	netdev_for_each_tx_queue(slave_dev, dsa_slave_set_lockdep_class_one,
 				 NULL);
 
-	SET_NETDEV_DEV(slave_dev, parent);
-	slave_dev->dev.of_node = ds->ports[port].dn;
+	SET_NETDEV_DEV(slave_dev, port->ds->dev);
+	slave_dev->dev.of_node = port->dn;
 	slave_dev->vlan_features = master->vlan_features;
 
 	p = netdev_priv(slave_dev);
 	u64_stats_init(&p->stats64.syncp);
-	p->dp = &ds->ports[port];
+	p->dp = port;
 	INIT_LIST_HEAD(&p->mall_tc_list);
 	p->xmit = dst->tag_ops->xmit;
 
@@ -1211,12 +1211,12 @@ int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 	p->old_link = -1;
 	p->old_duplex = -1;
 
-	ds->ports[port].netdev = slave_dev;
+	port->netdev = slave_dev;
 	ret = register_netdev(slave_dev);
 	if (ret) {
 		netdev_err(master, "error %d registering interface %s\n",
 			   ret, slave_dev->name);
-		ds->ports[port].netdev = NULL;
+		port->netdev = NULL;
 		free_netdev(slave_dev);
 		return ret;
 	}
-- 
2.13.3

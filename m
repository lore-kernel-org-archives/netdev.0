From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v3 1/3] net: dsa: remove useless argument in legacy setup
Date: Mon,  7 Aug 2017 12:17:08 -0400
Message-ID: <20170807161710.5357-2-vivien.didelot@savoirfairelinux.com>
References: <20170807161710.5357-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170807161710.5357-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

dsa_switch_alloc() already assigns ds-dev, which can be used in
dsa_switch_setup_one and dsa_cpu_dsa_setups instead of requiring an
additional struct device argument.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/legacy.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/dsa/legacy.c b/net/dsa/legacy.c
index 1d7a3282f2a7..fa162030a69c 100644
--- a/net/dsa/legacy.c
+++ b/net/dsa/legacy.c
@@ -78,7 +78,7 @@ dsa_switch_probe(struct device *parent, struct device *host_dev, int sw_addr,
 }
 
 /* basic switch operations **************************************************/
-static int dsa_cpu_dsa_setups(struct dsa_switch *ds, struct device *dev)
+static int dsa_cpu_dsa_setups(struct dsa_switch *ds)
 {
 	struct dsa_port *dport;
 	int ret, port;
@@ -88,15 +88,15 @@ static int dsa_cpu_dsa_setups(struct dsa_switch *ds, struct device *dev)
 			continue;
 
 		dport = &ds->ports[port];
-		ret = dsa_cpu_dsa_setup(ds, dev, dport, port);
+		ret = dsa_cpu_dsa_setup(ds, ds->dev, dport, port);
 		if (ret)
 			return ret;
 	}
 	return 0;
 }
 
-static int dsa_switch_setup_one(struct dsa_switch *ds, struct net_device *master,
-				struct device *parent)
+static int dsa_switch_setup_one(struct dsa_switch *ds,
+				struct net_device *master)
 {
 	const struct dsa_switch_ops *ops = ds->ops;
 	struct dsa_switch_tree *dst = ds->dst;
@@ -176,7 +176,7 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct net_device *master
 	}
 
 	if (!ds->slave_mii_bus && ops->phy_read) {
-		ds->slave_mii_bus = devm_mdiobus_alloc(parent);
+		ds->slave_mii_bus = devm_mdiobus_alloc(ds->dev);
 		if (!ds->slave_mii_bus)
 			return -ENOMEM;
 		dsa_slave_mii_bus_init(ds);
@@ -196,14 +196,14 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct net_device *master
 		if (!(ds->enabled_port_mask & (1 << i)))
 			continue;
 
-		ret = dsa_slave_create(ds, parent, i, cd->port_names[i]);
+		ret = dsa_slave_create(ds, ds->dev, i, cd->port_names[i]);
 		if (ret < 0)
 			netdev_err(master, "[%d]: can't create dsa slave device for port %d(%s): %d\n",
 				   index, i, cd->port_names[i], ret);
 	}
 
 	/* Perform configuration of the CPU and DSA ports */
-	ret = dsa_cpu_dsa_setups(ds, parent);
+	ret = dsa_cpu_dsa_setups(ds);
 	if (ret < 0)
 		netdev_err(master, "[%d] : can't configure CPU and DSA ports\n",
 			   index);
@@ -252,7 +252,7 @@ dsa_switch_setup(struct dsa_switch_tree *dst, struct net_device *master,
 	ds->ops = ops;
 	ds->priv = priv;
 
-	ret = dsa_switch_setup_one(ds, master, parent);
+	ret = dsa_switch_setup_one(ds, master);
 	if (ret)
 		return ERR_PTR(ret);
 
-- 
2.14.0

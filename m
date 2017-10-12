From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 2/5] net: dsa: add slave notify helper
Date: Thu, 12 Oct 2017 18:51:53 -0400
Message-ID: <20171012225156.20758-3-vivien.didelot@savoirfairelinux.com>
References: <20171012225156.20758-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171012225156.20758-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Both DSA slave create and destroy functions call call_dsa_notifiers with
respectively DSA_PORT_REGISTER and DSA_PORT_UNREGISTER and the same
dsa_notifier_register_info structure.

Wrap this in a dsa_slave_notify helper so prevent cluttering these
functions.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/slave.c | 29 +++++++++++++++++------------
 1 file changed, 17 insertions(+), 12 deletions(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index c6f4829645bf..f31737256f69 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -1114,9 +1114,23 @@ int dsa_slave_resume(struct net_device *slave_dev)
 	return 0;
 }
 
+static void dsa_slave_notify(struct net_device *dev, unsigned long val)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct net_device *master = dsa_master_netdev(p);
+	struct dsa_port *dp = p->dp;
+	struct dsa_notifier_register_info rinfo = {
+		.switch_number = dp->ds->index,
+		.port_number = dp->index,
+		.master = master,
+		.info.dev = dev,
+	};
+
+	call_dsa_notifiers(val, dev, &rinfo.info);
+}
+
 int dsa_slave_create(struct dsa_port *port, const char *name)
 {
-	struct dsa_notifier_register_info rinfo = { };
 	struct dsa_port *cpu_dp = port->cpu_dp;
 	struct net_device *master = cpu_dp->netdev;
 	struct dsa_switch *ds = port->ds;
@@ -1175,11 +1189,7 @@ int dsa_slave_create(struct dsa_port *port, const char *name)
 		goto out_free;
 	}
 
-	rinfo.info.dev = slave_dev;
-	rinfo.master = master;
-	rinfo.port_number = p->dp->index;
-	rinfo.switch_number = p->dp->ds->index;
-	call_dsa_notifiers(DSA_PORT_REGISTER, slave_dev, &rinfo.info);
+	dsa_slave_notify(slave_dev, DSA_PORT_REGISTER);
 
 	ret = register_netdev(slave_dev);
 	if (ret) {
@@ -1204,7 +1214,6 @@ int dsa_slave_create(struct dsa_port *port, const char *name)
 void dsa_slave_destroy(struct net_device *slave_dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(slave_dev);
-	struct dsa_notifier_register_info rinfo = { };
 	struct device_node *port_dn;
 
 	port_dn = p->dp->dn;
@@ -1216,11 +1225,7 @@ void dsa_slave_destroy(struct net_device *slave_dev)
 		if (of_phy_is_fixed_link(port_dn))
 			of_phy_deregister_fixed_link(port_dn);
 	}
-	rinfo.info.dev = slave_dev;
-	rinfo.master = p->dp->cpu_dp->netdev;
-	rinfo.port_number = p->dp->index;
-	rinfo.switch_number = p->dp->ds->index;
-	call_dsa_notifiers(DSA_PORT_UNREGISTER, slave_dev, &rinfo.info);
+	dsa_slave_notify(slave_dev, DSA_PORT_UNREGISTER);
 	unregister_netdev(slave_dev);
 	free_percpu(p->stats64);
 	free_netdev(slave_dev);
-- 
2.14.2

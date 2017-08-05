From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 2/3] net: dsa: remove useless args of dsa_cpu_dsa_setup
Date: Sat,  5 Aug 2017 16:20:18 -0400
Message-ID: <20170805202019.1679-3-vivien.didelot@savoirfairelinux.com>
References: <20170805202019.1679-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170805202019.1679-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

dsa_cpu_dsa_setup currently takes 4 arguments but they are all available
from the dsa_port argument. Remove all others.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/dsa.c      | 10 +++++-----
 net/dsa/dsa2.c     |  4 ++--
 net/dsa/dsa_priv.h |  3 +--
 net/dsa/legacy.c   |  4 +---
 4 files changed, 9 insertions(+), 12 deletions(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 0ba842c08dd3..64db6eece3c1 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -67,17 +67,17 @@ const struct dsa_device_ops *dsa_device_ops[DSA_TAG_LAST] = {
 	[DSA_TAG_PROTO_NONE] = &none_ops,
 };
 
-int dsa_cpu_dsa_setup(struct dsa_switch *ds, struct device *dev,
-		      struct dsa_port *dport, int port)
+int dsa_cpu_dsa_setup(struct dsa_port *port)
 {
-	struct device_node *port_dn = dport->dn;
+	struct device_node *port_dn = port->dn;
+	struct dsa_switch *ds = port->ds;
 	struct phy_device *phydev;
 	int ret, mode;
 
 	if (of_phy_is_fixed_link(port_dn)) {
 		ret = of_phy_register_fixed_link(port_dn);
 		if (ret) {
-			dev_err(dev, "failed to register fixed PHY\n");
+			dev_err(ds->dev, "failed to register fixed PHY\n");
 			return ret;
 		}
 		phydev = of_phy_find_device(port_dn);
@@ -90,7 +90,7 @@ int dsa_cpu_dsa_setup(struct dsa_switch *ds, struct device *dev,
 		genphy_config_init(phydev);
 		genphy_read_status(phydev);
 		if (ds->ops->adjust_link)
-			ds->ops->adjust_link(ds, port, phydev);
+			ds->ops->adjust_link(ds, port->index, phydev);
 
 		put_device(&phydev->mdio.dev);
 	}
diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index c442051d5a55..2a0120493cf1 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -219,7 +219,7 @@ static int dsa_dsa_port_apply(struct dsa_port *port)
 	struct dsa_switch *ds = port->ds;
 	int err;
 
-	err = dsa_cpu_dsa_setup(ds, ds->dev, port, port->index);
+	err = dsa_cpu_dsa_setup(port);
 	if (err) {
 		dev_warn(ds->dev, "Failed to setup dsa port %d: %d\n",
 			 port->index, err);
@@ -243,7 +243,7 @@ static int dsa_cpu_port_apply(struct dsa_port *port)
 	struct dsa_switch *ds = port->ds;
 	int err;
 
-	err = dsa_cpu_dsa_setup(ds, ds->dev, port, port->index);
+	err = dsa_cpu_dsa_setup(port);
 	if (err) {
 		dev_warn(ds->dev, "Failed to setup cpu port %d: %d\n",
 			 port->index, err);
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 7aa0656296c2..46851c91c7fe 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -101,8 +101,7 @@ struct dsa_slave_priv {
 };
 
 /* dsa.c */
-int dsa_cpu_dsa_setup(struct dsa_switch *ds, struct device *dev,
-		      struct dsa_port *dport, int port);
+int dsa_cpu_dsa_setup(struct dsa_port *port);
 void dsa_cpu_dsa_destroy(struct dsa_port *dport);
 const struct dsa_device_ops *dsa_resolve_tag_protocol(int tag_protocol);
 int dsa_cpu_port_ethtool_setup(struct dsa_port *cpu_dp);
diff --git a/net/dsa/legacy.c b/net/dsa/legacy.c
index fa162030a69c..903e8d70c792 100644
--- a/net/dsa/legacy.c
+++ b/net/dsa/legacy.c
@@ -80,15 +80,13 @@ dsa_switch_probe(struct device *parent, struct device *host_dev, int sw_addr,
 /* basic switch operations **************************************************/
 static int dsa_cpu_dsa_setups(struct dsa_switch *ds)
 {
-	struct dsa_port *dport;
 	int ret, port;
 
 	for (port = 0; port < ds->num_ports; port++) {
 		if (!(dsa_is_cpu_port(ds, port) || dsa_is_dsa_port(ds, port)))
 			continue;
 
-		dport = &ds->ports[port];
-		ret = dsa_cpu_dsa_setup(ds, ds->dev, dport, port);
+		ret = dsa_cpu_dsa_setup(&ds->ports[port]);
 		if (ret)
 			return ret;
 	}
-- 
2.13.3

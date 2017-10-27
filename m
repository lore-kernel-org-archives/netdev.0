From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 3/7] net: dsa: get port type at parse time
Date: Fri, 27 Oct 2017 15:55:15 -0400
Message-ID: <20171027195519.5931-4-vivien.didelot@savoirfairelinux.com>
References: <20171027195519.5931-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171027195519.5931-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Assign a port's type at parsed time instead of waiting for the tree to
be completed.

Because this is now done earlier, we can use the port's type in
dsa_port_is_* helpers instead of digging again in topology description.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/dsa2.c | 37 ++++++++++++++++++++++---------------
 1 file changed, 22 insertions(+), 15 deletions(-)

diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index 9b75d19d57cb..960219d2f862 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -87,23 +87,17 @@ static void dsa_dst_del_ds(struct dsa_switch_tree *dst,
  */
 static bool dsa_port_is_valid(struct dsa_port *port)
 {
-	return !!(port->dn || port->name);
+	return port->type != DSA_PORT_TYPE_UNUSED;
 }
 
 static bool dsa_port_is_dsa(struct dsa_port *port)
 {
-	if (port->name && !strcmp(port->name, "dsa"))
-		return true;
-	else
-		return !!of_parse_phandle(port->dn, "link", 0);
+	return port->type == DSA_PORT_TYPE_DSA;
 }
 
 static bool dsa_port_is_cpu(struct dsa_port *port)
 {
-	if (port->name && !strcmp(port->name, "cpu"))
-		return true;
-	else
-		return !!of_parse_phandle(port->dn, "ethernet", 0);
+	return port->type == DSA_PORT_TYPE_CPU;
 }
 
 static bool dsa_ds_find_port_dn(struct dsa_switch *ds,
@@ -183,8 +177,6 @@ static int dsa_ds_complete(struct dsa_switch_tree *dst, struct dsa_switch *ds)
 		err = dsa_port_complete(dst, ds, port, index);
 		if (err != 0)
 			return err;
-
-		port->type = DSA_PORT_TYPE_DSA;
 	}
 
 	return 0;
@@ -499,8 +491,6 @@ static int dsa_cpu_parse(struct dsa_port *port, u32 index,
 		dst->cpu_dp->master = ethernet_dev;
 	}
 
-	port->type = DSA_PORT_TYPE_CPU;
-
 	tag_protocol = ds->ops->get_tag_protocol(ds);
 	tag_ops = dsa_resolve_tag_protocol(tag_protocol);
 	if (IS_ERR(tag_ops)) {
@@ -533,8 +523,6 @@ static int dsa_ds_parse(struct dsa_switch_tree *dst, struct dsa_switch *ds)
 			err = dsa_cpu_parse(port, index, dst, ds);
 			if (err)
 				return err;
-		} else {
-			port->type = DSA_PORT_TYPE_USER;
 		}
 
 	}
@@ -591,6 +579,17 @@ static int dsa_dst_parse(struct dsa_switch_tree *dst)
 
 static int dsa_port_parse_of(struct dsa_port *dp, struct device_node *dn)
 {
+	struct device_node *ethernet = of_parse_phandle(dn, "ethernet", 0);
+	struct device_node *link = of_parse_phandle(dn, "link", 0);
+
+	if (ethernet) {
+		dp->type = DSA_PORT_TYPE_CPU;
+	} else if (link) {
+		dp->type = DSA_PORT_TYPE_DSA;
+	} else {
+		dp->type = DSA_PORT_TYPE_USER;
+	}
+
 	dp->dn = dn;
 
 	return 0;
@@ -630,6 +629,14 @@ static int dsa_parse_ports_of(struct device_node *dn, struct dsa_switch *ds)
 static int dsa_port_parse(struct dsa_port *dp, const char *name,
 			  struct device *dev)
 {
+	if (!strcmp(name, "cpu")) {
+		dp->type = DSA_PORT_TYPE_CPU;
+	} else if (!strcmp(name, "dsa")) {
+		dp->type = DSA_PORT_TYPE_DSA;
+	} else {
+		dp->type = DSA_PORT_TYPE_USER;
+	}
+
 	dp->name = name;
 
 	return 0;
-- 
2.14.3

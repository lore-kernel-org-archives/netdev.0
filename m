From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 1/7] net: dsa: get ports within parsing code
Date: Fri, 27 Oct 2017 15:55:13 -0400
Message-ID: <20171027195519.5931-2-vivien.didelot@savoirfairelinux.com>
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

There is no point into hiding the -EINVAL error code in ERR_PTR from a
dsa_get_ports function, simply get the "ports" node directly from within
the dsa_parse_ports_dn function.

This also has the effect to make the pdata and device tree handling code
symmetrical inside _dsa_register_switch.

At the same time, rename dsa_parse_ports_dn to dsa_parse_ports_of
because _of is a more common suffix for device tree parsing functions.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/dsa2.c | 33 ++++++++++-----------------------
 1 file changed, 10 insertions(+), 23 deletions(-)

diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index ec58654a71cd..26d2ff013eb1 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -589,11 +589,17 @@ static int dsa_dst_parse(struct dsa_switch_tree *dst)
 	return 0;
 }
 
-static int dsa_parse_ports_dn(struct device_node *ports, struct dsa_switch *ds)
+static int dsa_parse_ports_of(struct device_node *dn, struct dsa_switch *ds)
 {
-	struct device_node *port;
-	int err;
+	struct device_node *ports, *port;
 	u32 reg;
+	int err;
+
+	ports = of_get_child_by_name(dn, "ports");
+	if (!ports) {
+		dev_err(ds->dev, "no ports child node found\n");
+		return -EINVAL;
+	}
 
 	for_each_available_child_of_node(ports, port) {
 		err = of_property_read_u32(port, "reg", &reg);
@@ -664,26 +670,11 @@ static int dsa_parse_member(struct dsa_chip_data *pd, u32 *tree, u32 *index)
 	return 0;
 }
 
-static struct device_node *dsa_get_ports(struct dsa_switch *ds,
-					 struct device_node *np)
-{
-	struct device_node *ports;
-
-	ports = of_get_child_by_name(np, "ports");
-	if (!ports) {
-		dev_err(ds->dev, "no ports child node found\n");
-		return ERR_PTR(-EINVAL);
-	}
-
-	return ports;
-}
-
 static int _dsa_register_switch(struct dsa_switch *ds)
 {
 	struct dsa_chip_data *pdata = ds->dev->platform_data;
 	struct device_node *np = ds->dev->of_node;
 	struct dsa_switch_tree *dst;
-	struct device_node *ports;
 	u32 tree, index;
 	int i, err;
 
@@ -692,11 +683,7 @@ static int _dsa_register_switch(struct dsa_switch *ds)
 		if (err)
 			return err;
 
-		ports = dsa_get_ports(ds, np);
-		if (IS_ERR(ports))
-			return PTR_ERR(ports);
-
-		err = dsa_parse_ports_dn(ports, ds);
+		err = dsa_parse_ports_of(np, ds);
 		if (err)
 			return err;
 	} else {
-- 
2.14.3

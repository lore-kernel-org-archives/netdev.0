From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 2/7] net: dsa: add port parse functions
Date: Fri, 27 Oct 2017 15:55:14 -0400
Message-ID: <20171027195519.5931-3-vivien.didelot@savoirfairelinux.com>
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

Add symmetrical DSA port parsing functions for pdata and device tree,
used to parse and validate a given port node or platform data.

They don't do much for the moment but will be extended later on to
assign a port type and get device references.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/dsa2.c | 37 ++++++++++++++++++++++++++++++++++---
 1 file changed, 34 insertions(+), 3 deletions(-)

diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index 26d2ff013eb1..9b75d19d57cb 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -589,9 +589,17 @@ static int dsa_dst_parse(struct dsa_switch_tree *dst)
 	return 0;
 }
 
+static int dsa_port_parse_of(struct dsa_port *dp, struct device_node *dn)
+{
+	dp->dn = dn;
+
+	return 0;
+}
+
 static int dsa_parse_ports_of(struct device_node *dn, struct dsa_switch *ds)
 {
 	struct device_node *ports, *port;
+	struct dsa_port *dp;
 	u32 reg;
 	int err;
 
@@ -609,22 +617,45 @@ static int dsa_parse_ports_of(struct device_node *dn, struct dsa_switch *ds)
 		if (reg >= ds->num_ports)
 			return -EINVAL;
 
-		ds->ports[reg].dn = port;
+		dp = &ds->ports[reg];
+
+		err = dsa_port_parse_of(dp, port);
+		if (err)
+			return err;
 	}
 
 	return 0;
 }
 
+static int dsa_port_parse(struct dsa_port *dp, const char *name,
+			  struct device *dev)
+{
+	dp->name = name;
+
+	return 0;
+}
+
 static int dsa_parse_ports(struct dsa_chip_data *cd, struct dsa_switch *ds)
 {
 	bool valid_name_found = false;
+	struct dsa_port *dp;
+	struct device *dev;
+	const char *name;
 	unsigned int i;
+	int err;
 
 	for (i = 0; i < DSA_MAX_PORTS; i++) {
-		if (!cd->port_names[i])
+		name = cd->port_names[i];
+		dev = cd->netdev[i];
+		dp = &ds->ports[i];
+
+		if (!name)
 			continue;
 
-		ds->ports[i].name = cd->port_names[i];
+		err = dsa_port_parse(dp, name, dev);
+		if (err)
+			return err;
+
 		valid_name_found = true;
 	}
 
-- 
2.14.3

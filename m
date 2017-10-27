From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 6/7] net: dsa: get port name at parse time
Date: Fri, 27 Oct 2017 15:55:18 -0400
Message-ID: <20171027195519.5931-7-vivien.didelot@savoirfairelinux.com>
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

Get the optional "label" property and assign a default one directly at
parse time instead of doing it when creating the slave.

For legacy, simply assign the port name stored in cd->port_names.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/dsa2.c   | 10 +++++-----
 net/dsa/legacy.c |  1 +
 2 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index be43e06caf7e..f32fc0cd1bfe 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -260,11 +260,6 @@ static int dsa_user_port_apply(struct dsa_port *port)
 	const char *name = port->name;
 	int err;
 
-	if (port->dn)
-		name = of_get_property(port->dn, "label", NULL);
-	if (!name)
-		name = "eth%d";
-
 	err = dsa_slave_create(port, name);
 	if (err) {
 		dev_warn(ds->dev, "Failed to create slave %d: %d\n",
@@ -564,6 +559,7 @@ static int dsa_port_parse_of(struct dsa_port *dp, struct device_node *dn)
 {
 	struct device_node *ethernet = of_parse_phandle(dn, "ethernet", 0);
 	struct device_node *link = of_parse_phandle(dn, "link", 0);
+	const char *name = of_get_property(dn, "label", NULL);
 
 	if (ethernet) {
 		struct net_device *master;
@@ -577,7 +573,11 @@ static int dsa_port_parse_of(struct dsa_port *dp, struct device_node *dn)
 	} else if (link) {
 		dp->type = DSA_PORT_TYPE_DSA;
 	} else {
+		if (!name)
+			name = "eth%d";
+
 		dp->type = DSA_PORT_TYPE_USER;
+		dp->name = name;
 	}
 
 	dp->dn = dn;
diff --git a/net/dsa/legacy.c b/net/dsa/legacy.c
index 93e1b116ef83..3b50a5da0401 100644
--- a/net/dsa/legacy.c
+++ b/net/dsa/legacy.c
@@ -115,6 +115,7 @@ static int dsa_switch_setup_one(struct dsa_switch *ds,
 		name = cd->port_names[i];
 		if (name == NULL)
 			continue;
+		dp->name = name;
 
 		if (!strcmp(name, "cpu")) {
 			if (dst->cpu_dp) {
-- 
2.14.3

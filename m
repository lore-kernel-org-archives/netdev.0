From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next] net: dsa: assign default CPU port to all ports
Date: Thu, 15 Jun 2017 15:06:54 -0400
Message-ID: <20170615190654.5927-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Jason Cobham <jcobham@questertangent.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The current code only assigns the default cpu_dp to all user ports of
the switch to which the CPU port belongs. The user ports of the other
switches of the fabric thus don't have a default CPU port.

This patch fixes this by assigning the cpu_dp of all user ports of all
switches of the fabric when the tree is fully parsed.

Fixes: a29342e73911 ("net: dsa: Associate slave network device with CPU port")
Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/dsa2.c | 30 +++++++++++++++++++-----------
 1 file changed, 19 insertions(+), 11 deletions(-)

diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index 52af8401af07..56e46090526b 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -490,8 +490,6 @@ static int dsa_cpu_parse(struct dsa_port *port, u32 index,
 	enum dsa_tag_protocol tag_protocol;
 	struct net_device *ethernet_dev;
 	struct device_node *ethernet;
-	struct dsa_port *p;
-	unsigned int i;
 
 	if (port->dn) {
 		ethernet = of_parse_phandle(port->dn, "ethernet", 0);
@@ -509,15 +507,6 @@ static int dsa_cpu_parse(struct dsa_port *port, u32 index,
 	if (!dst->cpu_dp) {
 		dst->cpu_dp = port;
 		dst->cpu_dp->netdev = ethernet_dev;
-
-		for (i = 0; i < ds->num_ports; i++) {
-			p = &ds->ports[i];
-			if (!dsa_port_is_valid(p) ||
-			    i == index)
-				continue;
-
-			p->cpu_dp = port;
-		}
 	}
 
 	tag_protocol = ds->ops->get_tag_protocol(ds);
@@ -572,7 +561,9 @@ static int dsa_ds_parse(struct dsa_switch_tree *dst, struct dsa_switch *ds)
 static int dsa_dst_parse(struct dsa_switch_tree *dst)
 {
 	struct dsa_switch *ds;
+	struct dsa_port *dp;
 	u32 index;
+	int port;
 	int err;
 
 	for (index = 0; index < DSA_MAX_SWITCHES; index++) {
@@ -590,6 +581,23 @@ static int dsa_dst_parse(struct dsa_switch_tree *dst)
 		return -EINVAL;
 	}
 
+	/* Assign the default CPU port to all ports of the fabric */
+	for (index = 0; index < DSA_MAX_SWITCHES; index++) {
+		ds = dst->ds[index];
+		if (!ds)
+			continue;
+
+		for (port = 0; port < ds->num_ports; port++) {
+			dp = &ds->ports[port];
+			if (!dsa_port_is_valid(dp) ||
+			    dsa_port_is_dsa(dp) ||
+			    dsa_port_is_cpu(dp))
+				continue;
+
+			dp->cpu_dp = dst->cpu_dp;
+		}
+	}
+
 	pr_info("DSA: tree %d parsed\n", dst->tree);
 
 	return 0;
-- 
2.13.1

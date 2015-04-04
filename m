From: Pavel Nakonechny <pavel.nakonechny@skitlab.ru>
Subject: [PATCH v2] net: dsa: fix filling routing table from OF description
Date: Sun, 05 Apr 2015 00:46:21 +0300
Message-ID: <1516684.D2TdrA1BPT@kuro.zhome>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <robh+dt@kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Fabian Frederick <fabf@skynet.be>, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

According to description in 'include/net/dsa.h', in cascade switches
configurations where there are more than one interconnected devices,
'rtable' array in 'dsa_chip_data' structure is used to indicate which
port on this switch should be used to send packets to that are destined
for corresponding switch.

However, dsa_of_setup_routing_table() fills 'rtable' with port numbers
of the _target_ switch, but not current one.

This commit removes redundant devicetree parsing and adds needed port
number as a function argument. So dsa_of_setup_routing_table() now just
looks for target switch number by parsing parent of 'link' device node.

To remove possible misunderstandings with the way of determining target
switch number, a corresponding comment was added to the source code and
to the DSA device tree bindings documentation file.

This was tested on a custom board with two Marvell 88E6095 switches with
following corresponding routing tables: { -1, 10 } and { 8, -1 }.

Signed-off-by: Pavel Nakonechny <pavel.nakonechny@skitlab.ru>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
---
 Documentation/devicetree/bindings/net/dsa/dsa.txt |  4 +++-
 net/dsa/dsa.c                                     | 23 +++++++----------------
 2 files changed, 10 insertions(+), 17 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/dsa/dsa.txt b/Documentation/devicetree/bindings/net/dsa/dsa.txt
index a62c889..e25e58d 100644
--- a/Documentation/devicetree/bindings/net/dsa/dsa.txt
+++ b/Documentation/devicetree/bindings/net/dsa/dsa.txt
@@ -19,7 +19,9 @@ the parent DSA node. The maximum number of allowed child nodes is 4
 (DSA_MAX_SWITCHES).
 Each of these switch child nodes should have the following required properties:
 
-- reg			: Describes the switch address on the MII bus
+- reg			: Contains two fields. The first one describes the
+			  address on the MII bus. The second is the switch
+			  number that must be unique in cascaded configurations
 - #address-cells	: Must be 1
 - #size-cells		: Must be 0
 
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 947f550..1d56f84 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -375,12 +375,10 @@ static struct net_device *dev_to_net_device(struct device *dev)
 #ifdef CONFIG_OF
 static int dsa_of_setup_routing_table(struct dsa_platform_data *pd,
 					struct dsa_chip_data *cd,
-					int chip_index,
+					int chip_index, int port_index,
 					struct device_node *link)
 {
-	int ret;
 	const __be32 *reg;
-	int link_port_addr;
 	int link_sw_addr;
 	struct device_node *parent_sw;
 	int len;
@@ -393,6 +391,10 @@ static int dsa_of_setup_routing_table(struct dsa_platform_data *pd,
 	if (!reg || (len != sizeof(*reg) * 2))
 		return -EINVAL;
 
+	/*
+	 * Get the destination switch number from the second field of its 'reg'
+	 * property, i.e. for "reg = <0x19 1>" sw_addr is '1'.
+	 */
 	link_sw_addr = be32_to_cpup(reg + 1);
 
 	if (link_sw_addr >= pd->nr_chips)
@@ -409,20 +411,9 @@ static int dsa_of_setup_routing_table(struct dsa_platform_data *pd,
 		memset(cd->rtable, -1, pd->nr_chips * sizeof(s8));
 	}
 
-	reg = of_get_property(link, "reg", NULL);
-	if (!reg) {
-		ret = -EINVAL;
-		goto out;
-	}
-
-	link_port_addr = be32_to_cpup(reg);
-
-	cd->rtable[link_sw_addr] = link_port_addr;
+	cd->rtable[link_sw_addr] = port_index;
 
 	return 0;
-out:
-	kfree(cd->rtable);
-	return ret;
 }
 
 static void dsa_of_free_platform_data(struct dsa_platform_data *pd)
@@ -528,7 +519,7 @@ static int dsa_of_probe(struct platform_device *pdev)
 			if (!strcmp(port_name, "dsa") && link &&
 					pd->nr_chips > 1) {
 				ret = dsa_of_setup_routing_table(pd, cd,
-						chip_index, link);
+						chip_index, port_index, link);
 				if (ret)
 					goto out_free_chip;
 			}
-- 
2.1.4

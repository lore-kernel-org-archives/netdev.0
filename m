From: Pavel Nakonechny <pavel.nakonechny@skitlab.ru>
Subject: [PATCH] net: dsa: fix filling rtable from OF description
Date: Sat, 04 Apr 2015 16:48:48 +0300
Message-ID: <1941340.ZSOIoOXLWB@pavel.skitlab.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <robh+dt@kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Fabian Frederick <fabf@skynet.be>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Joe Perches <joe@perches.com>, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.skitlab.ru ([188.235.132.142]:57473 "EHLO mail.skitlab.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752133AbbDDNzr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Apr 2015 09:55:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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

This was tested on custom board with two Marvell 88E6095 switches with
following corresponding rtables: { -1, 10 } and { 8, -1 }.

Signed-off-by: Pavel Nakonechny <pavel.nakonechny@skitlab.ru>
---
 net/dsa/dsa.c | 19 +++----------------
 1 file changed, 3 insertions(+), 16 deletions(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 947f550..5593a0d 100644
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
@@ -409,20 +407,9 @@ static int dsa_of_setup_routing_table(struct dsa_platform_data *pd,
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
@@ -528,7 +515,7 @@ static int dsa_of_probe(struct platform_device *pdev)
 			if (!strcmp(port_name, "dsa") && link &&
 					pd->nr_chips > 1) {
 				ret = dsa_of_setup_routing_table(pd, cd,
-						chip_index, link);
+						chip_index, port_index, link);
 				if (ret)
 					goto out_free_chip;
 			}
-- 

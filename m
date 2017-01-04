From: John Crispin <john@phrozen.org>
Subject: [RFC 2/4] net-next: dsa: Refactor DT probing of a switch port
Date: Wed,  4 Jan 2017 08:38:02 +0100
Message-ID: <1483515484-21793-3-git-send-email-john@phrozen.org>
References: <1483515484-21793-1-git-send-email-john@phrozen.org>
Cc: netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:60136 "EHLO nbd.name"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751541AbdADHiP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 4 Jan 2017 02:38:15 -0500
In-Reply-To: <1483515484-21793-1-git-send-email-john@phrozen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>

Move the DT probing of a switch port into a function of its own, since
it is about to get more complex. Add better error handling as well.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 net/dsa/dsa.c |  138 ++++++++++++++++++++++++++++++++++++++++++---------------
 1 file changed, 102 insertions(+), 36 deletions(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 7899919..0e0621c 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -326,14 +326,10 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
 			continue;
 
 		if (!strcmp(name, "cpu")) {
-			if (dst->cpu_switch != -1) {
-				netdev_err(dst->master_netdev,
-					   "multiple cpu ports?!\n");
-				ret = -EINVAL;
-				goto out;
+			if (dst->cpu_switch == -1) {
+				dst->cpu_switch = index;
+				dst->cpu_port = i;
 			}
-			dst->cpu_switch = index;
-			dst->cpu_port = i;
 			ds->cpu_port_mask |= 1 << i;
 		} else if (!strcmp(name, "dsa")) {
 			ds->dsa_port_mask |= 1 << i;
@@ -709,11 +705,15 @@ static void dsa_of_free_platform_data(struct dsa_platform_data *pd)
 {
 	int i;
 	int port_index;
+	struct dsa_chip_data *cd;
 
 	for (i = 0; i < pd->nr_chips; i++) {
+		cd = &pd->chip[i];
 		port_index = 0;
 		while (port_index < DSA_MAX_PORTS) {
-			kfree(pd->chip[i].port_names[port_index]);
+			kfree(cd->port_names[port_index]);
+			if (cd->port_ethernet[port_index])
+				dev_put(cd->port_ethernet[port_index]);
 			port_index++;
 		}
 
@@ -724,6 +724,94 @@ static void dsa_of_free_platform_data(struct dsa_platform_data *pd)
 	kfree(pd->chip);
 }
 
+static int dsa_of_probe_cpu_port(struct dsa_chip_data *cd,
+				 struct device_node *port,
+				 int port_index)
+{
+	struct net_device *ethernet_dev;
+	struct device_node *ethernet;
+
+	ethernet = of_parse_phandle(port, "ethernet", 0);
+	if (ethernet) {
+		ethernet_dev = of_find_net_device_by_node(ethernet);
+		if (!ethernet_dev)
+			return -EPROBE_DEFER;
+
+		dev_hold(ethernet_dev);
+		cd->port_ethernet[port_index] = ethernet_dev;
+	}
+
+	return 0;
+}
+
+static int dsa_of_probe_user_port(struct dsa_chip_data *cd,
+				  struct device_node *port,
+				  int port_index)
+{
+	struct device_node *cpu_port;
+	const unsigned int *cpu_port_reg;
+	int cpu_port_index;
+
+	cpu_port = of_parse_phandle(port, "cpu", 0);
+	if (cpu_port) {
+		cpu_port_reg = of_get_property(cpu_port, "reg", NULL);
+		if (!cpu_port_reg)
+			return -EINVAL;
+		cpu_port_index = be32_to_cpup(cpu_port_reg);
+		cd->port_cpu[port_index] = cpu_port_index;
+	}
+
+	return 0;
+}
+
+static int dsa_of_probe_port(struct dsa_platform_data *pd,
+			     struct dsa_chip_data *cd,
+			     int chip_index,
+			     struct device_node *port)
+{
+	bool is_cpu_port = false, is_dsa_port = false;
+	bool is_user_port = false;
+	const unsigned int *port_reg;
+	const char *port_name;
+	int port_index, ret = 0;
+
+	port_reg = of_get_property(port, "reg", NULL);
+	if (!port_reg)
+		return -EINVAL;
+
+	port_index = be32_to_cpup(port_reg);
+
+	port_name = of_get_property(port, "label", NULL);
+	if (!port_name)
+		return -EINVAL;
+
+	if (!strcmp(port_name, "cpu"))
+		is_cpu_port = true;
+	if (!strcmp(port_name, "dsa"))
+		is_dsa_port = true;
+	if (!is_cpu_port && !is_dsa_port)
+		is_user_port = true;
+
+	cd->port_dn[port_index] = port;
+
+	cd->port_names[port_index] = kstrdup(port_name,
+			GFP_KERNEL);
+	if (!cd->port_names[port_index])
+		return -ENOMEM;
+
+	if (is_dsa_port)
+		ret = dsa_of_probe_links(pd, cd, chip_index,
+					 port_index, port, port_name);
+	if (is_cpu_port)
+		ret = dsa_of_probe_cpu_port(cd, port, port_index);
+	if (is_user_port)
+		ret = dsa_of_probe_user_port(cd, port, port_index);
+	if (ret)
+		return ret;
+
+	return port_index;
+}
+
 static int dsa_of_probe(struct device *dev)
 {
 	struct device_node *np = dev->of_node;
@@ -732,9 +820,8 @@ static int dsa_of_probe(struct device *dev)
 	struct net_device *ethernet_dev;
 	struct dsa_platform_data *pd;
 	struct dsa_chip_data *cd;
-	const char *port_name;
-	int chip_index, port_index;
-	const unsigned int *sw_addr, *port_reg;
+	int chip_index;
+	const unsigned int *sw_addr;
 	u32 eeprom_len;
 	int ret;
 
@@ -821,32 +908,11 @@ static int dsa_of_probe(struct device *dev)
 		}
 
 		for_each_available_child_of_node(child, port) {
-			port_reg = of_get_property(port, "reg", NULL);
-			if (!port_reg)
-				continue;
-
-			port_index = be32_to_cpup(port_reg);
-			if (port_index >= DSA_MAX_PORTS)
-				break;
-
-			port_name = of_get_property(port, "label", NULL);
-			if (!port_name)
-				continue;
-
-			cd->port_dn[port_index] = port;
-
-			cd->port_names[port_index] = kstrdup(port_name,
-					GFP_KERNEL);
-			if (!cd->port_names[port_index]) {
-				ret = -ENOMEM;
+			ret = dsa_of_probe_port(pd, cd, chip_index, port);
+			if (ret < 0)
 				goto out_free_chip;
-			}
-
-			ret = dsa_of_probe_links(pd, cd, chip_index,
-						 port_index, port, port_name);
-			if (ret)
-				goto out_free_chip;
-
+			if (ret == DSA_MAX_PORTS)
+				break;
 		}
 	}
 
-- 
1.7.10.4

From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH RFC 2/3] dsa: Add support for multiple cpu ports.
Date: Fri, 29 May 2015 21:13:33 +0200
Message-ID: <1432926814-22648-3-git-send-email-andrew@lunn.ch>
References: <1432926814-22648-1-git-send-email-andrew@lunn.ch>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>, mathieu@codeaurora.org,
	Andrew Lunn <andrew@lunn.ch>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:48114 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756545AbbE2TS6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 May 2015 15:18:58 -0400
In-Reply-To: <1432926814-22648-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some boards have two CPU interfaces connected to the switch, e.g. WiFi
access points, with 1 port labeled WAN, 4 ports labeled lan1-lan4, and
two port connected to the SoC.

This patch extends DSA to allows both CPU ports to be used. The "cpu"
node in the DSA tree can now have a phandle to the host interface it
connects to. Each user port can have a phandle to a cpu port which
should be used for traffic between the port and the CPU. Thus simple
load sharing over the two CPU ports can be achieved.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 Documentation/devicetree/bindings/net/dsa/dsa.txt |  66 ++++++++++++-
 drivers/net/dsa/mv88e6xxx.c                       |   8 +-
 include/net/dsa.h                                 |  28 +++++-
 net/dsa/dsa.c                                     | 109 ++++++++++++++++++----
 net/dsa/dsa_priv.h                                |   6 ++
 net/dsa/slave.c                                   |  10 +-
 net/dsa/tag_brcm.c                                |   2 +-
 net/dsa/tag_dsa.c                                 |   2 +-
 net/dsa/tag_edsa.c                                |   2 +-
 net/dsa/tag_trailer.c                             |   2 +-
 10 files changed, 206 insertions(+), 29 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/dsa/dsa.txt b/Documentation/devicetree/bindings/net/dsa/dsa.txt
index f0b4cd72411d..34f7f18026e5 100644
--- a/Documentation/devicetree/bindings/net/dsa/dsa.txt
+++ b/Documentation/devicetree/bindings/net/dsa/dsa.txt
@@ -58,13 +58,24 @@ Optionnal property:
 			  Documentation/devicetree/bindings/net/ethernet.txt
 			  for details.
 
+- ethernet		: Optional for "cpu" ports. A phandle to an ethernet
+                          device which will be used by this CPU port for
+			  passing packets to/from the host. If not present,
+			  the port will use the "dsa,ethernet" property
+			  defined above.
+
+- cpu			: Option for non "cpu"/"dsa" ports. A phandle to a
+			  "cpu" port, which will be used for passing packets
+			  from this port to the host. If not present, the first
+			  "cpu" port will be used.
+
 Optional subnodes:
 - fixed-link		: Fixed-link subnode describing a link to a non-MDIO
 			  managed entity. See
 			  Documentation/devicetree/bindings/net/fixed-link.txt
 			  for details.
 
-Example:
+Examples:
 
 	dsa@0 {
 		compatible = "marvell,dsa";
@@ -115,3 +126,56 @@ Example:
 			};
 		};
 	};
+
+	dsa@1 {
+		compatible = "marvell,dsa";
+		#address-cells = <2>;
+		#size-cells = <0>;
+
+		dsa,ethernet = <&eth0port>;
+		dsa,mii-bus = <&mdio>;
+
+		switch@0 {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			reg = <0 0>;	/* MDIO address 0, switch 0 in tree */
+
+			port@0 {
+				reg = <0>;
+				label = "lan4";
+			};
+
+			port@1 {
+				reg = <1>;
+				label = "lan3";
+				cpu = <&cpu1>;
+			};
+
+			port@2 {
+				reg = <2>;
+				label = "lan2";
+			};
+
+			port@3 {
+				reg = <3>;
+				label = "lan1";
+				cpu = <&cpu1>;
+			};
+
+			port@4 {
+				reg = <4>;
+				label = "wan";
+			};
+
+			port@5 {
+				reg = <5>;
+				label = "cpu";
+			};
+
+			cpu1: port@6 {
+				reg = <6>;
+				label = "cpu";
+				ethernet = <&eth1port>;
+			};
+		};
+	};
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 7fba330ce702..13e487f5bcdc 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1051,7 +1051,7 @@ static int _mv88e6xxx_update_port_config(struct dsa_switch *ds, int port)
 		reg |= ds->phys_port_mask;
 	else
 		reg |= (ps->bridge_mask[fid] |
-		       (1 << dsa_upstream_port(ds))) & ~(1 << port);
+			(1 << dsa_port_upstream_port(ds, port))) & ~(1 << port);
 
 	return _mv88e6xxx_reg_write(ds, REG_PORT(port), PORT_BASE_VLAN, reg);
 }
@@ -1433,7 +1433,7 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 	    mv88e6xxx_6095_family(ds) || mv88e6xxx_6065_family(ds)) {
 		if (ds->dsa_port_mask & (1 << port))
 			reg |= PORT_CONTROL_FRAME_MODE_DSA;
-		if (port == dsa_upstream_port(ds))
+		if (dsa_is_upstream_port(ds, port))
 			reg |= PORT_CONTROL_FORWARD_UNKNOWN |
 				PORT_CONTROL_FORWARD_UNKNOWN_MC;
 	}
@@ -1464,11 +1464,11 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 
 	if (mv88e6xxx_6095_family(ds) || mv88e6xxx_6185_family(ds)) {
 		/* Set the upstream port this port should use */
-		reg |= dsa_upstream_port(ds);
+		reg |= dsa_port_upstream_port(ds, port);
 		/* enable forwarding of unknown multicast addresses to
 		 * the upstream port
 		 */
-		if (port == dsa_upstream_port(ds))
+		if (dsa_is_upstream_port(ds, port))
 			reg |= PORT_CONTROL_2_FORWARD_UNKNOWN;
 	}
 
diff --git a/include/net/dsa.h b/include/net/dsa.h
index fbca63ba8f73..137870732a36 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -56,6 +56,8 @@ struct dsa_chip_data {
 	 */
 	char		*port_names[DSA_MAX_PORTS];
 	struct device_node *port_dn[DSA_MAX_PORTS];
+	struct net_device *port_ethernet[DSA_MAX_PORTS];
+	int		port_cpu[DSA_MAX_PORTS];
 
 	/*
 	 * An array (with nr_chips elements) of which element [a]
@@ -160,6 +162,7 @@ struct dsa_switch {
 	 * Slave mii_bus and devices for the individual ports.
 	 */
 	u32			dsa_port_mask;
+	u32			cpu_port_mask;
 	u32			phys_port_mask;
 	u32			phys_mii_mask;
 	struct mii_bus		*slave_mii_bus;
@@ -168,7 +171,12 @@ struct dsa_switch {
 
 static inline bool dsa_is_cpu_port(struct dsa_switch *ds, int p)
 {
-	return !!(ds->index == ds->dst->cpu_switch && p == ds->dst->cpu_port);
+	return ds->cpu_port_mask & (1 << p);
+}
+
+static inline bool dsa_is_dsa_port(struct dsa_switch *ds, int p)
+{
+	return ds->dsa_port_mask & (1 << p);
 }
 
 static inline bool dsa_is_port_initialized(struct dsa_switch *ds, int p)
@@ -176,6 +184,11 @@ static inline bool dsa_is_port_initialized(struct dsa_switch *ds, int p)
 	return ds->phys_port_mask & (1 << p) && ds->ports[p];
 }
 
+static inline bool dsa_is_upstream_port(struct dsa_switch *ds, int p)
+{
+	return dsa_is_cpu_port(ds, p) || dsa_is_dsa_port(ds, p);
+}
+
 static inline u8 dsa_upstream_port(struct dsa_switch *ds)
 {
 	struct dsa_switch_tree *dst = ds->dst;
@@ -192,6 +205,19 @@ static inline u8 dsa_upstream_port(struct dsa_switch *ds)
 		return ds->pd->rtable[dst->cpu_switch];
 }
 
+static inline u8 dsa_port_upstream_port(struct dsa_switch *ds, int port)
+{
+
+	/*
+	 * If this port has a specific upstream cpu port, use it,
+	 * otherwise use the switch default.
+	 */
+	if (ds->pd->port_cpu[port])
+		return ds->pd->port_cpu[port];
+	else
+		return dsa_upstream_port(ds);
+}
+
 struct dsa_switch_driver {
 	struct list_head	list;
 
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index b7b72d398d00..326643bbf64e 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -196,14 +196,11 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
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
+			ds->cpu_port_mask |= 1 << i;
 		} else if (!strcmp(name, "dsa")) {
 			ds->dsa_port_mask |= 1 << i;
 		} else {
@@ -211,6 +208,11 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
 		}
 		valid_name_found = true;
 	}
+	pr_info("cpu_port_mask %x\n", ds->cpu_port_mask);
+	pr_info("dsa_port_mask %x\n", ds->dsa_port_mask);
+	pr_info("phys_port_mask %x\n", ds->phys_port_mask);
+	pr_info("cpu_switch %d\n", dst->cpu_switch);
+	pr_info("cpu_port %d\n", dst->cpu_port);
 
 	if (!valid_name_found && i == DSA_MAX_PORTS) {
 		ret = -EINVAL;
@@ -558,11 +560,15 @@ static void dsa_of_free_platform_data(struct dsa_platform_data *pd)
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
 		kfree(pd->chip[i].rtable);
@@ -570,15 +576,74 @@ static void dsa_of_free_platform_data(struct dsa_platform_data *pd)
 	kfree(pd->chip);
 }
 
+static int dsa_of_probe_dsa_port(struct dsa_platform_data *pd,
+				 struct dsa_chip_data *cd,
+				 int chip_index, struct device_node *port,
+				 int port_index)
+{
+	struct device_node *link;
+
+	link = of_parse_phandle(port, "link", 0);
+	if (!link)
+		return -EINVAL;
+
+	if (pd->nr_chips == 1)
+		return -EINVAL;
+
+	return dsa_of_setup_routing_table(pd, cd, chip_index, port_index,
+					  link);
+}
+
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
 static int dsa_of_probe_port(struct dsa_platform_data *pd,
 			     struct dsa_chip_data *cd,
 			     int chip_index,
 			     struct device_node *port)
 {
+	bool is_cpu_port = false, is_dsa_port = false;
+	bool is_user_port = false;
 	const unsigned int *port_reg;
 	const char *port_name;
-	struct device_node *link;
-	int port_index, ret;
+	int port_index, ret = 0;
 
 	port_reg = of_get_property(port, "reg", NULL);
 	if (!port_reg)
@@ -590,20 +655,28 @@ static int dsa_of_probe_port(struct dsa_platform_data *pd,
 	if (!port_name)
 		return -EINVAL;
 
+	if (!strcmp(port_name, "cpu"))
+		is_cpu_port = true;
+	if (!strcmp(port_name, "dsa"))
+		is_dsa_port = true;
+	if (!is_cpu_port && !is_dsa_port)
+		is_user_port = true;
+
 	cd->port_dn[port_index] = port;
 
 	cd->port_names[port_index] = kstrdup(port_name, GFP_KERNEL);
 	if (!cd->port_names[port_index])
 		return -ENOMEM;
 
-	link = of_parse_phandle(port, "link", 0);
-
-	if (!strcmp(port_name, "dsa") && link && pd->nr_chips > 1) {
-		ret = dsa_of_setup_routing_table(pd, cd,
-						 chip_index, port_index, link);
-		if (ret)
-			return ret;
-	}
+	if (is_dsa_port)
+		ret = dsa_of_probe_dsa_port(pd, cd, chip_index, port,
+					    port_index);
+	if (is_cpu_port)
+		ret = dsa_of_probe_cpu_port(cd, port, port_index);
+	if (is_user_port)
+		ret = dsa_of_probe_user_port(cd, port, port_index);
+	if (ret)
+		return ret;
 
 	return port_index;
 }
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index d5f1f9b862ea..7f11beef1b50 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -30,6 +30,12 @@ struct dsa_slave_priv {
 					struct net_device *dev);
 
 	/*
+	 * Which host device do we used to send packets to the switch
+	 * for this port.
+	 */
+	struct net_device	*master;
+
+	/*
 	 * Which switch this port is a part of, and the port index
 	 * for this port.
 	 */
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 04ffad311704..b1ca6a63b090 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -875,11 +875,18 @@ int dsa_slave_resume(struct net_device *slave_dev)
 int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 		     int port, char *name)
 {
-	struct net_device *master = ds->dst->master_netdev;
+	struct net_device *master;
 	struct net_device *slave_dev;
 	struct dsa_slave_priv *p;
+	int port_cpu = ds->pd->port_cpu[port];
 	int ret;
 
+	if (port_cpu && ds->pd->port_ethernet[port_cpu])
+		master = ds->pd->port_ethernet[port_cpu];
+	else
+		master = ds->dst->master_netdev;
+	master->dsa_ptr = (void *)ds->dst;
+
 	slave_dev = alloc_netdev(sizeof(struct dsa_slave_priv), name,
 				 NET_NAME_UNKNOWN, ether_setup);
 	if (slave_dev == NULL)
@@ -903,6 +910,7 @@ int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 	p->dev = slave_dev;
 	p->parent = ds;
 	p->port = port;
+	p->master = master;
 
 	switch (ds->dst->tag_protocol) {
 #ifdef CONFIG_NET_DSA_TAG_DSA
diff --git a/net/dsa/tag_brcm.c b/net/dsa/tag_brcm.c
index 83d3572cdb20..0367ddd9bed5 100644
--- a/net/dsa/tag_brcm.c
+++ b/net/dsa/tag_brcm.c
@@ -90,7 +90,7 @@ static netdev_tx_t brcm_tag_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* Queue the SKB for transmission on the parent interface, but
 	 * do not modify its EtherType
 	 */
-	skb->dev = p->parent->dst->master_netdev;
+	skb->dev = p->master;
 	dev_queue_xmit(skb);
 
 	return NETDEV_TX_OK;
diff --git a/net/dsa/tag_dsa.c b/net/dsa/tag_dsa.c
index 2dab27063273..11ae958e7125 100644
--- a/net/dsa/tag_dsa.c
+++ b/net/dsa/tag_dsa.c
@@ -63,7 +63,7 @@ static netdev_tx_t dsa_xmit(struct sk_buff *skb, struct net_device *dev)
 		dsa_header[3] = 0x00;
 	}
 
-	skb->dev = p->parent->dst->master_netdev;
+	skb->dev = p->master;
 	dev_queue_xmit(skb);
 
 	return NETDEV_TX_OK;
diff --git a/net/dsa/tag_edsa.c b/net/dsa/tag_edsa.c
index 9aeda596f7ec..87df439985e2 100644
--- a/net/dsa/tag_edsa.c
+++ b/net/dsa/tag_edsa.c
@@ -76,7 +76,7 @@ static netdev_tx_t edsa_xmit(struct sk_buff *skb, struct net_device *dev)
 		edsa_header[7] = 0x00;
 	}
 
-	skb->dev = p->parent->dst->master_netdev;
+	skb->dev = p->master;
 	dev_queue_xmit(skb);
 
 	return NETDEV_TX_OK;
diff --git a/net/dsa/tag_trailer.c b/net/dsa/tag_trailer.c
index e268f9db8893..fa8895341d46 100644
--- a/net/dsa/tag_trailer.c
+++ b/net/dsa/tag_trailer.c
@@ -57,7 +57,7 @@ static netdev_tx_t trailer_xmit(struct sk_buff *skb, struct net_device *dev)
 	trailer[2] = 0x10;
 	trailer[3] = 0x00;
 
-	nskb->dev = p->parent->dst->master_netdev;
+	nskb->dev = p->master;
 	dev_queue_xmit(nskb);
 
 	return NETDEV_TX_OK;
-- 
2.1.4

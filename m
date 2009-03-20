From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 3/3] dsa: add switch chip cascading support
Date: Fri, 20 Mar 2009 20:52:09 +0100
Message-ID: <20090320195209.GW4738@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gary Thomas <gary@mlbassoc.com>,
	Jesper Dangaard Brouer <hawk@diku.dk>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:53136 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757442AbZCTTwO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2009 15:52:14 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The initial version of the DSA driver only supported a single switch
chip per network interface, while DSA-capable switch chips can be
interconnected to form a tree of switch chips.  This patch adds support
for multiple switch chips on a network interface.

An example topology for a 16-port device with an embedded CPU is as
follows:

	+-----+          +--------+       +--------+
	|     |eth0    10| switch |9    10| switch |
	| CPU +----------+        +-------+        |
	|     |          | chip 0 |       | chip 1 |
	+-----+          +---++---+       +---++---+
	                     ||               ||
	                     ||               ||
	                     ||1000baseT      ||1000baseT
	                     ||ports 1-8      ||ports 9-16

This requires a couple of interdependent changes in the DSA layer:

- The dsa platform driver data needs to be extended: there is still
  only one netdevice per DSA driver instance (eth0 in the example
  above), but each of the switch chips in the tree needs its own
  mii_bus device pointer, MII management bus address, and port name
  array. (include/net/dsa.h)  The existing in-tree dsa users need
  some small changes to deal with this. (arch/arm)

- The DSA and Ethertype DSA tagging modules need to be extended to
  use the DSA device ID field on receive and demultiplex the packet
  accordingly, and fill in the DSA device ID field on transmit
  according to which switch chip the packet is heading to.
  (net/dsa/tag_{dsa,edsa}.c)

- The concept of "CPU port", which is the switch chip port that the
  CPU is connected to (port 10 on switch chip 0 in the example), needs
  to be extended with the concept of "upstream port", which is the
  port on the switch chip that will bring us one hop closer to the CPU
  (port 10 for both switch chips in the example above).

- The dsa platform data needs to specify which ports on which switch
  chips are links to other switch chips, so that we can enable DSA
  tagging mode on them.  (For inter-switch links, we always use
  non-EtherType DSA tagging, since it has lower overhead.  The CPU
  link uses dsa or edsa tagging depending on what the 'root' switch
  chip supports.)  This is done by specifying "dsa" for the given
  port in the port array.

- The dsa platform data needs to be extended with information on via
  which port to reach any given switch chip from any given switch chip.
  This info is specified via the per-switch chip data struct ->rtable[]
  array, which gives the nexthop ports for each of the other switches
  in the tree.

For the example topology above, the dsa platform data would look
something like this:

	static struct dsa_chip_data sw[2] = {
		{
			.mii_bus	= &foo,
			.sw_addr	= 1,
			.port_names[0]	= "p1",
			.port_names[1]	= "p2",
			.port_names[2]	= "p3",
			.port_names[3]	= "p4",
			.port_names[4]	= "p5",
			.port_names[5]	= "p6",
			.port_names[6]	= "p7",
			.port_names[7]	= "p8",
			.port_names[9]	= "dsa",
			.port_names[10]	= "cpu",
			.rtable		= (s8 []){ -1, 9, },
		}, {
			.mii_bus	= &foo,
			.sw_addr	= 2,
			.port_names[0]	= "p9",
			.port_names[1]	= "p10",
			.port_names[2]	= "p11",
			.port_names[3]	= "p12",
			.port_names[4]	= "p13",
			.port_names[5]	= "p14",
			.port_names[6]	= "p15",
			.port_names[7]	= "p16",
			.port_names[10]	= "dsa",
			.rtable		= (s8 []){ 10, -1, },
		},
	},

	static struct dsa_platform_data pd = {
		.netdev		= &foo,
		.nr_switches	= 2,
		.sw		= sw,
	};

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
Tested-by: Gary Thomas <gary@mlbassoc.com>
---
 arch/arm/mach-kirkwood/common.c              |    5 +-
 arch/arm/mach-kirkwood/rd88f6281-setup.c     |   13 ++-
 arch/arm/mach-orion5x/common.c               |    5 +-
 arch/arm/mach-orion5x/rd88f5181l-fxo-setup.c |    9 +-
 arch/arm/mach-orion5x/rd88f5181l-ge-setup.c  |   10 +-
 arch/arm/mach-orion5x/rd88f6183ap-ge-setup.c |   10 +-
 arch/arm/mach-orion5x/wrt350n-v2-setup.c     |    9 +-
 include/net/dsa.h                            |   42 +++++--
 net/dsa/dsa.c                                |  177 ++++++++++++++++----------
 net/dsa/dsa_priv.h                           |   97 ++++++++++++---
 net/dsa/mv88e6060.c                          |   12 +-
 net/dsa/mv88e6123_61_65.c                    |   88 ++++++++-----
 net/dsa/mv88e6131.c                          |   78 +++++++----
 net/dsa/slave.c                              |   25 ++--
 net/dsa/tag_dsa.c                            |   30 +++--
 net/dsa/tag_edsa.c                           |   30 +++--
 net/dsa/tag_trailer.c                        |   10 +-
 17 files changed, 441 insertions(+), 209 deletions(-)

diff --git a/arch/arm/mach-kirkwood/common.c b/arch/arm/mach-kirkwood/common.c
index b3404b7..0d2074f 100644
--- a/arch/arm/mach-kirkwood/common.c
+++ b/arch/arm/mach-kirkwood/common.c
@@ -231,14 +231,17 @@ static struct platform_device kirkwood_switch_device = {
 
 void __init kirkwood_ge00_switch_init(struct dsa_platform_data *d, int irq)
 {
+	int i;
+
 	if (irq != NO_IRQ) {
 		kirkwood_switch_resources[0].start = irq;
 		kirkwood_switch_resources[0].end = irq;
 		kirkwood_switch_device.num_resources = 1;
 	}
 
-	d->mii_bus = &kirkwood_ge00_shared.dev;
 	d->netdev = &kirkwood_ge00.dev;
+	for (i = 0; i < d->nr_chips; i++)
+		d->chip[i].mii_bus = &kirkwood_ge00_shared.dev;
 	kirkwood_switch_device.dev.platform_data = d;
 
 	platform_device_register(&kirkwood_switch_device);
diff --git a/arch/arm/mach-kirkwood/rd88f6281-setup.c b/arch/arm/mach-kirkwood/rd88f6281-setup.c
index 9a0e905..e1c0516 100644
--- a/arch/arm/mach-kirkwood/rd88f6281-setup.c
+++ b/arch/arm/mach-kirkwood/rd88f6281-setup.c
@@ -75,7 +75,7 @@ static struct mv643xx_eth_platform_data rd88f6281_ge00_data = {
 	.duplex		= DUPLEX_FULL,
 };
 
-static struct dsa_platform_data rd88f6281_switch_data = {
+static struct dsa_chip_data rd88f6281_switch_chip_data = {
 	.port_names[0]	= "lan1",
 	.port_names[1]	= "lan2",
 	.port_names[2]	= "lan3",
@@ -83,6 +83,11 @@ static struct dsa_platform_data rd88f6281_switch_data = {
 	.port_names[5]	= "cpu",
 };
 
+static struct dsa_platform_data rd88f6281_switch_plat_data = {
+	.nr_chips	= 1,
+	.chip		= &rd88f6281_switch_chip_data,
+};
+
 static struct mv643xx_eth_platform_data rd88f6281_ge01_data = {
 	.phy_addr	= MV643XX_ETH_PHY_ADDR(11),
 };
@@ -105,12 +110,12 @@ static void __init rd88f6281_init(void)
 	kirkwood_ge00_init(&rd88f6281_ge00_data);
 	kirkwood_pcie_id(&dev, &rev);
 	if (rev == MV88F6281_REV_A0) {
-		rd88f6281_switch_data.sw_addr = 10;
+		rd88f6281_switch_chip_data.sw_addr = 10;
 		kirkwood_ge01_init(&rd88f6281_ge01_data);
 	} else {
-		rd88f6281_switch_data.port_names[4] = "wan";
+		rd88f6281_switch_chip_data.port_names[4] = "wan";
 	}
-	kirkwood_ge00_switch_init(&rd88f6281_switch_data, NO_IRQ);
+	kirkwood_ge00_switch_init(&rd88f6281_switch_plat_data, NO_IRQ);
 
 	kirkwood_rtc_init();
 	kirkwood_sata_init(&rd88f6281_sata_data);
diff --git a/arch/arm/mach-orion5x/common.c b/arch/arm/mach-orion5x/common.c
index 0a62337..a4ecf62 100644
--- a/arch/arm/mach-orion5x/common.c
+++ b/arch/arm/mach-orion5x/common.c
@@ -219,14 +219,17 @@ static struct platform_device orion5x_switch_device = {
 
 void __init orion5x_eth_switch_init(struct dsa_platform_data *d, int irq)
 {
+	int i;
+
 	if (irq != NO_IRQ) {
 		orion5x_switch_resources[0].start = irq;
 		orion5x_switch_resources[0].end = irq;
 		orion5x_switch_device.num_resources = 1;
 	}
 
-	d->mii_bus = &orion5x_eth_shared.dev;
 	d->netdev = &orion5x_eth.dev;
+	for (i = 0; i < d->nr_chips; i++)
+		d->chip[i].mii_bus = &orion5x_eth_shared.dev;
 	orion5x_switch_device.dev.platform_data = d;
 
 	platform_device_register(&orion5x_switch_device);
diff --git a/arch/arm/mach-orion5x/rd88f5181l-fxo-setup.c b/arch/arm/mach-orion5x/rd88f5181l-fxo-setup.c
index 15f5323..9c1ca41 100644
--- a/arch/arm/mach-orion5x/rd88f5181l-fxo-setup.c
+++ b/arch/arm/mach-orion5x/rd88f5181l-fxo-setup.c
@@ -94,7 +94,7 @@ static struct mv643xx_eth_platform_data rd88f5181l_fxo_eth_data = {
 	.duplex		= DUPLEX_FULL,
 };
 
-static struct dsa_platform_data rd88f5181l_fxo_switch_data = {
+static struct dsa_chip_data rd88f5181l_fxo_switch_chip_data = {
 	.port_names[0]	= "lan2",
 	.port_names[1]	= "lan1",
 	.port_names[2]	= "wan",
@@ -103,6 +103,11 @@ static struct dsa_platform_data rd88f5181l_fxo_switch_data = {
 	.port_names[7]	= "lan3",
 };
 
+static struct dsa_platform_data rd88f5181l_fxo_switch_plat_data = {
+	.nr_chips	= 1,
+	.chip		= &rd88f5181l_fxo_switch_chip_data,
+};
+
 static void __init rd88f5181l_fxo_init(void)
 {
 	/*
@@ -117,7 +122,7 @@ static void __init rd88f5181l_fxo_init(void)
 	 */
 	orion5x_ehci0_init();
 	orion5x_eth_init(&rd88f5181l_fxo_eth_data);
-	orion5x_eth_switch_init(&rd88f5181l_fxo_switch_data, NO_IRQ);
+	orion5x_eth_switch_init(&rd88f5181l_fxo_switch_plat_data, NO_IRQ);
 	orion5x_uart0_init();
 
 	orion5x_setup_dev_boot_win(RD88F5181L_FXO_NOR_BOOT_BASE,
diff --git a/arch/arm/mach-orion5x/rd88f5181l-ge-setup.c b/arch/arm/mach-orion5x/rd88f5181l-ge-setup.c
index 8ad3934..ee1399f 100644
--- a/arch/arm/mach-orion5x/rd88f5181l-ge-setup.c
+++ b/arch/arm/mach-orion5x/rd88f5181l-ge-setup.c
@@ -95,7 +95,7 @@ static struct mv643xx_eth_platform_data rd88f5181l_ge_eth_data = {
 	.duplex		= DUPLEX_FULL,
 };
 
-static struct dsa_platform_data rd88f5181l_ge_switch_data = {
+static struct dsa_chip_data rd88f5181l_ge_switch_chip_data = {
 	.port_names[0]	= "lan2",
 	.port_names[1]	= "lan1",
 	.port_names[2]	= "wan",
@@ -104,6 +104,11 @@ static struct dsa_platform_data rd88f5181l_ge_switch_data = {
 	.port_names[7]	= "lan3",
 };
 
+static struct dsa_platform_data rd88f5181l_ge_switch_plat_data = {
+	.nr_chips	= 1,
+	.chip		= &rd88f5181l_ge_switch_chip_data,
+};
+
 static struct i2c_board_info __initdata rd88f5181l_ge_i2c_rtc = {
 	I2C_BOARD_INFO("ds1338", 0x68),
 };
@@ -122,7 +127,8 @@ static void __init rd88f5181l_ge_init(void)
 	 */
 	orion5x_ehci0_init();
 	orion5x_eth_init(&rd88f5181l_ge_eth_data);
-	orion5x_eth_switch_init(&rd88f5181l_ge_switch_data, gpio_to_irq(8));
+	orion5x_eth_switch_init(&rd88f5181l_ge_switch_plat_data,
+				gpio_to_irq(8));
 	orion5x_i2c_init();
 	orion5x_uart0_init();
 
diff --git a/arch/arm/mach-orion5x/rd88f6183ap-ge-setup.c b/arch/arm/mach-orion5x/rd88f6183ap-ge-setup.c
index 262e25e..7737cf9 100644
--- a/arch/arm/mach-orion5x/rd88f6183ap-ge-setup.c
+++ b/arch/arm/mach-orion5x/rd88f6183ap-ge-setup.c
@@ -35,7 +35,7 @@ static struct mv643xx_eth_platform_data rd88f6183ap_ge_eth_data = {
 	.duplex		= DUPLEX_FULL,
 };
 
-static struct dsa_platform_data rd88f6183ap_ge_switch_data = {
+static struct dsa_chip_data rd88f6183ap_ge_switch_chip_data = {
 	.port_names[0]	= "lan1",
 	.port_names[1]	= "lan2",
 	.port_names[2]	= "lan3",
@@ -44,6 +44,11 @@ static struct dsa_platform_data rd88f6183ap_ge_switch_data = {
 	.port_names[5]	= "cpu",
 };
 
+static struct dsa_platform_data rd88f6183ap_ge_switch_plat_data = {
+	.nr_chips	= 1,
+	.chip		= &rd88f6183ap_ge_switch_chip_data,
+};
+
 static struct mtd_partition rd88f6183ap_ge_partitions[] = {
 	{
 		.name	= "kernel",
@@ -89,7 +94,8 @@ static void __init rd88f6183ap_ge_init(void)
 	 */
 	orion5x_ehci0_init();
 	orion5x_eth_init(&rd88f6183ap_ge_eth_data);
-	orion5x_eth_switch_init(&rd88f6183ap_ge_switch_data, gpio_to_irq(3));
+	orion5x_eth_switch_init(&rd88f6183ap_ge_switch_plat_data,
+				gpio_to_irq(3));
 	spi_register_board_info(rd88f6183ap_ge_spi_slave_info,
 				ARRAY_SIZE(rd88f6183ap_ge_spi_slave_info));
 	orion5x_spi_init();
diff --git a/arch/arm/mach-orion5x/wrt350n-v2-setup.c b/arch/arm/mach-orion5x/wrt350n-v2-setup.c
index cc8f892..1b4ad9d 100644
--- a/arch/arm/mach-orion5x/wrt350n-v2-setup.c
+++ b/arch/arm/mach-orion5x/wrt350n-v2-setup.c
@@ -106,7 +106,7 @@ static struct mv643xx_eth_platform_data wrt350n_v2_eth_data = {
 	.duplex		= DUPLEX_FULL,
 };
 
-static struct dsa_platform_data wrt350n_v2_switch_data = {
+static struct dsa_chip_data wrt350n_v2_switch_chip_data = {
 	.port_names[0]	= "lan2",
 	.port_names[1]	= "lan1",
 	.port_names[2]	= "wan",
@@ -115,6 +115,11 @@ static struct dsa_platform_data wrt350n_v2_switch_data = {
 	.port_names[7]	= "lan4",
 };
 
+static struct dsa_platform_data wrt350n_v2_switch_plat_data = {
+	.nr_chips	= 1,
+	.chip		= &wrt350n_v2_switch_chip_data,
+};
+
 static void __init wrt350n_v2_init(void)
 {
 	/*
@@ -129,7 +134,7 @@ static void __init wrt350n_v2_init(void)
 	 */
 	orion5x_ehci0_init();
 	orion5x_eth_init(&wrt350n_v2_eth_data);
-	orion5x_eth_switch_init(&wrt350n_v2_switch_data, NO_IRQ);
+	orion5x_eth_switch_init(&wrt350n_v2_switch_plat_data, NO_IRQ);
 	orion5x_uart0_init();
 
 	orion5x_setup_dev_boot_win(WRT350N_V2_NOR_BOOT_BASE,
diff --git a/include/net/dsa.h b/include/net/dsa.h
index 52e97bf..839f768 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -1,6 +1,6 @@
 /*
  * include/net/dsa.h - Driver for Distributed Switch Architecture switch chips
- * Copyright (c) 2008 Marvell Semiconductor
+ * Copyright (c) 2008-2009 Marvell Semiconductor
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -11,23 +11,47 @@
 #ifndef __LINUX_NET_DSA_H
 #define __LINUX_NET_DSA_H
 
-#define DSA_MAX_PORTS	12
+#define DSA_MAX_SWITCHES	4
+#define DSA_MAX_PORTS		12
+
+struct dsa_chip_data {
+	/*
+	 * How to access the switch configuration registers.
+	 */
+	struct device	*mii_bus;
+	int		sw_addr;
+
+	/*
+	 * The names of the switch's ports.  Use "cpu" to
+	 * designate the switch port that the cpu is connected to,
+	 * "dsa" to indicate that this port is a DSA link to
+	 * another switch, NULL to indicate the port is unused,
+	 * or any other string to indicate this is a physical port.
+	 */
+	char		*port_names[DSA_MAX_PORTS];
+
+	/*
+	 * An array (with nr_chips elements) of which element [a]
+	 * indicates which port on this switch should be used to
+	 * send packets to that are destined for switch a.  Can be
+	 * NULL if there is only one switch chip.
+	 */
+	s8		*rtable;
+};
 
 struct dsa_platform_data {
 	/*
 	 * Reference to a Linux network interface that connects
-	 * to the switch chip.
+	 * to the root switch chip of the tree.
 	 */
 	struct device	*netdev;
 
 	/*
-	 * How to access the switch configuration registers, and
-	 * the names of the switch ports (use "cpu" to designate
-	 * the switch port that the cpu is connected to).
+	 * Info structs describing each of the switch chips
+	 * connected via this network interface.
 	 */
-	struct device	*mii_bus;
-	int		sw_addr;
-	char		*port_names[DSA_MAX_PORTS];
+	int		nr_chips;
+	struct dsa_chip_data	*chip;
 };
 
 extern bool dsa_uses_dsa_tags(void *dsa_ptr);
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 33e9946..71489f6 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -1,6 +1,6 @@
 /*
  * net/dsa/dsa.c - Hardware switch handling
- * Copyright (c) 2008 Marvell Semiconductor
+ * Copyright (c) 2008-2009 Marvell Semiconductor
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -67,12 +67,13 @@ dsa_switch_probe(struct mii_bus *bus, int sw_addr, char **_name)
 
 /* basic switch operations **************************************************/
 static struct dsa_switch *
-dsa_switch_setup(struct device *parent, struct dsa_platform_data *pd,
-		 struct mii_bus *bus, struct net_device *dev)
+dsa_switch_setup(struct dsa_switch_tree *dst, int index,
+		 struct device *parent, struct mii_bus *bus)
 {
+	struct dsa_chip_data *pd = dst->pd->chip + index;
+	struct dsa_switch_driver *drv;
 	struct dsa_switch *ds;
 	int ret;
-	struct dsa_switch_driver *drv;
 	char *name;
 	int i;
 
@@ -81,11 +82,12 @@ dsa_switch_setup(struct device *parent, struct dsa_platform_data *pd,
 	 */
 	drv = dsa_switch_probe(bus, pd->sw_addr, &name);
 	if (drv == NULL) {
-		printk(KERN_ERR "%s: could not detect attached switch\n",
-		       dev->name);
+		printk(KERN_ERR "%s[%d]: could not detect attached switch\n",
+		       dst->master_netdev->name, index);
 		return ERR_PTR(-EINVAL);
 	}
-	printk(KERN_INFO "%s: detected a %s switch\n", dev->name, name);
+	printk(KERN_INFO "%s[%d]: detected a %s switch\n",
+		dst->master_netdev->name, index, name);
 
 
 	/*
@@ -95,18 +97,16 @@ dsa_switch_setup(struct device *parent, struct dsa_platform_data *pd,
 	if (ds == NULL)
 		return ERR_PTR(-ENOMEM);
 
-	ds->pd = pd;
-	ds->master_netdev = dev;
-	ds->master_mii_bus = bus;
-
+	ds->dst = dst;
+	ds->index = index;
+	ds->pd = dst->pd->chip + index;
 	ds->drv = drv;
-	ds->tag_protocol = drv->tag_protocol;
+	ds->master_mii_bus = bus;
 
 
 	/*
 	 * Validate supplied switch configuration.
 	 */
-	ds->cpu_port = -1;
 	for (i = 0; i < DSA_MAX_PORTS; i++) {
 		char *name;
 
@@ -115,32 +115,28 @@ dsa_switch_setup(struct device *parent, struct dsa_platform_data *pd,
 			continue;
 
 		if (!strcmp(name, "cpu")) {
-			if (ds->cpu_port != -1) {
+			if (dst->cpu_switch != -1) {
 				printk(KERN_ERR "multiple cpu ports?!\n");
 				ret = -EINVAL;
 				goto out;
 			}
-			ds->cpu_port = i;
+			dst->cpu_switch = index;
+			dst->cpu_port = i;
+		} else if (!strcmp(name, "dsa")) {
+			ds->dsa_port_mask |= 1 << i;
 		} else {
-			ds->valid_port_mask |= 1 << i;
+			ds->phys_port_mask |= 1 << i;
 		}
 	}
 
-	if (ds->cpu_port == -1) {
-		printk(KERN_ERR "no cpu port?!\n");
-		ret = -EINVAL;
-		goto out;
-	}
-
 
 	/*
-	 * If we use a tagging format that doesn't have an ethertype
-	 * field, make sure that all packets from this point on get
-	 * sent to the tag format's receive function.  (Which will
-	 * discard received packets until we set ds->ports[] below.)
+	 * If the CPU connects to this switch, set the switch tree
+	 * tagging protocol to the preferred tagging format of this
+	 * switch.
 	 */
-	wmb();
-	dev->dsa_ptr = (void *)ds;
+	if (ds->dst->cpu_switch == index)
+		ds->dst->tag_protocol = drv->tag_protocol;
 
 
 	/*
@@ -150,7 +146,7 @@ dsa_switch_setup(struct device *parent, struct dsa_platform_data *pd,
 	if (ret < 0)
 		goto out;
 
-	ret = drv->set_addr(ds, dev->dev_addr);
+	ret = drv->set_addr(ds, dst->master_netdev->dev_addr);
 	if (ret < 0)
 		goto out;
 
@@ -169,18 +165,18 @@ dsa_switch_setup(struct device *parent, struct dsa_platform_data *pd,
 	/*
 	 * Create network devices for physical switch ports.
 	 */
-	wmb();
 	for (i = 0; i < DSA_MAX_PORTS; i++) {
 		struct net_device *slave_dev;
 
-		if (!(ds->valid_port_mask & (1 << i)))
+		if (!(ds->phys_port_mask & (1 << i)))
 			continue;
 
 		slave_dev = dsa_slave_create(ds, parent, i, pd->port_names[i]);
 		if (slave_dev == NULL) {
-			printk(KERN_ERR "%s: can't create dsa slave "
-			       "device for port %d(%s)\n",
-			       dev->name, i, pd->port_names[i]);
+			printk(KERN_ERR "%s[%d]: can't create dsa "
+			       "slave device for port %d(%s)\n",
+			       dst->master_netdev->name,
+			       index, i, pd->port_names[i]);
 			continue;
 		}
 
@@ -192,7 +188,6 @@ dsa_switch_setup(struct device *parent, struct dsa_platform_data *pd,
 out_free:
 	mdiobus_free(ds->slave_mii_bus);
 out:
-	dev->dsa_ptr = NULL;
 	kfree(ds);
 	return ERR_PTR(ret);
 }
@@ -212,35 +207,42 @@ static void dsa_switch_destroy(struct dsa_switch *ds)
  */
 bool dsa_uses_dsa_tags(void *dsa_ptr)
 {
-	struct dsa_switch *ds = dsa_ptr;
+	struct dsa_switch_tree *dst = dsa_ptr;
 
-	return !!(ds->tag_protocol == htons(ETH_P_DSA));
+	return !!(dst->tag_protocol == htons(ETH_P_DSA));
 }
 
 bool dsa_uses_trailer_tags(void *dsa_ptr)
 {
-	struct dsa_switch *ds = dsa_ptr;
+	struct dsa_switch_tree *dst = dsa_ptr;
 
-	return !!(ds->tag_protocol == htons(ETH_P_TRAILER));
+	return !!(dst->tag_protocol == htons(ETH_P_TRAILER));
 }
 
 
 /* link polling *************************************************************/
 static void dsa_link_poll_work(struct work_struct *ugly)
 {
-	struct dsa_switch *ds;
+	struct dsa_switch_tree *dst;
+	int i;
+
+	dst = container_of(ugly, struct dsa_switch_tree, link_poll_work);
 
-	ds = container_of(ugly, struct dsa_switch, link_poll_work);
+	for (i = 0; i < dst->pd->nr_chips; i++) {
+		struct dsa_switch *ds = dst->ds[i];
 
-	ds->drv->poll_link(ds);
-	mod_timer(&ds->link_poll_timer, round_jiffies(jiffies + HZ));
+		if (ds != NULL && ds->drv->poll_link != NULL)
+			ds->drv->poll_link(ds);
+	}
+
+	mod_timer(&dst->link_poll_timer, round_jiffies(jiffies + HZ));
 }
 
-static void dsa_link_poll_timer(unsigned long _ds)
+static void dsa_link_poll_timer(unsigned long _dst)
 {
-	struct dsa_switch *ds = (void *)_ds;
+	struct dsa_switch_tree *dst = (void *)_dst;
 
-	schedule_work(&ds->link_poll_work);
+	schedule_work(&dst->link_poll_work);
 }
 
 
@@ -303,18 +305,14 @@ static int dsa_probe(struct platform_device *pdev)
 	static int dsa_version_printed;
 	struct dsa_platform_data *pd = pdev->dev.platform_data;
 	struct net_device *dev;
-	struct mii_bus *bus;
-	struct dsa_switch *ds;
+	struct dsa_switch_tree *dst;
+	int i;
 
 	if (!dsa_version_printed++)
 		printk(KERN_NOTICE "Distributed Switch Architecture "
 			"driver version %s\n", dsa_driver_version);
 
-	if (pd == NULL || pd->mii_bus == NULL || pd->netdev == NULL)
-		return -EINVAL;
-
-	bus = dev_to_mii_bus(pd->mii_bus);
-	if (bus == NULL)
+	if (pd == NULL || pd->netdev == NULL)
 		return -EINVAL;
 
 	dev = dev_to_net_device(pd->netdev);
@@ -326,36 +324,79 @@ static int dsa_probe(struct platform_device *pdev)
 		return -EEXIST;
 	}
 
-	ds = dsa_switch_setup(&pdev->dev, pd, bus, dev);
-	if (IS_ERR(ds)) {
+	dst = kzalloc(sizeof(*dst), GFP_KERNEL);
+	if (dst == NULL) {
 		dev_put(dev);
-		return PTR_ERR(ds);
+		return -ENOMEM;
 	}
 
-	if (ds->drv->poll_link != NULL) {
-		INIT_WORK(&ds->link_poll_work, dsa_link_poll_work);
-		init_timer(&ds->link_poll_timer);
-		ds->link_poll_timer.data = (unsigned long)ds;
-		ds->link_poll_timer.function = dsa_link_poll_timer;
-		ds->link_poll_timer.expires = round_jiffies(jiffies + HZ);
-		add_timer(&ds->link_poll_timer);
+	platform_set_drvdata(pdev, dst);
+
+	dst->pd = pd;
+	dst->master_netdev = dev;
+	dst->cpu_switch = -1;
+	dst->cpu_port = -1;
+
+	for (i = 0; i < pd->nr_chips; i++) {
+		struct mii_bus *bus;
+		struct dsa_switch *ds;
+
+		bus = dev_to_mii_bus(pd->chip[i].mii_bus);
+		if (bus == NULL) {
+			printk(KERN_ERR "%s[%d]: no mii bus found for "
+				"dsa switch\n", dev->name, i);
+			continue;
+		}
+
+		ds = dsa_switch_setup(dst, i, &pdev->dev, bus);
+		if (IS_ERR(ds)) {
+			printk(KERN_ERR "%s[%d]: couldn't create dsa switch "
+				"instance (error %ld)\n", dev->name, i,
+				PTR_ERR(ds));
+			continue;
+		}
+
+		dst->ds[i] = ds;
+		if (ds->drv->poll_link != NULL)
+			dst->link_poll_needed = 1;
 	}
 
-	platform_set_drvdata(pdev, ds);
+	/*
+	 * If we use a tagging format that doesn't have an ethertype
+	 * field, make sure that all packets from this point on get
+	 * sent to the tag format's receive function.
+	 */
+	wmb();
+	dev->dsa_ptr = (void *)dst;
+
+	if (dst->link_poll_needed) {
+		INIT_WORK(&dst->link_poll_work, dsa_link_poll_work);
+		init_timer(&dst->link_poll_timer);
+		dst->link_poll_timer.data = (unsigned long)dst;
+		dst->link_poll_timer.function = dsa_link_poll_timer;
+		dst->link_poll_timer.expires = round_jiffies(jiffies + HZ);
+		add_timer(&dst->link_poll_timer);
+	}
 
 	return 0;
 }
 
 static int dsa_remove(struct platform_device *pdev)
 {
-	struct dsa_switch *ds = platform_get_drvdata(pdev);
+	struct dsa_switch_tree *dst = platform_get_drvdata(pdev);
+	int i;
 
-	if (ds->drv->poll_link != NULL)
-		del_timer_sync(&ds->link_poll_timer);
+	if (dst->link_poll_needed)
+		del_timer_sync(&dst->link_poll_timer);
 
 	flush_scheduled_work();
 
-	dsa_switch_destroy(ds);
+	for (i = 0; i < dst->pd->nr_chips; i++) {
+		struct dsa_switch *ds = dst->ds[i];
+
+		if (ds != NULL)
+			dsa_switch_destroy(ds);
+	}
 
 	return 0;
 }
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 7063378..41055f3 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -1,6 +1,6 @@
 /*
  * net/dsa/dsa_priv.h - Hardware switch handling
- * Copyright (c) 2008 Marvell Semiconductor
+ * Copyright (c) 2008-2009 Marvell Semiconductor
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -19,42 +19,107 @@
 
 struct dsa_switch {
 	/*
-	 * Configuration data for the platform device that owns
-	 * this dsa switch instance.
+	 * Parent switch tree, and switch index.
 	 */
-	struct dsa_platform_data	*pd;
+	struct dsa_switch_tree	*dst;
+	int			index;
 
 	/*
-	 * References to network device and mii bus to use.
+	 * Configuration data for this switch.
 	 */
-	struct net_device		*master_netdev;
-	struct mii_bus			*master_mii_bus;
+	struct dsa_chip_data	*pd;
 
 	/*
-	 * The used switch driver and frame tagging type.
+	 * The used switch driver.
 	 */
 	struct dsa_switch_driver	*drv;
-	__be16				tag_protocol;
+
+	/*
+	 * Reference to mii bus to use.
+	 */
+	struct mii_bus		*master_mii_bus;
 
 	/*
 	 * Slave mii_bus and devices for the individual ports.
 	 */
-	int				cpu_port;
-	u32				valid_port_mask;
-	struct mii_bus			*slave_mii_bus;
-	struct net_device		*ports[DSA_MAX_PORTS];
+	u32			dsa_port_mask;
+	u32			phys_port_mask;
+	struct mii_bus		*slave_mii_bus;
+	struct net_device	*ports[DSA_MAX_PORTS];
+};
+
+struct dsa_switch_tree {
+	/*
+	 * Configuration data for the platform device that owns
+	 * this dsa switch tree instance.
+	 */
+	struct dsa_platform_data	*pd;
+
+	/*
+	 * Reference to network device to use, and which tagging
+	 * protocol to use.
+	 */
+	struct net_device	*master_netdev;
+	__be16			tag_protocol;
+
+	/*
+	 * The switch and port to which the CPU is attached.
+	 */
+	s8			cpu_switch;
+	s8			cpu_port;
 
 	/*
 	 * Link state polling.
 	 */
-	struct work_struct		link_poll_work;
-	struct timer_list		link_poll_timer;
+	int			link_poll_needed;
+	struct work_struct	link_poll_work;
+	struct timer_list	link_poll_timer;
+
+	/*
+	 * Data for the individual switch chips.
+	 */
+	struct dsa_switch	*ds[DSA_MAX_SWITCHES];
 };
 
+static inline bool dsa_is_cpu_port(struct dsa_switch *ds, int p)
+{
+	return !!(ds->index == ds->dst->cpu_switch && p == ds->dst->cpu_port);
+}
+
+static inline u8 dsa_upstream_port(struct dsa_switch *ds)
+{
+	struct dsa_switch_tree *dst = ds->dst;
+
+	/*
+	 * If this is the root switch (i.e. the switch that connects
+	 * to the CPU), return the cpu port number on this switch.
+	 * Else return the (DSA) port number that connects to the
+	 * switch that is one hop closer to the cpu.
+	 */
+	if (dst->cpu_switch == ds->index)
+		return dst->cpu_port;
+	else
+		return ds->pd->rtable[dst->cpu_switch];
+}
+
 struct dsa_slave_priv {
+	/*
+	 * The linux network interface corresponding to this
+	 * switch port.
+	 */
 	struct net_device	*dev;
+
+	/*
+	 * Which switch this port is a part of, and the port index
+	 * for this port.
+	 */
 	struct dsa_switch	*parent;
-	int			port;
+	u8			port;
+
+	/*
+	 * The phylib phy_device pointer for the PHY connected
+	 * to this port.
+	 */
 	struct phy_device	*phy;
 };
 
diff --git a/net/dsa/mv88e6060.c b/net/dsa/mv88e6060.c
index 85081ae..83277f4 100644
--- a/net/dsa/mv88e6060.c
+++ b/net/dsa/mv88e6060.c
@@ -1,6 +1,6 @@
 /*
  * net/dsa/mv88e6060.c - Driver for Marvell 88e6060 switch chips
- * Copyright (c) 2008 Marvell Semiconductor
+ * Copyright (c) 2008-2009 Marvell Semiconductor
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -81,7 +81,7 @@ static int mv88e6060_switch_reset(struct dsa_switch *ds)
 	/*
 	 * Reset the switch.
 	 */
-	REG_WRITE(REG_GLOBAL, 0x0A, 0xa130);
+	REG_WRITE(REG_GLOBAL, 0x0a, 0xa130);
 
 	/*
 	 * Wait up to one second for reset to complete.
@@ -128,7 +128,7 @@ static int mv88e6060_setup_port(struct dsa_switch *ds, int p)
 	 * state to Forwarding.  Additionally, if this is the CPU
 	 * port, enable Ingress and Egress Trailer tagging mode.
 	 */
-	REG_WRITE(addr, 0x04, (p == ds->cpu_port) ? 0x4103 : 0x0003);
+	REG_WRITE(addr, 0x04, dsa_is_cpu_port(ds, p) ?  0x4103 : 0x0003);
 
 	/*
 	 * Port based VLAN map: give each port its own address
@@ -138,9 +138,9 @@ static int mv88e6060_setup_port(struct dsa_switch *ds, int p)
 	 */
 	REG_WRITE(addr, 0x06,
 			((p & 0xf) << 12) |
-			 ((p == ds->cpu_port) ?
-				ds->valid_port_mask :
-				(1 << ds->cpu_port)));
+			 (dsa_is_cpu_port(ds, p) ?
+				ds->phys_port_mask :
+				(1 << ds->dst->cpu_port)));
 
 	/*
 	 * Port Association Vector: when learning source addresses
diff --git a/net/dsa/mv88e6123_61_65.c b/net/dsa/mv88e6123_61_65.c
index ec8c6a0..8e46547 100644
--- a/net/dsa/mv88e6123_61_65.c
+++ b/net/dsa/mv88e6123_61_65.c
@@ -1,6 +1,6 @@
 /*
  * net/dsa/mv88e6123_61_65.c - Marvell 88e6123/6161/6165 switch chip support
- * Copyright (c) 2008 Marvell Semiconductor
+ * Copyright (c) 2008-2009 Marvell Semiconductor
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -98,17 +98,17 @@ static int mv88e6123_61_65_setup_global(struct dsa_switch *ds)
 		return ret;
 
 	/*
-	 * Configure the cpu port, and configure the cpu port as the
-	 * port to which ingress and egress monitor frames are to be
-	 * sent.
+	 * Configure the upstream port, and configure the upstream
+	 * port as the port to which ingress and egress monitor frames
+	 * are to be sent.
 	 */
-	REG_WRITE(REG_GLOBAL, 0x1a, (ds->cpu_port * 0x1110));
+	REG_WRITE(REG_GLOBAL, 0x1a, (dsa_upstream_port(ds) * 0x1110));
 
 	/*
 	 * Disable remote management for now, and set the switch's
-	 * DSA device number to zero.
+	 * DSA device number.
 	 */
-	REG_WRITE(REG_GLOBAL, 0x1c, 0x0000);
+	REG_WRITE(REG_GLOBAL, 0x1c, ds->index & 0x1f);
 
 	/*
 	 * Send all frames with destination addresses matching
@@ -133,10 +133,17 @@ static int mv88e6123_61_65_setup_global(struct dsa_switch *ds)
 	REG_WRITE(REG_GLOBAL2, 0x05, 0x00ff);
 
 	/*
-	 * Map all DSA device IDs to the CPU port.
+	 * Program the DSA routing table.
 	 */
-	for (i = 0; i < 32; i++)
-		REG_WRITE(REG_GLOBAL2, 0x06, 0x8000 | (i << 8) | ds->cpu_port);
+	for (i = 0; i < 32; i++) {
+		int nexthop;
+
+		nexthop = 0x1f;
+		if (i != ds->index && i < ds->dst->pd->nr_chips)
+			nexthop = ds->pd->rtable[i] & 0x1f;
+
+		REG_WRITE(REG_GLOBAL2, 0x06, 0x8000 | (i << 8) | nexthop);
+	}
 
 	/*
 	 * Clear all trunk masks.
@@ -176,12 +183,18 @@ static int mv88e6123_61_65_setup_global(struct dsa_switch *ds)
 static int mv88e6123_61_65_setup_port(struct dsa_switch *ds, int p)
 {
 	int addr = REG_PORT(p);
+	u16 val;
 
 	/*
 	 * MAC Forcing register: don't force link, speed, duplex
-	 * or flow control state to any particular values.
+	 * or flow control state to any particular values on physical
+	 * ports, but force the CPU port and all DSA ports to 1000 Mb/s
+	 * full duplex.
 	 */
-	REG_WRITE(addr, 0x01, 0x0003);
+	if (dsa_is_cpu_port(ds, p) || ds->dsa_port_mask & (1 << p))
+		REG_WRITE(addr, 0x01, 0x003e);
+	else
+		REG_WRITE(addr, 0x01, 0x0003);
 
 	/*
 	 * Do not limit the period of time that this port can be
@@ -192,37 +205,50 @@ static int mv88e6123_61_65_setup_port(struct dsa_switch *ds, int p)
 
 	/*
 	 * Port Control: disable Drop-on-Unlock, disable Drop-on-Lock,
-	 * configure the requested (DSA/EDSA) tagging mode if this is
-	 * the CPU port, disable Header mode, enable IGMP/MLD snooping,
-	 * disable VLAN tunneling, determine priority by looking at
-	 * 802.1p and IP priority fields (IP prio has precedence), and
-	 * set STP state to Forwarding.  Finally, if this is the CPU
-	 * port, additionally enable forwarding of unknown unicast and
-	 * multicast addresses.
-	 */
-	REG_WRITE(addr, 0x04,
-			(p == ds->cpu_port) ?
-			 (ds->tag_protocol == htons(ETH_P_DSA)) ?
-			  0x053f : 0x373f :
-			 0x0433);
+	 * disable Header mode, enable IGMP/MLD snooping, disable VLAN
+	 * tunneling, determine priority by looking at 802.1p and IP
+	 * priority fields (IP prio has precedence), and set STP state
+	 * to Forwarding.
+	 *
+	 * If this is the CPU link, use DSA or EDSA tagging depending
+	 * on which tagging mode was configured.
+	 *
+	 * If this is a link to another switch, use DSA tagging mode.
+	 *
+	 * If this is the upstream port for this switch, enable
+	 * forwarding of unknown unicasts and multicasts.
+	 */
+	val = 0x0433;
+	if (dsa_is_cpu_port(ds, p)) {
+		if (ds->dst->tag_protocol == htons(ETH_P_EDSA))
+			val |= 0x3300;
+		else
+			val |= 0x0100;
+	}
+	if (ds->dsa_port_mask & (1 << p))
+		val |= 0x0100;
+	if (p == dsa_upstream_port(ds))
+		val |= 0x000c;
+	REG_WRITE(addr, 0x04, val);
 
 	/*
 	 * Port Control 1: disable trunking.  Also, if this is the
 	 * CPU port, enable learn messages to be sent to this port.
 	 */
-	REG_WRITE(addr, 0x05, (p == ds->cpu_port) ? 0x8000 : 0x0000);
+	REG_WRITE(addr, 0x05, dsa_is_cpu_port(ds, p) ? 0x8000 : 0x0000);
 
 	/*
 	 * Port based VLAN map: give each port its own address
 	 * database, allow the CPU port to talk to each of the 'real'
 	 * ports, and allow each of the 'real' ports to only talk to
-	 * the CPU port.
-	 */
-	REG_WRITE(addr, 0x06,
-			((p & 0xf) << 12) |
-			 ((p == ds->cpu_port) ?
-				ds->valid_port_mask :
-				(1 << ds->cpu_port)));
+	 * the upstream port.
+	 */
+	val = (p & 0xf) << 12;
+	if (dsa_is_cpu_port(ds, p))
+		val |= ds->phys_port_mask;
+	else
+		val |= 1 << dsa_upstream_port(ds);
+	REG_WRITE(addr, 0x06, val);
 
 	/*
 	 * Default VLAN ID and priority: don't set a default VLAN
diff --git a/net/dsa/mv88e6131.c b/net/dsa/mv88e6131.c
index 4e24eca..ea65af7 100644
--- a/net/dsa/mv88e6131.c
+++ b/net/dsa/mv88e6131.c
@@ -102,17 +102,17 @@ static int mv88e6131_setup_global(struct dsa_switch *ds)
 	REG_WRITE(REG_GLOBAL, 0x19, 0x8100);
 
 	/*
-	 * Disable ARP mirroring, and configure the cpu port as the
-	 * port to which ingress and egress monitor frames are to be
-	 * sent.
+	 * Disable ARP mirroring, and configure the upstream port as
+	 * the port to which ingress and egress monitor frames are to
+	 * be sent.
 	 */
-	REG_WRITE(REG_GLOBAL, 0x1a, (ds->cpu_port * 0x1100) | 0x00f0);
+	REG_WRITE(REG_GLOBAL, 0x1a, (dsa_upstream_port(ds) * 0x1100) | 0x00f0);
 
 	/*
 	 * Disable cascade port functionality, and set the switch's
-	 * DSA device number to zero.
+	 * DSA device number.
 	 */
-	REG_WRITE(REG_GLOBAL, 0x1c, 0xe000);
+	REG_WRITE(REG_GLOBAL, 0x1c, 0xe000 | (ds->index & 0x1f));
 
 	/*
 	 * Send all frames with destination addresses matching
@@ -129,10 +129,17 @@ static int mv88e6131_setup_global(struct dsa_switch *ds)
 	REG_WRITE(REG_GLOBAL2, 0x05, 0x00ff);
 
 	/*
-	 * Map all DSA device IDs to the CPU port.
+	 * Program the DSA routing table.
 	 */
-	for (i = 0; i < 32; i++)
-		REG_WRITE(REG_GLOBAL2, 0x06, 0x8000 | (i << 8) | ds->cpu_port);
+	for (i = 0; i < 32; i++) {
+		int nexthop;
+
+		nexthop = 0x1f;
+		if (i != ds->index && i < ds->dst->pd->nr_chips)
+			nexthop = ds->pd->rtable[i] & 0x1f;
+
+		REG_WRITE(REG_GLOBAL2, 0x06, 0x8000 | (i << 8) | nexthop);
+	}
 
 	/*
 	 * Clear all trunk masks.
@@ -158,13 +165,15 @@ static int mv88e6131_setup_global(struct dsa_switch *ds)
 static int mv88e6131_setup_port(struct dsa_switch *ds, int p)
 {
 	int addr = REG_PORT(p);
+	u16 val;
 
 	/*
 	 * MAC Forcing register: don't force link, speed, duplex
 	 * or flow control state to any particular values on physical
-	 * ports, but force the CPU port to 1000 Mb/s full duplex.
+	 * ports, but force the CPU port and all DSA ports to 1000 Mb/s
+	 * full duplex.
 	 */
-	if (p == ds->cpu_port)
+	if (dsa_is_cpu_port(ds, p) || ds->dsa_port_mask & (1 << p))
 		REG_WRITE(addr, 0x01, 0x003e);
 	else
 		REG_WRITE(addr, 0x01, 0x0003);
@@ -175,29 +184,40 @@ static int mv88e6131_setup_port(struct dsa_switch *ds, int p)
 	 * enable IGMP/MLD snoop, disable DoubleTag, disable VLAN
 	 * tunneling, determine priority by looking at 802.1p and
 	 * IP priority fields (IP prio has precedence), and set STP
-	 * state to Forwarding.  Finally, if this is the CPU port,
-	 * additionally enable DSA tagging and forwarding of unknown
-	 * unicast addresses.
+	 * state to Forwarding.
+	 *
+	 * If this is the upstream port for this switch, enable
+	 * forwarding of unknown unicasts, and enable DSA tagging
+	 * mode.
+	 *
+	 * If this is the link to another switch, use DSA tagging
+	 * mode, but do not enable forwarding of unknown unicasts.
 	 */
-	REG_WRITE(addr, 0x04, (p == ds->cpu_port) ? 0x0537 : 0x0433);
+	val = 0x0433;
+	if (p == dsa_upstream_port(ds))
+		val |= 0x0104;
+	if (ds->dsa_port_mask & (1 << p))
+		val |= 0x0100;
+	REG_WRITE(addr, 0x04, val);
 
 	/*
 	 * Port Control 1: disable trunking.  Also, if this is the
 	 * CPU port, enable learn messages to be sent to this port.
 	 */
-	REG_WRITE(addr, 0x05, (p == ds->cpu_port) ? 0x8000 : 0x0000);
+	REG_WRITE(addr, 0x05, dsa_is_cpu_port(ds, p) ? 0x8000 : 0x0000);
 
 	/*
 	 * Port based VLAN map: give each port its own address
 	 * database, allow the CPU port to talk to each of the 'real'
 	 * ports, and allow each of the 'real' ports to only talk to
-	 * the CPU port.
+	 * the upstream port.
 	 */
-	REG_WRITE(addr, 0x06,
-			((p & 0xf) << 12) |
-			 ((p == ds->cpu_port) ?
-				ds->valid_port_mask :
-				(1 << ds->cpu_port)));
+	val = (p & 0xf) << 12;
+	if (dsa_is_cpu_port(ds, p))
+		val |= ds->phys_port_mask;
+	else
+		val |= 1 << dsa_upstream_port(ds);
+	REG_WRITE(addr, 0x06, val);
 
 	/*
 	 * Default VLAN ID and priority: don't set a default VLAN
@@ -213,13 +233,15 @@ static int mv88e6131_setup_port(struct dsa_switch *ds, int p)
 	 * untagged frames on this port, do a destination address
 	 * lookup on received packets as usual, don't send a copy
 	 * of all transmitted/received frames on this port to the
-	 * CPU, and configure the CPU port number.  Also, if this
-	 * is the CPU port, enable forwarding of unknown multicast
-	 * addresses.
+	 * CPU, and configure the upstream port number.
+	 *
+	 * If this is the upstream port for this switch, enable
+	 * forwarding of unknown multicast addresses.
 	 */
-	REG_WRITE(addr, 0x08,
-			((p == ds->cpu_port) ? 0x00c0 : 0x0080) |
-			 ds->cpu_port);
+	val = 0x0080 | dsa_upstream_port(ds);
+	if (p == dsa_upstream_port(ds))
+		val |= 0x0040;
+	REG_WRITE(addr, 0x08, val);
 
 	/*
 	 * Rate Control: disable ingress rate limiting.
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 99114e5..ed13118 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -1,6 +1,6 @@
 /*
  * net/dsa/slave.c - Slave device handling
- * Copyright (c) 2008 Marvell Semiconductor
+ * Copyright (c) 2008-2009 Marvell Semiconductor
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -19,7 +19,7 @@ static int dsa_slave_phy_read(struct mii_bus *bus, int addr, int reg)
 {
 	struct dsa_switch *ds = bus->priv;
 
-	if (ds->valid_port_mask & (1 << addr))
+	if (ds->phys_port_mask & (1 << addr))
 		return ds->drv->phy_read(ds, addr, reg);
 
 	return 0xffff;
@@ -29,7 +29,7 @@ static int dsa_slave_phy_write(struct mii_bus *bus, int addr, int reg, u16 val)
 {
 	struct dsa_switch *ds = bus->priv;
 
-	if (ds->valid_port_mask & (1 << addr))
+	if (ds->phys_port_mask & (1 << addr))
 		return ds->drv->phy_write(ds, addr, reg, val);
 
 	return 0;
@@ -43,7 +43,7 @@ void dsa_slave_mii_bus_init(struct dsa_switch *ds)
 	ds->slave_mii_bus->write = dsa_slave_phy_write;
 	snprintf(ds->slave_mii_bus->id, MII_BUS_ID_SIZE, "%s:%.2x",
 			ds->master_mii_bus->id, ds->pd->sw_addr);
-	ds->slave_mii_bus->parent = &(ds->master_mii_bus->dev);
+	ds->slave_mii_bus->parent = &ds->master_mii_bus->dev;
 }
 
 
@@ -51,9 +51,8 @@ void dsa_slave_mii_bus_init(struct dsa_switch *ds)
 static int dsa_slave_init(struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct net_device *master = p->parent->master_netdev;
 
-	dev->iflink = master->ifindex;
+	dev->iflink = p->parent->dst->master_netdev->ifindex;
 
 	return 0;
 }
@@ -61,7 +60,7 @@ static int dsa_slave_init(struct net_device *dev)
 static int dsa_slave_open(struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct net_device *master = p->parent->master_netdev;
+	struct net_device *master = p->parent->dst->master_netdev;
 	int err;
 
 	if (!(master->flags & IFF_UP))
@@ -99,7 +98,7 @@ out:
 static int dsa_slave_close(struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct net_device *master = p->parent->master_netdev;
+	struct net_device *master = p->parent->dst->master_netdev;
 
 	dev_mc_unsync(master, dev);
 	dev_unicast_unsync(master, dev);
@@ -117,7 +116,7 @@ static int dsa_slave_close(struct net_device *dev)
 static void dsa_slave_change_rx_flags(struct net_device *dev, int change)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct net_device *master = p->parent->master_netdev;
+	struct net_device *master = p->parent->dst->master_netdev;
 
 	if (change & IFF_ALLMULTI)
 		dev_set_allmulti(master, dev->flags & IFF_ALLMULTI ? 1 : -1);
@@ -128,7 +127,7 @@ static void dsa_slave_change_rx_flags(struct net_device *dev, int change)
 static void dsa_slave_set_rx_mode(struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct net_device *master = p->parent->master_netdev;
+	struct net_device *master = p->parent->dst->master_netdev;
 
 	dev_mc_sync(master, dev);
 	dev_unicast_sync(master, dev);
@@ -137,7 +136,7 @@ static void dsa_slave_set_rx_mode(struct net_device *dev)
 static int dsa_slave_set_mac_address(struct net_device *dev, void *a)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct net_device *master = p->parent->master_netdev;
+	struct net_device *master = p->parent->dst->master_netdev;
 	struct sockaddr *addr = a;
 	int err;
 
@@ -341,7 +340,7 @@ struct net_device *
 dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 		 int port, char *name)
 {
-	struct net_device *master = ds->master_netdev;
+	struct net_device *master = ds->dst->master_netdev;
 	struct net_device *slave_dev;
 	struct dsa_slave_priv *p;
 	int ret;
@@ -356,7 +355,7 @@ dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 	memcpy(slave_dev->dev_addr, master->dev_addr, ETH_ALEN);
 	slave_dev->tx_queue_len = 0;
 
-	switch (ds->tag_protocol) {
+	switch (ds->dst->tag_protocol) {
 #ifdef CONFIG_NET_DSA_TAG_DSA
 	case htons(ETH_P_DSA):
 		slave_dev->netdev_ops = &dsa_netdev_ops;
diff --git a/net/dsa/tag_dsa.c b/net/dsa/tag_dsa.c
index f99a019..d9b6c14 100644
--- a/net/dsa/tag_dsa.c
+++ b/net/dsa/tag_dsa.c
@@ -1,6 +1,6 @@
 /*
  * net/dsa/tag_dsa.c - (Non-ethertype) DSA tagging
- * Copyright (c) 2008 Marvell Semiconductor
+ * Copyright (c) 2008-2009 Marvell Semiconductor
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -36,7 +36,7 @@ int dsa_xmit(struct sk_buff *skb, struct net_device *dev)
 		 * Construct tagged FROM_CPU DSA tag from 802.1q tag.
 		 */
 		dsa_header = skb->data + 2 * ETH_ALEN;
-		dsa_header[0] = 0x60;
+		dsa_header[0] = 0x60 | p->parent->index;
 		dsa_header[1] = p->port << 3;
 
 		/*
@@ -57,7 +57,7 @@ int dsa_xmit(struct sk_buff *skb, struct net_device *dev)
 		 * Construct untagged FROM_CPU DSA tag.
 		 */
 		dsa_header = skb->data + 2 * ETH_ALEN;
-		dsa_header[0] = 0x40;
+		dsa_header[0] = 0x40 | p->parent->index;
 		dsa_header[1] = p->port << 3;
 		dsa_header[2] = 0x00;
 		dsa_header[3] = 0x00;
@@ -65,7 +65,7 @@ int dsa_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	skb->protocol = htons(ETH_P_DSA);
 
-	skb->dev = p->parent->master_netdev;
+	skb->dev = p->parent->dst->master_netdev;
 	dev_queue_xmit(skb);
 
 	return NETDEV_TX_OK;
@@ -78,11 +78,13 @@ out_free:
 static int dsa_rcv(struct sk_buff *skb, struct net_device *dev,
 		   struct packet_type *pt, struct net_device *orig_dev)
 {
-	struct dsa_switch *ds = dev->dsa_ptr;
+	struct dsa_switch_tree *dst = dev->dsa_ptr;
+	struct dsa_switch *ds;
 	u8 *dsa_header;
+	int source_device;
 	int source_port;
 
-	if (unlikely(ds == NULL))
+	if (unlikely(dst == NULL))
 		goto out_drop;
 
 	skb = skb_unshare(skb, GFP_ATOMIC);
@@ -98,16 +100,24 @@ static int dsa_rcv(struct sk_buff *skb, struct net_device *dev,
 	dsa_header = skb->data - 2;
 
 	/*
-	 * Check that frame type is either TO_CPU or FORWARD, and
-	 * that the source device is zero.
+	 * Check that frame type is either TO_CPU or FORWARD.
 	 */
-	if ((dsa_header[0] & 0xdf) != 0x00 && (dsa_header[0] & 0xdf) != 0xc0)
+	if ((dsa_header[0] & 0xc0) != 0x00 && (dsa_header[0] & 0xc0) != 0xc0)
 		goto out_drop;
 
 	/*
-	 * Check that the source port is a registered DSA port.
+	 * Determine source device and port.
 	 */
+	source_device = dsa_header[0] & 0x1f;
 	source_port = (dsa_header[1] >> 3) & 0x1f;
+
+	/*
+	 * Check that the source device exists and that the source
+	 * port is a registered DSA port.
+	 */
+	if (source_device >= dst->pd->nr_chips)
+		goto out_drop;
+	ds = dst->ds[source_device];
 	if (source_port >= DSA_MAX_PORTS || ds->ports[source_port] == NULL)
 		goto out_drop;
 
diff --git a/net/dsa/tag_edsa.c b/net/dsa/tag_edsa.c
index 328ec95..2a5016f 100644
--- a/net/dsa/tag_edsa.c
+++ b/net/dsa/tag_edsa.c
@@ -1,6 +1,6 @@
 /*
  * net/dsa/tag_edsa.c - Ethertype DSA tagging
- * Copyright (c) 2008 Marvell Semiconductor
+ * Copyright (c) 2008-2009 Marvell Semiconductor
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -45,7 +45,7 @@ int edsa_xmit(struct sk_buff *skb, struct net_device *dev)
 		edsa_header[1] = ETH_P_EDSA & 0xff;
 		edsa_header[2] = 0x00;
 		edsa_header[3] = 0x00;
-		edsa_header[4] = 0x60;
+		edsa_header[4] = 0x60 | p->parent->index;
 		edsa_header[5] = p->port << 3;
 
 		/*
@@ -70,7 +70,7 @@ int edsa_xmit(struct sk_buff *skb, struct net_device *dev)
 		edsa_header[1] = ETH_P_EDSA & 0xff;
 		edsa_header[2] = 0x00;
 		edsa_header[3] = 0x00;
-		edsa_header[4] = 0x40;
+		edsa_header[4] = 0x40 | p->parent->index;
 		edsa_header[5] = p->port << 3;
 		edsa_header[6] = 0x00;
 		edsa_header[7] = 0x00;
@@ -78,7 +78,7 @@ int edsa_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	skb->protocol = htons(ETH_P_EDSA);
 
-	skb->dev = p->parent->master_netdev;
+	skb->dev = p->parent->dst->master_netdev;
 	dev_queue_xmit(skb);
 
 	return NETDEV_TX_OK;
@@ -91,11 +91,13 @@ out_free:
 static int edsa_rcv(struct sk_buff *skb, struct net_device *dev,
 		    struct packet_type *pt, struct net_device *orig_dev)
 {
-	struct dsa_switch *ds = dev->dsa_ptr;
+	struct dsa_switch_tree *dst = dev->dsa_ptr;
+	struct dsa_switch *ds;
 	u8 *edsa_header;
+	int source_device;
 	int source_port;
 
-	if (unlikely(ds == NULL))
+	if (unlikely(dst == NULL))
 		goto out_drop;
 
 	skb = skb_unshare(skb, GFP_ATOMIC);
@@ -111,16 +113,24 @@ static int edsa_rcv(struct sk_buff *skb, struct net_device *dev,
 	edsa_header = skb->data + 2;
 
 	/*
-	 * Check that frame type is either TO_CPU or FORWARD, and
-	 * that the source device is zero.
+	 * Check that frame type is either TO_CPU or FORWARD.
 	 */
-	if ((edsa_header[0] & 0xdf) != 0x00 && (edsa_header[0] & 0xdf) != 0xc0)
+	if ((edsa_header[0] & 0xc0) != 0x00 && (edsa_header[0] & 0xc0) != 0xc0)
 		goto out_drop;
 
 	/*
-	 * Check that the source port is a registered DSA port.
+	 * Determine source device and port.
 	 */
+	source_device = edsa_header[0] & 0x1f;
 	source_port = (edsa_header[1] >> 3) & 0x1f;
+
+	/*
+	 * Check that the source device exists and that the source
+	 * port is a registered DSA port.
+	 */
+	if (source_device >= dst->pd->nr_chips)
+		goto out_drop;
+	ds = dst->ds[source_device];
 	if (source_port >= DSA_MAX_PORTS || ds->ports[source_port] == NULL)
 		goto out_drop;
 
diff --git a/net/dsa/tag_trailer.c b/net/dsa/tag_trailer.c
index b591328..e0ce7c6 100644
--- a/net/dsa/tag_trailer.c
+++ b/net/dsa/tag_trailer.c
@@ -1,6 +1,6 @@
 /*
  * net/dsa/tag_trailer.c - Trailer tag format handling
- * Copyright (c) 2008 Marvell Semiconductor
+ * Copyright (c) 2008-2009 Marvell Semiconductor
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -59,7 +59,7 @@ int trailer_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	nskb->protocol = htons(ETH_P_TRAILER);
 
-	nskb->dev = p->parent->master_netdev;
+	nskb->dev = p->parent->dst->master_netdev;
 	dev_queue_xmit(nskb);
 
 	return NETDEV_TX_OK;
@@ -68,12 +68,14 @@ int trailer_xmit(struct sk_buff *skb, struct net_device *dev)
 static int trailer_rcv(struct sk_buff *skb, struct net_device *dev,
 		       struct packet_type *pt, struct net_device *orig_dev)
 {
-	struct dsa_switch *ds = dev->dsa_ptr;
+	struct dsa_switch_tree *dst = dev->dsa_ptr;
+	struct dsa_switch *ds;
 	u8 *trailer;
 	int source_port;
 
-	if (unlikely(ds == NULL))
+	if (unlikely(dst == NULL))
 		goto out_drop;
+	ds = dst->ds[0];
 
 	skb = skb_unshare(skb, GFP_ATOMIC);
 	if (skb == NULL)
-- 
1.5.6.4

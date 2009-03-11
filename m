From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: Marvell 88E609x switch?
Date: Wed, 11 Mar 2009 22:28:14 +0100
Message-ID: <20090311212814.GG4738@xi.wantstofly.org>
References: <49AD1C81.1020106@mlbassoc.com> <1236083560.30736.114.camel@localhost.localdomain> <49AD2FE1.60305@mlbassoc.com> <49AD30F7.4080006@mlbassoc.com> <49ADA697.3050400@mlbassoc.com> <49B145FF.5060208@mlbassoc.com> <20090310102805.GO4738@xi.wantstofly.org> <49B64CF5.9090508@mlbassoc.com> <20090310133635.GS4738@xi.wantstofly.org> <49B6831A.4080506@mlbassoc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jdb@comx.dk, Jesper Dangaard Brouer <hawk@diku.dk>,
	netdev <netdev@vger.kernel.org>
To: Gary Thomas <gary@mlbassoc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:59676 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750873AbZCKV2S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2009 17:28:18 -0400
Content-Disposition: inline
In-Reply-To: <49B6831A.4080506@mlbassoc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 10, 2009 at 09:11:22AM -0600, Gary Thomas wrote:

> The setup looks good.  Let me know when you have the rest of
> the patch ready to test (I'm all setup here)

Attached patch is what I came up with, and should implement full
cascaded DSA.  It adds the DSA device ID to DSA/EDSA tags, should
be able to deal with trees of DSA switches, and should configure
inter-switch links for DSA tagging and the CPU port for DSA or
EDSA tagging depending on which one we want.

Basically, this should let you send DSA tagged FROM_CPU packets to
any switch because it sets up the device routing table in each switch
correctly, TO_CPU packets should be able to find the CPU because we
program the upstream port into each switch, and unknown unicasts/
multicasts should find the CPU because only to upstream ports can
unknown unicasts/multicasts be forwarded.

I don't have multi-chip devices to test with, but it seems to still
work (i.e. ping still works) on the main board I use for testing
(which has a 6165).

Can you see if it works for you?

Left to do:
- Perhaps enumerate switches in multiple passes: first forcibly
  disable all ports, then configure all ports, and then re-enable
  link, to prevent races where one end of an inter-switch link is
  switched to DSA mode while the other end isn't yet.
- Re-port the HW bridging patch to go on top of this patch.
- Check if we need in-band autoneg and/or link speed forcing for
  SERDES ports.
- Perhaps allow configuring the speed/duplex/etc of the CPU port.
- Split up the patch into smaller pieces.



commit 0aabe480fe99c02a6609bdd2d2cecb001e82a7c7
Author: Lennert Buytenhek <buytenh@wantstofly.org>
Date:   Wed Mar 11 22:08:05 2009 +0100

    dsa: add dsa cascading support
    
    Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>

diff --git a/arch/arm/mach-kirkwood/common.c b/arch/arm/mach-kirkwood/common.c
index b3404b7..a2c8f6e 100644
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
+	for (i = 0; i < d->nr_switches; i++)
+		d->sw[i].mii_bus = &kirkwood_ge00_shared.dev;
 	kirkwood_switch_device.dev.platform_data = d;
 
 	platform_device_register(&kirkwood_switch_device);
diff --git a/arch/arm/mach-kirkwood/rd88f6281-setup.c b/arch/arm/mach-kirkwood/rd88f6281-setup.c
index 9a0e905..ad3fc91 100644
--- a/arch/arm/mach-kirkwood/rd88f6281-setup.c
+++ b/arch/arm/mach-kirkwood/rd88f6281-setup.c
@@ -75,7 +75,7 @@ static struct mv643xx_eth_platform_data rd88f6281_ge00_data = {
 	.duplex		= DUPLEX_FULL,
 };
 
-static struct dsa_platform_data rd88f6281_switch_data = {
+static struct dsa_switch_data rd88f6281_switch_data = {
 	.port_names[0]	= "lan1",
 	.port_names[1]	= "lan2",
 	.port_names[2]	= "lan3",
@@ -83,6 +83,11 @@ static struct dsa_platform_data rd88f6281_switch_data = {
 	.port_names[5]	= "cpu",
 };
 
+static struct dsa_platform_data rd88f6281_switch_plat_data = {
+	.nr_switches	= 1,
+	.sw		= &rd88f6281_switch_data,
+};
+
 static struct mv643xx_eth_platform_data rd88f6281_ge01_data = {
 	.phy_addr	= MV643XX_ETH_PHY_ADDR(11),
 };
@@ -110,7 +115,7 @@ static void __init rd88f6281_init(void)
 	} else {
 		rd88f6281_switch_data.port_names[4] = "wan";
 	}
-	kirkwood_ge00_switch_init(&rd88f6281_switch_data, NO_IRQ);
+	kirkwood_ge00_switch_init(&rd88f6281_switch_plat_data, NO_IRQ);
 
 	kirkwood_rtc_init();
 	kirkwood_sata_init(&rd88f6281_sata_data);
diff --git a/arch/arm/mach-orion5x/common.c b/arch/arm/mach-orion5x/common.c
index 0a62337..7eb61b3 100644
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
+	for (i = 0; i < d->nr_switches; i++)
+		d->sw[i].mii_bus = &orion5x_eth_shared.dev;
 	orion5x_switch_device.dev.platform_data = d;
 
 	platform_device_register(&orion5x_switch_device);
diff --git a/arch/arm/mach-orion5x/rd88f5181l-fxo-setup.c b/arch/arm/mach-orion5x/rd88f5181l-fxo-setup.c
index 15f5323..aa6968c 100644
--- a/arch/arm/mach-orion5x/rd88f5181l-fxo-setup.c
+++ b/arch/arm/mach-orion5x/rd88f5181l-fxo-setup.c
@@ -94,7 +94,7 @@ static struct mv643xx_eth_platform_data rd88f5181l_fxo_eth_data = {
 	.duplex		= DUPLEX_FULL,
 };
 
-static struct dsa_platform_data rd88f5181l_fxo_switch_data = {
+static struct dsa_switch_data rd88f5181l_fxo_switch_data = {
 	.port_names[0]	= "lan2",
 	.port_names[1]	= "lan1",
 	.port_names[2]	= "wan",
@@ -103,6 +103,11 @@ static struct dsa_platform_data rd88f5181l_fxo_switch_data = {
 	.port_names[7]	= "lan3",
 };
 
+static struct dsa_platform_data rd88f5181l_fxo_switch_plat_data = {
+	.nr_switches	= 1,
+	.sw		= &rd88f5181l_fxo_switch_data,
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
index 8ad3934..d48c57b 100644
--- a/arch/arm/mach-orion5x/rd88f5181l-ge-setup.c
+++ b/arch/arm/mach-orion5x/rd88f5181l-ge-setup.c
@@ -95,7 +95,7 @@ static struct mv643xx_eth_platform_data rd88f5181l_ge_eth_data = {
 	.duplex		= DUPLEX_FULL,
 };
 
-static struct dsa_platform_data rd88f5181l_ge_switch_data = {
+static struct dsa_switch_data rd88f5181l_ge_switch_data = {
 	.port_names[0]	= "lan2",
 	.port_names[1]	= "lan1",
 	.port_names[2]	= "wan",
@@ -104,6 +104,11 @@ static struct dsa_platform_data rd88f5181l_ge_switch_data = {
 	.port_names[7]	= "lan3",
 };
 
+static struct dsa_platform_data rd88f5181l_ge_switch_plat_data = {
+	.nr_switches	= 1,
+	.sw		= &rd88f5181l_ge_switch_data,
+};
+
 static struct i2c_board_info __initdata rd88f5181l_ge_i2c_rtc = {
 	I2C_BOARD_INFO("ds1338", 0x68),
 };
@@ -122,7 +127,7 @@ static void __init rd88f5181l_ge_init(void)
 	 */
 	orion5x_ehci0_init();
 	orion5x_eth_init(&rd88f5181l_ge_eth_data);
-	orion5x_eth_switch_init(&rd88f5181l_ge_switch_data, gpio_to_irq(8));
+	orion5x_eth_switch_init(&rd88f5181l_ge_switch_plat_data, gpio_to_irq(8));
 	orion5x_i2c_init();
 	orion5x_uart0_init();
 
diff --git a/arch/arm/mach-orion5x/rd88f6183ap-ge-setup.c b/arch/arm/mach-orion5x/rd88f6183ap-ge-setup.c
index 262e25e..eb716b8 100644
--- a/arch/arm/mach-orion5x/rd88f6183ap-ge-setup.c
+++ b/arch/arm/mach-orion5x/rd88f6183ap-ge-setup.c
@@ -35,7 +35,7 @@ static struct mv643xx_eth_platform_data rd88f6183ap_ge_eth_data = {
 	.duplex		= DUPLEX_FULL,
 };
 
-static struct dsa_platform_data rd88f6183ap_ge_switch_data = {
+static struct dsa_switch_data rd88f6183ap_ge_switch_data = {
 	.port_names[0]	= "lan1",
 	.port_names[1]	= "lan2",
 	.port_names[2]	= "lan3",
@@ -44,6 +44,11 @@ static struct dsa_platform_data rd88f6183ap_ge_switch_data = {
 	.port_names[5]	= "cpu",
 };
 
+static struct dsa_platform_data rd88f6183ap_ge_switch_plat_data = {
+	.nr_switches	= 1,
+	.sw		= &rd88f6183ap_ge_switch_data,
+};
+
 static struct mtd_partition rd88f6183ap_ge_partitions[] = {
 	{
 		.name	= "kernel",
@@ -89,7 +94,7 @@ static void __init rd88f6183ap_ge_init(void)
 	 */
 	orion5x_ehci0_init();
 	orion5x_eth_init(&rd88f6183ap_ge_eth_data);
-	orion5x_eth_switch_init(&rd88f6183ap_ge_switch_data, gpio_to_irq(3));
+	orion5x_eth_switch_init(&rd88f6183ap_ge_switch_plat_data, gpio_to_irq(3));
 	spi_register_board_info(rd88f6183ap_ge_spi_slave_info,
 				ARRAY_SIZE(rd88f6183ap_ge_spi_slave_info));
 	orion5x_spi_init();
diff --git a/arch/arm/mach-orion5x/wrt350n-v2-setup.c b/arch/arm/mach-orion5x/wrt350n-v2-setup.c
index cc8f892..238c8b2 100644
--- a/arch/arm/mach-orion5x/wrt350n-v2-setup.c
+++ b/arch/arm/mach-orion5x/wrt350n-v2-setup.c
@@ -106,7 +106,7 @@ static struct mv643xx_eth_platform_data wrt350n_v2_eth_data = {
 	.duplex		= DUPLEX_FULL,
 };
 
-static struct dsa_platform_data wrt350n_v2_switch_data = {
+static struct dsa_switch_data wrt350n_v2_switch_data = {
 	.port_names[0]	= "lan2",
 	.port_names[1]	= "lan1",
 	.port_names[2]	= "wan",
@@ -115,6 +115,11 @@ static struct dsa_platform_data wrt350n_v2_switch_data = {
 	.port_names[7]	= "lan4",
 };
 
+static struct dsa_platform_data wrt350n_v2_switch_plat_data = {
+	.nr_switches	= 1,
+	.sw		= &wrt350n_v2_switch_data,
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
index 52e97bf..649ade3 100644
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
+struct dsa_switch_data {
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
+	 * An array (with nr_switches elements) of which element [a]
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
+	int		nr_switches;
+	struct dsa_switch_data *sw;
 };
 
 extern bool dsa_uses_dsa_tags(void *dsa_ptr);
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 33e9946..7ac31cc 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -67,12 +67,13 @@ dsa_switch_probe(struct mii_bus *bus, int sw_addr, char **_name)
 
 /* basic switch operations **************************************************/
 static struct dsa_switch *
-dsa_switch_setup(struct device *parent, struct dsa_platform_data *pd,
-		 struct mii_bus *bus, struct net_device *dev)
+dsa_switch_setup(struct dsa_switch_tree *dst, int index,
+		 struct device *parent, struct mii_bus *bus)
 {
+	struct dsa_switch_data *pd = dst->pd->sw + index;
+	struct dsa_switch_driver *drv;
 	struct dsa_switch *ds;
 	int ret;
-	struct dsa_switch_driver *drv;
 	char *name;
 	int i;
 
@@ -82,10 +83,11 @@ dsa_switch_setup(struct device *parent, struct dsa_platform_data *pd,
 	drv = dsa_switch_probe(bus, pd->sw_addr, &name);
 	if (drv == NULL) {
 		printk(KERN_ERR "%s: could not detect attached switch\n",
-		       dev->name);
+		       dst->master_netdev->name);
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
+	ds->pd = dst->pd->sw + index;
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
 			printk(KERN_ERR "%s: can't create dsa slave "
-			       "device for port %d(%s)\n",
-			       dev->name, i, pd->port_names[i]);
+			       "device for port %d:%d(%s)\n",
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
@@ -212,35 +207,40 @@ static void dsa_switch_destroy(struct dsa_switch *ds)
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
+	for (i = 0; i < dst->pd->nr_switches; i++) {
+		struct dsa_switch *ds = dst->ds[i];
+		ds->drv->poll_link(ds);
+	}
 
-	ds->drv->poll_link(ds);
-	mod_timer(&ds->link_poll_timer, round_jiffies(jiffies + HZ));
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
 
 
@@ -303,18 +303,14 @@ static int dsa_probe(struct platform_device *pdev)
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
@@ -326,36 +322,79 @@ static int dsa_probe(struct platform_device *pdev)
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
+	for (i = 0; i < pd->nr_switches; i++) {
+		struct mii_bus *bus;
+		struct dsa_switch *ds;
+
+		bus = dev_to_mii_bus(pd->sw[i].mii_bus);
+		if (bus == NULL) {
+			printk(KERN_ERR "%s: no mii bus found for "
+				"dsa switch %d\n", dev->name, i);
+			continue;
+		}
+
+		ds = dsa_switch_setup(dst, i, &pdev->dev, bus);
+		if (IS_ERR(ds)) {
+			printk(KERN_ERR "%s: couldn't create dsa switch "
+				"instance for switch %d (error %ld)\n",
+				dev->name, i, PTR_ERR(ds));
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
+	for (i = 0; i < dst->pd->nr_switches; i++) {
+		struct dsa_switch *ds = dst->ds[i];
+
+		if (ds != NULL)
+			dsa_switch_destroy(ds);
+	}
 
 	return 0;
 }
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 7063378..e6b4e83 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
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
+	struct dsa_switch_data	*pd;
 
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
index 85081ae..d56bfe0 100644
--- a/net/dsa/mv88e6060.c
+++ b/net/dsa/mv88e6060.c
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
@@ -138,9 +138,8 @@ static int mv88e6060_setup_port(struct dsa_switch *ds, int p)
 	 */
 	REG_WRITE(addr, 0x06,
 			((p & 0xf) << 12) |
-			 ((p == ds->cpu_port) ?
-				ds->valid_port_mask :
-				(1 << ds->cpu_port)));
+			 (dsa_is_cpu_port(ds, p) ?
+				ds->phys_port_mask : (1 << ds->dst->cpu_port)));
 
 	/*
 	 * Port Association Vector: when learning source addresses
diff --git a/net/dsa/mv88e6123_61_65.c b/net/dsa/mv88e6123_61_65.c
index ec8c6a0..2e2e794 100644
--- a/net/dsa/mv88e6123_61_65.c
+++ b/net/dsa/mv88e6123_61_65.c
@@ -98,11 +98,11 @@ static int mv88e6123_61_65_setup_global(struct dsa_switch *ds)
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
+		if (i != ds->index && i < ds->dst->pd->nr_switches)
+			nexthop = ds->pd->rtable[i] & 0x1f;
+
+		REG_WRITE(REG_GLOBAL2, 0x06, 0x8000 | (i << 8) | nexthop);
+	}
 
 	/*
 	 * Clear all trunk masks.
@@ -176,6 +183,7 @@ static int mv88e6123_61_65_setup_global(struct dsa_switch *ds)
 static int mv88e6123_61_65_setup_port(struct dsa_switch *ds, int p)
 {
 	int addr = REG_PORT(p);
+	u16 val;
 
 	/*
 	 * MAC Forcing register: don't force link, speed, duplex
@@ -192,37 +200,46 @@ static int mv88e6123_61_65_setup_port(struct dsa_switch *ds, int p)
 
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
+	 * If this is the upstream port for this switch, enable
+	 * forwarding of unknown unicasts and multicasts.
+	 *
+	 * If this is a link to another switch, use DSA tagging mode.
+	 *
+	 * If this is the CPU link, use DSA or EDSA tagging depending
+	 * on which tagging mode was configured.
+	 */
+	val = 0x0433;
+	if (p == dsa_upstream_port(ds))
+		val |= 0x000c;
+	if (ds->dsa_port_mask & (1 << p))
+		val |= 0x0100;
+	if (dsa_is_cpu_port(ds, p) && ds->dst->tag_protocol == htons(ETH_P_EDSA))
+		val |= 0x3300;
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
index 4e24eca..61f07d4 100644
--- a/net/dsa/mv88e6131.c
+++ b/net/dsa/mv88e6131.c
@@ -102,11 +102,11 @@ static int mv88e6131_setup_global(struct dsa_switch *ds)
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
+		if (i != ds->index && i < ds->dst->pd->nr_switches)
+			nexthop = ds->pd->rtable[i] & 0x1f;
+
+		REG_WRITE(REG_GLOBAL2, 0x06, 0x8000 | (i << 8) | nexthop);
+	}
 
 	/*
 	 * Clear all trunk masks.
@@ -158,13 +165,14 @@ static int mv88e6131_setup_global(struct dsa_switch *ds)
 static int mv88e6131_setup_port(struct dsa_switch *ds, int p)
 {
 	int addr = REG_PORT(p);
+	u16 val;
 
 	/*
 	 * MAC Forcing register: don't force link, speed, duplex
 	 * or flow control state to any particular values on physical
 	 * ports, but force the CPU port to 1000 Mb/s full duplex.
 	 */
-	if (p == ds->cpu_port)
+	if (dsa_is_cpu_port(ds, p))
 		REG_WRITE(addr, 0x01, 0x003e);
 	else
 		REG_WRITE(addr, 0x01, 0x0003);
@@ -175,29 +183,40 @@ static int mv88e6131_setup_port(struct dsa_switch *ds, int p)
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
+		val |= 0x0004;
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
@@ -213,13 +232,15 @@ static int mv88e6131_setup_port(struct dsa_switch *ds, int p)
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
diff --git a/net/dsa/mv88e6xxx.h b/net/dsa/mv88e6xxx.h
index eb0e0aa..09f13b2 100644
--- a/net/dsa/mv88e6xxx.h
+++ b/net/dsa/mv88e6xxx.h
@@ -19,7 +19,7 @@ struct mv88e6xxx_priv_state {
 	/*
 	 * When using multi-chip addressing, this mutex protects
 	 * access to the indirect access registers.  (In single-chip
-	 * mode, this mutex is effectively useless.)
+	 * addressing mode, this mutex is effectively useless.)
 	 */
 	struct mutex	smi_mutex;
 
@@ -89,5 +89,4 @@ void mv88e6xxx_get_ethtool_stats(struct dsa_switch *ds,
 	})
 
 
-
 #endif
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 99114e5..eaa7a22 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
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
index f99a019..237e419 100644
--- a/net/dsa/tag_dsa.c
+++ b/net/dsa/tag_dsa.c
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
@@ -105,9 +107,17 @@ static int dsa_rcv(struct sk_buff *skb, struct net_device *dev,
 		goto out_drop;
 
 	/*
-	 * Check that the source port is a registered DSA port.
+	 * Determine source port and device.
 	 */
+	source_device = dsa_header[0] & 0x1f;
 	source_port = (dsa_header[1] >> 3) & 0x1f;
+
+	/*
+	 * Check that the source device/port combo is valid.
+	 */
+	if (source_device >= dst->pd->nr_switches)
+		goto out_drop;
+	ds = dst->ds[source_device];
 	if (source_port >= DSA_MAX_PORTS || ds->ports[source_port] == NULL)
 		goto out_drop;
 
diff --git a/net/dsa/tag_edsa.c b/net/dsa/tag_edsa.c
index 328ec95..8606941 100644
--- a/net/dsa/tag_edsa.c
+++ b/net/dsa/tag_edsa.c
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
@@ -118,9 +120,17 @@ static int edsa_rcv(struct sk_buff *skb, struct net_device *dev,
 		goto out_drop;
 
 	/*
-	 * Check that the source port is a registered DSA port.
+	 * Determine source port and device.
 	 */
+	source_device = edsa_header[0] & 0x1f;
 	source_port = (edsa_header[1] >> 3) & 0x1f;
+
+	/*
+	 * Check that the source port is a registered DSA port.
+	 */
+	if (source_device >= dst->pd->nr_switches)
+		goto out_drop;
+	ds = dst->ds[source_device];
 	if (source_port >= DSA_MAX_PORTS || ds->ports[source_port] == NULL)
 		goto out_drop;
 
diff --git a/net/dsa/tag_trailer.c b/net/dsa/tag_trailer.c
index b591328..d8f9ecf 100644
--- a/net/dsa/tag_trailer.c
+++ b/net/dsa/tag_trailer.c
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

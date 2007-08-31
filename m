From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH 1/7] Generic bitbanged MDIO library
Date: Fri, 31 Aug 2007 10:16:08 -0500
Message-ID: <20070831151608.GB27021@ld0162-tx32.am.freescale.net>
References: <20070817175357.GA9218@ld0162-tx32.am.freescale.net> <46D81638.6050509@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	Paul Mackerras <paulus@samba.org>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:60684 "EHLO
	de01egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932284AbXHaPQk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2007 11:16:40 -0400
Content-Disposition: inline
In-Reply-To: <46D81638.6050509@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 31, 2007 at 09:23:04AM -0400, Jeff Garzik wrote:
> I cannot ACK this, nor do I want to see it merged, until users appear 
> and have been reviewed alongside this.  I do not see any fs_enet patches 
> that actually use this.

The fs_enet patchset does use it in mii-bitbang.c, in patch 6/7 (or 7/8
in the revised patchset).  I'll also be using it on the ep8248e board
(which is why I factored it out), which I'll attach below.

> * the delay (where you call ndelay()) is not guaranteed without a flush 
> of some sort

Hmm...  I'm inclined to push that into the client's implementation of set
mdc/data, primarily because there's no get mdc to do a read-back
generically.

> * how widely applicable is this "generic" library?

It implements MDIO as described in the ethernet specification; there
should be no implementation dependencies.

>  have you converted any non-embedded drivers over to it?

No; most hardware doesn't need bitbanging.  Sunhme does, but I don't have
hardware to test a conversion.

Here's the ep8248e user of the bitbang code:

/*
 * Embedded Planet EP8248E support
 *
 * Copyright 2007 Freescale Semiconductor, Inc.
 * Author: Scott Wood <scottwood@freescale.com>
 *
 * This program is free software; you can redistribute  it and/or modify
 * it under the terms of version 2 of the GNU General Public License as
 * published by the Free Software Foundation.
 */

#include <linux/init.h>
#include <linux/interrupt.h>
#include <linux/fsl_devices.h>
#include <linux/mdio-bitbang.h>
#include <linux/of_platform.h>

#include <asm/io.h>
#include <asm/cpm2.h>
#include <asm/udbg.h>
#include <asm/machdep.h>
#include <asm/time.h>
#include <asm/mpc8260.h>

#include <sysdev/fsl_soc.h>
#include <sysdev/cpm2_pic.h>

#include "pq2.h"

static u8 __iomem *ep8248e_bcsr;
static struct device_node *ep8248e_bcsr_node;

#define BCSR7_SCC2_ENABLE 0x10

#define BCSR8_PHY1_ENABLE 0x80
#define BCSR8_PHY1_POWER  0x40
#define BCSR8_PHY2_ENABLE 0x20
#define BCSR8_PHY2_POWER  0x10
#define BCSR8_MDIO_READ   0x04
#define BCSR8_MDIO_CLOCK  0x02
#define BCSR8_MDIO_DATA   0x01

#define BCSR9_USB_ENABLE  0x80
#define BCSR9_USB_POWER   0x40
#define BCSR9_USB_HOST    0x20
#define BCSR9_USB_FULL_SPEED_TARGET 0x10

static void __init ep8248_pic_init(void)
{
	struct device_node *np = of_find_compatible_node(NULL, NULL, "fsl,pq2-pic");
	if (!np) {
		printk(KERN_ERR "PIC init: can not find cpm-pic node\n");
		return;
	}

	cpm2_pic_init(np);
	of_node_put(np);
}

static void ep8248e_set_mdc(struct mdio_bitbang_ctrl *ctrl, int level)
{
	if (level)
		setbits8(&ep8248e_bcsr[8], BCSR8_MDIO_CLOCK);
	else
		clrbits8(&ep8248e_bcsr[8], BCSR8_MDIO_CLOCK);

	/* Flush the write before delaying. */
	in_8(&ep8248e_bcsr[8]);
}

static void ep8248e_set_mdio_dir(struct mdio_bitbang_ctrl *ctrl, int output)
{
	if (output)
		clrbits8(&ep8248e_bcsr[8], BCSR8_MDIO_READ);
	else
		setbits8(&ep8248e_bcsr[8], BCSR8_MDIO_READ);

	/* Flush the write before delaying. */
	in_8(&ep8248e_bcsr[8]);
}

static void ep8248e_set_mdio_data(struct mdio_bitbang_ctrl *ctrl, int data)
{
	if (data)
		setbits8(&ep8248e_bcsr[8], BCSR8_MDIO_DATA);
	else
		clrbits8(&ep8248e_bcsr[8], BCSR8_MDIO_DATA);

	/* Flush the write before delaying. */
	in_8(&ep8248e_bcsr[8]);
}

static int ep8248e_get_mdio_data(struct mdio_bitbang_ctrl *ctrl)
{
	return in_8(&ep8248e_bcsr[8]) & BCSR8_MDIO_DATA;
}

static struct mdio_bitbang_ops ep8248e_mdio_ops = {
	.set_mdc = ep8248e_set_mdc,
	.set_mdio_dir = ep8248e_set_mdio_dir,
	.set_mdio_data = ep8248e_set_mdio_data,
	.get_mdio_data = ep8248e_get_mdio_data,
	.owner = THIS_MODULE,
};

static struct mdio_bitbang_ctrl ep8248e_mdio_ctrl = {
	.ops = &ep8248e_mdio_ops,
};

static int __devinit ep8248e_mdio_probe(struct of_device *ofdev,
                                        const struct of_device_id *match)
{
	struct mii_bus *bus;
	struct resource res;
	int ret, i;

	if (of_get_parent(ofdev->node) != ep8248e_bcsr_node)
		return -ENODEV;

	ret = of_address_to_resource(ofdev->node, 0, &res);
	if (ret)
		return ret;

	bus = alloc_mdio_bitbang(&ep8248e_mdio_ctrl);
	if (!bus)
		return -ENOMEM;

	bus->phy_mask = 0;
	bus->irq = kmalloc(sizeof(int) * PHY_MAX_ADDR, GFP_KERNEL);

	for (i = 0; i < PHY_MAX_ADDR; i++)
		bus->irq[i] = -1;

	bus->name = "ep8248e-mdio-bitbang";
	bus->dev = &ofdev->dev;
	bus->id = res.start;

	return mdiobus_register(bus);
}

static int ep8248e_mdio_remove(struct of_device *ofdev)
{
	BUG();
	return 0;
}

static struct of_device_id ep8248e_mdio_match[] = {
	{
		.compatible = "fsl,ep8248e-mdio-bitbang",
	},
	{},
};

static struct of_platform_driver ep8248e_mdio_driver = {
	.name = "ep8248e-mdio-bitbang",
	.match_table = ep8248e_mdio_match,
	.probe = ep8248e_mdio_probe,
	.remove = ep8248e_mdio_remove,
};

struct cpm_pin {
	int port, pin, flags;
};

static struct cpm_pin ep8248_pins[] = {
	/* SMC1 */
	{2, 4, CPM_PIN_INPUT | CPM_PIN_PRIMARY},
	{2, 5, CPM_PIN_OUTPUT | CPM_PIN_PRIMARY},

	/* SCC1 */
	{2, 14, CPM_PIN_INPUT | CPM_PIN_PRIMARY},
	{2, 15, CPM_PIN_INPUT | CPM_PIN_PRIMARY},
	{3, 29, CPM_PIN_OUTPUT | CPM_PIN_PRIMARY},
	{3, 30, CPM_PIN_OUTPUT | CPM_PIN_SECONDARY},
	{3, 31, CPM_PIN_INPUT | CPM_PIN_PRIMARY},

	/* FCC1 */
	{0, 14, CPM_PIN_INPUT | CPM_PIN_PRIMARY},
	{0, 15, CPM_PIN_INPUT | CPM_PIN_PRIMARY},
	{0, 16, CPM_PIN_INPUT | CPM_PIN_PRIMARY},
	{0, 17, CPM_PIN_INPUT | CPM_PIN_PRIMARY},
	{0, 18, CPM_PIN_OUTPUT | CPM_PIN_PRIMARY},
	{0, 19, CPM_PIN_OUTPUT | CPM_PIN_PRIMARY},
	{0, 20, CPM_PIN_OUTPUT | CPM_PIN_PRIMARY},
	{0, 21, CPM_PIN_OUTPUT | CPM_PIN_PRIMARY},
	{0, 26, CPM_PIN_INPUT | CPM_PIN_SECONDARY},
	{0, 27, CPM_PIN_INPUT | CPM_PIN_SECONDARY},
	{0, 28, CPM_PIN_OUTPUT | CPM_PIN_SECONDARY},
	{0, 29, CPM_PIN_OUTPUT | CPM_PIN_SECONDARY},
	{0, 30, CPM_PIN_INPUT | CPM_PIN_SECONDARY},
	{0, 31, CPM_PIN_INPUT | CPM_PIN_SECONDARY},
	{2, 21, CPM_PIN_INPUT | CPM_PIN_PRIMARY},
	{2, 22, CPM_PIN_INPUT | CPM_PIN_PRIMARY},

	/* FCC2 */
	{1, 18, CPM_PIN_INPUT | CPM_PIN_PRIMARY},
	{1, 19, CPM_PIN_INPUT | CPM_PIN_PRIMARY},
	{1, 20, CPM_PIN_INPUT | CPM_PIN_PRIMARY},
	{1, 21, CPM_PIN_INPUT | CPM_PIN_PRIMARY},
	{1, 22, CPM_PIN_OUTPUT | CPM_PIN_PRIMARY},
	{1, 23, CPM_PIN_OUTPUT | CPM_PIN_PRIMARY},
	{1, 24, CPM_PIN_OUTPUT | CPM_PIN_PRIMARY},
	{1, 25, CPM_PIN_OUTPUT | CPM_PIN_PRIMARY},
	{1, 26, CPM_PIN_INPUT | CPM_PIN_PRIMARY},
	{1, 27, CPM_PIN_INPUT | CPM_PIN_PRIMARY},
	{1, 28, CPM_PIN_INPUT | CPM_PIN_PRIMARY},
	{1, 29, CPM_PIN_OUTPUT | CPM_PIN_SECONDARY},
	{1, 30, CPM_PIN_INPUT | CPM_PIN_PRIMARY},
	{1, 31, CPM_PIN_OUTPUT | CPM_PIN_PRIMARY},
	{2, 18, CPM_PIN_INPUT | CPM_PIN_PRIMARY},
	{2, 19, CPM_PIN_INPUT | CPM_PIN_PRIMARY},

	/* I2C */
	{4, 14, CPM_PIN_INPUT | CPM_PIN_SECONDARY},
	{4, 15, CPM_PIN_INPUT | CPM_PIN_SECONDARY},

	/* USB */
	{2, 10, CPM_PIN_INPUT | CPM_PIN_PRIMARY},
	{2, 11, CPM_PIN_INPUT | CPM_PIN_PRIMARY},
	{2, 20, CPM_PIN_OUTPUT | CPM_PIN_PRIMARY},
	{2, 24, CPM_PIN_INPUT | CPM_PIN_PRIMARY},
	{3, 23, CPM_PIN_OUTPUT | CPM_PIN_PRIMARY},
	{3, 24, CPM_PIN_OUTPUT | CPM_PIN_PRIMARY},
	{3, 25, CPM_PIN_INPUT | CPM_PIN_PRIMARY},
};

static void __init init_ioports(void)
{
	int i;

	for (i = 0; i < ARRAY_SIZE(ep8248_pins); i++) {
		struct cpm_pin *pin = &ep8248_pins[i];
		cpm2_set_pin(pin->port, pin->pin, pin->flags);
	}

	cpm2_smc_clk_setup(CPM_CLK_SMC1, CPM_BRG7);
	cpm2_clk_setup(CPM_CLK_SCC1, CPM_BRG1, CPM_CLK_RX);
	cpm2_clk_setup(CPM_CLK_SCC1, CPM_BRG1, CPM_CLK_TX);
	cpm2_clk_setup(CPM_CLK_SCC3, CPM_CLK8, CPM_CLK_TX); /* USB */
	cpm2_clk_setup(CPM_CLK_FCC1, CPM_CLK11, CPM_CLK_RX);
	cpm2_clk_setup(CPM_CLK_FCC1, CPM_CLK10, CPM_CLK_TX);
	cpm2_clk_setup(CPM_CLK_FCC2, CPM_CLK13, CPM_CLK_RX);
	cpm2_clk_setup(CPM_CLK_FCC2, CPM_CLK14, CPM_CLK_TX);
}

static void __init ep8248_setup_arch(void)
{
	if (ppc_md.progress)
		ppc_md.progress("ep8248_setup_arch()", 0);

	cpm2_reset();

	/* When this is set, snooping CPM DMA from RAM causes
	 * machine checks.  See erratum SIU18.
	 */
	clrbits32(&cpm2_immr->im_siu_conf.siu_82xx.sc_bcr, MPC82XX_BCR_PLDP);

	ep8248e_bcsr_node =
		of_find_compatible_node(NULL, NULL, "fsl,ep8248e-bcsr");
	if (!ep8248e_bcsr_node) {
		printk(KERN_ERR "No bcsr in device tree\n");
		return;
	}

	ep8248e_bcsr = of_iomap(ep8248e_bcsr_node, 0);
	if (!ep8248e_bcsr) {
		printk(KERN_ERR "Cannot map BCSR registers\n");
		return;
	}

	setbits8(&ep8248e_bcsr[7], BCSR7_SCC2_ENABLE);
	setbits8(&ep8248e_bcsr[8], BCSR8_PHY1_ENABLE | BCSR8_PHY1_POWER |
	                           BCSR8_PHY2_ENABLE | BCSR8_PHY2_POWER);

	init_ioports();

	if (ppc_md.progress)
		ppc_md.progress("ep8248_setup_arch(), finish", 0);
}

static struct of_device_id __initdata of_bus_ids[] = {
	{ .name = "soc", },
	{ .name = "cpm", },
	{ .compatible = "fsl,pq2-chipselect", },
	{ .compatible = "fsl,ep8248e-bcsr", },
	{},
};

static int __init declare_of_platform_devices(void)
{
	if (!machine_is(ep8248))
		return 0;

	of_platform_bus_probe(NULL, of_bus_ids, NULL);
	of_register_platform_driver(&ep8248e_mdio_driver);

	return 0;
}
device_initcall(declare_of_platform_devices);

/*
 * Called very early, device-tree isn't unflattened
 */
static int __init ep8248_probe(void)
{
	unsigned long root = of_get_flat_dt_root();
	return of_flat_dt_is_compatible(root, "fsl,ep8248e");
}

define_machine(ep8248)
{
	.name = "Embedded Planet EP8248E",
	.probe = ep8248_probe,
	.setup_arch = ep8248_setup_arch,
	.init_IRQ = ep8248_pic_init,
	.get_irq = cpm2_get_irq,
	.calibrate_decr = generic_calibrate_decr,
	.restart = pq2_restart,
	.progress = udbg_progress,
};

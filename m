From: Henk Stegeman <henk.stegeman@gmail.com>
Subject: Davicom DM9000A on MPC5200B (powerpc) works using a dirty offsetting
	and byte trick
Date: Fri, 20 Feb 2009 10:51:48 +0100
Message-ID: <ae4f76fd0902200151m461f9336x1e2bbec61f815fde@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.185]:12883 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752354AbZBTJvu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2009 04:51:50 -0500
Received: by fk-out-0910.google.com with SMTP id f33so738798fkf.5
        for <netdev@vger.kernel.org>; Fri, 20 Feb 2009 01:51:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

My board has a Davicom DM9000A ethernet controller on the MPC5200B's
Local Plus bus.
With the following setup and code the controller *works fine* with the
MPC5200B, but I think the code + setup to make it happen could be a
lot cleaner.

The DM9000A is setup for 16 bit mode, and wired as such to the
MPC5200B, A1 is wired to the DM9000 CMD pin.
The DM9000 is accessed trough two registers, address and data register.
The chip-select used is CS1 and it is setup in U-boot as follows:
/*	Start addres: FB000000
	Data Bus Size: 2 bytes
	Address Bus Size: 16 bit
	Mux off.
*/
#define CFG_CS1_CFG = 0x04041500

The resulting physical DM9000 register map is:
FB000000 : address register
FB000002 : data register

I have the following definition for this network device in my dts:

	enet1:ethernet@fb000000 {
		#size-cells = <1>;
		#address-cells = <1>;
		device_type = "network";
		compatible = "davicom,dm9000";
		reg = <0xfb000000 0x00000002 		// DM9000 Address register
			0xfb000002 0x00000002>;		// DM9000 Data register
		mac-address = [ 00 00 00 00 00 00 ]; // Filled in by u-boot
		interrupts = <1 1 0>;			// External interrupt 1
		interrupt-parent = <&mpc5200_pic>;
	};

To pass this information to the unmodified DM9000 driver I put
together a wrapper arch/powerpc/sysdev/dm9000_dev.c (see below) for
the of_ part (I reused most of the work from
arch/powerpc/sysdev/tsi108_dev.c):

Because the dm9000 driver uses the data address both as pointer to u16
and pointer to u8, this works for a little-endian cpu to the
little-endian dm9000, but not for the big endian MPC5200 to little
endian dm9000.
So I add an offset of 1 to this pointer when it is passed to the
dm9000 driver. This offset of 1 is wrong for the u16 accesses of the
DM9000 driver, besides that the data needs to be byteswapped for the
dm9000 driver.
For these two reasons I wrote the functions dm9000_outblk_16bit
dm9000_intblk_16bit dm9000_dumpblk_16bit which are passed via the
platform_data.

Apart from comments on my assumptions I have the following questions
about this situation and my code:
- Is it the right way to make a separate arch/powerpc/sysdev/*_dev.c
for reading the device-tree and passing it to a driver, in stead of
adding it to the driver itself?
- I think the best solution to handle the separate address and data
register is the 2 entry register array in the device tree as above,
this accounts for an odd connection to the DM9000's CMD pin. Agree?
- The MPC5200's chip-select can be configured to do byte-swapping on
read and write, however when I configured it as such and I removed my
offsetting by 1 and byte-swapping code It didn't work.
- Any suggestions to what could be wrong here? Or does the MPC5200 in
this case only byte swap u16 reads, but a u8 read is unchanged?
- What about how the DM9000 driver deals with this u8 read and u16
read, is this correct?

Thanks,

Henk

----

/*
 * dm9000 device setup code
 *
 * Maintained by Henk Stegeman < henk.stegeman@gmail.com >
 *
 * This program is free software; you can redistribute it and/or modify it
 * under  the terms of  the GNU General  Public License as published by the
 * Free Software Foundation;  either version 2 of the  License, or (at your
 * option) any later version.
 */

#include <linux/stddef.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/errno.h>
#include <linux/major.h>
#include <linux/delay.h>
#include <linux/irq.h>
#include <linux/module.h>
#include <linux/device.h>
#include <linux/platform_device.h>
#include <linux/dm9000.h>

#include <asm/system.h>
#include <asm/atomic.h>
#include <asm/io.h>
#include <asm/irq.h>
#include <asm/prom.h>
#include <mm/mmu_decl.h>

#ifdef DEBUG
#define DBG(fmt...) do { printk(fmt); } while(0)
#else
#define DBG(fmt...) do { } while(0)
#endif

#define U16_SWAP_BYTES(v) (((v << 8) & 0xff00) | ((v >> 8) & 0x00ff))
static void dm9000_outblk_16bit(void __iomem *reg, void *data, int count)
{
	u16 * pU16 = data;
	count = ( count + 1 ) >> 1;
	while (count > 0) {
		/* subtract 1 from reg to get back at the 16bit reg addr */
		out_be16(reg - 1, U16_SWAP_BYTES(* pU16));
		pU16 ++;
		count --;
	}
}

static void dm9000_inblk_16bit(void __iomem *reg, void *data, int count)
{
	u16 * pU16 = data;
	count = ( count + 1 ) >> 1;
	while (count > 0) {	
		/* subtract 1 from reg to get back at the 16bit reg addr */
		* pU16 = in_be16(reg - 1);		
		* pU16 = U16_SWAP_BYTES(* pU16);
		pU16 ++;
		count --;
	}
}

static void dm9000_dumpblk_16bit(void __iomem *reg, int count)
{
	volatile u16 tmp;
	count = ( count + 1 ) >> 1;
	while (count > 0) {	
		/* subtract 1 from reg to get back at the 16bit reg addr */
		tmp = in_be16(reg - 1);		
		count --;
	}
}

#define NUM_DM9000_RESOURCES 3
static int __init dm9000_eth_of_init(void)
{
	struct device_node *np;
	unsigned int i = 0;
	struct platform_device *dm9000_eth_dev;
	int ret;

	for_each_compatible_node(np, "network", "davicom,dm9000") {
		struct resource r[NUM_DM9000_RESOURCES];
		struct dm9000_plat_data dm9000_eth_data;
		const void *dev_addr;

		memset(r, 0, sizeof(r));
		memset(&dm9000_eth_data, 0, sizeof(dm9000_eth_data));

		/* Address register. */
		ret = of_address_to_resource(np, 0, &r[0]);
		++ r[0].start; /* dm9000 driver uses this as an address to a u8,
						  our address is to a big endian u16, add an
						  offset of 1 byte so dm9000 driver reads the expected
						  least-significant byte */
		DBG("%s: name:start->end = %s:0x%lx-> 0x%lx\n",
			__func__,r[0].name, r[0].start, r[0].end);
		if (ret)
			goto err;

		/* Data register. */
		ret = of_address_to_resource(np, 1, &r[1]);
		++ r[1].start; /* dm9000 driver uses this as an address to a u8,
						  our address is to a big endian u16, add an
						  offset of 1 byte so dm9000 driver reads the expected
						  least-significant byte */
		DBG("%s: name:start->end = %s:0x%lx-> 0x%lx\n",
			__func__,r[1].name, r[1].start, r[1].end);
		if (ret)
			goto err;

		/* IRQ. */
		r[2].name = "irq";
		r[2].start = irq_of_parse_and_map(np, 0);
		r[2].flags = IORESOURCE_IRQ_HIGHLEVEL;
		if (r[2].start == NO_IRQ) {
			DBG("%s: irq_of_parse_and_map failed\n", __func__);
		}

		r[2].end = irq_of_parse_and_map(np, 0);
		if (r[2].end == NO_IRQ) {
			DBG("%s: irq_of_parse_and_map failed\n", __func__);
		}
		r[2].flags = IORESOURCE_IRQ;
		DBG("%s: name:start->end = %s:0x%lx-> 0x%lx\n",
			__func__,r[2].name, r[2].start, r[2].end);

		dm9000_eth_dev =
		    platform_device_register_simple("dm9000", i++, &r[0],
						    NUM_DM9000_RESOURCES);

		if (IS_ERR(dm9000_eth_dev)) {
			ret = PTR_ERR(dm9000_eth_dev);
			goto err;
		}

		dev_addr = of_get_mac_address(np);
		if (dev_addr) {
			memcpy(dm9000_eth_data.dev_addr, dev_addr, 6);
			dm9000_eth_data.flags |= DM9000_PLATF_NO_EEPROM;
		}		
		dm9000_eth_data.flags |= DM9000_PLATF_16BITONLY;
		dm9000_eth_data.inblk = dm9000_inblk_16bit;
		dm9000_eth_data.outblk = dm9000_outblk_16bit;
		dm9000_eth_data.dumpblk = dm9000_dumpblk_16bit;

		ret =
		    platform_device_add_data(dm9000_eth_dev, &dm9000_eth_data,
					     sizeof(struct dm9000_plat_data));
		if (ret)
			goto unreg;
	}
	return 0;
unreg:
	platform_device_unregister(dm9000_eth_dev);
err:
	of_node_put(np);
	return ret;
}

arch_initcall(dm9000_eth_of_init);


----

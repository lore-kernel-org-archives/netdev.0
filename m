From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: smsc911x driver
Date: Fri, 14 Jul 2006 11:50:35 -0700
Message-ID: <20060714115035.502d8edf@dxpl.pdx.osdl.net>
References: <7ac1e90c0607140711p4529d4fbh98d3e9edf2c7a52f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, catalin.marinas@arm.com,
	ian.saturley@smsc.com, steve.glendinning@smsc.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:54239 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1161287AbWGNSus (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jul 2006 14:50:48 -0400
To: "Bahadir Balban" <bahadir.balban@gmail.com>
In-Reply-To: <7ac1e90c0607140711p4529d4fbh98d3e9edf2c7a52f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 14 Jul 2006 14:11:34 +0000
"Bahadir Balban" <bahadir.balban@gmail.com> wrote:

> Attached is a driver patch for SMSC911x family of ethernet chips,
> generated against 2.6.18-rc1 sources. There's a similar driver in the
> tree; this one has been tested by SMSC on all flavors of the chip and
> claimed to be efficient.
> 

Please submit drivers to netdev@vger.kernel.org

> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index 3918990..d158e05 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -865,6 +865,13 @@ config NET_NETX
>  	  <file:Documentation/networking/net-modules.txt>. The module
>  	  will be called netx-eth.
> 
> +config SMSC911X
> +	tristate "SMSC 911x family of embedded ethernet support"
> +	depends on NET_ETHERNET
> +	---help---
> +	  Say Y here if you want support for SMSC LAN911x family
> +	  of ethernet chips.
> +
>  config DM9000
>  	tristate "DM9000 support"
>  	depends on (ARM || MIPS) && NET_ETHERNET
> diff --git a/drivers/net/Makefile b/drivers/net/Makefile
> index c91e951..51f680b 100644
> --- a/drivers/net/Makefile
> +++ b/drivers/net/Makefile
> @@ -196,6 +196,7 @@ obj-$(CONFIG_S2IO) += s2io.o
>  obj-$(CONFIG_MYRI10GE) += myri10ge/
>  obj-$(CONFIG_SMC91X) += smc91x.o
>  obj-$(CONFIG_SMC911X) += smc911x.o
> +obj-$(CONFIG_SMSC911X) += smsc911x.o
>  obj-$(CONFIG_DM9000) += dm9000.o
>  obj-$(CONFIG_FEC_8XX) += fec_8xx/
> 
> diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
> new file mode 100644
> index 0000000..e2f9adb
> --- /dev/null
> +++ b/drivers/net/smsc911x.c
> @@ -0,0 +1,2105 @@
> +/***************************************************************************
> + *
> + * Copyright (C) 2004-2005  SMSC
> + * Copyright (C) 2005 ARM
> + *
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public License
> + * as published by the Free Software Foundation; either version 2
> + * of the License, or (at your option) any later version.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program; if not, write to the Free Software
> + * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
> + *
> + ***************************************************************************
> + * Rewritten, heavily based on smsc911x simple driver by SMSC.
> + * Partly uses io macros from smc91x.c by Nicolas Pitre
> + */
> +
> +#include <linux/config.h>
> +#include <linux/delay.h>
> +#include <linux/errno.h>
> +#include <linux/etherdevice.h>
> +#include <linux/init.h>
> +#include <linux/ioport.h>
> +#include <linux/kernel.h>
> +#include <linux/mii.h>
> +#include <linux/module.h>
> +#include <linux/netdevice.h>
> +#include <linux/platform_device.h>
> +#include <linux/sched.h>
> +#include <linux/slab.h>
> +#include <linux/timer.h>
> +#include <linux/version.h>
> +#include <asm/bug.h>
> +#include <asm/bitops.h>
> +#include <asm/dma.h>
> +#include <asm/irq.h>
> +#include <asm/io.h>
> +#include "smsc911x.h"
> +
> +#define SMSC_CHIPNAME	"smsc911x"
> +
> +/* Tasklet declarations */
> +static unsigned long rx_tasklet_parameter;
> +static void smsc911x_rx_tasklet(unsigned long data);
> +
> +DECLARE_TASKLET(rx_tasklet, smsc911x_rx_tasklet, 0);

* should be static.

* if you want to receive in softirq context use NAPI rather
  than a tasklet.


> +MODULE_LICENSE("GPL");


> +/* Entry point for starting/opening the interface */
> +static int smsc911x_open(struct net_device *dev)
> +{
> +	struct smsc911x_data *pdata;
> +	unsigned char *mac_byte;
> +	unsigned int mac_high16;
> +	unsigned int mac_low32;
> +	unsigned int timeout;
> +	unsigned int intcfg;
> +	int result;
> +
> +	/* Set interrupt deassertion to 220uS */
> +	intcfg  = 22 << 24;
> +	timeout = 1000;
> +	result  = -ENODEV;
> +	pdata   = 0;
> +
> +	BUG_ON(!dev);
This kind of BUG_ON is useless, you will get whacked when
you deref the pointer anyway.

> +	pdata = netdev_priv(dev);
> +	BUG_ON(!pdata);
> +
> +	/* Initialise smsc911x */
> +
> +	/*
> +	 * dwIntCfg|=INT_CFG_IRQ_POL_;  use this to set IRQ_POL bit
> +	 * dwIntCfg|=INT_CFG_IRQ_TYPE_;  use this to set IRQ_TYPE bit
> +	 */
> +	if (!smsc911x_lan_initialise(pdata, intcfg))
> +		goto done;
> +
> +	SMSC_TRACE("Testing irq handler using IRQ %d", dev->irq);
> +	pdata->request_irq_disable = 0;
> +	pdata->software_irq_signal = 0;
> +	SMC_regwrite((SMC_regread(pdata, INT_EN) | INT_EN_SW_INT_EN_),
> +		     pdata, INT_EN);
> +	do {
> +		udelay(10);
> +		timeout--;
> +	} while (timeout && (!pdata->software_irq_signal));
> +
> +	if (!pdata->software_irq_signal) {
> +		printk("<1>ISR failed signaling test.");
> +		result = -ENODEV;
> +		goto done;
> +	}
> +	SMSC_TRACE("IRQ handler passed test using IRQ %d", dev->irq);
> +
> +	printk("%s: SMSC9%3x identified at %#08x, IRQ: %d\n", dev->name,
> +	       (u32)((pdata->idrev >> 16) & 0xFFFF), pdata->base, dev->irq);
> +
> +	smsc911x_mac_initialise(pdata);
> +
> +	/* Read mac address from EEPROM */
> +	mac_high16 = smsc911x_mac_read(pdata, ADDRH);
> +	mac_low32 = smsc911x_mac_read(pdata, ADDRL);
> +
> +	if ((mac_high16 == 0x0000FFFF) && (mac_low32 == 0xFFFFFFFF)) {
> +		/* Use default MAC addresses if eeprom values are invalid */
> +		mac_high16 = 0x00000070;
> +		mac_low32 = 0x110F8000;
> +
> +		smsc911x_mac_write(pdata, ADDRH, mac_high16);
> +		smsc911x_mac_write(pdata, ADDRL, mac_low32);

Please use random_ether_addr instead of the default value.

> +		SMSC_TRACE("MAC Address is set by default to 0x%04X%08X",
> +			   mac_high16, mac_low32);
> +	} else {
> +		SMSC_TRACE("Mac Address is read from LAN911x as 0x%04X%08X",
> +			   mac_high16, mac_low32);
> +	}
> +	mac_byte = (unsigned char *)&mac_low32;
> +	dev->dev_addr[0] = mac_byte[0];
> +	dev->dev_addr[1] = mac_byte[1];
> +	dev->dev_addr[2] = mac_byte[2];
> +	dev->dev_addr[3] = mac_byte[3];

What about byte order?

> +
> +	mac_byte = (unsigned char *)&mac_high16;
> +	dev->dev_addr[4] = mac_byte[0];
> +	dev->dev_addr[5] = mac_byte[1];
> +
> +	printk("%s: SMSC9%3x MAC Address: %02x:%02x:%02x:%02x:%02x:%02x\n",
> +	       dev->name, (u32)((pdata->idrev >> 16) & 0xFFFF),
> +	       dev->dev_addr[5], dev->dev_addr[4], dev->dev_addr[3],
> +	       dev->dev_addr[2], dev->dev_addr[1], dev->dev_addr[0]);
> +
> +	netif_carrier_off(dev);
> +	if (!smsc911x_phy_initialise(pdata)) {
> +		SMSC_WARNING("Failed to initialize PHY");
> +		result = -ENODEV;
> +		goto done;
> +	}
> +
> +	smsc911x_tx_initialise(pdata);
> +	smsc911x_rx_initialise(pdata);
> +	netif_start_queue(dev);
> +
> +	result = 0;
> +
> +done:
> +	SMSC_TRACE("result: %d", result);
> +	return result;
> +}
> +
> +/* Entry point for stopping the interface */
> +static int smsc911x_stop(struct net_device *dev)
> +{
> +	unsigned long flags;
> +	unsigned long base;
> +	unsigned long idrev;
> +	struct smsc911x_data *pdata;
> +	struct net_device *pnetdev;
> +
> +	BUG_ON(!dev);
> +	pdata = netdev_priv(dev);
> +	BUG_ON(!pdata);
> +
> +	pdata->stop_link_poll = 1;
> +	del_timer_sync(&pdata->link_poll_timer);
> +
> +	spin_lock_irqsave(&dev->_xmit_lock, flags);
> +	SMC_regwrite((SMC_regread(pdata, INT_CFG) & (~INT_CFG_IRQ_EN_)),
> +		     pdata, INT_CFG);
> +	netif_stop_queue(pdata->dev);
> +	spin_unlock_irqrestore(&dev->_xmit_lock, flags);
> +
> +	/* At this point all Rx and Tx activity is stopped */
> +	pdata->stats.rx_dropped += SMC_regread(pdata, RX_DROP);
> +	smsc911x_tx_update_txcounters(pdata);
> +
> +	/* Preserve important fields */
> +	base = pdata->base;
> +	idrev = pdata->idrev;
> +	pnetdev = pdata->dev;
> +
> +	/* Clear all structure */
> +	memset((void *)pdata, 0, sizeof(struct smsc911x_data));
> +
> +	/* Reassign important fields */
> +	pdata->base = base;
> +	pdata->idrev = idrev;
> +	pdata->dev = pnetdev;
> +
> +	SMSC_TRACE("<--Simp911x_stop");
> +	return 0;
> +}
> +
> +/* Entry point for transmitting a packet */
> +static int
> +smsc911x_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
> +{
> +	struct smsc911x_data *pdata;
> +
> +	BUG_ON(!skb);
> +	BUG_ON(!dev);
> +	BUG_ON(!netdev_priv(dev));

More bullshit bugon. Why the silly wrapper func?

> +	pdata = netdev_priv(dev);
> +	smsc911x_tx_sendskb(pdata, skb);
> +	return 0;
> +}
...

> +	platform_set_drvdata(pdev, netdev);
> +	strcpy(netdev->name, "eth%d");

Already done by alloc_etherdev...

> +	retval = register_netdev(netdev);
> +
> +	if (retval) {
> +		SMSC_WARNING("Error %i registering device", retval);
> +		retval = -ENODEV;
> +		goto out_unmap_io;
> +	} else {
> +		SMSC_TRACE("Network interface: \"%s\"",netdev->name);
> +	}
> +
> +	if ((retval = smsc911x_init(netdev)) < 0)
> +		goto out_deregister_netdev;

Please init before registering. Because during registration it is
possible that some callback would want to bring up the device automatically,
or send a packet.

> +	if (request_irq(netdev->irq, smsc911x_irqhandler,
> +	    SA_INTERRUPT, SMSC_CHIPNAME, netdev_priv(netdev)) != 0) {
> +		SMSC_WARNING("Unable to claim requested irq: %d", netdev->irq);
> +		retval = -ENODEV;
> +		goto out_deregister_netdev;
> +	}

You must have the IRQ in place before registering.

> +	return 0;
> +
> +out_deregister_netdev:
> +	unregister_netdev(netdev);
> +out_unmap_io:
> +	platform_set_drvdata(pdev, NULL);
> +	iounmap((void *) base);
> +out_free_netdev:
> +	rx_tasklet_parameter = 0;
> +	free_netdev(netdev);
> +out_release_io:
> +	release_mem_region(res->start, res->end - res->start);
> +out:
> +	return retval;
> +}
> +
> diff --git a/drivers/net/smsc911x.h b/drivers/net/smsc911x.h
> new file mode 100644
> index 0000000..5ab2987
> --- /dev/null
> +++ b/drivers/net/smsc911x.h
> @@ -0,0 +1,526 @@
> +#ifndef __SMSC911X_H__
> +#define __SMSC911X_H__
> +
> +#define USE_PHY_WORK_AROUND
> +#define USE_LED1_WORK_AROUND	/* 10/100 LED link-state inversion */
> +
> +/* Debugging */
> +#define USE_DEBUG	0
> +#if USE_DEBUG >= 1
> +#	define SMSC_WARNING(fmt, args...)			\
> +		printk(KERN_EMERG "SMSC_WARNING: %s: " fmt "\n",\
> +			__FUNCTION__ , ## args)
> +#else
> +#	define SMSC_WARNING(msg, args...)
> +#endif /* USE_DEBUG >= 1 */

Consider using pr_debug and the ethtool message level model.

> +#if USE_DEBUG >= 2
> +#	define SMSC_TRACE(fmt,args...)				\
> +		printk(KERN_EMERG "SMSC_TRACE: %s: " fmt "\n",	\
> +			__FUNCTION__ , ## args)
> +#else
> +#	define SMSC_TRACE(msg,args...)
> +#endif /* USE_DEBUG >= 2 */


-- 
Stephen Hemminger <shemminger@osdl.org>
"And in the Packet there writ down that doome"

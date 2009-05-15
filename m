From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH v2 5/7] [PATCH 5/8] can: SJA1000 generic platform bus
	driver
Date: Fri, 15 May 2009 14:07:12 +0200
Message-ID: <20090515120711.GE26519@pengutronix.de>
References: <20090512092757.048938233@denx.de> <20090512092757.894204198@denx.de> <20090514064633.GT29278@pengutronix.de> <4A0D374A.8080006@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:49075 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752625AbZEOMHN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2009 08:07:13 -0400
Content-Disposition: inline
In-Reply-To: <4A0D374A.8080006@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 15, 2009 at 11:35:06AM +0200, Wolfgang Grandegger wrote:
> Hi Sascha,
> 
> Sascha Hauer wrote:
> > Hi Wolfgang,
> > 
> > some comments inline.
> > 
> > Sascha
> > 
> > On Tue, May 12, 2009 at 11:28:02AM +0200, Wolfgang Grandegger wrote:
> >> This driver adds support for the SJA1000 chips connected to the
> >> "platform bus", which can be found on various embedded systems.
> >>
> >> Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>
> >> Signed-off-by: Wolfgang Grandegger <wg@grandegger.com>
> >> Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
> >> Signed-off-by: Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
> >> ---
> >>  drivers/net/can/Kconfig                    |   10 +
> >>  drivers/net/can/sja1000/Makefile           |    1 
> >>  drivers/net/can/sja1000/sja1000_platform.c |  169 +++++++++++++++++++++++++++++
> >>  include/linux/can/platform/sja1000.h       |   32 +++++
> >>  4 files changed, 212 insertions(+)
> >>  create mode 100644 drivers/net/can/sja1000/sja1000_platform.c
> >>  create mode 100644 include/linux/can/platform/sja1000.h
> >>
> >> Index: net-next-2.6/drivers/net/can/Kconfig
> >> ===================================================================
> >> --- net-next-2.6.orig/drivers/net/can/Kconfig	2009-05-12 10:47:25.747720647 +0200
> >> +++ net-next-2.6/drivers/net/can/Kconfig	2009-05-12 10:47:26.411720627 +0200
> >> @@ -41,6 +41,16 @@
> >>  	---help---
> >>  	  Driver for the SJA1000 CAN controllers from Philips or NXP
> >>  
> >> +config CAN_SJA1000_PLATFORM
> >> +	depends on CAN_SJA1000
> >> +	tristate "Generic Platform Bus based SJA1000 driver"
> >> +	---help---
> >> +	  This driver adds support for the SJA1000 chips connected to
> >> +	  the "platform bus" (Linux abstraction for directly to the
> >> +	  processor attached devices).  Which can be found on various
> >> +	  boards from Phytec (http://www.phytec.de) like the PCM027,
> >> +	  PCM038.
> >> +
> >>  config CAN_DEBUG_DEVICES
> >>  	bool "CAN devices debugging messages"
> >>  	depends on CAN
> >> Index: net-next-2.6/drivers/net/can/sja1000/Makefile
> >> ===================================================================
> >> --- net-next-2.6.orig/drivers/net/can/sja1000/Makefile	2009-05-12 10:47:25.753720385 +0200
> >> +++ net-next-2.6/drivers/net/can/sja1000/Makefile	2009-05-12 10:47:26.412720490 +0200
> >> @@ -3,5 +3,6 @@
> >>  #
> >>  
> >>  obj-$(CONFIG_CAN_SJA1000) += sja1000.o
> >> +obj-$(CONFIG_CAN_SJA1000_PLATFORM) += sja1000_platform.o
> >>  
> >>  ccflags-$(CONFIG_CAN_DEBUG_DEVICES) := -DDEBUG
> >> Index: net-next-2.6/drivers/net/can/sja1000/sja1000_platform.c
> >> ===================================================================
> >> --- /dev/null	1970-01-01 00:00:00.000000000 +0000
> >> +++ net-next-2.6/drivers/net/can/sja1000/sja1000_platform.c	2009-05-12 10:47:26.416720502 +0200
> >> @@ -0,0 +1,169 @@
> >> +/*
> >> + * Copyright (C) 2005 Sascha Hauer, Pengutronix
> >> + * Copyright (C) 2007 Wolfgang Grandegger <wg@grandegger.com>
> >> + *
> >> + * This program is free software; you can redistribute it and/or modify
> >> + * it under the terms of the version 2 of the GNU General Public License
> >> + * as published by the Free Software Foundation
> >> + *
> >> + * This program is distributed in the hope that it will be useful,
> >> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> >> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
> >> + * GNU General Public License for more details.
> >> + *
> >> + * You should have received a copy of the GNU General Public License
> >> + * along with this program; if not, write to the Free Software
> >> + * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
> >> + */
> >> +
> >> +#include <linux/kernel.h>
> >> +#include <linux/module.h>
> >> +#include <linux/interrupt.h>
> >> +#include <linux/netdevice.h>
> >> +#include <linux/delay.h>
> >> +#include <linux/pci.h>
> >> +#include <linux/platform_device.h>
> >> +#include <linux/irq.h>
> >> +#include <linux/can.h>
> >> +#include <linux/can/dev.h>
> >> +#include <linux/can/platform/sja1000.h>
> >> +#include <linux/io.h>
> >> +
> >> +#include "sja1000.h"
> >> +
> >> +#define DRV_NAME "sja1000_platform"
> >> +
> >> +MODULE_AUTHOR("Sascha Hauer <s.hauer@pengutronix.de>");
> >> +MODULE_DESCRIPTION("Socket-CAN driver for SJA1000 on the platform bus");
> >> +MODULE_LICENSE("GPL v2");
> >> +
> >> +static u8 sp_read_reg(const struct net_device *dev, int reg)
> >> +{
> >> +	return ioread8((void __iomem *)(dev->base_addr + reg));
> >> +}
> >> +
> >> +static void sp_write_reg(const struct net_device *dev, int reg, u8 val)
> >> +{
> >> +	iowrite8(val, (void __iomem *)(dev->base_addr + reg));
> >> +}
> >> +
> >> +static int sp_probe(struct platform_device *pdev)
> >> +{
> >> +	int err, irq;
> >> +	void __iomem *addr;
> >> +	struct net_device *dev;
> >> +	struct sja1000_priv *priv;
> >> +	struct resource *res_mem, *res_irq;
> >> +	struct sja1000_platform_data *pdata;
> >> +
> >> +	pdata = pdev->dev.platform_data;
> >> +	if (!pdata) {
> >> +		dev_err(&pdev->dev, "No platform data provided!\n");
> >> +		err = -ENODEV;
> >> +		goto exit;
> >> +	}
> >> +
> >> +	res_mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
> >> +	res_irq = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
> >> +	if (!res_mem || !res_irq) {
> >> +		err = -ENODEV;
> >> +		goto exit;
> >> +	}
> >> +
> >> +	if (!request_mem_region(res_mem->start,
> >> +				res_mem->end - res_mem->start + 1,
> >> +				DRV_NAME)) {
> > 
> > resource_size(res_mem) please, also for the other occurrences in this
> > file
> 
> OK.
> 
> >> +		err = -EBUSY;
> >> +		goto exit;
> >> +	}
> >> +
> >> +	addr = ioremap_nocache(res_mem->start,
> >> +			       res_mem->end - res_mem->start + 1);
> >> +	if (!addr) {
> >> +		err = -ENOMEM;
> >> +		goto exit_release;
> >> +	}
> >> +
> >> +	irq = res_irq->start;
> >> +	if (res_irq->flags & IRQF_TRIGGER_MASK)
> >> +		set_irq_type(irq, res_irq->flags & IRQF_TRIGGER_MASK);
> > 
> > You shouldn't use set_irq_type on not yet requested irqs but instead
> > pass the flags to the real driver and pass them in request_irq.
> 
> Why? I would require an extra member in the struct sja1000_priv.

You change a resource you do not own. What if request_irq returns with
-EBUSY? You already screwed up any other potential user.

Sascha

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |

From: Samuel Ortiz <samuel@sortiz.org>
Subject: Re: [PATCH] irda: driver for Freescale FIRI controller
Date: Thu, 12 Jun 2008 00:25:25 +0200
Message-ID: <20080611222524.GA6710@sortiz.org>
References: <20080604154510.GA31162@polina.dev.rtsoft.ru>
Reply-To: Samuel Ortiz <samuel@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Zhang Wei <Wei.Zhang@freescale.com>,
	Timur Tabi <timur@freescale.com>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: Anton Vorontsov <avorontsov@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp23.orange.fr ([80.12.242.97]:63145 "EHLO smtp23.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751331AbYFKWX7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jun 2008 18:23:59 -0400
Content-Disposition: inline
In-Reply-To: <20080604154510.GA31162@polina.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Anton,

On Wed, Jun 04, 2008 at 07:45:10PM +0400, Anton Vorontsov wrote:
> From: Zhang Wei <wei.zhang@freescale.com>
> 
> The driver supports SIR, MIR, FIR modes and maximum 4000000bps rate.
> 
> Signed-off-by: Zhang Wei <wei.zhang@freescale.com>
> [AV: few small fixes, plus had made platform ops passing via node->data
>      to avoid #ifdef stuff in the fsl_soc (think DIU). ]
> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
Some comments below:


> diff --git a/drivers/net/irda/Kconfig b/drivers/net/irda/Kconfig
> index ce816ba..da24f57 100644
> --- a/drivers/net/irda/Kconfig
> +++ b/drivers/net/irda/Kconfig
> @@ -341,5 +341,10 @@ config MCS_FIR
>  	  To compile it as a module, choose M here: the module will be called
>  	  mcs7780.
>  
> +config FSL_FIR
> +	tristate "Freescale Irda driver"
I guess you could be a little more descriptive here. At least specify which
chipsets this driver support, and that it is a FIR one.


> --- /dev/null
> +++ b/drivers/net/irda/fsl_ir.c
> @@ -0,0 +1,792 @@
> +/*
> + * Copyright (C) 2007 Freescale Semiconductor, Inc. All rights reserved.
> + *
> + * Author: Zhang Wei, wei.zhang@freescale.com, Oct. 2007
> + *
> + * Description:
> + * The IrDA driver for Freescale PowerPC MPC8610 processor. The driver
> + * support SIR and FIR mode. The maximum speed is 4Mbps.
> + *
> + * Changelog:
> + * Oct 2007 Zhang Wei <wei.zhang@freescale.com>
> + * - Initial version.
> + *
> + * This file is part of the Linux kernel
> + *
> + * This is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation; either version 2 of the License, or
> + * (at your option) any later version.
> + *
> + */
> +
> +#include <linux/kernel.h>
> +#include <linux/interrupt.h>
> +#include <linux/delay.h>
> +#include <linux/of_platform.h>
> +#include <linux/fsl_ir.h>
> +
> +#include <net/irda/irda.h>
> +#include <net/irda/wrapper.h>
> +#include <net/irda/irda_device.h>
> +#include <net/irda/irlap_frame.h>
> +#include <net/irda/irlap.h>
> +
> +#include <sysdev/fsl_soc.h>
> +
> +#define is_sir_speed(speed) ((speed <= 115200) ? 1 : 0)
> +#define is_sir(ir) (is_sir_speed(ir->speed))
> +
> +static void init_iobuf(iobuff_t *io, void *buff, int size)
> +{
> +	io->head = buff;
> +	io->truesize = size;
> +	io->in_frame = FALSE;
> +	io->state = OUTSIDE_FRAME;
> +	io->data = io->head;
> +	io->skb = NULL;
> +}
> +
> +static void ir_switch_mode(struct fsl_ir *ir, u32 speed)
> +{
> +
> +	if (ir->speed && (ir->speed < 115200))	/* Switch from SIR to FIR */
Dont you want <= 115200 here ?

> +		/* Disable SIRI */
> +		clrbits32(&ir->reg_base->scr1, FSL_IR_SCR1_IREN |
> +						FSL_IR_SCR1_SIRIEN);
> +	else {					/* Switch from FIR to SIR */
> +		/* Disable FIRI */
> +		out_be32(&ir->reg_base->firitcr, 0);
> +		out_be32(&ir->reg_base->firircr, 0);
> +	}
> +
> +	/* Switch the IrDA mode on board */
> +	if (ir->plat_op && ir->plat_op->set_ir_mode)
> +		ir->plat_op->set_ir_mode(ir, speed);
> +}
> +
> +static int ir_crc_len(struct fsl_ir *ir)
> +{
> +	int crc_len;
> +
> +	switch (ir->speed) {
> +	case 576000:
> +	case 1152000:
> +		crc_len = 2;	/* CRC16, 16 bits */
> +		break;
> +	case 4000000:
> +		crc_len = 4;	/* CRC32, 32 bits */
> +		break;
> +	default:
> +		crc_len = 0;
> +		break;
> +	}
> +	return crc_len;
> +}
> +
> +static void fir_rx(struct fsl_ir *ir, int len)
> +{
> +	struct net_device *ndev = dev_get_drvdata(ir->dev);
> +	struct sk_buff *skb;
> +	int i;
> +
> +	if (len <= ir_crc_len(ir))
> +		return;
> +
> +	do_gettimeofday(&ir->stamp);
> +	/* Now, for new packet arriving */
> +	skb = alloc_skb(len + 1, GFP_ATOMIC);
Please use dev_alloc_skb here.

> +	if (!skb) {
> +		ir->stats.rx_dropped++;
> +		return;
> +	}
> +	skb_reserve(skb, 1);
A comment here describing why you need a 1 byte header would be nice.


> +
> +	for (i = 0; i < len; i++)
> +		skb->data[i] = in_8((u8 *)&ir->reg_base->rfifo);
> +
> +	len -= ir_crc_len(ir);
> +	skb_put(skb, len);
> +
> +	ir->stats.rx_packets++;
> +	ir->stats.rx_bytes += len;
> +
> +	skb->dev = ndev;
> +	skb_reset_mac_header(skb);
> +	skb->protocol = htons(ETH_P_IRDA);
> +	netif_rx(skb);
> +}
On a general note, this RX routine could be part of a bottom half.
You're calling this from the IRQ handler, and this may not be a good idea.


> +
> +static void fir_tx(struct fsl_ir *ir)
> +{
> +	int free_bytes;
> +	struct sk_buff *skb = ir->tx_buff.skb;
> +	size_t len;
> +
> +	if (!skb)
> +		return;
> +
> +	spin_lock(&ir->tx_lock);
> +	do {
> +		free_bytes = 128 -
> +			((in_be32(&ir->reg_base->firitsr) >> 8) & 0xff);
> +		for (len = min(free_bytes, ir->tx_buff.len); len > 0;
> +			len--, ir->tx_buff.len--)
> +			out_8((u8 *)&ir->reg_base->tfifo,
> +				skb->data[skb->len - ir->tx_buff.len]);
> +	} while (ir->tx_buff.len > 0);
> +	spin_unlock(&ir->tx_lock);
Here I would make use the _irqsave() versions as your skb could be NULLed
from there. I know it's really unlikely, but still...
You should also probably take this lock in the set_speed() routine. This
is another place where tx_buff could be accessed concurrently.

> +static int fsl_ir_set_speed(struct net_device *ndev, u32 speed)
> +{
> +	u32 sbir;
> +	u32 sbmr;
> +	struct fsl_ir *ir = netdev_priv(ndev);
> +	struct irlap_cb *self;
> +
> +	if (is_sir_speed(ir->speed) != is_sir_speed(speed))
> +		ir_switch_mode(ir, speed);
> +
> +	ir->speed = speed;
> +	if (is_sir_speed(speed)) {
> +		/* SIR */
> +		sbir = 89;
If you can document this one as well, it would be nice.


> +static irqreturn_t fsl_ir_sir_irq(struct net_device *ndev)
> +{
> +	struct fsl_ir *ir = netdev_priv(ndev);
> +	u32 ssr1, ssr2;
> +	ssr1 = in_be32(&ir->reg_base->ssr1);
> +	ssr2 = in_be32(&ir->reg_base->ssr2);
> +
> +	/* Tx is ready */
> +	if ((ssr1 & FSL_IR_SSR1_TRDY) && ir->tx_buff.len) {
> +		clrbits32(&ir->reg_base->scr1, FSL_IR_SCR1_TRDYEN);
> +		tasklet_schedule(&ir->tx_tasklet);
> +	}
> +
> +	/* Last Tx transfer is finished */
> +	if (ssr2 & FSL_IR_SSR2_TXDC && !ir->tx_buff.len) {
> +		if (ir->new_speed) {
> +			fsl_ir_set_speed(ndev, ir->new_speed);
> +			ir->new_speed = 0;
> +		}
> +		clrbits32(&ir->reg_base->scr4, FSL_IR_SCR4_TCEN);
> +
> +		ir->stats.tx_packets++;
> +		ir->stats.tx_bytes += ir->tx_buff.data
> +						- ir->tx_buff.head;
> +
> +		netif_wake_queue(ndev);
> +	}
> +
> +	/* Rx is ready */
> +	if (ssr1 & FSL_IR_SSR1_RRDY) {
> +		int i;
> +		int rxchars = in_be32(&ir->reg_base->sfcr) & 0x3f;
> +
> +		for (i = 0; i < rxchars; i++)
> +			async_unwrap_char(ndev, &ir->stats, &ir->rx_buff,
> +								sir_get(ir));
> +		ndev->last_rx = jiffies;
> +	}
Here and in the FIR case, this could be done asynchronously, from a BH.


> +static void fsl_ir_tx_do_tasklet(unsigned long data)
> +{
> +	struct fsl_ir *ir = (struct fsl_ir *)data;
> +
> +	if (is_sir(ir)) {
A detail, but this test will always be true.

> diff --git a/include/linux/fsl_ir.h b/include/linux/fsl_ir.h
> new file mode 100644
> index 0000000..2ee623a
> --- /dev/null
> +++ b/include/linux/fsl_ir.h
> +struct fsl_ir {
> +	struct fsl_ir_reg __iomem	*reg_base;
> +	struct resource			res;
> +	struct device			*dev;
> +	int				irq;
> +	struct fsl_ir_op		*plat_op;
> +
> +	struct irlap_cb			*irlap;
> +	struct qos_info			qos;
> +	struct net_device_stats		stats;
> +
> +	int				speed;
> +	int				new_speed;
> +	u32				clock_in;
> +	int				div;
> +
> +	u8				txb[FSL_SIR_TXBUFF_SIZE];
> +	u8				rxb[FSL_SIR_RXBUFF_SIZE];
> +	iobuff_t			tx_buff;
> +	iobuff_t			rx_buff;
> +
> +	spinlock_t			tx_lock;  /* Lock for Tx */
> +	spinlock_t			rx_lock;  /* Lock for Rx */
This is not used, you could remove it.


> +
> +	struct tasklet_struct		tx_tasklet;
> +	struct delayed_work		rx_work;
This one is not used either, but it would be nice to use it :-)

Thanks a lot for your work.

Cheers,
Samuel.



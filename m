From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v3] can: add Renesas R-Car CAN driver
Date: Fri, 08 Nov 2013 02:57:18 +0300
Message-ID: <527C28DE.7070402@cogentembedded.com>
References: <201311020240.13354.sergei.shtylyov@cogentembedded.com> <5276ADF6.9050309@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wg@grandegger.com,
	linux-can@vger.kernel.org, linux-sh@vger.kernel.org,
	vksavl@gmail.com
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <5276ADF6.9050309@pengutronix.de>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 11/03/2013 11:11 PM, Marc Kleine-Budde wrote:

>> Add support for the CAN controller found in Renesas R-Car SoCs.

>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

> See comment inline.

[...]

>> Index: linux-can-next/drivers/net/can/rcar_can.c
>> ===================================================================
>> --- /dev/null
>> +++ linux-can-next/drivers/net/can/rcar_can.c
>> @@ -0,0 +1,893 @@
>> +/*
>> + * Renesas R-Car CAN device driver
>> + *
>> + * Copyright (C) 2013 Cogent Embedded, Inc. <source@cogentembedded.com>
>> + * Copyright (C) 2013 Renesas Solutions Corp.
>> + *
>> + * This program is free software; you can redistribute  it and/or modify it
>> + * under  the terms of  the GNU General  Public License as published by the
>> + * Free Software Foundation;  either version 2 of the  License, or (at your
>> + * option) any later version.
>> + */
>> +
>> +#include <linux/module.h>
>> +#include <linux/kernel.h>
>> +#include <linux/types.h>
>> +#include <linux/interrupt.h>
>> +#include <linux/errno.h>
>> +#include <linux/netdevice.h>
>> +#include <linux/platform_device.h>
>> +#include <linux/can/led.h>
>> +#include <linux/can/dev.h>
>> +#include <linux/clk.h>
>> +#include <linux/can/platform/rcar_can.h>
>> +
>> +#define DRV_NAME	"rcar_can"
>> +
>> +/* Mailbox configuration:
>> + * mailbox 0 - not used
>> + * mailbox 1-31 - Rx
>> + * mailbox 32-63 - Tx
>> + * no FIFO mailboxes
>> + */
>> +#define N_MBX		64
>> +#define FIRST_TX_MB	32
>> +#define N_TX_MB		(N_MBX - FIRST_TX_MB)
>> +#define RX_MBX_MASK	0xFFFFFFFE

> Please use a common prefix for all defines.

    OK, done now. Could you however explain why the file-local #define's 
should be prefixed? It's not quite obvious to me...

[...]
>> +static netdev_tx_t rcar_can_start_xmit(struct sk_buff *skb,
>> +				       struct net_device *ndev)
>> +{
>> +	struct rcar_can_priv *priv = netdev_priv(ndev);
>> +	struct can_frame *cf = (struct can_frame *)skb->data;
>> +	u32 data, mier1, mbxno, i;
>> +	unsigned long flags;
>> +	u8 mctl = 0;
>> +
>> +	if (can_dropped_invalid_skb(ndev, skb))
>> +		return NETDEV_TX_OK;
>> +
>> +	spin_lock_irqsave(&priv->mier_lock, flags);
>> +	mier1 = readl(&priv->regs->mier1);
>> +	if (mier1) {
>> +		i = __builtin_clz(mier1);
>> +		mbxno = i ? N_MBX - i : FIRST_TX_MB;
>> +	} else {
>> +		mbxno = FIRST_TX_MB;
>> +	}

> Can you explain how the hardware arbitration works, and you do you
> guarantee the CAN frames are send by the hardware in the same order you
> put them into the hardware.

    Tx mailbox with the smallest mailbox number has the highest priority. The 
other possible Tx mailbox selection rule (not used by the driver now) is ID 
priority transmit mode (as defined in the ISO 11898-1 specs). The algorithm 
used guarantees the mailboxes are filled sequentially. I've used 'canfdtest' 
as suggested by Wolfgang Grandegger to verify, see the log below:

root@am335x-evm:~# ./canfdtest -v -g can0
interface = can0, family = 29, type = 3, proto = 1
...............................................................................C
Test messages sent and received: 483203
Exiting...
root@am335x-evm:~#

[...]
>> +static int rcar_can_rx_poll(struct napi_struct *napi, int quota)
>> +{
>> +	struct rcar_can_priv *priv = container_of(napi,
>> +						  struct rcar_can_priv, napi);
>> +	int num_pkts = 0;
>> +
>> +	/* Find mailbox */
>> +	while (num_pkts < quota) {
>> +		u8 mctl, mbx;
>> +
>> +		mbx = readb(&priv->regs->mssr);

> How does the RX work? Is it a hardware FIFO?

    In short, the MSSR register provides the smallest Rx mailbox number that 
is looked up in the Rx search mode. We read MSSR until no search results can 
be obtained, so it is some sort of FIFO.
    And there is separate FIFO operation mode: some mailboxes can be 
configured as FIFO and serviced by special registers but this operation mode 
is not supported by the driver.

[...]
>> +static int rcar_can_probe(struct platform_device *pdev)
>> +{
>> +	struct rcar_can_platform_data *pdata;
>> +	struct rcar_can_priv *priv;
>> +	struct net_device *ndev;
>> +	struct resource *mem;
>> +	void __iomem *addr;
>> +	int err = -ENODEV;
>> +	int irq;
>> +
>> +	pdata = dev_get_platdata(&pdev->dev);
>> +	if (!pdata) {
>> +		dev_err(&pdev->dev, "No platform data provided!\n");
>> +		goto fail;
>> +	}
>> +
>> +	irq = platform_get_irq(pdev, 0);
>> +	if (!irq) {
>> +		dev_err(&pdev->dev, "No IRQ resource\n");
>> +		goto fail;
>> +	}
>> +
>> +	mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
>> +	addr = devm_ioremap_resource(&pdev->dev, mem);
>> +	if (IS_ERR(addr)) {
>> +		err = PTR_ERR(addr);
>> +		goto fail;
>> +	}
>> +
>> +	ndev = alloc_candev(sizeof(struct rcar_can_priv), N_MBX - FIRST_TX_MB);
>> +	if (!ndev) {
>> +		dev_err(&pdev->dev, "alloc_candev failed\n");
>> +		err = -ENOMEM;
>> +		goto fail;
>> +	}
>> +
>> +	priv = netdev_priv(ndev);
>> +
>> +	priv->clk = devm_clk_get(&pdev->dev, NULL);
>> +	if (IS_ERR(priv->clk)) {
>> +		err = PTR_ERR(priv->clk);
>> +		dev_err(&pdev->dev, "cannot get clock: %d\n", err);
>> +		goto fail_clk;
>> +	}
>> +
>> +	ndev->netdev_ops = &rcar_can_netdev_ops;
>> +	ndev->irq = irq;
>> +	ndev->flags |= IFF_ECHO;
>> +	priv->ndev = ndev;
>> +	priv->regs = addr;
>> +	priv->clock_select = pdata->clock_select;
>> +	priv->can.clock.freq = clk_get_rate(priv->clk);
>> +	priv->can.bittiming_const = &rcar_can_bittiming_const;
>> +	priv->can.do_set_bittiming = rcar_can_set_bittiming;

> Please call this function directly during the open() function.

    OK, done, and the method installation was removed. However, I'm not sure 
why you requested this as many drivers are still using the method.

[...]

> regards,
> Marc

WBR, Sergei



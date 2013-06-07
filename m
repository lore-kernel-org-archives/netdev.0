From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2] ethernet/arc/arc_emac - Add new driver
Date: Fri, 07 Jun 2013 11:13:03 -0700
Message-ID: <1370628783.2209.123.camel@joe-AO722>
References: <1370617656-18349-1-git-send-email-abrodkin@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Vineet Gupta <Vineet.Gupta1@synopsys.com>,
	Mischa Jonker <Mischa.Jonker@synopsys.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <rob.herring@calxeda.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, devicetree-discuss@lists.ozlabs.org
To: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1370617656-18349-1-git-send-email-abrodkin@synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-06-07 at 19:07 +0400, Alexey Brodkin wrote:
> Driver for non-standard on-chip ethernet device ARC EMAC 10/100,
> instantiated in some legacy ARC (Synopsys) FPGA Boards such as
> ARCAngel4/ML50x.

trivial comments only:

> diff --git a/drivers/net/ethernet/arc/arc_emac_main.c b/drivers/net/ethernet/arc/arc_emac_main.c
[]
> @@ -0,0 +1,956 @@
> +/*
> + * Copyright (C) 2004, 2007-2010, 2011-2013 Synopsys, Inc. (www.synopsys.com)
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2 as
> + * published by the Free Software Foundation.
> + *
> + * Driver for the ARC EMAC 10100 (Rev 5)
> + *
> + * Alexey Brodkin: June 2013
> + *  -Upsteaming
[]
> + * Vineet Gupta: June 2011
> + *  -Issues when working with 64b cache line size
[]
> + * Vineet Gupta: May 2010
> + *  -Reduced foot-print of the main ISR (handling for error cases moved out
[]
> + * Vineet Gupta: Nov 2009
> + *  -Unified NAPI and Non-NAPI Code.
[]
> + * Vineet Gupta: Nov 2009
[]
> + * Amit Bhor, Sameer Dhavale: 2004

Does the internal changelog add anything useful?

> +static int arc_emac_poll(struct napi_struct *napi, int budget)
> +{
> +	struct net_device *net_dev = napi->dev;
> +	struct arc_emac_priv *priv = netdev_priv(net_dev);
> +	struct sk_buff *skb, *skbnew;
> +	unsigned int i, loop, len, info, work_done = 0;
> +
> +	/* Loop thru the BD chain, but not always from 0.
> +	 * Start from right after where we last saw a packet.
> +	 */
> +	i = priv->last_rx_bd;
> +
> +	for (loop = 0; loop < RX_BD_NUM; loop++) {
> +		i = (i + 1) & (RX_BD_NUM - 1);
> +
> +		info = priv->rxbd[i].info;
> +
> +		/* BD contains a packet for CPU to grab */
> +		if (likely((info & OWN_MASK) == FOR_CPU)) {

You could reduce indentation a level for all
the lines that follow by using
		if (unlikely(!(...)
			continue;


> +				/* Get a new SKB from stack */
> +				skbnew = netdev_alloc_skb(net_dev,
> +							  net_dev->mtu +
> +							  EMAC_BUFFER_PAD);
> +
> +				if (!skbnew) {
> +					netdev_err(net_dev, "Out of memory, "
> +						   "dropping packet\n");

OOM messages aren't particularly useful,
and coalesce format please...

[]
> +				netdev_warn(net_dev,
> +					    "Rx chained, packet is larger than "
> +					    "device MTU (%d bytes)\n",
> +					    net_dev->mtu);

Same here.

> +static irqreturn_t arc_emac_intr(int irq, void *dev_instance)
> +{
> +	struct net_device *net_dev = (struct net_device *)dev_instance;

Don't need to cast void *
netdev is a more common variable name

> +		if (status & TXINT_MASK) {
> +			unsigned int i, info;
> +			struct sk_buff *skb;
[]
> +			if (status & TXCH_MASK) {
> +				priv->stats.tx_errors++;
> +				priv->stats.tx_aborted_errors++;
> +				netdev_err(priv->net_dev,
> +					   "Tx chaining err! txbd_dirty = %u\n",
> +					   priv->txbd_dirty);

You already have a local net_dev.
why not use that?

> +			} else {
> +				netdev_err(priv->net_dev,
> +					   "unknown err. Status reg is 0x%x\n",
> +					   status);

here too.

> +int arc_emac_open(struct net_device *net_dev)
> +{
> +	struct arc_emac_priv *priv = netdev_priv(net_dev);
> +	struct arc_emac_bd_t *bd;
> +	struct sk_buff *skb;
> +	int i;
> +
> +	if (!priv->phy_node) {
> +		netdev_err(net_dev, "arc_emac_open: phy device is absent\n");

If you really need the function name,
it's better to use "%s: ", __func__

> +int arc_emac_tx(struct sk_buff *skb, struct net_device *net_dev)
> +{
[]
> +tx_next_chunk:
> +
> +	info = priv->txbd[priv->txbd_curr].info;
> +	if (likely((info & OWN_MASK) == FOR_CPU)) {

	if (unlikely(!(etc...)
		return NETDEV_TX_BUSY;

and save an indent level

> +/**

> +int arc_emac_set_address(struct net_device *net_dev, void *p)
[]
> +	EMAC_REG_SET(priv->reg_base_addr, R_ADDRH,
> +		     *(unsigned int *)&net_dev->dev_addr[4] & 0x0000ffff);

That doesn't seem endian friendly.


> +static int arc_emac_probe(struct platform_device *pdev)
> +{
[]
> +	/* Get phy from device tree */
> +	priv->phy_node = of_parse_phandle(pdev->dev.of_node, "phy", 0);
> +	if (!priv->phy_node) {
> +		dev_err(&pdev->dev, "failed to retrieve phy description "
> +			"from device tree\n");

Coalesce formats please

> +	err = of_address_to_resource(pdev->dev.of_node, 0, &res_regs);
> +	if (err) {
> +		dev_err(&pdev->dev, "failed to retrieve registers base "
> +			"from device tree\n");
[]
> +	/* Get IRQ from device tree */
> +	err = of_irq_to_resource(pdev->dev.of_node, 0, &res_irq);
> +	if (!err) {
> +		dev_err(&pdev->dev, "failed to retrieve <irq> value "
> +			"from device tree\n");
[]

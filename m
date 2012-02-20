From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2 2/2] netdev: driver: ethernet: Add TI CPSW driver
Date: Mon, 20 Feb 2012 15:03:49 -0800
Message-ID: <1329779029.8318.21.camel@joe2Laptop>
References: <1329763023-29580-1-git-send-email-mugunthanvnm@ti.com>
	 <1329763023-29580-3-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:43264 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752193Ab2BTXDu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Feb 2012 18:03:50 -0500
In-Reply-To: <1329763023-29580-3-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-02-21 at 00:07 +0530, Mugunthan V N wrote:
> This patch adds support for TI's CPSW driver.
> 
> The three port switch gigabit ethernet subsystem provides ethernet packet
> communication and can be configured as an ethernet switch. Supports
> 10/100/1000 Mbps.

some more notes.

> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
[]
> +#define msg(level, type, format, ...)				\
> +do {								\
> +	if (netif_msg_##type(priv) && net_ratelimit())		\
> +		dev_##level(priv->dev, format, ## __VA_ARGS__);	\
> +} while (0)

This hides an always used priv variable.

I suggest you expand this to multiple #defines like:

#define cpsw_info(priv, type, format, ...)			\
do {								\
	if (netif_msg_##type(priv) && net_ratelimit())		\
		dev_info(priv->dev, format, ##__VA_ARGS__);	\
} while (0)

and change the uses from
	msg(info,...)
to
	cpsw_info(priv, type, format, ...)

[]

> +struct cpsw_priv {
> +	spinlock_t			lock;
> +	struct platform_device		*pdev;
> +	struct net_device		*ndev;
> +	struct resource			*cpsw_res;
> +	struct resource			*cpsw_ss_res;
> +	struct napi_struct		napi;
> +#define napi_to_priv(napi)	container_of(napi, struct cpsw_priv, napi)

I still think embedded #defines in structs are hard to read.

[]
> +static int cpsw_poll(struct napi_struct *napi, int budget)
> +{
> +	struct cpsw_priv	*priv = napi_to_priv(napi);
> +	int			num_tx, num_rx;
> +
> +	num_tx = cpdma_chan_process(priv->txch, 128);
> +	num_rx = cpdma_chan_process(priv->rxch, budget);
> +
> +	if (num_rx || num_tx)
> +		msg(dbg, intr, "poll %d rx, %d tx pkts\n", num_rx, num_tx);

		cpsw_dbg(priv, intr, etc...)
[]
> +		*link = true;
> +	} else {
> +		mac_control = 0;
> +		/* diable forwarding */

disable tyop

> +	if (IS_ERR(slave->phy)) {
> +		msg(err, ifup, "phy %s not found on slave %d\n",
> +		    slave->data->phy_id, slave->slave_num);
> +		slave->phy = NULL;
> +	} else {
> +		printk(KERN_ERR "\nCPSW phy found : id is : 0x%x\n",
> +			slave->phy->phy_id);

Using leading newlines doesn't help much.
I suggest dev_err.
[]

> +	ndev = alloc_etherdev(sizeof(struct cpsw_priv));
> +	if (!ndev) {
> +		pr_err("cpsw: error allocating net_device\n");

Add
#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
before all #includes and remove the embedded prefix
from all pr_<level> uses.

> +	if (is_valid_ether_addr(data->slave_data[0].mac_addr)) {
> +		memcpy(priv->mac_addr, data->slave_data[0].mac_addr, ETH_ALEN);
> +		printk(KERN_INFO"Detected MACID=%x:%x:%x:%x:%x:%x\n",
> +			priv->mac_addr[0], priv->mac_addr[1],
> +			priv->mac_addr[2], priv->mac_addr[3],
> +			priv->mac_addr[4], priv->mac_addr[5]);

Use printf extension %pM to print the MAC address

		pr_info("Detected MAC=%pM\n", priv->mac_addr);

> +	priv->slaves = kzalloc(sizeof(struct cpsw_slave) * data->slaves,
> +			       GFP_KERNEL);
> +	if (!priv->slaves) {
> +		dev_err(priv->dev, "failed to allocate slave ports\n");

No real need for this dev_err
[]
> +	memset(&dma_params, 0, sizeof(dma_params));
> +	dma_params.dev			= &pdev->dev;
> +	dma_params.dmaregs		= (void __iomem *)(((u32)priv->regs) +
> +						data->cpdma_reg_ofs);
> +	dma_params.rxthresh		= (void __iomem *)(((u32)priv->regs) +
> +					data->cpdma_reg_ofs + CPDMA_RXTHRESH);
> +	dma_params.rxfree		= (void __iomem *)(((u32)priv->regs) +
> +					data->cpdma_reg_ofs + CPDMA_RXFREE);
> +
> +	dma_params.txhdp	= (void __iomem *)(((u32)priv->regs) +
> +				data->cpdma_sram_ofs + CPDMA_TXHDP);
> +	dma_params.rxhdp	= (void __iomem *)(((u32)priv->regs) +
> +				data->cpdma_sram_ofs + CPDMA_RXHDP);
> +	dma_params.txcp		= (void __iomem *)(((u32)priv->regs) +
> +				data->cpdma_sram_ofs + CPDMA_TXCP);
> +	dma_params.rxcp		= (void __iomem *)(((u32)priv->regs) +
> +				data->cpdma_sram_ofs + CPDMA_RXCP);

These might be more readable if you didn't try to align it
or maybe add macros or inline functions like:

#define cpsw_sram_addr(priv, data, offset)			\
	(void __iomem *)(((u32)(priv)->regs) + (data)->cpdma_sram_ofs + offset)

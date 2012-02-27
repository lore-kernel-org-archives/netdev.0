From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v3] lpc32xx: Added ethernet driver
Date: Mon, 27 Feb 2012 19:49:02 +0000
Message-ID: <201202271949.03144.arnd@arndb.de>
References: <1330364539-23152-1-git-send-email-stigge@antcom.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	alexander.h.duyck@intel.com, eilong@broadcom.com,
	ian.campbell@citrix.com, netdev@vger.kernel.org,
	w.sang@pengutronix.de, linux-kernel@vger.kernel.org,
	kevin.wells@nxp.com, linux-arm-kernel@lists.infradead.org,
	baruch@tkos.co.il, joe@perches.com
To: Roland Stigge <stigge@antcom.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1330364539-23152-1-git-send-email-stigge@antcom.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 27 February 2012, Roland Stigge wrote:
> This patch adds an ethernet driver for the LPC32xx ARM SoC.
> 
> Signed-off-by: Roland Stigge <stigge@antcom.de>
> 
> ---
>  drivers/net/ethernet/Kconfig       |    1 
>  drivers/net/ethernet/Makefile      |    1 
>  drivers/net/ethernet/nxp/Kconfig   |    8 
>  drivers/net/ethernet/nxp/Makefile  |    1 
>  drivers/net/ethernet/nxp/lpc_eth.c | 1311 +++++++++++++++++++++++++++++++++++++
>  drivers/net/ethernet/nxp/lpc_eth.h |  336 +++++++++

Just merge the header into the implementation file, it's not used an
an interface between two .c files.

> --- linux-2.6.orig/drivers/net/ethernet/Makefile
> +++ linux-2.6/drivers/net/ethernet/Makefile
> @@ -47,6 +47,7 @@ obj-$(CONFIG_NET_VENDOR_NATSEMI) += nats
>  obj-$(CONFIG_NET_NETX) += netx-eth.o
>  obj-$(CONFIG_NET_VENDOR_NUVOTON) += nuvoton/
>  obj-$(CONFIG_NET_VENDOR_NVIDIA) += nvidia/
> +obj-$(CONFIG_LPC_ENET) += nxp/
>  obj-$(CONFIG_OCTEON_MGMT_ETHERNET) += octeon/
>  obj-$(CONFIG_NET_VENDOR_OKI) += oki-semi/
>  obj-$(CONFIG_ETHOC) += ethoc.o

Are you sure that npx is actually the origin of this controller?
If they only licensed the IP themselves, it would be better to list
it under the name of the actual creator so that the next person
who has the same core can find it.

> +static irqreturn_t __lpc_eth_interrupt(int irq, void *dev_id)
> +{
> +	struct net_device *ndev = dev_id;
> +	struct netdata_local *pldat = netdev_priv(ndev);
> +	u32 tmp;
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&pldat->lock, flags);
> +
> +	while ((tmp = readl(LPC_ENET_INTSTATUS(pldat->net_base)))) {
> +		/* Clear interrupts */
> +		writel(tmp, LPC_ENET_INTCLEAR(pldat->net_base));
> +
> +		/* Transmit complete? */
> +		if (tmp & (LPC_MACINT_TXUNDERRUNINTEN |
> +				LPC_MACINT_TXERRORINTEN |
> +				LPC_MACINT_TXFINISHEDINTEN |
> +				LPC_MACINT_TXDONEINTEN))
> +			__lpc_handle_xmit(ndev);
> +
> +		/* Receive buffer available */
> +		if (tmp & (LPC_MACINT_RXOVERRUNINTEN |
> +				LPC_MACINT_RXERRORONINT |
> +				LPC_MACINT_RXFINISHEDINTEN |
> +				LPC_MACINT_RXDONEINTEN))
> +			__lpc_handle_recv(ndev);
> +	}
> +
> +	spin_unlock_irqrestore(&pldat->lock, flags);
> +
> +	return IRQ_HANDLED;
> +}

Why do you handle receive and transmit directly in the irq handler,
rather than using napi?

> +	/* Save resources */
> +	pldat->net_region_start = res->start;
> +	pldat->net_region_size = res->end - res->start + 1;

This does not seem to be needed really. It's only printed in
debug output and copied into ndev->base_addr, which is also
unused.

> +	/* Save board specific configuration */
> +	pldat->ncfg = (struct lpc_net_cfg *)pdev->dev.platform_data;
> +	if (pldat->ncfg == NULL) {
> +		dev_err(&pdev->dev, "error requesting interrupt.\n");
> +		pldat->ncfg = &__lpc_local_net_config;
> +	}

I would recommend dropping all the platform_data logic from this driver.
The board support that you added doesn't actually set it and once you
move to device tree probing, it will be obsolete anyway.

> +	if (use_iram_for_net()) {
> +		dma_handle = (dma_addr_t)LPC32XX_IRAM_BASE;
> +		if (pldat->dma_buff_size <= lpc32xx_return_iram_size())
> +			pldat->dma_buff_base_v =
> +				(u32)io_p2v(LPC32XX_IRAM_BASE);
> +		else
> +			netdev_err(ndev,
> +				"IRAM not big enough for net buffers, using SDRAM instead.\n");
> +	}

Can you put this into another resource? It doesn't seem appropriate
to use constants from a platform specific header file here.

> +	if (pldat->dma_buff_base_v == 0) {
> +		pldat->dma_buff_size += 4096; /* Allows room for alignment */
> +
> +		/* Align on the next highest page entry size */
> +		pldat->dma_buff_size &= 0Xfffff000;
> +		pldat->dma_buff_size += 0X00001000;

PAGE_ALIGN()

> +		/* Allocate a chunk of memory for the DMA ethernet buffers
> +		   and descriptors */
> +		pldat->dma_buff_base_v =
> +			(u32)dma_alloc_coherent(&pldat->pdev->dev,
> +						pldat->dma_buff_size,
> +						&dma_handle, GFP_KERNEL);
> +
> +		if (pldat->dma_buff_base_v == (u32)NULL) {
> +			dev_err(&pdev->dev, "error getting DMA region.\n");
> +			ret = -ENOMEM;
> +			goto err_out_free_irq;
> +		}
> +	}
> +	pldat->dma_buff_base_p = (u32)dma_handle;

Please use correct types here and remove all the typecasts. Virtual
addresses use pointers and dma addresses are dma_addr_t.

> +static int lpc_net_drv_suspend(struct platform_device *pdev,
> +	pm_message_t state)
> +{
> +}
> +
> +static int lpc_net_drv_resume(struct platform_device *pdev)
> +{
> +}

Define these conditionally?

> +static int __init lpc_net_init(void)
> +{
> +	return platform_driver_register(&lpc_net_driver);
> +}
> +
> +static void __exit lpc_net_cleanup(void)
> +{
> +	platform_driver_unregister(&lpc_net_driver);
> +}
> +
> +module_init(lpc_net_init);
> +module_exit(lpc_net_cleanup);

You can use module_platform_driver() now.

	Arnd

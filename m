From: Guennadi Liakhovetski <g.liakhovetski@gmx.de>
Subject: Re: [PATCH] net: smc911x: convert pxa dma to dmaengine
Date: Sat, 20 Feb 2016 16:46:20 +0100 (CET)
Message-ID: <Pine.LNX.4.64.1602201645470.32647@axis700.grange>
References: <20151202.235217.2201517065767030121.davem@davemloft.net>
 <87fuzjl69l.fsf@belgarion.home> <87k2mi4ysn.fsf@belgarion.home>
 <20160205.173021.1388372628450225378.davem@davemloft.net> <87fux6439s.fsf@belgarion.home>
 <87y4afy0fp.wl%mitake.hitoshi@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Robert Jarzmik <robert.jarzmik@free.fr>,
	mitake@dcl.info.waseda.ac.jp, fabio.estevam@freescale.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Hitoshi Mitake <mitake.hitoshi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.21]:60587 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750716AbcBTPqr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Feb 2016 10:46:47 -0500
In-Reply-To: <87y4afy0fp.wl%mitake.hitoshi@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Sat, 20 Feb 2016, Hitoshi Mitake wrote:

> 
> Hi Robert,
> 
> At Sat, 06 Feb 2016 10:05:51 +0100,
> Robert Jarzmik wrote:
> > 
> > David Miller <davem@davemloft.net> writes:
> > 
> > > From: Robert Jarzmik <robert.jarzmik@free.fr>
> > > Date: Fri, 05 Feb 2016 22:44:56 +0100
> > >
> > >> Apart from Alberto who answered he cannot test it by lack of hardware, the
> > >> others didn't answer.
> > >> 
> > >> So how can I move forward ? Would you want me to amend the KConfig to add a "&&
> > >> !ARCH_PXA" on the "depend" line ?
> > >
> > > Please just keep pinging people to properly test this.
> > Okay, let's have another try.
> > 
> > Hi Guennadi, Hitoshi, Fabio,
> > 
> > Could any of you try this patch to ensure your board is not broken please ?
> > I've re-added the patch at the end of this mail for easier handling. Normally no
> > code path in non-PXA board is changed, so the test should be straightforward.
> > 
> > It's also available in : https://lkml.org/lkml/2015/11/30/768
> > 
> > You're the maintainers of the following boards using smc911x AFAIK:
> >  - sh2007: Guennadi and Hitoshi
> 
> (I noticed my previous mail was bounced, so sending it again)
> 
> Really sorry, currently I don't have the board :(
> Do you have a working board that can be used for testing, Guennadi?

Don't think I have anything, that I could use for testing with a 
reasonable effort.

Thanks
Guennadi

> 
> Thanks,
> Hitoshi
> 
> >  - armadillo5x0: Alberto
> >  - imx v6 and imx v7: Fabio
> > 
> > Cheers.
> > 
> > -- 
> > Robert
> > 
> > 
> > ---8<---
> > From: Robert Jarzmik <robert.jarzmik@free.fr>
> > Subject: [PATCH] net: smc911x: convert pxa dma to dmaengine
> > To: "David S. Miller" <davem@davemloft.net>
> > Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, Robert Jarzmik <robert.jarzmik@free.fr>
> > Date: Mon, 30 Nov 2015 22:40:28 +0100 (9 weeks, 4 days, 11 hours ago)
> > Message-Id: <1448919628-13273-1-git-send-email-robert.jarzmik@free.fr>
> > X-Mailer: git-send-email 2.1.4
> > 
> > Convert the dma transfers to be dmaengine based, now pxa has a dmaengine
> > slave driver. This makes this driver a bit more PXA agnostic.
> > 
> > The driver was only compile tested. The risk is quite small as no
> > current PXA platform I'm aware of is using smc911x driver.
> > 
> > Signed-off-by: Robert Jarzmik <robert.jarzmik@free.fr>
> > ---
> >  drivers/net/ethernet/smsc/smc911x.c | 85 ++++++++++++++++++++++++-------------
> >  drivers/net/ethernet/smsc/smc911x.h | 63 ++++++++++++---------------
> >  2 files changed, 82 insertions(+), 66 deletions(-)
> > 
> > diff --git a/drivers/net/ethernet/smsc/smc911x.c b/drivers/net/ethernet/smsc/smc911x.c
> > index bd64eb982e52..3f5711061432 100644
> > --- a/drivers/net/ethernet/smsc/smc911x.c
> > +++ b/drivers/net/ethernet/smsc/smc911x.c
> > @@ -73,6 +73,9 @@ static const char version[] =
> >  #include <linux/etherdevice.h>
> >  #include <linux/skbuff.h>
> >  
> > +#include <linux/dmaengine.h>
> > +#include <linux/dma/pxa-dma.h>
> > +
> >  #include <asm/io.h>
> >  
> >  #include "smc911x.h"
> > @@ -1174,18 +1177,16 @@ static irqreturn_t smc911x_interrupt(int irq, void *dev_id)
> >  
> >  #ifdef SMC_USE_DMA
> >  static void
> > -smc911x_tx_dma_irq(int dma, void *data)
> > +smc911x_tx_dma_irq(void *data)
> >  {
> > -	struct net_device *dev = (struct net_device *)data;
> > -	struct smc911x_local *lp = netdev_priv(dev);
> > +	struct smc911x_local *lp = data;
> > +	struct net_device *dev = lp->netdev;
> >  	struct sk_buff *skb = lp->current_tx_skb;
> >  	unsigned long flags;
> >  
> >  	DBG(SMC_DEBUG_FUNC, dev, "--> %s\n", __func__);
> >  
> >  	DBG(SMC_DEBUG_TX | SMC_DEBUG_DMA, dev, "TX DMA irq handler\n");
> > -	/* Clear the DMA interrupt sources */
> > -	SMC_DMA_ACK_IRQ(dev, dma);
> >  	BUG_ON(skb == NULL);
> >  	dma_unmap_single(NULL, tx_dmabuf, tx_dmalen, DMA_TO_DEVICE);
> >  	dev->trans_start = jiffies;
> > @@ -1208,18 +1209,16 @@ smc911x_tx_dma_irq(int dma, void *data)
> >  	    "TX DMA irq completed\n");
> >  }
> >  static void
> > -smc911x_rx_dma_irq(int dma, void *data)
> > +smc911x_rx_dma_irq(void *data)
> >  {
> > -	struct net_device *dev = (struct net_device *)data;
> > -	struct smc911x_local *lp = netdev_priv(dev);
> > +	struct smc911x_local *lp = data;
> > +	struct net_device *dev = lp->netdev;
> >  	struct sk_buff *skb = lp->current_rx_skb;
> >  	unsigned long flags;
> >  	unsigned int pkts;
> >  
> >  	DBG(SMC_DEBUG_FUNC, dev, "--> %s\n", __func__);
> >  	DBG(SMC_DEBUG_RX | SMC_DEBUG_DMA, dev, "RX DMA irq handler\n");
> > -	/* Clear the DMA interrupt sources */
> > -	SMC_DMA_ACK_IRQ(dev, dma);
> >  	dma_unmap_single(NULL, rx_dmabuf, rx_dmalen, DMA_FROM_DEVICE);
> >  	BUG_ON(skb == NULL);
> >  	lp->current_rx_skb = NULL;
> > @@ -1792,6 +1791,9 @@ static int smc911x_probe(struct net_device *dev)
> >  	unsigned int val, chip_id, revision;
> >  	const char *version_string;
> >  	unsigned long irq_flags;
> > +	struct dma_slave_config	config;
> > +	dma_cap_mask_t mask;
> > +	struct pxad_param param;
> >  
> >  	DBG(SMC_DEBUG_FUNC, dev, "--> %s\n", __func__);
> >  
> > @@ -1963,11 +1965,40 @@ static int smc911x_probe(struct net_device *dev)
> >  		goto err_out;
> >  
> >  #ifdef SMC_USE_DMA
> > -	lp->rxdma = SMC_DMA_REQUEST(dev, smc911x_rx_dma_irq);
> > -	lp->txdma = SMC_DMA_REQUEST(dev, smc911x_tx_dma_irq);
> > +
> > +	dma_cap_zero(mask);
> > +	dma_cap_set(DMA_SLAVE, mask);
> > +	param.prio = PXAD_PRIO_LOWEST;
> > +	param.drcmr = -1UL;
> > +
> > +	lp->rxdma =
> > +		dma_request_slave_channel_compat(mask, pxad_filter_fn,
> > +						 &param, &dev->dev, "rx");
> > +	lp->txdma =
> > +		dma_request_slave_channel_compat(mask, pxad_filter_fn,
> > +						 &param, &dev->dev, "tx");
> >  	lp->rxdma_active = 0;
> >  	lp->txdma_active = 0;
> > -	dev->dma = lp->rxdma;
> > +
> > +	memset(&config, 0, sizeof(config));
> > +	config.src_addr_width = DMA_SLAVE_BUSWIDTH_4_BYTES;
> > +	config.dst_addr_width = DMA_SLAVE_BUSWIDTH_4_BYTES;
> > +	config.src_addr = lp->physaddr + RX_DATA_FIFO;
> > +	config.dst_addr = lp->physaddr + TX_DATA_FIFO;
> > +	config.src_maxburst = 32;
> > +	config.dst_maxburst = 32;
> > +	retval = dmaengine_slave_config(lp->rxdma, &config);
> > +	if (retval) {
> > +		dev_err(lp->dev, "dma rx channel configuration failed: %d\n",
> > +			retval);
> > +		goto err_out;
> > +	}
> > +	retval = dmaengine_slave_config(lp->txdma, &config);
> > +	if (retval) {
> > +		dev_err(lp->dev, "dma tx channel configuration failed: %d\n",
> > +			retval);
> > +		goto err_out;
> > +	}
> >  #endif
> >  
> >  	retval = register_netdev(dev);
> > @@ -1978,11 +2009,11 @@ static int smc911x_probe(struct net_device *dev)
> >  			    dev->base_addr, dev->irq);
> >  
> >  #ifdef SMC_USE_DMA
> > -		if (lp->rxdma != -1)
> > -			pr_cont(" RXDMA %d", lp->rxdma);
> > +		if (lp->rxdma)
> > +			pr_cont(" RXDMA %p", lp->rxdma);
> >  
> > -		if (lp->txdma != -1)
> > -			pr_cont(" TXDMA %d", lp->txdma);
> > +		if (lp->txdma)
> > +			pr_cont(" TXDMA %p", lp->txdma);
> >  #endif
> >  		pr_cont("\n");
> >  		if (!is_valid_ether_addr(dev->dev_addr)) {
> > @@ -2005,12 +2036,10 @@ static int smc911x_probe(struct net_device *dev)
> >  err_out:
> >  #ifdef SMC_USE_DMA
> >  	if (retval) {
> > -		if (lp->rxdma != -1) {
> > -			SMC_DMA_FREE(dev, lp->rxdma);
> > -		}
> > -		if (lp->txdma != -1) {
> > -			SMC_DMA_FREE(dev, lp->txdma);
> > -		}
> > +		if (lp->rxdma)
> > +			dma_release_channel(lp->rxdma);
> > +		if (lp->txdma)
> > +			dma_release_channel(lp->txdma);
> >  	}
> >  #endif
> >  	return retval;
> > @@ -2112,12 +2141,10 @@ static int smc911x_drv_remove(struct platform_device *pdev)
> >  
> >  #ifdef SMC_USE_DMA
> >  	{
> > -		if (lp->rxdma != -1) {
> > -			SMC_DMA_FREE(dev, lp->rxdma);
> > -		}
> > -		if (lp->txdma != -1) {
> > -			SMC_DMA_FREE(dev, lp->txdma);
> > -		}
> > +		if (lp->rxdma)
> > +			dma_release_channel(lp->rxdma);
> > +		if (lp->txdma)
> > +			dma_release_channel(lp->txdma);
> >  	}
> >  #endif
> >  	iounmap(lp->base);
> > diff --git a/drivers/net/ethernet/smsc/smc911x.h b/drivers/net/ethernet/smsc/smc911x.h
> > index 04b35f55df97..fa528ea0ea51 100644
> > --- a/drivers/net/ethernet/smsc/smc911x.h
> > +++ b/drivers/net/ethernet/smsc/smc911x.h
> > @@ -101,8 +101,8 @@ struct smc911x_local {
> >  #ifdef SMC_USE_DMA
> >  	/* DMA needs the physical address of the chip */
> >  	u_long physaddr;
> > -	int rxdma;
> > -	int txdma;
> > +	struct dma_chan *rxdma;
> > +	struct dma_chan *txdma;
> >  	int rxdma_active;
> >  	int txdma_active;
> >  	struct sk_buff *current_rx_skb;
> > @@ -210,27 +210,6 @@ static inline void SMC_outsl(struct smc911x_local *lp, int reg,
> >  
> >  #ifdef SMC_USE_PXA_DMA
> >  
> > -#include <mach/dma.h>
> > -
> > -/*
> > - * Define the request and free functions
> > - * These are unfortunately architecture specific as no generic allocation
> > - * mechanism exits
> > - */
> > -#define SMC_DMA_REQUEST(dev, handler) \
> > -	 pxa_request_dma(dev->name, DMA_PRIO_LOW, handler, dev)
> > -
> > -#define SMC_DMA_FREE(dev, dma) \
> > -	 pxa_free_dma(dma)
> > -
> > -#define SMC_DMA_ACK_IRQ(dev, dma)					\
> > -{									\
> > -	if (DCSR(dma) & DCSR_BUSERR) {					\
> > -		netdev_err(dev, "DMA %d bus error!\n", dma);		\
> > -	}								\
> > -	DCSR(dma) = DCSR_STARTINTR|DCSR_ENDINTR|DCSR_BUSERR;		\
> > -}
> > -
> >  /*
> >   * Use a DMA for RX and TX packets.
> >   */
> > @@ -238,6 +217,8 @@ static inline void SMC_outsl(struct smc911x_local *lp, int reg,
> >  
> >  static dma_addr_t rx_dmabuf, tx_dmabuf;
> >  static int rx_dmalen, tx_dmalen;
> > +static void smc911x_rx_dma_irq(void *data);
> > +static void smc911x_tx_dma_irq(void *data);
> >  
> >  #ifdef SMC_insl
> >  #undef SMC_insl
> > @@ -246,8 +227,10 @@ static int rx_dmalen, tx_dmalen;
> >  
> >  static inline void
> >  smc_pxa_dma_insl(struct smc911x_local *lp, u_long physaddr,
> > -		int reg, int dma, u_char *buf, int len)
> > +		int reg, struct dma_chan *dma, u_char *buf, int len)
> >  {
> > +	struct dma_async_tx_descriptor *tx;
> > +
> >  	/* 64 bit alignment is required for memory to memory DMA */
> >  	if ((long)buf & 4) {
> >  		*((u32 *)buf) = SMC_inl(lp, reg);
> > @@ -258,12 +241,14 @@ smc_pxa_dma_insl(struct smc911x_local *lp, u_long physaddr,
> >  	len *= 4;
> >  	rx_dmabuf = dma_map_single(lp->dev, buf, len, DMA_FROM_DEVICE);
> >  	rx_dmalen = len;
> > -	DCSR(dma) = DCSR_NODESC;
> > -	DTADR(dma) = rx_dmabuf;
> > -	DSADR(dma) = physaddr + reg;
> > -	DCMD(dma) = (DCMD_INCTRGADDR | DCMD_BURST32 |
> > -		DCMD_WIDTH4 | DCMD_ENDIRQEN | (DCMD_LENGTH & rx_dmalen));
> > -	DCSR(dma) = DCSR_NODESC | DCSR_RUN;
> > +	tx = dmaengine_prep_slave_single(dma, rx_dmabuf, rx_dmalen,
> > +					 DMA_DEV_TO_MEM, 0);
> > +	if (tx) {
> > +		tx->callback = smc911x_rx_dma_irq;
> > +		tx->callback_param = lp;
> > +		dmaengine_submit(tx);
> > +		dma_async_issue_pending(dma);
> > +	}
> >  }
> >  #endif
> >  
> > @@ -274,8 +259,10 @@ smc_pxa_dma_insl(struct smc911x_local *lp, u_long physaddr,
> >  
> >  static inline void
> >  smc_pxa_dma_outsl(struct smc911x_local *lp, u_long physaddr,
> > -		int reg, int dma, u_char *buf, int len)
> > +		int reg, struct dma_chan *dma, u_char *buf, int len)
> >  {
> > +	struct dma_async_tx_descriptor *tx;
> > +
> >  	/* 64 bit alignment is required for memory to memory DMA */
> >  	if ((long)buf & 4) {
> >  		SMC_outl(*((u32 *)buf), lp, reg);
> > @@ -286,12 +273,14 @@ smc_pxa_dma_outsl(struct smc911x_local *lp, u_long physaddr,
> >  	len *= 4;
> >  	tx_dmabuf = dma_map_single(lp->dev, buf, len, DMA_TO_DEVICE);
> >  	tx_dmalen = len;
> > -	DCSR(dma) = DCSR_NODESC;
> > -	DSADR(dma) = tx_dmabuf;
> > -	DTADR(dma) = physaddr + reg;
> > -	DCMD(dma) = (DCMD_INCSRCADDR | DCMD_BURST32 |
> > -		DCMD_WIDTH4 | DCMD_ENDIRQEN | (DCMD_LENGTH & tx_dmalen));
> > -	DCSR(dma) = DCSR_NODESC | DCSR_RUN;
> > +	tx = dmaengine_prep_slave_single(dma, tx_dmabuf, tx_dmalen,
> > +					 DMA_DEV_TO_MEM, 0);
> > +	if (tx) {
> > +		tx->callback = smc911x_tx_dma_irq;
> > +		tx->callback_param = lp;
> > +		dmaengine_submit(tx);
> > +		dma_async_issue_pending(dma);
> > +	}
> >  }
> >  #endif
> >  #endif	 /* SMC_USE_PXA_DMA */
> > -- 
> > 2.1.4
> > 
> 

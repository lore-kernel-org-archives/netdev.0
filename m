From: Domen Puncer <domen@coderock.org>
Subject: Re: [RFC PATCH v0.2] net driver: mpc52xx fec
Date: Tue, 2 Oct 2007 16:32:02 +0200
Message-ID: <20071002143202.GQ32628@nd47.coderock.org>
References: <20070810095153.GC13994@moe.telargo.com> <20070902074143.GB2642@nd47.coderock.org> <20071002124939.GC10481@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linuxppc-embedded@ozlabs.org, netdev@vger.kernel.org
To: Sascha Hauer <s.hauer@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kukmak.uni-mb.si ([164.8.100.3]:36346 "EHLO kukmak.uni-mb.si"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753739AbXJBOcG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Oct 2007 10:32:06 -0400
Content-Disposition: inline
In-Reply-To: <20071002124939.GC10481@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/10/07 14:49 +0200, Sascha Hauer wrote:
> 
> Hi Domen,

Hi Sascha!


> 
> On Sun, Sep 02, 2007 at 09:41:43AM +0200, Domen Puncer wrote:
>  + */
> > +static void fec_start(struct net_device *dev)
> > +{
> > +	struct fec_priv *priv = netdev_priv(dev);
> > +	struct mpc52xx_fec __iomem *fec = priv->fec;
> > +	u32 rcntrl;
> > +	u32 tcntrl;
> > +	u32 tmp;
> > +
> > +	/* clear sticky error bits */
> > +	tmp = FEC_FIFO_STATUS_ERR | FEC_FIFO_STATUS_UF | FEC_FIFO_STATUS_OF;
> > +	out_be32(&fec->rfifo_status, in_be32(&fec->rfifo_status) & tmp);
> > +	out_be32(&fec->tfifo_status, in_be32(&fec->tfifo_status) & tmp);
> > +
> > +	/* FIFOs will reset on fec_enable */
> > +	out_be32(&fec->reset_cntrl, FEC_RESET_CNTRL_ENABLE_IS_RESET);
> > +
> > +	/* Set station address. */
> > +	fec_set_paddr(dev, dev->dev_addr);
> > +
> > +	fec_set_multicast_list(dev);
> > +
> > +	/* set max frame len, enable flow control, select mii mode */
> > +	rcntrl = FEC_RX_BUFFER_SIZE << 16;	/* max frame length */
> > +	rcntrl |= FEC_RCNTRL_FCE;
> > +	rcntrl |= MII_RCNTL_MODE;
> > +	if (priv->duplex == DUPLEX_FULL)
> > +		tcntrl = FEC_TCNTRL_FDEN;	/* FD enable */
> > +	else {
> > +		rcntrl |= FEC_RCNTRL_DRT;	/* disable Rx on Tx (HD) */
> > +		tcntrl = 0;
> > +	}
> > +	out_be32(&fec->r_cntrl, rcntrl);
> > +	out_be32(&fec->x_cntrl, tcntrl);
> > +
> > +	/* Clear any outstanding interrupt. */
> > +	out_be32(&fec->ievent, 0xffffffff);
> > +
> > +	/* Enable interrupts we wish to service. */
> > +	out_be32(&fec->imask, FEC_IMASK_ENABLE);
> 
> 
> This disables phy interrupts.

Right, oops.

> 
> 
> > +static int fec_mdio_read(struct mii_bus *bus, int phy_id, int reg)
> > +{
> > +	struct fec_mdio_priv *priv = bus->priv;
> > +	int tries = 100;
> > +
> > +	u32 request = FEC_MII_READ_FRAME;
> > +	request |= (phy_id << FEC_MII_DATA_PA_SHIFT) & FEC_MII_DATA_PA_MSK;
> > +	request |= (reg << FEC_MII_DATA_RA_SHIFT) & FEC_MII_DATA_RA_MSK;
> > +
> > +	out_be32(&priv->regs->mii_data, request);
> > +
> > +	/* wait for it to finish, this takes about 23 us on lite5200b */
> > +	while (priv->completed == 0 && tries--)
> > +		udelay(5);
> > +
> > +	priv->completed = 0;
> > +
> > +	if (tries == 0)
> > +		return -ETIMEDOUT;
> 
> This does not work as expected. When a timeout occurs tries is -1 not 0,
> so the test above will never trigger.
> Using --tries instead of tries-- reveals another bug. We get a timeout
> everytime now, because MII interrupts are accidently disabled in
> fec_start().

Oh, double bug made it work! ;-)


> 
> We cannot use a waitqueue or similar for waiting for the mii transfer
> because we are atomic here.
> A simple fix is provided below. It removes the need for the interrupt
> handler in the phy handling routines. Anyway, it might be better to fix
> the phy layer not to use atomic contexts, so this patch might not be the
> way to go.

Doh, looks like this was the problem with wq's, but I forgot to remove
them, when I "fixed" the code.

> 
> 
> Regards, 
>   Sascha
> 
>  +
> > +static int fec_mdio_probe(struct of_device *of, const struct of_device_id *match)
> > +{
> > +	struct device *dev = &of->dev;
> >
> >       [...]
> >
> > +	init_waitqueue_head(&priv->wq);
> 
> This waitqueue is never used. wake_up() is called in the interrupt
> handler, but noone ever sleeps on the queue.
> 
> 
> ---
>  drivers/net/fec_mpc52xx/fec.c     |    7 +---
>  drivers/net/fec_mpc52xx/fec_phy.c |   59 +++++++-------------------------------
>  2 files changed, 15 insertions(+), 51 deletions(-)

The patch looks ok to me.


	Domen

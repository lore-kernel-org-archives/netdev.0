From: Robin Holt <holt@sgi.com>
Subject: Re: [RFC 2/4] [flexcan] Introduce a flexcan_clk set of functions.
Date: Fri, 5 Aug 2011 06:36:38 -0500
Message-ID: <20110805113638.GF4926@sgi.com>
References: <1312509979-13226-1-git-send-email-holt@sgi.com>
 <1312509979-13226-3-git-send-email-holt@sgi.com>
 <4E3BAB03.4040803@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Robin Holt <holt@sgi.com>, Wolfgang Grandegger <wg@grandegger.com>,
	socketcan-core@lists.berlios.de, netdev@vger.kernel.org
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay3.sgi.com ([192.48.152.1]:36332 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750710Ab1HELgk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Aug 2011 07:36:40 -0400
Content-Disposition: inline
In-Reply-To: <4E3BAB03.4040803@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I implemented the coding style changes below (Sorry I missed the two
the first time).

As for a better implementation, I guess I would need to understand what
is being attempted here.  I only marginally understand the flexcan
hardware on the Freescale P1010 and certainly am clueless about arm
implementations of flexcan.  I just skimmed over freescale's site
and it looks like I would be looking at their i.MX25, i.MX28, i.MX35,
and i.MX53 family of processors.  I will attempt to find some useful
documentation of those and look at the kernel sources for what the clk_*
functions are trying to accomplish.

I _THINK_ I understand.  It looks like I could implement this as a powerpc
p1010 specific thing and get the same effect without impacting flexcan.c.
I also think I understand that the i.MX25 family of processors do
essentially the same thing the p1010 is doing for determining the
clock rate.

Thanks,
Robin

On Fri, Aug 05, 2011 at 10:34:11AM +0200, Marc Kleine-Budde wrote:
> On 08/05/2011 04:06 AM, Robin Holt wrote:
> > The freescale P1010RDB board does not have a
> > clk_{get,put,get_rate,enable,disable} set of functions.  Wrap these with a
> > flexcan_ #define for arm, and implement a more complete function for ppc.
> 
> Some codingstyle nitpicks inline. I hope we'll find a cleaner solution
> than this patch.
> 
> Marc
> 
> > Signed-off-by: Robin Holt <holt@sgi.com>
> > To: Marc Kleine-Budde <mkl@pengutronix.de>
> > To: Wolfgang Grandegger <wg@grandegger.com>
> > Cc: socketcan-core@lists.berlios.de
> > Cc: netdev@vger.kernel.org
> > ---
> >  drivers/net/can/flexcan.c |  114 +++++++++++++++++++++++++++++++++++++++++----
> >  1 files changed, 105 insertions(+), 9 deletions(-)
> > 
> > diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
> > index 74b1706..3417d0b 100644
> > --- a/drivers/net/can/flexcan.c
> > +++ b/drivers/net/can/flexcan.c
> > @@ -220,6 +220,102 @@ static inline void flexcan_write(u32 val, void __iomem *addr)
> >  }
> >  #endif
> >  
> > +#if defined(__powerpc__)
> > +struct flexcan_clk {
> > +	unsigned long rate;
> > +	void *data;
> > +};
> > +
> > +static struct clk *flexcan_clk_get(struct device *dev, const char *id)
> > +{
> > +	struct flexcan_clk *clock;
> > +	u32 *clock_freq;
> > +	u32 *clock_divider;
> > +	int err;
> > +
> > +	clock = kmalloc(sizeof(struct flexcan_clk), GFP_KERNEL);
> > +	if (!clock) {
> > +		dev_err(dev, "Cannot allocate memory\n");
> > +		err = -ENOMEM;
> > +		goto failed_clock;
> > +	}
> > +	clock_freq = (u32 *)of_get_property(dev->of_node, "clock_freq", NULL);
> > +	if (!clock_freq) {
> > +		dev_err(dev, "Cannot find clock_freq property\n");
> > +		err = -EINVAL;
> > +		goto failed_clock;
> > +	}
> > +
> > +	clock_divider = (u32 *) of_get_property(dev->of_node,
>                                ^
> 
> remove this space, please
> > +					"fsl,flexcan-clock-divider", NULL);
> > +	if (clock_divider == NULL) {
> 
> !clock_divider
> 
> > +		dev_err(dev, "Cannot find fsl,flexcan-clock-divider property\n");
> > +		err = -EINVAL;
> > +		goto failed_clock;
> > +	}
> > +
> > +	clock->rate = DIV_ROUND_CLOSEST(*clock_freq / *clock_divider, 1000);
> > +	clock->rate *= 1000;
> > +
> > +	return (struct clk *)clock;
> > +
> > + failed_clock:
> > +	kfree(clock);
> > +	return ERR_PTR(err);
> > +}
> > +
> > +static inline void flexcan_clk_put(struct clk *_clk)
> > +{
> > +	struct flexcan_clk *clk = (struct flexcan_clk *)_clk;
> 
> that cast is not needed.
> 
> > +
> > +	kfree(clk);
> > +}
> > +
> > +static inline int flexcan_clk_enable(struct clk *clk)
> > +{
> > +	return 0;
> > +}
> > +
> > +static inline void flexcan_clk_disable(struct clk *clk)
> > +{
> > +	return;
> > +}
> > +
> > +static inline unsigned long flexcan_clk_get_rate(struct clk *_clk)
> > +{
> > +	struct flexcan_clk *clk = (struct flexcan_clk *)_clk;
> > +
> > +	return clk->rate;
> > +}
> > +
> > +#else
> > +static inline struct clk *flexcan_clk_get(struct device *dev, const char *id)
> > +{
> > +	return clk_get(dev, id);
> > +}
> > +
> > +static inline void flexcan_clk_put(struct clk *clk)
> > +{
> > +	clk_put(clk);
> > +}
> > +
> > +static inline int flexcan_clk_enable(struct clk *clk)
> > +{
> > +	return clk_enable(clk);
> > +}
> > +
> > +static inline void flexcan_clk_disable(struct clk *clk)
> > +{
> > +	clk_disable(clk);
> > +}
> > +
> > +static inline unsigned long flexcan_clk_get_rate(struct clk *clk)
> > +{
> > +	return clk_get_rate(clk);
> > +}
> > +
> > +#endif
> > +
> >  /*
> >   * Swtich transceiver on or off
> >   */
> > @@ -807,7 +903,7 @@ static int flexcan_open(struct net_device *dev)
> >  	struct flexcan_priv *priv = netdev_priv(dev);
> >  	int err;
> >  
> > -	clk_enable(priv->clk);
> > +	flexcan_clk_enable(priv->clk);
> >  
> >  	err = open_candev(dev);
> >  	if (err)
> > @@ -829,7 +925,7 @@ static int flexcan_open(struct net_device *dev)
> >   out_close:
> >  	close_candev(dev);
> >   out:
> > -	clk_disable(priv->clk);
> > +	flexcan_clk_disable(priv->clk);
> >  
> >  	return err;
> >  }
> > @@ -843,7 +939,7 @@ static int flexcan_close(struct net_device *dev)
> >  	flexcan_chip_stop(dev);
> >  
> >  	free_irq(dev->irq, dev);
> > -	clk_disable(priv->clk);
> > +	flexcan_clk_disable(priv->clk);
> >  
> >  	close_candev(dev);
> >  
> > @@ -882,7 +978,7 @@ static int __devinit register_flexcandev(struct net_device *dev)
> >  	struct flexcan_regs __iomem *regs = priv->base;
> >  	u32 reg, err;
> >  
> > -	clk_enable(priv->clk);
> > +	flexcan_clk_enable(priv->clk);
> >  
> >  	/* select "bus clock", chip must be disabled */
> >  	flexcan_chip_disable(priv);
> > @@ -916,7 +1012,7 @@ static int __devinit register_flexcandev(struct net_device *dev)
> >   out:
> >  	/* disable core and turn off clocks */
> >  	flexcan_chip_disable(priv);
> > -	clk_disable(priv->clk);
> > +	flexcan_clk_disable(priv->clk);
> >  
> >  	return err;
> >  }
> > @@ -936,7 +1032,7 @@ static int __devinit flexcan_probe(struct platform_device *pdev)
> >  	resource_size_t mem_size;
> >  	int err, irq;
> >  
> > -	clk = clk_get(&pdev->dev, NULL);
> > +	clk = flexcan_clk_get(&pdev->dev, NULL);
> >  	if (IS_ERR(clk)) {
> >  		dev_err(&pdev->dev, "no clock defined\n");
> >  		err = PTR_ERR(clk);
> > @@ -973,7 +1069,7 @@ static int __devinit flexcan_probe(struct platform_device *pdev)
> >  	dev->flags |= IFF_ECHO; /* we support local echo in hardware */
> >  
> >  	priv = netdev_priv(dev);
> > -	priv->can.clock.freq = clk_get_rate(clk);
> > +	priv->can.clock.freq = flexcan_clk_get_rate(clk);
> >  	priv->can.bittiming_const = &flexcan_bittiming_const;
> >  	priv->can.do_set_mode = flexcan_set_mode;
> >  	priv->can.do_get_berr_counter = flexcan_get_berr_counter;
> > @@ -1008,7 +1104,7 @@ static int __devinit flexcan_probe(struct platform_device *pdev)
> >   failed_map:
> >  	release_mem_region(mem->start, mem_size);
> >   failed_get:
> > -	clk_put(clk);
> > +	flexcan_clk_put(clk);
> >   failed_clock:
> >  	return err;
> >  }
> > @@ -1026,7 +1122,7 @@ static int __devexit flexcan_remove(struct platform_device *pdev)
> >  	mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
> >  	release_mem_region(mem->start, resource_size(mem));
> >  
> > -	clk_put(priv->clk);
> > +	flexcan_clk_put(priv->clk);
> >  
> >  	free_candev(dev);
> >  
> 
> 
> -- 
> Pengutronix e.K.                  | Marc Kleine-Budde           |
> Industrial Linux Solutions        | Phone: +49-231-2826-924     |
> Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
> Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |
> 



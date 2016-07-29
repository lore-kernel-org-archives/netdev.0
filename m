From: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH v2 1/5] ethernet: add sun8i-emac driver
Date: Fri, 29 Jul 2016 19:25:26 +0200
Message-ID: <20160729172526.GE6215@lukather>
References: <1469001800-11615-1-git-send-email-clabbe.montjoie@gmail.com>
 <1469001800-11615-2-git-send-email-clabbe.montjoie@gmail.com>
 <20160725195455.GQ7419@lukather>
 <20160728145734.GD7582@Red>
Reply-To: maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ey/N+yb7u/X9mFhi"
Cc: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org, wens-jdAy2FN1RRM@public.gmane.org,
	linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
To: LABBE Corentin <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-sunxi+bncBDSJBYGBRIMBBEND526AKGQE5T4QQHA-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Content-Disposition: inline
In-Reply-To: <20160728145734.GD7582@Red>
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org


--ey/N+yb7u/X9mFhi
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline

On Thu, Jul 28, 2016 at 04:57:34PM +0200, LABBE Corentin wrote:
> > > +static int sun8i_mdio_write(struct mii_bus *bus, int phy_addr, int phy_reg,
> > > +			    u16 data)
> > > +{
> > > +	struct net_device *ndev = bus->priv;
> > > +	struct sun8i_emac_priv *priv = netdev_priv(ndev);
> > > +	u32 reg;
> > > +	int err;
> > > +
> > > +	err = readl_poll_timeout(priv->base + SUN8I_EMAC_MDIO_CMD, reg,
> > > +				 !(reg & MDIO_CMD_MII_BUSY), 100, 10000);
> > > +	if (err) {
> > > +		dev_err(priv->dev, "%s timeout %x\n", __func__, reg);
> > > +		return err;
> > > +	}
> > 
> > Why the poll_timeout variant?
> > 
> Because, in case of bad clock/reset/regulator setting, the value
> expected to come could never be set.

Ah, I missed that it was for a busy bit, my bad. However, you seem to
be using that on several occasions, maybe you could turn that into a
function?

> > > +static void sun8i_emac_unset_syscon(struct net_device *ndev)
> > > +{
> > > +	struct sun8i_emac_priv *priv = netdev_priv(ndev);
> > > +	u32 reg = 0;
> > > +
> > > +	if (priv->variant == H3_EMAC)
> > > +		reg = H3_EPHY_DEFAULT_VALUE;
> > 
> > Why do you need that?
> > 
> For resetting the syscon to the factory default.

Yes, but does it matter? Does it have any side effect? Is that
register shared with another device?

Otherwise, either it won't be used anymore, and you don't care, or you
will reload the driver later, and the driver should work whatever
state is programmed in there. In both cases, you don't need to reset
that value.

> > > +static irqreturn_t sun8i_emac_dma_interrupt(int irq, void *dev_id)
> > > +{
> > > +	struct net_device *ndev = dev_id;
> > > +	struct sun8i_emac_priv *priv = netdev_priv(ndev);
> > > +	u32 v, u;
> > > +
> > > +	v = readl(priv->base + SUN8I_EMAC_INT_STA);
> > > +
> > > +	/* When this bit is asserted, a frame transmission is completed. */
> > > +	if (v & BIT(0)) {
> > > +		priv->estats.tx_int++;
> > > +		writel(0, priv->base + SUN8I_EMAC_INT_EN);
> > > +		napi_schedule(&priv->napi);
> > > +	}
> > > +
> > > +	/* When this bit is asserted, the TX DMA FSM is stopped. */
> > > +	if (v & BIT(1))
> > > +		priv->estats.tx_dma_stop++;
> > > +
> > > +	/* When this asserted, the TX DMA can not acquire next TX descriptor
> > > +	 * and TX DMA FSM is suspended.
> > > +	*/
> > > +	if (v & BIT(2))
> > > +		priv->estats.tx_dma_ua++;
> > > +
> > > +	if (v & BIT(3))
> > > +		netif_dbg(priv, intr, ndev, "Unhandled interrupt TX TIMEOUT\n");
> > 
> > Why do you enable that interrupt if you can't handle it?
>
> Some interrupt fire even when not enabled (like RX_BUF_UA_INT/TX_BUF_UA_INT)

So the bits 9 and 2, respectively, in the interrupt enable register
are useless?

> > And printing in the interrupt handler is a very bad idea.
> 
> There are printed only when DEBUG is set, so not a problem ?

It's always a problem, this adds a very significant latency and will
fill the kernel log buffer at an insane rate, flushing out actual
important messages, for no particular reason.
> > > +
> > > +	return IRQ_HANDLED;
> > 
> > The lack of spinlocks in there is quite worrying.
> > 
> 
> The interrupt handler just do nothing harmfull if it race with itself.
> Just stats, enabling NAPI etc..
> Anyway, It miss a comment for that non-locking strategy

The interrupt handler cannot race with itself. The interrupts will be
masked on the local CPU and the interrupt can only be delivered to a
single CPU (so, the one that the handler is currently running from).

> > > +}
> > > +
> > > +static int sun8i_emac_probe(struct platform_device *pdev)
> > > +{
> > > +	struct device_node *node = pdev->dev.of_node;
> > > +	struct sun8i_emac_priv *priv;
> > > +	struct net_device *ndev;
> > > +	struct resource *res;
> > > +	int ret;
> > > +
> > > +	ret = dma_set_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(32));
> > > +	if (ret) {
> > > +		dev_err(&pdev->dev, "No suitable DMA available\n");
> > > +		return ret;
> > > +	}
> > 
> > Isn't that the default?
> > 
> No, it is necessary on arm64 as apritzel requested.

http://lxr.free-electrons.com/source/drivers/of/device.c#L93

It seems to be shared between the two.

Thanks!
Maxime

-- 
Maxime Ripard, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com
--ey/N+yb7u/X9mFhi--

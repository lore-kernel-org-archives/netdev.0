From: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH v2 1/5] ethernet: add sun8i-emac driver
Date: Sat, 30 Jul 2016 09:34:12 +0200
Message-ID: <20160730073412.GL6215@lukather>
References: <1469001800-11615-1-git-send-email-clabbe.montjoie@gmail.com>
 <1469001800-11615-2-git-send-email-clabbe.montjoie@gmail.com>
 <20160725195455.GQ7419@lukather>
 <20160728145734.GD7582@Red>
 <20160729172526.GE6215@lukather>
 <CAGb2v678MidsiV=QJjk1bvAPL-hRFyNzZy636aObEG+HC908xw@mail.gmail.com>
Reply-To: maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="kaF1vgn83Aa7CiXN"
Cc: LABBE Corentin <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	Russell King <linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	devicetree <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-sunxi <linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
To: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
Return-path: <linux-sunxi+bncBDSJBYGBRIMBB5NQ6G6AKGQEUON7MKA-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Content-Disposition: inline
In-Reply-To: <CAGb2v678MidsiV=QJjk1bvAPL-hRFyNzZy636aObEG+HC908xw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org


--kaF1vgn83Aa7CiXN
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline

On Sat, Jul 30, 2016 at 09:30:01AM +0800, Chen-Yu Tsai wrote:
> >> > > +static void sun8i_emac_unset_syscon(struct net_device *ndev)
> >> > > +{
> >> > > + struct sun8i_emac_priv *priv = netdev_priv(ndev);
> >> > > + u32 reg = 0;
> >> > > +
> >> > > + if (priv->variant == H3_EMAC)
> >> > > +         reg = H3_EPHY_DEFAULT_VALUE;
> >> >
> >> > Why do you need that?
> >> >
> >> For resetting the syscon to the factory default.
> >
> > Yes, but does it matter? Does it have any side effect? Is that
> > register shared with another device?
> >
> > Otherwise, either it won't be used anymore, and you don't care, or you
> > will reload the driver later, and the driver should work whatever
> > state is programmed in there. In both cases, you don't need to reset
> > that value.
> 
> The "default" setting also disables and powers down the internal PHY.
> I think that's a good thing? The naming could be better.

Ah, it might, and that would obviously be the right thing to do. Using
a define for those enable and power down bits would be better though.

> >> > > +static irqreturn_t sun8i_emac_dma_interrupt(int irq, void *dev_id)
> >> > > +{
> >> > > + struct net_device *ndev = dev_id;
> >> > > + struct sun8i_emac_priv *priv = netdev_priv(ndev);
> >> > > + u32 v, u;
> >> > > +
> >> > > + v = readl(priv->base + SUN8I_EMAC_INT_STA);
> >> > > +
> >> > > + /* When this bit is asserted, a frame transmission is completed. */
> >> > > + if (v & BIT(0)) {
> >> > > +         priv->estats.tx_int++;
> >> > > +         writel(0, priv->base + SUN8I_EMAC_INT_EN);
> >> > > +         napi_schedule(&priv->napi);
> >> > > + }
> >> > > +
> >> > > + /* When this bit is asserted, the TX DMA FSM is stopped. */
> >> > > + if (v & BIT(1))
> >> > > +         priv->estats.tx_dma_stop++;
> >> > > +
> >> > > + /* When this asserted, the TX DMA can not acquire next TX descriptor
> >> > > +  * and TX DMA FSM is suspended.
> >> > > + */
> >> > > + if (v & BIT(2))
> >> > > +         priv->estats.tx_dma_ua++;
> >> > > +
> >> > > + if (v & BIT(3))
> >> > > +         netif_dbg(priv, intr, ndev, "Unhandled interrupt TX TIMEOUT\n");
> >> >
> >> > Why do you enable that interrupt if you can't handle it?
> >>
> >> Some interrupt fire even when not enabled (like RX_BUF_UA_INT/TX_BUF_UA_INT)
> >
> > So the bits 9 and 2, respectively, in the interrupt enable register
> > are useless?
> 
> Does it actually fire, i.e. pull the interrupt line on the GIC? Or is it just
> the interrupt state showing an event? IIRC some other hardware blocks have this
> behavior, such as the timer.

That's quite easy to implement, you can do a bitwise and on the status
and enable registers.

Maxime

-- 
Maxime Ripard, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com
--kaF1vgn83Aa7CiXN--

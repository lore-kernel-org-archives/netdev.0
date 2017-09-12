From: Kunihiko Hayashi <hayashi.kunihiko@socionext.com>
Subject: Re: [PATCH net-next 2/3] net: ethernet: socionext: add AVE ethernet driver
Date: Tue, 12 Sep 2017 18:24:01 +0900
Message-ID: <20170912182400.180E.4A936039@socionext.com>
References: <20170911155047.6717.4A936039@socionext.com> <20170911120009.GA24174@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        <linux-arm-kernel@lists.infradead.org>,
        <linux-kernel@vger.kernel.org>, <devicetree@vger.kernel.org>,
        Masahiro Yamada <yamada.masahiro@socionext.com>,
        Masami Hiramatsu <masami.hiramatsu@linaro.org>,
        Jassi Brar <jaswinder.singh@linaro.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170911120009.GA24174@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

On Mon, 11 Sep 2017 14:00:09 +0200 Andrew Lunn <andrew@lunn.ch> wrote:

> > > > +static irqreturn_t ave_interrupt(int irq, void *netdev)
> > > > +{
> > > > +	struct net_device *ndev = (struct net_device *)netdev;
> > > > +	struct ave_private *priv = netdev_priv(ndev);
> > > > +	u32 gimr_val, gisr_val;
> > > > +
> > > > +	gimr_val = ave_irq_disable_all(ndev);
> > > > +
> > > > +	/* get interrupt status */
> > > > +	gisr_val = ave_r32(ndev, AVE_GISR);
> > > > +
> > > > +	/* PHY */
> > > > +	if (gisr_val & AVE_GI_PHY) {
> > > > +		ave_w32(ndev, AVE_GISR, AVE_GI_PHY);
> > > > +		if (priv->internal_phy_interrupt)
> > > > +			phy_mac_interrupt(ndev->phydev, ndev->phydev->link);
> > > 
> > > Humm. I don't think this is correct. You are supposed to give it the
> > > new link state, not the old.
> > > 
> > > What does a PHY interrupt mean here? 
> > 
> > In the general case, I think PHY events like changing link state are transmitted
> > to CPU as interrupt via interrupt controller, then PHY driver itself can handle
> > the interrupt.
> > 
> > And in this case, PHY events are transmitted to MAC as one of its interrupt factor,
> > then I thought that MAC driver had to tell the events to PHY.
> 
> Could this be in-band SGMI signalling from the PHY to the MAC? Does
> the documentation give examples of when this interrupt will happen?
> 
>     Andrew

Unfortunately this MAC doesn't support SGMII.
And there aren't any examples of when this interrupt will happen.
This interrupt happens after ave_open() is called and link is established.

However, I found that auto negotiation didn't start when this interrupt wasn't handled.

Although ave_init() calls phy_start_aneg(), it doesn't make sense
because phy driver doesn't start yet.

And according to Florian's comment in ave_init(),

> +	phy_start_interrupts(phydev);
> +
> +	phy_start_aneg(phydev);
>
> No, no, phy_start() would take care of all of that correctly for you,
> you don't have have to do it just there because ave_open() eventually
> calls phy_start() for you, so just drop these two calls.

When moving phy_start_aneg() to ave_open(), the handler doesn't need to call
phy_mac_interrupt() and I can remove it from the handler.

---
Best Regards,
Kunihiko Hayashi

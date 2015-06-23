From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCHv3 net-next] net: fec: Ensure clocks are enabled while
 using mdio bus
Date: Tue, 23 Jun 2015 04:52:21 +0200
Message-ID: <20150623025221.GA11054@lunn.ch>
References: <1434825509-11241-1-git-send-email-andrew@lunn.ch>
 <BLUPR03MB37330241ECB85BA2131AAA1F5A00@BLUPR03MB373.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Cory Tusar <cory.tusar@pid1solutions.com>,
	netdev <netdev@vger.kernel.org>
To: Duan Andy <fugang.duan@freescale.com>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:56684 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751981AbbFWC6V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Jun 2015 22:58:21 -0400
Content-Disposition: inline
In-Reply-To: <BLUPR03MB37330241ECB85BA2131AAA1F5A00@BLUPR03MB373.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > int mii_id, int regnum)  {
> >  	struct fec_enet_private *fep = bus->priv;
> >  	unsigned long time_left;
> > +	int ret;
> > +
> > +	ret = clk_prepare_enable(fep->clk_ipg);
> > +	if (ret)
> > +		return ret;
> > 
> >  	fep->mii_timeout = 0;
> >  	init_completion(&fep->mdio_done);
> > @@ -1779,11 +1785,14 @@ static int fec_enet_mdio_read(struct mii_bus *bus,
> > int mii_id, int regnum)
> >  	if (time_left == 0) {
> >  		fep->mii_timeout = 1;
> >  		netdev_err(fep->netdev, "MDIO read timeout\n");
> > +		clk_disable_unprepare(fep->clk_ipg);
> >  		return -ETIMEDOUT;
> >  	}
> > 
> > -	/* return value */
> > -	return FEC_MMFR_DATA(readl(fep->hwp + FEC_MII_DATA));
> > +	ret = FEC_MMFR_DATA(readl(fep->hwp + FEC_MII_DATA));
> > +	clk_disable_unprepare(fep->clk_ipg);
> > +
> > +	return ret;
> >  }
> > 
> 

> I suggest you use runtime pm to enable/disable clock for performance
> consideration. Not every time for mdio bus access needs to
> enable/disable clock.

Can you explain that some more. When are you suggesting doing a
runtime enable/disable? Given the current DSA architecture, i would
probably do a runtime enable as soon as i lookup the mdio bus, and
never do a runtime disable. Also, how would you include this runtime
pm into the phy state machine which is going to be polling your mdio
bus around once per second for normal phys?

Florian, as Maintainer of the phy state machine, what do you think
about adding runtime PM to it?

  Thanks
	Andrew

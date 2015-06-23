From: Duan Andy <fugang.duan@freescale.com>
Subject: RE: [PATCHv3 net-next] net: fec: Ensure clocks are enabled while
 using mdio bus
Date: Tue, 23 Jun 2015 03:12:15 +0000
Message-ID: <BLUPR03MB373DBCEB67F4E59BF04C9B2F5A00@BLUPR03MB373.namprd03.prod.outlook.com>
References: <1434825509-11241-1-git-send-email-andrew@lunn.ch>
 <BLUPR03MB37330241ECB85BA2131AAA1F5A00@BLUPR03MB373.namprd03.prod.outlook.com>
 <20150623025221.GA11054@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	Cory Tusar <cory.tusar@pid1solutions.com>,
	netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0140.outbound.protection.outlook.com ([157.56.111.140]:30164
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750941AbbFWDMT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jun 2015 23:12:19 -0400
In-Reply-To: <20150623025221.GA11054@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch> Sent: Tuesday, June 23, 2015 10:52 AM
> To: Duan Fugang-B38611; Florian Fainelli
> Cc: David Miller; Cory Tusar; netdev
> Subject: Re: [PATCHv3 net-next] net: fec: Ensure clocks are enabled while
> using mdio bus
> 
> > > int mii_id, int regnum)  {
> > >  	struct fec_enet_private *fep = bus->priv;
> > >  	unsigned long time_left;
> > > +	int ret;
> > > +
> > > +	ret = clk_prepare_enable(fep->clk_ipg);
> > > +	if (ret)
> > > +		return ret;
> > >
> > >  	fep->mii_timeout = 0;
> > >  	init_completion(&fep->mdio_done);
> > > @@ -1779,11 +1785,14 @@ static int fec_enet_mdio_read(struct mii_bus
> > > *bus, int mii_id, int regnum)
> > >  	if (time_left == 0) {
> > >  		fep->mii_timeout = 1;
> > >  		netdev_err(fep->netdev, "MDIO read timeout\n");
> > > +		clk_disable_unprepare(fep->clk_ipg);
> > >  		return -ETIMEDOUT;
> > >  	}
> > >
> > > -	/* return value */
> > > -	return FEC_MMFR_DATA(readl(fep->hwp + FEC_MII_DATA));
> > > +	ret = FEC_MMFR_DATA(readl(fep->hwp + FEC_MII_DATA));
> > > +	clk_disable_unprepare(fep->clk_ipg);
> > > +
> > > +	return ret;
> > >  }
> > >
> >
> 
> > I suggest you use runtime pm to enable/disable clock for performance
> > consideration. Not every time for mdio bus access needs to
> > enable/disable clock.
> 
> Can you explain that some more. When are you suggesting doing a runtime
> enable/disable? Given the current DSA architecture, i would probably do a
> runtime enable as soon as i lookup the mdio bus, and never do a runtime
> disable. Also, how would you include this runtime pm into the phy state
> machine which is going to be polling your mdio bus around once per second
> for normal phys?
> 

You can do it like this:

#define FEC_MDIO_PM_TIMEOUT  100 /* ms */

static int fec_probe(struct platform_device *pdev)
{
	...
	pm_runtime_enable(&pdev->dev);
	pm_runtime_set_autosuspend_delay(&pdev->dev, FEC_MDIO_PM_TIMEOUT);
	pm_runtime_use_autosuspend(&pdev->dev);
	...
}


static int fec_enet_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
{
	...
	pm_runtime_get_sync(dev);

	...

	pm_runtime_mark_last_busy(dev);
	pm_runtime_put_autosuspend(dev);
}


> Florian, as Maintainer of the phy state machine, what do you think about
> adding runtime PM to it?
> 
>   Thanks
> 	Andrew

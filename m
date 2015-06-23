From: Duan Andy <fugang.duan@freescale.com>
Subject: RE: [PATCHv3 net-next] net: fec: Ensure clocks are enabled while
 using mdio bus
Date: Tue, 23 Jun 2015 04:47:54 +0000
Message-ID: <BLUPR03MB37339A6B1031412B45CF681F5A00@BLUPR03MB373.namprd03.prod.outlook.com>
References: <1434825509-11241-1-git-send-email-andrew@lunn.ch>
 <BLUPR03MB37330241ECB85BA2131AAA1F5A00@BLUPR03MB373.namprd03.prod.outlook.com>
 <20150623025221.GA11054@lunn.ch>
 <BLUPR03MB373DBCEB67F4E59BF04C9B2F5A00@BLUPR03MB373.namprd03.prod.outlook.com>
 <20150623034356.GB11054@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	David Miller <davem@davemloft.net>,
	Cory Tusar <cory.tusar@pid1solutions.com>,
	netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0120.outbound.protection.outlook.com ([207.46.100.120]:34247
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750840AbbFWFWE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2015 01:22:04 -0400
In-Reply-To: <20150623034356.GB11054@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch> Sent: Tuesday, June 23, 2015 11:44 AM
> To: Duan Fugang-B38611
> Cc: Florian Fainelli; David Miller; Cory Tusar; netdev
> Subject: Re: [PATCHv3 net-next] net: fec: Ensure clocks are enabled while
> using mdio bus
> 
> On Tue, Jun 23, 2015 at 03:12:15AM +0000, Duan Andy wrote:
> > From: Andrew Lunn <andrew@lunn.ch> Sent: Tuesday, June 23, 2015 10:52
> > AM
> > > To: Duan Fugang-B38611; Florian Fainelli
> > > Cc: David Miller; Cory Tusar; netdev
> > > Subject: Re: [PATCHv3 net-next] net: fec: Ensure clocks are enabled
> > > while using mdio bus
> > >
> > > > > int mii_id, int regnum)  {
> > > > >  	struct fec_enet_private *fep = bus->priv;
> > > > >  	unsigned long time_left;
> > > > > +	int ret;
> > > > > +
> > > > > +	ret = clk_prepare_enable(fep->clk_ipg);
> > > > > +	if (ret)
> > > > > +		return ret;
> > > > >
> > > > >  	fep->mii_timeout = 0;
> > > > >  	init_completion(&fep->mdio_done); @@ -1779,11 +1785,14 @@
> > > > > static int fec_enet_mdio_read(struct mii_bus *bus, int mii_id,
> > > > > int regnum)
> > > > >  	if (time_left == 0) {
> > > > >  		fep->mii_timeout = 1;
> > > > >  		netdev_err(fep->netdev, "MDIO read timeout\n");
> > > > > +		clk_disable_unprepare(fep->clk_ipg);
> > > > >  		return -ETIMEDOUT;
> > > > >  	}
> > > > >
> > > > > -	/* return value */
> > > > > -	return FEC_MMFR_DATA(readl(fep->hwp + FEC_MII_DATA));
> > > > > +	ret = FEC_MMFR_DATA(readl(fep->hwp + FEC_MII_DATA));
> > > > > +	clk_disable_unprepare(fep->clk_ipg);
> > > > > +
> > > > > +	return ret;
> > > > >  }
> > > > >
> > > >
> > >
> > > > I suggest you use runtime pm to enable/disable clock for
> > > > performance consideration. Not every time for mdio bus access
> > > > needs to enable/disable clock.
> > >
> > > Can you explain that some more. When are you suggesting doing a
> > > runtime enable/disable? Given the current DSA architecture, i would
> > > probably do a runtime enable as soon as i lookup the mdio bus, and
> > > never do a runtime disable. Also, how would you include this runtime
> > > pm into the phy state machine which is going to be polling your mdio
> > > bus around once per second for normal phys?
> > >
> >
> > You can do it like this:
> >
> > #define FEC_MDIO_PM_TIMEOUT  100 /* ms */
> >
> > static int fec_probe(struct platform_device *pdev) {
> > 	...
> > 	pm_runtime_enable(&pdev->dev);
> > 	pm_runtime_set_autosuspend_delay(&pdev->dev, FEC_MDIO_PM_TIMEOUT);
> > 	pm_runtime_use_autosuspend(&pdev->dev);
> > 	...
> > }
> >
> >
> > static int fec_enet_mdio_read(struct mii_bus *bus, int mii_id, int
> > regnum) {
> > 	...
> > 	pm_runtime_get_sync(dev);
> >
> > 	...
> >
> > 	pm_runtime_mark_last_busy(dev);
> > 	pm_runtime_put_autosuspend(dev);
> > }
> 
> Isn't this heavier than clk_prepare_enable()/clk_disable_unprepare()?
> 
No, I don't think so. Move clock enable/disable() to runtime suspend/resume is similar to your patch, but
Can reduce the times during mii bus stress busy access like mii stress test case.


static int fec_runtime_suspend(struct device *dev)
{
	...
	clk_disable(fep->ipg_clk);

	return 0;
}

static int fec_runtime_resume(struct device *dev)
{
	return clk_enable(fep->ipg_clk);
}

> The clock is only going to be enabled/disabled before the interface is
> opened(). Once it is open, the IGP clock is always running, so these
> clock operations just become simple reference counts. But the runtime
> operations you are suggesting will be doing lots of stuff after open as
> well as before open.
> 
No, no any lots of stuff comparing to your current implementation.

>    Andrew

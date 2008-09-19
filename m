From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH 3/3] mv643xx_eth: convert to phylib
Date: Fri, 19 Sep 2008 19:52:56 +0200
Message-ID: <20080919175256.GB23288@xi.wantstofly.org>
References: <1220448012-20347-1-git-send-email-buytenh@wantstofly.org> <1220448012-20347-4-git-send-email-buytenh@wantstofly.org> <A8E7D979-2540-456E-818C-A419D7BE4166@freescale.com> <20080918124428.GB9157@xi.wantstofly.org> <2acbd3e40809181547m3ed512b8jd744f4b8a8a3bd59@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Fleming <afleming@freescale.com>, netdev@vger.kernel.org
To: Andy Fleming <afleming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:54076 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751309AbYISRxA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2008 13:53:00 -0400
Content-Disposition: inline
In-Reply-To: <2acbd3e40809181547m3ed512b8jd744f4b8a8a3bd59@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 18, 2008 at 05:47:03PM -0500, Andy Fleming wrote:

> > I'll make this function:
> >
> >        static void phy_init(struct mv643xx_eth_private *mp, int speed, int duplex)
> >        {
> >                struct phy_device *phy = mp->phy;
> >
> >                phy_reset(mp);
> >
> >                phy_attach(mp->dev, phy->dev.bus_id, 0, PHY_INTERFACE_MODE_GMII);
> >
> >                phy->state = PHY_HALTED;
> >
> >                if (speed == 0) {
> >                        phy->autoneg = AUTONEG_ENABLE;
> >                        phy->speed = 0;
> >                        phy->duplex = 0;
> >                        phy->advertising = phy->supported | ADVERTISED_Autoneg;
> >                } else {
> >                        phy->autoneg = AUTONEG_DISABLE;
> >                        phy->advertising = 0;
> >                        phy->speed = speed;
> >                        phy->duplex = duplex;
> >                }
> >                phy_start_aneg(phy);
> >        }
> >
> > OK?  (PHY_HALTED because that seems to be the way to stop the state
> > machine from running at all.  Or should I call phy_stop() once?)
> 
> You don't need to disable the state machine.  With phy_attach, it
> won't start unless you call phy_start_machine().  So the state changes
> won't cause the state machine to run.  If the state information is
> interfering with things, let me know.  We might have to create a state
> for "state machine is not actually running".

OK.  From a look at the state handling, trying to make sure that it's
in HALTED seemed like the safe option, but as you say, just the one
call to phy_start_aneg() shouldn't mess things up -- so I'll get rid
of that.


> >> You will, however, need to
> >> figure out how best to read out the status for the PHY, and how to
> >> know when autonegotiation is done.  I'm assuming that your controller
> >> tracks that information, and that you can manually pull that
> >> information from local register space (rather than the SMI bus).
> >
> > I don't really need to access it all during normal operation -- the
> > controller just reads the link up/down and speed and duplex bits from
> > the PHY automatically and then configures itself accordingly.  The
> > only time I need to access this information is when someone asks for
> > it via ethtool (or if I want to print a link status message).  I.e. I
> > don't need any state machine, be it phylib's or my own.
> 
> Right, but doesn't your driver react to the link going up and down by
> changing the carrier state?  If so, then it costs nothing to cache
> that state in the phydev->link, and then a request for link status can
> just return phydev->link.  Those are decisions you can make, though,
> as I'm not familiar with your device and your driver.

Or, I can just return !!netif_carrier_ok(dev), since that'll always
be the same thing in this case.


> If you could check those things, you can submit the patch with:
> 
> Acked-by: Andy Fleming <afleming@freescale.com>

Thanks for the review!

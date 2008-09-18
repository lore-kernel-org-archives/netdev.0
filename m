From: "Andy Fleming" <afleming@gmail.com>
Subject: Re: [PATCH 3/3] mv643xx_eth: convert to phylib
Date: Thu, 18 Sep 2008 17:47:03 -0500
Message-ID: <2acbd3e40809181547m3ed512b8jd744f4b8a8a3bd59@mail.gmail.com>
References: <1220448012-20347-1-git-send-email-buytenh@wantstofly.org>
	 <1220448012-20347-4-git-send-email-buytenh@wantstofly.org>
	 <A8E7D979-2540-456E-818C-A419D7BE4166@freescale.com>
	 <20080918124428.GB9157@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Andy Fleming" <afleming@freescale.com>, netdev@vger.kernel.org
To: "Lennert Buytenhek" <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.171]:65420 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754741AbYIRWrF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2008 18:47:05 -0400
Received: by wf-out-1314.google.com with SMTP id 27so165442wfd.4
        for <netdev@vger.kernel.org>; Thu, 18 Sep 2008 15:47:04 -0700 (PDT)
In-Reply-To: <20080918124428.GB9157@xi.wantstofly.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> I'll make this function:
>
>        static void phy_init(struct mv643xx_eth_private *mp, int speed, int duplex)
>        {
>                struct phy_device *phy = mp->phy;
>
>                phy_reset(mp);
>
>                phy_attach(mp->dev, phy->dev.bus_id, 0, PHY_INTERFACE_MODE_GMII);
>
>                phy->state = PHY_HALTED;
>
>                if (speed == 0) {
>                        phy->autoneg = AUTONEG_ENABLE;
>                        phy->speed = 0;
>                        phy->duplex = 0;
>                        phy->advertising = phy->supported | ADVERTISED_Autoneg;
>                } else {
>                        phy->autoneg = AUTONEG_DISABLE;
>                        phy->advertising = 0;
>                        phy->speed = speed;
>                        phy->duplex = duplex;
>                }
>                phy_start_aneg(phy);
>        }
>
> OK?  (PHY_HALTED because that seems to be the way to stop the state
> machine from running at all.  Or should I call phy_stop() once?)

You don't need to disable the state machine.  With phy_attach, it
won't start unless you call phy_start_machine().  So the state changes
won't cause the state machine to run.  If the state information is
interfering with things, let me know.  We might have to create a state
for "state machine is not actually running".

>
>
>> You will, however, need to
>> figure out how best to read out the status for the PHY, and how to
>> know when autonegotiation is done.  I'm assuming that your controller
>> tracks that information, and that you can manually pull that
>> information from local register space (rather than the SMI bus).
>
> I don't really need to access it all during normal operation -- the
> controller just reads the link up/down and speed and duplex bits from
> the PHY automatically and then configures itself accordingly.  The
> only time I need to access this information is when someone asks for
> it via ethtool (or if I want to print a link status message).  I.e. I
> don't need any state machine, be it phylib's or my own.

Right, but doesn't your driver react to the link going up and down by
changing the carrier state?  If so, then it costs nothing to cache
that state in the phydev->link, and then a request for link status can
just return phydev->link.  Those are decisions you can make, though,
as I'm not familiar with your device and your driver.

If you could check those things, you can submit the patch with:

Acked-by: Andy Fleming <afleming@freescale.com>
Andy

From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCHv3 net-next] net: fec: Ensure clocks are enabled while
 using mdio bus
Date: Mon, 22 Jun 2015 21:46:09 -0700
Message-ID: <CAGVrzcah=gQM9NfM9_BRyWvMELsujsA6qGrjEcGwu8Wxb-Y3mw@mail.gmail.com>
References: <1434825509-11241-1-git-send-email-andrew@lunn.ch>
 <BLUPR03MB37330241ECB85BA2131AAA1F5A00@BLUPR03MB373.namprd03.prod.outlook.com>
 <20150623025221.GA11054@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Duan Andy <fugang.duan@freescale.com>,
	David Miller <davem@davemloft.net>,
	Cory Tusar <cory.tusar@pid1solutions.com>,
	netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f47.google.com ([209.85.218.47]:32922 "EHLO
	mail-oi0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750860AbbFWEqt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2015 00:46:49 -0400
Received: by oiyy130 with SMTP id y130so119657290oiy.0
        for <netdev@vger.kernel.org>; Mon, 22 Jun 2015 21:46:48 -0700 (PDT)
In-Reply-To: <20150623025221.GA11054@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2015-06-22 19:52 GMT-07:00 Andrew Lunn <andrew@lunn.ch>:
>> > int mii_id, int regnum)  {
>> >     struct fec_enet_private *fep = bus->priv;
>> >     unsigned long time_left;
>> > +   int ret;
>> > +
>> > +   ret = clk_prepare_enable(fep->clk_ipg);
>> > +   if (ret)
>> > +           return ret;
>> >
>> >     fep->mii_timeout = 0;
>> >     init_completion(&fep->mdio_done);
>> > @@ -1779,11 +1785,14 @@ static int fec_enet_mdio_read(struct mii_bus *bus,
>> > int mii_id, int regnum)
>> >     if (time_left == 0) {
>> >             fep->mii_timeout = 1;
>> >             netdev_err(fep->netdev, "MDIO read timeout\n");
>> > +           clk_disable_unprepare(fep->clk_ipg);
>> >             return -ETIMEDOUT;
>> >     }
>> >
>> > -   /* return value */
>> > -   return FEC_MMFR_DATA(readl(fep->hwp + FEC_MII_DATA));
>> > +   ret = FEC_MMFR_DATA(readl(fep->hwp + FEC_MII_DATA));
>> > +   clk_disable_unprepare(fep->clk_ipg);
>> > +
>> > +   return ret;
>> >  }
>> >
>>
>
>> I suggest you use runtime pm to enable/disable clock for performance
>> consideration. Not every time for mdio bus access needs to
>> enable/disable clock.
>
> Can you explain that some more. When are you suggesting doing a
> runtime enable/disable? Given the current DSA architecture, i would
> probably do a runtime enable as soon as i lookup the mdio bus, and
> never do a runtime disable. Also, how would you include this runtime
> pm into the phy state machine which is going to be polling your mdio
> bus around once per second for normal phys?

I believe the sh_eth driver is an in-tree example of a driver doing
runtime PM for its MDIO bus controller implementation.

>
> Florian, as Maintainer of the phy state machine, what do you think
> about adding runtime PM to it?

I have no objection to adding runtime PM awareness into the PHY
library, runtime PM should work well here since we are doing host
initiated reads, at least for polled PHYs. For interrupt driven PHYs,
I suppose we could also get something to work, although one needs to
be more careful. One potential issue is that runtime PM does not seem
to have some sort of latency built-in into it, so you do not really
know how long it takes to transition from low-power to functional
state where you can issue a MDIO read/write  with success.

You could argue that as long as the sum of the times needed to
wake-up, perform the operation and go back to sleep is below the
polling frequency, you are safe, but a) this does not work for all
device if we ever lower the poll frequency and b) this starts putting
near real-time requirements on doing all of these operations.

I would suspect that unless the clock feeding the MDIO bus controller
feeds over power hungry digital logic, you would get most power
savings from enabling link power management features such as EEE.
Anything else dealing with digital logic might just be noise compared
to doing this. Technically, even between an Ethernet switch and the
CPU port you should be able to do it, provided that the switch
supports it.

My 2 cents.
-- 
Florian

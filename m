From: khalasa@piap.pl (Krzysztof =?utf-8?Q?Ha=C5=82asa?=)
Subject: Re: [PATCH] I.MX6: Fix Ethernet PHY mode on Ventana boards
Date: Tue, 08 Dec 2015 15:13:10 +0100
Message-ID: <m3zixlav0p.fsf@t19.piap.pl>
References: <m3egeyct8o.fsf@t19.piap.pl>
	<CAJ+vNU0bNzuDJ971VS4r0gt4+zJj4GkXWE_qzoC0bs7s4OdU1Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>
To: Tim Harvey <tharvey@gateworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ni.piap.pl ([195.187.100.4]:44704 "EHLO ni.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756067AbbLHONN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Dec 2015 09:13:13 -0500
In-Reply-To: <CAJ+vNU0bNzuDJ971VS4r0gt4+zJj4GkXWE_qzoC0bs7s4OdU1Q@mail.gmail.com>
	(Tim Harvey's message of "Mon, 7 Dec 2015 06:34:34 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tim Harvey <tharvey@gateworks.com> writes:

> It sounds like your saying this controls whether the phy is in charge
> of delay vs the MAC. I have never needed to set this and haven't found
> where its actually used (in at least 4.3). Is this caused by something
> new in the kernel I haven't seen yet or is it possible you have board
> that has an Ethernet issue?

I think you aren't using the Marvell PHY driver :-)
The existing DTS files work fine with the "default" PHY driver.
It's only the Marvell driver (drivers/net/phy/marvell.c, aka
CONFIG_MARVELL_PHY) which have the issue.

The problem is caused by the following code in m88e1121_config_aneg():

        if (phy_interface_is_rgmii(phydev)) {

                mscr = phy_read(phydev, MII_88E1121_PHY_MSCR_REG) &
                        MII_88E1121_PHY_MSCR_DELAY_MASK;

                if (phydev->interface == PHY_INTERFACE_MODE_RGMII_ID)
                        mscr |= (MII_88E1121_PHY_MSCR_RX_DELAY |
                                 MII_88E1121_PHY_MSCR_TX_DELAY);
                else if (phydev->interface == PHY_INTERFACE_MODE_RGMII_RXID)
                        mscr |= MII_88E1121_PHY_MSCR_RX_DELAY;
                else if (phydev->interface == PHY_INTERFACE_MODE_RGMII_TXID)
                        mscr |= MII_88E1121_PHY_MSCR_TX_DELAY;

                err = phy_write(phydev, MII_88E1121_PHY_MSCR_REG, mscr);
                if (err < 0)
                        return err;
        }

mscr initially holds the correct value (one with RX_DELAY and TX_DELAY
bits set). Since the _*ID are not specified, these bits are reset and
(now incorrect) value is written back to the register.
OTOH the generic PHY driver knows nothing about the MSCR and thus
doesn't "corrupt" it.

The whole -ID thing is about signal trace lengths (on PCB), where the
non-ID setup requires special, longer traces for certain signals to
compensate for propagation times etc. The -ID version does it internally
(when enabled) and the PCB layout can be a bit simpler.

To be honest I only checked it on a single GW5400 rev. C, but I'd expect
it to be exactly the same across all GW5[234]*. Can test on GW5[23] if
there is any doubt (in few days I guess).


This issue doesn't show itself on Yocto and OpenWrt, because they
apparently don't enable marvell PHY driver. Fedora 23 does and it
doesn't work (this probably means it could be worth it to push it to
stable).
-- 
Krzysztof Halasa

Industrial Research Institute for Automation and Measurements PIAP
Al. Jerozolimskie 202, 02-486 Warsaw, Poland

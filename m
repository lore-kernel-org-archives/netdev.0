From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v3 1/1 net-next] net: fec: enable pause frame to improve
 rx prefomance for 1G network
Date: Fri, 25 Jan 2013 17:33:42 +0000
Message-ID: <1359135222.2644.2.camel@bwh-desktop.uk.solarflarecom.com>
References: <1358391358-27977-1-git-send-email-Frank.Li@freescale.com>
	 <1358973584.2658.14.camel@bwh-desktop.uk.solarflarecom.com>
	 <CAHrpEqSzu97X2PUgUEh30EqkbjLUYyhCN28AEzJ6eLPXx0Qg1Q@mail.gmail.com>
	 <1359046173.2736.2.camel@bwh-desktop.uk.solarflarecom.com>
	 <CAHrpEqRKhXRg-SsigWdnfV-RBWSc=OH9ECqQnKHDvmbn8e4a2A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Frank Li <Frank.Li@freescale.com>, <shawn.guo@linaro.org>,
	<B38611@freescale.com>, <davem@davemloft.net>,
	<linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	<s.hauer@pengutronix.de>
To: Frank Li <lznuaa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:19030 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932161Ab3AYRdt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jan 2013 12:33:49 -0500
In-Reply-To: <CAHrpEqRKhXRg-SsigWdnfV-RBWSc=OH9ECqQnKHDvmbn8e4a2A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-01-25 at 09:50 +0800, Frank Li wrote:
> 2013/1/25 Ben Hutchings <bhutchings@solarflare.com>:
> > On Thu, 2013-01-24 at 10:16 +0800, Frank Li wrote:
> >> 2013/1/24 Ben Hutchings <bhutchings@solarflare.com>:
> >> > On Thu, 2013-01-17 at 10:55 +0800, Frank Li wrote:
> >> >> The limition of imx6 internal bus cause fec can't achieve 1G perfomance.
> >> >> There will be many packages lost because FIFO over run.
> >> >>
> >> >> This patch enable pause frame flow control.
> >> > [...]
> >> >> --- a/drivers/net/ethernet/freescale/fec.c
> >> >> +++ b/drivers/net/ethernet/freescale/fec.c
> >> > [...]
> >> >> +static int fec_enet_set_pauseparam(struct net_device *ndev,
> >> >> +                                struct ethtool_pauseparam *pause)
> >> >> +{
> >> >> +     struct fec_enet_private *fep = netdev_priv(ndev);
> >> >> +
> >> >> +     if (pause->tx_pause != pause->rx_pause) {
> >> >> +             netdev_info(ndev,
> >> >> +                     "hardware only support enable/disable both tx and rx");
> >> >> +             return -EINVAL;
> >> >> +     }
> >> >> +
> >> >> +     fep->pause_flag = 0;
> >> >> +
> >> >> +     /* tx pause must be same as rx pause */
> >> >> +     fep->pause_flag |= pause->rx_pause ? FEC_PAUSE_FLAG_ENABLE : 0;
> >> >> +     fep->pause_flag |= pause->autoneg ? FEC_PAUSE_FLAG_AUTONEG : 0;
> >> >> +
> >> >> +     if (pause->rx_pause || pause->autoneg) {
> >> >> +             fep->phy_dev->supported |= ADVERTISED_Pause;
> >> >> +             fep->phy_dev->advertising |= ADVERTISED_Pause;
> >> >> +     } else {
> >> >> +             fep->phy_dev->supported &= ~ADVERTISED_Pause;
> >> >> +             fep->phy_dev->advertising &= ~ADVERTISED_Pause;
> >> >> +     }
> >> > [...]
> >> >
> >> > Why is this changing the supported flags, i.e. device capabilities?  You
> >> > need to leave those flags alone and reject an attempt to enable pause
> >> > frames on a device that doesn't support them.
> >>
> >> I go through phylib, I have not found good place set ADVERTISED_Pause
> >> capabilities.
> >> genphy_config_init never check Pause capabilities.
> >
> > I agree that phylib can't initialise pause capabilities because those
> > depend on the MAC.  But look at which function I'm quoting: this is the
> > ethtool operation, which shouldn't change capabilities.
> 
> Where is good place do you think? in probe function?

You're already setting the supported flag in fec_enet_mii_probe().  I
assume (without great familiarity with phylib) that that's the right
place to do it.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

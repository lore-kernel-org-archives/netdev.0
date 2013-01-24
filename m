From: Frank Li <lznuaa@gmail.com>
Subject: Re: [PATCH v3 1/1 net-next] net: fec: enable pause frame to improve
 rx prefomance for 1G network
Date: Thu, 24 Jan 2013 10:16:33 +0800
Message-ID: <CAHrpEqSzu97X2PUgUEh30EqkbjLUYyhCN28AEzJ6eLPXx0Qg1Q@mail.gmail.com>
References: <1358391358-27977-1-git-send-email-Frank.Li@freescale.com>
	<1358973584.2658.14.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Frank Li <Frank.Li@freescale.com>, shawn.guo@linaro.org,
	B38611@freescale.com, davem@davemloft.net,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	s.hauer@pengutronix.de
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:54725 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752954Ab3AXCQe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 21:16:34 -0500
Received: by mail-la0-f42.google.com with SMTP id fe20so9621606lab.29
        for <netdev@vger.kernel.org>; Wed, 23 Jan 2013 18:16:33 -0800 (PST)
In-Reply-To: <1358973584.2658.14.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/1/24 Ben Hutchings <bhutchings@solarflare.com>:
> On Thu, 2013-01-17 at 10:55 +0800, Frank Li wrote:
>> The limition of imx6 internal bus cause fec can't achieve 1G perfomance.
>> There will be many packages lost because FIFO over run.
>>
>> This patch enable pause frame flow control.
> [...]
>> --- a/drivers/net/ethernet/freescale/fec.c
>> +++ b/drivers/net/ethernet/freescale/fec.c
> [...]
>> +static int fec_enet_set_pauseparam(struct net_device *ndev,
>> +                                struct ethtool_pauseparam *pause)
>> +{
>> +     struct fec_enet_private *fep = netdev_priv(ndev);
>> +
>> +     if (pause->tx_pause != pause->rx_pause) {
>> +             netdev_info(ndev,
>> +                     "hardware only support enable/disable both tx and rx");
>> +             return -EINVAL;
>> +     }
>> +
>> +     fep->pause_flag = 0;
>> +
>> +     /* tx pause must be same as rx pause */
>> +     fep->pause_flag |= pause->rx_pause ? FEC_PAUSE_FLAG_ENABLE : 0;
>> +     fep->pause_flag |= pause->autoneg ? FEC_PAUSE_FLAG_AUTONEG : 0;
>> +
>> +     if (pause->rx_pause || pause->autoneg) {
>> +             fep->phy_dev->supported |= ADVERTISED_Pause;
>> +             fep->phy_dev->advertising |= ADVERTISED_Pause;
>> +     } else {
>> +             fep->phy_dev->supported &= ~ADVERTISED_Pause;
>> +             fep->phy_dev->advertising &= ~ADVERTISED_Pause;
>> +     }
> [...]
>
> Why is this changing the supported flags, i.e. device capabilities?  You
> need to leave those flags alone and reject an attempt to enable pause
> frames on a device that doesn't support them.

I go through phylib, I have not found good place set ADVERTISED_Pause
capabilities.
genphy_config_init never check Pause capabilities.

>
> Ben.
>
> --
> Ben Hutchings, Staff Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
>

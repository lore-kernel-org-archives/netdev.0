From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: Re: [PATCH net] gianfar: Check if phydev present on ethtool -A
Date: Thu, 24 Apr 2014 11:04:18 +0300
Message-ID: <5358C582.8090808@freescale.com>
References: <1398260327-23381-1-git-send-email-claudiu.manoil@freescale.com>
 <1398270087.7767.157.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2lp0212.outbound.protection.outlook.com ([207.46.163.212]:56086
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751328AbaDXIEl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Apr 2014 04:04:41 -0400
In-Reply-To: <1398270087.7767.157.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/23/2014 7:21 PM, Ben Hutchings wrote:
> On Wed, 2014-04-23 at 16:38 +0300, Claudiu Manoil wrote:
>> This fixes a seg fault on 'ethtool -A' entry if the
>> interface is down.  Obviously we need to have the
>> phy device initialized / "connected" (see of_phy_connect())
>> to be able to advertise pause frame capabilities.
>
> Why is the phydev detached while the interface is down?!

Hi Ben,
Gianfar uses the phylib framework, and it's been always calling
phy_connect() during net_device open and the complementary
phy_disconnect() during net_device close (ndo_stop).
I think this is the general recommendation on how the net_device
driver should integrate with the phylib: i.e. "phy_disconnect - disable
interrupts, stop state machine, and detach a PHY device" while the
interface is down.  Many other net_device drivers call phy_disconnect()
on device close.

>
>> Fixes: 23402bddf9e56eecb27bbd1e5467b3b79b3dbe58
>> Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
>> ---
>>   drivers/net/ethernet/freescale/gianfar_ethtool.c | 3 +++
>>   1 file changed, 3 insertions(+)
>>
>> diff --git a/drivers/net/ethernet/freescale/gianfar_ethtool.c b/drivers/net/ethernet/freescale/gianfar_ethtool.c
>> index 891dbee..76d7070 100644
>> --- a/drivers/net/ethernet/freescale/gianfar_ethtool.c
>> +++ b/drivers/net/ethernet/freescale/gianfar_ethtool.c
>> @@ -533,6 +533,9 @@ static int gfar_spauseparam(struct net_device *dev,
>>   	struct gfar __iomem *regs = priv->gfargrp[0].regs;
>>   	u32 oldadv, newadv;
>>
>> +	if (!phydev)
>> +		return -ENODEV;
>> +
>>   	if (!(phydev->supported & SUPPORTED_Pause) ||
>>   	    (!(phydev->supported & SUPPORTED_Asym_Pause) &&
>>   	     (epause->rx_pause != epause->tx_pause)))
>
> I think you can instead remove the following check, as pause support is
> a property of the MAC not the PHY.
>

I wish it was as easy as that.  But my understanding is that link
partners need to negotiate their pause frame capabilities at PHY
level.  If a phy is not able to signal (advertise) to the link
partner that the MAC supports pause frame handling then the flow
control btw link partners won't work properly (at least this is my
understanding from looking at other implementations, like tg3).
If it weren't so then the phydev's pause support and advertising
flags and mii_advertise_flowctrl()/ mii_resolve_flowctrl_fdx()
would be useless, right?

Thanks,
Claudiu

> Ben.
>

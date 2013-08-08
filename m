From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: Re: [PATCH 2/2][net-next] gianfar: Add ethtool -A support for pause
 frame
Date: Thu, 8 Aug 2013 20:10:00 +0300
Message-ID: <5203D0E8.8050809@freescale.com>
References: <1375871056-10420-1-git-send-email-claudiu.manoil@freescale.com>  <1375871056-10420-2-git-send-email-claudiu.manoil@freescale.com> <1375902775.2644.98.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe003.messaging.microsoft.com ([216.32.181.183]:39342
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753094Ab3HHRKM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Aug 2013 13:10:12 -0400
In-Reply-To: <1375902775.2644.98.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ben,

On 8/7/2013 10:12 PM, Ben Hutchings wrote:
> On Wed, 2013-08-07 at 13:24 +0300, Claudiu Manoil wrote:
>> Allow Rx/Tx pause frame configuration via ethtool.
>> The gfar devices feature link autonegotioation by default.
>
> So the MAC configuration bits are actually copied to the PHY autoneg
> basic page, and then the PHY autoneg result is automatically used by the
> MAC?
>
> This is of course possible to do in hardware, but... since this MAC is
> not smart enough to ignore pause settings when running in half-duplex
> mode, I seriously doubt it is doing all this by itself.
>

I just wanted to say actually that the pause->autoneg parameter is not
needed by the gianfar driver, but I didn't know what to do with it in
get_pauseparam(), apparently pause->autoneg needs a value (or can
simply ignore this param?).

I don't see what autonegotiation has to do with enabling/disabling
pause frame generation in this case. My understanding is that link
autonegotiation is taken care somewhere else, by the phy state machine.
Each time this happens, the gianfar driver gets notified via the
adjust_link() hook that it implements and makes the necessary configs
in the mac registers.

Besides, autoneg info is already being displayed by ethtool (see
print below).
So I don't understand the use of pause->autoneg. What should I do with
it?

Thanks,
Claudiu

____
root@p1020rdb-pd:~# ethtool eth2
Settings for eth2:
         Supported ports: [ MII ]
         Supported link modes:   10baseT/Half 10baseT/Full
                                 100baseT/Half 100baseT/Full
                                 1000baseT/Full
         Supported pause frame use: No
         Supports auto-negotiation: Yes
         Advertised link modes:  10baseT/Half 10baseT/Full
                                 100baseT/Half 100baseT/Full
                                 1000baseT/Full
         Advertised pause frame use: No
         Advertised auto-negotiation: Yes
         Speed: 1000Mb/s
         Duplex: Full
         Port: MII
         PHYAD: 1
         Transceiver: external
         Auto-negotiation: on
         Supports Wake-on: g
         Wake-on: d
         Current message level: 0x0000003f (63)
                                drv probe link timer ifdown ifup
         Link detected: yes


>> The device is being configured with the new pause frame
>> parameters if the link is up, depending on link duplex (no
>> pause frames for half-duplex links), or during link autoneg
>> (see adjust_link()).
> [...]
>> --- a/drivers/net/ethernet/freescale/gianfar_ethtool.c
>> +++ b/drivers/net/ethernet/freescale/gianfar_ethtool.c
>> @@ -535,6 +535,34 @@ static int gfar_sringparam(struct net_device *dev,
>>   	return err;
>>   }
>>
>> +static void gfar_gpauseparam(struct net_device *dev,
>> +			     struct ethtool_pauseparam *pause)
>> +{
>> +	struct gfar_private *priv = netdev_priv(dev);
>> +
>> +	pause->autoneg = AUTONEG_ENABLE;
>> +	if (priv->rx_pause)
>> +		pause->rx_pause = 1;
>> +	if (priv->tx_pause)
>> +		pause->tx_pause = 1;
>> +}
>> +
>> +static int gfar_spauseparam(struct net_device *dev,
>> +			    struct ethtool_pauseparam *pause)
>> +{
>> +	struct gfar_private *priv = netdev_priv(dev);
>> +	struct phy_device *phydev = priv->phydev;
>
> You need to reject an unsupported setting of pause->autoneg here.
>
> Ben.
>
>> +	priv->rx_pause = !!pause->rx_pause;
>> +	priv->tx_pause = !!pause->tx_pause;
>> +
>> +	/* update h/w settings, if link is up */
>> +	if (phydev && phydev->link)
>> +		gfar_configure_pause(priv, !!phydev->duplex);
>> +
>> +	return 0;
>> +}
>> +
>>   int gfar_set_features(struct net_device *dev, netdev_features_t features)
>>   {
>>   	struct gfar_private *priv = netdev_priv(dev);
> [...]
>

From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 1/2] net: ethernet: nb8800: Do not apply TX delay at MAC
 level
Date: Wed, 9 Nov 2016 09:03:18 -0800
Message-ID: <0fc519a7-6e42-de55-7a4a-c7dc9d64c5db@gmail.com>
References: <581CA300.1060609@laposte.net>
 <yw1xlgwzjmti.fsf@unicorn.mansr.com> <581CAB12.3030604@laposte.net>
 <b792b229-6126-c3a7-e071-bdd93fe51626@gmail.com>
 <yw1x1syrjil8.fsf@unicorn.mansr.com> <58231E6C.2040603@laposte.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>, Mason <slash.tmp@free.fr>,
        Andrew Lunn <andrew@lunn.ch>
To: Sebastian Frias <sf84@laposte.net>,
        =?UTF-8?B?TcOlbnMgUnVsbGfDpXJk?= <mans@mansr.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <58231E6C.2040603@laposte.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/09/2016 05:02 AM, Sebastian Frias wrote:
> On 11/04/2016 05:49 PM, Måns Rullgård wrote:
>>>> But when doing so, both the Atheros 8035 and the Aurora NB8800 drivers
>>>> will apply the delay.
>>>>
>>>> I think a better way of dealing with this is that both, PHY and MAC
>>>> drivers exchange information so that the delay is applied only once.
>>>
>>> Exchange what information? The PHY device interface (phydev->interface)
>>> conveys the needed information for both entities.
>>
>> There doesn't seem to be any consensus among the drivers regarding where
>> the delay should be applied.  Since only a few drivers, MAC or PHY, act
>> on this property, most combinations still work by chance.  It is common
>> for boards to set the delay at the PHY using external config pins so no
>> software setup is required (although I have one Sigma based board that
>> gets this wrong).  I suspect if drivers/net/ethernet/broadcom/genet were
>> used with one of the four PHY drivers that also set the delay based on
>> this DT property, things would go wrong.
>>
> 
> Exactly, what about a patch like (I can make a formal submission, even
> merge it with the patch discussed in this thread, consider this a RFC):

I really don't see a point in doing this when we can just clarify what
phydev->interface does and already have the knowledge that we need
without introducing additional flags in the phy driver.

> 
> diff --git a/drivers/net/ethernet/aurora/nb8800.c b/drivers/net/ethernet/aurora/nb8800.c
> index fba2699..4217ff4 100644
> --- a/drivers/net/ethernet/aurora/nb8800.c
> +++ b/drivers/net/ethernet/aurora/nb8800.c
> @@ -1283,6 +1283,10 @@ static int nb8800_tangox_init(struct net_device *dev)
>  	case PHY_INTERFACE_MODE_RGMII_RXID:
>  	case PHY_INTERFACE_MODE_RGMII_TXID:
>  		pad_mode = PAD_MODE_RGMII;
> +
> +		if ((dev->phydev->flags & PHY_SUPPORTS_TXID) == 0)
> +			pad_mode |= PAD_MODE_GTX_CLK_DELAY;
> +
>  		break;
>  
>  	default:
> diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
> index 2e0c759..5eddb04 100644
> --- a/drivers/net/phy/at803x.c
> +++ b/drivers/net/phy/at803x.c
> @@ -426,7 +426,9 @@ static int at803x_aneg_done(struct phy_device *phydev)
>  	.suspend		= at803x_suspend,
>  	.resume			= at803x_resume,
>  	.features		= PHY_GBIT_FEATURES,
> -	.flags			= PHY_HAS_INTERRUPT,
> +	.flags			= PHY_HAS_INTERRUPT |
> +				  PHY_SUPPORTS_RXID |
> +				  PHY_SUPPORTS_TXID,
>  	.config_aneg		= genphy_config_aneg,
>  	.read_status		= genphy_read_status,
>  	.ack_interrupt		= at803x_ack_interrupt,
> diff --git a/include/linux/phy.h b/include/linux/phy.h
> index e7e1fd3..0f0b17e 100644
> --- a/include/linux/phy.h
> +++ b/include/linux/phy.h
> @@ -61,6 +61,8 @@
>  #define PHY_HAS_INTERRUPT	0x00000001
>  #define PHY_HAS_MAGICANEG	0x00000002
>  #define PHY_IS_INTERNAL		0x00000004
> +#define PHY_SUPPORTS_RXID       0x00000008
> +#define PHY_SUPPORTS_TXID       0x00000010
>  #define MDIO_DEVICE_IS_PHY	0x80000000
>  
>  /* Interface Mode definitions */
> 


-- 
Florian

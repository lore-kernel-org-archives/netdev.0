From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] r8169: support restricting speed+duplex in autonegotiation
Date: Fri, 27 May 2005 16:59:53 -0700
Message-ID: <4297B479.1080404@candelatech.com>
References: <4297A0F7.5070209@phekda.gotadsl.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, Linux netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Richard Dawe <rich@phekda.gotadsl.co.uk>
In-Reply-To: <4297A0F7.5070209@phekda.gotadsl.co.uk>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Richard Dawe wrote:
> Hello.
> 
> Attached is a patch for drivers/net/r8169.c against Linux 2.6.11 that 
> allows adjustment of the speed and duplex advertised via 
> autonegotiation. Example usage:
> 
>   ethtool -s eth0 autoneg on speed 10 duplex half
> 
> Also attached is a test script which tries various combinations of 
> autoneg, speed and duplex. There is also a log of the test run attache.d 
> While the test ran I had an ssh session running "while true; do sleep 1; 
> date; done". The ssh session did not drop. Note that I don't have GigE, 
> so that part of the test was bogus.
> 
> I also tried various speed tests, to check that the speed and duplex 
> were actually changed. They were.
> 
> Bye, Rich
> 
> r8169: Allow adjustment of speed and duplex advertised via autonegotiation
> 
> Signed-off-by: Richard Dawe <rich@phekda.gotadsl.co.uk>
> 
> 
> ------------------------------------------------------------------------
> 
> --- r8169.c.orig	2005-05-27 21:12:21.000000000 +0100
> +++ r8169.c	2005-05-27 22:14:59.000000000 +0100
> @@ -407,7 +407,9 @@ struct rtl8169_private {
>  #ifdef CONFIG_R8169_VLAN
>  	struct vlan_group *vlgrp;
>  #endif
> -	int (*set_speed)(struct net_device *, u8 autoneg, u16 speed, u8 duplex);
> +	int (*set_speed)(struct net_device *,
> +			 u8 autoneg, u16 speed, u8 duplex,
> +			 u32 advertising);
>  	void (*get_settings)(struct net_device *, struct ethtool_cmd *);
>  	void (*phy_reset_enable)(void __iomem *);
>  	unsigned int (*phy_reset_pending)(void __iomem *);
> @@ -549,7 +551,9 @@ static void rtl8169_check_link_status(st
>  	spin_unlock_irqrestore(&tp->lock, flags);
>  }
>  
> -static void rtl8169_link_option(int idx, u8 *autoneg, u16 *speed, u8 *duplex)
> +static void rtl8169_link_option(int idx,
> +				u8 *autoneg, u16 *speed, u8 *duplex,
> +				u32 *advertising)
>  {
>  	struct {
>  		u16 speed;
> @@ -579,6 +583,23 @@ static void rtl8169_link_option(int idx,
>  	*autoneg = p->autoneg;
>  	*speed = p->speed;
>  	*duplex = p->duplex;
> +
> +	if (p->media == _10_Half)
> +		*advertising = ADVERTISED_10baseT_Half;
> +	if (p->media == _10_Full)
> +		*advertising = ADVERTISED_10baseT_Full;
> +	if (p->media == _100_Half)
> +		*advertising = ADVERTISED_100baseT_Half;
> +	if (p->media == _100_Full)
> +		*advertising = ADVERTISED_100baseT_Full;
> +	if (p->media == _1000_Full)
> +		*advertising = ADVERTISED_1000baseT_Full;
> +	if (p->media == 0xff)
> +		*advertising = ADVERTISED_10baseT_Half |
> +			       ADVERTISED_10baseT_Full |
> +			       ADVERTISED_100baseT_Half |
> +			       ADVERTISED_100baseT_Full |
> +			       ADVERTISED_1000baseT_Full;
>  }

So, is there no way to advert just 100Mbps-half and -full ?

Seems like you should be able to set each flag by itself and
create a bit-mask of the particular flags that you want...

Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

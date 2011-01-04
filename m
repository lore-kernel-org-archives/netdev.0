From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] r8169: support control of advertising
Date: Tue, 04 Jan 2011 17:20:21 +0000
Message-ID: <1294161621.3636.17.camel@bwh-desktop>
References: <201101041715.09622.oneukum@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, davem@davemloft.net,
	netdev@vger.kernel.org, machen@novell.com
To: Oliver Neukum <oneukum@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:10514 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752489Ab1ADRUZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jan 2011 12:20:25 -0500
In-Reply-To: <201101041715.09622.oneukum@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-01-04 at 17:15 +0100, Oliver Neukum wrote:
> From 91e84e6b6ca416e8200f04b60383c398f9b93bd2 Mon Sep 17 00:00:00 2001
> From: Oliver Neukum <oliver@neukum.org>
> Date: Tue, 4 Jan 2011 17:11:29 +0100
> Subject: [PATCH] r8169: support control of advertising
> 
> This allows "ethtool advertise" to control the speed and duplex
> features the device offers the switch.
> 
> Signed-off-by: Oliver Neukum <oneukum@suse.de>
> ---
>  drivers/net/r8169.c |   41 +++++++++++++++++++++++++++++++----------
>  1 files changed, 31 insertions(+), 10 deletions(-)
> 
> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
> index e165d96..f2c8583 100644
> --- a/drivers/net/r8169.c
> +++ b/drivers/net/r8169.c
[...]
> @@ -912,8 +912,20 @@ static int rtl8169_set_speed_xmii(struct net_device *dev,
>  		int auto_nego;
>  
>  		auto_nego = mdio_read(ioaddr, MII_ADVERTISE);
> -		auto_nego |= (ADVERTISE_10HALF | ADVERTISE_10FULL |
> -			      ADVERTISE_100HALF | ADVERTISE_100FULL);
> +		auto_nego &= ~(ADVERTISED_10baseT_Half |

Should be ADVERTISE_10HALF.

> +				ADVERTISE_10FULL |
> +				ADVERTISE_100HALF |
> +				ADVERTISE_100FULL);
> +		
> +		if (adv & ADVERTISED_10baseT_Half)
> +			auto_nego |= ADVERTISE_10HALF;
> +		if (adv & ADVERTISED_10baseT_Full)
> +			auto_nego |= ADVERTISE_10FULL;
> +		if (adv & ADVERTISED_100baseT_Half)
> +			auto_nego |= ADVERTISE_100HALF;
> +		if (adv & ADVERTISED_100baseT_Full)
> +			auto_nego |=  ADVERTISE_100FULL;
> +
>  		auto_nego |= ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM;
[...]

Pause advertising should also be controllable through ethtool, if flow
control can be altered in the MAC.  (It's not clear whether it can.)

This should also check for unsupported advertising flags (e.g.
ADVERTISED_1000baseT_Full when the MAC doesn't support 1000M) and return
-EINVAL if they're set.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


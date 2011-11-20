From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2] Add ethtool to mii advertisment conversion helpers
Date: Sun, 20 Nov 2011 16:26:17 -0500 (EST)
Message-ID: <20111120.162617.1715993269904044868.davem@davemloft.net>
References: <1321486057-30968-1-git-send-email-mcarlson@broadcom.com>
	<20111116.184032.1176336205445892405.davem@davemloft.net>
	<1321823497.4984.4.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mcarlson@broadcom.com, netdev@vger.kernel.org, mchan@broadcom.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53295 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753835Ab1KTV0V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Nov 2011 16:26:21 -0500
In-Reply-To: <1321823497.4984.4.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 20 Nov 2011 22:11:37 +0100

> For reference, the revert on tg3 :
> 
> diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
> index 024ca1d..365cd47 100644
> --- a/drivers/net/ethernet/broadcom/tg3.c
> +++ b/drivers/net/ethernet/broadcom/tg3.c
> @@ -3594,7 +3594,15 @@ static int tg3_phy_autoneg_cfg(struct tg3 *tp, u32 advertise, u32 flowctrl)
>  	u32 val, new_adv;
>  
>  	new_adv = ADVERTISE_CSMA;
> -	new_adv |= ethtool_adv_to_mii_100bt(advertise);
> +	if (advertise & ADVERTISED_10baseT_Half)
> +		new_adv |= ADVERTISE_10HALF;
> +	if (advertise & ADVERTISED_10baseT_Full)
> +		new_adv |= ADVERTISE_10FULL;
> +	if (advertise & ADVERTISED_100baseT_Half)
> +		new_adv |= ADVERTISE_100HALF;
> +	if (advertise & ADVERTISED_100baseT_Full)
> +		new_adv |= ADVERTISE_100FULL;
> +
>  	new_adv |= tg3_advert_flowctrl_1000T(flowctrl);
>  

Well, for one thing the flow control handling is subtly changed here.

ethtool_adv_to_mii_100bt() does it's own setting of the flow control
advertisement bits.  It sets ADVERTISE_PAUSE_CAP and
ADVERTISE_PAUSE_ASYM.

But here in tg3, tg3_advert_flowctrl_1000T() has it's own seperate
logic for setting those bits.

I cannot say for certain that this is what it causing your problems,
but it is clear now that these transformations were not done carefully
enough.

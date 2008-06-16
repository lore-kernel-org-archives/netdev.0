From: Patrick McHardy <kaber@trash.net>
Subject: Re: RFC: [PATCH 2/3] netdevice: Fix promiscuity and allmulti overflow
Date: Mon, 16 Jun 2008 11:38:36 +0200
Message-ID: <4856349C.70201@trash.net>
References: <48562F45.3040302@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58263 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752202AbYFPJim (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 05:38:42 -0400
In-Reply-To: <48562F45.3040302@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wang Chen wrote:
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 5829630..a3c692d 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2753,10 +2753,20 @@ static void __dev_set_promiscuity(struct net_device *dev, int inc)
>  
>  	ASSERT_RTNL();
>  
> +	dev->flags |= IFF_PROMISC;
>  	if ((dev->promiscuity += inc) == 0)
> -		dev->flags &= ~IFF_PROMISC;
> -	else
> -		dev->flags |= IFF_PROMISC;
> +		/*
> +		 * Avoid overflow.
> +		 * If inc causes overflow, ignore it and warn user.
> +		 */
> +		if (inc < 0)
> +			dev->flags &= ~IFF_PROMISC;
> +		else {
> +			dev->promiscuity -= inc;
> +			printk(KERN_ERR "%s: promiscuity touches roof, "
> +				"set promiscuity failed, promiscuity feature "
> +				"of device will be broken.\n");
> +		}

Additional parens around the inner block would make this more
readable.

I question the need for this though, userspace can only trigger
an increase/decrease by one no matter how often it enables
the ALLMULTI/PROMISC flags, and I doubt any codepath in the
kernel would lead to an overflow.

If this can really happen it would be better to leave the
counter untouched and return an error, we already have too
many device operations that might fail more or less silently.



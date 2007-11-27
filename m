From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCHv6 1/3] rtnetlink: setlink changes are unprotected; with
 single notification
Date: Tue, 27 Nov 2007 14:07:28 +0100
Message-ID: <474C1690.3010405@trash.net>
References: <11955644701165-git-send-email-panther@balabit.hu> <1195564470928-git-send-email-panther@balabit.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Laszlo Attila Toth <panther@balabit.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58627 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755829AbXK0NHg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2007 08:07:36 -0500
In-Reply-To: <1195564470928-git-send-email-panther@balabit.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Laszlo Attila Toth wrote:
> In do_setlink the device changes don't need to be protected. Notification
> is sent at the end of the function once if any modification occured
> and once if an address has been changed.
> 
> Signed-off-by: Laszlo Attila Toth <panther@balabit.hu>
> ---
>  net/core/rtnetlink.c |   32 ++++++++++++++++++++------------
>  1 files changed, 20 insertions(+), 12 deletions(-)
> 
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index 4a07e83..20cb67e 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -542,7 +542,7 @@ int rtnl_put_cacheinfo(struct sk_buff *skb, struct dst_entry *dst, u32 id,
>  
>  EXPORT_SYMBOL_GPL(rtnl_put_cacheinfo);
>  
> -static void set_operstate(struct net_device *dev, unsigned char transition)
> +static int set_operstate(struct net_device *dev, unsigned char transition)
>  {
>  	unsigned char operstate = dev->operstate;
>  
> @@ -562,11 +562,10 @@ static void set_operstate(struct net_device *dev, unsigned char transition)
>  	}
>  
>  	if (dev->operstate != operstate) {
> -		write_lock_bh(&dev_base_lock);
>  		dev->operstate = operstate;
> -		write_unlock_bh(&dev_base_lock);
> -		netdev_state_change(dev);
> -	}
> +		return 1;
> +	} else
> +		return 0;


The locking changes belong in a seperate patch with an explanation.

>  
> -	if (tb[IFLA_OPERSTATE])
> -		set_operstate(dev, nla_get_u8(tb[IFLA_OPERSTATE]));
> +	if (tb[IFLA_OPERSTATE]) {
> +		modified |= set_operstate(dev, nla_get_u8(tb[IFLA_OPERSTATE]));
> +	}

Please don't add braces here.

The rest looks fine.

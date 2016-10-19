From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net] net: core: Correctly iterate over lower adjacency
 list
Date: Wed, 19 Oct 2016 08:33:19 -0600
Message-ID: <c029e5bb-68b4-322f-f7b5-9ada9e5915ac@cumulusnetworks.com>
References: <1476885428-5189-1-git-send-email-idosch@idosch.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
        Ido Schimmel <idosch@mellanox.com>
To: idosch@idosch.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:36758 "EHLO
        mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S941689AbcJSOdX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2016 10:33:23 -0400
Received: by mail-io0-f180.google.com with SMTP id j37so33301076ioo.3
        for <netdev@vger.kernel.org>; Wed, 19 Oct 2016 07:33:22 -0700 (PDT)
In-Reply-To: <1476885428-5189-1-git-send-email-idosch@idosch.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/19/16 7:57 AM, idosch@idosch.org wrote:
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 136ae6bb..465e128 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -3877,7 +3877,7 @@ struct net_device *netdev_all_lower_get_next_rcu(struct net_device *dev,
>  	     ldev = netdev_all_lower_get_next(dev, &(iter)))
>  
>  #define netdev_for_each_all_lower_dev_rcu(dev, ldev, iter) \
> -	for (iter = (dev)->all_adj_list.lower.next, \
> +	for (iter = &(dev)->all_adj_list.lower, \
>  	     ldev = netdev_all_lower_get_next_rcu(dev, &(iter)); \
>  	     ldev; \
>  	     ldev = netdev_all_lower_get_next_rcu(dev, &(iter)))
> diff --git a/net/core/dev.c b/net/core/dev.c
> index f1fe26f..b09ac57 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -5511,10 +5511,14 @@ struct net_device *netdev_all_lower_get_next_rcu(struct net_device *dev,
>  {
>  	struct netdev_adjacent *lower;
>  
> -	lower = list_first_or_null_rcu(&dev->all_adj_list.lower,
> -				       struct netdev_adjacent, list);
> +	lower = list_entry_rcu((*iter)->next, struct netdev_adjacent, list);
> +
> +	if (&lower->list == &dev->all_adj_list.lower)
> +		return NULL;
> +
> +	*iter = &lower->list;
>  
> -	return lower ? lower->dev : NULL;
> +	return lower->dev;
>  }
>  EXPORT_SYMBOL(netdev_all_lower_get_next_rcu);


When I converted this function in my series I wondered how the current code worked at all. I guess I didn't. This is inline with what I did and matches the form used for the all_upper variant, so for 4.9 and 4.8.x

Acked-by: David Ahern <dsa@cumulusnetworks.com>

I would like to see my series applied to 4.9 at some point.

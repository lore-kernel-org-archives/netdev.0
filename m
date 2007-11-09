From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Fix infinite loop on dev_mc_unsync()
Date: Sat, 10 Nov 2007 00:12:34 +0100
Message-ID: <4734E962.3010603@trash.net>
References: <20071109151135.GA12982@pogo> <20071109183733.GA22714@pogo> <1194635236.19522.3.camel@localhost> <20071109192033.GB22714@pogo>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	David Miller <davem@davemloft.net>
To: "Luis R. Rodriguez" <mcgrof@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36566 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751874AbXKIXMU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2007 18:12:20 -0500
In-Reply-To: <20071109192033.GB22714@pogo>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Luis R. Rodriguez wrote:
> diff --git a/net/core/dev_mcast.c b/net/core/dev_mcast.c
> index 15241cf..2aea8e1 100644
> --- a/net/core/dev_mcast.c
> +++ b/net/core/dev_mcast.c
> @@ -160,14 +160,12 @@ EXPORT_SYMBOL(dev_mc_sync);
>   */
>  void dev_mc_unsync(struct net_device *to, struct net_device *from)
>  {
> -	struct dev_addr_list *da, *next;
> +	struct dev_addr_list *da;
>  
>  	netif_tx_lock_bh(from);
>  	netif_tx_lock_bh(to);
>  
> -	da = from->mc_list;
> -	while (da != NULL) {
> -		next = da->next;
> +	for (da = from->mc_list; da; da = da->next) {
>   

This may cause a use-after-free since __dev_addr_delete frees the address
when all references are gone.

>  		if (!da->da_synced)
>  			continue;
>  		__dev_addr_delete(&to->mc_list, &to->mc_count,
> @@ -175,7 +173,6 @@ void dev_mc_unsync(struct net_device *to, struct net_device *from)
>  		da->da_synced = 0;
>  		__dev_addr_delete(&from->mc_list, &from->mc_count,
>  				  da->da_addr, da->da_addrlen, 0);
> -		da = next;
>  	}
>   



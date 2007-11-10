From: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Subject: Re: [PATCH] Fix infinite loop on dev_mc_unsync()
Date: Sat, 10 Nov 2007 01:13:42 +0100
Message-ID: <4734F7B6.7060505@trash.net>
References: <20071109151135.GA12982@pogo> <20071109183733.GA22714@pogo>	 <1194635236.19522.3.camel@localhost> <20071109192033.GB22714@pogo>	 <4734E962.3010603@trash.net> <1194653320.19522.28.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Luis R. Rodriguez" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1194653320.19522.28.camel@localhost>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Joe Perches wrote:
> On Sat, 2007-11-10 at 00:12 +0100, Patrick McHardy wrote:
>   
>> This may cause a use-after-free since __dev_addr_delete frees the address
>> when all references are gone.
>>     
>
> How about a comment then?  Perhaps:
>
> diff --git a/net/core/dev_mcast.c b/net/core/dev_mcast.c
> index ae35405..63576aa 100644
> --- a/net/core/dev_mcast.c
> +++ b/net/core/dev_mcast.c
> @@ -165,16 +165,23 @@ void dev_mc_unsync(struct net_device *to, struct net_device *from)
>  	netif_tx_lock_bh(from);
>  	netif_tx_lock_bh(to);
>  
> +	/*
> +	  This while loop can't be written as
> +		for (da = from->mc_list; da; da = da->next)
> +	  da = from->mc_list and __dev_addr_delete can kfree(from->mc_list)
> +	  which could cause a use-after-free of da->next
> +	*/
>   

Seems unnecessary to me, we also don't comment each list_for_each_entry_safe
iteration. I consider the use of a seperate next variable self-explanatory.

From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 1/2] net: Refactor path selection in
 __ip_route_output_key
Date: Wed, 9 Sep 2015 16:56:16 -0600
Message-ID: <55F0B910.2040906@cumulusnetworks.com>
References: <1441835862-41403-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:35388 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751055AbbIIW4S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 18:56:18 -0400
Received: by pacfv12 with SMTP id fv12so23305023pac.2
        for <netdev@vger.kernel.org>; Wed, 09 Sep 2015 15:56:18 -0700 (PDT)
In-Reply-To: <1441835862-41403-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

arg... I goofed the subject line (default is net-next via git config), 
but this one is required for 2/2 so if you want 2/2 for net this one 
should be net as well.


On 9/9/15 3:57 PM, David Ahern wrote:
> VRF device needs same path selection following lookup to set source
> address. Rather than duplicating code, move existing code into a
> function that is exported to modules.
>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
>   include/net/ip_fib.h     |  2 ++
>   net/ipv4/fib_semantics.c | 18 ++++++++++++++++++
>   net/ipv4/route.c         | 13 +------------
>   3 files changed, 21 insertions(+), 12 deletions(-)
>
> diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
> index a37d0432bebd..9d8fe37dacbf 100644
> --- a/include/net/ip_fib.h
> +++ b/include/net/ip_fib.h
> @@ -313,6 +313,8 @@ int fib_sync_down_dev(struct net_device *dev, unsigned long event);
>   int fib_sync_down_addr(struct net *net, __be32 local);
>   int fib_sync_up(struct net_device *dev, unsigned int nh_flags);
>   void fib_select_multipath(struct fib_result *res);
> +void fib_select_path(struct net *net, struct fib_result *res,
> +		     struct flowi4 *fl4);
>
>   /* Exported by fib_trie.c */
>   void fib_trie_init(void);
> diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
> index 064bd3caaa4f..4ca172223ecb 100644
> --- a/net/ipv4/fib_semantics.c
> +++ b/net/ipv4/fib_semantics.c
> @@ -1547,3 +1547,21 @@ void fib_select_multipath(struct fib_result *res)
>   	spin_unlock_bh(&fib_multipath_lock);
>   }
>   #endif
> +
> +void fib_select_path(struct net *net, struct fib_result *res,
> +		     struct flowi4 *fl4)
> +{
> +#ifdef CONFIG_IP_ROUTE_MULTIPATH
> +	if (res->fi->fib_nhs > 1 && fl4->flowi4_oif == 0)
> +		fib_select_multipath(res);
> +	else
> +#endif
> +	if (!res->prefixlen &&
> +	    res->table->tb_num_default > 1 &&
> +	    res->type == RTN_UNICAST && !fl4->flowi4_oif)
> +		fib_select_default(fl4, res);
> +
> +	if (!fl4->saddr)
> +		fl4->saddr = FIB_RES_PREFSRC(net, *res);
> +}
> +EXPORT_SYMBOL(fib_select_path);
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 5f4a5565ad8b..16d62635b484 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -2198,18 +2198,7 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *fl4)
>   		goto make_route;
>   	}
>
> -#ifdef CONFIG_IP_ROUTE_MULTIPATH
> -	if (res.fi->fib_nhs > 1 && fl4->flowi4_oif == 0)
> -		fib_select_multipath(&res);
> -	else
> -#endif
> -	if (!res.prefixlen &&
> -	    res.table->tb_num_default > 1 &&
> -	    res.type == RTN_UNICAST && !fl4->flowi4_oif)
> -		fib_select_default(fl4, &res);
> -
> -	if (!fl4->saddr)
> -		fl4->saddr = FIB_RES_PREFSRC(net, res);
> +	fib_select_path(net, &res, fl4);
>
>   	dev_out = FIB_RES_DEV(res);
>   	fl4->flowi4_oif = dev_out->ifindex;
>

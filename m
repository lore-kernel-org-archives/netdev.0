From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net-next v2] ipv4: fix validate_source for VRF setup
Date: Tue, 31 Oct 2017 11:50:32 -0600
Message-ID: <49a10062-f601-95b6-5e36-986a84098f83@gmail.com>
References: <94ec60b10f8cfea08ec197ef4611c5a6061b96f1.1509455741.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:50257 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932182AbdJaRue (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 13:50:34 -0400
Received: by mail-pf0-f194.google.com with SMTP id b6so14327340pfh.7
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 10:50:34 -0700 (PDT)
In-Reply-To: <94ec60b10f8cfea08ec197ef4611c5a6061b96f1.1509455741.git.pabeni@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/31/17 7:32 AM, Paolo Abeni wrote:
> David reported breakages of VRF scenarios due to the
> commit 6e617de84e87 ("net: avoid a full fib lookup when rp_filter is
> disabled."): the local addresses based test is too strict when VRFs
> are in place.
> 
> With this change we fall-back to a full lookup when custom fib rules
> are in place; so that we address the VRF use case and possibly other
> similar issues in non trivial setups.
> 
> v1 -> v2:
>  - fix build breakage when CONFIG_IP_MULTIPLE_TABLES is not defined,
>    reported by the kbuild test robot
> 
> Reported-by: David Ahern <dsahern@gmail.com>
> Fixes: 6e617de84e87 ("net: avoid a full fib lookup when rp_filter is disabled.")
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> ---
>  net/ipv4/fib_frontend.c | 18 +++++++++++++++---
>  1 file changed, 15 insertions(+), 3 deletions(-)
> 
> diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
> index f02819134ba2..f52d27a422c3 100644
> --- a/net/ipv4/fib_frontend.c
> +++ b/net/ipv4/fib_frontend.c
> @@ -73,6 +73,11 @@ static int __net_init fib4_rules_init(struct net *net)
>  	fib_free_table(main_table);
>  	return -ENOMEM;
>  }
> +
> +static bool fib4_has_custom_rules(struct net *net)
> +{
> +	return false;
> +}
>  #else
>  
>  struct fib_table *fib_new_table(struct net *net, u32 id)
> @@ -128,6 +133,11 @@ struct fib_table *fib_get_table(struct net *net, u32 id)
>  	}
>  	return NULL;
>  }
> +
> +static bool fib4_has_custom_rules(struct net *net)
> +{
> +	return net->ipv4.fib_has_custom_rules;
> +}
>  #endif /* CONFIG_IP_MULTIPLE_TABLES */
>  
>  static void fib_replace_table(struct net *net, struct fib_table *old,
> @@ -405,10 +415,12 @@ int fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst,
>  	    (dev->ifindex != oif || !IN_DEV_TX_REDIRECTS(idev))) {
>  		if (IN_DEV_ACCEPT_LOCAL(idev))
>  			goto ok;
> -		/* if no local routes are added from user space we can check
> -		 * for local addresses looking-up the ifaddr table
> +		/* with custom local routes in place, checking local addresses
> +		 * only will be too optimistic, with custom rules, checking
> +		 * local addresses only can be too strict, e.g. due to vrf
>  		 */
> -		if (net->ipv4.fib_has_custom_local_routes)
> +		if (net->ipv4.fib_has_custom_local_routes ||
> +		    fib4_has_custom_rules(net))
>  			goto full_check;
>  		if (inet_lookup_ifaddr_rcu(net, src))
>  			return -EINVAL;
> 

That seems specific to VRF, but I can't think of a better solution. so,
Acked-by: David Ahern <dsahern@gmail.com>

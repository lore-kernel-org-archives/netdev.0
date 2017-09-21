From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [patch net-next 02/12] ipmr: Add reference count to MFC entries
Date: Thu, 21 Sep 2017 14:56:59 +0300
Message-ID: <54cb367e-3769-ce9f-27dc-e08ee710bd98@cumulusnetworks.com>
References: <20170921064338.1282-1-jiri@resnulli.us>
 <20170921064338.1282-3-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:44486 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751387AbdIUL5C (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 07:57:02 -0400
Received: by mail-wm0-f54.google.com with SMTP id m127so529624wmm.1
        for <netdev@vger.kernel.org>; Thu, 21 Sep 2017 04:57:02 -0700 (PDT)
In-Reply-To: <20170921064338.1282-3-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21/09/17 09:43, Jiri Pirko wrote:
> From: Yotam Gigi <yotamg@mellanox.com>
> 
> Next commits will introduce MFC notifications through the atomic
> fib_notification chain, thus allowing modules to be aware of MFC entries.
> 
> Due to the fact that modules may need to hold a reference to an MFC entry,
> add reference count to MFC entries to prevent them from being freed while
> these modules use them.
> 
> The reference counting is done only on resolved MFC entries currently.
> 
> Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
> Reviewed-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  include/linux/mroute.h | 20 ++++++++++++++++++++
>  net/ipv4/ipmr.c        |  8 +++++---
>  2 files changed, 25 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/mroute.h b/include/linux/mroute.h
> index d7f6333..2f88e3d 100644
> --- a/include/linux/mroute.h
> +++ b/include/linux/mroute.h
> @@ -138,6 +138,7 @@ struct mfc_cache {
>  			unsigned long wrong_if;
>  			unsigned long lastuse;
>  			unsigned char ttls[MAXVIFS];
> +			refcount_t refcount;

There's a struct comment above that has a short description for each entry,
I know it seems redundant, but could you please add one for this ?

>  		} res;
>  	} mfc_un;
>  	struct list_head list;
> @@ -148,4 +149,23 @@ struct rtmsg;
>  int ipmr_get_route(struct net *net, struct sk_buff *skb,
>  		   __be32 saddr, __be32 daddr,
>  		   struct rtmsg *rtm, u32 portid);
> +
> +#ifdef CONFIG_IP_MROUTE
> +void ipmr_cache_free(struct mfc_cache *mfc_cache);
> +#else
> +static inline void ipmr_cache_free(struct mfc_cache *mfc_cache)
> +{
> +}
> +#endif
> +
> +static inline void ipmr_cache_put(struct mfc_cache *c)
> +{
> +	if (refcount_dec_and_test(&c->mfc_un.res.refcount))
> +		ipmr_cache_free(c);
> +}
> +static inline void ipmr_cache_hold(struct mfc_cache *c)
> +{
> +	refcount_inc(&c->mfc_un.res.refcount);
> +}
> +
>  #endif
> diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
> index c9b3e6e..86dc5f9 100644
> --- a/net/ipv4/ipmr.c
> +++ b/net/ipv4/ipmr.c
> @@ -652,10 +652,11 @@ static void ipmr_cache_free_rcu(struct rcu_head *head)
>  	kmem_cache_free(mrt_cachep, c);
>  }
>  
> -static inline void ipmr_cache_free(struct mfc_cache *c)
> +void ipmr_cache_free(struct mfc_cache *c)
>  {
>  	call_rcu(&c->rcu, ipmr_cache_free_rcu);
>  }
> +EXPORT_SYMBOL(ipmr_cache_free);
>  
>  /* Destroy an unresolved cache entry, killing queued skbs
>   * and reporting error to netlink readers.
> @@ -949,6 +950,7 @@ static struct mfc_cache *ipmr_cache_alloc(void)
>  	if (c) {
>  		c->mfc_un.res.last_assert = jiffies - MFC_ASSERT_THRESH - 1;
>  		c->mfc_un.res.minvif = MAXVIFS;
> +		refcount_set(&c->mfc_un.res.refcount, 1);
>  	}
>  	return c;
>  }
> @@ -1162,7 +1164,7 @@ static int ipmr_mfc_delete(struct mr_table *mrt, struct mfcctl *mfc, int parent)
>  	rhltable_remove(&mrt->mfc_hash, &c->mnode, ipmr_rht_params);
>  	list_del_rcu(&c->list);
>  	mroute_netlink_event(mrt, c, RTM_DELROUTE);
> -	ipmr_cache_free(c);
> +	ipmr_cache_put(c);
>  
>  	return 0;
>  }
> @@ -1264,7 +1266,7 @@ static void mroute_clean_tables(struct mr_table *mrt, bool all)
>  		rhltable_remove(&mrt->mfc_hash, &c->mnode, ipmr_rht_params);
>  		list_del_rcu(&c->list);
>  		mroute_netlink_event(mrt, c, RTM_DELROUTE);
> -		ipmr_cache_free(c);
> +		ipmr_cache_put(c);
>  	}
>  
>  	if (atomic_read(&mrt->cache_resolve_queue_len) != 0) {
> 

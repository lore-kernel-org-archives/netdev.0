From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next] dst: no need to take reference on DST_NOCACHE
 dsts
Date: Sun, 7 Dec 2014 21:20:34 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1412072040250.1885@ja.home.ssi.bg>
References: <51b54bc66109594459e1a08c9022c5c48f20d910.1417889528.git.hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:37373 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753268AbaLGTVB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Dec 2014 14:21:01 -0500
In-Reply-To: <51b54bc66109594459e1a08c9022c5c48f20d910.1417889528.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Sat, 6 Dec 2014, Hannes Frederic Sowa wrote:

> Since commit f8864972126899 ("ipv4: fix dst race in sk_dst_get()")
> DST_NOCACHE dst_entries get freed by RCU. So there is no need to get a
> reference on them when we are in rcu protected sections.
> 
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Julian Anastasov <ja@ssi.bg>

	Looks ok to me,

Reviewed-by: Julian Anastasov <ja@ssi.bg>

	For IPVS we still call dst_release from
RCU callback ip_vs_dest_dst_rcu_free(). May be I have to
create separate patch to move dst_release() from
ip_vs_dest_dst_rcu_free() to __ip_vs_dst_cache_reset() and
__ip_vs_dst_set() to avoid second callback step.

> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
>  include/linux/skbuff.h          | 23 ++---------------------
>  net/core/dst.c                  | 24 ------------------------
>  net/netfilter/ipvs/ip_vs_xmit.c |  4 ++--
>  3 files changed, 4 insertions(+), 47 deletions(-)
> 
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 7691ad5..70ebc79 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -718,9 +718,6 @@ static inline void skb_dst_set(struct sk_buff *skb, struct dst_entry *dst)
>  	skb->_skb_refdst = (unsigned long)dst;
>  }
>  
> -void __skb_dst_set_noref(struct sk_buff *skb, struct dst_entry *dst,
> -			 bool force);
> -
>  /**
>   * skb_dst_set_noref - sets skb dst, hopefully, without taking reference
>   * @skb: buffer
> @@ -733,24 +730,8 @@ void __skb_dst_set_noref(struct sk_buff *skb, struct dst_entry *dst,
>   */
>  static inline void skb_dst_set_noref(struct sk_buff *skb, struct dst_entry *dst)
>  {
> -	__skb_dst_set_noref(skb, dst, false);
> -}
> -
> -/**
> - * skb_dst_set_noref_force - sets skb dst, without taking reference
> - * @skb: buffer
> - * @dst: dst entry
> - *
> - * Sets skb dst, assuming a reference was not taken on dst.
> - * No reference is taken and no dst_release will be called. While for
> - * cached dsts deferred reclaim is a basic feature, for entries that are
> - * not cached it is caller's job to guarantee that last dst_release for
> - * provided dst happens when nobody uses it, eg. after a RCU grace period.
> - */
> -static inline void skb_dst_set_noref_force(struct sk_buff *skb,
> -					   struct dst_entry *dst)
> -{
> -	__skb_dst_set_noref(skb, dst, true);
> +	WARN_ON(!rcu_read_lock_held() && !rcu_read_lock_bh_held());
> +	skb->_skb_refdst = (unsigned long)dst | SKB_DST_NOREF;
>  }
>  
>  /**
> diff --git a/net/core/dst.c b/net/core/dst.c
> index a028409..e956ce6 100644
> --- a/net/core/dst.c
> +++ b/net/core/dst.c
> @@ -327,30 +327,6 @@ void __dst_destroy_metrics_generic(struct dst_entry *dst, unsigned long old)
>  }
>  EXPORT_SYMBOL(__dst_destroy_metrics_generic);
>  
> -/**
> - * __skb_dst_set_noref - sets skb dst, without a reference
> - * @skb: buffer
> - * @dst: dst entry
> - * @force: if force is set, use noref version even for DST_NOCACHE entries
> - *
> - * Sets skb dst, assuming a reference was not taken on dst
> - * skb_dst_drop() should not dst_release() this dst
> - */
> -void __skb_dst_set_noref(struct sk_buff *skb, struct dst_entry *dst, bool force)
> -{
> -	WARN_ON(!rcu_read_lock_held() && !rcu_read_lock_bh_held());
> -	/* If dst not in cache, we must take a reference, because
> -	 * dst_release() will destroy dst as soon as its refcount becomes zero
> -	 */
> -	if (unlikely((dst->flags & DST_NOCACHE) && !force)) {
> -		dst_hold(dst);
> -		skb_dst_set(skb, dst);
> -	} else {
> -		skb->_skb_refdst = (unsigned long)dst | SKB_DST_NOREF;
> -	}
> -}
> -EXPORT_SYMBOL(__skb_dst_set_noref);
> -
>  /* Dirty hack. We did it in 2.2 (in __dst_free),
>   * we have _very_ good reasons not to repeat
>   * this mistake in 2.3, but we have no choice
> diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
> index 1f93313..3aedbda 100644
> --- a/net/netfilter/ipvs/ip_vs_xmit.c
> +++ b/net/netfilter/ipvs/ip_vs_xmit.c
> @@ -343,7 +343,7 @@ __ip_vs_get_out_rt(int skb_af, struct sk_buff *skb, struct ip_vs_dest *dest,
>  	skb_dst_drop(skb);
>  	if (noref) {
>  		if (!local)
> -			skb_dst_set_noref_force(skb, &rt->dst);
> +			skb_dst_set_noref(skb, &rt->dst);
>  		else
>  			skb_dst_set(skb, dst_clone(&rt->dst));
>  	} else
> @@ -487,7 +487,7 @@ __ip_vs_get_out_rt_v6(int skb_af, struct sk_buff *skb, struct ip_vs_dest *dest,
>  	skb_dst_drop(skb);
>  	if (noref) {
>  		if (!local)
> -			skb_dst_set_noref_force(skb, &rt->dst);
> +			skb_dst_set_noref(skb, &rt->dst);
>  		else
>  			skb_dst_set(skb, dst_clone(&rt->dst));
>  	} else
> -- 
> 1.9.3

Regards

--
Julian Anastasov <ja@ssi.bg>

From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [NET] ROUTE: fix rcu_dereference() uses in /proc/net/rt_cache
Date: Fri, 11 Jan 2008 00:10:42 +0100
Message-ID: <20080110231042.GA3199@ami.dom.local>
References: <20080109113727.50eae500.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	davem@davemloft.net, dipankar@in.ibm.com, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:33695 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752564AbYAJXHB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2008 18:07:01 -0500
Received: by ug-out-1314.google.com with SMTP id z38so385152ugc.16
        for <netdev@vger.kernel.org>; Thu, 10 Jan 2008 15:07:00 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080109113727.50eae500.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote, On 01/09/2008 11:37 AM:
...
> [NET] ROUTE: fix rcu_dereference() uses in /proc/net/rt_cache
...
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index d337706..28484f3 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -283,12 +283,12 @@ static struct rtable *rt_cache_get_first(struct seq_file *seq)
>  			break;
>  		rcu_read_unlock_bh();
>  	}
> -	return r;
> +	return rcu_dereference(r);
>  }
>  
>  static struct rtable *rt_cache_get_next(struct seq_file *seq, struct rtable *r)
>  {
> -	struct rt_cache_iter_state *st = rcu_dereference(seq->private);
> +	struct rt_cache_iter_state *st = seq->private;
>  
>  	r = r->u.dst.rt_next;
>  	while (!r) {
> @@ -298,7 +298,7 @@ static struct rtable *rt_cache_get_next(struct seq_file *seq, struct rtable *r)
>  		rcu_read_lock_bh();
>  		r = rt_hash_table[st->bucket].chain;
>  	}
> -	return r;
> +	return rcu_dereference(r);
>  }

It seems this optimization could've a side effect: if during such a
loop updates are done, and r is seen !NULL during while() check, but
NULL after rcu_dereference(), the listing/counting could stop too
soon. So, IMHO, probably the first version of this patch is more
reliable. (Or alternatively additional check is needed before return.)

Regards,
Jarek P.

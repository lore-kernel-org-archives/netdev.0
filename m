From: David Miller <davem@davemloft.net>
Subject: Re: [IPV4] ROUTE: Avoid sparse warnings
Date: Mon, 07 Jan 2008 22:54:17 -0800 (PST)
Message-ID: <20080107.225417.119463845.davem@davemloft.net>
References: <20080107120117.aeebd0c8.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47424
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754532AbYAHGyR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 01:54:17 -0500
In-Reply-To: <20080107120117.aeebd0c8.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Mon, 7 Jan 2008 12:01:17 +0100

>   CHECK   net/ipv4/route.c
> net/ipv4/route.c:298:2: warning: context imbalance in 'rt_cache_get_first' - wrong count at exit
> net/ipv4/route.c:307:3: warning: context imbalance in 'rt_cache_get_next' - unexpected unlock
> net/ipv4/route.c:346:3: warning: context imbalance in 'rt_cache_seq_stop' - unexpected unlock
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> 
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 10915bb..fec0571 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -289,11 +289,11 @@ static struct rtable *rt_cache_get_first(struct seq_file *seq)
>  	struct rt_cache_iter_state *st = seq->private;
>  
>  	for (st->bucket = rt_hash_mask; st->bucket >= 0; --st->bucket) {
> -		rcu_read_lock_bh();
>  		r = rt_hash_table[st->bucket].chain;
>  		if (r)
>  			break;
>  		rcu_read_unlock_bh();
> +		rcu_read_lock_bh();
>  	}
>  	return r;
>  }

Like for Herbert, this patch leaves a bad taste in my mouth.

I don't understand, is it the case that sparse doesn't like
that rt_cache_get_first() returns with rcu_read_lock_bh()
held?  That's kind of rediculious.

Furthermore, these:

	rcu_read_unlock_bh()
	rcu_read_lock_bh()

sequences are at best funny looking.  For other lock types we would
look at this and ask "Does this even accomplish anything reliably?"

The answer here is that it wants the preempt_enable() to run to get
any potential kernel preemptions executed.  It also allows any
pending software interrupts to run.

So this does something reliably only because rcu_read_unlock_bh() has
specific and explicit side effects.

I don't know, to me it just looks awful :-)  I better understood the
original code.

We can continue splitting hairs over this but I'll hold off on this
patch for now. :)

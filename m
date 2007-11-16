From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] IPV4 : Move ip route cache flush (secret_rebuild) from softirq to workqueue
Date: Fri, 16 Nov 2007 11:50:01 -0800
Message-ID: <20071116194959.GE8971@verge.net.au>
References: <20071116174027.726e6eca.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:39774 "EHLO koto.vergenet.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754521AbXKPTuI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Nov 2007 14:50:08 -0500
Content-Disposition: inline
In-Reply-To: <20071116174027.726e6eca.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 16, 2007 at 05:40:27PM +0100, Eric Dumazet wrote:
> Hello David
> 
> This patch against net-2.6.25 is another step to get a more resistant ip route cache.
> 
> Thank you
> 
> [PATCH] IPV4 : Move ip route cache flush (secret_rebuild) from softirq to workqueue
> 
> Every 600 seconds (ip_rt_secret_interval), a softirq flush of the whole
> ip route cache is triggered. On loaded machines, this can starve softirq for
> many seconds and can eventually crash.
> 
> This patch moves this flush to a workqueue context, using the worker we
> intoduced in commit 39c90ece7565f5c47110c2fa77409d7a9478bd5b
> (IPV4: Convert rt_check_expire() from softirq processing to workqueue.)
> 
> Also, immediate flushes (echo 0 >/proc/sys/net/ipv4/route/flush) are using
> rt_do_flush() helper function, wich take attention to rescheduling.
> 
> Next step will be to handle delayed flushes 
> ("echo -1 >/proc/sys/net/ipv4/route/flush"  or
> "ip route flush cache")
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> 
>  net/ipv4/route.c |   89 ++++++++++++++++++++++++++++++++-------------
>  1 file changed, 65 insertions(+), 24 deletions(-)
> 
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 856807c..5d74620 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -133,13 +133,14 @@ static int ip_rt_mtu_expires		= 10 * 60 * HZ;
>  static int ip_rt_min_pmtu		= 512 + 20 + 20;
>  static int ip_rt_min_advmss		= 256;
>  static int ip_rt_secret_interval	= 10 * 60 * HZ;
> +static int ip_rt_flush_expected;
>  static unsigned long rt_deadline;
>  
>  #define RTprint(a...)	printk(KERN_DEBUG a)
>  
>  static struct timer_list rt_flush_timer;
> -static void rt_check_expire(struct work_struct *work);
> -static DECLARE_DELAYED_WORK(expires_work, rt_check_expire);
> +static void rt_worker_func(struct work_struct *work);
> +static DECLARE_DELAYED_WORK(expires_work, rt_worker_func);
>  static struct timer_list rt_secret_timer;
>  
>  /*
> @@ -561,7 +562,42 @@ static inline int compare_keys(struct flowi *fl1, struct flowi *fl2)
>  		(fl1->iif ^ fl2->iif)) == 0;
>  }
>  
> -static void rt_check_expire(struct work_struct *work)
> +/*
> + * Perform a full scan of hash table and free all entries.
> + * Can be called by a softirq or a process.
> + * In the later case, we want to be reschedule if necessary
> + */
> +static void rt_do_flush(int process_context)
> +{
> +	unsigned int i;
> +	struct rtable *rth, *next;
> +	unsigned long fake = 0, *flag_ptr;
> +
> +	flag_ptr = process_context ? &current_thread_info()->flags : &fake;
> +
> +	for (i = 0; i <= rt_hash_mask; i++) {
> +		rth = rt_hash_table[i].chain;
> +		if (rth) {
> +			spin_lock_bh(rt_hash_lock_addr(i));
> +			rth = rt_hash_table[i].chain;
> +			rt_hash_table[i].chain = NULL;
> +			spin_unlock_bh(rt_hash_lock_addr(i));
> +		}
> +		/*
> +		 * This is a fast version of :
> +		 * if (process_context && need_resched())
> +		 */
> +		if (unlikely(test_bit(TIF_NEED_RESCHED, flag_ptr)))
> +			cond_resched();
> +
> +		for (; rth; rth = next) {
> +			next = rth->u.dst.rt_next;
> +			rt_free(rth);
> +		}
> +	}
> +}

Is it ever neccessary to call cond_resched() if rt_hash_table[i].chain
is NULL? If not, the following looks cleaner to my eyes:

	for (i = 0; i <= rt_hash_mask; i++) {
		rth = rt_hash_table[i].chain;
		if (!rth)
			continue;

		spin_lock_bh(rt_hash_lock_addr(i));
		rth = rt_hash_table[i].chain;
		rt_hash_table[i].chain = NULL;
		spin_unlock_bh(rt_hash_lock_addr(i));

		...

-- 
Horms, California Edition


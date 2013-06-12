From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 06/12] sched: add cond_resched_rcu() helper
Date: Wed, 12 Jun 2013 08:50:08 -0700
Message-ID: <20130612155008.GY5146@linux.vnet.ibm.com>
References: <1370464832-4216-1-git-send-email-pablo@netfilter.org>
 <1370464832-4216-7-git-send-email-pablo@netfilter.org>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1370464832-4216-7-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 05, 2013 at 10:40:27PM +0200, Pablo Neira Ayuso wrote:
> From: Simon Horman <horms@verge.net.au>
> 
> This is intended for use in loops which read data protected by RCU and may
> have a large number of iterations.  Such an example is dumping the list of
> connections known to IPVS: ip_vs_conn_array() and ip_vs_conn_seq_next().
> 
> The benefits are for CONFIG_PREEMPT_RCU=y where we save CPU cycles
> by moving rcu_read_lock and rcu_read_unlock out of large loops
> but still allowing the current task to be preempted after every
> loop iteration for the CONFIG_PREEMPT_RCU=n case.
> 
> The call to cond_resched() is not needed when CONFIG_PREEMPT_RCU=y.
> Thanks to Paul E. McKenney for explaining this and for the
> final version that checks the context with CONFIG_DEBUG_ATOMIC_SLEEP=y
> for all possible configurations.
> 
> The function can be empty in the CONFIG_PREEMPT_RCU case,
> rcu_read_lock and rcu_read_unlock are not needed in this case
> because the task can be preempted on indication from scheduler.
> Thanks to Peter Zijlstra for catching this and for his help
> in trying a solution that changes __might_sleep.
> 
> Initial cond_resched_rcu_lock() function suggested by Eric Dumazet.
> 
> Tested-by: Julian Anastasov <ja@ssi.bg>
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> Signed-off-by: Simon Horman <horms@verge.net.au>
> Acked-by: Peter Zijlstra <peterz@infradead.org>
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>

Reviewed-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

> ---
>  include/linux/sched.h |    9 +++++++++
>  1 file changed, 9 insertions(+)
> 
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index 178a8d9..4ff8da1 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -2444,6 +2444,15 @@ extern int __cond_resched_softirq(void);
>  	__cond_resched_softirq();					\
>  })
> 
> +static inline void cond_resched_rcu(void)
> +{
> +#if defined(CONFIG_DEBUG_ATOMIC_SLEEP) || !defined(CONFIG_PREEMPT_RCU)
> +	rcu_read_unlock();
> +	cond_resched();
> +	rcu_read_lock();
> +#endif
> +}
> +
>  /*
>   * Does a critical section need to be broken due to another
>   * task waiting?: (technically does not depend on CONFIG_PREEMPT,
> -- 
> 1.7.10.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


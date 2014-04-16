From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] softirq: a single rcu_bh_qs() call is enough
Date: Wed, 16 Apr 2014 15:51:10 -0700
Message-ID: <20140416225110.GE4496@linux.vnet.ibm.com>
References: <1397664384.4222.124.camel@edumazet-glaptop2.roam.corp.google.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1397664384.4222.124.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 16, 2014 at 09:06:24AM -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> Calling rcu_bh_qs() after every softirq action is not really needed.
> 
> What RCU needs is at least one rcu_bh_qs() per softirq round to note a
> quiescent state was passed for rcu_bh
> 
> Note for Paul and myself : this could be inlined as a single instruction
> and avoid smp_processor_id()
> (sone this_cpu_write(rcu_bh_data.passed_quiesce, 1))
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Looks plausible -- will give it a go!  If nothing breaks, queued for
3.16.

							Thanx, Paul

> ---
>  kernel/softirq.c |    4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
> 
> diff --git a/kernel/softirq.c b/kernel/softirq.c
> index b50990a5bea0..b9b2d4906848 100644
> --- a/kernel/softirq.c
> +++ b/kernel/softirq.c
> @@ -232,7 +232,6 @@ asmlinkage void __do_softirq(void)
>  	bool in_hardirq;
>  	__u32 pending;
>  	int softirq_bit;
> -	int cpu;
> 
>  	/*
>  	 * Mask out PF_MEMALLOC s current task context is borrowed for the
> @@ -247,7 +246,6 @@ asmlinkage void __do_softirq(void)
>  	__local_bh_disable_ip(_RET_IP_, SOFTIRQ_OFFSET);
>  	in_hardirq = lockdep_softirq_start();
> 
> -	cpu = smp_processor_id();
>  restart:
>  	/* Reset the pending bitmask before enabling irqs */
>  	set_softirq_pending(0);
> @@ -276,11 +274,11 @@ restart:
>  			       prev_count, preempt_count());
>  			preempt_count_set(prev_count);
>  		}
> -		rcu_bh_qs(cpu);
>  		h++;
>  		pending >>= softirq_bit;
>  	}
> 
> +	rcu_bh_qs(smp_processor_id());
>  	local_irq_disable();
> 
>  	pending = local_softirq_pending();
> 
> 

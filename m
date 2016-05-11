From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC PATCH 0/2] net: threadable napi poll loop
Date: Wed, 11 May 2016 08:55:27 +0200
Message-ID: <20160511065527.GD3193@twins.programming.kicks-ass.net>
References: <cover.1462886866.git.pabeni@redhat.com>
 <1462890590.23934.68.camel@edumazet-glaptop3.roam.corp.google.com>
 <90f3db8c-c30c-b204-576a-454939ac93ce@stressinduktion.org>
 <CANn89i+YKrVOgfFwW-2psfCzq5_YLdmbV06-H-1FCOwXdMBuzQ@mail.gmail.com>
 <94f323a9-515e-4d75-cac8-ef0214f0499e@stressinduktion.org>
 <1462920697.23934.113.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <edumazet@google.com>,
	Paolo Abeni <pabeni@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jiri@mellanox.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Alexander Duyck <aduyck@mirantis.com>,
	Tom Herbert <tom@herbertland.com>,
	Ingo Molnar <mingo@kernel.org>, Rik van Riel <riel@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1462920697.23934.113.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 10, 2016 at 03:51:37PM -0700, Eric Dumazet wrote:
> diff --git a/kernel/softirq.c b/kernel/softirq.c
> index 17caf4b63342..22463217e3cf 100644
> --- a/kernel/softirq.c
> +++ b/kernel/softirq.c
> @@ -56,6 +56,7 @@ EXPORT_SYMBOL(irq_stat);
>  static struct softirq_action softirq_vec[NR_SOFTIRQS] __cacheline_aligned_in_smp;
>  
>  DEFINE_PER_CPU(struct task_struct *, ksoftirqd);
> +DEFINE_PER_CPU(bool, ksoftirqd_scheduled);
>  
>  const char * const softirq_to_name[NR_SOFTIRQS] = {
>  	"HI", "TIMER", "NET_TX", "NET_RX", "BLOCK", "BLOCK_IOPOLL",
> @@ -73,8 +74,10 @@ static void wakeup_softirqd(void)
>  	/* Interrupts are disabled: no need to stop preemption */
>  	struct task_struct *tsk = __this_cpu_read(ksoftirqd);
>  
> -	if (tsk && tsk->state != TASK_RUNNING)
> +	if (tsk && tsk->state != TASK_RUNNING) {
> +		__this_cpu_write(ksoftirqd_scheduled, true);
>  		wake_up_process(tsk);

Since we're already looking at tsk->state, and the wake_up_process()
ensures the thing becomes TASK_RUNNING, you could add:

static inline bool ksoftirqd_running(void)
{
	return __this_cpu_read(ksoftirqd)->state == TASK_RUNNING;
}

> +	}
>  }
>  
>  /*
> @@ -162,7 +165,9 @@ void __local_bh_enable_ip(unsigned long ip, unsigned int cnt)
>  	 */
>  	preempt_count_sub(cnt - 1);
>  
> -	if (unlikely(!in_interrupt() && local_softirq_pending())) {
> +	if (unlikely(!in_interrupt() &&
> +		     local_softirq_pending() &&
> +		     !__this_cpu_read(ksoftirqd_scheduled))) {

And use it here,

>  		/*
>  		 * Run softirq if any pending. And do it in its own stack
>  		 * as we may be calling this deep in a task call stack already.
> @@ -340,6 +345,9 @@ void irq_enter(void)
>  
>  static inline void invoke_softirq(void)
>  {
> +	if (__this_cpu_read(ksoftirqd_scheduled))

and here.

> +		return;
> +
>  	if (!force_irqthreads) {
>  #ifdef CONFIG_HAVE_IRQ_EXIT_ON_IRQ_STACK
>  		/*
> @@ -660,6 +668,8 @@ static void run_ksoftirqd(unsigned int cpu)
>  		 * in the task stack here.
>  		 */
>  		__do_softirq();
> +		if (!local_softirq_pending())
> +			__this_cpu_write(ksoftirqd_scheduled, false);

And avoid twiddling the new variable which only seems to mirror
tsk->state.

>  		local_irq_enable();
>  		cond_resched_rcu_qs();
>  		return;
> 
> 

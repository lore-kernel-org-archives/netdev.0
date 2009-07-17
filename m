From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: [patch 1/3] net: serialize hrtimer callback in sched_cbq
Date: Fri, 17 Jul 2009 15:26:29 +0200
Message-ID: <4A607C05.2080407@hartkopp.net>
References: <20090709215606.526259917@linutronix.de>	 <20090712.135555.207096388.davem@davemloft.net>	 <alpine.LFD.2.00.0907141040350.2777@localhost.localdomain>	 <20090714.090055.56906831.davem@davemloft.net>	 <1247588890.7500.186.camel@twins>	 <alpine.LFD.2.01.0907140940440.13838@localhost.localdomain> <1247832892.15751.35.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>, tglx@linutronix.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kaber@trash.net
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:40119 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934500AbZGQN0i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2009 09:26:38 -0400
In-Reply-To: <1247832892.15751.35.camel@twins>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Peter Zijlstra wrote:
> On Tue, 2009-07-14 at 09:42 -0700, Linus Torvalds wrote:
>> On Tue, 14 Jul 2009, Peter Zijlstra wrote:
>>> Linus really hated the softirq mode, which is what prompted me to change
>>> that.
>>>
>>> Now, it might be he only hated the particular interface and the
>>> resulting code, but I think to remember he simply thought the whole
>>> thing daft.
>> Yes. And I hated the bugs it had. 
>>
>> Don't make something as core as timers any more complicated. Don't take 
>> locks in timers and then complain about deadlocks. If your locking is 
>> broken, don't make the core timers be idiotically broken.
>>
>> Because it was. The code was a total mess to follow, and had bugs.
> 
> How would something like the below work for people?

Would be fine to me.

It reduces the duplicated code as well as private structs for hrtimers &
tasklets. And finally your suggestion preserves the proper separation of the
hrtimers and the tasklets that are used as underlying concepts.

Regards,
Oliver (who wrote net/can/bcm.c)


> 
> ---
>  include/linux/hrtimer.h |   22 ++++++++++++++++++++--
>  kernel/hrtimer.c        |   23 ++++++++++++++++++++++-
>  2 files changed, 42 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/hrtimer.h b/include/linux/hrtimer.h
> index 4759917..e7559fe 100644
> --- a/include/linux/hrtimer.h
> +++ b/include/linux/hrtimer.h
> @@ -22,6 +22,7 @@
>  #include <linux/wait.h>
>  #include <linux/percpu.h>
>  #include <linux/timer.h>
> +#include <linux/interrupt.h>
>  
>  
>  struct hrtimer_clock_base;
> @@ -91,7 +92,6 @@ enum hrtimer_restart {
>   * @function:	timer expiry callback function
>   * @base:	pointer to the timer base (per cpu and per clock)
>   * @state:	state information (See bit values above)
> - * @cb_entry:	list head to enqueue an expired timer into the callback list
>   * @start_site:	timer statistics field to store the site where the timer
>   *		was started
>   * @start_comm: timer statistics field to store the name of the process which
> @@ -108,7 +108,6 @@ struct hrtimer {
>  	enum hrtimer_restart		(*function)(struct hrtimer *);
>  	struct hrtimer_clock_base	*base;
>  	unsigned long			state;
> -	struct list_head		cb_entry;
>  #ifdef CONFIG_TIMER_STATS
>  	int				start_pid;
>  	void				*start_site;
> @@ -116,6 +115,12 @@ struct hrtimer {
>  #endif
>  };
>  
> +struct hrtimer_softirq {
> +	struct hrtimer		timer;
> +	struct tasklet_struct	tasklet;
> +	enum hrtimer_restart	(*function)(struct hrtimer *);
> +};
> +
>  /**
>   * struct hrtimer_sleeper - simple sleeper structure
>   * @timer:	embedded timer structure
> @@ -335,6 +340,19 @@ static inline void hrtimer_init_on_stack(struct hrtimer *timer,
>  static inline void destroy_hrtimer_on_stack(struct hrtimer *timer) { }
>  #endif
>  
> +enum hrtimer_restart __hrtimer_softirq_trampoline(struct hrtimer *timer);
> +void __hrtimer_tasklet_trampoline(unsigned long data);
> +
> +static inline void hrtimer_softirq_init(struct hrtimer_softirq *stimer,
> +		enum hrtimer_restart (*func)(struct hrtimer *),
> +		clockid_t which_clock, enum hrtimer_mode mode)
> +{
> +	hrtimer_init(&stimer->timer, which_clock, mode);
> +	stimer->timer.function = __hrtimer_softirq_trampoline;
> +	tasklet_init(&stimer->tasklet, __hrtimer_tasklet_trampoline, stimer);
> +	stimer->function = func;
> +}
> +
>  /* Basic timer operations: */
>  extern int hrtimer_start(struct hrtimer *timer, ktime_t tim,
>  			 const enum hrtimer_mode mode);
> diff --git a/kernel/hrtimer.c b/kernel/hrtimer.c
> index ab5eb70..dae063c 100644
> --- a/kernel/hrtimer.c
> +++ b/kernel/hrtimer.c
> @@ -1098,7 +1098,6 @@ static void __hrtimer_init(struct hrtimer *timer, clockid_t clock_id,
>  		clock_id = CLOCK_MONOTONIC;
>  
>  	timer->base = &cpu_base->clock_base[clock_id];
> -	INIT_LIST_HEAD(&timer->cb_entry);
>  	hrtimer_init_timer_hres(timer);
>  
>  #ifdef CONFIG_TIMER_STATS
> @@ -1141,6 +1140,28 @@ int hrtimer_get_res(const clockid_t which_clock, struct timespec *tp)
>  }
>  EXPORT_SYMBOL_GPL(hrtimer_get_res);
>  
> +enum hrtimer_restart __hrtimer_softirq_trampoline(struct hrtimer *timer)
> +{
> +	struct hrtimer_softirq *stimer =
> +		container_of(timer, struct hrtimer_softirq, timer);
> +
> +	tasklet_hi_schedule(&timer->tasklet);
> +
> +	return HRTIMER_NORESTART;
> +}
> +EXPORT_SYMBOL_GPL(__hrtimer_softirq_trampoline);
> +
> +void __hrtimer_tasklet_trampoline(unsigned long data)
> +{
> +	struct hrtimer_softirq *stimer = (void *)data;
> +	enum hrtimer_restart restart;
> +
> +	restart = stimer->function(&stimer->timer);
> +	if (restart != HRTIMER_NORESTART)
> +		hrtimer_restart(&stimer->timer);
> +}
> +EXPORT_SYMBOL_GPL(__hrtimer_tasklet_trampoline);
> +
>  static void __run_hrtimer(struct hrtimer *timer)
>  {
>  	struct hrtimer_clock_base *base = timer->base;
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


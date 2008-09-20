From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2]: softirq: Add support for triggering softirq work
 on softirqs.
Date: Sat, 20 Sep 2008 00:46:08 -0700
Message-ID: <20080920004608.a3123052.akpm@linux-foundation.org>
References: <20080919.234832.127229997.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com, steffen.klassert@secunet.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:47696 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750867AbYITHrT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2008 03:47:19 -0400
In-Reply-To: <20080919.234832.127229997.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 19 Sep 2008 23:48:32 -0700 (PDT) David Miller <davem@davemloft.net> wrote:

> 
> softirq: Add support for triggering softirq work on softirqs.
> 
> This is basically a genericization of Jens Axboe's block layer
> remote softirq changes.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> Signed-off-by: Jens Axboe <jens.axboe@oracle.com>
> ---
>  include/linux/interrupt.h |    6 ++-
>  kernel/softirq.c          |  103 +++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 108 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/interrupt.h b/include/linux/interrupt.h
> index fdd7b90..91ca3ac 100644
> --- a/include/linux/interrupt.h
> +++ b/include/linux/interrupt.h
> @@ -11,6 +11,8 @@
>  #include <linux/hardirq.h>
>  #include <linux/sched.h>
>  #include <linux/irqflags.h>
> +#include <linux/smp.h>
> +#include <linux/percpu.h>
>  #include <asm/atomic.h>
>  #include <asm/ptrace.h>
>  #include <asm/system.h>
> @@ -271,7 +273,9 @@ extern void softirq_init(void);
>  #define __raise_softirq_irqoff(nr) do { or_softirq_pending(1UL << (nr)); } while (0)
>  extern void raise_softirq_irqoff(unsigned int nr);
>  extern void raise_softirq(unsigned int nr);
> -
> +DECLARE_PER_CPU(struct list_head, softirq_work_list[NR_SOFTIRQ]);
> +extern void __send_remote_softirq(struct call_single_data *cp, int cpu, int this_cpu, int softirq);
> +extern void send_remote_softirq(struct call_single_data *cp, int cpu, int softirq);
>  
>  /* Tasklets --- multithreaded analogue of BHs.
>  
> diff --git a/kernel/softirq.c b/kernel/softirq.c
> index 27642a2..9c0723d 100644
> --- a/kernel/softirq.c
> +++ b/kernel/softirq.c
> @@ -6,6 +6,8 @@
>   *	Distribute under GPLv2.
>   *
>   *	Rewritten. Old one was good in 2.2, but in 2.3 it was immoral. --ANK (990903)
> + *
> + *	Remote softirq infrastructure is by Jens Axboe.
>   */
>  
>  #include <linux/module.h>
> @@ -463,17 +465,118 @@ void tasklet_kill(struct tasklet_struct *t)
>  
>  EXPORT_SYMBOL(tasklet_kill);
>  
> +DEFINE_PER_CPU(struct list_head, softirq_work_list[NR_SOFTIRQ]);
> +
> +static void __local_trigger(struct call_single_data *cp, int softirq)
> +{
> +	struct list_head *head = &__get_cpu_var(softirq_work_list[softirq]);
> +
> +	list_add_tail(&cp->list, head);
> +	if (head->next == &cp->list)

Took a little staring to work out what that test is doing.  Adding

	/* If the list was previouly empty, trigger a softirq run */

would be nice.

> +		raise_softirq_irqoff(softirq);
> +}
> +
> +#if defined(CONFIG_SMP) && defined(CONFIG_USE_GENERIC_SMP_HELPERS)

CONFIG_USE_GENERIC_SMP_HELPERS=y, CONFIG_SMP=n shouldn't be possible,
if we care..

> +static void remote_softirq_receive(void *data)
> +{
> +	struct call_single_data *cp = data;
> +	unsigned long flags;
> +	int softirq;
> +
> +	softirq = cp->flags >> 16;

OK, now what's going on with call_single_data.flags?

After a bit of grepping around it seems that it's a bitfield consisting
of the undocumented CSD_FLAG_WAIT and/or CSD_FLAG_ALLOC, which are
(somewhat strangely) private to kernel/smp.c.

IOW: some comments describing call_single_data.flags are somewhat
needed.  That documentation should include the locking rules, which
afaict are "local to this CPU, with local interrupts disabled".

Seems from the above `>> 16' you're stuffing the softirq ID into the
upper 16 bits of call_single_data.flags.  Is it needed?  Another u32
can be added to call_single_data for free on 64-bit, or it could be
split into two u16's.

Otherwise I'd suggest that local variable `softirq' here be changed to
`unsigned int', to match call_single_data.flags.

> +	local_irq_save(flags);
> +	__local_trigger(cp, softirq);
> +	local_irq_restore(flags);
> +}
> +
> +static int __try_remote_softirq(struct call_single_data *cp, int cpu, int softirq)
> +{
> +	if (cpu_online(cpu)) {

Is locking needed to keep that CPU online after this test?

> +		cp->func = remote_softirq_receive;
> +		cp->info = cp;
> +		cp->flags = softirq << 16;
> +		__smp_call_function_single(cpu, cp);
> +		return 0;
> +	}
> +	return 1;
> +}
> +#else /* CONFIG_SMP && CONFIG_USE_GENERIC_SMP_HELPERS */
> +static int __try_remote_softirq(struct call_single_data *cp, int cpu, int softirq)
> +{
> +	return 1;
> +}
> +#endif
> +
> +void __send_remote_softirq(struct call_single_data *cp, int cpu, int this_cpu, int softirq)
> +{
> +	if (cpu == this_cpu || __try_remote_softirq(cp, cpu, softirq))
> +		__local_trigger(cp, softirq);
> +}
> +EXPORT_SYMBOL(__send_remote_softirq);
> +
> +void send_remote_softirq(struct call_single_data *cp, int cpu, int softirq)
> +{
> +	unsigned long flags;
> +	int this_cpu;
> +
> +	local_irq_save(flags);
> +	this_cpu = smp_processor_id();
> +	__send_remote_softirq(cp, cpu, this_cpu, softirq);

Ah.  So it is required that the __send_remote_softirq() caller disable
local interrupts.  There's my locking.  It's worth a mention in the
interface description, if not a WARN_ON().

> +	local_irq_restore(flags);
> +}
> +EXPORT_SYMBOL(send_remote_softirq);

It's best to provide some documentation for global, exported-to-modules
functions please.

> +static int __cpuinit remote_softirq_cpu_notify(struct notifier_block *self,
> +					       unsigned long action, void *hcpu)
> +{
> +	/*
> +	 * If a CPU goes away, splice its entries to the current CPU
> +	 * and trigger a run of the softirq
> +	 */
> +	if (action == CPU_DEAD || action == CPU_DEAD_FROZEN) {
> +		int cpu = (unsigned long) hcpu;
> +		int i;
> +
> +		local_irq_disable();
> +		for (i = 0; i < NR_SOFTIRQ; i++) {
> +			struct list_head *head = &per_cpu(softirq_work_list[i], cpu);
> +			struct list_head *local_head;
> +
> +			if (list_empty(head))
> +				continue;
> +
> +			local_head = &__get_cpu_var(softirq_work_list[i]);
> +			list_splice_init(head, local_head);
> +			raise_softirq_irqoff(i);

Could use __local_trigger() here I think, although that wouldn't really
improve anything much.


> +		}
> +		local_irq_enable();
> +	}
> +
> +	return NOTIFY_OK;
> +}
> +
> +static struct notifier_block __cpuinitdata remote_softirq_cpu_notifier = {
> +	.notifier_call	= remote_softirq_cpu_notify,
> +};
> +
>  void __init softirq_init(void)
>  {
>  	int cpu;
>  
>  	for_each_possible_cpu(cpu) {
> +		int i;
> +
>  		per_cpu(tasklet_vec, cpu).tail =
>  			&per_cpu(tasklet_vec, cpu).head;
>  		per_cpu(tasklet_hi_vec, cpu).tail =
>  			&per_cpu(tasklet_hi_vec, cpu).head;
> +		for (i = 0; i < NR_SOFTIRQ; i++)
> +			INIT_LIST_HEAD(&per_cpu(softirq_work_list[i], cpu));
>  	}
>  
> +	register_hotcpu_notifier(&remote_softirq_cpu_notifier);
> +
>  	open_softirq(TASKLET_SOFTIRQ, tasklet_action);
>  	open_softirq(HI_SOFTIRQ, tasklet_hi_action);
>  }


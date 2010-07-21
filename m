From: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Subject: Re: [RFC PATCH v3 1/5] irq: add tracepoint to softirq_raise
Date: Wed, 21 Jul 2010 15:57:05 +0900
Message-ID: <4C469A41.4020807@jp.fujitsu.com>
References: <4C44F12F.5090908@jp.fujitsu.com> <4C44F1AB.6020902@jp.fujitsu.com> <20100720110439.GA1995@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, kaneshige.kenji@jp.fujitsu.com,
	izumi.taku@jp.fujitsu.com, kosaki.motohiro@jp.fujitsu.com,
	laijs@cn.fujitsu.com, scott.a.mcmillan@intel.com,
	rostedt@goodmis.org, eric.dumazet@gmail.com, fweisbec@gmail.com,
	mathieu.desnoyers@polymtl.ca
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail7.fujitsu.co.jp ([192.51.44.37]:59472 "EHLO
	fgwmail7.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762642Ab0GUG53 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jul 2010 02:57:29 -0400
In-Reply-To: <20100720110439.GA1995@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(2010/07/20 20:04), Neil Horman wrote:
> On Tue, Jul 20, 2010 at 09:45:31AM +0900, Koki Sanagi wrote:
>> From: Lai Jiangshan <laijs@cn.fujitsu.com>
>>
>> Add a tracepoint for tracing when softirq action is raised.
>>
>> It and the existed tracepoints complete softirq's tracepoints:
>> softirq_raise, softirq_entry and softirq_exit.
>>
>> And when this tracepoint is used in combination with
>> the softirq_entry tracepoint we can determine
>> the softirq raise latency.
>>
>> Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
>> Acked-by: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
>> Acked-by: Frederic Weisbecker <fweisbec@gmail.com>
>>
>> [ factorize softirq events with DECLARE_EVENT_CLASS ]
>> Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
>> ---
>>  include/linux/interrupt.h  |    8 +++++-
>>  include/trace/events/irq.h |   57 ++++++++++++++++++++++++++-----------------
>>  kernel/softirq.c           |    4 +-
>>  3 files changed, 43 insertions(+), 26 deletions(-)
>>
>> diff --git a/include/linux/interrupt.h b/include/linux/interrupt.h
>> index c233113..1cb5726 100644
>> --- a/include/linux/interrupt.h
>> +++ b/include/linux/interrupt.h
>> @@ -18,6 +18,7 @@
>>  #include <asm/atomic.h>
>>  #include <asm/ptrace.h>
>>  #include <asm/system.h>
>> +#include <trace/events/irq.h>
>>  
>>  /*
>>   * These correspond to the IORESOURCE_IRQ_* defines in
>> @@ -402,7 +403,12 @@ asmlinkage void do_softirq(void);
>>  asmlinkage void __do_softirq(void);
>>  extern void open_softirq(int nr, void (*action)(struct softirq_action *));
>>  extern void softirq_init(void);
>> -#define __raise_softirq_irqoff(nr) do { or_softirq_pending(1UL << (nr)); } while (0)
>> +static inline void __raise_softirq_irqoff(unsigned int nr)
>> +{
>> +	trace_softirq_raise(nr);
>> +	or_softirq_pending(1UL << nr);
>> +}
>> +
> We already have tracepoints in irq_enter and irq_exit.  If the goal here is to
> detect latency during packet processing, cant the delta in time between those
> two points be used to determine interrupt handling latency?

Certainly, the time between irq_entry and irq_exit is not directly related to
latency during packet processing. But it's indirectly related it.
Because softirq_entry isn't passed until irq exits and softirq_entry time is
related to packet processing latency. So I show it as a reference.

> 
> 
>>  extern void raise_softirq_irqoff(unsigned int nr);
>>  extern void raise_softirq(unsigned int nr);
>>  extern void wakeup_softirqd(void);
>> diff --git a/include/trace/events/irq.h b/include/trace/events/irq.h
>> index 0e4cfb6..717744c 100644
>> --- a/include/trace/events/irq.h
>> +++ b/include/trace/events/irq.h
>> @@ -5,7 +5,9 @@
>>  #define _TRACE_IRQ_H
>>  
>>  #include <linux/tracepoint.h>
>> -#include <linux/interrupt.h>
>> +
>> +struct irqaction;
>> +struct softirq_action;
>>  
>>  #define softirq_name(sirq) { sirq##_SOFTIRQ, #sirq }
>>  #define show_softirq_name(val)				\
>> @@ -84,56 +86,65 @@ TRACE_EVENT(irq_handler_exit,
>>  
>>  DECLARE_EVENT_CLASS(softirq,
>>  
>> -	TP_PROTO(struct softirq_action *h, struct softirq_action *vec),
>> +	TP_PROTO(unsigned int nr),
>>  
>> -	TP_ARGS(h, vec),
>> +	TP_ARGS(nr),
>>  
>>  	TP_STRUCT__entry(
>> -		__field(	int,	vec			)
>> +		__field(	unsigned int,	vec	)
>>  	),
>>  
>>  	TP_fast_assign(
>> -		__entry->vec = (int)(h - vec);
>> +		__entry->vec	= nr;
>>  	),
>>  
>>  	TP_printk("vec=%d [action=%s]", __entry->vec,
>> -		  show_softirq_name(__entry->vec))
>> +		show_softirq_name(__entry->vec))
>> +);
>> +
>> +/**
>> + * softirq_raise - called immediately when a softirq is raised
>> + * @nr: softirq vector number
>> + *
>> + * Tracepoint for tracing when softirq action is raised.
>> + * Also, when used in combination with the softirq_entry tracepoint
>> + * we can determine the softirq raise latency.
>> + */
>> +DEFINE_EVENT(softirq, softirq_raise,
>> +
>> +	TP_PROTO(unsigned int nr),
>> +
>> +	TP_ARGS(nr)
>>  );
>>  
>>  /**
>>   * softirq_entry - called immediately before the softirq handler
>> - * @h: pointer to struct softirq_action
>> - * @vec: pointer to first struct softirq_action in softirq_vec array
>> + * @nr: softirq vector number
>>   *
>> - * The @h parameter, contains a pointer to the struct softirq_action
>> - * which has a pointer to the action handler that is called. By subtracting
>> - * the @vec pointer from the @h pointer, we can determine the softirq
>> - * number. Also, when used in combination with the softirq_exit tracepoint
>> + * Tracepoint for tracing when softirq action starts.
>> + * Also, when used in combination with the softirq_exit tracepoint
>>   * we can determine the softirq latency.
>>   */
>>  DEFINE_EVENT(softirq, softirq_entry,
>>  
>> -	TP_PROTO(struct softirq_action *h, struct softirq_action *vec),
>> +	TP_PROTO(unsigned int nr),
>>  
>> -	TP_ARGS(h, vec)
>> +	TP_ARGS(nr)
>>  );
>>  
>>  /**
>>   * softirq_exit - called immediately after the softirq handler returns
>> - * @h: pointer to struct softirq_action
>> - * @vec: pointer to first struct softirq_action in softirq_vec array
>> + * @nr: softirq vector number
>>   *
>> - * The @h parameter contains a pointer to the struct softirq_action
>> - * that has handled the softirq. By subtracting the @vec pointer from
>> - * the @h pointer, we can determine the softirq number. Also, when used in
>> - * combination with the softirq_entry tracepoint we can determine the softirq
>> - * latency.
>> + * Tracepoint for tracing when softirq action ends.
>> + * Also, when used in combination with the softirq_entry tracepoint
>> + * we can determine the softirq latency.
>>   */
>>  DEFINE_EVENT(softirq, softirq_exit,
>>  
>> -	TP_PROTO(struct softirq_action *h, struct softirq_action *vec),
>> +	TP_PROTO(unsigned int nr),
>>  
>> -	TP_ARGS(h, vec)
>> +	TP_ARGS(nr)
>>  );
>>  
>>  #endif /*  _TRACE_IRQ_H */
>> diff --git a/kernel/softirq.c b/kernel/softirq.c
>> index 825e112..6790599 100644
>> --- a/kernel/softirq.c
>> +++ b/kernel/softirq.c
>> @@ -215,9 +215,9 @@ restart:
>>  			int prev_count = preempt_count();
>>  			kstat_incr_softirqs_this_cpu(h - softirq_vec);
>>  
>> -			trace_softirq_entry(h, softirq_vec);
>> +			trace_softirq_entry(h - softirq_vec);
>>  			h->action(h);
>> -			trace_softirq_exit(h, softirq_vec);
>> +			trace_softirq_exit(h - softirq_vec);
> 
> You're loosing information here by reducing the numbers of parameters in this
> tracepoint.  How many other tracepoint scripts rely on having both pointers
> handy?  Why not just do the pointer math inside your tracehook instead?

In __raise_softirq_irqoff macro there is no method to refer softirq_vec, so it
can't use softirq DECLARE_EVENT_CLASS as is.
Currently,  there is no script using softirq_entry or softirq_exit.

Thanks,
Koki Sanagi.

> 
>>  			if (unlikely(prev_count != preempt_count())) {
>>  				printk(KERN_ERR "huh, entered softirq %td %s %p"
>>  				       "with preempt_count %08x,"
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
> 
> 



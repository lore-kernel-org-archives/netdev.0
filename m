From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: [PATCH v4 1/5] irq: add tracepoint to softirq_raise
Date: Fri, 3 Sep 2010 17:29:13 +0200
Message-ID: <20100903152909.GA5352@nowhere>
References: <4C72422C.5070102@jp.fujitsu.com> <4C724298.4050509@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, kaneshige.kenji@jp.fujitsu.com,
	izumi.taku@jp.fujitsu.com, kosaki.motohiro@jp.fujitsu.com,
	nhorman@tuxdriver.com, laijs@cn.fujitsu.com,
	scott.a.mcmillan@intel.com, rostedt@goodmis.org,
	eric.dumazet@gmail.com, mathieu.desnoyers@polymtl.ca
To: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4C724298.4050509@jp.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 23, 2010 at 06:42:48PM +0900, Koki Sanagi wrote:
> From: Lai Jiangshan <laijs@cn.fujitsu.com>
> 
> Add a tracepoint for tracing when softirq action is raised.
> 
> It and the existed tracepoints complete softirq's tracepoints:
> softirq_raise, softirq_entry and softirq_exit.
> 
> And when this tracepoint is used in combination with
> the softirq_entry tracepoint we can determine
> the softirq raise latency.
> 
> Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
> Acked-by: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
> Acked-by: Frederic Weisbecker <fweisbec@gmail.com>
> 
> [ factorize softirq events with DECLARE_EVENT_CLASS ]
> Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
> ---
>  include/linux/interrupt.h  |    8 +++++++-
>  include/trace/events/irq.h |   26 ++++++++++++++++++++++++--
>  2 files changed, 31 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/interrupt.h b/include/linux/interrupt.h
> index a0384a4..d3e8e90 100644
> --- a/include/linux/interrupt.h
> +++ b/include/linux/interrupt.h
> @@ -18,6 +18,7 @@
>  #include <asm/atomic.h>
>  #include <asm/ptrace.h>
>  #include <asm/system.h>
> +#include <trace/events/irq.h>
>  
>  /*
>   * These correspond to the IORESOURCE_IRQ_* defines in
> @@ -407,7 +408,12 @@ asmlinkage void do_softirq(void);
>  asmlinkage void __do_softirq(void);
>  extern void open_softirq(int nr, void (*action)(struct softirq_action *));
>  extern void softirq_init(void);
> -#define __raise_softirq_irqoff(nr) do { or_softirq_pending(1UL << (nr)); } while (0)
> +static inline void __raise_softirq_irqoff(unsigned int nr)
> +{
> +	trace_softirq_raise((struct softirq_action *)&nr, NULL);
> +	or_softirq_pending(1UL << nr);
> +}
> +
>  extern void raise_softirq_irqoff(unsigned int nr);
>  extern void raise_softirq(unsigned int nr);
>  extern void wakeup_softirqd(void);
> diff --git a/include/trace/events/irq.h b/include/trace/events/irq.h
> index 0e4cfb6..3ddda02 100644
> --- a/include/trace/events/irq.h
> +++ b/include/trace/events/irq.h
> @@ -5,7 +5,9 @@
>  #define _TRACE_IRQ_H
>  
>  #include <linux/tracepoint.h>
> -#include <linux/interrupt.h>
> +
> +struct irqaction;
> +struct softirq_action;
>  
>  #define softirq_name(sirq) { sirq##_SOFTIRQ, #sirq }
>  #define show_softirq_name(val)				\
> @@ -93,7 +95,10 @@ DECLARE_EVENT_CLASS(softirq,
>  	),
>  
>  	TP_fast_assign(
> -		__entry->vec = (int)(h - vec);
> +		if (vec)
> +			__entry->vec = (int)(h - vec);
> +		else
> +			__entry->vec = *((int *)h);
>  	),



It seems that this will break softirq_entry/exit tracepoints.
__entry->vec will deref vec->action() for these two, which is not
what we want.

If you can't have the same tracepoint signature for the three, just
split the new one in a seperate TRACE_EVENT().

Thanks.

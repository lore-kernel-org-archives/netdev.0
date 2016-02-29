From: Peter Hurley <peter@hurleysoftware.com>
Subject: Re: Softirq priority inversion from "softirq: reduce latencies"
Date: Mon, 29 Feb 2016 10:05:29 -0800
Message-ID: <56D48869.1000106@hurleysoftware.com>
References: <56D1E8B6.6090003@hurleysoftware.com>
 <1456638957.3676.12.camel@gmail.com>
 <20160228170109.GA16322@electric-eye.fr.zoreil.com>
 <1456721889.3488.67.camel@gmail.com> <56D45DAF.5070709@hurleysoftware.com>
 <1456759153.648.61.camel@edumazet-ThinkPad-T530>
 <56D469B2.2070707@hurleysoftware.com>
 <1456762914.648.76.camel@edumazet-ThinkPad-T530>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Mike Galbraith <umgwanakikbuti@gmail.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Greg KH <gregkh@linuxfoundation.org>,
	dmaengine@vger.kernel.org, John Ogness <john.ogness@linutronix.de>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1456762914.648.76.camel@edumazet-ThinkPad-T530>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/29/2016 08:21 AM, Eric Dumazet wrote:
> On lun., 2016-02-29 at 07:54 -0800, Peter Hurley wrote:
> 
>>  The current kernel is HZ=250 but this would occur on HZ=1000 as well.
> 
> Right. But the problem with HZ=100 and HZ=250 is that the detection can
> happens because jiffy granularity is too coarse, since 
> 
> msecs_to_jiffies(2) -> 1
> 
> Following patch might reduce the probability, but wont really fix your
> problem.
> 
> Fact that ksoftirqd prio is not what you want is completely orthogonal.
> 
> diff --git a/kernel/softirq.c b/kernel/softirq.c
> index 479e443..f7cc594 100644
> --- a/kernel/softirq.c
> +++ b/kernel/softirq.c
> @@ -180,7 +180,7 @@ EXPORT_SYMBOL(__local_bh_enable_ip);
>  
>  /*
>   * We restart softirq processing for at most MAX_SOFTIRQ_RESTART times,
> - * but break the loop if need_resched() is set or after 2 ms.
> + * but break the loop if need_resched() is set or after 2 ms/ticks.
>   * The MAX_SOFTIRQ_TIME provides a nice upper bound in most cases, but in
>   * certain cases, such as stop_machine(), jiffies may cease to
>   * increment and so we need the MAX_SOFTIRQ_RESTART limit as
> @@ -191,7 +191,7 @@ EXPORT_SYMBOL(__local_bh_enable_ip);
>   * we want to handle softirqs as soon as possible, but they
>   * should not be able to lock up the box.
>   */
> -#define MAX_SOFTIRQ_TIME  msecs_to_jiffies(2)
> +#define MAX_SOFTIRQ_TIME  (1 + msecs_to_jiffies(2))
>  #define MAX_SOFTIRQ_RESTART 10
>  
>  #ifdef CONFIG_TRACE_IRQFLAGS

While I appreciate the attempt, that's not the problem.

Just to be clear

		if (time_before(jiffies, end) && !need_resched() &&
		    --max_restart)
			goto restart;

aborts softirq *even if 0ns have elapsed*, if NET_RX has woken a process.

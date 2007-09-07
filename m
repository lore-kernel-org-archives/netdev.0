From: Mandeep Singh Baines <mandeep.baines@gmail.com>
Subject: Re: RFC: possible NAPI improvements to reduce interrupt rates for
	low traffic rates
Date: Thu, 6 Sep 2007 20:55:28 -0700
Message-ID: <20070907035528.GA3755@ludhiana>
References: <200709061416.l86EG0Vb017675@quickie.katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, hadi@cyberus.ca, davem@davemloft.net,
	jeff@garzik.org, mandeep.baines@gmail.com, ossthema@de.ibm.com
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.188]:42144 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964800AbXIGD4c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2007 23:56:32 -0400
Received: by rv-out-0910.google.com with SMTP id k20so321965rvb
        for <netdev@vger.kernel.org>; Thu, 06 Sep 2007 20:56:32 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200709061416.l86EG0Vb017675@quickie.katalix.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi James,

I like the idea of staying in poll longer.

My comments are similar to what Jamal and Stephen have already said.

A tunable (via sysfs) would be nice.

A timer might be preferred to jiffy polling. Jiffy polling will not increase 
latency the way a timer would. However, jiffy polling will consume a lot more
CPU than a timer would. Hence more power. For jiffy polling, you could have 
thousands of calls to poll for a single packet received. While in a timer 
approach the numbers of polls per packet is upper bound to 2. 

I think it may difficult to make poll efficient for the no packet case because,
at a minimum, you have to poll the device state via the has_work method.

If you go to a timer implementation then having a tunable will be important.
Different appications will have different requirements on delay and jitter.
Some applications may want to trade delay/jitter for less CPU/power 
consumption and some may not.

imho, the work should definately be pursued further:)

Regards,
Mandeep

James Chapman (jchapman@katalix.com) wrote:
> This RFC suggests some possible improvements to NAPI in the area of minimizing interrupt rates. A possible scheme to reduce interrupt rate for the low packet rate / fast CPU case is described. 
> 
> First, do we need to encourage consistency in NAPI poll drivers? A survey of current NAPI drivers shows different strategies being used in their poll(). Some such as r8169 do the napi_complete() if poll() does less work than their allowed budget. Others such as e100 and tg3 do napi_complete() only if they do no work at all. And some drivers use NAPI only for receive handling, perhaps setting txdone interrupts for 1 in N transmitted packets, while others do all "interrupt" processing in their poll(). Should we encourage more consistency? Should we encourage more NAPI driver maintainers to minimize interrupts by doing all rx _and_ tx processing in the poll(), and do napi_complete() only when the poll does _no_ work?
> 
> One well known issue with NAPI is that it is possible with certain traffic patterns for NAPI drivers to schedule in and out of polled mode very quickly. Worst case, a NAPI driver might get 1 interrupt per packet. With fast CPUs and interfaces, this can happen at high rates, causing high CPU loads and poor packet processing performance. Some drivers avoid this by using hardware interrupt mitigation features of the network device in tandem with NAPI to throttle the max interrupt rate per device. But this adds latency. Jamal's paper http://kernel.org/pub/linux/kernel/people/hadi/docs/UKUUG2005.pdf discusses this problem in some detail.
> 
> By making some small changes to the NAPI core, I think it is possible to prevent high interrupt rates with NAPI, regardless of traffic patterns and without using per-device hardware interrupt mitigation. The basic idea is that instead of immediately exiting polled mode when it finds no work to do, the driver's poll() keeps itself in active polled mode for 1-2 jiffies and only does napi_complete() when it does no work in that time period. When it does no work in its poll(), the driver can return 0 while leaving itself in the NAPI poll list. This means it is possible for the softirq processing to spin around its active device list, doing no work, since no quota is consumed. A change is therefore also needed in the NAPI core to detect the case when the only devices that are being actively p
 olled in softirq processing are doing no work on each poll and to exit the softirq loop rather than wasting CPU cycles.
> 
> The code changes are shown in the patch below. The patch is against the latest NAPI rework posted by DaveM http://marc.info/?l=linux-netdev&m=118829721407289&w=2. I used e100 and tg3 drivers to test. Since a driver that returns 0 from its poll() while leaving itself in polled mode would now used by the NAPI core as a condition for exiting the softirq poll loop, all existing NAPI drivers would need to conform to this new invariant. Some drivers, e.g. e100, can return 0 even if they do tx work in their poll().
> 
> Clearly, keeping a device in polled mode for 1-2 jiffies after it would otherwise have gone idle means that it might be called many times by the NAPI softirq while it has no work to do. This wastes CPU cycles. It would be important therefore to implement the driver's poll() to make this case as efficient as possible, perhaps testing for it early.
> 
> When a device is in polled mode while idle, there are 2 scheduling cases to consider:-
> 
> 1. One or more other netdevs is not idle and is consuming quota on each poll. The net_rx softirq will loop until the next jiffy tick or when quota is exceeded, calling each device in its polled list. Since the idle device is still in the poll list, it will be polled very rapidly.
> 
> 2. No other active device is in the poll list. The net_rx softirq will poll the idle device twice and then exit the softirq processing loop as if quota is exceeded. See the net_rx_action() changes in the patch which force the loop to exit if no work is being done by any device in the poll list.
> 
> In both cases described above, the scheduler will continue NAPI processing from ksoftirqd. This might be very soon, especially if the system is otherwise idle. But if the system is idle, do we really care that idle network devices will be polled for 1-2 jiffies? If the system is otherwise busy, ksoftirqd will share the CPU with other threads/processes which will reduce the poll rate anyway.
> 
> In testing, I see significant reduction in interrupt rate for typical traffic patterns. A flood ping, for example, keeps the device in polled mode, generating no interrupts. In a test, 8510 packets are sent/received versus 6200 previously; CPU load is 100% versus 62% previously; and 1 netdev interrupt occurs versus 12400 previously. Performance and CPU load under extreme network load (using pktgen) is unchanged, as expected. Most importantly though, it is no longer possible to find a combination of CPU performance and traffic pattern that induce high interrupt rates. And because hardware interrupt mitigation isn't used, packet latency is minimized.
> 
> The increase in CPU load isn't surprising for a flood ping test since the CPU is working to bounce packets as fast as it can. The increase in packet rate is a good indicator of how much the interrupt and NAPI scheduling overhead is. The CPU load shows 100% because ksoftirqd is always wanting the CPU for the duration of the flood ping. The beauty of NAPI is that the scheduler gets to decide which thread gets the CPU, not hardware CPU interrupt priorities. On my desktop system, I perceive _better_ system response (smoother X cursor movement etc) during the flood ping test, despite the CPU load being increased. For a system whose main job is processing network traffic quickly, like an embedded router or a network server, this approach might be very beneficial. For a desktop, I'm less sure, 
 although as I said above, I've noticed no performance issues in my setups to date.
> 
> 
> Is this worth pursuing further? I'm considering doing more work to measure the effects at various relatively low packet rates. I also want to investigate using High Res Timers rather than jiffy sampling to reduce the idle poll time. Perhaps it is also worth trying HRT in the net_rx softirq too. I thought it would be worth throwing the ideas out there first to get early feedback.
> 
> Here's the patch.
> 
> Index: linux-2.6/drivers/net/e100.c
> ===================================================================
> --- linux-2.6.orig/drivers/net/e100.c
> +++ linux-2.6/drivers/net/e100.c
> @@ -544,6 +544,7 @@ struct nic {
>  	struct cb *cb_to_use;
>  	struct cb *cb_to_send;
>  	struct cb *cb_to_clean;
> +	unsigned long exit_poll_time;
>  	u16 tx_command;
>  	/* End: frequently used values: keep adjacent for cache effect */
>  
> @@ -1993,12 +1994,35 @@ static int e100_poll(struct napi_struct 
>  	e100_rx_clean(nic, &work_done, budget);
>  	tx_cleaned = e100_tx_clean(nic);
>  
> -	/* If no Rx and Tx cleanup work was done, exit polling mode. */
> -	if((!tx_cleaned && (work_done == 0)) || !netif_running(netdev)) {
> +	if (!netif_running(netdev)) {
>  		netif_rx_complete(netdev, napi);
>  		e100_enable_irq(nic);
> +		return 0;
>  	}
>  
> +	/* Stay in polled mode if we do any tx cleanup */
> +	if (tx_cleaned)
> +		work_done++;
> +
> +	/* If no Rx and Tx cleanup work was done, exit polling mode if
> +	 * we've seen no work for 1-2 jiffies.
> +	 */
> +	if (work_done == 0) {
> +		if (nic->exit_poll_time) {
> +			if (time_after(jiffies, nic->exit_poll_time)) {
> +				nic->exit_poll_time = 0;
> +				netif_rx_complete(netdev, napi);
> +				e100_enable_irq(nic);
> +			}
> +		} else {
> +			nic->exit_poll_time = jiffies + 2;
> +		}
> +		return 0;
> +	}
> +
> +	/* Otherwise, reset poll exit time and stay in poll list */
> +	nic->exit_poll_time = 0;
> +
>  	return work_done;
>  }
>  
> Index: linux-2.6/drivers/net/tg3.c
> ===================================================================
> --- linux-2.6.orig/drivers/net/tg3.c
> +++ linux-2.6/drivers/net/tg3.c
> @@ -3473,6 +3473,24 @@ static int tg3_poll(struct napi_struct *
>  	struct tg3_hw_status *sblk = tp->hw_status;
>  	int work_done = 0;
>  
> +	/* fastpath having no work while we're holding ourself in
> +	 * polled mode
> +	 */
> +	if ((tp->exit_poll_time) && (!tg3_has_work(tp))) {
> +		if (time_after(jiffies, tp->exit_poll_time)) {
> +			tp->exit_poll_time = 0;
> +			/* tell net stack and NIC we're done */
> +			netif_rx_complete(netdev, napi);
> +			tg3_restart_ints(tp);
> +		}
> +		return 0;
> +	}
> +
> +	/* if we get here, there might be work to do so disable the
> +	 * poll hold fastpath above
> +	 */
> +	tp->exit_poll_time = 0;
> +
>  	/* handle link change and other phy events */
>  	if (!(tp->tg3_flags &
>  	      (TG3_FLAG_USE_LINKCHG_REG |
> @@ -3511,11 +3529,11 @@ static int tg3_poll(struct napi_struct *
>  	} else
>  		sblk->status &= ~SD_STATUS_UPDATED;
>  
> -	/* if no more work, tell net stack and NIC we're done */
> -	if (!tg3_has_work(tp)) {
> -		netif_rx_complete(netdev, napi);
> -		tg3_restart_ints(tp);
> -	}
> +	/* if no more work, set the time in jiffies when we should
> +	 * exit polled mode
> +	 */
> +	if (!tg3_has_work(tp))
> +		tp->exit_poll_time = jiffies + 2;
>  
>  	return work_done;
>  }
> Index: linux-2.6/drivers/net/tg3.h
> ===================================================================
> --- linux-2.6.orig/drivers/net/tg3.h
> +++ linux-2.6/drivers/net/tg3.h
> @@ -2163,6 +2163,7 @@ struct tg3 {
>  	u32				last_tag;
>  
>  	u32				msg_enable;
> +	unsigned long			exit_poll_time;
>  
>  	/* begin "tx thread" cacheline section */
>  	void				(*write32_tx_mbox) (struct tg3 *, u32,
> Index: linux-2.6/net/core/dev.c
> ===================================================================
> --- linux-2.6.orig/net/core/dev.c
> +++ linux-2.6/net/core/dev.c
> @@ -2073,6 +2073,8 @@ static void net_rx_action(struct softirq
>  	unsigned long start_time = jiffies;
>  	int budget = netdev_budget;
>  	void *have;
> +	struct napi_struct *last_hold = NULL;
> +	int done = 0;
>  
>  	local_irq_disable();
>  	list_replace_init(&__get_cpu_var(softnet_data).poll_list, &list);
> @@ -2082,7 +2084,7 @@ static void net_rx_action(struct softirq
>  		struct napi_struct *n;
>  
>  		/* if softirq window is exhuasted then punt */
> -		if (unlikely(budget <= 0 || jiffies != start_time)) {
> +		if (unlikely(budget <= 0 || jiffies != start_time || done)) {
>  			local_irq_disable();
>  			list_splice(&list, &__get_cpu_var(softnet_data).poll_list);
>  			__raise_softirq_irqoff(NET_RX_SOFTIRQ);
> @@ -2096,12 +2098,28 @@ static void net_rx_action(struct softirq
>  
>  		list_del(&n->poll_list);
>  
> -		/* if quota not exhausted process work */
> +		/* if quota not exhausted process work. We special
> +		 * case on n->poll() returning 0 here when the driver
> +		 * doesn't do a napi_complete(), which indicates that
> +		 * the device wants to stay on the poll list although
> +		 * it did no work. We remember the first device to go
> +		 * into this state in order to terminate this loop if
> +		 * we see the same device again without doing any
> +		 * other work.
> +		 */
>  		if (likely(n->quota > 0)) {
>  			int work = n->poll(n, min(budget, n->quota));
>  
> -			budget -= work;
> -			n->quota -= work;
> +			if (likely(work)) {
> +				budget -= work;
> +				n->quota -= work;
> +				last_hold = NULL;
> +			} else if (test_bit(NAPI_STATE_SCHED, &n->state)) {
> +				if (unlikely(n == last_hold))
> +					done = 1;
> +				if (likely(!last_hold))
> +					last_hold = n;
> +			}
>  		}
>  
>  		/* if napi_complete not called, reschedule */

From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [4.4-RT PATCH RFC/RFT] drivers: net: cpsw: mark rx/tx irq as
 IRQF_NO_THREAD
Date: Fri, 12 Aug 2016 10:32:06 +0200
Message-ID: <20160812083206.t7lvxpo44marwpf5@linutronix.de>
References: <20160811161540.9613-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Steven Rostedt <rostedt@goodmis.org>, linux-omap@vger.kernel.org,
	Alison Chaiken <alison@peloton-tech.com>,
	linux-rt-users@vger.kernel.org, netdev@vger.kernel.org
To: Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <linux-rt-users-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160811161540.9613-1-grygorii.strashko@ti.com>
Sender: linux-rt-users-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2016-08-11 19:15:40 [+0300], Grygorii Strashko wrote:
> Mark CPSW Rx/Tx IRQs as IRQF_NO_THREAD and avoid double scheduling on -RT
> where this IRQs are forced threaded:
>  rx-irq
>   |- schedule threaded rx-irq handler
> ...
>   |- threaded rx-irq handler -> cpsw_rx_interrupt()
>      |- napi_schedule()
> 	|- __raise_softirq_irqoff()
> 	   |- wakeup_proper_softirq()
> ...
>   napi

This should not be the default path. The default should be napi running
in the context of the threaded rx-irq handler once the handler is done.
The wakeup_proper_softirq() part is only done if napi thinks that the
callback functions runs for too long. So in *that* case you continue
NAPI in the softirq-thread which runs at SCHED_OTHER.

> after:
>  rx-irq
>   |- cpsw_rx_interrupt()
>      |- napi_schedule()
>   |- irq_exit()
>      |- invoke_softirq()
> 	   |- wakeup_softirqd()
> ...
>   napi

Since you schedule the softirq from an IRQ-off region / without a
process context you force the softirq to run in the thread at
SCHED_OTHER priority.

> And, as result, get benefits from the following improvements (tested
> on am57xx-evm):
> 
> 1) "[ 78.348599] NOHZ: local_softirq_pending 80" message will not be
>    seen any more. Now these warnings can be seen once iperf is started.
>    # iperf -c $IPERFHOST -w 128K  -d -t 60

Do you also see "sched: RT throttling activated"? Because I don't see
otherwise why this should pop up.

> 2) latency reduction when cyclictest is run in parallel with network load
>  where net_perf.sh is:
>    iperf -c $IPERFHOST -w 8K    -d -t 60
>    iperf -c $IPERFHOST -w 16K   -d -t 60
>    iperf -c $IPERFHOST -w 32K   -d -t 60
>    iperf -c $IPERFHOST -w 64K   -d -t 60
>    iperf -c $IPERFHOST -w 128K  -d -t 60
> 
> before:
> T: 0 ( 1326) P:98 I:1000 C: 240000 Min:      8 Act:   13 Avg:   18 Max:      70
> T: 1 ( 1327) P:98 I:1500 C: 159981 Min:      9 Act:   15 Avg:   16 Max:      43
> after:
> T: 0 ( 1331) P:98 I:1000 C: 240000 Min:      8 Act:   15 Avg:   14 Max:      51
> T: 1 ( 1332) P:98 I:1500 C: 159953 Min:      8 Act:   16 Avg:   15 Max:      33

-d 0 to have I: set to the same value.
What does -i 250 say?
And without network load we are where we were at "after" values?

What happens if s/__raise_softirq_irqoff_ksoft/__raise_softirq_irqoff/
in net/core/dev.c and chrt the priority of you network interrupt
handlers to SCHED_OTHER priority?

> 3) network performance increase
> 
> win, K	Mbits/s
> 	before	after	%
> 8K	354	350.3	0.0
> 16K	412	551	33.7
> 32K	423	659.5	55.9
> 64K	436	728.3	67.0
> 128K	537	845	57.4

How close are the after numbers to !RT?

Sebastian

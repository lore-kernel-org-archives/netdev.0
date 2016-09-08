From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [4.4-RT PATCH RFC/RFT] drivers: net: cpsw: mark rx/tx irq as
 IRQF_NO_THREAD
Date: Thu, 8 Sep 2016 19:24:07 +0300
Message-ID: <4f134c90-9230-711e-6993-df84e5facd3b@ti.com>
References: <20160811161540.9613-1-grygorii.strashko@ti.com>
 <20160812083206.t7lvxpo44marwpf5@linutronix.de>
 <a5d1bd8f-4219-4890-9e1e-d4bc4181eb57@ti.com>
 <20160908142813.tma7j6p44e3z3nqc@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: Steven Rostedt <rostedt@goodmis.org>, <linux-omap@vger.kernel.org>,
        Alison Chaiken <alison@peloton-tech.com>,
        <linux-rt-users@vger.kernel.org>, <netdev@vger.kernel.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:52069 "EHLO comal.ext.ti.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752826AbcIHQYZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Sep 2016 12:24:25 -0400
In-Reply-To: <20160908142813.tma7j6p44e3z3nqc@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/08/2016 05:28 PM, Sebastian Andrzej Siewior wrote:
> On 2016-08-12 18:58:21 [+0300], Grygorii Strashko wrote:
>> Hi Sebastian,
> Hi Grygorii,
> 
>> Thankds for comment. You're right:
>> irq_thread()->irq_forced_thread_fn()->local_bh_enable()
>>
>> but wouldn't here two wake_up_process() calls any way,
>> plus preempt_check_resched_rt() in napi_schedule().
> 
> Usually you prefer BH handling in the IRQ-thread because it runs at
> higher priority and is not interrupted by a SCHED_OTHER process. And you
> can assign it a higher priority if it should be preferred over an other
> interrupt. However, if the processing of the interrupt is taking too
> much time (like that ping flood, a lot of network traffic) then we push
> it to the softirq thread. If you do this now unconditionally in the
> SCHED_OTHER softirq thread then you take away all the `good' things we
> had (like processing important packets at higher priority as long as
> nobody floods us). Plus you share this thread with everything else that
> runs in there.

That's i understand, but effect from this patch on network throughput
is pretty amazing :)

> 
>>>> And, as result, get benefits from the following improvements (tested
>>>> on am57xx-evm):
>>>>
>>>> 1) "[ 78.348599] NOHZ: local_softirq_pending 80" message will not be
>>>>    seen any more. Now these warnings can be seen once iperf is started.
>>>>    # iperf -c $IPERFHOST -w 128K  -d -t 60
>>>
>>> Do you also see "sched: RT throttling activated"? Because I don't see
>>> otherwise why this should pop up.
>>
>> I've reverted my patch an did requested experiments (some additional info below).
>>
>> I do not see "sched: RT throttling activated" :(
> 
> That is okay. However if aim for throughput you might want to switch
> away from NO_HZ (and deactivate the software watchdog wich runs at
> prio 99 if enabled).
> 
>> root@am57xx-evm:~# ./net_perf.sh & cyclictest -m -Sp98 -q  -D4m
>> [1] 1301
>> # /dev/cpu_dma_latency set to 0us
>> Linux am57xx-evm 4.4.16-rt23-00321-ga195e6a-dirty #92 SMP PREEMPT RT Fri Aug 12 14:03:59 EEST 2016 armv7l GNU/Linux
>>
> …
>> [1]+  Done                    ./net_perf.sh
> 
> I can't parse this. But that local_softirq_pending() warning might
> contribute to lower numbers.
> 
>> =============================================== before, no net load:
>> cyclictest -m -Sp98 -q  -D4m -i250 -d0
>> # /dev/cpu_dma_latency set to 0us
>> T: 0 ( 1288) P:98 I:250 C: 960000 Min:      8 Act:    9 Avg:    8 Max:      33
>> T: 1 ( 1289) P:98 I:250 C: 959929 Min:      7 Act:   11 Avg:    9 Max:      26
> 
>> =============================================== after, no net load:
>> cyclictest -m -Sp98 -q  -D4m -i250 -d0
>> T: 0 ( 1301) P:98 I:250 C: 960000 Min:      7 Act:    9 Avg:    8 Max:      22
>> T: 1 ( 1302) P:98 I:250 C: 959914 Min:      7 Act:   11 Avg:    8 Max:      28
> 
> I think those two should be equal more or less since the change should
> have no impact on "no net load" or do I miss something?

Correct I see no differences in this case, as per above.

> 
>> =============================================== before, with net load:
>> cyclictest -m -Sp98 -q -D4m -i250 -d0
>> T: 0 ( 1400) P:98 I:250 C: 960000 Min:      8 Act:   25 Avg:   18 Max:      83
>> T: 1 ( 1401) P:98 I:250 C: 959801 Min:      7 Act:   27 Avg:   17 Max:      48
>>
>>
>> =============================================== after, with net load:
>> cyclictest -m -Sp98 -q  -D4m -i250 -d0
>> T: 0 ( 1358) P:98 I:250 C: 960000 Min:      8 Act:   11 Avg:   14 Max:      42
>> T: 1 ( 1359) P:98 I:250 C: 959743 Min:      7 Act:   18 Avg:   15 Max:      36
> 
> So the max value dropped by ~50% with your patch. Interesting. What I
> remember from testing is that once you had, say, one hour of hackbench
> running then after that, the extra network traffic didn't contribute
> much (if at all) to the max value.
> That said it is hard to believe that one extra context switch
> contributes about 40us to the max value on CPU0.

Yup. but short time testing provides very stable results.
This patch is going to be tested more intensively shortly.

> 
>>> What happens if s/__raise_softirq_irqoff_ksoft/__raise_softirq_irqoff/
>>> in net/core/dev.c and chrt the priority of you network interrupt
>>> handlers to SCHED_OTHER priority?
>>
>> ===== without this patch + __raise_softirq_irqoff + netIRQs->SCHED_OTHER
>>
>> with net load:
>> cyclictest -m -Sp98 -q -D4m -i250 -d0
>> T: 0 ( 1325) P:98 I:1000 C: 240000 Min:      8 Act:   22 Avg:   17 Max:      51
>> T: 1 ( 1326) P:98 I:1500 C: 159981 Min:      8 Act:   15 Avg:   15 Max:      39
>>
>> cyclictest -m -Sp98 -q  -D4m -i250 -d0
>> T: 0 ( 1307) P:98 I:250 C: 960000 Min:      7 Act:   13 Avg:   16 Max:      50
>> T: 1 ( 1308) P:98 I:250 C: 959819 Min:      8 Act:   12 Avg:   14 Max:      37
>>

> 
> So that looks nice, doesn't it?

Yah, This improvement, in general. 
But the fact that so significant net performance drop observed out of the box 
(without any tunning) and on idle system - triggers a lot of questions ;(

I'm worry if observed original behavior can depend on usage NAPI polling  for both RX/TX 
in CPSW driver. CPSW request two IRQs RX and TX and both handler just do napi_schedule()[NET_RX].


-- 
regards,
-grygorii

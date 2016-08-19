From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [4.4-RT PATCH RFC/RFT] drivers: net: cpsw: mark rx/tx irq as
 IRQF_NO_THREAD
Date: Fri, 19 Aug 2016 17:29:16 +0300
Message-ID: <9f811252-82ff-fd24-1006-2b40cd448927@ti.com>
References: <20160811161540.9613-1-grygorii.strashko@ti.com>
 <20160812083206.t7lvxpo44marwpf5@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Steven Rostedt <rostedt@goodmis.org>, <linux-omap@vger.kernel.org>,
        Alison Chaiken <alison@peloton-tech.com>,
        <linux-rt-users@vger.kernel.org>, <netdev@vger.kernel.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:55444 "EHLO
        devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751599AbcHSOaX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 10:30:23 -0400
In-Reply-To: <20160812083206.t7lvxpo44marwpf5@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/12/2016 11:32 AM, Sebastian Andrzej Siewior wrote:
> On 2016-08-11 19:15:40 [+0300], Grygorii Strashko wrote:
>> Mark CPSW Rx/Tx IRQs as IRQF_NO_THREAD and avoid double scheduling on -RT
>> where this IRQs are forced threaded:
>>  rx-irq
>>   |- schedule threaded rx-irq handler
>> ...
>>   |- threaded rx-irq handler -> cpsw_rx_interrupt()
>>      |- napi_schedule()
>> 	|- __raise_softirq_irqoff()
>> 	   |- wakeup_proper_softirq()
>> ...
>>   napi
> 
> This should not be the default path. The default should be napi running
> in the context of the threaded rx-irq handler once the handler is done.
> The wakeup_proper_softirq() part is only done if napi thinks that the
> callback functions runs for too long. So in *that* case you continue
> NAPI in the softirq-thread which runs at SCHED_OTHER.
> 
>> after:
>>  rx-irq
>>   |- cpsw_rx_interrupt()
>>      |- napi_schedule()
>>   |- irq_exit()
>>      |- invoke_softirq()
>> 	   |- wakeup_softirqd()
>> ...
>>   napi
> 
> Since you schedule the softirq from an IRQ-off region / without a
> process context you force the softirq to run in the thread at
> SCHED_OTHER priority.
> 
>> And, as result, get benefits from the following improvements (tested
>> on am57xx-evm):
>>
>> 1) "[ 78.348599] NOHZ: local_softirq_pending 80" message will not be
>>    seen any more. Now these warnings can be seen once iperf is started.
>>    # iperf -c $IPERFHOST -w 128K  -d -t 60
> 
> Do you also see "sched: RT throttling activated"? Because I don't see
> otherwise why this should pop up.
> 

I've collected trace before first occurrence of  "NOHZ: local_softirq_pending 80"

 irq/354-4848400-85    [000]    90.639460: irq_handler_entry:    irq=19 name=arch_timer
           iperf-1284  [001]    90.639474: softirq_raise:        vec=1 [action=TIMER]
           iperf-1284  [001]    90.639486: irq_handler_exit:     irq=19 ret=handled
 irq/354-4848400-85    [000]    90.639488: softirq_raise:        vec=7 [action=SCHED]
           iperf-1284  [001]    90.639490: sched_waking:         comm=ksoftirqd/1 pid=21 prio=120 target_cpu=001
 irq/354-4848400-85    [000]    90.639492: softirq_raise:        vec=1 [action=TIMER]
           iperf-1284  [001]    90.639499: sched_wakeup:         ksoftirqd/1:21 [120] success=1 CPU:001
           iperf-1284  [001]    90.639504: sched_waking:         comm=ktimersoftd/1 pid=20 prio=98 target_cpu=001
 irq/354-4848400-85    [000]    90.639505: irq_handler_exit:     irq=19 ret=handled
           iperf-1284  [001]    90.639512: sched_wakeup:         ktimersoftd/1:20 [98] success=1 CPU:001
           iperf-1284  [001]    90.639526: sched_stat_runtime:   comm=iperf pid=1284 runtime=50752 [ns] vruntime=2105322850 [ns]
           iperf-1284  [001]    90.639537: sched_switch:         iperf:1284 [120] R ==> irq/355-4848400:86 [49]
 irq/355-4848400-86    [001]    90.639545: softirq_raise:        vec=3 [action=NET_RX]
 irq/355-4848400-86    [001]    90.639556: softirq_entry:        vec=3 [action=NET_RX]
 irq/355-4848400-86    [001]    90.639589: softirq_exit:         vec=3 [action=NET_RX]
 irq/355-4848400-86    [001]    90.639614: sched_switch:         irq/355-4848400:86 [49] S ==> ktimersoftd/1:20 [98]
   ktimersoftd/1-20    [001]    90.639625: softirq_entry:        vec=1 [action=TIMER]
   ktimersoftd/1-20    [001]    90.639637: sched_waking:         comm=rcu_preempt pid=8 prio=98 target_cpu=001
   ktimersoftd/1-20    [001]    90.639646: sched_wakeup:         rcu_preempt:8 [98] success=1 CPU:001
   ktimersoftd/1-20    [001]    90.639663: softirq_exit:         vec=1 [action=TIMER]
   ktimersoftd/1-20    [001]    90.639679: sched_switch:         ktimersoftd/1:20 [98] S ==> rcu_preempt:8 [98]
     rcu_preempt-8     [001]    90.639722: sched_switch:         rcu_preempt:8 [98] S ==> ksoftirqd/1:21 [120]
     ksoftirqd/1-21    [001]    90.639740: sched_stat_runtime:   comm=ksoftirqd/1 pid=21 runtime=25539 [ns] vruntime=29960463828 [ns]
     ksoftirqd/1-21    [001]    90.639750: sched_switch:         ksoftirqd/1:21 [120] S ==> iperf:1284 [120]
 irq/354-4848400-85    [000]    90.639878: irq_handler_entry:    irq=355 name=48484000.ethernet
 irq/354-4848400-85    [000]    90.639880: irq_handler_exit:     irq=355 ret=handled
 irq/354-4848400-85    [000]    90.639884: sched_waking:         comm=irq/355-4848400 pid=86 prio=49 target_cpu=001
 irq/354-4848400-85    [000]    90.639896: sched_wakeup:         irq/355-4848400:86 [49] success=1 CPU:001
           iperf-1284  [001]    90.639903: sched_stat_runtime:   comm=iperf pid=1284 runtime=150466 [ns] vruntime=2105473316 [ns]
           iperf-1284  [001]    90.639913: sched_switch:         iperf:1284 [120] R ==> irq/355-4848400:86 [49]
 irq/355-4848400-86    [001]    90.639921: softirq_raise:        vec=3 [action=NET_RX]
 irq/355-4848400-86    [001]    90.639932: softirq_entry:        vec=3 [action=NET_RX]
 irq/355-4848400-86    [001]    90.639958: sched_waking:         comm=irq/354-4848400 pid=85 prio=49 target_cpu=000
 irq/355-4848400-86    [001]    90.639963: sched_wakeup:         irq/354-4848400:85 [49] success=1 CPU:000
 irq/355-4848400-86    [001]    90.639984: softirq_exit:         vec=3 [action=NET_RX]
 irq/355-4848400-86    [001]    90.640012: sched_switch:         irq/355-4848400:86 [49] S ==> iperf:1284 [120]
 irq/354-4848400-85    [000]    90.640109: sched_waking:         comm=iperf pid=1284 prio=120 target_cpu=001
 irq/354-4848400-85    [000]    90.640115: sched_wakeup:         iperf:1284 [120] success=1 CPU:001
 irq/354-4848400-85    [000]    90.640152: irq_handler_entry:    irq=355 name=48484000.ethernet
 irq/354-4848400-85    [000]    90.640154: irq_handler_exit:     irq=355 ret=handled
 irq/354-4848400-85    [000]    90.640158: sched_waking:         comm=irq/355-4848400 pid=86 prio=49 target_cpu=001
 irq/354-4848400-85    [000]    90.640170: sched_wakeup:         irq/355-4848400:86 [49] success=1 CPU:001
           iperf-1284  [001]    90.640177: sched_stat_runtime:   comm=iperf pid=1284 runtime=163480 [ns] vruntime=2105636796 [ns]
           iperf-1284  [001]    90.640187: sched_switch:         iperf:1284 [120] R ==> irq/355-4848400:86 [49]
 irq/355-4848400-86    [001]    90.640195: softirq_raise:        vec=3 [action=NET_RX]
 irq/355-4848400-86    [001]    90.640206: softirq_entry:        vec=3 [action=NET_RX]
 irq/355-4848400-86    [001]    90.640239: softirq_exit:         vec=3 [action=NET_RX]
 irq/355-4848400-86    [001]    90.640266: sched_switch:         irq/355-4848400:86 [49] S ==> iperf:1284 [120]
 irq/354-4848400-85    [000]    90.640376: irq_handler_entry:    irq=355 name=48484000.ethernet
 irq/354-4848400-85    [000]    90.640378: irq_handler_exit:     irq=355 ret=handled
 irq/354-4848400-85    [000]    90.640382: sched_waking:         comm=irq/355-4848400 pid=86 prio=49 target_cpu=001
 irq/354-4848400-85    [000]    90.640394: sched_wakeup:         irq/355-4848400:86 [49] success=1 CPU:001
           iperf-1284  [001]    90.640401: sched_stat_runtime:   comm=iperf pid=1284 runtime=133387 [ns] vruntime=2105770183 [ns]
           iperf-1284  [001]    90.640412: sched_switch:         iperf:1284 [120] R ==> irq/355-4848400:86 [49]
 irq/355-4848400-86    [001]    90.640419: softirq_raise:        vec=3 [action=NET_RX]
 irq/355-4848400-86    [001]    90.640430: softirq_entry:        vec=3 [action=NET_RX]
 irq/355-4848400-86    [001]    90.640463: softirq_exit:         vec=3 [action=NET_RX]
 irq/355-4848400-86    [001]    90.640489: sched_switch:         irq/355-4848400:86 [49] S ==> iperf:1284 [120]
 irq/354-4848400-85    [000]    90.640560: softirq_exit:         vec=3 [action=NET_RX]
 irq/354-4848400-85    [000]    90.640568: softirq_raise:        vec=3 [action=NET_RX]
 irq/354-4848400-85    [000]    90.640579: softirq_entry:        vec=3 [action=NET_RX]
 irq/354-4848400-85    [000]    90.640606: irq_handler_entry:    irq=355 name=48484000.ethernet
 irq/354-4848400-85    [000]    90.640608: irq_handler_exit:     irq=355 ret=handled
 irq/354-4848400-85    [000]    90.640611: sched_waking:         comm=irq/355-4848400 pid=86 prio=49 target_cpu=001
 irq/354-4848400-85    [000]    90.640623: sched_wakeup:         irq/355-4848400:86 [49] success=1 CPU:001
           iperf-1284  [001]    90.640630: sched_stat_runtime:   comm=iperf pid=1284 runtime=139080 [ns] vruntime=2105909263 [ns]
           iperf-1284  [001]    90.640641: sched_switch:         iperf:1284 [120] R ==> irq/355-4848400:86 [49]
 irq/355-4848400-86    [001]    90.640648: softirq_raise:        vec=3 [action=NET_RX]
 irq/355-4848400-86    [001]    90.640659: softirq_entry:        vec=3 [action=NET_RX]
 irq/355-4848400-86    [001]    90.640692: softirq_exit:         vec=3 [action=NET_RX]
 irq/355-4848400-86    [001]    90.640720: sched_switch:         irq/355-4848400:86 [49] S ==> iperf:1284 [120]
 irq/354-4848400-85    [000]    90.640806: softirq_exit:         vec=3 [action=NET_RX]
 irq/354-4848400-85    [000]    90.640820: irq_handler_entry:    irq=354 name=48484000.ethernet
 irq/354-4848400-85    [000]    90.640823: irq_handler_exit:     irq=354 ret=handled
 irq/354-4848400-85    [000]    90.640833: irq_handler_entry:    irq=355 name=48484000.ethernet
 irq/354-4848400-85    [000]    90.640835: irq_handler_exit:     irq=355 ret=handled
 irq/354-4848400-85    [000]    90.640838: sched_waking:         comm=irq/355-4848400 pid=86 prio=49 target_cpu=001
 irq/354-4848400-85    [000]    90.640849: sched_wakeup:         irq/355-4848400:86 [49] success=1 CPU:001
           iperf-1284  [001]    90.640857: sched_stat_runtime:   comm=iperf pid=1284 runtime=135501 [ns] vruntime=2106044764 [ns]
 irq/354-4848400-85    [000]    90.640861: softirq_raise:        vec=3 [action=NET_RX]
           iperf-1284  [001]    90.640867: sched_switch:         iperf:1284 [120] R ==> irq/355-4848400:86 [49]
 irq/354-4848400-85    [000]    90.640872: irq_handler_entry:    irq=354 name=48484000.ethernet
 irq/354-4848400-85    [000]    90.640874: irq_handler_exit:     irq=354 ret=handled
 irq/355-4848400-86    [001]    90.640875: softirq_raise:        vec=3 [action=NET_RX]
 irq/354-4848400-85    [000]    90.640885: softirq_entry:        vec=3 [action=NET_RX]
 irq/355-4848400-86    [001]    90.640886: softirq_entry:        vec=3 [action=NET_RX]
 irq/355-4848400-86    [001]    90.640919: softirq_exit:         vec=3 [action=NET_RX]
 irq/355-4848400-86    [001]    90.640945: sched_switch:         irq/355-4848400:86 [49] S ==> iperf:1284 [120]
 irq/354-4848400-85    [000]    90.641052: irq_handler_entry:    irq=355 name=48484000.ethernet
 irq/354-4848400-85    [000]    90.641054: irq_handler_exit:     irq=355 ret=handled
 irq/354-4848400-85    [000]    90.641058: sched_waking:         comm=irq/355-4848400 pid=86 prio=49 target_cpu=001
 irq/354-4848400-85    [000]    90.641070: sched_wakeup:         irq/355-4848400:86 [49] success=1 CPU:001
           iperf-1284  [001]    90.641077: sched_stat_runtime:   comm=iperf pid=1284 runtime=129483 [ns] vruntime=2106174247 [ns]
           iperf-1284  [001]    90.641087: sched_switch:         iperf:1284 [120] R ==> irq/355-4848400:86 [49]
 irq/355-4848400-86    [001]    90.641095: softirq_raise:        vec=3 [action=NET_RX]
 irq/355-4848400-86    [001]    90.641106: softirq_entry:        vec=3 [action=NET_RX]
 irq/355-4848400-86    [001]    90.641132: sched_waking:         comm=irq/354-4848400 pid=85 prio=49 target_cpu=000
 irq/355-4848400-86    [001]    90.641138: sched_wakeup:         irq/354-4848400:85 [49] success=1 CPU:000
 irq/355-4848400-86    [001]    90.641159: softirq_exit:         vec=3 [action=NET_RX]
 irq/355-4848400-86    [001]    90.641185: sched_switch:         irq/355-4848400:86 [49] S ==> iperf:1284 [120]
 irq/354-4848400-85    [000]    90.641312: irq_handler_entry:    irq=355 name=48484000.ethernet
 irq/354-4848400-85    [000]    90.641314: irq_handler_exit:     irq=355 ret=handled
 irq/354-4848400-85    [000]    90.641317: sched_waking:         comm=irq/355-4848400 pid=86 prio=49 target_cpu=001
 irq/354-4848400-85    [000]    90.641329: sched_wakeup:         irq/355-4848400:86 [49] success=1 CPU:001
           iperf-1284  [001]    90.641336: sched_stat_runtime:   comm=iperf pid=1284 runtime=149003 [ns] vruntime=2106323250 [ns]
           iperf-1284  [001]    90.641347: sched_switch:         iperf:1284 [120] R ==> irq/355-4848400:86 [49]
 irq/355-4848400-86    [001]    90.641355: softirq_raise:        vec=3 [action=NET_RX]
 irq/355-4848400-86    [001]    90.641366: softirq_entry:        vec=3 [action=NET_RX]
 irq/355-4848400-86    [001]    90.641398: softirq_exit:         vec=3 [action=NET_RX]
 irq/355-4848400-86    [001]    90.641425: sched_switch:         irq/355-4848400:86 [49] S ==> iperf:1284 [120]
 irq/354-4848400-85    [000]    90.641526: softirq_exit:         vec=3 [action=NET_RX]
 irq/354-4848400-85    [000]    90.641526: irq_handler_entry:    irq=355 name=48484000.ethernet
 irq/354-4848400-85    [000]    90.641526: irq_handler_exit:     irq=355 ret=handled
 irq/354-4848400-85    [000]    90.641526: sched_waking:         comm=irq/355-4848400 pid=86 prio=49 target_cpu=001
 irq/354-4848400-85    [000]    90.641526: sched_wakeup:         irq/355-4848400:86 [49] success=1 CPU:001
           iperf-1284  [001]    90.641557: sched_stat_runtime:   comm=iperf pid=1284 runtime=130946 [ns] vruntime=2106454196 [ns]
 irq/354-4848400-85    [000]    90.641565: softirq_raise:        vec=3 [action=NET_RX]
           iperf-1284  [001]    90.641567: sched_switch:         iperf:1284 [120] R ==> irq/355-4848400:86 [49]
 irq/355-4848400-86    [001]    90.641575: softirq_raise:        vec=3 [action=NET_RX]
 irq/354-4848400-85    [000]    90.641576: irq_handler_entry:    irq=354 name=48484000.ethernet
 irq/354-4848400-85    [000]    90.641578: irq_handler_exit:     irq=354 ret=handled
 irq/355-4848400-86    [001]    90.641586: softirq_entry:        vec=3 [action=NET_RX]
 irq/354-4848400-85    [000]    90.641589: softirq_entry:        vec=3 [action=NET_RX]
 irq/355-4848400-86    [001]    90.641618: softirq_exit:         vec=3 [action=NET_RX]
 irq/355-4848400-86    [001]    90.641645: sched_switch:         irq/355-4848400:86 [49] S ==> iperf:1284 [120]
 irq/354-4848400-85    [000]    90.641760: irq_handler_entry:    irq=355 name=48484000.ethernet
 irq/354-4848400-85    [000]    90.641762: irq_handler_exit:     irq=355 ret=handled
 irq/354-4848400-85    [000]    90.641765: sched_waking:         comm=irq/355-4848400 pid=86 prio=49 target_cpu=001
 irq/354-4848400-85    [000]    90.641777: sched_wakeup:         irq/355-4848400:86 [49] success=1 CPU:001
           iperf-1284  [001]    90.641784: sched_stat_runtime:   comm=iperf pid=1284 runtime=137941 [ns] vruntime=2106592137 [ns]
           iperf-1284  [001]    90.641795: sched_switch:         iperf:1284 [120] R ==> irq/355-4848400:86 [49]
 irq/355-4848400-86    [001]    90.641802: softirq_raise:        vec=3 [action=NET_RX]
 irq/355-4848400-86    [001]    90.641814: softirq_entry:        vec=3 [action=NET_RX]
 irq/355-4848400-86    [001]    90.641845: softirq_exit:         vec=3 [action=NET_RX]
 irq/355-4848400-86    [001]    90.641871: sched_switch:         irq/355-4848400:86 [49] S ==> iperf:1284 [120]
 irq/354-4848400-85    [000]    90.641916: softirq_exit:         vec=3 [action=NET_RX]
 irq/354-4848400-85    [000]    90.641924: softirq_raise:        vec=3 [action=NET_RX]
 irq/354-4848400-85    [000]    90.641935: softirq_entry:        vec=3 [action=NET_RX]
 irq/354-4848400-85    [000]    90.641964: sched_waking:         comm=iperf pid=1284 prio=120 target_cpu=001
 irq/354-4848400-85    [000]    90.641969: sched_wakeup:         iperf:1284 [120] success=1 CPU:001
 irq/354-4848400-85    [000]    90.642006: irq_handler_entry:    irq=355 name=48484000.ethernet
 irq/354-4848400-85    [000]    90.642008: irq_handler_exit:     irq=355 ret=handled
 irq/354-4848400-85    [000]    90.642011: sched_waking:         comm=irq/355-4848400 pid=86 prio=49 target_cpu=001
 irq/354-4848400-85    [000]    90.642024: sched_wakeup:         irq/355-4848400:86 [49] success=1 CPU:001
           iperf-1284  [001]    90.642032: sched_stat_runtime:   comm=iperf pid=1284 runtime=156486 [ns] vruntime=2106748623 [ns]
           iperf-1284  [001]    90.642042: sched_switch:         iperf:1284 [120] R ==> irq/355-4848400:86 [49]
 irq/355-4848400-86    [001]    90.642049: softirq_raise:        vec=3 [action=NET_RX]
 irq/355-4848400-86    [001]    90.642060: softirq_entry:        vec=3 [action=NET_RX]
 irq/355-4848400-86    [001]    90.642093: softirq_exit:         vec=3 [action=NET_RX]
 irq/355-4848400-86    [001]    90.642120: sched_switch:         irq/355-4848400:86 [49] S ==> iperf:1284 [120]
 irq/354-4848400-85    [000]    90.642233: irq_handler_entry:    irq=355 name=48484000.ethernet
 irq/354-4848400-85    [000]    90.642235: irq_handler_exit:     irq=355 ret=handled
 irq/354-4848400-85    [000]    90.642238: sched_waking:         comm=irq/355-4848400 pid=86 prio=49 target_cpu=001
 irq/354-4848400-85    [000]    90.642250: sched_wakeup:         irq/355-4848400:86 [49] success=1 CPU:001
           iperf-1284  [001]    90.642257: sched_stat_runtime:   comm=iperf pid=1284 runtime=135990 [ns] vruntime=2106884613 [ns]
           iperf-1284  [001]    90.642268: sched_switch:         iperf:1284 [120] R ==> irq/355-4848400:86 [49]
 irq/355-4848400-86    [001]    90.642275: softirq_raise:        vec=3 [action=NET_RX]
 irq/355-4848400-86    [001]    90.642286: softirq_entry:        vec=3 [action=NET_RX]
 irq/355-4848400-86    [001]    90.642319: softirq_exit:         vec=3 [action=NET_RX]
 irq/355-4848400-86    [001]    90.642345: sched_switch:         irq/355-4848400:86 [49] S ==> iperf:1284 [120]
 irq/354-4848400-85    [000]    90.642393: softirq_exit:         vec=3 [action=NET_RX]
 irq/354-4848400-85    [000]    90.642419: sched_switch:         irq/354-4848400:85 [49] S ==> rcuc/0:11 [98]
          rcuc/0-11    [000]    90.642430: irq_handler_entry:    irq=354 name=48484000.ethernet
          rcuc/0-11    [000]    90.642432: irq_handler_exit:     irq=354 ret=handled
          rcuc/0-11    [000]    90.642435: sched_waking:         comm=irq/354-4848400 pid=85 prio=49 target_cpu=000
          rcuc/0-11    [000]    90.642442: sched_migrate_task:   comm=irq/354-4848400 pid=85 prio=49 orig_cpu=0 dest_cpu=1
          rcuc/0-11    [000]    90.642453: sched_wakeup:         irq/354-4848400:85 [49] success=1 CPU:001
           iperf-1284  [001]    90.642462: sched_stat_runtime:   comm=iperf pid=1284 runtime=113053 [ns] vruntime=2106997666 [ns]
          rcuc/0-11    [000]    90.642464: irq_handler_entry:    irq=355 name=48484000.ethernet
          rcuc/0-11    [000]    90.642466: irq_handler_exit:     irq=355 ret=handled
          rcuc/0-11    [000]    90.642469: sched_waking:         comm=irq/355-4848400 pid=86 prio=49 target_cpu=001
           iperf-1284  [001]    90.642473: sched_switch:         iperf:1284 [120] R ==> irq/354-4848400:85 [49]
 irq/354-4848400-85    [001]    90.642481: softirq_raise:        vec=3 [action=NET_RX]
          rcuc/0-11    [000]    90.642483: sched_wakeup:         irq/355-4848400:86 [49] success=1 CPU:001
 irq/354-4848400-85    [001]    90.642493: softirq_entry:        vec=3 [action=NET_RX]
          rcuc/0-11    [000]    90.642497: sched_migrate_task:   comm=irq/355-4848400 pid=86 prio=49 orig_cpu=1 dest_cpu=0
          rcuc/0-11    [000]    90.642515: irq_handler_entry:    irq=354 name=48484000.ethernet
          rcuc/0-11    [000]    90.642516: irq_handler_exit:     irq=354 ret=handled
          rcuc/0-11    [000]    90.642533: sched_switch:         rcuc/0:11 [98] R ==> irq/355-4848400:86 [49]
 irq/355-4848400-86    [000]    90.642541: softirq_raise:        vec=3 [action=NET_RX]
 irq/355-4848400-86    [000]    90.642551: softirq_entry:        vec=3 [action=NET_RX]
 irq/355-4848400-86    [000]    90.642562: sched_pi_setprio:     comm=iperf pid=1284 oldprio=120 newprio=49
 irq/355-4848400-86    [000]    90.642593: sched_switch:         irq/355-4848400:86 [49] D ==> rcuc/0:11 [98]
          rcuc/0-11    [000]    90.642621: sched_switch:         rcuc/0:11 [98] S ==> ktimersoftd/0:4 [98]
   ktimersoftd/0-4     [000]    90.642631: softirq_entry:        vec=1 [action=TIMER]
   ktimersoftd/0-4     [000]    90.642647: softirq_exit:         vec=1 [action=TIMER]
   ktimersoftd/0-4     [000]    90.642665: sched_switch:         ktimersoftd/0:4 [98] S ==> ksoftirqd/0:3 [120]
     ksoftirqd/0-3     [000]    90.642692: sched_stat_runtime:   comm=ksoftirqd/0 pid=3 runtime=34486 [ns] vruntime=33313887612 [ns]
     ksoftirqd/0-3     [000]    90.642703: sched_switch:         ksoftirqd/0:3 [120] D ==> trace-cmd:1278 [120]
       trace-cmd-1278  [000]    90.642742: sched_waking:         comm=trace-cmd pid=1279 prio=120 target_cpu=001
       trace-cmd-1278  [000]    90.642755: sched_wakeup:         trace-cmd:1279 [120] success=1 CPU:001
 irq/354-4848400-85    [001]    90.643012: softirq_exit:         vec=3 [action=NET_RX]
       trace-cmd-1278  [000]    90.643020: sched_stat_runtime:   comm=trace-cmd pid=1278 runtime=328098 [ns] vruntime=554552351 [ns]
 irq/354-4848400-85    [001]    90.643021: softirq_raise:        vec=3 [action=NET_RX]
 irq/354-4848400-85    [001]    90.643031: softirq_entry:        vec=3 [action=NET_RX]
       trace-cmd-1278  [000]    90.643036: sched_switch:         trace-cmd:1278 [120] D ==> iperf:1282 [120]
           iperf-1282  [000]    90.643055: sched_stat_runtime:   comm=iperf pid=1282 runtime=34811 [ns] vruntime=560242796 [ns]
           iperf-1282  [000]    90.643068: sched_switch:         iperf:1282 [120] D ==> swapper/0:0 [120]
          <idle>-0     [000]    90.643079: bputs:                0xc003e7d4s: 58f67c094e488
          <idle>-0     [000]    90.643090: bprint:               softirq_check_pending_idle: NOHZ: 80



-- 
regards,
-grygorii

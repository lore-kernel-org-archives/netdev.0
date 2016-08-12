From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [4.4-RT PATCH RFC/RFT] drivers: net: cpsw: mark rx/tx irq as
 IRQF_NO_THREAD
Date: Fri, 12 Aug 2016 18:58:21 +0300
Message-ID: <a5d1bd8f-4219-4890-9e1e-d4bc4181eb57@ti.com>
References: <20160811161540.9613-1-grygorii.strashko@ti.com>
 <20160812083206.t7lvxpo44marwpf5@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Steven Rostedt <rostedt@goodmis.org>, <linux-omap@vger.kernel.org>,
	Alison Chaiken <alison@peloton-tech.com>,
	<linux-rt-users@vger.kernel.org>, <netdev@vger.kernel.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Return-path: <linux-rt-users-owner@vger.kernel.org>
In-Reply-To: <20160812083206.t7lvxpo44marwpf5@linutronix.de>
Sender: linux-rt-users-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sebastian,

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

Thankds for comment. You're right:
irq_thread()->irq_forced_thread_fn()->local_bh_enable()

but wouldn't here two wake_up_process() calls any way,
plus preempt_check_resched_rt() in napi_schedule().

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

Thanks a lot for comments.
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

I've reverted my patch an did requested experiments (some additional info below).

I do not see "sched: RT throttling activated" :(

root@am57xx-evm:~# ./net_perf.sh & cyclictest -m -Sp98 -q  -D4m
[1] 1301
# /dev/cpu_dma_latency set to 0us
Linux am57xx-evm 4.4.16-rt23-00321-ga195e6a-dirty #92 SMP PREEMPT RT Fri Aug 12 14:03:59 EEST 2016 armv7l GNU/Linux


------------------------------------------------------------
Server listening on TCP port 5001
TCP window size: 16.0 KByte (WARNING: requested 8.00 KByte)
------------------------------------------------------------
------------------------------------------------------------
Client connecting to 172.22.39.17, TCP port 5001
TCP window size: 16.0 KByte (WARNING: requested 8.00 KByte)
------------------------------------------------------------
[  3] local 172.22.39.21 port 47500 connected with 172.22.39.17 port 5001
[  5] local 172.22.39.21 port 5001 connected with 172.22.39.17 port 59955
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0-60.0 sec  1.31 GBytes   188 Mbits/sec
[  5]  0.0-60.0 sec   868 MBytes   121 Mbits/sec
------------------------------------------------------------
Server listening on TCP port 5001
TCP window size: 32.0 KByte (WARNING: requested 16.0 KByte)
------------------------------------------------------------
------------------------------------------------------------
Client connecting to 172.22.39.17, TCP port 5001
TCP window size: 32.0 KByte (WARNING: requested 16.0 KByte)
------------------------------------------------------------
[  5] local 172.22.39.21 port 47502 connected with 172.22.39.17 port 5001
[  4] local 172.22.39.21 port 5001 connected with 172.22.39.17 port 59957
[ ID] Interval       Transfer     Bandwidth
[  5]  0.0-60.0 sec  1.92 GBytes   275 Mbits/sec
[  4]  0.0-60.0 sec  1.14 GBytes   163 Mbits/sec
------------------------------------------------------------
Server listening on TCP port 5001
TCP window size: 64.0 KByte (WARNING: requested 32.0 KByte)
------------------------------------------------------------
------------------------------------------------------------
Client connecting to 172.22.39.17, TCP port 5001
TCP window size: 64.0 KByte (WARNING: requested 32.0 KByte)
------------------------------------------------------------
[  5] local 172.22.39.21 port 47504 connected with 172.22.39.17 port 5001
[  4] local 172.22.39.21 port 5001 connected with 172.22.39.17 port 59965
[ 2285.928516] NOHZ: local_softirq_pending 80
[ 2285.928549] NOHZ: local_softirq_pending 80
[ 2285.928594] NOHZ: local_softirq_pending 80
[ 2285.928689] NOHZ: local_softirq_pending 80
[ 2286.348572] NOHZ: local_softirq_pending 80
[ 2290.358623] NOHZ: local_softirq_pending 80
[ 2291.588624] NOHZ: local_softirq_pending 80
[ 2291.698579] NOHZ: local_softirq_pending 80
[ 2292.608594] NOHZ: local_softirq_pending 80
[ 2293.178627] NOHZ: local_softirq_pending 80
[ ID] Interval       Transfer     Bandwidth
[  5]  0.0-60.0 sec  1.43 GBytes   205 Mbits/sec
[  4]  0.0-60.0 sec  1.58 GBytes   226 Mbits/sec
------------------------------------------------------------
Server listening on TCP port 5001
TCP window size:  128 KByte (WARNING: requested 64.0 KByte)
------------------------------------------------------------
------------------------------------------------------------
Client connecting to 172.22.39.17, TCP port 5001
TCP window size:  128 KByte (WARNING: requested 64.0 KByte)
------------------------------------------------------------
[  5] local 172.22.39.21 port 47506 connected with 172.22.39.17 port 5001
[  4] local 172.22.39.21 port 5001 connected with 172.22.39.17 port 59980
T: 0 ( 1309) P:98 I:1000 C: 240000 Min:      8 Act:   13 Avg:   18 Max:      60
T: 1 ( 1310) P:98 I:1500 C: 159968 Min:      8 Act:   14 Avg:   16 Max:      58
root@am57xx-evm:~# [ ID] Interval       Transfer     Bandwidth
[  5]  0.0-60.0 sec  1.84 GBytes   264 Mbits/sec
[  4]  0.0-60.0 sec  1.47 GBytes   210 Mbits/sec
------------------------------------------------------------
Server listening on TCP port 5001
TCP window size:  256 KByte (WARNING: requested  128 KByte)
------------------------------------------------------------
------------------------------------------------------------
Client connecting to 172.22.39.17, TCP port 5001
TCP window size:  256 KByte (WARNING: requested  128 KByte)
------------------------------------------------------------
[  5] local 172.22.39.21 port 47508 connected with 172.22.39.17 port 5001
[  4] local 172.22.39.21 port 5001 connected with 172.22.39.17 port 59982
[ ID] Interval       Transfer     Bandwidth
[  5]  0.0-60.0 sec   974 MBytes   136 Mbits/sec
[  4]  0.0-60.0 sec  2.84 GBytes   406 Mbits/sec

[1]+  Done                    ./net_perf.sh



> 
>> 2) latency reduction when cyclictest is run in parallel with network load
>>  where net_perf.sh is:
>>    iperf -c $IPERFHOST -w 8K    -d -t 60
>>    iperf -c $IPERFHOST -w 16K   -d -t 60
>>    iperf -c $IPERFHOST -w 32K   -d -t 60
>>    iperf -c $IPERFHOST -w 64K   -d -t 60
>>    iperf -c $IPERFHOST -w 128K  -d -t 60
>>
>> before:
>> T: 0 ( 1326) P:98 I:1000 C: 240000 Min:      8 Act:   13 Avg:   18 Max:      70
>> T: 1 ( 1327) P:98 I:1500 C: 159981 Min:      9 Act:   15 Avg:   16 Max:      43
>> after:
>> T: 0 ( 1331) P:98 I:1000 C: 240000 Min:      8 Act:   15 Avg:   14 Max:      51
>> T: 1 ( 1332) P:98 I:1500 C: 159953 Min:      8 Act:   16 Avg:   15 Max:      33
> 
> -d 0 to have I: set to the same value.
> What does -i 250 say?
> And without network load we are where we were at "after" values?

=============================================== before, no net load:
cyclictest -m -Sp98 -q  -D4m
# /dev/cpu_dma_latency set to 0us
T: 0 ( 1270) P:98 I:1000 C: 240000 Min:      8 Act:   10 Avg:    9 Max:      38
T: 1 ( 1271) P:98 I:1500 C: 159986 Min:      8 Act:   10 Avg:    9 Max:      23

cyclictest -m -Sp98 -q  -D4m -d0
# /dev/cpu_dma_latency set to 0us
T: 0 ( 1280) P:98 I:1000 C: 240000 Min:      8 Act:   10 Avg:    9 Max:      27
T: 1 ( 1281) P:98 I:1000 C: 239982 Min:      8 Act:   13 Avg:    9 Max:      26

cyclictest -m -Sp98 -q  -D4m -i250
# /dev/cpu_dma_latency set to 0us
T: 0 ( 1284) P:98 I:250 C: 960000 Min:      8 Act:   10 Avg:    8 Max:      24
T: 1 ( 1285) P:98 I:750 C: 319977 Min:      8 Act:   11 Avg:    9 Max:      21

cyclictest -m -Sp98 -q  -D4m -i250 -d0
# /dev/cpu_dma_latency set to 0us
T: 0 ( 1288) P:98 I:250 C: 960000 Min:      8 Act:    9 Avg:    8 Max:      33
T: 1 ( 1289) P:98 I:250 C: 959929 Min:      7 Act:   11 Avg:    9 Max:      26

=============================================== before, with net load:
cyclictest -m -Sp98 -q  -D4m
T: 0 ( 1309) P:98 I:1000 C: 240000 Min:      8 Act:   13 Avg:   18 Max:      60
T: 1 ( 1310) P:98 I:1500 C: 159968 Min:      8 Act:   14 Avg:   16 Max:      58

cyclictest -m -Sp98 -q -D4m -d0
T: 0 ( 1339) P:98 I:1000 C: 240000 Min:      8 Act:   28 Avg:   18 Max:      60
T: 1 ( 1340) P:98 I:1000 C: 239969 Min:      8 Act:   25 Avg:   16 Max:      43

cyclictest -m -Sp98 -q -D4m -i250
T: 0 ( 1369) P:98 I:250 C: 960000 Min:      8 Act:   13 Avg:   17 Max:      64
T: 1 ( 1370) P:98 I:750 C: 319941 Min:      8 Act:   18 Avg:   16 Max:      56

cyclictest -m -Sp98 -q -D4m -i250 -d0
T: 0 ( 1400) P:98 I:250 C: 960000 Min:      8 Act:   25 Avg:   18 Max:      83
T: 1 ( 1401) P:98 I:250 C: 959801 Min:      7 Act:   27 Avg:   17 Max:      48

=============================================== after, no net load:

cyclictest -m -Sp98 -q  -D4m 
T: 0 ( 1287) P:98 I:1000 C: 240000 Min:      8 Act:   10 Avg:    9 Max:      30
T: 1 ( 1288) P:98 I:1500 C: 159987 Min:      8 Act:   13 Avg:   10 Max:      32

cyclictest -m -Sp98 -q -D4m -d0  
T: 0 ( 1295) P:98 I:1000 C: 240000 Min:      8 Act:    8 Avg:    9 Max:      39
T: 1 ( 1296) P:98 I:1000 C: 239981 Min:      7 Act:    9 Avg:    8 Max:      29

cyclictest -m -Sp98 -q  -D4m -i250
T: 0 ( 1298) P:98 I:250 C: 960000 Min:      7 Act:    8 Avg:    9 Max:      42
T: 1 ( 1299) P:98 I:750 C: 319970 Min:      8 Act:    9 Avg:    8 Max:      29

cyclictest -m -Sp98 -q  -D4m -i250 -d0
T: 0 ( 1301) P:98 I:250 C: 960000 Min:      7 Act:    9 Avg:    8 Max:      22
T: 1 ( 1302) P:98 I:250 C: 959914 Min:      7 Act:   11 Avg:    8 Max:      28

=============================================== after, with net load:
cyclictest -m -Sp98 -q  -D4m 
T: 0 ( 1315) P:98 I:1000 C: 240000 Min:      8 Act:   11 Avg:   14 Max:      40
T: 1 ( 1316) P:98 I:1500 C: 159962 Min:      8 Act:   19 Avg:   15 Max:      38


cyclictest -m -Sp98 -q -D4m -d0  
T: 0 ( 1365) P:98 I:1000 C: 240000 Min:      8 Act:   14 Avg:   15 Max:      51
T: 1 ( 1366) P:98 I:1000 C: 239943 Min:      8 Act:   18 Avg:   15 Max:      36

cyclictest -m -Sp98 -q  -D4m -i250
T: 0 ( 1309) P:98 I:250 C: 960000 Min:      8 Act:   15 Avg:   13 Max:      42
T: 1 ( 1310) P:98 I:750 C: 319986 Min:      8 Act:   18 Avg:   15 Max:      36

cyclictest -m -Sp98 -q  -D4m -i250 -d0
T: 0 ( 1358) P:98 I:250 C: 960000 Min:      8 Act:   11 Avg:   14 Max:      42
T: 1 ( 1359) P:98 I:250 C: 959743 Min:      7 Act:   18 Avg:   15 Max:      36

> 
> What happens if s/__raise_softirq_irqoff_ksoft/__raise_softirq_irqoff/
> in net/core/dev.c and chrt the priority of you network interrupt
> handlers to SCHED_OTHER priority?

===== without this patch + __raise_softirq_irqoff + netIRQs->SCHED_OTHER

with net load:
cyclictest -m -Sp98 -q -D4m -i250 -d0
T: 0 ( 1325) P:98 I:1000 C: 240000 Min:      8 Act:   22 Avg:   17 Max:      51
T: 1 ( 1326) P:98 I:1500 C: 159981 Min:      8 Act:   15 Avg:   15 Max:      39

cyclictest -m -Sp98 -q  -D4m -i250 -d0
T: 0 ( 1307) P:98 I:250 C: 960000 Min:      7 Act:   13 Avg:   16 Max:      50
T: 1 ( 1308) P:98 I:250 C: 959819 Min:      8 Act:   12 Avg:   14 Max:      37

and net parformance is better:
root@am57xx-evm:~# ps -A | grep 4848
   82 ?        00:00:00 irq/354-4848400
   83 ?        00:00:00 irq/355-4848400
root@am57xx-evm:~# chrt -o -p 0 82
root@am57xx-evm:~# chrt -o -p 0 83
./net_perf.sh & cyclictest -m -Sp98 -q  -D4m -i250 -d0
[1] 1298
# /dev/cpu_dma_latency set to 0us
Linux am57xx-evm 4.4.16-rt23-00321-ga195e6a-dirty #95 SMP PREEMPT RT Fri Aug 12 16:20:42 EEST 2016 armv7l GNU/Linux


------------------------------------------------------------
Server listening on TCP port 5001
TCP window size: 16.0 KByte (WARNING: requested 8.00 KByte)
------------------------------------------------------------
------------------------------------------------------------
Client connecting to 172.22.39.17, TCP port 5001
TCP window size: 16.0 KByte (WARNING: requested 8.00 KByte)
------------------------------------------------------------
[  3] local 172.22.39.21 port 58672 connected with 172.22.39.17 port 5001
[  5] local 172.22.39.21 port 5001 connected with 172.22.39.17 port 60672
[   78.718828] NOHZ: local_softirq_pending 80
[   78.908849] NOHZ: local_softirq_pending 80
[   78.908927] NOHZ: local_softirq_pending 80
[   78.918827] NOHZ: local_softirq_pending 80
[   79.058826] NOHZ: local_softirq_pending 80
[   81.488918] NOHZ: local_softirq_pending 80
[   81.489162] NOHZ: local_softirq_pending 80
[   81.489398] NOHZ: local_softirq_pending 80
[   81.489646] NOHZ: local_softirq_pending 80
[   81.489895] NOHZ: local_softirq_pending 80
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0-60.0 sec  1.30 GBytes   187 Mbits/sec
[  5]  0.0-60.0 sec   637 MBytes  89.0 Mbits/sec
------------------------------------------------------------
Server listening on TCP port 5001
TCP window size: 32.0 KByte (WARNING: requested 16.0 KByte)
------------------------------------------------------------
------------------------------------------------------------
Client connecting to 172.22.39.17, TCP port 5001
TCP window size: 32.0 KByte (WARNING: requested 16.0 KByte)
------------------------------------------------------------
[  5] local 172.22.39.21 port 58674 connected with 172.22.39.17 port 5001
[  4] local 172.22.39.21 port 5001 connected with 172.22.39.17 port 60680
[ ID] Interval       Transfer     Bandwidth
[  5]  0.0-60.0 sec  1.78 GBytes   255 Mbits/sec
[  4]  0.0-60.0 sec  1.47 GBytes   210 Mbits/sec
------------------------------------------------------------
Server listening on TCP port 5001
TCP window size: 64.0 KByte (WARNING: requested 32.0 KByte)
------------------------------------------------------------
------------------------------------------------------------
Client connecting to 172.22.39.17, TCP port 5001
TCP window size: 64.0 KByte (WARNING: requested 32.0 KByte)
------------------------------------------------------------
[  5] local 172.22.39.21 port 58676 connected with 172.22.39.17 port 5001
[  4] local 172.22.39.21 port 5001 connected with 172.22.39.17 port 60693
[ ID] Interval       Transfer     Bandwidth
[  5]  0.0-60.0 sec  1.62 GBytes   232 Mbits/sec
[  4]  0.0-60.0 sec  2.07 GBytes   296 Mbits/sec
------------------------------------------------------------
Server listening on TCP port 5001
TCP window size:  128 KByte (WARNING: requested 64.0 KByte)
------------------------------------------------------------
------------------------------------------------------------
Client connecting to 172.22.39.17, TCP port 5001
TCP window size:  128 KByte (WARNING: requested 64.0 KByte)
------------------------------------------------------------
[  5] local 172.22.39.21 port 58678 connected with 172.22.39.17 port 5001
[  4] local 172.22.39.21 port 5001 connected with 172.22.39.17 port 60702
T: 0 ( 1307) P:98 I:250 C: 960000 Min:      7 Act:   13 Avg:   16 Max:      50
T: 1 ( 1308) P:98 I:250 C: 959819 Min:      8 Act:   12 Avg:   14 Max:      37
root@am57xx-evm:~# [ ID] Interval       Transfer     Bandwidth
[  5]  0.0-60.0 sec  1.77 GBytes   254 Mbits/sec
[  4]  0.0-60.0 sec  1.77 GBytes   253 Mbits/sec
------------------------------------------------------------
Server listening on TCP port 5001
TCP window size:  256 KByte (WARNING: requested  128 KByte)
------------------------------------------------------------
------------------------------------------------------------
Client connecting to 172.22.39.17, TCP port 5001
TCP window size:  256 KByte (WARNING: requested  128 KByte)
------------------------------------------------------------
[  5] local 172.22.39.21 port 58680 connected with 172.22.39.17 port 5001
[  4] local 172.22.39.21 port 5001 connected with 172.22.39.17 port 60711
[ ID] Interval       Transfer     Bandwidth
[  5]  0.0-60.0 sec  2.18 GBytes   312 Mbits/sec
[  4]  0.0-60.0 sec  2.53 GBytes   362 Mbits/sec


> 
>> 3) network performance increase
>>
>> win, K	Mbits/s
>> 	before	after	%
>> 8K	354	350.3	0.0
>> 16K	412	551	33.7 
>> 32K	423	659.5	55.9 
>> 64K	436	728.3	67.0 
>> 128K	537	845	57.4 
> 
> How close are the after numbers to !RT?

http://processors.wiki.ti.com/index.php/Processor_SDK_Linux_Kernel_Performance_Guide#AM57XX_TCP_Performance

Min 20% drop even with this patch :(

-- 
regards,
-grygorii


========================= ps -l -A (after boot)
root@am57xx-evm:~# ps -l -A
F S   UID   PID  PPID  C PRI  NI ADDR SZ WCHAN  TTY          TIME CMD
4 S     0     1     0  1  80   0 -  1321 SyS_ep ?        00:00:05 systemd
1 S     0     2     0  0  80   0 -     0 kthrea ?        00:00:00 kthreadd
1 S     0     3     2  0  80   0 -     0 smpboo ?        00:00:00 ksoftirqd/0
5 S     0     4     2  0  58   - -     0 smpboo ?        00:00:00 ktimersoftd/0
1 S     0     5     2  0  80   0 -     0 worker ?        00:00:00 kworker/0:0
1 S     0     6     2  0  60 -20 -     0 worker ?        00:00:00 kworker/0:0H
1 S     0     7     2  0  80   0 -     0 worker ?        00:00:00 kworker/u4:0
1 S     0     8     2  0  58   - -     0 rcu_gp ?        00:00:00 rcu_preempt
1 S     0     9     2  0  58   - -     0 rcu_gp ?        00:00:00 rcu_sched
1 S     0    10     2  0  58   - -     0 rcu_bo ?        00:00:00 rcub/0
1 S     0    11     2  0  58   - -     0 smpboo ?        00:00:00 rcuc/0
1 S     0    12     2  0  80   0 -     0 run_cl ?        00:00:00 kclksetdelayd
1 S     0    13     2  0 -40   - -     0 posix_ ?        00:00:00 posixcputmr/0
1 S     0    14     2  0  80   0 -     0 run_cm ?        00:00:00 kcmosdelayd
1 S     0    15     2  0 -40   - -     0 smpboo ?        00:00:00 migration/0
1 S     0    16     2  0 -40   - -     0 smpboo ?        00:00:00 migration/1
1 S     0    17     2  0  58   - -     0 smpboo ?        00:00:00 rcuc/1
5 S     0    18     2  0  58   - -     0 smpboo ?        00:00:00 ktimersoftd/1
1 S     0    19     2  0  80   0 -     0 smpboo ?        00:00:00 ksoftirqd/1
1 S     0    20     2  0 -40   - -     0 posix_ ?        00:00:00 posixcputmr/1
1 S     0    21     2  0  80   0 -     0 worker ?        00:00:00 kworker/1:0
1 S     0    22     2  0  60 -20 -     0 worker ?        00:00:00 kworker/1:0H
5 S     0    23     2  0  80   0 -     0 devtmp ?        00:00:00 kdevtmpfs
1 S     0    24     2  0  80   0 -     0 swork_ ?        00:00:00 kswork
1 S     0    25     2  0  60 -20 -     0 rescue ?        00:00:00 perf
1 S     0    26     2  0   9   - -     0 irq_th ?        00:00:00 irq/37-4ae10000
1 S     0    27     2  0  80   0 -     0 worker ?        00:00:00 kworker/0:1
1 S     0    28     2  0   9   - -     0 irq_th ?        00:00:00 irq/70-48055000
1 S     0    29     2  0   9   - -     0 irq_th ?        00:00:00 irq/103-4805700
1 S     0    30     2  0   9   - -     0 irq_th ?        00:00:00 irq/136-4805900
1 S     0    31     2  0   9   - -     0 irq_th ?        00:00:00 irq/169-4805b00
1 S     0    32     2  0   9   - -     0 irq_th ?        00:00:00 irq/202-4805d00
1 S     0    33     2  0   9   - -     0 irq_th ?        00:00:00 irq/235-4805100
1 S     0    34     2  0   9   - -     0 irq_th ?        00:00:00 irq/268-4805300
1 S     0    35     2  0  60 -20 -     0 rescue ?        00:00:00 writeback
1 S     0    36     2  0  60 -20 -     0 rescue ?        00:00:00 crypto
1 S     0    37     2  0  60 -20 -     0 rescue ?        00:00:00 bioset
1 S     0    38     2  0  60 -20 -     0 rescue ?        00:00:00 kblockd
1 S     0    39     2  0   9   - -     0 irq_th ?        00:00:00 irq/29-omap-dma
1 S     0    40     2  0   9   - -     0 irq_th ?        00:00:00 irq/32-43300000
1 S     0    41     2  0   9   - -     0 irq_th ?        00:00:00 irq/34-43300000
1 S     0    42     2  0   9   - -     0 irq_th ?        00:00:00 irq/343-40d0100
1 S     0    43     2  0   9   - -     0 irq_th ?        00:00:00 irq/344-40d0200
1 S     0    44     2  0   9   - -     0 irq_th ?        00:00:00 irq/345-5888200
1 S     0    45     2  0   9   - -     0 irq_th ?        00:00:00 irq/346-5508200
1 S     0    46     2  0   9   - -     0 irq_th ?        00:00:00 irq/363-4150100
1 S     0    47     2  0   9   - -     0 irq_th ?        00:00:00 irq/364-4150200
1 S     0    48     2  0   9   - -     0 irq_th ?        00:00:00 irq/337-4807000
1 S     0    49     2  0   9   - -     0 irq_th ?        00:00:00 irq/38-palmas
1 S     0    50     2  0   9   - -     0 irq_th ?        00:00:00 irq/338-4806000
1 S     0    51     2  0   9   - -     0 irq_th ?        00:00:00 irq/339-4807c00
1 S     0    52     2  0  60 -20 -     0 rescue ?        00:00:00 edac-poller
1 S     0    53     2  0  60 -20 -     0 rescue ?        00:00:00 rpciod
1 S     0    54     2  0  80   0 -     0 kswapd ?        00:00:00 kswapd0
1 S     0    55     2  0  60 -20 -     0 rescue ?        00:00:00 vmstat
1 S     0    56     2  0  80   0 -     0 fsnoti ?        00:00:00 fsnotify_mark
1 S     0    57     2  0  60 -20 -     0 rescue ?        00:00:00 nfsiod
1 S     0    66     2  0   9   - -     0 irq_th ?        00:00:00 irq/25-dra7xx-p
1 S     0    67     2  0   9   - -     0 irq_th ?        00:00:00 irq/437-PCIe PM
1 S     0    68     2  0   9   - -     0 irq_th ?        00:00:00 irq/437-aerdrv
1 S     0    69     2  0   9   - -     0 irq_th ?        00:00:00 irq/370-OMAP HD
1 S     0    70     2  0  60 -20 -     0 rescue ?        00:00:00 bioset
1 S     0    71     2  0  60 -20 -     0 rescue ?        00:00:00 bioset
1 S     0    72     2  0  60 -20 -     0 rescue ?        00:00:00 bioset
1 S     0    73     2  0  60 -20 -     0 rescue ?        00:00:00 bioset
1 S     0    74     2  0  60 -20 -     0 rescue ?        00:00:00 bioset
1 S     0    75     2  0  60 -20 -     0 rescue ?        00:00:00 bioset
1 S     0    76     2  0  60 -20 -     0 rescue ?        00:00:00 bioset
1 S     0    77     2  0  60 -20 -     0 rescue ?        00:00:00 bioset
1 S     0    78     2  0  80   0 -     0 worker ?        00:00:00 kworker/u4:1
1 S     0    81     2  0  80   0 -     0 worker ?        00:00:01 kworker/1:1
1 S     0    82     2  0   9   - -     0 irq_th ?        00:00:00 irq/354-4848400
1 S     0    83     2  0   9   - -     0 irq_th ?        00:00:00 irq/355-4848400
1 S     0    84     2  0  60 -20 -     0 rescue ?        00:00:00 kpsmoused
1 S     0    85     2  0   9   - -     0 irq_th ?        00:00:00 irq/27-talert
1 S     0    86     2  0   9   - -     0 irq_th ?        00:00:00 irq/340-mmc0
1 S     0    87     2  0   9   - -     0 irq_th ?        00:00:00 irq/230-4809c00
1 S     0    88     2  0   9   - -     0 irq_th ?        00:00:00 irq/341-mmc1
1 S     0    89     2  0   9   - -     0 irq_th ?        00:00:00 irq/342-mmc2
1 S     0    90     2  0   9   - -     0 irq_th ?        00:00:00 irq/352-4846800
1 S     0    91     2  0   9   - -     0 irq_th ?        00:00:00 irq/351-4846800
1 S     0    92     2  0  60 -20 -     0 rescue ?        00:00:00 ipv6_addrconf
1 S     0    93     2  0   9   - -     0 irq_th ?        00:00:00 irq/335-omap_dm
1 S     0    94     2  0   9   - -     0 irq_th ?        00:00:00 irq/369-OMAP DI
1 S     0    95     2  0  60 -20 -     0 rescue ?        00:00:00 bioset
1 S     0    96     2  0  80   0 -     0 mmc_qu ?        00:00:00 mmcqd/0
1 S     0    97     2  0  60 -20 -     0 rescue ?        00:00:00 bioset
1 S     0    98     2  0  80   0 -     0 mmc_qu ?        00:00:00 mmcqd/1
1 S     0    99     2  0  60 -20 -     0 rescue ?        00:00:00 bioset
1 S     0   100     2  0  80   0 -     0 mmc_qu ?        00:00:00 mmcqd/1boot0
1 S     0   101     2  0  60 -20 -     0 rescue ?        00:00:00 bioset
1 S     0   102     2  0  80   0 -     0 mmc_qu ?        00:00:00 mmcqd/1boot1
1 S     0   103     2  0  60 -20 -     0 rescue ?        00:00:00 deferwq
1 S     0   104     2  0   9   - -     0 irq_th ?        00:00:00 irq/94-Up
1 S     0   105     2  0   9   - -     0 irq_th ?        00:00:00 irq/96-Down
1 S     0   106     2  0   9   - -     0 irq_th ?        00:00:00 irq/99-Left
1 S     0   107     2  0   9   - -     0 irq_th ?        00:00:00 irq/95-Right
1 S     0   110     2  0  60 -20 -     0 worker ?        00:00:00 kworker/1:1H
1 S     0   111     2  0  80   0 -     0 kjourn ?        00:00:00 jbd2/mmcblk0p2-
1 S     0   112     2  0  60 -20 -     0 rescue ?        00:00:00 ext4-rsv-conver
1 S     0   129     2  0  60 -20 -     0 worker ?        00:00:00 kworker/0:1H
1 S     0   165     2  0  80   0 -     0 worker ?        00:00:00 kworker/0:2
1 S     0   168     2  0  80   0 -     0 worker ?        00:00:00 kworker/1:2
4 S     0   197     1  0  80   0 -  2566 SyS_ep ?        00:00:01 systemd-journal
1 S     0   249     2  0  80   0 -     0 worker ?        00:00:00 kworker/u4:2
1 S     0   255     2  0  80   0 -     0 worker ?        00:00:00 kworker/0:3
4 S     0   289     1  0  80   0 -  2731 SyS_ep ?        00:00:02 systemd-udevd
1 S     0   330     2  0  80   0 -     0 worker ?        00:00:00 kworker/0:4
1 S     0   339     2  0  80   0 -     0 worker ?        00:00:00 kworker/0:5
1 S     0   387     2  0   9   - -     0 irq_th ?        00:00:00 irq/362-4809000
1 S     0   407     2  0   9   - -     0 irq_th ?        00:00:00 irq/470-2-006f
1 S     0   409     2  0   9   - -     0 irq_th ?        00:00:00 irq/469-mcp7941
1 S     0   413     2  0   9   - -     0 irq_th ?        00:00:00 irq/75-pixcir_t
4 S   998   418     1  0  80   0 -  3038 SyS_ep ?        00:00:00 systemd-timesyn
1 S     0   429     2  0   9   - -     0 irq_th ?        00:00:00 irq/158-palmas_
1 S     0   462     2  0   9   - -     0 irq_th ?        00:00:00 irq/348-rtc2
1 S     0   464     2  0   9   - -     0 irq_th ?        00:00:00 irq/349-dwc3-om
1 S     0   466     2  0   9   - -     0 irq_th ?        00:00:00 irq/350-dwc3-om
1 S     0   493     2  0   9   - -     0 irq_th ?        00:00:00 irq/357-vpe
1 S     0   503     2  0  60 -20 -     0 rescue ?        00:00:00 ata_sff
1 S     0   509     2  0   9   - -     0 irq_th ?        00:00:00 irq/365-vip2-s0
1 S     0   510     2  0   9   - -     0 irq_th ?        00:00:00 irq/366-vip2-s1
1 S     0   514     2  0   9   - -     0 irq_th ?        00:00:00 irq/347-4a14000
1 S     0   516     2  0  80   0 -     0 scsi_e ?        00:00:00 scsi_eh_0
1 S     0   517     2  0  60 -20 -     0 rescue ?        00:00:00 scsi_tmf_0
1 S     0   595     2  0   9   - -     0 irq_th ?        00:00:00 irq/361-4b10100
1 S     0   605     2  0  80   0 -     0 worker ?        00:00:00 kworker/u4:3
4 S     0   765     1  0  80   0 -   498 poll_s ?        00:00:00 starter
4 S     0   792     1  0  80   0 -   497 syslog ?        00:00:00 klogd
4 S     0   819     1  0  80   0 -  2210 poll_s ?        00:00:01 ofonod
1 S     0   825     2  0  80   0 -     0 worker ?        00:00:02 kworker/1:3
1 S     0   887     2  0   9   - -     0 irq_th ?        00:00:00 irq/313-mbox_ip
4 S     0   900   765  0  80   0 - 35826 sigtim ?        00:00:00 charon
4 S   995   901     1  0  80   0 -  1164 poll_s ?        00:00:00 avahi-daemon
1 S     0   902     2  0   9   - -     0 irq_th ?        00:00:00 irq/317-mbox_ip
1 S     0   903     2  0   9   - -     0 irq_th ?        00:00:00 irq/321-rproc-w
1 S     0   904     2  0   9   - -     0 irq_th ?        00:00:00 irq/326-rproc-w
1 S     0   909     2  0   9   - -     0 irq_th ?        00:00:00 irq/313-mbox_ds
1 S   995   910   901  0  80   0 -  1164 unix_s ?        00:00:00 avahi-daemon
4 S     0   911     1  0  80   0 -   501 skb_re ?        00:00:00 syslogd
1 S     0   912     2  0   9   - -     0 irq_th ?        00:00:00 irq/317-mbox_ds
1 S     0   929     2  0   9   - -     0 irq_th ?        00:00:00 irq/490-remotep
1 S     0   930     2  0   9   - -     0 irq_th ?        00:00:00 irq/492-remotep
1 S     0   931     2  0   9   - -     0 irq_th ?        00:00:00 irq/494-remotep
1 S     0   934     2  0   9   - -     0 irq_th ?        00:00:00 irq/496-remotep
4 S   999   938     1  0  80   0 -  1080 SyS_ep ?        00:00:00 dbus-daemon
4 S   997   948     1  0  80   0 -  2725 SyS_ep ?        00:00:00 systemd-network
4 S     0   970     1  0  80   0 -   656 SyS_ep ?        00:00:00 systemd-logind
1 S     0  1006     2  0   9   - -     0 irq_th ?        00:00:00 irq/472-xhci-hc
4 S     0  1035     1  0  80   0 -  1221 wait   ttyS2    00:00:00 login
4 S     0  1036     1  0  80   0 -   447 poll_s tty1     00:00:00 agetty
4 S   996  1040     1  0  80   0 -   754 SyS_ep ?        00:00:00 systemd-resolve
4 S     0  1048     1  0  80   0 -  1143 SyS_ep ?        00:00:00 lighttpd
5 S     0  1176     1  0  80   0 -   497 poll_s ?        00:00:00 telnetd
5 S     0  1177     1  0  80   0 -  2441 pipe_w ?        00:00:00 lad_dra7xx
5 S 65534  1190     1  0  80   0 -   614 poll_s ?        00:00:00 thttpd
5 S     0  1199     1  0  80   0 -   581 poll_s ?        00:00:00 rngd
1 S     0  1241     2  0   9   - -     0 irq_th ?        00:00:00 irq/91-48020000
1 S     0  1242     2  0   9   - -     0 irq_th ?        00:00:00 irq/301-4802000
4 S     0  1248     1  0  80   0 -  1354 SyS_ep ?        00:00:00 systemd
5 S     0  1252  1248  0  80   0 -  1854 sigtim ?        00:00:00 (sd-pam)
4 S     0  1259  1035  0  80   0 -   676 wait   ttyS2    00:00:00 sh
0 R     0  1263  1259  0  80   0 -   553 -      ttyS2    00:00:00 ps

========================= /proc/interrupts & /proc/softirqs (after boot)
root@am57xx-evm:~# cat /proc/interrupts 
           CPU0       CPU1       
 16:          0          0      CBAR  32 Level     gp_timer
 19:      30322      29398       GIC  27 Edge      arch_timer
 22:          0          0      CBAR   4 Level     l3-dbg-irq
 23:          0          0     WUGEN  10 Level     l3-app-irq
 25:          7          0      CBAR 232 Level     dra7xx-pcie-main
 26:          0          0      CBAR 233 Level     dra7-pcie-msi
 27:          1          0      CBAR 121 Level     talert
 29:         57          0      CBAR   8 Level     omap-dma-engine
 32:        583          0      CBAR 361 Level     43300000.edma_ccint
 34:          0          0      CBAR 359 Level     43300000.edma_ccerrint
 37:          0          0      CBAR  24 Level     4ae10000.gpio
 38:          0          0  4ae10000.gpio   0 Level     palmas
 70:          1          0      CBAR  25 Level     48055000.gpio
 75:          0          1  48055000.gpio   4 Edge      pixcir_tangoc
 91:          0          0  48055000.gpio  20 Edge      48020000.serial
 94:          0          0  48055000.gpio  23 Edge      Up
 95:          0          0  48055000.gpio  24 Edge      Right
 96:          0          0  48055000.gpio  25 Edge      Down
 99:          0          0  48055000.gpio  28 Edge      Left
103:          0          0      CBAR  26 Level     48057000.gpio
136:          0          0      CBAR  27 Level     48059000.gpio
158:          0          0  48059000.gpio  21 Edge      palmas_usb_vbus
169:          0          0      CBAR  28 Level     4805b000.gpio
202:          0          0      CBAR  29 Level     4805d000.gpio
230:          0          0  4805d000.gpio  27 Edge      4809c000.mmc cd
235:          0          0      CBAR  30 Level     48051000.gpio
268:          0          0      CBAR 116 Level     48053000.gpio
301:        552          0      CBAR  69 Level     48020000.serial
313:         50          0      CBAR 251 Level     mbox_ipu1_ipc3x, mbox_dsp1_ipc3x
317:         60          0      CBAR 255 Level     mbox_ipu2_ipc3x, mbox_dsp2_ipc3x
321:          0          0      CBAR  35 Level     rproc-wdt
326:          0          0      CBAR  40 Level     rproc-wdt
335:          8          0      CBAR 108 Level     omap_dmm_irq_handler
337:       1888          0      CBAR  51 Level     48070000.i2c
338:         40          0      CBAR  56 Level     48060000.i2c
339:         28          0      CBAR  55 Level     4807c000.i2c
340:      12831          0      CBAR  78 Level     mmc0
341:       1473          0      CBAR  81 Level     mmc1
342:         13          0      CBAR  89 Level     mmc2
343:          0          0      CBAR  23 Level     40d01000.mmu
344:          0          0      CBAR 145 Level     40d02000.mmu
345:          0          0      CBAR 395 Level     58882000.mmu
346:          0          0      CBAR 396 Level     55082000.mmu
347:          0          0      CBAR  49 Level     4a140000.sata
348:          0          0      CBAR 217 Level     rtc2
349:          5          0      CBAR  72 Level     dwc3-omap
350:          2          0      CBAR  87 Level     dwc3-omap
351:          0          0      CBAR 151 Level     48468000.mcasp_tx
352:          0          0      CBAR 150 Level     48468000.mcasp_rx
354:         24          0      CBAR 335 Level     48484000.ethernet
355:         67          0      CBAR 336 Level     48484000.ethernet
357:          0          0      CBAR 354 Level     vpe
361:         20          0      CBAR  46 Level     4b101000.sham
362:          0          0      CBAR  47 Level     48090000.rng
363:          0          0      CBAR 146 Level     41501000.mmu
364:          0          0      CBAR 147 Level     41502000.mmu
365:          0          0      CBAR 352 Level     vip2-s0
366:          0          0      CBAR 393 Level     vip2-s1
369:      16949          0      CBAR  20 Level     OMAP DISPC
370:          0          0      CBAR  96 Level     OMAP HDMI
435:          0          0    palmas   8 Edge      48070000.i2c:tps659038@58:tps659038_rtc
437:          0          0   PCI-MSI   0 Edge      PCIe PME, aerdrv
469:          0          0      CBAR   2 Edge      mcp7941x
470:          0          0   pinctrl 1060 Edge      2-006f
472:         66          0      CBAR  71 Level     xhci-hcd:usb1
490:          1          0  4b220000.intc  16 Edge      remoteproc4
492:          1          0  4b220000.intc  18 Edge      remoteproc5
494:          1          0  4b2a0000.intc  16 Edge      remoteproc6
496:          1          0  4b2a0000.intc  18 Edge      remoteproc7
IPI0:          0          1  CPU wakeup interrupts
IPI1:          0          0  Timer broadcast interrupts
IPI2:      48241      64393  Rescheduling interrupts
IPI3:          0          0  Function call interrupts
IPI4:        432        620  Single function call interrupts
IPI5:          0          0  CPU stop interrupts
IPI6:          0          0  IRQ work interrupts
IPI7:          0          0  completion interrupts
Err:          0
root@am57xx-evm:~# cat /proc/softirqs 
                    CPU0       CPU1       
          HI:          0          2
       TIMER:      29167      29156
      NET_TX:          0         57
      NET_RX:        123         86
       BLOCK:          0          0
BLOCK_IOPOLL:          0          0
     TASKLET:        406        386
       SCHED:      28322      28253
     HRTIMER:        609        384
         RCU:          0          0


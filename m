From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: REDIRECT in nat OUTPUT
Date: Sat, 12 Jul 2008 16:55:44 +0300
Message-ID: <200807121655.44547.denys@visp.net.lb>
References: <200807120424.56462.denys@visp.net.lb> <20080712062812.GA7609@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:56476 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752325AbYGLNzx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jul 2008 09:55:53 -0400
In-Reply-To: <20080712062812.GA7609@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is nothing unusual on oprofile. And seems it is not CPU bottleneck, while i am doing tests it is not loaded 100% (i am using mpstat 1 -P ALL to measure that).
But i will show first significant lines, if you want i can give full oprofile output, but i dont think it's matter.
PU: Core 2, speed 2394 MHz (estimated)
Counted CPU_CLK_UNHALTED events (Clock cycles when not halted) with a unit mask
of 0x00 (Unhalted core cycles) count 100000
CPU_CLK_UNHALT...|
  samples|      %|
------------------
   421239 97.5732 vmlinux
     6834  1.5830 iperf

CPU: Core 2, speed 2394 MHz (estimated)
Counted CPU_CLK_UNHALTED events (Clock cycles when not halted) with a unit mask
of 0x00 (Unhalted core cycles) count 100000
samples  %        symbol name
46612    11.0655  __lock_acquire
40281     9.5625  __copy_from_user_ll
37177     8.8256  trace_hardirqs_off
32748     7.7742  native_read_tsc
30815     7.3153  __copy_to_user_ll
20171     4.7885  trace_hardirqs_on
17928     4.2560  sched_clock
12017     2.8528  lock_release
10060     2.3882  lock_acquired
9576      2.2733  debug_smp_processor_id
7272      1.7263  lock_acquire
6671      1.5837  check_chain_key
6017      1.4284  mark_lock
5911      1.4032  check_flags
5610      1.3318  sysenter_past_esp
5421      1.2869  _raw_spin_trylock
5224      1.2402  mark_held_locks
5037      1.1958  trace_softirqs_off
3384      0.8033  trace_softirqs_on
3170      0.7525  local_bh_enable

I tried to disable all debugging functions, dynticks, tried to use inet_lro, enabling/disabling forward (for iperf), changing mtu, adding qdisc to loopback - it is not changing anything.

And probably not related to netfilter, since i remember weird thing happening with loopback and iperf.

Here is results of iperf on _completely_ idle machine, Q6600 (Quad Core 2.6 Ghz).
There is nothing else than iperf.

omecore ~ # iperf -s
------------------------------------------------------------
Server listening on TCP port 5001
TCP window size: 85.3 KByte (default)
------------------------------------------------------------
[  4] local 127.0.0.1 port 5001 connected with 127.0.0.1 port 37679
[  4]  0.0-10.0 sec  92.3 MBytes  77.4 Mbits/sec
[  4] local 127.0.0.1 port 5001 connected with 127.0.0.1 port 37680
[  4]  0.0-10.0 sec  3.14 GBytes  2.69 Gbits/sec

Here is run udp tests 1Gbit/s, 2Gbit/s, 5Gbit/s

homecore ~ # iperf -s -u
------------------------------------------------------------
Server listening on UDP port 5001
Receiving 1470 byte datagrams
UDP buffer size:   107 KByte (default)
------------------------------------------------------------
[  3] local 127.0.0.1 port 5001 connected with 127.0.0.1 port 33517
[  3]  0.0-10.0 sec  1.24 GBytes  1.07 Gbits/sec  0.003 ms 2312/909081 (0.25%)
[  3] local 127.0.0.1 port 5001 connected with 127.0.0.1 port 35635
[  3]  0.0-10.0 sec  1.81 GBytes  1.55 Gbits/sec  0.003 ms    1/1319918 (7.6e-05%)
[  3] local 127.0.0.1 port 5001 connected with 127.0.0.1 port 53051
[  3]  0.0-10.0 sec    876 MBytes    735 Mbits/sec  0.003 ms    1/624991 (0.00016%)

So on completely idle machine (almost no processes in background, getty and other usual system for console), it can give once even 30Mbps, and another time up to 3Gbps.
I dont think it is normal.
Can anybody try to run iperf on loopback?

Here is tcpdump. What i always notice - it is switching to very low window size.

16:19:25.919074 IP (tos 0x0, ttl  64, id 18637, offset 0, flags [DF], proto: TCP (6), length: 60) localhost.37680 > localhost.5001: S, cksum 0x6e01 (correct)
, 3454202579:3454202579(0) win 32792 <mss 16396,sackOK,timestamp 4294818334 0,nop,wscale 6>
16:19:25.919084 IP (tos 0x0, ttl  64, id 0, offset 0, flags [DF], proto: TCP (6), length: 60) localhost.5001 > localhost.37680: S, cksum 0xcb39 (correct), 34
63911994:3463911994(0) ack 3454202580 win 32768 <mss 16396,sackOK,timestamp 4294818334 4294818334,nop,wscale 6>
16:19:25.919092 IP (tos 0x0, ttl  64, id 18638, offset 0, flags [DF], proto: TCP (6), length: 52) localhost.37680 > localhost.5001: ., cksum 0xb25c (correct)
, 1:1(0) ack 1 win 513 <nop,nop,timestamp 4294818334 4294818334>
16:19:25.919689 IP (tos 0x0, ttl  64, id 18639, offset 0, flags [DF], proto: TCP (6), length: 76) localhost.37680 > localhost.5001: P, cksum 0xfe40 (incorrec
t (-> 0xa299), 1:25(24) ack 1 win 513 <nop,nop,timestamp 4294818334 4294818334>
16:19:25.919712 IP (tos 0x0, ttl  64, id 40997, offset 0, flags [DF], proto: TCP (6), length: 52) localhost.5001 > localhost.37680: ., cksum 0xb245 (correct)
, 1:1(0) ack 25 win 512 <nop,nop,timestamp 4294818334 4294818334>
16:19:25.919872 IP (tos 0x0, ttl  64, id 18640, offset 0, flags [DF], proto: TCP (6), length: 8244) localhost.37680 > localhost.5001: P, cksum 0x1e29 (incorr
ect (-> 0x9fd1), 25:8217(8192) ack 1 win 513 <nop,nop,timestamp 4294818335 4294818334>
16:19:25.919879 IP (tos 0x0, ttl  64, id 40998, offset 0, flags [DF], proto: TCP (6), length: 52) localhost.5001 > localhost.37680: ., cksum 0x913f (correct)
, 1:1(0) ack 8217 win 772 <nop,nop,timestamp 4294818335 4294818335>
16:19:25.919949 IP (tos 0x0, ttl  64, id 18641, offset 0, flags [DF], proto: TCP (6), length: 8244) localhost.37680 > localhost.5001: P, cksum 0x1e29 (incorr
ect (-> 0x7fd0), 8217:16409(8192) ack 1 win 513 <nop,nop,timestamp 4294818335 4294818335>
16:19:25.919968 IP (tos 0x0, ttl  64, id 40999, offset 0, flags [DF], proto: TCP (6), length: 52) localhost.5001 > localhost.37680: ., cksum 0x713f (correct)
, 1:1(0) ack 16409 win 772 <nop,nop,timestamp 4294818335 4294818335>
16:19:25.919996 IP (tos 0x0, ttl  64, id 18642, offset 0, flags [DF], proto: TCP (6), length: 8244) localhost.37680 > localhost.5001: P, cksum 0x1e29 (incorr
ect (-> 0x5fd0), 16409:24601(8192) ack 1 win 513 <nop,nop,timestamp 4294818335 4294818335>
16:19:25.920013 IP (tos 0x0, ttl  64, id 41000, offset 0, flags [DF], proto: TCP (6), length: 52) localhost.5001 > localhost.37680: ., cksum 0x513f (correct)
, 1:1(0) ack 24601 win 772 <nop,nop,timestamp 4294818335 4294818335>
16:19:25.920040 IP (tos 0x0, ttl  64, id 18643, offset 0, flags [DF], proto: TCP (6), length: 8244) localhost.37680 > localhost.5001: P, cksum 0x1e29 (incorr
ect (-> 0x3fd0), 24601:32793(8192) ack 1 win 513 <nop,nop,timestamp 4294818335 4294818335>
16:19:25.920051 IP (tos 0x0, ttl  64, id 41001, offset 0, flags [DF], proto: TCP (6), length: 52) localhost.5001 > localhost.37680: ., cksum 0x313f (correct)
, 1:1(0) ack 32793 win 772 <nop,nop,timestamp 4294818335 4294818335>
16:19:25.920087 IP (tos 0x0, ttl  64, id 18644, offset 0, flags [DF], proto: TCP (6), length: 8244) localhost.37680 > localhost.5001: P, cksum 0x1e29 (incorr
ect (-> 0x1fd0), 32793:40985(8192) ack 1 win 513 <nop,nop,timestamp 4294818335 4294818335>
16:19:25.920099 IP (tos 0x0, ttl  64, id 41002, offset 0, flags [DF], proto: TCP (6), length: 52) localhost.5001 > localhost.37680: ., cksum 0x113f (correct)
, 1:1(0) ack 40985 win 772 <nop,nop,timestamp 4294818335 4294818335>
16:19:25.920129 IP (tos 0x0, ttl  64, id 18645, offset 0, flags [DF], proto: TCP (6), length: 8244) localhost.37680 > localhost.5001: P, cksum 0x1e29 (incorr
ect (-> 0xffcf), 40985:49177(8192) ack 1 win 513 <nop,nop,timestamp 4294818335 4294818335>
16:19:25.920145 IP (tos 0x0, ttl  64, id 41003, offset 0, flags [DF], proto: TCP (6), length: 52) localhost.5001 > localhost.37680: ., cksum 0xf13e (correct)
, 1:1(0) ack 49177 win 772 <nop,nop,timestamp 4294818335 4294818335>
16:19:25.920170 IP (tos 0x0, ttl  64, id 18646, offset 0, flags [DF], proto: TCP (6), length: 8244) localhost.37680 > localhost.5001: P, cksum 0x1e29 (incorr
ect (-> 0xdfcf), 49177:57369(8192) ack 1 win 513 <nop,nop,timestamp 4294818335 4294818335>
16:19:25.920181 IP (tos 0x0, ttl  64, id 41004, offset 0, flags [DF], proto: TCP (6), length: 52) localhost.5001 > localhost.37680: ., cksum 0xd13e (correct)
, 1:1(0) ack 57369 win 772 <nop,nop,timestamp 4294818335 4294818335>
16:19:25.920226 IP (tos 0x0, ttl  64, id 18647, offset 0, flags [DF], proto: TCP (6), length: 8244) localhost.37680 > localhost.5001: P, cksum 0x1e29 (incorr
ect (-> 0xbfcf), 57369:65561(8192) ack 1 win 513 <nop,nop,timestamp 4294818335 4294818335>
16:19:25.920238 IP (tos 0x0, ttl  64, id 41005, offset 0, flags [DF], proto: TCP (6), length: 52) localhost.5001 > localhost.37680: ., cksum 0xb13e (correct)
, 1:1(0) ack 65561 win 772 <nop,nop,timestamp 4294818335 4294818335>
16:19:25.920274 IP (tos 0x0, ttl  64, id 18648, offset 0, flags [DF], proto: TCP (6), length: 8244) localhost.37680 > localhost.5001: P, cksum 0x1e29 (incorr
ect (-> 0x9fcf), 65561:73753(8192) ack 1 win 513 <nop,nop,timestamp 4294818335 4294818335>
16:19:25.920286 IP (tos 0x0, ttl  64, id 41006, offset 0, flags [DF], proto: TCP (6), length: 52) localhost.5001 > localhost.37680: ., cksum 0x913e (correct)
, 1:1(0) ack 73753 win 772 <nop,nop,timestamp 4294818335 4294818335>
16:19:25.920319 IP (tos 0x0, ttl  64, id 18649, offset 0, flags [DF], proto: TCP (6), length: 8244) localhost.37680 > localhost.5001: P, cksum 0x1e29 (incorr
ect (-> 0x7fcf), 73753:81945(8192) ack 1 win 513 <nop,nop,timestamp 4294818335 4294818335>
16:19:25.920331 IP (tos 0x0, ttl  64, id 41007, offset 0, flags [DF], proto: TCP (6), length: 52) localhost.5001 > localhost.37680: ., cksum 0x713e (correct)
, 1:1(0) ack 81945 win 772 <nop,nop,timestamp 4294818335 4294818335>
16:19:25.920362 IP (tos 0x0, ttl  64, id 18650, offset 0, flags [DF], proto: TCP (6), length: 8244) localhost.37680 > localhost.5001: P, cksum 0x1e29 (incorr
ect (-> 0x5fcf), 81945:90137(8192) ack 1 win 513 <nop,nop,timestamp 4294818335 4294818335>
16:19:25.920378 IP (tos 0x0, ttl  64, id 41008, offset 0, flags [DF], proto: TCP (6), length: 52) localhost.5001 > localhost.37680: ., cksum 0x513e (correct)



On Saturday 12 July 2008, Evgeniy Polyakov wrote:
> Hi.
> 
> On Sat, Jul 12, 2008 at 04:24:56AM +0300, Denys Fedoryshchenko (denys@visp.net.lb) wrote:
> > Always all rules with REDIRECT to local port is dropping speed around 100Kbyte/s. What can be the problem?
> 
> Can you run oprofile on this machine?
> 



-- 
------
Technical Manager
Virtual ISP S.A.L.
Lebanon

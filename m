From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Multicast packet loss
Date: Mon, 02 Feb 2009 17:57:24 +0100
Message-ID: <498725F4.2010205@cosmosbay.com>
References: <49833DBC.7040607@athenacr.com> <20090130200330.GA12659@hmsreliant.think-freely.org> <49837F56.2020502@athenacr.com> <49838213.90700@cosmosbay.com> <49859847.9010206@cosmosbay.com> <20090202134523.GA13369@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kenny Chang <kchang@athenacr.com>, netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:59698 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752584AbZBBQ5f convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2009 11:57:35 -0500
In-Reply-To: <20090202134523.GA13369@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neil Horman a =E9crit :
> On Sun, Feb 01, 2009 at 01:40:39PM +0100, Eric Dumazet wrote:
>> Eric Dumazet a =E9crit :
>>> Kenny Chang a =E9crit :
>>>> Ah, sorry, here's the test program attached.
>>>>
>>>> We've tried 2.6.28.1, but no, we haven't tried the 2.6.28.2 or the
>>>> 2.6.29.-rcX.
>>>>
>>>> Right now, we are trying to step through the kernel versions until=
 we
>>>> see where the performance drops significantly.  We'll try 2.6.29-r=
c soon
>>>> and post the result.
>> I tried your program on my dev machines and 2.6.29 (each machine : t=
wo quad core cpus, 32bits kernel)
>>
>> With 8 clients, about 10% packet loss,=20
>>
>> Might be a scheduling problem, not sure... 50.000 packets per second=
, x 8 cpus =3D 400.000
>> wakeups per second... But at least UDP receive path seems OK.
>>
>> Thing is the receiver (softirq that queues the packet) seems to figh=
t on socket lock with
>> readers...
>>
>> I tried to setup IRQ affinities, but it doesnt work any more on bnx2=
 (unless using msi_disable=3D1)
>>
>> I tried playing with ethtool -C|c G|g params...
>> And /proc/net/core/rmem_max (and setsockopt(RCVBUF) to set bigger re=
ceive buffers in your program)
>>
>> I can have 0% packet loss if booting with msi_disable and
>>
>> echo 1 >/proc/irq/16/smp_affinities
>>
>> (16 being interrupt of eth0 NIC)
>>
>> then, a second run gave me errors, about 2%, oh well...
>>
>>
>> oprofile numbers without playing IRQ affinities:
>>
>> CPU: Core 2, speed 2999.89 MHz (estimated)
>> Counted CPU_CLK_UNHALTED events (Clock cycles when not halted) with =
a unit mask of 0x00 (Unhalted core cycles) count 100000
>> samples  %        symbol name
>> 327928   10.1427  schedule
>> 259625    8.0301  mwait_idle
>> 187337    5.7943  __skb_recv_datagram
>> 109854    3.3977  lock_sock_nested
>> 104713    3.2387  tick_nohz_stop_sched_tick
>> 98831     3.0568  select_nohz_load_balancer
>> 88163     2.7268  skb_release_data
>> 78552     2.4296  update_curr
>> 75241     2.3272  getnstimeofday
>> 71400     2.2084  set_next_entity
>> 67629     2.0917  get_next_timer_interrupt
>> 67375     2.0839  sched_clock_tick
>> 58112     1.7974  enqueue_entity
>> 56462     1.7463  udp_recvmsg
>> 55049     1.7026  copy_to_user
>> 54277     1.6788  sched_clock_cpu
>> 54031     1.6712  __copy_skb_header
>> 51859     1.6040  __slab_free
>> 51786     1.6017  prepare_to_wait_exclusive
>> 51776     1.6014  sock_def_readable
>> 50062     1.5484  try_to_wake_up
>> 42182     1.3047  __switch_to
>> 41631     1.2876  read_tsc
>> 38337     1.1857  tick_nohz_restart_sched_tick
>> 34358     1.0627  cpu_idle
>> 34194     1.0576  native_sched_clock
>> 33812     1.0458  pick_next_task_fair
>> 33685     1.0419  resched_task
>> 33340     1.0312  sys_recvfrom
>> 33287     1.0296  dst_release
>> 32439     1.0033  kmem_cache_free
>> 32131     0.9938  hrtimer_start_range_ns
>> 29807     0.9219  udp_queue_rcv_skb
>> 27815     0.8603  task_rq_lock
>> 26875     0.8312  __update_sched_clock
>> 23912     0.7396  sock_queue_rcv_skb
>> 21583     0.6676  __wake_up_sync
>> 21001     0.6496  effective_load
>> 20531     0.6350  hrtick_start_fair
>>
>>
>>
>>
>> With IRQ affinities and msi_disable (no packet drops)
>>
>> CPU: Core 2, speed 3000.13 MHz (estimated)
>> Counted CPU_CLK_UNHALTED events (Clock cycles when not halted) with =
a unit mask of 0x00 (Unhalted core cycles) count 100000
>> samples  %        symbol name
>> 79788    10.3815  schedule
>> 69422     9.0328  mwait_idle
>> 44877     5.8391  __skb_recv_datagram
>> 28629     3.7250  tick_nohz_stop_sched_tick
>> 27252     3.5459  select_nohz_load_balancer
>> 24320     3.1644  lock_sock_nested
>> 20833     2.7107  getnstimeofday
>> 20666     2.6889  skb_release_data
>> 18612     2.4217  set_next_entity
>> 17785     2.3141  get_next_timer_interrupt
>> 17691     2.3018  udp_recvmsg
>> 17271     2.2472  sched_clock_tick
>> 16032     2.0860  copy_to_user
>> 14785     1.9237  update_curr
>> 12512     1.6280  prepare_to_wait_exclusive
>> 12498     1.6262  __slab_free
>> 11380     1.4807  read_tsc
>> 11145     1.4501  sched_clock_cpu
>> 10598     1.3789  __switch_to
>> 9588      1.2475  pick_next_task_fair
>> 9480      1.2335  cpu_idle
>> 9218      1.1994  sys_recvfrom
>> 9008      1.1721  tick_nohz_restart_sched_tick
>> 8977      1.1680  dst_release
>> 8930      1.1619  native_sched_clock
>> 8392      1.0919  kmem_cache_free
>> 8124      1.0570  hrtimer_start_range_ns
>> 7274      0.9464  bnx2_interrupt
>> 7175      0.9336  __copy_skb_header
>> 7006      0.9116  try_to_wake_up
>> 6949      0.9042  sock_def_readable
>> 6787      0.8831  enqueue_entity
>> 6772      0.8811  __update_sched_clock
>> 6349      0.8261  finish_task_switch
>> 6164      0.8020  copy_from_user
>> 5096      0.6631  resched_task
>> 5007      0.6515  sysenter_past_esp
>>
>>
>> I will try to investigate a litle bit more in following days if time=
 permits.
>>
> I'm not 100% versed on this, but IIRC, some hardware simply can't set=
 irq
> affinity when operating in msi interrupt mode.  If this is the case w=
ith this
> particular bnx2 card, then I would expect some packet loss, simply du=
e to the
> constant cache misses.  It would be interesting to re-run your oprofi=
le cases,
> counting L2 cache hits/misses (if your cpu supports that class of cou=
nter) for
> both bnx2 running in msi enabled mode and msi disabled mode.  It woul=
d also be
> interesting to use a different card, that can set irq affinity, and c=
ompare loss
> with irqbalance on, and irqbalance off with irq afninty set to all cp=
us.

booted with msi_disable=3D1, IRQ of eth0 handled by CPU0 only, so that
oprofile results sorted on CPU0 numbers.

We can see scheduler has hard time to cope with this workload with more=
 of two CPUS

OK up to 30.000 (* 8 sockets) packets per second.=20

CPU0 is 100% handling softirq (ksoftirqd/0)


CPU: Core 2, speed 3000.31 MHz (estimated)
Counted CPU_CLK_UNHALTED events (Clock cycles when not halted) with a u=
nit mask of 0x00 (Unhalted core cycles) count 100000
Samples on CPU 0
Samples on CPU 1
Samples on CPU 2
Samples on CPU 3
Samples on CPU 4
Samples on CPU 5
Samples on CPU 6
Samples on CPU 7
samples  %        samples  %        samples  %        samples  %       =
 samples  %        samples  %        samples  %        samples  %      =
  symbol name
6152     12.5595  3         0.0098  3         0.0090  5         0.0156 =
 1         0.0582  0              0  2         0.0065  3         0.0169=
  enqueue_entity
4453      9.0909  2         0.0065  3         0.0090  4         0.0125 =
 5         0.2910  0              0  1         0.0033  2         0.0113=
  try_to_wake_up
3837      7.8333  3         0.0098  8         0.0241  0              0 =
 0              0  0              0  0              0  0              0=
  sock_def_readable
3694      7.5414  0              0  0              0  0              0 =
 0              0  0              0  0              0  0              0=
  __copy_skb_header
2320      4.7363  1         0.0033  2         0.0060  2         0.0062 =
 1         0.0582  1         0.0028  2         0.0065  0              0=
  resched_task
1818      3.7115  6         0.0196  32        0.0962  0              0 =
 0              0  0              0  0              0  0              0=
  sock_queue_rcv_skb
1776      3.6257  0              0  0              0  0              0 =
 0              0  0              0  0              0  0              0=
  udp_queue_rcv_skb
1677      3.4236  0              0  1         0.0030  0              0 =
 1         0.0582  1         0.0028  0              0  0              0=
  __slab_alloc
1658      3.3848  260       0.8496  303       0.9109  289       0.9021 =
 24        1.3970  418       1.1730  326       1.0626  173       0.9733=
  sched_clock_cpu
1614      3.2950  0              0  0              0  0              0 =
 0              0  0              0  0              0  0              0=
  __wake_up_sync
1600      3.2664  0              0  1         0.0030  0              0 =
 1         0.0582  1         0.0028  0              0  0              0=
  select_task_rq_fair
1569      3.2032  1299      4.2447  1530      4.5996  1271      3.9675 =
 6         0.3492  1677      4.7062  1275      4.1559  759       4.2703=
  update_curr
1532      3.1276  4         0.0131  4         0.0120  0              0 =
 2         0.1164  1         0.0028  1         0.0033  1         0.0056=
  task_rq_lock
1325      2.7050  1         0.0033  7         0.0210  0              0 =
 0              0  0              0  0              0  0              0=
  skb_queue_tail
1273      2.5989  1         0.0033  1         0.0030  1         0.0031 =
 0              0  0              0  1         0.0033  0              0=
  enqueue_task_fair
1227      2.5050  0              0  0              0  0              0 =
 0              0  0              0  0              0  0              0=
  effective_load
1071      2.1865  0              0  0              0  0              0 =
 0              0  0              0  0              0  0              0=
  __udp4_lib_rcv
1009      2.0599  0              0  0              0  0              0 =
 2         0.1164  1         0.0028  0              0  0              0=
  activate_task
940       1.9190  0              0  0              0  0              0 =
 0              0  0              0  0              0  0              0=
  __wake_up_common
930       1.8986  0              0  2         0.0060  0              0 =
 0              0  0              0  0              0  1         0.0056=
  account_scheduler_latency
859       1.7537  0              0  0              0  0              0 =
 0              0  0              0  0              0  1         0.0056=
  __skb_clone
609       1.2433  0              0  0              0  0              0 =
 1         0.0582  1         0.0028  1         0.0033  0              0=
  enqueue_task
588       1.2004  3         0.0098  2         0.0060  5         0.0156 =
 8         0.4657  2         0.0056  3         0.0098  2         0.0113=
  kmem_cache_alloc
477       0.9738  307       1.0032  322       0.9680  358       1.1175 =
 27        1.5716  338       0.9485  315       1.0268  203       1.1421=
  native_sched_clock
441       0.9003  0              0  0              0  0              0 =
 0              0  0              0  0              0  0              0=
  skb_clone
408       0.8329  0              0  0              0  0              0 =
 0              0  0              0  0              0  0              0=
  ip_route_input
375       0.7656  0              0  0              0  0              0 =
 0              0  0              0  0              0  0              0=
  bnx2_poll_work
366       0.7472  248       0.8104  269       0.8087  293       0.9146 =
 22        1.2806  289       0.8110  332       1.0822  157       0.8833=
  __update_sched_clock
327       0.6676  1         0.0033  0              0  0              0 =
 0              0  0              0  2         0.0065  1         0.0056=
  place_entity
265       0.5410  54        0.1765  62        0.1864  39        0.1217 =
 3         0.1746  84        0.2357  61        0.1988  12        0.0675=
  rb_insert_color
194       0.3961  2662      8.6985  3291      9.8936  3231     10.0858 =
 372      21.6531  2994      8.4021  3299     10.7533  1719      9.6714=
  mwait_idle



This problem completely disapears if I launch all clients bounded to CP=
U1
(and NIC irq still on CPU0)

taskset -p2 ./mcasttest.sh

(No packet loss, while CPU1 has 0% idle time...)
We have less context switches. Once awakened, a task can read several p=
ackets in its socket.

CPU: Core 2, speed 3000.31 MHz (estimated)
Counted CPU_CLK_UNHALTED events (Clock cycles when not halted) with a u=
nit mask of 0x00 (Unhalted core cycles) count 100000
Samples on CPU 0
Samples on CPU 1
Samples on CPU 2
Samples on CPU 3
Samples on CPU 4
Samples on CPU 5
Samples on CPU 6
Samples on CPU 7
samples  %        samples  %        samples  %        samples  %       =
 samples  %        samples  %        samples  %        samples  %      =
  symbol name
25316    13.6664  0              0  0              0  0              0 =
 0              0  0              0  0              0  0              0=
  __copy_skb_header
14584     7.8729  13        0.0083  2         0.2670  0              0 =
 0              0  1         0.0218  1         0.1577  1         0.2604=
  task_rq_lock
11624     6.2750  10657     6.7650  3         0.4005  2         0.5013 =
 5         0.7278  36        0.7862  2         0.3155  1         0.2604=
  update_curr
10038     5.4188  318       0.2019  0              0  0              0 =
 0              0  0              0  0              0  0              0=
  sock_def_readable
10021     5.4097  0              0  0              0  0              0 =
 0              0  0              0  0              0  0              0=
  bnx2_interrupt
7777      4.1983  11        0.0070  1         0.1335  2         0.5013 =
 2         0.2911  8         0.1747  3         0.4732  1         0.2604=
  try_to_wake_up
6559      3.5408  0              0  0              0  0              0 =
 0              0  0              0  0              0  0              0=
  udp_queue_rcv_skb
6389      3.4490  257       0.1631  0              0  0              0 =
 0              0  0              0  0              0  0              0=
  sock_queue_rcv_skb
6305      3.4036  6         0.0038  0              0  0              0 =
 0              0  0              0  0              0  1         0.2604=
  __slab_alloc
5661      3.0560  44        0.0279  2         0.2670  1         0.2506 =
 5         0.7278  0              0  1         0.1577  0              0=
  kmem_cache_alloc
5529      2.9847  5         0.0032  1         0.1335  4         1.0025 =
 0              0  14        0.3057  3         0.4732  1         0.2604=
  enqueue_entity
4706      2.5404  64        0.0406  0              0  0              0 =
 0              0  0              0  0              0  0              0=
  skb_queue_tail
4390      2.3699  0              0  0              0  0              0 =
 0              0  0              0  0              0  0              0=
  __udp4_lib_rcv
4043      2.1825  0              0  0              0  0              0 =
 0              0  0              0  0              0  0              0=
  uhci_irq
3897      2.1037  0              0  0              0  0              0 =
 0              0  0              0  0              0  0              0=
  bnx2_poll_work
3556      1.9196  0              0  296      39.5194  261      65.4135 =
 258      37.5546  650      14.1952  263      41.4826  257      66.9271=
  mwait_idle
3449      1.8619  0              0  0              0  0              0 =
 0              0  0              0  0              0  0              0=
  __skb_clone
3348      1.8074  0              0  0              0  0              0 =
 0              0  0              0  0              0  0              0=
  skb_clone
3243      1.7507  1653      1.0493  7         0.9346  3         0.7519 =
 2         0.2911  63        1.3758  1         0.1577  1         0.2604=
  sched_clock_cpu
3068      1.6562  1        6.3e-04  0              0  0              0 =
 0              0  0              0  0              0  0              0=
  __wake_up_sync
2923      1.5779  1        6.3e-04  0              0  0              0 =
 0              0  0              0  0              0  0              0=
  check_preempt_wakeup
2588      1.3971  1        6.3e-04  4         0.5340  2         0.5013 =
 1         0.1456  1         0.0218  2         0.3155  0              0=
  enqueue_task_fair
2399      1.2951  0              0  0              0  0              0 =
 0              0  0              0  0              0  0              0=
  ip_route_input
1986      1.0721  5         0.0032  0              0  0              0 =
 0              0  1         0.0218  0              0  0              0=
  __wake_up_common
1777      0.9593  132       0.0838  0              0  0              0 =
 3         0.4367  8         0.1747  1         0.1577  1         0.2604=
  rb_insert_color
1754      0.9469  34        0.0216  0              0  0              0 =
 0              0  0              0  0              0  0              0=
  __sk_mem_schedule
1550      0.8367  0              0  0              0  0              0 =
 0              0  0              0  0              0  0              0=
  irq_entries_start
1527      0.8243  0              0  13        1.7356  2         0.5013 =
 0              0  104       2.2712  6         0.9464  0              0=
  get_next_timer_interrupt
1398      0.7547  6         0.0038  0              0  0              0 =
 1         0.1456  1         0.0218  0              0  0              0=
  select_task_rq_fair
1159      0.6257  0              0  0              0  0              0 =
 0              0  0              0  0              0  0              0=
  __alloc_skb


Exchanging CPU0/CPU1 to get oprofile number sorted on the CPU used by u=
ser application :

CPU: Core 2, speed 3000.31 MHz (estimated)
Counted CPU_CLK_UNHALTED events (Clock cycles when not halted) with a u=
nit mask of 0x00 (Unhalted core cycles) count 100000
Samples on CPU 0
Samples on CPU 1
Samples on CPU 2
Samples on CPU 3
Samples on CPU 4
Samples on CPU 5
Samples on CPU 6
Samples on CPU 7
samples  %        samples  %        samples  %        samples  %       =
 samples  %        samples  %        samples  %        samples  %      =
  symbol name
6040     10.1815  8         0.0134  4         0.3208  6         1.3699 =
 1         0.1580  3         1.0909  5         0.6039  0              0=
  schedule
6014     10.1377  0              0  0              0  0              0 =
 0              0  0              0  0              0  0              0=
  __skb_recv_datagram
4730      7.9733  36        0.0604  0              0  0              0 =
 0              0  0              0  0              0  0              0=
  skb_release_data
4014      6.7663  2         0.0034  33        2.6464  1         0.2283 =
 6         0.9479  0              0  1         0.1208  0              0=
  copy_to_user
3732      6.2910  3708      6.2167  4         0.3208  1         0.2283 =
 3         0.4739  3         1.0909  2         0.2415  0              0=
  update_curr
3446      5.8089  0              0  0              0  0              0 =
 0              0  0              0  0              0  0              0=
  lock_sock_nested
2430      4.0962  0              0  0              0  0              0 =
 0              0  0              0  0              0  0              0=
  udp_recvmsg
2028      3.4186  73        0.1224  0              0  0              0 =
 2         0.3160  0              0  1         0.1208  1         0.3861=
  __slab_free
1898      3.1994  43        0.0721  0              0  0              0 =
 0              0  0              0  0              0  0              0=
  dst_release
1645      2.7730  0              0  0              0  0              0 =
 0              0  0              0  0              0  0              0=
  memcpy_toiovec
1635      2.7561  0              0  0              0  0              0 =
 1         0.1580  0              0  0              0  0              0=
  copy_from_user
1407      2.3718  2         0.0034  0              0  2         0.4566 =
 6         0.9479  0              0  5         0.6039  1         0.3861=
  sysenter_past_esp
1389      2.3414  58        0.0972  3         0.2406  3         0.6849 =
 4         0.6319  2         0.7273  3         0.3623  0              0=
  kmem_cache_free
1135      1.9133  1         0.0017  0              0  0              0 =
 0              0  0              0  0              0  0              0=
  release_sock
1069      1.8020  0              0  0              0  0              0 =
 0              0  0              0  0              0  0              0=
  prepare_to_wait_exclusive
1031      1.7379  3         0.0050  0              0  0              0 =
 0              0  0              0  1         0.1208  0              0=
  put_prev_task_fair
1007      1.6975  0              0  0              0  0              0 =
 0              0  0              0  0              0  0              0=
  sock_rfree
926       1.5609  0              0  0              0  0              0 =
 0              0  0              0  0              0  0              0=
  sys_recvfrom
838       1.4126  0              0  0              0  0              0 =
 0              0  0              0  0              0  0              0=
  skb_copy_datagram_iovec
697       1.1749  27        0.0453  1         0.0802  0              0 =
 0              0  1         0.3636  0              0  0              0=
  add_partial
697       1.1749  0              0  0              0  0              0 =
 0              0  0              0  1         0.1208  0              0=
  dequeue_task
604       1.0182  0              0  0              0  0              0 =
 0              0  0              0  0              0  0              0=
  sock_recvmsg
582       0.9811  933       1.5642  17        1.3633  1         0.2283 =
 2         0.3160  1         0.3636  6         0.7246  0              0=
  sched_clock_cpu
525       0.8850  0              0  0              0  0              0 =
 0              0  0              0  0              0  0              0=
  __sk_mem_reclaim
512       0.8631  0              0  0              0  1         0.2283 =
 0              0  0              0  1         0.1208  1         0.3861=
  __switch_to
489       0.8243  0              0  0              0  0              0 =
 0              0  0              0  0              0  0              0=
  fget_light
450       0.7586  1         0.0017  2         0.1604  1         0.2283 =
 0              0  0              0  4         0.4831  0              0=
  rb_erase
409       0.6894  95        0.1593  0              0  0              0 =
 0              0  0              0  0              0  0              0=
  wakeup_preempt_entity
360       0.6068  0              0  0              0  0              0 =
 0              0  0              0  0              0  0              0=
  move_addr_to_user
348       0.5866  0              0  0              0  0              0 =
 0              0  0              0  0              0  0              0=
  sys_socketcall
347       0.5849  1         0.0017  0              0  0              0 =
 0              0  0              0  0              0  1         0.3861=
  set_next_entity


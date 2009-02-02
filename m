From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: Multicast packet loss
Date: Mon, 2 Feb 2009 13:22:12 -0500
Message-ID: <20090202182212.GA17950@hmsreliant.think-freely.org>
References: <49833DBC.7040607@athenacr.com> <20090130200330.GA12659@hmsreliant.think-freely.org> <49837F56.2020502@athenacr.com> <49838213.90700@cosmosbay.com> <49859847.9010206@cosmosbay.com> <20090202134523.GA13369@hmsreliant.think-freely.org> <498725F4.2010205@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kenny Chang <kchang@athenacr.com>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:39754 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755437AbZBBSWZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2009 13:22:25 -0500
Content-Disposition: inline
In-Reply-To: <498725F4.2010205@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 02, 2009 at 05:57:24PM +0100, Eric Dumazet wrote:
> Neil Horman a =E9crit :
> > On Sun, Feb 01, 2009 at 01:40:39PM +0100, Eric Dumazet wrote:
> >> Eric Dumazet a =E9crit :
> >>> Kenny Chang a =E9crit :
> >>>> Ah, sorry, here's the test program attached.
> >>>>
> >>>> We've tried 2.6.28.1, but no, we haven't tried the 2.6.28.2 or t=
he
> >>>> 2.6.29.-rcX.
> >>>>
> >>>> Right now, we are trying to step through the kernel versions unt=
il we
> >>>> see where the performance drops significantly.  We'll try 2.6.29=
-rc soon
> >>>> and post the result.
> >> I tried your program on my dev machines and 2.6.29 (each machine :=
 two quad core cpus, 32bits kernel)
> >>
> >> With 8 clients, about 10% packet loss,=20
> >>
> >> Might be a scheduling problem, not sure... 50.000 packets per seco=
nd, x 8 cpus =3D 400.000
> >> wakeups per second... But at least UDP receive path seems OK.
> >>
> >> Thing is the receiver (softirq that queues the packet) seems to fi=
ght on socket lock with
> >> readers...
> >>
> >> I tried to setup IRQ affinities, but it doesnt work any more on bn=
x2 (unless using msi_disable=3D1)
> >>
> >> I tried playing with ethtool -C|c G|g params...
> >> And /proc/net/core/rmem_max (and setsockopt(RCVBUF) to set bigger =
receive buffers in your program)
> >>
> >> I can have 0% packet loss if booting with msi_disable and
> >>
> >> echo 1 >/proc/irq/16/smp_affinities
> >>
> >> (16 being interrupt of eth0 NIC)
> >>
> >> then, a second run gave me errors, about 2%, oh well...
> >>
> >>
> >> oprofile numbers without playing IRQ affinities:
> >>
> >> CPU: Core 2, speed 2999.89 MHz (estimated)
> >> Counted CPU_CLK_UNHALTED events (Clock cycles when not halted) wit=
h a unit mask of 0x00 (Unhalted core cycles) count 100000
> >> samples  %        symbol name
> >> 327928   10.1427  schedule
> >> 259625    8.0301  mwait_idle
> >> 187337    5.7943  __skb_recv_datagram
> >> 109854    3.3977  lock_sock_nested
> >> 104713    3.2387  tick_nohz_stop_sched_tick
> >> 98831     3.0568  select_nohz_load_balancer
> >> 88163     2.7268  skb_release_data
> >> 78552     2.4296  update_curr
> >> 75241     2.3272  getnstimeofday
> >> 71400     2.2084  set_next_entity
> >> 67629     2.0917  get_next_timer_interrupt
> >> 67375     2.0839  sched_clock_tick
> >> 58112     1.7974  enqueue_entity
> >> 56462     1.7463  udp_recvmsg
> >> 55049     1.7026  copy_to_user
> >> 54277     1.6788  sched_clock_cpu
> >> 54031     1.6712  __copy_skb_header
> >> 51859     1.6040  __slab_free
> >> 51786     1.6017  prepare_to_wait_exclusive
> >> 51776     1.6014  sock_def_readable
> >> 50062     1.5484  try_to_wake_up
> >> 42182     1.3047  __switch_to
> >> 41631     1.2876  read_tsc
> >> 38337     1.1857  tick_nohz_restart_sched_tick
> >> 34358     1.0627  cpu_idle
> >> 34194     1.0576  native_sched_clock
> >> 33812     1.0458  pick_next_task_fair
> >> 33685     1.0419  resched_task
> >> 33340     1.0312  sys_recvfrom
> >> 33287     1.0296  dst_release
> >> 32439     1.0033  kmem_cache_free
> >> 32131     0.9938  hrtimer_start_range_ns
> >> 29807     0.9219  udp_queue_rcv_skb
> >> 27815     0.8603  task_rq_lock
> >> 26875     0.8312  __update_sched_clock
> >> 23912     0.7396  sock_queue_rcv_skb
> >> 21583     0.6676  __wake_up_sync
> >> 21001     0.6496  effective_load
> >> 20531     0.6350  hrtick_start_fair
> >>
> >>
> >>
> >>
> >> With IRQ affinities and msi_disable (no packet drops)
> >>
> >> CPU: Core 2, speed 3000.13 MHz (estimated)
> >> Counted CPU_CLK_UNHALTED events (Clock cycles when not halted) wit=
h a unit mask of 0x00 (Unhalted core cycles) count 100000
> >> samples  %        symbol name
> >> 79788    10.3815  schedule
> >> 69422     9.0328  mwait_idle
> >> 44877     5.8391  __skb_recv_datagram
> >> 28629     3.7250  tick_nohz_stop_sched_tick
> >> 27252     3.5459  select_nohz_load_balancer
> >> 24320     3.1644  lock_sock_nested
> >> 20833     2.7107  getnstimeofday
> >> 20666     2.6889  skb_release_data
> >> 18612     2.4217  set_next_entity
> >> 17785     2.3141  get_next_timer_interrupt
> >> 17691     2.3018  udp_recvmsg
> >> 17271     2.2472  sched_clock_tick
> >> 16032     2.0860  copy_to_user
> >> 14785     1.9237  update_curr
> >> 12512     1.6280  prepare_to_wait_exclusive
> >> 12498     1.6262  __slab_free
> >> 11380     1.4807  read_tsc
> >> 11145     1.4501  sched_clock_cpu
> >> 10598     1.3789  __switch_to
> >> 9588      1.2475  pick_next_task_fair
> >> 9480      1.2335  cpu_idle
> >> 9218      1.1994  sys_recvfrom
> >> 9008      1.1721  tick_nohz_restart_sched_tick
> >> 8977      1.1680  dst_release
> >> 8930      1.1619  native_sched_clock
> >> 8392      1.0919  kmem_cache_free
> >> 8124      1.0570  hrtimer_start_range_ns
> >> 7274      0.9464  bnx2_interrupt
> >> 7175      0.9336  __copy_skb_header
> >> 7006      0.9116  try_to_wake_up
> >> 6949      0.9042  sock_def_readable
> >> 6787      0.8831  enqueue_entity
> >> 6772      0.8811  __update_sched_clock
> >> 6349      0.8261  finish_task_switch
> >> 6164      0.8020  copy_from_user
> >> 5096      0.6631  resched_task
> >> 5007      0.6515  sysenter_past_esp
> >>
> >>
> >> I will try to investigate a litle bit more in following days if ti=
me permits.
> >>
> > I'm not 100% versed on this, but IIRC, some hardware simply can't s=
et irq
> > affinity when operating in msi interrupt mode.  If this is the case=
 with this
> > particular bnx2 card, then I would expect some packet loss, simply =
due to the
> > constant cache misses.  It would be interesting to re-run your opro=
file cases,
> > counting L2 cache hits/misses (if your cpu supports that class of c=
ounter) for
> > both bnx2 running in msi enabled mode and msi disabled mode.  It wo=
uld also be
> > interesting to use a different card, that can set irq affinity, and=
 compare loss
> > with irqbalance on, and irqbalance off with irq afninty set to all =
cpus.
>=20
> booted with msi_disable=3D1, IRQ of eth0 handled by CPU0 only, so tha=
t
> oprofile results sorted on CPU0 numbers.
>=20
> We can see scheduler has hard time to cope with this workload with mo=
re of two CPUS
>=20
> OK up to 30.000 (* 8 sockets) packets per second.=20
>=20
> CPU0 is 100% handling softirq (ksoftirqd/0)
>=20

This explains alot.  if the application is scheduled to run on the same=
 cpu that
has the irq for the NIC bound to it, you get a perf boost by not having=
 to warm
up two caches (1 for the app cpu and one for the irq & softirq work), b=
ut you
loose it and then some fighting for cpu time.  If both the app and the =
irq are
on the same cpu, and we spend so much time in softirq context, we will
eventually overflow higher up the network stack, as the application doe=
sn't have
enough time to dequeue frames.

It may also speak to the need to make the bnx2 napi routine more effici=
ent :)

Neil


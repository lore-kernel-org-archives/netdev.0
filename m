From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH 2/4] bonding: make sure tx and rx hash tables stay in sync when using alb mode
Date: Wed, 16 Sep 2009 16:36:09 -0700
Message-ID: <27763.1253144169@death.nxdomain.ibm.com>
References: <20090911211112.GR8515@gospo.rdu.redhat.com>
Cc: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:56309 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755159AbZIPXgM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2009 19:36:12 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id n8GNY4DW011627
	for <netdev@vger.kernel.org>; Wed, 16 Sep 2009 17:34:04 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n8GNaEau028214
	for <netdev@vger.kernel.org>; Wed, 16 Sep 2009 17:36:14 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n8GNaDnG000921
	for <netdev@vger.kernel.org>; Wed, 16 Sep 2009 17:36:14 -0600
In-reply-to: <20090911211112.GR8515@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Gospodarek <andy@greyhouse.net> wrote:

>
>Subject: [PATCH] bonding: make sure tx and rx hash tables stay in sync when using alb mode

	When testing this, I'm getting a lockdep warning.  It appears to
be unhappy that tlb_choose_channel acquires the tx / rx hash table locks
in the order tx then rx, but rlb_choose_channel -> alb_get_best_slave
acquires the locks in the other order.  I applied all four patches, but
it looks like the change that trips lockdep is in this patch (#2).

	I haven't gotten an actual deadlock from this, although it seems
plausible if there are two cpus in bond_alb_xmit at the same time, and
one of them is sending an ARP.

	One fairly straightforward fix would be to combine the rx and tx
hash table locks into a single lock.  I suspect that wouldn't have any
real performance penalty, since the rx hash table lock is generally not
acquired very often (unlike the tx lock, which is taken for every packet
that goes out).

	Also, FYI, two of the four patches had trailing whitespace.  I
believe it was #2 and #4.

	Thoughts?

	Here's the lockdep warning:

Ethernet Channel Bonding Driver: v3.5.0 (November 4, 2008)
bonding: In ALB mode you might experience client disconnections upon reconnection of a link if the bonding module updelay parameter (0 msec) is incompatible with the forwarding delay time of the switch
bonding: MII link monitoring set to 10 ms
ADDRCONF(NETDEV_UP): bond0: link is not ready
tg3 0000:01:07.1: PME# disabled
bonding: bond0: enslaving eth0 as an active interface with a down link.
tg3 0000:01:07.0: PME# enabled
tg3 0000:01:07.0: PME# disabled
bonding: bond0: enslaving eth1 as an active interface with a down link.
tg3: eth0: Link is up at 1000 Mbps, full duplex.
tg3: eth0: Flow control is off for TX and off for RX.
bonding: bond0: link status definitely up for interface eth0.
bonding: bond0: making interface eth0 the new active one.
bonding: bond0: first active interface up!
ADDRCONF(NETDEV_CHANGE): bond0: link becomes ready
tg3: eth1: Link is up at 1000 Mbps, full duplex.
tg3: eth1: Flow control is off for TX and off for RX.
bonding: bond0: link status definitely up for interface eth1.
bonding: bond0: enslaving eth2 as an active interface with a down link.
e1000: eth2 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX
bonding: bond0: link status definitely up for interface eth2.

=======================================================
[ INFO: possible circular locking dependency detected ]
2.6.31-locking #10
-------------------------------------------------------
swapper/0 is trying to acquire lock:
 (&(bond_info->tx_hashtbl_lock)){+.-...}, at: [<e1863ec1>] alb_get_best_slave+0x1b/0x58 [bonding]

but task is already holding lock:
 (&(bond_info->rx_hashtbl_lock)){+.-...}, at: [<e1864fe5>] bond_alb_xmit+0x1b7/0x60b [bonding]

which lock already depends on the new lock.


the existing dependency chain (in reverse order) is:

-> #1 (&(bond_info->rx_hashtbl_lock)){+.-...}:
       [<c014fcbb>] __lock_acquire+0x109f/0x13a0
       [<c0150064>] lock_acquire+0xa8/0xbf
       [<c0343678>] _spin_lock_bh+0x2a/0x39
       [<e186532f>] bond_alb_xmit+0x501/0x60b [bonding]
       [<e1861a6b>] bond_start_xmit+0x2e9/0x32e [bonding]
       [<c02dc369>] dev_hard_start_xmit+0x281/0x314
       [<c02dc81a>] dev_queue_xmit+0x338/0x41b
       [<c02e1ddc>] neigh_resolve_output+0x260/0x28d
       [<e170dece>] ip6_output2+0x2dc/0x32a [ipv6]
       [<e170edaf>] ip6_output+0xe93/0xea0 [ipv6]
       [<e171be2e>] ndisc_send_skb+0x19d/0x320 [ipv6]
       [<e171bfeb>] __ndisc_send+0x3a/0x45 [ipv6]
       [<e171d3df>] ndisc_send_rs+0x34/0x3c [ipv6]
       [<e171127c>] addrconf_dad_completed+0x5e/0x99 [ipv6]
       [<e17120df>] addrconf_dad_timer+0x5d/0xe1 [ipv6]
       [<c0136692>] run_timer_softirq+0x1a0/0x219
       [<c0132cd9>] __do_softirq+0xd6/0x1a3
       [<c0132dd1>] do_softirq+0x2b/0x43
       [<c0132f4e>] irq_exit+0x38/0x74
       [<c0113669>] smp_apic_timer_interrupt+0x6e/0x7c
       [<c01032fb>] apic_timer_interrupt+0x2f/0x34
       [<c0101b43>] cpu_idle+0x49/0x76
       [<c03335f3>] rest_init+0x67/0x69
       [<c04937cd>] start_kernel+0x2c1/0x2c6
       [<c049306a>] __init_begin+0x6a/0x6f

-> #0 (&(bond_info->tx_hashtbl_lock)){+.-...}:
       [<c014fa46>] __lock_acquire+0xe2a/0x13a0
       [<c0150064>] lock_acquire+0xa8/0xbf
       [<c0343678>] _spin_lock_bh+0x2a/0x39
       [<e1863ec1>] alb_get_best_slave+0x1b/0x58 [bonding]
       [<e1865080>] bond_alb_xmit+0x252/0x60b [bonding]
       [<e1861a6b>] bond_start_xmit+0x2e9/0x32e [bonding]
       [<c02dc369>] dev_hard_start_xmit+0x281/0x314
       [<c02dc81a>] dev_queue_xmit+0x338/0x41b
       [<c03157a8>] arp_send+0x32/0x37
       [<c0316033>] arp_solicit+0x18a/0x1a1
       [<c02e3ce3>] neigh_timer_handler+0x1c9/0x20a
       [<c0136692>] run_timer_softirq+0x1a0/0x219
       [<c0132cd9>] __do_softirq+0xd6/0x1a3
       [<c0132dd1>] do_softirq+0x2b/0x43
       [<c0132f4e>] irq_exit+0x38/0x74
       [<c0113669>] smp_apic_timer_interrupt+0x6e/0x7c
       [<c01032fb>] apic_timer_interrupt+0x2f/0x34
       [<c0101b43>] cpu_idle+0x49/0x76
       [<c033e289>] start_secondary+0x1ab/0x1b2

other info that might help us debug this:

5 locks held by swapper/0:
 #0:  (&n->timer){+.-...}, at: [<c0136638>] run_timer_softirq+0x146/0x219
 #1:  (rcu_read_lock){.+.+..}, at: [<c02dc696>] dev_queue_xmit+0x1b4/0x41b
 #2:  (&bond->lock){++.?..}, at: [<e1864e6b>] bond_alb_xmit+0x3d/0x60b [bonding]
 #3:  (&bond->curr_slave_lock){++.?..}, at: [<e1864e7e>] bond_alb_xmit+0x50/0x60b [bonding]
 #4:  (&(bond_info->rx_hashtbl_lock)){+.-...}, at: [<e1864fe5>] bond_alb_xmit+0x1b7/0x60b [bonding]

stack backtrace:
Pid: 0, comm: swapper Not tainted 2.6.31-locking #10
Call Trace:
 [<c03408d6>] ? printk+0xf/0x11
 [<c014e7d5>] print_circular_bug+0x90/0x9c
 [<c014fa46>] __lock_acquire+0xe2a/0x13a0
 [<e1864fe5>] ? bond_alb_xmit+0x1b7/0x60b [bonding]
 [<c0150064>] lock_acquire+0xa8/0xbf
 [<e1863ec1>] ? alb_get_best_slave+0x1b/0x58 [bonding]
 [<c0343678>] _spin_lock_bh+0x2a/0x39
 [<e1863ec1>] ? alb_get_best_slave+0x1b/0x58 [bonding]
 [<e1863ec1>] alb_get_best_slave+0x1b/0x58 [bonding]
 [<e1865080>] bond_alb_xmit+0x252/0x60b [bonding]
 [<c014dff7>] ? mark_held_locks+0x43/0x5b
 [<c014e211>] ? trace_hardirqs_on_caller+0xe6/0x120
 [<e1861a6b>] bond_start_xmit+0x2e9/0x32e [bonding]
 [<c02dc369>] dev_hard_start_xmit+0x281/0x314
 [<c02dc81a>] dev_queue_xmit+0x338/0x41b
 [<c031579c>] ? arp_send+0x26/0x37
 [<c03157a8>] arp_send+0x32/0x37
 [<c0316033>] arp_solicit+0x18a/0x1a1
 [<c02e3ce3>] neigh_timer_handler+0x1c9/0x20a
 [<c0136692>] run_timer_softirq+0x1a0/0x219
 [<c0136638>] ? run_timer_softirq+0x146/0x219
 [<c02e3b1a>] ? neigh_timer_handler+0x0/0x20a
 [<c0132cd9>] __do_softirq+0xd6/0x1a3
 [<c0132dd1>] do_softirq+0x2b/0x43
 [<c0132f4e>] irq_exit+0x38/0x74
 [<c0113669>] smp_apic_timer_interrupt+0x6e/0x7c
 [<c01032fb>] apic_timer_interrupt+0x2f/0x34
 [<c0101b3d>] ? cpu_idle+0x43/0x76
 [<c014007b>] ? sys_timer_create+0x205/0x304
 [<c0108125>] ? default_idle+0x8a/0xef
 [<c014b25c>] ? tick_nohz_restart_sched_tick+0x12f/0x138
 [<c0101b43>] cpu_idle+0x49/0x76
 [<c033e289>] start_secondary+0x1ab/0x1b2


	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com

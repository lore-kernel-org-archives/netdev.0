From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: LOCKDEP complaints in l2tp_xmit_skb()
Date: Thu, 28 Jun 2012 08:56:12 +0200
Message-ID: <1340866572.26242.312.camel@edumazet-glaptop>
References: <20120627111152.GA2531@raven>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Tom Parkin <tparkin@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:36771 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754370Ab2F1G4R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 02:56:17 -0400
Received: by bkcji2 with SMTP id ji2so1667781bkc.19
        for <netdev@vger.kernel.org>; Wed, 27 Jun 2012 23:56:16 -0700 (PDT)
In-Reply-To: <20120627111152.GA2531@raven>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-27 at 12:11 +0100, Tom Parkin wrote:
> In testing L2TP ethernet pseudowires I have observed some complaints
> from lockdep due to circular/recursive locking in l2tp_xmit_skb().
> 
> I'm testing the -net tree, which includes Eric's recent patches to
> squash another lockdep error by converting l2tp to LLTX.  Git hash
> d7ffde35e31a811.
> 
> My test setup consists of two AMD64 boxes, both running 32bit kernels.
> One box is SMP, the other UP.  My test procedure consists of creating
> an L2TP tunnel containing N ethernet pseudowires.  I then run N iperf
> sessions across the N pseudowires.  The simplest configuration is:
> 
> 
> [On HOST A]
> ip l2tp add tunnel \
> 	tunnel_id 1 \
> 	peer_tunnel_id 1 \
> 	local <HOST A ip> \
> 	remote <HOST B ip> \
> 	udp_sport 9999 \
> 	udp_dport 9999
> ip add session \
> 	tunnel_id 1 \
> 	session_id 1 \
> 	peer_session_id 1
> ip addr add 172.16.0.1 \
> 	peer 172.16.0.2/24 \
> 	broadcast 172.16.0.255 \
> 	dev l2tpeth0
> ip link set l2tpeth0 up
> iperf -s -B 172.16.0.1
> 
> [On HOST B]
> ip l2tp add tunnel \
> 	tunnel_id 1 \
> 	peer_tunnel_id 1 \
> 	local <HOST B ip> \
> 	remote <HOST A ip> \
> 	udp_sport 9999 \
> 	udp_dport 9999
> ip add session \
> 	tunnel_id 1 \
> 	session_id 1 \
> 	peer_session_id 1
> ip addr add 172.16.0.2 \
> 	peer 172.16.0.1/24 \
> 	broadcast 172.16.0.255 \
> 	dev l2tpeth0
> ip link set l2tpeth0 up
> iperf -c 172.16.0.1
> 
> 
> If I run four concurrent iperf sessions across four pseudowires I
> see lockdep complaints on both SMP and UP boxes.
> 
> Lockdep output for the AMD64 SMP machine:
> 
> ======================================================
> [ INFO: possible circular locking dependency detected ]
> 3.5.0-rc2-net-lockdep-u64-sync-006-+ #2 Not tainted
> -------------------------------------------------------
> swapper/1/0 is trying to acquire lock:
>  (slock-AF_INET){+.-...}, at: [<f85f5bff>] l2tp_xmit_skb+0x13f/0x8e0 [l2tp_core]
> 
> but task is already holding lock:
>  (&(&sch->busylock)->rlock){+.-...}, at: [<c14fb1b2>] dev_queue_xmit+0xb42/0xbd0
> 
> which lock already depends on the new lock.
> 
> 
> the existing dependency chain (in reverse order) is:
> 
> -> #1 (&(&sch->busylock)->rlock){+.-...}:
>        [<c10a8b48>] lock_acquire+0x88/0x120
>        [<c16157bb>] _raw_spin_lock+0x3b/0x70
>        [<c1535cf8>] __inet_hash_nolisten+0xb8/0x140
>        [<c1536b77>] __inet_hash_connect+0x267/0x2c0
>        [<c1536c10>] inet_hash_connect+0x40/0x50
>        [<c154e4d4>] tcp_v4_connect+0x2c4/0x510
>        [<c156293f>] inet_stream_connect+0x1ff/0x380
>        [<c14e30c1>] sys_connect+0xc1/0xe0
>        [<c14e3d13>] sys_socketcall+0xe3/0x2e0
>        [<c161d89f>] sysenter_do_call+0x12/0x38
> 
> -> #0 (slock-AF_INET){+.-...}:
>        [<c10a78cc>] __lock_acquire+0xaec/0x17d0
>        [<c10a8b48>] lock_acquire+0x88/0x120
>        [<c16157bb>] _raw_spin_lock+0x3b/0x70
>        [<f85f5bff>] l2tp_xmit_skb+0x13f/0x8e0 [l2tp_core]
>        [<f851432d>] l2tp_eth_dev_xmit+0x2d/0x40 [l2tp_eth]
>        [<c14fa32f>] dev_hard_start_xmit+0x49f/0x7e0
>        [<c1515819>] sch_direct_xmit+0xa9/0x250
>        [<c14fa835>] dev_queue_xmit+0x1c5/0xbd0
>        [<c159442c>] ip6_finish_output2+0x11c/0x620
>        [<c159813f>] ip6_finish_output+0x7f/0x1e0
>        [<c15982ea>] ip6_output+0x4a/0x1f0
>        [<c15bbddc>] mld_sendpack+0x21c/0x530
>        [<c15bc817>] mld_ifc_timer_expire+0x187/0x260
>        [<c1055d10>] run_timer_softirq+0x140/0x370
>        [<c104da27>] __do_softirq+0x97/0x1f0
> 
> other info that might help us debug this:
> 
>  Possible unsafe locking scenario:
> 
>        CPU0                    CPU1
>        ----                    ----
>   lock(&(&sch->busylock)->rlock);
>                                lock(slock-AF_INET);
>                                lock(&(&sch->busylock)->rlock);
>   lock(slock-AF_INET);
> 
>  *** DEADLOCK ***
> 
> 5 locks held by swapper/1/0:
>  #0:  (&idev->mc_ifc_timer){+.-...}, at: [<c1055c88>] run_timer_softirq+0xb8/0x370
>  #1:  (rcu_read_lock){.+.+..}, at: [<c15bbbc0>] mld_sendpack+0x0/0x530
>  #2:  (rcu_read_lock){.+.+..}, at: [<c159434f>] ip6_finish_output2+0x3f/0x620
>  #3:  (rcu_read_lock_bh){.+....}, at: [<c14fa670>] dev_queue_xmit+0x0/0xbd0
>  #4:  (&(&sch->busylock)->rlock){+.-...}, at: [<c14fb1b2>] dev_queue_xmit+0xb42/0xbd0
> 
> stack backtrace:
> Pid: 0, comm: swapper/1 Not tainted 3.5.0-rc2-net-lockdep-u64-sync-006-+ #2
> Call Trace:
>  [<c160b540>] print_circular_bug+0x1b4/0x1be
>  [<c10a78cc>] __lock_acquire+0xaec/0x17d0
>  [<c10a8b48>] lock_acquire+0x88/0x120
>  [<f85f5bff>] ? l2tp_xmit_skb+0x13f/0x8e0 [l2tp_core]
>  [<c16157bb>] _raw_spin_lock+0x3b/0x70
>  [<f85f5bff>] ? l2tp_xmit_skb+0x13f/0x8e0 [l2tp_core]
>  [<f85f5bff>] l2tp_xmit_skb+0x13f/0x8e0 [l2tp_core]
>  [<f851432d>] l2tp_eth_dev_xmit+0x2d/0x40 [l2tp_eth]
>  [<c14fa32f>] dev_hard_start_xmit+0x49f/0x7e0
>  [<c14f9ee1>] ? dev_hard_start_xmit+0x51/0x7e0
>  [<c1515819>] sch_direct_xmit+0xa9/0x250
>  [<c16157e1>] ? _raw_spin_lock+0x61/0x70
>  [<c14fa835>] dev_queue_xmit+0x1c5/0xbd0
>  [<c14fa670>] ? dev_hard_start_xmit+0x7e0/0x7e0
>  [<c159442c>] ip6_finish_output2+0x11c/0x620
>  [<c159434f>] ? ip6_finish_output2+0x3f/0x620
>  [<c159813f>] ip6_finish_output+0x7f/0x1e0
>  [<c15982ea>] ip6_output+0x4a/0x1f0
>  [<c15a6ae0>] ? ip6_blackhole_route+0x2c0/0x2c0
>  [<c15bbddc>] mld_sendpack+0x21c/0x530
>  [<c15bbbc0>] ? igmp6_group_added+0x170/0x170
>  [<c15bc817>] mld_ifc_timer_expire+0x187/0x260
>  [<c1055d10>] run_timer_softirq+0x140/0x370
>  [<c1055c88>] ? run_timer_softirq+0xb8/0x370
>  [<c1085776>] ? rebalance_domains+0x1b6/0x2a0
>  [<c15bc690>] ? igmp6_timer_handler+0x80/0x80
>  [<c104da27>] __do_softirq+0x97/0x1f0
>  [<c104d990>] ? local_bh_enable_ip+0xd0/0xd0
>  <IRQ>  [<c104ddce>] ? irq_exit+0x7e/0xa0
>  [<c161e0f9>] ? smp_apic_timer_interrupt+0x59/0x88
>  [<c12fb498>] ? trace_hardirqs_off_thunk+0xc/0x14
>  [<c1616882>] ? apic_timer_interrupt+0x36/0x3c
>  [<c10380d5>] ? native_safe_halt+0x5/0x10
>  [<c1018bdf>] ? default_idle+0x4f/0x1e0
>  [<c1018dc1>] ? amd_e400_idle+0x51/0x100
>  [<c10199c9>] ? cpu_idle+0xb9/0xe0
>  [<c16038fc>] ? start_secondary+0x1ea/0x1f0
> 
> 
> 
> And on AMD64 UP machine:
> 
> ============================================
>  INFO: possible recursive locking detected ]
> .5.0-rc2-net-lockdep-u64-sync-006-+ #2 Not tainted
> --------------------------------------------
> wapper/0/0 is trying to acquire lock:
> (slock-AF_INET){+.-...}, at: [<f864fbff>] l2tp_xmit_skb+0x13f/0x8e0 [l2tp_core]
> 
> ut task is already holding lock:
> (slock-AF_INET){+.-...}, at: [<c154c177>] tcp_delack_timer+0x17/0x1e0
> 
> ther info that might help us debug this:
> Possible unsafe locking scenario:
> 
>       CPU0
>       ----
>  lock(slock-AF_INET);
>  lock(slock-AF_INET);
> 
> *** DEADLOCK ***
> 
> May be due to missing lock nesting notation
> 
>  locks held by swapper/0/0:
> #0:  (&icsk->icsk_delack_timer){+.-...}, at: [<c1055c88>] run_timer_softirq+0xb8/0x370
> #1:  (slock-AF_INET){+.-...}, at: [<c154c177>] tcp_delack_timer+0x17/0x1e0
> #2:  (rcu_read_lock){.+.+..}, at: [<c1531bf0>] ip_queue_xmit+0x0/0x610
> #3:  (rcu_read_lock){.+.+..}, at: [<c1531456>] ip_finish_output+0x106/0x710
> #4:  (rcu_read_lock_bh){.+....}, at: [<c14fa670>] dev_queue_xmit+0x0/0xbd0
> 
> tack backtrace:
> id: 0, comm: swapper/0 Not tainted 3.5.0-rc2-net-lockdep-u64-sync-006-+ #2
> all Trace:
> [<c10a7b32>] __lock_acquire+0xd52/0x17d0
> [<c1017ba8>] ? sched_clock+0x8/0x10
> [<c107edbb>] ? sched_clock_local+0xcb/0x1c0
> [<c10a8b48>] lock_acquire+0x88/0x120
> [<f864fbff>] ? l2tp_xmit_skb+0x13f/0x8e0 [l2tp_core]
> [<c16157bb>] _raw_spin_lock+0x3b/0x70
> [<f864fbff>] ? l2tp_xmit_skb+0x13f/0x8e0 [l2tp_core]
> [<f864fbff>] l2tp_xmit_skb+0x13f/0x8e0 [l2tp_core]
> [<f853032d>] l2tp_eth_dev_xmit+0x2d/0x40 [l2tp_eth]
> [<c14fa32f>] dev_hard_start_xmit+0x49f/0x7e0
> [<c14f9ee1>] ? dev_hard_start_xmit+0x51/0x7e0
> [<c1515819>] sch_direct_xmit+0xa9/0x250
> [<c16157e1>] ? _raw_spin_lock+0x61/0x70
> [<c14fa835>] dev_queue_xmit+0x1c5/0xbd0
> [<c14fa670>] ? dev_hard_start_xmit+0x7e0/0x7e0
> [<c15065f7>] neigh_resolve_output+0x117/0x230
> [<c1514880>] ? eth_rebuild_header+0x80/0x80
> [<c1531612>] ip_finish_output+0x2c2/0x710
> [<c1531456>] ? ip_finish_output+0x106/0x710
> [<c1532770>] ? ip_output+0x60/0x120
> [<c10a585b>] ? trace_hardirqs_on+0xb/0x10
> [<c153278b>] ip_output+0x7b/0x120
> [<c1531b95>] ip_local_out+0x25/0x80
> [<c1531d73>] ip_queue_xmit+0x183/0x610
> [<c1531bf0>] ? ip_local_out+0x80/0x80
> [<c154ecb5>] ? tcp_md5_do_lookup+0x125/0x170
> [<c15498c6>] tcp_transmit_skb+0x396/0x970
> [<c154bb12>] ? tcp_send_ack+0x32/0x100
> [<c154bb9d>] tcp_send_ack+0xbd/0x100
> [<c154c271>] tcp_delack_timer+0x111/0x1e0
> [<c1055d10>] run_timer_softirq+0x140/0x370
> [<c1055c88>] ? run_timer_softirq+0xb8/0x370
> [<c154c160>] ? tcp_out_of_resources+0xb0/0xb0
> [<c14f88cc>] ? net_rx_action+0x10c/0x210
> [<c104da27>] __do_softirq+0x97/0x1f0
> [<c104d990>] ? local_bh_enable_ip+0xd0/0xd0
> <IRQ>  [<c104ddce>] ? irq_exit+0x7e/0xa0
> [<c161e02b>] ? do_IRQ+0x4b/0xc0
> [<c161de75>] ? common_interrupt+0x35/0x3c
> [<c10380d5>] ? native_safe_halt+0x5/0x10
> [<c1018bdf>] ? default_idle+0x4f/0x1e0
> [<c1018dc1>] ? amd_e400_idle+0x51/0x100
> [<c10199c9>] ? cpu_idle+0xb9/0xe0
> [<c15eab3e>] ? rest_init+0x112/0x124
> [<c15eaa2c>] ? __read_lock_failed+0x14/0x14
> [<c1907a11>] ? start_kernel+0x376/0x37c
> [<c19074d6>] ? repair_env_string+0x51/0x51
> [<c19072f8>] ? i386_start_kernel+0x9b/0xa2
> 

Hi Tom

Could you please test following patch ?

Thanks !

[PATCH] net: Qdisc busylock gets its own lockdep class

Tom Parkin reported following LOCKDEP splat :

======================================================
[ INFO: possible circular locking dependency detected ]
3.5.0-rc2-net-lockdep-u64-sync-006-+ #2 Not tainted
-------------------------------------------------------
swapper/1/0 is trying to acquire lock:
 (slock-AF_INET){+.-...}, at: [<f85f5bff>] l2tp_xmit_skb+0x13f/0x8e0
[l2tp_core]

but task is already holding lock:
 (&(&sch->busylock)->rlock){+.-...}, at: [<c14fb1b2>] dev_queue_xmit
+0xb42/0xbd0

which lock already depends on the new lock.


the existing dependency chain (in reverse order) is:

-> #1 (&(&sch->busylock)->rlock){+.-...}:
       [<c10a8b48>] lock_acquire+0x88/0x120
       [<c16157bb>] _raw_spin_lock+0x3b/0x70
       [<c1535cf8>] __inet_hash_nolisten+0xb8/0x140
       [<c1536b77>] __inet_hash_connect+0x267/0x2c0
       [<c1536c10>] inet_hash_connect+0x40/0x50
       [<c154e4d4>] tcp_v4_connect+0x2c4/0x510
       [<c156293f>] inet_stream_connect+0x1ff/0x380
       [<c14e30c1>] sys_connect+0xc1/0xe0
       [<c14e3d13>] sys_socketcall+0xe3/0x2e0
       [<c161d89f>] sysenter_do_call+0x12/0x38

-> #0 (slock-AF_INET){+.-...}:
       [<c10a78cc>] __lock_acquire+0xaec/0x17d0
       [<c10a8b48>] lock_acquire+0x88/0x120
       [<c16157bb>] _raw_spin_lock+0x3b/0x70
       [<f85f5bff>] l2tp_xmit_skb+0x13f/0x8e0 [l2tp_core]
       [<f851432d>] l2tp_eth_dev_xmit+0x2d/0x40 [l2tp_eth]
       [<c14fa32f>] dev_hard_start_xmit+0x49f/0x7e0
       [<c1515819>] sch_direct_xmit+0xa9/0x250
       [<c14fa835>] dev_queue_xmit+0x1c5/0xbd0
       [<c159442c>] ip6_finish_output2+0x11c/0x620
       [<c159813f>] ip6_finish_output+0x7f/0x1e0
       [<c15982ea>] ip6_output+0x4a/0x1f0
       [<c15bbddc>] mld_sendpack+0x21c/0x530
       [<c15bc817>] mld_ifc_timer_expire+0x187/0x260
       [<c1055d10>] run_timer_softirq+0x140/0x370
       [<c104da27>] __do_softirq+0x97/0x1f0

other info that might help us debug this:

 Possible unsafe locking scenario:

       CPU0                    CPU1
       ----                    ----
  lock(&(&sch->busylock)->rlock);
                               lock(slock-AF_INET);
                               lock(&(&sch->busylock)->rlock);
  lock(slock-AF_INET);

 *** DEADLOCK ***

5 locks held by swapper/1/0:
 #0:  (&idev->mc_ifc_timer){+.-...}, at: [<c1055c88>] run_timer_softirq
+0xb8/0x370
 #1:  (rcu_read_lock){.+.+..}, at: [<c15bbbc0>] mld_sendpack+0x0/0x530
 #2:  (rcu_read_lock){.+.+..}, at: [<c159434f>] ip6_finish_output2
+0x3f/0x620
 #3:  (rcu_read_lock_bh){.+....}, at: [<c14fa670>] dev_queue_xmit
+0x0/0xbd0
 #4:  (&(&sch->busylock)->rlock){+.-...}, at: [<c14fb1b2>]
dev_queue_xmit+0xb42/0xbd0

stack backtrace:
Pid: 0, comm: swapper/1 Not tainted 3.5.0-rc2-net-lockdep-u64-sync-006-+
#2
Call Trace:
 [<c160b540>] print_circular_bug+0x1b4/0x1be
 [<c10a78cc>] __lock_acquire+0xaec/0x17d0
 [<c10a8b48>] lock_acquire+0x88/0x120
 [<f85f5bff>] ? l2tp_xmit_skb+0x13f/0x8e0 [l2tp_core]
 [<c16157bb>] _raw_spin_lock+0x3b/0x70
 [<f85f5bff>] ? l2tp_xmit_skb+0x13f/0x8e0 [l2tp_core]
 [<f85f5bff>] l2tp_xmit_skb+0x13f/0x8e0 [l2tp_core]
 [<f851432d>] l2tp_eth_dev_xmit+0x2d/0x40 [l2tp_eth]
 [<c14fa32f>] dev_hard_start_xmit+0x49f/0x7e0
 [<c14f9ee1>] ? dev_hard_start_xmit+0x51/0x7e0
 [<c1515819>] sch_direct_xmit+0xa9/0x250
 [<c16157e1>] ? _raw_spin_lock+0x61/0x70
 [<c14fa835>] dev_queue_xmit+0x1c5/0xbd0
 [<c14fa670>] ? dev_hard_start_xmit+0x7e0/0x7e0
 [<c159442c>] ip6_finish_output2+0x11c/0x620
 [<c159434f>] ? ip6_finish_output2+0x3f/0x620
 [<c159813f>] ip6_finish_output+0x7f/0x1e0
 [<c15982ea>] ip6_output+0x4a/0x1f0
 [<c15a6ae0>] ? ip6_blackhole_route+0x2c0/0x2c0
 [<c15bbddc>] mld_sendpack+0x21c/0x530
 [<c15bbbc0>] ? igmp6_group_added+0x170/0x170
 [<c15bc817>] mld_ifc_timer_expire+0x187/0x260
 [<c1055d10>] run_timer_softirq+0x140/0x370
 [<c1055c88>] ? run_timer_softirq+0xb8/0x370
 [<c1085776>] ? rebalance_domains+0x1b6/0x2a0
 [<c15bc690>] ? igmp6_timer_handler+0x80/0x80
 [<c104da27>] __do_softirq+0x97/0x1f0
 [<c104d990>] ? local_bh_enable_ip+0xd0/0xd0
 <IRQ>  [<c104ddce>] ? irq_exit+0x7e/0xa0
 [<c161e0f9>] ? smp_apic_timer_interrupt+0x59/0x88
 [<c12fb498>] ? trace_hardirqs_off_thunk+0xc/0x14
 [<c1616882>] ? apic_timer_interrupt+0x36/0x3c
 [<c10380d5>] ? native_safe_halt+0x5/0x10
 [<c1018bdf>] ? default_idle+0x4f/0x1e0
 [<c1018dc1>] ? amd_e400_idle+0x51/0x100
 [<c10199c9>] ? cpu_idle+0xb9/0xe0
 [<c16038fc>] ? start_secondary+0x1ea/0x1f0

Instruct lockdep that each Qdisc busylock is independant, or else
bonding or various tunnels can trigger a splat.

Reported-by: Tom Parkin <tparkin@katalix.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/sch_generic.h |    1 +
 net/sched/sch_generic.c   |    1 +
 2 files changed, 2 insertions(+)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 9d7d54a..a45b501 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -83,6 +83,7 @@ struct Qdisc {
 	struct rcu_head		rcu_head;
 	spinlock_t		busylock;
 	u32			limit;
+	struct lock_class_key	busylock_key;
 };
 
 static inline bool qdisc_is_running(const struct Qdisc *qdisc)
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 511323e..3357c6d 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -572,6 +572,7 @@ struct Qdisc *qdisc_alloc(struct netdev_queue *dev_queue,
 	INIT_LIST_HEAD(&sch->list);
 	skb_queue_head_init(&sch->q);
 	spin_lock_init(&sch->busylock);
+	lockdep_set_class(&sch->busylock, &sch->busylock_key);
 	sch->ops = ops;
 	sch->enqueue = ops->enqueue;
 	sch->dequeue = ops->dequeue;

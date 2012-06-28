From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: LOCKDEP complaints in l2tp_xmit_skb()
Date: Thu, 28 Jun 2012 17:00:42 +0200
Message-ID: <1340895642.13187.107.camel@edumazet-glaptop>
References: <20120627111152.GA2531@raven>
	 <1340866572.26242.312.camel@edumazet-glaptop>
	 <1340873862.13187.5.camel@edumazet-glaptop>
	 <1340882551.13187.96.camel@edumazet-glaptop>  <20120628143302.GB2507@raven>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Tom Parkin <tparkin@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:42708 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755030Ab2F1PAq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 11:00:46 -0400
Received: by eaak11 with SMTP id k11so843651eaa.19
        for <netdev@vger.kernel.org>; Thu, 28 Jun 2012 08:00:45 -0700 (PDT)
In-Reply-To: <20120628143302.GB2507@raven>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-06-28 at 15:33 +0100, Tom Parkin wrote:
> On Thu, Jun 28, 2012 at 01:22:31PM +0200, Eric Dumazet wrote:
> > On Thu, 2012-06-28 at 10:57 +0200, Eric Dumazet wrote:
> > > On Thu, 2012-06-28 at 08:56 +0200, Eric Dumazet wrote:
> > > 
> > > > [PATCH] net: Qdisc busylock gets its own lockdep class
> > > > 
> > > > Tom Parkin reported following LOCKDEP splat :
> > > ..
> > > > 
> > > > Instruct lockdep that each Qdisc busylock is independant, or else
> > > > bonding or various tunnels can trigger a splat.
> > > > 
> > > > Reported-by: Tom Parkin <tparkin@katalix.com>
> > > > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > > > ---
> > > 
> > > I reproduced the bug using a bond0 device, adding a qdisc on it,
> > > (one Qdisc on bond0, and a Qdisc on the slave too)
> > > 
> > > Problem with this patch is I have following message :
> > > 
> > > BUG: key ffff88..... not in .data!
> > > 
> > > No more LOCKDEP splat, but patch not good as is.
> > 
> > I tested the alternative following patch with my bonding setup,
> > could you test it with l2tp ?
> >
> 
> I've tested against my l2tp test configuration and I still see LOCKDEP
> splats:
> 
> 2tp_core: L2TP core driver, V2.0
> 2tp_netlink: L2TP netlink interface
> 2tp_eth: L2TP ethernet pseudowire support (L2TPv3)
> 
> ============================================
>  INFO: possible recursive locking detected ]
> .5.0-rc2-net-lockdep-u64-sync-007-+ #1 Not tainted
> --------------------------------------------
> wapper/0/0 is trying to acquire lock:
> (slock-AF_INET){+.-...}, at: [<f862abff>] l2tp_xmit_skb+0x13f/0x8e0 [l2tp_core]
> 
> ut task is already holding lock:
> (slock-AF_INET){+.-...}, at: [<c15333d7>] ip_send_reply+0x107/0x2b0
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
> #0:  (rcu_read_lock){.+.+..}, at: [<c14f7824>] __netif_receive_skb+0xe4/0x8d0
> #1:  (rcu_read_lock){.+.+..}, at: [<c152bd4c>] ip_local_deliver_finish+0x3c/0x4c0
> #2:  (slock-AF_INET){+.-...}, at: [<c15333d7>] ip_send_reply+0x107/0x2b0
> #3:  (rcu_read_lock){.+.+..}, at: [<c1531456>] ip_finish_output+0x106/0x710
> #4:  (rcu_read_lock_bh){.+....}, at: [<c14fa670>] dev_queue_xmit+0x0/0xbd0
> 
> tack backtrace:
> id: 0, comm: swapper/0 Not tainted 3.5.0-rc2-net-lockdep-u64-sync-007-+ #1
> all Trace:
> [<c10a7b32>] __lock_acquire+0xd52/0x17d0
> [<c10a334b>] ? trace_hardirqs_off+0xb/0x10
> [<c10a8b48>] lock_acquire+0x88/0x120
> [<f862abff>] ? l2tp_xmit_skb+0x13f/0x8e0 [l2tp_core]
> [<c16157bb>] _raw_spin_lock+0x3b/0x70
> [<f862abff>] ? l2tp_xmit_skb+0x13f/0x8e0 [l2tp_core]
> [<f862abff>] l2tp_xmit_skb+0x13f/0x8e0 [l2tp_core]
> [<f851a32d>] l2tp_eth_dev_xmit+0x2d/0x40 [l2tp_eth]
> [<c14fa32f>] dev_hard_start_xmit+0x49f/0x7e0
> [<c14f9ee1>] ? dev_hard_start_xmit+0x51/0x7e0
> [<c1515819>] sch_direct_xmit+0xa9/0x250
> [<c16157e1>] ? _raw_spin_lock+0x61/0x70
> [<c14fa83f>] dev_queue_xmit+0x1cf/0xbd0
> [<c14fa670>] ? dev_hard_start_xmit+0x7e0/0x7e0
> [<c1531537>] ip_finish_output+0x1e7/0x710
> [<c1531456>] ? ip_finish_output+0x106/0x710
> [<c1532770>] ? ip_output+0x60/0x120
> [<c10a585b>] ? trace_hardirqs_on+0xb/0x10
> [<c153278b>] ip_output+0x7b/0x120
> [<c1532fc9>] ? __ip_make_skb+0x229/0x360
> [<c1531b95>] ip_local_out+0x25/0x80
> [<c1533117>] ip_send_skb+0x17/0x70
> [<c153319b>] ip_push_pending_frames+0x2b/0x40
> [<c1533495>] ip_send_reply+0x1c5/0x2b0
> [<c107efef>] ? sched_clock_cpu+0xcf/0x150
> [<c154f253>] tcp_v4_send_ack+0x1a3/0x260
> [<c1552430>] ? tcp_timewait_state_process+0x90/0x3c0
> [<c15514ef>] tcp_v4_rcv+0x3ff/0xc20
> [<c152bdff>] ip_local_deliver_finish+0xef/0x4c0
> [<c152bd4c>] ? ip_local_deliver_finish+0x3c/0x4c0
> [<c152c40f>] ip_local_deliver+0x3f/0x80
> [<c152b844>] ip_rcv_finish+0x174/0x640
> [<c152c671>] ip_rcv+0x221/0x320
> [<c14f7f11>] __netif_receive_skb+0x7d1/0x8d0
> [<c14f7824>] ? __netif_receive_skb+0xe4/0x8d0
> [<c14f80b7>] process_backlog+0xa7/0x170
> [<c14f88dd>] net_rx_action+0x11d/0x210
> [<c104d990>] ? local_bh_enable_ip+0xd0/0xd0
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

Yes, but this is not the splat I fixed.

You reported two different splats, didnt you ?

I fixed a core network issue, I am sure guys who wrote l2tp can fix the
l2tp one ;)

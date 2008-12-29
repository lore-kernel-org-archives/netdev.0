From: Ingo Molnar <mingo@elte.hu>
Subject: Re: unsafe locks seen with netperf on net-2.6.29 tree
Date: Mon, 29 Dec 2008 10:57:39 +0100
Message-ID: <20081229095739.GA10084@elte.hu>
References: <9929d2390812250225w19bcd2f7n11357ff26de78c52@mail.gmail.com> <20081225112658.GA7260@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Emil Tantilov <emil.s.tantilov@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	linux-kernel@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:44826 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753814AbYL2J6B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Dec 2008 04:58:01 -0500
Content-Disposition: inline
In-Reply-To: <20081225112658.GA7260@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Thu, Dec 25, 2008 at 10:25:44AM +0000, Jeff Kirsher wrote:
> >
> > [ 1439.758437] ======================================================
> > [ 1439.758724] [ INFO: soft-safe -> soft-unsafe lock order detected ]
> > [ 1439.758868] 2.6.28-rc8-net-next-igb #13
> > [ 1439.759007] ------------------------------------------------------
> > [ 1439.759150] netperf/22302 [HC0[0]:SC0[1]:HE1:SE0] is trying to acquire:
> > [ 1439.759293]  (&fbc->lock){--..}, at: [<ffffffff803691a6>]
> > __percpu_counter_add+0x4a/0x6d
> > [ 1439.759581]
> > [ 1439.759582] and this task is already holding:
> > [ 1439.759853]  (slock-AF_INET){-+..}, at: [<ffffffff804fdca6>]
> > tcp_close+0x16c/0x2da
> > [ 1439.760137] which would create a new lock dependency:
> > [ 1439.762122]  (slock-AF_INET){-+..} -> (&fbc->lock){--..}
> 
> This is a false positive.  The lock slock is not a normal lock.
> It's an ancient creature that's a spinlock in interrupt context
> and a semaphore in process context.
> 
> In particular, holding slock in process context does not disable 
> softirqs and you're still allowed to take the spinlock portion of slock 
> on the same CPU through an interrupt.  What happens is that the softirq 
> will notice that the slock is already taken by process context, and 
> defer the work for later.

False positive or not, this splat has now been allowed upstream - i just 
got it with v2.6.28-3114-g3c92ec8:

[   42.312021] eth0: no IPv6 routers present
[   71.252349] 
[   71.252354] =================================
[   71.256258] [ INFO: inconsistent lock state ]
[   71.256258] 2.6.28-tip-03857-g33ad6a3-dirty #13095
[   71.256258] ---------------------------------
[   71.256258] inconsistent {softirq-on-W} -> {in-softirq-W} usage.
[   71.256258] cc1/3913 [HC0[0]:SC1[1]:HE1:SE0] takes:
[   71.256258]  (&fbc->lock){-+..}, at: [<c0417b35>] __percpu_counter_add+0x65/0xb0
[   71.256258] {softirq-on-W} state was registered at:
[   71.256258]   [<c016696c>] __lock_acquire+0x4cc/0x640
[   71.256258]   [<c0166b69>] lock_acquire+0x89/0xc0
[   71.256258]   [<c0dddb7b>] _spin_lock+0x3b/0x70
[   71.256258]   [<c0417b35>] __percpu_counter_add+0x65/0xb0
[   71.256258]   [<c01bf0fa>] get_empty_filp+0x6a/0x1d0
[   71.256258]   [<c01c85e9>] path_lookup_open+0x29/0x90
[   71.256258]   [<c01c86e2>] do_filp_open+0x92/0x7a0
[   71.256258]   [<c01bc32c>] do_sys_open+0x4c/0x90
[   71.256258]   [<c01bc3de>] sys_open+0x2e/0x40
[   71.256258]   [<c0103e6f>] sysenter_do_call+0x12/0x43
[   71.256258]   [<ffffffff>] 0xffffffff
[   71.256258] irq event stamp: 18174
[   71.256258] hardirqs last  enabled at (18174): [<c0196de6>] free_hot_cold_page+0x1b6/0x280
[   71.256258] hardirqs last disabled at (18173): [<c0196d3e>] free_hot_cold_page+0x10e/0x280
[   71.256258] softirqs last  enabled at (18136): [<c0143ee2>] __do_softirq+0x132/0x180
[   71.256258] softirqs last disabled at (18139): [<c010631a>] call_on_stack+0x1a/0x30
[   71.256258] 
[   71.256258] other info that might help us debug this:
[   71.256258] 4 locks held by cc1/3913:
[   71.256258]  #0:  (rcu_read_lock){..--}, at: [<c0ba49b0>] net_rx_action+0xd0/0x250
[   71.256258]  #1:  (rcu_read_lock){..--}, at: [<c0ba1f62>] netif_receive_skb+0xf2/0x340
[   71.256258]  #2:  (rcu_read_lock){..--}, at: [<c0c01556>] ip_local_deliver_finish+0x36/0x200
[   71.256258]  #3:  (slock-AF_INET/1){-+..}, at: [<c0c1f3b8>] tcp_v4_rcv+0x5b8/0x820
[   71.256258] 
[   71.256258] stack backtrace:
[   71.256258] Pid: 3913, comm: cc1 Not tainted 2.6.28-tip-03857-g33ad6a3-dirty #13095
[   71.256258] Call Trace:
[   71.256258]  [<c0163fc6>] print_usage_bug+0x176/0x1d0
[   71.256258]  [<c01662ef>] mark_lock+0xbcf/0xd80
[   71.256258]  [<c0109566>] ? sched_clock+0x16/0x40
[   71.256258]  [<c016692b>] __lock_acquire+0x48b/0x640
[   71.256258]  [<c0167581>] ? trace_hardirqs_on_caller+0x81/0x1e0
[   71.256258]  [<c01673f0>] ? mark_held_locks+0x30/0x80
[   71.256258]  [<c0196de6>] ? free_hot_cold_page+0x1b6/0x280
[   71.256258]  [<c0166b69>] lock_acquire+0x89/0xc0
[   71.256258]  [<c0417b35>] ? __percpu_counter_add+0x65/0xb0
[   71.256258]  [<c0dddb7b>] _spin_lock+0x3b/0x70
[   71.256258]  [<c0417b35>] ? __percpu_counter_add+0x65/0xb0
[   71.256258]  [<c0417b35>] __percpu_counter_add+0x65/0xb0
[   71.256258]  [<c0c0ac19>] inet_csk_destroy_sock+0x89/0x160
[   71.256258]  [<c0c0a1b5>] ? inet_csk_clear_xmit_timers+0x45/0x50
[   71.256258]  [<c0c0cbad>] tcp_done+0x4d/0x70
[   71.256258]  [<c0c16b6c>] tcp_rcv_state_process+0x68c/0x950
[   71.256258]  [<c0c1bd66>] ? tcp_v4_md5_do_lookup+0x16/0x70
[   71.256258]  [<c0c1e68b>] tcp_v4_do_rcv+0xdb/0x340
[   71.256258]  [<c0c1f3b8>] ? tcp_v4_rcv+0x5b8/0x820
[   71.256258]  [<c0dddb2f>] ? _spin_lock_nested+0x5f/0x70
[   71.256258]  [<c0c1f3d6>] tcp_v4_rcv+0x5d6/0x820
[   71.256258]  [<c0c219be>] ? raw_local_deliver+0xe/0x190
[   71.256258]  [<c0c01556>] ? ip_local_deliver_finish+0x36/0x200
[   71.256258]  [<c0c015d6>] ip_local_deliver_finish+0xb6/0x200
[   71.256258]  [<c0c01556>] ? ip_local_deliver_finish+0x36/0x200
[   71.256258]  [<c0c01752>] ip_local_deliver+0x32/0xa0
[   71.256258]  [<c0c01520>] ? ip_local_deliver_finish+0x0/0x200
[   71.256258]  [<c0c018ce>] ip_rcv_finish+0x10e/0x2f0
[   71.256258]  [<c0c017c0>] ? ip_rcv_finish+0x0/0x2f0
[   71.256258]  [<c0c01c8c>] ip_rcv+0x1dc/0x290
[   71.256258]  [<c0c017c0>] ? ip_rcv_finish+0x0/0x2f0
[   71.256258]  [<c0c01ab0>] ? ip_rcv+0x0/0x290
[   71.256258]  [<c0ba210c>] netif_receive_skb+0x29c/0x340
[   71.256258]  [<c0ba1f62>] ? netif_receive_skb+0xf2/0x340
[   71.256258]  [<c0166815>] ? __lock_acquire+0x375/0x640
[   71.256258]  [<c0b996d9>] ? skb_pull+0x9/0x40
[   71.256258]  [<c060f44e>] nv_napi_poll+0x33e/0x630
[   71.256258]  [<c0ba4a34>] net_rx_action+0x154/0x250
[   71.256258]  [<c0ba49b0>] ? net_rx_action+0xd0/0x250
[   71.256258]  [<c0143e59>] __do_softirq+0xa9/0x180
[   71.256258]  [<c0143db0>] ? __do_softirq+0x0/0x180
[   71.256258]  <IRQ>  [<c012d778>] ? idle_cpu+0x8/0x30
[   71.256258]  [<c014436c>] ? irq_exit+0x7c/0x90
[   71.256258]  [<c0106601>] ? do_IRQ+0xa1/0x120
[   71.256258]  [<c010452c>] ? common_interrupt+0x2c/0x34

	Ingo

From: Ingo Molnar <mingo@elte.hu>
Subject: Re: unsafe locks seen with netperf on net-2.6.29 tree
Date: Mon, 29 Dec 2008 13:38:19 +0100
Message-ID: <20081229123819.GA18321@elte.hu>
References: <1230410308.9487.295.camel@twins> <EA929A9653AAE14F841771FB1DE5A1365F56B664A3@rrsmsx501.amr.corp.intel.com> <1230544927.16718.12.camel@twins> <20081229103154.GA9691@gondor.apana.org.au> <20081229103735.GA9763@gondor.apana.org.au> <20081229112858.GA16385@elte.hu> <20081229114907.GA10170@gondor.apana.org.au> <20081229115827.GA441@elte.hu> <20081229120132.GA10363@gondor.apana.org.au> <20081229121626.GF9628@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	"Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	Eric Dumazet <dada1@cosmosbay.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:57835 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750710AbYL2Mif (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Dec 2008 07:38:35 -0500
Content-Disposition: inline
In-Reply-To: <20081229121626.GF9628@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Ingo Molnar <mingo@elte.hu> wrote:

> 
> * Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
> > On Mon, Dec 29, 2008 at 12:58:27PM +0100, Ingo Molnar wrote:
> > >
> > > no, i only applied one of them. Is his second patch a good solution in 
> > > your opinion, and should i thus test both of them? (or will the second one 
> > > iterate some more - in which case i will keep the revert for now)
> > 
> > Well the second patch is definitely the right solution to the problem 
> > as reported.  It just needs to be extended to fix other similar bugs 
> > introduced by the original changeset.
> 
> okay - will keep the revert for now and will wait for you guys to do the 
> full fix.

hm, even with the revert i got the splat below. So some other commits are 
causing this too?

	Ingo

=================================
[ INFO: inconsistent lock state ]
2.6.28-tip-03883-gf855e6c-dirty #13150
---------------------------------
inconsistent {softirq-on-W} -> {in-softirq-W} usage.
kjournald/1435 [HC0[0]:SC1[1]:HE1:SE0] takes:
 (&fbc->lock){-+..}, at: [<c034fc75>] __percpu_counter_add+0x65/0xb0
{softirq-on-W} state was registered at:
  [<c015da56>] __lock_acquire+0x4c6/0xae0
  [<c015e0f9>] lock_acquire+0x89/0xc0
  [<c07247a8>] _spin_lock+0x38/0x50
  [<c034fc75>] __percpu_counter_add+0x65/0xb0
  [<c01b704a>] get_empty_filp+0x6a/0x1d0
  [<c01c10a9>] path_lookup_open+0x29/0x90
  [<c01c134e>] do_filp_open+0x9e/0x790
  [<c01b3e60>] do_sys_open+0x50/0xe0
  [<c01b3f5e>] sys_open+0x2e/0x40
  [<c0103e76>] syscall_call+0x7/0xb
  [<ffffffff>] 0xffffffff
irq event stamp: 125790
hardirqs last  enabled at (125790): [<c0191c56>] free_hot_cold_page+0x1b6/0x280
hardirqs last disabled at (125789): [<c0191bae>] free_hot_cold_page+0x10e/0x280
softirqs last  enabled at (123900): [<c013ca12>] __do_softirq+0x132/0x180
softirqs last disabled at (125765): [<c010621a>] call_on_stack+0x1a/0x30

other info that might help us debug this:
4 locks held by kjournald/1435:
 #0:  (rcu_read_lock){..--}, at: [<c05bef70>] net_rx_action+0xd0/0x220
 #1:  (rcu_read_lock){..--}, at: [<c05bbfb1>] netif_receive_skb+0x101/0x3a0
 #2:  (rcu_read_lock){..--}, at: [<c05f1bf5>] ip_local_deliver+0x55/0x1d0
 #3:  (slock-AF_INET/1){-+..}, at: [<c060ec3a>] tcp_v4_rcv+0x55a/0x6e0

stack backtrace:
Pid: 1435, comm: kjournald Not tainted 2.6.28-tip-03883-gf855e6c-dirty #13150
Call Trace:
 [<c015a0d6>] print_usage_bug+0x176/0x1d0
 [<c015b800>] mark_lock+0xbd0/0xd80
 [<c015da13>] __lock_acquire+0x483/0xae0
 [<c015bcdb>] ? trace_hardirqs_on+0xb/0x10
 [<c015e0f9>] lock_acquire+0x89/0xc0
 [<c034fc75>] ? __percpu_counter_add+0x65/0xb0
 [<c07247a8>] _spin_lock+0x38/0x50
 [<c034fc75>] ? __percpu_counter_add+0x65/0xb0
 [<c034fc75>] __percpu_counter_add+0x65/0xb0
 [<c060dc49>] tcp_v4_destroy_sock+0x1d9/0x240
 [<c05fa06a>] inet_csk_destroy_sock+0x4a/0x140
 [<c05fa675>] ? inet_csk_clear_xmit_timers+0x45/0x50
 [<c05fb96d>] tcp_done+0x4d/0x70
 [<c060655c>] tcp_rcv_state_process+0x68c/0x950
 [<c060c9b6>] tcp_v4_do_rcv+0xd6/0x310
 [<c072475d>] ? _spin_lock_nested+0x3d/0x50
 [<c060ecc4>] tcp_v4_rcv+0x5e4/0x6e0
 [<c05f1bf5>] ? ip_local_deliver+0x55/0x1d0
 [<c05f1c44>] ip_local_deliver+0xa4/0x1d0
 [<c05f1bf5>] ? ip_local_deliver+0x55/0x1d0
 [<c05f201a>] ip_rcv+0x2aa/0x510
 [<c05bbfb1>] ? netif_receive_skb+0x101/0x3a0
 [<c05f1d70>] ? ip_rcv+0x0/0x510
 [<c05bc199>] netif_receive_skb+0x2e9/0x3a0
 [<c05bbfb1>] ? netif_receive_skb+0x101/0x3a0
 [<c015d8f1>] ? __lock_acquire+0x361/0xae0
 [<c05bc541>] napi_gro_receive+0x1c1/0x200
 [<c015b9e0>] ? mark_held_locks+0x30/0x80
 [<c05bf1bb>] ? process_backlog+0x7b/0xd0
 [<c05bf1d2>] process_backlog+0x92/0xd0
 [<c05beff4>] net_rx_action+0x154/0x220
 [<c05bef70>] ? net_rx_action+0xd0/0x220
 [<c013c989>] __do_softirq+0xa9/0x180
 [<c013c8e0>] ? __do_softirq+0x0/0x180
 <IRQ>  [<c013c8cd>] ? irq_exit+0x4d/0x60
 [<c01064ca>] ? do_IRQ+0x8a/0xe0
 [<c01b086f>] ? check_object+0xef/0x1f0
 [<c01044ac>] ? common_interrupt+0x2c/0x34
 [<c01b27d2>] ? kmem_cache_free+0xc2/0xf0
 [<c0234b65>] ? journal_write_revoke_records+0xa5/0x140
 [<c0234b65>] ? journal_write_revoke_records+0xa5/0x140
 [<c0234b65>] ? journal_write_revoke_records+0xa5/0x140
 [<c023276d>] ? journal_commit_transaction+0x42d/0xe80
 [<c015bc6e>] ? trace_hardirqs_on_caller+0x17e/0x1e0
 [<c015bcdb>] ? trace_hardirqs_on+0xb/0x10
 [<c014101e>] ? try_to_del_timer_sync+0x4e/0x60
 [<c023608b>] ? kjournald+0xbb/0x1d0
 [<c014b8e0>] ? autoremove_wake_function+0x0/0x40
 [<c0235fd0>] ? kjournald+0x0/0x1d0
 [<c014b5d7>] ? kthread+0x47/0x80
 [<c014b590>] ? kthread+0x0/0x80
 [<c010472f>] ? kernel_thread_helper+0x7/0x10


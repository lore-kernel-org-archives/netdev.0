From: Ingo Molnar <mingo@elte.hu>
Subject: Re: unsafe locks seen with netperf on net-2.6.29 tree
Date: Mon, 29 Dec 2008 12:28:58 +0100
Message-ID: <20081229112858.GA16385@elte.hu>
References: <9929d2390812250225w19bcd2f7n11357ff26de78c52@mail.gmail.com> <20081225112658.GA7260@gondor.apana.org.au> <1230300535.9487.292.camel@twins> <EA929A9653AAE14F841771FB1DE5A1365F56B6648A@rrsmsx501.amr.corp.intel.com> <1230410308.9487.295.camel@twins> <EA929A9653AAE14F841771FB1DE5A1365F56B664A3@rrsmsx501.amr.corp.intel.com> <1230544927.16718.12.camel@twins> <20081229103154.GA9691@gondor.apana.org.au> <20081229103735.GA9763@gondor.apana.org.au>
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
Received: from mx2.mail.elte.hu ([157.181.151.9]:56516 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751308AbYL2L3f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Dec 2008 06:29:35 -0500
Content-Disposition: inline
In-Reply-To: <20081229103735.GA9763@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Mon, Dec 29, 2008 at 09:31:54PM +1100, Herbert Xu wrote:
> >
> > You also need to patch the other places where we use that percpu
> > counter from process context, e.g., for /proc/net/tcp.
> 
> In fact, it looks like just about every spot in the original
> changeset (dd24c00191d5e4a1ae896aafe33c6b8095ab4bd1) may be run
> from process context.  So you might be better off making BH-disabling
> variants of the percpu counter ops.

i got the splat further below with Peter's workaround applied.

	Ingo

[   65.163041] 
[   65.163041] ======================================================
[   65.164028] [ INFO: soft-safe -> soft-unsafe lock order detected ]
[   65.164028] 2.6.28-tip-03865-gb8c8c2c-dirty #13131
[   65.164028] ------------------------------------------------------
[   65.164028] ssh/2856 [HC0[0]:SC0[1]:HE1:SE0] is trying to acquire:
[   65.164028]  (&fbc->lock){--..}, at: [<c03a94d4>] __percpu_counter_add+0x52/0x7a
[   65.164028] 
[   65.164028] and this task is already holding:
[   65.164028]  (slock-AF_INET){-+..}, at: [<c05fd3f3>] tcp_close+0x184/0x335
[   65.164028] which would create a new lock dependency:
[   65.164028]  (slock-AF_INET){-+..} -> (&fbc->lock){--..}
[   65.164028] 
[   65.164028] but this new dependency connects a soft-irq-safe lock:
[   65.164028]  (slock-AF_INET){-+..}
[   65.164028] ... which became soft-irq-safe at:
[   65.164028]   [<c014d9a4>] __lock_acquire+0x51a/0x746
[   65.164028]   [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]   [<c06c8ab8>] _spin_lock+0x23/0x53
[   65.164028]   [<c0608651>] tcp_delack_timer+0x17/0x1b1
[   65.164028]   [<c0134d2e>] run_timer_softirq+0x144/0x1a4
[   65.164028]   [<c01314ec>] __do_softirq+0x9d/0x154
[   65.164028]   [<ffffffff>] 0xffffffff
[   65.164028] 
[   65.164028] to a soft-irq-unsafe lock:
[   65.164028]  (&fbc->lock){--..}
[   65.164028] ... which became soft-irq-unsafe at:
[   65.164028] ...  [<c014da19>] __lock_acquire+0x58f/0x746
[   65.164028]   [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]   [<c06c8ab8>] _spin_lock+0x23/0x53
[   65.164028]   [<c03a94d4>] __percpu_counter_add+0x52/0x7a
[   65.164028]   [<c019a133>] get_empty_filp+0x9f/0x1b0
[   65.164028]   [<c01a2612>] path_lookup_open+0x23/0x7a
[   65.164028]   [<c01a2710>] do_filp_open+0xa7/0x67e
[   65.164028]   [<c019777c>] do_sys_open+0x47/0xbc
[   65.164028]   [<c019783d>] sys_open+0x23/0x2b
[   65.164028]   [<c010388b>] sysenter_do_call+0x12/0x3f
[   65.164028]   [<ffffffff>] 0xffffffff
[   65.164028] 
[   65.164028] other info that might help us debug this:
[   65.164028] 
[   65.164028] 1 lock held by ssh/2856:
[   65.164028]  #0:  (slock-AF_INET){-+..}, at: [<c05fd3f3>] tcp_close+0x184/0x335
[   65.164028] 
[   65.164028] the soft-irq-safe lock's dependencies:
[   65.164028] -> (slock-AF_INET){-+..} ops: 0 {
[   65.164028]    initial-use  at:
[   65.164028]                                        [<c014da2e>] __lock_acquire+0x5a4/0x746
[   65.164028]                                        [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                        [<c06c8b10>] _spin_lock_bh+0x28/0x58
[   65.164028]                                        [<c05c3916>] lock_sock_nested+0x2c/0xc3
[   65.164028]                                        [<c05fd289>] tcp_close+0x1a/0x335
[   65.164028]                                        [<c0615b42>] inet_release+0x47/0x4d
[   65.164028]                                        [<c05c20be>] sock_release+0x15/0x58
[   65.164028]                                        [<c05c2510>] sock_close+0x21/0x25
[   65.164028]                                        [<c0199f08>] __fput+0xcf/0x1a2
[   65.164028]                                        [<c019a2da>] fput+0x1c/0x1e
[   65.164028]                                        [<c0197685>] filp_close+0x55/0x5f
[   65.164028]                                        [<c01976fc>] sys_close+0x6d/0xa6
[   65.164028]                                        [<c010388b>] sysenter_do_call+0x12/0x3f
[   65.164028]                                        [<ffffffff>] 0xffffffff
[   65.164028]    in-softirq-W at:
[   65.164028]                                        [<c014d9a4>] __lock_acquire+0x51a/0x746
[   65.164028]                                        [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                        [<c06c8ab8>] _spin_lock+0x23/0x53
[   65.164028]                                        [<c0608651>] tcp_delack_timer+0x17/0x1b1
[   65.164028]                                        [<c0134d2e>] run_timer_softirq+0x144/0x1a4
[   65.164028]                                        [<c01314ec>] __do_softirq+0x9d/0x154
[   65.164028]                                        [<ffffffff>] 0xffffffff
[   65.164028]    hardirq-on-W at:
[   65.164028]                                        [<c014d9f8>] __lock_acquire+0x56e/0x746
[   65.164028]                                        [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                        [<c06c8b10>] _spin_lock_bh+0x28/0x58
[   65.164028]                                        [<c05c3916>] lock_sock_nested+0x2c/0xc3
[   65.164028]                                        [<c05fd289>] tcp_close+0x1a/0x335
[   65.164028]                                        [<c0615b42>] inet_release+0x47/0x4d
[   65.164028]                                        [<c05c20be>] sock_release+0x15/0x58
[   65.164028]                                        [<c05c2510>] sock_close+0x21/0x25
[   65.164028]                                        [<c0199f08>] __fput+0xcf/0x1a2
[   65.164028]                                        [<c019a2da>] fput+0x1c/0x1e
[   65.164028]                                        [<c0197685>] filp_close+0x55/0x5f
[   65.164028]                                        [<c01976fc>] sys_close+0x6d/0xa6
[   65.164028]                                        [<c010388b>] sysenter_do_call+0x12/0x3f
[   65.164028]                                        [<ffffffff>] 0xffffffff
[   65.164028]  }
[   65.164028]  ... key      at: [<c132a184>] af_family_slock_keys+0x10/0x120
[   65.164028]  -> (pool_lock){.+..} ops: 0 {
[   65.164028]     initial-use  at:
[   65.164028]                                          [<c014da2e>] __lock_acquire+0x5a4/0x746
[   65.164028]                                          [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                          [<c06c8ab8>] _spin_lock+0x23/0x53
[   65.164028]                                          [<c03a5da9>] __debug_object_init+0xb5/0x29e
[   65.164028]                                          [<c03a5fbd>] debug_object_init+0x13/0x16
[   65.164028]                                          [<c0140344>] hrtimer_init+0x1b/0x2b
[   65.164028]                                          [<c0a7b1da>] sched_init+0x99/0x333
[   65.164028]                                          [<c0a6e6a9>] start_kernel+0x13e/0x30a
[   65.164028]                                          [<c0a6e056>] i386_start_kernel+0x56/0x5e
[   65.164028]                                          [<ffffffff>] 0xffffffff
[   65.164028]     in-softirq-W at:
[   65.164028]                                          [<c014d9a4>] __lock_acquire+0x51a/0x746
[   65.164028]                                          [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                          [<c06c8f2e>] _spin_lock_irqsave+0x3f/0x72
[   65.164028]                                          [<c03a5d3b>] __debug_object_init+0x47/0x29e
[   65.164028]                                          [<c03a5fbd>] debug_object_init+0x13/0x16
[   65.164028]                                          [<c0134b9b>] timer_fixup_activate+0x2d/0x7c
[   65.164028]                                          [<c03a5805>] debug_object_fixup+0x17/0x22
[   65.164028]                                          [<c03a5bb1>] debug_object_activate+0xb6/0xbd
[   65.164028]                                          [<c0135350>] __mod_timer+0x6d/0xc8
[   65.164028]                                          [<c0135585>] mod_timer+0x38/0x3c
[   65.164028]                                          [<c05f9c54>] inet_twsk_schedule+0x13f/0x158
[   65.164028]                                          [<c060c7aa>] tcp_time_wait+0x169/0x1a7
[   65.164028]                                          [<c0600b00>] tcp_fin+0x80/0x16a
[   65.164028]                                          [<c060159d>] tcp_data_queue+0x293/0xa6d
[   65.164028]                                          [<c0604869>] tcp_rcv_state_process+0x852/0x8b7
[   65.164028]                                          [<c0609f92>] tcp_v4_do_rcv+0x25c/0x2a5
[   65.164028]                                          [<c060be0b>] tcp_v4_rcv+0x67d/0x6d2
[   65.164028]                                          [<c05f2c95>] ip_local_deliver_finish+0x112/0x1c5
[   65.164028]                                          [<c05f309a>] ip_local_deliver+0x59/0x63
[   65.164028]                                          [<c05f2b6d>] ip_rcv_finish+0x285/0x29b
[   65.164028]                                          [<c05f3017>] ip_rcv+0x1f1/0x21b
[   65.164028]                                          [<c05cc853>] netif_receive_skb+0x2f2/0x325
[   65.164028]                                          [<c04b597f>] nv_napi_poll+0x3b9/0x4d2
[   65.164028]                                          [<c05cefec>] net_rx_action+0xd6/0x1f7
[   65.164028]                                          [<c01314ec>] __do_softirq+0x9d/0x154
[   65.164028]                                          [<ffffffff>] 0xffffffff
[   65.164028]   }
[   65.164028]   ... key      at: [<c09f5924>] pool_lock+0x10/0x24
[   65.164028]  ... acquired at:
[   65.164028]    [<c014d1b5>] validate_chain+0x8f9/0xbce
[   65.164028]    [<c014db6a>] __lock_acquire+0x6e0/0x746
[   65.164028]    [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]    [<c06c8f2e>] _spin_lock_irqsave+0x3f/0x72
[   65.164028]    [<c03a5d3b>] __debug_object_init+0x47/0x29e
[   65.164028]    [<c03a5fbd>] debug_object_init+0x13/0x16
[   65.164028]    [<c0134b4d>] init_timer+0x15/0x1f
[   65.164028]    [<c05faa8f>] inet_csk_init_xmit_timers+0x25/0x6a
[   65.164028]    [<c0608305>] tcp_init_xmit_timers+0x1c/0x1f
[   65.164028]    [<c060c40d>] tcp_create_openreq_child+0x190/0x3c4
[   65.164028]    [<c060a5f4>] tcp_v4_syn_recv_sock+0x53/0x1c0
[   65.164028]    [<c060c0f0>] tcp_check_req+0x1e0/0x36d
[   65.164028]    [<c0609ee8>] tcp_v4_do_rcv+0x1b2/0x2a5
[   65.164028]    [<c060be0b>] tcp_v4_rcv+0x67d/0x6d2
[   65.164028]    [<c05f2c95>] ip_local_deliver_finish+0x112/0x1c5
[   65.164028]    [<c05f309a>] ip_local_deliver+0x59/0x63
[   65.164028]    [<c05f2b6d>] ip_rcv_finish+0x285/0x29b
[   65.164028]    [<c05f3017>] ip_rcv+0x1f1/0x21b
[   65.164028]    [<c05cc853>] netif_receive_skb+0x2f2/0x325
[   65.164028]    [<c04b597f>] nv_napi_poll+0x3b9/0x4d2
[   65.164028]    [<c05cefec>] net_rx_action+0xd6/0x1f7
[   65.164028]    [<c01314ec>] __do_softirq+0x9d/0x154
[   65.164028]    [<ffffffff>] 0xffffffff
[   65.164028] 
[   65.164028]  -> (&obj_hash[i].lock){++..} ops: 0 {
[   65.164028]     initial-use  at:
[   65.164028]                                          [<c014da2e>] __lock_acquire+0x5a4/0x746
[   65.164028]                                          [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                          [<c06c8f2e>] _spin_lock_irqsave+0x3f/0x72
[   65.164028]                                          [<c03a5d89>] __debug_object_init+0x95/0x29e
[   65.164028]                                          [<c03a5fbd>] debug_object_init+0x13/0x16
[   65.164028]                                          [<c0140344>] hrtimer_init+0x1b/0x2b
[   65.164028]                                          [<c0a7b1da>] sched_init+0x99/0x333
[   65.164028]                                          [<c0a6e6a9>] start_kernel+0x13e/0x30a
[   65.164028]                                          [<c0a6e056>] i386_start_kernel+0x56/0x5e
[   65.164028]                                          [<ffffffff>] 0xffffffff
[   65.164028]     in-hardirq-W at:
[   65.164028]                                          [<c014d983>] __lock_acquire+0x4f9/0x746
[   65.164028]                                          [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                          [<c06c8f2e>] _spin_lock_irqsave+0x3f/0x72
[   65.164028]                                          [<c03a5a95>] debug_object_deactivate+0x29/0x8f
[   65.164028]                                          [<c0140473>] __run_hrtimer+0x47/0xae
[   65.164028]                                          [<c01407e2>] hrtimer_run_queues+0xf6/0x124
[   65.164028]                                          [<c0134fb5>] run_local_timers+0xd/0x1e
[   65.164028]                                          [<c0135445>] update_process_times+0x29/0x53
[   65.164028]                                          [<c0147766>] tick_periodic+0x6b/0x6d
[   65.164028]                                          [<c0147786>] tick_handle_periodic+0x1e/0x60
[   65.164028]                                          [<c06c943c>] __irqentry_text_start+0x74/0x87
[   65.164028]                                          [<c0104061>] apic_timer_interrupt+0x2d/0x34
[   65.164028]                                          [<c012d4a0>] printk+0x1a/0x1c
[   65.164028]                                          [<c0101132>] do_one_initcall+0x4a/0x17f
[   65.164028]                                          [<c0a6e4ee>] kernel_init+0xfc/0x14a
[   65.164028]                                          [<c010417b>] kernel_thread_helper+0x7/0x10
[   65.164028]                                          [<ffffffff>] 0xffffffff
[   65.164028]     in-softirq-W at:
[   65.164028]                                          [<c014d9a4>] __lock_acquire+0x51a/0x746
[   65.164028]                                          [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                          [<c06c8f2e>] _spin_lock_irqsave+0x3f/0x72
[   65.164028]                                          [<c03a5a95>] debug_object_deactivate+0x29/0x8f
[   65.164028]                                          [<c0134d00>] run_timer_softirq+0x116/0x1a4
[   65.164028]                                          [<c01314ec>] __do_softirq+0x9d/0x154
[   65.164028]                                          [<ffffffff>] 0xffffffff
[   65.164028]   }
[   65.164028]   ... key      at: [<c127aabc>] __key.19955+0x0/0x8
[   65.164028]   ... acquired at:
[   65.164028]    [<c014d1b5>] validate_chain+0x8f9/0xbce
[   65.164028]    [<c014db6a>] __lock_acquire+0x6e0/0x746
[   65.164028]    [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]    [<c06c8ab8>] _spin_lock+0x23/0x53
[   65.164028]    [<c03a5da9>] __debug_object_init+0xb5/0x29e
[   65.164028]    [<c03a5fbd>] debug_object_init+0x13/0x16
[   65.164028]    [<c0140344>] hrtimer_init+0x1b/0x2b
[   65.164028]    [<c0a7b1da>] sched_init+0x99/0x333
[   65.164028]    [<c0a6e6a9>] start_kernel+0x13e/0x30a
[   65.164028]    [<c0a6e056>] i386_start_kernel+0x56/0x5e
[   65.164028]    [<ffffffff>] 0xffffffff
[   65.164028] 
[   65.164028]  ... acquired at:
[   65.164028]    [<c014d1b5>] validate_chain+0x8f9/0xbce
[   65.164028]    [<c014db6a>] __lock_acquire+0x6e0/0x746
[   65.164028]    [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]    [<c06c8f2e>] _spin_lock_irqsave+0x3f/0x72
[   65.164028]    [<c03a5d89>] __debug_object_init+0x95/0x29e
[   65.164028]    [<c03a5fbd>] debug_object_init+0x13/0x16
[   65.164028]    [<c0134b4d>] init_timer+0x15/0x1f
[   65.164028]    [<c05faa8f>] inet_csk_init_xmit_timers+0x25/0x6a
[   65.164028]    [<c0608305>] tcp_init_xmit_timers+0x1c/0x1f
[   65.164028]    [<c060c40d>] tcp_create_openreq_child+0x190/0x3c4
[   65.164028]    [<c060a5f4>] tcp_v4_syn_recv_sock+0x53/0x1c0
[   65.164028]    [<c060c0f0>] tcp_check_req+0x1e0/0x36d
[   65.164028]    [<c0609ee8>] tcp_v4_do_rcv+0x1b2/0x2a5
[   65.164028]    [<c060be0b>] tcp_v4_rcv+0x67d/0x6d2
[   65.164028]    [<c05f2c95>] ip_local_deliver_finish+0x112/0x1c5
[   65.164028]    [<c05f309a>] ip_local_deliver+0x59/0x63
[   65.164028]    [<c05f2b6d>] ip_rcv_finish+0x285/0x29b
[   65.164028]    [<c05f3017>] ip_rcv+0x1f1/0x21b
[   65.164028]    [<c05cc853>] netif_receive_skb+0x2f2/0x325
[   65.164028]    [<c04b597f>] nv_napi_poll+0x3b9/0x4d2
[   65.164028]    [<c05cefec>] net_rx_action+0xd6/0x1f7
[   65.164028]    [<c01314ec>] __do_softirq+0x9d/0x154
[   65.164028]    [<ffffffff>] 0xffffffff
[   65.164028] 
[   65.164028]  -> (&hashinfo->ehash_locks[i]){-+..} ops: 0 {
[   65.164028]     initial-use  at:
[   65.164028]                                          [<c014da2e>] __lock_acquire+0x5a4/0x746
[   65.164028]                                          [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                          [<c06c8ab8>] _spin_lock+0x23/0x53
[   65.164028]                                          [<c05f89c7>] __inet_hash_nolisten+0xea/0x11f
[   65.164028]                                          [<c05f8d9a>] __inet_hash_connect+0x17a/0x213
[   65.164028]                                          [<c05f8e6e>] inet_hash_connect+0x3b/0x42
[   65.164028]                                          [<c060b222>] tcp_v4_connect+0x33f/0x49e
[   65.164028]                                          [<c06160cf>] inet_stream_connect+0x8f/0x204
[   65.164028]                                          [<c05c276e>] sys_connect+0x59/0x76
[   65.164028]                                          [<c05c2db2>] sys_socketcall+0x91/0x18a
[   65.164028]                                          [<c010388b>] sysenter_do_call+0x12/0x3f
[   65.164028]                                          [<ffffffff>] 0xffffffff
[   65.164028]     in-softirq-W at:
[   65.164028]                                          [<c014d9a4>] __lock_acquire+0x51a/0x746
[   65.164028]                                          [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                          [<c06c8ab8>] _spin_lock+0x23/0x53
[   65.164028]                                          [<c05f9d0d>] __inet_twsk_hashdance+0xa0/0x103
[   65.164028]                                          [<c060c772>] tcp_time_wait+0x131/0x1a7
[   65.164028]                                          [<c0600b00>] tcp_fin+0x80/0x16a
[   65.164028]                                          [<c060159d>] tcp_data_queue+0x293/0xa6d
[   65.164028]                                          [<c0604869>] tcp_rcv_state_process+0x852/0x8b7
[   65.164028]                                          [<c0609f92>] tcp_v4_do_rcv+0x25c/0x2a5
[   65.164028]                                          [<c060be0b>] tcp_v4_rcv+0x67d/0x6d2
[   65.164028]                                          [<c05f2c95>] ip_local_deliver_finish+0x112/0x1c5
[   65.164028]                                          [<c05f309a>] ip_local_deliver+0x59/0x63
[   65.164028]                                          [<c05f2b6d>] ip_rcv_finish+0x285/0x29b
[   65.164028]                                          [<c05f3017>] ip_rcv+0x1f1/0x21b
[   65.164028]                                          [<c05cc853>] netif_receive_skb+0x2f2/0x325
[   65.164028]                                          [<c04b597f>] nv_napi_poll+0x3b9/0x4d2
[   65.164028]                                          [<c05cefec>] net_rx_action+0xd6/0x1f7
[   65.164028]                                          [<c01314ec>] __do_softirq+0x9d/0x154
[   65.164028]                                          [<ffffffff>] 0xffffffff
[   65.164028]     hardirq-on-W at:
[   65.164028]                                          [<c014d9f8>] __lock_acquire+0x56e/0x746
[   65.164028]                                          [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                          [<c06c8ab8>] _spin_lock+0x23/0x53
[   65.164028]                                          [<c05f89c7>] __inet_hash_nolisten+0xea/0x11f
[   65.164028]                                          [<c05f8d9a>] __inet_hash_connect+0x17a/0x213
[   65.164028]                                          [<c05f8e6e>] inet_hash_connect+0x3b/0x42
[   65.164028]                                          [<c060b222>] tcp_v4_connect+0x33f/0x49e
[   65.164028]                                          [<c06160cf>] inet_stream_connect+0x8f/0x204
[   65.164028]                                          [<c05c276e>] sys_connect+0x59/0x76
[   65.164028]                                          [<c05c2db2>] sys_socketcall+0x91/0x18a
[   65.164028]                                          [<c010388b>] sysenter_do_call+0x12/0x3f
[   65.164028]                                          [<ffffffff>] 0xffffffff
[   65.164028]   }
[   65.164028]   ... key      at: [<c132b8a8>] __key.38748+0x0/0x8
[   65.164028]  ... acquired at:
[   65.164028]    [<c014d1b5>] validate_chain+0x8f9/0xbce
[   65.164028]    [<c014db6a>] __lock_acquire+0x6e0/0x746
[   65.164028]    [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]    [<c06c8ab8>] _spin_lock+0x23/0x53
[   65.164028]    [<c05f89c7>] __inet_hash_nolisten+0xea/0x11f
[   65.164028]    [<c060a71a>] tcp_v4_syn_recv_sock+0x179/0x1c0
[   65.164028]    [<c060c0f0>] tcp_check_req+0x1e0/0x36d
[   65.164028]    [<c0609ee8>] tcp_v4_do_rcv+0x1b2/0x2a5
[   65.164028]    [<c060be0b>] tcp_v4_rcv+0x67d/0x6d2
[   65.164028]    [<c05f2c95>] ip_local_deliver_finish+0x112/0x1c5
[   65.164028]    [<c05f309a>] ip_local_deliver+0x59/0x63
[   65.164028]    [<c05f2b6d>] ip_rcv_finish+0x285/0x29b
[   65.164028]    [<c05f3017>] ip_rcv+0x1f1/0x21b
[   65.164028]    [<c05cc853>] netif_receive_skb+0x2f2/0x325
[   65.164028]    [<c04b597f>] nv_napi_poll+0x3b9/0x4d2
[   65.164028]    [<c05cefec>] net_rx_action+0xd6/0x1f7
[   65.164028]    [<c01314ec>] __do_softirq+0x9d/0x154
[   65.164028]    [<ffffffff>] 0xffffffff
[   65.164028] 
[   65.164028]  -> (&tcp_hashinfo.bhash[i].lock){-+..} ops: 0 {
[   65.164028]     initial-use  at:
[   65.164028]                                          [<c014da2e>] __lock_acquire+0x5a4/0x746
[   65.164028]                                          [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                          [<c06c8ab8>] _spin_lock+0x23/0x53
[   65.164028]                                          [<c05fa7de>] inet_csk_get_port+0xc4/0x1d2
[   65.164028]                                          [<c0615f9e>] inet_bind+0x102/0x1a4
[   65.164028]                                          [<c05c27de>] sys_bind+0x53/0x72
[   65.164028]                                          [<c05c2da0>] sys_socketcall+0x7f/0x18a
[   65.164028]                                          [<c010388b>] sysenter_do_call+0x12/0x3f
[   65.164028]                                          [<ffffffff>] 0xffffffff
[   65.164028]     in-softirq-W at:
[   65.164028]                                          [<c014d9a4>] __lock_acquire+0x51a/0x746
[   65.164028]                                          [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                          [<c06c8ab8>] _spin_lock+0x23/0x53
[   65.164028]                                          [<c05f9cbc>] __inet_twsk_hashdance+0x4f/0x103
[   65.164028]                                          [<c060c772>] tcp_time_wait+0x131/0x1a7
[   65.164028]                                          [<c0600b00>] tcp_fin+0x80/0x16a
[   65.164028]                                          [<c060159d>] tcp_data_queue+0x293/0xa6d
[   65.164028]                                          [<c0604869>] tcp_rcv_state_process+0x852/0x8b7
[   65.164028]                                          [<c0609f92>] tcp_v4_do_rcv+0x25c/0x2a5
[   65.164028]                                          [<c060be0b>] tcp_v4_rcv+0x67d/0x6d2
[   65.164028]                                          [<c05f2c95>] ip_local_deliver_finish+0x112/0x1c5
[   65.164028]                                          [<c05f309a>] ip_local_deliver+0x59/0x63
[   65.164028]                                          [<c05f2b6d>] ip_rcv_finish+0x285/0x29b
[   65.164028]                                          [<c05f3017>] ip_rcv+0x1f1/0x21b
[   65.164028]                                          [<c05cc853>] netif_receive_skb+0x2f2/0x325
[   65.164028]                                          [<c04b597f>] nv_napi_poll+0x3b9/0x4d2
[   65.164028]                                          [<c05cefec>] net_rx_action+0xd6/0x1f7
[   65.164028]                                          [<c01314ec>] __do_softirq+0x9d/0x154
[   65.164028]                                          [<ffffffff>] 0xffffffff
[   65.164028]     hardirq-on-W at:
[   65.164028]                                          [<c014d9f8>] __lock_acquire+0x56e/0x746
[   65.164028]                                          [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                          [<c06c8ab8>] _spin_lock+0x23/0x53
[   65.164028]                                          [<c05fa7de>] inet_csk_get_port+0xc4/0x1d2
[   65.164028]                                          [<c0615f9e>] inet_bind+0x102/0x1a4
[   65.164028]                                          [<c05c27de>] sys_bind+0x53/0x72
[   65.164028]                                          [<c05c2da0>] sys_socketcall+0x7f/0x18a
[   65.164028]                                          [<c010388b>] sysenter_do_call+0x12/0x3f
[   65.164028]                                          [<ffffffff>] 0xffffffff
[   65.164028]   }
[   65.164028]   ... key      at: [<c132b8a0>] __key.45901+0x0/0x8
[   65.164028]   ... acquired at:
[   65.164028]    [<c014d1b5>] validate_chain+0x8f9/0xbce
[   65.164028]    [<c014db6a>] __lock_acquire+0x6e0/0x746
[   65.164028]    [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]    [<c06c8ab8>] _spin_lock+0x23/0x53
[   65.164028]    [<c05f89c7>] __inet_hash_nolisten+0xea/0x11f
[   65.164028]    [<c05f8d9a>] __inet_hash_connect+0x17a/0x213
[   65.164028]    [<c05f8e6e>] inet_hash_connect+0x3b/0x42
[   65.164028]    [<c060b222>] tcp_v4_connect+0x33f/0x49e
[   65.164028]    [<c06160cf>] inet_stream_connect+0x8f/0x204
[   65.164028]    [<c05c276e>] sys_connect+0x59/0x76
[   65.164028]    [<c05c2db2>] sys_socketcall+0x91/0x18a
[   65.164028]    [<c010388b>] sysenter_do_call+0x12/0x3f
[   65.164028]    [<ffffffff>] 0xffffffff
[   65.164028] 
[   65.164028]   -> (&n->list_lock){.+..} ops: 0 {
[   65.164028]      initial-use  at:
[   65.164028]                                            [<c014da2e>] __lock_acquire+0x5a4/0x746
[   65.164028]                                            [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                            [<c06c8ab8>] _spin_lock+0x23/0x53
[   65.164028]                                            [<c0193510>] deactivate_slab+0x71/0xd6
[   65.164028]                                            [<c0193ac0>] __slab_alloc+0x91/0x441
[   65.164028]                                            [<c0194f21>] __kmalloc+0x99/0x10c
[   65.164028]                                            [<c0195a3d>] kmem_cache_create+0x1bd/0x1d4
[   65.164028]                                            [<c0a8033e>] vfs_caches_init+0x63/0x107
[   65.164028]                                            [<c0a6e837>] start_kernel+0x2cc/0x30a
[   65.164028]                                            [<c0a6e056>] i386_start_kernel+0x56/0x5e
[   65.164028]                                            [<ffffffff>] 0xffffffff
[   65.164028]      in-softirq-W at:
[   65.164028]                                            [<c014d9a4>] __lock_acquire+0x51a/0x746
[   65.164028]                                            [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                            [<c06c8ab8>] _spin_lock+0x23/0x53
[   65.164028]                                            [<c019373f>] __slab_free+0x1b5/0x243
[   65.164028]                                            [<c0194002>] kfree+0xc1/0xf7
[   65.164028]                                            [<c016e092>] rcu_free_old_probes+0xd/0xf
[   65.164028]                                            [<c0169ea3>] __rcu_process_callbacks+0x162/0x1f7
[   65.164028]                                            [<c0169f5e>] rcu_process_callbacks+0x26/0x46
[   65.164028]                                            [<c01314ec>] __do_softirq+0x9d/0x154
[   65.164028]                                            [<ffffffff>] 0xffffffff
[   65.164028]    }
[   65.164028]    ... key      at: [<c12296a4>] __key.25975+0x0/0x8
[   65.164028]   ... acquired at:
[   65.164028]    [<c014d1b5>] validate_chain+0x8f9/0xbce
[   65.164028]    [<c014db6a>] __lock_acquire+0x6e0/0x746
[   65.164028]    [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]    [<c06c8ab8>] _spin_lock+0x23/0x53
[   65.164028]    [<c0193ad7>] __slab_alloc+0xa8/0x441
[   65.164028]    [<c0193ed3>] kmem_cache_alloc+0x63/0xd1
[   65.164028]    [<c05f8be8>] inet_bind_bucket_create+0x19/0x51
[   65.164028]    [<c05f8d21>] __inet_hash_connect+0x101/0x213
[   65.164028]    [<c05f8e6e>] inet_hash_connect+0x3b/0x42
[   65.164028]    [<c060b222>] tcp_v4_connect+0x33f/0x49e
[   65.164028]    [<c06160cf>] inet_stream_connect+0x8f/0x204
[   65.164028]    [<c05c276e>] sys_connect+0x59/0x76
[   65.164028]    [<c05c2db2>] sys_socketcall+0x91/0x18a
[   65.164028]    [<c010388b>] sysenter_do_call+0x12/0x3f
[   65.164028]    [<ffffffff>] 0xffffffff
[   65.164028] 
[   65.164028]  ... acquired at:
[   65.164028]    [<c014d1b5>] validate_chain+0x8f9/0xbce
[   65.164028]    [<c014db6a>] __lock_acquire+0x6e0/0x746
[   65.164028]    [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]    [<c06c8ab8>] _spin_lock+0x23/0x53
[   65.164028]    [<c05f8ea7>] __inet_inherit_port+0x32/0x66
[   65.164028]    [<c060a724>] tcp_v4_syn_recv_sock+0x183/0x1c0
[   65.164028]    [<c060c0f0>] tcp_check_req+0x1e0/0x36d
[   65.164028]    [<c0609ee8>] tcp_v4_do_rcv+0x1b2/0x2a5
[   65.164028]    [<c060be0b>] tcp_v4_rcv+0x67d/0x6d2
[   65.164028]    [<c05f2c95>] ip_local_deliver_finish+0x112/0x1c5
[   65.164028]    [<c05f309a>] ip_local_deliver+0x59/0x63
[   65.164028]    [<c05f2b6d>] ip_rcv_finish+0x285/0x29b
[   65.164028]    [<c05f3017>] ip_rcv+0x1f1/0x21b
[   65.164028]    [<c05cc853>] netif_receive_skb+0x2f2/0x325
[   65.164028]    [<c04b597f>] nv_napi_poll+0x3b9/0x4d2
[   65.164028]    [<c05cefec>] net_rx_action+0xd6/0x1f7
[   65.164028]    [<c01314ec>] __do_softirq+0x9d/0x154
[   65.164028]    [<ffffffff>] 0xffffffff
[   65.164028] 
[   65.164028]  -> (&queue->syn_wait_lock){-+..} ops: 0 {
[   65.164028]     initial-use  at:
[   65.164028]                                          [<c014da2e>] __lock_acquire+0x5a4/0x746
[   65.164028]                                          [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                          [<c06c8bf6>] _write_lock_bh+0x28/0x58
[   65.164028]                                          [<c05c579b>] reqsk_queue_alloc+0xba/0xcf
[   65.164028]                                          [<c05fa676>] inet_csk_listen_start+0x1e/0xc2
[   65.164028]                                          [<c0615e78>] inet_listen+0x43/0x67
[   65.164028]                                          [<c05c1a51>] sys_listen+0x3f/0x59
[   65.164028]                                          [<c05c2dbb>] sys_socketcall+0x9a/0x18a
[   65.164028]                                          [<c010388b>] sysenter_do_call+0x12/0x3f
[   65.164028]                                          [<ffffffff>] 0xffffffff
[   65.164028]     in-softirq-W at:
[   65.164028]                                          [<c014d9a4>] __lock_acquire+0x51a/0x746
[   65.164028]                                          [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                          [<c06c8b9e>] _write_lock+0x23/0x53
[   65.164028]                                          [<c05fa403>] inet_csk_reqsk_queue_hash_add+0xca/0x101
[   65.164028]                                          [<c060ab5f>] tcp_v4_conn_request+0x3fe/0x435
[   65.164028]                                          [<c0604079>] tcp_rcv_state_process+0x62/0x8b7
[   65.164028]                                          [<c0609f92>] tcp_v4_do_rcv+0x25c/0x2a5
[   65.164028]                                          [<c060be0b>] tcp_v4_rcv+0x67d/0x6d2
[   65.164028]                                          [<c05f2c95>] ip_local_deliver_finish+0x112/0x1c5
[   65.164028]                                          [<c05f309a>] ip_local_deliver+0x59/0x63
[   65.164028]                                          [<c05f2b6d>] ip_rcv_finish+0x285/0x29b
[   65.164028]                                          [<c05f3017>] ip_rcv+0x1f1/0x21b
[   65.164028]                                          [<c05cc853>] netif_receive_skb+0x2f2/0x325
[   65.164028]                                          [<c04b597f>] nv_napi_poll+0x3b9/0x4d2
[   65.164028]                                          [<c05cefec>] net_rx_action+0xd6/0x1f7
[   65.164028]                                          [<c01314ec>] __do_softirq+0x9d/0x154
[   65.164028]                                          [<ffffffff>] 0xffffffff
[   65.164028]     hardirq-on-W at:
[   65.164028]                                          [<c014d9f8>] __lock_acquire+0x56e/0x746
[   65.164028]                                          [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                          [<c06c8bf6>] _write_lock_bh+0x28/0x58
[   65.164028]                                          [<c05c579b>] reqsk_queue_alloc+0xba/0xcf
[   65.164028]                                          [<c05fa676>] inet_csk_listen_start+0x1e/0xc2
[   65.164028]                                          [<c0615e78>] inet_listen+0x43/0x67
[   65.164028]                                          [<c05c1a51>] sys_listen+0x3f/0x59
[   65.164028]                                          [<c05c2dbb>] sys_socketcall+0x9a/0x18a
[   65.164028]                                          [<c010388b>] sysenter_do_call+0x12/0x3f
[   65.164028]                                          [<ffffffff>] 0xffffffff
[   65.164028]   }
[   65.164028]   ... key      at: [<c132a3bc>] __key.34733+0x0/0x8
[   65.164028]  ... acquired at:
[   65.164028]    [<c014d1b5>] validate_chain+0x8f9/0xbce
[   65.164028]    [<c014db6a>] __lock_acquire+0x6e0/0x746
[   65.164028]    [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]    [<c06c8b9e>] _write_lock+0x23/0x53
[   65.164028]    [<c060c15f>] tcp_check_req+0x24f/0x36d
[   65.164028]    [<c0609ee8>] tcp_v4_do_rcv+0x1b2/0x2a5
[   65.164028]    [<c060be0b>] tcp_v4_rcv+0x67d/0x6d2
[   65.164028]    [<c05f2c95>] ip_local_deliver_finish+0x112/0x1c5
[   65.164028]    [<c05f309a>] ip_local_deliver+0x59/0x63
[   65.164028]    [<c05f2b6d>] ip_rcv_finish+0x285/0x29b
[   65.164028]    [<c05f3017>] ip_rcv+0x1f1/0x21b
[   65.164028]    [<c05cc853>] netif_receive_skb+0x2f2/0x325
[   65.164028]    [<c04b597f>] nv_napi_poll+0x3b9/0x4d2
[   65.164028]    [<c05cefec>] net_rx_action+0xd6/0x1f7
[   65.164028]    [<c01314ec>] __do_softirq+0x9d/0x154
[   65.164028]    [<ffffffff>] 0xffffffff
[   65.164028] 
[   65.164028]  -> (&base->lock){++..} ops: 0 {
[   65.164028]     initial-use  at:
[   65.164028]                                          [<c014da2e>] __lock_acquire+0x5a4/0x746
[   65.164028]                                          [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                          [<c06c8f2e>] _spin_lock_irqsave+0x3f/0x72
[   65.164028]                                          [<c01351eb>] lock_timer_base+0x24/0x43
[   65.164028]                                          [<c0135312>] __mod_timer+0x2f/0xc8
[   65.164028]                                          [<c0135585>] mod_timer+0x38/0x3c
[   65.164028]                                          [<c0a88246>] con_init+0xa1/0x215
[   65.164028]                                          [<c0a87aff>] console_init+0x12/0x20
[   65.164028]                                          [<c0a6e795>] start_kernel+0x22a/0x30a
[   65.164028]                                          [<c0a6e056>] i386_start_kernel+0x56/0x5e
[   65.164028]                                          [<ffffffff>] 0xffffffff
[   65.164028]     in-hardirq-W at:
[   65.164028]                                          [<c014d983>] __lock_acquire+0x4f9/0x746
[   65.164028]                                          [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                          [<c06c8f2e>] _spin_lock_irqsave+0x3f/0x72
[   65.164028]                                          [<c01351eb>] lock_timer_base+0x24/0x43
[   65.164028]                                          [<c0135312>] __mod_timer+0x2f/0xc8
[   65.164028]                                          [<c0135585>] mod_timer+0x38/0x3c
[   65.164028]                                          [<c05dbeb0>] __netdev_watchdog_up+0x47/0x55
[   65.164028]                                          [<c05dc228>] netif_carrier_on+0x34/0x37
[   65.164028]                                          [<c04b0fed>] nv_linkchange+0x21/0x5b
[   65.164028]                                          [<c04b1057>] nv_link_irq+0x30/0x33
[   65.164028]                                          [<c04b2201>] nv_nic_irq_optimized+0xfe/0x22d
[   65.164028]                                          [<c0166953>] handle_IRQ_event+0x1f/0x54
[   65.164028]                                          [<c0167f4b>] handle_fasteoi_irq+0xaa/0xb7
[   65.164028]                                          [<ffffffff>] 0xffffffff
[   65.164028]     in-softirq-W at:
[   65.164028]                                          [<c014d9a4>] __lock_acquire+0x51a/0x746
[   65.164028]                                          [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                          [<c06c8df5>] _spin_lock_irq+0x32/0x62
[   65.164028]                                          [<c0134c21>] run_timer_softirq+0x37/0x1a4
[   65.164028]                                          [<c01314ec>] __do_softirq+0x9d/0x154
[   65.164028]                                          [<ffffffff>] 0xffffffff
[   65.164028]   }
[   65.164028]   ... key      at: [<c0e2fbac>] __key.23710+0x0/0x8
[   65.164028]   ... acquired at:
[   65.164028]    [<c014d1b5>] validate_chain+0x8f9/0xbce
[   65.164028]    [<c014db6a>] __lock_acquire+0x6e0/0x746
[   65.164028]    [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]    [<c06c8f2e>] _spin_lock_irqsave+0x3f/0x72
[   65.164028]    [<c03a5b27>] debug_object_activate+0x2c/0xbd
[   65.164028]    [<c0135350>] __mod_timer+0x6d/0xc8
[   65.164028]    [<c0135585>] mod_timer+0x38/0x3c
[   65.164028]    [<c0a88246>] con_init+0xa1/0x215
[   65.164028]    [<c0a87aff>] console_init+0x12/0x20
[   65.164028]    [<c0a6e795>] start_kernel+0x22a/0x30a
[   65.164028]    [<c0a6e056>] i386_start_kernel+0x56/0x5e
[   65.164028]    [<ffffffff>] 0xffffffff
[   65.164028] 
[   65.164028]   ... acquired at:
[   65.164028]    [<c014d1b5>] validate_chain+0x8f9/0xbce
[   65.164028]    [<c014db6a>] __lock_acquire+0x6e0/0x746
[   65.164028]    [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]    [<c06c8f2e>] _spin_lock_irqsave+0x3f/0x72
[   65.164028]    [<c03a5d3b>] __debug_object_init+0x47/0x29e
[   65.164028]    [<c03a5fbd>] debug_object_init+0x13/0x16
[   65.164028]    [<c0134b9b>] timer_fixup_activate+0x2d/0x7c
[   65.164028]    [<c03a5805>] debug_object_fixup+0x17/0x22
[   65.164028]    [<c03a5bb1>] debug_object_activate+0xb6/0xbd
[   65.164028]    [<c0135350>] __mod_timer+0x6d/0xc8
[   65.164028]    [<c04408f4>] __reschedule_timeout+0x6f/0xaf
[   65.164028]    [<c0440961>] reschedule_timeout+0x2d/0x3f
[   65.164028]    [<c0a8998a>] floppy_init+0x172/0xdb3
[   65.164028]    [<c0101152>] do_one_initcall+0x6a/0x17f
[   65.164028]    [<c0a6e4ee>] kernel_init+0xfc/0x14a
[   65.164028]    [<c010417b>] kernel_thread_helper+0x7/0x10
[   65.164028]    [<ffffffff>] 0xffffffff
[   65.164028] 
[   65.164028]   -> (&base->lock/1){....} ops: 0 {
[   65.164028]      initial-use  at:
[   65.164028]                                            [<c014da2e>] __lock_acquire+0x5a4/0x746
[   65.164028]                                            [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                            [<c06c8a65>] _spin_lock_nested+0x21/0x51
[   65.164028]                                            [<c06c462e>] timer_cpu_notify+0x1a2/0x22b
[   65.164028]                                            [<c0141b6b>] notifier_call_chain+0x49/0x71
[   65.164028]                                            [<c0141c09>] __raw_notifier_call_chain+0x13/0x15
[   65.164028]                                            [<c0141c1c>] raw_notifier_call_chain+0x11/0x13
[   65.164028]                                            [<c069a366>] _cpu_down+0x168/0x221
[   65.164028]                                            [<c069a454>] cpu_down+0x35/0x57
[   65.164028]                                            [<c069b594>] store_online+0x2a/0x5e
[   65.164028]                                            [<c04397a5>] sysdev_store+0x20/0x28
[   65.164028]                                            [<c01d2f30>] sysfs_write_file+0xbd/0xe8
[   65.164028]                                            [<c019958a>] vfs_write+0x91/0x138
[   65.164028]                                            [<c0199a95>] sys_write+0x40/0x65
[   65.164028]                                            [<c010388b>] sysenter_do_call+0x12/0x3f
[   65.164028]                                            [<ffffffff>] 0xffffffff
[   65.164028]    }
[   65.164028]    ... key      at: [<c0e2fbad>] __key.23710+0x1/0x8
[   65.164028]    ... acquired at:
[   65.164028]    [<c014d1b5>] validate_chain+0x8f9/0xbce
[   65.164028]    [<c014db6a>] __lock_acquire+0x6e0/0x746
[   65.164028]    [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]    [<c06c8f2e>] _spin_lock_irqsave+0x3f/0x72
[   65.164028]    [<c03a5a95>] debug_object_deactivate+0x29/0x8f
[   65.164028]    [<c0134af4>] migrate_timer_list+0x1d/0x4d
[   65.164028]    [<c06c4644>] timer_cpu_notify+0x1b8/0x22b
[   65.164028]    [<c0141b6b>] notifier_call_chain+0x49/0x71
[   65.164028]    [<c0141c09>] __raw_notifier_call_chain+0x13/0x15
[   65.164028]    [<c0141c1c>] raw_notifier_call_chain+0x11/0x13
[   65.164028]    [<c069a366>] _cpu_down+0x168/0x221
[   65.164028]    [<c069a454>] cpu_down+0x35/0x57
[   65.164028]    [<c069b594>] store_online+0x2a/0x5e
[   65.164028]    [<c04397a5>] sysdev_store+0x20/0x28
[   65.164028]    [<c01d2f30>] sysfs_write_file+0xbd/0xe8
[   65.164028]    [<c019958a>] vfs_write+0x91/0x138
[   65.164028]    [<c0199a95>] sys_write+0x40/0x65
[   65.164028]    [<c010388b>] sysenter_do_call+0x12/0x3f
[   65.164028]    [<ffffffff>] 0xffffffff
[   65.164028] 
[   65.164028]   ... acquired at:
[   65.164028]    [<c014d1b5>] validate_chain+0x8f9/0xbce
[   65.164028]    [<c014db6a>] __lock_acquire+0x6e0/0x746
[   65.164028]    [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]    [<c06c8a65>] _spin_lock_nested+0x21/0x51
[   65.164028]    [<c06c462e>] timer_cpu_notify+0x1a2/0x22b
[   65.164028]    [<c0141b6b>] notifier_call_chain+0x49/0x71
[   65.164028]    [<c0141c09>] __raw_notifier_call_chain+0x13/0x15
[   65.164028]    [<c0141c1c>] raw_notifier_call_chain+0x11/0x13
[   65.164028]    [<c069a366>] _cpu_down+0x168/0x221
[   65.164028]    [<c069a454>] cpu_down+0x35/0x57
[   65.164028]    [<c069b594>] store_online+0x2a/0x5e
[   65.164028]    [<c04397a5>] sysdev_store+0x20/0x28
[   65.164028]    [<c01d2f30>] sysfs_write_file+0xbd/0xe8
[   65.164028]    [<c019958a>] vfs_write+0x91/0x138
[   65.164028]    [<c0199a95>] sys_write+0x40/0x65
[   65.164028]    [<c010388b>] sysenter_do_call+0x12/0x3f
[   65.164028]    [<ffffffff>] 0xffffffff
[   65.164028] 
[   65.164028]  ... acquired at:
[   65.164028]    [<c014d1b5>] validate_chain+0x8f9/0xbce
[   65.164028]    [<c014db6a>] __lock_acquire+0x6e0/0x746
[   65.164028]    [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]    [<c06c8f2e>] _spin_lock_irqsave+0x3f/0x72
[   65.164028]    [<c01351eb>] lock_timer_base+0x24/0x43
[   65.164028]    [<c01355af>] del_timer+0x26/0x66
[   65.164028]    [<c05c39c4>] sk_stop_timer+0x17/0x22
[   65.164028]    [<c05f9efb>] inet_csk_delete_keepalive_timer+0x13/0x15
[   65.164028]    [<c060c192>] tcp_check_req+0x282/0x36d
[   65.164028]    [<c0609ee8>] tcp_v4_do_rcv+0x1b2/0x2a5
[   65.164028]    [<c060be0b>] tcp_v4_rcv+0x67d/0x6d2
[   65.164028]    [<c05f2c95>] ip_local_deliver_finish+0x112/0x1c5
[   65.164028]    [<c05f309a>] ip_local_deliver+0x59/0x63
[   65.164028]    [<c05f2b6d>] ip_rcv_finish+0x285/0x29b
[   65.164028]    [<c05f3017>] ip_rcv+0x1f1/0x21b
[   65.164028]    [<c05cc853>] netif_receive_skb+0x2f2/0x325
[   65.164028]    [<c04b597f>] nv_napi_poll+0x3b9/0x4d2
[   65.164028]    [<c05cefec>] net_rx_action+0xd6/0x1f7
[   65.164028]    [<c01314ec>] __do_softirq+0x9d/0x154
[   65.164028]    [<ffffffff>] 0xffffffff
[   65.164028] 
[   65.164028]  -> (&q->lock){++..} ops: 0 {
[   65.164028]     initial-use  at:
[   65.164028]                                          [<c014da2e>] __lock_acquire+0x5a4/0x746
[   65.164028]                                          [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                          [<c06c8df5>] _spin_lock_irq+0x32/0x62
[   65.164028]                                          [<c06c5c49>] wait_for_common+0x2f/0x110
[   65.164028]                                          [<c06c5dc5>] wait_for_completion+0x17/0x19
[   65.164028]                                          [<c013df64>] kthread_create+0x75/0xa0
[   65.164028]                                          [<c06c3afb>] migration_call+0x39/0x4d6
[   65.164028]                                          [<c0a7aeca>] migration_init+0x1d/0x4b
[   65.164028]                                          [<c0101152>] do_one_initcall+0x6a/0x17f
[   65.164028]                                          [<c0a6e445>] kernel_init+0x53/0x14a
[   65.164028]                                          [<c010417b>] kernel_thread_helper+0x7/0x10
[   65.164028]                                          [<ffffffff>] 0xffffffff
[   65.164028]     in-hardirq-W at:
[   65.164028]                                          [<c014d983>] __lock_acquire+0x4f9/0x746
[   65.164028]                                          [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                          [<c06c8f2e>] _spin_lock_irqsave+0x3f/0x72
[   65.164028]                                          [<c011fd42>] __wake_up+0x1a/0x40
[   65.164028]                                          [<c013aea2>] insert_work+0x48/0x50
[   65.164028]                                          [<c013b5df>] __queue_work+0x22/0x30
[   65.164028]                                          [<c013b650>] queue_work_on+0x3a/0x46
[   65.164028]                                          [<c013b710>] queue_work+0x1a/0x1d
[   65.164028]                                          [<c013b727>] schedule_work+0x14/0x16
[   65.164028]                                          [<c044142d>] schedule_bh+0x17/0x19
[   65.164028]                                          [<c04415a7>] floppy_interrupt+0x15a/0x171
[   65.164028]                                          [<c044385a>] floppy_hardint+0x22/0xe1
[   65.164028]                                          [<c0166953>] handle_IRQ_event+0x1f/0x54
[   65.164028]                                          [<c0167ffe>] handle_edge_irq+0xa6/0x10d
[   65.164028]                                          [<ffffffff>] 0xffffffff
[   65.164028]     in-softirq-W at:
[   65.164028]                                          [<c014d9a4>] __lock_acquire+0x51a/0x746
[   65.164028]                                          [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                          [<c06c8f2e>] _spin_lock_irqsave+0x3f/0x72
[   65.164028]                                          [<c011fcb3>] complete+0x17/0x43
[   65.164028]                                          [<c013c1ee>] wakeme_after_rcu+0x10/0x12
[   65.164028]                                          [<c0169ea3>] __rcu_process_callbacks+0x162/0x1f7
[   65.164028]                                          [<c0169f5e>] rcu_process_callbacks+0x26/0x46
[   65.164028]                                          [<c01314ec>] __do_softirq+0x9d/0x154
[   65.164028]                                          [<ffffffff>] 0xffffffff
[   65.164028]   }
[   65.164028]   ... key      at: [<c0e2ff64>] __key.18770+0x0/0x8
[   65.164028]   -> (&rq->lock){++..} ops: 0 {
[   65.164028]      initial-use  at:
[   65.164028]                                            [<c014da2e>] __lock_acquire+0x5a4/0x746
[   65.164028]                                            [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                            [<c06c8f2e>] _spin_lock_irqsave+0x3f/0x72
[   65.164028]                                            [<c0123e2a>] rq_attach_root+0x19/0x191
[   65.164028]                                            [<c0a7b355>] sched_init+0x214/0x333
[   65.164028]                                            [<c0a6e6a9>] start_kernel+0x13e/0x30a
[   65.164028]                                            [<c0a6e056>] i386_start_kernel+0x56/0x5e
[   65.164028]                                            [<ffffffff>] 0xffffffff
[   65.164028]      in-hardirq-W at:
[   65.164028]                                            [<c014d983>] __lock_acquire+0x4f9/0x746
[   65.164028]                                            [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                            [<c06c8ab8>] _spin_lock+0x23/0x53
[   65.164028]                                            [<c012a118>] scheduler_tick+0x3a/0x211
[   65.164028]                                            [<c0135463>] update_process_times+0x47/0x53
[   65.164028]                                            [<c0147766>] tick_periodic+0x6b/0x6d
[   65.164028]                                            [<c0147786>] tick_handle_periodic+0x1e/0x60
[   65.164028]                                            [<c0105c7a>] timer_interrupt+0x46/0x4d
[   65.164028]                                            [<c0166953>] handle_IRQ_event+0x1f/0x54
[   65.164028]                                            [<c0168123>] handle_level_irq+0xbe/0xcb
[   65.164028]                                            [<ffffffff>] 0xffffffff
[   65.164028]      in-softirq-W at:
[   65.164028]                                            [<c014d9a4>] __lock_acquire+0x51a/0x746
[   65.164028]                                            [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                            [<c06c8ab8>] _spin_lock+0x23/0x53
[   65.164028]                                            [<c012a118>] scheduler_tick+0x3a/0x211
[   65.164028]                                            [<c0135463>] update_process_times+0x47/0x53
[   65.164028]                                            [<c0147766>] tick_periodic+0x6b/0x6d
[   65.164028]                                            [<c0147786>] tick_handle_periodic+0x1e/0x60
[   65.164028]                                            [<c06c943c>] __irqentry_text_start+0x74/0x87
[   65.164028]                                            [<c0104061>] apic_timer_interrupt+0x2d/0x34
[   65.164028]                                            [<c0134d86>] run_timer_softirq+0x19c/0x1a4
[   65.164028]                                            [<c01314ec>] __do_softirq+0x9d/0x154
[   65.164028]                                            [<ffffffff>] 0xffffffff
[   65.164028]    }
[   65.164028]    ... key      at: [<c0c2cdf4>] __key.45602+0x0/0x8
[   65.164028]    -> (&vec->lock){.+..} ops: 0 {
[   65.164028]       initial-use  at:
[   65.164028]                                              [<c014da2e>] __lock_acquire+0x5a4/0x746
[   65.164028]                                              [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                              [<c06c8f2e>] _spin_lock_irqsave+0x3f/0x72
[   65.164028]                                              [<c0178677>] cpupri_set+0xc1/0x12f
[   65.164028]                                              [<c0122d2f>] rq_online_rt+0x92/0x9a
[   65.164028]                                              [<c012012c>] set_rq_online+0x72/0x80
[   65.164028]                                              [<c0123f8f>] rq_attach_root+0x17e/0x191
[   65.164028]                                              [<c0a7b355>] sched_init+0x214/0x333
[   65.164028]                                              [<c0a6e6a9>] start_kernel+0x13e/0x30a
[   65.164028]                                              [<c0a6e056>] i386_start_kernel+0x56/0x5e
[   65.164028]                                              [<ffffffff>] 0xffffffff
[   65.164028]       in-softirq-W at:
[   65.164028]                                              [<c014d9a4>] __lock_acquire+0x51a/0x746
[   65.164028]                                              [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                              [<c06c8f2e>] _spin_lock_irqsave+0x3f/0x72
[   65.164028]                                              [<c0178607>] cpupri_set+0x51/0x12f
[   65.164028]                                              [<c0122f72>] __enqueue_rt_entity+0xa3/0x14a
[   65.164028]                                              [<c012307d>] enqueue_task_rt+0x35/0x47
[   65.164028]                                              [<c011f747>] enqueue_task+0x51/0x5d
[   65.164028]                                              [<c011f771>] activate_task+0x1e/0x24
[   65.164028]                                              [<c0126c24>] try_to_wake_up+0x23e/0x2bf
[   65.164028]                                              [<c0126cdc>] wake_up_process+0x14/0x16
[   65.164028]                                              [<c012757b>] rebalance_domains+0x3ea/0x4d5
[   65.164028]                                              [<c012939f>] run_rebalance_domains+0x33/0xf2
[   65.164028]                                              [<c01314ec>] __do_softirq+0x9d/0x154
[   65.164028]                                              [<ffffffff>] 0xffffffff
[   65.164028]     }
[   65.164028]     ... key      at: [<c1222338>] __key.15525+0x0/0x8
[   65.164028]    ... acquired at:
[   65.164028]    [<c014d1b5>] validate_chain+0x8f9/0xbce
[   65.164028]    [<c014db6a>] __lock_acquire+0x6e0/0x746
[   65.164028]    [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]    [<c06c8f2e>] _spin_lock_irqsave+0x3f/0x72
[   65.164028]    [<c0178677>] cpupri_set+0xc1/0x12f
[   65.164028]    [<c0122d2f>] rq_online_rt+0x92/0x9a
[   65.164028]    [<c012012c>] set_rq_online+0x72/0x80
[   65.164028]    [<c0123f8f>] rq_attach_root+0x17e/0x191
[   65.164028]    [<c0a7b355>] sched_init+0x214/0x333
[   65.164028]    [<c0a6e6a9>] start_kernel+0x13e/0x30a
[   65.164028]    [<c0a6e056>] i386_start_kernel+0x56/0x5e
[   65.164028]    [<ffffffff>] 0xffffffff
[   65.164028] 
[   65.164028]    -> (&rt_b->rt_runtime_lock){.+..} ops: 0 {
[   65.164028]       initial-use  at:
[   65.164028]                                              [<c014da2e>] __lock_acquire+0x5a4/0x746
[   65.164028]                                              [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                              [<c06c8ab8>] _spin_lock+0x23/0x53
[   65.164028]                                              [<c0122fb6>] __enqueue_rt_entity+0xe7/0x14a
[   65.164028]                                              [<c012307d>] enqueue_task_rt+0x35/0x47
[   65.164028]                                              [<c011f747>] enqueue_task+0x51/0x5d
[   65.164028]                                              [<c011f771>] activate_task+0x1e/0x24
[   65.164028]                                              [<c0126c24>] try_to_wake_up+0x23e/0x2bf
[   65.164028]                                              [<c0126cdc>] wake_up_process+0x14/0x16
[   65.164028]                                              [<c06c3b7b>] migration_call+0xb9/0x4d6
[   65.164028]                                              [<c0a7aee8>] migration_init+0x3b/0x4b
[   65.164028]                                              [<c0101152>] do_one_initcall+0x6a/0x17f
[   65.164028]                                              [<c0a6e445>] kernel_init+0x53/0x14a
[   65.164028]                                              [<c010417b>] kernel_thread_helper+0x7/0x10
[   65.164028]                                              [<ffffffff>] 0xffffffff
[   65.164028]       in-softirq-W at:
[   65.164028]                                              [<c014d9a4>] __lock_acquire+0x51a/0x746
[   65.164028]                                              [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                              [<c06c8ab8>] _spin_lock+0x23/0x53
[   65.164028]                                              [<c0122fb6>] __enqueue_rt_entity+0xe7/0x14a
[   65.164028]                                              [<c012307d>] enqueue_task_rt+0x35/0x47
[   65.164028]                                              [<c011f747>] enqueue_task+0x51/0x5d
[   65.164028]                                              [<c011f771>] activate_task+0x1e/0x24
[   65.164028]                                              [<c0126c24>] try_to_wake_up+0x23e/0x2bf
[   65.164028]                                              [<c0126cdc>] wake_up_process+0x14/0x16
[   65.164028]                                              [<c012757b>] rebalance_domains+0x3ea/0x4d5
[   65.164028]                                              [<c012939f>] run_rebalance_domains+0x33/0xf2
[   65.164028]                                              [<c01314ec>] __do_softirq+0x9d/0x154
[   65.164028]                                              [<ffffffff>] 0xffffffff
[   65.164028]     }
[   65.164028]     ... key      at: [<c0c2cdfc>] __key.37294+0x0/0x8
[   65.164028]     -> (&cpu_base->lock){++..} ops: 0 {
[   65.164028]        initial-use  at:
[   65.164028]                                                [<c014da2e>] __lock_acquire+0x5a4/0x746
[   65.164028]                                                [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                                [<c06c8f2e>] _spin_lock_irqsave+0x3f/0x72
[   65.164028]                                                [<c01408f7>] lock_hrtimer_base+0x1d/0x38
[   65.164028]                                                [<c0140a62>] hrtimer_start_range_ns+0x1e/0x142
[   65.164028]                                                [<c0123002>] __enqueue_rt_entity+0x133/0x14a
[   65.164028]                                                [<c012307d>] enqueue_task_rt+0x35/0x47
[   65.164028]                                                [<c011f747>] enqueue_task+0x51/0x5d
[   65.164028]                                                [<c011f771>] activate_task+0x1e/0x24
[   65.164028]                                                [<c0126c24>] try_to_wake_up+0x23e/0x2bf
[   65.164028]                                                [<c0126cdc>] wake_up_process+0x14/0x16
[   65.164028]                                                [<c06c3b7b>] migration_call+0xb9/0x4d6
[   65.164028]                                                [<c0a7aee8>] migration_init+0x3b/0x4b
[   65.164028]                                                [<c0101152>] do_one_initcall+0x6a/0x17f
[   65.164028]                                                [<c0a6e445>] kernel_init+0x53/0x14a
[   65.164028]                                                [<c010417b>] kernel_thread_helper+0x7/0x10
[   65.164028]                                                [<ffffffff>] 0xffffffff
[   65.164028]        in-hardirq-W at:
[   65.164028]                                                [<c014d983>] __lock_acquire+0x4f9/0x746
[   65.164028]                                                [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                                [<c06c8ab8>] _spin_lock+0x23/0x53
[   65.164028]                                                [<c01407c1>] hrtimer_run_queues+0xd5/0x124
[   65.164028]                                                [<c0134fb5>] run_local_timers+0xd/0x1e
[   65.164028]                                                [<c0135445>] update_process_times+0x29/0x53
[   65.164028]                                                [<c0147766>] tick_periodic+0x6b/0x6d
[   65.164028]                                                [<c0147786>] tick_handle_periodic+0x1e/0x60
[   65.164028]                                                [<c06c943c>] __irqentry_text_start+0x74/0x87
[   65.164028]                                                [<c0104061>] apic_timer_interrupt+0x2d/0x34
[   65.164028]                                                [<c012d4a0>] printk+0x1a/0x1c
[   65.164028]                                                [<c01011ac>] do_one_initcall+0xc4/0x17f
[   65.164028]                                                [<c0a6e445>] kernel_init+0x53/0x14a
[   65.164028]                                                [<c010417b>] kernel_thread_helper+0x7/0x10
[   65.164028]                                                [<ffffffff>] 0xffffffff
[   65.164028]        in-softirq-W at:
[   65.164028]                                                [<c014d9a4>] __lock_acquire+0x51a/0x746
[   65.164028]                                                [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                                [<c06c8ab8>] _spin_lock+0x23/0x53
[   65.164028]                                                [<c01407c1>] hrtimer_run_queues+0xd5/0x124
[   65.164028]                                                [<c0134fb5>] run_local_timers+0xd/0x1e
[   65.164028]                                                [<c0135445>] update_process_times+0x29/0x53
[   65.164028]                                                [<c0147766>] tick_periodic+0x6b/0x6d
[   65.164028]                                                [<c0147786>] tick_handle_periodic+0x1e/0x60
[   65.164028]                                                [<c06c943c>] __irqentry_text_start+0x74/0x87
[   65.164028]                                                [<c0104061>] apic_timer_interrupt+0x2d/0x34
[   65.164028]                                                [<c0134d86>] run_timer_softirq+0x19c/0x1a4
[   65.164028]                                                [<c01314ec>] __do_softirq+0x9d/0x154
[   65.164028]                                                [<ffffffff>] 0xffffffff
[   65.164028]      }
[   65.164028]      ... key      at: [<c0e2ff8c>] __key.21090+0x0/0x8
[   65.164028]      ... acquired at:
[   65.164028]    [<c014d1b5>] validate_chain+0x8f9/0xbce
[   65.164028]    [<c014db6a>] __lock_acquire+0x6e0/0x746
[   65.164028]    [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]    [<c06c8f2e>] _spin_lock_irqsave+0x3f/0x72
[   65.164028]    [<c03a5b27>] debug_object_activate+0x2c/0xbd
[   65.164028]    [<c0140505>] enqueue_hrtimer+0x2b/0x15d
[   65.164028]    [<c0140b6e>] hrtimer_start_range_ns+0x12a/0x142
[   65.164028]    [<c0123002>] __enqueue_rt_entity+0x133/0x14a
[   65.164028]    [<c012307d>] enqueue_task_rt+0x35/0x47
[   65.164028]    [<c011f747>] enqueue_task+0x51/0x5d
[   65.164028]    [<c011f771>] activate_task+0x1e/0x24
[   65.164028]    [<c0126c24>] try_to_wake_up+0x23e/0x2bf
[   65.164028]    [<c0126cdc>] wake_up_process+0x14/0x16
[   65.164028]    [<c06c3b7b>] migration_call+0xb9/0x4d6
[   65.164028]    [<c0a7aee8>] migration_init+0x3b/0x4b
[   65.164028]    [<c0101152>] do_one_initcall+0x6a/0x17f
[   65.164028]    [<c0a6e445>] kernel_init+0x53/0x14a
[   65.164028]    [<c010417b>] kernel_thread_helper+0x7/0x10
[   65.164028]    [<ffffffff>] 0xffffffff
[   65.164028] 
[   65.164028]      -> (&cpu_base->lock/1){....} ops: 0 {
[   65.164028]         initial-use  at:
[   65.164028]                                                  [<c014da2e>] __lock_acquire+0x5a4/0x746
[   65.164028]                                                  [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                                  [<c06c8a65>] _spin_lock_nested+0x21/0x51
[   65.164028]                                                  [<c06c4789>] hrtimer_cpu_notify+0xd2/0x179
[   65.164028]                                                  [<c0141b6b>] notifier_call_chain+0x49/0x71
[   65.164028]                                                  [<c0141c09>] __raw_notifier_call_chain+0x13/0x15
[   65.164028]                                                  [<c0141c1c>] raw_notifier_call_chain+0x11/0x13
[   65.164028]                                                  [<c069a366>] _cpu_down+0x168/0x221
[   65.164028]                                                  [<c069a454>] cpu_down+0x35/0x57
[   65.164028]                                                  [<c069b594>] store_online+0x2a/0x5e
[   65.164028]                                                  [<c04397a5>] sysdev_store+0x20/0x28
[   65.164028]                                                  [<c01d2f30>] sysfs_write_file+0xbd/0xe8
[   65.164028]                                                  [<c019958a>] vfs_write+0x91/0x138
[   65.164028]                                                  [<c0199a95>] sys_write+0x40/0x65
[   65.164028]                                                  [<c010388b>] sysenter_do_call+0x12/0x3f
[   65.164028]                                                  [<ffffffff>] 0xffffffff
[   65.164028]       }
[   65.164028]       ... key      at: [<c0e2ff8d>] __key.21090+0x1/0x8
[   65.164028]       ... acquired at:
[   65.164028]    [<c014d1b5>] validate_chain+0x8f9/0xbce
[   65.164028]    [<c014db6a>] __lock_acquire+0x6e0/0x746
[   65.164028]    [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]    [<c06c8f2e>] _spin_lock_irqsave+0x3f/0x72
[   65.164028]    [<c03a5a95>] debug_object_deactivate+0x29/0x8f
[   65.164028]    [<c06c47c5>] hrtimer_cpu_notify+0x10e/0x179
[   65.164028]    [<c0141b6b>] notifier_call_chain+0x49/0x71
[   65.164028]    [<c0141c09>] __raw_notifier_call_chain+0x13/0x15
[   65.164028]    [<c0141c1c>] raw_notifier_call_chain+0x11/0x13
[   65.164028]    [<c069a366>] _cpu_down+0x168/0x221
[   65.164028]    [<c069a454>] cpu_down+0x35/0x57
[   65.164028]    [<c069b594>] store_online+0x2a/0x5e
[   65.164028]    [<c04397a5>] sysdev_store+0x20/0x28
[   65.164028]    [<c01d2f30>] sysfs_write_file+0xbd/0xe8
[   65.164028]    [<c019958a>] vfs_write+0x91/0x138
[   65.164028]    [<c0199a95>] sys_write+0x40/0x65
[   65.164028]    [<c010388b>] sysenter_do_call+0x12/0x3f
[   65.164028]    [<ffffffff>] 0xffffffff
[   65.164028] 
[   65.164028]      ... acquired at:
[   65.164028]    [<c014d1b5>] validate_chain+0x8f9/0xbce
[   65.164028]    [<c014db6a>] __lock_acquire+0x6e0/0x746
[   65.164028]    [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]    [<c06c8a65>] _spin_lock_nested+0x21/0x51
[   65.164028]    [<c06c4789>] hrtimer_cpu_notify+0xd2/0x179
[   65.164028]    [<c0141b6b>] notifier_call_chain+0x49/0x71
[   65.164028]    [<c0141c09>] __raw_notifier_call_chain+0x13/0x15
[   65.164028]    [<c0141c1c>] raw_notifier_call_chain+0x11/0x13
[   65.164028]    [<c069a366>] _cpu_down+0x168/0x221
[   65.164028]    [<c069a454>] cpu_down+0x35/0x57
[   65.164028]    [<c069b594>] store_online+0x2a/0x5e
[   65.164028]    [<c04397a5>] sysdev_store+0x20/0x28
[   65.164028]    [<c01d2f30>] sysfs_write_file+0xbd/0xe8
[   65.164028]    [<c019958a>] vfs_write+0x91/0x138
[   65.164028]    [<c0199a95>] sys_write+0x40/0x65
[   65.164028]    [<c010388b>] sysenter_do_call+0x12/0x3f
[   65.164028]    [<ffffffff>] 0xffffffff
[   65.164028] 
[   65.164028]     ... acquired at:
[   65.164028]    [<c014d1b5>] validate_chain+0x8f9/0xbce
[   65.164028]    [<c014db6a>] __lock_acquire+0x6e0/0x746
[   65.164028]    [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]    [<c06c8f2e>] _spin_lock_irqsave+0x3f/0x72
[   65.164028]    [<c01408f7>] lock_hrtimer_base+0x1d/0x38
[   65.164028]    [<c0140a62>] hrtimer_start_range_ns+0x1e/0x142
[   65.164028]    [<c0123002>] __enqueue_rt_entity+0x133/0x14a
[   65.164028]    [<c012307d>] enqueue_task_rt+0x35/0x47
[   65.164028]    [<c011f747>] enqueue_task+0x51/0x5d
[   65.164028]    [<c011f771>] activate_task+0x1e/0x24
[   65.164028]    [<c0126c24>] try_to_wake_up+0x23e/0x2bf
[   65.164028]    [<c0126cdc>] wake_up_process+0x14/0x16
[   65.164028]    [<c06c3b7b>] migration_call+0xb9/0x4d6
[   65.164028]    [<c0a7aee8>] migration_init+0x3b/0x4b
[   65.164028]    [<c0101152>] do_one_initcall+0x6a/0x17f
[   65.164028]    [<c0a6e445>] kernel_init+0x53/0x14a
[   65.164028]    [<c010417b>] kernel_thread_helper+0x7/0x10
[   65.164028]    [<ffffffff>] 0xffffffff
[   65.164028] 
[   65.164028]     -> (&rt_rq->rt_runtime_lock){++..} ops: 0 {
[   65.164028]        initial-use  at:
[   65.164028]                                                [<c014da2e>] __lock_acquire+0x5a4/0x746
[   65.164028]                                                [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                                [<c06c8ab8>] _spin_lock+0x23/0x53
[   65.164028]                                                [<c012246d>] update_curr_rt+0xdf/0x198
[   65.164028]                                                [<c012302c>] dequeue_task_rt+0x13/0x2f
[   65.164028]                                                [<c011f6c3>] dequeue_task+0xfb/0x10a
[   65.164028]                                                [<c011f6f0>] deactivate_task+0x1e/0x24
[   65.164028]                                                [<c06c5fc3>] schedule+0x168/0x98a
[   65.164028]                                                [<c0127df5>] migration_thread+0x1b3/0x24a
[   65.164028]                                                [<c013dfcf>] kthread+0x40/0x69
[   65.164028]                                                [<c010417b>] kernel_thread_helper+0x7/0x10
[   65.164028]                                                [<ffffffff>] 0xffffffff
[   65.164028]        in-hardirq-W at:
[   65.164028]                                                [<c014d983>] __lock_acquire+0x4f9/0x746
[   65.164028]                                                [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                                [<c06c8ab8>] _spin_lock+0x23/0x53
[   65.164028]                                                [<c012314f>] sched_rt_period_timer+0xc0/0x239
[   65.164028]                                                [<c01404a8>] __run_hrtimer+0x7c/0xae
[   65.164028]                                                [<c01407e2>] hrtimer_run_queues+0xf6/0x124
[   65.164028]                                                [<c0134fb5>] run_local_timers+0xd/0x1e
[   65.164028]                                                [<c0135445>] update_process_times+0x29/0x53
[   65.164028]                                                [<c0147766>] tick_periodic+0x6b/0x6d
[   65.164028]                                                [<c0147786>] tick_handle_periodic+0x1e/0x60
[   65.164028]                                                [<c06c943c>] __irqentry_text_start+0x74/0x87
[   65.164028]                                                [<c0104061>] apic_timer_interrupt+0x2d/0x34
[   65.164028]                                                [<c0108f9b>] default_idle+0x5d/0x97
[   65.164028]                                                [<c010233d>] cpu_idle+0x84/0xa5
[   65.164028]                                                [<c0699b3f>] rest_init+0x53/0x55
[   65.164028]                                                [<ffffffff>] 0xffffffff
[   65.164028]        in-softirq-W at:
[   65.164028]                                                [<c014d9a4>] __lock_acquire+0x51a/0x746
[   65.164028]                                                [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                                [<c06c8ab8>] _spin_lock+0x23/0x53
[   65.164028]                                                [<c012314f>] sched_rt_period_timer+0xc0/0x239
[   65.164028]                                                [<c01404a8>] __run_hrtimer+0x7c/0xae
[   65.164028]                                                [<c01407e2>] hrtimer_run_queues+0xf6/0x124
[   65.164028]                                                [<c0134fb5>] run_local_timers+0xd/0x1e
[   65.164028]                                                [<c0135445>] update_process_times+0x29/0x53
[   65.164028]                                                [<c0147766>] tick_periodic+0x6b/0x6d
[   65.164028]                                                [<c0147786>] tick_handle_periodic+0x1e/0x60
[   65.164028]                                                [<c06c943c>] __irqentry_text_start+0x74/0x87
[   65.164028]                                                [<c0104061>] apic_timer_interrupt+0x2d/0x34
[   65.164028]                                                [<c017b301>] mempool_free_slab+0x13/0x15
[   65.164028]                                                [<c017b36f>] mempool_free+0x6c/0x74
[   65.164028]                                                [<c01b72c5>] bio_free+0x2d/0x49
[   65.164028]                                                [<c01b72f4>] bio_fs_destructor+0x13/0x15
[   65.164028]                                                [<c01b6467>] bio_put+0x2b/0x2d
[   65.164028]                                                [<c01b5732>] end_bio_bh_io_sync+0x2f/0x32
[   65.164028]                                                [<c01b61fc>] bio_endio+0x2d/0x30
[   65.164028]                                                [<c0384bc6>] req_bio_endio+0x81/0x9e
[   65.164028]                                                [<c0384d4f>] __end_that_request_first+0x16c/0x265
[   65.164028]                                                [<c0384e61>] end_that_request_data+0x19/0x47
[   65.164028]                                                [<c0385753>] blk_end_io+0x21/0x6f
[   65.164028]                                                [<c03857da>] blk_end_request+0x11/0x13
[   65.164028]                                                [<c04ec256>] scsi_end_request+0x24/0x80
[   65.164028]                                                [<c04ece1e>] scsi_io_completion+0x1a4/0x376
[   65.164028]                                                [<c04e7588>] scsi_finish_command+0xd1/0xd9
[   65.164028]                                                [<c04ed0e3>] scsi_softirq_done+0xf3/0xfb
[   65.164028]                                                [<c0389705>] blk_done_softirq+0x72/0x81
[   65.164028]                                                [<c01314ec>] __do_softirq+0x9d/0x154
[   65.164028]                                                [<ffffffff>] 0xffffffff
[   65.164028]      }
[   65.164028]      ... key      at: [<c0c2ce04>] __key.45584+0x0/0x8
[   65.164028]     ... acquired at:
[   65.164028]    [<c014d1b5>] validate_chain+0x8f9/0xbce
[   65.164028]    [<c014db6a>] __lock_acquire+0x6e0/0x746
[   65.164028]    [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]    [<c06c8ab8>] _spin_lock+0x23/0x53
[   65.164028]    [<c0121921>] __enable_runtime+0x33/0x7d
[   65.164028]    [<c0122d15>] rq_online_rt+0x78/0x9a
[   65.164028]    [<c012012c>] set_rq_online+0x72/0x80
[   65.164028]    [<c06c3be9>] migration_call+0x127/0x4d6
[   65.164028]    [<c0141b6b>] notifier_call_chain+0x49/0x71
[   65.164028]    [<c0141c09>] __raw_notifier_call_chain+0x13/0x15
[   65.164028]    [<c0141c1c>] raw_notifier_call_chain+0x11/0x13
[   65.164028]    [<c06c40cb>] _cpu_up+0xbd/0xef
[   65.164028]    [<c06c4146>] cpu_up+0x49/0x59
[   65.164028]    [<c0a6e48d>] kernel_init+0x9b/0x14a
[   65.164028]    [<c010417b>] kernel_thread_helper+0x7/0x10
[   65.164028]    [<ffffffff>] 0xffffffff
[   65.164028] 
[   65.164028]    ... acquired at:
[   65.164028]    [<c014d1b5>] validate_chain+0x8f9/0xbce
[   65.164028]    [<c014db6a>] __lock_acquire+0x6e0/0x746
[   65.164028]    [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]    [<c06c8ab8>] _spin_lock+0x23/0x53
[   65.164028]    [<c0122fb6>] __enqueue_rt_entity+0xe7/0x14a
[   65.164028]    [<c012307d>] enqueue_task_rt+0x35/0x47
[   65.164028]    [<c011f747>] enqueue_task+0x51/0x5d
[   65.164028]    [<c011f771>] activate_task+0x1e/0x24
[   65.164028]    [<c0126c24>] try_to_wake_up+0x23e/0x2bf
[   65.164028]    [<c0126cdc>] wake_up_process+0x14/0x16
[   65.164028]    [<c06c3b7b>] migration_call+0xb9/0x4d6
[   65.164028]    [<c0a7aee8>] migration_init+0x3b/0x4b
[   65.164028]    [<c0101152>] do_one_initcall+0x6a/0x17f
[   65.164028]    [<c0a6e445>] kernel_init+0x53/0x14a
[   65.164028]    [<c010417b>] kernel_thread_helper+0x7/0x10
[   65.164028]    [<ffffffff>] 0xffffffff
[   65.164028] 
[   65.164028]    ... acquired at:
[   65.164028]    [<c014d1b5>] validate_chain+0x8f9/0xbce
[   65.164028]    [<c014db6a>] __lock_acquire+0x6e0/0x746
[   65.164028]    [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]    [<c06c8ab8>] _spin_lock+0x23/0x53
[   65.164028]    [<c012246d>] update_curr_rt+0xdf/0x198
[   65.164028]    [<c012302c>] dequeue_task_rt+0x13/0x2f
[   65.164028]    [<c011f6c3>] dequeue_task+0xfb/0x10a
[   65.164028]    [<c011f6f0>] deactivate_task+0x1e/0x24
[   65.164028]    [<c06c5fc3>] schedule+0x168/0x98a
[   65.164028]    [<c0127df5>] migration_thread+0x1b3/0x24a
[   65.164028]    [<c013dfcf>] kthread+0x40/0x69
[   65.164028]    [<c010417b>] kernel_thread_helper+0x7/0x10
[   65.164028]    [<ffffffff>] 0xffffffff
[   65.164028] 
[   65.164028]    -> (&zone->lock){.+..} ops: 0 {
[   65.164028]       initial-use  at:
[   65.164028]                                              [<c014da2e>] __lock_acquire+0x5a4/0x746
[   65.164028]                                              [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                              [<c06c8ab8>] _spin_lock+0x23/0x53
[   65.164028]                                              [<c017cfbf>] free_pages_bulk+0x21/0x1f2
[   65.164028]                                              [<c017d559>] free_hot_cold_page+0x1d8/0x233
[   65.164028]                                              [<c017d602>] free_hot_page+0xf/0x11
[   65.164028]                                              [<c017d9b4>] __free_pages+0x2a/0x35
[   65.164028]                                              [<c0a9c969>] __free_pages_bootmem+0x7e/0x82
[   65.164028]                                              [<c0a7eb2c>] free_all_bootmem_core+0xcb/0x180
[   65.164028]                                              [<c0a7ebee>] free_all_bootmem+0xd/0xf
[   65.164028]                                              [<c0a79f2a>] mem_init+0x26/0x261
[   65.164028]                                              [<c0a6e7c8>] start_kernel+0x25d/0x30a
[   65.164028]                                              [<c0a6e056>] i386_start_kernel+0x56/0x5e
[   65.164028]                                              [<ffffffff>] 0xffffffff
[   65.164028]       in-softirq-W at:
[   65.164028]                                              [<c014d9a4>] __lock_acquire+0x51a/0x746
[   65.164028]                                              [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                              [<c06c8ab8>] _spin_lock+0x23/0x53
[   65.164028]                                              [<c017d7ad>] __free_pages_ok+0x1a9/0x386
[   65.164028]                                              [<c017d9bd>] __free_pages+0x33/0x35
[   65.164028]                                              [<c0193463>] __free_slab+0xad/0xb5
[   65.164028]                                              [<c019349d>] discard_slab+0x32/0x34
[   65.164028]                                              [<c0193650>] __slab_free+0xc6/0x243
[   65.164028]                                              [<c0194ac2>] kmem_cache_free+0x9c/0xd2
[   65.164028]                                              [<c012ac09>] free_task+0x38/0x3b
[   65.164028]                                              [<c012c301>] __put_task_struct+0xd0/0xd5
[   65.164028]                                              [<c012ddd2>] delayed_put_task_struct+0x41/0x45
[   65.164028]                                              [<c0169ea3>] __rcu_process_callbacks+0x162/0x1f7
[   65.164028]                                              [<c0169f5e>] rcu_process_callbacks+0x26/0x46
[   65.164028]                                              [<c01314ec>] __do_softirq+0x9d/0x154
[   65.164028]                                              [<ffffffff>] 0xffffffff
[   65.164028]     }
[   65.164028]     ... key      at: [<c12223a0>] __key.31326+0x0/0x8
[   65.164028]    ... acquired at:
[   65.164028]    [<c014d1b5>] validate_chain+0x8f9/0xbce
[   65.164028]    [<c014db6a>] __lock_acquire+0x6e0/0x746
[   65.164028]    [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]    [<c06c8ab8>] _spin_lock+0x23/0x53
[   65.164028]    [<c017ce6c>] rmqueue_bulk+0x2b/0x70
[   65.164028]    [<c017dbb6>] get_page_from_freelist+0x167/0x42a
[   65.164028]    [<c017df4c>] __alloc_pages_internal+0xb8/0x370
[   65.164028]    [<c0193b79>] __slab_alloc+0x14a/0x441
[   65.164028]    [<c0193ed3>] kmem_cache_alloc+0x63/0xd1
[   65.164028]    [<c0391c65>] alloc_cpumask_var+0x23/0x6f
[   65.164028]    [<c06c6004>] schedule+0x1a9/0x98a
[   65.164028]    [<c0166552>] watchdog+0x3f/0x1d5
[   65.164028]    [<c013dfcf>] kthread+0x40/0x69
[   65.164028]    [<c010417b>] kernel_thread_helper+0x7/0x10
[   65.164028]    [<ffffffff>] 0xffffffff
[   65.164028] 
[   65.164028]    ... acquired at:
[   65.164028]    [<c014d1b5>] validate_chain+0x8f9/0xbce
[   65.164028]    [<c014db6a>] __lock_acquire+0x6e0/0x746
[   65.164028]    [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]    [<c06c8ab8>] _spin_lock+0x23/0x53
[   65.164028]    [<c0193510>] deactivate_slab+0x71/0xd6
[   65.164028]    [<c0193ac0>] __slab_alloc+0x91/0x441
[   65.164028]    [<c0193ed3>] kmem_cache_alloc+0x63/0xd1
[   65.164028]    [<c0391c65>] alloc_cpumask_var+0x23/0x6f
[   65.164028]    [<c06c6004>] schedule+0x1a9/0x98a
[   65.164028]    [<c06c6934>] schedule_timeout+0x1b/0x97
[   65.164028]    [<c06c5cdb>] wait_for_common+0xc1/0x110
[   65.164028]    [<c06c5dc5>] wait_for_completion+0x17/0x19
[   65.164028]    [<c013a8ad>] call_usermodehelper_exec+0x90/0xd0
[   65.164028]    [<c0393cf2>] kobject_uevent_env+0x489/0x4c5
[   65.164028]    [<c0393d38>] kobject_uevent+0xa/0xc
[   65.164028]    [<c03932c0>] kset_register+0x2e/0x34
[   65.164028]    [<c04399c1>] sysdev_class_register+0x96/0x9e
[   65.164028]    [<c0a8954c>] cpu_dev_init+0xf/0x49
[   65.164028]    [<c0a895ca>] driver_init+0x26/0x28
[   65.164028]    [<c0a6e4db>] kernel_init+0xe9/0x14a
[   65.164028]    [<c010417b>] kernel_thread_helper+0x7/0x10
[   65.164028]    [<ffffffff>] 0xffffffff
[   65.164028] 
[   65.164028]    -> (trace_wait.lock){.+..} ops: 0 {
[   65.164028]       initial-use  at:
[   65.164028]                                              [<c014da2e>] __lock_acquire+0x5a4/0x746
[   65.164028]                                              [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                              [<c06c8f2e>] _spin_lock_irqsave+0x3f/0x72
[   65.164028]                                              [<c011fd42>] __wake_up+0x1a/0x40
[   65.164028]                                              [<c0175152>] trace_wake_up+0x2b/0x2e
[   65.164028]                                              [<c0177897>] trace_boot_call+0x74/0x7b
[   65.164028]                                              [<c0101148>] do_one_initcall+0x60/0x17f
[   65.164028]                                              [<c0a6e4ee>] kernel_init+0xfc/0x14a
[   65.164028]                                              [<c010417b>] kernel_thread_helper+0x7/0x10
[   65.164028]                                              [<ffffffff>] 0xffffffff
[   65.164028]       in-softirq-W at:
[   65.164028]                                              [<c014d9a4>] __lock_acquire+0x51a/0x746
[   65.164028]                                              [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                              [<c06c8f2e>] _spin_lock_irqsave+0x3f/0x72
[   65.164028]                                              [<c011fd42>] __wake_up+0x1a/0x40
[   65.164028]                                              [<c0175152>] trace_wake_up+0x2b/0x2e
[   65.164028]                                              [<c01751fe>] tracing_sched_wakeup_trace+0xa9/0xb4
[   65.164028]                                              [<c0176369>] probe_sched_wakeup+0x71/0xa5
[   65.164028]                                              [<c0126c44>] try_to_wake_up+0x25e/0x2bf
[   65.164028]                                              [<c0126cdc>] wake_up_process+0x14/0x16
[   65.164028]                                              [<c017fdba>] pdflush_operation+0x76/0x8c
[   65.164028]                                              [<c017eec4>] wb_timer_fn+0x14/0x30
[   65.164028]                                              [<c0134d2e>] run_timer_softirq+0x144/0x1a4
[   65.164028]                                              [<c01314ec>] __do_softirq+0x9d/0x154
[   65.164028]                                              [<ffffffff>] 0xffffffff
[   65.164028]     }
[   65.164028]     ... key      at: [<c09dcd98>] trace_wait+0x10/0x2c
[   65.164028]    ... acquired at:
[   65.164028]    [<c014d1b5>] validate_chain+0x8f9/0xbce
[   65.164028]    [<c014db6a>] __lock_acquire+0x6e0/0x746
[   65.164028]    [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]    [<c06c8f2e>] _spin_lock_irqsave+0x3f/0x72
[   65.164028]    [<c011fd42>] __wake_up+0x1a/0x40
[   65.164028]    [<c0175152>] trace_wake_up+0x2b/0x2e
[   65.164028]    [<c01751fe>] tracing_sched_wakeup_trace+0xa9/0xb4
[   65.164028]    [<c0176369>] probe_sched_wakeup+0x71/0xa5
[   65.164028]    [<c0129f55>] wake_up_new_task+0x8f/0xc9
[   65.164028]    [<c012bf31>] do_fork+0x205/0x2a2
[   65.164028]    [<c01022b1>] kernel_thread+0x7c/0x84
[   65.164028]    [<c013de53>] kthreadd+0xb1/0x14d
[   65.164028]    [<c010417b>] kernel_thread_helper+0x7/0x10
[   65.164028]    [<ffffffff>] 0xffffffff
[   65.164028] 
[   65.164028]    -> (&rq->lock/1){.+..} ops: 0 {
[   65.164028]       initial-use  at:
[   65.164028]                                              [<c014da2e>] __lock_acquire+0x5a4/0x746
[   65.164028]                                              [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                              [<c06c8a65>] _spin_lock_nested+0x21/0x51
[   65.164028]                                              [<c012679c>] double_rq_lock+0x53/0x85
[   65.164028]                                              [<c01273b5>] rebalance_domains+0x224/0x4d5
[   65.164028]                                              [<c012939f>] run_rebalance_domains+0x33/0xf2
[   65.164028]                                              [<c01314ec>] __do_softirq+0x9d/0x154
[   65.164028]                                              [<ffffffff>] 0xffffffff
[   65.164028]       in-softirq-W at:
[   65.164028]                                              [<c014d9a4>] __lock_acquire+0x51a/0x746
[   65.164028]                                              [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                              [<c06c8a65>] _spin_lock_nested+0x21/0x51
[   65.164028]                                              [<c012679c>] double_rq_lock+0x53/0x85
[   65.164028]                                              [<c01273b5>] rebalance_domains+0x224/0x4d5
[   65.164028]                                              [<c012939f>] run_rebalance_domains+0x33/0xf2
[   65.164028]                                              [<c01314ec>] __do_softirq+0x9d/0x154
[   65.164028]                                              [<ffffffff>] 0xffffffff
[   65.164028]     }
[   65.164028]     ... key      at: [<c0c2cdf5>] __key.45602+0x1/0x8
[   65.164028]    ... acquired at:
[   65.164028]    [<c014d1b5>] validate_chain+0x8f9/0xbce
[   65.164028]    [<c014db6a>] __lock_acquire+0x6e0/0x746
[   65.164028]    [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]    [<c06c8a65>] _spin_lock_nested+0x21/0x51
[   65.164028]    [<c012679c>] double_rq_lock+0x53/0x85
[   65.164028]    [<c01273b5>] rebalance_domains+0x224/0x4d5
[   65.164028]    [<c012939f>] run_rebalance_domains+0x33/0xf2
[   65.164028]    [<c01314ec>] __do_softirq+0x9d/0x154
[   65.164028]    [<ffffffff>] 0xffffffff
[   65.164028] 
[   65.164028]   ... acquired at:
[   65.164028]    [<c014d1b5>] validate_chain+0x8f9/0xbce
[   65.164028]    [<c014db6a>] __lock_acquire+0x6e0/0x746
[   65.164028]    [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]    [<c06c8ab8>] _spin_lock+0x23/0x53
[   65.164028]    [<c011fe83>] task_rq_lock+0x4e/0x78
[   65.164028]    [<c0126a87>] try_to_wake_up+0xa1/0x2bf
[   65.164028]    [<c0126cb5>] default_wake_function+0x10/0x12
[   65.164028]    [<c011ec20>] __wake_up_common+0x3a/0x60
[   65.164028]    [<c011fccc>] complete+0x30/0x43
[   65.164028]    [<c013dfb3>] kthread+0x24/0x69
[   65.164028]    [<c010417b>] kernel_thread_helper+0x7/0x10
[   65.164028]    [<ffffffff>] 0xffffffff
[   65.164028] 
[   65.164028]  ... acquired at:
[   65.164028]    [<c014d1b5>] validate_chain+0x8f9/0xbce
[   65.164028]    [<c014db6a>] __lock_acquire+0x6e0/0x746
[   65.164028]    [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]    [<c06c8f2e>] _spin_lock_irqsave+0x3f/0x72
[   65.164028]    [<c011fcfd>] __wake_up_sync+0x1e/0x49
[   65.164028]    [<c05c5301>] sock_def_readable+0x3d/0x68
[   65.164028]    [<c060beac>] tcp_child_process+0x4c/0x9a
[   65.164028]    [<c0609f77>] tcp_v4_do_rcv+0x241/0x2a5
[   65.164028]    [<c060be0b>] tcp_v4_rcv+0x67d/0x6d2
[   65.164028]    [<c05f2c95>] ip_local_deliver_finish+0x112/0x1c5
[   65.164028]    [<c05f309a>] ip_local_deliver+0x59/0x63
[   65.164028]    [<c05f2b6d>] ip_rcv_finish+0x285/0x29b
[   65.164028]    [<c05f3017>] ip_rcv+0x1f1/0x21b
[   65.164028]    [<c05cc853>] netif_receive_skb+0x2f2/0x325
[   65.164028]    [<c04b597f>] nv_napi_poll+0x3b9/0x4d2
[   65.164028]    [<c05cefec>] net_rx_action+0xd6/0x1f7
[   65.164028]    [<c01314ec>] __do_softirq+0x9d/0x154
[   65.164028]    [<ffffffff>] 0xffffffff
[   65.164028] 
[   65.164028]  -> (tcp_lock){-+..} ops: 0 {
[   65.164028]     initial-use  at:
[   65.164028]                                          [<c014da2e>] __lock_acquire+0x5a4/0x746
[   65.164028]                                          [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                          [<c06c8bf6>] _write_lock_bh+0x28/0x58
[   65.164028]                                          [<c05e7a08>] tcp_packet+0x7a/0xea6
[   65.164028]                                          [<c05e4da5>] nf_conntrack_in+0x6e9/0x7d4
[   65.164028]                                          [<c0620120>] ipv4_conntrack_local+0x55/0x5c
[   65.164028]                                          [<c05e0265>] nf_iterate+0x34/0x80
[   65.164028]                                          [<c05e030f>] nf_hook_slow+0x5e/0xca
[   65.164028]                                          [<c05f5dc5>] __ip_local_out+0x82/0x89
[   65.164028]                                          [<c05f5ddc>] ip_local_out+0x10/0x20
[   65.164028]                                          [<c05f68ce>] ip_queue_xmit+0x2b6/0x2f7
[   65.164028]                                          [<c0605e8a>] tcp_transmit_skb+0x5ca/0x604
[   65.164028]                                          [<c0607fed>] tcp_connect+0x2ad/0x388
[   65.164028]                                          [<c060b32a>] tcp_v4_connect+0x447/0x49e
[   65.164028]                                          [<c06160cf>] inet_stream_connect+0x8f/0x204
[   65.164028]                                          [<c05c276e>] sys_connect+0x59/0x76
[   65.164028]                                          [<c05c2db2>] sys_socketcall+0x91/0x18a
[   65.164028]                                          [<c010388b>] sysenter_do_call+0x12/0x3f
[   65.164028]                                          [<ffffffff>] 0xffffffff
[   65.164028]     in-softirq-W at:
[   65.164028]                                          [<c014d9a4>] __lock_acquire+0x51a/0x746
[   65.164028]                                          [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                          [<c06c8bf6>] _write_lock_bh+0x28/0x58
[   65.164028]                                          [<c05e7a08>] tcp_packet+0x7a/0xea6
[   65.164028]                                          [<c05e4da5>] nf_conntrack_in+0x6e9/0x7d4
[   65.164028]                                          [<c06204ac>] ipv4_conntrack_in+0x1a/0x1c
[   65.164028]                                          [<c05e0265>] nf_iterate+0x34/0x80
[   65.164028]                                          [<c05e030f>] nf_hook_slow+0x5e/0xca
[   65.164028]                                          [<c05f3008>] ip_rcv+0x1e2/0x21b
[   65.164028]                                          [<c05cc853>] netif_receive_skb+0x2f2/0x325
[   65.164028]                                          [<c04b597f>] nv_napi_poll+0x3b9/0x4d2
[   65.164028]                                          [<c05cefec>] net_rx_action+0xd6/0x1f7
[   65.164028]                                          [<c01314ec>] __do_softirq+0x9d/0x154
[   65.164028]                                          [<ffffffff>] 0xffffffff
[   65.164028]     hardirq-on-W at:
[   65.164028]                                          [<c014d9f8>] __lock_acquire+0x56e/0x746
[   65.164028]                                          [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                          [<c06c8bf6>] _write_lock_bh+0x28/0x58
[   65.164028]                                          [<c05e7a08>] tcp_packet+0x7a/0xea6
[   65.164028]                                          [<c05e4da5>] nf_conntrack_in+0x6e9/0x7d4
[   65.164028]                                          [<c0620120>] ipv4_conntrack_local+0x55/0x5c
[   65.164028]                                          [<c05e0265>] nf_iterate+0x34/0x80
[   65.164028]                                          [<c05e030f>] nf_hook_slow+0x5e/0xca
[   65.164028]                                          [<c05f5dc5>] __ip_local_out+0x82/0x89
[   65.164028]                                          [<c05f5ddc>] ip_local_out+0x10/0x20
[   65.164028]                                          [<c05f68ce>] ip_queue_xmit+0x2b6/0x2f7
[   65.164028]                                          [<c0605e8a>] tcp_transmit_skb+0x5ca/0x604
[   65.164028]                                          [<c0607fed>] tcp_connect+0x2ad/0x388
[   65.164028]                                          [<c060b32a>] tcp_v4_connect+0x447/0x49e
[   65.164028]                                          [<c06160cf>] inet_stream_connect+0x8f/0x204
[   65.164028]                                          [<c05c276e>] sys_connect+0x59/0x76
[   65.164028]                                          [<c05c2db2>] sys_socketcall+0x91/0x18a
[   65.164028]                                          [<c010388b>] sysenter_do_call+0x12/0x3f
[   65.164028]                                          [<ffffffff>] 0xffffffff
[   65.164028]   }
[   65.164028]   ... key      at: [<c0a29b08>] tcp_lock+0x10/0x24
[   65.164028]  ... acquired at:
[   65.164028]    [<c014d1b5>] validate_chain+0x8f9/0xbce
[   65.164028]    [<c014db6a>] __lock_acquire+0x6e0/0x746
[   65.164028]    [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]    [<c06c8bf6>] _write_lock_bh+0x28/0x58
[   65.164028]    [<c05e7a08>] tcp_packet+0x7a/0xea6
[   65.164028]    [<c05e4da5>] nf_conntrack_in+0x6e9/0x7d4
[   65.164028]    [<c0620120>] ipv4_conntrack_local+0x55/0x5c
[   65.164028]    [<c05e0265>] nf_iterate+0x34/0x80
[   65.164028]    [<c05e030f>] nf_hook_slow+0x5e/0xca
[   65.164028]    [<c05f5dc5>] __ip_local_out+0x82/0x89
[   65.164028]    [<c05f5ddc>] ip_local_out+0x10/0x20
[   65.164028]    [<c05f68ce>] ip_queue_xmit+0x2b6/0x2f7
[   65.164028]    [<c0605e8a>] tcp_transmit_skb+0x5ca/0x604
[   65.164028]    [<c0605ff0>] tcp_send_ack+0xb3/0xbb
[   65.164028]    [<c0608794>] tcp_delack_timer+0x15a/0x1b1
[   65.164028]    [<c0134d2e>] run_timer_softirq+0x144/0x1a4
[   65.164028]    [<c01314ec>] __do_softirq+0x9d/0x154
[   65.164028]    [<ffffffff>] 0xffffffff
[   65.164028] 
[   65.164028]  -> (nf_conntrack_lock){-+..} ops: 0 {
[   65.164028]     initial-use  at:
[   65.164028]                                          [<c014da2e>] __lock_acquire+0x5a4/0x746
[   65.164028]                                          [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                          [<c06c8b10>] _spin_lock_bh+0x28/0x58
[   65.164028]                                          [<c05e4a7b>] nf_conntrack_in+0x3bf/0x7d4
[   65.164028]                                          [<c0620120>] ipv4_conntrack_local+0x55/0x5c
[   65.164028]                                          [<c05e0265>] nf_iterate+0x34/0x80
[   65.164028]                                          [<c05e030f>] nf_hook_slow+0x5e/0xca
[   65.164028]                                          [<c05f5dc5>] __ip_local_out+0x82/0x89
[   65.164028]                                          [<c05f5ddc>] ip_local_out+0x10/0x20
[   65.164028]                                          [<c05f68ce>] ip_queue_xmit+0x2b6/0x2f7
[   65.164028]                                          [<c0605e8a>] tcp_transmit_skb+0x5ca/0x604
[   65.164028]                                          [<c0607fed>] tcp_connect+0x2ad/0x388
[   65.164028]                                          [<c060b32a>] tcp_v4_connect+0x447/0x49e
[   65.164028]                                          [<c06160cf>] inet_stream_connect+0x8f/0x204
[   65.164028]                                          [<c05c276e>] sys_connect+0x59/0x76
[   65.164028]                                          [<c05c2db2>] sys_socketcall+0x91/0x18a
[   65.164028]                                          [<c010388b>] sysenter_do_call+0x12/0x3f
[   65.164028]                                          [<ffffffff>] 0xffffffff
[   65.164028]     in-softirq-W at:
[   65.164028]                                          [<c014d9a4>] __lock_acquire+0x51a/0x746
[   65.164028]                                          [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                          [<c06c8b10>] _spin_lock_bh+0x28/0x58
[   65.164028]                                          [<c05e3fc7>] __nf_ct_refresh_acct+0x57/0x167
[   65.164028]                                          [<c05e8816>] tcp_packet+0xe88/0xea6
[   65.164028]                                          [<c05e4da5>] nf_conntrack_in+0x6e9/0x7d4
[   65.164028]                                          [<c06204ac>] ipv4_conntrack_in+0x1a/0x1c
[   65.164028]                                          [<c05e0265>] nf_iterate+0x34/0x80
[   65.164028]                                          [<c05e030f>] nf_hook_slow+0x5e/0xca
[   65.164028]                                          [<c05f3008>] ip_rcv+0x1e2/0x21b
[   65.164028]                                          [<c05cc853>] netif_receive_skb+0x2f2/0x325
[   65.164028]                                          [<c04b597f>] nv_napi_poll+0x3b9/0x4d2
[   65.164028]                                          [<c05cefec>] net_rx_action+0xd6/0x1f7
[   65.164028]                                          [<c01314ec>] __do_softirq+0x9d/0x154
[   65.164028]                                          [<ffffffff>] 0xffffffff
[   65.164028]     hardirq-on-W at:
[   65.164028]                                          [<c014d9f8>] __lock_acquire+0x56e/0x746
[   65.164028]                                          [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                          [<c06c8b10>] _spin_lock_bh+0x28/0x58
[   65.164028]                                          [<c05e4a7b>] nf_conntrack_in+0x3bf/0x7d4
[   65.164028]                                          [<c0620120>] ipv4_conntrack_local+0x55/0x5c
[   65.164028]                                          [<c05e0265>] nf_iterate+0x34/0x80
[   65.164028]                                          [<c05e030f>] nf_hook_slow+0x5e/0xca
[   65.164028]                                          [<c05f5dc5>] __ip_local_out+0x82/0x89
[   65.164028]                                          [<c05f5ddc>] ip_local_out+0x10/0x20
[   65.164028]                                          [<c05f68ce>] ip_queue_xmit+0x2b6/0x2f7
[   65.164028]                                          [<c0605e8a>] tcp_transmit_skb+0x5ca/0x604
[   65.164028]                                          [<c0607fed>] tcp_connect+0x2ad/0x388
[   65.164028]                                          [<c060b32a>] tcp_v4_connect+0x447/0x49e
[   65.164028]                                          [<c06160cf>] inet_stream_connect+0x8f/0x204
[   65.164028]                                          [<c05c276e>] sys_connect+0x59/0x76
[   65.164028]                                          [<c05c2db2>] sys_socketcall+0x91/0x18a
[   65.164028]                                          [<c010388b>] sysenter_do_call+0x12/0x3f
[   65.164028]                                          [<ffffffff>] 0xffffffff
[   65.164028]   }
[   65.164028]   ... key      at: [<c0a2983c>] nf_conntrack_lock+0x10/0x24
[   65.164028]   ... acquired at:
[   65.164028]    [<c014d1b5>] validate_chain+0x8f9/0xbce
[   65.164028]    [<c014db6a>] __lock_acquire+0x6e0/0x746
[   65.164028]    [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]    [<c06c8f2e>] _spin_lock_irqsave+0x3f/0x72
[   65.164028]    [<c01351eb>] lock_timer_base+0x24/0x43
[   65.164028]    [<c0135312>] __mod_timer+0x2f/0xc8
[   65.164028]    [<c05e45e9>] __nf_conntrack_confirm+0x23c/0x30f
[   65.164028]    [<c0620585>] ipv4_confirm+0xa7/0xc5
[   65.164028]    [<c05e0265>] nf_iterate+0x34/0x80
[   65.164028]    [<c05e030f>] nf_hook_slow+0x5e/0xca
[   65.164028]    [<c05f656f>] ip_output+0x68/0x7c
[   65.164028]    [<c05f5de9>] ip_local_out+0x1d/0x20
[   65.164028]    [<c05f68ce>] ip_queue_xmit+0x2b6/0x2f7
[   65.164028]    [<c0605e8a>] tcp_transmit_skb+0x5ca/0x604
[   65.164028]    [<c0607fed>] tcp_connect+0x2ad/0x388
[   65.164028]    [<c060b32a>] tcp_v4_connect+0x447/0x49e
[   65.164028]    [<c06160cf>] inet_stream_connect+0x8f/0x204
[   65.164028]    [<c05c276e>] sys_connect+0x59/0x76
[   65.164028]    [<c05c2db2>] sys_socketcall+0x91/0x18a
[   65.164028]    [<c010388b>] sysenter_do_call+0x12/0x3f
[   65.164028]    [<ffffffff>] 0xffffffff
[   65.164028] 
[   65.164028]  ... acquired at:
[   65.164028]    [<c014d1b5>] validate_chain+0x8f9/0xbce
[   65.164028]    [<c014db6a>] __lock_acquire+0x6e0/0x746
[   65.164028]    [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]    [<c06c8b10>] _spin_lock_bh+0x28/0x58
[   65.164028]    [<c05e3fc7>] __nf_ct_refresh_acct+0x57/0x167
[   65.164028]    [<c05e8816>] tcp_packet+0xe88/0xea6
[   65.164028]    [<c05e4da5>] nf_conntrack_in+0x6e9/0x7d4
[   65.164028]    [<c0620120>] ipv4_conntrack_local+0x55/0x5c
[   65.164028]    [<c05e0265>] nf_iterate+0x34/0x80
[   65.164028]    [<c05e030f>] nf_hook_slow+0x5e/0xca
[   65.164028]    [<c05f5dc5>] __ip_local_out+0x82/0x89
[   65.164028]    [<c05f5ddc>] ip_local_out+0x10/0x20
[   65.164028]    [<c05f68ce>] ip_queue_xmit+0x2b6/0x2f7
[   65.164028]    [<c0605e8a>] tcp_transmit_skb+0x5ca/0x604
[   65.164028]    [<c0605ff0>] tcp_send_ack+0xb3/0xbb
[   65.164028]    [<c0608794>] tcp_delack_timer+0x15a/0x1b1
[   65.164028]    [<c0134d2e>] run_timer_softirq+0x144/0x1a4
[   65.164028]    [<c01314ec>] __do_softirq+0x9d/0x154
[   65.164028]    [<ffffffff>] 0xffffffff
[   65.164028] 
[   65.164028]  -> (&list->lock#4){-+..} ops: 0 {
[   65.164028]     initial-use  at:
[   65.164028]                                          [<c014da2e>] __lock_acquire+0x5a4/0x746
[   65.164028]                                          [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                          [<c06c8b10>] _spin_lock_bh+0x28/0x58
[   65.164028]                                          [<c05dc5a8>] dev_deactivate+0x11d/0x15a
[   65.164028]                                          [<c05d7238>] __linkwatch_run_queue+0x112/0x141
[   65.164028]                                          [<c05d728c>] linkwatch_event+0x25/0x2c
[   65.164028]                                          [<c013ad65>] run_workqueue+0xc3/0x193
[   65.164028]                                          [<c013b81f>] worker_thread+0xbb/0xc7
[   65.164028]                                          [<c013dfcf>] kthread+0x40/0x69
[   65.164028]                                          [<c010417b>] kernel_thread_helper+0x7/0x10
[   65.164028]                                          [<ffffffff>] 0xffffffff
[   65.164028]     in-softirq-W at:
[   65.164028]                                          [<c014d9a4>] __lock_acquire+0x51a/0x746
[   65.164028]                                          [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                          [<c06c8ab8>] _spin_lock+0x23/0x53
[   65.164028]                                          [<c05cfafa>] dev_queue_xmit+0x304/0x482
[   65.164028]                                          [<c0610c3b>] arp_xmit+0x38/0x3d
[   65.164028]                                          [<c061159a>] arp_send+0x37/0x3c
[   65.164028]                                          [<c0611ef0>] arp_solicit+0x16e/0x185
[   65.164028]                                          [<c05d5123>] neigh_timer_handler+0x24f/0x298
[   65.164028]                                          [<c0134d2e>] run_timer_softirq+0x144/0x1a4
[   65.164028]                                          [<c01314ec>] __do_softirq+0x9d/0x154
[   65.164028]                                          [<ffffffff>] 0xffffffff
[   65.164028]     hardirq-on-W at:
[   65.164028]                                          [<c014d9f8>] __lock_acquire+0x56e/0x746
[   65.164028]                                          [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                          [<c06c8b10>] _spin_lock_bh+0x28/0x58
[   65.164028]                                          [<c05dc5a8>] dev_deactivate+0x11d/0x15a
[   65.164028]                                          [<c05d7238>] __linkwatch_run_queue+0x112/0x141
[   65.164028]                                          [<c05d728c>] linkwatch_event+0x25/0x2c
[   65.164028]                                          [<c013ad65>] run_workqueue+0xc3/0x193
[   65.164028]                                          [<c013b81f>] worker_thread+0xbb/0xc7
[   65.164028]                                          [<c013dfcf>] kthread+0x40/0x69
[   65.164028]                                          [<c010417b>] kernel_thread_helper+0x7/0x10
[   65.164028]                                          [<ffffffff>] 0xffffffff
[   65.164028]   }
[   65.164028]   ... key      at: [<c132b094>] __key.22497+0x0/0x8
[   65.164028]  ... acquired at:
[   65.164028]    [<c014d1b5>] validate_chain+0x8f9/0xbce
[   65.164028]    [<c014db6a>] __lock_acquire+0x6e0/0x746
[   65.164028]    [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]    [<c06c8ab8>] _spin_lock+0x23/0x53
[   65.164028]    [<c05cfafa>] dev_queue_xmit+0x304/0x482
[   65.164028]    [<c05f629e>] ip_finish_output+0x1e0/0x218
[   65.164028]    [<c05f657e>] ip_output+0x77/0x7c
[   65.164028]    [<c05f5de9>] ip_local_out+0x1d/0x20
[   65.164028]    [<c05f68ce>] ip_queue_xmit+0x2b6/0x2f7
[   65.164028]    [<c0605e8a>] tcp_transmit_skb+0x5ca/0x604
[   65.164028]    [<c0605ff0>] tcp_send_ack+0xb3/0xbb
[   65.164028]    [<c0608794>] tcp_delack_timer+0x15a/0x1b1
[   65.164028]    [<c0134d2e>] run_timer_softirq+0x144/0x1a4
[   65.164028]    [<c01314ec>] __do_softirq+0x9d/0x154
[   65.164028]    [<ffffffff>] 0xffffffff
[   65.164028] 
[   65.164028]  -> (_xmit_ETHER#2){-+..} ops: 0 {
[   65.164028]     initial-use  at:
[   65.164028]                                          [<c014da2e>] __lock_acquire+0x5a4/0x746
[   65.164028]                                          [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                          [<c06c8ab8>] _spin_lock+0x23/0x53
[   65.164028]                                          [<c05dc509>] dev_deactivate+0x7e/0x15a
[   65.164028]                                          [<c05d7238>] __linkwatch_run_queue+0x112/0x141
[   65.164028]                                          [<c05d728c>] linkwatch_event+0x25/0x2c
[   65.164028]                                          [<c013ad65>] run_workqueue+0xc3/0x193
[   65.164028]                                          [<c013b81f>] worker_thread+0xbb/0xc7
[   65.164028]                                          [<c013dfcf>] kthread+0x40/0x69
[   65.164028]                                          [<c010417b>] kernel_thread_helper+0x7/0x10
[   65.164028]                                          [<ffffffff>] 0xffffffff
[   65.164028]     in-softirq-W at:
[   65.164028]                                          [<c014d9a4>] __lock_acquire+0x51a/0x746
[   65.164028]                                          [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                          [<c06c8ab8>] _spin_lock+0x23/0x53
[   65.164028]                                          [<c05dc628>] dev_watchdog+0x43/0x193
[   65.164028]                                          [<c0134d2e>] run_timer_softirq+0x144/0x1a4
[   65.164028]                                          [<c01314ec>] __do_softirq+0x9d/0x154
[   65.164028]                                          [<ffffffff>] 0xffffffff
[   65.164028]     hardirq-on-W at:
[   65.164028]                                          [<c014d9f8>] __lock_acquire+0x56e/0x746
[   65.164028]                                          [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                          [<c06c8ab8>] _spin_lock+0x23/0x53
[   65.164028]                                          [<c05dc509>] dev_deactivate+0x7e/0x15a
[   65.164028]                                          [<c05d7238>] __linkwatch_run_queue+0x112/0x141
[   65.164028]                                          [<c05d728c>] linkwatch_event+0x25/0x2c
[   65.164028]                                          [<c013ad65>] run_workqueue+0xc3/0x193
[   65.164028]                                          [<c013b81f>] worker_thread+0xbb/0xc7
[   65.164028]                                          [<c013dfcf>] kthread+0x40/0x69
[   65.164028]                                          [<c010417b>] kernel_thread_helper+0x7/0x10
[   65.164028]                                          [<ffffffff>] 0xffffffff
[   65.164028]   }
[   65.164028]   ... key      at: [<c132a944>] netdev_xmit_lock_key+0x8/0x1c8
[   65.164028]   -> (&np->lock){++..} ops: 0 {
[   65.164028]      initial-use  at:
[   65.164028]                                            [<c014da2e>] __lock_acquire+0x5a4/0x746
[   65.164028]                                            [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                            [<c06c8df5>] _spin_lock_irq+0x32/0x62
[   65.164028]                                            [<c06afc22>] nv_probe+0xb87/0x1b85
[   65.164028]                                            [<c03af7d6>] pci_device_probe+0x3e/0x5e
[   65.164028]                                            [<c043b7b0>] driver_probe_device+0x158/0x235
[   65.164028]                                            [<c043b8e1>] __driver_attach+0x54/0x76
[   65.164028]                                            [<c043ac57>] bus_for_each_dev+0x43/0x65
[   65.164028]                                            [<c043b4c3>] driver_attach+0x19/0x1b
[   65.164028]                                            [<c043b10b>] bus_add_driver+0xef/0x202
[   65.164028]                                            [<c043ba82>] driver_register+0x76/0xd2
[   65.164028]                                            [<c03afa04>] __pci_register_driver+0x58/0x84
[   65.164028]                                            [<c0a8e884>] init_nic+0x14/0x16
[   65.164028]                                            [<c0101152>] do_one_initcall+0x6a/0x17f
[   65.164028]                                            [<c0a6e4ee>] kernel_init+0xfc/0x14a
[   65.164028]                                            [<c010417b>] kernel_thread_helper+0x7/0x10
[   65.164028]                                            [<ffffffff>] 0xffffffff
[   65.164028]      in-hardirq-W at:
[   65.164028]                                            [<c014d983>] __lock_acquire+0x4f9/0x746
[   65.164028]                                            [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                            [<c06c8ab8>] _spin_lock+0x23/0x53
[   65.164028]                                            [<c04b2185>] nv_nic_irq_optimized+0x82/0x22d
[   65.164028]                                            [<c0166953>] handle_IRQ_event+0x1f/0x54
[   65.164028]                                            [<c0167f4b>] handle_fasteoi_irq+0xaa/0xb7
[   65.164028]                                            [<ffffffff>] 0xffffffff
[   65.164028]      in-softirq-W<3>INFO: RCU detected CPU 0 stall (t=4294911085/2500 jiffies)
[   75.156028] Pid: 2701, comm: distccd Not tainted 2.6.28-tip-03865-gb8c8c2c-dirty #13131
[   75.156028] Call Trace:
[   75.156028]  [<c016a06c>] __rcu_pending+0x50/0x182
[   75.156028]  [<c016a1bf>] rcu_pending+0x21/0x4c
[   75.156028]  [<c013544c>] update_process_times+0x30/0x53
[   75.156028]  [<c0147766>] tick_periodic+0x6b/0x6d
[   75.156028]  [<c0147786>] tick_handle_periodic+0x1e/0x60
[   75.156028]  [<c06c943c>] __irqentry_text_start+0x74/0x87
[   75.156028]  [<c0104061>] apic_timer_interrupt+0x2d/0x34
[   75.156028]  [<c0397971>] ? delay_tsc+0xe/0xb5
[   75.156028]  [<c03978c8>] __delay+0xe/0x10
[   75.156028]  [<c03a5687>] _raw_spin_lock+0xa0/0xf9
[   75.156028]  [<c06c8a84>] _spin_lock_nested+0x40/0x51
[   75.156028]  [<c060ba68>] tcp_v4_rcv+0x2da/0x6d2
[   75.156028]  [<c05f2bb5>] ? ip_local_deliver_finish+0x32/0x1c5
[   75.156028]  [<c05f2c95>] ip_local_deliver_finish+0x112/0x1c5
[   75.156028]  [<c05f309a>] ip_local_deliver+0x59/0x63
[   75.156028]  [<c05f2b6d>] ip_rcv_finish+0x285/0x29b
[   75.156028]  [<c05f3017>] ip_rcv+0x1f1/0x21b
[   75.156028]  [<c05cc853>] netif_receive_skb+0x2f2/0x325
[   75.156028]  [<c04b597f>] nv_napi_poll+0x3b9/0x4d2
[   75.156028]  [<c05cef7d>] ? net_rx_action+0x67/0x1f7
[   75.156028]  [<c05cefec>] net_rx_action+0xd6/0x1f7
[   75.156028]  [<c01314ec>] __do_softirq+0x9d/0x154
[   75.156028]  [<c013144f>] ? __do_softirq+0x0/0x154
[   75.156028]  <IRQ>  [<c0167ea1>] ? handle_fasteoi_irq+0x0/0xb7
[   75.156028]  [<c0131421>] ? irq_exit+0x49/0x77
[   75.156028]  [<c010593a>] ? do_IRQ+0xb5/0xcb
[   75.156028]  [<c0103f2c>] ? common_interrupt+0x2c/0x34
[   75.156028]  [<c0116355>] ? __ticket_spin_is_locked+0xb/0x16
[   75.156028]  [<c03a5486>] ? _raw_spin_unlock+0x2d/0x92
[   75.156028]  [<c06c8976>] ? _spin_unlock+0x22/0x25
[   75.156028]  [<c019bdce>] ? inode_add_bytes+0x5b/0x61
[   75.156028]  [<c01d935e>] ? ext3_new_blocks+0x7f/0x5b5
[   75.156028]  [<c06c7437>] ? mutex_lock_nested+0x2b9/0x2d5
[   75.156028]  [<c06c744b>] ? mutex_lock_nested+0x2cd/0x2d5
[   75.156028]  [<c01dc150>] ? ext3_get_blocks_handle+0x136/0x816
[   75.156028]  [<c01dc35a>] ? ext3_get_blocks_handle+0x340/0x816
[   75.156028]  [<c01dca32>] ? ext3_get_block+0x90/0xc5
[   75.156028]  [<c01b4306>] ? __block_prepare_write+0x152/0x32b
[   75.156028]  [<c01b4589>] ? block_write_begin+0x7e/0xdb
[   75.156028]  [<c01dc9a2>] ? ext3_get_block+0x0/0xc5
[   75.156028]  [<c01dddc7>] ? ext3_write_begin+0xcd/0x192
[   75.156028]  [<c01dc9a2>] ? ext3_get_block+0x0/0xc5
[   75.156028]  [<c0179cd6>] ? generic_file_buffered_write+0xce/0x204
[   75.156028]  [<c017a3f8>] ? __generic_file_aio_write_nolock+0x3f9/0x433
[   75.156028]  [<c014c042>] ? mark_held_locks+0x45/0x5c
[   75.156028]  [<c06c744b>] ? mutex_lock_nested+0x2cd/0x2d5
[   75.156028]  [<c017a49b>] ? generic_file_aio_write+0x69/0xbd
[   75.156028]  [<c01da3ff>] ? ext3_file_write+0x1f/0x90
[   75.156028]  [<c0198e09>] ? do_sync_write+0xc0/0xfe
[   75.156028]  [<c013e0a8>] ? autoremove_wake_function+0x0/0x35
[   75.156028]  [<c0149c1a>] ? lock_release_holdtime+0x8a/0x92
[   75.156028]  [<c01c5437>] ? dnotify_parent+0x5d/0x62
[   75.156028]  [<c03a54e7>] ? _raw_spin_unlock+0x8e/0x92
[   75.156028]  [<c0359dad>] ? security_file_permission+0x14/0x16
[   75.156028]  [<c0198d49>] ? do_sync_write+0x0/0xfe
[   75.156028]  [<c019958a>] ? vfs_write+0x91/0x138
[   75.156028]  [<c0199a95>] ? sys_write+0x40/0x65
[   75.156028]  [<c010388b>] ? sysenter_do_call+0x12/0x3f
[   65.164028]  at:
[   65.164028]                                                              [<c014d9a4>] __lock_acquire+0x51a/0x746
[   65.164028]                                                              [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                                              [<c06c8ab8>] _spin_lock+0x23/0x53
[   65.164028]                                                              [<c04b2185>] nv_nic_irq_optimized+0x82/0x22d
[   65.164028]                                                              [<c0166953>] handle_IRQ_event+0x1f/0x54
[   65.164028]                                                              [<c0167f4b>] handle_fasteoi_irq+0xaa/0xb7
[   65.164028]                                                              [<ffffffff>] 0xffffffff
[   65.164028]    }
[   65.164028]    ... key      at: [<c13263dc>] __key.35695+0x0/0x8
[   65.164028]    -> (lweventlist_lock){+...} ops: 0 {
[   65.164028]       initial-use  at:
[   65.164028]                                              [<c014da2e>] __lock_acquire+0x5a4/0x746
[   65.164028]                                              [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                              [<c06c8f2e>] _spin_lock_irqsave+0x3f/0x72
[   65.164028]                                              [<c05d703b>] linkwatch_add_event+0x15/0x36
[   65.164028]                                              [<c05d7110>] linkwatch_fire_event+0x2d/0x43
[   65.164028]                                              [<c05dc1f2>] netif_carrier_off+0x26/0x28
[   65.164028]                                              [<c0469f41>] bond_create+0x297/0x2fd
[   65.164028]                                              [<c0a8e09c>] bonding_init+0x720/0x7a6
[   65.164028]                                              [<c0101152>] do_one_initcall+0x6a/0x17f
[   65.164028]                                              [<c0a6e4ee>] kernel_init+0xfc/0x14a
[   65.164028]                                              [<c010417b>] kernel_thread_helper+0x7/0x10
[   65.164028]                                              [<ffffffff>] 0xffffffff
[   65.164028]       in-hardirq-W at:
[   65.164028]                                              [<c014d983>] __lock_acquire+0x4f9/0x746
[   65.164028]                                              [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                              [<c06c8f2e>] _spin_lock_irqsave+0x3f/0x72
[   65.164028]                                              [<c05d703b>] linkwatch_add_event+0x15/0x36
[   65.164028]                                              [<c05d7110>] linkwatch_fire_event+0x2d/0x43
[   65.164028]                                              [<c05dc21b>] netif_carrier_on+0x27/0x37
[   65.164028]                                              [<c04b0fed>] nv_linkchange+0x21/0x5b
[   65.164028]                                              [<c04b1057>] nv_link_irq+0x30/0x33
[   65.164028]                                              [<c04b2201>] nv_nic_irq_optimized+0xfe/0x22d
[   65.164028]                                              [<c0166953>] handle_IRQ_event+0x1f/0x54
[   65.164028]                                              [<c0167f4b>] handle_fasteoi_irq+0xaa/0xb7
[   65.164028]                                              [<ffffffff>] 0xffffffff
[   65.164028]     }
[   65.164028]     ... key      at: [<c0a28c10>] lweventlist_lock+0x10/0x24
[   65.164028]    ... acquired at:
[   65.164028]    [<c014d1b5>] validate_chain+0x8f9/0xbce
[   65.164028]    [<c014db6a>] __lock_acquire+0x6e0/0x746
[   65.164028]    [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]    [<c06c8f2e>] _spin_lock_irqsave+0x3f/0x72
[   65.164028]    [<c05d703b>] linkwatch_add_event+0x15/0x36
[   65.164028]    [<c05d7110>] linkwatch_fire_event+0x2d/0x43
[   65.164028]    [<c05dc1f2>] netif_carrier_off+0x26/0x28
[   65.164028]    [<c04b19f5>] nv_open+0x4b4/0x518
[   65.164028]    [<c05cf66c>] dev_open+0x6c/0xa1
[   65.164028]    [<c05cd684>] dev_change_flags+0x9b/0x149
[   65.164028]    [<c06145da>] devinet_ioctl+0x215/0x4e3
[   65.164028]    [<c0615318>] inet_ioctl+0x93/0xac
[   65.164028]    [<c05c17ea>] sock_ioctl+0x1cc/0x1f0
[   65.164028]    [<c01a39e9>] vfs_ioctl+0x27/0x6c
[   65.164028]    [<c01a3ebf>] do_vfs_ioctl+0x3c3/0x3f5
[   65.164028]    [<c01a3f36>] sys_ioctl+0x45/0x5f
[   65.164028]    [<c010388b>] sysenter_do_call+0x12/0x3f
[   65.164028]    [<ffffffff>] 0xffffffff
[   65.164028] 
[   65.164028]    -> (&cwq->lock){++..} ops: 0 {
[   65.164028]       initial-use  at:
[   65.164028]                                              [<c014da2e>] __lock_acquire+0x5a4/0x746
[   65.164028]                                              [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                              [<c06c8f2e>] _spin_lock_irqsave+0x3f/0x72
[   65.164028]                                              [<c013b5d1>] __queue_work+0x14/0x30
[   65.164028]                                              [<c013b650>] queue_work_on+0x3a/0x46
[   65.164028]                                              [<c013b710>] queue_work+0x1a/0x1d
[   65.164028]                                              [<c013a8a0>] call_usermodehelper_exec+0x83/0xd0
[   65.164028]                                              [<c0393cf2>] kobject_uevent_env+0x489/0x4c5
[   65.164028]                                              [<c0393d38>] kobject_uevent+0xa/0xc
[   65.164028]                                              [<c03932c0>] kset_register+0x2e/0x34
[   65.164028]                                              [<c043ae7e>] bus_register+0x93/0x231
[   65.164028]                                              [<c0a89528>] platform_bus_init+0x1e/0x33
[   65.164028]                                              [<c0a895c0>] driver_init+0x1c/0x28
[   65.164028]                                              [<c0a6e4db>] kernel_init+0xe9/0x14a
[   65.164028]                                              [<c010417b>] kernel_thread_helper+0x7/0x10
[   65.164028]                                              [<ffffffff>] 0xffffffff
[   65.164028]       in-hardirq-W at:
[   65.164028]                                              [<c014d983>] __lock_acquire+0x4f9/0x746
[   65.164028]                                              [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                              [<c06c8f2e>] _spin_lock_irqsave+0x3f/0x72
[   65.164028]                                              [<c013b5d1>] __queue_work+0x14/0x30
[   65.164028]                                              [<c013b650>] queue_work_on+0x3a/0x46
[   65.164028]                                              [<c013b710>] queue_work+0x1a/0x1d
[   65.164028]                                              [<c013b727>] schedule_work+0x14/0x16
[   65.164028]                                              [<c044142d>] schedule_bh+0x17/0x19
[   65.164028]                                              [<c04415a7>] floppy_interrupt+0x15a/0x171
[   65.164028]                                              [<c044385a>] floppy_hardint+0x22/0xe1
[   65.164028]                                              [<c0166953>] handle_IRQ_event+0x1f/0x54
[   65.164028]                                              [<c0167ffe>] handle_edge_irq+0xa6/0x10d
[   65.164028]                                              [<ffffffff>] 0xffffffff
[   65.164028]       in-softirq-W at:
[   65.164028]                                              [<c014d9a4>] __lock_acquire+0x51a/0x746
[   65.164028]                                              [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                              [<c06c8f2e>] _spin_lock_irqsave+0x3f/0x72
[   65.164028]                                              [<c013b5d1>] __queue_work+0x14/0x30
[   65.164028]                                              [<c013b613>] delayed_work_timer_fn+0x26/0x29
[   65.164028]                                              [<c0134d2e>] run_timer_softirq+0x144/0x1a4
[   65.164028]                                              [<c01314ec>] __do_softirq+0x9d/0x154
[   65.164028]                                              [<ffffffff>] 0xffffffff
[   65.164028]     }
[   65.164028]     ... key      at: [<c0e2fc0c>] __key.24394+0x0/0x8
[   65.164028]     ... acquired at:
[   65.164028]    [<c014d1b5>] validate_chain+0x8f9/0xbce
[   65.164028]    [<c014db6a>] __lock_acquire+0x6e0/0x746
[   65.164028]    [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]    [<c06c8f2e>] _spin_lock_irqsave+0x3f/0x72
[   65.164028]    [<c011fd42>] __wake_up+0x1a/0x40
[   65.164028]    [<c013aea2>] insert_work+0x48/0x50
[   65.164028]    [<c013b5df>] __queue_work+0x22/0x30
[   65.164028]    [<c013b650>] queue_work_on+0x3a/0x46
[   65.164028]    [<c013b710>] queue_work+0x1a/0x1d
[   65.164028]    [<c013a8a0>] call_usermodehelper_exec+0x83/0xd0
[   65.164028]    [<c0393cf2>] kobject_uevent_env+0x489/0x4c5
[   65.164028]    [<c0393d38>] kobject_uevent+0xa/0xc
[   65.164028]    [<c03932c0>] kset_register+0x2e/0x34
[   65.164028]    [<c043ae7e>] bus_register+0x93/0x231
[   65.164028]    [<c0a89528>] platform_bus_init+0x1e/0x33
[   65.164028]    [<c0a895c0>] driver_init+0x1c/0x28
[   65.164028]    [<c0a6e4db>] kernel_init+0xe9/0x14a
[   65.164028]    [<c010417b>] kernel_thread_helper+0x7/0x10
[   65.164028]    [<ffffffff>] 0xffffffff
[   65.164028] 
[   65.164028]    ... acquired at:
[   65.164028]    [<c014d1b5>] validate_chain+0x8f9/0xbce
[   65.164028]    [<c014db6a>] __lock_acquire+0x6e0/0x746
[   65.164028]    [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]    [<c06c8f2e>] _spin_lock_irqsave+0x3f/0x72
[   65.164028]    [<c013b5d1>] __queue_work+0x14/0x30
[   65.164028]    [<c013b650>] queue_work_on+0x3a/0x46
[   65.164028]    [<c013b710>] queue_work+0x1a/0x1d
[   65.164028]    [<c013b73a>] queue_delayed_work+0x11/0x23
[   65.164028]    [<c013b762>] schedule_delayed_work+0x16/0x18
[   65.164028]    [<c05d70aa>] linkwatch_schedule_work+0x4e/0x87
[   65.164028]    [<c05d7122>] linkwatch_fire_event+0x3f/0x43
[   65.164028]    [<c05dc1f2>] netif_carrier_off+0x26/0x28
[   65.164028]    [<c04b19f5>] nv_open+0x4b4/0x518
[   65.164028]    [<c05cf66c>] dev_open+0x6c/0xa1
[   65.164028]    [<c05cd684>] dev_change_flags+0x9b/0x149
[   65.164028]    [<c06145da>] devinet_ioctl+0x215/0x4e3
[   65.164028]    [<c0615318>] inet_ioctl+0x93/0xac
[   65.164028]    [<c05c17ea>] sock_ioctl+0x1cc/0x1f0
[   65.164028]    [<c01a39e9>] vfs_ioctl+0x27/0x6c
[   65.164028]    [<c01a3ebf>] do_vfs_ioctl+0x3c3/0x3f5
[   65.164028]    [<c01a3f36>] sys_ioctl+0x45/0x5f
[   65.164028]    [<c010388b>] sysenter_do_call+0x12/0x3f
[   65.164028]    [<ffffffff>] 0xffffffff
[   65.164028] 
[   65.164028]    ... acquired at:
[   65.164028]    [<c014d1b5>] validate_chain+0x8f9/0xbce
[   65.164028]    [<c014db6a>] __lock_acquire+0x6e0/0x746
[   65.164028]    [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]    [<c06c8f2e>] _spin_lock_irqsave+0x3f/0x72
[   65.164028]    [<c01351eb>] lock_timer_base+0x24/0x43
[   65.164028]    [<c0135312>] __mod_timer+0x2f/0xc8
[   65.164028]    [<c0135585>] mod_timer+0x38/0x3c
[   65.164028]    [<c04b1a39>] nv_open+0x4f8/0x518
[   65.164028]    [<c05cf66c>] dev_open+0x6c/0xa1
[   65.164028]    [<c05cd684>] dev_change_flags+0x9b/0x149
[   65.164028]    [<c06145da>] devinet_ioctl+0x215/0x4e3
[   65.164028]    [<c0615318>] inet_ioctl+0x93/0xac
[   65.164028]    [<c05c17ea>] sock_ioctl+0x1cc/0x1f0
[   65.164028]    [<c01a39e9>] vfs_ioctl+0x27/0x6c
[   65.164028]    [<c01a3ebf>] do_vfs_ioctl+0x3c3/0x3f5
[   65.164028]    [<c01a3f36>] sys_ioctl+0x45/0x5f
[   65.164028]    [<c010388b>] sysenter_do_call+0x12/0x3f
[   65.164028]    [<ffffffff>] 0xffffffff
[   65.164028] 
[   65.164028]   ... acquired at:
[   65.164028]    [<c014d1b5>] validate_chain+0x8f9/0xbce
[   65.164028]    [<c014db6a>] __lock_acquire+0x6e0/0x746
[   65.164028]    [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]    [<c06c8f2e>] _spin_lock_irqsave+0x3f/0x72
[   65.164028]    [<c04b3dfb>] nv_start_xmit_optimized+0x36a/0x411
[   65.164028]    [<c05cd1e2>] dev_hard_start_xmit+0x235/0x299
[   65.164028]    [<c05dc2f7>] __qdisc_run+0xcc/0x1ad
[   65.164028]    [<c05cfb37>] dev_queue_xmit+0x341/0x482
[   65.164028]    [<c0630943>] packet_sendmsg+0x1c1/0x20a
[   65.164028]    [<c05c1e4e>] sock_sendmsg+0xcf/0xe6
[   65.164028]    [<c05c26d7>] sys_sendto+0xa9/0xc8
[   65.164028]    [<c05c2e16>] sys_socketcall+0xf5/0x18a
[   65.164028]    [<c010388b>] sysenter_do_call+0x12/0x3f
[   65.164028]    [<ffffffff>] 0xffffffff
[   65.164028] 
[   65.164028]  ... acquired at:
[   65.164028]    [<c014d1b5>] validate_chain+0x8f9/0xbce
[   65.164028]    [<c014db6a>] __lock_acquire+0x6e0/0x746
[   65.164028]    [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]    [<c06c8ab8>] _spin_lock+0x23/0x53
[   65.164028]    [<c05dc2dc>] __qdisc_run+0xb1/0x1ad
[   65.164028]    [<c05cfb37>] dev_queue_xmit+0x341/0x482
[   65.164028]    [<c05f629e>] ip_finish_output+0x1e0/0x218
[   65.164028]    [<c05f657e>] ip_output+0x77/0x7c
[   65.164028]    [<c05f5de9>] ip_local_out+0x1d/0x20
[   65.164028]    [<c05f68ce>] ip_queue_xmit+0x2b6/0x2f7
[   65.164028]    [<c0605e8a>] tcp_transmit_skb+0x5ca/0x604
[   65.164028]    [<c0605ff0>] tcp_send_ack+0xb3/0xbb
[   65.164028]    [<c0608794>] tcp_delack_timer+0x15a/0x1b1
[   65.164028]    [<c0134d2e>] run_timer_softirq+0x144/0x1a4
[   65.164028]    [<c01314ec>] __do_softirq+0x9d/0x154
[   65.164028]    [<ffffffff>] 0xffffffff
[   65.164028] 
[   65.164028]  -> (rt_peer_lock){-+..} ops: 0 {
[   65.164028]     initial-use  at:
[   65.164028]                                          [<c014da2e>] __lock_acquire+0x5a4/0x746
[   65.164028]                                          [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                          [<c06c8b10>] _spin_lock_bh+0x28/0x58
[   65.164028]                                          [<c05f0f43>] rt_bind_peer+0x23/0x4d
[   65.164028]                                          [<c05f0ff7>] __ip_select_ident+0x2e/0xb9
[   65.164028]                                          [<c05f6000>] ip_push_pending_frames+0x214/0x2d2
[   65.164028]                                          [<c06121e3>] icmp_push_reply+0xc9/0xd4
[   65.164028]                                          [<c06123aa>] icmp_reply+0x141/0x15d
[   65.164028]                                          [<c06127f3>] icmp_echo+0x4c/0x4e
[   65.164028]                                          [<c0612606>] icmp_rcv+0x1d5/0x209
[   65.164028]                                          [<c05f2c95>] ip_local_deliver_finish+0x112/0x1c5
[   65.164028]                                          [<c05f309a>] ip_local_deliver+0x59/0x63
[   65.164028]                                          [<c05f2b6d>] ip_rcv_finish+0x285/0x29b
[   65.164028]                                          [<c05f3017>] ip_rcv+0x1f1/0x21b
[   65.164028]                                          [<c05cc853>] netif_receive_skb+0x2f2/0x325
[   65.164028]                                          [<c04b597f>] nv_napi_poll+0x3b9/0x4d2
[   65.164028]                                          [<c05cefec>] net_rx_action+0xd6/0x1f7
[   65.164028]                                          [<c01314ec>] __do_softirq+0x9d/0x154
[   65.164028]                                          [<ffffffff>] 0xffffffff
[   65.164028]     in-softirq-W at:
[   65.164028]                                          [<c014d9a4>] __lock_acquire+0x51a/0x746
[   65.164028]                                          [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                          [<c06c8b10>] _spin_lock_bh+0x28/0x58
[   65.164028]                                          [<c05f0f43>] rt_bind_peer+0x23/0x4d
[   65.164028]                                          [<c05f0ff7>] __ip_select_ident+0x2e/0xb9
[   65.164028]                                          [<c05f6000>] ip_push_pending_frames+0x214/0x2d2
[   65.164028]                                          [<c06121e3>] icmp_push_reply+0xc9/0xd4
[   65.164028]                                          [<c06123aa>] icmp_reply+0x141/0x15d
[   65.164028]                                          [<c06127f3>] icmp_echo+0x4c/0x4e
[   65.164028]                                          [<c0612606>] icmp_rcv+0x1d5/0x209
[   65.164028]                                          [<c05f2c95>] ip_local_deliver_finish+0x112/0x1c5
[   65.164028]                                          [<c05f309a>] ip_local_deliver+0x59/0x63
[   65.164028]                                          [<c05f2b6d>] ip_rcv_finish+0x285/0x29b
[   65.164028]                                          [<c05f3017>] ip_rcv+0x1f1/0x21b
[   65.164028]                                          [<c05cc853>] netif_receive_skb+0x2f2/0x325
[   65.164028]                                          [<c04b597f>] nv_napi_poll+0x3b9/0x4d2
[   65.164028]                                          [<c05cefec>] net_rx_action+0xd6/0x1f7
[   65.164028]                                          [<c01314ec>] __do_softirq+0x9d/0x154
[   65.164028]                                          [<ffffffff>] 0xffffffff
[   65.164028]     hardirq-on-W at:
[   65.164028]                                          [<c014d9f8>] __lock_acquire+0x56e/0x746
[   65.164028]                                          [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                          [<c06c8b10>] _spin_lock_bh+0x28/0x58
[   65.164028]                                          [<c05f0f43>] rt_bind_peer+0x23/0x4d
[   65.164028]                                          [<c05f0ff7>] __ip_select_ident+0x2e/0xb9
[   65.164028]                                          [<c05f6000>] ip_push_pending_frames+0x214/0x2d2
[   65.164028]                                          [<c06121e3>] icmp_push_reply+0xc9/0xd4
[   65.164028]                                          [<c06123aa>] icmp_reply+0x141/0x15d
[   65.164028]                                          [<c06127f3>] icmp_echo+0x4c/0x4e
[   65.164028]                                          [<c0612606>] icmp_rcv+0x1d5/0x209
[   65.164028]                                          [<c05f2c95>] ip_local_deliver_finish+0x112/0x1c5
[   65.164028]                                          [<c05f309a>] ip_local_deliver+0x59/0x63
[   65.164028]                                          [<c05f2b6d>] ip_rcv_finish+0x285/0x29b
[   65.164028]                                          [<c05f3017>] ip_rcv+0x1f1/0x21b
[   65.164028]                                          [<c05cc853>] netif_receive_skb+0x2f2/0x325
[   65.164028]                                          [<c04b597f>] nv_napi_poll+0x3b9/0x4d2
[   65.164028]                                          [<c05cefec>] net_rx_action+0xd6/0x1f7
[   65.164028]                                          [<c01314ec>] __do_softirq+0x9d/0x154
[   65.164028]                                          [<ffffffff>] 0xffffffff
[   65.164028]   }
[   65.164028]   ... key      at: [<c0a2a500>] rt_peer_lock.45038+0x10/0x24
[   65.164028]  ... acquired at:
[   65.164028]    [<c014d1b5>] validate_chain+0x8f9/0xbce
[   65.164028]    [<c014db6a>] __lock_acquire+0x6e0/0x746
[   65.164028]    [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]    [<c06c8b10>] _spin_lock_bh+0x28/0x58
[   65.164028]    [<c05f0f43>] rt_bind_peer+0x23/0x4d
[   65.164028]    [<c05f0ff7>] __ip_select_ident+0x2e/0xb9
[   65.164028]    [<c05f6000>] ip_push_pending_frames+0x214/0x2d2
[   65.164028]    [<c06121e3>] icmp_push_reply+0xc9/0xd4
[   65.164028]    [<c06123aa>] icmp_reply+0x141/0x15d
[   65.164028]    [<c06127f3>] icmp_echo+0x4c/0x4e
[   65.164028]    [<c0612606>] icmp_rcv+0x1d5/0x209
[   65.164028]    [<c05f2c95>] ip_local_deliver_finish+0x112/0x1c5
[   65.164028]    [<c05f309a>] ip_local_deliver+0x59/0x63
[   65.164028]    [<c05f2b6d>] ip_rcv_finish+0x285/0x29b
[   65.164028]    [<c05f3017>] ip_rcv+0x1f1/0x21b
[   65.164028]    [<c05cc853>] netif_receive_skb+0x2f2/0x325
[   65.164028]    [<c04b597f>] nv_napi_poll+0x3b9/0x4d2
[   65.164028]    [<c05cefec>] net_rx_action+0xd6/0x1f7
[   65.164028]    [<c01314ec>] __do_softirq+0x9d/0x154
[   65.164028]    [<ffffffff>] 0xffffffff
[   65.164028] 
[   65.164028]  -> (inet_peer_idlock){-+..} ops: 0 {
[   65.164028]     initial-use  at:
[   65.164028]                                          [<c014da2e>] __lock_acquire+0x5a4/0x746
[   65.164028]                                          [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                          [<c06c8b10>] _spin_lock_bh+0x28/0x58
[   65.164028]                                          [<c05f100b>] __ip_select_ident+0x42/0xb9
[   65.164028]                                          [<c05f6000>] ip_push_pending_frames+0x214/0x2d2
[   65.164028]                                          [<c06121e3>] icmp_push_reply+0xc9/0xd4
[   65.164028]                                          [<c06123aa>] icmp_reply+0x141/0x15d
[   65.164028]                                          [<c06127f3>] icmp_echo+0x4c/0x4e
[   65.164028]                                          [<c0612606>] icmp_rcv+0x1d5/0x209
[   65.164028]                                          [<c05f2c95>] ip_local_deliver_finish+0x112/0x1c5
[   65.164028]                                          [<c05f309a>] ip_local_deliver+0x59/0x63
[   65.164028]                                          [<c05f2b6d>] ip_rcv_finish+0x285/0x29b
[   65.164028]                                          [<c05f3017>] ip_rcv+0x1f1/0x21b
[   65.164028]                                          [<c05cc853>] netif_receive_skb+0x2f2/0x325
[   65.164028]                                          [<c04b597f>] nv_napi_poll+0x3b9/0x4d2
[   65.164028]                                          [<c05cefec>] net_rx_action+0xd6/0x1f7
[   65.164028]                                          [<c01314ec>] __do_softirq+0x9d/0x154
[   65.164028]                                          [<ffffffff>] 0xffffffff
[   65.164028]     in-softirq-W at:
[   65.164028]                                          [<c014d9a4>] __lock_acquire+0x51a/0x746
[   65.164028]                                          [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                          [<c06c8b10>] _spin_lock_bh+0x28/0x58
[   65.164028]                                          [<c05f100b>] __ip_select_ident+0x42/0xb9
[   65.164028]                                          [<c05f6000>] ip_push_pending_frames+0x214/0x2d2
[   65.164028]                                          [<c06121e3>] icmp_push_reply+0xc9/0xd4
[   65.164028]                                          [<c06123aa>] icmp_reply+0x141/0x15d
[   65.164028]                                          [<c06127f3>] icmp_echo+0x4c/0x4e
[   65.164028]                                          [<c0612606>] icmp_rcv+0x1d5/0x209
[   65.164028]                                          [<c05f2c95>] ip_local_deliver_finish+0x112/0x1c5
[   65.164028]                                          [<c05f309a>] ip_local_deliver+0x59/0x63
[   65.164028]                                          [<c05f2b6d>] ip_rcv_finish+0x285/0x29b
[   65.164028]                                          [<c05f3017>] ip_rcv+0x1f1/0x21b
[   65.164028]                                          [<c05cc853>] netif_receive_skb+0x2f2/0x325
[   65.164028]                                          [<c04b597f>] nv_napi_poll+0x3b9/0x4d2
[   65.164028]                                          [<c05cefec>] net_rx_action+0xd6/0x1f7
[   65.164028]                                          [<c01314ec>] __do_softirq+0x9d/0x154
[   65.164028]                                          [<ffffffff>] 0xffffffff
[   65.164028]     hardirq-on-W at:
[   65.164028]                                          [<c014d9f8>] __lock_acquire+0x56e/0x746
[   65.164028]                                          [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                          [<c06c8b10>] _spin_lock_bh+0x28/0x58
[   65.164028]                                          [<c05f100b>] __ip_select_ident+0x42/0xb9
[   65.164028]                                          [<c05f6000>] ip_push_pending_frames+0x214/0x2d2
[   65.164028]                                          [<c06121e3>] icmp_push_reply+0xc9/0xd4
[   65.164028]                                          [<c06123aa>] icmp_reply+0x141/0x15d
[   65.164028]                                          [<c06127f3>] icmp_echo+0x4c/0x4e
[   65.164028]                                          [<c0612606>] icmp_rcv+0x1d5/0x209
[   65.164028]                                          [<c05f2c95>] ip_local_deliver_finish+0x112/0x1c5
[   65.164028]                                          [<c05f309a>] ip_local_deliver+0x59/0x63
[   65.164028]                                          [<c05f2b6d>] ip_rcv_finish+0x285/0x29b
[   65.164028]                                          [<c05f3017>] ip_rcv+0x1f1/0x21b
[   65.164028]                                          [<c05cc853>] netif_receive_skb+0x2f2/0x325
[   65.164028]                                          [<c04b597f>] nv_napi_poll+0x3b9/0x4d2
[   65.164028]                                          [<c05cefec>] net_rx_action+0xd6/0x1f7
[   65.164028]                                          [<c01314ec>] __do_softirq+0x9d/0x154
[   65.164028]                                          [<ffffffff>] 0xffffffff
[   65.164028]   }
[   65.164028]   ... key      at: [<c0a2a810>] inet_peer_idlock+0x10/0x24
[   65.164028]  ... acquired at:
[   65.164028]    [<c014d1b5>] validate_chain+0x8f9/0xbce
[   65.164028]    [<c014db6a>] __lock_acquire+0x6e0/0x746
[   65.164028]    [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]    [<c06c8b10>] _spin_lock_bh+0x28/0x58
[   65.164028]    [<c05f100b>] __ip_select_ident+0x42/0xb9
[   65.164028]    [<c05f6000>] ip_push_pending_frames+0x214/0x2d2
[   65.164028]    [<c06121e3>] icmp_push_reply+0xc9/0xd4
[   65.164028]    [<c06123aa>] icmp_reply+0x141/0x15d
[   65.164028]    [<c06127f3>] icmp_echo+0x4c/0x4e
[   65.164028]    [<c0612606>] icmp_rcv+0x1d5/0x209
[   65.164028]    [<c05f2c95>] ip_local_deliver_finish+0x112/0x1c5
[   65.164028]    [<c05f309a>] ip_local_deliver+0x59/0x63
[   65.164028]    [<c05f2b6d>] ip_rcv_finish+0x285/0x29b
[   65.164028]    [<c05f3017>] ip_rcv+0x1f1/0x21b
[   65.164028]    [<c05cc853>] netif_receive_skb+0x2f2/0x325
[   65.164028]    [<c04b597f>] nv_napi_poll+0x3b9/0x4d2
[   65.164028]    [<c05cefec>] net_rx_action+0xd6/0x1f7
[   65.164028]    [<c01314ec>] __do_softirq+0x9d/0x154
[   65.164028]    [<ffffffff>] 0xffffffff
[   65.164028] 
[   65.164028]  ... acquired at:
[   65.164028]    [<c014d1b5>] validate_chain+0x8f9/0xbce
[   65.164028]    [<c014db6a>] __lock_acquire+0x6e0/0x746
[   65.164028]    [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]    [<c06c8ab8>] _spin_lock+0x23/0x53
[   65.164028]    [<c0193510>] deactivate_slab+0x71/0xd6
[   65.164028]    [<c0193ac0>] __slab_alloc+0x91/0x441
[   65.164028]    [<c0193ed3>] kmem_cache_alloc+0x63/0xd1
[   65.164028]    [<c05c7613>] __alloc_skb+0x2e/0x10c
[   65.164028]    [<c0605f67>] tcp_send_ack+0x2a/0xbb
[   65.164028]    [<c0608794>] tcp_delack_timer+0x15a/0x1b1
[   65.164028]    [<c0134d2e>] run_timer_softirq+0x144/0x1a4
[   65.164028]    [<c01314ec>] __do_softirq+0x9d/0x154
[   65.164028]    [<ffffffff>] 0xffffffff
[   65.164028] 
[   65.164028] 
[   65.164028] the soft-irq-unsafe lock's dependencies:
[   65.164028] -> (&fbc->lock){--..} ops: 0 {
[   65.164028]    initial-use  at:
[   65.164028]                                        [<c014da2e>] __lock_acquire+0x5a4/0x746
[   65.164028]                                        [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                        [<c06c8ab8>] _spin_lock+0x23/0x53
[   65.164028]                                        [<c03a94d4>] __percpu_counter_add+0x52/0x7a
[   65.164028]                                        [<c019a133>] get_empty_filp+0x9f/0x1b0
[   65.164028]                                        [<c01a2612>] path_lookup_open+0x23/0x7a
[   65.164028]                                        [<c01a2710>] do_filp_open+0xa7/0x67e
[   65.164028]                                        [<c019777c>] do_sys_open+0x47/0xbc
[   65.164028]                                        [<c019783d>] sys_open+0x23/0x2b
[   65.164028]                                        [<c010388b>] sysenter_do_call+0x12/0x3f
[   65.164028]                                        [<ffffffff>] 0xffffffff
[   65.164028]    softirq-on-W at:
[   65.164028]                                        [<c014da19>] __lock_acquire+0x58f/0x746
[   65.164028]                                        [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                        [<c06c8ab8>] _spin_lock+0x23/0x53
[   65.164028]                                        [<c03a94d4>] __percpu_counter_add+0x52/0x7a
[   65.164028]                                        [<c019a133>] get_empty_filp+0x9f/0x1b0
[   65.164028]                                        [<c01a2612>] path_lookup_open+0x23/0x7a
[   65.164028]                                        [<c01a2710>] do_filp_open+0xa7/0x67e
[   65.164028]                                        [<c019777c>] do_sys_open+0x47/0xbc
[   65.164028]                                        [<c019783d>] sys_open+0x23/0x2b
[   65.164028]                                        [<c010388b>] sysenter_do_call+0x12/0x3f
[   65.164028]                                        [<ffffffff>] 0xffffffff
[   65.164028]    hardirq-on-W at:
[   65.164028]                                        [<c014d9f8>] __lock_acquire+0x56e/0x746
[   65.164028]                                        [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]                                        [<c06c8ab8>] _spin_lock+0x23/0x53
[   65.164028]                                        [<c03a94d4>] __percpu_counter_add+0x52/0x7a
[   65.164028]                                        [<c019a133>] get_empty_filp+0x9f/0x1b0
[   65.164028]                                        [<c01a2612>] path_lookup_open+0x23/0x7a
[   65.164028]                                        [<c01a2710>] do_filp_open+0xa7/0x67e
[   65.164028]                                        [<c019777c>] do_sys_open+0x47/0xbc
[   65.164028]                                        [<c019783d>] sys_open+0x23/0x2b
[   65.164028]                                        [<c010388b>] sysenter_do_call+0x12/0x3f
[   65.164028]                                        [<ffffffff>] 0xffffffff
[   65.164028]  }
[   65.164028]  ... key      at: [<c131d2dc>] __key.12530+0x0/0x8
[   65.164028] 
[   65.164028] stack backtrace:
[   65.164028] Pid: 2856, comm: ssh Not tainted 2.6.28-tip-03865-gb8c8c2c-dirty #13131
[   65.164028] Call Trace:
[   65.164028]  [<c014c7f5>] check_usage+0x345/0x356
[   65.164028]  [<c014cf3b>] validate_chain+0x67f/0xbce
[   65.164028]  [<c014db6a>] __lock_acquire+0x6e0/0x746
[   65.164028]  [<c014dc2b>] lock_acquire+0x5b/0x81
[   65.164028]  [<c03a94d4>] ? __percpu_counter_add+0x52/0x7a
[   65.164028]  [<c06c8ab8>] _spin_lock+0x23/0x53
[   65.164028]  [<c03a94d4>] ? __percpu_counter_add+0x52/0x7a
[   65.164028]  [<c03a94d4>] __percpu_counter_add+0x52/0x7a
[   65.164028]  [<c05fd421>] tcp_close+0x1b2/0x335
[   65.164028]  [<c0615b42>] inet_release+0x47/0x4d
[   65.164028]  [<c05c20be>] sock_release+0x15/0x58
[   65.164028]  [<c05c2510>] sock_close+0x21/0x25
[   65.164028]  [<c0199f08>] __fput+0xcf/0x1a2
[   65.164028]  [<c019a2da>] fput+0x1c/0x1e
[   65.164028]  [<c0197685>] filp_close+0x55/0x5f
[   65.164028]  [<c01976fc>] sys_close+0x6d/0xa6
[   65.164028]  [<c010388b>] sysenter_do_call+0x12/0x3f

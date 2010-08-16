From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [LOCKDEP BUG][2.6.36-rc1] xt_info_wrlock?
Date: Mon, 16 Aug 2010 13:55:01 -0400
Message-ID: <1281981301.3268.110.camel@gandalf.stny.rr.com>
References: <1281978469.3268.55.camel@gandalf.stny.rr.com>
	 <1281979893.2524.54.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, Ingo Molnar <mingo@elte.hu>,
	Peter Zijlstra <peterz@infradead.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1281979893.2524.54.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2010-08-16 at 19:31 +0200, Eric Dumazet wrote:
> Le lundi 16 ao=FBt 2010 =E0 13:07 -0400, Steven Rostedt a =E9crit :
> > Hi, I hit this when booting 2.6.36-rc1:
> >=20
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > [ INFO: inconsistent lock state ]
> > 2.6.36-rc1 #2937
> > ---------------------------------
> > inconsistent {SOFTIRQ-ON-W} -> {IN-SOFTIRQ-W} usage.
> > ifup-eth/3288 [HC0[0]:SC1[2]:HE1:SE0] takes:
> >  (&(&lock->lock)->rlock){+.?...}, at: [<ffffffffa0166eef>] ip6t_do_=
table+0x8a/0x3f1 [ip6_tables]
> > {SOFTIRQ-ON-W} state was registered at:
> >   [<ffffffff8107b08e>] __lock_acquire+0x756/0x93c
> >   [<ffffffff8107b374>] lock_acquire+0x100/0x12d
> >   [<ffffffff813f4ec3>] _raw_spin_lock+0x40/0x73
> >   [<ffffffffa01664b1>] get_counters+0xb2/0x168 [ip6_tables]
> >   [<ffffffffa01665a3>] alloc_counters+0x3c/0x47 [ip6_tables]
> >   [<ffffffffa0167a7b>] do_ip6t_get_ctl+0x10c/0x363 [ip6_tables]
> >   [<ffffffff813863a2>] nf_sockopt+0x5a/0x86
> >   [<ffffffff813863e6>] nf_getsockopt+0x18/0x1a
> >   [<ffffffffa034c1ff>] ipv6_getsockopt+0x84/0xba [ipv6]
> >   [<ffffffffa0353289>] rawv6_getsockopt+0x42/0x4b [ipv6]
> >   [<ffffffff81355571>] sock_common_getsockopt+0x14/0x16
> >   [<ffffffff813525bb>] sys_getsockopt+0x7a/0x9b
> >   [<ffffffff8100ad32>] system_call_fastpath+0x16/0x1b
> > irq event stamp: 40
> > hardirqs last  enabled at (40): [<ffffffff813f5ad5>] _raw_spin_unlo=
ck_irqrestore+0x47/0x79
> > hardirqs last disabled at (39): [<ffffffff813f5036>] _raw_spin_lock=
_irqsave+0x2b/0x92
> > softirqs last  enabled at (0): [<ffffffff8104975a>] copy_process+0x=
40e/0x11ce
> > softirqs last disabled at (9): [<ffffffff8100bc9c>] call_softirq+0x=
1c/0x30
> >=20
> > other info that might help us debug this:
> > 3 locks held by ifup-eth/3288:
> >  #0:  (&idev->mc_ifc_timer){+.-...}, at: [<ffffffff8105841c>] run_t=
imer_softirq+0x1f5/0x3e6
> >  #1:  (rcu_read_lock){.+.+..}, at: [<ffffffffa03578ca>] mld_sendpac=
k+0x0/0x3ab [ipv6]
> >  #2:  (rcu_read_lock){.+.+..}, at: [<ffffffff81384f83>] nf_hook_slo=
w+0x0/0x119
> >=20
> > stack backtrace:
> > Pid: 3288, comm: ifup-eth Not tainted 2.6.36-rc1 #2937
> > Call Trace:
> >  <IRQ>  [<ffffffff81077ae6>] print_usage_bug+0x1a4/0x1b5
> >  [<ffffffff810164fa>] ? save_stack_trace+0x2f/0x4c
> >  [<ffffffff8106cd0c>] ? local_clock+0x40/0x59
> >  [<ffffffff810786b6>] ? check_usage_forwards+0x0/0xcf
> >  [<ffffffff81077de1>] mark_lock+0x2ea/0x51f
> >  [<ffffffff8107b014>] __lock_acquire+0x6dc/0x93c
> >  [<ffffffff8106cd0c>] ? local_clock+0x40/0x59
> >  [<ffffffffa0166eef>] ? ip6t_do_table+0x8a/0x3f1 [ip6_tables]
> >  [<ffffffff8107b374>] lock_acquire+0x100/0x12d
> >  [<ffffffffa0166eef>] ? ip6t_do_table+0x8a/0x3f1 [ip6_tables]
> >  [<ffffffff81011149>] ? sched_clock+0x9/0xd
> >  [<ffffffff813f4ec3>] _raw_spin_lock+0x40/0x73
> >  [<ffffffffa0166eef>] ? ip6t_do_table+0x8a/0x3f1 [ip6_tables]
> >  [<ffffffffa0166eef>] ip6t_do_table+0x8a/0x3f1 [ip6_tables]
> >  [<ffffffff810771db>] ? trace_hardirqs_off_caller+0x1f/0x9e
> >  [<ffffffff81384f83>] ? nf_hook_slow+0x0/0x119
> >  [<ffffffffa010601c>] ip6table_filter_hook+0x1c/0x20 [ip6table_filt=
er]
> >  [<ffffffff81384f40>] nf_iterate+0x46/0x89
> >  [<ffffffffa035627b>] ? dst_output+0x0/0x5c [ipv6]
> >  [<ffffffff8138501b>] nf_hook_slow+0x98/0x119
> >  [<ffffffffa035627b>] ? dst_output+0x0/0x5c [ipv6]
> >  [<ffffffffa0349557>] ? icmp6_dst_alloc+0x0/0x1b2 [ipv6]
> >  [<ffffffffa0357b01>] mld_sendpack+0x237/0x3ab [ipv6]
> >  [<ffffffff81051475>] ? local_bh_enable_ip+0xc7/0xeb
> >  [<ffffffffa0358390>] mld_ifc_timer_expire+0x254/0x28d [ipv6]
> >  [<ffffffff810584ed>] run_timer_softirq+0x2c6/0x3e6
> >  [<ffffffff8105841c>] ? run_timer_softirq+0x1f5/0x3e6
> >  [<ffffffffa035813c>] ? mld_ifc_timer_expire+0x0/0x28d [ipv6]
> >  [<ffffffff8105169e>] ? __do_softirq+0x79/0x247
> >  [<ffffffff81051763>] __do_softirq+0x13e/0x247
> >  [<ffffffff8100bc9c>] call_softirq+0x1c/0x30
> >  [<ffffffff8100d32f>] do_softirq+0x4b/0xa3
> >  [<ffffffff8105120a>] irq_exit+0x4a/0x95
> >  [<ffffffff813fc185>] smp_apic_timer_interrupt+0x8c/0x9a
> >  [<ffffffff8100b753>] apic_timer_interrupt+0x13/0x20
> >  <EOI>  [<ffffffff8102c72a>] ? native_flush_tlb_global+0x2b/0x32
> >  [<ffffffff81031fec>] kernel_map_pages+0x12c/0x142
> >  [<ffffffff810cc89a>] free_pages_prepare+0x14c/0x15d
> >  [<ffffffff810cc9c8>] free_hot_cold_page+0x2d/0x165
> >  [<ffffffff810ccb2b>] __free_pages+0x2b/0x34
> >  [<ffffffff810ccb7d>] free_pages+0x49/0x4e
> >  [<ffffffff81033871>] pgd_free+0x71/0x79
> >  [<ffffffff81048b1b>] __mmdrop+0x27/0x54
> >  [<ffffffff81042c62>] finish_task_switch+0xb4/0xe4
> >  [<ffffffff81042bae>] ? finish_task_switch+0x0/0xe4
> >  [<ffffffff810096e7>] ? __switch_to+0x1a9/0x297
> >  [<ffffffff81042df3>] schedule_tail+0x30/0xa7
> >  [<ffffffff8100ac33>] ret_from_fork+0x13/0x80
> >=20
> > I noticed in net/ipv6/netfilter/ip6_tables.c in get_counters() as w=
ith
> > other "get_counters()" functions do not block bottom halves anymore=
 as
> > to this commit:
> >=20
> > commit 24b36f0193467fa727b85b4c004016a8dae999b9
> > Author: Eric Dumazet <eric.dumazet@gmail.com>
> > Date:   Mon Aug 2 16:49:01 2010 +0200
> >=20
> >     netfilter: {ip,ip6,arp}_tables: dont block bottom half more tha=
n necessary
> >    =20
> >     We currently disable BH for the whole duration of get_counters(=
)
> >=20
> > Now we take xt_info_wrlock(cpu) lock out of BH disabling. And that =
lock
> > even has the following comment:
> >=20
> > /*
> >  * The "writer" side needs to get exclusive access to the lock,
> >  * regardless of readers.  This must be called with bottom half
> >  * processing (and thus also preemption) disabled.
> >  */
> > static inline void xt_info_wrlock(unsigned int cpu)
> >=20
> >=20
> > As lockdep has proven, this is not satisfied.
> >=20
> > -- Steve
> >=20
> >=20
>=20
>=20
> This is a false positive, and a patch was sent yesterday
>=20
> http://patchwork.ozlabs.org/patch/61750/
>=20

I still do not see how this is a false positive. Per-cpu locks do not
solve the issue.


Please tell me what prevents an interrupt going off after we grab the
xt_info_wrlock(cpu) in get_counters().

IOW, what prevents this:

	get_counters() {
		xt_info_wrlock(cpu);

		<interrupt> --> softirq

			xt_info_rblock_bh();
				/* which grabs the writer lock */
			DEADLOCK!!


-- Steve

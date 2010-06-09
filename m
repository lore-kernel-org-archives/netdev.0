From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: 2.6.35-rc2-git1 - include/linux/cgroup.h:534 invoked
 rcu_dereference_check() without protection!
Date: Wed, 09 Jun 2010 19:57:09 +0200
Message-ID: <1276106229.1745.65.camel@laptop>
References: <AANLkTin2pPqOUx--9fIX3BH3e-cU6oCRufijcx_4ozx5@mail.gmail.com>
	 <20100608001929.GF2387@linux.vnet.ibm.com>
	 <AANLkTikl13cJNuU32JzRarrUnoh5DYHr-Tbnv9B-UjsG@mail.gmail.com>
	 <1275986441.5408.111.camel@twins>
	 <AANLkTimXVlgzHivCQberLdrFP8BH_nJzt8_ozUNHG_aI@mail.gmail.com>
	 <1276004075.2987.208.camel@twins>
	 <AANLkTil6ucLZ0A6tWx-OQt_2EeKnx8nSx6rIg2t1L2t5@mail.gmail.com>
	 <1276097068.1745.13.camel@laptop>
	 <AANLkTinl2JKUX6859Ioa1y0DqHWXH5TrkissQ8BAF4cP@mail.gmail.com>
	 <AANLkTilpM9O373rA0cw_wTYVfTiDPbjaKHScAGlt7IAr@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: paulmck@linux.vnet.ibm.com, Vivek Goyal <vgoyal@redhat.com>,
	Eric Paris <eparis@redhat.com>,
	Lai Jiangshan <laijs@cn.fujitsu.com>,
	Ingo Molnar <mingo@elte.hu>,
	LKML <linux-kernel@vger.kernel.org>, nauman@google.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	Jens Axboe <jens.axboe@oracle.com>,
	Gui Jianfeng <guijianfeng@cn.fujitsu.com>,
	Li Zefan <lizf@cn.fujitsu.com>,
	Johannes Berg <johannes@sipsolutions.net>
To: Miles Lane <miles.lane@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:42761 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754200Ab0FIR5g convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jun 2010 13:57:36 -0400
In-Reply-To: <AANLkTilpM9O373rA0cw_wTYVfTiDPbjaKHScAGlt7IAr@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-06-09 at 13:00 -0400, Miles Lane wrote:

> ACPI: Core revision 20100428
> [    0.061088]
> [    0.061090] ===================================================
> [    0.062009] [ INFO: suspicious rcu_dereference_check() usage. ]
> [    0.062138] ---------------------------------------------------
> [    0.062268] kernel/sched.c:616 invoked rcu_dereference_check()
> without protection!
> [    0.062470]
> [    0.062471] other info that might help us debug this:
> [    0.062472]
> [    0.062835]
> [    0.062836] rcu_scheduler_active = 1, debug_locks = 1
> [    0.063009] no locks held by swapper/0.
> [    0.063134]
> [    0.063135] stack backtrace:
> [    0.063378] Pid: 0, comm: swapper Not tainted 2.6.35-rc2-git3 #3
> [    0.063507] Call Trace:
> [    0.063638]  [<ffffffff81072205>] lockdep_rcu_dereference+0x9d/0xa5
> [    0.063773]  [<ffffffff810379f9>] task_group+0x7b/0x8a
> [    0.064012]  [<ffffffff81037a1d>] set_task_rq+0x15/0x6e
> [    0.064143]  [<ffffffff8103e50f>] set_task_cpu+0xa9/0xba
> [    0.064274]  [<ffffffff81042dbb>] sched_fork+0x10a/0x1b3
> [    0.064405]  [<ffffffff810446f9>] copy_process+0x617/0x10e6
> [    0.064537]  [<ffffffff8104533d>] do_fork+0x175/0x39b
> [    0.064670]  [<ffffffff8106589b>] ? up+0xf/0x39
> [    0.064800]  [<ffffffff8106589b>] ? up+0xf/0x39
> [    0.065013]  [<ffffffff811dbf73>] ? do_raw_spin_lock+0x79/0x13e
> [    0.065148]  [<ffffffff81011526>] kernel_thread+0x70/0x72
> [    0.065279]  [<ffffffff816cc5e4>] ? kernel_init+0x0/0x1ce
> [    0.065411]  [<ffffffff8100aba0>] ? kernel_thread_helper+0x0/0x10
> [    0.065545]  [<ffffffff81096bea>] ? rcu_scheduler_starting+0x2a/0x4c
> [    0.065679]  [<ffffffff813a8a4d>] rest_init+0x21/0xde
> [    0.065810]  [<ffffffff816cce28>] start_kernel+0x448/0x453
> [    0.066013]  [<ffffffff816cc2c8>] x86_64_start_reservations+0xb3/0xb7
> [    0.066148]  [<ffffffff816cc418>] x86_64_start_kernel+0x14c/0x15b
> [    0.066499] Setting APIC routing to flat

Argh, moar funkeh stuff..

Either we do something like the below, or add something like (p->flags &
PF_STARTING) to the task_subsys_state_check(), opinions?

---
 kernel/sched.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/kernel/sched.c b/kernel/sched.c
index 19b3c5d..bfd3128 100644
--- a/kernel/sched.c
+++ b/kernel/sched.c
@@ -2564,7 +2564,15 @@ void sched_fork(struct task_struct *p, int clone_flags)
 	if (p->sched_class->task_fork)
 		p->sched_class->task_fork(p);
 
+	/*
+	 * We're not in the pid-hash yet so no cgroup attach races, and the
+	 * cgroup is pinned by the parent running this.
+	 *
+	 * Silence PROVE_RCU.
+	 */
+	rcu_read_lock();
 	set_task_cpu(p, cpu);
+	rcu_read_unlock();
 
 #if defined(CONFIG_SCHEDSTATS) || defined(CONFIG_TASK_DELAY_ACCT)
 	if (likely(sched_info_on()))


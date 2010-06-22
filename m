From: Peter Zijlstra <peterz@infradead.org>
Subject: [PATCH] sched: silence PROVE_RCU in sched_fork()
Date: Tue, 22 Jun 2010 11:44:53 +0200
Message-ID: <1277199893.1875.690.camel@laptop>
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
	 <1276106229.1745.65.camel@laptop> <1276107311.1745.66.camel@laptop>
	 <AANLkTilG5bjN5QaOChmuVN6vT7kMK4eGaV-DvPynBn_t@mail.gmail.com>
	 <1276118458.1745.144.camel@laptop>
	 <AANLkTilsDv59zbL7rbAgJByz_vSnZ0QlbK3dVJUX2VYQ@mail.gmail.com>
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
	Johannes Berg <johannes@sipsolutions.net>,
	Paul Menage <menage@google.com>
To: Miles Lane <miles.lane@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTilsDv59zbL7rbAgJByz_vSnZ0QlbK3dVJUX2VYQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Paul Menage, Li Zefan, any comments?


---
Because cgroup_fork() is ran before sched_fork() [ from copy_process() ]
and the child's pid is not yet visible the child is pinned to its
cgroup. Therefore we can silence this warning.

A nicer solution would be moving cgroup_fork() to right after
dup_task_struct() and exclude PF_STARTING from task_subsys_state().

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 kernel/sched.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/kernel/sched.c b/kernel/sched.c
index b697606..2e79518 100644
--- a/kernel/sched.c
+++ b/kernel/sched.c
@@ -2561,7 +2561,16 @@ void sched_fork(struct task_struct *p, int clone_flags)
 	if (p->sched_class->task_fork)
 		p->sched_class->task_fork(p);
 
+	/*
+	 * The child is not yet in the pid-hash so no cgroup attach races,
+	 * and the cgroup is pinned to this child due to cgroup_fork()
+	 * is ran before sched_fork().
+	 *
+	 * Silence PROVE_RCU.
+	 */
+	rcu_read_lock();
 	set_task_cpu(p, cpu);
+	rcu_read_unlock();
 
 #if defined(CONFIG_SCHEDSTATS) || defined(CONFIG_TASK_DELAY_ACCT)
 	if (likely(sched_info_on()))

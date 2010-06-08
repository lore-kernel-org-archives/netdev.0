From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: 2.6.35-rc2-git1 - include/linux/cgroup.h:534 invoked
 rcu_dereference_check() without protection!
Date: Tue, 08 Jun 2010 10:40:41 +0200
Message-ID: <1275986441.5408.111.camel@twins>
References: <AANLkTin2pPqOUx--9fIX3BH3e-cU6oCRufijcx_4ozx5@mail.gmail.com>
	 <20100608001929.GF2387@linux.vnet.ibm.com>
	 <AANLkTikl13cJNuU32JzRarrUnoh5DYHr-Tbnv9B-UjsG@mail.gmail.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTikl13cJNuU32JzRarrUnoh5DYHr-Tbnv9B-UjsG@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2010-06-08 at 00:16 -0400, Miles Lane wrote:
> On Mon, Jun 7, 2010 at 8:19 PM, Paul E. McKenney
> <paulmck@linux.vnet.ibm.com> wrote:
> > On Mon, Jun 07, 2010 at 02:14:25PM -0400, Miles Lane wrote:
> >> Hi All,
> >>
> >> I just reproduced a warning I reported quite a while ago.  Is a patch
> >> for this in the pipeline?
> >
> > I proposed a patch, thinking that it was a false positive.  Peter Zijlstra
> > pointed out that there was a real race, and proposed an alternative patch,
> > which may be found at http://lkml.org/lkml/2010/4/22/603.
> >
> > Could you please test Peter's patch and let us know if it cures the problem?
> >

Gah, this task_group() stuff is annoying, how about something like the
below which teaches task_group() about the task_rq()->lock rule?

---
 include/linux/cgroup.h |   20 +++++++++++----
 kernel/sched.c         |   61 +++++++++++++++++++++++++----------------------
 2 files changed, 46 insertions(+), 35 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 0c62160..1efd212 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -525,13 +525,21 @@ static inline struct cgroup_subsys_state *cgroup_subsys_state(
 	return cgrp->subsys[subsys_id];
 }
 
-static inline struct cgroup_subsys_state *task_subsys_state(
-	struct task_struct *task, int subsys_id)
+/*
+ * function to get the cgroup_subsys_state which allows for extra
+ * rcu_dereference_check() conditions, such as locks used during the
+ * cgroup_subsys::attach() methods.
+ */
+#define task_subsys_state_check(task, subsys_id, __c) 			\
+	rcu_dereference_check(task->cgroups->subsys[subsys_id],		\
+			      rcu_read_lock_held() ||			\
+			      lockdep_is_held(&task->alloc_lock) || 	\
+			      cgroup_lock_is_held() || (__c))
+
+static inline struct cgroup_subsys_state *
+task_subsys_state(struct task_struct *task, int subsys_id)
 {
-	return rcu_dereference_check(task->cgroups->subsys[subsys_id],
-				     rcu_read_lock_held() ||
-				     lockdep_is_held(&task->alloc_lock) ||
-				     cgroup_lock_is_held());
+	return task_subsys_state_check(task, subsys_id, false);
 }
 
 static inline struct cgroup* task_cgroup(struct task_struct *task,
diff --git a/kernel/sched.c b/kernel/sched.c
index f8b8996..e01bb45 100644
--- a/kernel/sched.c
+++ b/kernel/sched.c
@@ -306,32 +306,26 @@ static int init_task_group_load = INIT_TASK_GROUP_LOAD;
  */
 struct task_group init_task_group;
 
-/* return group to which a task belongs */
+/*
+ * Return the group to which this tasks belongs.
+ *
+ * We use task_subsys_state_check() and extend the RCU verification
+ * with lockdep_is_held(&task_rq(p)->lock) because cpu_cgroup_attach()
+ * holds that lock for each task it moves into the cgroup. Therefore
+ * by holding that lock, we pin the task to the current cgroup.
+ */
 static inline struct task_group *task_group(struct task_struct *p)
 {
-	struct task_group *tg;
+	struct cgroup_subsys_state *css;
 
-#ifdef CONFIG_CGROUP_SCHED
-	tg = container_of(task_subsys_state(p, cpu_cgroup_subsys_id),
-				struct task_group, css);
-#else
-	tg = &init_task_group;
-#endif
-	return tg;
+	css = task_subsys_state_check(p, cpu_cgroup_subsys_id,
+			lockdep_is_held(&task_rq(p)->lock));
+	return container_of(css, struct task_group, css);
 }
 
 /* Change a task's cfs_rq and parent entity if it moves across CPUs/groups */
 static inline void set_task_rq(struct task_struct *p, unsigned int cpu)
 {
-	/*
-	 * Strictly speaking this rcu_read_lock() is not needed since the
-	 * task_group is tied to the cgroup, which in turn can never go away
-	 * as long as there are tasks attached to it.
-	 *
-	 * However since task_group() uses task_subsys_state() which is an
-	 * rcu_dereference() user, this quiets CONFIG_PROVE_RCU.
-	 */
-	rcu_read_lock();
 #ifdef CONFIG_FAIR_GROUP_SCHED
 	p->se.cfs_rq = task_group(p)->cfs_rq[cpu];
 	p->se.parent = task_group(p)->se[cpu];
@@ -341,7 +335,6 @@ static inline void set_task_rq(struct task_struct *p, unsigned int cpu)
 	p->rt.rt_rq  = task_group(p)->rt_rq[cpu];
 	p->rt.parent = task_group(p)->rt_se[cpu];
 #endif
-	rcu_read_unlock();
 }
 
 #else
@@ -4465,16 +4458,6 @@ recheck:
 	}
 
 	if (user) {
-#ifdef CONFIG_RT_GROUP_SCHED
-		/*
-		 * Do not allow realtime tasks into groups that have no runtime
-		 * assigned.
-		 */
-		if (rt_bandwidth_enabled() && rt_policy(policy) &&
-				task_group(p)->rt_bandwidth.rt_runtime == 0)
-			return -EPERM;
-#endif
-
 		retval = security_task_setscheduler(p, policy, param);
 		if (retval)
 			return retval;
@@ -4490,6 +4473,26 @@ recheck:
 	 * runqueue lock must be held.
 	 */
 	rq = __task_rq_lock(p);
+
+	retval = 0;
+#ifdef CONFIG_RT_GROUP_SCHED
+	if (user) {
+		/*
+		 * Do not allow realtime tasks into groups that have no runtime
+		 * assigned.
+		 */
+		if (rt_bandwidth_enabled() && rt_policy(policy) &&
+				task_group(p)->rt_bandwidth.rt_runtime == 0)
+			retval = -EPERM;
+
+		if (retval) {
+			__task_rq_unlock(rq);
+			raw_spin_unlock_irqrestore(&p->pi_lock, flags);
+			return retval;
+		}
+	}
+#endif
+
 	/* recheck policy now with rq lock held */
 	if (unlikely(oldpolicy != -1 && oldpolicy != p->policy)) {
 		policy = oldpolicy = -1;

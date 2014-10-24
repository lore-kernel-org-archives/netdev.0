From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: localed stuck in recent 3.18 git in copy_net_ns?
Date: Fri, 24 Oct 2014 14:49:27 -0700
Message-ID: <20141024214927.GA4977@linux.vnet.ibm.com>
References: <20141023220406.GJ4977@linux.vnet.ibm.com>
 <20141024090857.GA4083@declera.com>
 <20141024154006.GP4977@linux.vnet.ibm.com>
 <20141024162943.GA16621@declera.com>
 <20141024165454.GS4977@linux.vnet.ibm.com>
 <20141024170931.GA21849@declera.com>
 <20141024172009.GV4977@linux.vnet.ibm.com>
 <20141024173526.GA26058@declera.com>
 <20141024183226.GW4977@linux.vnet.ibm.com>
 <20141024212557.GA15537@declera.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Josh Boyer <jwboyer@fedoraproject.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Cong Wang <cwang@twopensource.com>,
	Kevin Fenzi <kevin@scrye.com>, netdev <netdev@vger.kernel.org>,
	"Linux-Kernel@Vger. Kernel. Org" <linux-kernel@vger.kernel.org>,
	jay.vosburgh@canonical.com, mroos@linux.ee, tj@kernel.org
To: Yanko Kaneti <yaneti@declera.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141024212557.GA15537@declera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Oct 25, 2014 at 12:25:57AM +0300, Yanko Kaneti wrote:
> On Fri-10/24/14-2014 11:32, Paul E. McKenney wrote:
> > On Fri, Oct 24, 2014 at 08:35:26PM +0300, Yanko Kaneti wrote:
> > > On Fri-10/24/14-2014 10:20, Paul E. McKenney wrote:

[ . . . ]

> > > > Well, if you are feeling aggressive, give the following patch a spin.
> > > > I am doing sanity tests on it in the meantime.
> > > 
> > > Doesn't seem to make a difference here
> > 
> > OK, inspection isn't cutting it, so time for tracing.  Does the system
> > respond to user input?  If so, please enable rcu:rcu_barrier ftrace before
> > the problem occurs, then dump the trace buffer after the problem occurs.
> 
> Sorry for being unresposive here, but I know next to nothing about tracing
> or most things about the kernel, so I have some cathing up to do.
> 
> In the meantime some layman observations while I tried to find what exactly
> triggers the problem.
> - Even in runlevel 1 I can reliably trigger the problem by starting libvirtd
> - libvirtd seems to be very active in using all sorts of kernel facilities
>   that are modules on fedora so it seems to cause many simultaneous kworker 
>   calls to modprobe
> - there are 8 kworker/u16 from 0 to 7
> - one of these kworkers always deadlocks, while there appear to be two
>   kworker/u16:6 - the seventh

Adding Tejun on CC in case this duplication of kworker/u16:6 is important.

>   6 vs 8 as in 6 rcuos where before they were always 8
> 
> Just observations from someone who still doesn't know what the u16
> kworkers are..

Could you please run the following diagnostic patch?  This will help
me see if I have managed to miswire the rcuo kthreads.  It should
print some information at task-hang time.

							Thanx, Paul

------------------------------------------------------------------------

rcu: Dump no-CBs CPU state at task-hung time

Strictly diagnostic commit for rcu_barrier() hang.  Not for inclusion.

Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

diff --git a/include/linux/rcutiny.h b/include/linux/rcutiny.h
index 0e5366200154..34048140577b 100644
--- a/include/linux/rcutiny.h
+++ b/include/linux/rcutiny.h
@@ -157,4 +157,8 @@ static inline bool rcu_is_watching(void)
 
 #endif /* #else defined(CONFIG_DEBUG_LOCK_ALLOC) || defined(CONFIG_RCU_TRACE) */
 
+static inline void rcu_show_nocb_setup(void)
+{
+}
+
 #endif /* __LINUX_RCUTINY_H */
diff --git a/include/linux/rcutree.h b/include/linux/rcutree.h
index 52953790dcca..0b813bdb971b 100644
--- a/include/linux/rcutree.h
+++ b/include/linux/rcutree.h
@@ -97,4 +97,6 @@ extern int rcu_scheduler_active __read_mostly;
 
 bool rcu_is_watching(void);
 
+void rcu_show_nocb_setup(void);
+
 #endif /* __LINUX_RCUTREE_H */
diff --git a/kernel/hung_task.c b/kernel/hung_task.c
index 06db12434d72..e6e4d0f6b063 100644
--- a/kernel/hung_task.c
+++ b/kernel/hung_task.c
@@ -118,6 +118,7 @@ static void check_hung_task(struct task_struct *t, unsigned long timeout)
 		" disables this message.\n");
 	sched_show_task(t);
 	debug_show_held_locks(t);
+	rcu_show_nocb_setup();
 
 	touch_nmi_watchdog();
 
diff --git a/kernel/rcu/rcutorture.c b/kernel/rcu/rcutorture.c
index 240fa9094f83..6b373e79ce0e 100644
--- a/kernel/rcu/rcutorture.c
+++ b/kernel/rcu/rcutorture.c
@@ -1513,6 +1513,7 @@ rcu_torture_cleanup(void)
 {
 	int i;
 
+	rcu_show_nocb_setup();
 	rcutorture_record_test_transition();
 	if (torture_cleanup_begin()) {
 		if (cur_ops->cb_barrier != NULL)
diff --git a/kernel/rcu/tree_plugin.h b/kernel/rcu/tree_plugin.h
index 927c17b081c7..285b3f6fb229 100644
--- a/kernel/rcu/tree_plugin.h
+++ b/kernel/rcu/tree_plugin.h
@@ -2699,6 +2699,31 @@ static bool init_nocb_callback_list(struct rcu_data *rdp)
 
 #endif /* #else #ifdef CONFIG_RCU_NOCB_CPU */
 
+void rcu_show_nocb_setup(void)
+{
+#ifdef CONFIG_RCU_NOCB_CPU
+	int cpu;
+	struct rcu_data *rdp;
+	struct rcu_state *rsp;
+
+	for_each_rcu_flavor(rsp) {
+		pr_alert("rcu_show_nocb_setup(): %s nocb state:\n", rsp->name);
+		for_each_possible_cpu(cpu) {
+			if (!rcu_is_nocb_cpu(cpu))
+				continue;
+			rdp = per_cpu_ptr(rsp->rda, cpu);
+			pr_alert("%3d: %p l:%p n:%p %c%c%c\n",
+				 cpu,
+				 rdp, rdp->nocb_leader, rdp->nocb_next_follower,
+				 ".N"[!!rdp->nocb_head],
+				 ".G"[!!rdp->nocb_gp_head],
+				 ".F"[!!rdp->nocb_follower_head]);
+		}
+	}
+#endif /* #ifdef CONFIG_RCU_NOCB_CPU */
+}
+EXPORT_SYMBOL_GPL(rcu_show_nocb_setup);
+
 /*
  * An adaptive-ticks CPU can potentially execute in kernel mode for an
  * arbitrarily long period of time with the scheduling-clock tick turned

From: Yanko Kaneti <yaneti@declera.com>
Subject: Re: localed stuck in recent 3.18 git in copy_net_ns?
Date: Sat, 25 Oct 2014 15:09:36 +0300
Message-ID: <20141025120936.GA27000@declera.com>
References: <20141024090857.GA4083@declera.com>
 <20141024154006.GP4977@linux.vnet.ibm.com>
 <20141024162943.GA16621@declera.com>
 <20141024165454.GS4977@linux.vnet.ibm.com>
 <20141024170931.GA21849@declera.com>
 <20141024172009.GV4977@linux.vnet.ibm.com>
 <20141024173526.GA26058@declera.com>
 <20141024183226.GW4977@linux.vnet.ibm.com>
 <20141024212557.GA15537@declera.com>
 <20141024214927.GA4977@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Josh Boyer <jwboyer@fedoraproject.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Cong Wang <cwang@twopensource.com>,
	Kevin Fenzi <kevin@scrye.com>, netdev <netdev@vger.kernel.org>,
	"Linux-Kernel@Vger. Kernel. Org" <linux-kernel@vger.kernel.org>,
	jay.vosburgh@canonical.com, mroos@linux.ee, tj@kernel.org
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141024214927.GA4977@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri-10/24/14-2014 14:49, Paul E. McKenney wrote:
> On Sat, Oct 25, 2014 at 12:25:57AM +0300, Yanko Kaneti wrote:
> > On Fri-10/24/14-2014 11:32, Paul E. McKenney wrote:
> > > On Fri, Oct 24, 2014 at 08:35:26PM +0300, Yanko Kaneti wrote:
> > > > On Fri-10/24/14-2014 10:20, Paul E. McKenney wrote:
> 
> [ . . . ]
> 
> > > > > Well, if you are feeling aggressive, give the following patch a spin.
> > > > > I am doing sanity tests on it in the meantime.
> > > > 
> > > > Doesn't seem to make a difference here
> > > 
> > > OK, inspection isn't cutting it, so time for tracing.  Does the system
> > > respond to user input?  If so, please enable rcu:rcu_barrier ftrace before
> > > the problem occurs, then dump the trace buffer after the problem occurs.
> > 
> > Sorry for being unresposive here, but I know next to nothing about tracing
> > or most things about the kernel, so I have some cathing up to do.
> > 
> > In the meantime some layman observations while I tried to find what exactly
> > triggers the problem.
> > - Even in runlevel 1 I can reliably trigger the problem by starting libvirtd
> > - libvirtd seems to be very active in using all sorts of kernel facilities
> >   that are modules on fedora so it seems to cause many simultaneous kworker 
> >   calls to modprobe
> > - there are 8 kworker/u16 from 0 to 7
> > - one of these kworkers always deadlocks, while there appear to be two
> >   kworker/u16:6 - the seventh
> 
> Adding Tejun on CC in case this duplication of kworker/u16:6 is important.
> 
> >   6 vs 8 as in 6 rcuos where before they were always 8
> > 
> > Just observations from someone who still doesn't know what the u16
> > kworkers are..
> 
> Could you please run the following diagnostic patch?  This will help
> me see if I have managed to miswire the rcuo kthreads.  It should
> print some information at task-hang time.

So here the output with todays linux tip and the diagnostic patch.
This is the case with just starting libvird in runlevel 1.
Also a snapshot  of the kworker/u16 s

    6 ?        S      0:00  \_ [kworker/u16:0]
  553 ?        S      0:00  |   \_ [kworker/u16:0]
  554 ?        D      0:00  |       \_ /sbin/modprobe -q -- bridge
   78 ?        S      0:00  \_ [kworker/u16:1]
   92 ?        S      0:00  \_ [kworker/u16:2]
   93 ?        S      0:00  \_ [kworker/u16:3]
   94 ?        S      0:00  \_ [kworker/u16:4]
   95 ?        S      0:00  \_ [kworker/u16:5]
   96 ?        D      0:00  \_ [kworker/u16:6]
  105 ?        S      0:00  \_ [kworker/u16:7]
  108 ?        S      0:00  \_ [kworker/u16:8]


INFO: task kworker/u16:6:96 blocked for more than 120 seconds.
      Not tainted 3.18.0-rc1+ #16
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
kworker/u16:6   D ffff8800ca9ecec0 11552    96      2 0x00000000
Workqueue: netns cleanup_net
 ffff880221fff9c8 0000000000000096 ffff8800ca9ecec0 00000000001d5f00
 ffff880221ffffd8 00000000001d5f00 ffff880223260000 ffff8800ca9ecec0
 ffffffff82c44010 7fffffffffffffff ffffffff81ee3798 ffffffff81ee3790
Call Trace:
 [<ffffffff81866219>] schedule+0x29/0x70
 [<ffffffff8186b43c>] schedule_timeout+0x26c/0x410
 [<ffffffff81028bea>] ? native_sched_clock+0x2a/0xa0
 [<ffffffff8110748c>] ? mark_held_locks+0x7c/0xb0
 [<ffffffff8186c4c0>] ? _raw_spin_unlock_irq+0x30/0x50
 [<ffffffff8110761d>] ? trace_hardirqs_on_caller+0x15d/0x200
 [<ffffffff81867c4c>] wait_for_completion+0x10c/0x150
 [<ffffffff810e4dc0>] ? wake_up_state+0x20/0x20
 [<ffffffff81133627>] _rcu_barrier+0x677/0xcd0
 [<ffffffff81133cd5>] rcu_barrier+0x15/0x20
 [<ffffffff81720edf>] netdev_run_todo+0x6f/0x310
 [<ffffffff81715aa5>] ? rollback_registered_many+0x265/0x2e0
 [<ffffffff8172df4e>] rtnl_unlock+0xe/0x10
 [<ffffffff81717906>] default_device_exit_batch+0x156/0x180
 [<ffffffff810fd280>] ? abort_exclusive_wait+0xb0/0xb0
 [<ffffffff8170f9b3>] ops_exit_list.isra.1+0x53/0x60
 [<ffffffff81710560>] cleanup_net+0x100/0x1f0
 [<ffffffff810cc988>] process_one_work+0x218/0x850
 [<ffffffff810cc8ef>] ? process_one_work+0x17f/0x850
 [<ffffffff810cd0a7>] ? worker_thread+0xe7/0x4a0
 [<ffffffff810cd02b>] worker_thread+0x6b/0x4a0
 [<ffffffff810ccfc0>] ? process_one_work+0x850/0x850
 [<ffffffff810d337b>] kthread+0x10b/0x130
 [<ffffffff81028c69>] ? sched_clock+0x9/0x10
 [<ffffffff810d3270>] ? kthread_create_on_node+0x250/0x250
 [<ffffffff8186d1fc>] ret_from_fork+0x7c/0xb0
 [<ffffffff810d3270>] ? kthread_create_on_node+0x250/0x250
4 locks held by kworker/u16:6/96:
 #0:  ("%s""netns"){.+.+.+}, at: [<ffffffff810cc8ef>]
 #process_one_work+0x17f/0x850
 #1:  (net_cleanup_work){+.+.+.}, at: [<ffffffff810cc8ef>]
 #process_one_work+0x17f/0x850
 #2:  (net_mutex){+.+.+.}, at: [<ffffffff817104ec>] cleanup_net+0x8c/0x1f0
 #3:  (rcu_sched_state.barrier_mutex){+.+...}, at: [<ffffffff81133025>]
 #_rcu_barrier+0x75/0xcd0
rcu_show_nocb_setup(): rcu_sched nocb state:
  0: ffff8802267ced40 l:ffff8802267ced40 n:ffff8802269ced40 .G.
  1: ffff8802269ced40 l:ffff8802267ced40 n:          (null) ...
  2: ffff880226bced40 l:ffff880226bced40 n:ffff880226dced40 .G.
  3: ffff880226dced40 l:ffff880226bced40 n:          (null) N..
  4: ffff880226fced40 l:ffff880226fced40 n:ffff8802271ced40 .G.
  5: ffff8802271ced40 l:ffff880226fced40 n:          (null) ...
  6: ffff8802273ced40 l:ffff8802273ced40 n:ffff8802275ced40 N..
  7: ffff8802275ced40 l:ffff8802273ced40 n:          (null) N..
rcu_show_nocb_setup(): rcu_bh nocb state:
  0: ffff8802267ceac0 l:ffff8802267ceac0 n:ffff8802269ceac0 ...
  1: ffff8802269ceac0 l:ffff8802267ceac0 n:          (null) ...
  2: ffff880226bceac0 l:ffff880226bceac0 n:ffff880226dceac0 ...
  3: ffff880226dceac0 l:ffff880226bceac0 n:          (null) ...
  4: ffff880226fceac0 l:ffff880226fceac0 n:ffff8802271ceac0 ...
  5: ffff8802271ceac0 l:ffff880226fceac0 n:          (null) ...
  6: ffff8802273ceac0 l:ffff8802273ceac0 n:ffff8802275ceac0 ...
  7: ffff8802275ceac0 l:ffff8802273ceac0 n:          (null) ...
INFO: task modprobe:554 blocked for more than 120 seconds.
      Not tainted 3.18.0-rc1+ #16
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
modprobe        D ffff8800c85dcec0 12456   554    553 0x00000000
 ffff8802178afbf8 0000000000000096 ffff8800c85dcec0 00000000001d5f00
 ffff8802178affd8 00000000001d5f00 ffffffff81e1b580 ffff8800c85dcec0
 ffff8800c85dcec0 ffffffff81f90c08 0000000000000246 ffff8800c85dcec0
Call Trace:
 [<ffffffff818667c1>] schedule_preempt_disabled+0x31/0x80
 [<ffffffff81868013>] mutex_lock_nested+0x183/0x440
 [<ffffffff8171037f>] ? register_pernet_subsys+0x1f/0x50
 [<ffffffff8171037f>] ? register_pernet_subsys+0x1f/0x50
 [<ffffffffa0619000>] ? 0xffffffffa0619000
 [<ffffffff8171037f>] register_pernet_subsys+0x1f/0x50
 [<ffffffffa0619048>] br_init+0x48/0xd3 [bridge]
 [<ffffffff81002148>] do_one_initcall+0xd8/0x210
 [<ffffffff8115bc22>] load_module+0x20c2/0x2870
 [<ffffffff81156c00>] ? store_uevent+0x70/0x70
 [<ffffffff81281327>] ? kernel_read+0x57/0x90
 [<ffffffff8115c5b6>] SyS_finit_module+0xa6/0xe0
 [<ffffffff8186d2d5>] ? sysret_check+0x22/0x5d
 [<ffffffff8186d2a9>] system_call_fastpath+0x12/0x17
1 lock held by modprobe/554:
 #0:  (net_mutex){+.+.+.}, at: [<ffffffff8171037f>]
 #register_pernet_subsys+0x1f/0x50
rcu_show_nocb_setup(): rcu_sched nocb state:
  0: ffff8802267ced40 l:ffff8802267ced40 n:ffff8802269ced40 .G.
  1: ffff8802269ced40 l:ffff8802267ced40 n:          (null) ...
  2: ffff880226bced40 l:ffff880226bced40 n:ffff880226dced40 .G.
  3: ffff880226dced40 l:ffff880226bced40 n:          (null) N..
  4: ffff880226fced40 l:ffff880226fced40 n:ffff8802271ced40 .G.
  5: ffff8802271ced40 l:ffff880226fced40 n:          (null) ...
  6: ffff8802273ced40 l:ffff8802273ced40 n:ffff8802275ced40 N..
  7: ffff8802275ced40 l:ffff8802273ced40 n:          (null) N..
rcu_show_nocb_setup(): rcu_bh nocb state:
  0: ffff8802267ceac0 l:ffff8802267ceac0 n:ffff8802269ceac0 ...
  1: ffff8802269ceac0 l:ffff8802267ceac0 n:          (null) ...
  2: ffff880226bceac0 l:ffff880226bceac0 n:ffff880226dceac0 ...
  3: ffff880226dceac0 l:ffff880226bceac0 n:          (null) ...
  4: ffff880226fceac0 l:ffff880226fceac0 n:ffff8802271ceac0 ...
  5: ffff8802271ceac0 l:ffff880226fceac0 n:          (null) ...
  6: ffff8802273ceac0 l:ffff8802273ceac0 n:ffff8802275ceac0 ...
  7: ffff8802275ceac0 l:ffff8802273ceac0 n:          (null) ...


 
> 							Thanx, Paul
> 
> ------------------------------------------------------------------------
> 
> rcu: Dump no-CBs CPU state at task-hung time
> 
> Strictly diagnostic commit for rcu_barrier() hang.  Not for inclusion.
> 
> Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> 
> diff --git a/include/linux/rcutiny.h b/include/linux/rcutiny.h
> index 0e5366200154..34048140577b 100644
> --- a/include/linux/rcutiny.h
> +++ b/include/linux/rcutiny.h
> @@ -157,4 +157,8 @@ static inline bool rcu_is_watching(void)
>  
>  #endif /* #else defined(CONFIG_DEBUG_LOCK_ALLOC) || defined(CONFIG_RCU_TRACE) */
>  
> +static inline void rcu_show_nocb_setup(void)
> +{
> +}
> +
>  #endif /* __LINUX_RCUTINY_H */
> diff --git a/include/linux/rcutree.h b/include/linux/rcutree.h
> index 52953790dcca..0b813bdb971b 100644
> --- a/include/linux/rcutree.h
> +++ b/include/linux/rcutree.h
> @@ -97,4 +97,6 @@ extern int rcu_scheduler_active __read_mostly;
>  
>  bool rcu_is_watching(void);
>  
> +void rcu_show_nocb_setup(void);
> +
>  #endif /* __LINUX_RCUTREE_H */
> diff --git a/kernel/hung_task.c b/kernel/hung_task.c
> index 06db12434d72..e6e4d0f6b063 100644
> --- a/kernel/hung_task.c
> +++ b/kernel/hung_task.c
> @@ -118,6 +118,7 @@ static void check_hung_task(struct task_struct *t, unsigned long timeout)
>  		" disables this message.\n");
>  	sched_show_task(t);
>  	debug_show_held_locks(t);
> +	rcu_show_nocb_setup();
>  
>  	touch_nmi_watchdog();
>  
> diff --git a/kernel/rcu/rcutorture.c b/kernel/rcu/rcutorture.c
> index 240fa9094f83..6b373e79ce0e 100644
> --- a/kernel/rcu/rcutorture.c
> +++ b/kernel/rcu/rcutorture.c
> @@ -1513,6 +1513,7 @@ rcu_torture_cleanup(void)
>  {
>  	int i;
>  
> +	rcu_show_nocb_setup();
>  	rcutorture_record_test_transition();
>  	if (torture_cleanup_begin()) {
>  		if (cur_ops->cb_barrier != NULL)
> diff --git a/kernel/rcu/tree_plugin.h b/kernel/rcu/tree_plugin.h
> index 927c17b081c7..285b3f6fb229 100644
> --- a/kernel/rcu/tree_plugin.h
> +++ b/kernel/rcu/tree_plugin.h
> @@ -2699,6 +2699,31 @@ static bool init_nocb_callback_list(struct rcu_data *rdp)
>  
>  #endif /* #else #ifdef CONFIG_RCU_NOCB_CPU */
>  
> +void rcu_show_nocb_setup(void)
> +{
> +#ifdef CONFIG_RCU_NOCB_CPU
> +	int cpu;
> +	struct rcu_data *rdp;
> +	struct rcu_state *rsp;
> +
> +	for_each_rcu_flavor(rsp) {
> +		pr_alert("rcu_show_nocb_setup(): %s nocb state:\n", rsp->name);
> +		for_each_possible_cpu(cpu) {
> +			if (!rcu_is_nocb_cpu(cpu))
> +				continue;
> +			rdp = per_cpu_ptr(rsp->rda, cpu);
> +			pr_alert("%3d: %p l:%p n:%p %c%c%c\n",
> +				 cpu,
> +				 rdp, rdp->nocb_leader, rdp->nocb_next_follower,
> +				 ".N"[!!rdp->nocb_head],
> +				 ".G"[!!rdp->nocb_gp_head],
> +				 ".F"[!!rdp->nocb_follower_head]);
> +		}
> +	}
> +#endif /* #ifdef CONFIG_RCU_NOCB_CPU */
> +}
> +EXPORT_SYMBOL_GPL(rcu_show_nocb_setup);
> +
>  /*
>   * An adaptive-ticks CPU can potentially execute in kernel mode for an
>   * arbitrarily long period of time with the scheduling-clock tick turned
> 

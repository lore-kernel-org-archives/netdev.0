From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: localed stuck in recent 3.18 git in copy_net_ns?
Date: Fri, 24 Oct 2014 08:40:06 -0700
Message-ID: <20141024154006.GP4977@linux.vnet.ibm.com>
References: <20141022224032.GA1240@declera.com>
 <20141022232421.GN4977@linux.vnet.ibm.com>
 <1414044566.2031.1.camel@declera.com>
 <20141023122750.GP4977@linux.vnet.ibm.com>
 <20141023153333.GA19278@linux.vnet.ibm.com>
 <20141023195159.GA2331@declera.com>
 <20141023200507.GC4977@linux.vnet.ibm.com>
 <1414100740.2065.2.camel@declera.com>
 <20141023220406.GJ4977@linux.vnet.ibm.com>
 <20141024090857.GA4083@declera.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Josh Boyer <jwboyer@fedoraproject.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Cong Wang <cwang@twopensource.com>,
	Kevin Fenzi <kevin@scrye.com>, netdev <netdev@vger.kernel.org>,
	"Linux-Kernel@Vger. Kernel. Org" <linux-kernel@vger.kernel.org>,
	jay.vosburgh@canonical.com, mroos@linux.ee
To: Yanko Kaneti <yaneti@declera.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141024090857.GA4083@declera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 24, 2014 at 12:08:57PM +0300, Yanko Kaneti wrote:
> On Thu-10/23/14-2014 15:04, Paul E. McKenney wrote:
> > On Fri, Oct 24, 2014 at 12:45:40AM +0300, Yanko Kaneti wrote:
> > > 
> > > On Thu, 2014-10-23 at 13:05 -0700, Paul E. McKenney wrote:
> > > > On Thu, Oct 23, 2014 at 10:51:59PM +0300, Yanko Kaneti wrote:

[ . . . ]

> > > > > Indeed, c847f14217d5 it is.
> > > > > 
> > > > > Much to my embarrasment I just noticed that in addition to the
> > > > > rcu merge, triggering the bug "requires" my specific Fedora 
> > > > > rawhide network
> > > > > setup. Booting in single mode and modprobe ppp_generic is fine. 
> > > > > The bug
> > > > > appears when starting with my regular fedora network setup, which 
> > > > > in my case
> > > > > includes 3 ethernet adapters and a libvirt birdge+nat setup.
> > > > > 
> > > > > Hope that helps.
> > > > > 
> > > > > I am attaching the config.
> > > > 
> > > > It does help a lot, thank you!!!
> > > > 
> > > > The following patch is a bit of a shot in the dark, and assumes that
> > > > commit 1772947bd012 (rcu: Handle NOCB callbacks from irq-disabled 
> > > > idle
> > > > code) introduced the problem.  Does this patch fix things up?
> > > 
> > > Unfortunately not, This is linus-tip + patch
> > 
> > OK.  Can't have everything, I guess.
> > 
> > > INFO: task kworker/u16:6:96 blocked for more than 120 seconds.
> > >       Not tainted 3.18.0-rc1+ #4
> > > "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> > > kworker/u16:6   D ffff8800ca84cec0 11168    96      2 0x00000000
> > > Workqueue: netns cleanup_net
> > >  ffff8802218339e8 0000000000000096 ffff8800ca84cec0 00000000001d5f00
> > >  ffff880221833fd8 00000000001d5f00 ffff880223264ec0 ffff8800ca84cec0
> > >  ffffffff82c52040 7fffffffffffffff ffffffff81ee2658 ffffffff81ee2650
> > > Call Trace:
> > >  [<ffffffff8185b8e9>] schedule+0x29/0x70
> > >  [<ffffffff81860b0c>] schedule_timeout+0x26c/0x410
> > >  [<ffffffff81028bea>] ? native_sched_clock+0x2a/0xa0
> > >  [<ffffffff8110759c>] ? mark_held_locks+0x7c/0xb0
> > >  [<ffffffff81861b90>] ? _raw_spin_unlock_irq+0x30/0x50
> > >  [<ffffffff8110772d>] ? trace_hardirqs_on_caller+0x15d/0x200
> > >  [<ffffffff8185d31c>] wait_for_completion+0x10c/0x150
> > >  [<ffffffff810e4ed0>] ? wake_up_state+0x20/0x20
> > >  [<ffffffff8112a219>] _rcu_barrier+0x159/0x200
> > >  [<ffffffff8112a315>] rcu_barrier+0x15/0x20
> > >  [<ffffffff8171657f>] netdev_run_todo+0x6f/0x310
> > >  [<ffffffff8170b145>] ? rollback_registered_many+0x265/0x2e0
> > >  [<ffffffff817235ee>] rtnl_unlock+0xe/0x10
> > >  [<ffffffff8170cfa6>] default_device_exit_batch+0x156/0x180
> > >  [<ffffffff810fd390>] ? abort_exclusive_wait+0xb0/0xb0
> > >  [<ffffffff81705053>] ops_exit_list.isra.1+0x53/0x60
> > >  [<ffffffff81705c00>] cleanup_net+0x100/0x1f0
> > >  [<ffffffff810cca98>] process_one_work+0x218/0x850
> > >  [<ffffffff810cc9ff>] ? process_one_work+0x17f/0x850
> > >  [<ffffffff810cd1b7>] ? worker_thread+0xe7/0x4a0
> > >  [<ffffffff810cd13b>] worker_thread+0x6b/0x4a0
> > >  [<ffffffff810cd0d0>] ? process_one_work+0x850/0x850
> > >  [<ffffffff810d348b>] kthread+0x10b/0x130
> > >  [<ffffffff81028c69>] ? sched_clock+0x9/0x10
> > >  [<ffffffff810d3380>] ? kthread_create_on_node+0x250/0x250
> > >  [<ffffffff818628bc>] ret_from_fork+0x7c/0xb0
> > >  [<ffffffff810d3380>] ? kthread_create_on_node+0x250/0x250
> > > 4 locks held by kworker/u16:6/96:
> > >  #0:  ("%s""netns"){.+.+.+}, at: [<ffffffff810cc9ff>] process_one_work+0x17f/0x850
> > >  #1:  (net_cleanup_work){+.+.+.}, at: [<ffffffff810cc9ff>] process_one_work+0x17f/0x850
> > >  #2:  (net_mutex){+.+.+.}, at: [<ffffffff81705b8c>] cleanup_net+0x8c/0x1f0
> > >  #3:  (rcu_sched_state.barrier_mutex){+.+...}, at: [<ffffffff8112a0f5>] _rcu_barrier+0x35/0x200
> > > INFO: task modprobe:1045 blocked for more than 120 seconds.
> > >       Not tainted 3.18.0-rc1+ #4
> > > "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> > > modprobe        D ffff880218343480 12920  1045   1044 0x00000080
> > >  ffff880218353bf8 0000000000000096 ffff880218343480 00000000001d5f00
> > >  ffff880218353fd8 00000000001d5f00 ffffffff81e1b580 ffff880218343480
> > >  ffff880218343480 ffffffff81f8f748 0000000000000246 ffff880218343480
> > > Call Trace:
> > >  [<ffffffff8185be91>] schedule_preempt_disabled+0x31/0x80
> > >  [<ffffffff8185d6e3>] mutex_lock_nested+0x183/0x440
> > >  [<ffffffff81705a1f>] ? register_pernet_subsys+0x1f/0x50
> > >  [<ffffffff81705a1f>] ? register_pernet_subsys+0x1f/0x50
> > >  [<ffffffffa0673000>] ? 0xffffffffa0673000
> > >  [<ffffffff81705a1f>] register_pernet_subsys+0x1f/0x50
> > >  [<ffffffffa0673048>] br_init+0x48/0xd3 [bridge]
> > >  [<ffffffff81002148>] do_one_initcall+0xd8/0x210
> > >  [<ffffffff81153052>] load_module+0x20c2/0x2870
> > >  [<ffffffff8114e030>] ? store_uevent+0x70/0x70
> > >  [<ffffffff81278717>] ? kernel_read+0x57/0x90
> > >  [<ffffffff811539e6>] SyS_finit_module+0xa6/0xe0
> > >  [<ffffffff81862969>] system_call_fastpath+0x12/0x17
> > > 1 lock held by modprobe/1045:
> > >  #0:  (net_mutex){+.+.+.}, at: [<ffffffff81705a1f>] register_pernet_subsys+0x1f/0x50
> > 
> > Presumably the kworker/u16:6 completed, then modprobe hung?
> > 
> > If not, I have some very hard questions about why net_mutex can be
> > held by two tasks concurrently, given that it does not appear to be a
> > reader-writer lock...
> > 
> > Either way, my patch assumed that 39953dfd4007 (rcu: Avoid misordering in
> > __call_rcu_nocb_enqueue()) would work and that 1772947bd012 (rcu: Handle
> > NOCB callbacks from irq-disabled idle code) would fail.  Is that the case?
> > If not, could you please bisect the commits between 11ed7f934cb8 (rcu:
> > Make nocb leader kthreads process pending callbacks after spawning)
> > and c847f14217d5 (rcu: Avoid misordering in nocb_leader_wait())?
> 
> Ok, unless I've messsed up something major, bisecting points to:
> 
> 35ce7f29a44a rcu: Create rcuo kthreads only for onlined CPUs
> 
> Makes any sense ?

Good question.  ;-)

Are any of your online CPUs missing rcuo kthreads?  There should be
kthreads named rcuos/0, rcuos/1, rcuos/2, and so on for each online CPU.

> Another thing I noticed is that in failure mode the libvirtd bridge actually 
> doesn't show up. So maybe ppp is just the first thing to try that bumps up
> into whatever libvirtd is failing to do to setup those.
> 
> Truly hope this is not something with random timing dependency....

Me too.  ;-)

							Thanx, Paul

> --Yanko
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

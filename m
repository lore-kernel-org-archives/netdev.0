From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: localed stuck in recent 3.18 git in copy_net_ns?
Date: Fri, 24 Oct 2014 07:50:28 -0700
Message-ID: <20141024145028.GN4977@linux.vnet.ibm.com>
References: <20141022224032.GA1240@declera.com>
 <20141022232421.GN4977@linux.vnet.ibm.com>
 <1414044566.2031.1.camel@declera.com>
 <20141023122750.GP4977@linux.vnet.ibm.com>
 <20141023153333.GA19278@linux.vnet.ibm.com>
 <20141023195159.GA2331@declera.com>
 <20141023200507.GC4977@linux.vnet.ibm.com>
 <1414100740.2065.2.camel@declera.com>
 <20141023220406.GJ4977@linux.vnet.ibm.com>
 <31920.1414126114@famine>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Yanko Kaneti <yaneti@declera.com>,
	Josh Boyer <jwboyer@fedoraproject.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Cong Wang <cwang@twopensource.com>,
	Kevin Fenzi <kevin@scrye.com>, netdev <netdev@vger.kernel.org>,
	"Linux-Kernel@Vger. Kernel. Org" <linux-kernel@vger.kernel.org>
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <31920.1414126114@famine>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 23, 2014 at 09:48:34PM -0700, Jay Vosburgh wrote:
> Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:
> 
> >On Fri, Oct 24, 2014 at 12:45:40AM +0300, Yanko Kaneti wrote:
> >> 
> >> On Thu, 2014-10-23 at 13:05 -0700, Paul E. McKenney wrote:
> >> > On Thu, Oct 23, 2014 at 10:51:59PM +0300, Yanko Kaneti wrote:
> >> > > On Thu-10/23/14-2014 08:33, Paul E. McKenney wrote:
> >> > > > On Thu, Oct 23, 2014 at 05:27:50AM -0700, Paul E. McKenney wrote:
> >> > > > > On Thu, Oct 23, 2014 at 09:09:26AM +0300, Yanko Kaneti wrote:
> >> > > > > > On Wed, 2014-10-22 at 16:24 -0700, Paul E. McKenney wrote:
> >> > > > > > > On Thu, Oct 23, 2014 at 01:40:32AM +0300, Yanko Kaneti 
> >> > > > > > > wrote:
> >> > > > > > > > On Wed-10/22/14-2014 15:33, Josh Boyer wrote:
> >> > > > > > > > > On Wed, Oct 22, 2014 at 2:55 PM, Paul E. McKenney
> >> > > > > > > > > <paulmck@linux.vnet.ibm.com> wrote:
> >> > > > > > > 
> >> > > > > > > [ . . . ]
> >> > > > > > > 
> >> > > > > > > > > > Don't get me wrong -- the fact that this kthread 
> >> > > > > > > > > > appears to
> >> > > > > > > > > > have
> >> > > > > > > > > > blocked within rcu_barrier() for 120 seconds means 
> >> > > > > > > > > > that
> >> > > > > > > > > > something is
> >> > > > > > > > > > most definitely wrong here.  I am surprised that 
> >> > > > > > > > > > there are no
> >> > > > > > > > > > RCU CPU
> >> > > > > > > > > > stall warnings, but perhaps the blockage is in the 
> >> > > > > > > > > > callback
> >> > > > > > > > > > execution
> >> > > > > > > > > > rather than grace-period completion.  Or something is
> >> > > > > > > > > > preventing this
> >> > > > > > > > > > kthread from starting up after the wake-up callback 
> >> > > > > > > > > > executes.
> >> > > > > > > > > > Or...
> >> > > > > > > > > > 
> >> > > > > > > > > > Is this thing reproducible?
> >> > > > > > > > > 
> >> > > > > > > > > I've added Yanko on CC, who reported the backtrace 
> >> > > > > > > > > above and can
> >> > > > > > > > > recreate it reliably.  Apparently reverting the RCU 
> >> > > > > > > > > merge commit
> >> > > > > > > > > (d6dd50e) and rebuilding the latest after that does 
> >> > > > > > > > > not show the
> >> > > > > > > > > issue.  I'll let Yanko explain more and answer any 
> >> > > > > > > > > questions you
> >> > > > > > > > > have.
> >> > > > > > > > 
> >> > > > > > > > - It is reproducible
> >> > > > > > > > - I've done another build here to double check and its 
> >> > > > > > > > definitely
> >> > > > > > > > the rcu merge
> >> > > > > > > >   that's causing it.
> >> > > > > > > > 
> >> > > > > > > > Don't think I'll be able to dig deeper, but I can do 
> >> > > > > > > > testing if
> >> > > > > > > > needed.
> >> > > > > > > 
> >> > > > > > > Please!  Does the following patch help?
> >> > > > > > 
> >> > > > > > Nope, doesn't seem to make a difference to the modprobe 
> >> > > > > > ppp_generic
> >> > > > > > test
> >> > > > > 
> >> > > > > Well, I was hoping.  I will take a closer look at the RCU 
> >> > > > > merge commit
> >> > > > > and see what suggests itself.  I am likely to ask you to 
> >> > > > > revert specific
> >> > > > > commits, if that works for you.
> >> > > > 
> >> > > > Well, rather than reverting commits, could you please try 
> >> > > > testing the
> >> > > > following commits?
> >> > > > 
> >> > > > 11ed7f934cb8 (rcu: Make nocb leader kthreads process pending 
> >> > > > callbacks after spawning)
> >> > > > 
> >> > > > 73a860cd58a1 (rcu: Replace flush_signals() with 
> >> > > > WARN_ON(signal_pending()))
> >> > > > 
> >> > > > c847f14217d5 (rcu: Avoid misordering in nocb_leader_wait())
> >> > > > 
> >> > > >         For whatever it is worth, I am guessing this one.
> >> > > 
> >> > > Indeed, c847f14217d5 it is.
> >> > > 
> >> > > Much to my embarrasment I just noticed that in addition to the
> >> > > rcu merge, triggering the bug "requires" my specific Fedora 
> >> > > rawhide network
> >> > > setup. Booting in single mode and modprobe ppp_generic is fine. 
> >> > > The bug
> >> > > appears when starting with my regular fedora network setup, which 
> >> > > in my case
> >> > > includes 3 ethernet adapters and a libvirt birdge+nat setup.
> >> > > 
> >> > > Hope that helps.
> >> > > 
> >> > > I am attaching the config.
> >> > 
> >> > It does help a lot, thank you!!!
> >> > 
> >> > The following patch is a bit of a shot in the dark, and assumes that
> >> > commit 1772947bd012 (rcu: Handle NOCB callbacks from irq-disabled 
> >> > idle
> >> > code) introduced the problem.  Does this patch fix things up?
> >> 
> >> Unfortunately not, This is linus-tip + patch
> >
> >OK.  Can't have everything, I guess.
> >
> >> INFO: task kworker/u16:6:96 blocked for more than 120 seconds.
> >>       Not tainted 3.18.0-rc1+ #4
> >> "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> >> kworker/u16:6   D ffff8800ca84cec0 11168    96      2 0x00000000
> >> Workqueue: netns cleanup_net
> >>  ffff8802218339e8 0000000000000096 ffff8800ca84cec0 00000000001d5f00
> >>  ffff880221833fd8 00000000001d5f00 ffff880223264ec0 ffff8800ca84cec0
> >>  ffffffff82c52040 7fffffffffffffff ffffffff81ee2658 ffffffff81ee2650
> >> Call Trace:
> >>  [<ffffffff8185b8e9>] schedule+0x29/0x70
> >>  [<ffffffff81860b0c>] schedule_timeout+0x26c/0x410
> >>  [<ffffffff81028bea>] ? native_sched_clock+0x2a/0xa0
> >>  [<ffffffff8110759c>] ? mark_held_locks+0x7c/0xb0
> >>  [<ffffffff81861b90>] ? _raw_spin_unlock_irq+0x30/0x50
> >>  [<ffffffff8110772d>] ? trace_hardirqs_on_caller+0x15d/0x200
> >>  [<ffffffff8185d31c>] wait_for_completion+0x10c/0x150
> >>  [<ffffffff810e4ed0>] ? wake_up_state+0x20/0x20
> >>  [<ffffffff8112a219>] _rcu_barrier+0x159/0x200
> >>  [<ffffffff8112a315>] rcu_barrier+0x15/0x20
> >>  [<ffffffff8171657f>] netdev_run_todo+0x6f/0x310
> >>  [<ffffffff8170b145>] ? rollback_registered_many+0x265/0x2e0
> >>  [<ffffffff817235ee>] rtnl_unlock+0xe/0x10
> >>  [<ffffffff8170cfa6>] default_device_exit_batch+0x156/0x180
> >>  [<ffffffff810fd390>] ? abort_exclusive_wait+0xb0/0xb0
> >>  [<ffffffff81705053>] ops_exit_list.isra.1+0x53/0x60
> >>  [<ffffffff81705c00>] cleanup_net+0x100/0x1f0
> >>  [<ffffffff810cca98>] process_one_work+0x218/0x850
> >>  [<ffffffff810cc9ff>] ? process_one_work+0x17f/0x850
> >>  [<ffffffff810cd1b7>] ? worker_thread+0xe7/0x4a0
> >>  [<ffffffff810cd13b>] worker_thread+0x6b/0x4a0
> >>  [<ffffffff810cd0d0>] ? process_one_work+0x850/0x850
> >>  [<ffffffff810d348b>] kthread+0x10b/0x130
> >>  [<ffffffff81028c69>] ? sched_clock+0x9/0x10
> >>  [<ffffffff810d3380>] ? kthread_create_on_node+0x250/0x250
> >>  [<ffffffff818628bc>] ret_from_fork+0x7c/0xb0
> >>  [<ffffffff810d3380>] ? kthread_create_on_node+0x250/0x250
> >> 4 locks held by kworker/u16:6/96:
> >>  #0:  ("%s""netns"){.+.+.+}, at: [<ffffffff810cc9ff>] process_one_work+0x17f/0x850
> >>  #1:  (net_cleanup_work){+.+.+.}, at: [<ffffffff810cc9ff>] process_one_work+0x17f/0x850
> >>  #2:  (net_mutex){+.+.+.}, at: [<ffffffff81705b8c>] cleanup_net+0x8c/0x1f0
> >>  #3:  (rcu_sched_state.barrier_mutex){+.+...}, at: [<ffffffff8112a0f5>] _rcu_barrier+0x35/0x200
> >> INFO: task modprobe:1045 blocked for more than 120 seconds.
> >>       Not tainted 3.18.0-rc1+ #4
> >> "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> >> modprobe        D ffff880218343480 12920  1045   1044 0x00000080
> >>  ffff880218353bf8 0000000000000096 ffff880218343480 00000000001d5f00
> >>  ffff880218353fd8 00000000001d5f00 ffffffff81e1b580 ffff880218343480
> >>  ffff880218343480 ffffffff81f8f748 0000000000000246 ffff880218343480
> >> Call Trace:
> >>  [<ffffffff8185be91>] schedule_preempt_disabled+0x31/0x80
> >>  [<ffffffff8185d6e3>] mutex_lock_nested+0x183/0x440
> >>  [<ffffffff81705a1f>] ? register_pernet_subsys+0x1f/0x50
> >>  [<ffffffff81705a1f>] ? register_pernet_subsys+0x1f/0x50
> >>  [<ffffffffa0673000>] ? 0xffffffffa0673000
> >>  [<ffffffff81705a1f>] register_pernet_subsys+0x1f/0x50
> >>  [<ffffffffa0673048>] br_init+0x48/0xd3 [bridge]
> >>  [<ffffffff81002148>] do_one_initcall+0xd8/0x210
> >>  [<ffffffff81153052>] load_module+0x20c2/0x2870
> >>  [<ffffffff8114e030>] ? store_uevent+0x70/0x70
> >>  [<ffffffff81278717>] ? kernel_read+0x57/0x90
> >>  [<ffffffff811539e6>] SyS_finit_module+0xa6/0xe0
> >>  [<ffffffff81862969>] system_call_fastpath+0x12/0x17
> >> 1 lock held by modprobe/1045:
> >>  #0:  (net_mutex){+.+.+.}, at: [<ffffffff81705a1f>] register_pernet_subsys+0x1f/0x50
> >
> >Presumably the kworker/u16:6 completed, then modprobe hung?
> >
> >If not, I have some very hard questions about why net_mutex can be
> >held by two tasks concurrently, given that it does not appear to be a
> >reader-writer lock...
> >
> >Either way, my patch assumed that 39953dfd4007 (rcu: Avoid misordering in
> >__call_rcu_nocb_enqueue()) would work and that 1772947bd012 (rcu: Handle
> >NOCB callbacks from irq-disabled idle code) would fail.  Is that the case?
> >If not, could you please bisect the commits between 11ed7f934cb8 (rcu:
> >Make nocb leader kthreads process pending callbacks after spawning)
> >and c847f14217d5 (rcu: Avoid misordering in nocb_leader_wait())?
> 
> 	Just a note to add that I am also reliably inducing what appears
> to be this issue on a current -net tree, when configuring openvswitch
> via script.  I am available to test patches or bisect tomorrow (Friday)
> US time if needed.

Thank you, Jay!  Could you please check to see if reverting this commit
fixes things for you?

35ce7f29a44a rcu: Create rcuo kthreads only for onlined CPUs

Reverting is not a long-term fix, as this commit is itself a bug fix,
but would be good to check to see if you are seeing the same thing that
Yanko is.  ;-)

							Thanx, Paul

> 	The stack is as follows:
> 
> [ 1320.492020] INFO: task ovs-vswitchd:1303 blocked for more than 120 seconds.
> [ 1320.498965]       Not tainted 3.17.0-testola+ #1
> [ 1320.503570] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> [ 1320.511374] ovs-vswitchd    D ffff88013fc14600     0  1303   1302 0x00000004
> [ 1320.511378]  ffff8801388d77d8 0000000000000002 ffff880031144b00 ffff8801388d7fd8
> [ 1320.511382]  0000000000014600 0000000000014600 ffff8800b092e400 ffff880031144b00
> [ 1320.511385]  ffff8800b1126000 ffffffff81c58ad0 ffffffff81c58ad8 7fffffffffffffff
> [ 1320.511389] Call Trace:
> [ 1320.511396]  [<ffffffff81739db9>] schedule+0x29/0x70
> [ 1320.511399]  [<ffffffff8173cd8c>] schedule_timeout+0x1dc/0x260
> [ 1320.511404]  [<ffffffff8109698d>] ? check_preempt_curr+0x8d/0xa0
> [ 1320.511407]  [<ffffffff810969bd>] ? ttwu_do_wakeup+0x1d/0xd0
> [ 1320.511410]  [<ffffffff8173aab6>] wait_for_completion+0xa6/0x160
> [ 1320.511413]  [<ffffffff81099980>] ? wake_up_state+0x20/0x20
> [ 1320.511417]  [<ffffffff810cdb57>] _rcu_barrier+0x157/0x200
> [ 1320.511419]  [<ffffffff810cdc55>] rcu_barrier+0x15/0x20
> [ 1320.511423]  [<ffffffff8163a780>] netdev_run_todo+0x60/0x300
> [ 1320.511427]  [<ffffffff8164515e>] rtnl_unlock+0xe/0x10
> [ 1320.511435]  [<ffffffffa01aecc5>] internal_dev_destroy+0x55/0x80 [openvswitch]
> [ 1320.511440]  [<ffffffffa01ae622>] ovs_vport_del+0x32/0x40 [openvswitch]
> [ 1320.511444]  [<ffffffffa01a7dd0>] ovs_dp_detach_port+0x30/0x40 [openvswitch]
> [ 1320.511448]  [<ffffffffa01a7ea5>] ovs_vport_cmd_del+0xc5/0x110 [openvswitch]
> [ 1320.511452]  [<ffffffff816675b5>] genl_family_rcv_msg+0x1a5/0x3c0
> [ 1320.511455]  [<ffffffff816677d0>] ? genl_family_rcv_msg+0x3c0/0x3c0
> [ 1320.511458]  [<ffffffff81667861>] genl_rcv_msg+0x91/0xd0
> [ 1320.511461]  [<ffffffff816658d1>] netlink_rcv_skb+0xc1/0xe0
> [ 1320.511463]  [<ffffffff81665dfc>] genl_rcv+0x2c/0x40
> [ 1320.511466]  [<ffffffff81664e66>] netlink_unicast+0xf6/0x200
> [ 1320.511468]  [<ffffffff8166528d>] netlink_sendmsg+0x31d/0x780
> [ 1320.511472]  [<ffffffff81662274>] ? netlink_rcv_wake+0x44/0x60
> [ 1320.511475]  [<ffffffff816632e3>] ? netlink_recvmsg+0x1d3/0x3e0
> [ 1320.511479]  [<ffffffff8161c463>] sock_sendmsg+0x93/0xd0
> [ 1320.511484]  [<ffffffff81332d00>] ? apparmor_file_alloc_security+0x20/0x40
> [ 1320.511487]  [<ffffffff8162a697>] ? verify_iovec+0x47/0xd0
> [ 1320.511491]  [<ffffffff8161cc79>] ___sys_sendmsg+0x399/0x3b0
> [ 1320.511495]  [<ffffffff81254e02>] ? kernfs_seq_stop_active+0x32/0x40
> [ 1320.511499]  [<ffffffff8101c385>] ? native_sched_clock+0x35/0x90
> [ 1320.511502]  [<ffffffff8101c385>] ? native_sched_clock+0x35/0x90
> [ 1320.511505]  [<ffffffff8101c3e9>] ? sched_clock+0x9/0x10
> [ 1320.511509]  [<ffffffff81122d5c>] ? acct_account_cputime+0x1c/0x20
> [ 1320.511512]  [<ffffffff8109ce6b>] ? account_user_time+0x8b/0xa0
> [ 1320.511516]  [<ffffffff811fc135>] ? __fget_light+0x25/0x70
> [ 1320.511519]  [<ffffffff8161d372>] __sys_sendmsg+0x42/0x80
> [ 1320.511521]  [<ffffffff8161d3c2>] SyS_sendmsg+0x12/0x20
> [ 1320.511525]  [<ffffffff8173e6a4>] tracesys_phase2+0xd8/0xdd
> 
> 	-J
> 
> ---
> 	-Jay Vosburgh, jay.vosburgh@canonical.com
> 

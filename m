From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: localed stuck in recent 3.18 git in copy_net_ns?
Date: Fri, 24 Oct 2014 16:05:24 -0700
Message-ID: <20141024230524.GA16023@linux.vnet.ibm.com>
References: <20141024162943.GA16621@declera.com>
 <20141024165454.GS4977@linux.vnet.ibm.com>
 <20141024170931.GA21849@declera.com>
 <20141024172009.GV4977@linux.vnet.ibm.com>
 <20141024173526.GA26058@declera.com>
 <20141024183226.GW4977@linux.vnet.ibm.com>
 <20141024212557.GA15537@declera.com>
 <20141024214927.GA4977@linux.vnet.ibm.com>
 <8915.1414190047@famine>
 <20141024225931.GC4977@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Yanko Kaneti <yaneti@declera.com>,
	Josh Boyer <jwboyer@fedoraproject.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Cong Wang <cwang@twopensource.com>,
	Kevin Fenzi <kevin@scrye.com>, netdev <netdev@vger.kernel.org>,
	"Linux-Kernel@Vger. Kernel. Org" <linux-kernel@vger.kernel.org>,
	mroos@linux.ee, tj@kernel.org
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:41405 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752915AbaJXXJP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Oct 2014 19:09:15 -0400
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <paulmck@linux.vnet.ibm.com>;
	Fri, 24 Oct 2014 19:09:14 -0400
Content-Disposition: inline
In-Reply-To: <20141024225931.GC4977@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 24, 2014 at 03:59:31PM -0700, Paul E. McKenney wrote:
> On Fri, Oct 24, 2014 at 03:34:07PM -0700, Jay Vosburgh wrote:
> > Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:
> > 
> > >On Sat, Oct 25, 2014 at 12:25:57AM +0300, Yanko Kaneti wrote:
> > >> On Fri-10/24/14-2014 11:32, Paul E. McKenney wrote:
> > >> > On Fri, Oct 24, 2014 at 08:35:26PM +0300, Yanko Kaneti wrote:
> > >> > > On Fri-10/24/14-2014 10:20, Paul E. McKenney wrote:
> > >
> > >[ . . . ]
> > >
> > >> > > > Well, if you are feeling aggressive, give the following patch a spin.
> > >> > > > I am doing sanity tests on it in the meantime.
> > >> > > 
> > >> > > Doesn't seem to make a difference here
> > >> > 
> > >> > OK, inspection isn't cutting it, so time for tracing.  Does the system
> > >> > respond to user input?  If so, please enable rcu:rcu_barrier ftrace before
> > >> > the problem occurs, then dump the trace buffer after the problem occurs.
> > >> 
> > >> Sorry for being unresposive here, but I know next to nothing about tracing
> > >> or most things about the kernel, so I have some cathing up to do.
> > >> 
> > >> In the meantime some layman observations while I tried to find what exactly
> > >> triggers the problem.
> > >> - Even in runlevel 1 I can reliably trigger the problem by starting libvirtd
> > >> - libvirtd seems to be very active in using all sorts of kernel facilities
> > >>   that are modules on fedora so it seems to cause many simultaneous kworker 
> > >>   calls to modprobe
> > >> - there are 8 kworker/u16 from 0 to 7
> > >> - one of these kworkers always deadlocks, while there appear to be two
> > >>   kworker/u16:6 - the seventh
> > >
> > >Adding Tejun on CC in case this duplication of kworker/u16:6 is important.
> > >
> > >>   6 vs 8 as in 6 rcuos where before they were always 8
> > >> 
> > >> Just observations from someone who still doesn't know what the u16
> > >> kworkers are..
> > >
> > >Could you please run the following diagnostic patch?  This will help
> > >me see if I have managed to miswire the rcuo kthreads.  It should
> > >print some information at task-hang time.
> > 
> > 	Here's the output of the patch; I let it sit through two hang
> > cycles.
> > 
> > 	-J
> > 
> > 
> > [  240.348020] INFO: task ovs-vswitchd:902 blocked for more than 120 seconds.
> > [  240.354878]       Not tainted 3.17.0-testola+ #4
> > [  240.359481] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> > [  240.367285] ovs-vswitchd    D ffff88013fc94600     0   902    901 0x00000004
> > [  240.367290]  ffff8800ab20f7b8 0000000000000002 ffff8800b3304b00 ffff8800ab20ffd8
> > [  240.367293]  0000000000014600 0000000000014600 ffff8800b0810000 ffff8800b3304b00
> > [  240.367296]  ffff8800b3304b00 ffffffff81c59850 ffffffff81c59858 7fffffffffffffff
> > [  240.367300] Call Trace:
> > [  240.367307]  [<ffffffff81722b99>] schedule+0x29/0x70
> > [  240.367310]  [<ffffffff81725b6c>] schedule_timeout+0x1dc/0x260
> > [  240.367313]  [<ffffffff81722f69>] ? _cond_resched+0x29/0x40
> > [  240.367316]  [<ffffffff81723818>] ? wait_for_completion+0x28/0x160
> > [  240.367321]  [<ffffffff811081a7>] ? queue_stop_cpus_work+0xc7/0xe0
> > [  240.367324]  [<ffffffff81723896>] wait_for_completion+0xa6/0x160
> > [  240.367328]  [<ffffffff81099980>] ? wake_up_state+0x20/0x20
> > [  240.367331]  [<ffffffff810d0ecc>] _rcu_barrier+0x20c/0x480
> > [  240.367334]  [<ffffffff810d1195>] rcu_barrier+0x15/0x20
> > [  240.367338]  [<ffffffff81625010>] netdev_run_todo+0x60/0x300
> > [  240.367341]  [<ffffffff8162f9ee>] rtnl_unlock+0xe/0x10
> > [  240.367349]  [<ffffffffa01ffcc5>] internal_dev_destroy+0x55/0x80 [openvswitch]
> > [  240.367354]  [<ffffffffa01ff622>] ovs_vport_del+0x32/0x40 [openvswitch]
> > [  240.367358]  [<ffffffffa01f8dd0>] ovs_dp_detach_port+0x30/0x40 [openvswitch]
> > [  240.367363]  [<ffffffffa01f8ea5>] ovs_vport_cmd_del+0xc5/0x110 [openvswitch]
> > [  240.367367]  [<ffffffff81651d75>] genl_family_rcv_msg+0x1a5/0x3c0
> > [  240.367370]  [<ffffffff81651f90>] ? genl_family_rcv_msg+0x3c0/0x3c0
> > [  240.367372]  [<ffffffff81652021>] genl_rcv_msg+0x91/0xd0
> > [  240.367376]  [<ffffffff81650091>] netlink_rcv_skb+0xc1/0xe0
> > [  240.367378]  [<ffffffff816505bc>] genl_rcv+0x2c/0x40
> > [  240.367381]  [<ffffffff8164f626>] netlink_unicast+0xf6/0x200
> > [  240.367383]  [<ffffffff8164fa4d>] netlink_sendmsg+0x31d/0x780
> > [  240.367387]  [<ffffffff8164ca74>] ? netlink_rcv_wake+0x44/0x60
> > [  240.367391]  [<ffffffff81606a53>] sock_sendmsg+0x93/0xd0
> > [  240.367395]  [<ffffffff81337700>] ? apparmor_capable+0x60/0x60
> > [  240.367399]  [<ffffffff81614f27>] ? verify_iovec+0x47/0xd0
> > [  240.367402]  [<ffffffff81606e79>] ___sys_sendmsg+0x399/0x3b0
> > [  240.367406]  [<ffffffff812598a2>] ? kernfs_seq_stop_active+0x32/0x40
> > [  240.367410]  [<ffffffff8101c385>] ? native_sched_clock+0x35/0x90
> > [  240.367413]  [<ffffffff8101c385>] ? native_sched_clock+0x35/0x90
> > [  240.367416]  [<ffffffff8101c3e9>] ? sched_clock+0x9/0x10
> > [  240.367420]  [<ffffffff811277fc>] ? acct_account_cputime+0x1c/0x20
> > [  240.367424]  [<ffffffff8109ce6b>] ? account_user_time+0x8b/0xa0
> > [  240.367428]  [<ffffffff81200bd5>] ? __fget_light+0x25/0x70
> > [  240.367431]  [<ffffffff81607c02>] __sys_sendmsg+0x42/0x80
> > [  240.367433]  [<ffffffff81607c52>] SyS_sendmsg+0x12/0x20
> > [  240.367436]  [<ffffffff81727464>] tracesys_phase2+0xd8/0xdd
> > [  240.367439] rcu_show_nocb_setup(): rcu_sched nocb state:
> > [  240.372734]   0: ffff88013fc0e600 l:ffff88013fc0e600 n:ffff88013fc8e600 .G.
> > [  240.379673]   1: ffff88013fc8e600 l:ffff88013fc0e600 n:          (null) .G.
> > [  240.386611]   2: ffff88013fd0e600 l:ffff88013fd0e600 n:ffff88013fd8e600 N..
> > [  240.393550]   3: ffff88013fd8e600 l:ffff88013fd0e600 n:          (null) N..
> > [  240.400489] rcu_show_nocb_setup(): rcu_bh nocb state:
> > [  240.405525]   0: ffff88013fc0e3c0 l:ffff88013fc0e3c0 n:ffff88013fc8e3c0 ...
> > [  240.412463]   1: ffff88013fc8e3c0 l:ffff88013fc0e3c0 n:          (null) ...
> > [  240.419401]   2: ffff88013fd0e3c0 l:ffff88013fd0e3c0 n:ffff88013fd8e3c0 ...
> > [  240.426339]   3: ffff88013fd8e3c0 l:ffff88013fd0e3c0 n:          (null) ...
> > [  360.432020] INFO: task ovs-vswitchd:902 blocked for more than 120 seconds.
> > [  360.438881]       Not tainted 3.17.0-testola+ #4
> > [  360.443484] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> > [  360.451289] ovs-vswitchd    D ffff88013fc94600     0   902    901 0x00000004
> > [  360.451293]  ffff8800ab20f7b8 0000000000000002 ffff8800b3304b00 ffff8800ab20ffd8
> > [  360.451297]  0000000000014600 0000000000014600 ffff8800b0810000 ffff8800b3304b00
> > [  360.451300]  ffff8800b3304b00 ffffffff81c59850 ffffffff81c59858 7fffffffffffffff
> > [  360.451303] Call Trace:
> > [  360.451311]  [<ffffffff81722b99>] schedule+0x29/0x70
> > [  360.451314]  [<ffffffff81725b6c>] schedule_timeout+0x1dc/0x260
> > [  360.451317]  [<ffffffff81722f69>] ? _cond_resched+0x29/0x40
> > [  360.451320]  [<ffffffff81723818>] ? wait_for_completion+0x28/0x160
> > [  360.451325]  [<ffffffff811081a7>] ? queue_stop_cpus_work+0xc7/0xe0
> > [  360.451327]  [<ffffffff81723896>] wait_for_completion+0xa6/0x160
> > [  360.451331]  [<ffffffff81099980>] ? wake_up_state+0x20/0x20
> > [  360.451335]  [<ffffffff810d0ecc>] _rcu_barrier+0x20c/0x480
> > [  360.451338]  [<ffffffff810d1195>] rcu_barrier+0x15/0x20
> > [  360.451342]  [<ffffffff81625010>] netdev_run_todo+0x60/0x300
> > [  360.451345]  [<ffffffff8162f9ee>] rtnl_unlock+0xe/0x10
> > [  360.451353]  [<ffffffffa01ffcc5>] internal_dev_destroy+0x55/0x80 [openvswitch]
> > [  360.451358]  [<ffffffffa01ff622>] ovs_vport_del+0x32/0x40 [openvswitch]
> > [  360.451362]  [<ffffffffa01f8dd0>] ovs_dp_detach_port+0x30/0x40 [openvswitch]
> > [  360.451366]  [<ffffffffa01f8ea5>] ovs_vport_cmd_del+0xc5/0x110 [openvswitch]
> > [  360.451370]  [<ffffffff81651d75>] genl_family_rcv_msg+0x1a5/0x3c0
> > [  360.451373]  [<ffffffff81651f90>] ? genl_family_rcv_msg+0x3c0/0x3c0
> > [  360.451376]  [<ffffffff81652021>] genl_rcv_msg+0x91/0xd0
> > [  360.451379]  [<ffffffff81650091>] netlink_rcv_skb+0xc1/0xe0
> > [  360.451381]  [<ffffffff816505bc>] genl_rcv+0x2c/0x40
> > [  360.451384]  [<ffffffff8164f626>] netlink_unicast+0xf6/0x200
> > [  360.451387]  [<ffffffff8164fa4d>] netlink_sendmsg+0x31d/0x780
> > [  360.451390]  [<ffffffff8164ca74>] ? netlink_rcv_wake+0x44/0x60
> > [  360.451394]  [<ffffffff81606a53>] sock_sendmsg+0x93/0xd0
> > [  360.451399]  [<ffffffff81337700>] ? apparmor_capable+0x60/0x60
> > [  360.451402]  [<ffffffff81614f27>] ? verify_iovec+0x47/0xd0
> > [  360.451406]  [<ffffffff81606e79>] ___sys_sendmsg+0x399/0x3b0
> > [  360.451410]  [<ffffffff812598a2>] ? kernfs_seq_stop_active+0x32/0x40
> > [  360.451414]  [<ffffffff8101c385>] ? native_sched_clock+0x35/0x90
> > [  360.451417]  [<ffffffff8101c385>] ? native_sched_clock+0x35/0x90
> > [  360.451419]  [<ffffffff8101c3e9>] ? sched_clock+0x9/0x10
> > [  360.451424]  [<ffffffff811277fc>] ? acct_account_cputime+0x1c/0x20
> > [  360.451427]  [<ffffffff8109ce6b>] ? account_user_time+0x8b/0xa0
> > [  360.451431]  [<ffffffff81200bd5>] ? __fget_light+0x25/0x70
> > [  360.451434]  [<ffffffff81607c02>] __sys_sendmsg+0x42/0x80
> > [  360.451437]  [<ffffffff81607c52>] SyS_sendmsg+0x12/0x20
> > [  360.451440]  [<ffffffff81727464>] tracesys_phase2+0xd8/0xdd
> > [  360.451442] rcu_show_nocb_setup(): rcu_sched nocb state:
> > [  360.456737]   0: ffff88013fc0e600 l:ffff88013fc0e600 n:ffff88013fc8e600 ...
> > [  360.463676]   1: ffff88013fc8e600 l:ffff88013fc0e600 n:          (null) ...
> > [  360.470614]   2: ffff88013fd0e600 l:ffff88013fd0e600 n:ffff88013fd8e600 N..
> > [  360.477554]   3: ffff88013fd8e600 l:ffff88013fd0e600 n:          (null) N..
> 
> Hmmm...  It sure looks like we have some callbacks stuck here.  I clearly
> need to take a hard look at the sleep/wakeup code.
> 
> Thank you for running this!!!

Could you please try the following patch?  If no joy, could you please
add rcu:rcu_nocb_wake to the list of ftrace events?

							Thanx, Paul

------------------------------------------------------------------------

rcu: Kick rcuo kthreads after their CPU goes offline

If a no-CBs CPU were to post an RCU callback with interrupts disabled
after it entered the idle loop for the last time, there might be no
deferred wakeup for the corresponding rcuo kthreads.  This commit
therefore adds a set of calls to do_nocb_deferred_wakeup() after the
CPU has gone completely offline.

Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

diff --git a/kernel/rcu/tree.c b/kernel/rcu/tree.c
index 84b41b3c6ebd..f6880052b917 100644
--- a/kernel/rcu/tree.c
+++ b/kernel/rcu/tree.c
@@ -3493,8 +3493,10 @@ static int rcu_cpu_notify(struct notifier_block *self,
 	case CPU_DEAD_FROZEN:
 	case CPU_UP_CANCELED:
 	case CPU_UP_CANCELED_FROZEN:
-		for_each_rcu_flavor(rsp)
+		for_each_rcu_flavor(rsp) {
 			rcu_cleanup_dead_cpu(cpu, rsp);
+			do_nocb_deferred_wakeup(per_cpu_ptr(rsp->rda, cpu));
+		}
 		break;
 	default:
 		break;

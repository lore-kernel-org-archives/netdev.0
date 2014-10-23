From: Yanko Kaneti <yaneti@declera.com>
Subject: Re: localed stuck in recent 3.18 git in copy_net_ns?
Date: Thu, 23 Oct 2014 09:09:26 +0300
Message-ID: <1414044566.2031.1.camel@declera.com>
References: <20141020145359.565fe5e6@voldemort.scrye.com>
	 <20141021151225.5df96645@voldemort.scrye.com>
	 <CA+5PVA7Ro_ejBUqsZ9StWVeu59==fGnj6e4Gx8zM4_3+Lq5s4A@mail.gmail.com>
	 <CAHA+R7OUHy8XFPoip5gPvr1uqwkxgKxoSMf_pSgB1aFx=XCs8g@mail.gmail.com>
	 <8738aghtyj.fsf@x220.int.ebiederm.org>
	 <20141022181135.GH4977@linux.vnet.ibm.com>
	 <87d29kezby.fsf@x220.int.ebiederm.org>
	 <20141022185511.GI4977@linux.vnet.ibm.com>
	 <CA+5PVA56ajrBQ-C9orSb9-_qhMKe994QL2x0FcKbe6BYmaWFBw@mail.gmail.com>
	 <20141022224032.GA1240@declera.com>
	 <20141022232421.GN4977@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Josh Boyer <jwboyer@fedoraproject.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Cong Wang <cwang@twopensource.com>,
	Kevin Fenzi <kevin@scrye.com>, netdev <netdev@vger.kernel.org>,
	"Linux-Kernel@Vger. Kernel. Org" <linux-kernel@vger.kernel.org>
To: paulmck@linux.vnet.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141022232421.GN4977@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2014-10-22 at 16:24 -0700, Paul E. McKenney wrote:
> On Thu, Oct 23, 2014 at 01:40:32AM +0300, Yanko Kaneti wrote:
> > On Wed-10/22/14-2014 15:33, Josh Boyer wrote:
> > > On Wed, Oct 22, 2014 at 2:55 PM, Paul E. McKenney
> > > <paulmck@linux.vnet.ibm.com> wrote:
> 
> [ . . . ]
> 
> > > > Don't get me wrong -- the fact that this kthread appears to 
> > > > have
> > > > blocked within rcu_barrier() for 120 seconds means that 
> > > > something is
> > > > most definitely wrong here.  I am surprised that there are no 
> > > > RCU CPU
> > > > stall warnings, but perhaps the blockage is in the callback 
> > > > execution
> > > > rather than grace-period completion.  Or something is 
> > > > preventing this
> > > > kthread from starting up after the wake-up callback executes.  
> > > > Or...
> > > > 
> > > > Is this thing reproducible?
> > > 
> > > I've added Yanko on CC, who reported the backtrace above and can
> > > recreate it reliably.  Apparently reverting the RCU merge commit
> > > (d6dd50e) and rebuilding the latest after that does not show the
> > > issue.  I'll let Yanko explain more and answer any questions you 
> > > have.
> > 
> > - It is reproducible
> > - I've done another build here to double check and its definitely 
> > the rcu merge
> >   that's causing it.
> > 
> > Don't think I'll be able to dig deeper, but I can do testing if 
> > needed.
> 
> Please!  Does the following patch help?

Nope, doesn't seem to make a difference to the modprobe ppp_generic 
test


INFO: task kworker/u16:6:101 blocked for more than 120 seconds.
      Not tainted 3.18.0-0.rc1.git2.3.fc22.x86_64 #1
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this 
message.
kworker/u16:6   D ffff88022067cec0 11680   101      2 0x00000000
Workqueue: netns cleanup_net
 ffff8802206939e8 0000000000000096 ffff88022067cec0 00000000001d5f00
 ffff880220693fd8 00000000001d5f00 ffff880223263480 ffff88022067cec0
 ffffffff82c51d60 7fffffffffffffff ffffffff81ee2698 ffffffff81ee2690
Call Trace:
 [<ffffffff8185e289>] schedule+0x29/0x70
 [<ffffffff818634ac>] schedule_timeout+0x26c/0x410
 [<ffffffff81028c4a>] ? native_sched_clock+0x2a/0xa0
 [<ffffffff81107afc>] ? mark_held_locks+0x7c/0xb0
 [<ffffffff81864530>] ? _raw_spin_unlock_irq+0x30/0x50
 [<ffffffff81107c8d>] ? trace_hardirqs_on_caller+0x15d/0x200
 [<ffffffff8185fcbc>] wait_for_completion+0x10c/0x150
 [<ffffffff810e5430>] ? wake_up_state+0x20/0x20
 [<ffffffff8112a799>] _rcu_barrier+0x159/0x200
 [<ffffffff8112a895>] rcu_barrier+0x15/0x20
 [<ffffffff81718f0f>] netdev_run_todo+0x6f/0x310
 [<ffffffff8170dad5>] ? rollback_registered_many+0x265/0x2e0
 [<ffffffff81725f7e>] rtnl_unlock+0xe/0x10
 [<ffffffff8170f936>] default_device_exit_batch+0x156/0x180
 [<ffffffff810fd8f0>] ? abort_exclusive_wait+0xb0/0xb0
 [<ffffffff817079e3>] ops_exit_list.isra.1+0x53/0x60
 [<ffffffff81708590>] cleanup_net+0x100/0x1f0
 [<ffffffff810ccff8>] process_one_work+0x218/0x850
 [<ffffffff810ccf5f>] ? process_one_work+0x17f/0x850
 [<ffffffff810cd717>] ? worker_thread+0xe7/0x4a0
 [<ffffffff810cd69b>] worker_thread+0x6b/0x4a0
 [<ffffffff810cd630>] ? process_one_work+0x850/0x850
 [<ffffffff810d39eb>] kthread+0x10b/0x130
 [<ffffffff81028cc9>] ? sched_clock+0x9/0x10
 [<ffffffff810d38e0>] ? kthread_create_on_node+0x250/0x250
 [<ffffffff8186527c>] ret_from_fork+0x7c/0xb0
 [<ffffffff810d38e0>] ? kthread_create_on_node+0x250/0x250
4 locks held by kworker/u16:6/101:
 #0:  ("%s""netns"){.+.+.+}, at: [<ffffffff810ccf5f>] process_one_work+0x17f/0x850
 #1:  (net_cleanup_work){+.+.+.}, at: [<ffffffff810ccf5f>] process_one_work+0x17f/0x850
 #2:  (net_mutex){+.+.+.}, at: [<ffffffff8170851c>] cleanup_net+0x8c/0x1f0
 #3:  (rcu_sched_state.barrier_mutex){+.+...}, at: [<ffffffff8112a675>] _rcu_barrier+0x35/0x200
INFO: task modprobe:1139 blocked for more than 120 seconds.
      Not tainted 3.18.0-0.rc1.git2.3.fc22.x86_64 #1
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this 
message.
modprobe        D ffff880213ac1a40 13112  1139   1138 0x00000080
 ffff880036ab3be8 0000000000000096 ffff880213ac1a40 00000000001d5f00
 ffff880036ab3fd8 00000000001d5f00 ffff880223264ec0 ffff880213ac1a40
 ffff880213ac1a40 ffffffff81f8fb48 0000000000000246 ffff880213ac1a40
Call Trace:
 [<ffffffff8185e831>] schedule_preempt_disabled+0x31/0x80
 [<ffffffff81860083>] mutex_lock_nested+0x183/0x440
 [<ffffffff817083af>] ? register_pernet_subsys+0x1f/0x50
 [<ffffffff817083af>] ? register_pernet_subsys+0x1f/0x50
 [<ffffffffa06f3000>] ? 0xffffffffa06f3000
 [<ffffffff817083af>] register_pernet_subsys+0x1f/0x50
 [<ffffffffa06f3048>] br_init+0x48/0xd3 [bridge]
 [<ffffffff81002148>] do_one_initcall+0xd8/0x210
 [<ffffffff81153c52>] load_module+0x20c2/0x2870
 [<ffffffff8114ec30>] ? store_uevent+0x70/0x70
 [<ffffffff8110ac76>] ? lock_release_non_nested+0x3c6/0x3d0
 [<ffffffff811544e7>] SyS_init_module+0xe7/0x140
 [<ffffffff81865329>] system_call_fastpath+0x12/0x17
1 lock held by modprobe/1139:
 #0:  (net_mutex){+.+.+.}, at: [<ffffffff817083af>] 
register_pernet_subsys+0x1f/0x50
INFO: task modprobe:1209 blocked for more than 120 seconds.
      Not tainted 3.18.0-0.rc1.git2.3.fc22.x86_64 #1
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this 
message.
modprobe        D ffff8800c5324ec0 13368  1209   1151 0x00000080
 ffff88020d14bbe8 0000000000000096 ffff8800c5324ec0 00000000001d5f00
 ffff88020d14bfd8 00000000001d5f00 ffff880223280000 ffff8800c5324ec0
 ffff8800c5324ec0 ffffffff81f8fb48 0000000000000246 ffff8800c5324ec0
Call Trace:
 [<ffffffff8185e831>] schedule_preempt_disabled+0x31/0x80
 [<ffffffff81860083>] mutex_lock_nested+0x183/0x440
 [<ffffffff817083fd>] ? register_pernet_device+0x1d/0x70
 [<ffffffff817083fd>] ? register_pernet_device+0x1d/0x70
 [<ffffffffa070f000>] ? 0xffffffffa070f000
 [<ffffffff817083fd>] register_pernet_device+0x1d/0x70
 [<ffffffffa070f020>] ppp_init+0x20/0x1000 [ppp_generic]
 [<ffffffff81002148>] do_one_initcall+0xd8/0x210
 [<ffffffff81153c52>] load_module+0x20c2/0x2870
 [<ffffffff8114ec30>] ? store_uevent+0x70/0x70
 [<ffffffff8110ac76>] ? lock_release_non_nested+0x3c6/0x3d0
 [<ffffffff811544e7>] SyS_init_module+0xe7/0x140
 [<ffffffff81865329>] system_call_fastpath+0x12/0x17
1 lock held by modprobe/1209:
 #0:  (net_mutex){+.+.+.}, at: [<ffffffff817083fd>] register_pernet_device+0x1d/0x70


>                 Thanx, Paul
> 
> ---------------------------------------------------------------------
> ---
> 
> rcu: More on deadlock between CPU hotplug and expedited grace periods
> 
> Commit dd56af42bd82 (rcu: Eliminate deadlock between CPU hotplug and
> expedited grace periods) was incomplete.  Although it did eliminate
> deadlocks involving synchronize_sched_expedited()'s acquisition of
> cpu_hotplug.lock via get_online_cpus(), it did nothing about the 
> similar
> deadlock involving acquisition of this same lock via 
> put_online_cpus().
> This deadlock became apparent with testing involving hibernation.
> 
> This commit therefore changes put_online_cpus() acquisition of this 
> lock
> to be conditional, and increments a new cpu_hotplug.puts_pending 
> field
> in case of acquisition failure.  Then cpu_hotplug_begin() checks for 
> this
> new field being non-zero, and applies any changes to 
> cpu_hotplug.refcount.
> 
> Reported-by: Jiri Kosina <jkosina@suse.cz>
> Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> Tested-by: Jiri Kosina <jkosina@suse.cz>
> 
> diff --git a/kernel/cpu.c b/kernel/cpu.c
> index 356450f09c1f..90a3d017b90c 100644
> --- a/kernel/cpu.c
> +++ b/kernel/cpu.c
> @@ -64,6 +64,8 @@ static struct {
>         * an ongoing cpu hotplug operation.
>         */
>         int refcount;
> +       /* And allows lockless put_online_cpus(). */
> +       atomic_t puts_pending;
> 
>  #ifdef CONFIG_DEBUG_LOCK_ALLOC
>         struct lockdep_map dep_map;
> @@ -113,7 +115,11 @@ void put_online_cpus(void)
>  {
>         if (cpu_hotplug.active_writer == current)
>         return;
> -       mutex_lock(&cpu_hotplug.lock);
> +       if (!mutex_trylock(&cpu_hotplug.lock)) {
> +       atomic_inc(&cpu_hotplug.puts_pending);
> +       cpuhp_lock_release();
> +       return;
> +       }
> 
>         if (WARN_ON(!cpu_hotplug.refcount))
>         cpu_hotplug.refcount++; /* try to fix things up */
> @@ -155,6 +161,12 @@ void cpu_hotplug_begin(void)
>         cpuhp_lock_acquire();
>         for (;;) {
>         mutex_lock(&cpu_hotplug.lock);
> +       if (atomic_read(&cpu_hotplug.puts_pending)) {
> +       int delta;
> +
> +       delta = atomic_xchg(&cpu_hotplug.puts_pending, 0);
> +       cpu_hotplug.refcount -= delta;
> +       }
>         if (likely(!cpu_hotplug.refcount))
>         break;
>         __set_current_state(TASK_UNINTERRUPTIBLE);
> 
> 

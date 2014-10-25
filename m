From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: localed stuck in recent 3.18 git in copy_net_ns?
Date: Fri, 24 Oct 2014 22:16:02 -0700
Message-ID: <20141025051602.GB28247@linux.vnet.ibm.com>
References: <20141024173526.GA26058@declera.com>
 <20141024183226.GW4977@linux.vnet.ibm.com>
 <20141024212557.GA15537@declera.com>
 <20141024214927.GA4977@linux.vnet.ibm.com>
 <8915.1414190047@famine>
 <20141024225931.GC4977@linux.vnet.ibm.com>
 <20141024230524.GA16023@linux.vnet.ibm.com>
 <10136.1414196448@famine>
 <20141025020324.GA28247@linux.vnet.ibm.com>
 <11813.1414211613@famine>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <11813.1414211613@famine>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 24, 2014 at 09:33:33PM -0700, Jay Vosburgh wrote:
> Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:
> 
> >On Fri, Oct 24, 2014 at 05:20:48PM -0700, Jay Vosburgh wrote:
> >> Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:
> >> 
> >> >On Fri, Oct 24, 2014 at 03:59:31PM -0700, Paul E. McKenney wrote:
> >> [...]
> >> >> Hmmm...  It sure looks like we have some callbacks stuck here.  I clearly
> >> >> need to take a hard look at the sleep/wakeup code.
> >> >> 
> >> >> Thank you for running this!!!
> >> >
> >> >Could you please try the following patch?  If no joy, could you please
> >> >add rcu:rcu_nocb_wake to the list of ftrace events?
> >> 
> >> 	I tried the patch, it did not change the behavior.
> >> 
> >> 	I enabled the rcu:rcu_barrier and rcu:rcu_nocb_wake tracepoints
> >> and ran it again (with this patch and the first patch from earlier
> >> today); the trace output is a bit on the large side so I put it and the
> >> dmesg log at:
> >> 
> >> http://people.canonical.com/~jvosburgh/nocb-wake-dmesg.txt
> >> 
> >> http://people.canonical.com/~jvosburgh/nocb-wake-trace.txt
> >
> >Thank you again!
> >
> >Very strange part of the trace.  The only sign of CPU 2 and 3 are:
> >
> >    ovs-vswitchd-902   [000] ....   109.896840: rcu_barrier: rcu_sched Begin cpu -1 remaining 0 # 0
> >    ovs-vswitchd-902   [000] ....   109.896840: rcu_barrier: rcu_sched Check cpu -1 remaining 0 # 0
> >    ovs-vswitchd-902   [000] ....   109.896841: rcu_barrier: rcu_sched Inc1 cpu -1 remaining 0 # 1
> >    ovs-vswitchd-902   [000] ....   109.896841: rcu_barrier: rcu_sched OnlineNoCB cpu 0 remaining 1 # 1
> >    ovs-vswitchd-902   [000] d...   109.896841: rcu_nocb_wake: rcu_sched 0 WakeNot
> >    ovs-vswitchd-902   [000] ....   109.896841: rcu_barrier: rcu_sched OnlineNoCB cpu 1 remaining 2 # 1
> >    ovs-vswitchd-902   [000] d...   109.896841: rcu_nocb_wake: rcu_sched 1 WakeNot
> >    ovs-vswitchd-902   [000] ....   109.896842: rcu_barrier: rcu_sched OnlineNoCB cpu 2 remaining 3 # 1
> >    ovs-vswitchd-902   [000] d...   109.896842: rcu_nocb_wake: rcu_sched 2 WakeNotPoll
> >    ovs-vswitchd-902   [000] ....   109.896842: rcu_barrier: rcu_sched OnlineNoCB cpu 3 remaining 4 # 1
> >    ovs-vswitchd-902   [000] d...   109.896842: rcu_nocb_wake: rcu_sched 3 WakeNotPoll
> >    ovs-vswitchd-902   [000] ....   109.896843: rcu_barrier: rcu_sched Inc2 cpu -1 remaining 4 # 2
> >
> >The pair of WakeNotPoll trace entries says that at that point, RCU believed
> >that the CPU 2's and CPU 3's rcuo kthreads did not exist.  :-/
> 
> 	On the test system I'm using, CPUs 2 and 3 really do not exist;
> it is a 2 CPU system (Intel Core 2 Duo E8400). I mentioned this in an
> earlier message, but perhaps you missed it in the flurry.

Or forgot it.  Either way, thank you for reminding me.

> 	Looking at the dmesg, the early boot messages seem to be
> confused as to how many CPUs there are, e.g.,
> 
> [    0.000000] SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=4, Nodes=1
> [    0.000000] Hierarchical RCU implementation.
> [    0.000000]  RCU debugfs-based tracing is enabled.
> [    0.000000]  RCU dyntick-idle grace-period acceleration is enabled.
> [    0.000000]  RCU restricting CPUs from NR_CPUS=256 to nr_cpu_ids=4.
> [    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=16, nr_cpu_ids=4
> [    0.000000] NR_IRQS:16640 nr_irqs:456 0
> [    0.000000]  Offload RCU callbacks from all CPUs
> [    0.000000]  Offload RCU callbacks from CPUs: 0-3.
> 
> 	but later shows 2:
> 
> [    0.233703] x86: Booting SMP configuration:
> [    0.236003] .... node  #0, CPUs:      #1
> [    0.255528] x86: Booted up 1 node, 2 CPUs
> 
> 	In any event, the E8400 is a 2 core CPU with no hyperthreading.

Well, this might explain some of the difficulties.  If RCU decides to wait
on CPUs that don't exist, we will of course get a hang.  And rcu_barrier()
was definitely expecting four CPUs.

So what happens if you boot with maxcpus=2?  (Or build with
CONFIG_NR_CPUS=2.) I suspect that this might avoid the hang.  If so,
I might have some ideas for a real fix.

							Thanx, Paul

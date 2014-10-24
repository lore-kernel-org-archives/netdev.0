From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: localed stuck in recent 3.18 git in copy_net_ns?
Date: Fri, 24 Oct 2014 15:16:02 -0700
Message-ID: <20141024221602.GB4977@linux.vnet.ibm.com>
References: <20141024154006.GP4977@linux.vnet.ibm.com>
 <20141024162943.GA16621@declera.com>
 <20141024165454.GS4977@linux.vnet.ibm.com>
 <20141024170931.GA21849@declera.com>
 <20141024172009.GV4977@linux.vnet.ibm.com>
 <20141024173526.GA26058@declera.com>
 <20141024183226.GW4977@linux.vnet.ibm.com>
 <20141024212557.GA15537@declera.com>
 <20141024214927.GA4977@linux.vnet.ibm.com>
 <8451.1414188124@famine>
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
In-Reply-To: <8451.1414188124@famine>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 24, 2014 at 03:02:04PM -0700, Jay Vosburgh wrote:
> Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:
> 
> >On Sat, Oct 25, 2014 at 12:25:57AM +0300, Yanko Kaneti wrote:
> >> On Fri-10/24/14-2014 11:32, Paul E. McKenney wrote:
> >> > On Fri, Oct 24, 2014 at 08:35:26PM +0300, Yanko Kaneti wrote:
> >> > > On Fri-10/24/14-2014 10:20, Paul E. McKenney wrote:
> >
> >[ . . . ]
> >
> >> > > > Well, if you are feeling aggressive, give the following patch a spin.
> >> > > > I am doing sanity tests on it in the meantime.
> >> > > 
> >> > > Doesn't seem to make a difference here
> >> > 
> >> > OK, inspection isn't cutting it, so time for tracing.  Does the system
> >> > respond to user input?  If so, please enable rcu:rcu_barrier ftrace before
> >> > the problem occurs, then dump the trace buffer after the problem occurs.
> >> 
> >> Sorry for being unresposive here, but I know next to nothing about tracing
> >> or most things about the kernel, so I have some cathing up to do.
> >> 
> >> In the meantime some layman observations while I tried to find what exactly
> >> triggers the problem.
> >> - Even in runlevel 1 I can reliably trigger the problem by starting libvirtd
> >> - libvirtd seems to be very active in using all sorts of kernel facilities
> >>   that are modules on fedora so it seems to cause many simultaneous kworker 
> >>   calls to modprobe
> >> - there are 8 kworker/u16 from 0 to 7
> >> - one of these kworkers always deadlocks, while there appear to be two
> >>   kworker/u16:6 - the seventh
> >
> >Adding Tejun on CC in case this duplication of kworker/u16:6 is important.
> >
> >>   6 vs 8 as in 6 rcuos where before they were always 8
> >> 
> >> Just observations from someone who still doesn't know what the u16
> >> kworkers are..
> >
> >Could you please run the following diagnostic patch?  This will help
> >me see if I have managed to miswire the rcuo kthreads.  It should
> >print some information at task-hang time.
> 
> 	I can give this a spin after the ftrace (now that I've got
> CONFIG_RCU_TRACE turned on).
> 
> 	I've got an ftrace capture from unmodified -net, it looks like
> this:
> 
>     ovs-vswitchd-902   [000] ....   471.778441: rcu_barrier: rcu_sched Begin cpu -1 remaining 0 # 0
>     ovs-vswitchd-902   [000] ....   471.778452: rcu_barrier: rcu_sched Check cpu -1 remaining 0 # 0
>     ovs-vswitchd-902   [000] ....   471.778452: rcu_barrier: rcu_sched Inc1 cpu -1 remaining 0 # 1
>     ovs-vswitchd-902   [000] ....   471.778453: rcu_barrier: rcu_sched OnlineNoCB cpu 0 remaining 1 # 1
>     ovs-vswitchd-902   [000] ....   471.778453: rcu_barrier: rcu_sched OnlineNoCB cpu 1 remaining 2 # 1
>     ovs-vswitchd-902   [000] ....   471.778453: rcu_barrier: rcu_sched OnlineNoCB cpu 2 remaining 3 # 1
>     ovs-vswitchd-902   [000] ....   471.778454: rcu_barrier: rcu_sched OnlineNoCB cpu 3 remaining 4 # 1

OK, so it looks like your system has four CPUs, and rcu_barrier() placed
callbacks on them all.

>     ovs-vswitchd-902   [000] ....   471.778454: rcu_barrier: rcu_sched Inc2 cpu -1 remaining 4 # 2

The above removes the extra count used to avoid races between posting new
callbacks and completion of previously posted callbacks.

>          rcuos/0-9     [000] ..s.   471.793150: rcu_barrier: rcu_sched CB cpu -1 remaining 3 # 2
>          rcuos/1-18    [001] ..s.   471.793308: rcu_barrier: rcu_sched CB cpu -1 remaining 2 # 2

Two of the four callbacks fired, but the other two appear to be AWOL.
And rcu_barrier() won't return until they all fire.

> 	I let it sit through several "hung task" cycles but that was all
> there was for rcu:rcu_barrier.
> 
> 	I should have ftrace with the patch as soon as the kernel is
> done building, then I can try the below patch (I'll start it building
> now).

Sounds very good, looking forward to hearing of the results.

							Thanx, Paul

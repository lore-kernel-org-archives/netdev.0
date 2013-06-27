From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 15/45] rcu: Use get/put_online_cpus_atomic() to prevent
 CPU offline
Date: Thu, 27 Jun 2013 12:23:43 +0530
Message-ID: <51CBE177.90502@linux.vnet.ibm.com>
References: <20130625202755.16593.67819.stgit@srivatsabhat.in.ibm.com> <20130625220026.GG3828@linux.vnet.ibm.com> <51CAF624.6060004@linux.vnet.ibm.com> <AE90C24D6B3A694183C094C60CF0A2F6026B72AA@saturn3.aculab.com> <20130626143424.GN3828@linux.vnet.ibm.com> <1372258271.18733.256.camel@gandalf.local.home> <20130626152148.GA4405@mtj.dyndns.org> <1372260823.18733.263.camel@gandalf.local.home> <20130626172948.GD4405@mtj.dyndns.org> <51CB32E0.3040106@linux.vnet.ibm.com> <20130626213458.GC4536@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Steven Rostedt <rostedt@goodmis.org>, peterz@infradead.org,
	fweisbec@gmail.com, oleg@redhat.com, walken@google.com,
	mingo@kernel.org, linux-arch@vger.kernel.org,
	vincent.guittot@linaro.org, xiaoguangrong@linux.vnet.ibm.com,
	wangyun@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com,
	nikunj@linux.vnet.ibm.com, linux-pm@vger.kernel.org,
	rusty@rustcorp.com.au, namhyung@kernel.org, tglx@linutronix.de,
	laijs@cn.fujitsu.com, zhong@linux.vnet.ibm.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org, sbw@mit.edu,
	David Laight <David.Laight@ACULAB.COM>,
	akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130626213458.GC4536@htj.dyndns.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/27/2013 03:04 AM, Tejun Heo wrote:
> Hey,
> 
> On Wed, Jun 26, 2013 at 11:58:48PM +0530, Srivatsa S. Bhat wrote:
>> Yes, we were discussing hot-unplug latency for use-cases such as
>> suspend/resume. We didn't want to make those operations slower in the
>> process of removing stop_machine() from hotplug.
> 
> Can you please explain why tho?

Sure.

>  How much would it help in terms of
> power-saving?  Or are there other issues in taking longer to shut down
> cpus?
> 

Basically, power-management techniques (like suspend/resume as used on
smartphones etc) are implemented using a controlling algorithm which
controls the aggressiveness of power-management depending on the load
on the system.

Today, the cpuidle subsystem in Linux handles cpuidle transitions using
that technique, so I'll explain using that as an example. Similar
strategies are used for suspend/resume also.

For every cpuidle state, we have atleast 2 parameters that determine
how usable it is - 1. exit latency 2. target residency.

The exit latency captures the amount of time it takes to come out of
the power-saving state, from the time you asked it to come out. This
is an estimate of how "deep" the power-saving state is. The deeper it
is, the longer it takes to come out. (And of course, deeper states give
higher power-savings).

The target residency is a value which represents the break-even for
that state. It tells us how long we should stay in that idle state
(at a minimum) before we ask it to come out, to actually get some good
power-savings out of that state. (Note that entry and exit to an idle
state itself consumes some power, so there won't be any power-savings
if we keep entering and exiting a deep state without staying in that
state long enough).

Once the idle states are characterized like this, the cpuidle subsystem
uses a cpuidle "governor" to actually decide which of the states to
enter, given an idle period of time. The governor keeps track of the
load on the system and predicts the length of the next idle period, and
based on that prediction, it selects the idle state whose characteristics
(exit latency/target residency) match the predicted idle time closely.

So as we can see, the "deeper" the idle state, the lower its chance of
getting used during regular workload runs, because it is deemed too costly.
So entry/exit latency of an idle state is a very important aspect which
determines how often you can use that state. Ideally we want states which
are "deep" in the sense that they give huge power-savings, but "light"
in the sense that their entry/exit latencies are low. Such states give
us the best benefits, since we can use them aggressively.

Now a similar argument applies for suspend/resume (on smartphones etc).
Suspend/resume already gives good power-savings. But if we make it slower,
the chances of using it profitably begins to reduce. That's why, IMHO,
its important to keep a check on the latency of CPU hotplug and reduce
it if possible. And that becomes even more important as systems keep
sporting more and more CPUs.

Regards,
Srivatsa S. Bhat

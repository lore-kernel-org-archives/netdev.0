From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: [PATCH -tip 0/3] expedited "big hammer" RCU grace periods
Date: Wed, 24 Jun 2009 09:45:36 -0700
Message-ID: <20090624164535.GA13334@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mingo@elte.hu, akpm@linux-foundation.org,
	torvalds@linux-foundation.org, davem@davemloft.net,
	dada1@cosmosbay.com, zbr@ioremap.net, jeff.chua.linux@gmail.com,
	paulus@samba.org, laijs@cn.fujitsu.com, jengelh@medozas.de,
	r000n@r000n.net, benh@kernel.crashing.org,
	mathieu.desnoyers@polymtl.ca
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch set implements the "big hammer" expedited RCU grace periods.
This leverages the existing per-CPU migration kthreads, as suggested
by Ingo.  These are awakened in a loop, and waited for in a second loop.
Not fully scalable, but removing the extra hop through smp_call_function
reduces latency on systems with moderate numbers of CPUs.  The
synchronize_rcu_expedited() and synchronize_bh_expedited() primitives
invoke synchronize_sched_expedited(), except for CONFIG_PREEMPT_RCU,
where they instead invoke synchronize_rcu() and synchronize_rcu_bh(),
respectively.  This will be fixed in the future, after preemptable RCU
is folded into the rcutree implementation.

As before, this does nothing to expedite callbacks already registered
with call_rcu() or call_rcu_bh(), but there is no need to.

Passes many hours of rcutorture testing in parallel with a script
that randomly offlines and onlines CPUs in a number of configurations.
Grace periods take about 40 microseconds on an 8-CPU Power machine, which
I believe is good enough from a performance viewpoint for the near future.
This represents some slowdown from v7, which was unfortunately necessary
to fix some bugs.

This is finally ready for inclusion.  ;-)

Shortcomings:

o	Does not address preemptable RCU (though synchronize_sched_expedited()
	is in fact expedited in this configuration).

o	Probably not helpful on systems with thousands of CPUs, but likely
	quite helpful even on systems with a few hundred CPUs.

Changes since v7:

o	Fixed several embarrassing bugs turned up by tests on multiple
	configurations.

Changes since v6:

o	Moved to using the migration threads, as suggested by Ingo.

Changes since v5:

o	Fixed several embarrassing locking bugs, including those
	noted by Ingo and Lai.

o	Added a missing set of braces.

o	Cut out the extra kthread, so that synchronize_sched_expedited()
	directly calls smp_call_function() and waits for the quiescent
	states.

o	Removed some debug code, but promoted one to production.

o	Fix a compiler warning.

Changes since v4:

o	Use per-CPU kthreads to force the quiescent states in parallel.

Changes since v3:

o	Use a kthread that schedules itself on each CPU in turn to
	force a grace period.  The synchronize_rcu() primitive
	wakes up the kthread in order to avoid messing with affinity
	masks on user tasks.

o	Tried a number of additional variations on the v3 approach, none
	of which helped much.

Changes since v2:

o	Use reschedule IPIs rather than a softirq.

Changes since v1:

o	Added rcutorture support, and added exports required by
	rcutorture.

o	Added comment stating that smp_call_function() implies a
	memory barrier, suggested by Mathieu.

o	Added #include for delay.h.

 Documentation/RCU/torture.txt |   17 +++
 include/linux/rcuclassic.h    |   15 ++-
 include/linux/rcupdate.h      |   25 ++---
 include/linux/rcupreempt.h    |   10 ++
 include/linux/rcutree.h       |   12 ++
 kernel/rcupdate.c             |   25 +++++
 kernel/rcutorture.c           |  202 ++++++++++++++++++++++--------------------
 kernel/sched.c                |  129 ++++++++++++++++++++++++++
 8 files changed, 327 insertions(+), 108 deletions(-)

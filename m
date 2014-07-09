From: Viresh Kumar <viresh.kumar@linaro.org>
Subject: [RFC 0/7] hrtimer: drop active hrtimer checks after adding it
Date: Wed,  9 Jul 2014 12:25:32 +0530
Message-ID: <cover.1404888801.git.viresh.kumar@linaro.org>
Cc: linaro-kernel@lists.linaro.org, linux-kernel@vger.kernel.org,
	fweisbec@gmail.com, arvind.chauhan@arm.com,
	preeti@linux.vnet.ibm.com, khilman@linaro.org,
	Viresh Kumar <viresh.kumar@linaro.org>,
	Darren Hart <dvhart@linux.intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@redhat.com>, netdev@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>
To: tglx@linutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

hrtimer_start*() family never fails to enqueue a hrtimer to a clock-base. The
only special case is when the hrtimer was in past. If it is getting enqueued to
local CPUs's clock-base, we raise a softirq and exit, else we handle that on
next interrupt on remote CPU.

At several places in the kernel, we try to make sure if hrtimer was added
properly or not by calling hrtimer_active(), like:

	hrtimer_start(timer, expires, mode);
	if (hrtimer_active(timer)) {
		/* Added successfully */
	} else {
		/* Was added in the past */
	}

As hrtimer_start*() never fails, hrtimer_active() is guaranteed to return '1'.
So, there is no point calling hrtimer_active().

First patch adds a WARN_ON_ONCE() to __hrtimer_start_range_ns() to make sure
hrtimers are always enqueued from it. Next 6 patches update several parts of
kernel to drop calls to hrtimer_active() after starting a hrtimer.

Rebased over 3.16-rc4 and pushed here:
git://git.kernel.org/pub/scm/linux/kernel/git/vireshk/linux.git hrtimer/drop-hrtimer-active-calls

Cc: Darren Hart <dvhart@linux.intel.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: netdev@vger.kernel.org
Cc: Peter Zijlstra <peterz@infradead.org>

Viresh Kumar (7):
  hrtimer: Warn if hrtimer_start*() failed to enqueue hrtimer
  hrtimer: don't check for active hrtimer after adding it
  tick: don't check for active hrtimer after adding it
  sched: don't check for active hrtimer after adding it
  futex: don't check for active hrtimer after adding it
  rtmutex: don't check for active hrtimer after adding it
  net: don't check for active hrtimer after adding it

 kernel/futex.c           |  5 +----
 kernel/hrtimer.c         |  6 ++----
 kernel/locking/rtmutex.c |  5 +----
 kernel/sched/core.c      | 20 +++++++++-----------
 kernel/sched/deadline.c  |  2 +-
 kernel/time/tick-sched.c | 45 ++++++++++++++++++---------------------------
 net/core/pktgen.c        |  2 --
 7 files changed, 32 insertions(+), 53 deletions(-)

-- 
2.0.0.rc2

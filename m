From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [RFC 0/7] hrtimer: drop active hrtimer checks after adding it
Date: Wed, 9 Jul 2014 23:30:41 +0200 (CEST)
Message-ID: <alpine.DEB.2.10.1407092321130.4357@nanos>
References: <cover.1404888801.git.viresh.kumar@linaro.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linaro-kernel@lists.linaro.org, linux-kernel@vger.kernel.org,
	fweisbec@gmail.com, arvind.chauhan@arm.com,
	preeti@linux.vnet.ibm.com, khilman@linaro.org,
	Darren Hart <dvhart@linux.intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@redhat.com>, netdev@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>
To: Viresh Kumar <viresh.kumar@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1404888801.git.viresh.kumar@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 9 Jul 2014, Viresh Kumar wrote:

So your patch series drops active hrtimer checks after adding it,
according to your subject line.

Quite useeul to drop something after adding it, right?

> hrtimer_start*() family never fails to enqueue a hrtimer to a clock-base. The
> only special case is when the hrtimer was in past. If it is getting enqueued to
> local CPUs's clock-base, we raise a softirq and exit, else we handle that on
> next interrupt on remote CPU.
> 
> At several places in the kernel, we try to make sure if hrtimer was added
> properly or not by calling hrtimer_active(), like:
> 
> 	hrtimer_start(timer, expires, mode);
> 	if (hrtimer_active(timer)) {
> 		/* Added successfully */
> 	} else {
> 		/* Was added in the past */
> 	}
> 
> As hrtimer_start*() never fails, hrtimer_active() is guaranteed to return '1'.
> So, there is no point calling hrtimer_active().

Wrong as usual.

It's a common pattern that short timeouts are given which lead to
immediate expiry so the extra round through schedule is even more
pointless than the extra check.

Aside of that it's a long discussed issue that we really should tell
the caller right away that the timer was setup in the past and not
enqueued at all.

That requires to fixup a few call sites, but that'd far more valuable
than removing a few assumed to be pointless checks.

Thnaks,

	tglx

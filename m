From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Using sched_clock() for polling time limit
Date: Fri, 28 Jun 2013 17:51:49 +0100
Message-ID: <1372438309.1937.9.camel@bwh-desktop.uk.level5networks.com>
References: <20130628125918.14419.36214.stgit@ladj378.jer.intel.com>
	 <20130628125926.14419.89905.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, Willem de Bruijn <willemb@google.com>,
	Eric Dumazet <erdnetdev@gmail.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Cody P Schafer <devel-lists@codyps.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130628125926.14419.89905.stgit@ladj378.jer.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-06-28 at 15:59 +0300, Eliezer Tamir wrote:
> Our use of sched_clock is OK because we don't mind the side effects
> of calling it and occasionally waking up on a different CPU.

Sure about that?  Jitter matters too.

> When CONFIG_DEBUG_PREEMPT is on, disable preempt before calling
> sched_clock() so we don't trigger a debug_smp_processor_id() warning.
[...]

I think this is papering over a problem.  The warning is there for a
good reason.

Would functions like these make it possible to use sched_clock() safely
for polling?  (I didn't spend much time thinking about the names.)

struct sched_timestamp {
	int cpu;
	unsigned long long clock;
};

static inline struct sched_timestamp sched_get_timestamp(void)
{
	struct sched_timestamp ret;

	preempt_disable_notrace();
	ret.cpu = smp_processor_id();
	ret.clock = sched_clock();
	preempt_enable_no_resched_notrace();

	return ret;
}

static inline bool sched_timeout_or_moved(struct sched_timestamp start,
					  unsigned long long timeout)
{
	bool ret;

	preempt_disable_notrace();
	ret = start.cpu != smp_processor_id() ||
		(sched_clock() - start.clock) > timeout;
	preempt_enable_no_resched_notrace();

	return ret;
}

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

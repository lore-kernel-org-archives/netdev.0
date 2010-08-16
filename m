From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [LOCKDEP BUG][2.6.36-rc1] xt_info_wrlock?
Date: Mon, 16 Aug 2010 14:16:06 -0400
Message-ID: <1281982566.3268.137.camel@gandalf.stny.rr.com>
References: <1281978469.3268.55.camel@gandalf.stny.rr.com>
	 <1281979893.2524.54.camel@edumazet-laptop>
	 <1281981301.3268.110.camel@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, Ingo Molnar <mingo@elte.hu>,
	Peter Zijlstra <peterz@infradead.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1281981301.3268.110.camel@gandalf.stny.rr.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2010-08-16 at 13:55 -0400, Steven Rostedt wrote:

Re-looking at the code, I think I figured it out. But it should really
be documented better.


> 
> Please tell me what prevents an interrupt going off after we grab the
> xt_info_wrlock(cpu) in get_counters().
> 
> IOW, what prevents this:
> 
> 	get_counters() {

I left out here:

		for_each_possible_cpu(cpu) {
			if (cpu == curcpu)
				continue;

which means that we are grabbing the lock for other CPUs, and that a
softirq would not be a problem.

> 		xt_info_wrlock(cpu);
> 
> 		<interrupt> --> softirq
> 
> 			xt_info_rblock_bh();
> 				/* which grabs the writer lock */
> 			DEADLOCK!!
> 

Your patchwork patch has:


@@ -729,8 +729,10 @@  static void get_counters(const struct
xt_table_info *t,
 	local_bh_enable();
 	/* Processing counters from other cpus, we can let bottom half enabled,
 	 * (preemption is disabled)
+	 * We must turn off lockdep to avoid a false positive.
 	 */
 
+	lockdep_off();
 	for_each_possible_cpu(cpu) {


We need a better comment than that. Could that be changed to something like:

	/*
	 * lockdep tests if we grab a lock and can be preempted by 
	 * a softirq and that softirq grabs the same lock causing a
	 * deadlock.
	 * This is a special case because this is a per-cpu lock,
	 * and we are only grabbing the lock for other CPUs. A softirq
	 * will only takes its local CPU lock thus, if we are preempted
	 * by a softirq, then it will grab the current CPU lock which
	 * we do not take here.
	 *
	 * Simply disable lockdep here until it can handle this situation.
	 */

Thanks,

-- Steve

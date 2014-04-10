From: Rik van Riel <riel@redhat.com>
Subject: [PATCH] softirq: punt to ksoftirqd if __do_softirq recently looped
Date: Thu, 10 Apr 2014 11:57:06 -0400
Message-ID: <20140410115706.662fb5e7@annuminas.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jiri Benc <jbenc@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	David Miller <davem@davemloft.net>,
	Frederic Weisbecker <fweisbec@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jiri noticed that netperf throughput had gotten worse in recent years,
for smaller message sizes. In the past, ksoftirqd would take around 80%
of a CPU, and netserver would take around 100% of another CPU.

On current kernels, sometimes all the softirq processing is done in the
context of the netperf process, which can result in as much as a 50%
performance drop, due to netserver spending all its CPU time "delivering"
packets to a socket it rarely empties, and dropping the packets on the
floor as a result.

This seems silly in an age where even cell phones are multi-core, and
we could simply let the ksoftirqd thread handle the softirq load, so
the scheduler can migrate the userspace task to another CPU.

This patch accomplishes that in a very simplistic way. The code
remembers when __do_softirq last looped, and will punt softirq
handling to ksoftirqd if another softirq happens in the same jiffie.

Netperf results:

			without patch		with patch
UDP_STREAM      1472    957.17 / 954.18         957.15 / 951.73
UDP_STREAM      978     936.85 / 930.06         936.84 / 927.63
UDP_STREAM      466     875.98 / 865.62         875.98 / 868.65
UDP_STREAM      210     760.88 / 748.70         760.88 / 748.61
UDP_STREAM      82      554.06 / 329.96         554.06 / 505.95
                        unstable ^^^^^^
UDP_STREAM      18      158.99 / 108.95         160.73 / 112.68

Signed-off-by: Rik van Riel <riel@redhat.com>
Cc: Frederic Weisbecker <fweisbec@gmail.com>
Cc: David Miller <davem@davemloft.net>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Peter Zijlstra <peterz@infradead.org>
Tested-by: Jiri Benc <jbenc@redhat.com>
Reported-by: Jiri Benc <jbenc@redhat.com>
---
 kernel/softirq.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/kernel/softirq.c b/kernel/softirq.c
index 787b3a0..020be2f 100644
--- a/kernel/softirq.c
+++ b/kernel/softirq.c
@@ -56,6 +56,7 @@ EXPORT_SYMBOL(irq_stat);
 static struct softirq_action softirq_vec[NR_SOFTIRQS] __cacheline_aligned_in_smp;
 
 DEFINE_PER_CPU(struct task_struct *, ksoftirqd);
+DEFINE_PER_CPU(unsigned long, softirq_looped);
 
 char *softirq_to_name[NR_SOFTIRQS] = {
 	"HI", "TIMER", "NET_TX", "NET_RX", "BLOCK", "BLOCK_IOPOLL",
@@ -271,6 +272,9 @@ asmlinkage void __do_softirq(void)
 
 	pending = local_softirq_pending();
 	if (pending) {
+		/* Still busy? Remember this for invoke_softirq() below... */
+		this_cpu_write(softirq_looped, jiffies);
+
 		if (time_before(jiffies, end) && !need_resched() &&
 		    --max_restart)
 			goto restart;
@@ -330,7 +334,11 @@ void irq_enter(void)
 
 static inline void invoke_softirq(void)
 {
-	if (!force_irqthreads) {
+	/*
+	 * If force_irqthreads is set, or if we looped in __do_softirq this
+	 * jiffie, punt to ksoftirqd to prevent userland starvation.
+	 */
+	if (!force_irqthreads && this_cpu_read(softirq_looped) != jiffies) {
 		/*
 		 * We can safely execute softirq on the current stack if
 		 * it is the irq stack, because it should be near empty

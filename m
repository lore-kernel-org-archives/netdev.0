From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 2.6] netem - add correlated random number support
Date: Wed, 25 Aug 2004 16:15:35 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040825161535.62f07a8c@dell_ss3.pdx.osdl.net>
References: <20040825105339.30210e84@dell_ss3.pdx.osdl.net>
	<20040825110108.6a79216a@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040825110108.6a79216a@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch adds correlated random number support (really just a sliding
average).  Like most of this stuff, the concept came from NISTnet.

Dave, this applies after "(4/4) netem - change parameters shouldn't destroy child qdisc"
but before the patch to add loadable distributions, sorry for the confusion.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/net/sched/sch_netem.c b/net/sched/sch_netem.c
--- a/net/sched/sch_netem.c	2004-08-25 16:14:27 -07:00
+++ b/net/sched/sch_netem.c	2004-08-25 16:14:27 -07:00
@@ -63,6 +63,11 @@
 	u32 gap;
 	u32 jitter;
 	u32 duplicate;
+
+	struct crndstate {
+		unsigned long last;
+		unsigned long rho;
+	} delay_cor, loss_cor, dup_cor;
 };
 
 /* Time stamp put into socket buffer control block */
@@ -70,6 +75,34 @@
 	psched_time_t	time_to_send;
 };
 
+/* init_crandom - initialize correlated random number generator
+ * Use entropy source for initial seed.
+ */
+static void init_crandom(struct crndstate *state, unsigned long rho)
+{
+	state->rho = rho;
+	state->last = net_random();
+}
+
+/* get_crandom - correlated random number generator
+ * Next number depends on last value.
+ * rho is scaled to avoid floating point.
+ */
+static unsigned long get_crandom(struct crndstate *state)
+{
+	u64 value, rho;
+	unsigned long answer;
+
+	if (state->rho == 0)	/* no correllation */
+		return net_random();
+
+	value = net_random();
+	rho = (u64)state->rho + 1;
+	answer = (value * ((1ull<<32) - rho) + state->last * rho) >> 32;
+	state->last = answer;
+	return answer;
+}
+
 /* This is the distribution table for the normal distribution produced
  * with NISTnet tools.
  * The entries represent a scaled inverse of the cumulative distribution
@@ -678,14 +711,14 @@
 	pr_debug("netem_enqueue skb=%p @%lu\n", skb, jiffies);
 
 	/* Random packet drop 0 => none, ~0 => all */
-	if (q->loss && q->loss >= net_random()) {
+	if (q->loss && q->loss >= get_crandom(&q->loss_cor)) {
 		pr_debug("netem_enqueue: random loss\n");
 		sch->stats.drops++;
 		return 0;	/* lie about loss so TCP doesn't know */
 	}
 
 	/* Random duplication */
-	if (q->duplicate && q->duplicate >= net_random()) {
+	if (q->duplicate && q->duplicate >= get_crandom(&q->dup_cor)) {
 		struct sk_buff *skb2 = skb_clone(skb, GFP_ATOMIC);
 
 		pr_debug("netem_enqueue: dup %p\n", skb2);
@@ -807,6 +840,10 @@
 	q->loss = qopt->loss;
 	q->duplicate = qopt->duplicate;
 
+	init_crandom(&q->delay_cor, qopt->delay_corr);
+	init_crandom(&q->loss_cor, qopt->loss_corr);
+	init_crandom(&q->dup_cor, qopt->dup_corr);
+
 	return 0;
 }
 
@@ -872,6 +909,9 @@
 	qopt.loss = q->loss;
 	qopt.gap = q->gap;
 	qopt.duplicate = q->duplicate;
+	qopt.delay_corr = q->delay_cor.rho;
+	qopt.loss_corr = q->loss_cor.rho;
+	qopt.dup_corr = q->dup_cor.rho;
 
 	RTA_PUT(skb, TCA_OPTIONS, sizeof(qopt), &qopt);
 

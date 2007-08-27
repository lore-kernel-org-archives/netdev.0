From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Remove softirq scheduling from pktgen [PATCH]
Date: Mon, 27 Aug 2007 18:57:19 +0200
Message-ID: <18131.623.945573.425948@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:38914 "EHLO mx1.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754104AbXH0Q5Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Aug 2007 12:57:24 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Hello, It's not a job for pktgen.

Cheers
					--ro


Signed-off-by: Robert Olsson <robert.olsson@its.uu.se>


diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 18601af..975e887 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -164,7 +164,7 @@
 #include <asm/div64.h>		/* do_div */
 #include <asm/timex.h>
 
-#define VERSION  "pktgen v2.68: Packet Generator for packet performance testing.\n"
+#define VERSION  "pktgen v2.69: Packet Generator for packet performance testing.\n"
 
 /* The buckets are exponential in 'width' */
 #define LAT_BUCKETS_MAX 32
@@ -381,7 +381,6 @@ struct pktgen_thread {
 	struct list_head th_list;
 	struct task_struct *tsk;
 	char result[512];
-	u32 max_before_softirq;	/* We'll call do_softirq to prevent starvation. */
 
 	/* Field for thread to receive "posted" events terminate, stop ifs etc. */
 
@@ -1752,9 +1751,6 @@ static int pktgen_thread_show(struct seq_file *seq, void *v)
 
 	BUG_ON(!t);
 
-	seq_printf(seq, "Name: %s  max_before_softirq: %d\n",
-		   t->tsk->comm, t->max_before_softirq);
-
 	seq_printf(seq, "Running: ");
 
 	if_lock(t);
@@ -1787,7 +1783,6 @@ static ssize_t pktgen_thread_write(struct file *file,
 	int i = 0, max, len, ret;
 	char name[40];
 	char *pg_result;
-	unsigned long value = 0;
 
 	if (count < 1) {
 		//      sprintf(pg_result, "Wrong command format");
@@ -1861,12 +1856,8 @@ static ssize_t pktgen_thread_write(struct file *file,
 	}
 
 	if (!strcmp(name, "max_before_softirq")) {
-		len = num_arg(&user_buffer[i], 10, &value);
-		mutex_lock(&pktgen_thread_lock);
-		t->max_before_softirq = value;
-		mutex_unlock(&pktgen_thread_lock);
+		sprintf(pg_result, "OK: Note! max_before_softirq is obsoleted -- Do not use");
 		ret = count;
-		sprintf(pg_result, "OK: max_before_softirq=%lu", value);
 		goto out;
 	}
 
@@ -2145,7 +2136,6 @@ static void spin(struct pktgen_dev *pkt_dev, __u64 spin_until_us)
 		if (spin_until_us - now > jiffies_to_usecs(1) + 1)
 			schedule_timeout_interruptible(1);
 		else if (spin_until_us - now > 100) {
-			do_softirq();
 			if (!pkt_dev->running)
 				return;
 			if (need_resched())
@@ -3515,8 +3505,6 @@ static int pktgen_thread_worker(void *arg)
 	struct pktgen_thread *t = arg;
 	struct pktgen_dev *pkt_dev = NULL;
 	int cpu = t->cpu;
-	u32 max_before_softirq;
-	u32 tx_since_softirq = 0;
 
 	BUG_ON(smp_processor_id() != cpu);
 
@@ -3526,8 +3514,6 @@ static int pktgen_thread_worker(void *arg)
 
 	pr_debug("pktgen: starting pktgen/%d:  pid=%d\n", cpu, current->pid);
 
-	max_before_softirq = t->max_before_softirq;
-
 	set_current_state(TASK_INTERRUPTIBLE);
 
 	set_freezable();
@@ -3546,24 +3532,9 @@ static int pktgen_thread_worker(void *arg)
 
 		__set_current_state(TASK_RUNNING);
 
-		if (pkt_dev) {
-
+		if (pkt_dev) 
 			pktgen_xmit(pkt_dev);
 
-			/*
-			 * We like to stay RUNNING but must also give
-			 * others fair share.
-			 */
-
-			tx_since_softirq += pkt_dev->last_ok;
-
-			if (tx_since_softirq > max_before_softirq) {
-				if (local_softirq_pending())
-					do_softirq();
-				tx_since_softirq = 0;
-			}
-		}
-
 		if (t->control & T_STOP) {
 			pktgen_stop(t);
 			t->control &= ~(T_STOP);

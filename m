From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: less interrupt masking in NAPI
Date: Sun, 02 Nov 2014 06:19:33 -0800
Message-ID: <1414937973.31792.37.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Willem de Bruijn <willemb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:48971 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751074AbaKBOTj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Nov 2014 09:19:39 -0500
Received: by mail-ig0-f178.google.com with SMTP id a13so3348714igq.11
        for <netdev@vger.kernel.org>; Sun, 02 Nov 2014 06:19:38 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

net_rx_action() can mask irqs a single time to transfert sd->poll_list
into a private list, for a very short duration.

Then, napi_complete() can avoid masking irqs again,
and net_rx_action() only needs to mask irq again in slow path.

This patch removes 2 couples of irq mask/unmask per typical NAPI run,
more if multiple napi were triggered.

Note this also allows to give control back to caller (do_softirq())
more often, so that other softirq handlers can be called a bit earlier,
or ksoftirqd can be wakeup earlier under pressure.

This was developed while testing an alternative to RX interrupt
mitigation to reduce latencies while keeping or improving GRO
aggregation on fast NIC.

Idea is to test napi->gro_list at the end of a napi->poll() and
reschedule one NAPI poll, but after servicing a full round of
softirqs (timers, TX, rcu, ...). This will be allowed only if softirq
is currently serviced by idle task or ksoftirqd, and resched not needed.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Willem de Bruijn <willemb@google.com>
---
 net/core/dev.c |   68 +++++++++++++++++++++++++++++------------------
 1 file changed, 43 insertions(+), 25 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index ebf778df58cd..40be481268de 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4316,20 +4316,28 @@ static void net_rps_action_and_irq_enable(struct softnet_data *sd)
 		local_irq_enable();
 }
 
+static bool sd_has_rps_ipi_waiting(struct softnet_data *sd)
+{
+#ifdef CONFIG_RPS
+	return sd->rps_ipi_list != NULL;
+#else
+	return false;
+#endif
+}
+
 static int process_backlog(struct napi_struct *napi, int quota)
 {
 	int work = 0;
 	struct softnet_data *sd = container_of(napi, struct softnet_data, backlog);
 
-#ifdef CONFIG_RPS
 	/* Check if we have pending ipi, its better to send them now,
 	 * not waiting net_rx_action() end.
 	 */
-	if (sd->rps_ipi_list) {
+	if (sd_has_rps_ipi_waiting(sd)) {
 		local_irq_disable();
 		net_rps_action_and_irq_enable(sd);
 	}
-#endif
+
 	napi->weight = weight_p;
 	local_irq_disable();
 	while (1) {
@@ -4356,7 +4364,6 @@ static int process_backlog(struct napi_struct *napi, int quota)
 			 * We can use a plain write instead of clear_bit(),
 			 * and we dont need an smp_mb() memory barrier.
 			 */
-			list_del(&napi->poll_list);
 			napi->state = 0;
 			rps_unlock(sd);
 
@@ -4406,7 +4413,7 @@ void __napi_complete(struct napi_struct *n)
 	BUG_ON(!test_bit(NAPI_STATE_SCHED, &n->state));
 	BUG_ON(n->gro_list);
 
-	list_del(&n->poll_list);
+	list_del_init(&n->poll_list);
 	smp_mb__before_atomic();
 	clear_bit(NAPI_STATE_SCHED, &n->state);
 }
@@ -4424,9 +4431,15 @@ void napi_complete(struct napi_struct *n)
 		return;
 
 	napi_gro_flush(n, false);
-	local_irq_save(flags);
-	__napi_complete(n);
-	local_irq_restore(flags);
+
+	if (likely(list_empty(&n->poll_list))) {
+		WARN_ON_ONCE(!test_and_clear_bit(NAPI_STATE_SCHED, &n->state));
+	} else {
+		/* If n->poll_list is not empty, we need to mask irqs */
+		local_irq_save(flags);
+		__napi_complete(n);
+		local_irq_restore(flags);
+	}
 }
 EXPORT_SYMBOL(napi_complete);
 
@@ -4520,29 +4533,28 @@ static void net_rx_action(struct softirq_action *h)
 	struct softnet_data *sd = this_cpu_ptr(&softnet_data);
 	unsigned long time_limit = jiffies + 2;
 	int budget = netdev_budget;
+	LIST_HEAD(list);
+	LIST_HEAD(repoll);
 	void *have;
 
 	local_irq_disable();
+	list_splice_init(&sd->poll_list, &list);
+	local_irq_enable();
 
-	while (!list_empty(&sd->poll_list)) {
+	while (!list_empty(&list)) {
 		struct napi_struct *n;
 		int work, weight;
 
-		/* If softirq window is exhuasted then punt.
+		/* If softirq window is exhausted then punt.
 		 * Allow this to run for 2 jiffies since which will allow
 		 * an average latency of 1.5/HZ.
 		 */
 		if (unlikely(budget <= 0 || time_after_eq(jiffies, time_limit)))
 			goto softnet_break;
 
-		local_irq_enable();
 
-		/* Even though interrupts have been re-enabled, this
-		 * access is safe because interrupts can only add new
-		 * entries to the tail of this list, and only ->poll()
-		 * calls can remove this head entry from the list.
-		 */
-		n = list_first_entry(&sd->poll_list, struct napi_struct, poll_list);
+		n = list_first_entry(&list, struct napi_struct, poll_list);
+		list_del_init(&n->poll_list);
 
 		have = netpoll_poll_lock(n);
 
@@ -4564,8 +4576,6 @@ static void net_rx_action(struct softirq_action *h)
 
 		budget -= work;
 
-		local_irq_disable();
-
 		/* Drivers must not modify the NAPI state if they
 		 * consume the entire weight.  In such cases this code
 		 * still "owns" the NAPI instance and therefore can
@@ -4573,32 +4583,40 @@ static void net_rx_action(struct softirq_action *h)
 		 */
 		if (unlikely(work == weight)) {
 			if (unlikely(napi_disable_pending(n))) {
-				local_irq_enable();
 				napi_complete(n);
-				local_irq_disable();
 			} else {
 				if (n->gro_list) {
 					/* flush too old packets
 					 * If HZ < 1000, flush all packets.
 					 */
-					local_irq_enable();
 					napi_gro_flush(n, HZ >= 1000);
-					local_irq_disable();
 				}
-				list_move_tail(&n->poll_list, &sd->poll_list);
+				list_add_tail(&n->poll_list, &repoll);
 			}
 		}
 
 		netpoll_poll_unlock(have);
 	}
+
+	if (!sd_has_rps_ipi_waiting(sd) &&
+	    list_empty(&list) &&
+	    list_empty(&repoll))
+		return;
 out:
+	local_irq_disable();
+
+	list_splice_tail_init(&sd->poll_list, &list);
+	list_splice_tail(&repoll, &list);
+	list_splice(&list, &sd->poll_list);
+	if (!list_empty(&sd->poll_list))
+		__raise_softirq_irqoff(NET_RX_SOFTIRQ);
+
 	net_rps_action_and_irq_enable(sd);
 
 	return;
 
 softnet_break:
 	sd->time_squeeze++;
-	__raise_softirq_irqoff(NET_RX_SOFTIRQ);
 	goto out;
 }
 

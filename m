From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] rps: Various optimizations
Date: Thu, 06 May 2010 10:58:42 +0200
Message-ID: <1273136322.2357.15.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Tom Herbert <therbert@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:53800 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752725Ab0EFJAK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 05:00:10 -0400
Received: by bwz19 with SMTP id 19so355336bwz.21
        for <netdev@vger.kernel.org>; Thu, 06 May 2010 02:00:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce ____napi_schedule() helper for callers in irq disabled
contexts. rps_trigger_softirq() becomes a leaf function.

Use container_of() in process_backlog() instead of accessing per_cpu
address.

Use a custom inlined version of __napi_complete() in process_backlog()
to avoid one locked instruction :

 only current cpu owns and manipulates this napi,
 and NAPI_STATE_SCHED is the only possible flag set on backlog.
 we can use a plain write instead of clear_bit(),
 and we dont need an smp_mb() memory barrier, since RPS is on,
 backlog is protected by a spinlock.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/dev.c |   28 ++++++++++++++++++++++------
 1 files changed, 22 insertions(+), 6 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 36d53be..c6861e4 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2205,6 +2205,14 @@ int netdev_max_backlog __read_mostly = 1000;
 int netdev_budget __read_mostly = 300;
 int weight_p __read_mostly = 64;            /* old backlog weight */
 
+/* Called with irq disabled */
+static inline void ____napi_schedule(struct softnet_data *sd,
+				     struct napi_struct *napi)
+{
+	list_add_tail(&napi->poll_list, &sd->poll_list);
+	__raise_softirq_irqoff(NET_RX_SOFTIRQ);
+}
+
 #ifdef CONFIG_RPS
 
 /* One global table that all flow-based protocols share. */
@@ -2363,7 +2371,7 @@ static void rps_trigger_softirq(void *data)
 {
 	struct softnet_data *sd = data;
 
-	__napi_schedule(&sd->backlog);
+	____napi_schedule(sd, &sd->backlog);
 	sd->received_rps++;
 }
 
@@ -2421,7 +2429,7 @@ enqueue:
 		/* Schedule NAPI for backlog device */
 		if (napi_schedule_prep(&sd->backlog)) {
 			if (!rps_ipi_queued(sd))
-				__napi_schedule(&sd->backlog);
+				____napi_schedule(sd, &sd->backlog);
 		}
 		goto enqueue;
 	}
@@ -3280,7 +3288,7 @@ static void net_rps_action_and_irq_enable(struct softnet_data *sd)
 static int process_backlog(struct napi_struct *napi, int quota)
 {
 	int work = 0;
-	struct softnet_data *sd = &__get_cpu_var(softnet_data);
+	struct softnet_data *sd = container_of(napi, struct softnet_data, backlog);
 
 #ifdef CONFIG_RPS
 	/* Check if we have pending ipi, its better to send them now,
@@ -3313,7 +3321,16 @@ static int process_backlog(struct napi_struct *napi, int quota)
 						   &sd->process_queue);
 		}
 		if (qlen < quota - work) {
-			__napi_complete(napi);
+			/*
+			 * Inline a custom version of __napi_complete().
+			 * only current cpu owns and manipulates this napi,
+			 * and NAPI_STATE_SCHED is the only possible flag set on backlog.
+			 * we can use a plain write instead of clear_bit(),
+			 * and we dont need an smp_mb() memory barrier.
+			 */
+			list_del(&napi->poll_list);
+			napi->state = 0;
+
 			quota = work + qlen;
 		}
 		rps_unlock(sd);
@@ -3334,8 +3351,7 @@ void __napi_schedule(struct napi_struct *n)
 	unsigned long flags;
 
 	local_irq_save(flags);
-	list_add_tail(&n->poll_list, &__get_cpu_var(softnet_data).poll_list);
-	__raise_softirq_irqoff(NET_RX_SOFTIRQ);
+	____napi_schedule(&__get_cpu_var(softnet_data), n);
 	local_irq_restore(flags);
 }
 EXPORT_SYMBOL(__napi_schedule);



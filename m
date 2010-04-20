From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] rps: send IPIs ASAP
Date: Tue, 20 Apr 2010 12:08:39 +0800
Message-ID: <1271736519-2991-1-git-send-email-xiaosuo@gmail.com>
Cc: Tom Herbert <therbert@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f194.google.com ([209.85.211.194]:43370 "EHLO
	mail-yw0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751147Ab0DTEJZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 00:09:25 -0400
Received: by ywh32 with SMTP id 32so3160962ywh.33
        for <netdev@vger.kernel.org>; Mon, 19 Apr 2010 21:09:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rps: send IPIs ASAP

In order to reduce latency, we'd better send IPIs ASAP to schedule the
corresponding NAPIs.

For NAPI drivers, we send IPIs immediately, and for the others, we defer them
to NET_RX_SOFTIRQ. In this patch, we move net_rps_action() to the beginning of
net_rx_action() to emulate a softirq with the higher priority than
NET_RX_SOFTIRQ.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 net/core/dev.c |   23 ++++++++++++++++++++---
 1 file changed, 20 insertions(+), 3 deletions(-)
diff --git a/net/core/dev.c b/net/core/dev.c
index 05a2b29..d8fca21 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2363,6 +2363,10 @@ static int enqueue_to_backlog(struct sk_buff *skb, int cpu,
 {
 	struct softnet_data *queue;
 	unsigned long flags;
+#ifdef CONFIG_RPS
+	bool ni = !in_irq();
+	bool ipi = false;
+#endif
 
 	queue = &per_cpu(softnet_data, cpu);
 
@@ -2380,6 +2384,10 @@ enqueue:
 #endif
 			rps_unlock(queue);
 			local_irq_restore(flags);
+#ifdef CONFIG_RPS
+			if (ipi)
+				__smp_call_function_single(cpu, &queue->csd, 0);
+#endif
 			return NET_RX_SUCCESS;
 		}
 
@@ -2389,6 +2397,11 @@ enqueue:
 			if (cpu != smp_processor_id()) {
 				struct softnet_data *myqueue;
 
+				if (ni) {
+					ipi = true;
+					goto enqueue;
+				}
+
 				myqueue = &__get_cpu_var(softnet_data);
 				queue->rps_ipi_next = myqueue->rps_ipi_list;
 				myqueue->rps_ipi_list = queue;
@@ -3337,6 +3350,7 @@ static void net_rps_action(void)
 	struct softnet_data *locqueue = &__get_cpu_var(softnet_data);
 	struct softnet_data *remqueue = locqueue->rps_ipi_list;
 
+	local_irq_disable();
 	if (remqueue) {
 		locqueue->rps_ipi_list = NULL;
 
@@ -3350,9 +3364,10 @@ static void net_rps_action(void)
 							   &remqueue->csd, 0);
 			remqueue = next;
 		}
-	} else
-#endif
+	} else {
 		local_irq_enable();
+	}
+#endif
 }
 
 static void net_rx_action(struct softirq_action *h)
@@ -3362,6 +3377,8 @@ static void net_rx_action(struct softirq_action *h)
 	int budget = netdev_budget;
 	void *have;
 
+	net_rps_action();
+
 	local_irq_disable();
 
 	while (!list_empty(list)) {
@@ -3423,7 +3440,7 @@ static void net_rx_action(struct softirq_action *h)
 		netpoll_poll_unlock(have);
 	}
 out:
-	net_rps_action();
+	local_irq_enable();
 
 #ifdef CONFIG_NET_DMA
 	/*

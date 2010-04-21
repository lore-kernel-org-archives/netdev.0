From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] rps: immediate send IPI in process_backlog()
Date: Wed, 21 Apr 2010 23:04:58 +0200
Message-ID: <1271883898.7895.3379.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>, Changli Gao <xiaosuo@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:37744 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753074Ab0DUVFJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Apr 2010 17:05:09 -0400
Received: by bwz1 with SMTP id 1so10686391bwz.2
        for <netdev@vger.kernel.org>; Wed, 21 Apr 2010 14:05:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If some skb are queued to our backlog, we are delaying IPI sending at
the end of net_rx_action(), increasing latencies. This defeats the
queueing, since we want to quickly dispatch packets to the pool of
worker cpus, then eventually deeply process our packets.

It's better to send IPI before processing our packets in upper layers,
from process_backlog().

Change the _and_disable_irq suffix to _and_enable_irq(), since we enable
local irq in net_rps_action(), sorry for the confusion.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

 net/core/dev.c |   76 +++++++++++++++++++++++++----------------------
 1 file changed, 42 insertions(+), 34 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index b31d5d6..9871660 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3239,11 +3239,48 @@ gro_result_t napi_gro_frags(struct napi_struct *napi)
 }
 EXPORT_SYMBOL(napi_gro_frags);
 
+/*
+ * net_rps_action sends any pending IPI's for rps.
+ * Note: called with local irq disabled, but exits with local irq enabled.
+ */
+static void net_rps_action_and_irq_enable(struct softnet_data *sd)
+{
+#ifdef CONFIG_RPS
+	struct softnet_data *remsd = sd->rps_ipi_list;
+
+	if (remsd) {
+		sd->rps_ipi_list = NULL;
+
+		local_irq_enable();
+
+		/* Send pending IPI's to kick RPS processing on remote cpus. */
+		while (remsd) {
+			struct softnet_data *next = remsd->rps_ipi_next;
+
+			if (cpu_online(remsd->cpu))
+				__smp_call_function_single(remsd->cpu,
+							   &remsd->csd, 0);
+			remsd = next;
+		}
+	} else
+#endif
+		local_irq_enable();
+}
+
 static int process_backlog(struct napi_struct *napi, int quota)
 {
 	int work = 0;
 	struct softnet_data *sd = &__get_cpu_var(softnet_data);
 
+#ifdef CONFIG_RPS
+	/* Check if we have pending ipi, its better to send them now,
+	 * not waiting net_rx_action() end.
+	 */
+	if (sd->rps_ipi_list) {
+		local_irq_disable();
+		net_rps_action_and_irq_enable(sd);
+	}
+#endif
 	napi->weight = weight_p;
 	do {
 		struct sk_buff *skb;
@@ -3350,45 +3387,16 @@ void netif_napi_del(struct napi_struct *napi)
 }
 EXPORT_SYMBOL(netif_napi_del);
 
-/*
- * net_rps_action sends any pending IPI's for rps.
- * Note: called with local irq disabled, but exits with local irq enabled.
- */
-static void net_rps_action_and_irq_disable(void)
-{
-#ifdef CONFIG_RPS
-	struct softnet_data *sd = &__get_cpu_var(softnet_data);
-	struct softnet_data *remsd = sd->rps_ipi_list;
-
-	if (remsd) {
-		sd->rps_ipi_list = NULL;
-
-		local_irq_enable();
-
-		/* Send pending IPI's to kick RPS processing on remote cpus. */
-		while (remsd) {
-			struct softnet_data *next = remsd->rps_ipi_next;
-
-			if (cpu_online(remsd->cpu))
-				__smp_call_function_single(remsd->cpu,
-							   &remsd->csd, 0);
-			remsd = next;
-		}
-	} else
-#endif
-		local_irq_enable();
-}
-
 static void net_rx_action(struct softirq_action *h)
 {
-	struct list_head *list = &__get_cpu_var(softnet_data).poll_list;
+	struct softnet_data *sd = &__get_cpu_var(softnet_data);
 	unsigned long time_limit = jiffies + 2;
 	int budget = netdev_budget;
 	void *have;
 
 	local_irq_disable();
 
-	while (!list_empty(list)) {
+	while (!list_empty(&sd->poll_list)) {
 		struct napi_struct *n;
 		int work, weight;
 
@@ -3406,7 +3414,7 @@ static void net_rx_action(struct softirq_action *h)
 		 * entries to the tail of this list, and only ->poll()
 		 * calls can remove this head entry from the list.
 		 */
-		n = list_first_entry(list, struct napi_struct, poll_list);
+		n = list_first_entry(&sd->poll_list, struct napi_struct, poll_list);
 
 		have = netpoll_poll_lock(n);
 
@@ -3441,13 +3449,13 @@ static void net_rx_action(struct softirq_action *h)
 				napi_complete(n);
 				local_irq_disable();
 			} else
-				list_move_tail(&n->poll_list, list);
+				list_move_tail(&n->poll_list, &sd->poll_list);
 		}
 
 		netpoll_poll_unlock(have);
 	}
 out:
-	net_rps_action_and_irq_disable();
+	net_rps_action_and_irq_enable(sd);
 
 #ifdef CONFIG_NET_DMA
 	/*



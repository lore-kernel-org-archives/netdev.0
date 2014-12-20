From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 1/4] net: Move napi polling code out of net_rx_action
Date: Sun, 21 Dec 2014 07:16:21 +1100
Message-ID: <E1Y2QRp-0001pD-J7@gondolin.me.apana.org.au>
References: <20141220201453.GA6924@gondor.apana.org.au>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, david.vrabel@citrix.com,
	netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	konrad.wilk@oracle.com, boris.ostrovsky@oracle.com,
	edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:39591 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751187AbaLTUQb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Dec 2014 15:16:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch creates a new function napi_poll and moves the napi
polling code from net_rx_action into it.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/core/dev.c |   98 +++++++++++++++++++++++++++++++--------------------------
 1 file changed, 54 insertions(+), 44 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index f411c28..f7c4f4e 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4557,6 +4557,59 @@ void netif_napi_del(struct napi_struct *napi)
 }
 EXPORT_SYMBOL(netif_napi_del);
 
+static int napi_poll(struct napi_struct *n, struct list_head *repoll)
+{
+	void *have;
+	int work, weight;
+
+	list_del_init(&n->poll_list);
+
+	have = netpoll_poll_lock(n);
+
+	weight = n->weight;
+
+	/* This NAPI_STATE_SCHED test is for avoiding a race
+	 * with netpoll's poll_napi().  Only the entity which
+	 * obtains the lock and sees NAPI_STATE_SCHED set will
+	 * actually make the ->poll() call.  Therefore we avoid
+	 * accidentally calling ->poll() when NAPI is not scheduled.
+	 */
+	work = 0;
+	if (test_bit(NAPI_STATE_SCHED, &n->state)) {
+		work = n->poll(n, weight);
+		trace_napi_poll(n);
+	}
+
+	WARN_ON_ONCE(work > weight);
+
+	if (likely(work < weight))
+		goto out_unlock;
+
+	/* Drivers must not modify the NAPI state if they
+	 * consume the entire weight.  In such cases this code
+	 * still "owns" the NAPI instance and therefore can
+	 * move the instance around on the list at-will.
+	 */
+	if (unlikely(napi_disable_pending(n))) {
+		napi_complete(n);
+		goto out_unlock;
+	}
+
+	if (n->gro_list) {
+		/* flush too old packets
+		 * If HZ < 1000, flush all packets.
+		 */
+		napi_gro_flush(n, HZ >= 1000);
+	}
+
+	list_add_tail(&n->poll_list, repoll);
+
+out_unlock:
+	netpoll_poll_unlock(have);
+
+	return work;
+}
+
 static void net_rx_action(struct softirq_action *h)
 {
 	struct softnet_data *sd = this_cpu_ptr(&softnet_data);
@@ -4564,7 +4617,6 @@ static void net_rx_action(struct softirq_action *h)
 	int budget = netdev_budget;
 	LIST_HEAD(list);
 	LIST_HEAD(repoll);
-	void *have;
 
 	local_irq_disable();
 	list_splice_init(&sd->poll_list, &list);
@@ -4572,7 +4624,6 @@ static void net_rx_action(struct softirq_action *h)
 
 	while (!list_empty(&list)) {
 		struct napi_struct *n;
-		int work, weight;
 
 		/* If softirq window is exhausted then punt.
 		 * Allow this to run for 2 jiffies since which will allow
@@ -4583,48 +4634,7 @@ static void net_rx_action(struct softirq_action *h)
 
 
 		n = list_first_entry(&list, struct napi_struct, poll_list);
-		list_del_init(&n->poll_list);
-
-		have = netpoll_poll_lock(n);
-
-		weight = n->weight;
-
-		/* This NAPI_STATE_SCHED test is for avoiding a race
-		 * with netpoll's poll_napi().  Only the entity which
-		 * obtains the lock and sees NAPI_STATE_SCHED set will
-		 * actually make the ->poll() call.  Therefore we avoid
-		 * accidentally calling ->poll() when NAPI is not scheduled.
-		 */
-		work = 0;
-		if (test_bit(NAPI_STATE_SCHED, &n->state)) {
-			work = n->poll(n, weight);
-			trace_napi_poll(n);
-		}
-
-		WARN_ON_ONCE(work > weight);
-
-		budget -= work;
-
-		/* Drivers must not modify the NAPI state if they
-		 * consume the entire weight.  In such cases this code
-		 * still "owns" the NAPI instance and therefore can
-		 * move the instance around on the list at-will.
-		 */
-		if (unlikely(work == weight)) {
-			if (unlikely(napi_disable_pending(n))) {
-				napi_complete(n);
-			} else {
-				if (n->gro_list) {
-					/* flush too old packets
-					 * If HZ < 1000, flush all packets.
-					 */
-					napi_gro_flush(n, HZ >= 1000);
-				}
-				list_add_tail(&n->poll_list, &repoll);
-			}
-		}
-
-		netpoll_poll_unlock(have);
+		budget -= napi_poll(n, &repoll);
 	}
 
 	if (!sd_has_rps_ipi_waiting(sd) &&

From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 1/2] net: sched: consolidate handle_ing and ing_filter
Date: Sat,  9 May 2015 22:51:31 +0200
Message-ID: <1ce9def551699476aabe0d592825bf530c9a3e75.1431203900.git.daniel@iogearbox.net>
References: <cover.1431203900.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, jhs@mojatatu.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:43959 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751451AbbEIUvh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 16:51:37 -0400
In-Reply-To: <cover.1431203900.git.daniel@iogearbox.net>
In-Reply-To: <cover.1431203900.git.daniel@iogearbox.net>
References: <cover.1431203900.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Given quite some code has been removed from ing_filter(), we can just
consolidate that function into handle_ing() and get rid of a few
instructions at the same time.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 net/core/dev.c | 46 ++++++++++++++++------------------------------
 1 file changed, 16 insertions(+), 30 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 862875e..8a75746 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3521,37 +3521,19 @@ EXPORT_SYMBOL_GPL(br_fdb_test_addr_hook);
 #endif
 
 #ifdef CONFIG_NET_CLS_ACT
-/* TODO: Maybe we should just force sch_ingress to be compiled in
- * when CONFIG_NET_CLS_ACT is? otherwise some useless instructions
- * a compare and 2 stores extra right now if we dont have it on
- * but have CONFIG_NET_CLS_ACT
- * NOTE: This doesn't stop any functionality; if you dont have
- * the ingress scheduler, you just can't add policies on ingress.
- *
- */
-static int ing_filter(struct sk_buff *skb, struct netdev_queue *rxq)
-{
-	int result = TC_ACT_OK;
-	struct Qdisc *q;
-
-	skb->tc_verd = SET_TC_AT(skb->tc_verd, AT_INGRESS);
-
-	q = rcu_dereference(rxq->qdisc);
-	if (q != &noop_qdisc) {
-		if (likely(!test_bit(__QDISC_STATE_DEACTIVATED, &q->state)))
-			result = qdisc_enqueue_root(skb, q);
-	}
-
-	return result;
-}
-
 static inline struct sk_buff *handle_ing(struct sk_buff *skb,
 					 struct packet_type **pt_prev,
 					 int *ret, struct net_device *orig_dev)
 {
 	struct netdev_queue *rxq = rcu_dereference(skb->dev->ingress_queue);
+	struct Qdisc *q;
 
-	if (!rxq || rcu_access_pointer(rxq->qdisc) == &noop_qdisc)
+	/* If there's at least one ingress present somewhere (so
+	 * we get here via enabled static key), remaining devices
+	 * that are not configured with an ingress qdisc will bail
+	 * out w/o the rcu_dereference().
+	 */
+	if (!rxq || (q = rcu_dereference(rxq->qdisc)) == &noop_qdisc)
 		return skb;
 
 	if (*pt_prev) {
@@ -3559,11 +3541,15 @@ static inline struct sk_buff *handle_ing(struct sk_buff *skb,
 		*pt_prev = NULL;
 	}
 
-	switch (ing_filter(skb, rxq)) {
-	case TC_ACT_SHOT:
-	case TC_ACT_STOLEN:
-		kfree_skb(skb);
-		return NULL;
+	skb->tc_verd = SET_TC_AT(skb->tc_verd, AT_INGRESS);
+
+	if (likely(!test_bit(__QDISC_STATE_DEACTIVATED, &q->state))) {
+		switch (qdisc_enqueue_root(skb, q)) {
+		case TC_ACT_SHOT:
+		case TC_ACT_STOLEN:
+			kfree_skb(skb);
+			return NULL;
+		}
 	}
 
 	return skb;
-- 
1.9.3

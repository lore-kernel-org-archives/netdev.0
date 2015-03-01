From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 6/6] sched: Eliminate use of flow_keys in sch_sfq
Date: Sun,  1 Mar 2015 14:09:49 -0800
Message-ID: <1425247789-21211-7-git-send-email-therbert@google.com>
References: <1425247789-21211-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:44688 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752829AbbCAWKZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2015 17:10:25 -0500
Received: by igdh15 with SMTP id h15so12749321igd.3
        for <netdev@vger.kernel.org>; Sun, 01 Mar 2015 14:10:24 -0800 (PST)
In-Reply-To: <1425247789-21211-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Call qdisc_skb_get_hash instead of doing skb_flow_dissect and then
jhash by hand.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/sched/sch_sfq.c | 29 +++--------------------------
 1 file changed, 3 insertions(+), 26 deletions(-)

diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index b877140..e7ed8a5 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -23,7 +23,6 @@
 #include <linux/vmalloc.h>
 #include <net/netlink.h>
 #include <net/pkt_sched.h>
-#include <net/flow_keys.h>
 #include <net/red.h>
 
 
@@ -156,30 +155,10 @@ static inline struct sfq_head *sfq_dep_head(struct sfq_sched_data *q, sfq_index
 	return &q->dep[val - SFQ_MAX_FLOWS];
 }
 
-/*
- * In order to be able to quickly rehash our queue when timer changes
- * q->perturbation, we store flow_keys in skb->cb[]
- */
-struct sfq_skb_cb {
-       struct flow_keys        keys;
-};
-
-static inline struct sfq_skb_cb *sfq_skb_cb(const struct sk_buff *skb)
-{
-	qdisc_cb_private_validate(skb, sizeof(struct sfq_skb_cb));
-	return (struct sfq_skb_cb *)qdisc_skb_cb(skb)->data;
-}
-
 static unsigned int sfq_hash(const struct sfq_sched_data *q,
-			     const struct sk_buff *skb)
+			     struct sk_buff *skb)
 {
-	const struct flow_keys *keys = &sfq_skb_cb(skb)->keys;
-	unsigned int hash;
-
-	hash = jhash_3words((__force u32)keys->dst,
-			    (__force u32)keys->src ^ keys->ip_proto,
-			    (__force u32)keys->ports, q->perturbation);
-	return hash & (q->divisor - 1);
+	return skb_get_hash_perturb(skb, q->perturbation) & (q->divisor - 1);
 }
 
 static unsigned int sfq_classify(struct sk_buff *skb, struct Qdisc *sch,
@@ -196,10 +175,8 @@ static unsigned int sfq_classify(struct sk_buff *skb, struct Qdisc *sch,
 		return TC_H_MIN(skb->priority);
 
 	fl = rcu_dereference_bh(q->filter_list);
-	if (!fl) {
-		skb_flow_dissect(skb, &sfq_skb_cb(skb)->keys);
+	if (!fl)
 		return sfq_hash(q, skb) + 1;
-	}
 
 	*qerr = NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
 	result = tc_classify(skb, fl, &res);
-- 
2.2.0.rc0.207.ga3a616c

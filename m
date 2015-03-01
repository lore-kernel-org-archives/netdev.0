From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 5/6] sched: Eliminate use of flow_keys in sch_sfb
Date: Sun,  1 Mar 2015 14:09:48 -0800
Message-ID: <1425247789-21211-6-git-send-email-therbert@google.com>
References: <1425247789-21211-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:40484 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752933AbbCAWKX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2015 17:10:23 -0500
Received: by iebtr6 with SMTP id tr6so43328241ieb.7
        for <netdev@vger.kernel.org>; Sun, 01 Mar 2015 14:10:22 -0800 (PST)
In-Reply-To: <1425247789-21211-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Call qdisc_skb_get_hash instead of doing skb_flow_dissect and then
jhash by hand.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/sched/sch_sfb.c | 24 ++++++++----------------
 1 file changed, 8 insertions(+), 16 deletions(-)

diff --git a/net/sched/sch_sfb.c b/net/sched/sch_sfb.c
index 5819dd8..402d051 100644
--- a/net/sched/sch_sfb.c
+++ b/net/sched/sch_sfb.c
@@ -26,7 +26,6 @@
 #include <net/ip.h>
 #include <net/pkt_sched.h>
 #include <net/inet_ecn.h>
-#include <net/flow_keys.h>
 
 /*
  * SFB uses two B[l][n] : L x N arrays of bins (L levels, N bins per level)
@@ -285,9 +284,9 @@ static int sfb_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	int i;
 	u32 p_min = ~0;
 	u32 minqlen = ~0;
-	u32 r, slot, salt, sfbhash;
+	u32 r, sfbhash;
+	u32 slot = q->slot;
 	int ret = NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
-	struct flow_keys keys;
 
 	if (unlikely(sch->q.qlen >= q->limit)) {
 		qdisc_qstats_overlimit(sch);
@@ -309,22 +308,17 @@ static int sfb_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 
 	fl = rcu_dereference_bh(q->filter_list);
 	if (fl) {
+		u32 salt;
+
 		/* If using external classifiers, get result and record it. */
 		if (!sfb_classify(skb, fl, &ret, &salt))
 			goto other_drop;
-		keys.src = salt;
-		keys.dst = 0;
-		keys.ports = 0;
+		sfbhash = jhash_1word(salt, q->bins[q->slot].perturbation);
 	} else {
-		skb_flow_dissect(skb, &keys);
+		sfbhash = skb_get_hash_perturb(skb, q->bins[slot].perturbation);
 	}
 
-	slot = q->slot;
 
-	sfbhash = jhash_3words((__force u32)keys.dst,
-			       (__force u32)keys.src,
-			       (__force u32)keys.ports,
-			       q->bins[slot].perturbation);
 	if (!sfbhash)
 		sfbhash = 1;
 	sfb_skb_cb(skb)->hashes[slot] = sfbhash;
@@ -356,10 +350,8 @@ static int sfb_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	if (unlikely(p_min >= SFB_MAX_PROB)) {
 		/* Inelastic flow */
 		if (q->double_buffering) {
-			sfbhash = jhash_3words((__force u32)keys.dst,
-					       (__force u32)keys.src,
-					       (__force u32)keys.ports,
-					       q->bins[slot].perturbation);
+			sfbhash = skb_get_hash_perturb(skb,
+			    q->bins[slot].perturbation);
 			if (!sfbhash)
 				sfbhash = 1;
 			sfb_skb_cb(skb)->hashes[slot] = sfbhash;
-- 
2.2.0.rc0.207.ga3a616c

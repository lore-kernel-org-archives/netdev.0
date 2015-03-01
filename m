From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 2/6] sched: Eliminate use of flow_keys in sch_choke
Date: Sun,  1 Mar 2015 14:09:45 -0800
Message-ID: <1425247789-21211-3-git-send-email-therbert@google.com>
References: <1425247789-21211-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:35643 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752613AbbCAWKQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2015 17:10:16 -0500
Received: by igqa13 with SMTP id a13so12789491igq.0
        for <netdev@vger.kernel.org>; Sun, 01 Mar 2015 14:10:15 -0800 (PST)
In-Reply-To: <1425247789-21211-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In choke_match_flow compare skb_get_hash values for the skbuffs
instead of explicitly matching keys after calling flow_dissector.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/sched/sch_choke.c | 32 ++------------------------------
 1 file changed, 2 insertions(+), 30 deletions(-)

diff --git a/net/sched/sch_choke.c b/net/sched/sch_choke.c
index c009eb9..8faa375 100644
--- a/net/sched/sch_choke.c
+++ b/net/sched/sch_choke.c
@@ -18,7 +18,6 @@
 #include <net/pkt_sched.h>
 #include <net/inet_ecn.h>
 #include <net/red.h>
-#include <net/flow_keys.h>
 
 /*
    CHOKe stateless AQM for fair bandwidth allocation
@@ -133,16 +132,8 @@ static void choke_drop_by_idx(struct Qdisc *sch, unsigned int idx)
 	--sch->q.qlen;
 }
 
-/* private part of skb->cb[] that a qdisc is allowed to use
- * is limited to QDISC_CB_PRIV_LEN bytes.
- * As a flow key might be too large, we store a part of it only.
- */
-#define CHOKE_K_LEN min_t(u32, sizeof(struct flow_keys), QDISC_CB_PRIV_LEN - 3)
-
 struct choke_skb_cb {
 	u16			classid;
-	u8			keys_valid;
-	u8			keys[QDISC_CB_PRIV_LEN - 3];
 };
 
 static inline struct choke_skb_cb *choke_skb_cb(const struct sk_buff *skb)
@@ -169,26 +160,8 @@ static u16 choke_get_classid(const struct sk_buff *skb)
 static bool choke_match_flow(struct sk_buff *skb1,
 			     struct sk_buff *skb2)
 {
-	struct flow_keys temp;
-
-	if (skb1->protocol != skb2->protocol)
-		return false;
-
-	if (!choke_skb_cb(skb1)->keys_valid) {
-		choke_skb_cb(skb1)->keys_valid = 1;
-		skb_flow_dissect(skb1, &temp);
-		memcpy(&choke_skb_cb(skb1)->keys, &temp, CHOKE_K_LEN);
-	}
-
-	if (!choke_skb_cb(skb2)->keys_valid) {
-		choke_skb_cb(skb2)->keys_valid = 1;
-		skb_flow_dissect(skb2, &temp);
-		memcpy(&choke_skb_cb(skb2)->keys, &temp, CHOKE_K_LEN);
-	}
-
-	return !memcmp(&choke_skb_cb(skb1)->keys,
-		       &choke_skb_cb(skb2)->keys,
-		       CHOKE_K_LEN);
+	return (skb1->protocol == skb2->protocol &&
+		skb_get_hash(skb1) == skb_get_hash(skb2));
 }
 
 /*
@@ -279,7 +252,6 @@ static int choke_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 			goto other_drop;	/* Packet was eaten by filter */
 	}
 
-	choke_skb_cb(skb)->keys_valid = 0;
 	/* Compute average queue usage (see RED) */
 	q->vars.qavg = red_calc_qavg(p, &q->vars, sch->q.qlen);
 	if (red_is_idling(&q->vars))
-- 
2.2.0.rc0.207.ga3a616c

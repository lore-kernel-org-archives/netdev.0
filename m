From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 4/6] sched: Eliminate use of flow_keys in sch_hhf
Date: Sun,  1 Mar 2015 14:09:47 -0800
Message-ID: <1425247789-21211-5-git-send-email-therbert@google.com>
References: <1425247789-21211-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:38324 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752829AbbCAWKV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2015 17:10:21 -0500
Received: by iecrd18 with SMTP id rd18so43380152iec.5
        for <netdev@vger.kernel.org>; Sun, 01 Mar 2015 14:10:20 -0800 (PST)
In-Reply-To: <1425247789-21211-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Call qdisc_skb_get_hash instead of doing skb_flow_dissect and then
jhash by hand.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/sched/sch_hhf.c | 19 +------------------
 1 file changed, 1 insertion(+), 18 deletions(-)

diff --git a/net/sched/sch_hhf.c b/net/sched/sch_hhf.c
index 15d3aab..9d15cb6 100644
--- a/net/sched/sch_hhf.c
+++ b/net/sched/sch_hhf.c
@@ -9,7 +9,6 @@
 #include <linux/module.h>
 #include <linux/skbuff.h>
 #include <linux/vmalloc.h>
-#include <net/flow_keys.h>
 #include <net/pkt_sched.h>
 #include <net/sock.h>
 
@@ -176,22 +175,6 @@ static u32 hhf_time_stamp(void)
 	return jiffies;
 }
 
-static unsigned int skb_hash(const struct hhf_sched_data *q,
-			     const struct sk_buff *skb)
-{
-	struct flow_keys keys;
-	unsigned int hash;
-
-	if (skb->sk && skb->sk->sk_hash)
-		return skb->sk->sk_hash;
-
-	skb_flow_dissect(skb, &keys);
-	hash = jhash_3words((__force u32)keys.dst,
-			    (__force u32)keys.src ^ keys.ip_proto,
-			    (__force u32)keys.ports, q->perturbation);
-	return hash;
-}
-
 /* Looks up a heavy-hitter flow in a chaining list of table T. */
 static struct hh_flow_state *seek_list(const u32 hash,
 				       struct list_head *head,
@@ -280,7 +263,7 @@ static enum wdrr_bucket_idx hhf_classify(struct sk_buff *skb, struct Qdisc *sch)
 	}
 
 	/* Get hashed flow-id of the skb. */
-	hash = skb_hash(q, skb);
+	hash = skb_get_hash_perturb(skb, q->perturbation);
 
 	/* Check if this packet belongs to an already established HH flow. */
 	flow_pos = hash & HHF_BIT_MASK;
-- 
2.2.0.rc0.207.ga3a616c

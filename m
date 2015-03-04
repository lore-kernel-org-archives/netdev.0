From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 3/6] sched: Eliminate use of flow_keys in sch_fq_codel
Date: Wed,  4 Mar 2015 10:40:01 -0800
Message-ID: <1425494404-24114-4-git-send-email-therbert@google.com>
References: <1425494404-24114-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:46853 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759404AbbCDSkX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 13:40:23 -0500
Received: by iery20 with SMTP id y20so16140544ier.13
        for <netdev@vger.kernel.org>; Wed, 04 Mar 2015 10:40:22 -0800 (PST)
In-Reply-To: <1425494404-24114-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Call qdisc_skb_get_hash instead of doing skb_flow_dissect and then
jhash by hand.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/sched/sch_fq_codel.c | 11 ++---------
 1 file changed, 2 insertions(+), 9 deletions(-)

diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
index 1e52dec..a6fc53d 100644
--- a/net/sched/sch_fq_codel.c
+++ b/net/sched/sch_fq_codel.c
@@ -23,7 +23,6 @@
 #include <linux/vmalloc.h>
 #include <net/netlink.h>
 #include <net/pkt_sched.h>
-#include <net/flow_keys.h>
 #include <net/codel.h>
 
 /*	Fair Queue CoDel.
@@ -68,15 +67,9 @@ struct fq_codel_sched_data {
 };
 
 static unsigned int fq_codel_hash(const struct fq_codel_sched_data *q,
-				  const struct sk_buff *skb)
+				  struct sk_buff *skb)
 {
-	struct flow_keys keys;
-	unsigned int hash;
-
-	skb_flow_dissect(skb, &keys);
-	hash = jhash_3words((__force u32)keys.dst,
-			    (__force u32)keys.src ^ keys.ip_proto,
-			    (__force u32)keys.ports, q->perturbation);
+	u32 hash = skb_get_hash_perturb(skb, q->perturbation);
 
 	return reciprocal_scale(hash, q->flows_cnt);
 }
-- 
2.2.0.rc0.207.ga3a616c

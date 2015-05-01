From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v2 net-next 5/7] sched: Call skb_get_hash_perturb in sch_sfq
Date: Fri, 1 May 2015 11:30:16 -0700
Message-ID: <1430505018-496801-6-git-send-email-tom@herbertland.com>
References: <1430505018-496801-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:10176 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751825AbbEASam (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 14:30:42 -0400
Received: from pps.filterd (m0004060 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t41IPq5O013431
	for <netdev@vger.kernel.org>; Fri, 1 May 2015 11:30:41 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1u4efbg4f3-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 01 May 2015 11:30:41 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.236.89) with ESMTP	id
 2ad29afcf03011e497970002c95209d8-7aad4240 for <netdev@vger.kernel.org>;	Fri,
 01 May 2015 11:30:39 -0700
In-Reply-To: <1430505018-496801-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Call skb_get_hash_perturb instead of doing skb_flow_dissect and then
jhash by hand.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/sched/sch_sfq.c | 27 ++-------------------------
 1 file changed, 2 insertions(+), 25 deletions(-)

diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index b877140..7d14926 100644
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
 			     const struct sk_buff *skb)
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
1.8.1

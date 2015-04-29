From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 5/7] sched: Eliminate use of flow_keys in sch_sfq
Date: Tue, 28 Apr 2015 21:27:39 -0700
Message-ID: <1430281661-2271966-6-git-send-email-tom@herbertland.com>
References: <1430281661-2271966-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <jiri@resnulli.us>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:17739 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S966107AbbD2E2P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 00:28:15 -0400
Received: from pps.filterd (m0004077 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t3T4ReYd007213
	for <netdev@vger.kernel.org>; Tue, 28 Apr 2015 21:28:15 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1u2p8fr9xa-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 28 Apr 2015 21:28:15 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.232.63) with ESMTP	id
 2630408aee2811e4954e0002c992ebde-37fd12c0 for <netdev@vger.kernel.org>;	Tue,
 28 Apr 2015 21:28:13 -0700
In-Reply-To: <1430281661-2271966-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Call qdisc_skb_get_hash instead of doing skb_flow_dissect and then
jhash by hand.

Signed-off-by: Tom Herbert <tom@herbertland.com>
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
1.8.1

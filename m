From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 4/7] sched: Eliminate use of flow_keys in sch_sfb
Date: Tue, 28 Apr 2015 21:27:38 -0700
Message-ID: <1430281661-2271966-5-git-send-email-tom@herbertland.com>
References: <1430281661-2271966-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <jiri@resnulli.us>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:22220 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S966113AbbD2E2N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 00:28:13 -0400
Received: from pps.filterd (m0004347 [127.0.0.1])
	by m0004347.ppops.net (8.14.5/8.14.5) with SMTP id t3T4R9YS010149
	for <netdev@vger.kernel.org>; Tue, 28 Apr 2015 21:28:12 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0004347.ppops.net with ESMTP id 1u2qpfr1g1-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 28 Apr 2015 21:28:12 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.236.89) with ESMTP	id
 2504c05aee2811e48b1a0002c95209d8-e51c62c0 for <netdev@vger.kernel.org>;	Tue,
 28 Apr 2015 21:28:11 -0700
In-Reply-To: <1430281661-2271966-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Call qdisc_skb_get_hash instead of doing skb_flow_dissect and then
jhash by hand.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/sched/sch_sfb.c | 24 ++++++++----------------
 1 file changed, 8 insertions(+), 16 deletions(-)

diff --git a/net/sched/sch_sfb.c b/net/sched/sch_sfb.c
index 5819dd8..4b81519 100644
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
+		sfbhash = jhash_1word(salt, q->bins[slot].perturbation);
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
1.8.1

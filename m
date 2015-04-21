From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [RFC 1/3] tc: fix return values of ingress qdisc
Date: Tue, 21 Apr 2015 12:27:54 -0700
Message-ID: <1429644476-8914-2-git-send-email-ast@plumgrid.com>
References: <1429644476-8914-1-git-send-email-ast@plumgrid.com>
Cc: Eric Dumazet <edumazet@google.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:35317 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755982AbbDUT2M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2015 15:28:12 -0400
Received: by pabtp1 with SMTP id tp1so249941010pab.2
        for <netdev@vger.kernel.org>; Tue, 21 Apr 2015 12:28:11 -0700 (PDT)
In-Reply-To: <1429644476-8914-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ingress qdisc should return NET_XMIT_* values just like all other qdiscs.

Since it's invoked via qdisc_enqueue_root() (which suppose to return
only NET_XMIT_* values as well), it was working by accident,
since TC_ACT_* values fit within NET_XMIT_MASK.

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 net/core/dev.c          |    8 ++------
 net/sched/sch_ingress.c |    9 ++++-----
 2 files changed, 6 insertions(+), 11 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 1796cef55ab5..ac6233f6f353 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3533,7 +3533,7 @@ static int ing_filter(struct sk_buff *skb, struct netdev_queue *rxq)
 {
 	struct net_device *dev = skb->dev;
 	u32 ttl = G_TC_RTTL(skb->tc_verd);
-	int result = TC_ACT_OK;
+	int result = NET_XMIT_SUCCESS;
 	struct Qdisc *q;
 
 	if (unlikely(MAX_RED_LOOP < ttl++)) {
@@ -3570,12 +3570,8 @@ static inline struct sk_buff *handle_ing(struct sk_buff *skb,
 		*pt_prev = NULL;
 	}
 
-	switch (ing_filter(skb, rxq)) {
-	case TC_ACT_SHOT:
-	case TC_ACT_STOLEN:
-		kfree_skb(skb);
+	if (ing_filter(skb, rxq) == NET_XMIT_DROP)
 		return NULL;
-	}
 
 	return skb;
 }
diff --git a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
index 4cdbfb85686a..e68f4a5dbeba 100644
--- a/net/sched/sch_ingress.c
+++ b/net/sched/sch_ingress.c
@@ -65,21 +65,20 @@ static int ingress_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 
 	result = tc_classify(skb, fl, &res);
 
-	qdisc_bstats_update(sch, skb);
 	switch (result) {
 	case TC_ACT_SHOT:
-		result = TC_ACT_SHOT;
 		qdisc_qstats_drop(sch);
-		break;
 	case TC_ACT_STOLEN:
 	case TC_ACT_QUEUED:
-		result = TC_ACT_STOLEN;
+		result = NET_XMIT_DROP;
+		kfree_skb(skb);
 		break;
 	case TC_ACT_RECLASSIFY:
 	case TC_ACT_OK:
 		skb->tc_index = TC_H_MIN(res.classid);
 	default:
-		result = TC_ACT_OK;
+		qdisc_bstats_update(sch, skb);
+		result = NET_XMIT_SUCCESS;
 		break;
 	}
 
-- 
1.7.9.5

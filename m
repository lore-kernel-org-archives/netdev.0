From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH v2] act_mirred: don't clone skb when skb isn't shared
Date: Sat,  5 Jun 2010 20:39:13 +0800
Message-ID: <1275741553-21463-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Jamal Hadi Salim <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f185.google.com ([209.85.222.185]:38642 "EHLO
	mail-pz0-f185.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756112Ab0FEOiw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jun 2010 10:38:52 -0400
Received: by pzk15 with SMTP id 15so1520203pzk.15
        for <netdev@vger.kernel.org>; Sat, 05 Jun 2010 07:38:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

don't clone skb when skb isn't shared

When the tcf_action is TC_ACT_STOLEN, and the skb isn't shared, we don't need
to clone a new skb. As the skb will be freed after this function returns, we
can use it freely once we get a reference to it.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 include/net/sch_generic.h |   11 +++++++++--
 net/sched/act_mirred.c    |    6 +++---
 2 files changed, 12 insertions(+), 5 deletions(-)
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 03ca5d8..d7d4439 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -571,9 +571,16 @@ static inline u32 qdisc_l2t(struct qdisc_rate_table* rtab, unsigned int pktlen)
 }
 
 #ifdef CONFIG_NET_CLS_ACT
-static inline struct sk_buff *skb_act_clone(struct sk_buff *skb, gfp_t gfp_mask)
+static inline struct sk_buff *skb_act_clone(struct sk_buff *skb, gfp_t gfp_mask,
+					    int action)
 {
-	struct sk_buff *n = skb_clone(skb, gfp_mask);
+	struct sk_buff *n;
+
+	if ((action == TC_ACT_SHOT || action == TC_ACT_STOLEN ||
+	     action == TC_ACT_QUEUED) && !skb_shared(skb))
+		n = skb_get(skb);
+	else
+		n = skb_clone(skb, gfp_mask);
 
 	if (n) {
 		n->tc_verd = SET_TC_VERD(n->tc_verd, 0);
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index c0b6863..2e9a7b9 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -169,13 +169,13 @@ static int tcf_mirred(struct sk_buff *skb, struct tc_action *a,
 		goto out;
 	}
 
-	skb2 = skb_act_clone(skb, GFP_ATOMIC);
+	at = G_TC_AT(skb->tc_verd);
+	skb2 = skb_act_clone(skb, GFP_ATOMIC, m->tcf_action);
 	if (skb2 == NULL)
 		goto out;
 
 	m->tcf_bstats.bytes += qdisc_pkt_len(skb2);
 	m->tcf_bstats.packets++;
-	at = G_TC_AT(skb->tc_verd);
 	if (!(at & AT_EGRESS)) {
 		if (m->tcfm_ok_push)
 			skb_push(skb2, skb2->dev->hard_header_len);
@@ -185,8 +185,8 @@ static int tcf_mirred(struct sk_buff *skb, struct tc_action *a,
 	if (m->tcfm_eaction != TCA_EGRESS_MIRROR)
 		skb2->tc_verd = SET_TC_FROM(skb2->tc_verd, at);
 
-	skb2->dev = dev;
 	skb2->skb_iif = skb->dev->ifindex;
+	skb2->dev = dev;
 	dev_queue_xmit(skb2);
 	err = 0;
 

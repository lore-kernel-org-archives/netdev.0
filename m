From: kaber@trash.net
Subject: [PATCH] net_sched: sch_hfsc: fix classification loops
Date: Fri, 14 May 2010 20:08:14 +0200
Message-ID: <1273860494-23328-1-git-send-email-kaber@trash.net>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:50117 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753442Ab0ENSIP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 May 2010 14:08:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

When attaching filters to a class pointing to a class higher up in the
hierarchy, classification may enter an endless loop. Currently this is
prevented for filters that are already resolved, but not for filters
resolved at runtime.

Only allow filters to point downwards in the hierarchy, similar to what
CBQ does.

Reported-by: Pawel Staszewski <pstaszewski@itcare.pl>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/sched/sch_hfsc.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index b38b39c..a435cf1 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1155,7 +1155,7 @@ static struct hfsc_class *
 hfsc_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 {
 	struct hfsc_sched *q = qdisc_priv(sch);
-	struct hfsc_class *cl;
+	struct hfsc_class *head, *cl;
 	struct tcf_result res;
 	struct tcf_proto *tcf;
 	int result;
@@ -1166,6 +1166,7 @@ hfsc_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 			return cl;
 
 	*qerr = NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
+	head = &q->root;
 	tcf = q->root.filter_list;
 	while (tcf && (result = tc_classify(skb, tcf, &res)) >= 0) {
 #ifdef CONFIG_NET_CLS_ACT
@@ -1180,6 +1181,8 @@ hfsc_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 		if ((cl = (struct hfsc_class *)res.class) == NULL) {
 			if ((cl = hfsc_find_class(res.classid, sch)) == NULL)
 				break; /* filter selected invalid classid */
+			if (cl->level >= head->level)
+				break; /* filter may only point downwards */
 		}
 
 		if (cl->level == 0)
@@ -1187,6 +1190,7 @@ hfsc_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 
 		/* apply inner filter chain */
 		tcf = cl->filter_list;
+		head = cl;
 	}
 
 	/* classification failed, try default class */
-- 
1.7.0.4


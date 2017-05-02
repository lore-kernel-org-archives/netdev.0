From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH 09/17] net: sched: check for frozen queue before
 skb_bad_txq check
Date: Tue, 02 May 2017 08:27:39 -0700
Message-ID: <20170502152739.8871.29058.stgit@john-Precision-Tower-5810>
References: <20170502151445.8871.43089.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.fastabend@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33021 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750733AbdEBP1w (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 11:27:52 -0400
Received: by mail-pf0-f194.google.com with SMTP id b23so17867364pfc.0
        for <netdev@vger.kernel.org>; Tue, 02 May 2017 08:27:52 -0700 (PDT)
In-Reply-To: <20170502151445.8871.43089.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I can not think of any good reason to pull the bad txq skb off the
qdisc if the txq we plan to send this on is still frozen. So check
for frozen queue first and abort before dequeuing either skb_bad_txq
skb or normal qdisc dequeue() skb.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 net/sched/sch_generic.c |   11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index d4194c2..db5f7a0 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -203,7 +203,7 @@ static struct sk_buff *dequeue_skb(struct Qdisc *q, bool *validate,
 				   int *packets)
 {
 	const struct netdev_queue *txq = q->dev_queue;
-	struct sk_buff *skb;
+	struct sk_buff *skb = NULL;
 
 	*packets = 1;
 	if (unlikely(!skb_queue_empty(&q->gso_skb))) {
@@ -247,12 +247,15 @@ static struct sk_buff *dequeue_skb(struct Qdisc *q, bool *validate,
 	}
 validate:
 	*validate = true;
+
+	if ((q->flags & TCQ_F_ONETXQUEUE) &&
+	    netif_xmit_frozen_or_stopped(txq))
+		return skb;
+
 	skb = qdisc_dequeue_skb_bad_txq(q);
 	if (unlikely(skb))
 		goto bulk;
-	if (!(q->flags & TCQ_F_ONETXQUEUE) ||
-	    !netif_xmit_frozen_or_stopped(txq))
-		skb = q->dequeue(q);
+	skb = q->dequeue(q);
 	if (skb) {
 bulk:
 		if (qdisc_may_bulk(q))

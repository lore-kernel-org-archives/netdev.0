From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH] pkt_sched: sch_drr: Fix drr_dequeue() loop
Date: Mon, 24 Nov 2008 10:50:23 +0000
Message-ID: <20081124105023.GA13957@ff.dom.local>
References: <20081120113557.GA5275@ff.dom.local> <49254D42.10506@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.25]:40674 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751599AbYKXKua (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 05:50:30 -0500
Received: by ey-out-2122.google.com with SMTP id 6so782515eyi.37
        for <netdev@vger.kernel.org>; Mon, 24 Nov 2008 02:50:28 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <49254D42.10506@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

pkt_sched: sch_drr: Fix loop in drr_dequeue

If all child qdiscs of sch_drr are non-work-conserving (e.g. sch_tbf)
drr_dequeue() will busy-loop waiting for skbs instead of leaving the
job for a watchdog. Checking for list_empty() in each loop isn't
necessary either, because this can never be true exept the first time.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

 net/sched/sch_drr.c |   24 +++++++++++++++++++++---
 1 files changed, 21 insertions(+), 3 deletions(-)

diff --git a/net/sched/sch_drr.c b/net/sched/sch_drr.c
index 37e6ab9..ab75461 100644
--- a/net/sched/sch_drr.c
+++ b/net/sched/sch_drr.c
@@ -369,12 +369,17 @@ static int drr_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 static struct sk_buff *drr_dequeue(struct Qdisc *sch)
 {
 	struct drr_sched *q = qdisc_priv(sch);
-	struct drr_class *cl;
+	struct drr_class *cl, *cl_first;
 	struct sk_buff *skb;
 	unsigned int len;
+	bool skb_waiting = false;
 
-	while (!list_empty(&q->active)) {
-		cl = list_first_entry(&q->active, struct drr_class, alist);
+	if (list_empty(&q->active))
+		return NULL;
+
+	cl_first = cl = list_first_entry(&q->active, struct drr_class, alist);
+
+	while (1) {
 		skb = cl->qdisc->ops->peek(cl->qdisc);
 		if (skb == NULL)
 			goto skip;
@@ -390,9 +395,22 @@ static struct sk_buff *drr_dequeue(struct Qdisc *sch)
 		}
 
 		cl->deficit += cl->quantum;
+		skb_waiting = true;
 skip:
 		list_move_tail(&cl->alist, &q->active);
+		cl = list_first_entry(&q->active, struct drr_class, alist);
+
+		if (cl == cl_first) {
+			if (skb_waiting) {
+				/* next round of deficit refilling */
+				skb_waiting = false;
+			} else {
+				/* all qdiscs are non-work-conserving! */
+				break;
+			}
+		}
 	}
+
 	return NULL;
 }
 

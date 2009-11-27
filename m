From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] sch_htb: ix the deficit overflows
Date: Fri, 27 Nov 2009 16:14:21 +0800
Message-ID: <4B0F8A5D.1040806@gmail.com>
Reply-To: xiaosuo@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiaosuo <xiaosuo@gmail.com>
To: Jamal Hadi Salim <hadi@cyberus.ca>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f180.google.com ([209.85.216.180]:50622 "EHLO
	mail-px0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751063AbZK0IOb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Nov 2009 03:14:31 -0500
Received: by pxi10 with SMTP id 10so991337pxi.33
        for <netdev@vger.kernel.org>; Fri, 27 Nov 2009 00:14:37 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fix the deficit overflows.

HTB uses WDRR(Weighted Deficit Round Robin) algorithm to schedule the spare bandwidth, but it doesn't check if the deficit is big enough for the skb when dequeuing skb from a class. In some case(the quantum is smaller than the packet size), the deficit will be decreased, even when it is smaller than ZERO. At last, the deficit will overflows, and become MAX_INT.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 sch_htb.c |   25 ++++++++++++++++++++-----
 1 file changed, 20 insertions(+), 5 deletions(-)
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 2e38d1a..293983e 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -783,6 +783,7 @@ static struct sk_buff *htb_dequeue_tree(struct htb_sched *q, int prio,
 {
 	struct sk_buff *skb = NULL;
 	struct htb_class *cl, *start;
+	unsigned int len;
 	/* look initial class up in the row */
 	start = cl = htb_lookup_leaf(q->row[level] + prio, prio,
 				     q->ptr[level] + prio,
@@ -815,9 +816,23 @@ next:
 			goto next;
 		}
 
-		skb = cl->un.leaf.q->dequeue(cl->un.leaf.q);
-		if (likely(skb != NULL))
-			break;
+		skb = cl->un.leaf.q->ops->peek(cl->un.leaf.q);
+		if (likely(skb != NULL)) {
+			len = qdisc_pkt_len(skb);
+			if (len <= cl->un.leaf.deficit[level]) {
+				skb = qdisc_dequeue_peeked(cl->un.leaf.q);
+				break;
+			}
+			skb = NULL;
+			cl->un.leaf.deficit[level] += cl->quantum;
+			htb_next_rb_node((level ? cl->parent->un.inner.ptr :
+					  q->ptr[0]) + prio);
+			cl = htb_lookup_leaf(q->row[level] + prio, prio,
+					     q->ptr[level] + prio,
+					     q->last_ptr_id[level] + prio);
+			start = cl;
+			goto next;
+		}
 
 		qdisc_warn_nonwc("htb", cl->un.leaf.q);
 		htb_next_rb_node((level ? cl->parent->un.inner.ptr : q->
@@ -829,8 +844,8 @@ next:
 	} while (cl != start);
 
 	if (likely(skb != NULL)) {
-		cl->un.leaf.deficit[level] -= qdisc_pkt_len(skb);
-		if (cl->un.leaf.deficit[level] < 0) {
+		cl->un.leaf.deficit[level] -= len;
+		if (cl->un.leaf.deficit[level] <= 0) {
 			cl->un.leaf.deficit[level] += cl->quantum;
 			htb_next_rb_node((level ? cl->parent->un.inner.ptr : q->
 					  ptr[0]) + prio);


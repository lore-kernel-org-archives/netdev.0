From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH][NET_SCHED] sch_htb: htb_requeue fix
Date: Fri, 8 Feb 2008 08:57:49 +0000
Message-ID: <20080208085749.GA5656@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.187]:12330 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757707AbYBHIup (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2008 03:50:45 -0500
Received: by mu-out-0910.google.com with SMTP id i10so4074250mue.5
        for <netdev@vger.kernel.org>; Fri, 08 Feb 2008 00:50:43 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

htb_requeue() enqueues skbs for which htb_classify() returns NULL.
This is wrong because such skbs could be handled by NET_CLS_ACT code,
and the decision could be different than earlier in htb_enqueue().
So htb_requeue() is changed to work and look more like htb_enqueue().


Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

---

diff -Nurp 2.6.24-mm1-/net/sched/sch_htb.c 2.6.24-mm1+/net/sched/sch_htb.c
--- 2.6.24-mm1-/net/sched/sch_htb.c	2008-02-05 07:45:48.000000000 +0000
+++ 2.6.24-mm1+/net/sched/sch_htb.c	2008-02-08 08:19:25.000000000 +0000
@@ -609,14 +609,14 @@ static int htb_enqueue(struct sk_buff *s
 /* TODO: requeuing packet charges it to policers again !! */
 static int htb_requeue(struct sk_buff *skb, struct Qdisc *sch)
 {
+	int ret;
 	struct htb_sched *q = qdisc_priv(sch);
-	int ret = NET_XMIT_SUCCESS;
 	struct htb_class *cl = htb_classify(skb, sch, &ret);
 	struct sk_buff *tskb;
 
-	if (cl == HTB_DIRECT || !cl) {
+	if (cl == HTB_DIRECT) {
 		/* enqueue to helper queue */
-		if (q->direct_queue.qlen < q->direct_qlen && cl) {
+		if (q->direct_queue.qlen < q->direct_qlen) {
 			__skb_queue_head(&q->direct_queue, skb);
 		} else {
 			__skb_queue_head(&q->direct_queue, skb);
@@ -625,6 +625,13 @@ static int htb_requeue(struct sk_buff *s
 			sch->qstats.drops++;
 			return NET_XMIT_CN;
 		}
+#ifdef CONFIG_NET_CLS_ACT
+	} else if (!cl) {
+		if (ret == NET_XMIT_BYPASS)
+			sch->qstats.drops++;
+		kfree_skb(skb);
+		return ret;
+#endif
 	} else if (cl->un.leaf.q->ops->requeue(skb, cl->un.leaf.q) !=
 		   NET_XMIT_SUCCESS) {
 		sch->qstats.drops++;

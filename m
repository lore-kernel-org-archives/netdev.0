From: Kyeong Yoo <kyeong.yoo@alliedtelesis.co.nz>
Subject: [PATCH net-next v3] net_sched: dsmark: use qdisc_dequeue_peeked()
Date: Mon, 07 Mar 2016 17:07:57 +1300
Message-ID: <20160307040735.17574.71568.stgit@kyeongy-dl>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate2.alliedtelesis.co.nz ([202.36.163.20]:53333 "EHLO
	gate2.alliedtelesis.co.nz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751869AbcCGEIA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Mar 2016 23:08:00 -0500
Received: from mmarshal3.atlnz.lc (mmarshal3.atlnz.lc [10.32.18.43])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(Client did not present a certificate)
	by gate2.alliedtelesis.co.nz (Postfix) with ESMTPS id 3BD5E806A3
	for <netdev@vger.kernel.org>; Mon,  7 Mar 2016 17:07:58 +1300 (NZDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fix is for dsmark similar to commit 3557619f0f6f7496ed453d4825e249
("net_sched: prio: use qdisc_dequeue_peeked")
and makes use of qdisc_dequeue_peeked() instead of direct dequeue() call.

First time, wrr peeks dsmark, which will then peek into sfq.
sfq dequeues an skb and it's stored in sch->gso_skb.
Next time, wrr tries to dequeue from dsmark, which will call sfq dequeue
directly. This results skipping the previously peeked skb.

So changed dsmark dequeue to call qdisc_dequeue_peeked() instead to use
peeked skb if exists.

Signed-off-by: Kyeong Yoo <kyeong.yoo@alliedtelesis.co.nz>
---
 net/sched/sch_dsmark.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index f357f34..b204472 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -281,7 +281,7 @@ static struct sk_buff *dsmark_dequeue(struct Qdisc *sch)
 
 	pr_debug("%s(sch %p,[qdisc %p])\n", __func__, sch, p);
 
-	skb = p->q->ops->dequeue(p->q);
+	skb = qdisc_dequeue_peeked(p->q);
 	if (skb == NULL)
 		return NULL;
 

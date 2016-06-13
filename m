From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 net] net_sched: prio: insure proper transactional behavior
Date: Mon, 13 Jun 2016 11:33:32 -0700
Message-ID: <1465842812.7945.175.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1465773707.7945.133.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CAM_iQpXY0Ce5hbXYGOcd-N1tb9BH33JYXFQdmWEbsc5SWYsV8A@mail.gmail.com>
	 <1465792157.7945.145.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1465794231.7945.150.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CAM_iQpWWLTMRUNUeS9=6B3KqA6Tyu0qaUYSRw_PFYFK_mo7Urw@mail.gmail.com>
	 <1465838004.7945.167.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1465838879.7945.168.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:36616 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751920AbcFMSdf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 14:33:35 -0400
Received: by mail-pa0-f66.google.com with SMTP id fg1so10937452pad.3
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 11:33:34 -0700 (PDT)
In-Reply-To: <1465838879.7945.168.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Now prio_init() can return -ENOMEM, it also has to make sure
any allocated qdiscs are freed, since the caller (qdisc_create()) wont
call ->destroy() handler for us.

More generally, we want a transactional behavior for "tc qdisc
change ...", so prio_tune() should not make modifications if
any error is returned.

It means that we must validate parameters and allocate missing qdisc(s)
before taking root qdisc lock exactly once, to not leave the prio qdisc
in an intermediate state.

Fixes: cbdf45116478 ("net_sched: prio: properly report out of memory errors")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/sch_prio.c |   57 ++++++++++++++++++++-------------------------------
 1 file changed, 23 insertions(+), 34 deletions(-)

diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index 071718bccdab..a356450b747b 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -172,8 +172,9 @@ prio_destroy(struct Qdisc *sch)
 static int prio_tune(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct prio_sched_data *q = qdisc_priv(sch);
+	struct Qdisc *queues[TCQ_PRIO_BANDS];
+	int oldbands = q->bands, i;
 	struct tc_prio_qopt *qopt;
-	int i;
 
 	if (nla_len(opt) < sizeof(*qopt))
 		return -EINVAL;
@@ -187,54 +188,42 @@ static int prio_tune(struct Qdisc *sch, struct nlattr *opt)
 			return -EINVAL;
 	}
 
+	/* Before commit, make sure we can allocate all new qdiscs */
+	for (i = oldbands; i < qopt->bands; i++) {
+		queues[i] = qdisc_create_dflt(sch->dev_queue, &pfifo_qdisc_ops,
+					      TC_H_MAKE(sch->handle, i + 1));
+		if (!queues[i]) {
+			while (i > oldbands)
+				qdisc_destroy(queues[--i]);
+			return -ENOMEM;
+		}
+	}
+
 	sch_tree_lock(sch);
 	q->bands = qopt->bands;
 	memcpy(q->prio2band, qopt->priomap, TC_PRIO_MAX+1);
 
-	for (i = q->bands; i < TCQ_PRIO_BANDS; i++) {
+	for (i = q->bands; i < oldbands; i++) {
 		struct Qdisc *child = q->queues[i];
-		q->queues[i] = &noop_qdisc;
-		if (child != &noop_qdisc) {
-			qdisc_tree_reduce_backlog(child, child->q.qlen, child->qstats.backlog);
-			qdisc_destroy(child);
-		}
-	}
-	sch_tree_unlock(sch);
 
-	for (i = 0; i < q->bands; i++) {
-		struct Qdisc *child;
+		qdisc_tree_reduce_backlog(child, child->q.qlen,
+					  child->qstats.backlog);
+		qdisc_destroy(child);
+	}
 
-		if (q->queues[i] != &noop_qdisc)
-			continue;
+	for (i = oldbands; i < q->bands; i++)
+		q->queues[i] = queues[i];
 
-		child = qdisc_create_dflt(sch->dev_queue, &pfifo_qdisc_ops,
-					  TC_H_MAKE(sch->handle, i + 1));
-		if (!child)
-			return -ENOMEM;
-		sch_tree_lock(sch);
-		q->queues[i] = child;
-		sch_tree_unlock(sch);
-	}
+	sch_tree_unlock(sch);
 	return 0;
 }
 
 static int prio_init(struct Qdisc *sch, struct nlattr *opt)
 {
-	struct prio_sched_data *q = qdisc_priv(sch);
-	int i;
-
-	for (i = 0; i < TCQ_PRIO_BANDS; i++)
-		q->queues[i] = &noop_qdisc;
-
-	if (opt == NULL) {
+	if (!opt)
 		return -EINVAL;
-	} else {
-		int err;
 
-		if ((err = prio_tune(sch, opt)) != 0)
-			return err;
-	}
-	return 0;
+	return prio_tune(sch, opt);
 }
 
 static int prio_dump(struct Qdisc *sch, struct sk_buff *skb)

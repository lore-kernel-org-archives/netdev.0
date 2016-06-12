From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] net_sched: prio: properly report out of memory errors
Date: Sun, 12 Jun 2016 16:21:47 -0700
Message-ID: <1465773707.7945.133.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:35858 "EHLO
	mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932668AbcFLXVu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jun 2016 19:21:50 -0400
Received: by mail-io0-f193.google.com with SMTP id o127so12103104iod.3
        for <netdev@vger.kernel.org>; Sun, 12 Jun 2016 16:21:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

At Qdisc creation or change time, prio_tune() creates missing
pfifo qdiscs but does not return an error code if one
qdisc could not be allocated.

Leaving a qdisc in non operational state without telling user
anything about this problem is not good.

Also, testing if we replace something different than noop_qdisc
a second time makes no sense so I removed useless code.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/sched/sch_prio.c |   32 ++++++++++++--------------------
 1 file changed, 12 insertions(+), 20 deletions(-)

diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index 4b0a82191bc4..071718bccdab 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -202,26 +202,18 @@ static int prio_tune(struct Qdisc *sch, struct nlattr *opt)
 	sch_tree_unlock(sch);
 
 	for (i = 0; i < q->bands; i++) {
-		if (q->queues[i] == &noop_qdisc) {
-			struct Qdisc *child, *old;
-
-			child = qdisc_create_dflt(sch->dev_queue,
-						  &pfifo_qdisc_ops,
-						  TC_H_MAKE(sch->handle, i + 1));
-			if (child) {
-				sch_tree_lock(sch);
-				old = q->queues[i];
-				q->queues[i] = child;
-
-				if (old != &noop_qdisc) {
-					qdisc_tree_reduce_backlog(old,
-								  old->q.qlen,
-								  old->qstats.backlog);
-					qdisc_destroy(old);
-				}
-				sch_tree_unlock(sch);
-			}
-		}
+		struct Qdisc *child;
+
+		if (q->queues[i] != &noop_qdisc)
+			continue;
+
+		child = qdisc_create_dflt(sch->dev_queue, &pfifo_qdisc_ops,
+					  TC_H_MAKE(sch->handle, i + 1));
+		if (!child)
+			return -ENOMEM;
+		sch_tree_lock(sch);
+		q->queues[i] = child;
+		sch_tree_unlock(sch);
 	}
 	return 0;
 }

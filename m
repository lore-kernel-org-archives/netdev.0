From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] pkt_sched: set root qdisc before change() in
 attach_default_qdiscs()
Date: Thu, 12 Dec 2013 15:41:56 -0800
Message-ID: <1386891716.19078.119.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f43.google.com ([209.85.213.43]:54690 "EHLO
	mail-yh0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751831Ab3LLXl7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 18:41:59 -0500
Received: by mail-yh0-f43.google.com with SMTP id a41so967304yho.30
        for <netdev@vger.kernel.org>; Thu, 12 Dec 2013 15:41:59 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

After commit 95dc19299f74 ("pkt_sched: give visibility to mq slave
qdiscs") we call disc_list_add() while the device qdisc might be
the noop_qdisc one.

This shows up as duplicates in "tc qdisc show", as all inactive devices
point to noop_qdisc.

Fix this by setting dev->qdisc to the new qdisc before calling
ops->change() in attach_default_qdiscs()

Add a WARN_ON_ONCE() to catch any future similar problem.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/sched/sch_api.c     |    5 ++++-
 net/sched/sch_generic.c |    2 +-
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 547b4a8..c31190e 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -273,8 +273,11 @@ static struct Qdisc *qdisc_match_from_root(struct Qdisc *root, u32 handle)
 
 void qdisc_list_add(struct Qdisc *q)
 {
+	struct Qdisc *root = qdisc_dev(q)->qdisc;
+
+	WARN_ON_ONCE(root == &noop_qdisc);
 	if ((q->parent != TC_H_ROOT) && !(q->flags & TCQ_F_INGRESS))
-		list_add_tail(&q->list, &qdisc_dev(q)->qdisc->list);
+		list_add_tail(&q->list, &root->list);
 }
 EXPORT_SYMBOL(qdisc_list_add);
 
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 6a91d7d..32bb942 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -718,8 +718,8 @@ static void attach_default_qdiscs(struct net_device *dev)
 	} else {
 		qdisc = qdisc_create_dflt(txq, &mq_qdisc_ops, TC_H_ROOT);
 		if (qdisc) {
-			qdisc->ops->attach(qdisc);
 			dev->qdisc = qdisc;
+			qdisc->ops->attach(qdisc);
 		}
 	}
 }

From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net_sched: increment drop counters in
 qdisc_tree_decrease_qlen()
Date: Mon, 07 Oct 2013 08:32:32 -0700
Message-ID: <1381159952.12191.14.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:60356 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751634Ab3JGPce (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Oct 2013 11:32:34 -0400
Received: by mail-pd0-f177.google.com with SMTP id y10so7213524pdj.8
        for <netdev@vger.kernel.org>; Mon, 07 Oct 2013 08:32:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

qdisc_tree_decrease_qlen() is called when some packets are dropped
on a qdisc, and we want to notify parents of qlen changes.

We also can increment parents qdisc qstats drop counters.

This permits more accurate drop counters up to root qdisc.

For example a graft operation typically resets a qdisc 
(drops all packets) and call qdisc_tree_decrease_qlen()

Note that callers are responsible for their drop counters.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/sched/sch_api.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 2adda7f..cd81505 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -737,9 +737,11 @@ void qdisc_tree_decrease_qlen(struct Qdisc *sch, unsigned int n)
 	const struct Qdisc_class_ops *cops;
 	unsigned long cl;
 	u32 parentid;
+	int drops;
 
 	if (n == 0)
 		return;
+	drops = max_t(int, n, 0);
 	while ((parentid = sch->parent)) {
 		if (TC_H_MAJ(parentid) == TC_H_MAJ(TC_H_INGRESS))
 			return;
@@ -756,6 +758,7 @@ void qdisc_tree_decrease_qlen(struct Qdisc *sch, unsigned int n)
 			cops->put(sch, cl);
 		}
 		sch->q.qlen -= n;
+		sch->qstats.drops += drops;
 	}
 }
 EXPORT_SYMBOL(qdisc_tree_decrease_qlen);

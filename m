From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 01/06]: sch_htb: perform qlen adjustment immediately in ->delete
Date: Mon, 20 Nov 2006 14:08:37 +0100 (MET)
Message-ID: <20061120130836.22347.80939.sendpatchset@localhost.localdomain>
References: <20061120130834.22347.34853.sendpatchset@localhost.localdomain>
Cc: devik@cdi.cz, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:7678 "EHLO stinky.trash.net")
	by vger.kernel.org with ESMTP id S965834AbWKTNIi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Nov 2006 08:08:38 -0500
To: davem@davemloft.net
In-Reply-To: <20061120130834.22347.34853.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NET_SCHED]: sch_htb: perform qlen adjustment immediately in ->delete

qlen adjustment should happen immediately in ->delete and not in the
class destroy function because the reference count will not hit zero in
->delete (sch_api holds a reference) but in ->put. Since the qdisc
lock is released between deletion of the class and final destruction
this creates an externally visible error in the qlen counter.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 28ceb9f1cece3e1fa989a96a99dc76dc44d5629b
tree 568ab7acb7b9c6d1783c5e4a23edd83ee0381e22
parent 808dbbb6bb61173bf52946a28f99089d2efa4c55
author Patrick McHardy <kaber@trash.net> Sun, 19 Nov 2006 06:55:10 +0100
committer Patrick McHardy <kaber@trash.net> Sun, 19 Nov 2006 06:55:10 +0100

 net/sched/sch_htb.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 4b52fa7..08fa4d0 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1269,9 +1269,9 @@ static void htb_destroy_filters(struct t
 static void htb_destroy_class(struct Qdisc *sch, struct htb_class *cl)
 {
 	struct htb_sched *q = qdisc_priv(sch);
+
 	if (!cl->level) {
 		BUG_TRAP(cl->un.leaf.q);
-		sch->q.qlen -= cl->un.leaf.q->q.qlen;
 		qdisc_destroy(cl->un.leaf.q);
 	}
 	qdisc_put_rtab(cl->rate);
@@ -1334,6 +1334,11 @@ static int htb_delete(struct Qdisc *sch,
 	/* delete from hash and active; remainder in destroy_class */
 	hlist_del_init(&cl->hlist);
 
+	if (!cl->level) {
+		sch->q.qlen -= cl->un.leaf.q->q.qlen;
+		qdisc_reset(cl->un.leaf.q);
+	}
+
 	if (cl->prio_activity)
 		htb_deactivate(q, cl);
 

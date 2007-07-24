From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Subject: [PATCH 1/2] NET: Fix sch_api to properly set sch->parent on the root
	qdisc
Date: Tue, 24 Jul 2007 15:33:52 -0700
Message-ID: <20070724223352.10658.82935.stgit@localhost.localdomain>
References: <20070724223346.10658.80645.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:53342 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756844AbXGXWdy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jul 2007 18:33:54 -0400
In-Reply-To: <20070724223346.10658.80645.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

Fix sch_api to correctly set sch->parent for both ingress and egress
qdiscs in qdisc_create().

Signed-off-by: Patrick McHardy <trash@kaber.net>
Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
---

 net/sched/sch_api.c |   17 ++++++++++++-----
 1 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 13c09bc..dee0d5f 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -380,6 +380,10 @@ void qdisc_tree_decrease_qlen(struct Qdisc *sch, unsigned int n)
 		return;
 	while ((parentid = sch->parent)) {
 		sch = qdisc_lookup(sch->dev, TC_H_MAJ(parentid));
+		if (sch == NULL) {
+			WARN_ON(parentid != TC_H_ROOT);
+			return;
+		}
 		cops = sch->ops->cl_ops;
 		if (cops->qlen_notify) {
 			cl = cops->get(sch, parentid);
@@ -420,8 +424,6 @@ static int qdisc_graft(struct net_device *dev, struct Qdisc *parent,
 			unsigned long cl = cops->get(parent, classid);
 			if (cl) {
 				err = cops->graft(parent, cl, new, old);
-				if (new)
-					new->parent = classid;
 				cops->put(parent, cl);
 			}
 		}
@@ -436,7 +438,8 @@ static int qdisc_graft(struct net_device *dev, struct Qdisc *parent,
  */
 
 static struct Qdisc *
-qdisc_create(struct net_device *dev, u32 handle, struct rtattr **tca, int *errp)
+qdisc_create(struct net_device *dev, u32 parent, u32 handle,
+	   struct rtattr **tca, int *errp)
 {
 	int err;
 	struct rtattr *kind = tca[TCA_KIND-1];
@@ -482,6 +485,8 @@ qdisc_create(struct net_device *dev, u32 handle, struct rtattr **tca, int *errp)
 		goto err_out2;
 	}
 
+	sch->parent = parent;
+
 	if (handle == TC_H_INGRESS) {
 		sch->flags |= TCQ_F_INGRESS;
 		sch->stats_lock = &dev->ingress_lock;
@@ -758,9 +763,11 @@ create_n_graft:
 	if (!(n->nlmsg_flags&NLM_F_CREATE))
 		return -ENOENT;
 	if (clid == TC_H_INGRESS)
-		q = qdisc_create(dev, tcm->tcm_parent, tca, &err);
+		q = qdisc_create(dev, tcm->tcm_parent, tcm->tcm_parent,
+				 tca, &err);
 	else
-		q = qdisc_create(dev, tcm->tcm_handle, tca, &err);
+		q = qdisc_create(dev, tcm->tcm_parent, tcm->tcm_handle,
+				 tca, &err);
 	if (q == NULL) {
 		if (err == -EAGAIN)
 			goto replay;

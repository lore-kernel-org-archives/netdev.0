From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/14]: pkt_sched: More refactoring of sched API qdisc
 grafting.
Date: Mon, 14 Jul 2008 15:59:19 -0700 (PDT)
Message-ID: <20080714.155919.79466578.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49259
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758282AbYGNW7U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2008 18:59:20 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 18610C8C187
	for <netdev@vger.kernel.org>; Mon, 14 Jul 2008 15:59:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


New functions, tc_graft, tc_create, and tc_create_and_graft.  Call
them from tc_modify_qdisc().

This is just getting us one step closer to being able to make this
code replicate every config change to each TX queue.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/sched/sch_api.c |  114 +++++++++++++++++++++++++++++++++------------------
 1 files changed, 74 insertions(+), 40 deletions(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 51b8bae..3ed3b32 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -555,11 +555,7 @@ static int qdisc_graft(struct netdev_queue *dev_queue, struct Qdisc *parent,
 	return err;
 }
 
-/*
-   Allocate and initialize new qdisc.
-
-   Parameters are passed via opt.
- */
+/* Allocate and initialize new qdisc.  Parameters are passed via tca.  */
 
 static struct Qdisc *
 qdisc_create(struct net_device *dev, struct netdev_queue *dev_queue,
@@ -785,9 +781,74 @@ static int tc_get_qdisc(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 	return 0;
 }
 
-/*
-   Create/change qdisc.
- */
+static struct Qdisc *tc_create(struct net_device *dev,
+			       struct netdev_queue *dev_queue,
+			       u32 parent, u32 handle,
+			       struct nlattr **tca)
+{
+	struct Qdisc *q;
+	int err = 0;
+
+	q = qdisc_create(dev, dev_queue, parent, handle, tca, &err);
+	if (unlikely(!q))
+		return ERR_PTR(err);
+
+	return q;
+}
+
+static int tc_graft(struct net_device *dev, struct netdev_queue *dev_queue,
+		    struct Qdisc *new_q, struct Qdisc *parent_q,
+		    u32 clid, struct sk_buff *skb, struct nlmsghdr *n)
+{
+	struct Qdisc *old_q = NULL;
+	int err;
+
+	err = qdisc_graft(dev_queue, parent_q, clid, new_q, &old_q);
+	if (err) {
+		if (new_q) {
+			qdisc_lock_tree(dev);
+			qdisc_destroy(new_q);
+			qdisc_unlock_tree(dev);
+		}
+		return err;
+	}
+
+	qdisc_notify(skb, n, clid, old_q, new_q);
+
+	if (old_q) {
+		qdisc_lock_tree(dev);
+		qdisc_destroy(old_q);
+		qdisc_unlock_tree(dev);
+	}
+
+	return 0;
+}
+
+static int tc_create_and_graft(struct net_device *dev, u32 clid,
+			       struct tcmsg *tcm, struct nlattr **tca,
+			       struct Qdisc *parent_q,
+			       struct sk_buff *skb, struct nlmsghdr *n)
+{
+	struct netdev_queue *dev_queue;
+	u32 parent, handle;
+	struct Qdisc *q;
+
+	parent = tcm->tcm_parent;
+	if (clid == TC_H_INGRESS) {
+		dev_queue = &dev->rx_queue;
+		handle = parent;
+	} else {
+		dev_queue = netdev_get_tx_queue(dev, 0);
+		handle = tcm->tcm_handle;
+	}
+	q = tc_create(dev, dev_queue, parent, handle, tca);
+	if (IS_ERR(q))
+		return PTR_ERR(q);
+
+	return tc_graft(dev, dev_queue, q, parent_q, clid, skb, n);
+}
+
+/* Create/change qdisc.  */
 
 static int tc_modify_qdisc(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 {
@@ -903,40 +964,13 @@ replay:
 create_n_graft:
 	if (!(n->nlmsg_flags&NLM_F_CREATE))
 		return -ENOENT;
-	if (clid == TC_H_INGRESS)
-		q = qdisc_create(dev, &dev->rx_queue,
-				 tcm->tcm_parent, tcm->tcm_parent,
-				 tca, &err);
-	else
-		q = qdisc_create(dev, netdev_get_tx_queue(dev, 0),
-				 tcm->tcm_parent, tcm->tcm_handle,
-				 tca, &err);
-	if (q == NULL) {
-		if (err == -EAGAIN)
-			goto replay;
-		return err;
-	}
+	err = tc_create_and_graft(dev, clid, tcm, tca, p, skb, n);
+	if (err == -EAGAIN)
+		goto replay;
+	return err;
 
 graft:
-	if (1) {
-		struct Qdisc *old_q = NULL;
-		err = qdisc_graft(q->dev_queue, p, clid, q, &old_q);
-		if (err) {
-			if (q) {
-				qdisc_lock_tree(dev);
-				qdisc_destroy(q);
-				qdisc_unlock_tree(dev);
-			}
-			return err;
-		}
-		qdisc_notify(skb, n, clid, old_q, q);
-		if (old_q) {
-			qdisc_lock_tree(dev);
-			qdisc_destroy(old_q);
-			qdisc_unlock_tree(dev);
-		}
-	}
-	return 0;
+	return tc_graft(dev, q->dev_queue, q, p, clid, skb, n);
 }
 
 static int tc_fill_qdisc(struct sk_buff *skb, struct Qdisc *q, u32 clid,
-- 
1.5.6.2.255.gbed62


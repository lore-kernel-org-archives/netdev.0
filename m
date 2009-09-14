From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH v2] pkt_sched: Fix tx queue selection in tc_modify_qdisc
Date: Tue, 15 Sep 2009 00:50:22 +0200
Message-ID: <20090914225022.GA13363@ami.dom.local>
References: <20090914122226.GA14087@ff.dom.local>
 <4AAE85F9.2060600@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f217.google.com ([209.85.220.217]:38381 "EHLO
	mail-fx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757424AbZINWug (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Sep 2009 18:50:36 -0400
Received: by fxm17 with SMTP id 17so1200119fxm.37
        for <netdev@vger.kernel.org>; Mon, 14 Sep 2009 15:50:38 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4AAE85F9.2060600@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 14, 2009 at 08:05:45PM +0200, Patrick McHardy wrote:
> Jarek Poplawski wrote:
> > After the recent mq change there is the new select_queue qdisc class
> > method used in tc_modify_qdisc, but it works OK only for direct child
> > qdiscs of mq qdisc. Grandchildren always get the first tx queue, which
> > would give wrong qdisc_root etc. results (e.g. for sch_htb as child of
> > sch_prio). This patch fixes it by using parent's dev_queue for such
> > grandchildren qdiscs. The select_queue method is replaced BTW with the
> > static qdisc_select_tx_queue function (it's used only in one place).
> 
> Thanks, this looks correct. My assumption was that we shouldn't
> be using the locks of grandchildren anyways, but we do need the
> proper root lock for estimators.
...
> I didn't want to expose the numbering scheme used by sch_mq internally,
> but fine, I see you really don't like the callback :)

So here is an alternative version with the callback saved (the return
type is changed) for consideration.

Thanks,
Jarek P.
-----------------------> (take 2)
pkt_sched: Fix tx queue selection in tc_modify_qdisc

After the recent mq change there is the new select_queue qdisc class
method used in tc_modify_qdisc, but it works OK only for direct child
qdiscs of mq qdisc. Grandchildren always get the first tx queue, which
would give wrong qdisc_root etc. results (e.g. for sch_htb as child of
sch_prio). This patch fixes it by using parent's dev_queue for such
grandchildren qdiscs. The select_queue method's return type is changed
BTW.

With feedback from: Patrick McHardy <kaber@trash.net>

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

 include/net/sch_generic.h |    2 +-
 net/sched/sch_api.c       |   10 +++++++---
 net/sched/sch_mq.c        |   13 +++++++++----
 3 files changed, 17 insertions(+), 8 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 88eb9de..c33180d 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -81,7 +81,7 @@ struct Qdisc
 struct Qdisc_class_ops
 {
 	/* Child qdisc manipulation */
-	unsigned int		(*select_queue)(struct Qdisc *, struct tcmsg *);
+	struct netdev_queue *	(*select_queue)(struct Qdisc *, struct tcmsg *);
 	int			(*graft)(struct Qdisc *, unsigned long cl,
 					struct Qdisc *, struct Qdisc **);
 	struct Qdisc *		(*leaf)(struct Qdisc *, unsigned long cl);
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 3af1061..a1184b2 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1111,12 +1111,16 @@ create_n_graft:
 				 tcm->tcm_parent, tcm->tcm_parent,
 				 tca, &err);
 	else {
-		unsigned int ntx = 0;
+		struct netdev_queue *dev_queue;
 
 		if (p && p->ops->cl_ops && p->ops->cl_ops->select_queue)
-			ntx = p->ops->cl_ops->select_queue(p, tcm);
+			dev_queue = p->ops->cl_ops->select_queue(p, tcm);
+		else if (p)
+			dev_queue = p->dev_queue;
+		else
+			dev_queue = netdev_get_tx_queue(dev, 0);
 
-		q = qdisc_create(dev, netdev_get_tx_queue(dev, ntx), p,
+		q = qdisc_create(dev, dev_queue, p,
 				 tcm->tcm_parent, tcm->tcm_handle,
 				 tca, &err);
 	}
diff --git a/net/sched/sch_mq.c b/net/sched/sch_mq.c
index dd5ee02..600c501 100644
--- a/net/sched/sch_mq.c
+++ b/net/sched/sch_mq.c
@@ -125,13 +125,18 @@ static struct netdev_queue *mq_queue_get(struct Qdisc *sch, unsigned long cl)
 	return netdev_get_tx_queue(dev, ntx);
 }
 
-static unsigned int mq_select_queue(struct Qdisc *sch, struct tcmsg *tcm)
+static struct netdev_queue *mq_select_queue(struct Qdisc *sch,
+					    struct tcmsg *tcm)
 {
 	unsigned int ntx = TC_H_MIN(tcm->tcm_parent);
+	struct netdev_queue *dev_queue = mq_queue_get(sch, ntx);
 
-	if (!mq_queue_get(sch, ntx))
-		return 0;
-	return ntx - 1;
+	if (!dev_queue) {
+		struct net_device *dev = qdisc_dev(sch);
+
+		return netdev_get_tx_queue(dev, 0);
+	}
+	return dev_queue;
 }
 
 static int mq_graft(struct Qdisc *sch, unsigned long cl, struct Qdisc *new,

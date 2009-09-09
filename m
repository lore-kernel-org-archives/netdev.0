From: Patrick McHardy <kaber@trash.net>
Subject: net_sched: fix estimator lock selection for mq child qdiscs
Date: Wed, 09 Sep 2009 17:59:01 +0200
Message-ID: <4AA7D0C5.9080601@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090907070502090304030209"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:40615 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752895AbZIIP7E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2009 11:59:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090907070502090304030209
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit


--------------090907070502090304030209
Content-Type: text/x-patch;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

commit d0a936694984bfd8bcd56cdddbbe1f077be7f277
Author: Patrick McHardy <kaber@trash.net>
Date:   Wed Sep 9 17:50:10 2009 +0200

    net_sched: fix estimator lock selection for mq child qdiscs
    
    When new child qdiscs are attached to the mq qdisc, they are actually
    attached as root qdiscs to the device queues. The lock selection for
    new estimators incorrectly picks the root lock of the existing and
    to be replaced qdisc, which results in a use-after-free once the old
    qdisc has been destroyed.
    
    Mark mq qdisc instances with a new flag and treat qdiscs attached to
    mq as children similar to regular root qdiscs.
    
    Additionally prevent estimators from being attached to the mq qdisc
    itself since it only updates its byte and packet counters during dumps.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 9c69585..88eb9de 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -46,6 +46,7 @@ struct Qdisc
 #define TCQ_F_THROTTLED		2
 #define TCQ_F_INGRESS		4
 #define TCQ_F_CAN_BYPASS	8
+#define TCQ_F_MQROOT		16
 #define TCQ_F_WARN_NONWC	(1 << 16)
 	int			padded;
 	struct Qdisc_ops	*ops;
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index de1ebc4..692d9a4 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -733,7 +733,8 @@ static struct lock_class_key qdisc_rx_lock;
 
 static struct Qdisc *
 qdisc_create(struct net_device *dev, struct netdev_queue *dev_queue,
-	     u32 parent, u32 handle, struct nlattr **tca, int *errp)
+	     struct Qdisc *p, u32 parent, u32 handle,
+	     struct nlattr **tca, int *errp)
 {
 	int err;
 	struct nlattr *kind = tca[TCA_KIND];
@@ -810,24 +811,21 @@ qdisc_create(struct net_device *dev, struct netdev_queue *dev_queue,
 		if (tca[TCA_RATE]) {
 			spinlock_t *root_lock;
 
+			err = -EOPNOTSUPP;
+			if (sch->flags & TCQ_F_MQROOT)
+				goto err_out4;
+
 			if ((sch->parent != TC_H_ROOT) &&
-			    !(sch->flags & TCQ_F_INGRESS))
+			    !(sch->flags & TCQ_F_INGRESS) &&
+			    (!p || !(p->flags & TCQ_F_MQROOT)))
 				root_lock = qdisc_root_sleeping_lock(sch);
 			else
 				root_lock = qdisc_lock(sch);
 
 			err = gen_new_estimator(&sch->bstats, &sch->rate_est,
 						root_lock, tca[TCA_RATE]);
-			if (err) {
-				/*
-				 * Any broken qdiscs that would require
-				 * a ops->reset() here? The qdisc was never
-				 * in action so it shouldn't be necessary.
-				 */
-				if (ops->destroy)
-					ops->destroy(sch);
-				goto err_out3;
-			}
+			if (err)
+				goto err_out4;
 		}
 
 		qdisc_list_add(sch);
@@ -843,6 +841,15 @@ err_out2:
 err_out:
 	*errp = err;
 	return NULL;
+
+err_out4:
+	/*
+	 * Any broken qdiscs that would require a ops->reset() here?
+	 * The qdisc was never in action so it shouldn't be necessary.
+	 */
+	if (ops->destroy)
+		ops->destroy(sch);
+	goto err_out3;
 }
 
 static int qdisc_change(struct Qdisc *sch, struct nlattr **tca)
@@ -867,13 +874,16 @@ static int qdisc_change(struct Qdisc *sch, struct nlattr **tca)
 	qdisc_put_stab(sch->stab);
 	sch->stab = stab;
 
-	if (tca[TCA_RATE])
+	if (tca[TCA_RATE]) {
 		/* NB: ignores errors from replace_estimator
 		   because change can't be undone. */
+		if (sch->flags & TCQ_F_MQROOT)
+			goto out;
 		gen_replace_estimator(&sch->bstats, &sch->rate_est,
 					    qdisc_root_sleeping_lock(sch),
 					    tca[TCA_RATE]);
-
+	}
+out:
 	return 0;
 }
 
@@ -1097,7 +1107,7 @@ create_n_graft:
 	if (!(n->nlmsg_flags&NLM_F_CREATE))
 		return -ENOENT;
 	if (clid == TC_H_INGRESS)
-		q = qdisc_create(dev, &dev->rx_queue,
+		q = qdisc_create(dev, &dev->rx_queue, p,
 				 tcm->tcm_parent, tcm->tcm_parent,
 				 tca, &err);
 	else {
@@ -1106,7 +1116,7 @@ create_n_graft:
 		if (p && p->ops->cl_ops && p->ops->cl_ops->select_queue)
 			ntx = p->ops->cl_ops->select_queue(p, tcm);
 
-		q = qdisc_create(dev, netdev_get_tx_queue(dev, ntx),
+		q = qdisc_create(dev, netdev_get_tx_queue(dev, ntx), p,
 				 tcm->tcm_parent, tcm->tcm_handle,
 				 tca, &err);
 	}
diff --git a/net/sched/sch_mq.c b/net/sched/sch_mq.c
index c84dec9..dd5ee02 100644
--- a/net/sched/sch_mq.c
+++ b/net/sched/sch_mq.c
@@ -64,6 +64,7 @@ static int mq_init(struct Qdisc *sch, struct nlattr *opt)
 		priv->qdiscs[ntx] = qdisc;
 	}
 
+	sch->flags |= TCQ_F_MQROOT;
 	return 0;
 
 err:

--------------090907070502090304030209--

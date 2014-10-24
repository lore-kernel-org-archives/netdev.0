From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net 2/2] net_sched: always call ->destroy when ->init() fails
Date: Fri, 24 Oct 2014 16:55:59 -0700
Message-ID: <1414194959-28006-2-git-send-email-xiyou.wangcong@gmail.com>
References: <1414194959-28006-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: davem@davemloft.net, Cong Wang <xiyou.wangcong@gmail.com>,
	Wang Bo <wang.bo116@zte.com.cn>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Patrick McHardy <kaber@trash.net>, Terry Lam <vtlam@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:45170 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755237AbaJXX5K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2014 19:57:10 -0400
Received: by mail-pd0-f169.google.com with SMTP id w10so2294711pde.14
        for <netdev@vger.kernel.org>; Fri, 24 Oct 2014 16:57:09 -0700 (PDT)
In-Reply-To: <1414194959-28006-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In qdisc_create(), when ->init() exists and it fails, we should
call ->destroy() to clean up the potentially partially initialized
qdisc's. This will also make the ->init() implementation easier.

qdisc_create_dflt() already does that. Most callers of qdisc_create_dflt()
simply use noop_qdisc when it fails.

And, most of the ->destroy() implementations are already able to clean up
partially initialization, we don't need to worry.

The following ->init()'s need to catch up:
fq_codel_init(), hhf_init(), multiq_init(),  sfq_init(), mq_init(),
mqprio_init().

Reported-by: Wang Bo <wang.bo116@zte.com.cn>
Cc: Wang Bo <wang.bo116@zte.com.cn>
Cc: John Fastabend <john.r.fastabend@intel.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: Patrick McHardy <kaber@trash.net>
Cc: Terry Lam <vtlam@google.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/sch_api.c      |  2 ++
 net/sched/sch_drr.c      |  1 -
 net/sched/sch_fq_codel.c |  6 +++---
 net/sched/sch_generic.c  |  1 +
 net/sched/sch_hhf.c      |  8 ++------
 net/sched/sch_mq.c       |  6 +-----
 net/sched/sch_mqprio.c   | 18 +++++-------------
 net/sched/sch_multiq.c   |  9 ++-------
 net/sched/sch_qfq.c      |  1 -
 net/sched/sch_sfq.c      |  7 ++++---
 10 files changed, 20 insertions(+), 39 deletions(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 76f402e..7c308c9 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -990,6 +990,8 @@ qdisc_create(struct net_device *dev, struct netdev_queue *dev_queue,
 		qdisc_list_add(sch);
 
 		return sch;
+	} else {
+		goto err_out4;
 	}
 err_out3:
 	dev_put(dev);
diff --git a/net/sched/sch_drr.c b/net/sched/sch_drr.c
index 3387060..6c69b88 100644
--- a/net/sched/sch_drr.c
+++ b/net/sched/sch_drr.c
@@ -121,7 +121,6 @@ static int drr_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 					    qdisc_root_sleeping_lock(sch),
 					    tca[TCA_RATE]);
 		if (err) {
-			qdisc_destroy(cl->qdisc);
 			kfree(cl);
 			return err;
 		}
diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
index b9ca32e..05c725f 100644
--- a/net/sched/sch_fq_codel.c
+++ b/net/sched/sch_fq_codel.c
@@ -406,11 +406,11 @@ static int fq_codel_init(struct Qdisc *sch, struct nlattr *opt)
 					   sizeof(struct fq_codel_flow));
 		if (!q->flows)
 			return -ENOMEM;
+
 		q->backlogs = fq_codel_zalloc(q->flows_cnt * sizeof(u32));
-		if (!q->backlogs) {
-			fq_codel_free(q->flows);
+		if (!q->backlogs)
 			return -ENOMEM;
-		}
+
 		for (i = 0; i < q->flows_cnt; i++) {
 			struct fq_codel_flow *flow = q->flows + i;
 
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 6efca30..d1e2ed6 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -622,6 +622,7 @@ struct Qdisc *qdisc_alloc(struct netdev_queue *dev_queue,
 	return ERR_PTR(err);
 }
 
+/* Callers don't need to clean up on failure, we do here. */
 struct Qdisc *qdisc_create_dflt(struct netdev_queue *dev_queue,
 				const struct Qdisc_ops *ops,
 				unsigned int parentid)
diff --git a/net/sched/sch_hhf.c b/net/sched/sch_hhf.c
index 15d3aab..8f94bb9 100644
--- a/net/sched/sch_hhf.c
+++ b/net/sched/sch_hhf.c
@@ -639,10 +639,8 @@ static int hhf_init(struct Qdisc *sch, struct nlattr *opt)
 		for (i = 0; i < HHF_ARRAYS_CNT; i++) {
 			q->hhf_arrays[i] = hhf_zalloc(HHF_ARRAYS_LEN *
 						      sizeof(u32));
-			if (!q->hhf_arrays[i]) {
-				hhf_destroy(sch);
+			if (!q->hhf_arrays[i])
 				return -ENOMEM;
-			}
 		}
 		q->hhf_arrays_reset_timestamp = hhf_time_stamp();
 
@@ -650,10 +648,8 @@ static int hhf_init(struct Qdisc *sch, struct nlattr *opt)
 		for (i = 0; i < HHF_ARRAYS_CNT; i++) {
 			q->hhf_valid_bits[i] = hhf_zalloc(HHF_ARRAYS_LEN /
 							  BITS_PER_BYTE);
-			if (!q->hhf_valid_bits[i]) {
-				hhf_destroy(sch);
+			if (!q->hhf_valid_bits[i])
 				return -ENOMEM;
-			}
 		}
 
 		/* Initialize Weighted DRR buckets. */
diff --git a/net/sched/sch_mq.c b/net/sched/sch_mq.c
index f3cbaec..8f009c9 100644
--- a/net/sched/sch_mq.c
+++ b/net/sched/sch_mq.c
@@ -61,17 +61,13 @@ static int mq_init(struct Qdisc *sch, struct nlattr *opt)
 					  TC_H_MAKE(TC_H_MAJ(sch->handle),
 						    TC_H_MIN(ntx + 1)));
 		if (qdisc == NULL)
-			goto err;
+			return -ENOMEM;
 		priv->qdiscs[ntx] = qdisc;
 		qdisc->flags |= TCQ_F_ONETXQUEUE;
 	}
 
 	sch->flags |= TCQ_F_MQROOT;
 	return 0;
-
-err:
-	mq_destroy(sch);
-	return -ENOMEM;
 }
 
 static void mq_attach(struct Qdisc *sch)
diff --git a/net/sched/sch_mqprio.c b/net/sched/sch_mqprio.c
index 3811a74..d172819 100644
--- a/net/sched/sch_mqprio.c
+++ b/net/sched/sch_mqprio.c
@@ -117,20 +117,16 @@ static int mqprio_init(struct Qdisc *sch, struct nlattr *opt)
 	/* pre-allocate qdisc, attachment can't fail */
 	priv->qdiscs = kcalloc(dev->num_tx_queues, sizeof(priv->qdiscs[0]),
 			       GFP_KERNEL);
-	if (priv->qdiscs == NULL) {
-		err = -ENOMEM;
-		goto err;
-	}
+	if (priv->qdiscs == NULL)
+		return -ENOMEM;
 
 	for (i = 0; i < dev->num_tx_queues; i++) {
 		dev_queue = netdev_get_tx_queue(dev, i);
 		qdisc = qdisc_create_dflt(dev_queue, default_qdisc_ops,
 					  TC_H_MAKE(TC_H_MAJ(sch->handle),
 						    TC_H_MIN(i + 1)));
-		if (qdisc == NULL) {
-			err = -ENOMEM;
-			goto err;
-		}
+		if (qdisc == NULL)
+			return -ENOMEM;
 		priv->qdiscs[i] = qdisc;
 		qdisc->flags |= TCQ_F_ONETXQUEUE;
 	}
@@ -143,7 +139,7 @@ static int mqprio_init(struct Qdisc *sch, struct nlattr *opt)
 		priv->hw_owned = 1;
 		err = dev->netdev_ops->ndo_setup_tc(dev, qopt->num_tc);
 		if (err)
-			goto err;
+			return err;
 	} else {
 		netdev_set_num_tc(dev, qopt->num_tc);
 		for (i = 0; i < qopt->num_tc; i++)
@@ -157,10 +153,6 @@ static int mqprio_init(struct Qdisc *sch, struct nlattr *opt)
 
 	sch->flags |= TCQ_F_MQROOT;
 	return 0;
-
-err:
-	mqprio_destroy(sch);
-	return err;
 }
 
 static void mqprio_attach(struct Qdisc *sch)
diff --git a/net/sched/sch_multiq.c b/net/sched/sch_multiq.c
index 42dd218..31dd2d2 100644
--- a/net/sched/sch_multiq.c
+++ b/net/sched/sch_multiq.c
@@ -252,7 +252,7 @@ static int multiq_tune(struct Qdisc *sch, struct nlattr *opt)
 static int multiq_init(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct multiq_sched_data *q = qdisc_priv(sch);
-	int i, err;
+	int i;
 
 	q->queues = NULL;
 
@@ -267,12 +267,7 @@ static int multiq_init(struct Qdisc *sch, struct nlattr *opt)
 	for (i = 0; i < q->max_bands; i++)
 		q->queues[i] = &noop_qdisc;
 
-	err = multiq_tune(sch, opt);
-
-	if (err)
-		kfree(q->queues);
-
-	return err;
+	return multiq_tune(sch, opt);
 }
 
 static int multiq_dump(struct Qdisc *sch, struct sk_buff *skb)
diff --git a/net/sched/sch_qfq.c b/net/sched/sch_qfq.c
index 3ec7e88..55ac6a4 100644
--- a/net/sched/sch_qfq.c
+++ b/net/sched/sch_qfq.c
@@ -522,7 +522,6 @@ static int qfq_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 	return 0;
 
 destroy_class:
-	qdisc_destroy(cl->qdisc);
 	kfree(cl);
 	return err;
 }
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index b877140..7ad2879 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -761,11 +761,12 @@ static int sfq_init(struct Qdisc *sch, struct nlattr *opt)
 	}
 
 	q->ht = sfq_alloc(sizeof(q->ht[0]) * q->divisor);
+	if (!q->ht)
+		return -ENOMEM;
 	q->slots = sfq_alloc(sizeof(q->slots[0]) * q->maxflows);
-	if (!q->ht || !q->slots) {
-		sfq_destroy(sch);
+	if (!q->slots)
 		return -ENOMEM;
-	}
+
 	for (i = 0; i < q->divisor; i++)
 		q->ht[i] = SFQ_EMPTY_SLOT;
 
-- 
1.8.3.1

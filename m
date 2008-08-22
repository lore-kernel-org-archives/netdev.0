From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 3/3] pkt_sched: restore multiqueue prio scheduler
Date: Thu, 21 Aug 2008 17:51:29 -0700
Message-ID: <20080822005129.4697.77680.stgit@jtkirshe-mobile.jf.intel.com>
References: <20080822005122.4697.26953.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.179]:20620 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754801AbYHVAvb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 20:51:31 -0400
Received: by py-out-1112.google.com with SMTP id p76so172212pyb.10
        for <netdev@vger.kernel.org>; Thu, 21 Aug 2008 17:51:30 -0700 (PDT)
In-Reply-To: <20080822005122.4697.26953.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch restores the multiqueue prio scheduler which was removed along with
the RR scheduler during the early changes for multiple tx queue support.  This
patch fixes the regression which occured as a result disabling the multiqueue
qdisc functionality.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 include/linux/pkt_sched.h |    9 +++++++
 net/sched/sch_prio.c      |   57 ++++++++++++++++++++++++++++++++++++---------
 2 files changed, 55 insertions(+), 11 deletions(-)

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index e5de421..6ceef2e 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -123,6 +123,15 @@ struct tc_prio_qopt
 	__u8	priomap[TC_PRIO_MAX+1];	/* Map: logical priority -> PRIO band */
 };
 
+enum
+{
+ TCA_PRIO_UNSPEC,
+ TCA_PRIO_MQ,
+ __TCA_PRIO_MAX
+};
+
+#define TCA_PRIO_MAX (__TCA_PRIO_MAX - 1)
+
 /* TBF section */
 
 struct tc_tbf_qopt
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index a6697c6..ef3e978 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -27,6 +27,7 @@ struct prio_sched_data
 	struct tcf_proto *filter_list;
 	u8  prio2band[TC_PRIO_MAX+1];
 	struct Qdisc *queues[TCQ_PRIO_BANDS];
+	int mq;
 };
 
 
@@ -53,14 +54,17 @@ prio_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 		if (!q->filter_list || err < 0) {
 			if (TC_H_MAJ(band))
 				band = 0;
-			return q->queues[q->prio2band[band&TC_PRIO_MAX]];
+			band = q->prio2band[band&TC_PRIO_MAX];
+			goto out;
 		}
 		band = res.classid;
 	}
 	band = TC_H_MIN(band) - 1;
 	if (band >= q->bands)
-		return q->queues[q->prio2band[0]];
-
+		band = q->prio2band[0];
+out:
+	if (q->mq)
+		skb_set_queue_mapping(skb, band);
 	return q->queues[band];
 }
 
@@ -127,11 +131,18 @@ static struct sk_buff *prio_dequeue(struct Qdisc* sch)
 	int prio;
 
 	for (prio = 0; prio < q->bands; prio++) {
-		struct Qdisc *qdisc = q->queues[prio];
-		struct sk_buff *skb = qdisc->dequeue(qdisc);
-		if (skb) {
-			sch->q.qlen--;
-			return skb;
+		/* Check if target subqueue is avaialble before
+		 * pulling an skb.  This way we avoid excessive requeues
+		 * for slower queues.
+		 */
+		if (!q->mq ||
+		    !__netif_subqueue_stopped(qdisc_dev(sch), prio)) {
+			struct Qdisc *qdisc = q->queues[prio];
+			struct sk_buff *skb = qdisc->dequeue(qdisc);
+			if (skb) {
+				sch->q.qlen--;
+				return skb;
+			}
 		}
 	}
 	return NULL;
@@ -182,11 +193,30 @@ static int prio_tune(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct prio_sched_data *q = qdisc_priv(sch);
 	struct tc_prio_qopt *qopt;
+	struct nlattr *tb[TCA_PRIO_MAX + 1];
+	int err;
+	int mq;
 	int i;
 
-	if (nla_len(opt) < sizeof(*qopt))
-		return -EINVAL;
-	qopt = nla_data(opt);
+	err = nla_parse_nested_compat(tb, TCA_PRIO_MAX, opt, NULL, qopt,
+	                              sizeof(*qopt));
+	if (err < 0)
+		return err;
+	/* If we're multiqueue, make sure the number of bands equals the
+	 * number of transmit for the device.  If bands requested is 0 then
+	 * set the bands to match dev->real_num_tx_queues.  This qdisc can
+	 * only be added as a root qdisc since it must interact with the
+	 * underlying device.
+	 */
+	mq = nla_get_flag(tb[TCA_PRIO_MQ]);
+	if (mq) {
+		if (sch->parent != TC_H_ROOT)
+			return -EINVAL;
+		if (qopt->bands == 0)
+			qopt->bands = qdisc_dev(sch)->real_num_tx_queues;
+		else if (qopt->bands != qdisc_dev(sch)->real_num_tx_queues)
+			return -EINVAL;
+	}
 
 	if (qopt->bands > TCQ_PRIO_BANDS || qopt->bands < 2)
 		return -EINVAL;
@@ -197,6 +227,7 @@ static int prio_tune(struct Qdisc *sch, struct nlattr *opt)
 	}
 
 	sch_tree_lock(sch);
+	q->mq = mq;
 	q->bands = qopt->bands;
 	memcpy(q->prio2band, qopt->priomap, TC_PRIO_MAX+1);
 
@@ -263,6 +294,10 @@ static int prio_dump(struct Qdisc *sch, struct sk_buff *skb)
 	nest = nla_nest_compat_start(skb, TCA_OPTIONS, sizeof(opt), &opt);
 	if (nest == NULL)
 		goto nla_put_failure;
+	if (q->mq) {
+		if (nla_put_flag(skb, TCA_PRIO_MQ) < 0)
+			goto nla_put_failure;
+	}
 	nla_nest_compat_end(skb, nest);
 
 	return skb->len;


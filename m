From: Michal Kazior <michal.kazior@tieto.com>
Subject: [PATCH] fq: add fair queuing framework
Date: Fri, 22 Apr 2016 14:20:13 +0200
Message-ID: <1461327613-22902-1-git-send-email-michal.kazior@tieto.com>
Cc: davem@davemloft.net, johannes@sipsolutions.net,
	Michal Kazior <michal.kazior@tieto.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f53.google.com ([209.85.215.53]:36725 "EHLO
	mail-lf0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751949AbcDVMSr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2016 08:18:47 -0400
Received: by mail-lf0-f53.google.com with SMTP id g184so78197683lfb.3
        for <netdev@vger.kernel.org>; Fri, 22 Apr 2016 05:18:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This works on the same implementation principle as
codel*.h, i.e. there's a generic header with
structures and macros and a implementation header
carrying function definitions to include in given,
e.g. driver or module.

The fairness logic comes from
net/sched/sch_fq_codel.c but is generalized so it
is more flexible and easier to re-use.

Signed-off-by: Michal Kazior <michal.kazior@tieto.com>
---
This will be used by mac80211.

For more background please see:

  https://www.spinics.net/lists/linux-wireless/msg149976.html


 include/net/fq.h      |  95 ++++++++++++++++++
 include/net/fq_impl.h | 269 ++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 364 insertions(+)
 create mode 100644 include/net/fq.h
 create mode 100644 include/net/fq_impl.h

diff --git a/include/net/fq.h b/include/net/fq.h
new file mode 100644
index 000000000000..268b49049c37
--- /dev/null
+++ b/include/net/fq.h
@@ -0,0 +1,95 @@
+/*
+ * Copyright (c) 2016 Qualcomm Atheros, Inc
+ *
+ * GPL v2
+ *
+ * Based on net/sched/sch_fq_codel.c
+ */
+#ifndef __NET_SCHED_FQ_H
+#define __NET_SCHED_FQ_H
+
+struct fq_tin;
+
+/**
+ * struct fq_flow - per traffic flow queue
+ *
+ * @tin: owner of this flow. Used to manage collisions, i.e. when a packet
+ *	hashes to an index which points to a flow that is already owned by a
+ *	different tin the packet is destined to. In such case the implementer
+ *	must provide a fallback flow
+ * @flowchain: can be linked to fq_tin's new_flows or old_flows. Used for DRR++
+ *	(deficit round robin) based round robin queuing similar to the one
+ *	found in net/sched/sch_fq_codel.c
+ * @backlogchain: can be linked to other fq_flow and fq. Used to keep track of
+ *	fat flows and efficient head-dropping if packet limit is reached
+ * @queue: sk_buff queue to hold packets
+ * @backlog: number of bytes pending in the queue. The number of packets can be
+ *	found in @queue.qlen
+ * @deficit: used for DRR++
+ */
+struct fq_flow {
+	struct fq_tin *tin;
+	struct list_head flowchain;
+	struct list_head backlogchain;
+	struct sk_buff_head queue;
+	u32 backlog;
+	int deficit;
+};
+
+/**
+ * struct fq_tin - a logical container of fq_flows
+ *
+ * Used to group fq_flows into a logical aggregate. DRR++ scheme is used to
+ * pull interleaved packets out of the associated flows.
+ *
+ * @new_flows: linked list of fq_flow
+ * @old_flows: linked list of fq_flow
+ */
+struct fq_tin {
+	struct list_head new_flows;
+	struct list_head old_flows;
+	u32 backlog_bytes;
+	u32 backlog_packets;
+	u32 overlimit;
+	u32 collisions;
+	u32 flows;
+	u32 tx_bytes;
+	u32 tx_packets;
+};
+
+/**
+ * struct fq - main container for fair queuing purposes
+ *
+ * @backlogs: linked to fq_flows. Used to maintain fat flows for efficient
+ *	head-dropping when @backlog reaches @limit
+ * @limit: max number of packets that can be queued across all flows
+ * @backlog: number of packets queued across all flows
+ */
+struct fq {
+	struct fq_flow *flows;
+	struct list_head backlogs;
+	spinlock_t lock;
+	u32 flows_cnt;
+	u32 perturbation;
+	u32 limit;
+	u32 quantum;
+	u32 backlog;
+	u32 overlimit;
+	u32 collisions;
+};
+
+typedef struct sk_buff *fq_tin_dequeue_t(struct fq *,
+					 struct fq_tin *,
+					 struct fq_flow *flow);
+
+typedef void fq_skb_free_t(struct fq *,
+			   struct fq_tin *,
+			   struct fq_flow *,
+			   struct sk_buff *);
+
+typedef struct fq_flow *fq_flow_get_default_t(struct fq *,
+					      struct fq_tin *,
+					      int idx,
+					      struct sk_buff *);
+
+#endif
diff --git a/include/net/fq_impl.h b/include/net/fq_impl.h
new file mode 100644
index 000000000000..02eab7c51adb
--- /dev/null
+++ b/include/net/fq_impl.h
@@ -0,0 +1,269 @@
+/*
+ * Copyright (c) 2016 Qualcomm Atheros, Inc
+ *
+ * GPL v2
+ *
+ * Based on net/sched/sch_fq_codel.c
+ */
+#ifndef __NET_SCHED_FQ_IMPL_H
+#define __NET_SCHED_FQ_IMPL_H
+
+#include <net/fq.h>
+
+/* functions that are embedded into includer */
+
+static struct sk_buff *fq_flow_dequeue(struct fq *fq,
+				       struct fq_flow *flow)
+{
+	struct fq_tin *tin = flow->tin;
+	struct fq_flow *i;
+	struct sk_buff *skb;
+
+	lockdep_assert_held(&fq->lock);
+
+	skb = __skb_dequeue(&flow->queue);
+	if (!skb)
+		return NULL;
+
+	tin->backlog_bytes -= skb->len;
+	tin->backlog_packets--;
+	flow->backlog -= skb->len;
+	fq->backlog--;
+
+	if (flow->backlog == 0) {
+		list_del_init(&flow->backlogchain);
+	} else {
+		i = flow;
+
+		list_for_each_entry_continue(i, &fq->backlogs, backlogchain)
+			if (i->backlog < flow->backlog)
+				break;
+
+		list_move_tail(&flow->backlogchain,
+			       &i->backlogchain);
+	}
+
+	return skb;
+}
+
+static struct sk_buff *fq_tin_dequeue(struct fq *fq,
+				      struct fq_tin *tin,
+				      fq_tin_dequeue_t dequeue_func)
+{
+	struct fq_flow *flow;
+	struct list_head *head;
+	struct sk_buff *skb;
+
+	lockdep_assert_held(&fq->lock);
+
+begin:
+	head = &tin->new_flows;
+	if (list_empty(head)) {
+		head = &tin->old_flows;
+		if (list_empty(head))
+			return NULL;
+	}
+
+	flow = list_first_entry(head, struct fq_flow, flowchain);
+
+	if (flow->deficit <= 0) {
+		flow->deficit += fq->quantum;
+		list_move_tail(&flow->flowchain,
+			       &tin->old_flows);
+		goto begin;
+	}
+
+	skb = dequeue_func(fq, tin, flow);
+	if (!skb) {
+		/* force a pass through old_flows to prevent starvation */
+		if ((head == &tin->new_flows) &&
+		    !list_empty(&tin->old_flows)) {
+			list_move_tail(&flow->flowchain, &tin->old_flows);
+		} else {
+			list_del_init(&flow->flowchain);
+			flow->tin = NULL;
+		}
+		goto begin;
+	}
+
+	flow->deficit -= skb->len;
+	tin->tx_bytes += skb->len;
+	tin->tx_packets++;
+
+	return skb;
+}
+
+static struct fq_flow *fq_flow_classify(struct fq *fq,
+					struct fq_tin *tin,
+					struct sk_buff *skb,
+					fq_flow_get_default_t get_default_func)
+{
+	struct fq_flow *flow;
+	u32 hash;
+	u32 idx;
+
+	lockdep_assert_held(&fq->lock);
+
+	hash = skb_get_hash_perturb(skb, fq->perturbation);
+	idx = reciprocal_scale(hash, fq->flows_cnt);
+	flow = &fq->flows[idx];
+
+	if (flow->tin && flow->tin != tin) {
+		flow = get_default_func(fq, tin, idx, skb);
+		tin->collisions++;
+		fq->collisions++;
+	}
+
+	if (!flow->tin)
+		tin->flows++;
+
+	return flow;
+}
+
+static void fq_tin_enqueue(struct fq *fq,
+			   struct fq_tin *tin,
+			   struct sk_buff *skb,
+			   fq_skb_free_t free_func,
+			   fq_flow_get_default_t get_default_func)
+{
+	struct fq_flow *flow;
+	struct fq_flow *i;
+
+	lockdep_assert_held(&fq->lock);
+
+	flow = fq_flow_classify(fq, tin, skb, get_default_func);
+
+	flow->tin = tin;
+	flow->backlog += skb->len;
+	tin->backlog_bytes += skb->len;
+	tin->backlog_packets++;
+	fq->backlog++;
+
+	if (list_empty(&flow->backlogchain))
+		list_add_tail(&flow->backlogchain, &fq->backlogs);
+
+	i = flow;
+	list_for_each_entry_continue_reverse(i, &fq->backlogs,
+					     backlogchain)
+		if (i->backlog > flow->backlog)
+			break;
+
+	list_move(&flow->backlogchain, &i->backlogchain);
+
+	if (list_empty(&flow->flowchain)) {
+		flow->deficit = fq->quantum;
+		list_add_tail(&flow->flowchain,
+			      &tin->new_flows);
+	}
+
+	__skb_queue_tail(&flow->queue, skb);
+
+	if (fq->backlog > fq->limit) {
+		flow = list_first_entry_or_null(&fq->backlogs,
+						struct fq_flow,
+						backlogchain);
+		if (!flow)
+			return;
+
+		skb = fq_flow_dequeue(fq, flow);
+		if (!skb)
+			return;
+
+		free_func(fq, flow->tin, flow, skb);
+
+		flow->tin->overlimit++;
+		fq->overlimit++;
+	}
+}
+
+static void fq_flow_reset(struct fq *fq,
+			  struct fq_flow *flow,
+			  fq_skb_free_t free_func)
+{
+	struct sk_buff *skb;
+
+	while ((skb = fq_flow_dequeue(fq, flow)))
+		free_func(fq, flow->tin, flow, skb);
+
+	if (!list_empty(&flow->flowchain))
+		list_del_init(&flow->flowchain);
+
+	if (!list_empty(&flow->backlogchain))
+		list_del_init(&flow->backlogchain);
+
+	flow->tin = NULL;
+
+	WARN_ON_ONCE(flow->backlog);
+}
+
+static void fq_tin_reset(struct fq *fq,
+			 struct fq_tin *tin,
+			 fq_skb_free_t free_func)
+{
+	struct list_head *head;
+	struct fq_flow *flow;
+
+	for (;;) {
+		head = &tin->new_flows;
+		if (list_empty(head)) {
+			head = &tin->old_flows;
+			if (list_empty(head))
+				break;
+		}
+
+		flow = list_first_entry(head, struct fq_flow, flowchain);
+		fq_flow_reset(fq, flow, free_func);
+	}
+
+	WARN_ON_ONCE(tin->backlog_bytes);
+	WARN_ON_ONCE(tin->backlog_packets);
+}
+
+static void fq_flow_init(struct fq_flow *flow)
+{
+	INIT_LIST_HEAD(&flow->flowchain);
+	INIT_LIST_HEAD(&flow->backlogchain);
+	__skb_queue_head_init(&flow->queue);
+}
+
+static void fq_tin_init(struct fq_tin *tin)
+{
+	INIT_LIST_HEAD(&tin->new_flows);
+	INIT_LIST_HEAD(&tin->old_flows);
+}
+
+static int fq_init(struct fq *fq, int flows_cnt)
+{
+	int i;
+
+	memset(fq, 0, sizeof(fq[0]));
+	INIT_LIST_HEAD(&fq->backlogs);
+	spin_lock_init(&fq->lock);
+	fq->flows_cnt = max_t(u32, flows_cnt, 1);
+	fq->perturbation = prandom_u32();
+	fq->quantum = 300;
+	fq->limit = 8192;
+
+	fq->flows = kcalloc(fq->flows_cnt, sizeof(fq->flows[0]), GFP_KERNEL);
+	if (!fq->flows)
+		return -ENOMEM;
+
+	for (i = 0; i < fq->flows_cnt; i++)
+		fq_flow_init(&fq->flows[i]);
+
+	return 0;
+}
+
+static void fq_reset(struct fq *fq,
+		     fq_skb_free_t free_func)
+{
+	int i;
+
+	for (i = 0; i < fq->flows_cnt; i++)
+		fq_flow_reset(fq, &fq->flows[i], free_func);
+
+	kfree(fq->flows);
+	fq->flows = NULL;
+}
+
+#endif
-- 
2.1.4

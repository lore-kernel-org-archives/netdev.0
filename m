From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 2/2] multiq: Further multiqueue cleanup
Date: Fri, 12 Sep 2008 17:45:49 -0700
Message-ID: <20080913004549.5342.39819.stgit@jtkirshe-mobile.jf.intel.com>
References: <20080913004547.5342.9954.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jarkao2@gmail.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.177]:14862 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757254AbYIMApx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2008 20:45:53 -0400
Received: by py-out-1112.google.com with SMTP id p76so881391pyb.10
        for <netdev@vger.kernel.org>; Fri, 12 Sep 2008 17:45:52 -0700 (PDT)
In-Reply-To: <20080913004547.5342.9954.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch resolves a few issues found with multiq including wording
suggestions and a problem seen in the allocation of queues.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 Documentation/networking/multiqueue.txt |   14 +++++++-------
 net/sched/sch_multiq.c                  |   13 +++++++++----
 2 files changed, 16 insertions(+), 11 deletions(-)

diff --git a/Documentation/networking/multiqueue.txt b/Documentation/networking/multiqueue.txt
index 8c2b06b..4caa0e3 100644
--- a/Documentation/networking/multiqueue.txt
+++ b/Documentation/networking/multiqueue.txt
@@ -29,15 +29,15 @@ Section 2: Qdisc support for multiqueue devices
 
 -----------------------------------------------
 
-Currently two qdiscs support multiqueue devices.  The first is the default
-pfifo_fast qdisc.  This qdisc supports one qdisc per hardware queue.  A new
-round-robin qdisc, sch_multiq also supports multiple hardware queues. The
+Currently two qdiscs are optimized for multiqueue devices.  The first is the
+default pfifo_fast qdisc.  This qdisc supports one qdisc per hardware queue.
+A new round-robin qdisc, sch_multiq also supports multiple hardware queues. The
 qdisc is responsible for classifying the skb's and then directing the skb's to
 bands and queues based on the value in skb->queue_mapping.  Use this field in
 the base driver to determine which queue to send the skb to.
 
-sch_multiq has been added for hardware that wishes to avoid unnecessary
-requeuing.  It will cycle though the bands and verify that the hardware queue
+sch_multiq has been added for hardware that wishes to avoid head-of-line
+blocking.  It will cycle though the bands and verify that the hardware queue
 associated with the band is not stopped prior to dequeuing a packet.
 
 On qdisc load, the number of bands is based on the number of queues on the
@@ -63,8 +63,8 @@ band 1 => queue 1
 band 2 => queue 2
 band 3 => queue 3
 
-Traffic will begin flowing through each queue if your base device has either
-the default simple_tx_hash or a custom netdev->select_queue() defined.
+Traffic will begin flowing through each queue based on either the simple_tx_hash
+function or based on netdev->select_queue() if you have it defined.
 
 The behavior of tc filters remains the same.  However a new tc action,
 skbedit, has been added.  Assuming you wanted to route all traffic to a
diff --git a/net/sched/sch_multiq.c b/net/sched/sch_multiq.c
index 49a8b67..5d9cd68 100644
--- a/net/sched/sch_multiq.c
+++ b/net/sched/sch_multiq.c
@@ -214,8 +214,8 @@ static int multiq_tune(struct Qdisc *sch, struct nlattr *opt)
 	sch_tree_lock(sch);
 	q->bands = qopt->bands;
 	for (i = q->bands; i < q->max_bands; i++) {
-		struct Qdisc *child = xchg(&q->queues[i], &noop_qdisc);
-		if (child != &noop_qdisc) {
+		if (q->queues[i] != &noop_qdisc) {
+			struct Qdisc *child = xchg(&q->queues[i], &noop_qdisc);
 			qdisc_tree_decrease_qlen(child, child->q.qlen);
 			qdisc_destroy(child);
 		}
@@ -250,7 +250,7 @@ static int multiq_tune(struct Qdisc *sch, struct nlattr *opt)
 static int multiq_init(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct multiq_sched_data *q = qdisc_priv(sch);
-	int i;
+	int i, err;
 
 	q->queues = NULL;
 
@@ -265,7 +265,12 @@ static int multiq_init(struct Qdisc *sch, struct nlattr *opt)
 	for (i = 0; i < q->max_bands; i++)
 		q->queues[i] = &noop_qdisc;
 
-	return multiq_tune(sch, opt);
+	err = multiq_tune(sch,opt);
+
+	if (err)
+		kfree(q->queues);
+
+	return err;
 }
 
 static int multiq_dump(struct Qdisc *sch, struct sk_buff *skb)


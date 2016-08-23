From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH 08/15] net: sched: support qdisc_reset on NOLOCK
 qdisc
Date: Tue, 23 Aug 2016 13:26:09 -0700
Message-ID: <20160823202609.14368.14098.stgit@john-Precision-Tower-5810>
References: <20160823202135.14368.62466.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
        john.fastabend@gmail.com
To: eric.dumazet@gmail.com, jhs@mojatatu.com, davem@davemloft.net,
        brouer@redhat.com, xiyou.wangcong@gmail.com,
        alexei.starovoitov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:34509 "EHLO
        mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754840AbcHWU02 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 16:26:28 -0400
Received: by mail-pa0-f65.google.com with SMTP id hh10so10464069pac.1
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 13:26:28 -0700 (PDT)
In-Reply-To: <20160823202135.14368.62466.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The qdisc_reset operation depends on the qdisc lock at the moment
to halt any additions to gso_skb and statistics while the list is
free'd and the stats zeroed.

Without the qdisc lock we can not guarantee another cpu is not in
the process of adding a skb to one of the "cells".

To resolve the dev_deactivate sequence that can come from a user
bringing the interface down which causes the gso_skb list to be
flushed and the qlen zero'd. At the moment this is protected by the
qdisc lock so while we clear the qlen/gso_skb fields we are guaranteed
no new skbs are added. For the lockless case though this is not true.
To resolve this move the qdisc_reset call after the new qdisc is
assigned and a grace period is exercised to ensure no new skbs can be
enqueued. Further the RTNL lock is held so we can not get another call
to activate the qdisc while the skb lists are being free'd.

Finally, fix qdisc_reset to handle the per cpu stats and skb lists.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 net/sched/sch_generic.c |   41 +++++++++++++++++++++++++++++++++++------
 1 file changed, 35 insertions(+), 6 deletions(-)

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 112d029..fd4a2b9 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -738,6 +738,20 @@ void qdisc_reset(struct Qdisc *qdisc)
 	kfree_skb(qdisc->skb_bad_txq);
 	qdisc->skb_bad_txq = NULL;
 
+	if (qdisc->gso_cpu_skb) {
+		int i;
+
+		for_each_possible_cpu(i) {
+			struct gso_cell *cell;
+
+			cell = per_cpu_ptr(qdisc->gso_cpu_skb, i);
+			if (cell) {
+				kfree_skb_list(cell->skb);
+				cell->skb = NULL;
+			}
+		}
+	}
+
 	if (qdisc->gso_skb) {
 		kfree_skb_list(qdisc->gso_skb);
 		qdisc->gso_skb = NULL;
@@ -926,7 +940,6 @@ static void dev_deactivate_queue(struct net_device *dev,
 			set_bit(__QDISC_STATE_DEACTIVATED, &qdisc->state);
 
 		rcu_assign_pointer(dev_queue->qdisc, qdisc_default);
-		qdisc_reset(qdisc);
 
 		spin_unlock_bh(qdisc_lock(qdisc));
 	}
@@ -963,6 +976,16 @@ static bool some_qdisc_is_busy(struct net_device *dev)
 	return false;
 }
 
+static void dev_qdisc_reset(struct net_device *dev,
+			    struct netdev_queue *dev_queue,
+			    void *none)
+{
+	struct Qdisc *qdisc = dev_queue->qdisc_sleeping;
+
+	if (qdisc)
+		qdisc_reset(qdisc);
+}
+
 /**
  * 	dev_deactivate_many - deactivate transmissions on several devices
  * 	@head: list of devices to deactivate
@@ -973,7 +996,6 @@ static bool some_qdisc_is_busy(struct net_device *dev)
 void dev_deactivate_many(struct list_head *head)
 {
 	struct net_device *dev;
-	bool sync_needed = false;
 
 	list_for_each_entry(dev, head, close_list) {
 		netdev_for_each_tx_queue(dev, dev_deactivate_queue,
@@ -983,20 +1005,27 @@ void dev_deactivate_many(struct list_head *head)
 					     &noop_qdisc);
 
 		dev_watchdog_down(dev);
-		sync_needed |= !dev->dismantle;
 	}
 
 	/* Wait for outstanding qdisc-less dev_queue_xmit calls.
 	 * This is avoided if all devices are in dismantle phase :
 	 * Caller will call synchronize_net() for us
 	 */
-	if (sync_needed)
-		synchronize_net();
+	synchronize_net();
 
 	/* Wait for outstanding qdisc_run calls. */
-	list_for_each_entry(dev, head, close_list)
+	list_for_each_entry(dev, head, close_list) {
 		while (some_qdisc_is_busy(dev))
 			yield();
+
+		/* The new qdisc is assigned at this point so we can safely
+		 * unwind stale skb lists and qdisc statistics
+		 */
+		netdev_for_each_tx_queue(dev, dev_qdisc_reset, NULL);
+		if (dev_ingress_queue(dev))
+			dev_qdisc_reset(dev, dev_ingress_queue(dev), NULL);
+	}
+
 }
 
 void dev_deactivate(struct net_device *dev)

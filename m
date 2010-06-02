From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH 1/2 net-next-2.6] net: Define accessors to manipulate
 QDISC_STATE_RUNNING
Date: Wed, 02 Jun 2010 11:49:14 +0200
Message-ID: <1275472154.2725.143.camel@edumazet-laptop>
References: <20100323202553.21598.10754.stgit@gitlad.jf.intel.com>
	 <1269377667.2915.25.camel@edumazet-laptop>
	 <20100323.144512.140757007.davem@davemloft.net>
	 <1269382380.2915.40.camel@edumazet-laptop>
	 <20100521084349.0d6f8f9a@nehalam>
	 <1274460275.2439.469.camel@edumazet-laptop>
	 <1274463643.2439.473.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:35842 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757718Ab0FBJtS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 05:49:18 -0400
Received: by fxm8 with SMTP id 8so1680994fxm.19
        for <netdev@vger.kernel.org>; Wed, 02 Jun 2010 02:49:17 -0700 (PDT)
In-Reply-To: <1274463643.2439.473.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Define three helpers to manipulate QDISC_STATE_RUNNIG flag, that a
second patch will move on another location.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/pkt_sched.h   |    2 +-
 include/net/sch_generic.h |   15 +++++++++++++++
 net/core/dev.c            |    4 ++--
 net/sched/sch_generic.c   |    4 ++--
 4 files changed, 20 insertions(+), 5 deletions(-)

diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index 9d4d87c..d9549af 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -95,7 +95,7 @@ extern void __qdisc_run(struct Qdisc *q);
 
 static inline void qdisc_run(struct Qdisc *q)
 {
-	if (!test_and_set_bit(__QDISC_STATE_RUNNING, &q->state))
+	if (qdisc_run_begin(q))
 		__qdisc_run(q);
 }
 
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 03ca5d8..9707dae 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -76,6 +76,21 @@ struct Qdisc {
 	struct rcu_head     rcu_head;
 };
 
+static inline bool qdisc_is_running(struct Qdisc *qdisc)
+{
+	return test_bit(__QDISC_STATE_RUNNING, &qdisc->state);
+}
+
+static inline bool qdisc_run_begin(struct Qdisc *qdisc)
+{
+	return !test_and_set_bit(__QDISC_STATE_RUNNING, &qdisc->state);
+}
+
+static inline void qdisc_run_end(struct Qdisc *qdisc)
+{
+	clear_bit(__QDISC_STATE_RUNNING, &qdisc->state);
+}
+
 struct Qdisc_class_ops {
 	/* Child qdisc manipulation */
 	struct netdev_queue *	(*select_queue)(struct Qdisc *, struct tcmsg *);
diff --git a/net/core/dev.c b/net/core/dev.c
index 983a3c1..2733226 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2047,7 +2047,7 @@ static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
 		kfree_skb(skb);
 		rc = NET_XMIT_DROP;
 	} else if ((q->flags & TCQ_F_CAN_BYPASS) && !qdisc_qlen(q) &&
-		   !test_and_set_bit(__QDISC_STATE_RUNNING, &q->state)) {
+		   qdisc_run_begin(q)) {
 		/*
 		 * This is a work-conserving queue; there are no old skbs
 		 * waiting to be sent out; and the qdisc is not running -
@@ -2059,7 +2059,7 @@ static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
 		if (sch_direct_xmit(skb, q, dev, txq, root_lock))
 			__qdisc_run(q);
 		else
-			clear_bit(__QDISC_STATE_RUNNING, &q->state);
+			qdisc_run_end(q);
 
 		rc = NET_XMIT_SUCCESS;
 	} else {
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index bd1892f..37b86ea 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -205,7 +205,7 @@ void __qdisc_run(struct Qdisc *q)
 		}
 	}
 
-	clear_bit(__QDISC_STATE_RUNNING, &q->state);
+	qdisc_run_end(q);
 }
 
 unsigned long dev_trans_start(struct net_device *dev)
@@ -797,7 +797,7 @@ static bool some_qdisc_is_busy(struct net_device *dev)
 
 		spin_lock_bh(root_lock);
 
-		val = (test_bit(__QDISC_STATE_RUNNING, &q->state) ||
+		val = (qdisc_is_running(q) ||
 		       test_bit(__QDISC_STATE_SCHED, &q->state));
 
 		spin_unlock_bh(root_lock);



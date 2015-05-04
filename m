From: Florian Westphal <fw@strlen.de>
Subject: [PATCH -next 4/5] net: sched: remove AT INGRESS/EGRESS
Date: Mon,  4 May 2015 20:48:37 +0200
Message-ID: <1430765318-13788-5-git-send-email-fw@strlen.de>
References: <1430765318-13788-1-git-send-email-fw@strlen.de>
Cc: jhs@mojatatu.com, alexei.starovoitov@gmail.com,
	Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:46874 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751980AbbEDSs6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 14:48:58 -0400
In-Reply-To: <1430765318-13788-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

use single marker to propagate location.
tc_at_ingress 1: ingress, 0 is egress.

The new flag is set/unset in sch_ingress instead of the core.
We will also no longer set skb->tc_verd to AT_EGRESS in the xmit
handler.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 drivers/staging/octeon/ethernet-tx.c | 1 +
 include/linux/skbuff.h               | 4 +++-
 include/uapi/linux/pkt_cls.h         | 4 +---
 net/core/dev.c                       | 5 -----
 net/sched/act_mirred.c               | 7 +++----
 net/sched/sch_ingress.c              | 2 ++
 6 files changed, 10 insertions(+), 13 deletions(-)

diff --git a/drivers/staging/octeon/ethernet-tx.c b/drivers/staging/octeon/ethernet-tx.c
index bcefebd..2852d8a 100644
--- a/drivers/staging/octeon/ethernet-tx.c
+++ b/drivers/staging/octeon/ethernet-tx.c
@@ -405,6 +405,7 @@ int cvm_oct_xmit(struct sk_buff *skb, struct net_device *dev)
 #ifdef CONFIG_NET_CLS_ACT
 	skb->tc_nocls = 0;
 	skb->tc_from_ingress = 0;
+	skb->tc_at_ingress = 0;
 	skb->tc_verd = 0;
 #endif /* CONFIG_NET_CLS_ACT */
 #endif /* CONFIG_NET_SCHED */
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 911d84e..d794077 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -488,6 +488,7 @@ static inline u32 skb_mstamp_us_delta(const struct skb_mstamp *t1,
  *	@queue_mapping: Queue mapping for multiqueue devices
  *	@xmit_more: More SKBs are pending for this queue
  *	@tc_from_ingress: skb is processed during rx, not transmit
+ *	@tc_at_ingress: skb is processed during rx, not transmit
  *	@tc_nocls: skip classification on ingress
  *	@ndisc_nodetype: router type (from link layer)
  *	@ooo_okay: allow the mapping of a socket to a queue to be changed
@@ -619,9 +620,10 @@ struct sk_buff {
 	__u8			inner_protocol_type:1;
 	__u8			remcsum_offload:1;
 #ifdef CONFIG_NET_CLS_ACT
+	__u8			tc_at_ingress:1;
 	__u8			tc_from_ingress:1;
 #endif
-	/* 2 or 4 bit hole */
+	/* 1 or 3 bit hole */
 
 #ifdef CONFIG_NET_SCHED
 	__u16			tc_index;	/* traffic control index */
diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
index ac88cbb..621d9d1 100644
--- a/include/uapi/linux/pkt_cls.h
+++ b/include/uapi/linux/pkt_cls.h
@@ -56,12 +56,10 @@ bits 9,10,11: redirect counter -  redirect TTL. Loop avoidance
 #define G_TC_FROM(x)       _TC_GETVALUE(x,S_TC_FROM,M_TC_FROM)
 #define V_TC_FROM(x)       _TC_MAKEVALUE(x,S_TC_FROM)
 #define SET_TC_FROM(v,n)   ((V_TC_FROM(n)) | (v & ~M_TC_FROM))
-#endif
 #define AT_STACK	0x0
 #define AT_INGRESS	0x1
 #define AT_EGRESS	0x2
 
-#ifndef __KERNEL__
 #define TC_NCLS          _TC_MAKEMASK1(8)
 #define SET_TC_NCLS(v)   ( TC_NCLS | (v & ~TC_NCLS))
 #define CLR_TC_NCLS(v)   ( v & ~TC_NCLS)
@@ -71,13 +69,13 @@ bits 9,10,11: redirect counter -  redirect TTL. Loop avoidance
 #define G_TC_RTTL(x)       _TC_GETVALUE(x,S_TC_RTTL,M_TC_RTTL)
 #define V_TC_RTTL(x)       _TC_MAKEVALUE(x,S_TC_RTTL)
 #define SET_TC_RTTL(v,n)   ((V_TC_RTTL(n)) | (v & ~M_TC_RTTL))
-#endif
 
 #define S_TC_AT          _TC_MAKE32(12)
 #define M_TC_AT          _TC_MAKEMASK(2,S_TC_AT)
 #define G_TC_AT(x)       _TC_GETVALUE(x,S_TC_AT,M_TC_AT)
 #define V_TC_AT(x)       _TC_MAKEVALUE(x,S_TC_AT)
 #define SET_TC_AT(v,n)   ((V_TC_AT(n)) | (v & ~M_TC_AT))
+#endif
 
 /* Action attributes */
 enum {
diff --git a/net/core/dev.c b/net/core/dev.c
index 68bf73a..e2549fd 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2964,9 +2964,6 @@ static int __dev_queue_xmit(struct sk_buff *skb, void *accel_priv)
 	txq = netdev_pick_tx(dev, skb, accel_priv);
 	q = rcu_dereference_bh(txq->qdisc);
 
-#ifdef CONFIG_NET_CLS_ACT
-	skb->tc_verd = SET_TC_AT(skb->tc_verd, AT_EGRESS);
-#endif
 	trace_net_dev_queue(skb);
 	if (q->enqueue) {
 		rc = __dev_xmit_skb(skb, q, dev, txq);
@@ -3534,8 +3531,6 @@ static int ing_filter(struct sk_buff *skb, struct netdev_queue *rxq)
 	int result = TC_ACT_OK;
 	struct Qdisc *q;
 
-	skb->tc_verd = SET_TC_AT(skb->tc_verd, AT_INGRESS);
-
 	q = rcu_dereference(rxq->qdisc);
 	if (q != &noop_qdisc) {
 		if (likely(!test_bit(__QDISC_STATE_DEACTIVATED, &q->state)))
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 9d51baa..63bd83b 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -131,7 +131,6 @@ static int tcf_mirred(struct sk_buff *skb, const struct tc_action *a,
 	struct tcf_mirred *m = a->priv;
 	struct net_device *dev;
 	struct sk_buff *skb2;
-	u32 at;
 	int retval, err = 1;
 
 	spin_lock(&m->tcf_lock);
@@ -150,19 +149,19 @@ static int tcf_mirred(struct sk_buff *skb, const struct tc_action *a,
 		goto out;
 	}
 
-	at = G_TC_AT(skb->tc_verd);
 	skb2 = skb_clone(skb, GFP_ATOMIC);
 	if (skb2 == NULL)
 		goto out;
 
-	if (!(at & AT_EGRESS)) {
+	if (skb->tc_at_ingress) {
 		if (m->tcfm_ok_push)
 			skb_push(skb2, skb->mac_len);
+		skb2->tc_at_ingress = 0;
 	}
 
 	/* mirror is always swallowed */
 	if (m->tcfm_eaction != TCA_EGRESS_MIRROR)
-		skb2->tc_from_ingress = at & AT_INGRESS ? 1 : 0;
+		skb2->tc_from_ingress = skb->tc_at_ingress;
 
 	skb2->skb_iif = skb->dev->ifindex;
 	skb2->dev = dev;
diff --git a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
index a89cc32..b163658 100644
--- a/net/sched/sch_ingress.c
+++ b/net/sched/sch_ingress.c
@@ -63,7 +63,9 @@ static int ingress_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	struct tcf_proto *fl = rcu_dereference_bh(p->filter_list);
 	int result;
 
+	skb->tc_at_ingress = 1;
 	result = tc_classify(skb, fl, &res);
+	skb->tc_at_ingress = 0;
 
 	qdisc_bstats_update_cpu(sch, skb);
 	switch (result) {
-- 
2.0.5

From: Florian Westphal <fw@strlen.de>
Subject: [PATCH -next 2/3] net: sched: remove AT INGRESS/EGRESS
Date: Fri, 15 May 2015 10:50:49 +0200
Message-ID: <1431679850-31896-3-git-send-email-fw@strlen.de>
References: <1431679850-31896-1-git-send-email-fw@strlen.de>
Cc: jhs@mojatatu.com, alexei.starovoitov@gmail.com,
	daniel@iogearbox.net, Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:48181 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932074AbbEOIvB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 04:51:01 -0400
In-Reply-To: <1431679850-31896-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

act_mirred needs to know when it is invoked from ingress sched so it
knows that it has to push the l2 header back (which is already in place
if its called via the 'normal' egress path).

This is currently done via SET_TC_AT(), and explicit AT_INGRESS/EGRESS.
But some of this information is redundant.

The skb can only be in one of four states:

- FROM_INGRESS: skb was redirected via act_mirred and should be
                reinjected into ingress path
- FROM_EGRESS:  skb was redirected via act_mirred and needs to
                be transmitted via the device that the mirred action is
		attached to.

These (existing) two states are set by act_mirred, IFB driver is consumer.

The third state is 'zero', which means the skb has not been handled by
any part of the tc machinery (or has no "special properties" tc
needs to be aware of).

This adds the 4th skb_tc_state: TC_AT_INGRESS.

This is set when calling tc_classify in the ingress path.  The mirred
action uses this to decide the state of the cloned skb that it operates on:

original      clone
TC_AT_INGRESS TC_FROM_INGRESS
0             TC_FROM_EGRESS

We also remove the need to re-set tc_verd AT state in dev_queue_xmit.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/linux/skbuff.h       |  2 +-
 include/net/pkt_sched.h      | 12 ++++++++++++
 include/uapi/linux/pkt_cls.h |  4 ++--
 net/core/dev.c               |  6 ++----
 net/sched/act_mirred.c       |  8 +++-----
 5 files changed, 20 insertions(+), 12 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 4a1367e..906dc35 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -487,7 +487,7 @@ static inline u32 skb_mstamp_us_delta(const struct skb_mstamp *t1,
  *	@hash: the packet hash
  *	@queue_mapping: Queue mapping for multiqueue devices
  *	@xmit_more: More SKBs are pending for this queue
- *	@skb_tc_state: was mirrored (act_mirred)
+ *	@skb_tc_state: was mirrored (act_mirred) or is handled via sch_ingress
  *	@ndisc_nodetype: router type (from link layer)
  *	@ooo_okay: allow the mapping of a socket to a queue to be changed
  *	@l4_hash: indicate hash is a canonical 4-tuple hash over transport
diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index a4c509d..63328cf 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -134,10 +134,22 @@ static inline unsigned int psched_mtu(const struct net_device *dev)
 	return dev->mtu + dev->hard_header_len;
 }
 
+/* traffic control processing state of the skb.
+ *
+ * This is mainly used by IFB driver, the 'mirred' action, and
+ * the ingress scheduler (sch_ingress).
+ */
 enum skb_tc_state {
+	TC_NO_STATE = 0, /* must be 0 */
+
 	/* set by act_mirred to tell IFB that skb needs to be ... */
 	TC_FROM_INGRESS = 1, /* ... re-injected to local stack */
 	TC_FROM_EGRESS = 2,  /* ... transmitted to device */
+
+	/* used by act_mirred to learn its called during skb rx processing
+	 * and has to push back the (already pulled) l2 header.
+	 */
+	TC_AT_INGRESS = 3,
 };
 
 #endif
diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
index 3308e89..271c788 100644
--- a/include/uapi/linux/pkt_cls.h
+++ b/include/uapi/linux/pkt_cls.h
@@ -56,10 +56,10 @@ bits 9,10,11: redirect counter -  redirect TTL. Loop avoidance
 #define G_TC_FROM(x)       _TC_GETVALUE(x,S_TC_FROM,M_TC_FROM)
 #define V_TC_FROM(x)       _TC_MAKEVALUE(x,S_TC_FROM)
 #define SET_TC_FROM(v,n)   ((V_TC_FROM(n)) | (v & ~M_TC_FROM))
-#endif
 #define AT_STACK	0x0
 #define AT_INGRESS	0x1
 #define AT_EGRESS	0x2
+#endif
 
 #define TC_NCLS          _TC_MAKEMASK1(8)
 #define SET_TC_NCLS(v)   ( TC_NCLS | (v & ~TC_NCLS))
@@ -71,13 +71,13 @@ bits 9,10,11: redirect counter -  redirect TTL. Loop avoidance
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
index 0e7afef..802b9b9 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3071,9 +3071,6 @@ static int __dev_queue_xmit(struct sk_buff *skb, void *accel_priv)
 	txq = netdev_pick_tx(dev, skb, accel_priv);
 	q = rcu_dereference_bh(txq->qdisc);
 
-#ifdef CONFIG_NET_CLS_ACT
-	skb->tc_verd = SET_TC_AT(skb->tc_verd, AT_EGRESS);
-#endif
 	trace_net_dev_queue(skb);
 	if (q->enqueue) {
 		rc = __dev_xmit_skb(skb, q, dev, txq);
@@ -3648,7 +3645,7 @@ static inline struct sk_buff *handle_ing(struct sk_buff *skb,
 	}
 
 	qdisc_skb_cb(skb)->pkt_len = skb->len;
-	skb->tc_verd = SET_TC_AT(skb->tc_verd, AT_INGRESS);
+	skb->skb_tc_state = TC_AT_INGRESS;
 	qdisc_bstats_update_cpu(cl->q, skb);
 
 	switch (tc_classify(skb, cl, &cl_res)) {
@@ -3665,6 +3662,7 @@ static inline struct sk_buff *handle_ing(struct sk_buff *skb,
 	default:
 		break;
 	}
+	skb->skb_tc_state = 0;
 
 	return skb;
 }
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 34d4320..b8d70de 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -131,7 +131,6 @@ static int tcf_mirred(struct sk_buff *skb, const struct tc_action *a,
 	struct tcf_mirred *m = a->priv;
 	struct net_device *dev;
 	struct sk_buff *skb2;
-	u32 at;
 	int retval, err = 1;
 
 	spin_lock(&m->tcf_lock);
@@ -150,21 +149,20 @@ static int tcf_mirred(struct sk_buff *skb, const struct tc_action *a,
 		goto out;
 	}
 
-	at = G_TC_AT(skb->tc_verd);
 	skb2 = skb_clone(skb, GFP_ATOMIC);
 	if (skb2 == NULL)
 		goto out;
 
-	if (!(at & AT_EGRESS)) {
+	if (skb->skb_tc_state == TC_AT_INGRESS) {
 		if (m->tcfm_ok_push)
 			skb_push(skb2, skb->mac_len);
 	}
 
 	/* mirror is always swallowed */
 	if (m->tcfm_eaction != TCA_EGRESS_MIRROR) {
-		if (at & AT_INGRESS)
+		if (skb->skb_tc_state == TC_AT_INGRESS)
 			skb2->skb_tc_state = TC_FROM_INGRESS;
-		else if (at & AT_EGRESS)
+		else
 			skb2->skb_tc_state = TC_FROM_EGRESS;
 	}
 	skb2->skb_iif = skb->dev->ifindex;
-- 
2.0.5

From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next rfc 5/6] net-tc: convert tc_at to tc_at_ingress
Date: Wed, 28 Dec 2016 14:13:29 -0500
Message-ID: <1482952410-50003-6-git-send-email-willemdebruijn.kernel@gmail.com>
References: <1482952410-50003-1-git-send-email-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, fw@strlen.de, dborkman@iogearbox.net,
        jhs@mojatatu.com, alexei.starovoitov@gmail.com,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:33939 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751878AbcL1TNg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Dec 2016 14:13:36 -0500
Received: by mail-qt0-f194.google.com with SMTP id p16so24897617qta.1
        for <netdev@vger.kernel.org>; Wed, 28 Dec 2016 11:13:36 -0800 (PST)
In-Reply-To: <1482952410-50003-1-git-send-email-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Field tc_at is used only within tc actions to distinguish ingress from
egress processing. A single bit is sufficient for this purpose. Set it
within tc_classify to make the scope clear and to avoid the need to
clear it in skb_reset_tc.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 include/linux/skbuff.h    |  3 ++-
 include/net/sch_generic.h |  3 +--
 net/core/dev.c            |  6 +-----
 net/sched/act_mirred.c    | 12 ++++++------
 net/sched/sch_api.c       |  1 +
 5 files changed, 11 insertions(+), 14 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index f738d09..fab3f87 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -590,6 +590,7 @@ static inline bool skb_mstamp_after(const struct skb_mstamp *t1,
  *	@fclone: skbuff clone status
  *	@ipvs_property: skbuff is owned by ipvs
  *	@tc_skip_classify: do not classify packet. set by IFB device
+ *	@tc_at_ingress: used within tc_classify to distinguish in/egress
  *	@peeked: this packet has been seen already, so stats have been
  *		done for it, don't do them again
  *	@nf_trace: netfilter packet trace flag
@@ -751,7 +752,7 @@ struct sk_buff {
 #endif
 #ifdef CONFIG_NET_CLS_ACT
 	__u8			tc_skip_classify:1;
-	__u8			tc_at:2;
+	__u8			tc_at_ingress:1;
 	__u8			tc_from:2;
 #endif
 
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index f80dba5..4bd6d53 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -412,7 +412,6 @@ int skb_do_redirect(struct sk_buff *);
 static inline void skb_reset_tc(struct sk_buff *skb)
 {
 #ifdef CONFIG_NET_CLS_ACT
-	skb->tc_at = 0;
 	skb->tc_from = 0;
 #endif
 }
@@ -420,7 +419,7 @@ static inline void skb_reset_tc(struct sk_buff *skb)
 static inline bool skb_at_tc_ingress(const struct sk_buff *skb)
 {
 #ifdef CONFIG_NET_CLS_ACT
-	return skb->tc_at & AT_INGRESS;
+	return skb->tc_at_ingress;
 #else
 	return false;
 #endif
diff --git a/net/core/dev.c b/net/core/dev.c
index 25620cf..90833fdf 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3153,9 +3153,7 @@ sch_handle_egress(struct sk_buff *skb, int *ret, struct net_device *dev)
 	if (!cl)
 		return skb;
 
-	/* skb->tc_at and qdisc_skb_cb(skb)->pkt_len were already set
-	 * earlier by the caller.
-	 */
+	/* qdisc_skb_cb(skb)->pkt_len was already set by the caller. */
 	qdisc_bstats_cpu_update(cl->q, skb);
 
 	switch (tc_classify(skb, cl, &cl_res, false)) {
@@ -3320,7 +3318,6 @@ static int __dev_queue_xmit(struct sk_buff *skb, void *accel_priv)
 
 	qdisc_pkt_len_init(skb);
 #ifdef CONFIG_NET_CLS_ACT
-	skb->tc_at = AT_EGRESS;
 # ifdef CONFIG_NET_EGRESS
 	if (static_key_false(&egress_needed)) {
 		skb = sch_handle_egress(skb, &rc, dev);
@@ -3916,7 +3913,6 @@ sch_handle_ingress(struct sk_buff *skb, struct packet_type **pt_prev, int *ret,
 	}
 
 	qdisc_skb_cb(skb)->pkt_len = skb->len;
-	skb->tc_at = AT_INGRESS;
 	qdisc_bstats_cpu_update(cl->q, skb);
 
 	switch (tc_classify(skb, cl, &cl_res, false)) {
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 8543279..e832c62 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -39,15 +39,15 @@ static bool tcf_mirred_is_act_redirect(int action)
 	return action == TCA_EGRESS_REDIR || action == TCA_INGRESS_REDIR;
 }
 
-static u32 tcf_mirred_act_direction(int action)
+static bool tcf_mirred_act_wants_ingress(int action)
 {
 	switch (action) {
 	case TCA_EGRESS_REDIR:
 	case TCA_EGRESS_MIRROR:
-		return AT_EGRESS;
+		return false;
 	case TCA_INGRESS_REDIR:
 	case TCA_INGRESS_MIRROR:
-		return AT_INGRESS;
+		return true;
 	default:
 		BUG();
 	}
@@ -198,7 +198,7 @@ static int tcf_mirred(struct sk_buff *skb, const struct tc_action *a,
 	 * and devices expect a mac header on xmit, then mac push/pull is
 	 * needed.
 	 */
-	if (skb->tc_at != tcf_mirred_act_direction(m_eaction) &&
+	if (skb_at_tc_ingress(skb) != tcf_mirred_act_wants_ingress(m_eaction) &&
 	    m_mac_header_xmit) {
 		if (!skb_at_tc_ingress(skb)) {
 			/* caught at egress, act ingress: pull mac */
@@ -212,11 +212,11 @@ static int tcf_mirred(struct sk_buff *skb, const struct tc_action *a,
 
 	/* mirror is always swallowed */
 	if (tcf_mirred_is_act_redirect(m_eaction))
-		skb2->tc_from = skb2->tc_at;
+		skb2->tc_from = skb_at_tc_ingress(skb) ? AT_INGRESS : AT_EGRESS;
 
 	skb2->skb_iif = skb->dev->ifindex;
 	skb2->dev = dev;
-	if (tcf_mirred_act_direction(m_eaction) & AT_EGRESS)
+	if (!tcf_mirred_act_wants_ingress(m_eaction))
 		err = dev_queue_xmit(skb2);
 	else
 		err = netif_receive_skb(skb2);
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index ef53ede..be4e18d 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1865,6 +1865,7 @@ int tc_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 	const struct tcf_proto *old_tp = tp;
 	int limit = 0;
 
+	skb->tc_at_ingress = !!(tp && tp->q->flags & TCQ_F_INGRESS);
 reclassify:
 #endif
 	for (; tp; tp = rcu_dereference_bh(tp->next)) {
-- 
2.8.0.rc3.226.g39d4020

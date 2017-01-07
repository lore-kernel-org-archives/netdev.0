From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next 5/6] net-tc: convert tc_at to tc_at_ingress
Date: Sat,  7 Jan 2017 17:06:37 -0500
Message-ID: <20170107220638.61314-6-willemdebruijn.kernel@gmail.com>
References: <20170107220638.61314-1-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, fw@strlen.de, dborkman@iogearbox.net,
        jhs@mojatatu.com, alexei.starovoitov@gmail.com,
        eric.dumazet@gmail.com, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:33808 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932821AbdAGWGs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 7 Jan 2017 17:06:48 -0500
Received: by mail-qk0-f196.google.com with SMTP id e1so11295559qkh.1
        for <netdev@vger.kernel.org>; Sat, 07 Jan 2017 14:06:47 -0800 (PST)
In-Reply-To: <20170107220638.61314-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Field tc_at is used only within tc actions to distinguish ingress from
egress processing. A single bit is sufficient for this purpose.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 include/linux/skbuff.h    |  3 ++-
 include/net/sch_generic.h |  3 +--
 net/core/dev.c            |  8 +++-----
 net/sched/act_mirred.c    | 12 ++++++------
 4 files changed, 12 insertions(+), 14 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index f738d09947b2..fab3f87e9bd1 100644
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
index f80dba516964..4bd6d5387209 100644
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
index 8b5d6d033473..c143f1391117 100644
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
@@ -3320,7 +3318,7 @@ static int __dev_queue_xmit(struct sk_buff *skb, void *accel_priv)
 
 	qdisc_pkt_len_init(skb);
 #ifdef CONFIG_NET_CLS_ACT
-	skb->tc_at = AT_EGRESS;
+	skb->tc_at_ingress = 0;
 # ifdef CONFIG_NET_EGRESS
 	if (static_key_false(&egress_needed)) {
 		skb = sch_handle_egress(skb, &rc, dev);
@@ -3920,7 +3918,7 @@ sch_handle_ingress(struct sk_buff *skb, struct packet_type **pt_prev, int *ret,
 	}
 
 	qdisc_skb_cb(skb)->pkt_len = skb->len;
-	skb->tc_at = AT_INGRESS;
+	skb->tc_at_ingress = 1;
 	qdisc_bstats_cpu_update(cl->q, skb);
 
 	switch (tc_classify(skb, cl, &cl_res, false)) {
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 8543279bba49..e832c62fd705 100644
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
-- 
2.11.0.390.gc69c2f50cf-goog

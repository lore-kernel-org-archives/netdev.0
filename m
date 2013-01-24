From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH 1/2] net: Add skb_unclone() helper function.
Date: Thu, 24 Jan 2013 14:16:27 -0800
Message-ID: <1359065787-1763-1-git-send-email-pshelar@nicira.com>
Cc: jesse@nicira.com, eric.dumazet@gmail.com,
	Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog114.obsmtp.com ([74.125.149.211]:39691 "HELO
	na3sys009aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755659Ab3AXWPl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2013 17:15:41 -0500
Received: by mail-oa0-f69.google.com with SMTP id l10so12971976oag.8
        for <netdev@vger.kernel.org>; Thu, 24 Jan 2013 14:15:36 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 drivers/net/ppp/ppp_generic.c           |    3 +--
 include/linux/skbuff.h                  |   13 +++++++++++++
 net/ipv4/ah4.c                          |    3 +--
 net/ipv4/ip_fragment.c                  |    2 +-
 net/ipv4/tcp_output.c                   |    2 +-
 net/ipv4/xfrm4_input.c                  |    2 +-
 net/ipv4/xfrm4_mode_tunnel.c            |    3 +--
 net/ipv6/ah6.c                          |    3 +--
 net/ipv6/netfilter/nf_conntrack_reasm.c |    2 +-
 net/ipv6/reassembly.c                   |    2 +-
 net/ipv6/xfrm6_mode_tunnel.c            |    3 +--
 net/sched/act_ipt.c                     |    6 ++----
 net/sched/act_pedit.c                   |    3 +--
 13 files changed, 26 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index 0b2706a..4fd754e 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -1805,8 +1805,7 @@ ppp_receive_nonmp_frame(struct ppp *ppp, struct sk_buff *skb)
 		/* the filter instructions are constructed assuming
 		   a four-byte PPP header on each packet */
 		if (ppp->pass_filter || ppp->active_filter) {
-			if (skb_cloned(skb) &&
-			    pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
+			if (skb_unclone(skb, GFP_ATOMIC))
 				goto err;
 
 			*skb_push(skb, 2) = 0;
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 8b2256e..7c00664 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -798,6 +798,19 @@ static inline int skb_cloned(const struct sk_buff *skb)
 }
 
 /**
+ *	skb_unclone - creates separate copy if skb is cloned.
+ */
+static inline bool skb_unclone(struct sk_buff *skb, gfp_t pri)
+{
+	might_sleep_if(pri & __GFP_WAIT);
+
+	if (skb_cloned(skb))
+		return pskb_expand_head(skb, 0, 0, pri);
+
+	return 0;
+}
+
+/**
  *	skb_header_cloned - is the header a clone
  *	@skb: buffer to check
  *
diff --git a/net/ipv4/ah4.c b/net/ipv4/ah4.c
index a0d8392..396c823 100644
--- a/net/ipv4/ah4.c
+++ b/net/ipv4/ah4.c
@@ -317,8 +317,7 @@ static int ah_input(struct xfrm_state *x, struct sk_buff *skb)
 
 	/* We are going to _remove_ AH header to keep sockets happy,
 	 * so... Later this can change. */
-	if (skb_cloned(skb) &&
-	    pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
+	if (skb_unclone(skb, GFP_ATOMIC))
 		goto out;
 
 	skb->ip_summed = CHECKSUM_NONE;
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index f55a4e6..411ef7c 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -594,7 +594,7 @@ static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
 		goto out_oversize;
 
 	/* Head of list must not be cloned. */
-	if (skb_cloned(head) && pskb_expand_head(head, 0, 0, GFP_ATOMIC))
+	if (skb_unclone(head, GFP_ATOMIC))
 		goto out_nomem;
 
 	/* If the first fragment is fragmented itself, we split
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 667a6ad..0ecc187 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1331,7 +1331,7 @@ static void __pskb_trim_head(struct sk_buff *skb, int len)
 /* Remove acked data from a packet in the transmit queue. */
 int tcp_trim_head(struct sock *sk, struct sk_buff *skb, u32 len)
 {
-	if (skb_cloned(skb) && pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
+	if (skb_unclone(skb, GFP_ATOMIC))
 		return -ENOMEM;
 
 	__pskb_trim_head(skb, len);
diff --git a/net/ipv4/xfrm4_input.c b/net/ipv4/xfrm4_input.c
index 06814b6..1f12c8b 100644
--- a/net/ipv4/xfrm4_input.c
+++ b/net/ipv4/xfrm4_input.c
@@ -132,7 +132,7 @@ int xfrm4_udp_encap_rcv(struct sock *sk, struct sk_buff *skb)
 	 * header and optional ESP marker bytes) and then modify the
 	 * protocol to ESP, and then call into the transform receiver.
 	 */
-	if (skb_cloned(skb) && pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
+	if (skb_unclone(skb, GFP_ATOMIC))
 		goto drop;
 
 	/* Now we can update and verify the packet length... */
diff --git a/net/ipv4/xfrm4_mode_tunnel.c b/net/ipv4/xfrm4_mode_tunnel.c
index ddee0a0..c1f00ef 100644
--- a/net/ipv4/xfrm4_mode_tunnel.c
+++ b/net/ipv4/xfrm4_mode_tunnel.c
@@ -142,8 +142,7 @@ static int xfrm4_mode_tunnel_input(struct xfrm_state *x, struct sk_buff *skb)
 	for_each_input_rcu(rcv_notify_handlers, handler)
 		handler->handler(skb);
 
-	if (skb_cloned(skb) &&
-	    (err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC)))
+	if (skb_unclone(skb, GFP_ATOMIC))
 		goto out;
 
 	if (x->props.flags & XFRM_STATE_DECAP_DSCP)
diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index ecc35b9..afcf8ee 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -518,8 +518,7 @@ static int ah6_input(struct xfrm_state *x, struct sk_buff *skb)
 
 	/* We are going to _remove_ AH header to keep sockets happy,
 	 * so... Later this can change. */
-	if (skb_cloned(skb) &&
-	    pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
+	if (skb_unclone(skb, GFP_ATOMIC))
 		goto out;
 
 	skb->ip_summed = CHECKSUM_NONE;
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 3dacecc..4e941dc 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -369,7 +369,7 @@ nf_ct_frag6_reasm(struct frag_queue *fq, struct net_device *dev)
 	}
 
 	/* Head of list must not be cloned. */
-	if (skb_cloned(head) && pskb_expand_head(head, 0, 0, GFP_ATOMIC)) {
+	if (skb_unclone(head, GFP_ATOMIC)) {
 		pr_debug("skb is cloned but can't expand head");
 		goto out_oom;
 	}
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index e5253ec..c9d5d3ddfc 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -406,7 +406,7 @@ static int ip6_frag_reasm(struct frag_queue *fq, struct sk_buff *prev,
 		goto out_oversize;
 
 	/* Head of list must not be cloned. */
-	if (skb_cloned(head) && pskb_expand_head(head, 0, 0, GFP_ATOMIC))
+	if (skb_unclone(head, GFP_ATOMIC))
 		goto out_oom;
 
 	/* If the first fragment is fragmented itself, we split
diff --git a/net/ipv6/xfrm6_mode_tunnel.c b/net/ipv6/xfrm6_mode_tunnel.c
index 9f2095b..4b04f4e 100644
--- a/net/ipv6/xfrm6_mode_tunnel.c
+++ b/net/ipv6/xfrm6_mode_tunnel.c
@@ -69,8 +69,7 @@ static int xfrm6_mode_tunnel_input(struct xfrm_state *x, struct sk_buff *skb)
 	if (!pskb_may_pull(skb, sizeof(struct ipv6hdr)))
 		goto out;
 
-	if (skb_cloned(skb) &&
-	    (err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC)))
+	if (skb_unclone(skb, GFP_ATOMIC))
 		goto out;
 
 	if (x->props.flags & XFRM_STATE_DECAP_DSCP)
diff --git a/net/sched/act_ipt.c b/net/sched/act_ipt.c
index 0fb9e3f..e0f6de6 100644
--- a/net/sched/act_ipt.c
+++ b/net/sched/act_ipt.c
@@ -207,10 +207,8 @@ static int tcf_ipt(struct sk_buff *skb, const struct tc_action *a,
 	struct tcf_ipt *ipt = a->priv;
 	struct xt_action_param par;
 
-	if (skb_cloned(skb)) {
-		if (pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
-			return TC_ACT_UNSPEC;
-	}
+	if (skb_unclone(skb, GFP_ATOMIC))
+		return TC_ACT_UNSPEC;
 
 	spin_lock(&ipt->tcf_lock);
 
diff --git a/net/sched/act_pedit.c b/net/sched/act_pedit.c
index 0c3fadd..7ed78c9 100644
--- a/net/sched/act_pedit.c
+++ b/net/sched/act_pedit.c
@@ -131,8 +131,7 @@ static int tcf_pedit(struct sk_buff *skb, const struct tc_action *a,
 	int i, munged = 0;
 	unsigned int off;
 
-	if (skb_cloned(skb) &&
-	    pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
+	if (skb_unclone(skb, GFP_ATOMIC))
 		return p->tcf_action;
 
 	off = skb_network_offset(skb);
-- 
1.7.10

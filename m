From: pablo@netfilter.org
Subject: [PATCH 5/5] netfilter: nf_conntrack: permanently attach timeout policy to conntrack
Date: Fri, 23 Mar 2012 10:34:17 +0100
Message-ID: <1332495257-3149-6-git-send-email-pablo@netfilter.org>
References: <1332495257-3149-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:47842 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758015Ab2CWJen (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Mar 2012 05:34:43 -0400
In-Reply-To: <1332495257-3149-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

We need to permanently attach the timeout policy to the conntrack,
otherwise we may apply the custom timeout policy inconsistently.

Without this patch, the following example:

 nfct timeout add test inet icmp timeout 100
 iptables -I PREROUTING -t raw -p icmp -s 1.1.1.1 -j CT --timeout test

Will only apply the custom timeout policy to outgoing packets from
1.1.1.1, but not to reply packets from 2.2.2.2 going to 1.1.1.1.

To fix this issue, this patch modifies the current logic to attach the
timeout policy when the first packet is seen (which is when the
conntrack entry is created). Then, we keep using the attached timeout
policy until the conntrack entry is destroyed.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_core.c |   39 ++++++++++++++++++++----------------
 1 files changed, 22 insertions(+), 17 deletions(-)

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 7b48035..cbdb754 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -768,8 +768,7 @@ init_conntrack(struct net *net, struct nf_conn *tmpl,
 	       struct nf_conntrack_l3proto *l3proto,
 	       struct nf_conntrack_l4proto *l4proto,
 	       struct sk_buff *skb,
-	       unsigned int dataoff, u32 hash,
-	       unsigned int *timeouts)
+	       unsigned int dataoff, u32 hash)
 {
 	struct nf_conn *ct;
 	struct nf_conn_help *help;
@@ -777,6 +776,8 @@ init_conntrack(struct net *net, struct nf_conn *tmpl,
 	struct nf_conntrack_ecache *ecache;
 	struct nf_conntrack_expect *exp;
 	u16 zone = tmpl ? nf_ct_zone(tmpl) : NF_CT_DEFAULT_ZONE;
+	struct nf_conn_timeout *timeout_ext;
+	unsigned int *timeouts;
 
 	if (!nf_ct_invert_tuple(&repl_tuple, tuple, l3proto, l4proto)) {
 		pr_debug("Can't invert tuple.\n");
@@ -788,12 +789,21 @@ init_conntrack(struct net *net, struct nf_conn *tmpl,
 	if (IS_ERR(ct))
 		return (struct nf_conntrack_tuple_hash *)ct;
 
+	timeout_ext = tmpl ? nf_ct_timeout_find(tmpl) : NULL;
+	if (timeout_ext)
+		timeouts = NF_CT_TIMEOUT_EXT_DATA(timeout_ext);
+	else
+		timeouts = l4proto->get_timeouts(net);
+
 	if (!l4proto->new(ct, skb, dataoff, timeouts)) {
 		nf_conntrack_free(ct);
 		pr_debug("init conntrack: can't track with proto module\n");
 		return NULL;
 	}
 
+	if (timeout_ext)
+		nf_ct_timeout_ext_add(ct, timeout_ext->timeout, GFP_ATOMIC);
+
 	nf_ct_acct_ext_add(ct, GFP_ATOMIC);
 	nf_ct_tstamp_ext_add(ct, GFP_ATOMIC);
 
@@ -854,8 +864,7 @@ resolve_normal_ct(struct net *net, struct nf_conn *tmpl,
 		  struct nf_conntrack_l3proto *l3proto,
 		  struct nf_conntrack_l4proto *l4proto,
 		  int *set_reply,
-		  enum ip_conntrack_info *ctinfo,
-		  unsigned int *timeouts)
+		  enum ip_conntrack_info *ctinfo)
 {
 	struct nf_conntrack_tuple tuple;
 	struct nf_conntrack_tuple_hash *h;
@@ -875,7 +884,7 @@ resolve_normal_ct(struct net *net, struct nf_conn *tmpl,
 	h = __nf_conntrack_find_get(net, zone, &tuple, hash);
 	if (!h) {
 		h = init_conntrack(net, tmpl, &tuple, l3proto, l4proto,
-				   skb, dataoff, hash, timeouts);
+				   skb, dataoff, hash);
 		if (!h)
 			return NULL;
 		if (IS_ERR(h))
@@ -964,19 +973,8 @@ nf_conntrack_in(struct net *net, u_int8_t pf, unsigned int hooknum,
 			goto out;
 	}
 
-	/* Decide what timeout policy we want to apply to this flow. */
-	if (tmpl) {
-	        timeout_ext = nf_ct_timeout_find(tmpl);
-		if (timeout_ext)
-			timeouts = NF_CT_TIMEOUT_EXT_DATA(timeout_ext);
-		else
-			timeouts = l4proto->get_timeouts(net);
-	} else
-		timeouts = l4proto->get_timeouts(net);
-
 	ct = resolve_normal_ct(net, tmpl, skb, dataoff, pf, protonum,
-			       l3proto, l4proto, &set_reply, &ctinfo,
-			       timeouts);
+			       l3proto, l4proto, &set_reply, &ctinfo);
 	if (!ct) {
 		/* Not valid part of a connection */
 		NF_CT_STAT_INC_ATOMIC(net, invalid);
@@ -993,6 +991,13 @@ nf_conntrack_in(struct net *net, u_int8_t pf, unsigned int hooknum,
 
 	NF_CT_ASSERT(skb->nfct);
 
+	/* Decide what timeout policy we want to apply to this flow. */
+	timeout_ext = nf_ct_timeout_find(ct);
+	if (timeout_ext)
+		timeouts = NF_CT_TIMEOUT_EXT_DATA(timeout_ext);
+	else
+		timeouts = l4proto->get_timeouts(net);
+
 	ret = l4proto->packet(ct, skb, dataoff, ctinfo, pf, hooknum, timeouts);
 	if (ret <= 0) {
 		/* Invalid: inverse of the return code tells
-- 
1.7.2.5

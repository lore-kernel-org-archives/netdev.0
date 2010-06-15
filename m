From: kaber@trash.net
Subject: [PATCH 05/17] netfilter: nf_conntrack: IPS_UNTRACKED bit
Date: Tue, 15 Jun 2010 17:38:31 +0200
Message-ID: <1276616323-20880-6-git-send-email-kaber@trash.net>
References: <1276616323-20880-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42172 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932145Ab0FOP3y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 11:29:54 -0400
In-Reply-To: <1276616323-20880-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>

NOTRACK makes all cpus share a cache line on nf_conntrack_untracked
twice per packet. This is bad for performance.
__read_mostly annotation is also a bad choice.

This patch introduces IPS_UNTRACKED bit so that we can use later a
per_cpu untrack structure more easily.

A new helper, nf_ct_untracked_get() returns a pointer to
nf_conntrack_untracked.

Another one, nf_ct_untracked_status_or() is used by nf_nat_init() to add
IPS_NAT_DONE_MASK bits to untracked status.

nf_ct_is_untracked() prototype is changed to work on a nf_conn pointer.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netfilter/nf_conntrack_common.h  |    4 ++++
 include/net/netfilter/nf_conntrack.h           |   12 +++++++++---
 include/net/netfilter/nf_conntrack_core.h      |    2 +-
 net/ipv4/netfilter/nf_nat_core.c               |    2 +-
 net/ipv4/netfilter/nf_nat_standalone.c         |    2 +-
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |    2 +-
 net/netfilter/nf_conntrack_core.c              |   11 ++++++++---
 net/netfilter/nf_conntrack_netlink.c           |    2 +-
 net/netfilter/xt_CT.c                          |    4 ++--
 net/netfilter/xt_NOTRACK.c                     |    2 +-
 net/netfilter/xt_TEE.c                         |    4 ++--
 net/netfilter/xt_cluster.c                     |    2 +-
 net/netfilter/xt_conntrack.c                   |   11 ++++++-----
 net/netfilter/xt_socket.c                      |    2 +-
 net/netfilter/xt_state.c                       |   14 ++++++++------
 15 files changed, 47 insertions(+), 29 deletions(-)

diff --git a/include/linux/netfilter/nf_conntrack_common.h b/include/linux/netfilter/nf_conntrack_common.h
index 14e6d32..1afd18c 100644
--- a/include/linux/netfilter/nf_conntrack_common.h
+++ b/include/linux/netfilter/nf_conntrack_common.h
@@ -76,6 +76,10 @@ enum ip_conntrack_status {
 	/* Conntrack is a template */
 	IPS_TEMPLATE_BIT = 11,
 	IPS_TEMPLATE = (1 << IPS_TEMPLATE_BIT),
+
+	/* Conntrack is a fake untracked entry */
+	IPS_UNTRACKED_BIT = 12,
+	IPS_UNTRACKED = (1 << IPS_UNTRACKED_BIT),
 };
 
 /* Connection tracking event types */
diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index bde095f..3bc38c7 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -261,7 +261,13 @@ extern s16 (*nf_ct_nat_offset)(const struct nf_conn *ct,
 			       u32 seq);
 
 /* Fake conntrack entry for untracked connections */
-extern struct nf_conn nf_conntrack_untracked;
+static inline struct nf_conn *nf_ct_untracked_get(void)
+{
+	extern struct nf_conn nf_conntrack_untracked;
+
+	return &nf_conntrack_untracked;
+}
+extern void nf_ct_untracked_status_or(unsigned long bits);
 
 /* Iterate over all conntracks: if iter returns true, it's deleted. */
 extern void
@@ -289,9 +295,9 @@ static inline int nf_ct_is_dying(struct nf_conn *ct)
 	return test_bit(IPS_DYING_BIT, &ct->status);
 }
 
-static inline int nf_ct_is_untracked(const struct sk_buff *skb)
+static inline int nf_ct_is_untracked(const struct nf_conn *ct)
 {
-	return (skb->nfct == &nf_conntrack_untracked.ct_general);
+	return test_bit(IPS_UNTRACKED_BIT, &ct->status);
 }
 
 extern int nf_conntrack_set_hashsize(const char *val, struct kernel_param *kp);
diff --git a/include/net/netfilter/nf_conntrack_core.h b/include/net/netfilter/nf_conntrack_core.h
index 3d7524f..aced085 100644
--- a/include/net/netfilter/nf_conntrack_core.h
+++ b/include/net/netfilter/nf_conntrack_core.h
@@ -60,7 +60,7 @@ static inline int nf_conntrack_confirm(struct sk_buff *skb)
 	struct nf_conn *ct = (struct nf_conn *)skb->nfct;
 	int ret = NF_ACCEPT;
 
-	if (ct && ct != &nf_conntrack_untracked) {
+	if (ct && !nf_ct_is_untracked(ct)) {
 		if (!nf_ct_is_confirmed(ct))
 			ret = __nf_conntrack_confirm(skb);
 		if (likely(ret == NF_ACCEPT))
diff --git a/net/ipv4/netfilter/nf_nat_core.c b/net/ipv4/netfilter/nf_nat_core.c
index 4f8bddb..c7719b2 100644
--- a/net/ipv4/netfilter/nf_nat_core.c
+++ b/net/ipv4/netfilter/nf_nat_core.c
@@ -742,7 +742,7 @@ static int __init nf_nat_init(void)
 	spin_unlock_bh(&nf_nat_lock);
 
 	/* Initialize fake conntrack so that NAT will skip it */
-	nf_conntrack_untracked.status |= IPS_NAT_DONE_MASK;
+	nf_ct_untracked_status_or(IPS_NAT_DONE_MASK);
 
 	l3proto = nf_ct_l3proto_find_get((u_int16_t)AF_INET);
 
diff --git a/net/ipv4/netfilter/nf_nat_standalone.c b/net/ipv4/netfilter/nf_nat_standalone.c
index beb2581..6723c68 100644
--- a/net/ipv4/netfilter/nf_nat_standalone.c
+++ b/net/ipv4/netfilter/nf_nat_standalone.c
@@ -98,7 +98,7 @@ nf_nat_fn(unsigned int hooknum,
 		return NF_ACCEPT;
 
 	/* Don't try to NAT if this packet is not conntracked */
-	if (ct == &nf_conntrack_untracked)
+	if (nf_ct_is_untracked(ct))
 		return NF_ACCEPT;
 
 	nat = nfct_nat(ct);
diff --git a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
index 9be8177..1df3c8b 100644
--- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -208,7 +208,7 @@ icmpv6_error(struct net *net, struct nf_conn *tmpl,
 	type = icmp6h->icmp6_type - 130;
 	if (type >= 0 && type < sizeof(noct_valid_new) &&
 	    noct_valid_new[type]) {
-		skb->nfct = &nf_conntrack_untracked.ct_general;
+		skb->nfct = &nf_ct_untracked_get()->ct_general;
 		skb->nfctinfo = IP_CT_NEW;
 		nf_conntrack_get(skb->nfct);
 		return NF_ACCEPT;
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index eeeb8bc..6c1da21 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -62,7 +62,7 @@ EXPORT_SYMBOL_GPL(nf_conntrack_htable_size);
 unsigned int nf_conntrack_max __read_mostly;
 EXPORT_SYMBOL_GPL(nf_conntrack_max);
 
-struct nf_conn nf_conntrack_untracked __read_mostly;
+struct nf_conn nf_conntrack_untracked;
 EXPORT_SYMBOL_GPL(nf_conntrack_untracked);
 
 static int nf_conntrack_hash_rnd_initted;
@@ -1321,6 +1321,12 @@ EXPORT_SYMBOL_GPL(nf_conntrack_set_hashsize);
 module_param_call(hashsize, nf_conntrack_set_hashsize, param_get_uint,
 		  &nf_conntrack_htable_size, 0600);
 
+void nf_ct_untracked_status_or(unsigned long bits)
+{
+	nf_conntrack_untracked.status |= bits;
+}
+EXPORT_SYMBOL_GPL(nf_ct_untracked_status_or);
+
 static int nf_conntrack_init_init_net(void)
 {
 	int max_factor = 8;
@@ -1368,8 +1374,7 @@ static int nf_conntrack_init_init_net(void)
 #endif
 	atomic_set(&nf_conntrack_untracked.ct_general.use, 1);
 	/*  - and look it like as a confirmed connection */
-	set_bit(IPS_CONFIRMED_BIT, &nf_conntrack_untracked.status);
-
+	nf_ct_untracked_status_or(IPS_CONFIRMED | IPS_UNTRACKED);
 	return 0;
 
 #ifdef CONFIG_NF_CONNTRACK_ZONES
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index c42ff6a..5bae1cd 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -480,7 +480,7 @@ ctnetlink_conntrack_event(unsigned int events, struct nf_ct_event *item)
 	int err;
 
 	/* ignore our fake conntrack entry */
-	if (ct == &nf_conntrack_untracked)
+	if (nf_ct_is_untracked(ct))
 		return 0;
 
 	if (events & (1 << IPCT_DESTROY)) {
diff --git a/net/netfilter/xt_CT.c b/net/netfilter/xt_CT.c
index 562bf32..0cb6053 100644
--- a/net/netfilter/xt_CT.c
+++ b/net/netfilter/xt_CT.c
@@ -67,7 +67,7 @@ static int xt_ct_tg_check(const struct xt_tgchk_param *par)
 		return -EINVAL;
 
 	if (info->flags & XT_CT_NOTRACK) {
-		ct = &nf_conntrack_untracked;
+		ct = nf_ct_untracked_get();
 		atomic_inc(&ct->ct_general.use);
 		goto out;
 	}
@@ -132,7 +132,7 @@ static void xt_ct_tg_destroy(const struct xt_tgdtor_param *par)
 	struct nf_conn *ct = info->ct;
 	struct nf_conn_help *help;
 
-	if (ct != &nf_conntrack_untracked) {
+	if (!nf_ct_is_untracked(ct)) {
 		help = nfct_help(ct);
 		if (help)
 			module_put(help->helper->me);
diff --git a/net/netfilter/xt_NOTRACK.c b/net/netfilter/xt_NOTRACK.c
index 512b912..9d78218 100644
--- a/net/netfilter/xt_NOTRACK.c
+++ b/net/netfilter/xt_NOTRACK.c
@@ -23,7 +23,7 @@ notrack_tg(struct sk_buff *skb, const struct xt_action_param *par)
 	   If there is a real ct entry correspondig to this packet,
 	   it'll hang aroun till timing out. We don't deal with it
 	   for performance reasons. JK */
-	skb->nfct = &nf_conntrack_untracked.ct_general;
+	skb->nfct = &nf_ct_untracked_get()->ct_general;
 	skb->nfctinfo = IP_CT_NEW;
 	nf_conntrack_get(skb->nfct);
 
diff --git a/net/netfilter/xt_TEE.c b/net/netfilter/xt_TEE.c
index 859d9fd..7a11826 100644
--- a/net/netfilter/xt_TEE.c
+++ b/net/netfilter/xt_TEE.c
@@ -104,7 +104,7 @@ tee_tg4(struct sk_buff *skb, const struct xt_action_param *par)
 #ifdef WITH_CONNTRACK
 	/* Avoid counting cloned packets towards the original connection. */
 	nf_conntrack_put(skb->nfct);
-	skb->nfct     = &nf_conntrack_untracked.ct_general;
+	skb->nfct     = &nf_ct_untracked_get()->ct_general;
 	skb->nfctinfo = IP_CT_NEW;
 	nf_conntrack_get(skb->nfct);
 #endif
@@ -177,7 +177,7 @@ tee_tg6(struct sk_buff *skb, const struct xt_action_param *par)
 
 #ifdef WITH_CONNTRACK
 	nf_conntrack_put(skb->nfct);
-	skb->nfct     = &nf_conntrack_untracked.ct_general;
+	skb->nfct     = &nf_ct_untracked_get()->ct_general;
 	skb->nfctinfo = IP_CT_NEW;
 	nf_conntrack_get(skb->nfct);
 #endif
diff --git a/net/netfilter/xt_cluster.c b/net/netfilter/xt_cluster.c
index 30b95a1..f4af1bf 100644
--- a/net/netfilter/xt_cluster.c
+++ b/net/netfilter/xt_cluster.c
@@ -120,7 +120,7 @@ xt_cluster_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	if (ct == NULL)
 		return false;
 
-	if (ct == &nf_conntrack_untracked)
+	if (nf_ct_is_untracked(ct))
 		return false;
 
 	if (ct->master)
diff --git a/net/netfilter/xt_conntrack.c b/net/netfilter/xt_conntrack.c
index 39681f1..e536710 100644
--- a/net/netfilter/xt_conntrack.c
+++ b/net/netfilter/xt_conntrack.c
@@ -123,11 +123,12 @@ conntrack_mt(const struct sk_buff *skb, struct xt_action_param *par,
 
 	ct = nf_ct_get(skb, &ctinfo);
 
-	if (ct == &nf_conntrack_untracked)
-		statebit = XT_CONNTRACK_STATE_UNTRACKED;
-	else if (ct != NULL)
-		statebit = XT_CONNTRACK_STATE_BIT(ctinfo);
-	else
+	if (ct) {
+		if (nf_ct_is_untracked(ct))
+			statebit = XT_CONNTRACK_STATE_UNTRACKED;
+		else
+			statebit = XT_CONNTRACK_STATE_BIT(ctinfo);
+	} else
 		statebit = XT_CONNTRACK_STATE_INVALID;
 
 	if (info->match_flags & XT_CONNTRACK_STATE) {
diff --git a/net/netfilter/xt_socket.c b/net/netfilter/xt_socket.c
index 3d54c23..1ca8990 100644
--- a/net/netfilter/xt_socket.c
+++ b/net/netfilter/xt_socket.c
@@ -127,7 +127,7 @@ socket_match(const struct sk_buff *skb, struct xt_action_param *par,
 	 * reply packet of an established SNAT-ted connection. */
 
 	ct = nf_ct_get(skb, &ctinfo);
-	if (ct && (ct != &nf_conntrack_untracked) &&
+	if (ct && !nf_ct_is_untracked(ct) &&
 	    ((iph->protocol != IPPROTO_ICMP &&
 	      ctinfo == IP_CT_IS_REPLY + IP_CT_ESTABLISHED) ||
 	     (iph->protocol == IPPROTO_ICMP &&
diff --git a/net/netfilter/xt_state.c b/net/netfilter/xt_state.c
index e12e053..a507922 100644
--- a/net/netfilter/xt_state.c
+++ b/net/netfilter/xt_state.c
@@ -26,14 +26,16 @@ state_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	const struct xt_state_info *sinfo = par->matchinfo;
 	enum ip_conntrack_info ctinfo;
 	unsigned int statebit;
+	struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
 
-	if (nf_ct_is_untracked(skb))
-		statebit = XT_STATE_UNTRACKED;
-	else if (!nf_ct_get(skb, &ctinfo))
+	if (!ct)
 		statebit = XT_STATE_INVALID;
-	else
-		statebit = XT_STATE_BIT(ctinfo);
-
+	else {
+		if (nf_ct_is_untracked(ct))
+			statebit = XT_STATE_UNTRACKED;
+		else
+			statebit = XT_STATE_BIT(ctinfo);
+	}
 	return (sinfo->statemask & statebit);
 }
 
-- 
1.7.0.4


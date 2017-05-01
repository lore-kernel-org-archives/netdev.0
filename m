From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 23/53] netfilter: kill the fake untracked conntrack objects
Date: Mon,  1 May 2017 12:46:50 +0200
Message-ID: <1493635640-24325-24-git-send-email-pablo@netfilter.org>
References: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:49702 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S378882AbdEAKsF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 1 May 2017 06:48:05 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id A45BD209921
        for <netdev@vger.kernel.org>; Mon,  1 May 2017 12:47:48 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 92395FF2D1
        for <netdev@vger.kernel.org>; Mon,  1 May 2017 12:47:48 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 10D16DA90B
        for <netdev@vger.kernel.org>; Mon,  1 May 2017 12:47:46 +0200 (CEST)
In-Reply-To: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

resurrect an old patch from Pablo Neira to remove the untracked objects.

Currently, there are four possible states of an skb wrt. conntrack.

1. No conntrack attached, ct is NULL.
2. Normal (kmem cache allocated) ct attached.
3. a template (kmalloc'd), not in any hash tables at any point in time
4. the 'untracked' conntrack, a percpu nf_conn object, tagged via
   IPS_UNTRACKED_BIT in ct->status.

Untracked is supposed to be identical to case 1.  It exists only
so users can check

-m conntrack --ctstate UNTRACKED vs.
-m conntrack --ctstate INVALID

e.g. attempts to set connmark on INVALID or UNTRACKED conntracks is
supposed to be a no-op.

Thus currently we need to check
 ct == NULL || nf_ct_is_untracked(ct)

in a lot of places in order to avoid altering untracked objects.

The other consequence of the percpu untracked object is that all
-j NOTRACK (and, later, kfree_skb of such skbs) result in an atomic op
(inc/dec the untracked conntracks refcount).

This adds a new kernel-private ctinfo state, IP_CT_UNTRACKED, to
make the distinction instead.

The (few) places that care about packet invalid (ct is NULL) vs.
packet untracked now need to test ct == NULL vs. ctinfo == IP_CT_UNTRACKED,
but all other places can omit the nf_ct_is_untracked() check.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/ip_vs.h                                |  6 +--
 include/net/netfilter/nf_conntrack.h               | 10 +----
 include/uapi/linux/netfilter/nf_conntrack_common.h |  6 ++-
 net/ipv4/netfilter/nf_dup_ipv4.c                   |  3 +-
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c     |  3 +-
 net/ipv6/netfilter/nf_dup_ipv6.c                   |  3 +-
 net/netfilter/nf_conntrack_core.c                  | 48 +++-------------------
 net/netfilter/nf_nat_core.c                        |  3 --
 net/netfilter/nft_ct.c                             | 14 +++----
 net/netfilter/xt_CT.c                              | 16 ++++----
 net/netfilter/xt_conntrack.c                       | 11 +++--
 net/netfilter/xt_state.c                           | 13 +++---
 12 files changed, 39 insertions(+), 97 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 8a4a57b887fb..9a75d9933e63 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1556,12 +1556,8 @@ static inline void ip_vs_notrack(struct sk_buff *skb)
 	struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
 
 	if (!ct || !nf_ct_is_untracked(ct)) {
-		struct nf_conn *untracked;
-
 		nf_conntrack_put(&ct->ct_general);
-		untracked = nf_ct_untracked_get();
-		nf_conntrack_get(&untracked->ct_general);
-		nf_ct_set(skb, untracked, IP_CT_NEW);
+		nf_ct_set(skb, NULL, IP_CT_UNTRACKED);
 	}
 #endif
 }
diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index 19605878da47..012b99f563e5 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -243,14 +243,6 @@ extern s32 (*nf_ct_nat_offset)(const struct nf_conn *ct,
 			       enum ip_conntrack_dir dir,
 			       u32 seq);
 
-/* Fake conntrack entry for untracked connections */
-DECLARE_PER_CPU_ALIGNED(struct nf_conn, nf_conntrack_untracked);
-static inline struct nf_conn *nf_ct_untracked_get(void)
-{
-	return raw_cpu_ptr(&nf_conntrack_untracked);
-}
-void nf_ct_untracked_status_or(unsigned long bits);
-
 /* Iterate over all conntracks: if iter returns true, it's deleted. */
 void nf_ct_iterate_cleanup(struct net *net,
 			   int (*iter)(struct nf_conn *i, void *data),
@@ -283,7 +275,7 @@ static inline int nf_ct_is_dying(const struct nf_conn *ct)
 
 static inline int nf_ct_is_untracked(const struct nf_conn *ct)
 {
-	return test_bit(IPS_UNTRACKED_BIT, &ct->status);
+	return false;
 }
 
 /* Packet is received from loopback */
diff --git a/include/uapi/linux/netfilter/nf_conntrack_common.h b/include/uapi/linux/netfilter/nf_conntrack_common.h
index 6a8e33dd4ecb..b4a0a1940118 100644
--- a/include/uapi/linux/netfilter/nf_conntrack_common.h
+++ b/include/uapi/linux/netfilter/nf_conntrack_common.h
@@ -28,12 +28,14 @@ enum ip_conntrack_info {
 	/* only for userspace compatibility */
 #ifndef __KERNEL__
 	IP_CT_NEW_REPLY = IP_CT_NUMBER,
+#else
+	IP_CT_UNTRACKED = 7,
 #endif
 };
 
 #define NF_CT_STATE_INVALID_BIT			(1 << 0)
 #define NF_CT_STATE_BIT(ctinfo)			(1 << ((ctinfo) % IP_CT_IS_REPLY + 1))
-#define NF_CT_STATE_UNTRACKED_BIT		(1 << (IP_CT_NUMBER + 1))
+#define NF_CT_STATE_UNTRACKED_BIT		(1 << (IP_CT_UNTRACKED + 1))
 
 /* Bitset representing status of connection. */
 enum ip_conntrack_status {
@@ -94,7 +96,7 @@ enum ip_conntrack_status {
 	IPS_TEMPLATE_BIT = 11,
 	IPS_TEMPLATE = (1 << IPS_TEMPLATE_BIT),
 
-	/* Conntrack is a fake untracked entry */
+	/* Conntrack is a fake untracked entry.  Obsolete and not used anymore */
 	IPS_UNTRACKED_BIT = 12,
 	IPS_UNTRACKED = (1 << IPS_UNTRACKED_BIT),
 
diff --git a/net/ipv4/netfilter/nf_dup_ipv4.c b/net/ipv4/netfilter/nf_dup_ipv4.c
index f0dbff05fc28..39895b9ddeb9 100644
--- a/net/ipv4/netfilter/nf_dup_ipv4.c
+++ b/net/ipv4/netfilter/nf_dup_ipv4.c
@@ -69,8 +69,7 @@ void nf_dup_ipv4(struct net *net, struct sk_buff *skb, unsigned int hooknum,
 #if IS_ENABLED(CONFIG_NF_CONNTRACK)
 	/* Avoid counting cloned packets towards the original connection. */
 	nf_reset(skb);
-	nf_ct_set(skb, nf_ct_untracked_get(), IP_CT_NEW);
-	nf_conntrack_get(skb_nfct(skb));
+	nf_ct_set(skb, NULL, IP_CT_UNTRACKED);
 #endif
 	/*
 	 * If we are in PREROUTING/INPUT, decrease the TTL to mitigate potential
diff --git a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
index d2c2ccbfbe72..d5f028e33f65 100644
--- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -221,8 +221,7 @@ icmpv6_error(struct net *net, struct nf_conn *tmpl,
 	type = icmp6h->icmp6_type - 130;
 	if (type >= 0 && type < sizeof(noct_valid_new) &&
 	    noct_valid_new[type]) {
-		nf_ct_set(skb, nf_ct_untracked_get(), IP_CT_NEW);
-		nf_conntrack_get(skb_nfct(skb));
+		nf_ct_set(skb, NULL, IP_CT_UNTRACKED);
 		return NF_ACCEPT;
 	}
 
diff --git a/net/ipv6/netfilter/nf_dup_ipv6.c b/net/ipv6/netfilter/nf_dup_ipv6.c
index 888ecd106e5f..4a7ddeddbaab 100644
--- a/net/ipv6/netfilter/nf_dup_ipv6.c
+++ b/net/ipv6/netfilter/nf_dup_ipv6.c
@@ -58,8 +58,7 @@ void nf_dup_ipv6(struct net *net, struct sk_buff *skb, unsigned int hooknum,
 
 #if IS_ENABLED(CONFIG_NF_CONNTRACK)
 	nf_reset(skb);
-	nf_ct_set(skb, nf_ct_untracked_get(), IP_CT_NEW);
-	nf_conntrack_get(skb_nfct(skb));
+	nf_ct_set(skb, NULL, IP_CT_UNTRACKED);
 #endif
 	if (hooknum == NF_INET_PRE_ROUTING ||
 	    hooknum == NF_INET_LOCAL_IN) {
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index bcf1d2a6539e..03150f60714d 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -180,14 +180,6 @@ EXPORT_SYMBOL_GPL(nf_conntrack_htable_size);
 
 unsigned int nf_conntrack_max __read_mostly;
 seqcount_t nf_conntrack_generation __read_mostly;
-
-/* nf_conn must be 8 bytes aligned, as the 3 LSB bits are used
- * for the nfctinfo. We cheat by (ab)using the PER CPU cache line
- * alignment to enforce this.
- */
-DEFINE_PER_CPU_ALIGNED(struct nf_conn, nf_conntrack_untracked);
-EXPORT_PER_CPU_SYMBOL(nf_conntrack_untracked);
-
 static unsigned int nf_conntrack_hash_rnd __read_mostly;
 
 static u32 hash_conntrack_raw(const struct nf_conntrack_tuple *tuple,
@@ -1314,9 +1306,10 @@ nf_conntrack_in(struct net *net, u_int8_t pf, unsigned int hooknum,
 	int ret;
 
 	tmpl = nf_ct_get(skb, &ctinfo);
-	if (tmpl) {
+	if (tmpl || ctinfo == IP_CT_UNTRACKED) {
 		/* Previously seen (loopback or untracked)?  Ignore. */
-		if (!nf_ct_is_template(tmpl)) {
+		if ((tmpl && !nf_ct_is_template(tmpl)) ||
+		     ctinfo == IP_CT_UNTRACKED) {
 			NF_CT_STAT_INC_ATOMIC(net, ignore);
 			return NF_ACCEPT;
 		}
@@ -1629,18 +1622,6 @@ void nf_ct_free_hashtable(void *hash, unsigned int size)
 }
 EXPORT_SYMBOL_GPL(nf_ct_free_hashtable);
 
-static int untrack_refs(void)
-{
-	int cnt = 0, cpu;
-
-	for_each_possible_cpu(cpu) {
-		struct nf_conn *ct = &per_cpu(nf_conntrack_untracked, cpu);
-
-		cnt += atomic_read(&ct->ct_general.use) - 1;
-	}
-	return cnt;
-}
-
 void nf_conntrack_cleanup_start(void)
 {
 	conntrack_gc_work.exiting = true;
@@ -1650,8 +1631,6 @@ void nf_conntrack_cleanup_start(void)
 void nf_conntrack_cleanup_end(void)
 {
 	RCU_INIT_POINTER(nf_ct_destroy, NULL);
-	while (untrack_refs() > 0)
-		schedule();
 
 	cancel_delayed_work_sync(&conntrack_gc_work.dwork);
 	nf_ct_free_hashtable(nf_conntrack_hash, nf_conntrack_htable_size);
@@ -1825,20 +1804,11 @@ EXPORT_SYMBOL_GPL(nf_conntrack_set_hashsize);
 module_param_call(hashsize, nf_conntrack_set_hashsize, param_get_uint,
 		  &nf_conntrack_htable_size, 0600);
 
-void nf_ct_untracked_status_or(unsigned long bits)
-{
-	int cpu;
-
-	for_each_possible_cpu(cpu)
-		per_cpu(nf_conntrack_untracked, cpu).status |= bits;
-}
-EXPORT_SYMBOL_GPL(nf_ct_untracked_status_or);
-
 int nf_conntrack_init_start(void)
 {
 	int max_factor = 8;
 	int ret = -ENOMEM;
-	int i, cpu;
+	int i;
 
 	seqcount_init(&nf_conntrack_generation);
 
@@ -1921,15 +1891,6 @@ int nf_conntrack_init_start(void)
 	if (ret < 0)
 		goto err_proto;
 
-	/* Set up fake conntrack: to never be deleted, not in any hashes */
-	for_each_possible_cpu(cpu) {
-		struct nf_conn *ct = &per_cpu(nf_conntrack_untracked, cpu);
-		write_pnet(&ct->ct_net, &init_net);
-		atomic_set(&ct->ct_general.use, 1);
-	}
-	/*  - and look it like as a confirmed connection */
-	nf_ct_untracked_status_or(IPS_CONFIRMED | IPS_UNTRACKED);
-
 	conntrack_gc_work_init(&conntrack_gc_work);
 	queue_delayed_work(system_long_wq, &conntrack_gc_work.dwork, HZ);
 
@@ -1977,6 +1938,7 @@ int nf_conntrack_init_net(struct net *net)
 	int ret = -ENOMEM;
 	int cpu;
 
+	BUILD_BUG_ON(IP_CT_UNTRACKED == IP_CT_NUMBER);
 	atomic_set(&net->ct.count, 0);
 
 	net->ct.pcpu_lists = alloc_percpu(struct ct_pcpu);
diff --git a/net/netfilter/nf_nat_core.c b/net/netfilter/nf_nat_core.c
index 5e35643da650..9cbf49f9c1b7 100644
--- a/net/netfilter/nf_nat_core.c
+++ b/net/netfilter/nf_nat_core.c
@@ -861,9 +861,6 @@ static int __init nf_nat_init(void)
 
 	nf_ct_helper_expectfn_register(&follow_master_nat);
 
-	/* Initialize fake conntrack so that NAT will skip it */
-	nf_ct_untracked_status_or(IPS_NAT_DONE_MASK);
-
 	BUG_ON(nfnetlink_parse_nat_setup_hook != NULL);
 	RCU_INIT_POINTER(nfnetlink_parse_nat_setup_hook,
 			   nfnetlink_parse_nat_setup);
diff --git a/net/netfilter/nft_ct.c b/net/netfilter/nft_ct.c
index 6e23dbbedd7f..6c6fd48b024c 100644
--- a/net/netfilter/nft_ct.c
+++ b/net/netfilter/nft_ct.c
@@ -72,12 +72,12 @@ static void nft_ct_get_eval(const struct nft_expr *expr,
 
 	switch (priv->key) {
 	case NFT_CT_STATE:
-		if (ct == NULL)
-			state = NF_CT_STATE_INVALID_BIT;
-		else if (nf_ct_is_untracked(ct))
+		if (ct)
+			state = NF_CT_STATE_BIT(ctinfo);
+		else if (ctinfo == IP_CT_UNTRACKED)
 			state = NF_CT_STATE_UNTRACKED_BIT;
 		else
-			state = NF_CT_STATE_BIT(ctinfo);
+			state = NF_CT_STATE_INVALID_BIT;
 		*dest = state;
 		return;
 	default:
@@ -718,12 +718,10 @@ static void nft_notrack_eval(const struct nft_expr *expr,
 
 	ct = nf_ct_get(pkt->skb, &ctinfo);
 	/* Previously seen (loopback or untracked)?  Ignore. */
-	if (ct)
+	if (ct || ctinfo == IP_CT_UNTRACKED)
 		return;
 
-	ct = nf_ct_untracked_get();
-	atomic_inc(&ct->ct_general.use);
-	nf_ct_set(skb, ct, IP_CT_NEW);
+	nf_ct_set(skb, ct, IP_CT_UNTRACKED);
 }
 
 static struct nft_expr_type nft_notrack_type;
diff --git a/net/netfilter/xt_CT.c b/net/netfilter/xt_CT.c
index b008db0184b8..3cbe1bcf6a74 100644
--- a/net/netfilter/xt_CT.c
+++ b/net/netfilter/xt_CT.c
@@ -26,11 +26,12 @@ static inline int xt_ct_target(struct sk_buff *skb, struct nf_conn *ct)
 	if (skb->_nfct != 0)
 		return XT_CONTINUE;
 
-	/* special case the untracked ct : we want the percpu object */
-	if (!ct)
-		ct = nf_ct_untracked_get();
-	atomic_inc(&ct->ct_general.use);
-	nf_ct_set(skb, ct, IP_CT_NEW);
+	if (ct) {
+		atomic_inc(&ct->ct_general.use);
+		nf_ct_set(skb, ct, IP_CT_NEW);
+	} else {
+		nf_ct_set(skb, ct, IP_CT_UNTRACKED);
+	}
 
 	return XT_CONTINUE;
 }
@@ -335,7 +336,7 @@ static void xt_ct_tg_destroy(const struct xt_tgdtor_param *par,
 	struct nf_conn *ct = info->ct;
 	struct nf_conn_help *help;
 
-	if (ct && !nf_ct_is_untracked(ct)) {
+	if (ct) {
 		help = nfct_help(ct);
 		if (help)
 			module_put(help->helper->me);
@@ -412,8 +413,7 @@ notrack_tg(struct sk_buff *skb, const struct xt_action_param *par)
 	if (skb->_nfct != 0)
 		return XT_CONTINUE;
 
-	nf_ct_set(skb, nf_ct_untracked_get(), IP_CT_NEW);
-	nf_conntrack_get(skb_nfct(skb));
+	nf_ct_set(skb, NULL, IP_CT_UNTRACKED);
 
 	return XT_CONTINUE;
 }
diff --git a/net/netfilter/xt_conntrack.c b/net/netfilter/xt_conntrack.c
index c0fb217bc649..39cf1d019240 100644
--- a/net/netfilter/xt_conntrack.c
+++ b/net/netfilter/xt_conntrack.c
@@ -172,12 +172,11 @@ conntrack_mt(const struct sk_buff *skb, struct xt_action_param *par,
 
 	ct = nf_ct_get(skb, &ctinfo);
 
-	if (ct) {
-		if (nf_ct_is_untracked(ct))
-			statebit = XT_CONNTRACK_STATE_UNTRACKED;
-		else
-			statebit = XT_CONNTRACK_STATE_BIT(ctinfo);
-	} else
+	if (ct)
+		statebit = XT_CONNTRACK_STATE_BIT(ctinfo);
+	else if (ctinfo == IP_CT_UNTRACKED)
+		statebit = XT_CONNTRACK_STATE_UNTRACKED;
+	else
 		statebit = XT_CONNTRACK_STATE_INVALID;
 
 	if (info->match_flags & XT_CONNTRACK_STATE) {
diff --git a/net/netfilter/xt_state.c b/net/netfilter/xt_state.c
index 5746a33789a5..5fbd79194d21 100644
--- a/net/netfilter/xt_state.c
+++ b/net/netfilter/xt_state.c
@@ -28,14 +28,13 @@ state_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	unsigned int statebit;
 	struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
 
-	if (!ct)
+	if (ct)
+		statebit = XT_STATE_BIT(ctinfo);
+	else if (ctinfo == IP_CT_UNTRACKED)
+		statebit = XT_STATE_UNTRACKED;
+	else
 		statebit = XT_STATE_INVALID;
-	else {
-		if (nf_ct_is_untracked(ct))
-			statebit = XT_STATE_UNTRACKED;
-		else
-			statebit = XT_STATE_BIT(ctinfo);
-	}
+
 	return (sinfo->statemask & statebit);
 }
 
-- 
2.1.4

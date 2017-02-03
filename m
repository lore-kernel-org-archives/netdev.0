From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 22/27] skbuff: add and use skb_nfct helper
Date: Fri,  3 Feb 2017 13:25:33 +0100
Message-ID: <1486124738-3013-23-git-send-email-pablo@netfilter.org>
References: <1486124738-3013-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1486124738-3013-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

Followup patch renames skb->nfct and changes its type so add a helper to
avoid intrusive rename change later.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/skbuff.h                         | 13 ++++++++++---
 include/net/netfilter/nf_conntrack_core.h      |  2 +-
 net/core/skbuff.c                              |  2 +-
 net/ipv4/netfilter/ipt_SYNPROXY.c              |  8 ++++----
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c   |  2 +-
 net/ipv4/netfilter/nf_defrag_ipv4.c            |  4 ++--
 net/ipv4/netfilter/nf_dup_ipv4.c               |  2 +-
 net/ipv6/netfilter/ip6t_SYNPROXY.c             |  8 ++++----
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |  4 ++--
 net/ipv6/netfilter/nf_defrag_ipv6_hooks.c      |  4 ++--
 net/netfilter/nf_conntrack_core.c              |  4 ++--
 net/netfilter/nf_nat_helper.c                  |  2 +-
 net/netfilter/xt_CT.c                          |  2 +-
 net/openvswitch/conntrack.c                    |  6 +++---
 net/sched/cls_flow.c                           |  2 +-
 15 files changed, 36 insertions(+), 29 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index b53c0cfd417e..276431e047af 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -3553,6 +3553,15 @@ static inline void skb_remcsum_process(struct sk_buff *skb, void *ptr,
 	skb->csum = csum_add(skb->csum, delta);
 }
 
+static inline struct nf_conntrack *skb_nfct(const struct sk_buff *skb)
+{
+#if IS_ENABLED(CONFIG_NF_CONNTRACK)
+	return skb->nfct;
+#else
+	return NULL;
+#endif
+}
+
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
 void nf_conntrack_destroy(struct nf_conntrack *nfct);
 static inline void nf_conntrack_put(struct nf_conntrack *nfct)
@@ -3652,9 +3661,7 @@ static inline bool skb_irq_freeable(const struct sk_buff *skb)
 #if IS_ENABLED(CONFIG_XFRM)
 		!skb->sp &&
 #endif
-#if IS_ENABLED(CONFIG_NF_CONNTRACK)
-		!skb->nfct &&
-#endif
+		!skb_nfct(skb) &&
 		!skb->_skb_refdst &&
 		!skb_has_frag_list(skb);
 }
diff --git a/include/net/netfilter/nf_conntrack_core.h b/include/net/netfilter/nf_conntrack_core.h
index 62e17d1319ff..84ec7ca5f195 100644
--- a/include/net/netfilter/nf_conntrack_core.h
+++ b/include/net/netfilter/nf_conntrack_core.h
@@ -62,7 +62,7 @@ int __nf_conntrack_confirm(struct sk_buff *skb);
 /* Confirm a connection: returns NF_DROP if packet must be dropped. */
 static inline int nf_conntrack_confirm(struct sk_buff *skb)
 {
-	struct nf_conn *ct = (struct nf_conn *)skb->nfct;
+	struct nf_conn *ct = (struct nf_conn *)skb_nfct(skb);
 	int ret = NF_ACCEPT;
 
 	if (ct && !nf_ct_is_untracked(ct)) {
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 5a03730fbc1a..cac3ebfb4b45 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -655,7 +655,7 @@ static void skb_release_head_state(struct sk_buff *skb)
 		skb->destructor(skb);
 	}
 #if IS_ENABLED(CONFIG_NF_CONNTRACK)
-	nf_conntrack_put(skb->nfct);
+	nf_conntrack_put(skb_nfct(skb));
 #endif
 #if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 	nf_bridge_put(skb->nf_bridge);
diff --git a/net/ipv4/netfilter/ipt_SYNPROXY.c b/net/ipv4/netfilter/ipt_SYNPROXY.c
index 30c0de53e254..a12d4f0aa674 100644
--- a/net/ipv4/netfilter/ipt_SYNPROXY.c
+++ b/net/ipv4/netfilter/ipt_SYNPROXY.c
@@ -107,8 +107,8 @@ synproxy_send_client_synack(struct net *net,
 
 	synproxy_build_options(nth, opts);
 
-	synproxy_send_tcp(net, skb, nskb, skb->nfct, IP_CT_ESTABLISHED_REPLY,
-			  niph, nth, tcp_hdr_size);
+	synproxy_send_tcp(net, skb, nskb, skb_nfct(skb),
+			  IP_CT_ESTABLISHED_REPLY, niph, nth, tcp_hdr_size);
 }
 
 static void
@@ -230,8 +230,8 @@ synproxy_send_client_ack(struct net *net,
 
 	synproxy_build_options(nth, opts);
 
-	synproxy_send_tcp(net, skb, nskb, skb->nfct, IP_CT_ESTABLISHED_REPLY,
-			  niph, nth, tcp_hdr_size);
+	synproxy_send_tcp(net, skb, nskb, skb_nfct(skb),
+			  IP_CT_ESTABLISHED_REPLY, niph, nth, tcp_hdr_size);
 }
 
 static bool
diff --git a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
index 566afac98a88..478a025909fc 100644
--- a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
+++ b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
@@ -137,7 +137,7 @@ icmp_error_message(struct net *net, struct nf_conn *tmpl, struct sk_buff *skb,
 	enum ip_conntrack_info ctinfo;
 	struct nf_conntrack_zone tmp;
 
-	NF_CT_ASSERT(skb->nfct == NULL);
+	NF_CT_ASSERT(!skb_nfct(skb));
 	zone = nf_ct_zone_tmpl(tmpl, skb, &tmp);
 
 	/* Are they talking about one of our connections? */
diff --git a/net/ipv4/netfilter/nf_defrag_ipv4.c b/net/ipv4/netfilter/nf_defrag_ipv4.c
index 49bd6a54404f..346bf7ccac08 100644
--- a/net/ipv4/netfilter/nf_defrag_ipv4.c
+++ b/net/ipv4/netfilter/nf_defrag_ipv4.c
@@ -45,7 +45,7 @@ static enum ip_defrag_users nf_ct_defrag_user(unsigned int hooknum,
 {
 	u16 zone_id = NF_CT_DEFAULT_ZONE_ID;
 #if IS_ENABLED(CONFIG_NF_CONNTRACK)
-	if (skb->nfct) {
+	if (skb_nfct(skb)) {
 		enum ip_conntrack_info ctinfo;
 		const struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
 
@@ -75,7 +75,7 @@ static unsigned int ipv4_conntrack_defrag(void *priv,
 #if !IS_ENABLED(CONFIG_NF_NAT)
 	/* Previously seen (loopback)?  Ignore.  Do this before
 	   fragment check. */
-	if (skb->nfct && !nf_ct_is_template((struct nf_conn *)skb->nfct))
+	if (skb_nfct(skb) && !nf_ct_is_template((struct nf_conn *)skb_nfct(skb)))
 		return NF_ACCEPT;
 #endif
 #endif
diff --git a/net/ipv4/netfilter/nf_dup_ipv4.c b/net/ipv4/netfilter/nf_dup_ipv4.c
index a981ef7151ca..1a5e1f53ceaa 100644
--- a/net/ipv4/netfilter/nf_dup_ipv4.c
+++ b/net/ipv4/netfilter/nf_dup_ipv4.c
@@ -71,7 +71,7 @@ void nf_dup_ipv4(struct net *net, struct sk_buff *skb, unsigned int hooknum,
 	nf_reset(skb);
 	skb->nfct     = &nf_ct_untracked_get()->ct_general;
 	skb->nfctinfo = IP_CT_NEW;
-	nf_conntrack_get(skb->nfct);
+	nf_conntrack_get(skb_nfct(skb));
 #endif
 	/*
 	 * If we are in PREROUTING/INPUT, decrease the TTL to mitigate potential
diff --git a/net/ipv6/netfilter/ip6t_SYNPROXY.c b/net/ipv6/netfilter/ip6t_SYNPROXY.c
index 98c8dd38575a..2dc01d2c6ec0 100644
--- a/net/ipv6/netfilter/ip6t_SYNPROXY.c
+++ b/net/ipv6/netfilter/ip6t_SYNPROXY.c
@@ -121,8 +121,8 @@ synproxy_send_client_synack(struct net *net,
 
 	synproxy_build_options(nth, opts);
 
-	synproxy_send_tcp(net, skb, nskb, skb->nfct, IP_CT_ESTABLISHED_REPLY,
-			  niph, nth, tcp_hdr_size);
+	synproxy_send_tcp(net, skb, nskb, skb_nfct(skb),
+			  IP_CT_ESTABLISHED_REPLY, niph, nth, tcp_hdr_size);
 }
 
 static void
@@ -244,8 +244,8 @@ synproxy_send_client_ack(struct net *net,
 
 	synproxy_build_options(nth, opts);
 
-	synproxy_send_tcp(net, skb, nskb, skb->nfct, IP_CT_ESTABLISHED_REPLY,
-			  niph, nth, tcp_hdr_size);
+	synproxy_send_tcp(net, skb, nskb, skb_nfct(skb),
+			  IP_CT_ESTABLISHED_REPLY, niph, nth, tcp_hdr_size);
 }
 
 static bool
diff --git a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
index 44b9af3f813e..09f1661a4e88 100644
--- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -153,7 +153,7 @@ icmpv6_error_message(struct net *net, struct nf_conn *tmpl,
 	enum ip_conntrack_info ctinfo;
 	struct nf_conntrack_zone tmp;
 
-	NF_CT_ASSERT(skb->nfct == NULL);
+	NF_CT_ASSERT(!skb_nfct(skb));
 
 	/* Are they talking about one of our connections? */
 	if (!nf_ct_get_tuplepr(skb,
@@ -224,7 +224,7 @@ icmpv6_error(struct net *net, struct nf_conn *tmpl,
 	    noct_valid_new[type]) {
 		skb->nfct = &nf_ct_untracked_get()->ct_general;
 		skb->nfctinfo = IP_CT_NEW;
-		nf_conntrack_get(skb->nfct);
+		nf_conntrack_get(skb_nfct(skb));
 		return NF_ACCEPT;
 	}
 
diff --git a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
index 8e0bdd058787..ada60d1a991b 100644
--- a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
+++ b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
@@ -37,7 +37,7 @@ static enum ip6_defrag_users nf_ct6_defrag_user(unsigned int hooknum,
 {
 	u16 zone_id = NF_CT_DEFAULT_ZONE_ID;
 #if IS_ENABLED(CONFIG_NF_CONNTRACK)
-	if (skb->nfct) {
+	if (skb_nfct(skb)) {
 		enum ip_conntrack_info ctinfo;
 		const struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
 
@@ -61,7 +61,7 @@ static unsigned int ipv6_defrag(void *priv,
 
 #if IS_ENABLED(CONFIG_NF_CONNTRACK)
 	/* Previously seen (loopback)?	*/
-	if (skb->nfct && !nf_ct_is_template((struct nf_conn *)skb->nfct))
+	if (skb_nfct(skb) && !nf_ct_is_template((struct nf_conn *)skb_nfct(skb)))
 		return NF_ACCEPT;
 #endif
 
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index adb7af3a4c4c..78aebf0ee6e3 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1357,7 +1357,7 @@ nf_conntrack_in(struct net *net, u_int8_t pf, unsigned int hooknum,
 		goto out;
 	}
 
-	NF_CT_ASSERT(skb->nfct);
+	NF_CT_ASSERT(skb_nfct(skb));
 
 	/* Decide what timeout policy we want to apply to this flow. */
 	timeouts = nf_ct_timeout_lookup(net, ct, l4proto);
@@ -1528,7 +1528,7 @@ static void nf_conntrack_attach(struct sk_buff *nskb, const struct sk_buff *skb)
 	/* Attach to new skbuff, and increment count */
 	nskb->nfct = &ct->ct_general;
 	nskb->nfctinfo = ctinfo;
-	nf_conntrack_get(nskb->nfct);
+	nf_conntrack_get(skb_nfct(nskb));
 }
 
 /* Bring out ya dead! */
diff --git a/net/netfilter/nf_nat_helper.c b/net/netfilter/nf_nat_helper.c
index 2840abb5bb99..211661cb2c90 100644
--- a/net/netfilter/nf_nat_helper.c
+++ b/net/netfilter/nf_nat_helper.c
@@ -60,7 +60,7 @@ static void mangle_contents(struct sk_buff *skb,
 		__skb_trim(skb, skb->len + rep_len - match_len);
 	}
 
-	if (nf_ct_l3num((struct nf_conn *)skb->nfct) == NFPROTO_IPV4) {
+	if (nf_ct_l3num((struct nf_conn *)skb_nfct(skb)) == NFPROTO_IPV4) {
 		/* fix IP hdr checksum information */
 		ip_hdr(skb)->tot_len = htons(skb->len);
 		ip_send_check(ip_hdr(skb));
diff --git a/net/netfilter/xt_CT.c b/net/netfilter/xt_CT.c
index 26b0bccfa0c5..cd7e29910ae1 100644
--- a/net/netfilter/xt_CT.c
+++ b/net/netfilter/xt_CT.c
@@ -415,7 +415,7 @@ notrack_tg(struct sk_buff *skb, const struct xt_action_param *par)
 
 	skb->nfct = &nf_ct_untracked_get()->ct_general;
 	skb->nfctinfo = IP_CT_NEW;
-	nf_conntrack_get(skb->nfct);
+	nf_conntrack_get(skb_nfct(skb));
 
 	return XT_CONTINUE;
 }
diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index 6b78bab27755..452557946147 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -721,8 +721,8 @@ static int __ovs_ct_lookup(struct net *net, struct sw_flow_key *key,
 
 		/* Associate skb with specified zone. */
 		if (tmpl) {
-			if (skb->nfct)
-				nf_conntrack_put(skb->nfct);
+			if (skb_nfct(skb))
+				nf_conntrack_put(skb_nfct(skb));
 			nf_conntrack_get(&tmpl->ct_general);
 			skb->nfct = &tmpl->ct_general;
 			skb->nfctinfo = IP_CT_NEW;
@@ -819,7 +819,7 @@ static int ovs_ct_lookup(struct net *net, struct sw_flow_key *key,
 		if (err)
 			return err;
 
-		ct = (struct nf_conn *)skb->nfct;
+		ct = (struct nf_conn *)skb_nfct(skb);
 		if (ct)
 			nf_ct_deliver_cached_events(ct);
 	}
diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index 6575aba87630..3d6b9286c203 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -129,7 +129,7 @@ static u32 flow_get_mark(const struct sk_buff *skb)
 static u32 flow_get_nfct(const struct sk_buff *skb)
 {
 #if IS_ENABLED(CONFIG_NF_CONNTRACK)
-	return addr_fold(skb->nfct);
+	return addr_fold(skb_nfct(skb));
 #else
 	return 0;
 #endif
-- 
2.1.4


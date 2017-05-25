From: David Ahern <dsahern@gmail.com>
Subject: [PATCH net-next 3/6] net: plumb extack arg down to lwtunnel build state
Date: Wed, 24 May 2017 21:54:39 -0600
Message-ID: <20170525035442.51407-4-dsahern@gmail.com>
References: <20170525035442.51407-1-dsahern@gmail.com>
Cc: roopa@cumulusnetworks.com, David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33682 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S941583AbdEYDyw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 23:54:52 -0400
Received: by mail-pf0-f193.google.com with SMTP id f27so36382146pfe.0
        for <netdev@vger.kernel.org>; Wed, 24 May 2017 20:54:52 -0700 (PDT)
In-Reply-To: <20170525035442.51407-1-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pass extack arg down to lwtunnel_build_state and the build_state callbacks.
Add messages for failures in lwtunnel_build_state, and add the extarg to
nla_parse where possible in the build_state callbacks.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 include/linux/netlink.h   | 10 ++++++++++
 include/net/lwtunnel.h    |  9 ++++++---
 net/core/lwt_bpf.c        |  5 +++--
 net/core/lwtunnel.c       | 20 +++++++++++++++++---
 net/ipv4/fib_lookup.h     |  3 ++-
 net/ipv4/fib_semantics.c  | 20 +++++++++++---------
 net/ipv4/fib_trie.c       |  2 +-
 net/ipv4/ip_tunnel_core.c | 11 +++++++----
 net/ipv6/ila/ila_lwt.c    |  5 +++--
 net/ipv6/route.c          |  2 +-
 net/ipv6/seg6_iptunnel.c  |  5 +++--
 net/mpls/mpls_iptunnel.c  |  5 +++--
 12 files changed, 67 insertions(+), 30 deletions(-)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index a68aad484c69..8664fd26eb5d 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -102,6 +102,16 @@ struct netlink_ext_ack {
 		(extack)->bad_attr = (attr);		\
 } while (0)
 
+#define NL_SET_ERR_MSG_ATTR(extack, attr, msg) do {	\
+	static const char __msg[] = (msg);		\
+	struct netlink_ext_ack *__extack = (extack);	\
+							\
+	if (__extack) {					\
+		__extack->_msg = __msg;			\
+		__extack->bad_attr = (attr);		\
+	}						\
+} while (0)
+
 extern void netlink_kernel_release(struct sock *sk);
 extern int __netlink_change_ngroups(struct sock *sk, unsigned int groups);
 extern int netlink_change_ngroups(struct sock *sk, unsigned int groups);
diff --git a/include/net/lwtunnel.h b/include/net/lwtunnel.h
index ca6f002774ef..7c26863b8cf4 100644
--- a/include/net/lwtunnel.h
+++ b/include/net/lwtunnel.h
@@ -35,7 +35,8 @@ struct lwtunnel_state {
 struct lwtunnel_encap_ops {
 	int (*build_state)(struct nlattr *encap,
 			   unsigned int family, const void *cfg,
-			   struct lwtunnel_state **ts);
+			   struct lwtunnel_state **ts,
+			   struct netlink_ext_ack *extack);
 	void (*destroy_state)(struct lwtunnel_state *lws);
 	int (*output)(struct net *net, struct sock *sk, struct sk_buff *skb);
 	int (*input)(struct sk_buff *skb);
@@ -114,7 +115,8 @@ int lwtunnel_valid_encap_type_attr(struct nlattr *attr, int len,
 int lwtunnel_build_state(u16 encap_type,
 			 struct nlattr *encap,
 			 unsigned int family, const void *cfg,
-			 struct lwtunnel_state **lws);
+			 struct lwtunnel_state **lws,
+			 struct netlink_ext_ack *extack);
 int lwtunnel_fill_encap(struct sk_buff *skb,
 			struct lwtunnel_state *lwtstate);
 int lwtunnel_get_encap_size(struct lwtunnel_state *lwtstate);
@@ -192,7 +194,8 @@ static inline int lwtunnel_valid_encap_type_attr(struct nlattr *attr, int len,
 static inline int lwtunnel_build_state(u16 encap_type,
 				       struct nlattr *encap,
 				       unsigned int family, const void *cfg,
-				       struct lwtunnel_state **lws)
+				       struct lwtunnel_state **lws,
+				       struct netlink_ext_ack *extack)
 {
 	return -EOPNOTSUPP;
 }
diff --git a/net/core/lwt_bpf.c b/net/core/lwt_bpf.c
index b3bc0a31af9f..1307731ddfe4 100644
--- a/net/core/lwt_bpf.c
+++ b/net/core/lwt_bpf.c
@@ -240,7 +240,8 @@ static const struct nla_policy bpf_nl_policy[LWT_BPF_MAX + 1] = {
 
 static int bpf_build_state(struct nlattr *nla,
 			   unsigned int family, const void *cfg,
-			   struct lwtunnel_state **ts)
+			   struct lwtunnel_state **ts,
+			   struct netlink_ext_ack *extack)
 {
 	struct nlattr *tb[LWT_BPF_MAX + 1];
 	struct lwtunnel_state *newts;
@@ -250,7 +251,7 @@ static int bpf_build_state(struct nlattr *nla,
 	if (family != AF_INET && family != AF_INET6)
 		return -EAFNOSUPPORT;
 
-	ret = nla_parse_nested(tb, LWT_BPF_MAX, nla, bpf_nl_policy, NULL);
+	ret = nla_parse_nested(tb, LWT_BPF_MAX, nla, bpf_nl_policy, extack);
 	if (ret < 0)
 		return ret;
 
diff --git a/net/core/lwtunnel.c b/net/core/lwtunnel.c
index ab840386a74d..a0feca1df7b5 100644
--- a/net/core/lwtunnel.c
+++ b/net/core/lwtunnel.c
@@ -103,25 +103,39 @@ EXPORT_SYMBOL(lwtunnel_encap_del_ops);
 
 int lwtunnel_build_state(u16 encap_type,
 			 struct nlattr *encap, unsigned int family,
-			 const void *cfg, struct lwtunnel_state **lws)
+			 const void *cfg, struct lwtunnel_state **lws,
+			 struct netlink_ext_ack *extack)
 {
 	const struct lwtunnel_encap_ops *ops;
+	bool found = false;
 	int ret = -EINVAL;
 
 	if (encap_type == LWTUNNEL_ENCAP_NONE ||
-	    encap_type > LWTUNNEL_ENCAP_MAX)
+	    encap_type > LWTUNNEL_ENCAP_MAX) {
+		NL_SET_BAD_ATTR(extack, encap);
+		NL_SET_ERR_MSG(extack, "Unknown LWT encapsulation type");
 		return ret;
+	}
 
 	ret = -EOPNOTSUPP;
 	rcu_read_lock();
 	ops = rcu_dereference(lwtun_encaps[encap_type]);
 	if (likely(ops && ops->build_state && try_module_get(ops->owner))) {
-		ret = ops->build_state(encap, family, cfg, lws);
+		found = true;
+		ret = ops->build_state(encap, family, cfg, lws, extack);
 		if (ret)
 			module_put(ops->owner);
 	}
 	rcu_read_unlock();
 
+	/* don't rely on -EOPNOTSUPP to detect match as build_state
+	 * handlers could return it
+	 */
+	if (!found) {
+		NL_SET_BAD_ATTR(extack, encap);
+		NL_SET_ERR_MSG(extack, "LWT encapsulation type not supported");
+	}
+
 	return ret;
 }
 EXPORT_SYMBOL(lwtunnel_build_state);
diff --git a/net/ipv4/fib_lookup.h b/net/ipv4/fib_lookup.h
index 2704e08545da..769ab87ebc4b 100644
--- a/net/ipv4/fib_lookup.h
+++ b/net/ipv4/fib_lookup.h
@@ -30,7 +30,8 @@ static inline void fib_alias_accessed(struct fib_alias *fa)
 void fib_release_info(struct fib_info *);
 struct fib_info *fib_create_info(struct fib_config *cfg,
 				 struct netlink_ext_ack *extack);
-int fib_nh_match(struct fib_config *cfg, struct fib_info *fi);
+int fib_nh_match(struct fib_config *cfg, struct fib_info *fi,
+		 struct netlink_ext_ack *extack);
 int fib_dump_info(struct sk_buff *skb, u32 pid, u32 seq, int event, u32 tb_id,
 		  u8 type, __be32 dst, int dst_len, u8 tos, struct fib_info *fi,
 		  unsigned int);
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 4852e183afe0..89e8fcc8449b 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -530,7 +530,7 @@ static int fib_get_nhs(struct fib_info *fi, struct rtnexthop *rtnh,
 				ret = lwtunnel_build_state(nla_get_u16(
 							   nla_entype),
 							   nla,  AF_INET, cfg,
-							   &lwtstate);
+							   &lwtstate, extack);
 				if (ret)
 					goto errout;
 				nexthop_nh->nh_lwtstate =
@@ -612,7 +612,8 @@ static inline void fib_add_weight(struct fib_info *fi,
 static int fib_encap_match(u16 encap_type,
 			   struct nlattr *encap,
 			   const struct fib_nh *nh,
-			   const struct fib_config *cfg)
+			   const struct fib_config *cfg,
+			   struct netlink_ext_ack *extack)
 {
 	struct lwtunnel_state *lwtstate;
 	int ret, result = 0;
@@ -620,8 +621,8 @@ static int fib_encap_match(u16 encap_type,
 	if (encap_type == LWTUNNEL_ENCAP_NONE)
 		return 0;
 
-	ret = lwtunnel_build_state(encap_type, encap,
-				   AF_INET, cfg, &lwtstate);
+	ret = lwtunnel_build_state(encap_type, encap, AF_INET,
+				   cfg, &lwtstate, extack);
 	if (!ret) {
 		result = lwtunnel_cmp_encap(lwtstate, nh->nh_lwtstate);
 		lwtstate_free(lwtstate);
@@ -630,7 +631,8 @@ static int fib_encap_match(u16 encap_type,
 	return result;
 }
 
-int fib_nh_match(struct fib_config *cfg, struct fib_info *fi)
+int fib_nh_match(struct fib_config *cfg, struct fib_info *fi,
+		 struct netlink_ext_ack *extack)
 {
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 	struct rtnexthop *rtnh;
@@ -642,9 +644,9 @@ int fib_nh_match(struct fib_config *cfg, struct fib_info *fi)
 
 	if (cfg->fc_oif || cfg->fc_gw) {
 		if (cfg->fc_encap) {
-			if (fib_encap_match(cfg->fc_encap_type,
-					    cfg->fc_encap, fi->fib_nh, cfg))
-			    return 1;
+			if (fib_encap_match(cfg->fc_encap_type, cfg->fc_encap,
+					    fi->fib_nh, cfg, extack))
+				return 1;
 		}
 		if ((!cfg->fc_oif || cfg->fc_oif == fi->fib_nh->nh_oif) &&
 		    (!cfg->fc_gw  || cfg->fc_gw == fi->fib_nh->nh_gw))
@@ -1145,7 +1147,7 @@ struct fib_info *fib_create_info(struct fib_config *cfg,
 			}
 			err = lwtunnel_build_state(cfg->fc_encap_type,
 						   cfg->fc_encap, AF_INET, cfg,
-						   &lwtstate);
+						   &lwtstate, extack);
 			if (err)
 				goto failure;
 
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 015ff759b0fd..03800e39e924 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1561,7 +1561,7 @@ int fib_table_delete(struct net *net, struct fib_table *tb,
 		     fi->fib_prefsrc == cfg->fc_prefsrc) &&
 		    (!cfg->fc_protocol ||
 		     fi->fib_protocol == cfg->fc_protocol) &&
-		    fib_nh_match(cfg, fi) == 0) {
+		    fib_nh_match(cfg, fi, extack) == 0) {
 			fa_to_delete = fa;
 			break;
 		}
diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index baf196eaf1d8..90e11479c725 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -228,14 +228,16 @@ static const struct nla_policy ip_tun_policy[LWTUNNEL_IP_MAX + 1] = {
 
 static int ip_tun_build_state(struct nlattr *attr,
 			      unsigned int family, const void *cfg,
-			      struct lwtunnel_state **ts)
+			      struct lwtunnel_state **ts,
+			      struct netlink_ext_ack *extack)
 {
 	struct ip_tunnel_info *tun_info;
 	struct lwtunnel_state *new_state;
 	struct nlattr *tb[LWTUNNEL_IP_MAX + 1];
 	int err;
 
-	err = nla_parse_nested(tb, LWTUNNEL_IP_MAX, attr, ip_tun_policy, NULL);
+	err = nla_parse_nested(tb, LWTUNNEL_IP_MAX, attr, ip_tun_policy,
+			       extack);
 	if (err < 0)
 		return err;
 
@@ -325,7 +327,8 @@ static const struct nla_policy ip6_tun_policy[LWTUNNEL_IP6_MAX + 1] = {
 
 static int ip6_tun_build_state(struct nlattr *attr,
 			       unsigned int family, const void *cfg,
-			       struct lwtunnel_state **ts)
+			       struct lwtunnel_state **ts,
+			       struct netlink_ext_ack *extack)
 {
 	struct ip_tunnel_info *tun_info;
 	struct lwtunnel_state *new_state;
@@ -333,7 +336,7 @@ static int ip6_tun_build_state(struct nlattr *attr,
 	int err;
 
 	err = nla_parse_nested(tb, LWTUNNEL_IP6_MAX, attr, ip6_tun_policy,
-			       NULL);
+			       extack);
 	if (err < 0)
 		return err;
 
diff --git a/net/ipv6/ila/ila_lwt.c b/net/ipv6/ila/ila_lwt.c
index f4a413aba423..0c02a09bc351 100644
--- a/net/ipv6/ila/ila_lwt.c
+++ b/net/ipv6/ila/ila_lwt.c
@@ -117,7 +117,8 @@ static const struct nla_policy ila_nl_policy[ILA_ATTR_MAX + 1] = {
 
 static int ila_build_state(struct nlattr *nla,
 			   unsigned int family, const void *cfg,
-			   struct lwtunnel_state **ts)
+			   struct lwtunnel_state **ts,
+			   struct netlink_ext_ack *extack)
 {
 	struct ila_lwt *ilwt;
 	struct ila_params *p;
@@ -146,7 +147,7 @@ static int ila_build_state(struct nlattr *nla,
 		return -EINVAL;
 	}
 
-	ret = nla_parse_nested(tb, ILA_ATTR_MAX, nla, ila_nl_policy, NULL);
+	ret = nla_parse_nested(tb, ILA_ATTR_MAX, nla, ila_nl_policy, extack);
 	if (ret < 0)
 		return ret;
 
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index afc76b24ee6b..0146116f8539 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1939,7 +1939,7 @@ static struct rt6_info *ip6_route_info_create(struct fib6_config *cfg,
 
 		err = lwtunnel_build_state(cfg->fc_encap_type,
 					   cfg->fc_encap, AF_INET6, cfg,
-					   &lwtstate);
+					   &lwtstate, extack);
 		if (err)
 			goto out;
 		rt->dst.lwtstate = lwtstate_get(lwtstate);
diff --git a/net/ipv6/seg6_iptunnel.c b/net/ipv6/seg6_iptunnel.c
index 6a495490d43e..264d772d3c7d 100644
--- a/net/ipv6/seg6_iptunnel.c
+++ b/net/ipv6/seg6_iptunnel.c
@@ -326,7 +326,8 @@ static int seg6_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 
 static int seg6_build_state(struct nlattr *nla,
 			    unsigned int family, const void *cfg,
-			    struct lwtunnel_state **ts)
+			    struct lwtunnel_state **ts,
+			    struct netlink_ext_ack *extack)
 {
 	struct nlattr *tb[SEG6_IPTUNNEL_MAX + 1];
 	struct seg6_iptunnel_encap *tuninfo;
@@ -336,7 +337,7 @@ static int seg6_build_state(struct nlattr *nla,
 	int err;
 
 	err = nla_parse_nested(tb, SEG6_IPTUNNEL_MAX, nla,
-			       seg6_iptunnel_policy, NULL);
+			       seg6_iptunnel_policy, extack);
 
 	if (err < 0)
 		return err;
diff --git a/net/mpls/mpls_iptunnel.c b/net/mpls/mpls_iptunnel.c
index 369c7a23c86c..15e1aa708e50 100644
--- a/net/mpls/mpls_iptunnel.c
+++ b/net/mpls/mpls_iptunnel.c
@@ -159,7 +159,8 @@ static int mpls_xmit(struct sk_buff *skb)
 
 static int mpls_build_state(struct nlattr *nla,
 			    unsigned int family, const void *cfg,
-			    struct lwtunnel_state **ts)
+			    struct lwtunnel_state **ts,
+			    struct netlink_ext_ack *extack)
 {
 	struct mpls_iptunnel_encap *tun_encap_info;
 	struct nlattr *tb[MPLS_IPTUNNEL_MAX + 1];
@@ -168,7 +169,7 @@ static int mpls_build_state(struct nlattr *nla,
 	int ret;
 
 	ret = nla_parse_nested(tb, MPLS_IPTUNNEL_MAX, nla,
-			       mpls_iptunnel_policy, NULL);
+			       mpls_iptunnel_policy, extack);
 	if (ret < 0)
 		return ret;
 
-- 
2.11.0 (Apple Git-81)

From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next] lwtunnel: remove device arg to lwtunnel_build_state
Date: Tue, 17 Jan 2017 15:08:41 -0800
Message-ID: <1484694521-17479-1-git-send-email-dsa@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:33401 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751415AbdAQXhb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 18:37:31 -0500
Received: by mail-pg0-f53.google.com with SMTP id 204so28342975pge.0
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 15:37:31 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nothing about lwt state requires a device reference, so remove the
input argument.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/net/lwtunnel.h    |  6 +++---
 net/core/lwt_bpf.c        |  2 +-
 net/core/lwtunnel.c       |  4 ++--
 net/ipv4/fib_semantics.c  | 22 ++++++----------------
 net/ipv4/ip_tunnel_core.c |  4 ++--
 net/ipv6/ila/ila_lwt.c    |  2 +-
 net/ipv6/route.c          |  2 +-
 net/ipv6/seg6_iptunnel.c  |  2 +-
 net/mpls/mpls_iptunnel.c  |  2 +-
 9 files changed, 18 insertions(+), 28 deletions(-)

diff --git a/include/net/lwtunnel.h b/include/net/lwtunnel.h
index d4c1c75b8862..671d5a766dd9 100644
--- a/include/net/lwtunnel.h
+++ b/include/net/lwtunnel.h
@@ -33,7 +33,7 @@ struct lwtunnel_state {
 };
 
 struct lwtunnel_encap_ops {
-	int (*build_state)(struct net_device *dev, struct nlattr *encap,
+	int (*build_state)(struct nlattr *encap,
 			   unsigned int family, const void *cfg,
 			   struct lwtunnel_state **ts);
 	void (*destroy_state)(struct lwtunnel_state *lws);
@@ -105,7 +105,7 @@ int lwtunnel_encap_add_ops(const struct lwtunnel_encap_ops *op,
 			   unsigned int num);
 int lwtunnel_encap_del_ops(const struct lwtunnel_encap_ops *op,
 			   unsigned int num);
-int lwtunnel_build_state(struct net_device *dev, u16 encap_type,
+int lwtunnel_build_state(u16 encap_type,
 			 struct nlattr *encap,
 			 unsigned int family, const void *cfg,
 			 struct lwtunnel_state **lws);
@@ -168,7 +168,7 @@ static inline int lwtunnel_encap_del_ops(const struct lwtunnel_encap_ops *op,
 	return -EOPNOTSUPP;
 }
 
-static inline int lwtunnel_build_state(struct net_device *dev, u16 encap_type,
+static inline int lwtunnel_build_state(u16 encap_type,
 				       struct nlattr *encap,
 				       unsigned int family, const void *cfg,
 				       struct lwtunnel_state **lws)
diff --git a/net/core/lwt_bpf.c b/net/core/lwt_bpf.c
index 71bb3e2eca08..4b737a2e5457 100644
--- a/net/core/lwt_bpf.c
+++ b/net/core/lwt_bpf.c
@@ -237,7 +237,7 @@ static const struct nla_policy bpf_nl_policy[LWT_BPF_MAX + 1] = {
 	[LWT_BPF_XMIT_HEADROOM]	= { .type = NLA_U32 },
 };
 
-static int bpf_build_state(struct net_device *dev, struct nlattr *nla,
+static int bpf_build_state(struct nlattr *nla,
 			   unsigned int family, const void *cfg,
 			   struct lwtunnel_state **ts)
 {
diff --git a/net/core/lwtunnel.c b/net/core/lwtunnel.c
index a5d4e866ce88..0f30398e0bdd 100644
--- a/net/core/lwtunnel.c
+++ b/net/core/lwtunnel.c
@@ -100,7 +100,7 @@ int lwtunnel_encap_del_ops(const struct lwtunnel_encap_ops *ops,
 }
 EXPORT_SYMBOL(lwtunnel_encap_del_ops);
 
-int lwtunnel_build_state(struct net_device *dev, u16 encap_type,
+int lwtunnel_build_state(u16 encap_type,
 			 struct nlattr *encap, unsigned int family,
 			 const void *cfg, struct lwtunnel_state **lws)
 {
@@ -127,7 +127,7 @@ int lwtunnel_build_state(struct net_device *dev, u16 encap_type,
 	}
 #endif
 	if (likely(ops && ops->build_state))
-		ret = ops->build_state(dev, encap, family, cfg, lws);
+		ret = ops->build_state(encap, family, cfg, lws);
 	rcu_read_unlock();
 
 	return ret;
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 9a375b908d01..f57efe73b84f 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -471,7 +471,6 @@ static int fib_count_nexthops(struct rtnexthop *rtnh, int remaining)
 static int fib_get_nhs(struct fib_info *fi, struct rtnexthop *rtnh,
 		       int remaining, struct fib_config *cfg)
 {
-	struct net *net = cfg->fc_nlinfo.nl_net;
 	int ret;
 
 	change_nexthops(fi) {
@@ -503,16 +502,14 @@ static int fib_get_nhs(struct fib_info *fi, struct rtnexthop *rtnh,
 			nla = nla_find(attrs, attrlen, RTA_ENCAP);
 			if (nla) {
 				struct lwtunnel_state *lwtstate;
-				struct net_device *dev = NULL;
 				struct nlattr *nla_entype;
 
 				nla_entype = nla_find(attrs, attrlen,
 						      RTA_ENCAP_TYPE);
 				if (!nla_entype)
 					goto err_inval;
-				if (cfg->fc_oif)
-					dev = __dev_get_by_index(net, cfg->fc_oif);
-				ret = lwtunnel_build_state(dev, nla_get_u16(
+
+				ret = lwtunnel_build_state(nla_get_u16(
 							   nla_entype),
 							   nla,  AF_INET, cfg,
 							   &lwtstate);
@@ -597,21 +594,18 @@ static inline void fib_add_weight(struct fib_info *fi,
 
 #endif /* CONFIG_IP_ROUTE_MULTIPATH */
 
-static int fib_encap_match(struct net *net, u16 encap_type,
+static int fib_encap_match(u16 encap_type,
 			   struct nlattr *encap,
 			   int oif, const struct fib_nh *nh,
 			   const struct fib_config *cfg)
 {
 	struct lwtunnel_state *lwtstate;
-	struct net_device *dev = NULL;
 	int ret, result = 0;
 
 	if (encap_type == LWTUNNEL_ENCAP_NONE)
 		return 0;
 
-	if (oif)
-		dev = __dev_get_by_index(net, oif);
-	ret = lwtunnel_build_state(dev, encap_type, encap,
+	ret = lwtunnel_build_state(encap_type, encap,
 				   AF_INET, cfg, &lwtstate);
 	if (!ret) {
 		result = lwtunnel_cmp_encap(lwtstate, nh->nh_lwtstate);
@@ -623,7 +617,6 @@ static int fib_encap_match(struct net *net, u16 encap_type,
 
 int fib_nh_match(struct fib_config *cfg, struct fib_info *fi)
 {
-	struct net *net = cfg->fc_nlinfo.nl_net;
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 	struct rtnexthop *rtnh;
 	int remaining;
@@ -634,7 +627,7 @@ int fib_nh_match(struct fib_config *cfg, struct fib_info *fi)
 
 	if (cfg->fc_oif || cfg->fc_gw) {
 		if (cfg->fc_encap) {
-			if (fib_encap_match(net, cfg->fc_encap_type,
+			if (fib_encap_match(cfg->fc_encap_type,
 					    cfg->fc_encap, cfg->fc_oif,
 					    fi->fib_nh, cfg))
 			    return 1;
@@ -1093,13 +1086,10 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 
 		if (cfg->fc_encap) {
 			struct lwtunnel_state *lwtstate;
-			struct net_device *dev = NULL;
 
 			if (cfg->fc_encap_type == LWTUNNEL_ENCAP_NONE)
 				goto err_inval;
-			if (cfg->fc_oif)
-				dev = __dev_get_by_index(net, cfg->fc_oif);
-			err = lwtunnel_build_state(dev, cfg->fc_encap_type,
+			err = lwtunnel_build_state(cfg->fc_encap_type,
 						   cfg->fc_encap, AF_INET, cfg,
 						   &lwtstate);
 			if (err)
diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index fed3d29f9eb3..d9ebdd594192 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -228,7 +228,7 @@ static const struct nla_policy ip_tun_policy[LWTUNNEL_IP_MAX + 1] = {
 	[LWTUNNEL_IP_FLAGS]	= { .type = NLA_U16 },
 };
 
-static int ip_tun_build_state(struct net_device *dev, struct nlattr *attr,
+static int ip_tun_build_state(struct nlattr *attr,
 			      unsigned int family, const void *cfg,
 			      struct lwtunnel_state **ts)
 {
@@ -324,7 +324,7 @@ static const struct nla_policy ip6_tun_policy[LWTUNNEL_IP6_MAX + 1] = {
 	[LWTUNNEL_IP6_FLAGS]		= { .type = NLA_U16 },
 };
 
-static int ip6_tun_build_state(struct net_device *dev, struct nlattr *attr,
+static int ip6_tun_build_state(struct nlattr *attr,
 			       unsigned int family, const void *cfg,
 			       struct lwtunnel_state **ts)
 {
diff --git a/net/ipv6/ila/ila_lwt.c b/net/ipv6/ila/ila_lwt.c
index a7bc54ab46e2..4facfb7c38d5 100644
--- a/net/ipv6/ila/ila_lwt.c
+++ b/net/ipv6/ila/ila_lwt.c
@@ -115,7 +115,7 @@ static const struct nla_policy ila_nl_policy[ILA_ATTR_MAX + 1] = {
 	[ILA_ATTR_CSUM_MODE] = { .type = NLA_U8, },
 };
 
-static int ila_build_state(struct net_device *dev, struct nlattr *nla,
+static int ila_build_state(struct nlattr *nla,
 			   unsigned int family, const void *cfg,
 			   struct lwtunnel_state **ts)
 {
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 4f6b067c8753..e941c31d0a01 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1897,7 +1897,7 @@ static struct rt6_info *ip6_route_info_create(struct fib6_config *cfg)
 	if (cfg->fc_encap) {
 		struct lwtunnel_state *lwtstate;
 
-		err = lwtunnel_build_state(dev, cfg->fc_encap_type,
+		err = lwtunnel_build_state(cfg->fc_encap_type,
 					   cfg->fc_encap, AF_INET6, cfg,
 					   &lwtstate);
 		if (err)
diff --git a/net/ipv6/seg6_iptunnel.c b/net/ipv6/seg6_iptunnel.c
index 1d60cb132835..75657172293a 100644
--- a/net/ipv6/seg6_iptunnel.c
+++ b/net/ipv6/seg6_iptunnel.c
@@ -303,7 +303,7 @@ int seg6_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 	return err;
 }
 
-static int seg6_build_state(struct net_device *dev, struct nlattr *nla,
+static int seg6_build_state(struct nlattr *nla,
 			    unsigned int family, const void *cfg,
 			    struct lwtunnel_state **ts)
 {
diff --git a/net/mpls/mpls_iptunnel.c b/net/mpls/mpls_iptunnel.c
index 2f7ccd934416..62fca574d249 100644
--- a/net/mpls/mpls_iptunnel.c
+++ b/net/mpls/mpls_iptunnel.c
@@ -126,7 +126,7 @@ static int mpls_xmit(struct sk_buff *skb)
 	return -EINVAL;
 }
 
-static int mpls_build_state(struct net_device *dev, struct nlattr *nla,
+static int mpls_build_state(struct nlattr *nla,
 			    unsigned int family, const void *cfg,
 			    struct lwtunnel_state **ts)
 {
-- 
2.1.4

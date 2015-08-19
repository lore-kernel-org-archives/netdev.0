From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 1/2] lwt: Add cfg argumnt to build_state
Date: Tue, 18 Aug 2015 20:21:10 -0700
Message-ID: <1439954471-599831-2-git-send-email-tom@herbertland.com>
References: <1439954471-599831-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <roopa@cumulusnetworks.com>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:17745 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751736AbbHSDV2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2015 23:21:28 -0400
Received: from pps.filterd (m0004346 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t7J3IxAq020153
	for <netdev@vger.kernel.org>; Tue, 18 Aug 2015 20:21:27 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1wc9jmh4r4-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 18 Aug 2015 20:21:27 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.232.63) with ESMTP	id
 5ff4149e462111e58f210002c992ebde-88ab16b0 for <netdev@vger.kernel.org>;	Tue,
 18 Aug 2015 20:21:26 -0700
In-Reply-To: <1439954471-599831-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add cfg and family arguments to lwt build state functions. cfg is a void
pointer and will either be a pointer to a fib_config or fib6_config
structure. The family parametter indicates which one (either AF_INET
or AF_INET6).

LWT encpasulation implementation may use the fib configuration to build
the LWT state.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/net/lwtunnel.h    |  9 ++++++---
 net/core/lwtunnel.c       |  5 +++--
 net/ipv4/fib_semantics.c  | 14 +++++++++-----
 net/ipv4/ip_tunnel_core.c |  3 ++-
 net/ipv6/ila.c            |  3 ++-
 net/ipv6/route.c          |  3 ++-
 net/mpls/mpls_iptunnel.c  |  3 ++-
 7 files changed, 26 insertions(+), 14 deletions(-)

diff --git a/include/net/lwtunnel.h b/include/net/lwtunnel.h
index e25b60e..9bf7e6a 100644
--- a/include/net/lwtunnel.h
+++ b/include/net/lwtunnel.h
@@ -26,7 +26,8 @@ struct lwtunnel_state {
 
 struct lwtunnel_encap_ops {
 	int (*build_state)(struct net_device *dev, struct nlattr *encap,
-			   struct lwtunnel_state **ts);
+			   struct lwtunnel_state **ts,
+			   unsigned int family, const void *cfg);
 	int (*output)(struct sock *sk, struct sk_buff *skb);
 	int (*input)(struct sk_buff *skb);
 	int (*fill_encap)(struct sk_buff *skb,
@@ -75,7 +76,8 @@ int lwtunnel_encap_del_ops(const struct lwtunnel_encap_ops *op,
 			   unsigned int num);
 int lwtunnel_build_state(struct net_device *dev, u16 encap_type,
 			 struct nlattr *encap,
-			 struct lwtunnel_state **lws);
+			 struct lwtunnel_state **lws,
+			 unsigned int family, const void *cfg);
 int lwtunnel_fill_encap(struct sk_buff *skb,
 			struct lwtunnel_state *lwtstate);
 int lwtunnel_get_encap_size(struct lwtunnel_state *lwtstate);
@@ -123,7 +125,8 @@ static inline int lwtunnel_encap_del_ops(const struct lwtunnel_encap_ops *op,
 
 static inline int lwtunnel_build_state(struct net_device *dev, u16 encap_type,
 				       struct nlattr *encap,
-				       struct lwtunnel_state **lws)
+				       struct lwtunnel_state **lws,
+				       unsigned int family, const void *cfg)
 {
 	return -EOPNOTSUPP;
 }
diff --git a/net/core/lwtunnel.c b/net/core/lwtunnel.c
index 3331585..5ee3889 100644
--- a/net/core/lwtunnel.c
+++ b/net/core/lwtunnel.c
@@ -72,7 +72,8 @@ int lwtunnel_encap_del_ops(const struct lwtunnel_encap_ops *ops,
 EXPORT_SYMBOL(lwtunnel_encap_del_ops);
 
 int lwtunnel_build_state(struct net_device *dev, u16 encap_type,
-			 struct nlattr *encap, struct lwtunnel_state **lws)
+			 struct nlattr *encap, struct lwtunnel_state **lws,
+			 unsigned int family, const void *cfg)
 {
 	const struct lwtunnel_encap_ops *ops;
 	int ret = -EINVAL;
@@ -85,7 +86,7 @@ int lwtunnel_build_state(struct net_device *dev, u16 encap_type,
 	rcu_read_lock();
 	ops = rcu_dereference(lwtun_encaps[encap_type]);
 	if (likely(ops && ops->build_state))
-		ret = ops->build_state(dev, encap, lws);
+		ret = ops->build_state(dev, encap, lws, family, cfg);
 	rcu_read_unlock();
 
 	return ret;
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index c802585..408e037 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -511,7 +511,8 @@ static int fib_get_nhs(struct fib_info *fi, struct rtnexthop *rtnh,
 					dev = __dev_get_by_index(net, cfg->fc_oif);
 				ret = lwtunnel_build_state(dev, nla_get_u16(
 							   nla_entype),
-							   nla, &lwtstate);
+							   nla, &lwtstate,
+							   AF_INET, cfg);
 				if (ret)
 					goto errout;
 				nexthop_nh->nh_lwtstate =
@@ -535,7 +536,8 @@ errout:
 
 int fib_encap_match(struct net *net, u16 encap_type,
 		    struct nlattr *encap,
-		    int oif, const struct fib_nh *nh)
+		    int oif, const struct fib_nh *nh,
+		    const struct fib_config *cfg)
 {
 	struct lwtunnel_state *lwtstate;
 	struct net_device *dev = NULL;
@@ -547,7 +549,8 @@ int fib_encap_match(struct net *net, u16 encap_type,
 	if (oif)
 		dev = __dev_get_by_index(net, oif);
 	ret = lwtunnel_build_state(dev, encap_type,
-				   encap, &lwtstate);
+				   encap, &lwtstate,
+				   AF_INET, cfg);
 	if (!ret)
 		return lwtunnel_cmp_encap(lwtstate, nh->nh_lwtstate);
 
@@ -569,7 +572,7 @@ int fib_nh_match(struct fib_config *cfg, struct fib_info *fi)
 		if (cfg->fc_encap) {
 			if (fib_encap_match(net, cfg->fc_encap_type,
 					    cfg->fc_encap, cfg->fc_oif,
-					    fi->fib_nh))
+					    fi->fib_nh, cfg))
 			    return 1;
 		}
 		if ((!cfg->fc_oif || cfg->fc_oif == fi->fib_nh->nh_oif) &&
@@ -996,7 +999,8 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 			if (cfg->fc_oif)
 				dev = __dev_get_by_index(net, cfg->fc_oif);
 			err = lwtunnel_build_state(dev, cfg->fc_encap_type,
-						   cfg->fc_encap, &lwtstate);
+						   cfg->fc_encap, &lwtstate,
+						   AF_INET, cfg);
 			if (err)
 				goto failure;
 
diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index fd63196..0c95caa 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -204,7 +204,8 @@ static const struct nla_policy ip_tun_policy[LWTUNNEL_IP_MAX + 1] = {
 };
 
 static int ip_tun_build_state(struct net_device *dev, struct nlattr *attr,
-			      struct lwtunnel_state **ts)
+			      struct lwtunnel_state **ts, unsigned int family,
+			      const void *cfg)
 {
 	struct ip_tunnel_info *tun_info;
 	struct lwtunnel_state *new_state;
diff --git a/net/ipv6/ila.c b/net/ipv6/ila.c
index 2540ab4..0b955e2 100644
--- a/net/ipv6/ila.c
+++ b/net/ipv6/ila.c
@@ -129,7 +129,8 @@ static struct nla_policy ila_nl_policy[ILA_ATTR_MAX + 1] = {
 };
 
 static int ila_build_state(struct net_device *dev, struct nlattr *nla,
-			   struct lwtunnel_state **ts)
+			   struct lwtunnel_state **ts, unsigned int family,
+			   const void *cfg)
 {
 	struct ila_params *p;
 	struct nlattr *tb[ILA_ATTR_MAX + 1];
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index c373304..ff3a0f9 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1781,7 +1781,8 @@ int ip6_route_add(struct fib6_config *cfg)
 		struct lwtunnel_state *lwtstate;
 
 		err = lwtunnel_build_state(dev, cfg->fc_encap_type,
-					   cfg->fc_encap, &lwtstate);
+					   cfg->fc_encap, &lwtstate,
+					   AF_INET6, cfg);
 		if (err)
 			goto out;
 		rt->rt6i_lwtstate = lwtstate_get(lwtstate);
diff --git a/net/mpls/mpls_iptunnel.c b/net/mpls/mpls_iptunnel.c
index 276f8c9..4513d22 100644
--- a/net/mpls/mpls_iptunnel.c
+++ b/net/mpls/mpls_iptunnel.c
@@ -126,7 +126,8 @@ drop:
 }
 
 static int mpls_build_state(struct net_device *dev, struct nlattr *nla,
-			    struct lwtunnel_state **ts)
+			    struct lwtunnel_state **ts, unsigned int family,
+			    const void *cfg)
 {
 	struct mpls_iptunnel_encap *tun_encap_info;
 	struct nlattr *tb[MPLS_IPTUNNEL_MAX + 1];
-- 
1.8.1

From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next v2 1/2] lwt: Add cfg argumnt to build_state
Date: Thu, 20 Aug 2015 11:22:37 -0700
Message-ID: <1440094958-1808151-2-git-send-email-tom@herbertland.com>
References: <1440094958-1808151-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:51390 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752284AbbHTSWw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 14:22:52 -0400
Received: from pps.filterd (m0004003 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t7KIKhOV025282
	for <netdev@vger.kernel.org>; Thu, 20 Aug 2015 11:22:51 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1wdj2j0p5v-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 20 Aug 2015 11:22:51 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.232.59) with ESMTP	id
 766ebe52476811e593e90002c991e86a-f5bfb2b0 for <netdev@vger.kernel.org>;	Thu,
 20 Aug 2015 11:22:49 -0700
In-Reply-To: <1440094958-1808151-1-git-send-email-tom@herbertland.com>
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
 include/net/lwtunnel.h    |  5 ++++-
 net/core/lwtunnel.c       |  5 +++--
 net/ipv4/fib_semantics.c  | 15 +++++++++------
 net/ipv4/ip_tunnel_core.c |  1 +
 net/ipv6/ila.c            |  1 +
 net/ipv6/route.c          |  3 ++-
 net/mpls/mpls_iptunnel.c  |  1 +
 7 files changed, 21 insertions(+), 10 deletions(-)

diff --git a/include/net/lwtunnel.h b/include/net/lwtunnel.h
index cfee539..41acbdb 100644
--- a/include/net/lwtunnel.h
+++ b/include/net/lwtunnel.h
@@ -26,6 +26,7 @@ struct lwtunnel_state {
 
 struct lwtunnel_encap_ops {
 	int (*build_state)(struct net_device *dev, struct nlattr *encap,
+			   unsigned int family, const void *cfg,
 			   struct lwtunnel_state **ts);
 	int (*output)(struct sock *sk, struct sk_buff *skb);
 	int (*input)(struct sk_buff *skb);
@@ -80,6 +81,7 @@ int lwtunnel_encap_del_ops(const struct lwtunnel_encap_ops *op,
 			   unsigned int num);
 int lwtunnel_build_state(struct net_device *dev, u16 encap_type,
 			 struct nlattr *encap,
+			 unsigned int family, const void *cfg,
 			 struct lwtunnel_state **lws);
 int lwtunnel_fill_encap(struct sk_buff *skb,
 			struct lwtunnel_state *lwtstate);
@@ -132,7 +134,8 @@ static inline int lwtunnel_encap_del_ops(const struct lwtunnel_encap_ops *op,
 
 static inline int lwtunnel_build_state(struct net_device *dev, u16 encap_type,
 				       struct nlattr *encap,
-				       struct lwtunnel_state **lws)
+				       unsigned int family, const void *cfg,
+				       struct lwtunnel_state **lws);
 {
 	return -EOPNOTSUPP;
 }
diff --git a/net/core/lwtunnel.c b/net/core/lwtunnel.c
index 3331585..d5ca58f 100644
--- a/net/core/lwtunnel.c
+++ b/net/core/lwtunnel.c
@@ -72,7 +72,8 @@ int lwtunnel_encap_del_ops(const struct lwtunnel_encap_ops *ops,
 EXPORT_SYMBOL(lwtunnel_encap_del_ops);
 
 int lwtunnel_build_state(struct net_device *dev, u16 encap_type,
-			 struct nlattr *encap, struct lwtunnel_state **lws)
+			 struct nlattr *encap, unsigned int family,
+			  const void *cfg, struct lwtunnel_state **lws)
 {
 	const struct lwtunnel_encap_ops *ops;
 	int ret = -EINVAL;
@@ -85,7 +86,7 @@ int lwtunnel_build_state(struct net_device *dev, u16 encap_type,
 	rcu_read_lock();
 	ops = rcu_dereference(lwtun_encaps[encap_type]);
 	if (likely(ops && ops->build_state))
-		ret = ops->build_state(dev, encap, lws);
+		ret = ops->build_state(dev, encap, family, cfg, lws);
 	rcu_read_unlock();
 
 	return ret;
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index d525307..afc4488 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -511,7 +511,8 @@ static int fib_get_nhs(struct fib_info *fi, struct rtnexthop *rtnh,
 					dev = __dev_get_by_index(net, cfg->fc_oif);
 				ret = lwtunnel_build_state(dev, nla_get_u16(
 							   nla_entype),
-							   nla, &lwtstate);
+							   nla,  AF_INET, cfg,
+							   &lwtstate);
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
@@ -546,8 +548,8 @@ int fib_encap_match(struct net *net, u16 encap_type,
 
 	if (oif)
 		dev = __dev_get_by_index(net, oif);
-	ret = lwtunnel_build_state(dev, encap_type,
-				   encap, &lwtstate);
+	ret = lwtunnel_build_state(dev, encap_type, encap,
+				   AF_INET, cfg, &lwtstate);
 	if (!ret) {
 		result = lwtunnel_cmp_encap(lwtstate, nh->nh_lwtstate);
 		lwtstate_free(lwtstate);
@@ -571,7 +573,7 @@ int fib_nh_match(struct fib_config *cfg, struct fib_info *fi)
 		if (cfg->fc_encap) {
 			if (fib_encap_match(net, cfg->fc_encap_type,
 					    cfg->fc_encap, cfg->fc_oif,
-					    fi->fib_nh))
+					    fi->fib_nh, cfg))
 			    return 1;
 		}
 		if ((!cfg->fc_oif || cfg->fc_oif == fi->fib_nh->nh_oif) &&
@@ -998,7 +1000,8 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 			if (cfg->fc_oif)
 				dev = __dev_get_by_index(net, cfg->fc_oif);
 			err = lwtunnel_build_state(dev, cfg->fc_encap_type,
-						   cfg->fc_encap, &lwtstate);
+						   cfg->fc_encap, AF_INET, cfg,
+						   &lwtstate);
 			if (err)
 				goto failure;
 
diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index 1c2389d..93f86b0 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -204,6 +204,7 @@ static const struct nla_policy ip_tun_policy[LWTUNNEL_IP_MAX + 1] = {
 };
 
 static int ip_tun_build_state(struct net_device *dev, struct nlattr *attr,
+			      unsigned int family, const void *cfg,
 			      struct lwtunnel_state **ts)
 {
 	struct ip_tunnel_info *tun_info;
diff --git a/net/ipv6/ila.c b/net/ipv6/ila.c
index 2540ab4..1c48e46 100644
--- a/net/ipv6/ila.c
+++ b/net/ipv6/ila.c
@@ -129,6 +129,7 @@ static struct nla_policy ila_nl_policy[ILA_ATTR_MAX + 1] = {
 };
 
 static int ila_build_state(struct net_device *dev, struct nlattr *nla,
+			   unsigned int family, const void *cfg,
 			   struct lwtunnel_state **ts)
 {
 	struct ila_params *p;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index c373304..7feb3e0 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1781,7 +1781,8 @@ int ip6_route_add(struct fib6_config *cfg)
 		struct lwtunnel_state *lwtstate;
 
 		err = lwtunnel_build_state(dev, cfg->fc_encap_type,
-					   cfg->fc_encap, &lwtstate);
+					   cfg->fc_encap, AF_INET6, cfg,
+					   &lwtstate);
 		if (err)
 			goto out;
 		rt->rt6i_lwtstate = lwtstate_get(lwtstate);
diff --git a/net/mpls/mpls_iptunnel.c b/net/mpls/mpls_iptunnel.c
index 276f8c9..6e44ef8 100644
--- a/net/mpls/mpls_iptunnel.c
+++ b/net/mpls/mpls_iptunnel.c
@@ -126,6 +126,7 @@ drop:
 }
 
 static int mpls_build_state(struct net_device *dev, struct nlattr *nla,
+			    unsigned int family, const void *cfg,
 			    struct lwtunnel_state **ts)
 {
 	struct mpls_iptunnel_encap *tun_encap_info;
-- 
1.8.1

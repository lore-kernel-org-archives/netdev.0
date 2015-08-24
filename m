From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next v3 1/2] lwt: Add cfg argument to build_state
Date: Mon, 24 Aug 2015 09:45:41 -0700
Message-ID: <1440434742-4112603-2-git-send-email-tom@herbertland.com>
References: <1440434742-4112603-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:54075 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751061AbbHXQpx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2015 12:45:53 -0400
Received: from pps.filterd (m0004060 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t7OGfS6Y025240
	for <netdev@vger.kernel.org>; Mon, 24 Aug 2015 09:45:53 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1wg6tr02hx-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 24 Aug 2015 09:45:53 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.232.63) with ESMTP	id
 941616524a7f11e58bc10002c992ebde-3dbf1240 for <netdev@vger.kernel.org>;	Mon,
 24 Aug 2015 09:45:51 -0700
In-Reply-To: <1440434742-4112603-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add cfg and family arguments to lwt build state functions. cfg is a void
pointer and will either be a pointer to a fib_config or fib6_config
structure. The family parameter indicates which one (either AF_INET
or AF_INET6).

LWT encpasulation implementation may use the fib configuration to build
the LWT state.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/net/lwtunnel.h    |  3 +++
 net/core/lwtunnel.c       |  5 +++--
 net/ipv4/fib_semantics.c  | 17 ++++++++++-------
 net/ipv4/ip_tunnel_core.c |  2 ++
 net/ipv6/ila.c            |  1 +
 net/ipv6/route.c          |  3 ++-
 net/mpls/mpls_iptunnel.c  |  1 +
 7 files changed, 22 insertions(+), 10 deletions(-)

diff --git a/include/net/lwtunnel.h b/include/net/lwtunnel.h
index 8434898..fce0e35 100644
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
@@ -130,6 +132,7 @@ static inline int lwtunnel_encap_del_ops(const struct lwtunnel_encap_ops *op,
 
 static inline int lwtunnel_build_state(struct net_device *dev, u16 encap_type,
 				       struct nlattr *encap,
+				       unsigned int family, const void *cfg,
 				       struct lwtunnel_state **lws)
 {
 	return -EOPNOTSUPP;
diff --git a/net/core/lwtunnel.c b/net/core/lwtunnel.c
index e924c2e..dfb1a9c 100644
--- a/net/core/lwtunnel.c
+++ b/net/core/lwtunnel.c
@@ -72,7 +72,8 @@ int lwtunnel_encap_del_ops(const struct lwtunnel_encap_ops *ops,
 EXPORT_SYMBOL(lwtunnel_encap_del_ops);
 
 int lwtunnel_build_state(struct net_device *dev, u16 encap_type,
-			 struct nlattr *encap, struct lwtunnel_state **lws)
+			 struct nlattr *encap, unsigned int family,
+			 const void *cfg, struct lwtunnel_state **lws)
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
index 01f1c7d..1b2d011 100644
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
 
 static int fib_encap_match(struct net *net, u16 encap_type,
 			   struct nlattr *encap,
-			   int oif, const struct fib_nh *nh)
+			   int oif, const struct fib_nh *nh,
+			   const struct fib_config *cfg)
 {
 	struct lwtunnel_state *lwtstate;
 	struct net_device *dev = NULL;
@@ -546,8 +548,8 @@ static int fib_encap_match(struct net *net, u16 encap_type,
 
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
@@ -663,7 +665,7 @@ int fib_nh_match(struct fib_config *cfg, struct fib_info *fi)
 static int fib_check_nh(struct fib_config *cfg, struct fib_info *fi,
 			struct fib_nh *nh)
 {
-	int err;
+	int err = 0;
 	struct net *net;
 	struct net_device *dev;
 
@@ -1005,7 +1007,8 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 			if (cfg->fc_oif)
 				dev = __dev_get_by_index(net, cfg->fc_oif);
 			err = lwtunnel_build_state(dev, cfg->fc_encap_type,
-						   cfg->fc_encap, &lwtstate);
+						   cfg->fc_encap, AF_INET, cfg,
+						   &lwtstate);
 			if (err)
 				goto failure;
 
diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index 289b6c2..934f2ac 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -204,6 +204,7 @@ static const struct nla_policy ip_tun_policy[LWTUNNEL_IP_MAX + 1] = {
 };
 
 static int ip_tun_build_state(struct net_device *dev, struct nlattr *attr,
+			      unsigned int family, const void *cfg,
 			      struct lwtunnel_state **ts)
 {
 	struct ip_tunnel_info *tun_info;
@@ -311,6 +312,7 @@ static const struct nla_policy ip6_tun_policy[LWTUNNEL_IP6_MAX + 1] = {
 };
 
 static int ip6_tun_build_state(struct net_device *dev, struct nlattr *attr,
+			       unsigned int family, const void *cfg,
 			       struct lwtunnel_state **ts)
 {
 	struct ip_tunnel_info *tun_info;
diff --git a/net/ipv6/ila.c b/net/ipv6/ila.c
index f011c3d..ffe4dca 100644
--- a/net/ipv6/ila.c
+++ b/net/ipv6/ila.c
@@ -123,6 +123,7 @@ static struct nla_policy ila_nl_policy[ILA_ATTR_MAX + 1] = {
 };
 
 static int ila_build_state(struct net_device *dev, struct nlattr *nla,
+			   unsigned int family, const void *cfg,
 			   struct lwtunnel_state **ts)
 {
 	struct ila_params *p;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index e476f01..df3e353 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1819,7 +1819,8 @@ int ip6_route_add(struct fib6_config *cfg)
 		struct lwtunnel_state *lwtstate;
 
 		err = lwtunnel_build_state(dev, cfg->fc_encap_type,
-					   cfg->fc_encap, &lwtstate);
+					   cfg->fc_encap, AF_INET6, cfg,
+					   &lwtstate);
 		if (err)
 			goto out;
 		rt->dst.lwtstate = lwtstate_get(lwtstate);
diff --git a/net/mpls/mpls_iptunnel.c b/net/mpls/mpls_iptunnel.c
index 3da5ca3..21e70bc 100644
--- a/net/mpls/mpls_iptunnel.c
+++ b/net/mpls/mpls_iptunnel.c
@@ -123,6 +123,7 @@ drop:
 }
 
 static int mpls_build_state(struct net_device *dev, struct nlattr *nla,
+			    unsigned int family, const void *cfg,
 			    struct lwtunnel_state **ts)
 {
 	struct mpls_iptunnel_encap *tun_encap_info;
-- 
1.8.1

From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v2 net-next 1/7] lwt: Add net to build_state argument
Date: Thu, 15 Sep 2016 14:19:15 -0700
Message-ID: <1473974361-2275254-2-git-send-email-tom@herbertland.com>
References: <1473974361-2275254-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>, <roopa@cumulusnetworks.com>, <tgraf@suug.ch>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:59715 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753255AbcIOVTe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 17:19:34 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8FL9Ml6004198
        for <netdev@vger.kernel.org>; Thu, 15 Sep 2016 14:19:33 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 25g21krn9p-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 15 Sep 2016 14:19:33 -0700
Received: from facebook.com (2401:db00:21:6030:face:0:92:0)     by
 mx-out.facebook.com (10.223.101.97) with ESMTP id
 175a227e7b8a11e6ba5224be0595f910-1a3f5a50 for <netdev@vger.kernel.org>;        Thu,
 15 Sep 2016 14:19:31 -0700
In-Reply-To: <1473974361-2275254-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Users of LWT need to know net if they want to have per net operations
in LWT.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/net/lwtunnel.h    | 14 +++++++-------
 net/core/lwtunnel.c       | 11 +++++++----
 net/ipv4/fib_semantics.c  |  7 ++++---
 net/ipv4/ip_tunnel_core.c | 12 ++++++------
 net/ipv6/ila/ila_lwt.c    |  6 +++---
 net/ipv6/route.c          |  2 +-
 net/mpls/mpls_iptunnel.c  |  6 +++---
 7 files changed, 31 insertions(+), 27 deletions(-)

diff --git a/include/net/lwtunnel.h b/include/net/lwtunnel.h
index ea3f80f..9d1e172 100644
--- a/include/net/lwtunnel.h
+++ b/include/net/lwtunnel.h
@@ -33,9 +33,9 @@ struct lwtunnel_state {
 };
 
 struct lwtunnel_encap_ops {
-	int (*build_state)(struct net_device *dev, struct nlattr *encap,
-			   unsigned int family, const void *cfg,
-			   struct lwtunnel_state **ts);
+	int (*build_state)(struct net *net, struct net_device *dev,
+			   struct nlattr *encap, unsigned int family,
+			   const void *cfg, struct lwtunnel_state **ts);
 	int (*output)(struct net *net, struct sock *sk, struct sk_buff *skb);
 	int (*input)(struct sk_buff *skb);
 	int (*fill_encap)(struct sk_buff *skb,
@@ -106,8 +106,8 @@ int lwtunnel_encap_add_ops(const struct lwtunnel_encap_ops *op,
 			   unsigned int num);
 int lwtunnel_encap_del_ops(const struct lwtunnel_encap_ops *op,
 			   unsigned int num);
-int lwtunnel_build_state(struct net_device *dev, u16 encap_type,
-			 struct nlattr *encap,
+int lwtunnel_build_state(struct net *net, struct net_device *dev,
+			 u16 encap_type, struct nlattr *encap,
 			 unsigned int family, const void *cfg,
 			 struct lwtunnel_state **lws);
 int lwtunnel_fill_encap(struct sk_buff *skb,
@@ -169,8 +169,8 @@ static inline int lwtunnel_encap_del_ops(const struct lwtunnel_encap_ops *op,
 	return -EOPNOTSUPP;
 }
 
-static inline int lwtunnel_build_state(struct net_device *dev, u16 encap_type,
-				       struct nlattr *encap,
+static inline int lwtunnel_build_state(struct net *net, struct net_device *dev,
+				       u16 encap_type, struct nlattr *encap,
 				       unsigned int family, const void *cfg,
 				       struct lwtunnel_state **lws)
 {
diff --git a/net/core/lwtunnel.c b/net/core/lwtunnel.c
index e5f84c2..ba8be0b 100644
--- a/net/core/lwtunnel.c
+++ b/net/core/lwtunnel.c
@@ -39,6 +39,8 @@ static const char *lwtunnel_encap_str(enum lwtunnel_encap_types encap_type)
 		return "MPLS";
 	case LWTUNNEL_ENCAP_ILA:
 		return "ILA";
+	case LWTUNNEL_ENCAP_ILA_NOTIFY:
+		return "ILA_NOTIFY";
 	case LWTUNNEL_ENCAP_IP6:
 	case LWTUNNEL_ENCAP_IP:
 	case LWTUNNEL_ENCAP_NONE:
@@ -96,9 +98,10 @@ int lwtunnel_encap_del_ops(const struct lwtunnel_encap_ops *ops,
 }
 EXPORT_SYMBOL(lwtunnel_encap_del_ops);
 
-int lwtunnel_build_state(struct net_device *dev, u16 encap_type,
-			 struct nlattr *encap, unsigned int family,
-			 const void *cfg, struct lwtunnel_state **lws)
+int lwtunnel_build_state(struct net *net, struct net_device *dev,
+			 u16 encap_type, struct nlattr *encap,
+			 unsigned int family, const void *cfg,
+			 struct lwtunnel_state **lws)
 {
 	const struct lwtunnel_encap_ops *ops;
 	int ret = -EINVAL;
@@ -123,7 +126,7 @@ int lwtunnel_build_state(struct net_device *dev, u16 encap_type,
 	}
 #endif
 	if (likely(ops && ops->build_state))
-		ret = ops->build_state(dev, encap, family, cfg, lws);
+		ret = ops->build_state(net, dev, encap, family, cfg, lws);
 	rcu_read_unlock();
 
 	return ret;
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 388d3e2..aee4e95 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -511,7 +511,8 @@ static int fib_get_nhs(struct fib_info *fi, struct rtnexthop *rtnh,
 					goto err_inval;
 				if (cfg->fc_oif)
 					dev = __dev_get_by_index(net, cfg->fc_oif);
-				ret = lwtunnel_build_state(dev, nla_get_u16(
+				ret = lwtunnel_build_state(net, dev,
+							   nla_get_u16(
 							   nla_entype),
 							   nla,  AF_INET, cfg,
 							   &lwtstate);
@@ -610,7 +611,7 @@ static int fib_encap_match(struct net *net, u16 encap_type,
 
 	if (oif)
 		dev = __dev_get_by_index(net, oif);
-	ret = lwtunnel_build_state(dev, encap_type, encap,
+	ret = lwtunnel_build_state(net, dev, encap_type, encap,
 				   AF_INET, cfg, &lwtstate);
 	if (!ret) {
 		result = lwtunnel_cmp_encap(lwtstate, nh->nh_lwtstate);
@@ -1098,7 +1099,7 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 				goto err_inval;
 			if (cfg->fc_oif)
 				dev = __dev_get_by_index(net, cfg->fc_oif);
-			err = lwtunnel_build_state(dev, cfg->fc_encap_type,
+			err = lwtunnel_build_state(net, dev, cfg->fc_encap_type,
 						   cfg->fc_encap, AF_INET, cfg,
 						   &lwtstate);
 			if (err)
diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index 777bc18..6a0cac3 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -239,9 +239,9 @@ static const struct nla_policy ip_tun_policy[LWTUNNEL_IP_MAX + 1] = {
 	[LWTUNNEL_IP_FLAGS]	= { .type = NLA_U16 },
 };
 
-static int ip_tun_build_state(struct net_device *dev, struct nlattr *attr,
-			      unsigned int family, const void *cfg,
-			      struct lwtunnel_state **ts)
+static int ip_tun_build_state(struct net *net, struct net_device *dev,
+			      struct nlattr *attr, unsigned int family,
+			      const void *cfg, struct lwtunnel_state **ts)
 {
 	struct ip_tunnel_info *tun_info;
 	struct lwtunnel_state *new_state;
@@ -335,9 +335,9 @@ static const struct nla_policy ip6_tun_policy[LWTUNNEL_IP6_MAX + 1] = {
 	[LWTUNNEL_IP6_FLAGS]		= { .type = NLA_U16 },
 };
 
-static int ip6_tun_build_state(struct net_device *dev, struct nlattr *attr,
-			       unsigned int family, const void *cfg,
-			       struct lwtunnel_state **ts)
+static int ip6_tun_build_state(struct net *net, struct net_device *dev,
+			       struct nlattr *attr, unsigned int family,
+			       const void *cfg, struct lwtunnel_state **ts)
 {
 	struct ip_tunnel_info *tun_info;
 	struct lwtunnel_state *new_state;
diff --git a/net/ipv6/ila/ila_lwt.c b/net/ipv6/ila/ila_lwt.c
index e50c27a..30a6920 100644
--- a/net/ipv6/ila/ila_lwt.c
+++ b/net/ipv6/ila/ila_lwt.c
@@ -56,9 +56,9 @@ static const struct nla_policy ila_nl_policy[ILA_ATTR_MAX + 1] = {
 	[ILA_ATTR_CSUM_MODE] = { .type = NLA_U8, },
 };
 
-static int ila_build_state(struct net_device *dev, struct nlattr *nla,
-			   unsigned int family, const void *cfg,
-			   struct lwtunnel_state **ts)
+static int ila_build_state(struct net *net, struct net_device *dev,
+			   struct nlattr *nla, unsigned int family,
+			   const void *cfg, struct lwtunnel_state **ts)
 {
 	struct ila_params *p;
 	struct nlattr *tb[ILA_ATTR_MAX + 1];
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index ad4a7ff..48c3aa7 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1884,7 +1884,7 @@ static struct rt6_info *ip6_route_info_create(struct fib6_config *cfg)
 	if (cfg->fc_encap) {
 		struct lwtunnel_state *lwtstate;
 
-		err = lwtunnel_build_state(dev, cfg->fc_encap_type,
+		err = lwtunnel_build_state(net, dev, cfg->fc_encap_type,
 					   cfg->fc_encap, AF_INET6, cfg,
 					   &lwtstate);
 		if (err)
diff --git a/net/mpls/mpls_iptunnel.c b/net/mpls/mpls_iptunnel.c
index cf52cf3..d2df225 100644
--- a/net/mpls/mpls_iptunnel.c
+++ b/net/mpls/mpls_iptunnel.c
@@ -126,9 +126,9 @@ drop:
 	return -EINVAL;
 }
 
-static int mpls_build_state(struct net_device *dev, struct nlattr *nla,
-			    unsigned int family, const void *cfg,
-			    struct lwtunnel_state **ts)
+static int mpls_build_state(struct net *net, struct net_device *dev,
+			    struct nlattr *nla, unsigned int family,
+			    const void *cfg, struct lwtunnel_state **ts)
 {
 	struct mpls_iptunnel_encap *tun_encap_info;
 	struct nlattr *tb[MPLS_IPTUNNEL_MAX + 1];
-- 
2.8.0.rc2

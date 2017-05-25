From: David Ahern <dsahern@gmail.com>
Subject: [PATCH net-next 2/6] net: lwtunnel: Add extack to encap attr validation
Date: Wed, 24 May 2017 21:54:38 -0600
Message-ID: <20170525035442.51407-3-dsahern@gmail.com>
References: <20170525035442.51407-1-dsahern@gmail.com>
Cc: roopa@cumulusnetworks.com, David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33665 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S941582AbdEYDyu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 23:54:50 -0400
Received: by mail-pf0-f193.google.com with SMTP id f27so36381976pfe.0
        for <netdev@vger.kernel.org>; Wed, 24 May 2017 20:54:50 -0700 (PDT)
In-Reply-To: <20170525035442.51407-1-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pass extack down to lwtunnel_valid_encap_type and
lwtunnel_valid_encap_type_attr. Add messages for unknown
or unsupported encap types.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 include/net/lwtunnel.h  | 13 +++++++++----
 net/core/lwtunnel.c     | 18 +++++++++++++-----
 net/ipv4/fib_frontend.c |  6 ++++--
 net/ipv6/route.c        |  4 ++--
 4 files changed, 28 insertions(+), 13 deletions(-)

diff --git a/include/net/lwtunnel.h b/include/net/lwtunnel.h
index ebfe237aad7e..ca6f002774ef 100644
--- a/include/net/lwtunnel.h
+++ b/include/net/lwtunnel.h
@@ -107,8 +107,10 @@ int lwtunnel_encap_add_ops(const struct lwtunnel_encap_ops *op,
 			   unsigned int num);
 int lwtunnel_encap_del_ops(const struct lwtunnel_encap_ops *op,
 			   unsigned int num);
-int lwtunnel_valid_encap_type(u16 encap_type);
-int lwtunnel_valid_encap_type_attr(struct nlattr *attr, int len);
+int lwtunnel_valid_encap_type(u16 encap_type,
+			      struct netlink_ext_ack *extack);
+int lwtunnel_valid_encap_type_attr(struct nlattr *attr, int len,
+				   struct netlink_ext_ack *extack);
 int lwtunnel_build_state(u16 encap_type,
 			 struct nlattr *encap,
 			 unsigned int family, const void *cfg,
@@ -172,11 +174,14 @@ static inline int lwtunnel_encap_del_ops(const struct lwtunnel_encap_ops *op,
 	return -EOPNOTSUPP;
 }
 
-static inline int lwtunnel_valid_encap_type(u16 encap_type)
+static inline int lwtunnel_valid_encap_type(u16 encap_type,
+					    struct netlink_ext_ack *extack)
 {
+	NL_SET_ERR_MSG(extack, "CONFIG_LWTUNNEL is not enabled in this kernel");
 	return -EOPNOTSUPP;
 }
-static inline int lwtunnel_valid_encap_type_attr(struct nlattr *attr, int len)
+static inline int lwtunnel_valid_encap_type_attr(struct nlattr *attr, int len,
+						 struct netlink_ext_ack *extack)
 {
 	/* return 0 since we are not walking attr looking for
 	 * RTA_ENCAP_TYPE attribute on nexthops.
diff --git a/net/core/lwtunnel.c b/net/core/lwtunnel.c
index cfae3d5fe11f..ab840386a74d 100644
--- a/net/core/lwtunnel.c
+++ b/net/core/lwtunnel.c
@@ -126,14 +126,16 @@ int lwtunnel_build_state(u16 encap_type,
 }
 EXPORT_SYMBOL(lwtunnel_build_state);
 
-int lwtunnel_valid_encap_type(u16 encap_type)
+int lwtunnel_valid_encap_type(u16 encap_type, struct netlink_ext_ack *extack)
 {
 	const struct lwtunnel_encap_ops *ops;
 	int ret = -EINVAL;
 
 	if (encap_type == LWTUNNEL_ENCAP_NONE ||
-	    encap_type > LWTUNNEL_ENCAP_MAX)
+	    encap_type > LWTUNNEL_ENCAP_MAX) {
+		NL_SET_ERR_MSG(extack, "Unknown lwt encapsulation type");
 		return ret;
+	}
 
 	rcu_read_lock();
 	ops = rcu_dereference(lwtun_encaps[encap_type]);
@@ -153,11 +155,16 @@ int lwtunnel_valid_encap_type(u16 encap_type)
 		}
 	}
 #endif
-	return ops ? 0 : -EOPNOTSUPP;
+	ret = ops ? 0 : -EOPNOTSUPP;
+	if (ret < 0)
+		NL_SET_ERR_MSG(extack, "lwt encapsulation type not supported");
+
+	return ret;
 }
 EXPORT_SYMBOL(lwtunnel_valid_encap_type);
 
-int lwtunnel_valid_encap_type_attr(struct nlattr *attr, int remaining)
+int lwtunnel_valid_encap_type_attr(struct nlattr *attr, int remaining,
+				   struct netlink_ext_ack *extack)
 {
 	struct rtnexthop *rtnh = (struct rtnexthop *)attr;
 	struct nlattr *nla_entype;
@@ -174,7 +181,8 @@ int lwtunnel_valid_encap_type_attr(struct nlattr *attr, int remaining)
 			if (nla_entype) {
 				encap_type = nla_get_u16(nla_entype);
 
-				if (lwtunnel_valid_encap_type(encap_type) != 0)
+				if (lwtunnel_valid_encap_type(encap_type,
+							      extack) != 0)
 					return -EOPNOTSUPP;
 			}
 		}
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 2d55882d566e..f03fe8521f6e 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -684,7 +684,8 @@ static int rtm_to_fib_config(struct net *net, struct sk_buff *skb,
 			break;
 		case RTA_MULTIPATH:
 			err = lwtunnel_valid_encap_type_attr(nla_data(attr),
-							     nla_len(attr));
+							     nla_len(attr),
+							     extack);
 			if (err < 0)
 				goto errout;
 			cfg->fc_mp = nla_data(attr);
@@ -701,7 +702,8 @@ static int rtm_to_fib_config(struct net *net, struct sk_buff *skb,
 			break;
 		case RTA_ENCAP_TYPE:
 			cfg->fc_encap_type = nla_get_u16(attr);
-			err = lwtunnel_valid_encap_type(cfg->fc_encap_type);
+			err = lwtunnel_valid_encap_type(cfg->fc_encap_type,
+							extack);
 			if (err < 0)
 				goto errout;
 			break;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 80bda31ffbbe..afc76b24ee6b 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -3016,7 +3016,7 @@ static int rtm_to_fib6_config(struct sk_buff *skb, struct nlmsghdr *nlh,
 		cfg->fc_mp_len = nla_len(tb[RTA_MULTIPATH]);
 
 		err = lwtunnel_valid_encap_type_attr(cfg->fc_mp,
-						     cfg->fc_mp_len);
+						     cfg->fc_mp_len, extack);
 		if (err < 0)
 			goto errout;
 	}
@@ -3035,7 +3035,7 @@ static int rtm_to_fib6_config(struct sk_buff *skb, struct nlmsghdr *nlh,
 	if (tb[RTA_ENCAP_TYPE]) {
 		cfg->fc_encap_type = nla_get_u16(tb[RTA_ENCAP_TYPE]);
 
-		err = lwtunnel_valid_encap_type(cfg->fc_encap_type);
+		err = lwtunnel_valid_encap_type(cfg->fc_encap_type, extack);
 		if (err < 0)
 			goto errout;
 	}
-- 
2.11.0 (Apple Git-81)

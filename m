From: David Ahern <dsahern@gmail.com>
Subject: [PATCH net-next 2/4] net: ipv4: Add extack messages for route add failures
Date: Sun, 21 May 2017 10:12:03 -0600
Message-ID: <20170521161205.36720-3-dsahern@gmail.com>
References: <20170521161205.36720-1-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33557 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756727AbdEUQMW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 21 May 2017 12:12:22 -0400
Received: by mail-pf0-f196.google.com with SMTP id f27so14790186pfe.0
        for <netdev@vger.kernel.org>; Sun, 21 May 2017 09:12:22 -0700 (PDT)
In-Reply-To: <20170521161205.36720-1-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add messages for non-obvious errors (e.g, no need to add text for malloc
failures or ENODEV failures). This mostly covers the annoying EINVAL errors
Some message strings violate the 80-columns but searchable strings need to
trump that rule.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 include/linux/netlink.h  |   5 +++
 net/ipv4/fib_frontend.c  |   2 +
 net/ipv4/fib_semantics.c | 115 ++++++++++++++++++++++++++++++++++++++---------
 3 files changed, 100 insertions(+), 22 deletions(-)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index 5fff5ba5964e..a68aad484c69 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -97,6 +97,11 @@ struct netlink_ext_ack {
 #define NL_SET_ERR_MSG_MOD(extack, msg)			\
 	NL_SET_ERR_MSG((extack), KBUILD_MODNAME ": " msg)
 
+#define NL_SET_BAD_ATTR(extack, attr) do {		\
+	if ((extack))					\
+		(extack)->bad_attr = (attr);		\
+} while (0)
+
 extern void netlink_kernel_release(struct sock *sk);
 extern int __netlink_change_ngroups(struct sock *sk, unsigned int groups);
 extern int netlink_change_ngroups(struct sock *sk, unsigned int groups);
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 511edff76c01..14d2f7bd7c76 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -656,6 +656,7 @@ static int rtm_to_fib_config(struct net *net, struct sk_buff *skb,
 	cfg->fc_nlinfo.nl_net = net;
 
 	if (cfg->fc_type > RTN_MAX) {
+		NL_SET_ERR_MSG(extack, "Invalid route type");
 		err = -EINVAL;
 		goto errout;
 	}
@@ -726,6 +727,7 @@ static int inet_rtm_delroute(struct sk_buff *skb, struct nlmsghdr *nlh,
 
 	tb = fib_get_table(net, cfg.fc_table);
 	if (!tb) {
+		NL_SET_ERR_MSG(extack, "FIB table does not exist");
 		err = -ESRCH;
 		goto errout;
 	}
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 8587d1b55b53..4852e183afe0 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -32,6 +32,7 @@
 #include <linux/skbuff.h>
 #include <linux/init.h>
 #include <linux/slab.h>
+#include <linux/netlink.h>
 
 #include <net/arp.h>
 #include <net/ip.h>
@@ -465,7 +466,13 @@ static int fib_count_nexthops(struct rtnexthop *rtnh, int remaining,
 	}
 
 	/* leftover implies invalid nexthop configuration, discard it */
-	return remaining > 0 ? 0 : nhs;
+	if (remaining > 0) {
+		NL_SET_ERR_MSG(extack,
+			       "Invalid nexthop configuration - extra data after nexthops");
+		nhs = 0;
+	}
+
+	return nhs;
 }
 
 static int fib_get_nhs(struct fib_info *fi, struct rtnexthop *rtnh,
@@ -477,11 +484,17 @@ static int fib_get_nhs(struct fib_info *fi, struct rtnexthop *rtnh,
 	change_nexthops(fi) {
 		int attrlen;
 
-		if (!rtnh_ok(rtnh, remaining))
+		if (!rtnh_ok(rtnh, remaining)) {
+			NL_SET_ERR_MSG(extack,
+				       "Invalid nexthop configuration - extra data after nexthop");
 			return -EINVAL;
+		}
 
-		if (rtnh->rtnh_flags & (RTNH_F_DEAD | RTNH_F_LINKDOWN))
+		if (rtnh->rtnh_flags & (RTNH_F_DEAD | RTNH_F_LINKDOWN)) {
+			NL_SET_ERR_MSG(extack,
+				       "Invalid flags for nexthop - can not contain DEAD or LINKDOWN");
 			return -EINVAL;
+		}
 
 		nexthop_nh->nh_flags =
 			(cfg->fc_flags & ~0xFF) | rtnh->rtnh_flags;
@@ -507,8 +520,12 @@ static int fib_get_nhs(struct fib_info *fi, struct rtnexthop *rtnh,
 
 				nla_entype = nla_find(attrs, attrlen,
 						      RTA_ENCAP_TYPE);
-				if (!nla_entype)
+				if (!nla_entype) {
+					NL_SET_BAD_ATTR(extack, nla);
+					NL_SET_ERR_MSG(extack,
+						       "Encap type is missing");
 					goto err_inval;
+				}
 
 				ret = lwtunnel_build_state(nla_get_u16(
 							   nla_entype),
@@ -729,16 +746,25 @@ static int fib_check_nh(struct fib_config *cfg, struct fib_info *fi,
 		if (nh->nh_flags & RTNH_F_ONLINK) {
 			unsigned int addr_type;
 
-			if (cfg->fc_scope >= RT_SCOPE_LINK)
+			if (cfg->fc_scope >= RT_SCOPE_LINK) {
+				NL_SET_ERR_MSG(extack,
+					       "Nexthop has invalid scope");
 				return -EINVAL;
+			}
 			dev = __dev_get_by_index(net, nh->nh_oif);
 			if (!dev)
 				return -ENODEV;
-			if (!(dev->flags & IFF_UP))
+			if (!(dev->flags & IFF_UP)) {
+				NL_SET_ERR_MSG(extack,
+					       "Nexthop device is not up");
 				return -ENETDOWN;
+			}
 			addr_type = inet_addr_type_dev_table(net, dev, nh->nh_gw);
-			if (addr_type != RTN_UNICAST)
+			if (addr_type != RTN_UNICAST) {
+				NL_SET_ERR_MSG(extack,
+					       "Nexthop has invalid gateway");
 				return -EINVAL;
+			}
 			if (!netif_carrier_ok(dev))
 				nh->nh_flags |= RTNH_F_LINKDOWN;
 			nh->nh_dev = dev;
@@ -778,18 +804,25 @@ static int fib_check_nh(struct fib_config *cfg, struct fib_info *fi,
 			}
 
 			if (err) {
+				NL_SET_ERR_MSG(extack,
+					       "Nexthop has invalid gateway");
 				rcu_read_unlock();
 				return err;
 			}
 		}
 		err = -EINVAL;
-		if (res.type != RTN_UNICAST && res.type != RTN_LOCAL)
+		if (res.type != RTN_UNICAST && res.type != RTN_LOCAL) {
+			NL_SET_ERR_MSG(extack, "Nexthop has invalid gateway");
 			goto out;
+		}
 		nh->nh_scope = res.scope;
 		nh->nh_oif = FIB_RES_OIF(res);
 		nh->nh_dev = dev = FIB_RES_DEV(res);
-		if (!dev)
+		if (!dev) {
+			NL_SET_ERR_MSG(extack,
+				       "No egress device for nexthop gateway");
 			goto out;
+		}
 		dev_hold(dev);
 		if (!netif_carrier_ok(dev))
 			nh->nh_flags |= RTNH_F_LINKDOWN;
@@ -797,16 +830,21 @@ static int fib_check_nh(struct fib_config *cfg, struct fib_info *fi,
 	} else {
 		struct in_device *in_dev;
 
-		if (nh->nh_flags & (RTNH_F_PERVASIVE | RTNH_F_ONLINK))
+		if (nh->nh_flags & (RTNH_F_PERVASIVE | RTNH_F_ONLINK)) {
+			NL_SET_ERR_MSG(extack,
+				       "Invalid flags for nexthop - PERVASIVE and ONLINK can not be set");
 			return -EINVAL;
+		}
 		rcu_read_lock();
 		err = -ENODEV;
 		in_dev = inetdev_by_index(net, nh->nh_oif);
 		if (!in_dev)
 			goto out;
 		err = -ENETDOWN;
-		if (!(in_dev->dev->flags & IFF_UP))
+		if (!(in_dev->dev->flags & IFF_UP)) {
+			NL_SET_ERR_MSG(extack, "Device for nexthop is not up");
 			goto out;
+		}
 		nh->nh_dev = in_dev->dev;
 		dev_hold(nh->nh_dev);
 		nh->nh_scope = RT_SCOPE_HOST;
@@ -994,11 +1032,16 @@ struct fib_info *fib_create_info(struct fib_config *cfg,
 		goto err_inval;
 
 	/* Fast check to catch the most weird cases */
-	if (fib_props[cfg->fc_type].scope > cfg->fc_scope)
+	if (fib_props[cfg->fc_type].scope > cfg->fc_scope) {
+		NL_SET_ERR_MSG(extack, "Invalid scope");
 		goto err_inval;
+	}
 
-	if (cfg->fc_flags & (RTNH_F_DEAD | RTNH_F_LINKDOWN))
+	if (cfg->fc_flags & (RTNH_F_DEAD | RTNH_F_LINKDOWN)) {
+		NL_SET_ERR_MSG(extack,
+			       "Invalid rtm_flags - can not contain DEAD or LINKDOWN");
 		goto err_inval;
+	}
 
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 	if (cfg->fc_mp) {
@@ -1067,15 +1110,26 @@ struct fib_info *fib_create_info(struct fib_config *cfg,
 		err = fib_get_nhs(fi, cfg->fc_mp, cfg->fc_mp_len, cfg, extack);
 		if (err != 0)
 			goto failure;
-		if (cfg->fc_oif && fi->fib_nh->nh_oif != cfg->fc_oif)
+		if (cfg->fc_oif && fi->fib_nh->nh_oif != cfg->fc_oif) {
+			NL_SET_ERR_MSG(extack,
+				       "Nexthop device index does not match RTA_OIF");
 			goto err_inval;
-		if (cfg->fc_gw && fi->fib_nh->nh_gw != cfg->fc_gw)
+		}
+		if (cfg->fc_gw && fi->fib_nh->nh_gw != cfg->fc_gw) {
+			NL_SET_ERR_MSG(extack,
+				       "Nexthop gateway does not match RTA_GATEWAY");
 			goto err_inval;
+		}
 #ifdef CONFIG_IP_ROUTE_CLASSID
-		if (cfg->fc_flow && fi->fib_nh->nh_tclassid != cfg->fc_flow)
+		if (cfg->fc_flow && fi->fib_nh->nh_tclassid != cfg->fc_flow) {
+			NL_SET_ERR_MSG(extack,
+				       "Nexthop class id does not match RTA_FLOW");
 			goto err_inval;
+		}
 #endif
 #else
+		NL_SET_ERR_MSG(extack,
+			       "Multipath support not enabled in kernel");
 		goto err_inval;
 #endif
 	} else {
@@ -1084,8 +1138,11 @@ struct fib_info *fib_create_info(struct fib_config *cfg,
 		if (cfg->fc_encap) {
 			struct lwtunnel_state *lwtstate;
 
-			if (cfg->fc_encap_type == LWTUNNEL_ENCAP_NONE)
+			if (cfg->fc_encap_type == LWTUNNEL_ENCAP_NONE) {
+				NL_SET_ERR_MSG(extack,
+					       "LWT encap type not specified");
 				goto err_inval;
+			}
 			err = lwtunnel_build_state(cfg->fc_encap_type,
 						   cfg->fc_encap, AF_INET, cfg,
 						   &lwtstate);
@@ -1108,8 +1165,11 @@ struct fib_info *fib_create_info(struct fib_config *cfg,
 	}
 
 	if (fib_props[cfg->fc_type].error) {
-		if (cfg->fc_gw || cfg->fc_oif || cfg->fc_mp)
+		if (cfg->fc_gw || cfg->fc_oif || cfg->fc_mp) {
+			NL_SET_ERR_MSG(extack,
+				       "Gateway, device and multipath can not be specified for this route type");
 			goto err_inval;
+		}
 		goto link_it;
 	} else {
 		switch (cfg->fc_type) {
@@ -1120,21 +1180,30 @@ struct fib_info *fib_create_info(struct fib_config *cfg,
 		case RTN_MULTICAST:
 			break;
 		default:
+			NL_SET_ERR_MSG(extack, "Invalid route type");
 			goto err_inval;
 		}
 	}
 
-	if (cfg->fc_scope > RT_SCOPE_HOST)
+	if (cfg->fc_scope > RT_SCOPE_HOST) {
+		NL_SET_ERR_MSG(extack, "Invalid scope");
 		goto err_inval;
+	}
 
 	if (cfg->fc_scope == RT_SCOPE_HOST) {
 		struct fib_nh *nh = fi->fib_nh;
 
 		/* Local address is added. */
-		if (nhs != 1)
+		if (nhs != 1) {
+			NL_SET_ERR_MSG(extack,
+				       "Route with host scope can not have multiple nexthops");
 			goto err_inval;
-		if (nh->nh_gw)
+		}
+		if (nh->nh_gw) {
+			NL_SET_ERR_MSG(extack,
+				       "Route with host scope can not have a gateway");
 			goto err_inval;
+		}
 		nh->nh_scope = RT_SCOPE_NOWHERE;
 		nh->nh_dev = dev_get_by_index(net, fi->fib_nh->nh_oif);
 		err = -ENODEV;
@@ -1154,8 +1223,10 @@ struct fib_info *fib_create_info(struct fib_config *cfg,
 			fi->fib_flags |= RTNH_F_LINKDOWN;
 	}
 
-	if (fi->fib_prefsrc && !fib_valid_prefsrc(cfg, fi->fib_prefsrc))
+	if (fi->fib_prefsrc && !fib_valid_prefsrc(cfg, fi->fib_prefsrc)) {
+		NL_SET_ERR_MSG(extack, "Invalid prefsrc address");
 		goto err_inval;
+	}
 
 	change_nexthops(fi) {
 		fib_info_update_nh_saddr(net, nexthop_nh);
-- 
2.11.0 (Apple Git-81)

From: David Ahern <dsahern@gmail.com>
Subject: [PATCH v2 net-next 7/9] net: mpls: Add extack messages for route add and delete failures
Date: Sat, 27 May 2017 16:19:31 -0600
Message-ID: <20170527221933.57644-8-dsahern@gmail.com>
References: <20170527221933.57644-1-dsahern@gmail.com>
Cc: roopa@cumulusnetworks.com, David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34356 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750797AbdE0WTu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 27 May 2017 18:19:50 -0400
Received: by mail-pf0-f196.google.com with SMTP id w69so8209699pfk.1
        for <netdev@vger.kernel.org>; Sat, 27 May 2017 15:19:50 -0700 (PDT)
In-Reply-To: <20170527221933.57644-1-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add error messages for failures in adding and deleting mpls routes.
This covers most of the annoying EINVAL errors.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 net/mpls/af_mpls.c  | 125 ++++++++++++++++++++++++++++++++++++----------------
 net/mpls/internal.h |   2 +-
 2 files changed, 87 insertions(+), 40 deletions(-)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 726eafecc793..0133d1ad9032 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -720,7 +720,8 @@ static int mpls_nh_build_from_cfg(struct mpls_route_config *cfg,
 
 static int mpls_nh_build(struct net *net, struct mpls_route *rt,
 			 struct mpls_nh *nh, int oif, struct nlattr *via,
-			 struct nlattr *newdst, u8 max_labels)
+			 struct nlattr *newdst, u8 max_labels,
+			 struct netlink_ext_ack *extack)
 {
 	int err = -ENOMEM;
 
@@ -729,14 +730,14 @@ static int mpls_nh_build(struct net *net, struct mpls_route *rt,
 
 	if (newdst) {
 		err = nla_get_labels(newdst, max_labels, &nh->nh_labels,
-				     nh->nh_label, NULL);
+				     nh->nh_label, extack);
 		if (err)
 			goto errout;
 	}
 
 	if (via) {
 		err = nla_get_via(via, &nh->nh_via_alen, &nh->nh_via_table,
-				  __mpls_nh_via(rt, nh));
+				  __mpls_nh_via(rt, nh), extack);
 		if (err)
 			goto errout;
 	} else {
@@ -803,7 +804,8 @@ static u8 mpls_count_nexthops(struct rtnexthop *rtnh, int len,
 }
 
 static int mpls_nh_build_multi(struct mpls_route_config *cfg,
-			       struct mpls_route *rt, u8 max_labels)
+			       struct mpls_route *rt, u8 max_labels,
+			       struct netlink_ext_ack *extack)
 {
 	struct rtnexthop *rtnh = cfg->rc_mp;
 	struct nlattr *nla_via, *nla_newdst;
@@ -837,7 +839,7 @@ static int mpls_nh_build_multi(struct mpls_route_config *cfg,
 
 		err = mpls_nh_build(cfg->rc_nlinfo.nl_net, rt, nh,
 				    rtnh->rtnh_ifindex, nla_via, nla_newdst,
-				    max_labels);
+				    max_labels, extack);
 		if (err)
 			goto errout;
 
@@ -856,20 +858,28 @@ static int mpls_nh_build_multi(struct mpls_route_config *cfg,
 	return err;
 }
 
-static bool mpls_label_ok(struct net *net, unsigned int index)
+static bool mpls_label_ok(struct net *net, unsigned int index,
+			  struct netlink_ext_ack *extack)
 {
 	/* Reserved labels may not be set */
-	if (index < MPLS_LABEL_FIRST_UNRESERVED)
+	if (index < MPLS_LABEL_FIRST_UNRESERVED) {
+		NL_SET_ERR_MSG(extack,
+			       "Invalid label - must be MPLS_LABEL_FIRST_UNRESERVED or higher");
 		return false;
+	}
 
 	/* The full 20 bit range may not be supported. */
-	if (index >= net->mpls.platform_labels)
+	if (index >= net->mpls.platform_labels) {
+		NL_SET_ERR_MSG(extack,
+			       "Label >= configured maximum in platform_labels");
 		return false;
+	}
 
 	return true;
 }
 
-static int mpls_route_add(struct mpls_route_config *cfg)
+static int mpls_route_add(struct mpls_route_config *cfg,
+			  struct netlink_ext_ack *extack)
 {
 	struct mpls_route __rcu **platform_label;
 	struct net *net = cfg->rc_nlinfo.nl_net;
@@ -888,13 +898,15 @@ static int mpls_route_add(struct mpls_route_config *cfg)
 		index = find_free_label(net);
 	}
 
-	if (!mpls_label_ok(net, index))
+	if (!mpls_label_ok(net, index, extack))
 		goto errout;
 
 	/* Append makes no sense with mpls */
 	err = -EOPNOTSUPP;
-	if (cfg->rc_nlflags & NLM_F_APPEND)
+	if (cfg->rc_nlflags & NLM_F_APPEND) {
+		NL_SET_ERR_MSG(extack, "MPLS does not support route append");
 		goto errout;
+	}
 
 	err = -EEXIST;
 	platform_label = rtnl_dereference(net->mpls.platform_label);
@@ -921,8 +933,10 @@ static int mpls_route_add(struct mpls_route_config *cfg)
 		nhs = 1;
 	}
 
-	if (nhs == 0)
+	if (nhs == 0) {
+		NL_SET_ERR_MSG(extack, "Route does not contain a nexthop");
 		goto errout;
+	}
 
 	err = -ENOMEM;
 	rt = mpls_rt_alloc(nhs, max_via_alen, max_labels);
@@ -936,7 +950,7 @@ static int mpls_route_add(struct mpls_route_config *cfg)
 	rt->rt_ttl_propagate = cfg->rc_ttl_propagate;
 
 	if (cfg->rc_mp)
-		err = mpls_nh_build_multi(cfg, rt, max_labels);
+		err = mpls_nh_build_multi(cfg, rt, max_labels, extack);
 	else
 		err = mpls_nh_build_from_cfg(cfg, rt);
 	if (err)
@@ -952,7 +966,8 @@ static int mpls_route_add(struct mpls_route_config *cfg)
 	return err;
 }
 
-static int mpls_route_del(struct mpls_route_config *cfg)
+static int mpls_route_del(struct mpls_route_config *cfg,
+			  struct netlink_ext_ack *extack)
 {
 	struct net *net = cfg->rc_nlinfo.nl_net;
 	unsigned index;
@@ -960,7 +975,7 @@ static int mpls_route_del(struct mpls_route_config *cfg)
 
 	index = cfg->rc_label;
 
-	if (!mpls_label_ok(net, index))
+	if (!mpls_label_ok(net, index, extack))
 		goto errout;
 
 	mpls_route_update(net, index, NULL, &cfg->rc_nlinfo);
@@ -1626,19 +1641,25 @@ int nla_get_labels(const struct nlattr *nla, u8 max_labels, u8 *labels,
 }
 EXPORT_SYMBOL_GPL(nla_get_labels);
 
-int nla_get_via(const struct nlattr *nla, u8 *via_alen,
-		u8 *via_table, u8 via_addr[])
+int nla_get_via(const struct nlattr *nla, u8 *via_alen, u8 *via_table,
+		u8 via_addr[], struct netlink_ext_ack *extack)
 {
 	struct rtvia *via = nla_data(nla);
 	int err = -EINVAL;
 	int alen;
 
-	if (nla_len(nla) < offsetof(struct rtvia, rtvia_addr))
+	if (nla_len(nla) < offsetof(struct rtvia, rtvia_addr)) {
+		NL_SET_ERR_MSG_ATTR(extack, nla,
+				    "Invalid attribute length for RTA_VIA");
 		goto errout;
+	}
 	alen = nla_len(nla) -
 			offsetof(struct rtvia, rtvia_addr);
-	if (alen > MAX_VIA_ALEN)
+	if (alen > MAX_VIA_ALEN) {
+		NL_SET_ERR_MSG_ATTR(extack, nla,
+				    "Invalid address length for RTA_VIA");
 		goto errout;
+	}
 
 	/* Validate the address family */
 	switch (via->rtvia_family) {
@@ -1668,8 +1689,10 @@ int nla_get_via(const struct nlattr *nla, u8 *via_alen,
 	return err;
 }
 
-static int rtm_to_route_config(struct sk_buff *skb,  struct nlmsghdr *nlh,
-			       struct mpls_route_config *cfg)
+static int rtm_to_route_config(struct sk_buff *skb,
+			       struct nlmsghdr *nlh,
+			       struct mpls_route_config *cfg,
+			       struct netlink_ext_ack *extack)
 {
 	struct rtmsg *rtm;
 	struct nlattr *tb[RTA_MAX+1];
@@ -1677,35 +1700,54 @@ static int rtm_to_route_config(struct sk_buff *skb,  struct nlmsghdr *nlh,
 	int err;
 
 	err = nlmsg_parse(nlh, sizeof(*rtm), tb, RTA_MAX, rtm_mpls_policy,
-			  NULL);
+			  extack);
 	if (err < 0)
 		goto errout;
 
 	err = -EINVAL;
 	rtm = nlmsg_data(nlh);
 
-	if (rtm->rtm_family != AF_MPLS)
+	if (rtm->rtm_family != AF_MPLS) {
+		NL_SET_ERR_MSG(extack, "Invalid address family in rtmsg");
 		goto errout;
-	if (rtm->rtm_dst_len != 20)
+	}
+	if (rtm->rtm_dst_len != 20) {
+		NL_SET_ERR_MSG(extack, "rtm_dst_len must be 20 for MPLS");
 		goto errout;
-	if (rtm->rtm_src_len != 0)
+	}
+	if (rtm->rtm_src_len != 0) {
+		NL_SET_ERR_MSG(extack, "rtm_src_len must be 0 for MPLS");
 		goto errout;
-	if (rtm->rtm_tos != 0)
+	}
+	if (rtm->rtm_tos != 0) {
+		NL_SET_ERR_MSG(extack, "rtm_tos must be 0 for MPLS");
 		goto errout;
-	if (rtm->rtm_table != RT_TABLE_MAIN)
+	}
+	if (rtm->rtm_table != RT_TABLE_MAIN) {
+		NL_SET_ERR_MSG(extack,
+			       "MPLS only supports the main route table");
 		goto errout;
+	}
 	/* Any value is acceptable for rtm_protocol */
 
 	/* As mpls uses destination specific addresses
 	 * (or source specific address in the case of multicast)
 	 * all addresses have universal scope.
 	 */
-	if (rtm->rtm_scope != RT_SCOPE_UNIVERSE)
+	if (rtm->rtm_scope != RT_SCOPE_UNIVERSE) {
+		NL_SET_ERR_MSG(extack,
+			       "Invalid route scope  - MPLS only supports UNIVERSE");
 		goto errout;
-	if (rtm->rtm_type != RTN_UNICAST)
+	}
+	if (rtm->rtm_type != RTN_UNICAST) {
+		NL_SET_ERR_MSG(extack,
+			       "Invalid route type - MPLS only supports UNICAST");
 		goto errout;
-	if (rtm->rtm_flags != 0)
+	}
+	if (rtm->rtm_flags != 0) {
+		NL_SET_ERR_MSG(extack, "rtm_flags must be 0 for MPLS");
 		goto errout;
+	}
 
 	cfg->rc_label		= LABEL_NOT_SPECIFIED;
 	cfg->rc_protocol	= rtm->rtm_protocol;
@@ -1728,25 +1770,26 @@ static int rtm_to_route_config(struct sk_buff *skb,  struct nlmsghdr *nlh,
 		case RTA_NEWDST:
 			if (nla_get_labels(nla, MAX_NEW_LABELS,
 					   &cfg->rc_output_labels,
-					   cfg->rc_output_label, NULL))
+					   cfg->rc_output_label, extack))
 				goto errout;
 			break;
 		case RTA_DST:
 		{
 			u8 label_count;
 			if (nla_get_labels(nla, 1, &label_count,
-					   &cfg->rc_label, NULL))
+					   &cfg->rc_label, extack))
 				goto errout;
 
 			if (!mpls_label_ok(cfg->rc_nlinfo.nl_net,
-					   cfg->rc_label))
+					   cfg->rc_label, extack))
 				goto errout;
 			break;
 		}
 		case RTA_VIA:
 		{
 			if (nla_get_via(nla, &cfg->rc_via_alen,
-					&cfg->rc_via_table, cfg->rc_via))
+					&cfg->rc_via_table, cfg->rc_via,
+					extack))
 				goto errout;
 			break;
 		}
@@ -1760,14 +1803,18 @@ static int rtm_to_route_config(struct sk_buff *skb,  struct nlmsghdr *nlh,
 		{
 			u8 ttl_propagate = nla_get_u8(nla);
 
-			if (ttl_propagate > 1)
+			if (ttl_propagate > 1) {
+				NL_SET_ERR_MSG_ATTR(extack, nla,
+						    "RTA_TTL_PROPAGATE can only be 0 or 1");
 				goto errout;
+			}
 			cfg->rc_ttl_propagate = ttl_propagate ?
 				MPLS_TTL_PROP_ENABLED :
 				MPLS_TTL_PROP_DISABLED;
 			break;
 		}
 		default:
+			NL_SET_ERR_MSG_ATTR(extack, nla, "Unknown attribute");
 			/* Unsupported attribute */
 			goto errout;
 		}
@@ -1788,11 +1835,11 @@ static int mpls_rtm_delroute(struct sk_buff *skb, struct nlmsghdr *nlh,
 	if (!cfg)
 		return -ENOMEM;
 
-	err = rtm_to_route_config(skb, nlh, cfg);
+	err = rtm_to_route_config(skb, nlh, cfg, extack);
 	if (err < 0)
 		goto out;
 
-	err = mpls_route_del(cfg);
+	err = mpls_route_del(cfg, extack);
 out:
 	kfree(cfg);
 
@@ -1810,11 +1857,11 @@ static int mpls_rtm_newroute(struct sk_buff *skb, struct nlmsghdr *nlh,
 	if (!cfg)
 		return -ENOMEM;
 
-	err = rtm_to_route_config(skb, nlh, cfg);
+	err = rtm_to_route_config(skb, nlh, cfg, extack);
 	if (err < 0)
 		goto out;
 
-	err = mpls_route_add(cfg);
+	err = mpls_route_add(cfg, extack);
 out:
 	kfree(cfg);
 
diff --git a/net/mpls/internal.h b/net/mpls/internal.h
index e59f299ceb3f..a015a6a1143b 100644
--- a/net/mpls/internal.h
+++ b/net/mpls/internal.h
@@ -205,7 +205,7 @@ int nla_put_labels(struct sk_buff *skb, int attrtype,  u8 labels,
 int nla_get_labels(const struct nlattr *nla, u8 max_labels, u8 *labels,
 		   u32 label[], struct netlink_ext_ack *extack);
 int nla_get_via(const struct nlattr *nla, u8 *via_alen, u8 *via_table,
-		u8 via[]);
+		u8 via[], struct netlink_ext_ack *extack);
 bool mpls_output_possible(const struct net_device *dev);
 unsigned int mpls_dev_mtu(const struct net_device *dev);
 bool mpls_pkt_too_big(const struct sk_buff *skb, unsigned int mtu);
-- 
2.11.0 (Apple Git-81)

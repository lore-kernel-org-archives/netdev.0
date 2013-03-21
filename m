From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next 1/2] decnet: Parse netlink attributes on our own
Date: Thu, 21 Mar 2013 18:45:28 +0100
Message-ID: <5b888618a6aebfebf496c91482794a606b3bb094.1363885020.git.tgraf@suug.ch>
References: <cover.1363885020.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, linux-decnet-user@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 173-166-109-252-newengland.hfc.comcastbusiness.net ([173.166.109.252]:39002
	"EHLO bombadil.infradead.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751387Ab3CURph (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 13:45:37 -0400
In-Reply-To: <cover.1363885020.git.tgraf@suug.ch>
In-Reply-To: <cover.1363885020.git.tgraf@suug.ch>
References: <cover.1363885020.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

decnet is the only subsystem left that is relying on the global
netlink attribute buffer rta_buf. It's horrible design and we
want to get rid of it.

This converts all of decnet to do implicit attribute parsing. It
also gets rid of the error prone struct dn_kern_rta.

Yes, the fib_magic() stuff is not pretty.

It's compiled tested but I need someone with appropriate hardware
to test the patch since I don't have access to it.

Cc: linux-decnet-user@lists.sourceforge.net
Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 include/net/dn_fib.h  |  28 ++-----
 net/decnet/dn_fib.c   | 211 +++++++++++++++++++++++++++-----------------------
 net/decnet/dn_route.c |  27 ++++---
 net/decnet/dn_table.c |  42 +++++-----
 4 files changed, 160 insertions(+), 148 deletions(-)

diff --git a/include/net/dn_fib.h b/include/net/dn_fib.h
index 1ee9d4b..74004af 100644
--- a/include/net/dn_fib.h
+++ b/include/net/dn_fib.h
@@ -1,24 +1,9 @@
 #ifndef _NET_DN_FIB_H
 #define _NET_DN_FIB_H
 
-/* WARNING: The ordering of these elements must match ordering
- *          of RTA_* rtnetlink attribute numbers.
- */
-struct dn_kern_rta {
-        void            *rta_dst;
-        void            *rta_src;
-        int             *rta_iif;
-        int             *rta_oif;
-        void            *rta_gw;
-        u32             *rta_priority;
-        void            *rta_prefsrc;
-        struct rtattr   *rta_mx;
-        struct rtattr   *rta_mp;
-        unsigned char   *rta_protoinfo;
-        u32             *rta_flow;
-        struct rta_cacheinfo *rta_ci;
-	struct rta_session *rta_sess;
-};
+#include <linux/netlink.h>
+
+extern const struct nla_policy rtm_dn_policy[];
 
 struct dn_fib_res {
 	struct fib_rule *r;
@@ -93,10 +78,10 @@ struct dn_fib_table {
 	u32 n;
 
 	int (*insert)(struct dn_fib_table *t, struct rtmsg *r, 
-			struct dn_kern_rta *rta, struct nlmsghdr *n, 
+			struct nlattr *attrs[], struct nlmsghdr *n,
 			struct netlink_skb_parms *req);
 	int (*delete)(struct dn_fib_table *t, struct rtmsg *r,
-			struct dn_kern_rta *rta, struct nlmsghdr *n,
+			struct nlattr *attrs[], struct nlmsghdr *n,
 			struct netlink_skb_parms *req);
 	int (*lookup)(struct dn_fib_table *t, const struct flowidn *fld,
 			struct dn_fib_res *res);
@@ -116,13 +101,12 @@ extern void dn_fib_cleanup(void);
 extern int dn_fib_ioctl(struct socket *sock, unsigned int cmd, 
 			unsigned long arg);
 extern struct dn_fib_info *dn_fib_create_info(const struct rtmsg *r, 
-				struct dn_kern_rta *rta, 
+				struct nlattr *attrs[],
 				const struct nlmsghdr *nlh, int *errp);
 extern int dn_fib_semantic_match(int type, struct dn_fib_info *fi, 
 			const struct flowidn *fld,
 			struct dn_fib_res *res);
 extern void dn_fib_release_info(struct dn_fib_info *fi);
-extern __le16 dn_fib_get_attr16(struct rtattr *attr, int attrlen, int type);
 extern void dn_fib_flush(void);
 extern void dn_fib_select_multipath(const struct flowidn *fld,
 					struct dn_fib_res *res);
diff --git a/net/decnet/dn_fib.c b/net/decnet/dn_fib.c
index e36614e..42a8048 100644
--- a/net/decnet/dn_fib.c
+++ b/net/decnet/dn_fib.c
@@ -145,22 +145,10 @@ static inline struct dn_fib_info *dn_fib_find_info(const struct dn_fib_info *nfi
 	return NULL;
 }
 
-__le16 dn_fib_get_attr16(struct rtattr *attr, int attrlen, int type)
+static int dn_fib_count_nhs(const struct nlattr *attr)
 {
-	while(RTA_OK(attr,attrlen)) {
-		if (attr->rta_type == type)
-			return *(__le16*)RTA_DATA(attr);
-		attr = RTA_NEXT(attr, attrlen);
-	}
-
-	return 0;
-}
-
-static int dn_fib_count_nhs(struct rtattr *rta)
-{
-	int nhs = 0;
-	struct rtnexthop *nhp = RTA_DATA(rta);
-	int nhlen = RTA_PAYLOAD(rta);
+	struct rtnexthop *nhp = nla_data(attr);
+	int nhs = 0, nhlen = nla_len(attr);
 
 	while(nhlen >= (int)sizeof(struct rtnexthop)) {
 		if ((nhlen -= nhp->rtnh_len) < 0)
@@ -172,10 +160,11 @@ static int dn_fib_count_nhs(struct rtattr *rta)
 	return nhs;
 }
 
-static int dn_fib_get_nhs(struct dn_fib_info *fi, const struct rtattr *rta, const struct rtmsg *r)
+static int dn_fib_get_nhs(struct dn_fib_info *fi, const struct nlattr *attr,
+			  const struct rtmsg *r)
 {
-	struct rtnexthop *nhp = RTA_DATA(rta);
-	int nhlen = RTA_PAYLOAD(rta);
+	struct rtnexthop *nhp = nla_data(attr);
+	int nhlen = nla_len(attr);
 
 	change_nexthops(fi) {
 		int attrlen = nhlen - sizeof(struct rtnexthop);
@@ -187,7 +176,10 @@ static int dn_fib_get_nhs(struct dn_fib_info *fi, const struct rtattr *rta, cons
 		nh->nh_weight = nhp->rtnh_hops + 1;
 
 		if (attrlen) {
-			nh->nh_gw = dn_fib_get_attr16(RTNH_DATA(nhp), attrlen, RTA_GATEWAY);
+			struct nlattr *gw_attr;
+
+			gw_attr = nla_find((struct nlattr *) (nhp + 1), attrlen, RTA_GATEWAY);
+			nh->nh_gw = gw_attr ? nla_get_le16(gw_attr) : 0;
 		}
 		nhp = RTNH_NEXT(nhp);
 	} endfor_nexthops(fi);
@@ -268,7 +260,8 @@ out:
 }
 
 
-struct dn_fib_info *dn_fib_create_info(const struct rtmsg *r, struct dn_kern_rta *rta, const struct nlmsghdr *nlh, int *errp)
+struct dn_fib_info *dn_fib_create_info(const struct rtmsg *r, struct nlattr *attrs[],
+				       const struct nlmsghdr *nlh, int *errp)
 {
 	int err;
 	struct dn_fib_info *fi = NULL;
@@ -281,11 +274,9 @@ struct dn_fib_info *dn_fib_create_info(const struct rtmsg *r, struct dn_kern_rta
 	if (dn_fib_props[r->rtm_type].scope > r->rtm_scope)
 		goto err_inval;
 
-	if (rta->rta_mp) {
-		nhs = dn_fib_count_nhs(rta->rta_mp);
-		if (nhs == 0)
-			goto err_inval;
-	}
+	if (attrs[RTA_MULTIPATH] &&
+	    (nhs = dn_fib_count_nhs(attrs[RTA_MULTIPATH])) == 0)
+		goto err_inval;
 
 	fi = kzalloc(sizeof(*fi)+nhs*sizeof(struct dn_fib_nh), GFP_KERNEL);
 	err = -ENOBUFS;
@@ -295,53 +286,65 @@ struct dn_fib_info *dn_fib_create_info(const struct rtmsg *r, struct dn_kern_rta
 	fi->fib_protocol = r->rtm_protocol;
 	fi->fib_nhs = nhs;
 	fi->fib_flags = r->rtm_flags;
-	if (rta->rta_priority)
-		fi->fib_priority = *rta->rta_priority;
-	if (rta->rta_mx) {
-		int attrlen = RTA_PAYLOAD(rta->rta_mx);
-		struct rtattr *attr = RTA_DATA(rta->rta_mx);
 
-		while(RTA_OK(attr, attrlen)) {
-			unsigned int flavour = attr->rta_type;
+	if (attrs[RTA_PRIORITY])
+		fi->fib_priority = nla_get_u32(attrs[RTA_PRIORITY]);
+
+	if (attrs[RTA_METRICS]) {
+		struct nlattr *attr;
+		int rem;
 
-			if (flavour) {
-				if (flavour > RTAX_MAX)
+		nla_for_each_nested(attr, attrs[RTA_METRICS], rem) {
+			int type = nla_type(attr);
+
+			if (type) {
+				if (type > RTAX_MAX || nla_len(attr) < 4)
 					goto err_inval;
-				fi->fib_metrics[flavour-1] = *(unsigned int *)RTA_DATA(attr);
+
+				fi->fib_metrics[type-1] = nla_get_u32(attr);
 			}
-			attr = RTA_NEXT(attr, attrlen);
 		}
 	}
-	if (rta->rta_prefsrc)
-		memcpy(&fi->fib_prefsrc, rta->rta_prefsrc, 2);
 
-	if (rta->rta_mp) {
-		if ((err = dn_fib_get_nhs(fi, rta->rta_mp, r)) != 0)
+	if (attrs[RTA_PREFSRC])
+		fi->fib_prefsrc = nla_get_le16(attrs[RTA_PREFSRC]);
+
+	if (attrs[RTA_MULTIPATH]) {
+		if ((err = dn_fib_get_nhs(fi, attrs[RTA_MULTIPATH], r)) != 0)
 			goto failure;
-		if (rta->rta_oif && fi->fib_nh->nh_oif != *rta->rta_oif)
+
+		if (attrs[RTA_OIF] &&
+		    fi->fib_nh->nh_oif != nla_get_u32(attrs[RTA_OIF]))
 			goto err_inval;
-		if (rta->rta_gw && memcmp(&fi->fib_nh->nh_gw, rta->rta_gw, 2))
+
+		if (attrs[RTA_GATEWAY] &&
+		    fi->fib_nh->nh_gw != nla_get_le16(attrs[RTA_GATEWAY]))
 			goto err_inval;
 	} else {
 		struct dn_fib_nh *nh = fi->fib_nh;
-		if (rta->rta_oif)
-			nh->nh_oif = *rta->rta_oif;
-		if (rta->rta_gw)
-			memcpy(&nh->nh_gw, rta->rta_gw, 2);
+
+		if (attrs[RTA_OIF])
+			nh->nh_oif = nla_get_u32(attrs[RTA_OIF]);
+
+		if (attrs[RTA_GATEWAY])
+			nh->nh_gw = nla_get_le16(attrs[RTA_GATEWAY]);
+
 		nh->nh_flags = r->rtm_flags;
 		nh->nh_weight = 1;
 	}
 
 	if (r->rtm_type == RTN_NAT) {
-		if (rta->rta_gw == NULL || nhs != 1 || rta->rta_oif)
+		if (!attrs[RTA_GATEWAY] || nhs != 1 || attrs[RTA_OIF])
 			goto err_inval;
-		memcpy(&fi->fib_nh->nh_gw, rta->rta_gw, 2);
+
+		fi->fib_nh->nh_gw = nla_get_le16(attrs[RTA_GATEWAY]);
 		goto link_it;
 	}
 
 	if (dn_fib_props[r->rtm_type].error) {
-		if (rta->rta_gw || rta->rta_oif || rta->rta_mp)
+		if (attrs[RTA_GATEWAY] || attrs[RTA_OIF] || attrs[RTA_MULTIPATH])
 			goto err_inval;
+
 		goto link_it;
 	}
 
@@ -367,8 +370,8 @@ struct dn_fib_info *dn_fib_create_info(const struct rtmsg *r, struct dn_kern_rta
 	}
 
 	if (fi->fib_prefsrc) {
-		if (r->rtm_type != RTN_LOCAL || rta->rta_dst == NULL ||
-		    memcmp(&fi->fib_prefsrc, rta->rta_dst, 2))
+		if (r->rtm_type != RTN_LOCAL || !attrs[RTA_DST] ||
+		    fi->fib_prefsrc != nla_get_le16(attrs[RTA_DST]))
 			if (dnet_addr_type(fi->fib_prefsrc) != RTN_LOCAL)
 				goto err_inval;
 	}
@@ -486,29 +489,24 @@ void dn_fib_select_multipath(const struct flowidn *fld, struct dn_fib_res *res)
 	spin_unlock_bh(&dn_fib_multipath_lock);
 }
 
+const struct nla_policy rtm_dn_policy[RTA_MAX + 1] = {
+	[RTA_DST]		= { .type = NLA_U16 },
+	[RTA_SRC]		= { .type = NLA_U16 },
+	[RTA_IIF]		= { .type = NLA_U32 },
+	[RTA_OIF]		= { .type = NLA_U32 },
+	[RTA_GATEWAY]		= { .type = NLA_U16 },
+	[RTA_PRIORITY]		= { .type = NLA_U32 },
+	[RTA_PREFSRC]		= { .type = NLA_U16 },
+	[RTA_METRICS]		= { .type = NLA_NESTED },
+	[RTA_MULTIPATH]		= { .type = NLA_NESTED },
+	[RTA_TABLE]		= { .type = NLA_U32 },
+	[RTA_MARK]		= { .type = NLA_U32 },
+};
 
-static int dn_fib_check_attr(struct rtmsg *r, struct rtattr **rta)
-{
-	int i;
-
-	for(i = 1; i <= RTA_MAX; i++) {
-		struct rtattr *attr = rta[i-1];
-		if (attr) {
-			if (RTA_PAYLOAD(attr) < 4 && RTA_PAYLOAD(attr) != 2)
-				return -EINVAL;
-			if (i != RTA_MULTIPATH && i != RTA_METRICS &&
-			    i != RTA_TABLE)
-				rta[i-1] = (struct rtattr *)RTA_DATA(attr);
-		}
-	}
-
-	return 0;
-}
-
-static inline u32 rtm_get_table(struct rtattr **rta, u8 table)
+static inline u32 rtm_get_table(struct nlattr *attrs[], u8 table)
 {
-	if (rta[RTA_TABLE - 1])
-		table = nla_get_u32((struct nlattr *) rta[RTA_TABLE - 1]);
+	if (attrs[RTA_TABLE])
+		table = nla_get_u32(attrs[RTA_TABLE]);
 
 	return table;
 }
@@ -517,8 +515,9 @@ static int dn_fib_rtm_delroute(struct sk_buff *skb, struct nlmsghdr *nlh, void *
 {
 	struct net *net = sock_net(skb->sk);
 	struct dn_fib_table *tb;
-	struct rtattr **rta = arg;
-	struct rtmsg *r = NLMSG_DATA(nlh);
+	struct rtmsg *r = nlmsg_data(nlh);
+	struct nlattr *attrs[RTA_MAX+1];
+	int err;
 
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
@@ -526,22 +525,24 @@ static int dn_fib_rtm_delroute(struct sk_buff *skb, struct nlmsghdr *nlh, void *
 	if (!net_eq(net, &init_net))
 		return -EINVAL;
 
-	if (dn_fib_check_attr(r, rta))
-		return -EINVAL;
+	err = nlmsg_parse(nlh, sizeof(*r), attrs, RTA_MAX, rtm_dn_policy);
+	if (err < 0)
+		return err;
 
-	tb = dn_fib_get_table(rtm_get_table(rta, r->rtm_table), 0);
-	if (tb)
-		return tb->delete(tb, r, (struct dn_kern_rta *)rta, nlh, &NETLINK_CB(skb));
+	tb = dn_fib_get_table(rtm_get_table(attrs, r->rtm_table), 0);
+	if (!tb)
+		return -ESRCH;
 
-	return -ESRCH;
+	return tb->delete(tb, r, attrs, nlh, &NETLINK_CB(skb));
 }
 
 static int dn_fib_rtm_newroute(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 {
 	struct net *net = sock_net(skb->sk);
 	struct dn_fib_table *tb;
-	struct rtattr **rta = arg;
-	struct rtmsg *r = NLMSG_DATA(nlh);
+	struct rtmsg *r = nlmsg_data(nlh);
+	struct nlattr *attrs[RTA_MAX+1];
+	int err;
 
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
@@ -549,14 +550,15 @@ static int dn_fib_rtm_newroute(struct sk_buff *skb, struct nlmsghdr *nlh, void *
 	if (!net_eq(net, &init_net))
 		return -EINVAL;
 
-	if (dn_fib_check_attr(r, rta))
-		return -EINVAL;
+	err = nlmsg_parse(nlh, sizeof(*r), attrs, RTA_MAX, rtm_dn_policy);
+	if (err < 0)
+		return err;
 
-	tb = dn_fib_get_table(rtm_get_table(rta, r->rtm_table), 1);
-	if (tb)
-		return tb->insert(tb, r, (struct dn_kern_rta *)rta, nlh, &NETLINK_CB(skb));
+	tb = dn_fib_get_table(rtm_get_table(attrs, r->rtm_table), 1);
+	if (!tb)
+		return -ENOBUFS;
 
-	return -ENOBUFS;
+	return tb->insert(tb, r, attrs, nlh, &NETLINK_CB(skb));
 }
 
 static void fib_magic(int cmd, int type, __le16 dst, int dst_len, struct dn_ifaddr *ifa)
@@ -566,10 +568,31 @@ static void fib_magic(int cmd, int type, __le16 dst, int dst_len, struct dn_ifad
 		struct nlmsghdr nlh;
 		struct rtmsg rtm;
 	} req;
-	struct dn_kern_rta rta;
+	struct {
+		struct nlattr hdr;
+		__le16 dst;
+	} dst_attr = {
+		.dst = dst,
+	};
+	struct {
+		struct nlattr hdr;
+		__le16 prefsrc;
+	} prefsrc_attr = {
+		.prefsrc = ifa->ifa_local,
+	};
+	struct {
+		struct nlattr hdr;
+		u32 oif;
+	} oif_attr = {
+		.oif = ifa->ifa_dev->dev->ifindex,
+	};
+	struct nlattr *attrs[RTA_MAX+1] = {
+		[RTA_DST] = (struct nlattr *) &dst_attr,
+		[RTA_PREFSRC] = (struct nlattr * ) &prefsrc_attr,
+		[RTA_OIF] = (struct nlattr *) &oif_attr,
+	};
 
 	memset(&req.rtm, 0, sizeof(req.rtm));
-	memset(&rta, 0, sizeof(rta));
 
 	if (type == RTN_UNICAST)
 		tb = dn_fib_get_table(RT_MIN_TABLE, 1);
@@ -591,14 +614,10 @@ static void fib_magic(int cmd, int type, __le16 dst, int dst_len, struct dn_ifad
 	req.rtm.rtm_scope = (type != RTN_LOCAL ? RT_SCOPE_LINK : RT_SCOPE_HOST);
 	req.rtm.rtm_type = type;
 
-	rta.rta_dst = &dst;
-	rta.rta_prefsrc = &ifa->ifa_local;
-	rta.rta_oif = &ifa->ifa_dev->dev->ifindex;
-
 	if (cmd == RTM_NEWROUTE)
-		tb->insert(tb, &req.rtm, &rta, &req.nlh, NULL);
+		tb->insert(tb, &req.rtm, attrs, &req.nlh, NULL);
 	else
-		tb->delete(tb, &req.rtm, &rta, &req.nlh, NULL);
+		tb->delete(tb, &req.rtm, attrs, &req.nlh, NULL);
 }
 
 static void dn_fib_add_ifaddr(struct dn_ifaddr *ifa)
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 5ac0e15..b4b3508 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -1619,17 +1619,21 @@ errout:
 static int dn_cache_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh, void *arg)
 {
 	struct net *net = sock_net(in_skb->sk);
-	struct rtattr **rta = arg;
 	struct rtmsg *rtm = nlmsg_data(nlh);
 	struct dn_route *rt = NULL;
 	struct dn_skb_cb *cb;
 	int err;
 	struct sk_buff *skb;
 	struct flowidn fld;
+	struct nlattr *tb[RTA_MAX+1];
 
 	if (!net_eq(net, &init_net))
 		return -EINVAL;
 
+	err = nlmsg_parse(nlh, sizeof(*rtm), tb, RTA_MAX, rtm_dn_policy);
+	if (err < 0)
+		return err;
+
 	memset(&fld, 0, sizeof(fld));
 	fld.flowidn_proto = DNPROTO_NSP;
 
@@ -1639,12 +1643,14 @@ static int dn_cache_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh, void
 	skb_reset_mac_header(skb);
 	cb = DN_SKB_CB(skb);
 
-	if (rta[RTA_SRC-1])
-		memcpy(&fld.saddr, RTA_DATA(rta[RTA_SRC-1]), 2);
-	if (rta[RTA_DST-1])
-		memcpy(&fld.daddr, RTA_DATA(rta[RTA_DST-1]), 2);
-	if (rta[RTA_IIF-1])
-		memcpy(&fld.flowidn_iif, RTA_DATA(rta[RTA_IIF-1]), sizeof(int));
+	if (tb[RTA_SRC])
+		fld.saddr = nla_get_le16(tb[RTA_SRC]);
+
+	if (tb[RTA_DST])
+		fld.daddr = nla_get_le16(tb[RTA_DST]);
+
+	if (tb[RTA_IIF])
+		fld.flowidn_iif = nla_get_u32(tb[RTA_IIF]);
 
 	if (fld.flowidn_iif) {
 		struct net_device *dev;
@@ -1669,10 +1675,9 @@ static int dn_cache_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh, void
 		if (!err && -rt->dst.error)
 			err = rt->dst.error;
 	} else {
-		int oif = 0;
-		if (rta[RTA_OIF - 1])
-			memcpy(&oif, RTA_DATA(rta[RTA_OIF - 1]), sizeof(int));
-		fld.flowidn_oif = oif;
+		if (tb[RTA_OIF])
+			fld.flowidn_oif = nla_get_u32(tb[RTA_OIF]);
+
 		err = dn_route_output_key((struct dst_entry **)&rt, &fld, 0);
 	}
 
diff --git a/net/decnet/dn_table.c b/net/decnet/dn_table.c
index 6c2445b..fc42a0a 100644
--- a/net/decnet/dn_table.c
+++ b/net/decnet/dn_table.c
@@ -224,26 +224,27 @@ static struct dn_zone *dn_new_zone(struct dn_hash *table, int z)
 }
 
 
-static int dn_fib_nh_match(struct rtmsg *r, struct nlmsghdr *nlh, struct dn_kern_rta *rta, struct dn_fib_info *fi)
+static int dn_fib_nh_match(struct rtmsg *r, struct nlmsghdr *nlh, struct nlattr *attrs[], struct dn_fib_info *fi)
 {
 	struct rtnexthop *nhp;
 	int nhlen;
 
-	if (rta->rta_priority && *rta->rta_priority != fi->fib_priority)
+	if (attrs[RTA_PRIORITY] &&
+	    nla_get_u32(attrs[RTA_PRIORITY]) != fi->fib_priority)
 		return 1;
 
-	if (rta->rta_oif || rta->rta_gw) {
-		if ((!rta->rta_oif || *rta->rta_oif == fi->fib_nh->nh_oif) &&
-		    (!rta->rta_gw  || memcmp(rta->rta_gw, &fi->fib_nh->nh_gw, 2) == 0))
+	if (attrs[RTA_OIF] || attrs[RTA_GATEWAY]) {
+		if ((!attrs[RTA_OIF] || nla_get_u32(attrs[RTA_OIF]) == fi->fib_nh->nh_oif) &&
+		    (!attrs[RTA_GATEWAY]  || nla_get_le16(attrs[RTA_GATEWAY]) != fi->fib_nh->nh_gw))
 			return 0;
 		return 1;
 	}
 
-	if (rta->rta_mp == NULL)
+	if (!attrs[RTA_MULTIPATH])
 		return 0;
 
-	nhp = RTA_DATA(rta->rta_mp);
-	nhlen = RTA_PAYLOAD(rta->rta_mp);
+	nhp = nla_data(attrs[RTA_MULTIPATH]);
+	nhlen = nla_len(attrs[RTA_MULTIPATH]);
 
 	for_nexthops(fi) {
 		int attrlen = nhlen - sizeof(struct rtnexthop);
@@ -254,7 +255,10 @@ static int dn_fib_nh_match(struct rtmsg *r, struct nlmsghdr *nlh, struct dn_kern
 		if (nhp->rtnh_ifindex && nhp->rtnh_ifindex != nh->nh_oif)
 			return 1;
 		if (attrlen) {
-			gw = dn_fib_get_attr16(RTNH_DATA(nhp), attrlen, RTA_GATEWAY);
+			struct nlattr *gw_attr;
+
+			gw_attr = nla_find((struct nlattr *) (nhp + 1), attrlen, RTA_GATEWAY);
+			gw = gw_attr ? nla_get_le16(gw_attr) : 0;
 
 			if (gw && gw != nh->nh_gw)
 				return 1;
@@ -517,7 +521,8 @@ out:
 	return skb->len;
 }
 
-static int dn_fib_table_insert(struct dn_fib_table *tb, struct rtmsg *r, struct dn_kern_rta *rta, struct nlmsghdr *n, struct netlink_skb_parms *req)
+static int dn_fib_table_insert(struct dn_fib_table *tb, struct rtmsg *r, struct nlattr *attrs[],
+			       struct nlmsghdr *n, struct netlink_skb_parms *req)
 {
 	struct dn_hash *table = (struct dn_hash *)tb->data;
 	struct dn_fib_node *new_f, *f, **fp, **del_fp;
@@ -536,15 +541,14 @@ static int dn_fib_table_insert(struct dn_fib_table *tb, struct rtmsg *r, struct
 		return -ENOBUFS;
 
 	dz_key_0(key);
-	if (rta->rta_dst) {
-		__le16 dst;
-		memcpy(&dst, rta->rta_dst, 2);
+	if (attrs[RTA_DST]) {
+		__le16 dst = nla_get_le16(attrs[RTA_DST]);
 		if (dst & ~DZ_MASK(dz))
 			return -EINVAL;
 		key = dz_key(dst, dz);
 	}
 
-	if ((fi = dn_fib_create_info(r, rta, n, &err)) == NULL)
+	if ((fi = dn_fib_create_info(r, attrs, n, &err)) == NULL)
 		return err;
 
 	if (dz->dz_nent > (dz->dz_divisor << 2) &&
@@ -654,7 +658,8 @@ out:
 }
 
 
-static int dn_fib_table_delete(struct dn_fib_table *tb, struct rtmsg *r, struct dn_kern_rta *rta, struct nlmsghdr *n, struct netlink_skb_parms *req)
+static int dn_fib_table_delete(struct dn_fib_table *tb, struct rtmsg *r, struct nlattr *attrs[],
+			       struct nlmsghdr *n, struct netlink_skb_parms *req)
 {
 	struct dn_hash *table = (struct dn_hash*)tb->data;
 	struct dn_fib_node **fp, **del_fp, *f;
@@ -671,9 +676,8 @@ static int dn_fib_table_delete(struct dn_fib_table *tb, struct rtmsg *r, struct
 		return -ESRCH;
 
 	dz_key_0(key);
-	if (rta->rta_dst) {
-		__le16 dst;
-		memcpy(&dst, rta->rta_dst, 2);
+	if (attrs[RTA_DST]) {
+		__le16 dst = nla_get_le16(attrs[RTA_DST]);
 		if (dst & ~DZ_MASK(dz))
 			return -EINVAL;
 		key = dz_key(dst, dz);
@@ -703,7 +707,7 @@ static int dn_fib_table_delete(struct dn_fib_table *tb, struct rtmsg *r, struct
 				(r->rtm_scope == RT_SCOPE_NOWHERE || f->fn_scope == r->rtm_scope) &&
 				(!r->rtm_protocol ||
 					fi->fib_protocol == r->rtm_protocol) &&
-				dn_fib_nh_match(r, n, rta, fi) == 0)
+				dn_fib_nh_match(r, n, attrs, fi) == 0)
 			del_fp = fp;
 	}
 
-- 
1.7.11.7

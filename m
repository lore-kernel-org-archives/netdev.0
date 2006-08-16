From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 4/5] [IPv6] route: Convert FIB6 dumping to use new netlink api
Date: Thu, 17 Aug 2006 00:00:04 +0200
Message-ID: <20060816234343.418444868@postel.suug.ch>
References: <20060816234038.106537101@postel.suug.ch>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:58785 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S932131AbWHPXpK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2006 19:45:10 -0400
To: davem@davemloft.net
Content-Disposition: inline; filename=nl_ip6_fib6_dump
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.19.git/net/core/rtnetlink.c
===================================================================
--- net-2.6.19.git.orig/net/core/rtnetlink.c
+++ net-2.6.19.git/net/core/rtnetlink.c
@@ -188,22 +188,27 @@ void rtnl_set_sk_err(u32 group, int erro
 
 int rtnetlink_put_metrics(struct sk_buff *skb, u32 *metrics)
 {
-	struct rtattr *mx = (struct rtattr*)skb->tail;
-	int i;
+	struct nlattr *mx;
+	int i, valid = 0;
 
-	RTA_PUT(skb, RTA_METRICS, 0, NULL);
-	for (i=0; i<RTAX_MAX; i++) {
-		if (metrics[i])
-			RTA_PUT(skb, i+1, sizeof(u32), metrics+i);
-	}
-	mx->rta_len = skb->tail - (u8*)mx;
-	if (mx->rta_len == RTA_LENGTH(0))
-		skb_trim(skb, (u8*)mx - skb->data);
-	return 0;
+	mx = nla_nest_start(skb, RTA_METRICS);
+	if (mx == NULL)
+		return -ENOBUFS;
 
-rtattr_failure:
-	skb_trim(skb, (u8*)mx - skb->data);
-	return -1;
+	for (i = 0; i < RTAX_MAX; i++) {
+		if (metrics[i]) {
+			valid++;
+			NLA_PUT_U32(skb, i+1, metrics[i]);
+		}
+	}
+
+	if (!valid)
+		goto nla_put_failure;
+
+	return nla_nest_end(skb, mx);
+
+nla_put_failure:
+	return nla_nest_cancel(skb, mx);
 }
 
 
Index: net-2.6.19.git/net/ipv6/route.c
===================================================================
--- net-2.6.19.git.orig/net/ipv6/route.c
+++ net-2.6.19.git/net/ipv6/route.c
@@ -1932,8 +1932,7 @@ static int rt6_fill_node(struct sk_buff 
 			 int prefix, unsigned int flags)
 {
 	struct rtmsg *rtm;
-	struct nlmsghdr  *nlh;
-	unsigned char	 *b = skb->tail;
+	struct nlmsghdr *nlh;
 	struct rta_cacheinfo ci;
 	u32 table;
 
@@ -1944,8 +1943,11 @@ static int rt6_fill_node(struct sk_buff 
 		}
 	}
 
-	nlh = NLMSG_NEW(skb, pid, seq, type, sizeof(*rtm), flags);
-	rtm = NLMSG_DATA(nlh);
+	nlh = nlmsg_put(skb, pid, seq, type, sizeof(*rtm), flags);
+	if (nlh == NULL)
+		return -ENOBUFS;
+
+	rtm = nlmsg_data(nlh);
 	rtm->rtm_family = AF_INET6;
 	rtm->rtm_dst_len = rt->rt6i_dst.plen;
 	rtm->rtm_src_len = rt->rt6i_src.plen;
@@ -1955,7 +1957,7 @@ static int rt6_fill_node(struct sk_buff 
 	else
 		table = RT6_TABLE_UNSPEC;
 	rtm->rtm_table = table;
-	RTA_PUT_U32(skb, RTA_TABLE, table);
+	NLA_PUT_U32(skb, RTA_TABLE, table);
 	if (rt->rt6i_flags&RTF_REJECT)
 		rtm->rtm_type = RTN_UNREACHABLE;
 	else if (rt->rt6i_dev && (rt->rt6i_dev->flags&IFF_LOOPBACK))
@@ -1976,31 +1978,35 @@ static int rt6_fill_node(struct sk_buff 
 		rtm->rtm_flags |= RTM_F_CLONED;
 
 	if (dst) {
-		RTA_PUT(skb, RTA_DST, 16, dst);
+		NLA_PUT(skb, RTA_DST, 16, dst);
 	        rtm->rtm_dst_len = 128;
 	} else if (rtm->rtm_dst_len)
-		RTA_PUT(skb, RTA_DST, 16, &rt->rt6i_dst.addr);
+		NLA_PUT(skb, RTA_DST, 16, &rt->rt6i_dst.addr);
 #ifdef CONFIG_IPV6_SUBTREES
 	if (src) {
-		RTA_PUT(skb, RTA_SRC, 16, src);
+		NLA_PUT(skb, RTA_SRC, 16, src);
 	        rtm->rtm_src_len = 128;
 	} else if (rtm->rtm_src_len)
-		RTA_PUT(skb, RTA_SRC, 16, &rt->rt6i_src.addr);
+		NLA_PUT(skb, RTA_SRC, 16, &rt->rt6i_src.addr);
 #endif
 	if (iif)
-		RTA_PUT(skb, RTA_IIF, 4, &iif);
+		NLA_PUT_U32(skb, RTA_IIF, iif);
 	else if (dst) {
 		struct in6_addr saddr_buf;
 		if (ipv6_get_saddr(&rt->u.dst, dst, &saddr_buf) == 0)
-			RTA_PUT(skb, RTA_PREFSRC, 16, &saddr_buf);
+			NLA_PUT(skb, RTA_PREFSRC, 16, &saddr_buf);
 	}
+
 	if (rtnetlink_put_metrics(skb, rt->u.dst.metrics) < 0)
-		goto rtattr_failure;
+		goto nla_put_failure;
+
 	if (rt->u.dst.neighbour)
-		RTA_PUT(skb, RTA_GATEWAY, 16, &rt->u.dst.neighbour->primary_key);
+		NLA_PUT(skb, RTA_GATEWAY, 16, &rt->u.dst.neighbour->primary_key);
+
 	if (rt->u.dst.dev)
-		RTA_PUT(skb, RTA_OIF, sizeof(int), &rt->rt6i_dev->ifindex);
-	RTA_PUT(skb, RTA_PRIORITY, 4, &rt->rt6i_metric);
+		NLA_PUT_U32(skb, RTA_OIF, rt->rt6i_dev->ifindex);
+
+	NLA_PUT_U32(skb, RTA_PRIORITY, rt->rt6i_metric);
 	ci.rta_lastuse = jiffies_to_clock_t(jiffies - rt->u.dst.lastuse);
 	if (rt->rt6i_expires)
 		ci.rta_expires = jiffies_to_clock_t(rt->rt6i_expires - jiffies);
@@ -2012,14 +2018,12 @@ static int rt6_fill_node(struct sk_buff 
 	ci.rta_id = 0;
 	ci.rta_ts = 0;
 	ci.rta_tsage = 0;
-	RTA_PUT(skb, RTA_CACHEINFO, sizeof(ci), &ci);
-	nlh->nlmsg_len = skb->tail - b;
-	return skb->len;
-
-nlmsg_failure:
-rtattr_failure:
-	skb_trim(skb, b - skb->data);
-	return -1;
+	NLA_PUT(skb, RTA_CACHEINFO, sizeof(ci), &ci);
+
+	return nlmsg_end(skb, nlh);
+
+nla_put_failure:
+	return nlmsg_cancel(skb, nlh);
 }
 
 int rt6_dump_route(struct rt6_info *rt, void *p_arg)
@@ -2027,8 +2031,8 @@ int rt6_dump_route(struct rt6_info *rt, 
 	struct rt6_rtnl_dump_arg *arg = (struct rt6_rtnl_dump_arg *) p_arg;
 	int prefix;
 
-	if (arg->cb->nlh->nlmsg_len >= NLMSG_LENGTH(sizeof(struct rtmsg))) {
-		struct rtmsg *rtm = NLMSG_DATA(arg->cb->nlh);
+	if (nlmsg_len(arg->cb->nlh) >= sizeof(struct rtmsg)) {
+		struct rtmsg *rtm = nlmsg_data(arg->cb->nlh);
 		prefix = (rtm->rtm_flags & RTM_F_PREFIX) != 0;
 	} else
 		prefix = 0;


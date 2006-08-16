From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 5/5] [IPv6] route: Convert GETROUTE to use new netlink api
Date: Thu, 17 Aug 2006 00:00:05 +0200
Message-ID: <20060816234343.744015147@postel.suug.ch>
References: <20060816234038.106537101@postel.suug.ch>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:59297 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S932132AbWHPXpP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2006 19:45:15 -0400
To: davem@davemloft.net
Content-Disposition: inline; filename=nl_ip6_getroute
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixes various unvalidated netlink attributes causing memory
corruptions when left empty by userspace applications.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.19.git/net/ipv6/route.c
===================================================================
--- net-2.6.19.git.orig/net/ipv6/route.c
+++ net-2.6.19.git/net/ipv6/route.c
@@ -1829,6 +1829,7 @@ void rt6_mtu_change(struct net_device *d
 static struct nla_policy rtm_ipv6_policy[RTA_MAX+1] __read_mostly = {
 	[RTA_GATEWAY]           = { .minlen = sizeof(struct in6_addr) },
 	[RTA_OIF]               = { .type = NLA_U32 },
+	[RTA_IIF]		= { .type = NLA_U32 },
 	[RTA_PRIORITY]          = { .type = NLA_U32 },
 	[RTA_METRICS]           = { .type = NLA_NESTED },
 };
@@ -2044,68 +2045,75 @@ int rt6_dump_route(struct rt6_info *rt, 
 
 int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr* nlh, void *arg)
 {
-	struct rtattr **rta = arg;
-	int iif = 0;
-	int err = -ENOBUFS;
+	struct nlattr *tb[RTA_MAX+1];
+	struct rt6_info *rt;
 	struct sk_buff *skb;
+	struct rtmsg *rtm;
 	struct flowi fl;
-	struct rt6_info *rt;
+	int err, iif = 0;
 
-	skb = alloc_skb(NLMSG_GOODSIZE, GFP_KERNEL);
-	if (skb == NULL)
-		goto out;
-
-	/* Reserve room for dummy headers, this skb can pass
-	   through good chunk of routing engine.
-	 */
-	skb->mac.raw = skb->data;
-	skb_reserve(skb, MAX_HEADER + sizeof(struct ipv6hdr));
+	err = nlmsg_parse(nlh, sizeof(*rtm), tb, RTA_MAX, rtm_ipv6_policy);
+	if (err < 0)
+		goto errout;
 
+	err = -EINVAL;
 	memset(&fl, 0, sizeof(fl));
-	if (rta[RTA_SRC-1])
-		ipv6_addr_copy(&fl.fl6_src,
-			       (struct in6_addr*)RTA_DATA(rta[RTA_SRC-1]));
-	if (rta[RTA_DST-1])
-		ipv6_addr_copy(&fl.fl6_dst,
-			       (struct in6_addr*)RTA_DATA(rta[RTA_DST-1]));
 
-	if (rta[RTA_IIF-1])
-		memcpy(&iif, RTA_DATA(rta[RTA_IIF-1]), sizeof(int));
+	if (tb[RTA_SRC]) {
+		if (nla_len(tb[RTA_SRC]) < sizeof(struct in6_addr))
+			goto errout;
+
+		ipv6_addr_copy(&fl.fl6_src, nla_data(tb[RTA_SRC]));
+	}
+
+	if (tb[RTA_DST]) {
+		if (nla_len(tb[RTA_DST]) < sizeof(struct in6_addr))
+			goto errout;
+
+		ipv6_addr_copy(&fl.fl6_dst, nla_data(tb[RTA_DST]));
+	}
+
+	if (tb[RTA_IIF])
+		iif = nla_get_u32(tb[RTA_IIF]);
+
+	if (tb[RTA_OIF])
+		fl.oif = nla_get_u32(tb[RTA_OIF]);
 
 	if (iif) {
 		struct net_device *dev;
 		dev = __dev_get_by_index(iif);
 		if (!dev) {
 			err = -ENODEV;
-			goto out_free;
+			goto errout;
 		}
 	}
 
-	fl.oif = 0;
-	if (rta[RTA_OIF-1])
-		memcpy(&fl.oif, RTA_DATA(rta[RTA_OIF-1]), sizeof(int));
+	skb = alloc_skb(NLMSG_GOODSIZE, GFP_KERNEL);
+	if (skb == NULL) {
+		err = -ENOBUFS;
+		goto errout;
+	}
 
-	rt = (struct rt6_info*)ip6_route_output(NULL, &fl);
+	/* Reserve room for dummy headers, this skb can pass
+	   through good chunk of routing engine.
+	 */
+	skb->mac.raw = skb->data;
+	skb_reserve(skb, MAX_HEADER + sizeof(struct ipv6hdr));
 
+	rt = (struct rt6_info*) ip6_route_output(NULL, &fl);
 	skb->dst = &rt->u.dst;
 
-	NETLINK_CB(skb).dst_pid = NETLINK_CB(in_skb).pid;
-	err = rt6_fill_node(skb, rt, 
-			    &fl.fl6_dst, &fl.fl6_src,
-			    iif,
+	err = rt6_fill_node(skb, rt, &fl.fl6_dst, &fl.fl6_src, iif,
 			    RTM_NEWROUTE, NETLINK_CB(in_skb).pid,
 			    nlh->nlmsg_seq, 0, 0);
 	if (err < 0) {
-		err = -EMSGSIZE;
-		goto out_free;
+		kfree_skb(skb);
+		goto errout;
 	}
 
 	err = rtnl_unicast(skb, NETLINK_CB(in_skb).pid);
-out:
+errout:
 	return err;
-out_free:
-	kfree_skb(skb);
-	goto out;	
 }
 
 void inet6_rt_notify(int event, struct rt6_info *rt, struct nl_info *info)


From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 3/3] [IPv4]: Convert route get to new netlink api
Date: Tue, 08 Aug 2006 00:00:03 +0200
Message-ID: <20060808194601.633140475@postel.suug.ch>
References: <20060808193822.104083150@postel.suug.ch>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:42113 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1030275AbWHHTrB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2006 15:47:01 -0400
To: davem@davemloft.net
Content-Disposition: inline; filename=nl_ipv4_get_route
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixes various unvalidated netlink attributes causing memory
corruptions when left empty by userspace applications.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.19.git/include/net/ip_fib.h
===================================================================
--- net-2.6.19.git.orig/include/net/ip_fib.h
+++ net-2.6.19.git/include/net/ip_fib.h
@@ -245,6 +245,7 @@ extern void fib_select_default(const str
 #endif /* CONFIG_IP_MULTIPLE_TABLES */
 
 /* Exported by fib_frontend.c */
+extern struct nla_policy rtm_ipv4_policy[];
 extern void		ip_fib_init(void);
 extern int inet_rtm_delroute(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg);
 extern int inet_rtm_newroute(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg);
Index: net-2.6.19.git/net/ipv4/fib_frontend.c
===================================================================
--- net-2.6.19.git.orig/net/ipv4/fib_frontend.c
+++ net-2.6.19.git/net/ipv4/fib_frontend.c
@@ -433,7 +433,7 @@ int ip_rt_ioctl(unsigned int cmd, void *
 
 #endif
 
-static struct nla_policy rtm_ipv4_policy[RTA_MAX+1] __read_mostly = {
+struct nla_policy rtm_ipv4_policy[RTA_MAX+1] __read_mostly = {
 	[RTA_DST]		= { .type = NLA_U32 },
 	[RTA_SRC]		= { .type = NLA_U32 },
 	[RTA_IIF]		= { .type = NLA_U32 },
Index: net-2.6.19.git/net/ipv4/route.c
===================================================================
--- net-2.6.19.git.orig/net/ipv4/route.c
+++ net-2.6.19.git/net/ipv4/route.c
@@ -2736,18 +2736,24 @@ nla_put_failure:
 
 int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr* nlh, void *arg)
 {
-	struct rtattr **rta = arg;
-	struct rtmsg *rtm = NLMSG_DATA(nlh);
+	struct rtmsg *rtm;
+	struct nlattr *tb[RTA_MAX+1];
 	struct rtable *rt = NULL;
-	u32 dst = 0;
-	u32 src = 0;
-	int iif = 0;
-	int err = -ENOBUFS;
+	u32 dst, src, iif;
+	int err;
 	struct sk_buff *skb;
 
+	err = nlmsg_parse(nlh, sizeof(*rtm), tb, RTA_MAX, rtm_ipv4_policy);
+	if (err < 0)
+		goto errout;
+
+	rtm = nlmsg_data(nlh);
+
 	skb = alloc_skb(NLMSG_GOODSIZE, GFP_KERNEL);
-	if (!skb)
-		goto out;
+	if (skb == NULL) {
+		err = -ENOBUFS;
+		goto errout;
+	}
 
 	/* Reserve room for dummy headers, this skb can pass
 	   through good chunk of routing engine.
@@ -2758,62 +2764,64 @@ int inet_rtm_getroute(struct sk_buff *in
 	skb->nh.iph->protocol = IPPROTO_ICMP;
 	skb_reserve(skb, MAX_HEADER + sizeof(struct iphdr));
 
-	if (rta[RTA_SRC - 1])
-		memcpy(&src, RTA_DATA(rta[RTA_SRC - 1]), 4);
-	if (rta[RTA_DST - 1])
-		memcpy(&dst, RTA_DATA(rta[RTA_DST - 1]), 4);
-	if (rta[RTA_IIF - 1])
-		memcpy(&iif, RTA_DATA(rta[RTA_IIF - 1]), sizeof(int));
+	src = tb[RTA_SRC] ? nla_get_u32(tb[RTA_SRC]) : 0;
+	dst = tb[RTA_DST] ? nla_get_u32(tb[RTA_DST]) : 0;
+	iif = tb[RTA_IIF] ? nla_get_u32(tb[RTA_IIF]) : 0;
 
 	if (iif) {
-		struct net_device *dev = __dev_get_by_index(iif);
-		err = -ENODEV;
-		if (!dev)
-			goto out_free;
+		struct net_device *dev;
+
+		dev = __dev_get_by_index(iif);
+		if (dev == NULL) {
+			err = -ENODEV;
+			goto errout_free;
+		}
+
 		skb->protocol	= htons(ETH_P_IP);
 		skb->dev	= dev;
+
 		local_bh_disable();
 		err = ip_route_input(skb, dst, src, rtm->rtm_tos, dev);
 		local_bh_enable();
-		rt = (struct rtable*)skb->dst;
-		if (!err && rt->u.dst.error)
+
+		rt = (struct rtable*) skb->dst;
+		if (err == 0 && rt->u.dst.error)
 			err = -rt->u.dst.error;
 	} else {
-		struct flowi fl = { .nl_u = { .ip4_u = { .daddr = dst,
-							 .saddr = src,
-							 .tos = rtm->rtm_tos } } };
-		int oif = 0;
-		if (rta[RTA_OIF - 1])
-			memcpy(&oif, RTA_DATA(rta[RTA_OIF - 1]), sizeof(int));
-		fl.oif = oif;
+		struct flowi fl = {
+			.nl_u = {
+				.ip4_u = {
+					.daddr = dst,
+					.saddr = src,
+					.tos = rtm->rtm_tos,
+				},
+			},
+			.oif = tb[RTA_OIF] ? nla_get_u32(tb[RTA_OIF]) : 0,
+		};
+
 		err = ip_route_output_key(&rt, &fl);
 	}
 	if (err)
-		goto out_free;
+		goto errout_free;
 
 	skb->dst = &rt->u.dst;
 	if (rtm->rtm_flags & RTM_F_NOTIFY)
 		rt->rt_flags |= RTCF_NOTIFY;
 
-	NETLINK_CB(skb).dst_pid = NETLINK_CB(in_skb).pid;
-
 	err = rt_fill_info(skb, NETLINK_CB(in_skb).pid, nlh->nlmsg_seq,
 				RTM_NEWROUTE, 0, 0);
-	if (!err)
-		goto out_free;
-	if (err < 0) {
-		err = -EMSGSIZE;
-		goto out_free;
-	}
+	if (err <= 0)
+		goto errout_free;
 
 	err = netlink_unicast(rtnl, skb, NETLINK_CB(in_skb).pid, MSG_DONTWAIT);
 	if (err > 0)
 		err = 0;
-out:	return err;
+errout:
+	return err;
 
-out_free:
+errout_free:
 	kfree_skb(skb);
-	goto out;
+	goto errout;
 }
 
 int ip_rt_dump(struct sk_buff *skb,  struct netlink_callback *cb)


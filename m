From: Varun Chandramohan <varunc@linux.vnet.ibm.com>
Subject: [PATCH 4/4] Initialize and fill IPv6 route age
Date: Mon, 23 Jul 2007 10:13:18 +0530
Message-ID: <20070723101318.c773f600.varunc@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: sri@us.ibm.com, dlstevens@us.ibm.com, varuncha@in.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:38369 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751912AbXGWEnI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jul 2007 00:43:08 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l6N3cuc8030970
	for <netdev@vger.kernel.org>; Sun, 22 Jul 2007 23:38:56 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l6N4h5Tk444098
	for <netdev@vger.kernel.org>; Mon, 23 Jul 2007 00:43:05 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6N4h4IN016586
	for <netdev@vger.kernel.org>; Mon, 23 Jul 2007 00:43:05 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The age field of the ipv6 route structures are initilized with the current timeval at the time of route       creation. When the route dump is called the route age value stored in the structure is subtracted from the     present timeval and the difference is passed on as the route age.

Signed-off-by: Varun Chandramohan <varunc@linux.vnet.ibm.com>
---
 include/net/ip6_fib.h   |    1 +
 include/net/ip6_route.h |    3 +++
 net/ipv6/addrconf.c     |    5 +++++
 net/ipv6/route.c        |   23 +++++++++++++++++++----
 4 files changed, 28 insertions(+), 4 deletions(-)

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index c48ea87..e30a1cf 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -98,6 +98,7 @@ struct rt6_info
 	
 	u32				rt6i_flags;
 	u32				rt6i_metric;
+	time_t				rt6i_age;
 	atomic_t			rt6i_ref;
 	struct fib6_table		*rt6i_table;
 
diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 5456fdd..fc9716c 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -36,6 +36,9 @@ struct route_info {
 #define RT6_LOOKUP_F_REACHABLE	0x2
 #define RT6_LOOKUP_F_HAS_SADDR	0x4
 
+#define RT6_SET_ROUTE_INFO 0x0
+#define RT6_GET_ROUTE_INFO 0x1
+
 extern struct rt6_info	ip6_null_entry;
 
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 5a5f8bd..715c766 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4187,6 +4187,7 @@ EXPORT_SYMBOL(unregister_inet6addr_notif
 
 int __init addrconf_init(void)
 {
+	struct timeval tv;
 	int err = 0;
 
 	/* The addrconf netdev notifier requires that loopback_dev
@@ -4214,10 +4215,14 @@ int __init addrconf_init(void)
 	if (err)
 		return err;
 
+	do_gettimeofday(&tv);
 	ip6_null_entry.rt6i_idev = in6_dev_get(&loopback_dev);
+	ip6_null_entry.rt6i_age = timeval_to_sec(&tv);
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
 	ip6_prohibit_entry.rt6i_idev = in6_dev_get(&loopback_dev);
+	ip6_prohibit_entry.rt6i_age = timeval_to_sec(&tv);
 	ip6_blk_hole_entry.rt6i_idev = in6_dev_get(&loopback_dev);
+	ip6_blk_hole_entry.rt6i_age = timeval_to_sec(&tv);
 #endif
 
 	register_netdevice_notifier(&ipv6_dev_notf);
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index fe8d983..9386c05 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -600,7 +600,14 @@ static int __ip6_ins_rt(struct rt6_info
 {
 	int err;
 	struct fib6_table *table;
+	struct timeval tv;
 
+	do_gettimeofday(&tv);
+	/* Update the timeval for new routes
+	 * We add it here to make it common irrespective
+	 * of how the new route is added.
+	 */
+	rt->rt6i_age = timeval_to_sec(&tv);
 	table = rt->rt6i_table;
 	write_lock_bh(&table->tb6_lock);
 	err = fib6_add(&table->tb6_root, rt, info);
@@ -2111,6 +2118,7 @@ static inline size_t rt6_nlmsg_size(void
 	       + nla_total_size(4) /* RTA_IIF */
 	       + nla_total_size(4) /* RTA_OIF */
 	       + nla_total_size(4) /* RTA_PRIORITY */
+	       + nla_total_size(4) /*RTA_AGE*/
 	       + RTAX_MAX * nla_total_size(4) /* RTA_METRICS */
 	       + nla_total_size(sizeof(struct rta_cacheinfo));
 }
@@ -2118,10 +2126,11 @@ static inline size_t rt6_nlmsg_size(void
 static int rt6_fill_node(struct sk_buff *skb, struct rt6_info *rt,
 			 struct in6_addr *dst, struct in6_addr *src,
 			 int iif, int type, u32 pid, u32 seq,
-			 int prefix, unsigned int flags)
+			 int prefix, unsigned int flags, int dumpflg)
 {
 	struct rtmsg *rtm;
 	struct nlmsghdr *nlh;
+	struct timeval tv;
 	long expires;
 	u32 table;
 
@@ -2185,6 +2194,12 @@ static int rt6_fill_node(struct sk_buff
 		if (ipv6_get_saddr(&rt->u.dst, dst, &saddr_buf) == 0)
 			NLA_PUT(skb, RTA_PREFSRC, 16, &saddr_buf);
 	}
+	
+	do_gettimeofday(&tv);
+	if (dumpflg)
+		NLA_PUT_U32(skb, RTA_AGE, timeval_to_sec(&tv) - rt->rt6i_age);
+	else
+		NLA_PUT_U32(skb, RTA_AGE, rt->rt6i_age);
 
 	if (rtnetlink_put_metrics(skb, rt->u.dst.metrics) < 0)
 		goto nla_put_failure;
@@ -2222,7 +2237,7 @@ int rt6_dump_route(struct rt6_info *rt,
 
 	return rt6_fill_node(arg->skb, rt, NULL, NULL, 0, RTM_NEWROUTE,
 		     NETLINK_CB(arg->cb->skb).pid, arg->cb->nlh->nlmsg_seq,
-		     prefix, NLM_F_MULTI);
+		     prefix, NLM_F_MULTI, RT6_GET_ROUTE_INFO);
 }
 
 static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr* nlh, void *arg)
@@ -2287,7 +2302,7 @@ static int inet6_rtm_getroute(struct sk_
 
 	err = rt6_fill_node(skb, rt, &fl.fl6_dst, &fl.fl6_src, iif,
 			    RTM_NEWROUTE, NETLINK_CB(in_skb).pid,
-			    nlh->nlmsg_seq, 0, 0);
+			    nlh->nlmsg_seq, 0, 0, RT6_GET_ROUTE_INFO);
 	if (err < 0) {
 		kfree_skb(skb);
 		goto errout;
@@ -2316,7 +2331,7 @@ void inet6_rt_notify(int event, struct r
 	if (skb == NULL)
 		goto errout;
 
-	err = rt6_fill_node(skb, rt, NULL, NULL, 0, event, pid, seq, 0, 0);
+	err = rt6_fill_node(skb, rt, NULL, NULL, 0, event, pid, seq, 0, 0, RT6_SET_ROUTE_INFO);
 	if (err < 0) {
 		/* -EMSGSIZE implies BUG in rt6_nlmsg_size() */
 		WARN_ON(err == -EMSGSIZE);
-- 
1.4.3.4


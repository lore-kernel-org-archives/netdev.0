From: Varun Chandramohan <varunc@linux.vnet.ibm.com>
Subject: [PATCH 3/3 Rev4] Initialize and fill IPv6 route age
Date: Thu, 20 Sep 2007 20:59:03 +0530
Message-ID: <20070920205903.e40b37af.varunc@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, socketcan@hartkopp.net,
	shemminger@linux-foundation.org, krkumar2@in.ibm.com,
	tgraf@suug.ch, varuncha@in.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:38860 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756134AbXITP2L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2007 11:28:11 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l8KFRvN7011649
	for <netdev@vger.kernel.org>; Thu, 20 Sep 2007 11:27:57 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8KFRqvG498468
	for <netdev@vger.kernel.org>; Thu, 20 Sep 2007 09:27:56 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8KFRp4P001633
	for <netdev@vger.kernel.org>; Thu, 20 Sep 2007 09:27:52 -0600
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The age field of the ipv6 route structures are initilized with the current timeval at the time of route
creation. When the route dump is called the route age value stored in the structure is subtracted from the
present timeval and the difference is passed on as the route age.

Signed-off-by: Varun Chandramohan <varunc@linux.vnet.ibm.com>
---
 include/net/ip6_fib.h |    1 +
 net/ipv6/addrconf.c   |    5 +++++
 net/ipv6/route.c      |   14 ++++++++++++++
 3 files changed, 20 insertions(+), 0 deletions(-)

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
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 91ef3be..e77c6ad 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4182,6 +4182,7 @@ EXPORT_SYMBOL(unregister_inet6addr_notif
 
 int __init addrconf_init(void)
 {
+	struct timeval tv;
 	int err = 0;
 
 	/* The addrconf netdev notifier requires that loopback_dev
@@ -4209,10 +4210,14 @@ int __init addrconf_init(void)
 	if (err)
 		return err;
 
+	do_gettimeofday(&tv);
 	ip6_null_entry.rt6i_idev = in6_dev_get(&loopback_dev);
+	ip6_null_entry.rt6i_age = tv.tv_sec;
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
 	ip6_prohibit_entry.rt6i_idev = in6_dev_get(&loopback_dev);
+	ip6_prohibit_entry.rt6i_age = tv.tv_sec;
 	ip6_blk_hole_entry.rt6i_idev = in6_dev_get(&loopback_dev);
+	ip6_blk_hole_entry.rt6i_age = tv.tv_sec;
 #endif
 
 	register_netdevice_notifier(&ipv6_dev_notf);
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 55ea80f..e9a9d00 100644
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
+	rt->rt6i_age = tv.tv_sec;
 	table = rt->rt6i_table;
 	write_lock_bh(&table->tb6_lock);
 	err = fib6_add(&table->tb6_root, rt, info);
@@ -2112,6 +2119,7 @@ static inline size_t rt6_nlmsg_size(void
 	       + nla_total_size(4) /* RTA_IIF */
 	       + nla_total_size(4) /* RTA_OIF */
 	       + nla_total_size(4) /* RTA_PRIORITY */
+	       + nla_total_size(4) /*RTA_AGE*/
 	       + RTAX_MAX * nla_total_size(4) /* RTA_METRICS */
 	       + nla_total_size(sizeof(struct rta_cacheinfo));
 }
@@ -2123,6 +2131,7 @@ static int rt6_fill_node(struct sk_buff
 {
 	struct rtmsg *rtm;
 	struct nlmsghdr *nlh;
+	struct timeval tv;
 	long expires;
 	u32 table;
 
@@ -2186,6 +2195,11 @@ static int rt6_fill_node(struct sk_buff
 		if (ipv6_get_saddr(&rt->u.dst, dst, &saddr_buf) == 0)
 			NLA_PUT(skb, RTA_PREFSRC, 16, &saddr_buf);
 	}
+	
+	do_gettimeofday(&tv);
+	if (rt->rt6i_age) {
+		NLA_PUT_U32(skb, RTA_AGE, (tv.tv_sec - rt->rt6i_age));
+	}
 
 	if (rtnetlink_put_metrics(skb, rt->u.dst.metrics) < 0)
 		goto nla_put_failure;
-- 
1.4.3.4


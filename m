From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next v4 08/10] ipv6: Keep track of DST_NOCACHE routes in case of iface down/unregister
Date: Wed, 20 May 2015 15:52:27 -0700
Message-ID: <1432162349-788789-9-git-send-email-kafai@fb.com>
References: <1432162349-788789-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Julian Anastasov <ja@ssi.bg>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Kernel Team <Kernel-team@fb.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:37451 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753060AbbETWxS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 18:53:18 -0400
Received: from pps.filterd (m0044010 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t4KMoIWc027261
	for <netdev@vger.kernel.org>; Wed, 20 May 2015 15:53:18 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1uh1jv86b3-3
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 20 May 2015 15:53:18 -0700
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.212.236.89) with ESMTP	id
 00768684ff4311e48e2f0002c95209d8-fb4d93a0 for <netdev@vger.kernel.org>;	Wed,
 20 May 2015 15:53:16 -0700
In-Reply-To: <1432162349-788789-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch keeps track of the DST_NOCACHE routes in a list and replaces its
dev with loopback during the iface down/unregister event.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
Cc: Steffen Klassert <steffen.klassert@secunet.com>
Cc: Julian Anastasov <ja@ssi.bg>
---
 include/net/ip6_fib.h |  3 ++
 net/ipv6/route.c      | 78 +++++++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 79 insertions(+), 2 deletions(-)

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 5556111..cc8f03c 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -120,6 +120,9 @@ struct rt6_info {
 	struct rt6key			rt6i_src;
 	struct rt6key			rt6i_prefsrc;
 
+	struct list_head		rt6i_uncached;
+	struct uncached_list		*rt6i_uncached_list;
+
 	struct inet6_dev		*rt6i_idev;
 
 	u32				rt6i_metric;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 9dbee3d..121ed73 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -105,6 +105,67 @@ static struct rt6_info *rt6_get_route_info(struct net *net,
 					   const struct in6_addr *gwaddr, int ifindex);
 #endif
 
+struct uncached_list {
+	spinlock_t		lock;
+	struct list_head	head;
+};
+
+static DEFINE_PER_CPU_ALIGNED(struct uncached_list, rt6_uncached_list);
+
+static void rt6_uncached_list_add(struct rt6_info *rt)
+{
+	struct uncached_list *ul = raw_cpu_ptr(&rt6_uncached_list);
+
+	rt->dst.flags |= DST_NOCACHE;
+	rt->rt6i_uncached_list = ul;
+
+	spin_lock_bh(&ul->lock);
+	list_add_tail(&rt->rt6i_uncached, &ul->head);
+	spin_unlock_bh(&ul->lock);
+}
+
+static void rt6_uncached_list_del(struct rt6_info *rt)
+{
+	if (!list_empty(&rt->rt6i_uncached)) {
+		struct uncached_list *ul = rt->rt6i_uncached_list;
+
+		spin_lock_bh(&ul->lock);
+		list_del(&rt->rt6i_uncached);
+		spin_unlock_bh(&ul->lock);
+	}
+}
+
+static void rt6_uncached_list_flush_dev(struct net *net, struct net_device *dev)
+{
+	struct net_device *loopback_dev = net->loopback_dev;
+	struct rt6_info *rt;
+	int cpu;
+
+	for_each_possible_cpu(cpu) {
+		struct uncached_list *ul = per_cpu_ptr(&rt6_uncached_list, cpu);
+
+		spin_lock_bh(&ul->lock);
+		list_for_each_entry(rt, &ul->head, rt6i_uncached) {
+			struct inet6_dev *rt_idev = rt->rt6i_idev;
+			struct net_device *rt_dev = rt->dst.dev;
+
+			if (rt_idev && (rt_idev->dev == dev || !dev) &&
+			    rt_idev->dev != loopback_dev) {
+				rt->rt6i_idev = in6_dev_get(loopback_dev);
+				in6_dev_put(rt_idev);
+			}
+
+			if (rt_dev && (rt_dev == dev || !dev) &&
+			    rt_dev != loopback_dev) {
+				rt->dst.dev = loopback_dev;
+				dev_hold(rt->dst.dev);
+				dev_put(rt_dev);
+			}
+		}
+		spin_unlock_bh(&ul->lock);
+	}
+}
+
 static u32 *ipv6_cow_metrics(struct dst_entry *dst, unsigned long old)
 {
 	struct rt6_info *rt = (struct rt6_info *)dst;
@@ -262,6 +323,7 @@ static inline struct rt6_info *ip6_dst_alloc(struct net *net,
 
 		memset(dst + 1, 0, sizeof(*rt) - sizeof(*dst));
 		INIT_LIST_HEAD(&rt->rt6i_siblings);
+		INIT_LIST_HEAD(&rt->rt6i_uncached);
 	}
 	return rt;
 }
@@ -269,11 +331,14 @@ static inline struct rt6_info *ip6_dst_alloc(struct net *net,
 static void ip6_dst_destroy(struct dst_entry *dst)
 {
 	struct rt6_info *rt = (struct rt6_info *)dst;
-	struct inet6_dev *idev = rt->rt6i_idev;
 	struct dst_entry *from = dst->from;
+	struct inet6_dev *idev;
 
 	dst_destroy_metrics_generic(dst);
 
+	rt6_uncached_list_del(rt);
+
+	idev = rt->rt6i_idev;
 	if (idev) {
 		rt->rt6i_idev = NULL;
 		in6_dev_put(idev);
@@ -920,7 +985,7 @@ redo_rt6_select:
 		dst_release(&rt->dst);
 
 		if (uncached_rt)
-			uncached_rt->dst.flags |= DST_NOCACHE;
+			rt6_uncached_list_add(uncached_rt);
 		else
 			uncached_rt = net->ipv6.ip6_null_entry;
 		dst_hold(&uncached_rt->dst);
@@ -2358,6 +2423,7 @@ void rt6_ifdown(struct net *net, struct net_device *dev)
 
 	fib6_clean_all(net, fib6_ifdown, &adn);
 	icmp6_clean_all(fib6_ifdown, &adn);
+	rt6_uncached_list_flush_dev(net, dev);
 }
 
 struct rt6_mtu_change_arg {
@@ -3250,6 +3316,7 @@ static struct notifier_block ip6_route_dev_notifier = {
 int __init ip6_route_init(void)
 {
 	int ret;
+	int cpu;
 
 	ret = -ENOMEM;
 	ip6_dst_ops_template.kmem_cachep =
@@ -3309,6 +3376,13 @@ int __init ip6_route_init(void)
 	if (ret)
 		goto out_register_late_subsys;
 
+	for_each_possible_cpu(cpu) {
+		struct uncached_list *ul = per_cpu_ptr(&rt6_uncached_list, cpu);
+
+		INIT_LIST_HEAD(&ul->head);
+		spin_lock_init(&ul->lock);
+	}
+
 out:
 	return ret;
 
-- 
1.8.1

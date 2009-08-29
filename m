From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] netns: embed ip6_dst_ops directly
Date: Sat, 29 Aug 2009 15:34:49 +0400
Message-ID: <20090829113449.GA3067@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, benjamin.thery@bull.net,
	dlezcano@fr.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:58782 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752234AbZH2Leu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2009 07:34:50 -0400
Received: by ey-out-2122.google.com with SMTP id 4so154128eyf.5
        for <netdev@vger.kernel.org>; Sat, 29 Aug 2009 04:34:51 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

struct net::ipv6.ip6_dst_ops is separatedly dynamically allocated,
but there is no fundamental reason for it. Embed it directly into
struct netns_ipv6.

For that:
* move struct dst_ops into separate header to fix circular dependencies
	I honestly tried not to, it's pretty impossible to do other way
* drop dynamical allocation, allocate together with netns

For a change, remove struct dst_ops::dst_net, it's deducible
by using container_of() given dst_ops pointer.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/net/dst.h        |   23 +----------------------
 include/net/dst_ops.h    |   28 ++++++++++++++++++++++++++++
 include/net/netns/ipv6.h |    3 ++-
 net/ipv6/route.c         |   34 +++++++++++++---------------------
 4 files changed, 44 insertions(+), 44 deletions(-)

--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -8,6 +8,7 @@
 #ifndef _NET_DST_H
 #define _NET_DST_H
 
+#include <net/dst_ops.h>
 #include <linux/netdevice.h>
 #include <linux/rtnetlink.h>
 #include <linux/rcupdate.h>
@@ -102,28 +103,6 @@ struct dst_entry
 	};
 };
 
-
-struct dst_ops
-{
-	unsigned short		family;
-	__be16			protocol;
-	unsigned		gc_thresh;
-
-	int			(*gc)(struct dst_ops *ops);
-	struct dst_entry *	(*check)(struct dst_entry *, __u32 cookie);
-	void			(*destroy)(struct dst_entry *);
-	void			(*ifdown)(struct dst_entry *,
-					  struct net_device *dev, int how);
-	struct dst_entry *	(*negative_advice)(struct dst_entry *);
-	void			(*link_failure)(struct sk_buff *);
-	void			(*update_pmtu)(struct dst_entry *dst, u32 mtu);
-	int			(*local_out)(struct sk_buff *skb);
-
-	atomic_t		entries;
-	struct kmem_cache 		*kmem_cachep;
-	struct net              *dst_net;
-};
-
 #ifdef __KERNEL__
 
 static inline u32
new file mode 100644
--- /dev/null
+++ b/include/net/dst_ops.h
@@ -0,0 +1,28 @@
+#ifndef _NET_DST_OPS_H
+#define _NET_DST_OPS_H
+#include <linux/types.h>
+
+struct dst_entry;
+struct kmem_cachep;
+struct net_device;
+struct sk_buff;
+
+struct dst_ops {
+	unsigned short		family;
+	__be16			protocol;
+	unsigned		gc_thresh;
+
+	int			(*gc)(struct dst_ops *ops);
+	struct dst_entry *	(*check)(struct dst_entry *, __u32 cookie);
+	void			(*destroy)(struct dst_entry *);
+	void			(*ifdown)(struct dst_entry *,
+					  struct net_device *dev, int how);
+	struct dst_entry *	(*negative_advice)(struct dst_entry *);
+	void			(*link_failure)(struct sk_buff *);
+	void			(*update_pmtu)(struct dst_entry *dst, u32 mtu);
+	int			(*local_out)(struct sk_buff *skb);
+
+	atomic_t		entries;
+	struct kmem_cache	*kmem_cachep;
+};
+#endif
--- a/include/net/netns/ipv6.h
+++ b/include/net/netns/ipv6.h
@@ -6,6 +6,7 @@
 
 #ifndef __NETNS_IPV6_H__
 #define __NETNS_IPV6_H__
+#include <net/dst_ops.h>
 
 struct ctl_table_header;
 
@@ -42,7 +43,7 @@ struct netns_ipv6 {
 	struct timer_list       ip6_fib_timer;
 	struct hlist_head       *fib_table_hash;
 	struct fib6_table       *fib6_main_tbl;
-	struct dst_ops		*ip6_dst_ops;
+	struct dst_ops		ip6_dst_ops;
 	unsigned int		 ip6_rt_gc_expire;
 	unsigned long		 ip6_rt_last_gc;
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -665,7 +665,7 @@ static struct rt6_info *rt6_alloc_cow(struct rt6_info *ort, struct in6_addr *dad
 				net->ipv6.sysctl.ip6_rt_gc_elasticity = 1;
 				net->ipv6.sysctl.ip6_rt_gc_min_interval = 0;
 
-				ip6_dst_gc(net->ipv6.ip6_dst_ops);
+				ip6_dst_gc(&net->ipv6.ip6_dst_ops);
 
 				net->ipv6.sysctl.ip6_rt_gc_elasticity =
 					saved_rt_elasticity;
@@ -970,7 +970,7 @@ struct dst_entry *icmp6_dst_alloc(struct net_device *dev,
 	if (unlikely(idev == NULL))
 		return NULL;
 
-	rt = ip6_dst_alloc(net->ipv6.ip6_dst_ops);
+	rt = ip6_dst_alloc(&net->ipv6.ip6_dst_ops);
 	if (unlikely(rt == NULL)) {
 		in6_dev_put(idev);
 		goto out;
@@ -1060,7 +1060,7 @@ static void icmp6_clean_all(int (*func)(struct rt6_info *rt, void *arg),
 static int ip6_dst_gc(struct dst_ops *ops)
 {
 	unsigned long now = jiffies;
-	struct net *net = ops->dst_net;
+	struct net *net = container_of(ops, struct net, ipv6.ip6_dst_ops);
 	int rt_min_interval = net->ipv6.sysctl.ip6_rt_gc_min_interval;
 	int rt_max_size = net->ipv6.sysctl.ip6_rt_max_size;
 	int rt_elasticity = net->ipv6.sysctl.ip6_rt_gc_elasticity;
@@ -1154,7 +1154,7 @@ int ip6_route_add(struct fib6_config *cfg)
 		goto out;
 	}
 
-	rt = ip6_dst_alloc(net->ipv6.ip6_dst_ops);
+	rt = ip6_dst_alloc(&net->ipv6.ip6_dst_ops);
 
 	if (rt == NULL) {
 		err = -ENOMEM;
@@ -1643,7 +1643,7 @@ out:
 static struct rt6_info * ip6_rt_copy(struct rt6_info *ort)
 {
 	struct net *net = dev_net(ort->rt6i_dev);
-	struct rt6_info *rt = ip6_dst_alloc(net->ipv6.ip6_dst_ops);
+	struct rt6_info *rt = ip6_dst_alloc(&net->ipv6.ip6_dst_ops);
 
 	if (rt) {
 		rt->u.dst.input = ort->u.dst.input;
@@ -1923,7 +1923,7 @@ struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
 				    int anycast)
 {
 	struct net *net = dev_net(idev->dev);
-	struct rt6_info *rt = ip6_dst_alloc(net->ipv6.ip6_dst_ops);
+	struct rt6_info *rt = ip6_dst_alloc(&net->ipv6.ip6_dst_ops);
 	struct neighbour *neigh;
 
 	if (rt == NULL)
@@ -2501,7 +2501,7 @@ static int rt6_stats_seq_show(struct seq_file *seq, void *v)
 		   net->ipv6.rt6_stats->fib_rt_alloc,
 		   net->ipv6.rt6_stats->fib_rt_entries,
 		   net->ipv6.rt6_stats->fib_rt_cache,
-		   atomic_read(&net->ipv6.ip6_dst_ops->entries),
+		   atomic_read(&net->ipv6.ip6_dst_ops.entries),
 		   net->ipv6.rt6_stats->fib_discarded_routes);
 
 	return 0;
@@ -2637,7 +2637,7 @@ struct ctl_table *ipv6_route_sysctl_init(struct net *net)
 
 	if (table) {
 		table[0].data = &net->ipv6.sysctl.flush_delay;
-		table[1].data = &net->ipv6.ip6_dst_ops->gc_thresh;
+		table[1].data = &net->ipv6.ip6_dst_ops.gc_thresh;
 		table[2].data = &net->ipv6.sysctl.ip6_rt_max_size;
 		table[3].data = &net->ipv6.sysctl.ip6_rt_gc_min_interval;
 		table[4].data = &net->ipv6.sysctl.ip6_rt_gc_timeout;
@@ -2655,12 +2655,8 @@ static int ip6_route_net_init(struct net *net)
 {
 	int ret = -ENOMEM;
 
-	net->ipv6.ip6_dst_ops = kmemdup(&ip6_dst_ops_template,
-					sizeof(*net->ipv6.ip6_dst_ops),
-					GFP_KERNEL);
-	if (!net->ipv6.ip6_dst_ops)
-		goto out;
-	net->ipv6.ip6_dst_ops->dst_net = hold_net(net);
+	memcpy(&net->ipv6.ip6_dst_ops, &ip6_dst_ops_template,
+	       sizeof(net->ipv6.ip6_dst_ops));
 
 	net->ipv6.ip6_null_entry = kmemdup(&ip6_null_entry_template,
 					   sizeof(*net->ipv6.ip6_null_entry),
@@ -2669,7 +2665,7 @@ static int ip6_route_net_init(struct net *net)
 		goto out_ip6_dst_ops;
 	net->ipv6.ip6_null_entry->u.dst.path =
 		(struct dst_entry *)net->ipv6.ip6_null_entry;
-	net->ipv6.ip6_null_entry->u.dst.ops = net->ipv6.ip6_dst_ops;
+	net->ipv6.ip6_null_entry->u.dst.ops = &net->ipv6.ip6_dst_ops;
 
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
 	net->ipv6.ip6_prohibit_entry = kmemdup(&ip6_prohibit_entry_template,
@@ -2679,7 +2675,7 @@ static int ip6_route_net_init(struct net *net)
 		goto out_ip6_null_entry;
 	net->ipv6.ip6_prohibit_entry->u.dst.path =
 		(struct dst_entry *)net->ipv6.ip6_prohibit_entry;
-	net->ipv6.ip6_prohibit_entry->u.dst.ops = net->ipv6.ip6_dst_ops;
+	net->ipv6.ip6_prohibit_entry->u.dst.ops = &net->ipv6.ip6_dst_ops;
 
 	net->ipv6.ip6_blk_hole_entry = kmemdup(&ip6_blk_hole_entry_template,
 					       sizeof(*net->ipv6.ip6_blk_hole_entry),
@@ -2688,7 +2684,7 @@ static int ip6_route_net_init(struct net *net)
 		goto out_ip6_prohibit_entry;
 	net->ipv6.ip6_blk_hole_entry->u.dst.path =
 		(struct dst_entry *)net->ipv6.ip6_blk_hole_entry;
-	net->ipv6.ip6_blk_hole_entry->u.dst.ops = net->ipv6.ip6_dst_ops;
+	net->ipv6.ip6_blk_hole_entry->u.dst.ops = &net->ipv6.ip6_dst_ops;
 #endif
 
 	net->ipv6.sysctl.flush_delay = 0;
@@ -2717,8 +2713,6 @@ out_ip6_null_entry:
 	kfree(net->ipv6.ip6_null_entry);
 #endif
 out_ip6_dst_ops:
-	release_net(net->ipv6.ip6_dst_ops->dst_net);
-	kfree(net->ipv6.ip6_dst_ops);
 	goto out;
 }
 
@@ -2733,8 +2727,6 @@ static void ip6_route_net_exit(struct net *net)
 	kfree(net->ipv6.ip6_prohibit_entry);
 	kfree(net->ipv6.ip6_blk_hole_entry);
 #endif
-	release_net(net->ipv6.ip6_dst_ops->dst_net);
-	kfree(net->ipv6.ip6_dst_ops);
 }
 
 static struct pernet_operations ip6_route_net_ops = {

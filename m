From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 2/6] mpls: Cleanup the rcu usage in the code.
Date: Sat, 07 Mar 2015 16:21:56 -0600
Message-ID: <87mw3o4fej.fsf@x220.int.ebiederm.org>
References: <874mpw5u3x.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:33831 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751166AbbCGWZe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Mar 2015 17:25:34 -0500
In-Reply-To: <874mpw5u3x.fsf@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Sat, 07 Mar 2015 16:18:58 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Sparse was generating a lot of warnings mostly from missing annotations
in the code.  Add missing annotations and in a few cases tweak the code
for performance by moving work before loops.

This also fixes a problematic ommision of rcu_assign_pointer and
rcu_dereference.

Hopefully with complete rcu annotations any new rcu errors will stick
out like a sore thumb.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/mpls/af_mpls.c | 73 +++++++++++++++++++++++++++++++++++-------------------
 1 file changed, 47 insertions(+), 26 deletions(-)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 59cc32564d50..0f2833e1b233 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -24,7 +24,7 @@
 #define MAX_VIA_ALEN (ALIGN(MAX_ADDR_LEN, sizeof(unsigned long)))
 
 struct mpls_route { /* next hop label forwarding entry */
-	struct net_device 	*rt_dev;
+	struct net_device __rcu *rt_dev;
 	struct rcu_head		rt_rcu;
 	u32			rt_label[MAX_NEW_LABELS];
 	u8			rt_protocol; /* routing protocol that set this entry */
@@ -152,7 +152,7 @@ static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
 		goto drop;
 
 	/* Find the output device */
-	out_dev = rt->rt_dev;
+	out_dev = rcu_dereference(rt->rt_dev);
 	if (!mpls_output_possible(out_dev))
 		goto drop;
 
@@ -269,13 +269,15 @@ static void mpls_route_update(struct net *net, unsigned index,
 			      struct net_device *dev, struct mpls_route *new,
 			      const struct nl_info *info)
 {
+	struct mpls_route __rcu **platform_label;
 	struct mpls_route *rt, *old = NULL;
 
 	ASSERT_RTNL();
 
-	rt = net->mpls.platform_label[index];
-	if (!dev || (rt && (rt->rt_dev == dev))) {
-		rcu_assign_pointer(net->mpls.platform_label[index], new);
+	platform_label = rtnl_dereference(net->mpls.platform_label);
+	rt = rtnl_dereference(platform_label[index]);
+	if (!dev || (rt && (rtnl_dereference(rt->rt_dev) == dev))) {
+		rcu_assign_pointer(platform_label[index], new);
 		old = rt;
 	}
 
@@ -287,9 +289,14 @@ static void mpls_route_update(struct net *net, unsigned index,
 
 static unsigned find_free_label(struct net *net)
 {
+	struct mpls_route __rcu **platform_label;
+	size_t platform_labels;
 	unsigned index;
-	for (index = 16; index < net->mpls.platform_labels; index++) {
-		if (!net->mpls.platform_label[index])
+
+	platform_label = rtnl_dereference(net->mpls.platform_label);
+	platform_labels = net->mpls.platform_labels;
+	for (index = 16; index < platform_labels; index++) {
+		if (!rtnl_dereference(platform_label[index]))
 			return index;
 	}
 	return LABEL_NOT_SPECIFIED;
@@ -297,6 +304,7 @@ static unsigned find_free_label(struct net *net)
 
 static int mpls_route_add(struct mpls_route_config *cfg)
 {
+	struct mpls_route __rcu **platform_label;
 	struct net *net = cfg->rc_nlinfo.nl_net;
 	struct net_device *dev = NULL;
 	struct mpls_route *rt, *old;
@@ -345,7 +353,8 @@ static int mpls_route_add(struct mpls_route_config *cfg)
 		goto errout;
 
 	err = -EEXIST;
-	old = net->mpls.platform_label[index];
+	platform_label = rtnl_dereference(net->mpls.platform_label);
+	old = rtnl_dereference(platform_label[index]);
 	if ((cfg->rc_nlflags & NLM_F_EXCL) && old)
 		goto errout;
 
@@ -366,7 +375,7 @@ static int mpls_route_add(struct mpls_route_config *cfg)
 	for (i = 0; i < rt->rt_labels; i++)
 		rt->rt_label[i] = cfg->rc_output_label[i];
 	rt->rt_protocol = cfg->rc_protocol;
-	rt->rt_dev = dev;
+	RCU_INIT_POINTER(rt->rt_dev, dev);
 	rt->rt_via_family = cfg->rc_via_family;
 	memcpy(rt->rt_via, cfg->rc_via, cfg->rc_via_alen);
 
@@ -406,14 +415,16 @@ errout:
 
 static void mpls_ifdown(struct net_device *dev)
 {
+	struct mpls_route __rcu **platform_label;
 	struct net *net = dev_net(dev);
 	unsigned index;
 
+	platform_label = rtnl_dereference(net->mpls.platform_label);
 	for (index = 0; index < net->mpls.platform_labels; index++) {
-		struct mpls_route *rt = net->mpls.platform_label[index];
+		struct mpls_route *rt = rtnl_dereference(platform_label[index]);
 		if (!rt)
 			continue;
-		if (rt->rt_dev != dev)
+		if (rtnl_dereference(rt->rt_dev) != dev)
 			continue;
 		rt->rt_dev = NULL;
 	}
@@ -653,6 +664,7 @@ static int mpls_rtm_newroute(struct sk_buff *skb, struct nlmsghdr *nlh)
 static int mpls_dump_route(struct sk_buff *skb, u32 portid, u32 seq, int event,
 			   u32 label, struct mpls_route *rt, int flags)
 {
+	struct net_device *dev;
 	struct nlmsghdr *nlh;
 	struct rtmsg *rtm;
 
@@ -676,7 +688,8 @@ static int mpls_dump_route(struct sk_buff *skb, u32 portid, u32 seq, int event,
 		goto nla_put_failure;
 	if (nla_put_via(skb, rt->rt_via_family, rt->rt_via, rt->rt_via_alen))
 		goto nla_put_failure;
-	if (rt->rt_dev && nla_put_u32(skb, RTA_OIF, rt->rt_dev->ifindex))
+	dev = rtnl_dereference(rt->rt_dev);
+	if (dev && nla_put_u32(skb, RTA_OIF, dev->ifindex))
 		goto nla_put_failure;
 	if (nla_put_labels(skb, RTA_DST, 1, &label))
 		goto nla_put_failure;
@@ -692,6 +705,8 @@ nla_put_failure:
 static int mpls_dump_routes(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	struct net *net = sock_net(skb->sk);
+	struct mpls_route __rcu **platform_label;
+	size_t platform_labels;
 	unsigned int index;
 
 	ASSERT_RTNL();
@@ -700,9 +715,11 @@ static int mpls_dump_routes(struct sk_buff *skb, struct netlink_callback *cb)
 	if (index < 16)
 		index = 16;
 
-	for (; index < net->mpls.platform_labels; index++) {
+	platform_label = rtnl_dereference(net->mpls.platform_label);
+	platform_labels = net->mpls.platform_labels;
+	for (; index < platform_labels; index++) {
 		struct mpls_route *rt;
-		rt = net->mpls.platform_label[index];
+		rt = rtnl_dereference(platform_label[index]);
 		if (!rt)
 			continue;
 
@@ -780,7 +797,7 @@ static int resize_platform_label_table(struct net *net, size_t limit)
 		rt0 = mpls_rt_alloc(lo->addr_len);
 		if (!rt0)
 			goto nort0;
-		rt0->rt_dev = lo;
+		RCU_INIT_POINTER(rt0->rt_dev, lo);
 		rt0->rt_protocol = RTPROT_KERNEL;
 		rt0->rt_via_family = AF_PACKET;
 		memcpy(rt0->rt_via, lo->dev_addr, lo->addr_len);
@@ -790,7 +807,7 @@ static int resize_platform_label_table(struct net *net, size_t limit)
 		rt2 = mpls_rt_alloc(lo->addr_len);
 		if (!rt2)
 			goto nort2;
-		rt2->rt_dev = lo;
+		RCU_INIT_POINTER(rt2->rt_dev, lo);
 		rt2->rt_protocol = RTPROT_KERNEL;
 		rt2->rt_via_family = AF_PACKET;
 		memcpy(rt2->rt_via, lo->dev_addr, lo->addr_len);
@@ -798,7 +815,7 @@ static int resize_platform_label_table(struct net *net, size_t limit)
 
 	rtnl_lock();
 	/* Remember the original table */
-	old = net->mpls.platform_label;
+	old = rtnl_dereference(net->mpls.platform_label);
 	old_limit = net->mpls.platform_labels;
 
 	/* Free any labels beyond the new table */
@@ -815,19 +832,19 @@ static int resize_platform_label_table(struct net *net, size_t limit)
 	/* If needed set the predefined labels */
 	if ((old_limit <= LABEL_IPV6_EXPLICIT_NULL) &&
 	    (limit > LABEL_IPV6_EXPLICIT_NULL)) {
-		labels[LABEL_IPV6_EXPLICIT_NULL] = rt2;
+		RCU_INIT_POINTER(labels[LABEL_IPV6_EXPLICIT_NULL], rt2);
 		rt2 = NULL;
 	}
 
 	if ((old_limit <= LABEL_IPV4_EXPLICIT_NULL) &&
 	    (limit > LABEL_IPV4_EXPLICIT_NULL)) {
-		labels[LABEL_IPV4_EXPLICIT_NULL] = rt0;
+		RCU_INIT_POINTER(labels[LABEL_IPV4_EXPLICIT_NULL], rt0);
 		rt0 = NULL;
 	}
 
 	/* Update the global pointers */
 	net->mpls.platform_labels = limit;
-	net->mpls.platform_label = labels;
+	rcu_assign_pointer(net->mpls.platform_label, labels);
 
 	rtnl_unlock();
 
@@ -903,6 +920,8 @@ static int mpls_net_init(struct net *net)
 
 static void mpls_net_exit(struct net *net)
 {
+	struct mpls_route __rcu **platform_label;
+	size_t platform_labels;
 	struct ctl_table *table;
 	unsigned int index;
 
@@ -910,8 +929,8 @@ static void mpls_net_exit(struct net *net)
 	unregister_net_sysctl_table(net->mpls.ctl);
 	kfree(table);
 
-	/* An rcu grace period haselapsed since there was a device in
-	 * the network namespace (and thus the last in fqlight packet)
+	/* An rcu grace period has passed since there was a device in
+	 * the network namespace (and thus the last in flight packet)
 	 * left this network namespace.  This is because
 	 * unregister_netdevice_many and netdev_run_todo has completed
 	 * for each network device that was in this network namespace.
@@ -920,14 +939,16 @@ static void mpls_net_exit(struct net *net)
 	 * freeing the platform_label table.
 	 */
 	rtnl_lock();
-	for (index = 0; index < net->mpls.platform_labels; index++) {
-		struct mpls_route *rt = net->mpls.platform_label[index];
-		rcu_assign_pointer(net->mpls.platform_label[index], NULL);
+	platform_label = rtnl_dereference(net->mpls.platform_label);
+	platform_labels = net->mpls.platform_labels;
+	for (index = 0; index < platform_labels; index++) {
+		struct mpls_route *rt = rtnl_dereference(platform_label[index]);
+		RCU_INIT_POINTER(platform_label[index], NULL);
 		mpls_rt_free(rt);
 	}
 	rtnl_unlock();
 
-	kvfree(net->mpls.platform_label);
+	kvfree(platform_label);
 }
 
 static struct pernet_operations mpls_net_ops = {
-- 
2.2.1

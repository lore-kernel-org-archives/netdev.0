From: Robert Shearman <rshearma@brocade.com>
Subject: [PATCH net-next 2/2] mpls: reduce memory usage of routes
Date: Tue, 27 Oct 2015 00:37:36 +0000
Message-ID: <1445906256-14927-3-git-send-email-rshearma@brocade.com>
References: <1445906256-14927-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Roopa Prabhu <roopa@cumulusnetworks.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Robert Shearman <rshearma@brocade.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:25133 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753134AbbJ0AiQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2015 20:38:16 -0400
In-Reply-To: <1445906256-14927-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nexthops for MPLS routes have a via address field sized for the
largest via address that is expected, which is 32 bytes. This means
that in the most common case of having ipv4 via addresses, 28 bytes of
memory more than required are used per nexthop. In the other common
case of an ipv6 nexthop then 16 bytes more than required are
used. With large numbers of MPLS routes this extra memory usage could
start to become significant.

To avoid allocating memory for a maximum length via address when not
all of it is required and to allow for ease of iterating over
nexthops, then the via addresses are changed to be stored in the same
memory block as the route and nexthops, but in an array after the end
of the array of nexthops. New accessors are provided to retrieve a
pointer to the via address.

To allow for O(1) access without having to store a pointer or offset
per nh, the via address for each nexthop is sized according to the
maximum via address for any nexthop in the route, which is stored in a
new route field, rt_max_alen, but this is in an existing hole in
struct mpls_route so it doesn't increase the size of the
structure. Each via address is ensured to be aligned to VIA_ALEN_ALIGN
to account for architectures that don't allow unaligned accesses.

Signed-off-by: Robert Shearman <rshearma@brocade.com>
---
 net/mpls/af_mpls.c  | 121 +++++++++++++++++++++++++++++++++++++---------------
 net/mpls/internal.h |  28 ++++++++++--
 2 files changed, 111 insertions(+), 38 deletions(-)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 1c58662db4b2..c70d750148b6 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -57,6 +57,20 @@ bool mpls_output_possible(const struct net_device *dev)
 }
 EXPORT_SYMBOL_GPL(mpls_output_possible);
 
+static u8 *__mpls_nh_via(struct mpls_route *rt, struct mpls_nh *nh)
+{
+	u8 *nh0_via = PTR_ALIGN((u8 *)&rt->rt_nh[rt->rt_nhn], VIA_ALEN_ALIGN);
+	int nh_index = nh - rt->rt_nh;
+
+	return nh0_via + rt->rt_max_alen * nh_index;
+}
+
+static const u8 *mpls_nh_via(const struct mpls_route *rt,
+			     const struct mpls_nh *nh)
+{
+	return __mpls_nh_via((struct mpls_route *)rt, (struct mpls_nh *)nh);
+}
+
 static unsigned int mpls_nh_header_size(const struct mpls_nh *nh)
 {
 	/* The size of the layer 2.5 labels to be added for this route */
@@ -303,7 +317,7 @@ static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
 		}
 	}
 
-	err = neigh_xmit(nh->nh_via_table, out_dev, nh->nh_via, skb);
+	err = neigh_xmit(nh->nh_via_table, out_dev, mpls_nh_via(rt, nh), skb);
 	if (err)
 		net_dbg_ratelimited("%s: packet transmission failed: %d\n",
 				    __func__, err);
@@ -340,14 +354,19 @@ struct mpls_route_config {
 	int			rc_mp_len;
 };
 
-static struct mpls_route *mpls_rt_alloc(int num_nh)
+static struct mpls_route *mpls_rt_alloc(int num_nh, u8 max_alen)
 {
+	u8 max_alen_aligned = ALIGN(max_alen, VIA_ALEN_ALIGN);
 	struct mpls_route *rt;
 
-	rt = kzalloc(sizeof(*rt) + (num_nh * sizeof(struct mpls_nh)),
+	rt = kzalloc(ALIGN(sizeof(*rt) + num_nh * sizeof(*rt->rt_nh),
+			   VIA_ALEN_ALIGN) +
+		     num_nh * max_alen_aligned,
 		     GFP_KERNEL);
-	if (rt)
+	if (rt) {
 		rt->rt_nhn = num_nh;
+		rt->rt_max_alen = max_alen_aligned;
+	}
 
 	return rt;
 }
@@ -408,7 +427,8 @@ static unsigned find_free_label(struct net *net)
 }
 
 #if IS_ENABLED(CONFIG_INET)
-static struct net_device *inet_fib_lookup_dev(struct net *net, void *addr)
+static struct net_device *inet_fib_lookup_dev(struct net *net,
+					      const void *addr)
 {
 	struct net_device *dev;
 	struct rtable *rt;
@@ -427,14 +447,16 @@ static struct net_device *inet_fib_lookup_dev(struct net *net, void *addr)
 	return dev;
 }
 #else
-static struct net_device *inet_fib_lookup_dev(struct net *net, void *addr)
+static struct net_device *inet_fib_lookup_dev(struct net *net,
+					      const void *addr)
 {
 	return ERR_PTR(-EAFNOSUPPORT);
 }
 #endif
 
 #if IS_ENABLED(CONFIG_IPV6)
-static struct net_device *inet6_fib_lookup_dev(struct net *net, void *addr)
+static struct net_device *inet6_fib_lookup_dev(struct net *net,
+					       const void *addr)
 {
 	struct net_device *dev;
 	struct dst_entry *dst;
@@ -457,13 +479,15 @@ static struct net_device *inet6_fib_lookup_dev(struct net *net, void *addr)
 	return dev;
 }
 #else
-static struct net_device *inet6_fib_lookup_dev(struct net *net, void *addr)
+static struct net_device *inet6_fib_lookup_dev(struct net *net,
+					       const void *addr)
 {
 	return ERR_PTR(-EAFNOSUPPORT);
 }
 #endif
 
 static struct net_device *find_outdev(struct net *net,
+				      struct mpls_route *rt,
 				      struct mpls_nh *nh, int oif)
 {
 	struct net_device *dev = NULL;
@@ -471,10 +495,10 @@ static struct net_device *find_outdev(struct net *net,
 	if (!oif) {
 		switch (nh->nh_via_table) {
 		case NEIGH_ARP_TABLE:
-			dev = inet_fib_lookup_dev(net, nh->nh_via);
+			dev = inet_fib_lookup_dev(net, mpls_nh_via(rt, nh));
 			break;
 		case NEIGH_ND_TABLE:
-			dev = inet6_fib_lookup_dev(net, nh->nh_via);
+			dev = inet6_fib_lookup_dev(net, mpls_nh_via(rt, nh));
 			break;
 		case NEIGH_LINK_TABLE:
 			break;
@@ -492,12 +516,13 @@ static struct net_device *find_outdev(struct net *net,
 	return dev;
 }
 
-static int mpls_nh_assign_dev(struct net *net, struct mpls_nh *nh, int oif)
+static int mpls_nh_assign_dev(struct net *net, struct mpls_route *rt,
+			      struct mpls_nh *nh, int oif)
 {
 	struct net_device *dev = NULL;
 	int err = -ENODEV;
 
-	dev = find_outdev(net, nh, oif);
+	dev = find_outdev(net, rt, nh, oif);
 	if (IS_ERR(dev)) {
 		err = PTR_ERR(dev);
 		dev = NULL;
@@ -538,10 +563,10 @@ static int mpls_nh_build_from_cfg(struct mpls_route_config *cfg,
 		nh->nh_label[i] = cfg->rc_output_label[i];
 
 	nh->nh_via_table = cfg->rc_via_table;
-	memcpy(nh->nh_via, cfg->rc_via, cfg->rc_via_alen);
+	memcpy(__mpls_nh_via(rt, nh), cfg->rc_via, cfg->rc_via_alen);
 	nh->nh_via_alen = cfg->rc_via_alen;
 
-	err = mpls_nh_assign_dev(net, nh, cfg->rc_ifindex);
+	err = mpls_nh_assign_dev(net, rt, nh, cfg->rc_ifindex);
 	if (err)
 		goto errout;
 
@@ -551,8 +576,9 @@ errout:
 	return err;
 }
 
-static int mpls_nh_build(struct net *net, struct mpls_nh *nh,
-			 int oif, struct nlattr *via, struct nlattr *newdst)
+static int mpls_nh_build(struct net *net, struct mpls_route *rt,
+			 struct mpls_nh *nh, int oif,
+			 struct nlattr *via, struct nlattr *newdst)
 {
 	int err = -ENOMEM;
 
@@ -567,11 +593,11 @@ static int mpls_nh_build(struct net *net, struct mpls_nh *nh,
 	}
 
 	err = nla_get_via(via, &nh->nh_via_alen, &nh->nh_via_table,
-			  nh->nh_via);
+			  __mpls_nh_via(rt, nh));
 	if (err)
 		goto errout;
 
-	err = mpls_nh_assign_dev(net, nh, oif);
+	err = mpls_nh_assign_dev(net, rt, nh, oif);
 	if (err)
 		goto errout;
 
@@ -581,12 +607,35 @@ errout:
 	return err;
 }
 
-static int mpls_count_nexthops(struct rtnexthop *rtnh, int len)
+static int mpls_count_nexthops(struct rtnexthop *rtnh, int len,
+			       u8 cfg_via_alen, u8 *max_via_alen)
 {
 	int nhs = 0;
 	int remaining = len;
 
+	if (!rtnh) {
+		*max_via_alen = cfg_via_alen;
+		return 1;
+	}
+
+	*max_via_alen = 0;
+
 	while (rtnh_ok(rtnh, remaining)) {
+		struct nlattr *nla, *attrs = rtnh_attrs(rtnh);
+		int attrlen;
+
+		attrlen = rtnh_attrlen(rtnh);
+		nla = nla_find(attrs, attrlen, RTA_VIA);
+		if (nla && nla_len(nla) >=
+		    offsetof(struct rtvia, rtvia_addr)) {
+			int via_alen = nla_len(nla) -
+				offsetof(struct rtvia, rtvia_addr);
+
+			if (via_alen <= MAX_VIA_ALEN)
+				*max_via_alen = max_t(u16, *max_via_alen,
+						      via_alen);
+		}
+
 		nhs++;
 		rtnh = rtnh_next(rtnh, &remaining);
 	}
@@ -631,7 +680,7 @@ static int mpls_nh_build_multi(struct mpls_route_config *cfg,
 		if (!nla_via)
 			goto errout;
 
-		err = mpls_nh_build(cfg->rc_nlinfo.nl_net, nh,
+		err = mpls_nh_build(cfg->rc_nlinfo.nl_net, rt, nh,
 				    rtnh->rtnh_ifindex, nla_via,
 				    nla_newdst);
 		if (err)
@@ -655,8 +704,9 @@ static int mpls_route_add(struct mpls_route_config *cfg)
 	struct net *net = cfg->rc_nlinfo.nl_net;
 	struct mpls_route *rt, *old;
 	int err = -EINVAL;
+	u8 max_via_alen;
 	unsigned index;
-	int nhs = 1; /* default to one nexthop */
+	int nhs;
 
 	index = cfg->rc_label;
 
@@ -693,15 +743,14 @@ static int mpls_route_add(struct mpls_route_config *cfg)
 	if (!(cfg->rc_nlflags & NLM_F_CREATE) && !old)
 		goto errout;
 
-	if (cfg->rc_mp) {
-		err = -EINVAL;
-		nhs = mpls_count_nexthops(cfg->rc_mp, cfg->rc_mp_len);
-		if (nhs == 0)
-			goto errout;
-	}
+	err = -EINVAL;
+	nhs = mpls_count_nexthops(cfg->rc_mp, cfg->rc_mp_len,
+				  cfg->rc_via_alen, &max_via_alen);
+	if (nhs == 0)
+		goto errout;
 
 	err = -ENOMEM;
-	rt = mpls_rt_alloc(nhs);
+	rt = mpls_rt_alloc(nhs, max_via_alen);
 	if (!rt)
 		goto errout;
 
@@ -1176,13 +1225,13 @@ static int mpls_dump_route(struct sk_buff *skb, u32 portid, u32 seq, int event,
 	if (nla_put_labels(skb, RTA_DST, 1, &label))
 		goto nla_put_failure;
 	if (rt->rt_nhn == 1) {
-		struct mpls_nh *nh = rt->rt_nh;
+		const struct mpls_nh *nh = rt->rt_nh;
 
 		if (nh->nh_labels &&
 		    nla_put_labels(skb, RTA_NEWDST, nh->nh_labels,
 				   nh->nh_label))
 			goto nla_put_failure;
-		if (nla_put_via(skb, nh->nh_via_table, nh->nh_via,
+		if (nla_put_via(skb, nh->nh_via_table, mpls_nh_via(rt, nh),
 				nh->nh_via_alen))
 			goto nla_put_failure;
 		dev = rtnl_dereference(nh->nh_dev);
@@ -1209,7 +1258,7 @@ static int mpls_dump_route(struct sk_buff *skb, u32 portid, u32 seq, int event,
 							    nh->nh_label))
 				goto nla_put_failure;
 			if (nla_put_via(skb, nh->nh_via_table,
-					nh->nh_via,
+					mpls_nh_via(rt, nh),
 					nh->nh_via_alen))
 				goto nla_put_failure;
 
@@ -1338,7 +1387,7 @@ static int resize_platform_label_table(struct net *net, size_t limit)
 	/* In case the predefined labels need to be populated */
 	if (limit > MPLS_LABEL_IPV4NULL) {
 		struct net_device *lo = net->loopback_dev;
-		rt0 = mpls_rt_alloc(1);
+		rt0 = mpls_rt_alloc(1, lo->addr_len);
 		if (!rt0)
 			goto nort0;
 		RCU_INIT_POINTER(rt0->rt_nh->nh_dev, lo);
@@ -1346,11 +1395,12 @@ static int resize_platform_label_table(struct net *net, size_t limit)
 		rt0->rt_payload_type = MPT_IPV4;
 		rt0->rt_nh->nh_via_table = NEIGH_LINK_TABLE;
 		rt0->rt_nh->nh_via_alen = lo->addr_len;
-		memcpy(rt0->rt_nh->nh_via, lo->dev_addr, lo->addr_len);
+		memcpy(__mpls_nh_via(rt0, rt0->rt_nh), lo->dev_addr,
+		       lo->addr_len);
 	}
 	if (limit > MPLS_LABEL_IPV6NULL) {
 		struct net_device *lo = net->loopback_dev;
-		rt2 = mpls_rt_alloc(1);
+		rt2 = mpls_rt_alloc(1, lo->addr_len);
 		if (!rt2)
 			goto nort2;
 		RCU_INIT_POINTER(rt2->rt_nh->nh_dev, lo);
@@ -1358,7 +1408,8 @@ static int resize_platform_label_table(struct net *net, size_t limit)
 		rt2->rt_payload_type = MPT_IPV6;
 		rt2->rt_nh->nh_via_table = NEIGH_LINK_TABLE;
 		rt2->rt_nh->nh_via_alen = lo->addr_len;
-		memcpy(rt2->rt_nh->nh_via, lo->dev_addr, lo->addr_len);
+		memcpy(__mpls_nh_via(rt2, rt2->rt_nh), lo->dev_addr,
+		       lo->addr_len);
 	}
 
 	rtnl_lock();
diff --git a/net/mpls/internal.h b/net/mpls/internal.h
index d7757be39877..bde52ce88c94 100644
--- a/net/mpls/internal.h
+++ b/net/mpls/internal.h
@@ -25,7 +25,8 @@ struct sk_buff;
 #define MAX_NEW_LABELS 2
 
 /* This maximum ha length copied from the definition of struct neighbour */
-#define MAX_VIA_ALEN (ALIGN(MAX_ADDR_LEN, sizeof(unsigned long)))
+#define VIA_ALEN_ALIGN sizeof(unsigned long)
+#define MAX_VIA_ALEN (ALIGN(MAX_ADDR_LEN, VIA_ALEN_ALIGN))
 
 enum mpls_payload_type {
 	MPT_UNSPEC, /* IPv4 or IPv6 */
@@ -44,14 +45,35 @@ struct mpls_nh { /* next hop label forwarding entry */
 	u8			nh_labels;
 	u8			nh_via_alen;
 	u8			nh_via_table;
-	u8			nh_via[MAX_VIA_ALEN];
 };
 
+/* The route, nexthops and vias are stored together in the same memory
+ * block:
+ *
+ * +----------------------+
+ * | mpls_route           |
+ * +----------------------+
+ * | mpls_nh 0            |
+ * +----------------------+
+ * | ...                  |
+ * +----------------------+
+ * | mpls_nh n-1          |
+ * +----------------------+
+ * | alignment padding    |
+ * +----------------------+
+ * | via[rt_max_alen] 0   |
+ * +----------------------+
+ * | ...                  |
+ * +----------------------+
+ * | via[rt_max_alen] n-1 |
+ * +----------------------+
+ */
 struct mpls_route { /* next hop label forwarding entry */
 	struct rcu_head		rt_rcu;
 	u8			rt_protocol;
 	u8			rt_payload_type;
-	int			rt_nhn;
+	u8			rt_max_alen;
+	unsigned int		rt_nhn;
 	struct mpls_nh		rt_nh[0];
 };
 
-- 
2.1.4

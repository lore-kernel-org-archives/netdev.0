From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next 1/3] mpls: move mpls_route nexthop fields to a new nhlfe struct
Date: Tue, 11 Aug 2015 14:45:46 -0700
Message-ID: <1439329548-50935-2-git-send-email-roopa@cumulusnetworks.com>
Cc: ebiederm@xmission.com, rshearma@brocade.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:35267 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753562AbbHKVp4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2015 17:45:56 -0400
Received: by pdrg1 with SMTP id g1so87830236pdr.2
        for <netdev@vger.kernel.org>; Tue, 11 Aug 2015 14:45:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

moves mpls_route nexthop fields to a new mpls_nhlfe
struct. mpls_nhlfe represents a mpls nexthop label forwarding entry.
It prepares mpls route structure for multipath support.

In the process moves mpls_route structure into internal.h.
Moves some of the code from mpls_route_add into a separate mpls
nhlfe build function. changed mpls_rt_alloc to take number of
nexthops as argument.

A mpls route can point to multiple mpls_nhlfe. This patch
does not support multipath yet, hence the rest of the changes
assume that a mpls route points to a single mpls_nhlfe

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 net/mpls/af_mpls.c  |  225 ++++++++++++++++++++++++++++-----------------------
 net/mpls/internal.h |   35 ++++++++
 2 files changed, 158 insertions(+), 102 deletions(-)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 8c5707d..cf86e9d 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -21,35 +21,6 @@
 #endif
 #include "internal.h"
 
-#define LABEL_NOT_SPECIFIED (1<<20)
-#define MAX_NEW_LABELS 2
-
-/* This maximum ha length copied from the definition of struct neighbour */
-#define MAX_VIA_ALEN (ALIGN(MAX_ADDR_LEN, sizeof(unsigned long)))
-
-enum mpls_payload_type {
-	MPT_UNSPEC, /* IPv4 or IPv6 */
-	MPT_IPV4 = 4,
-	MPT_IPV6 = 6,
-
-	/* Other types not implemented:
-	 *  - Pseudo-wire with or without control word (RFC4385)
-	 *  - GAL (RFC5586)
-	 */
-};
-
-struct mpls_route { /* next hop label forwarding entry */
-	struct net_device __rcu *rt_dev;
-	struct rcu_head		rt_rcu;
-	u32			rt_label[MAX_NEW_LABELS];
-	u8			rt_protocol; /* routing protocol that set this entry */
-	u8                      rt_payload_type;
-	u8			rt_labels;
-	u8			rt_via_alen;
-	u8			rt_via_table;
-	u8			rt_via[0];
-};
-
 static int zero = 0;
 static int label_limit = (1 << 20) - 1;
 
@@ -83,7 +54,7 @@ EXPORT_SYMBOL_GPL(mpls_output_possible);
 static unsigned int mpls_rt_header_size(const struct mpls_route *rt)
 {
 	/* The size of the layer 2.5 labels to be added for this route */
-	return rt->rt_labels * sizeof(struct mpls_shim_hdr);
+	return rt->rt_nh->nh_labels * sizeof(struct mpls_shim_hdr);
 }
 
 unsigned int mpls_dev_mtu(const struct net_device *dev)
@@ -124,7 +95,7 @@ static bool mpls_egress(struct mpls_route *rt, struct sk_buff *skb,
 	if (!pskb_may_pull(skb, 12))
 		return false;
 
-	payload_type = rt->rt_payload_type;
+	payload_type = rt->rt_nh->nh_payload_type;
 	if (payload_type == MPT_UNSPEC)
 		payload_type = ip_hdr(skb)->version;
 
@@ -197,7 +168,7 @@ static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
 		goto drop;
 
 	/* Find the output device */
-	out_dev = rcu_dereference(rt->rt_dev);
+	out_dev = rcu_dereference(rt->rt_nh->nh_dev);
 	if (!mpls_output_possible(out_dev))
 		goto drop;
 
@@ -240,13 +211,15 @@ static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
 		/* Push the new labels */
 		hdr = mpls_hdr(skb);
 		bos = dec.bos;
-		for (i = rt->rt_labels - 1; i >= 0; i--) {
-			hdr[i] = mpls_entry_encode(rt->rt_label[i], dec.ttl, 0, bos);
+		for (i = rt->rt_nh->nh_labels - 1; i >= 0; i--) {
+			hdr[i] = mpls_entry_encode(rt->rt_nh->nh_label[i],
+						   dec.ttl, 0, bos);
 			bos = false;
 		}
 	}
 
-	err = neigh_xmit(rt->rt_via_table, out_dev, rt->rt_via, skb);
+	err = neigh_xmit(rt->rt_nh->nh_via_table, out_dev, rt->rt_nh->nh_via,
+			 skb);
 	if (err)
 		net_dbg_ratelimited("%s: packet transmission failed: %d\n",
 				    __func__, err);
@@ -281,13 +254,15 @@ struct mpls_route_config {
 	struct nl_info		rc_nlinfo;
 };
 
-static struct mpls_route *mpls_rt_alloc(size_t alen)
+static struct mpls_route *mpls_rt_alloc(int num_nh)
 {
 	struct mpls_route *rt;
 
-	rt = kzalloc(sizeof(*rt) + alen, GFP_KERNEL);
+	rt = kzalloc(sizeof(*rt) + (num_nh * sizeof(struct mpls_nhlfe)),
+		     GFP_KERNEL);
 	if (rt)
-		rt->rt_via_alen = alen;
+		rt->rt_nhn = num_nh;
+
 	return rt;
 }
 
@@ -322,7 +297,7 @@ static void mpls_route_update(struct net *net, unsigned index,
 
 	platform_label = rtnl_dereference(net->mpls.platform_label);
 	rt = rtnl_dereference(platform_label[index]);
-	if (!dev || (rt && (rtnl_dereference(rt->rt_dev) == dev))) {
+	if (!dev || (rt && (rtnl_dereference(rt->rt_nh->nh_dev) == dev))) {
 		rcu_assign_pointer(platform_label[index], new);
 		old = rt;
 	}
@@ -406,23 +381,23 @@ static struct net_device *inet6_fib_lookup_dev(struct net *net, void *addr)
 #endif
 
 static struct net_device *find_outdev(struct net *net,
-				      struct mpls_route_config *cfg)
+				      struct mpls_nhlfe *nhlfe, int oif)
 {
 	struct net_device *dev = NULL;
 
-	if (!cfg->rc_ifindex) {
-		switch (cfg->rc_via_table) {
+	if (!oif) {
+		switch (nhlfe->nh_via_table) {
 		case NEIGH_ARP_TABLE:
-			dev = inet_fib_lookup_dev(net, cfg->rc_via);
+			dev = inet_fib_lookup_dev(net, nhlfe->nh_via);
 			break;
 		case NEIGH_ND_TABLE:
-			dev = inet6_fib_lookup_dev(net, cfg->rc_via);
+			dev = inet6_fib_lookup_dev(net, nhlfe->nh_via);
 			break;
 		case NEIGH_LINK_TABLE:
 			break;
 		}
 	} else {
-		dev = dev_get_by_index(net, cfg->rc_ifindex);
+		dev = dev_get_by_index(net, oif);
 	}
 
 	if (!dev)
@@ -431,15 +406,81 @@ static struct net_device *find_outdev(struct net *net,
 	return dev;
 }
 
+int mpls_nhlfe_assign_dev(struct net *net, struct mpls_nhlfe *nhlfe, int oif)
+{
+	struct net_device *dev = NULL;
+	int err = -ENODEV;
+
+	dev = find_outdev(net, nhlfe, oif);
+	if (IS_ERR(dev)) {
+		err = PTR_ERR(dev);
+		dev = NULL;
+		goto errout;
+	}
+
+	/* Ensure this is a supported device */
+	err = -EINVAL;
+	if (!mpls_dev_get(dev))
+		goto errout;
+
+	/* For now just support ethernet devices */
+	err = -EINVAL;
+	if ((dev->type != ARPHRD_ETHER) && (dev->type != ARPHRD_LOOPBACK))
+		goto errout;
+
+	RCU_INIT_POINTER(nhlfe->nh_dev, dev);
+	dev_put(dev);
+
+	return 0;
+
+errout:
+	if (dev)
+		dev_put(dev);
+	return err;
+}
+
+static int mpls_nhlfe_build(struct mpls_route_config *cfg,
+			    struct mpls_nhlfe *nhlfe)
+{
+	struct net *net = cfg->rc_nlinfo.nl_net;
+	int err = -ENOMEM;
+	int i;
+
+	if (!nhlfe)
+		goto errout;
+
+	err = -EINVAL;
+	/* Ensure only a supported number of labels are present */
+	if (cfg->rc_output_labels > MAX_NEW_LABELS)
+		goto errout;
+
+	nhlfe->nh_labels = cfg->rc_output_labels;
+	for (i = 0; i < nhlfe->nh_labels; i++)
+		nhlfe->nh_label[i] = cfg->rc_output_label[i];
+
+	nhlfe->nh_payload_type = cfg->rc_payload_type;
+	nhlfe->nh_via_table = cfg->rc_via_table;
+	memcpy(nhlfe->nh_via, cfg->rc_via, cfg->rc_via_alen);
+	nhlfe->nh_via_alen = cfg->rc_via_alen;
+
+	err = mpls_nhlfe_assign_dev(net, nhlfe, cfg->rc_ifindex);
+	if (err)
+		goto errout;
+
+	return 0;
+
+errout:
+	return err;
+}
+
 static int mpls_route_add(struct mpls_route_config *cfg)
 {
 	struct mpls_route __rcu **platform_label;
 	struct net *net = cfg->rc_nlinfo.nl_net;
-	struct net_device *dev = NULL;
 	struct mpls_route *rt, *old;
-	unsigned index;
-	int i;
 	int err = -EINVAL;
+	unsigned index;
+	int nhs = 1; /* default to one nexthop */
 
 	index = cfg->rc_label;
 
@@ -457,27 +498,6 @@ static int mpls_route_add(struct mpls_route_config *cfg)
 	if (index >= net->mpls.platform_labels)
 		goto errout;
 
-	/* Ensure only a supported number of labels are present */
-	if (cfg->rc_output_labels > MAX_NEW_LABELS)
-		goto errout;
-
-	dev = find_outdev(net, cfg);
-	if (IS_ERR(dev)) {
-		err = PTR_ERR(dev);
-		dev = NULL;
-		goto errout;
-	}
-
-	/* Ensure this is a supported device */
-	err = -EINVAL;
-	if (!mpls_dev_get(dev))
-		goto errout;
-
-	err = -EINVAL;
-	if ((cfg->rc_via_table == NEIGH_LINK_TABLE) &&
-	    (dev->addr_len != cfg->rc_via_alen))
-		goto errout;
-
 	/* Append makes no sense with mpls */
 	err = -EOPNOTSUPP;
 	if (cfg->rc_nlflags & NLM_F_APPEND)
@@ -498,27 +518,22 @@ static int mpls_route_add(struct mpls_route_config *cfg)
 		goto errout;
 
 	err = -ENOMEM;
-	rt = mpls_rt_alloc(cfg->rc_via_alen);
+	rt = mpls_rt_alloc(nhs);
 	if (!rt)
 		goto errout;
-
-	rt->rt_labels = cfg->rc_output_labels;
-	for (i = 0; i < rt->rt_labels; i++)
-		rt->rt_label[i] = cfg->rc_output_label[i];
 	rt->rt_protocol = cfg->rc_protocol;
-	RCU_INIT_POINTER(rt->rt_dev, dev);
-	rt->rt_payload_type = cfg->rc_payload_type;
-	rt->rt_via_table = cfg->rc_via_table;
-	memcpy(rt->rt_via, cfg->rc_via, cfg->rc_via_alen);
+
+	err = mpls_nhlfe_build(cfg, rt->rt_nh);
+	if (err)
+		goto freert;
 
 	mpls_route_update(net, index, NULL, rt, &cfg->rc_nlinfo);
 
-	dev_put(dev);
 	return 0;
 
+freert:
+	mpls_rt_free(rt);
 errout:
-	if (dev)
-		dev_put(dev);
 	return err;
 }
 
@@ -635,9 +650,9 @@ static void mpls_ifdown(struct net_device *dev)
 		struct mpls_route *rt = rtnl_dereference(platform_label[index]);
 		if (!rt)
 			continue;
-		if (rtnl_dereference(rt->rt_dev) != dev)
+		if (rtnl_dereference(rt->rt_nh->nh_dev) != dev)
 			continue;
-		rt->rt_dev = NULL;
+		rt->rt_nh->nh_dev = NULL;
 	}
 
 	mdev = mpls_dev_get(dev);
@@ -927,6 +942,7 @@ static int mpls_rtm_newroute(struct sk_buff *skb, struct nlmsghdr *nlh)
 static int mpls_dump_route(struct sk_buff *skb, u32 portid, u32 seq, int event,
 			   u32 label, struct mpls_route *rt, int flags)
 {
+	struct mpls_nhlfe *nhlfe = rt->rt_nh;
 	struct net_device *dev;
 	struct nlmsghdr *nlh;
 	struct rtmsg *rtm;
@@ -946,12 +962,14 @@ static int mpls_dump_route(struct sk_buff *skb, u32 portid, u32 seq, int event,
 	rtm->rtm_type = RTN_UNICAST;
 	rtm->rtm_flags = 0;
 
-	if (rt->rt_labels &&
-	    nla_put_labels(skb, RTA_NEWDST, rt->rt_labels, rt->rt_label))
+	if (nhlfe->nh_labels &&
+	    nla_put_labels(skb, RTA_NEWDST, nhlfe->nh_labels,
+			   nhlfe->nh_label))
 		goto nla_put_failure;
-	if (nla_put_via(skb, rt->rt_via_table, rt->rt_via, rt->rt_via_alen))
+	if (nla_put_via(skb, nhlfe->nh_via_table, nhlfe->nh_via,
+			nhlfe->nh_via_alen))
 		goto nla_put_failure;
-	dev = rtnl_dereference(rt->rt_dev);
+	dev = rtnl_dereference(nhlfe->nh_dev);
 	if (dev && nla_put_u32(skb, RTA_OIF, dev->ifindex))
 		goto nla_put_failure;
 	if (nla_put_labels(skb, RTA_DST, 1, &label))
@@ -998,14 +1016,17 @@ static int mpls_dump_routes(struct sk_buff *skb, struct netlink_callback *cb)
 
 static inline size_t lfib_nlmsg_size(struct mpls_route *rt)
 {
+	struct mpls_nhlfe *nhlfe = rt->rt_nh;
 	size_t payload =
 		NLMSG_ALIGN(sizeof(struct rtmsg))
-		+ nla_total_size(2 + rt->rt_via_alen)	/* RTA_VIA */
 		+ nla_total_size(4);			/* RTA_DST */
-	if (rt->rt_labels)				/* RTA_NEWDST */
-		payload += nla_total_size(rt->rt_labels * 4);
-	if (rt->rt_dev)					/* RTA_OIF */
-		payload += nla_total_size(4);
+
+	if (nhlfe->nh_dev)
+		payload += nla_total_size(4); /* RTA_OIF */
+	payload += nla_total_size(2 + nhlfe->nh_via_alen); /* RTA_VIA */
+	if (nhlfe->nh_labels) /* RTA_NEWDST */
+		payload += nla_total_size(nhlfe->nh_labels * 4);
+
 	return payload;
 }
 
@@ -1057,25 +1078,25 @@ static int resize_platform_label_table(struct net *net, size_t limit)
 	/* In case the predefined labels need to be populated */
 	if (limit > MPLS_LABEL_IPV4NULL) {
 		struct net_device *lo = net->loopback_dev;
-		rt0 = mpls_rt_alloc(lo->addr_len);
+		rt0 = mpls_rt_alloc(1);
 		if (!rt0)
 			goto nort0;
-		RCU_INIT_POINTER(rt0->rt_dev, lo);
+		RCU_INIT_POINTER(rt0->rt_nh->nh_dev, lo);
 		rt0->rt_protocol = RTPROT_KERNEL;
-		rt0->rt_payload_type = MPT_IPV4;
-		rt0->rt_via_table = NEIGH_LINK_TABLE;
-		memcpy(rt0->rt_via, lo->dev_addr, lo->addr_len);
+		rt0->rt_nh->nh_payload_type = MPT_IPV4;
+		rt0->rt_nh->nh_via_table = NEIGH_LINK_TABLE;
+		memcpy(rt0->rt_nh->nh_via, lo->dev_addr, lo->addr_len);
 	}
 	if (limit > MPLS_LABEL_IPV6NULL) {
 		struct net_device *lo = net->loopback_dev;
-		rt2 = mpls_rt_alloc(lo->addr_len);
+		rt2 = mpls_rt_alloc(1);
 		if (!rt2)
 			goto nort2;
-		RCU_INIT_POINTER(rt2->rt_dev, lo);
+		RCU_INIT_POINTER(rt2->rt_nh->nh_dev, lo);
 		rt2->rt_protocol = RTPROT_KERNEL;
-		rt2->rt_payload_type = MPT_IPV6;
-		rt2->rt_via_table = NEIGH_LINK_TABLE;
-		memcpy(rt2->rt_via, lo->dev_addr, lo->addr_len);
+		rt2->rt_nh->nh_payload_type = MPT_IPV6;
+		rt2->rt_nh->nh_via_table = NEIGH_LINK_TABLE;
+		memcpy(rt2->rt_nh->nh_via, lo->dev_addr, lo->addr_len);
 	}
 
 	rtnl_lock();
diff --git a/net/mpls/internal.h b/net/mpls/internal.h
index 2681a4b..f05e2e8 100644
--- a/net/mpls/internal.h
+++ b/net/mpls/internal.h
@@ -1,6 +1,17 @@
 #ifndef MPLS_INTERNAL_H
 #define MPLS_INTERNAL_H
 
+enum mpls_payload_type {
+	MPT_UNSPEC, /* IPv4 or IPv6 */
+	MPT_IPV4 = 4,
+	MPT_IPV6 = 6,
+
+	/* Other types not implemented:
+	 *  - Pseudo-wire with or without control word (RFC4385)
+	 *  - GAL (RFC5586)
+	 */
+};
+
 struct mpls_shim_hdr {
 	__be32 label_stack_entry;
 };
@@ -21,6 +32,30 @@ struct mpls_dev {
 
 struct sk_buff;
 
+#define LABEL_NOT_SPECIFIED (1 << 20)
+#define MAX_NEW_LABELS 2
+
+/* This maximum ha length copied from the definition of struct neighbour */
+#define MAX_VIA_ALEN (ALIGN(MAX_ADDR_LEN, sizeof(unsigned long)))
+
+struct mpls_nhlfe { /* next hop label forwarding entry */
+	struct net_device __rcu *nh_dev;
+	u32			nh_label[MAX_NEW_LABELS];
+	unsigned int		nh_flags;
+	u8			nh_payload_type;
+	u8			nh_labels;
+	u8			nh_via_alen;
+	u8			nh_via_table;
+	u8			nh_via[MAX_VIA_ALEN];
+};
+
+struct mpls_route { /* next hop label forwarding entry */
+	struct rcu_head		rt_rcu;
+	u8			rt_protocol;
+	int			rt_nhn;
+	struct mpls_nhlfe	rt_nh[0];
+};
+
 static inline struct mpls_shim_hdr *mpls_hdr(const struct sk_buff *skb)
 {
 	return (struct mpls_shim_hdr *)skb_network_header(skb);
-- 
1.7.10.4

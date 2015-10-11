From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next v3 1/2] mpls: multipath route support
Date: Sun, 11 Oct 2015 11:29:33 -0700
Message-ID: <1444588174-44663-2-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, ebiederm@xmission.com, rshearma@brocade.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:36141 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752454AbbJKS3j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Oct 2015 14:29:39 -0400
Received: by pablk4 with SMTP id lk4so133528788pab.3
        for <netdev@vger.kernel.org>; Sun, 11 Oct 2015 11:29:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch adds support for MPLS multipath routes.

Includes following changes to support multipath:
- splits struct mpls_route into 'struct mpls_route + struct mpls_nh'

- 'struct mpls_nh' represents a mpls nexthop label forwarding entry

- moves mpls route and nexthop structures into internal.h

- A mpls_route can point to multiple mpls_nh structs

- the nexthops are maintained as a array (similar to ipv4 fib)

- In the process of restructuring, this patch also consistently changes
  all labels to u8

- Adds support to parse/fill RTA_MULTIPATH netlink attribute for
multipath routes similar to ipv4/v6 fib

- In this patch, the multipath route nexthop selection algorithm
simply returns the first nexthop. It is replaced by a
hash based algorithm from Robert Shearman in the next patch

- mpls_route_update cleanup: remove 'dev' handling in mpls_route_update.
mpls_route_update though implemented to update based on dev, it was
never used that way. And the dev handling gets tricky with multiple nexthops.
Cannot match against any single nexthops dev. So, this patch removes the unused
'dev' handling in mpls_route_update.

Example:

$ip -f mpls route add 100 nexthop as 200 via inet 10.1.1.2 dev swp1 \
                nexthop as 700 via inet 10.1.1.6 dev swp2 \
                nexthop as 800 via inet 40.1.1.2 dev swp3

$ip  -f mpls route show
100
        nexthop as to 200 via inet 10.1.1.2  dev swp1
        nexthop as to 700 via inet 10.1.1.6  dev swp2
        nexthop as to 800 via inet 40.1.1.2  dev swp3

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 include/net/mpls_iptunnel.h |   2 +-
 net/mpls/af_mpls.c          | 500 +++++++++++++++++++++++++++++++-------------
 net/mpls/internal.h         |  52 ++++-
 3 files changed, 404 insertions(+), 150 deletions(-)

diff --git a/include/net/mpls_iptunnel.h b/include/net/mpls_iptunnel.h
index 4757997..179253f 100644
--- a/include/net/mpls_iptunnel.h
+++ b/include/net/mpls_iptunnel.h
@@ -18,7 +18,7 @@
 
 struct mpls_iptunnel_encap {
 	u32	label[MAX_NEW_LABELS];
-	u32	labels;
+	u8	labels;
 };
 
 static inline struct mpls_iptunnel_encap *mpls_lwtunnel_encap(struct lwtunnel_state *lwtstate)
diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index bb185a2..4d819df 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -19,37 +19,9 @@
 #include <net/ipv6.h>
 #include <net/addrconf.h>
 #endif
+#include <net/nexthop.h>
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
 
@@ -80,10 +52,10 @@ bool mpls_output_possible(const struct net_device *dev)
 }
 EXPORT_SYMBOL_GPL(mpls_output_possible);
 
-static unsigned int mpls_rt_header_size(const struct mpls_route *rt)
+static unsigned int mpls_nh_header_size(const struct mpls_nh *nh)
 {
 	/* The size of the layer 2.5 labels to be added for this route */
-	return rt->rt_labels * sizeof(struct mpls_shim_hdr);
+	return nh->nh_labels * sizeof(struct mpls_shim_hdr);
 }
 
 unsigned int mpls_dev_mtu(const struct net_device *dev)
@@ -105,6 +77,12 @@ bool mpls_pkt_too_big(const struct sk_buff *skb, unsigned int mtu)
 }
 EXPORT_SYMBOL_GPL(mpls_pkt_too_big);
 
+static struct mpls_nh *mpls_select_multipath(struct mpls_route *rt)
+{
+	/* assume single nexthop for now */
+	return &rt->rt_nh[0];
+}
+
 static bool mpls_egress(struct mpls_route *rt, struct sk_buff *skb,
 			struct mpls_entry_decoded dec)
 {
@@ -159,6 +137,7 @@ static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
 	struct net *net = dev_net(dev);
 	struct mpls_shim_hdr *hdr;
 	struct mpls_route *rt;
+	struct mpls_nh *nh;
 	struct mpls_entry_decoded dec;
 	struct net_device *out_dev;
 	struct mpls_dev *mdev;
@@ -166,6 +145,7 @@ static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
 	unsigned int new_header_size;
 	unsigned int mtu;
 	int err;
+	int nhidx;
 
 	/* Careful this entire function runs inside of an rcu critical section */
 
@@ -196,9 +176,13 @@ static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
 	if (!rt)
 		goto drop;
 
+	nh = mpls_select_multipath(rt);
+	if (!nh)
+		goto drop;
+
 	/* Find the output device */
-	out_dev = rcu_dereference(rt->rt_dev);
-	if (!mpls_output_possible(out_dev))
+	out_dev = rcu_dereference(nh->nh_dev);
+	if (!out_dev || !mpls_output_possible(out_dev))
 		goto drop;
 
 	if (skb_warn_if_lro(skb))
@@ -212,7 +196,7 @@ static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
 	dec.ttl -= 1;
 
 	/* Verify the destination can hold the packet */
-	new_header_size = mpls_rt_header_size(rt);
+	new_header_size = mpls_nh_header_size(nh);
 	mtu = mpls_dev_mtu(out_dev);
 	if (mpls_pkt_too_big(skb, mtu - new_header_size))
 		goto drop;
@@ -240,13 +224,14 @@ static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
 		/* Push the new labels */
 		hdr = mpls_hdr(skb);
 		bos = dec.bos;
-		for (i = rt->rt_labels - 1; i >= 0; i--) {
-			hdr[i] = mpls_entry_encode(rt->rt_label[i], dec.ttl, 0, bos);
+		for (i = nh->nh_labels - 1; i >= 0; i--) {
+			hdr[i] = mpls_entry_encode(nh->nh_label[i],
+						   dec.ttl, 0, bos);
 			bos = false;
 		}
 	}
 
-	err = neigh_xmit(rt->rt_via_table, out_dev, rt->rt_via, skb);
+	err = neigh_xmit(nh->nh_via_table, out_dev, nh->nh_via, skb);
 	if (err)
 		net_dbg_ratelimited("%s: packet transmission failed: %d\n",
 				    __func__, err);
@@ -270,24 +255,28 @@ static const struct nla_policy rtm_mpls_policy[RTA_MAX+1] = {
 struct mpls_route_config {
 	u32			rc_protocol;
 	u32			rc_ifindex;
-	u16			rc_via_table;
-	u16			rc_via_alen;
+	u8			rc_via_table;
+	u8			rc_via_alen;
 	u8			rc_via[MAX_VIA_ALEN];
 	u32			rc_label;
-	u32			rc_output_labels;
+	u8			rc_output_labels;
 	u32			rc_output_label[MAX_NEW_LABELS];
 	u32			rc_nlflags;
 	enum mpls_payload_type	rc_payload_type;
 	struct nl_info		rc_nlinfo;
+	struct rtnexthop	*rc_mp;
+	int			rc_mp_len;
 };
 
-static struct mpls_route *mpls_rt_alloc(size_t alen)
+static struct mpls_route *mpls_rt_alloc(int num_nh)
 {
 	struct mpls_route *rt;
 
-	rt = kzalloc(sizeof(*rt) + alen, GFP_KERNEL);
+	rt = kzalloc(sizeof(*rt) + (num_nh * sizeof(struct mpls_nh)),
+		     GFP_KERNEL);
 	if (rt)
-		rt->rt_via_alen = alen;
+		rt->rt_nhn = num_nh;
+
 	return rt;
 }
 
@@ -312,25 +301,22 @@ static void mpls_notify_route(struct net *net, unsigned index,
 }
 
 static void mpls_route_update(struct net *net, unsigned index,
-			      struct net_device *dev, struct mpls_route *new,
+			      struct mpls_route *new,
 			      const struct nl_info *info)
 {
 	struct mpls_route __rcu **platform_label;
-	struct mpls_route *rt, *old = NULL;
+	struct mpls_route *rt;
 
 	ASSERT_RTNL();
 
 	platform_label = rtnl_dereference(net->mpls.platform_label);
 	rt = rtnl_dereference(platform_label[index]);
-	if (!dev || (rt && (rtnl_dereference(rt->rt_dev) == dev))) {
-		rcu_assign_pointer(platform_label[index], new);
-		old = rt;
-	}
+	rcu_assign_pointer(platform_label[index], new);
 
-	mpls_notify_route(net, index, old, new, info);
+	mpls_notify_route(net, index, rt, new, info);
 
 	/* If we removed a route free it now */
-	mpls_rt_free(old);
+	mpls_rt_free(rt);
 }
 
 static unsigned find_free_label(struct net *net)
@@ -406,23 +392,23 @@ static struct net_device *inet6_fib_lookup_dev(struct net *net, void *addr)
 #endif
 
 static struct net_device *find_outdev(struct net *net,
-				      struct mpls_route_config *cfg)
+				      struct mpls_nh *nh, int oif)
 {
 	struct net_device *dev = NULL;
 
-	if (!cfg->rc_ifindex) {
-		switch (cfg->rc_via_table) {
+	if (!oif) {
+		switch (nh->nh_via_table) {
 		case NEIGH_ARP_TABLE:
-			dev = inet_fib_lookup_dev(net, cfg->rc_via);
+			dev = inet_fib_lookup_dev(net, nh->nh_via);
 			break;
 		case NEIGH_ND_TABLE:
-			dev = inet6_fib_lookup_dev(net, cfg->rc_via);
+			dev = inet6_fib_lookup_dev(net, nh->nh_via);
 			break;
 		case NEIGH_LINK_TABLE:
 			break;
 		}
 	} else {
-		dev = dev_get_by_index(net, cfg->rc_ifindex);
+		dev = dev_get_by_index(net, oif);
 	}
 
 	if (!dev)
@@ -431,15 +417,171 @@ static struct net_device *find_outdev(struct net *net,
 	return dev;
 }
 
+static int mpls_nh_assign_dev(struct net *net, struct mpls_nh *nh, int oif)
+{
+	struct net_device *dev = NULL;
+	int err = -ENODEV;
+
+	dev = find_outdev(net, nh, oif);
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
+	if ((dev->type != ARPHRD_ETHER) && (dev->type != ARPHRD_LOOPBACK))
+		goto errout;
+
+	RCU_INIT_POINTER(nh->nh_dev, dev);
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
+static int mpls_nh_build_from_cfg(struct mpls_route_config *cfg,
+				  struct mpls_route *rt)
+{
+	struct net *net = cfg->rc_nlinfo.nl_net;
+	struct mpls_nh *nh = rt->rt_nh;
+	int err;
+	int i;
+
+	if (!nh)
+		return -ENOMEM;
+
+	err = -EINVAL;
+	/* Ensure only a supported number of labels are present */
+	if (cfg->rc_output_labels > MAX_NEW_LABELS)
+		goto errout;
+
+	nh->nh_labels = cfg->rc_output_labels;
+	for (i = 0; i < nh->nh_labels; i++)
+		nh->nh_label[i] = cfg->rc_output_label[i];
+
+	nh->nh_via_table = cfg->rc_via_table;
+	memcpy(nh->nh_via, cfg->rc_via, cfg->rc_via_alen);
+	nh->nh_via_alen = cfg->rc_via_alen;
+
+	err = mpls_nh_assign_dev(net, nh, cfg->rc_ifindex);
+	if (err)
+		goto errout;
+
+	return 0;
+
+errout:
+	return err;
+}
+
+static int mpls_nh_build(struct net *net, struct mpls_nh *nh,
+			 int oif, struct nlattr *via, struct nlattr *newdst)
+{
+	int err = -ENOMEM;
+
+	if (!nh)
+		goto errout;
+
+	if (newdst) {
+		err = nla_get_labels(newdst, MAX_NEW_LABELS,
+			     &nh->nh_labels, nh->nh_label);
+		if (err)
+			goto errout;
+	}
+
+	err = nla_get_via(via, &nh->nh_via_alen, &nh->nh_via_table,
+			  nh->nh_via);
+	if (err)
+		goto errout;
+
+	err = mpls_nh_assign_dev(net, nh, oif);
+	if (err)
+		goto errout;
+
+	return 0;
+
+errout:
+	return err;
+}
+
+static int mpls_count_nexthops(struct rtnexthop *rtnh, int len)
+{
+	int nhs = 0;
+	int remaining = len;
+
+	while (rtnh_ok(rtnh, remaining)) {
+		nhs++;
+		rtnh = rtnh_next(rtnh, &remaining);
+	}
+
+	/* leftover implies invalid nexthop configuration, discard it */
+	return remaining > 0 ? 0 : nhs;
+}
+
+static int mpls_nh_build_multi(struct mpls_route_config *cfg,
+				  struct mpls_route *rt)
+{
+	struct rtnexthop *rtnh = cfg->rc_mp;
+	struct nlattr *nla_via, *nla_newdst;
+	int remaining = cfg->rc_mp_len;
+	int nhs = 0;
+	int err = 0;
+
+	change_nexthops(rt) {
+		int attrlen;
+
+		nla_via = nla_newdst = NULL;
+
+		err = -EINVAL;
+		if (!rtnh_ok(rtnh, remaining))
+			goto errout;
+
+		attrlen = rtnh_attrlen(rtnh);
+		if (attrlen > 0) {
+			struct nlattr *attrs = rtnh_attrs(rtnh);
+
+			nla_via = nla_find(attrs, attrlen, RTA_VIA);
+			nla_newdst = nla_find(attrs, attrlen, RTA_NEWDST);
+		}
+
+		if (!nla_via)
+			goto errout;
+
+		err = mpls_nh_build(cfg->rc_nlinfo.nl_net, nh,
+				       rtnh->rtnh_ifindex, nla_via,
+				       nla_newdst);
+		if (err)
+			goto errout;
+
+		rtnh = rtnh_next(rtnh, &remaining);
+		nhs++;
+	} endfor_nexthops(rt);
+
+	rt->rt_nhn = nhs;
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
+	int nhs =1; /* default to one nexthop */
 
 	index = cfg->rc_label;
 
@@ -457,27 +599,6 @@ static int mpls_route_add(struct mpls_route_config *cfg)
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
@@ -497,28 +618,35 @@ static int mpls_route_add(struct mpls_route_config *cfg)
 	if (!(cfg->rc_nlflags & NLM_F_CREATE) && !old)
 		goto errout;
 
+	if (cfg->rc_mp) {
+		err = -EINVAL;
+		nhs = mpls_count_nexthops(cfg->rc_mp, cfg->rc_mp_len);
+		if (nhs == 0)
+			goto errout;
+	}
+
 	err = -ENOMEM;
-	rt = mpls_rt_alloc(cfg->rc_via_alen);
+	rt = mpls_rt_alloc(nhs);
 	if (!rt)
 		goto errout;
 
-	rt->rt_labels = cfg->rc_output_labels;
-	for (i = 0; i < rt->rt_labels; i++)
-		rt->rt_label[i] = cfg->rc_output_label[i];
 	rt->rt_protocol = cfg->rc_protocol;
-	RCU_INIT_POINTER(rt->rt_dev, dev);
 	rt->rt_payload_type = cfg->rc_payload_type;
-	rt->rt_via_table = cfg->rc_via_table;
-	memcpy(rt->rt_via, cfg->rc_via, cfg->rc_via_alen);
 
-	mpls_route_update(net, index, NULL, rt, &cfg->rc_nlinfo);
+	if (cfg->rc_mp)
+		err = mpls_nh_build_multi(cfg, rt);
+	else
+		err = mpls_nh_build_from_cfg(cfg, rt);
+	if (err)
+		goto freert;
+
+	mpls_route_update(net, index, rt, &cfg->rc_nlinfo);
 
-	dev_put(dev);
 	return 0;
 
+freert:
+	mpls_rt_free(rt);
 errout:
-	if (dev)
-		dev_put(dev);
 	return err;
 }
 
@@ -538,7 +666,7 @@ static int mpls_route_del(struct mpls_route_config *cfg)
 	if (index >= net->mpls.platform_labels)
 		goto errout;
 
-	mpls_route_update(net, index, NULL, NULL, &cfg->rc_nlinfo);
+	mpls_route_update(net, index, NULL, &cfg->rc_nlinfo);
 
 	err = 0;
 errout:
@@ -635,9 +763,11 @@ static void mpls_ifdown(struct net_device *dev)
 		struct mpls_route *rt = rtnl_dereference(platform_label[index]);
 		if (!rt)
 			continue;
-		if (rtnl_dereference(rt->rt_dev) != dev)
-			continue;
-		rt->rt_dev = NULL;
+		for_nexthops(rt) {
+			if (rtnl_dereference(nh->nh_dev) != dev)
+				continue;
+			nh->nh_dev = NULL;
+		} endfor_nexthops(rt);
 	}
 
 	mdev = mpls_dev_get(dev);
@@ -736,7 +866,7 @@ int nla_put_labels(struct sk_buff *skb, int attrtype,
 EXPORT_SYMBOL_GPL(nla_put_labels);
 
 int nla_get_labels(const struct nlattr *nla,
-		   u32 max_labels, u32 *labels, u32 label[])
+		   u32 max_labels, u8 *labels, u32 label[])
 {
 	unsigned len = nla_len(nla);
 	unsigned nla_labels;
@@ -781,6 +911,48 @@ int nla_get_labels(const struct nlattr *nla,
 }
 EXPORT_SYMBOL_GPL(nla_get_labels);
 
+int nla_get_via(const struct nlattr *nla, u8 *via_alen,
+		u8 *via_table, u8 via_addr[])
+{
+	struct rtvia *via = nla_data(nla);
+	int err = -EINVAL;
+	u8 alen;
+
+	if (nla_len(nla) < offsetof(struct rtvia, rtvia_addr))
+		goto errout;
+	alen = nla_len(nla) -
+			offsetof(struct rtvia, rtvia_addr);
+	if (alen > MAX_VIA_ALEN)
+		goto errout;
+
+	/* Validate the address family */
+	switch(via->rtvia_family) {
+	case AF_PACKET:
+		*via_table = NEIGH_LINK_TABLE;
+		break;
+	case AF_INET:
+		*via_table = NEIGH_ARP_TABLE;
+		if (alen != 4)
+			goto errout;
+		break;
+	case AF_INET6:
+		*via_table = NEIGH_ND_TABLE;
+		if (alen != 16)
+			goto errout;
+		break;
+	default:
+		/* Unsupported address family */
+		goto errout;
+	}
+
+	memcpy(via_addr, via->rtvia_addr, alen);
+	*via_alen = alen;
+	err = 0;
+
+errout:
+	return err;
+}
+
 static int rtm_to_route_config(struct sk_buff *skb,  struct nlmsghdr *nlh,
 			       struct mpls_route_config *cfg)
 {
@@ -844,7 +1016,7 @@ static int rtm_to_route_config(struct sk_buff *skb,  struct nlmsghdr *nlh,
 			break;
 		case RTA_DST:
 		{
-			u32 label_count;
+			u8 label_count;
 			if (nla_get_labels(nla, 1, &label_count,
 					   &cfg->rc_label))
 				goto errout;
@@ -857,35 +1029,15 @@ static int rtm_to_route_config(struct sk_buff *skb,  struct nlmsghdr *nlh,
 		}
 		case RTA_VIA:
 		{
-			struct rtvia *via = nla_data(nla);
-			if (nla_len(nla) < offsetof(struct rtvia, rtvia_addr))
-				goto errout;
-			cfg->rc_via_alen   = nla_len(nla) -
-				offsetof(struct rtvia, rtvia_addr);
-			if (cfg->rc_via_alen > MAX_VIA_ALEN)
+			if (nla_get_via(nla, &cfg->rc_via_alen,
+					&cfg->rc_via_table, cfg->rc_via))
 				goto errout;
-
-			/* Validate the address family */
-			switch(via->rtvia_family) {
-			case AF_PACKET:
-				cfg->rc_via_table = NEIGH_LINK_TABLE;
-				break;
-			case AF_INET:
-				cfg->rc_via_table = NEIGH_ARP_TABLE;
-				if (cfg->rc_via_alen != 4)
-					goto errout;
-				break;
-			case AF_INET6:
-				cfg->rc_via_table = NEIGH_ND_TABLE;
-				if (cfg->rc_via_alen != 16)
-					goto errout;
-				break;
-			default:
-				/* Unsupported address family */
-				goto errout;
-			}
-
-			memcpy(cfg->rc_via, via->rtvia_addr, cfg->rc_via_alen);
+			break;
+		}
+		case RTA_MULTIPATH:
+		{
+			cfg->rc_mp = nla_data(nla);
+			cfg->rc_mp_len = nla_len(nla);
 			break;
 		}
 		default:
@@ -946,16 +1098,51 @@ static int mpls_dump_route(struct sk_buff *skb, u32 portid, u32 seq, int event,
 	rtm->rtm_type = RTN_UNICAST;
 	rtm->rtm_flags = 0;
 
-	if (rt->rt_labels &&
-	    nla_put_labels(skb, RTA_NEWDST, rt->rt_labels, rt->rt_label))
-		goto nla_put_failure;
-	if (nla_put_via(skb, rt->rt_via_table, rt->rt_via, rt->rt_via_alen))
-		goto nla_put_failure;
-	dev = rtnl_dereference(rt->rt_dev);
-	if (dev && nla_put_u32(skb, RTA_OIF, dev->ifindex))
-		goto nla_put_failure;
 	if (nla_put_labels(skb, RTA_DST, 1, &label))
 		goto nla_put_failure;
+	if (rt->rt_nhn == 1) {
+		struct mpls_nh *nh = rt->rt_nh;
+
+		if (nh->nh_labels &&
+			nla_put_labels(skb, RTA_NEWDST, nh->nh_labels,
+				       nh->nh_label))
+			goto nla_put_failure;
+		if (nla_put_via(skb, nh->nh_via_table, nh->nh_via,
+				nh->nh_via_alen))
+			goto nla_put_failure;
+		dev = rtnl_dereference(nh->nh_dev);
+		if (dev && nla_put_u32(skb, RTA_OIF, dev->ifindex))
+			goto nla_put_failure;
+	} else {
+		struct rtnexthop *rtnh;
+		struct nlattr *mp;
+
+		mp = nla_nest_start(skb, RTA_MULTIPATH);
+		if (!mp)
+			goto nla_put_failure;
+
+		for_nexthops(rt) {
+			rtnh = nla_reserve_nohdr(skb, sizeof(*rtnh));
+			if (!rtnh)
+				goto nla_put_failure;
+
+			dev = rtnl_dereference(nh->nh_dev);
+			if (dev)
+				rtnh->rtnh_ifindex = dev->ifindex;
+			if (nh->nh_labels && nla_put_labels(skb,
+				RTA_NEWDST, nh->nh_labels, nh->nh_label))
+				goto nla_put_failure;
+			if (nla_put_via(skb, nh->nh_via_table,
+					nh->nh_via,
+					nh->nh_via_alen))
+				goto nla_put_failure;
+
+			/* length of rtnetlink header + attributes */
+			rtnh->rtnh_len = nlmsg_get_pos(skb) - (void *) rtnh;
+		} endfor_nexthops(rt);
+
+		nla_nest_end(skb, mp);
+	}
 
 	nlmsg_end(skb, nlh);
 	return 0;
@@ -1000,12 +1187,29 @@ static inline size_t lfib_nlmsg_size(struct mpls_route *rt)
 {
 	size_t payload =
 		NLMSG_ALIGN(sizeof(struct rtmsg))
-		+ nla_total_size(2 + rt->rt_via_alen)	/* RTA_VIA */
 		+ nla_total_size(4);			/* RTA_DST */
-	if (rt->rt_labels)				/* RTA_NEWDST */
-		payload += nla_total_size(rt->rt_labels * 4);
-	if (rt->rt_dev)					/* RTA_OIF */
-		payload += nla_total_size(4);
+
+	if (rt->rt_nhn == 1) {
+		struct mpls_nh *nh = rt->rt_nh;
+
+		if (nh->nh_dev)
+			payload += nla_total_size(4); /* RTA_OIF */
+		payload += nla_total_size(2 + nh->nh_via_alen); /* RTA_VIA */
+		if (nh->nh_labels) /* RTA_NEWDST */
+			payload += nla_total_size(nh->nh_labels * 4);
+	} else {
+		/* each nexthop is packed in an attribute */
+		size_t nhsize = 0;
+		for_nexthops(rt) {
+			nhsize += nla_total_size(sizeof(struct rtnexthop));
+			nhsize += nla_total_size(2 + nh->nh_via_alen); /* RTA_VIA */
+			if (nh->nh_labels)
+				nhsize += nla_total_size(nh->nh_labels * 4); /* RTA_NEWDST */
+		} endfor_nexthops(rt);
+		/* nested attribute */
+		payload += nla_total_size(nhsize);
+	}
+
 	return payload;
 }
 
@@ -1057,25 +1261,25 @@ static int resize_platform_label_table(struct net *net, size_t limit)
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
 		rt0->rt_payload_type = MPT_IPV4;
-		rt0->rt_via_table = NEIGH_LINK_TABLE;
-		memcpy(rt0->rt_via, lo->dev_addr, lo->addr_len);
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
 		rt2->rt_payload_type = MPT_IPV6;
-		rt2->rt_via_table = NEIGH_LINK_TABLE;
-		memcpy(rt2->rt_via, lo->dev_addr, lo->addr_len);
+		rt2->rt_nh->nh_via_table = NEIGH_LINK_TABLE;
+		memcpy(rt2->rt_nh->nh_via, lo->dev_addr, lo->addr_len);
 	}
 
 	rtnl_lock();
@@ -1085,7 +1289,7 @@ static int resize_platform_label_table(struct net *net, size_t limit)
 
 	/* Free any labels beyond the new table */
 	for (index = limit; index < old_limit; index++)
-		mpls_route_update(net, index, NULL, NULL, NULL);
+		mpls_route_update(net, index, NULL, NULL);
 
 	/* Copy over the old labels */
 	cp_size = size;
diff --git a/net/mpls/internal.h b/net/mpls/internal.h
index 2681a4b..d7757be3 100644
--- a/net/mpls/internal.h
+++ b/net/mpls/internal.h
@@ -21,6 +21,54 @@ struct mpls_dev {
 
 struct sk_buff;
 
+#define LABEL_NOT_SPECIFIED (1 << 20)
+#define MAX_NEW_LABELS 2
+
+/* This maximum ha length copied from the definition of struct neighbour */
+#define MAX_VIA_ALEN (ALIGN(MAX_ADDR_LEN, sizeof(unsigned long)))
+
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
+struct mpls_nh { /* next hop label forwarding entry */
+	struct net_device __rcu *nh_dev;
+	u32			nh_label[MAX_NEW_LABELS];
+	u8			nh_labels;
+	u8			nh_via_alen;
+	u8			nh_via_table;
+	u8			nh_via[MAX_VIA_ALEN];
+};
+
+struct mpls_route { /* next hop label forwarding entry */
+	struct rcu_head		rt_rcu;
+	u8			rt_protocol;
+	u8			rt_payload_type;
+	int			rt_nhn;
+	struct mpls_nh		rt_nh[0];
+};
+
+#define for_nexthops(rt) {						\
+	int nhsel; struct mpls_nh *nh;			\
+	for (nhsel = 0, nh = (rt)->rt_nh;				\
+	     nhsel < (rt)->rt_nhn;					\
+	     nh++, nhsel++)
+
+#define change_nexthops(rt) {						\
+	int nhsel; struct mpls_nh *nh;				\
+	for (nhsel = 0,	nh = (struct mpls_nh *)((rt)->rt_nh);	\
+	     nhsel < (rt)->rt_nhn;					\
+	     nh++, nhsel++)
+
+#define endfor_nexthops(rt) }
+
 static inline struct mpls_shim_hdr *mpls_hdr(const struct sk_buff *skb)
 {
 	return (struct mpls_shim_hdr *)skb_network_header(skb);
@@ -52,8 +100,10 @@ static inline struct mpls_entry_decoded mpls_entry_decode(struct mpls_shim_hdr *
 
 int nla_put_labels(struct sk_buff *skb, int attrtype,  u8 labels,
 		   const u32 label[]);
-int nla_get_labels(const struct nlattr *nla, u32 max_labels, u32 *labels,
+int nla_get_labels(const struct nlattr *nla, u32 max_labels, u8 *labels,
 		   u32 label[]);
+int nla_get_via(const struct nlattr *nla, u8 *via_alen, u8 *via_table,
+		u8 via[]);
 bool mpls_output_possible(const struct net_device *dev);
 unsigned int mpls_dev_mtu(const struct net_device *dev);
 bool mpls_pkt_too_big(const struct sk_buff *skb, unsigned int mtu);
-- 
1.9.1

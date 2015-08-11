From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next 3/3] mpls: add multipath route support
Date: Tue, 11 Aug 2015 14:45:48 -0700
Message-ID: <1439329548-50935-4-git-send-email-roopa@cumulusnetworks.com>
Cc: ebiederm@xmission.com, rshearma@brocade.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:35278 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753610AbbHKVp6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2015 17:45:58 -0400
Received: by pdrg1 with SMTP id g1so87830484pdr.2
        for <netdev@vger.kernel.org>; Tue, 11 Aug 2015 14:45:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

Adds support for MPLS multipath routes.
supports parse/fill of RTA_MULTIPATH netlink attribute
for multipath routes similar to ipv4 fib. Mostly based on
multipath handling in ipv4 fib code.

The multipath route nexthop selection algorithm is the same
code as in ipv4 fib.

This patch also adds new functions to parse multipath attributes
from route config into mpls_nhlfe.

note that it also simplifies mpls_route_update. Removes handling
route updates based on dev argument. The reason for
doing that is, the function was not being used for route updates
based on dev and if we do need to support route updates based
on dev in the future it will have to be done differently.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 net/mpls/af_mpls.c  |  378 +++++++++++++++++++++++++++++++++++++++++----------
 net/mpls/internal.h |   19 +++
 2 files changed, 323 insertions(+), 74 deletions(-)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index eb089ef..de5ae29 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -19,10 +19,12 @@
 #include <net/ipv6.h>
 #include <net/addrconf.h>
 #endif
+#include <net/nexthop.h>
 #include "internal.h"
 
 static int zero = 0;
 static int label_limit = (1 << 20) - 1;
+static DEFINE_SPINLOCK(mpls_multipath_lock);
 
 static void rtmsg_lfib(int event, u32 label, struct mpls_route *rt,
 		       struct nlmsghdr *nlh, struct net *net, u32 portid,
@@ -51,10 +53,10 @@ bool mpls_output_possible(const struct net_device *dev)
 }
 EXPORT_SYMBOL_GPL(mpls_output_possible);
 
-static unsigned int mpls_rt_header_size(const struct mpls_route *rt)
+static unsigned int mpls_nhlfe_header_size(const struct mpls_nhlfe *nhlfe)
 {
 	/* The size of the layer 2.5 labels to be added for this route */
-	return rt->rt_nh->nh_labels * sizeof(struct mpls_shim_hdr);
+	return nhlfe->nh_labels * sizeof(struct mpls_shim_hdr);
 }
 
 unsigned int mpls_dev_mtu(const struct net_device *dev)
@@ -76,7 +78,52 @@ bool mpls_pkt_too_big(const struct sk_buff *skb, unsigned int mtu)
 }
 EXPORT_SYMBOL_GPL(mpls_pkt_too_big);
 
-static bool mpls_egress(struct mpls_route *rt, struct sk_buff *skb,
+/* This is a cut/copy/modify from fib_select_multipath */
+static void mpls_select_multipath(struct mpls_route *rt, int *nhidx)
+{
+	int w;
+
+	spin_lock_bh(&mpls_multipath_lock);
+	if (rt->rt_power <= 0) {
+		int power = 0;
+
+		change_nexthops(rt) {
+			power += nhlfe->nh_weight;
+			nhlfe->nh_power = nhlfe->nh_weight;
+		} endfor_nexthops(rt);
+		rt->rt_power = power;
+		if (power <= 0) {
+			spin_unlock_bh(&mpls_multipath_lock);
+			/* Race condition: route has just become dead. */
+			*nhidx = 0;
+			return;
+		}
+	}
+
+	/* w should be random number [0..rt->rt_power-1],
+	 * it is pretty bad approximation.
+	 */
+	w = jiffies % rt->rt_power;
+
+	change_nexthops(rt) {
+		if (nhlfe->nh_power) {
+			w -= nhlfe->nh_power;
+			if (w <= 0) {
+				nhlfe->nh_power--;
+				rt->rt_power--;
+				*nhidx = nhsel;
+				spin_unlock_bh(&mpls_multipath_lock);
+				return;
+			}
+		}
+	} endfor_nexthops(rt);
+
+	/* Race condition: route has just become dead. */
+	*nhidx = 0;
+	spin_unlock_bh(&mpls_multipath_lock);
+}
+
+static bool mpls_egress(struct mpls_nhlfe *nhlfe, struct sk_buff *skb,
 			struct mpls_entry_decoded dec)
 {
 	enum mpls_payload_type payload_type;
@@ -95,7 +142,7 @@ static bool mpls_egress(struct mpls_route *rt, struct sk_buff *skb,
 	if (!pskb_may_pull(skb, 12))
 		return false;
 
-	payload_type = rt->rt_nh->nh_payload_type;
+	payload_type = nhlfe->nh_payload_type;
 	if (payload_type == MPT_UNSPEC)
 		payload_type = ip_hdr(skb)->version;
 
@@ -130,6 +177,7 @@ static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
 	struct net *net = dev_net(dev);
 	struct mpls_shim_hdr *hdr;
 	struct mpls_route *rt;
+	struct mpls_nhlfe *nhlfe;
 	struct mpls_entry_decoded dec;
 	struct net_device *out_dev;
 	struct mpls_dev *mdev;
@@ -137,6 +185,7 @@ static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
 	unsigned int new_header_size;
 	unsigned int mtu;
 	int err;
+	int nhidx;
 
 	/* Careful this entire function runs inside of an rcu critical section */
 
@@ -167,9 +216,12 @@ static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
 	if (!rt)
 		goto drop;
 
+	mpls_select_multipath(rt, &nhidx);
+	nhlfe = &rt->rt_nh[nhidx];
+
 	/* Find the output device */
-	out_dev = rcu_dereference(rt->rt_nh->nh_dev);
-	if (!mpls_output_possible(out_dev))
+	out_dev = rcu_dereference(nhlfe->nh_dev);
+	if (!out_dev || !mpls_output_possible(out_dev))
 		goto drop;
 
 	if (skb_warn_if_lro(skb))
@@ -183,7 +235,7 @@ static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
 	dec.ttl -= 1;
 
 	/* Verify the destination can hold the packet */
-	new_header_size = mpls_rt_header_size(rt);
+	new_header_size = mpls_nhlfe_header_size(nhlfe);
 	mtu = mpls_dev_mtu(out_dev);
 	if (mpls_pkt_too_big(skb, mtu - new_header_size))
 		goto drop;
@@ -201,7 +253,7 @@ static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
 
 	if (unlikely(!new_header_size && dec.bos)) {
 		/* Penultimate hop popping */
-		if (!mpls_egress(rt, skb, dec))
+		if (!mpls_egress(nhlfe, skb, dec))
 			goto drop;
 	} else {
 		bool bos;
@@ -211,15 +263,14 @@ static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
 		/* Push the new labels */
 		hdr = mpls_hdr(skb);
 		bos = dec.bos;
-		for (i = rt->rt_nh->nh_labels - 1; i >= 0; i--) {
-			hdr[i] = mpls_entry_encode(rt->rt_nh->nh_label[i],
+		for (i = nhlfe->nh_labels - 1; i >= 0; i--) {
+			hdr[i] = mpls_entry_encode(nhlfe->nh_label[i],
 						   dec.ttl, 0, bos);
 			bos = false;
 		}
 	}
 
-	err = neigh_xmit(rt->rt_nh->nh_via_table, out_dev, rt->rt_nh->nh_via,
-			 skb);
+	err = neigh_xmit(nhlfe->nh_via_table, out_dev, nhlfe->nh_via, skb);
 	if (err)
 		net_dbg_ratelimited("%s: packet transmission failed: %d\n",
 				    __func__, err);
@@ -252,6 +303,8 @@ struct mpls_route_config {
 	u32			rc_nlflags;
 	enum mpls_payload_type	rc_payload_type;
 	struct nl_info		rc_nlinfo;
+	struct rtnexthop	*rc_mp;
+	int			rc_mp_len;
 };
 
 static struct mpls_route *mpls_rt_alloc(int num_nh)
@@ -287,25 +340,22 @@ static void mpls_notify_route(struct net *net, unsigned index,
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
-	if (!dev || (rt && (rtnl_dereference(rt->rt_nh->nh_dev) == dev))) {
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
@@ -439,10 +489,11 @@ errout:
 	return err;
 }
 
-static int mpls_nhlfe_build(struct mpls_route_config *cfg,
-			    struct mpls_nhlfe *nhlfe)
+static int mpls_nhlfe_build_from_cfg(struct mpls_route_config *cfg,
+				     struct mpls_route *rt)
 {
 	struct net *net = cfg->rc_nlinfo.nl_net;
+	struct mpls_nhlfe *nhlfe = rt->rt_nh;
 	int err = -ENOMEM;
 	int i;
 
@@ -473,6 +524,98 @@ errout:
 	return err;
 }
 
+int mpls_nhlfe_build(struct net *net, struct mpls_nhlfe *nhlfe,
+		     int oif, struct nlattr *via, struct nlattr *newdst)
+{
+	int err = -ENOMEM;
+
+	if (!nhlfe)
+		goto errout;
+
+	if (newdst) {
+		err = nla_get_labels(newdst, MAX_NEW_LABELS,
+				     &nhlfe->nh_labels, nhlfe->nh_label);
+		if (err)
+			goto errout;
+	}
+
+	err = nla_get_via(via, &nhlfe->nh_via_alen, &nhlfe->nh_via_table,
+			  nhlfe->nh_via);
+	if (err)
+		goto errout;
+
+	err = mpls_nhlfe_assign_dev(net, nhlfe, oif);
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
+static int mpls_nhlfe_build_multi(struct mpls_route_config *cfg,
+				  struct mpls_route *rt)
+{
+	struct rtnexthop *rtnh = cfg->rc_mp;
+	struct nlattr *nla_via, *nla_newdst;
+	int remaining = cfg->rc_mp_len;
+	int n = 0;
+	int err = 0;
+
+	change_nexthops(rt) {
+		int attrlen;
+
+		nla_via = NULL;
+		nla_newdst = NULL;
+
+		err = -EINVAL;
+		if (!rtnh_ok(rtnh, remaining))
+			goto errout;
+
+		nhlfe->nh_weight = rtnh->rtnh_hops + 1;
+		attrlen = rtnh_attrlen(rtnh);
+		if (attrlen > 0) {
+			struct nlattr *attrs = rtnh_attrs(rtnh);
+
+			nla_via = nla_find(attrs, attrlen, RTA_VIA);
+			nla_newdst = nla_find(attrs, attrlen, RTA_NEWDST);
+		}
+
+		err = -EINVAL;
+		if (!nla_via)
+			goto errout;
+
+		err = mpls_nhlfe_build(cfg->rc_nlinfo.nl_net, nhlfe,
+				       rtnh->rtnh_ifindex, nla_via,
+				       nla_newdst);
+		if (err)
+			goto errout;
+
+		rtnh = rtnh_next(rtnh, &remaining);
+		n++;
+	} endfor_nexthops(rt);
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
@@ -517,17 +660,27 @@ static int mpls_route_add(struct mpls_route_config *cfg)
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
 	rt = mpls_rt_alloc(nhs);
 	if (!rt)
 		goto errout;
 	rt->rt_protocol = cfg->rc_protocol;
 
-	err = mpls_nhlfe_build(cfg, rt->rt_nh);
+	if (cfg->rc_mp)
+		err = mpls_nhlfe_build_multi(cfg, rt);
+	else
+		err = mpls_nhlfe_build_from_cfg(cfg, rt);
 	if (err)
 		goto freert;
 
-	mpls_route_update(net, index, NULL, rt, &cfg->rc_nlinfo);
+	mpls_route_update(net, index, rt, &cfg->rc_nlinfo);
 
 	return 0;
 
@@ -553,7 +706,7 @@ static int mpls_route_del(struct mpls_route_config *cfg)
 	if (index >= net->mpls.platform_labels)
 		goto errout;
 
-	mpls_route_update(net, index, NULL, NULL, &cfg->rc_nlinfo);
+	mpls_route_update(net, index, NULL, &cfg->rc_nlinfo);
 
 	err = 0;
 errout:
@@ -650,9 +803,14 @@ static void mpls_ifdown(struct net_device *dev)
 		struct mpls_route *rt = rtnl_dereference(platform_label[index]);
 		if (!rt)
 			continue;
-		if (rtnl_dereference(rt->rt_nh->nh_dev) != dev)
-			continue;
-		rt->rt_nh->nh_dev = NULL;
+		change_nexthops(rt) {
+			struct net_device *mdev;
+
+			mdev = rtnl_dereference(nhlfe->nh_dev);
+			if (mdev != dev)
+				continue;
+			nhlfe->nh_dev = NULL;
+		} endfor_nexthops(rt);
 	}
 
 	mdev = mpls_dev_get(dev);
@@ -796,6 +954,48 @@ int nla_get_labels(const struct nlattr *nla,
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
+	switch (via->rtvia_family) {
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
@@ -872,35 +1072,15 @@ static int rtm_to_route_config(struct sk_buff *skb,  struct nlmsghdr *nlh,
 		}
 		case RTA_VIA:
 		{
-			struct rtvia *via = nla_data(nla);
-			if (nla_len(nla) < offsetof(struct rtvia, rtvia_addr))
-				goto errout;
-			cfg->rc_via_alen   = nla_len(nla) -
-				offsetof(struct rtvia, rtvia_addr);
-			if (cfg->rc_via_alen > MAX_VIA_ALEN)
-				goto errout;
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
+			if (nla_get_via(nla, &cfg->rc_via_alen,
+					&cfg->rc_via_table, cfg->rc_via))
 				goto errout;
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
@@ -942,7 +1122,6 @@ static int mpls_rtm_newroute(struct sk_buff *skb, struct nlmsghdr *nlh)
 static int mpls_dump_route(struct sk_buff *skb, u32 portid, u32 seq, int event,
 			   u32 label, struct mpls_route *rt, int flags)
 {
-	struct mpls_nhlfe *nhlfe = rt->rt_nh;
 	struct net_device *dev;
 	struct nlmsghdr *nlh;
 	struct rtmsg *rtm;
@@ -962,18 +1141,53 @@ static int mpls_dump_route(struct sk_buff *skb, u32 portid, u32 seq, int event,
 	rtm->rtm_type = RTN_UNICAST;
 	rtm->rtm_flags = 0;
 
-	if (nhlfe->nh_labels &&
-	    nla_put_labels(skb, RTA_NEWDST, nhlfe->nh_labels,
-			   nhlfe->nh_label))
-		goto nla_put_failure;
-	if (nla_put_via(skb, nhlfe->nh_via_table, nhlfe->nh_via,
-			nhlfe->nh_via_alen))
-		goto nla_put_failure;
-	dev = rtnl_dereference(nhlfe->nh_dev);
-	if (dev && nla_put_u32(skb, RTA_OIF, dev->ifindex))
-		goto nla_put_failure;
 	if (nla_put_labels(skb, RTA_DST, 1, &label))
 		goto nla_put_failure;
+	if (rt->rt_nhn == 1) {
+		struct mpls_nhlfe *nhlfe = rt->rt_nh;
+
+		if (nhlfe->nh_labels &&
+		    nla_put_labels(skb, RTA_NEWDST, nhlfe->nh_labels,
+				   nhlfe->nh_label))
+			goto nla_put_failure;
+		if (nla_put_via(skb, nhlfe->nh_via_table, nhlfe->nh_via,
+				nhlfe->nh_via_alen))
+			goto nla_put_failure;
+		dev = rtnl_dereference(nhlfe->nh_dev);
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
+			rtnh->rtnh_flags = nhlfe->nh_flags & 0xFF;
+			dev = rtnl_dereference(nhlfe->nh_dev);
+			if (dev)
+				rtnh->rtnh_ifindex = dev->ifindex;
+			if (nhlfe->nh_labels &&
+			    nla_put_labels(skb, RTA_NEWDST, nhlfe->nh_labels,
+					   nhlfe->nh_label))
+				goto nla_put_failure;
+			if (nla_put_via(skb, nhlfe->nh_via_table,
+					nhlfe->nh_via,
+					nhlfe->nh_via_alen))
+				goto nla_put_failure;
+
+			/* length of rtnetlink header + attributes */
+			rtnh->rtnh_len = nlmsg_get_pos(skb) - (void *)rtnh;
+		} endfor_nexthops(rt);
+
+		nla_nest_end(skb, mp);
+	}
 
 	nlmsg_end(skb, nlh);
 	return 0;
@@ -1016,16 +1230,32 @@ static int mpls_dump_routes(struct sk_buff *skb, struct netlink_callback *cb)
 
 static inline size_t lfib_nlmsg_size(struct mpls_route *rt)
 {
-	struct mpls_nhlfe *nhlfe = rt->rt_nh;
 	size_t payload =
 		NLMSG_ALIGN(sizeof(struct rtmsg))
 		+ nla_total_size(4);			/* RTA_DST */
 
-	if (nhlfe->nh_dev)
-		payload += nla_total_size(4); /* RTA_OIF */
-	payload += nla_total_size(2 + nhlfe->nh_via_alen); /* RTA_VIA */
-	if (nhlfe->nh_labels) /* RTA_NEWDST */
-		payload += nla_total_size(nhlfe->nh_labels * 4);
+	if (rt->rt_nhn == 1) {
+		struct mpls_nhlfe *nhlfe = rt->rt_nh;
+
+		if (nhlfe->nh_dev)
+			payload += nla_total_size(4); /* RTA_OIF */
+		payload += nla_total_size(2 + nhlfe->nh_via_alen); /* RTA_VIA */
+		if (nhlfe->nh_labels) /* RTA_NEWDST */
+			payload += nla_total_size(nhlfe->nh_labels * 4);
+	} else {
+		/* each nexthop is packed in an attribute */
+		size_t nhsize = 0;
+
+		for_nexthops(rt) {
+			nhsize += nla_total_size(sizeof(struct rtnexthop)) +
+					nla_total_size(nhlfe->nh_via_alen +
+						       2); /* RTA_VIA */
+			if (nhlfe->nh_labels) /* RTA_NEWDST */
+				nhsize += nla_total_size(nhlfe->nh_labels * 4);
+		} endfor_nexthops(rt);
+		/* nested attribute */
+		payload += nla_total_size(nhsize);
+	}
 
 	return payload;
 }
@@ -1106,7 +1336,7 @@ static int resize_platform_label_table(struct net *net, size_t limit)
 
 	/* Free any labels beyond the new table */
 	for (index = limit; index < old_limit; index++)
-		mpls_route_update(net, index, NULL, NULL, NULL);
+		mpls_route_update(net, index, NULL, NULL);
 
 	/* Copy over the old labels */
 	cp_size = size;
diff --git a/net/mpls/internal.h b/net/mpls/internal.h
index f5dafcaf..62ae101 100644
--- a/net/mpls/internal.h
+++ b/net/mpls/internal.h
@@ -43,6 +43,8 @@ struct mpls_nhlfe { /* next hop label forwarding entry */
 	u32			nh_label[MAX_NEW_LABELS];
 	unsigned int		nh_flags;
 	u8			nh_payload_type;
+	int                     nh_weight;
+	int                     nh_power;
 	u8			nh_labels;
 	u8			nh_via_alen;
 	u8			nh_via_table;
@@ -52,10 +54,25 @@ struct mpls_nhlfe { /* next hop label forwarding entry */
 struct mpls_route { /* next hop label forwarding entry */
 	struct rcu_head		rt_rcu;
 	u8			rt_protocol;
+	int                     rt_power;
 	int			rt_nhn;
 	struct mpls_nhlfe	rt_nh[0];
 };
 
+#define for_nexthops(rt) {						\
+	int nhsel; const struct mpls_nhlfe *nhlfe;			\
+	for (nhsel = 0, nhlfe = (rt)->rt_nh;				\
+	     nhsel < (rt)->rt_nhn;					\
+	     nhlfe++, nhsel++)
+
+#define change_nexthops(rt) {						\
+	int nhsel; struct mpls_nhlfe *nhlfe;				\
+	for (nhsel = 0,	nhlfe = (struct mpls_nhlfe *)((rt)->rt_nh);	\
+	     nhsel < (rt)->rt_nhn;					\
+	     nhlfe++, nhsel++)
+
+#define endfor_nexthops(rt) }
+
 static inline struct mpls_shim_hdr *mpls_hdr(const struct sk_buff *skb)
 {
 	return (struct mpls_shim_hdr *)skb_network_header(skb);
@@ -89,6 +106,8 @@ int nla_put_labels(struct sk_buff *skb, int attrtype,  u8 labels,
 		   const u32 label[]);
 int nla_get_labels(const struct nlattr *nla, u32 max_labels, u8 *labels,
 		   u32 label[]);
+int nla_get_via(const struct nlattr *nla, u8 *via_alen, u8 *via_table,
+		u8 via[]);
 bool mpls_output_possible(const struct net_device *dev);
 unsigned int mpls_dev_mtu(const struct net_device *dev);
 bool mpls_pkt_too_big(const struct sk_buff *skb, unsigned int mtu);
-- 
1.7.10.4

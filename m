From: David Lamparter <equinox@diac24.net>
Subject: [PATCH 3/6] mpls: add VPLS entry points
Date: Wed, 16 Aug 2017 19:01:59 +0200
Message-ID: <20170816170202.456851-4-equinox@diac24.net>
References: <20170816170202.456851-1-equinox@diac24.net>
Cc: amine.kherbouche@6wind.com, roopa@cumulusnetworks.com,
        David Lamparter <equinox@diac24.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eidolon.nox.tf ([185.142.180.128]:43706 "EHLO eidolon.nox.tf"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752420AbdHPRCY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 16 Aug 2017 13:02:24 -0400
In-Reply-To: <20170816170202.456851-1-equinox@diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This wires up the neccessary calls for VPLS into the MPLS forwarding
pieces.  Since CONFIG_MPLS_VPLS doesn't exist yet in Kconfig, it'll
never be enabled, so we're on the stubs for now.

Signed-off-by: David Lamparter <equinox@diac24.net>
---
 include/uapi/linux/rtnetlink.h |  1 +
 net/mpls/af_mpls.c             | 54 ++++++++++++++++++++++++++++++++++++++++++
 net/mpls/internal.h            | 29 +++++++++++++++++++++++
 3 files changed, 84 insertions(+)

diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index dab7dad9e01a..b7840ed94526 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -326,6 +326,7 @@ enum rtattr_type_t {
 	RTA_PAD,
 	RTA_UID,
 	RTA_TTL_PROPAGATE,
+	RTA_VPLS_IF,
 	__RTA_MAX
 };
 
diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 0c5953e5d5bd..4d3ce007b7db 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -299,6 +299,11 @@ static bool mpls_egress(struct net *net, struct mpls_route *rt,
 		success = true;
 		break;
 	}
+	case MPT_VPLS:
+		/* nothing to do here, no TTL in Ethernet
+		 * (and we shouldn't mess with the TTL in inner IP packets,
+		 * pseudowires are supposed to be transparent) */
+		break;
 	case MPT_UNSPEC:
 		/* Should have decided which protocol it is by now */
 		break;
@@ -349,6 +354,8 @@ static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
 		goto drop;
 	}
 
+	if (rt->rt_payload_type == MPT_VPLS)
+		return vpls_rcv(skb, dev, pt, rt, hdr, orig_dev);
 
 	/* Pop the label */
 	skb_pull(skb, sizeof(*hdr));
@@ -469,6 +476,7 @@ static const struct nla_policy rtm_mpls_policy[RTA_MAX+1] = {
 struct mpls_route_config {
 	u32			rc_protocol;
 	u32			rc_ifindex;
+	u32			rc_vpls_ifindex;
 	u8			rc_via_table;
 	u8			rc_via_alen;
 	u8			rc_via[MAX_VIA_ALEN];
@@ -541,6 +549,8 @@ static void mpls_route_update(struct net *net, unsigned index,
 	rt = rtnl_dereference(platform_label[index]);
 	rcu_assign_pointer(platform_label[index], new);
 
+	vpls_label_update(index, rt, new);
+
 	mpls_notify_route(net, index, rt, new, info);
 
 	/* If we removed a route free it now */
@@ -942,6 +952,7 @@ static int mpls_route_add(struct mpls_route_config *cfg,
 	struct mpls_route __rcu **platform_label;
 	struct net *net = cfg->rc_nlinfo.nl_net;
 	struct mpls_route *rt, *old;
+	struct net_device *vpls_dev = NULL;
 	int err = -EINVAL;
 	u8 max_via_alen;
 	unsigned index;
@@ -996,6 +1007,24 @@ static int mpls_route_add(struct mpls_route_config *cfg,
 		goto errout;
 	}
 
+	if (cfg->rc_vpls_ifindex) {
+		vpls_dev = dev_get_by_index(net, cfg->rc_vpls_ifindex);
+		if (!vpls_dev) {
+			err = -ENODEV;
+			NL_SET_ERR_MSG(extack, "Invalid VPLS ifindex");
+			goto errout;
+		}
+		/* we're under RTNL; and we'll drop routes when we're
+		 * notified the device is going away. */
+		dev_put(vpls_dev);
+
+		if (!is_vpls_dev(vpls_dev)) {
+			err = -ENODEV;
+			NL_SET_ERR_MSG(extack, "Not a VPLS device");
+			goto errout;
+		}
+	}
+
 	err = -ENOMEM;
 	rt = mpls_rt_alloc(nhs, max_via_alen, max_labels);
 	if (IS_ERR(rt)) {
@@ -1006,6 +1035,7 @@ static int mpls_route_add(struct mpls_route_config *cfg,
 	rt->rt_protocol = cfg->rc_protocol;
 	rt->rt_payload_type = cfg->rc_payload_type;
 	rt->rt_ttl_propagate = cfg->rc_ttl_propagate;
+	rt->rt_vpls_dev = vpls_dev;
 
 	if (cfg->rc_mp)
 		err = mpls_nh_build_multi(cfg, rt, max_labels, extack);
@@ -1430,6 +1460,14 @@ static void mpls_ifdown(struct net_device *dev, int event)
 		if (!rt)
 			continue;
 
+		if (rt->rt_vpls_dev == dev) {
+			switch (event) {
+			case NETDEV_UNREGISTER:
+				mpls_route_update(net, index, NULL, NULL);
+				continue;
+			}
+		}
+
 		alive = 0;
 		deleted = 0;
 		change_nexthops(rt) {
@@ -1777,6 +1815,10 @@ static int rtm_to_route_config(struct sk_buff *skb,
 		case RTA_OIF:
 			cfg->rc_ifindex = nla_get_u32(nla);
 			break;
+		case RTA_VPLS_IF:
+			cfg->rc_vpls_ifindex = nla_get_u32(nla);
+			cfg->rc_payload_type = MPT_VPLS;
+			break;
 		case RTA_NEWDST:
 			if (nla_get_labels(nla, MAX_NEW_LABELS,
 					   &cfg->rc_output_labels,
@@ -1911,6 +1953,11 @@ static int mpls_dump_route(struct sk_buff *skb, u32 portid, u32 seq, int event,
 			       ttl_propagate))
 			goto nla_put_failure;
 	}
+
+	if (rt->rt_vpls_dev)
+		if (nla_put_u32(skb, RTA_VPLS_IF, rt->rt_vpls_dev->ifindex))
+			goto nla_put_failure;
+
 	if (rt->rt_nhn == 1) {
 		const struct mpls_nh *nh = rt->rt_nh;
 
@@ -2220,6 +2267,10 @@ static int mpls_getroute(struct sk_buff *in_skb, struct nlmsghdr *in_nlh,
 	if (nla_put_labels(skb, RTA_DST, 1, &in_label))
 		goto nla_put_failure;
 
+	if (rt->rt_vpls_dev)
+		if (nla_put_u32(skb, RTA_VPLS_IF, rt->rt_vpls_dev->ifindex))
+			goto nla_put_failure;
+
 	if (nh->nh_labels &&
 	    nla_put_labels(skb, RTA_NEWDST, nh->nh_labels,
 			   nh->nh_label))
@@ -2491,6 +2542,8 @@ static int __init mpls_init(void)
 
 	rtnl_af_register(&mpls_af_ops);
 
+	vpls_init();
+
 	rtnl_register(PF_MPLS, RTM_NEWROUTE, mpls_rtm_newroute, NULL, 0);
 	rtnl_register(PF_MPLS, RTM_DELROUTE, mpls_rtm_delroute, NULL, 0);
 	rtnl_register(PF_MPLS, RTM_GETROUTE, mpls_getroute, mpls_dump_routes,
@@ -2510,6 +2563,7 @@ module_init(mpls_init);
 static void __exit mpls_exit(void)
 {
 	rtnl_unregister_all(PF_MPLS);
+	vpls_exit();
 	rtnl_af_unregister(&mpls_af_ops);
 	dev_remove_pack(&mpls_packet_type);
 	unregister_netdevice_notifier(&mpls_dev_notifier);
diff --git a/net/mpls/internal.h b/net/mpls/internal.h
index b70c6663d4f3..876ae9993207 100644
--- a/net/mpls/internal.h
+++ b/net/mpls/internal.h
@@ -76,6 +76,7 @@ struct sk_buff;
 
 enum mpls_payload_type {
 	MPT_UNSPEC, /* IPv4 or IPv6 */
+	MPT_VPLS = 2,	/* pseudowire */
 	MPT_IPV4 = 4,
 	MPT_IPV6 = 6,
 
@@ -153,6 +154,8 @@ struct mpls_route { /* next hop label forwarding entry */
 	u8			rt_nh_size;
 	u8			rt_via_offset;
 	u8			rt_reserved1;
+	struct net_device	*rt_vpls_dev;
+
 	struct mpls_nh		rt_nh[0];
 };
 
@@ -214,4 +217,30 @@ struct mpls_route *mpls_route_input_rcu(struct net *net, unsigned index);
 int mpls_rt_xmit(struct sk_buff *skb, struct mpls_route *rt,
 		 struct mpls_entry_decoded dec);
 
+#ifdef CONFIG_MPLS_VPLS
+int vpls_rcv(struct sk_buff *skb, struct net_device *in_dev,
+	     struct packet_type *pt, struct mpls_route *rt,
+	     struct mpls_shim_hdr *hdr, struct net_device *orig_dev);
+void vpls_label_update(unsigned label, struct mpls_route *rt_old,
+		       struct mpls_route *rt_new);
+__init int vpls_init(void);
+__exit void vpls_exit(void);
+int is_vpls_dev(struct net_device *dev);
+
+#else /* !CONFIG_MPLS_VPLS */
+static inline int vpls_rcv(skb, in_dev, pt, rt, hdr, orig_dev)
+{
+	kfree_skb(skb);
+	return NET_RX_DROP;
+}
+static inline int is_vpls_dev(struct net_device *dev)
+{
+	return 0;
+}
+
+#define vpls_label_update(label, rt_old, rt_new) do { } while (0)
+#define vpls_init() do { } while (0)
+#define vpls_exit() do { } while (0)
+#endif
+
 #endif /* MPLS_INTERNAL_H */
-- 
2.13.0

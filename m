From: Amine Kherbouche <amine.kherbouche@6wind.com>
Subject: [PATCH 1/2] mpls: add handlers
Date: Thu, 10 Aug 2017 22:28:36 +0200
Message-ID: <1502396917-14848-2-git-send-email-amine.kherbouche@6wind.com>
References: <1502396917-14848-1-git-send-email-amine.kherbouche@6wind.com>
Cc: amine.kherbouche@6wind.com, roopa@cumulusnetworks.com,
        David Lamparter <equinox@diac24.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:35838 "EHLO
        mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752889AbdHJU3A (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 16:29:00 -0400
Received: by mail-wm0-f52.google.com with SMTP id m85so28246578wma.0
        for <netdev@vger.kernel.org>; Thu, 10 Aug 2017 13:28:59 -0700 (PDT)
In-Reply-To: <1502396917-14848-1-git-send-email-amine.kherbouche@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mpls handler allows creation/deletion of mpls routes without using
rtnetlink. When an incoming mpls packet matches this route, the saved
function handler is called.

Signed-off-by: Amine Kherbouche <amine.kherbouche@6wind.com>
Signed-off-by: David Lamparter <equinox@diac24.net>
---
 include/net/mpls.h  | 10 +++++++
 net/mpls/af_mpls.c  | 75 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 net/mpls/internal.h |  3 +++
 3 files changed, 88 insertions(+)

diff --git a/include/net/mpls.h b/include/net/mpls.h
index 1dbc669..0ff51b6 100644
--- a/include/net/mpls.h
+++ b/include/net/mpls.h
@@ -33,4 +33,14 @@ static inline struct mpls_shim_hdr *mpls_hdr(const struct sk_buff *skb)
 {
 	return (struct mpls_shim_hdr *)skb_network_header(skb);
 }
+
+typedef int (*mpls_handler)(void *arg, struct sk_buff *skb,
+			    struct net_device *dev, u32 index, u8 bos);
+
+extern int mpls_handler_add(struct net *net, u32 index, u8 via_table, u8 via[],
+			    mpls_handler handler, void *handler_arg,
+			    struct netlink_ext_ack *extack);
+extern int mpls_handler_del(struct net *net, u32 index,
+			    struct netlink_ext_ack *extack);
+
 #endif
diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index c5b9ce4..82d2126 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -10,6 +10,7 @@
 #include <linux/netconf.h>
 #include <linux/vmalloc.h>
 #include <linux/percpu.h>
+#include <net/mpls.h>
 #include <net/ip.h>
 #include <net/dst.h>
 #include <net/sock.h>
@@ -299,6 +300,7 @@ static bool mpls_egress(struct net *net, struct mpls_route *rt,
 		success = true;
 		break;
 	}
+	case MPT_HANDLER:
 	case MPT_UNSPEC:
 		/* Should have decided which protocol it is by now */
 		break;
@@ -356,6 +358,10 @@ static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
 		goto drop;
 	}
 
+	if (rt->rt_payload_type == MPT_HANDLER)
+		return rt->rt_handler(rt->rt_harg, skb, dev,
+				      dec.label, dec.bos);
+
 	nh = mpls_select_multipath(rt, skb);
 	if (!nh)
 		goto err;
@@ -457,6 +463,8 @@ static const struct nla_policy rtm_mpls_policy[RTA_MAX+1] = {
 struct mpls_route_config {
 	u32			rc_protocol;
 	u32			rc_ifindex;
+	mpls_handler		rc_handler;
+	void			*rc_harg;
 	u8			rc_via_table;
 	u8			rc_via_alen;
 	u8			rc_via[MAX_VIA_ALEN];
@@ -995,6 +1003,11 @@ static int mpls_route_add(struct mpls_route_config *cfg,
 	rt->rt_payload_type = cfg->rc_payload_type;
 	rt->rt_ttl_propagate = cfg->rc_ttl_propagate;
 
+	if (cfg->rc_handler) {
+		rt->rt_handler = cfg->rc_handler;
+		rt->rt_harg = cfg->rc_harg;
+	}
+
 	if (cfg->rc_mp)
 		err = mpls_nh_build_multi(cfg, rt, max_labels, extack);
 	else
@@ -1271,6 +1284,68 @@ static int mpls_netconf_dump_devconf(struct sk_buff *skb,
 	return skb->len;
 }
 
+int mpls_handler_add(struct net *net, u32 label, u8 via_table, u8 via[],
+		     mpls_handler handler, void *handler_arg,
+		     struct netlink_ext_ack *extack)
+{
+	struct net_device *dev = handler_arg;
+	struct mpls_route_config *cfg;
+	u8 alen = 0;
+	int err;
+
+	cfg = kzalloc(sizeof(*cfg), GFP_KERNEL);
+	if (!cfg)
+		return -ENOMEM;
+
+	memset(cfg, 0, sizeof(*cfg));
+	if (via_table == NEIGH_ARP_TABLE)
+		alen = sizeof(struct in_addr);
+	else if (via_table == NEIGH_ND_TABLE)
+		alen = sizeof(struct in6_addr);
+
+	cfg->rc_ttl_propagate	= MPLS_TTL_PROP_DEFAULT;
+	cfg->rc_protocol	= RTPROT_KERNEL;
+	cfg->rc_nlflags		|= NLM_F_CREATE;
+	cfg->rc_payload_type	= MPT_HANDLER;
+	cfg->rc_via_table	= via_table;
+	cfg->rc_label		= label;
+	cfg->rc_via_alen	= alen;
+	memcpy(&cfg->rc_via, via, alen);
+	cfg->rc_ifindex		= dev->ifindex;
+	cfg->rc_nlinfo.nl_net	= net;
+	cfg->rc_harg		= handler_arg;
+	cfg->rc_handler		= handler;
+	cfg->rc_output_labels	= 0;
+
+	err = mpls_route_add(cfg, extack);
+	kfree(cfg);
+
+	return err;
+}
+EXPORT_SYMBOL(mpls_handler_add);
+
+int mpls_handler_del(struct net *net, u32 index,
+		     struct netlink_ext_ack *extack)
+{
+	struct mpls_route_config *cfg;
+	int err = 0;
+
+	cfg = kzalloc(sizeof(*cfg), GFP_KERNEL);
+	if (!cfg)
+		return -ENOMEM;
+
+	memset(cfg, 0, sizeof(*cfg));
+	cfg->rc_protocol	= RTPROT_KERNEL;
+	cfg->rc_label		= index;
+	cfg->rc_nlinfo.nl_net	= net;
+
+	err = mpls_route_del(cfg, extack);
+	kfree(cfg);
+
+	return err;
+}
+EXPORT_SYMBOL(mpls_handler_del);
+
 #define MPLS_PERDEV_SYSCTL_OFFSET(field)	\
 	(&((struct mpls_dev *)0)->field)
 
diff --git a/net/mpls/internal.h b/net/mpls/internal.h
index cf65aec..2cd73eb 100644
--- a/net/mpls/internal.h
+++ b/net/mpls/internal.h
@@ -78,6 +78,7 @@ enum mpls_payload_type {
 	MPT_UNSPEC, /* IPv4 or IPv6 */
 	MPT_IPV4 = 4,
 	MPT_IPV6 = 6,
+	MPT_HANDLER = 255,
 
 	/* Other types not implemented:
 	 *  - Pseudo-wire with or without control word (RFC4385)
@@ -141,6 +142,8 @@ enum mpls_ttl_propagation {
  */
 struct mpls_route { /* next hop label forwarding entry */
 	struct rcu_head		rt_rcu;
+	mpls_handler		rt_handler;
+	void			*rt_harg;
 	u8			rt_protocol;
 	u8			rt_payload_type;
 	u8			rt_max_alen;
-- 
2.1.4

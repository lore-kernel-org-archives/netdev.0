From: Robert Shearman <rshearma@brocade.com>
Subject: [PATCH net-next v3 1/2] mpls: allow TTL propagation to IP packets to be configured
Date: Fri, 10 Mar 2017 20:43:24 +0000
Message-ID: <1489178605-30027-2-git-send-email-rshearma@brocade.com>
References: <1488933990-14490-1-git-send-email-rshearma@brocade.com>
 <1489178605-30027-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        roopa <roopa@cumulusnetworks.com>,
        David Ahern <dsa@cumulusnetworks.com>,
        Robert Shearman <rshearma@brocade.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:41882 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S933456AbdCJUoC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 15:44:02 -0500
In-Reply-To: <1489178605-30027-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Provide the ability to control on a per-route basis whether the TTL
value from an MPLS packet is propagated to an IPv4/IPv6 packet when
the last label is popped as per the theoretical model in RFC 3443
through a new route attribute, RTA_TTL_PROPAGATE which can be 0 to
mean disable propagation and 1 to mean enable propagation.

In order to provide the ability to change the behaviour for packets
arriving with IPv4/IPv6 Explicit Null labels and to provide an easy
way for a user to change the behaviour for all existing routes without
having to reprogram them, a global knob is provided. This is done
through the addition of a new per-namespace sysctl,
"net.mpls.ip_ttl_propagate", which defaults to enabled. If the
per-route attribute is set (either enabled or disabled) then it
overrides the global configuration.

Signed-off-by: Robert Shearman <rshearma@brocade.com>
---
 Documentation/networking/mpls-sysctl.txt | 11 ++++
 include/net/netns/mpls.h                 |  2 +
 include/uapi/linux/rtnetlink.h           |  1 +
 net/mpls/af_mpls.c                       | 87 +++++++++++++++++++++++++++++---
 net/mpls/internal.h                      |  7 +++
 5 files changed, 100 insertions(+), 8 deletions(-)

diff --git a/Documentation/networking/mpls-sysctl.txt b/Documentation/networking/mpls-sysctl.txt
index 15d8d16934fd..9badd1d6685f 100644
--- a/Documentation/networking/mpls-sysctl.txt
+++ b/Documentation/networking/mpls-sysctl.txt
@@ -19,6 +19,17 @@ platform_labels - INTEGER
 	Possible values: 0 - 1048575
 	Default: 0
 
+ip_ttl_propagate - BOOL
+	Control whether TTL is propagated from the IPv4/IPv6 header to
+	the MPLS header on imposing labels and propagated from the
+	MPLS header to the IPv4/IPv6 header on popping the last label.
+
+	If disabled, the MPLS transport network will appear as a
+	single hop to transit traffic.
+
+	0 - disabled / RFC 3443 [Short] Pipe Model
+	1 - enabled / RFC 3443 Uniform Model (default)
+
 conf/<interface>/input - BOOL
 	Control whether packets can be input on this interface.
 
diff --git a/include/net/netns/mpls.h b/include/net/netns/mpls.h
index d29203651c01..08652eedabb2 100644
--- a/include/net/netns/mpls.h
+++ b/include/net/netns/mpls.h
@@ -9,8 +9,10 @@ struct mpls_route;
 struct ctl_table_header;
 
 struct netns_mpls {
+	int ip_ttl_propagate;
 	size_t platform_labels;
 	struct mpls_route __rcu * __rcu *platform_label;
+
 	struct ctl_table_header *ctl;
 };
 
diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index 6546917d605a..30fb25e851db 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -319,6 +319,7 @@ enum rtattr_type_t {
 	RTA_EXPIRES,
 	RTA_PAD,
 	RTA_UID,
+	RTA_TTL_PROPAGATE,
 	__RTA_MAX
 };
 
diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 3818686182b2..0e1046f21af8 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -32,6 +32,7 @@
 #define MPLS_NEIGH_TABLE_UNSPEC (NEIGH_LINK_TABLE + 1)
 
 static int zero = 0;
+static int one = 1;
 static int label_limit = (1 << 20) - 1;
 
 static void rtmsg_lfib(int event, u32 label, struct mpls_route *rt,
@@ -220,8 +221,8 @@ static struct mpls_nh *mpls_select_multipath(struct mpls_route *rt,
 	return &rt->rt_nh[nh_index];
 }
 
-static bool mpls_egress(struct mpls_route *rt, struct sk_buff *skb,
-			struct mpls_entry_decoded dec)
+static bool mpls_egress(struct net *net, struct mpls_route *rt,
+			struct sk_buff *skb, struct mpls_entry_decoded dec)
 {
 	enum mpls_payload_type payload_type;
 	bool success = false;
@@ -246,22 +247,46 @@ static bool mpls_egress(struct mpls_route *rt, struct sk_buff *skb,
 	switch (payload_type) {
 	case MPT_IPV4: {
 		struct iphdr *hdr4 = ip_hdr(skb);
+		u8 new_ttl;
 		skb->protocol = htons(ETH_P_IP);
+
+		/* If propagating TTL, take the decremented TTL from
+		 * the incoming MPLS header, otherwise decrement the
+		 * TTL, but only if not 0 to avoid underflow.
+		 */
+		if (rt->rt_ttl_propagate == MPLS_TTL_PROP_ENABLED ||
+		    (rt->rt_ttl_propagate == MPLS_TTL_PROP_DEFAULT &&
+		     net->mpls.ip_ttl_propagate))
+			new_ttl = dec.ttl;
+		else
+			new_ttl = hdr4->ttl ? hdr4->ttl - 1 : 0;
+
 		csum_replace2(&hdr4->check,
 			      htons(hdr4->ttl << 8),
-			      htons(dec.ttl << 8));
-		hdr4->ttl = dec.ttl;
+			      htons(new_ttl << 8));
+		hdr4->ttl = new_ttl;
 		success = true;
 		break;
 	}
 	case MPT_IPV6: {
 		struct ipv6hdr *hdr6 = ipv6_hdr(skb);
 		skb->protocol = htons(ETH_P_IPV6);
-		hdr6->hop_limit = dec.ttl;
+
+		/* If propagating TTL, take the decremented TTL from
+		 * the incoming MPLS header, otherwise decrement the
+		 * hop limit, but only if not 0 to avoid underflow.
+		 */
+		if (rt->rt_ttl_propagate == MPLS_TTL_PROP_ENABLED ||
+		    (rt->rt_ttl_propagate == MPLS_TTL_PROP_DEFAULT &&
+		     net->mpls.ip_ttl_propagate))
+			hdr6->hop_limit = dec.ttl;
+		else if (hdr6->hop_limit)
+			hdr6->hop_limit = hdr6->hop_limit - 1;
 		success = true;
 		break;
 	}
 	case MPT_UNSPEC:
+		/* Should have decided which protocol it is by now */
 		break;
 	}
 
@@ -361,7 +386,7 @@ static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
 
 	if (unlikely(!new_header_size && dec.bos)) {
 		/* Penultimate hop popping */
-		if (!mpls_egress(rt, skb, dec))
+		if (!mpls_egress(dev_net(out_dev), rt, skb, dec))
 			goto err;
 	} else {
 		bool bos;
@@ -412,6 +437,7 @@ static struct packet_type mpls_packet_type __read_mostly = {
 static const struct nla_policy rtm_mpls_policy[RTA_MAX+1] = {
 	[RTA_DST]		= { .type = NLA_U32 },
 	[RTA_OIF]		= { .type = NLA_U32 },
+	[RTA_TTL_PROPAGATE]	= { .type = NLA_U8 },
 };
 
 struct mpls_route_config {
@@ -421,6 +447,7 @@ struct mpls_route_config {
 	u8			rc_via_alen;
 	u8			rc_via[MAX_VIA_ALEN];
 	u32			rc_label;
+	u8			rc_ttl_propagate;
 	u8			rc_output_labels;
 	u32			rc_output_label[MAX_NEW_LABELS];
 	u32			rc_nlflags;
@@ -856,6 +883,7 @@ static int mpls_route_add(struct mpls_route_config *cfg)
 
 	rt->rt_protocol = cfg->rc_protocol;
 	rt->rt_payload_type = cfg->rc_payload_type;
+	rt->rt_ttl_propagate = cfg->rc_ttl_propagate;
 
 	if (cfg->rc_mp)
 		err = mpls_nh_build_multi(cfg, rt);
@@ -1576,6 +1604,7 @@ static int rtm_to_route_config(struct sk_buff *skb,  struct nlmsghdr *nlh,
 	cfg->rc_label		= LABEL_NOT_SPECIFIED;
 	cfg->rc_protocol	= rtm->rtm_protocol;
 	cfg->rc_via_table	= MPLS_NEIGH_TABLE_UNSPEC;
+	cfg->rc_ttl_propagate	= MPLS_TTL_PROP_DEFAULT;
 	cfg->rc_nlflags		= nlh->nlmsg_flags;
 	cfg->rc_nlinfo.portid	= NETLINK_CB(skb).portid;
 	cfg->rc_nlinfo.nlh	= nlh;
@@ -1622,6 +1651,17 @@ static int rtm_to_route_config(struct sk_buff *skb,  struct nlmsghdr *nlh,
 			cfg->rc_mp_len = nla_len(nla);
 			break;
 		}
+		case RTA_TTL_PROPAGATE:
+		{
+			u8 ttl_propagate = nla_get_u8(nla);
+
+			if (ttl_propagate > 1)
+				goto errout;
+			cfg->rc_ttl_propagate = ttl_propagate ?
+				MPLS_TTL_PROP_ENABLED :
+				MPLS_TTL_PROP_DISABLED;
+			break;
+		}
 		default:
 			/* Unsupported attribute */
 			goto errout;
@@ -1682,6 +1722,15 @@ static int mpls_dump_route(struct sk_buff *skb, u32 portid, u32 seq, int event,
 
 	if (nla_put_labels(skb, RTA_DST, 1, &label))
 		goto nla_put_failure;
+
+	if (rt->rt_ttl_propagate != MPLS_TTL_PROP_DEFAULT) {
+		bool ttl_propagate =
+			rt->rt_ttl_propagate == MPLS_TTL_PROP_ENABLED;
+
+		if (nla_put_u8(skb, RTA_TTL_PROPAGATE,
+			       ttl_propagate))
+			goto nla_put_failure;
+	}
 	if (rt->rt_nhn == 1) {
 		const struct mpls_nh *nh = rt->rt_nh;
 
@@ -1792,7 +1841,8 @@ static inline size_t lfib_nlmsg_size(struct mpls_route *rt)
 {
 	size_t payload =
 		NLMSG_ALIGN(sizeof(struct rtmsg))
-		+ nla_total_size(4);			/* RTA_DST */
+		+ nla_total_size(4)			/* RTA_DST */
+		+ nla_total_size(1);			/* RTA_TTL_PROPAGATE */
 
 	if (rt->rt_nhn == 1) {
 		struct mpls_nh *nh = rt->rt_nh;
@@ -1876,6 +1926,7 @@ static int resize_platform_label_table(struct net *net, size_t limit)
 		RCU_INIT_POINTER(rt0->rt_nh->nh_dev, lo);
 		rt0->rt_protocol = RTPROT_KERNEL;
 		rt0->rt_payload_type = MPT_IPV4;
+		rt0->rt_ttl_propagate = MPLS_TTL_PROP_DEFAULT;
 		rt0->rt_nh->nh_via_table = NEIGH_LINK_TABLE;
 		rt0->rt_nh->nh_via_alen = lo->addr_len;
 		memcpy(__mpls_nh_via(rt0, rt0->rt_nh), lo->dev_addr,
@@ -1889,6 +1940,7 @@ static int resize_platform_label_table(struct net *net, size_t limit)
 		RCU_INIT_POINTER(rt2->rt_nh->nh_dev, lo);
 		rt2->rt_protocol = RTPROT_KERNEL;
 		rt2->rt_payload_type = MPT_IPV6;
+		rt0->rt_ttl_propagate = MPLS_TTL_PROP_DEFAULT;
 		rt2->rt_nh->nh_via_table = NEIGH_LINK_TABLE;
 		rt2->rt_nh->nh_via_alen = lo->addr_len;
 		memcpy(__mpls_nh_via(rt2, rt2->rt_nh), lo->dev_addr,
@@ -1970,6 +2022,9 @@ static int mpls_platform_labels(struct ctl_table *table, int write,
 	return ret;
 }
 
+#define MPLS_NS_SYSCTL_OFFSET(field)		\
+	(&((struct net *)0)->field)
+
 static const struct ctl_table mpls_table[] = {
 	{
 		.procname	= "platform_labels",
@@ -1978,21 +2033,37 @@ static const struct ctl_table mpls_table[] = {
 		.mode		= 0644,
 		.proc_handler	= mpls_platform_labels,
 	},
+	{
+		.procname	= "ip_ttl_propagate",
+		.data		= MPLS_NS_SYSCTL_OFFSET(mpls.ip_ttl_propagate),
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
+		.extra2		= &one,
+	},
 	{ }
 };
 
 static int mpls_net_init(struct net *net)
 {
 	struct ctl_table *table;
+	int i;
 
 	net->mpls.platform_labels = 0;
 	net->mpls.platform_label = NULL;
+	net->mpls.ip_ttl_propagate = 1;
 
 	table = kmemdup(mpls_table, sizeof(mpls_table), GFP_KERNEL);
 	if (table == NULL)
 		return -ENOMEM;
 
-	table[0].data = net;
+	/* Table data contains only offsets relative to the base of
+	 * the mdev at this point, so make them absolute.
+	 */
+	for (i = 0; i < ARRAY_SIZE(mpls_table) - 1; i++)
+		table[i].data = (char *)net + (uintptr_t)table[i].data;
+
 	net->mpls.ctl = register_net_sysctl(net, "net/mpls", table);
 	if (net->mpls.ctl == NULL) {
 		kfree(table);
diff --git a/net/mpls/internal.h b/net/mpls/internal.h
index 76360d8b9579..62928d8fabd1 100644
--- a/net/mpls/internal.h
+++ b/net/mpls/internal.h
@@ -90,6 +90,12 @@ struct mpls_nh { /* next hop label forwarding entry */
 	u8			nh_via_table;
 };
 
+enum mpls_ttl_propagation {
+	MPLS_TTL_PROP_DEFAULT,
+	MPLS_TTL_PROP_ENABLED,
+	MPLS_TTL_PROP_DISABLED,
+};
+
 /* The route, nexthops and vias are stored together in the same memory
  * block:
  *
@@ -116,6 +122,7 @@ struct mpls_route { /* next hop label forwarding entry */
 	u8			rt_protocol;
 	u8			rt_payload_type;
 	u8			rt_max_alen;
+	u8			rt_ttl_propagate;
 	unsigned int		rt_nhn;
 	unsigned int		rt_nhn_alive;
 	struct mpls_nh		rt_nh[0];
-- 
2.1.4

From: Robert Shearman <rshearma@brocade.com>
Subject: [PATCH net-next] mpls: allow TTL propagation to/from IP packets to be configured
Date: Mon, 30 Jan 2017 20:36:15 +0000
Message-ID: <1485808575-16852-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, roopa <roopa@cumulusnetworks.com>,
        <ebiederm@xmission.com>, Robert Shearman <rshearma@brocade.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:40473 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752675AbdA3UhQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 15:37:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is sometimes desirable to present an MPLS transport network as a
single hop to traffic transiting it because it prevents confusion when
diagnosing failures. An example of where confusion can be generated is
when addresses used in the provider network overlap with addresses in
the overlay network and the addresses get exposed through ICMP errors
generated as packets transit the provider network.

Therefore, provide the ability to control whether the TTL value from
an MPLS packet is propagated to an IPv4/IPv6 packet when the last
label is popped through the addition of a new per-namespace sysctl:
"net.mpls.ip_ttl_propagate" which defaults to enabled.

Use the same sysctl to control whether the TTL is propagated from IP
packets into the MPLS header. If the TTL isn't propagated then a
default TTL value is used which can be configured via a new sysctl:
"net.mpls.default_ttl".

Signed-off-by: Robert Shearman <rshearma@brocade.com>
---
 Documentation/networking/mpls-sysctl.txt | 19 +++++++++
 include/net/netns/mpls.h                 |  3 ++
 net/mpls/af_mpls.c                       | 70 ++++++++++++++++++++++++--------
 net/mpls/mpls_iptunnel.c                 | 12 +++++-
 4 files changed, 85 insertions(+), 19 deletions(-)

diff --git a/Documentation/networking/mpls-sysctl.txt b/Documentation/networking/mpls-sysctl.txt
index 15d8d16934fd..b8f0725ff09e 100644
--- a/Documentation/networking/mpls-sysctl.txt
+++ b/Documentation/networking/mpls-sysctl.txt
@@ -19,6 +19,25 @@ platform_labels - INTEGER
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
+	0 - disabled
+	1 - enabled (default)
+
+default_ttl - BOOL
+	Default TTL value to use for MPLS packets where it cannot be
+	propagated from an IP header, either because one isn't present
+	or ip_ttl_propagate has been disabled.
+
+	Possible values: 1 - 255
+	Default: 255
+
 conf/<interface>/input - BOOL
 	Control whether packets can be input on this interface.
 
diff --git a/include/net/netns/mpls.h b/include/net/netns/mpls.h
index d29203651c01..1b68aed6e1b9 100644
--- a/include/net/netns/mpls.h
+++ b/include/net/netns/mpls.h
@@ -10,7 +10,10 @@ struct ctl_table_header;
 
 struct netns_mpls {
 	size_t platform_labels;
+	int ip_ttl_propagate;
+	int default_ttl;
 	struct mpls_route __rcu * __rcu *platform_label;
+
 	struct ctl_table_header *ctl;
 };
 
diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 64d3bf269a26..bf5f0792e8a2 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -31,7 +31,9 @@
 #define MPLS_NEIGH_TABLE_UNSPEC (NEIGH_LINK_TABLE + 1)
 
 static int zero = 0;
+static int one = 1;
 static int label_limit = (1 << 20) - 1;
+static int ttl_max = 255;
 
 static void rtmsg_lfib(int event, u32 label, struct mpls_route *rt,
 		       struct nlmsghdr *nlh, struct net *net, u32 portid,
@@ -219,8 +221,8 @@ static struct mpls_nh *mpls_select_multipath(struct mpls_route *rt,
 	return &rt->rt_nh[nh_index];
 }
 
-static bool mpls_egress(struct mpls_route *rt, struct sk_buff *skb,
-			struct mpls_entry_decoded dec)
+static bool mpls_egress(struct net *net, struct mpls_route *rt,
+			struct sk_buff *skb, struct mpls_entry_decoded dec)
 {
 	enum mpls_payload_type payload_type;
 	bool success = false;
@@ -243,24 +245,29 @@ static bool mpls_egress(struct mpls_route *rt, struct sk_buff *skb,
 		payload_type = ip_hdr(skb)->version;
 
 	switch (payload_type) {
-	case MPT_IPV4: {
-		struct iphdr *hdr4 = ip_hdr(skb);
-		skb->protocol = htons(ETH_P_IP);
-		csum_replace2(&hdr4->check,
-			      htons(hdr4->ttl << 8),
-			      htons(dec.ttl << 8));
-		hdr4->ttl = dec.ttl;
+	case MPT_IPV4:
+		if (net->mpls.ip_ttl_propagate) {
+			struct iphdr *hdr4 = ip_hdr(skb);
+
+			skb->protocol = htons(ETH_P_IP);
+			csum_replace2(&hdr4->check,
+				      htons(hdr4->ttl << 8),
+				      htons(dec.ttl << 8));
+			hdr4->ttl = dec.ttl;
+		}
 		success = true;
 		break;
-	}
-	case MPT_IPV6: {
-		struct ipv6hdr *hdr6 = ipv6_hdr(skb);
-		skb->protocol = htons(ETH_P_IPV6);
-		hdr6->hop_limit = dec.ttl;
+	case MPT_IPV6:
+		if (net->mpls.ip_ttl_propagate) {
+			struct ipv6hdr *hdr6 = ipv6_hdr(skb);
+
+			skb->protocol = htons(ETH_P_IPV6);
+			hdr6->hop_limit = dec.ttl;
+		}
 		success = true;
 		break;
-	}
 	case MPT_UNSPEC:
+		/* Should have decided which protocol it is by now */
 		break;
 	}
 
@@ -360,7 +367,7 @@ static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
 
 	if (unlikely(!new_header_size && dec.bos)) {
 		/* Penultimate hop popping */
-		if (!mpls_egress(rt, skb, dec))
+		if (!mpls_egress(dev_net(out_dev), rt, skb, dec))
 			goto err;
 	} else {
 		bool bos;
@@ -1764,6 +1771,9 @@ static int mpls_platform_labels(struct ctl_table *table, int write,
 	return ret;
 }
 
+#define MPLS_NS_SYSCTL_OFFSET(field)		\
+	(&((struct net *)0)->field)
+
 static const struct ctl_table mpls_table[] = {
 	{
 		.procname	= "platform_labels",
@@ -1772,21 +1782,47 @@ static const struct ctl_table mpls_table[] = {
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
+	{
+		.procname	= "default_ttl",
+		.data		= MPLS_NS_SYSCTL_OFFSET(mpls.default_ttl),
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &one,
+		.extra2		= &ttl_max,
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
+	net->mpls.default_ttl = 255;
 
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
diff --git a/net/mpls/mpls_iptunnel.c b/net/mpls/mpls_iptunnel.c
index 67b7a955de65..c6a8e1c7c5f5 100644
--- a/net/mpls/mpls_iptunnel.c
+++ b/net/mpls/mpls_iptunnel.c
@@ -49,6 +49,7 @@ static int mpls_xmit(struct sk_buff *skb)
 	struct rtable *rt = NULL;
 	struct rt6_info *rt6 = NULL;
 	struct mpls_dev *out_mdev;
+	struct net *net;
 	int err = 0;
 	bool bos;
 	int i;
@@ -56,13 +57,20 @@ static int mpls_xmit(struct sk_buff *skb)
 
 	/* Find the output device */
 	out_dev = dst->dev;
+	net = dev_net(out_dev);
 
 	/* Obtain the ttl */
 	if (dst->ops->family == AF_INET) {
-		ttl = ip_hdr(skb)->ttl;
+		if (net->mpls.ip_ttl_propagate)
+			ttl = ip_hdr(skb)->ttl;
+		else
+			ttl = net->mpls.default_ttl;
 		rt = (struct rtable *)dst;
 	} else if (dst->ops->family == AF_INET6) {
-		ttl = ipv6_hdr(skb)->hop_limit;
+		if (net->mpls.ip_ttl_propagate)
+			ttl = ipv6_hdr(skb)->hop_limit;
+		else
+			ttl = net->mpls.default_ttl;
 		rt6 = (struct rt6_info *)dst;
 	} else {
 		goto drop;
-- 
2.1.4

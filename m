From: Robert Shearman <rshearma@brocade.com>
Subject: [PATCH net-next v3 2/2] mpls: allow TTL propagation from IP packets to be configured
Date: Fri, 10 Mar 2017 20:43:25 +0000
Message-ID: <1489178605-30027-3-git-send-email-rshearma@brocade.com>
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
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:41881 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932372AbdCJUoC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 15:44:02 -0500
In-Reply-To: <1489178605-30027-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow TTL propagation from IP packets to MPLS packets to be
configured. Add a new optional LWT attribute, MPLS_IPTUNNEL_TTL, which
allows the TTL to be set in the resulting MPLS packet, with the value
of 0 having the semantics of enabling propagation of the TTL from the
IP header (i.e. non-zero values disable propagation).

Also allow the configuration to be overridden globally by reusing the
same sysctl to control whether the TTL is propagated from IP packets
into the MPLS header. If the per-LWT attribute is set then it
overrides the global configuration. If the TTL isn't propagated then a
default TTL value is used which can be configured via a new sysctl,
"net.mpls.default_ttl". This is kept separate from the configuration
of whether IP TTL propagation is enabled as it can be used in the
future when non-IP payloads are supported (i.e. where there is no
payload TTL that can be propagated).

Signed-off-by: Robert Shearman <rshearma@brocade.com>
---
 Documentation/networking/mpls-sysctl.txt |  8 ++++
 include/net/mpls_iptunnel.h              |  2 +
 include/net/netns/mpls.h                 |  1 +
 include/uapi/linux/mpls_iptunnel.h       |  2 +
 net/mpls/af_mpls.c                       | 11 +++++
 net/mpls/mpls_iptunnel.c                 | 73 ++++++++++++++++++++++++++------
 6 files changed, 84 insertions(+), 13 deletions(-)

diff --git a/Documentation/networking/mpls-sysctl.txt b/Documentation/networking/mpls-sysctl.txt
index 9badd1d6685f..2f24a1912a48 100644
--- a/Documentation/networking/mpls-sysctl.txt
+++ b/Documentation/networking/mpls-sysctl.txt
@@ -30,6 +30,14 @@ ip_ttl_propagate - BOOL
 	0 - disabled / RFC 3443 [Short] Pipe Model
 	1 - enabled / RFC 3443 Uniform Model (default)
 
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
 
diff --git a/include/net/mpls_iptunnel.h b/include/net/mpls_iptunnel.h
index 179253f9dcfd..a18af6a16eb5 100644
--- a/include/net/mpls_iptunnel.h
+++ b/include/net/mpls_iptunnel.h
@@ -19,6 +19,8 @@
 struct mpls_iptunnel_encap {
 	u32	label[MAX_NEW_LABELS];
 	u8	labels;
+	u8	ttl_propagate;
+	u8	default_ttl;
 };
 
 static inline struct mpls_iptunnel_encap *mpls_lwtunnel_encap(struct lwtunnel_state *lwtstate)
diff --git a/include/net/netns/mpls.h b/include/net/netns/mpls.h
index 08652eedabb2..6608b3693385 100644
--- a/include/net/netns/mpls.h
+++ b/include/net/netns/mpls.h
@@ -10,6 +10,7 @@ struct ctl_table_header;
 
 struct netns_mpls {
 	int ip_ttl_propagate;
+	int default_ttl;
 	size_t platform_labels;
 	struct mpls_route __rcu * __rcu *platform_label;
 
diff --git a/include/uapi/linux/mpls_iptunnel.h b/include/uapi/linux/mpls_iptunnel.h
index d80a0498f77e..f5e45095b0bb 100644
--- a/include/uapi/linux/mpls_iptunnel.h
+++ b/include/uapi/linux/mpls_iptunnel.h
@@ -16,11 +16,13 @@
 /* MPLS tunnel attributes
  * [RTA_ENCAP] = {
  *     [MPLS_IPTUNNEL_DST]
+ *     [MPLS_IPTUNNEL_TTL]
  * }
  */
 enum {
 	MPLS_IPTUNNEL_UNSPEC,
 	MPLS_IPTUNNEL_DST,
+	MPLS_IPTUNNEL_TTL,
 	__MPLS_IPTUNNEL_MAX,
 };
 #define MPLS_IPTUNNEL_MAX (__MPLS_IPTUNNEL_MAX - 1)
diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 0e1046f21af8..0c5d111abe36 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -34,6 +34,7 @@
 static int zero = 0;
 static int one = 1;
 static int label_limit = (1 << 20) - 1;
+static int ttl_max = 255;
 
 static void rtmsg_lfib(int event, u32 label, struct mpls_route *rt,
 		       struct nlmsghdr *nlh, struct net *net, u32 portid,
@@ -2042,6 +2043,15 @@ static const struct ctl_table mpls_table[] = {
 		.extra1		= &zero,
 		.extra2		= &one,
 	},
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
 
@@ -2053,6 +2063,7 @@ static int mpls_net_init(struct net *net)
 	net->mpls.platform_labels = 0;
 	net->mpls.platform_label = NULL;
 	net->mpls.ip_ttl_propagate = 1;
+	net->mpls.default_ttl = 255;
 
 	table = kmemdup(mpls_table, sizeof(mpls_table), GFP_KERNEL);
 	if (table == NULL)
diff --git a/net/mpls/mpls_iptunnel.c b/net/mpls/mpls_iptunnel.c
index e4e4424f9eb1..22f71fce0bfb 100644
--- a/net/mpls/mpls_iptunnel.c
+++ b/net/mpls/mpls_iptunnel.c
@@ -29,6 +29,7 @@
 
 static const struct nla_policy mpls_iptunnel_policy[MPLS_IPTUNNEL_MAX + 1] = {
 	[MPLS_IPTUNNEL_DST]	= { .type = NLA_U32 },
+	[MPLS_IPTUNNEL_TTL]	= { .type = NLA_U8 },
 };
 
 static unsigned int mpls_encap_size(struct mpls_iptunnel_encap *en)
@@ -49,6 +50,7 @@ static int mpls_xmit(struct sk_buff *skb)
 	struct rtable *rt = NULL;
 	struct rt6_info *rt6 = NULL;
 	struct mpls_dev *out_mdev;
+	struct net *net;
 	int err = 0;
 	bool bos;
 	int i;
@@ -56,17 +58,7 @@ static int mpls_xmit(struct sk_buff *skb)
 
 	/* Find the output device */
 	out_dev = dst->dev;
-
-	/* Obtain the ttl */
-	if (dst->ops->family == AF_INET) {
-		ttl = ip_hdr(skb)->ttl;
-		rt = (struct rtable *)dst;
-	} else if (dst->ops->family == AF_INET6) {
-		ttl = ipv6_hdr(skb)->hop_limit;
-		rt6 = (struct rt6_info *)dst;
-	} else {
-		goto drop;
-	}
+	net = dev_net(out_dev);
 
 	skb_orphan(skb);
 
@@ -78,6 +70,38 @@ static int mpls_xmit(struct sk_buff *skb)
 
 	tun_encap_info = mpls_lwtunnel_encap(dst->lwtstate);
 
+	/* Obtain the ttl using the following set of rules.
+	 *
+	 * LWT ttl propagation setting:
+	 *  - disabled => use default TTL value from LWT
+	 *  - enabled  => use TTL value from IPv4/IPv6 header
+	 *  - default  =>
+	 *   Global ttl propagation setting:
+	 *    - disabled => use default TTL value from global setting
+	 *    - enabled => use TTL value from IPv4/IPv6 header
+	 */
+	if (dst->ops->family == AF_INET) {
+		if (tun_encap_info->ttl_propagate == MPLS_TTL_PROP_DISABLED)
+			ttl = tun_encap_info->default_ttl;
+		else if (tun_encap_info->ttl_propagate == MPLS_TTL_PROP_DEFAULT &&
+			 !net->mpls.ip_ttl_propagate)
+			ttl = net->mpls.default_ttl;
+		else
+			ttl = ip_hdr(skb)->ttl;
+		rt = (struct rtable *)dst;
+	} else if (dst->ops->family == AF_INET6) {
+		if (tun_encap_info->ttl_propagate == MPLS_TTL_PROP_DISABLED)
+			ttl = tun_encap_info->default_ttl;
+		else if (tun_encap_info->ttl_propagate == MPLS_TTL_PROP_DEFAULT &&
+			 !net->mpls.ip_ttl_propagate)
+			ttl = net->mpls.default_ttl;
+		else
+			ttl = ipv6_hdr(skb)->hop_limit;
+		rt6 = (struct rt6_info *)dst;
+	} else {
+		goto drop;
+	}
+
 	/* Verify the destination can hold the packet */
 	new_header_size = mpls_encap_size(tun_encap_info);
 	mtu = mpls_dev_mtu(out_dev);
@@ -160,6 +184,17 @@ static int mpls_build_state(struct nlattr *nla,
 			     &tun_encap_info->labels, tun_encap_info->label);
 	if (ret)
 		goto errout;
+
+	tun_encap_info->ttl_propagate = MPLS_TTL_PROP_DEFAULT;
+
+	if (tb[MPLS_IPTUNNEL_TTL]) {
+		tun_encap_info->default_ttl = nla_get_u8(tb[MPLS_IPTUNNEL_TTL]);
+		/* TTL 0 implies propagate from IP header */
+		tun_encap_info->ttl_propagate = tun_encap_info->default_ttl ?
+			MPLS_TTL_PROP_DISABLED :
+			MPLS_TTL_PROP_ENABLED;
+	}
+
 	newts->type = LWTUNNEL_ENCAP_MPLS;
 	newts->flags |= LWTUNNEL_STATE_XMIT_REDIRECT;
 	newts->headroom = mpls_encap_size(tun_encap_info);
@@ -186,6 +221,10 @@ static int mpls_fill_encap_info(struct sk_buff *skb,
 			   tun_encap_info->label))
 		goto nla_put_failure;
 
+	if (tun_encap_info->ttl_propagate != MPLS_TTL_PROP_DEFAULT &&
+	    nla_put_u8(skb, MPLS_IPTUNNEL_TTL, tun_encap_info->default_ttl))
+		goto nla_put_failure;
+
 	return 0;
 
 nla_put_failure:
@@ -195,10 +234,16 @@ static int mpls_fill_encap_info(struct sk_buff *skb,
 static int mpls_encap_nlsize(struct lwtunnel_state *lwtstate)
 {
 	struct mpls_iptunnel_encap *tun_encap_info;
+	int nlsize;
 
 	tun_encap_info = mpls_lwtunnel_encap(lwtstate);
 
-	return nla_total_size(tun_encap_info->labels * 4);
+	nlsize = nla_total_size(tun_encap_info->labels * 4);
+
+	if (tun_encap_info->ttl_propagate != MPLS_TTL_PROP_DEFAULT)
+		nlsize += nla_total_size(1);
+
+	return nlsize;
 }
 
 static int mpls_encap_cmp(struct lwtunnel_state *a, struct lwtunnel_state *b)
@@ -207,7 +252,9 @@ static int mpls_encap_cmp(struct lwtunnel_state *a, struct lwtunnel_state *b)
 	struct mpls_iptunnel_encap *b_hdr = mpls_lwtunnel_encap(b);
 	int l;
 
-	if (a_hdr->labels != b_hdr->labels)
+	if (a_hdr->labels != b_hdr->labels ||
+	    a_hdr->ttl_propagate != b_hdr->ttl_propagate ||
+	    a_hdr->default_ttl != b_hdr->default_ttl)
 		return 1;
 
 	for (l = 0; l < MAX_NEW_LABELS; l++)
-- 
2.1.4

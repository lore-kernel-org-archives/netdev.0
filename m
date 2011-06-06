From: Eric Leblond <eric@regit.org>
Subject: [RFC PATCHv2] ipv6: implementation of reverse path filtering
Date: Mon,  6 Jun 2011 19:53:25 +0200
Message-ID: <1307382805-5753-1-git-send-email-eric@regit.org>
References: <1307362957.3098.7.camel@edumazet-laptop>
Cc: netdev@vger.kernel.org, Eric Leblond <eric@regit.org>
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ks28632.kimsufi.com ([91.121.96.152]:49787 "EHLO
	ks28632.kimsufi.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756605Ab1FFRyB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 13:54:01 -0400
In-Reply-To: <1307362957.3098.7.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch provides a basic implementation of reverse path filtering
for IPv6. Functionnality can be activatedor desactivated through an
rp_filter entry similar to the IPv4 one.

The functionnality is disabled by default for backward compatibility
but should be enable on all IPv6 routers/firewalls for security reason.

This implementation is heavily based on the patch Denis Semmau proposed
in 2006.

Signed-off-by: Eric Leblond <eric@regit.org>
---
 include/linux/ipv6.h   |    2 ++
 include/linux/sysctl.h |    1 +
 net/ipv6/addrconf.c    |   10 ++++++++++
 net/ipv6/ip6_output.c  |   35 +++++++++++++++++++++++++++++++++++
 4 files changed, 48 insertions(+), 0 deletions(-)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 0c99776..6b61869 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -172,6 +172,7 @@ struct ipv6_devconf {
 	__s32		disable_ipv6;
 	__s32		accept_dad;
 	__s32		force_tllao;
+	__s32		rp_filter;
 	void		*sysctl;
 };
 
@@ -213,6 +214,7 @@ enum {
 	DEVCONF_DISABLE_IPV6,
 	DEVCONF_ACCEPT_DAD,
 	DEVCONF_FORCE_TLLAO,
+	DEVCONF_RP_FILTER,
 	DEVCONF_MAX
 };
 
diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index 11684d9..bdcb7f8 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -568,6 +568,7 @@ enum {
 	NET_IPV6_ACCEPT_RA_RT_INFO_MAX_PLEN=22,
 	NET_IPV6_PROXY_NDP=23,
 	NET_IPV6_ACCEPT_SOURCE_ROUTE=25,
+	NET_IPV6_RP_FILTER=26,
 	__NET_IPV6_MAX
 };
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 498b927..ba1c574 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -196,6 +196,7 @@ static struct ipv6_devconf ipv6_devconf __read_mostly = {
 	.accept_source_route	= 0,	/* we do not accept RH0 by default. */
 	.disable_ipv6		= 0,
 	.accept_dad		= 1,
+	.rp_filter		= 0,
 };
 
 static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
@@ -230,6 +231,7 @@ static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
 	.accept_source_route	= 0,	/* we do not accept RH0 by default. */
 	.disable_ipv6		= 0,
 	.accept_dad		= 1,
+	.rp_filter		= 0,
 };
 
 /* IPv6 Wildcard Address and Loopback Address defined by RFC2553 */
@@ -3805,6 +3807,7 @@ static inline void ipv6_store_devconf(struct ipv6_devconf *cnf,
 	array[DEVCONF_DISABLE_IPV6] = cnf->disable_ipv6;
 	array[DEVCONF_ACCEPT_DAD] = cnf->accept_dad;
 	array[DEVCONF_FORCE_TLLAO] = cnf->force_tllao;
+	array[DEVCONF_RP_FILTER] = cnf->rp_filter;
 }
 
 static inline size_t inet6_ifla6_size(void)
@@ -4459,6 +4462,13 @@ static struct addrconf_sysctl_table
 			.proc_handler   = proc_dointvec
 		},
 		{
+			.procname       = "rp_filter",
+			.data           = &ipv6_devconf.rp_filter,
+			.maxlen         = sizeof(int),
+			.mode           = 0644,
+			.proc_handler   = proc_dointvec
+		},
+		{
 			/* sentinel */
 		}
 	},
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 9d4b165..ad8f351 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -374,6 +374,22 @@ static int ip6_forward_proxy_check(struct sk_buff *skb)
 	return 0;
 }
 
+static int rt6_validate_source(struct sk_buff *skb, char mode)
+{
+	struct rt6_info *rt;
+	struct ipv6hdr *hdr = ipv6_hdr(skb);
+	if (mode == 0)
+		return 0;
+	rt = rt6_lookup(dev_net(skb->dev), &hdr->saddr, NULL, 0, 0);
+	if (rt != NULL) {
+		if ((mode >= 2) && rt->rt6i_idev->dev)
+			return 0;
+		if ((mode == 1) && (rt->rt6i_idev->dev == skb->dev))
+			return 0;
+	}
+	return -1;
+}
+
 static inline int ip6_forward_finish(struct sk_buff *skb)
 {
 	return dst_output(skb);
@@ -384,6 +400,7 @@ int ip6_forward(struct sk_buff *skb)
 	struct dst_entry *dst = skb_dst(skb);
 	struct ipv6hdr *hdr = ipv6_hdr(skb);
 	struct inet6_skb_parm *opt = IP6CB(skb);
+	struct inet6_dev *idev = NULL;
 	struct net *net = dev_net(dst->dev);
 	u32 mtu;
 
@@ -401,6 +418,24 @@ int ip6_forward(struct sk_buff *skb)
 	if (skb->pkt_type != PACKET_HOST)
 		goto drop;
 
+	idev = in6_dev_get(skb->dev);
+	if (!idev) {
+		printk(KERN_WARNING "idev error for rp_filter\n");
+		goto error;
+	}
+
+	if (rt6_validate_source(skb,
+				max(net->ipv6.devconf_all->rp_filter,
+				    idev->cnf.rp_filter)) < 0) {
+		printk(KERN_WARNING
+				"rp_filter: packet refused on %s, invalid src %pI6 (dst: %pI6)",
+				skb->dev->name,
+				&hdr->saddr,
+				&hdr->daddr
+		      );
+		goto drop;
+	}
+
 	skb_forward_csum(skb);
 
 	/*
-- 
1.7.5.3


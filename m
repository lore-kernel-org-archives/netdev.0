From: David Lebrun <david.lebrun@uclouvain.be>
Subject: [PATCH 1/9] ipv6: implement dataplane support for rthdr type 4 (Segment Routing Header)
Date: Mon, 17 Oct 2016 16:42:22 +0200
Message-ID: <1476715350-18983-2-git-send-email-david.lebrun@uclouvain.be>
References: <1476715350-18983-1-git-send-email-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Lebrun <david.lebrun@uclouvain.be>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:33134 "EHLO
        smtp2.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933005AbcJQOqf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 10:46:35 -0400
Received: from mailboxes.uclouvain.be (mailboxes.uclouvain.be [130.104.6.131])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
        (No client certificate requested)
        by smtp2.sgsi.ucl.ac.be (Postfix) with ESMTPS id 36FF667DD6A
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2016 16:41:10 +0200 (CEST)
In-Reply-To: <1476715350-18983-1-git-send-email-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement minimal support for processing of SR-enabled packets
as described in
https://tools.ietf.org/html/draft-ietf-6man-segment-routing-header-02.

This patch implements the following operations:
- Intermediate segment endpoint: incrementation of active segment and rerouting.
- Egress for SR-encapsulated packets: decapsulation of outer IPv6 header + SRH
  and routing of inner packet.
- Cleanup flag support for SR-inlined packets: removal of SRH if we are the
  penultimate segment endpoint.

A per-interface sysctl seg6_enabled is provided, to accept/deny SR-enabled
packets. Default is deny.

This patch does not provide support for HMAC-signed packets.

Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>
---
 include/linux/ipv6.h      |   3 +
 include/linux/seg6.h      |   6 ++
 include/uapi/linux/ipv6.h |   2 +
 include/uapi/linux/seg6.h |  46 +++++++++++++++
 net/ipv6/Kconfig          |  13 +++++
 net/ipv6/addrconf.c       |  18 ++++++
 net/ipv6/exthdrs.c        | 140 ++++++++++++++++++++++++++++++++++++++++++++++
 7 files changed, 228 insertions(+)
 create mode 100644 include/linux/seg6.h
 create mode 100644 include/uapi/linux/seg6.h

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 7e9a789..75395ad 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -64,6 +64,9 @@ struct ipv6_devconf {
 	} stable_secret;
 	__s32		use_oif_addrs_only;
 	__s32		keep_addr_on_down;
+#ifdef CONFIG_IPV6_SEG6
+	__s32		seg6_enabled;
+#endif
 
 	struct ctl_table_header *sysctl_header;
 };
diff --git a/include/linux/seg6.h b/include/linux/seg6.h
new file mode 100644
index 0000000..7a66d2b
--- /dev/null
+++ b/include/linux/seg6.h
@@ -0,0 +1,6 @@
+#ifndef _LINUX_SEG6_H
+#define _LINUX_SEG6_H
+
+#include <uapi/linux/seg6.h>
+
+#endif
diff --git a/include/uapi/linux/ipv6.h b/include/uapi/linux/ipv6.h
index 8c27723..7ff1d65 100644
--- a/include/uapi/linux/ipv6.h
+++ b/include/uapi/linux/ipv6.h
@@ -39,6 +39,7 @@ struct in6_ifreq {
 #define IPV6_SRCRT_STRICT	0x01	/* Deprecated; will be removed */
 #define IPV6_SRCRT_TYPE_0	0	/* Deprecated; will be removed */
 #define IPV6_SRCRT_TYPE_2	2	/* IPv6 type 2 Routing Header	*/
+#define IPV6_SRCRT_TYPE_4	4	/* Segment Routing with IPv6 */
 
 /*
  *	routing header
@@ -178,6 +179,7 @@ enum {
 	DEVCONF_DROP_UNSOLICITED_NA,
 	DEVCONF_KEEP_ADDR_ON_DOWN,
 	DEVCONF_RTR_SOLICIT_MAX_INTERVAL,
+	DEVCONF_SEG6_ENABLED,
 	DEVCONF_MAX
 };
 
diff --git a/include/uapi/linux/seg6.h b/include/uapi/linux/seg6.h
new file mode 100644
index 0000000..9f9e157
--- /dev/null
+++ b/include/uapi/linux/seg6.h
@@ -0,0 +1,46 @@
+/*
+ *  SR-IPv6 implementation
+ *
+ *  Author:
+ *  David Lebrun <david.lebrun@uclouvain.be>
+ *
+ *
+ *  This program is free software; you can redistribute it and/or
+ *      modify it under the terms of the GNU General Public License
+ *      as published by the Free Software Foundation; either version
+ *      2 of the License, or (at your option) any later version.
+ */
+
+#ifndef _UAPI_LINUX_SEG6_H
+#define _UAPI_LINUX_SEG6_H
+
+/*
+ * SRH
+ */
+struct ipv6_sr_hdr {
+	__u8	nexthdr;
+	__u8	hdrlen;
+	__u8	type;
+	__u8	segments_left;
+	__u8	first_segment;
+	__be16	flags;
+	__u8	reserved;
+
+	struct in6_addr segments[0];
+} __attribute__((packed));
+
+#define SR6_FLAG_CLEANUP	(1 << 15)
+#define SR6_FLAG_PROTECTED	(1 << 14)
+#define SR6_FLAG_OAM		(1 << 13)
+#define SR6_FLAG_ALERT		(1 << 12)
+#define SR6_FLAG_HMAC		(1 << 11)
+
+#define SR6_TLV_INGRESS		1
+#define SR6_TLV_EGRESS		2
+#define SR6_TLV_OPAQUE		3
+#define SR6_TLV_PADDING		4
+#define SR6_TLV_HMAC		5
+
+#define sr_get_flags(srh) (be16_to_cpu((srh)->flags))
+
+#endif
diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
index 2343e4f..691c318 100644
--- a/net/ipv6/Kconfig
+++ b/net/ipv6/Kconfig
@@ -289,4 +289,17 @@ config IPV6_PIMSM_V2
 	  Support for IPv6 PIM multicast routing protocol PIM-SMv2.
 	  If unsure, say N.
 
+config IPV6_SEG6
+	bool "IPv6: Segment Routing support"
+	depends on IPV6
+	select CRYPTO_HMAC
+	select CRYPTO_SHA1
+	select CRYPTO_SHA256
+	---help---
+	  Experimental support for IPv6 Segment Routing dataplane as defined
+	  in IETF draft-ietf-6man-segment-routing-header-02. This option
+	  enables the processing of SR-enabled packets allowing the kernel
+	  to act as a segment endpoint (intermediate or egress). It also
+	  enables an API for the kernel to act as an ingress SR router.
+
 endif # IPV6
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index d8983e1..42c0ffb 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -239,6 +239,9 @@ static struct ipv6_devconf ipv6_devconf __read_mostly = {
 	.use_oif_addrs_only	= 0,
 	.ignore_routes_with_linkdown = 0,
 	.keep_addr_on_down	= 0,
+#ifdef CONFIG_IPV6_SEG6
+	.seg6_enabled		= 0,
+#endif
 };
 
 static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
@@ -285,6 +288,9 @@ static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
 	.use_oif_addrs_only	= 0,
 	.ignore_routes_with_linkdown = 0,
 	.keep_addr_on_down	= 0,
+#ifdef CONFIG_IPV6_SEG6
+	.seg6_enabled		= 0,
+#endif
 };
 
 /* Check if a valid qdisc is available */
@@ -4965,6 +4971,9 @@ static inline void ipv6_store_devconf(struct ipv6_devconf *cnf,
 	array[DEVCONF_DROP_UNICAST_IN_L2_MULTICAST] = cnf->drop_unicast_in_l2_multicast;
 	array[DEVCONF_DROP_UNSOLICITED_NA] = cnf->drop_unsolicited_na;
 	array[DEVCONF_KEEP_ADDR_ON_DOWN] = cnf->keep_addr_on_down;
+#ifdef CONFIG_IPV6_SEG6
+	array[DEVCONF_SEG6_ENABLED] = cnf->seg6_enabled;
+#endif
 }
 
 static inline size_t inet6_ifla6_size(void)
@@ -6056,6 +6065,15 @@ static const struct ctl_table addrconf_sysctl[] = {
 		.proc_handler	= proc_dointvec,
 
 	},
+#ifdef CONFIG_IPV6_SEG6
+	{
+		.procname	= "seg6_enabled",
+		.data		= &ipv6_devconf.seg6_enabled,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+#endif
 	{
 		/* sentinel */
 	}
diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index 139ceb6..b31f811 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -47,6 +47,9 @@
 #if IS_ENABLED(CONFIG_IPV6_MIP6)
 #include <net/xfrm.h>
 #endif
+#ifdef CONFIG_IPV6_SEG6
+#include <linux/seg6.h>
+#endif
 
 #include <linux/uaccess.h>
 
@@ -286,6 +289,137 @@ static int ipv6_destopt_rcv(struct sk_buff *skb)
 	return -1;
 }
 
+#ifdef CONFIG_IPV6_SEG6
+static int ipv6_srh_rcv(struct sk_buff *skb)
+{
+	struct in6_addr *addr = NULL, *last_addr = NULL, *active_addr = NULL;
+	struct inet6_skb_parm *opt = IP6CB(skb);
+	struct net *net = dev_net(skb->dev);
+	struct ipv6_sr_hdr *hdr;
+	struct inet6_dev *idev;
+	int cleanup = 0;
+	int accept_seg6;
+
+	hdr = (struct ipv6_sr_hdr *)skb_transport_header(skb);
+
+	idev = __in6_dev_get(skb->dev);
+
+	accept_seg6 = net->ipv6.devconf_all->seg6_enabled;
+	if (accept_seg6 > idev->cnf.seg6_enabled)
+		accept_seg6 = idev->cnf.seg6_enabled;
+
+	if (!accept_seg6) {
+		kfree_skb(skb);
+		return -1;
+	}
+
+looped_back:
+	last_addr = hdr->segments;
+
+	if (hdr->segments_left > 0) {
+		if (hdr->nexthdr != NEXTHDR_IPV6 && hdr->segments_left == 1 &&
+		    sr_get_flags(hdr) & SR6_FLAG_CLEANUP)
+			cleanup = 1;
+	} else {
+		if (hdr->nexthdr == NEXTHDR_IPV6) {
+			int offset = (hdr->hdrlen + 1) << 3;
+
+			if (!pskb_pull(skb, offset)) {
+				kfree_skb(skb);
+				return -1;
+			}
+			skb_postpull_rcsum(skb, skb_transport_header(skb),
+					   offset);
+
+			skb_reset_network_header(skb);
+			skb_reset_transport_header(skb);
+			skb->encapsulation = 0;
+
+			__skb_tunnel_rx(skb, skb->dev, net);
+
+			netif_rx(skb);
+			return -1;
+		}
+
+		opt->srcrt = skb_network_header_len(skb);
+		opt->lastopt = opt->srcrt;
+		skb->transport_header += (hdr->hdrlen + 1) << 3;
+		opt->nhoff = (&hdr->nexthdr) - skb_network_header(skb);
+
+		return 1;
+	}
+
+	if (skb_cloned(skb)) {
+		if (pskb_expand_head(skb, 0, 0, GFP_ATOMIC)) {
+			__IP6_INC_STATS(net, ip6_dst_idev(skb_dst(skb)),
+					IPSTATS_MIB_OUTDISCARDS);
+			kfree_skb(skb);
+			return -1;
+		}
+	}
+
+	if (skb->ip_summed == CHECKSUM_COMPLETE)
+		skb->ip_summed = CHECKSUM_NONE;
+
+	hdr = (struct ipv6_sr_hdr *)skb_transport_header(skb);
+
+	active_addr = hdr->segments + hdr->segments_left;
+	hdr->segments_left--;
+	addr = hdr->segments + hdr->segments_left;
+
+	ipv6_hdr(skb)->daddr = *addr;
+
+	skb_push(skb, sizeof(struct ipv6hdr));
+
+	if (cleanup) {
+		int srhlen = (hdr->hdrlen + 1) << 3;
+		int nh = hdr->nexthdr;
+
+		memmove(skb_network_header(skb) + srhlen,
+			skb_network_header(skb),
+			(unsigned char *)hdr - skb_network_header(skb));
+		skb_pull(skb, srhlen);
+		skb->network_header += srhlen;
+		ipv6_hdr(skb)->nexthdr = nh;
+		ipv6_hdr(skb)->payload_len = htons(skb->len -
+						   sizeof(struct ipv6hdr));
+	}
+
+	skb_dst_drop(skb);
+
+	ip6_route_input(skb);
+
+	if (skb_dst(skb)->error) {
+		dst_input(skb);
+		return -1;
+	}
+
+	if (skb_dst(skb)->dev->flags & IFF_LOOPBACK) {
+		if (ipv6_hdr(skb)->hop_limit <= 1) {
+			__IP6_INC_STATS(net, ip6_dst_idev(skb_dst(skb)),
+					IPSTATS_MIB_INHDRERRORS);
+			icmpv6_send(skb, ICMPV6_TIME_EXCEED,
+				    ICMPV6_EXC_HOPLIMIT, 0);
+			kfree_skb(skb);
+			return -1;
+		}
+		ipv6_hdr(skb)->hop_limit--;
+
+		/* be sure that srh is still present before reinjecting */
+		if (!cleanup) {
+			skb_pull(skb, sizeof(struct ipv6hdr));
+			goto looped_back;
+		}
+		skb_set_transport_header(skb, sizeof(struct ipv6hdr));
+		IP6CB(skb)->nhoff = offsetof(struct ipv6hdr, nexthdr);
+	}
+
+	dst_input(skb);
+
+	return -1;
+}
+#endif
+
 /********************************
   Routing header.
  ********************************/
@@ -326,6 +460,12 @@ static int ipv6_rthdr_rcv(struct sk_buff *skb)
 		return -1;
 	}
 
+#ifdef CONFIG_IPV6_SEG6
+	/* segment routing */
+	if (hdr->type == IPV6_SRCRT_TYPE_4)
+		return ipv6_srh_rcv(skb);
+#endif
+
 looped_back:
 	if (hdr->segments_left == 0) {
 		switch (hdr->type) {
-- 
2.7.3

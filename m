From: David Lebrun <david.lebrun@uclouvain.be>
Subject: [PATCH net-next v4 1/9] ipv6: implement dataplane support for rthdr type 4 (Segment Routing Header)
Date: Fri, 4 Nov 2016 11:29:40 +0100
Message-ID: <1478255388-32213-2-git-send-email-david.lebrun@uclouvain.be>
References: <1478255388-32213-1-git-send-email-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Lebrun <david.lebrun@uclouvain.be>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:60288 "EHLO
        smtp4.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933333AbcKDK2L (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2016 06:28:11 -0400
Received: from mailboxes.uclouvain.be (mailboxes.uclouvain.be [130.104.6.131])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
        (No client certificate requested)
        by smtp4.sgsi.ucl.ac.be (Postfix) with ESMTPS id B333967DB44
        for <netdev@vger.kernel.org>; Fri,  4 Nov 2016 11:27:58 +0100 (CET)
In-Reply-To: <1478255388-32213-1-git-send-email-david.lebrun@uclouvain.be>
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
 include/linux/ipv6.h      |   1 +
 include/linux/seg6.h      |   6 ++
 include/net/seg6.h        |  36 ++++++++++
 include/uapi/linux/ipv6.h |   2 +
 include/uapi/linux/seg6.h |  54 +++++++++++++++
 net/ipv6/addrconf.c       |  10 +++
 net/ipv6/exthdrs.c        | 165 ++++++++++++++++++++++++++++++++++++++++++++++
 7 files changed, 274 insertions(+)
 create mode 100644 include/linux/seg6.h
 create mode 100644 include/net/seg6.h
 create mode 100644 include/uapi/linux/seg6.h

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 1afb6e8..68d3f71 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -64,6 +64,7 @@ struct ipv6_devconf {
 	} stable_secret;
 	__s32		use_oif_addrs_only;
 	__s32		keep_addr_on_down;
+	__s32		seg6_enabled;
 
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
diff --git a/include/net/seg6.h b/include/net/seg6.h
new file mode 100644
index 0000000..4dd52a7
--- /dev/null
+++ b/include/net/seg6.h
@@ -0,0 +1,36 @@
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
+#ifndef _NET_SEG6_H
+#define _NET_SEG6_H
+
+static inline void update_csum_diff4(struct sk_buff *skb, __be32 from,
+				     __be32 to)
+{
+	__be32 diff[] = { ~from, to };
+
+	skb->csum = ~csum_partial((char *)diff, sizeof(diff), ~skb->csum);
+}
+
+static inline void update_csum_diff16(struct sk_buff *skb, __be32 *from,
+				      __be32 *to)
+{
+	__be32 diff[] = {
+		~from[0], ~from[1], ~from[2], ~from[3],
+		to[0], to[1], to[2], to[3],
+	};
+
+	skb->csum = ~csum_partial((char *)diff, sizeof(diff), ~skb->csum);
+}
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
index 0000000..c396a80
--- /dev/null
+++ b/include/uapi/linux/seg6.h
@@ -0,0 +1,54 @@
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
+	__u8	flag_1;
+	__u8	flag_2;
+	__u8	reserved;
+
+	struct in6_addr segments[0];
+};
+
+#define SR6_FLAG1_CLEANUP	(1 << 7)
+#define SR6_FLAG1_PROTECTED	(1 << 6)
+#define SR6_FLAG1_OAM		(1 << 5)
+#define SR6_FLAG1_ALERT		(1 << 4)
+#define SR6_FLAG1_HMAC		(1 << 3)
+
+#define SR6_TLV_INGRESS		1
+#define SR6_TLV_EGRESS		2
+#define SR6_TLV_OPAQUE		3
+#define SR6_TLV_PADDING		4
+#define SR6_TLV_HMAC		5
+
+#define sr_has_cleanup(srh) ((srh)->flag_1 & SR6_FLAG1_CLEANUP)
+#define sr_has_hmac(srh) ((srh)->flag_1 & SR6_FLAG1_HMAC)
+
+struct sr6_tlv {
+	__u8 type;
+	__u8 len;
+	__u8 data[0];
+};
+
+#endif
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 060dd99..2ac6cb4 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -238,6 +238,7 @@ static struct ipv6_devconf ipv6_devconf __read_mostly = {
 	.use_oif_addrs_only	= 0,
 	.ignore_routes_with_linkdown = 0,
 	.keep_addr_on_down	= 0,
+	.seg6_enabled		= 0,
 };
 
 static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
@@ -284,6 +285,7 @@ static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
 	.use_oif_addrs_only	= 0,
 	.ignore_routes_with_linkdown = 0,
 	.keep_addr_on_down	= 0,
+	.seg6_enabled		= 0,
 };
 
 /* Check if a valid qdisc is available */
@@ -4944,6 +4946,7 @@ static inline void ipv6_store_devconf(struct ipv6_devconf *cnf,
 	array[DEVCONF_DROP_UNICAST_IN_L2_MULTICAST] = cnf->drop_unicast_in_l2_multicast;
 	array[DEVCONF_DROP_UNSOLICITED_NA] = cnf->drop_unsolicited_na;
 	array[DEVCONF_KEEP_ADDR_ON_DOWN] = cnf->keep_addr_on_down;
+	array[DEVCONF_SEG6_ENABLED] = cnf->seg6_enabled;
 }
 
 static inline size_t inet6_ifla6_size(void)
@@ -6036,6 +6039,13 @@ static const struct ctl_table addrconf_sysctl[] = {
 
 	},
 	{
+		.procname	= "seg6_enabled",
+		.data		= &ipv6_devconf.seg6_enabled,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
 		/* sentinel */
 	}
 };
diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index 139ceb6..21a86cf 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -47,6 +47,8 @@
 #if IS_ENABLED(CONFIG_IPV6_MIP6)
 #include <net/xfrm.h>
 #endif
+#include <linux/seg6.h>
+#include <net/seg6.h>
 
 #include <linux/uaccess.h>
 
@@ -286,6 +288,165 @@ static int ipv6_destopt_rcv(struct sk_buff *skb)
 	return -1;
 }
 
+static void seg6_update_csum(struct sk_buff *skb)
+{
+	struct ipv6_sr_hdr *hdr;
+	struct in6_addr *addr;
+	__be32 from, to;
+
+	/* srh is at transport offset and seg_left is already decremented
+	 * but daddr is not yet updated with next segment
+	 */
+
+	hdr = (struct ipv6_sr_hdr *)skb_transport_header(skb);
+	addr = hdr->segments + hdr->segments_left;
+
+	hdr->segments_left++;
+	from = *(__be32 *)hdr;
+
+	hdr->segments_left--;
+	to = *(__be32 *)hdr;
+
+	/* update skb csum with diff resulting from seg_left decrement */
+
+	update_csum_diff4(skb, from, to);
+
+	/* compute csum diff between current and next segment and update */
+
+	update_csum_diff16(skb, (__be32 *)(&ipv6_hdr(skb)->daddr),
+			   (__be32 *)addr);
+}
+
+static int ipv6_srh_rcv(struct sk_buff *skb)
+{
+	struct inet6_skb_parm *opt = IP6CB(skb);
+	struct net *net = dev_net(skb->dev);
+	struct ipv6_sr_hdr *hdr;
+	struct inet6_dev *idev;
+	struct in6_addr *addr;
+	bool cleanup = false;
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
+	if (hdr->segments_left > 0) {
+		if (hdr->nexthdr != NEXTHDR_IPV6 && hdr->segments_left == 1 &&
+		    sr_has_cleanup(hdr))
+			cleanup = true;
+	} else {
+		if (hdr->nexthdr == NEXTHDR_IPV6) {
+			int offset = (hdr->hdrlen + 1) << 3;
+
+			skb_postpull_rcsum(skb, skb_network_header(skb),
+					   skb_network_header_len(skb));
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
+	hdr = (struct ipv6_sr_hdr *)skb_transport_header(skb);
+
+	hdr->segments_left--;
+	addr = hdr->segments + hdr->segments_left;
+
+	skb_push(skb, sizeof(struct ipv6hdr));
+
+	if (skb->ip_summed == CHECKSUM_COMPLETE)
+		seg6_update_csum(skb);
+
+	ipv6_hdr(skb)->daddr = *addr;
+
+	if (cleanup) {
+		int srhlen = (hdr->hdrlen + 1) << 3;
+		int nh = hdr->nexthdr;
+
+		skb_pull_rcsum(skb, sizeof(struct ipv6hdr) + srhlen);
+		memmove(skb_network_header(skb) + srhlen,
+			skb_network_header(skb),
+			(unsigned char *)hdr - skb_network_header(skb));
+		skb->network_header += srhlen;
+		ipv6_hdr(skb)->nexthdr = nh;
+		ipv6_hdr(skb)->payload_len = htons(skb->len -
+						   sizeof(struct ipv6hdr));
+		skb_push_rcsum(skb, sizeof(struct ipv6hdr));
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
+
 /********************************
   Routing header.
  ********************************/
@@ -326,6 +487,10 @@ static int ipv6_rthdr_rcv(struct sk_buff *skb)
 		return -1;
 	}
 
+	/* segment routing */
+	if (hdr->type == IPV6_SRCRT_TYPE_4)
+		return ipv6_srh_rcv(skb);
+
 looped_back:
 	if (hdr->segments_left == 0) {
 		switch (hdr->type) {
-- 
2.7.3

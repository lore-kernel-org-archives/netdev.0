From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [RFC PATCH 09/13] ipv6: Separate out UDP offload functionality
Date: Tue, 13 Nov 2012 20:24:10 -0500
Message-ID: <1352856254-29667-10-git-send-email-vyasevic@redhat.com>
References: <1352856254-29667-1-git-send-email-vyasevic@redhat.com>
Cc: eric.dumazet@gmail.com, davem@davemloft.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6304 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932397Ab2KNBYd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2012 20:24:33 -0500
In-Reply-To: <1352856254-29667-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pull UDP GSO code into a separate file in preparation for moving
the code out of the module.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/ipv6/Makefile      |    2 +-
 net/ipv6/ip6_offload.h |    3 +
 net/ipv6/udp.c         |  104 ++---------------------------------------
 net/ipv6/udp_offload.c |  122 ++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 130 insertions(+), 101 deletions(-)
 create mode 100644 net/ipv6/udp_offload.c

diff --git a/net/ipv6/Makefile b/net/ipv6/Makefile
index f47ad9f..04b5c96 100644
--- a/net/ipv6/Makefile
+++ b/net/ipv6/Makefile
@@ -10,7 +10,7 @@ ipv6-objs :=	af_inet6.o anycast.o ip6_output.o ip6_input.o addrconf.o \
 		raw.o protocol.o icmp.o mcast.o reassembly.o tcp_ipv6.o \
 		exthdrs.o datagram.o ip6_flowlabel.o inet6_connection_sock.o
 
-ipv6-offload :=	ip6_offload.o tcpv6_offload.o
+ipv6-offload :=	ip6_offload.o tcpv6_offload.o udp_offload.o
 
 ipv6-$(CONFIG_SYSCTL) = sysctl_net_ipv6.o
 ipv6-$(CONFIG_IPV6_MROUTE) += ip6mr.o
diff --git a/net/ipv6/ip6_offload.h b/net/ipv6/ip6_offload.h
index 1891946..dff7936 100644
--- a/net/ipv6/ip6_offload.h
+++ b/net/ipv6/ip6_offload.h
@@ -11,6 +11,9 @@
 #ifndef __ip6_offload_h
 #define __ip6_offload_h
 
+int udp_offload_init(void);
+void udp_offload_cleanup(void);
+
 int tcpv6_offload_init(void);
 void tcpv6_offload_cleanup(void);
 
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index e4cc1f4..013fef7 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -50,6 +50,7 @@
 #include <linux/seq_file.h>
 #include <trace/events/skb.h>
 #include "udp_impl.h"
+#include "ip6_offload.h"
 
 int ipv6_rcv_saddr_equal(const struct sock *sk, const struct sock *sk2)
 {
@@ -1343,109 +1344,12 @@ int compat_udpv6_getsockopt(struct sock *sk, int level, int optname,
 }
 #endif
 
-static int udp6_ufo_send_check(struct sk_buff *skb)
-{
-	const struct ipv6hdr *ipv6h;
-	struct udphdr *uh;
-
-	if (!pskb_may_pull(skb, sizeof(*uh)))
-		return -EINVAL;
-
-	ipv6h = ipv6_hdr(skb);
-	uh = udp_hdr(skb);
-
-	uh->check = ~csum_ipv6_magic(&ipv6h->saddr, &ipv6h->daddr, skb->len,
-				     IPPROTO_UDP, 0);
-	skb->csum_start = skb_transport_header(skb) - skb->head;
-	skb->csum_offset = offsetof(struct udphdr, check);
-	skb->ip_summed = CHECKSUM_PARTIAL;
-	return 0;
-}
-
-static struct sk_buff *udp6_ufo_fragment(struct sk_buff *skb,
-	netdev_features_t features)
-{
-	struct sk_buff *segs = ERR_PTR(-EINVAL);
-	unsigned int mss;
-	unsigned int unfrag_ip6hlen, unfrag_len;
-	struct frag_hdr *fptr;
-	u8 *mac_start, *prevhdr;
-	u8 nexthdr;
-	u8 frag_hdr_sz = sizeof(struct frag_hdr);
-	int offset;
-	__wsum csum;
-
-	mss = skb_shinfo(skb)->gso_size;
-	if (unlikely(skb->len <= mss))
-		goto out;
-
-	if (skb_gso_ok(skb, features | NETIF_F_GSO_ROBUST)) {
-		/* Packet is from an untrusted source, reset gso_segs. */
-		int type = skb_shinfo(skb)->gso_type;
-
-		if (unlikely(type & ~(SKB_GSO_UDP | SKB_GSO_DODGY) ||
-			     !(type & (SKB_GSO_UDP))))
-			goto out;
-
-		skb_shinfo(skb)->gso_segs = DIV_ROUND_UP(skb->len, mss);
-
-		segs = NULL;
-		goto out;
-	}
-
-	/* Do software UFO. Complete and fill in the UDP checksum as HW cannot
-	 * do checksum of UDP packets sent as multiple IP fragments.
-	 */
-	offset = skb_checksum_start_offset(skb);
-	csum = skb_checksum(skb, offset, skb->len - offset, 0);
-	offset += skb->csum_offset;
-	*(__sum16 *)(skb->data + offset) = csum_fold(csum);
-	skb->ip_summed = CHECKSUM_NONE;
-
-	/* Check if there is enough headroom to insert fragment header. */
-	if ((skb_mac_header(skb) < skb->head + frag_hdr_sz) &&
-	    pskb_expand_head(skb, frag_hdr_sz, 0, GFP_ATOMIC))
-		goto out;
-
-	/* Find the unfragmentable header and shift it left by frag_hdr_sz
-	 * bytes to insert fragment header.
-	 */
-	unfrag_ip6hlen = ip6_find_1stfragopt(skb, &prevhdr);
-	nexthdr = *prevhdr;
-	*prevhdr = NEXTHDR_FRAGMENT;
-	unfrag_len = skb_network_header(skb) - skb_mac_header(skb) +
-		     unfrag_ip6hlen;
-	mac_start = skb_mac_header(skb);
-	memmove(mac_start-frag_hdr_sz, mac_start, unfrag_len);
-
-	skb->mac_header -= frag_hdr_sz;
-	skb->network_header -= frag_hdr_sz;
-
-	fptr = (struct frag_hdr *)(skb_network_header(skb) + unfrag_ip6hlen);
-	fptr->nexthdr = nexthdr;
-	fptr->reserved = 0;
-	ipv6_select_ident(fptr, (struct rt6_info *)skb_dst(skb));
-
-	/* Fragment the skb. ipv6 header and the remaining fields of the
-	 * fragment header are updated in ipv6_gso_segment()
-	 */
-	segs = skb_segment(skb, features);
-
-out:
-	return segs;
-}
-
 static const struct inet6_protocol udpv6_protocol = {
 	.handler	=	udpv6_rcv,
 	.err_handler	=	udpv6_err,
 	.flags		=	INET6_PROTO_NOPOLICY|INET6_PROTO_FINAL,
 };
 
-static const struct net_offload udpv6_offload = {
-	.gso_send_check =	udp6_ufo_send_check,
-	.gso_segment	=	udp6_ufo_fragment,
-};
-
 /* ------------------------------------------------------------------------ */
 #ifdef CONFIG_PROC_FS
 
@@ -1568,7 +1472,7 @@ int __init udpv6_init(void)
 {
 	int ret;
 
-	ret = inet6_add_offload(&udpv6_offload, IPPROTO_UDP);
+	ret = udp_offload_init();
 	if (ret)
 		goto out;
 
@@ -1585,7 +1489,7 @@ out:
 out_udpv6_protocol:
 	inet6_del_protocol(&udpv6_protocol, IPPROTO_UDP);
 out_offload:
-	inet6_del_offload(&udpv6_offload, IPPROTO_UDP);
+	udp_offload_cleanup();
 	goto out;
 }
 
@@ -1593,5 +1497,5 @@ void udpv6_exit(void)
 {
 	inet6_unregister_protosw(&udpv6_protosw);
 	inet6_del_protocol(&udpv6_protocol, IPPROTO_UDP);
-	inet6_del_offload(&udpv6_offload, IPPROTO_UDP);
+	udp_offload_cleanup();
 }
diff --git a/net/ipv6/udp_offload.c b/net/ipv6/udp_offload.c
new file mode 100644
index 0000000..f964d2b
--- /dev/null
+++ b/net/ipv6/udp_offload.c
@@ -0,0 +1,122 @@
+/*
+ *	IPV6 GSO/GRO offload support
+ *	Linux INET6 implementation
+ *
+ *	This program is free software; you can redistribute it and/or
+ *      modify it under the terms of the GNU General Public License
+ *      as published by the Free Software Foundation; either version
+ *      2 of the License, or (at your option) any later version.
+ *
+ *      UDPv6 GSO support
+ */
+#include <linux/skbuff.h>
+#include <net/protocol.h>
+#include <net/ipv6.h>
+#include <net/udp.h>
+#include "ip6_offload.h"
+
+static int udp6_ufo_send_check(struct sk_buff *skb)
+{
+	const struct ipv6hdr *ipv6h;
+	struct udphdr *uh;
+
+	if (!pskb_may_pull(skb, sizeof(*uh)))
+		return -EINVAL;
+
+	ipv6h = ipv6_hdr(skb);
+	uh = udp_hdr(skb);
+
+	uh->check = ~csum_ipv6_magic(&ipv6h->saddr, &ipv6h->daddr, skb->len,
+				     IPPROTO_UDP, 0);
+	skb->csum_start = skb_transport_header(skb) - skb->head;
+	skb->csum_offset = offsetof(struct udphdr, check);
+	skb->ip_summed = CHECKSUM_PARTIAL;
+	return 0;
+}
+
+static struct sk_buff *udp6_ufo_fragment(struct sk_buff *skb,
+	netdev_features_t features)
+{
+	struct sk_buff *segs = ERR_PTR(-EINVAL);
+	unsigned int mss;
+	unsigned int unfrag_ip6hlen, unfrag_len;
+	struct frag_hdr *fptr;
+	u8 *mac_start, *prevhdr;
+	u8 nexthdr;
+	u8 frag_hdr_sz = sizeof(struct frag_hdr);
+	int offset;
+	__wsum csum;
+
+	mss = skb_shinfo(skb)->gso_size;
+	if (unlikely(skb->len <= mss))
+		goto out;
+
+	if (skb_gso_ok(skb, features | NETIF_F_GSO_ROBUST)) {
+		/* Packet is from an untrusted source, reset gso_segs. */
+		int type = skb_shinfo(skb)->gso_type;
+
+		if (unlikely(type & ~(SKB_GSO_UDP | SKB_GSO_DODGY) ||
+			     !(type & (SKB_GSO_UDP))))
+			goto out;
+
+		skb_shinfo(skb)->gso_segs = DIV_ROUND_UP(skb->len, mss);
+
+		segs = NULL;
+		goto out;
+	}
+
+	/* Do software UFO. Complete and fill in the UDP checksum as HW cannot
+	 * do checksum of UDP packets sent as multiple IP fragments.
+	 */
+	offset = skb_checksum_start_offset(skb);
+	csum = skb_checksum(skb, offset, skb->len - offset, 0);
+	offset += skb->csum_offset;
+	*(__sum16 *)(skb->data + offset) = csum_fold(csum);
+	skb->ip_summed = CHECKSUM_NONE;
+
+	/* Check if there is enough headroom to insert fragment header. */
+	if ((skb_mac_header(skb) < skb->head + frag_hdr_sz) &&
+	    pskb_expand_head(skb, frag_hdr_sz, 0, GFP_ATOMIC))
+		goto out;
+
+	/* Find the unfragmentable header and shift it left by frag_hdr_sz
+	 * bytes to insert fragment header.
+	 */
+	unfrag_ip6hlen = ip6_find_1stfragopt(skb, &prevhdr);
+	nexthdr = *prevhdr;
+	*prevhdr = NEXTHDR_FRAGMENT;
+	unfrag_len = skb_network_header(skb) - skb_mac_header(skb) +
+		     unfrag_ip6hlen;
+	mac_start = skb_mac_header(skb);
+	memmove(mac_start-frag_hdr_sz, mac_start, unfrag_len);
+
+	skb->mac_header -= frag_hdr_sz;
+	skb->network_header -= frag_hdr_sz;
+
+	fptr = (struct frag_hdr *)(skb_network_header(skb) + unfrag_ip6hlen);
+	fptr->nexthdr = nexthdr;
+	fptr->reserved = 0;
+	ipv6_select_ident(fptr, (struct rt6_info *)skb_dst(skb));
+
+	/* Fragment the skb. ipv6 header and the remaining fields of the
+	 * fragment header are updated in ipv6_gso_segment()
+	 */
+	segs = skb_segment(skb, features);
+
+out:
+	return segs;
+}
+static const struct net_offload udpv6_offload = {
+	.gso_send_check =	udp6_ufo_send_check,
+	.gso_segment	=	udp6_ufo_fragment,
+};
+
+int __init udp_offload_init(void)
+{
+	return inet6_add_offload(&udpv6_offload, IPPROTO_UDP);
+}
+
+void udp_offload_cleanup(void)
+{
+	inet6_del_offload(&udpv6_offload, IPPROTO_UDP);
+}
-- 
1.7.7.6

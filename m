From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next] net: udp4: move GSO functions to udp_offload
Date: Sat,  8 Jun 2013 12:56:03 +0200
Message-ID: <1370688963-32635-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15803 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751980Ab3FHK4I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Jun 2013 06:56:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similarly to TCP offloading and UDPv6 offloading, move all related
UDPv4 functions to udp_offload.c to make things more explicit. Also,
by this, we can make those functions static.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 include/net/udp.h      |   7 ++--
 net/ipv4/Makefile      |   2 +-
 net/ipv4/af_inet.c     |   9 +----
 net/ipv4/udp.c         |  75 +------------------------------------
 net/ipv4/udp_offload.c | 100 +++++++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 108 insertions(+), 85 deletions(-)
 create mode 100644 net/ipv4/udp_offload.c

diff --git a/include/net/udp.h b/include/net/udp.h
index 065f379..b30a71a 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -187,6 +187,8 @@ extern int udp_ioctl(struct sock *sk, int cmd, unsigned long arg);
 extern int udp_disconnect(struct sock *sk, int flags);
 extern unsigned int udp_poll(struct file *file, struct socket *sock,
 			     poll_table *wait);
+extern struct sk_buff *skb_udp_tunnel_segment(struct sk_buff *skb,
+					      netdev_features_t features);
 extern int udp_lib_getsockopt(struct sock *sk, int level, int optname,
 			      char __user *optval, int __user *optlen);
 extern int udp_lib_setsockopt(struct sock *sk, int level, int optname,
@@ -262,11 +264,10 @@ extern int udp4_proc_init(void);
 extern void udp4_proc_exit(void);
 #endif
 
+extern int udpv4_offload_init(void);
+
 extern void udp_init(void);
 
-extern int udp4_ufo_send_check(struct sk_buff *skb);
-extern struct sk_buff *udp4_ufo_fragment(struct sk_buff *skb,
-	netdev_features_t features);
 extern void udp_encap_enable(void);
 #if IS_ENABLED(CONFIG_IPV6)
 extern void udpv6_encap_enable(void);
diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
index 4d3e138..a9dd333 100644
--- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -9,7 +9,7 @@ obj-y     := route.o inetpeer.o protocol.o \
 	     tcp.o tcp_input.o tcp_output.o tcp_timer.o tcp_ipv4.o \
 	     tcp_minisocks.o tcp_cong.o tcp_metrics.o tcp_fastopen.o \
 	     tcp_offload.o datagram.o raw.o udp.o udplite.o \
-	     arp.o icmp.o devinet.o af_inet.o  igmp.o \
+	     udp_offload.o arp.o icmp.o devinet.o af_inet.o igmp.o \
 	     fib_frontend.o fib_semantics.o fib_trie.o \
 	     inet_fragment.o ping.o
 
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 7b51429..5598b06 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1566,13 +1566,6 @@ static const struct net_protocol udp_protocol = {
 	.netns_ok =	1,
 };
 
-static const struct net_offload udp_offload = {
-	.callbacks = {
-		.gso_send_check = udp4_ufo_send_check,
-		.gso_segment = udp4_ufo_fragment,
-	},
-};
-
 static const struct net_protocol icmp_protocol = {
 	.handler =	icmp_rcv,
 	.err_handler =	icmp_err,
@@ -1672,7 +1665,7 @@ static int __init ipv4_offload_init(void)
 	/*
 	 * Add offloads
 	 */
-	if (inet_add_offload(&udp_offload, IPPROTO_UDP) < 0)
+	if (udpv4_offload_init() < 0)
 		pr_crit("%s: Cannot add UDP protocol offload\n", __func__);
 	if (tcpv4_offload_init() < 0)
 		pr_crit("%s: Cannot add TCP protocol offload\n", __func__);
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index c7338ec..aef854f 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -2286,29 +2286,8 @@ void __init udp_init(void)
 	sysctl_udp_wmem_min = SK_MEM_QUANTUM;
 }
 
-int udp4_ufo_send_check(struct sk_buff *skb)
-{
-	if (!pskb_may_pull(skb, sizeof(struct udphdr)))
-		return -EINVAL;
-
-	if (likely(!skb->encapsulation)) {
-		const struct iphdr *iph;
-		struct udphdr *uh;
-
-		iph = ip_hdr(skb);
-		uh = udp_hdr(skb);
-
-		uh->check = ~csum_tcpudp_magic(iph->saddr, iph->daddr, skb->len,
-				IPPROTO_UDP, 0);
-		skb->csum_start = skb_transport_header(skb) - skb->head;
-		skb->csum_offset = offsetof(struct udphdr, check);
-		skb->ip_summed = CHECKSUM_PARTIAL;
-	}
-	return 0;
-}
-
-static struct sk_buff *skb_udp_tunnel_segment(struct sk_buff *skb,
-		netdev_features_t features)
+struct sk_buff *skb_udp_tunnel_segment(struct sk_buff *skb,
+				       netdev_features_t features)
 {
 	struct sk_buff *segs = ERR_PTR(-EINVAL);
 	int mac_len = skb->mac_len;
@@ -2367,53 +2346,3 @@ static struct sk_buff *skb_udp_tunnel_segment(struct sk_buff *skb,
 out:
 	return segs;
 }
-
-struct sk_buff *udp4_ufo_fragment(struct sk_buff *skb,
-	netdev_features_t features)
-{
-	struct sk_buff *segs = ERR_PTR(-EINVAL);
-	unsigned int mss;
-	mss = skb_shinfo(skb)->gso_size;
-	if (unlikely(skb->len <= mss))
-		goto out;
-
-	if (skb_gso_ok(skb, features | NETIF_F_GSO_ROBUST)) {
-		/* Packet is from an untrusted source, reset gso_segs. */
-		int type = skb_shinfo(skb)->gso_type;
-
-		if (unlikely(type & ~(SKB_GSO_UDP | SKB_GSO_DODGY |
-				      SKB_GSO_UDP_TUNNEL |
-				      SKB_GSO_GRE | SKB_GSO_MPLS) ||
-			     !(type & (SKB_GSO_UDP))))
-			goto out;
-
-		skb_shinfo(skb)->gso_segs = DIV_ROUND_UP(skb->len, mss);
-
-		segs = NULL;
-		goto out;
-	}
-
-	/* Fragment the skb. IP headers of the fragments are updated in
-	 * inet_gso_segment()
-	 */
-	if (skb->encapsulation && skb_shinfo(skb)->gso_type & SKB_GSO_UDP_TUNNEL)
-		segs = skb_udp_tunnel_segment(skb, features);
-	else {
-		int offset;
-		__wsum csum;
-
-		/* Do software UFO. Complete and fill in the UDP checksum as
-		 * HW cannot do checksum of UDP packets sent as multiple
-		 * IP fragments.
-		 */
-		offset = skb_checksum_start_offset(skb);
-		csum = skb_checksum(skb, offset, skb->len - offset, 0);
-		offset += skb->csum_offset;
-		*(__sum16 *)(skb->data + offset) = csum_fold(csum);
-		skb->ip_summed = CHECKSUM_NONE;
-
-		segs = skb_segment(skb, features);
-	}
-out:
-	return segs;
-}
diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
new file mode 100644
index 0000000..f35ecca
--- /dev/null
+++ b/net/ipv4/udp_offload.c
@@ -0,0 +1,100 @@
+/*
+ *	IPV4 GSO/GRO offload support
+ *	Linux INET implementation
+ *
+ *	This program is free software; you can redistribute it and/or
+ *	modify it under the terms of the GNU General Public License
+ *	as published by the Free Software Foundation; either version
+ *	2 of the License, or (at your option) any later version.
+ *
+ *	UDPv4 GSO support
+ */
+
+#include <linux/skbuff.h>
+#include <net/udp.h>
+#include <net/protocol.h>
+
+static int udp4_ufo_send_check(struct sk_buff *skb)
+{
+	if (!pskb_may_pull(skb, sizeof(struct udphdr)))
+		return -EINVAL;
+
+	if (likely(!skb->encapsulation)) {
+		const struct iphdr *iph;
+		struct udphdr *uh;
+
+		iph = ip_hdr(skb);
+		uh = udp_hdr(skb);
+
+		uh->check = ~csum_tcpudp_magic(iph->saddr, iph->daddr, skb->len,
+				IPPROTO_UDP, 0);
+		skb->csum_start = skb_transport_header(skb) - skb->head;
+		skb->csum_offset = offsetof(struct udphdr, check);
+		skb->ip_summed = CHECKSUM_PARTIAL;
+	}
+
+	return 0;
+}
+
+static struct sk_buff *udp4_ufo_fragment(struct sk_buff *skb,
+					 netdev_features_t features)
+{
+	struct sk_buff *segs = ERR_PTR(-EINVAL);
+	unsigned int mss;
+
+	mss = skb_shinfo(skb)->gso_size;
+	if (unlikely(skb->len <= mss))
+		goto out;
+
+	if (skb_gso_ok(skb, features | NETIF_F_GSO_ROBUST)) {
+		/* Packet is from an untrusted source, reset gso_segs. */
+		int type = skb_shinfo(skb)->gso_type;
+
+		if (unlikely(type & ~(SKB_GSO_UDP | SKB_GSO_DODGY |
+				      SKB_GSO_UDP_TUNNEL |
+				      SKB_GSO_GRE | SKB_GSO_MPLS) ||
+			     !(type & (SKB_GSO_UDP))))
+			goto out;
+
+		skb_shinfo(skb)->gso_segs = DIV_ROUND_UP(skb->len, mss);
+
+		segs = NULL;
+		goto out;
+	}
+
+	/* Fragment the skb. IP headers of the fragments are updated in
+	 * inet_gso_segment()
+	 */
+	if (skb->encapsulation && skb_shinfo(skb)->gso_type & SKB_GSO_UDP_TUNNEL)
+		segs = skb_udp_tunnel_segment(skb, features);
+	else {
+		int offset;
+		__wsum csum;
+
+		/* Do software UFO. Complete and fill in the UDP checksum as
+		 * HW cannot do checksum of UDP packets sent as multiple
+		 * IP fragments.
+		 */
+		offset = skb_checksum_start_offset(skb);
+		csum = skb_checksum(skb, offset, skb->len - offset, 0);
+		offset += skb->csum_offset;
+		*(__sum16 *)(skb->data + offset) = csum_fold(csum);
+		skb->ip_summed = CHECKSUM_NONE;
+
+		segs = skb_segment(skb, features);
+	}
+out:
+	return segs;
+}
+
+static const struct net_offload udpv4_offload = {
+	.callbacks = {
+		.gso_send_check = udp4_ufo_send_check,
+		.gso_segment = udp4_ufo_fragment,
+	},
+};
+
+int __init udpv4_offload_init(void)
+{
+	return inet_add_offload(&udpv4_offload, IPPROTO_UDP);
+}
-- 
1.7.11.7

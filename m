From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next v3] pktgen: Add UDPCSUM flag to support UDP checksums
Date: Thu, 25 Jul 2013 18:12:18 +0200
Message-ID: <84311bc33840c8d77ab4286729df86ec85cdd411.1374768622.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Ben Greear <greearb@candelatech.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:42275 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756193Ab3GYQMY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jul 2013 12:12:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

UDP checksums are optional, hence pktgen has been omitting them in
favour of performance. The optional flag UDPCSUM enables UDP
checksumming. If the output device supports hardware checksumming
the skb is prepared and marked CHECKSUM_PARTIAL, otherwise the
checksum is generated in software.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Ben Greear <greearb@candelatech.com>
---
v2: - Add IPv6 support
v3: - Allow unsetting UDPCSUM flag

 include/net/udp.h |  1 +
 net/core/pktgen.c | 57 ++++++++++++++++++++++++++++++++++++++++++++++++++-----
 net/ipv4/udp.c    |  3 ++-
 3 files changed, 55 insertions(+), 6 deletions(-)

diff --git a/include/net/udp.h b/include/net/udp.h
index 74c10ec..ef2e0b7 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -183,6 +183,7 @@ extern int udp_sendmsg(struct kiocb *iocb, struct sock *sk,
 			    struct msghdr *msg, size_t len);
 extern int udp_push_pending_frames(struct sock *sk);
 extern void udp_flush_pending_frames(struct sock *sk);
+extern void udp4_hwcsum(struct sk_buff *skb, __be32 src, __be32 dst);
 extern int udp_rcv(struct sk_buff *skb);
 extern int udp_ioctl(struct sock *sk, int cmd, unsigned long arg);
 extern int udp_disconnect(struct sock *sk, int flags);
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 9640972..48cebf2 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -160,6 +160,7 @@
 #include <net/net_namespace.h>
 #include <net/checksum.h>
 #include <net/ipv6.h>
+#include <net/udp.h>
 #include <net/addrconf.h>
 #ifdef CONFIG_XFRM
 #include <net/xfrm.h>
@@ -198,6 +199,7 @@
 #define F_QUEUE_MAP_RND (1<<13)	/* queue map Random */
 #define F_QUEUE_MAP_CPU (1<<14)	/* queue map mirrors smp_processor_id() */
 #define F_NODE          (1<<15)	/* Node memory alloc*/
+#define F_UDPCSUM       (1<<16)	/* Include UDP checksum */
 
 /* Thread control flag bits */
 #define T_STOP        (1<<0)	/* Stop run */
@@ -631,6 +633,9 @@ static int pktgen_if_show(struct seq_file *seq, void *v)
 	if (pkt_dev->flags & F_UDPDST_RND)
 		seq_printf(seq, "UDPDST_RND  ");
 
+	if (pkt_dev->flags & F_UDPCSUM)
+		seq_printf(seq, "UDPCSUM  ");
+
 	if (pkt_dev->flags & F_MPLS_RND)
 		seq_printf(seq,  "MPLS_RND  ");
 
@@ -1228,6 +1233,12 @@ static ssize_t pktgen_if_write(struct file *file,
 		else if (strcmp(f, "!NODE_ALLOC") == 0)
 			pkt_dev->flags &= ~F_NODE;
 
+		else if (strcmp(f, "UDPCSUM") == 0)
+			pkt_dev->flags |= F_UDPCSUM;
+
+		else if (strcmp(f, "!UDPCSUM") == 0)
+			pkt_dev->flags &= ~F_UDPCSUM;
+
 		else {
 			sprintf(pg_result,
 				"Flag -:%s:- unknown\nAvailable flags, (prepend ! to un-set flag):\n%s",
@@ -2733,7 +2744,7 @@ static struct sk_buff *fill_packet_ipv4(struct net_device *odev,
 	udph->source = htons(pkt_dev->cur_udp_src);
 	udph->dest = htons(pkt_dev->cur_udp_dst);
 	udph->len = htons(datalen + 8);	/* DATA + udphdr */
-	udph->check = 0;	/* No checksum */
+	udph->check = 0;
 
 	iph->ihl = 5;
 	iph->version = 4;
@@ -2752,6 +2763,24 @@ static struct sk_buff *fill_packet_ipv4(struct net_device *odev,
 	skb->protocol = protocol;
 	skb->dev = odev;
 	skb->pkt_type = PACKET_HOST;
+
+	if (!(pkt_dev->flags & F_UDPCSUM)) {
+		skb->ip_summed = CHECKSUM_NONE;
+	} else if (odev->features & NETIF_F_V4_CSUM) {
+		skb->ip_summed = CHECKSUM_PARTIAL;
+		skb->csum = 0;
+		udp4_hwcsum(skb, udph->source, udph->dest);
+	} else {
+		__wsum csum = udp_csum(skb);
+
+		/* add protocol-dependent pseudo-header */
+		udph->check = csum_tcpudp_magic(udph->source, udph->dest,
+						datalen + 8, IPPROTO_UDP, csum);
+
+		if (udph->check == 0)
+			udph->check = CSUM_MANGLED_0;
+	}
+
 	pktgen_finalize_skb(pkt_dev, skb, datalen);
 
 #ifdef CONFIG_XFRM
@@ -2768,7 +2797,7 @@ static struct sk_buff *fill_packet_ipv6(struct net_device *odev,
 	struct sk_buff *skb = NULL;
 	__u8 *eth;
 	struct udphdr *udph;
-	int datalen;
+	int datalen, udplen;
 	struct ipv6hdr *iph;
 	__be16 protocol = htons(ETH_P_IPV6);
 	__be32 *mpls;
@@ -2844,10 +2873,11 @@ static struct sk_buff *fill_packet_ipv6(struct net_device *odev,
 		net_info_ratelimited("increased datalen to %d\n", datalen);
 	}
 
+	udplen = datalen + sizeof(struct udphdr);
 	udph->source = htons(pkt_dev->cur_udp_src);
 	udph->dest = htons(pkt_dev->cur_udp_dst);
-	udph->len = htons(datalen + sizeof(struct udphdr));
-	udph->check = 0;	/* No checksum */
+	udph->len = htons(udplen);
+	udph->check = 0;
 
 	*(__be32 *) iph = htonl(0x60000000);	/* Version + flow */
 
@@ -2858,7 +2888,7 @@ static struct sk_buff *fill_packet_ipv6(struct net_device *odev,
 
 	iph->hop_limit = 32;
 
-	iph->payload_len = htons(sizeof(struct udphdr) + datalen);
+	iph->payload_len = htons(udplen);
 	iph->nexthdr = IPPROTO_UDP;
 
 	iph->daddr = pkt_dev->cur_in6_daddr;
@@ -2868,6 +2898,23 @@ static struct sk_buff *fill_packet_ipv6(struct net_device *odev,
 	skb->dev = odev;
 	skb->pkt_type = PACKET_HOST;
 
+	if (!(pkt_dev->flags & F_UDPCSUM)) {
+		skb->ip_summed = CHECKSUM_NONE;
+	} else if (odev->features & NETIF_F_V6_CSUM) {
+		skb->ip_summed = CHECKSUM_PARTIAL;
+		skb->csum_start = skb_transport_header(skb) - skb->head;
+		skb->csum_offset = offsetof(struct udphdr, check);
+		udph->check = ~csum_ipv6_magic(&iph->saddr, &iph->daddr, udplen, IPPROTO_UDP, 0);
+	} else {
+		__wsum csum = udp_csum(skb);
+
+		/* add protocol-dependent pseudo-header */
+		udph->check = csum_ipv6_magic(&iph->saddr, &iph->daddr, udplen, IPPROTO_UDP, csum);
+
+		if (udph->check == 0)
+			udph->check = CSUM_MANGLED_0;
+	}
+
 	pktgen_finalize_skb(pkt_dev, skb, datalen);
 
 	return skb;
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 766e6ba..9e88af0 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -704,7 +704,7 @@ EXPORT_SYMBOL(udp_flush_pending_frames);
  *	@src:	source IP address
  *	@dst:	destination IP address
  */
-static void udp4_hwcsum(struct sk_buff *skb, __be32 src, __be32 dst)
+void udp4_hwcsum(struct sk_buff *skb, __be32 src, __be32 dst)
 {
 	struct udphdr *uh = udp_hdr(skb);
 	struct sk_buff *frags = skb_shinfo(skb)->frag_list;
@@ -740,6 +740,7 @@ static void udp4_hwcsum(struct sk_buff *skb, __be32 src, __be32 dst)
 			uh->check = CSUM_MANGLED_0;
 	}
 }
+EXPORT_SYMBOL_GPL(udp4_hwcsum);
 
 static int udp_send_skb(struct sk_buff *skb, struct flowi4 *fl4)
 {
-- 
1.8.3.1

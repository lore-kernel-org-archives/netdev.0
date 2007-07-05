From: James Chapman <jchapman@katalix.com>
Subject: [PATCH net-2.6.23] UDP: Cleanup UDP encapsulation code
Date: Thu, 5 Jul 2007 15:27:06 +0100
Message-ID: <200707051427.l65ER6iS016766@quickie.katalix.com>
To: derek@ihtfp.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:35928 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757212AbXGEO1u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jul 2007 10:27:50 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This cleanup fell out after adding L2TP support where a new encap_rcv
funcptr was added to struct udp_sock. Have XFRM use the new encap_rcv
funcptr, which allows us to move the XFRM encap code from udp.c into
xfrm4_input.c.

Packets discarded by the encap handler are now counted in
udp_mib_indatagrams. Previously they weren't counted.

Make xfrm4_rcv_encap() static since it is no longer called externally.

Signed-off-by: James Chapman <jchapman@katalix.com>

---
Tested with L2TP and L2TP/IPsec.

The registered UDP encap handler returns <0 when the skb is to be
discarded. Original code from udp_encap_rcv() which returned 0 to have
the skb discarded is changed to return -1 since it is now called via
the encap_rcv funcptr.

 include/net/xfrm.h     |    8 +-
 net/ipv4/udp.c         |  163 +++++++++---------------------------------------
 net/ipv4/xfrm4_input.c |  110 ++++++++++++++++++++++++++++++--
 3 files changed, 136 insertions(+), 145 deletions(-)

12856a34bb084fcbcaeba66bd0069653550652dd
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index d3a898b..da3b468 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1003,7 +1003,7 @@ extern int xfrm6_find_1stfragopt(struct 
 				 u8 **prevhdr);
 
 #ifdef CONFIG_XFRM
-extern int xfrm4_rcv_encap(struct sk_buff *skb, __u16 encap_type);
+extern int xfrm4_udp_encap_rcv(struct sock *sk, struct sk_buff *skb);
 extern int xfrm_user_policy(struct sock *sk, int optname, u8 __user *optval, int optlen);
 extern int xfrm_dst_lookup(struct xfrm_dst **dst, struct flowi *fl, unsigned short family);
 #else
@@ -1012,12 +1012,12 @@ static inline int xfrm_user_policy(struc
  	return -ENOPROTOOPT;
 } 
 
-static inline int xfrm4_rcv_encap(struct sk_buff *skb, __u16 encap_type)
+static inline int xfrm4_udp_encap_rcv(struct sock *sk, struct sk_buff *skb)
 {
  	/* should not happen */
- 	kfree_skb(skb);
-	return 0;
+	return -1;
 }
+
 static inline int xfrm_dst_lookup(struct xfrm_dst **dst, struct flowi *fl, unsigned short family)
 {
 	return -EINVAL;
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index b9276f8..777d5e8 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -70,7 +70,8 @@
  *	Alexey Kuznetsov:		allow both IPv4 and IPv6 sockets to bind
  *					a single port at the same time.
  *	Derek Atkins <derek@ihtfp.com>: Add Encapulation Support
- *	James Chapman		:	Add L2TP encapsulation type.
+ *	James Chapman		:	Use socket's encap_rcv for all encapsulated
+ *					protocols..
  *
  *
  *		This program is free software; you can redistribute it and/or
@@ -920,108 +921,6 @@ int udp_disconnect(struct sock *sk, int 
 	return 0;
 }
 
-/* return:
- * 	1  if the UDP system should process it
- *	0  if we should drop this packet
- * 	-1 if it should get processed by xfrm4_rcv_encap
- *	-2 if it should get processed by l2tp
- */
-static int udp_encap_rcv(struct sock * sk, struct sk_buff *skb)
-{
-	struct udp_sock *up = udp_sk(sk);
-	struct udphdr *uh;
-	struct iphdr *iph;
-	int iphlen, len;
-
-	__u8 *udpdata;
-	__be32 *udpdata32;
-	__u16 encap_type = up->encap_type;
-
-	/* if we're overly short, let UDP handle it */
-	len = skb->len - sizeof(struct udphdr);
-	if (len <= 0)
-		return 1;
-
-	/* if this is not encapsulated socket, then just return now */
-	if (!encap_type)
-		return 1;
-
-	/* If this is a paged skb, make sure we pull up
-	 * whatever data we need to look at. */
-	if (!pskb_may_pull(skb, sizeof(struct udphdr) + min(len, 8)))
-		return 1;
-
-	/* Now we can get the pointers */
-	uh = udp_hdr(skb);
-	udpdata = (__u8 *)uh + sizeof(struct udphdr);
-	udpdata32 = (__be32 *)udpdata;
-
-	switch (encap_type) {
-	default:
-	case UDP_ENCAP_ESPINUDP:
-		/* Check if this is a keepalive packet.  If so, eat it. */
-		if (len == 1 && udpdata[0] == 0xff) {
-			return 0;
-		} else if (len > sizeof(struct ip_esp_hdr) && udpdata32[0] != 0) {
-			/* ESP Packet without Non-ESP header */
-			len = sizeof(struct udphdr);
-		} else
-			/* Must be an IKE packet.. pass it through */
-			return 1;
-		break;
-	case UDP_ENCAP_ESPINUDP_NON_IKE:
-		/* Check if this is a keepalive packet.  If so, eat it. */
-		if (len == 1 && udpdata[0] == 0xff) {
-			return 0;
-		} else if (len > 2 * sizeof(u32) + sizeof(struct ip_esp_hdr) &&
-			   udpdata32[0] == 0 && udpdata32[1] == 0) {
-
-			/* ESP Packet with Non-IKE marker */
-			len = sizeof(struct udphdr) + 2 * sizeof(u32);
-		} else
-			/* Must be an IKE packet.. pass it through */
-			return 1;
-		break;
-	case UDP_ENCAP_L2TPINUDP:
-		/* Let caller know to send this to l2tp */
-		return -2;
-	}
-
-#ifndef CONFIG_XFRM
-	return 1;
-#else
-	/* At this point we are sure that this is an ESPinUDP packet,
-	 * so we need to remove 'len' bytes from the packet (the UDP
-	 * header and optional ESP marker bytes) and then modify the
-	 * protocol to ESP, and then call into the transform receiver.
-	 */
-	if (skb_cloned(skb) && pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
-		return 0;
-
-	/* Now we can update and verify the packet length... */
-	iph = ip_hdr(skb);
-	iphlen = iph->ihl << 2;
-	iph->tot_len = htons(ntohs(iph->tot_len) - len);
-	if (skb->len < iphlen + len) {
-		/* packet is too small!?! */
-		return 0;
-	}
-
-	/* pull the data buffer up to the ESP header and set the
-	 * transport header to point to ESP.  Keep UDP on the stack
-	 * for later.
-	 */
-	__skb_pull(skb, len);
-	skb_reset_transport_header(skb);
-
-	/* modify the protocol (it's ESP!) */
-	iph->protocol = IPPROTO_ESP;
-
-	/* and let the caller know to send this into the ESP processor... */
-	return -1;
-#endif
-}
-
 /* returns:
  *  -1: error
  *   0: success
@@ -1044,44 +943,39 @@ int udp_queue_rcv_skb(struct sock * sk, 
 
 	if (up->encap_type) {
 		/*
-		 * This is an encapsulation socket, so let's see if this is
-		 * an encapsulated packet.
-		 * If it's a keepalive packet, then just eat it.
-		 * If it's an encapsulateed packet, then pass it to the
-		 * IPsec xfrm input and return the response
-		 * appropriately.  Otherwise, just fall through and
-		 * pass this up the UDP socket.
+		 * This is an encapsulation socket so pass the skb to
+		 * the socket's udp_encap_rcv() hook. Otherwise, just
+		 * fall through and pass this up the UDP socket.
+		 * up->encap_rcv() returns the following value:
+		 * =0 if skb was successfully passed to the encap
+		 *    handler or was discarded by it.
+		 * >0 if skb should be passed on to UDP.
+		 * <0 if error detected. skb is _not_ freed.
 		 */
-		int ret;
-
-		ret = udp_encap_rcv(sk, skb);
-		if (ret == 0) {
-			/* Eat the packet .. */
-			kfree_skb(skb);
-			return 0;
-		}
-		if (ret == -1) {
-			/* process the ESP packet */
-			ret = xfrm4_rcv_encap(skb, up->encap_type);
-			UDP_INC_STATS_BH(UDP_MIB_INDATAGRAMS, up->pcflag);
-			return -ret;
-		}
-		if (ret == -2) {
-			/* process the L2TP packet */
-			if (up->encap_rcv != NULL) {
-				ret = (*up->encap_rcv)(sk, skb);
-				if (ret <= 0) {
-					UDP_INC_STATS_BH(UDP_MIB_INDATAGRAMS, up->pcflag);
-					return ret;
-				}
+		unsigned int len;
 
-				/* FALLTHROUGH -- pass up as UDP packet */
+		/* if we're overly short, let UDP handle it */
+		len = skb->len - sizeof(struct udphdr);
+		if (len <= 0)
+			goto udp;
+
+		if (up->encap_rcv != NULL) {
+			int ret;
+
+			ret = (*up->encap_rcv)(sk, skb);
+			if (ret == 0)
+				goto out;
+			if (ret < 0) {
+				/* Eat the packet .. */
+				kfree_skb(skb);
+				goto out;
 			}
 		}
 
 		/* FALLTHROUGH -- it's a UDP Packet */
 	}
 
+udp:
 	/*
 	 * 	UDP-Lite specific tests, ignored on UDP sockets
 	 */
@@ -1130,6 +1024,7 @@ int udp_queue_rcv_skb(struct sock * sk, 
 		goto drop;
 	}
 
+out:
 	UDP_INC_STATS_BH(UDP_MIB_INDATAGRAMS, up->pcflag);
 	return 0;
 
@@ -1367,6 +1262,8 @@ int udp_lib_setsockopt(struct sock *sk, 
 		case 0:
 		case UDP_ENCAP_ESPINUDP:
 		case UDP_ENCAP_ESPINUDP_NON_IKE:
+			up->encap_rcv = xfrm4_udp_encap_rcv;
+			/* FALLTHROUGH */
 		case UDP_ENCAP_L2TPINUDP:
 			up->encap_type = val;
 			break;
diff --git a/net/ipv4/xfrm4_input.c b/net/ipv4/xfrm4_input.c
index fa1902d..a5799e4 100644
--- a/net/ipv4/xfrm4_input.c
+++ b/net/ipv4/xfrm4_input.c
@@ -16,13 +16,6 @@
 #include <net/ip.h>
 #include <net/xfrm.h>
 
-int xfrm4_rcv(struct sk_buff *skb)
-{
-	return xfrm4_rcv_encap(skb, 0);
-}
-
-EXPORT_SYMBOL(xfrm4_rcv);
-
 static int xfrm4_parse_spi(struct sk_buff *skb, u8 nexthdr, __be32 *spi, __be32 *seq)
 {
 	switch (nexthdr) {
@@ -53,7 +46,7 @@ drop:
 }
 #endif
 
-int xfrm4_rcv_encap(struct sk_buff *skb, __u16 encap_type)
+static int xfrm4_rcv_encap(struct sk_buff *skb, __u16 encap_type)
 {
 	__be32 spi, seq;
 	struct xfrm_state *xfrm_vec[XFRM_MAX_DEPTH];
@@ -167,3 +160,104 @@ drop:
 	kfree_skb(skb);
 	return 0;
 }
+
+/* If it's a keepalive packet, then just eat it.
+ * If it's an encapsulated packet, then pass it to the
+ * IPsec xfrm input.
+ * Returns 0 if skb passed to xfrm or was dropped.
+ * Returns >0 if skb should be passed to UDP.
+ * Returns <0 if skb should be discarded..
+ */
+int xfrm4_udp_encap_rcv(struct sock *sk, struct sk_buff *skb)
+{
+	struct udp_sock *up = udp_sk(sk);
+	struct udphdr *uh;
+	struct iphdr *iph;
+	int iphlen, len;
+	int ret;
+
+	__u8 *udpdata;
+	__be32 *udpdata32;
+	__u16 encap_type = up->encap_type;
+
+	/* if this is not encapsulated socket, then just return now */
+	if (!encap_type)
+		return 1;
+
+	/* If this is a paged skb, make sure we pull up
+	 * whatever data we need to look at. */
+	len = skb->len - sizeof(struct udphdr);
+	if (!pskb_may_pull(skb, sizeof(struct udphdr) + min(len, 8)))
+		return 1;
+
+	/* Now we can get the pointers */
+	uh = udp_hdr(skb);
+	udpdata = (__u8 *)uh + sizeof(struct udphdr);
+	udpdata32 = (__be32 *)udpdata;
+
+	switch (encap_type) {
+	default:
+	case UDP_ENCAP_ESPINUDP:
+		/* Check if this is a keepalive packet.  If so, eat it. */
+		if (len == 1 && udpdata[0] == 0xff) {
+			return -1;
+		} else if (len > sizeof(struct ip_esp_hdr) && udpdata32[0] != 0) {
+			/* ESP Packet without Non-ESP header */
+			len = sizeof(struct udphdr);
+		} else
+			/* Must be an IKE packet.. pass it through */
+			return 1;
+		break;
+	case UDP_ENCAP_ESPINUDP_NON_IKE:
+		/* Check if this is a keepalive packet.  If so, eat it. */
+		if (len == 1 && udpdata[0] == 0xff) {
+			return -1;
+		} else if (len > 2 * sizeof(u32) + sizeof(struct ip_esp_hdr) &&
+			   udpdata32[0] == 0 && udpdata32[1] == 0) {
+
+			/* ESP Packet with Non-IKE marker */
+			len = sizeof(struct udphdr) + 2 * sizeof(u32);
+		} else
+			/* Must be an IKE packet.. pass it through */
+			return 1;
+		break;
+	}
+
+	/* At this point we are sure that this is an ESPinUDP packet,
+	 * so we need to remove 'len' bytes from the packet (the UDP
+	 * header and optional ESP marker bytes) and then modify the
+	 * protocol to ESP, and then call into the transform receiver.
+	 */
+	if (skb_cloned(skb) && pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
+		return -1;
+
+	/* Now we can update and verify the packet length... */
+	iph = ip_hdr(skb);
+	iphlen = iph->ihl << 2;
+	iph->tot_len = htons(ntohs(iph->tot_len) - len);
+	if (skb->len < iphlen + len) {
+		/* packet is too small!?! */
+		return -1;
+	}
+
+	/* pull the data buffer up to the ESP header and set the
+	 * transport header to point to ESP.  Keep UDP on the stack
+	 * for later.
+	 */
+	__skb_pull(skb, len);
+	skb_reset_transport_header(skb);
+
+	/* modify the protocol (it's ESP!) */
+	iph->protocol = IPPROTO_ESP;
+
+	/* process ESP */
+	ret = xfrm4_rcv_encap(skb, encap_type);
+	return -ret;
+}
+
+int xfrm4_rcv(struct sk_buff *skb)
+{
+	return xfrm4_rcv_encap(skb, 0);
+}
+
+EXPORT_SYMBOL(xfrm4_rcv);

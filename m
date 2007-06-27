From: James Chapman <jchapman@katalix.com>
Subject: [PATCH 1/5 2.6.22-rc6] UDP: Introduce UDP encapsulation type for L2TP
Date: Wed, 27 Jun 2007 23:20:38 +0100
Message-ID: <200706272220.l5RMKc7I004940@quickie.katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:60937 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757641AbXF0WVU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jun 2007 18:21:20 -0400
Received: from jchapman.plus.com ([84.92.108.75] helo=quickie.katalix.com)
	by s36.avahost.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.63)
	(envelope-from <jchapman@katalix.com>)
	id 1I3fk2-00050M-S8
	for netdev@vger.kernel.org; Wed, 27 Jun 2007 17:12:03 -0500
Received: from quickie.katalix.com (quickie.katalix.com [127.0.0.1])
	by quickie.katalix.com (8.13.5/8.13.5) with ESMTP id l5RMKcOl004948
	for <netdev@vger.kernel.org>; Wed, 27 Jun 2007 23:20:38 +0100
Received: (from james@localhost)
	by quickie.katalix.com (8.13.5/8.13.5/Submit) id l5RMKc7I004940
	for netdev@vger.kernel.org; Wed, 27 Jun 2007 23:20:38 +0100
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds a new UDP_ENCAP_L2TPINUDP encapsulation type for UDP
sockets. When a UDP socket's encap_type is UDP_ENCAP_L2TPINUDP, the
skb is delivered to a function pointed to by the udp_sock's
encap_rcv funcptr. If the skb isn't wanted by L2TP, it returns >0, which
causes it to be passed through to UDP.

Include padding to put the new encap_rcv field on a 4-byte boundary.

Previously, the only user of UDP encap sockets was ESP, so when
CONFIG_XFRM was not defined, some of the encap code was compiled 
out. This patch changes that. As a result, udp_encap_rcv() will
now do a little more work when CONFIG_XFRM is not defined. 

Signed-off-by: James Chapman <jchapman@katalix.com>

---

This mechanism could now be used by any protocol encapsulated in UDP
since the encap_rcv funcptr could be set to point to a
protocol-specific encap_rcv function. Should UDP_ENCAP_L2TPINUDP be
something like UDP_ENCAP_GENERICINUDP?

Index: linux-2.6.22-rc6/include/linux/udp.h
===================================================================
--- linux-2.6.22-rc6.orig/include/linux/udp.h
+++ linux-2.6.22-rc6/include/linux/udp.h
@@ -42,6 +42,7 @@ static inline struct udphdr *udp_hdr(con
 /* UDP encapsulation types */
 #define UDP_ENCAP_ESPINUDP_NON_IKE	1 /* draft-ietf-ipsec-nat-t-ike-00/01 */
 #define UDP_ENCAP_ESPINUDP	2 /* draft-ietf-ipsec-udp-encaps-06 */
+#define UDP_ENCAP_L2TPINUDP	3 /* rfc2661 */
 
 #ifdef __KERNEL__
 #include <linux/types.h>
@@ -70,6 +71,11 @@ struct udp_sock {
 #define UDPLITE_SEND_CC  0x2  		/* set via udplite setsockopt         */
 #define UDPLITE_RECV_CC  0x4		/* set via udplite setsocktopt        */
 	__u8		 pcflag;        /* marks socket as UDP-Lite if > 0    */
+	__u8		 unused[3];
+	/*
+	 * For encapsulation sockets.
+	 */
+	int (*encap_rcv)(struct sock *sk, struct sk_buff *skb);
 };
 
 static inline struct udp_sock *udp_sk(const struct sock *sk)
Index: linux-2.6.22-rc6/net/ipv4/udp.c
===================================================================
--- linux-2.6.22-rc6.orig/net/ipv4/udp.c
+++ linux-2.6.22-rc6/net/ipv4/udp.c
@@ -70,6 +70,7 @@
  *	Alexey Kuznetsov:		allow both IPv4 and IPv6 sockets to bind
  *					a single port at the same time.
  *	Derek Atkins <derek@ihtfp.com>: Add Encapulation Support
+ *	James Chapman		:	Add L2TP encapsulation type.
  *
  *
  *		This program is free software; you can redistribute it and/or
@@ -923,12 +924,10 @@ int udp_disconnect(struct sock *sk, int 
  * 	1  if the UDP system should process it
  *	0  if we should drop this packet
  * 	-1 if it should get processed by xfrm4_rcv_encap
+ *	-2 if it should get processed by l2tp
  */
 static int udp_encap_rcv(struct sock * sk, struct sk_buff *skb)
 {
-#ifndef CONFIG_XFRM
-	return 1;
-#else
 	struct udp_sock *up = udp_sk(sk);
 	struct udphdr *uh;
 	struct iphdr *iph;
@@ -983,8 +982,14 @@ static int udp_encap_rcv(struct sock * s
 			/* Must be an IKE packet.. pass it through */
 			return 1;
 		break;
+	case UDP_ENCAP_L2TPINUDP:
+		/* Let caller know to send this to l2tp */
+		return -2;
 	}
 
+#ifndef CONFIG_XFRM
+	return 1;
+#else
 	/* At this point we are sure that this is an ESPinUDP packet,
 	 * so we need to remove 'len' bytes from the packet (the UDP
 	 * header and optional ESP marker bytes) and then modify the
@@ -1055,12 +1060,25 @@ int udp_queue_rcv_skb(struct sock * sk, 
 			kfree_skb(skb);
 			return 0;
 		}
-		if (ret < 0) {
+		if (ret == -1) {
 			/* process the ESP packet */
 			ret = xfrm4_rcv_encap(skb, up->encap_type);
 			UDP_INC_STATS_BH(UDP_MIB_INDATAGRAMS, up->pcflag);
 			return -ret;
 		}
+		if (ret == -2) {
+			/* process the L2TP packet */
+			if (up->encap_rcv != NULL) {
+				ret = (*up->encap_rcv)(sk, skb);
+				if (ret <= 0) {
+					UDP_INC_STATS_BH(UDP_MIB_INDATAGRAMS, up->pcflag);
+					return ret;
+				}
+
+				/* FALLTHROUGH -- pass up as UDP packet */
+			}
+		}
+
 		/* FALLTHROUGH -- it's a UDP Packet */
 	}
 
@@ -1349,6 +1367,7 @@ int udp_lib_setsockopt(struct sock *sk, 
 		case 0:
 		case UDP_ENCAP_ESPINUDP:
 		case UDP_ENCAP_ESPINUDP_NON_IKE:
+		case UDP_ENCAP_L2TPINUDP:
 			up->encap_type = val;
 			break;
 		default:

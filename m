From: James Chapman <jchapman@katalix.com>
Subject: [PATCH 1/5 2.6.21] UDP: Introduce UDP encapsulation type for L2TP
Date: Mon, 30 Apr 2007 10:52:01 +0100
Message-ID: <200704300952.l3U9q1kD031844@quickie.katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:42313 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031518AbXD3Jwn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Apr 2007 05:52:43 -0400
Received: from jchapman.plus.com ([84.92.108.75] helo=quickie.katalix.com)
	by s36.avahost.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.63)
	(envelope-from <jchapman@katalix.com>)
	id 1HiSYj-0006EW-Iu
	for netdev@vger.kernel.org; Mon, 30 Apr 2007 04:52:42 -0500
Received: from quickie.katalix.com (quickie.katalix.com [127.0.0.1])
	by quickie.katalix.com (8.13.5/8.13.5) with ESMTP id l3U9q1uK031856
	for <netdev@vger.kernel.org>; Mon, 30 Apr 2007 10:52:01 +0100
Received: (from james@localhost)
	by quickie.katalix.com (8.13.5/8.13.5/Submit) id l3U9q1kD031844
	for netdev@vger.kernel.org; Mon, 30 Apr 2007 10:52:01 +0100
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds a new UDP_ENCAP_L2TPINUDP encapsulation type for UDP
sockets. When a UDP socket's encap_type is UDP_ENCAP_L2TPINUDP, the
skb is delivered to a function pointed to by udp_encap_l2tp_rcv. If
the skb isn't wanted by L2TP, it returns >0, which causes it to be
passed through to UDP. A funcptr is used for udp_encap_l2tp_rcv to 
allow L2TP to be implemented as a kernel module.

Previously, the only user of UDP encap sockets was ESP, so when
CONFIG_XFRM was not defined, some of the encap code was compiled 
out. This patch changes that. As a result, udp_encap_rcv() will
now do a little more work when CONFIG_XFRM is not defined. 

Signed-off-by: James Chapman <jchapman@katalix.com>

---
There are some magic numbers returned by udp_encap_rcv() that
should perhaps now be made #defines. I chose not to do so in
this patch.

Index: linux-2.6.21/include/linux/udp.h
===================================================================
--- linux-2.6.21.orig/include/linux/udp.h
+++ linux-2.6.21/include/linux/udp.h
@@ -33,6 +33,7 @@ struct udphdr {
 /* UDP encapsulation types */
 #define UDP_ENCAP_ESPINUDP_NON_IKE	1 /* draft-ietf-ipsec-nat-t-ike-00/01 */
 #define UDP_ENCAP_ESPINUDP	2 /* draft-ietf-ipsec-udp-encaps-06 */
+#define UDP_ENCAP_L2TPINUDP	3 /* rfc2661 */
 
 #ifdef __KERNEL__
 #include <linux/types.h>
@@ -69,6 +70,8 @@ static inline struct udp_sock *udp_sk(co
 }
 #define IS_UDPLITE(__sk) (udp_sk(__sk)->pcflag)
 
+extern int (*udp_encap_l2tp_rcv)(struct sock *sk, struct sk_buff *skb);
+
 #endif
 
 #endif	/* _LINUX_UDP_H */
Index: linux-2.6.21/net/ipv4/udp.c
===================================================================
--- linux-2.6.21.orig/net/ipv4/udp.c
+++ linux-2.6.21/net/ipv4/udp.c
@@ -70,6 +70,7 @@
  *	Alexey Kuznetsov:		allow both IPv4 and IPv6 sockets to bind
  *					a single port at the same time.
  *	Derek Atkins <derek@ihtfp.com>: Add Encapulation Support
+ *	James Chapman		:	Add L2TP encapsulation type.
  *
  *
  *		This program is free software; you can redistribute it and/or
@@ -112,6 +113,12 @@ DEFINE_SNMP_STAT(struct udp_mib, udp_sta
 struct hlist_head udp_hash[UDP_HTABLE_SIZE];
 DEFINE_RWLOCK(udp_hash_lock);
 
+/* For use by L2TP protocol code (encap_type==UDP_ENCAP_L2TPINUDP).
+ * Using function pointers allows L2TP to be implemented as a
+ * module.
+ */
+int (*udp_encap_l2tp_rcv)(struct sock *sk, struct sk_buff *skb);
+
 static int udp_port_rover;
 
 static inline int __udp_lib_lport_inuse(__u16 num, struct hlist_head udptable[])
@@ -919,12 +926,10 @@ int udp_disconnect(struct sock *sk, int 
  * 	1  if the the UDP system should process it
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
@@ -979,8 +984,14 @@ static int udp_encap_rcv(struct sock * s
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
@@ -1050,12 +1061,25 @@ int udp_queue_rcv_skb(struct sock * sk, 
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
+			if (udp_encap_l2tp_rcv != NULL) {
+				ret = (*udp_encap_l2tp_rcv)(sk, skb);
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
 
@@ -1336,6 +1360,7 @@ int udp_lib_setsockopt(struct sock *sk, 
 		case 0:
 		case UDP_ENCAP_ESPINUDP:
 		case UDP_ENCAP_ESPINUDP_NON_IKE:
+		case UDP_ENCAP_L2TPINUDP:
 			up->encap_type = val;
 			break;
 		default:
@@ -1729,6 +1754,8 @@ EXPORT_SYMBOL(udp_lib_getsockopt);
 EXPORT_SYMBOL(udp_lib_setsockopt);
 EXPORT_SYMBOL(udp_poll);
 
+EXPORT_SYMBOL(udp_encap_l2tp_rcv);
+
 #ifdef CONFIG_PROC_FS
 EXPORT_SYMBOL(udp_proc_register);
 EXPORT_SYMBOL(udp_proc_unregister);

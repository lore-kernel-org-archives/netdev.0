From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [RFC PATCH net-next 2/2] udp: add sk opt to allow sending pkt with src 0.0.0.0
Date: Sat,  9 Nov 2013 01:54:34 +0100
Message-ID: <1383958474-6255-2-git-send-email-nicolas.dichtel@6wind.com>
References: <20131105205744.GK8832@order.stressinduktion.org>
 <1383958474-6255-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	David.Laight@ACULAB.COM, jiri@resnulli.us, vyasevich@gmail.com,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, thaller@redhat.com, stephen@networkplumber.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:35049 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756220Ab3KIAyp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 19:54:45 -0500
In-Reply-To: <1383958474-6255-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This feature allows to a send packets with address source set to 0.0.0.0 even if
an ip address is available on another interface.

It's useful for DHCP client, to allow them to use UDP sockets and be compliant
with the RFC2131, Section 4.1:

4.1 Constructing and sending DHCP messages
...
   DHCP messages broadcast by a client prior to that client obtaining
   its IP address must have the source address field in the IP header
   set to 0.

Based on a previous work from
Guillaume Gaudonville <guillaume.gaudonville@6wind.com>.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/linux/udp.h      |  3 ++-
 include/uapi/linux/udp.h |  1 +
 net/ipv4/udp.c           | 21 +++++++++++++++++++++
 3 files changed, 24 insertions(+), 1 deletion(-)

diff --git a/include/linux/udp.h b/include/linux/udp.h
index 42278bbf7a88..ca947206f0fe 100644
--- a/include/linux/udp.h
+++ b/include/linux/udp.h
@@ -63,7 +63,8 @@ struct udp_sock {
 #define UDPLITE_SEND_CC  0x2  		/* set via udplite setsockopt         */
 #define UDPLITE_RECV_CC  0x4		/* set via udplite setsocktopt        */
 	__u8		 pcflag;        /* marks socket as UDP-Lite if > 0    */
-	__u8		 unused[3];
+	__u8		 src_any:1;	/* saddr to 0 when no IP is available */
+	__u8		 unused[2];
 	/*
 	 * For encapsulation sockets.
 	 */
diff --git a/include/uapi/linux/udp.h b/include/uapi/linux/udp.h
index e2bcfd75a30d..daf4a48face1 100644
--- a/include/uapi/linux/udp.h
+++ b/include/uapi/linux/udp.h
@@ -29,6 +29,7 @@ struct udphdr {
 /* UDP socket options */
 #define UDP_CORK	1	/* Never send partially complete segments */
 #define UDP_ENCAP	100	/* Set the socket to accept encapsulated packets */
+#define UDP_SRC_ANY	101	/* Set src addr to 0 when no IP is available */
 
 /* UDP encapsulation types */
 #define UDP_ENCAP_ESPINUDP_NON_IKE	1 /* draft-ietf-ipsec-nat-t-ike-00/01 */
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 89909dd730dd..f58945187dbd 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -111,6 +111,7 @@
 #include <linux/static_key.h>
 #include <trace/events/skb.h>
 #include <net/busy_poll.h>
+#include <linux/inetdevice.h>
 #include "udp_impl.h"
 
 struct udp_table udp_table __read_mostly;
@@ -1015,6 +1016,18 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		goto do_confirm;
 back_from_confirm:
 
+	if (up->src_any && sk->sk_bound_dev_if) {
+		struct net_device *dev;
+		struct in_device *in_dev;
+
+		rcu_read_lock();
+		dev = dev_get_by_index_rcu(sock_net(sk), sk->sk_bound_dev_if);
+		in_dev = dev ? __in_dev_get_rcu(dev) : NULL;
+		if (!inet_confirm_addr(sock_net(sk), in_dev, 0, 0,
+				       RT_SCOPE_HOST))
+			fl4->saddr = 0;
+		rcu_read_unlock();
+	}
 	saddr = fl4->saddr;
 	if (!ipc.addr)
 		daddr = ipc.addr = fl4->daddr;
@@ -2045,6 +2058,10 @@ int udp_lib_setsockopt(struct sock *sk, int level, int optname,
 		up->pcflag |= UDPLITE_RECV_CC;
 		break;
 
+	case UDP_SRC_ANY:
+		up->src_any = val ? 1 : 0;
+		break;
+
 	default:
 		err = -ENOPROTOOPT;
 		break;
@@ -2107,6 +2124,10 @@ int udp_lib_getsockopt(struct sock *sk, int level, int optname,
 		val = up->pcrlen;
 		break;
 
+	case UDP_SRC_ANY:
+		val = up->src_any;
+		break;
+
 	default:
 		return -ENOPROTOOPT;
 	}
-- 
1.8.4.1

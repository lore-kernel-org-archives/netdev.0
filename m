From: Benjamin LaHaise <bcrl@kvack.org>
Subject: [net-next PATCH 2/2] net/l2tp: add support for L2TP over IPv6 UDP
Date: Tue, 10 Apr 2012 22:21:51 -0400
Message-ID: <20120411022151.GA19150@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:46886 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755716Ab2DKCVw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Apr 2012 22:21:52 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for carrying L2TP frames over UDP on top of IPv6 in
addition to the existing UDP on IPv4.  Support has been tested with both hw
accelerated ethernet drivers, as well as dumb interfaces.

Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>
---
 include/linux/if_pppol2tp.h |   28 ++++++++++++++-
 include/linux/if_pppox.h    |   12 ++++++
 net/l2tp/l2tp_core.c        |   84 ++++++++++++++++++++++++++++++++++++------
 net/l2tp/l2tp_ppp.c         |   42 +++++++++++++++++++++-
 4 files changed, 152 insertions(+), 14 deletions(-)

diff --git a/include/linux/if_pppol2tp.h b/include/linux/if_pppol2tp.h
index 23cefa1..b477541 100644
--- a/include/linux/if_pppol2tp.h
+++ b/include/linux/if_pppol2tp.h
@@ -19,10 +19,11 @@
 
 #ifdef __KERNEL__
 #include <linux/in.h>
+#include <linux/in6.h>
 #endif
 
 /* Structure used to connect() the socket to a particular tunnel UDP
- * socket.
+ * socket over IPv4.
  */
 struct pppol2tp_addr {
 	__kernel_pid_t	pid;		/* pid that owns the fd.
@@ -35,6 +36,20 @@ struct pppol2tp_addr {
 	__u16 d_tunnel, d_session;	/* For sending outgoing packets */
 };
 
+/* Structure used to connect() the socket to a particular tunnel UDP
+ * socket over IPv6.
+ */
+struct pppol2tpin6_addr {
+	__kernel_pid_t	pid;		/* pid that owns the fd.
+					 * 0 => current */
+	int	fd;			/* FD of UDP socket to use */
+
+	__u16 s_tunnel, s_session;	/* For matching incoming packets */
+	__u16 d_tunnel, d_session;	/* For sending outgoing packets */
+
+	struct sockaddr_in6 addr;	/* IP address and port to send to */
+};
+
 /* The L2TPv3 protocol changes tunnel and session ids from 16 to 32
  * bits. So we need a different sockaddr structure.
  */
@@ -49,6 +64,17 @@ struct pppol2tpv3_addr {
 	__u32 d_tunnel, d_session;	/* For sending outgoing packets */
 };
 
+struct pppol2tpv3in6_addr {
+	__kernel_pid_t	pid;		/* pid that owns the fd.
+					 * 0 => current */
+	int	fd;			/* FD of UDP or IP socket to use */
+
+	__u32 s_tunnel, s_session;	/* For matching incoming packets */
+	__u32 d_tunnel, d_session;	/* For sending outgoing packets */
+
+	struct sockaddr_in6 addr;	/* IP address and port to send to */
+};
+
 /* Socket options:
  * DEBUG	- bitmask of debug message categories
  * SENDSEQ	- 0 => don't send packets with sequence numbers
diff --git a/include/linux/if_pppox.h b/include/linux/if_pppox.h
index b5f927f..6720d57 100644
--- a/include/linux/if_pppox.h
+++ b/include/linux/if_pppox.h
@@ -83,6 +83,12 @@ struct sockaddr_pppol2tp {
 	struct pppol2tp_addr pppol2tp;
 } __attribute__((packed));
 
+struct sockaddr_pppol2tpin6 {
+	__kernel_sa_family_t sa_family; /* address family, AF_PPPOX */
+	unsigned int    sa_protocol;    /* protocol identifier */
+	struct pppol2tpin6_addr pppol2tp;
+} __attribute__((packed));
+
 /* The L2TPv3 protocol changes tunnel and session ids from 16 to 32
  * bits. So we need a different sockaddr structure.
  */
@@ -92,6 +98,12 @@ struct sockaddr_pppol2tpv3 {
 	struct pppol2tpv3_addr pppol2tp;
 } __attribute__((packed));
 
+struct sockaddr_pppol2tpv3in6 {
+	__kernel_sa_family_t sa_family; /* address family, AF_PPPOX */
+	unsigned int    sa_protocol;    /* protocol identifier */
+	struct pppol2tpv3in6_addr pppol2tp;
+} __attribute__((packed));
+
 /*********************************************************************
  *
  * ioctl interface for defining forwarding of connections
diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index 89ff8c6..ef024a4 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -53,6 +53,9 @@
 #include <net/inet_common.h>
 #include <net/xfrm.h>
 #include <net/protocol.h>
+#include <net/inet6_connection_sock.h>
+#include <net/inet_ecn.h>
+#include <net/ip6_route.h>
 
 #include <asm/byteorder.h>
 #include <linux/atomic.h>
@@ -446,21 +449,43 @@ static inline int l2tp_verify_udp_checksum(struct sock *sk,
 {
 	struct udphdr *uh = udp_hdr(skb);
 	u16 ulen = ntohs(uh->len);
-	struct inet_sock *inet;
 	__wsum psum;
 
-	if (sk->sk_no_check || skb_csum_unnecessary(skb) || !uh->check)
-		return 0;
-
-	inet = inet_sk(sk);
-	psum = csum_tcpudp_nofold(inet->inet_saddr, inet->inet_daddr, ulen,
-				  IPPROTO_UDP, 0);
-
-	if ((skb->ip_summed == CHECKSUM_COMPLETE) &&
-	    !csum_fold(csum_add(psum, skb->csum)))
+	if (sk->sk_no_check || skb_csum_unnecessary(skb))
 		return 0;
 
-	skb->csum = psum;
+#if IS_ENABLED(CONFIG_IPV6)
+	if (sk->sk_family == PF_INET6) {
+		if (!uh->check) {
+			LIMIT_NETDEBUG(KERN_INFO "L2TP: IPv6: checksum is 0\n");
+			return 1;
+		}
+		if ((skb->ip_summed == CHECKSUM_COMPLETE) &&
+		    !csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
+				     &ipv6_hdr(skb)->daddr, ulen,
+				     IPPROTO_UDP, skb->csum)) {
+			skb->ip_summed = CHECKSUM_UNNECESSARY;
+			return 0;
+		}
+		skb->csum = ~csum_unfold(csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
+							 &ipv6_hdr(skb)->daddr,
+							 skb->len, IPPROTO_UDP,
+							 0));
+	} else
+#endif
+	{
+		struct inet_sock *inet;
+		if (!uh->check)
+			return 0;
+		inet = inet_sk(sk);
+		psum = csum_tcpudp_nofold(inet->inet_saddr, inet->inet_daddr,
+					  ulen, IPPROTO_UDP, 0);
+
+		if ((skb->ip_summed == CHECKSUM_COMPLETE) &&
+		    !csum_fold(csum_add(psum, skb->csum)))
+			return 0;
+		skb->csum = psum;
+	}
 
 	return __skb_checksum_complete(skb);
 }
@@ -988,7 +1013,12 @@ static int l2tp_xmit_core(struct l2tp_session *session, struct sk_buff *skb,
 
 	/* Queue the packet to IP for output */
 	skb->local_df = 1;
-	error = ip_queue_xmit(skb, fl);
+#if IS_ENABLED(CONFIG_IPV6)
+	if (skb->sk->sk_family == PF_INET6)
+		error = inet6_csk_xmit(skb, NULL);
+	else
+#endif
+		error = ip_queue_xmit(skb, fl);
 
 	/* Update stats */
 	if (error >= 0) {
@@ -1021,6 +1051,31 @@ static inline void l2tp_skb_set_owner_w(struct sk_buff *skb, struct sock *sk)
 	skb->destructor = l2tp_sock_wfree;
 }
 
+#if IS_ENABLED(CONFIG_IPV6)
+static void l2tp_xmit_ipv6_csum(struct sock *sk, struct sk_buff *skb,
+				int udp_len)
+{
+	struct ipv6_pinfo *np = inet6_sk(sk);
+	struct udphdr *uh = udp_hdr(skb);
+
+	if (!skb_dst(skb) || !skb_dst(skb)->dev ||
+	    !(skb_dst(skb)->dev->features & NETIF_F_IPV6_CSUM)) {
+		skb->ip_summed = CHECKSUM_COMPLETE;
+		skb->csum = skb_checksum(skb, 0, udp_len, 0);
+		uh->check = csum_ipv6_magic(&np->saddr, &np->daddr, udp_len,
+					    IPPROTO_UDP, skb->csum);
+		if (uh->check == 0)
+			uh->check = CSUM_MANGLED_0;
+	} else {
+		skb->ip_summed = CHECKSUM_PARTIAL;
+		skb->csum_start = skb_transport_header(skb) - skb->head;
+		skb->csum_offset = offsetof(struct udphdr, check);
+		uh->check = ~csum_ipv6_magic(&np->saddr, &np->daddr,
+					     udp_len, IPPROTO_UDP, 0);
+	}
+}
+#endif
+
 /* If caller requires the skb to have a ppp header, the header must be
  * inserted in the skb data before calling this function.
  */
@@ -1089,6 +1144,11 @@ int l2tp_xmit_skb(struct l2tp_session *session, struct sk_buff *skb, int hdr_len
 		uh->check = 0;
 
 		/* Calculate UDP checksum if configured to do so */
+#if IS_ENABLED(CONFIG_IPV6)
+		if (sk->sk_family == PF_INET6)
+			l2tp_xmit_ipv6_csum(sk, skb, udp_len);
+		else
+#endif
 		if (sk->sk_no_check == UDP_CSUM_NOXMIT)
 			skb->ip_summed = CHECKSUM_NONE;
 		else if ((skb_dst(skb) && skb_dst(skb)->dev) &&
diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
index 1addd9f..27b9dec 100644
--- a/net/l2tp/l2tp_ppp.c
+++ b/net/l2tp/l2tp_ppp.c
@@ -916,7 +916,7 @@ static int pppol2tp_getname(struct socket *sock, struct sockaddr *uaddr,
 	}
 
 	inet = inet_sk(tunnel->sock);
-	if (tunnel->version == 2) {
+	if ((tunnel->version == 2) && (tunnel->sock->sk_family == AF_INET)) {
 		struct sockaddr_pppol2tp sp;
 		len = sizeof(sp);
 		memset(&sp, 0, len);
@@ -932,6 +932,46 @@ static int pppol2tp_getname(struct socket *sock, struct sockaddr *uaddr,
 		sp.pppol2tp.addr.sin_port = inet->inet_dport;
 		sp.pppol2tp.addr.sin_addr.s_addr = inet->inet_daddr;
 		memcpy(uaddr, &sp, len);
+#if IS_ENABLED(CONFIG_IPV6)
+	} else if ((tunnel->version == 2) &&
+		   (tunnel->sock->sk_family == AF_INET6)) {
+		struct ipv6_pinfo *np = inet6_sk(tunnel->sock);
+		struct sockaddr_pppol2tpin6 sp;
+		len = sizeof(sp);
+		memset(&sp, 0, len);
+		sp.sa_family	= AF_PPPOX;
+		sp.sa_protocol	= PX_PROTO_OL2TP;
+		sp.pppol2tp.fd  = tunnel->fd;
+		sp.pppol2tp.pid = pls->owner;
+		sp.pppol2tp.s_tunnel = tunnel->tunnel_id;
+		sp.pppol2tp.d_tunnel = tunnel->peer_tunnel_id;
+		sp.pppol2tp.s_session = session->session_id;
+		sp.pppol2tp.d_session = session->peer_session_id;
+		sp.pppol2tp.addr.sin6_family = AF_INET6;
+		sp.pppol2tp.addr.sin6_port = inet->inet_dport;
+		memcpy(&sp.pppol2tp.addr.sin6_addr, &np->daddr,
+		       sizeof(np->daddr));
+		memcpy(uaddr, &sp, len);
+	} else if ((tunnel->version == 3) &&
+		   (tunnel->sock->sk_family == AF_INET6)) {
+		struct ipv6_pinfo *np = inet6_sk(tunnel->sock);
+		struct sockaddr_pppol2tpv3in6 sp;
+		len = sizeof(sp);
+		memset(&sp, 0, len);
+		sp.sa_family	= AF_PPPOX;
+		sp.sa_protocol	= PX_PROTO_OL2TP;
+		sp.pppol2tp.fd  = tunnel->fd;
+		sp.pppol2tp.pid = pls->owner;
+		sp.pppol2tp.s_tunnel = tunnel->tunnel_id;
+		sp.pppol2tp.d_tunnel = tunnel->peer_tunnel_id;
+		sp.pppol2tp.s_session = session->session_id;
+		sp.pppol2tp.d_session = session->peer_session_id;
+		sp.pppol2tp.addr.sin6_family = AF_INET6;
+		sp.pppol2tp.addr.sin6_port = inet->inet_dport;
+		memcpy(&sp.pppol2tp.addr.sin6_addr, &np->daddr,
+		       sizeof(np->daddr));
+		memcpy(uaddr, &sp, len);
+#endif
 	} else if (tunnel->version == 3) {
 		struct sockaddr_pppol2tpv3 sp;
 		len = sizeof(sp);
-- 
1.7.4.1


-- 
"Thought is the essence of where you are now."

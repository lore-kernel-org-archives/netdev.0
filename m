From: Benjamin LaHaise <bcrl@kvack.org>
Subject: [v2] Re: [RFC] l2tp/ipv6: support for L2TPv2 over UDP over IPv6
Date: Sun, 18 Mar 2012 23:28:07 -0400
Message-ID: <20120319032807.GD11293@kvack.org>
References: <20120214223112.GB6806@kvack.org> <1329282410.2555.31.camel@edumazet-laptop> <4F3B6C26.4090701@katalix.com> <4F632FB6.9010206@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:41523 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932094Ab2CSD2I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Mar 2012 23:28:08 -0400
Content-Disposition: inline
In-Reply-To: <4F632FB6.9010206@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 16, 2012 at 12:19:02PM +0000, James Chapman wrote:
> Hi Ben,
> 
> Do you have an updated patch to test?

Yes, here's an updated version.  There is still work to do, as I've not 
added IPv6 support to L2TPv3 pseudo-wires yet.  I have managed to test 
this with a couple of VMs as well as on IPv6 checksumming capable hardware, 
and the checksum offloading code works for me.  I'm not sure if the dst 
handling is 100% correct, so close review of this area would be greatly 
appreciated.

A simple test program for wiring pppd up to an L2TP socket that I've used 
for testing is available at http://www.kvack.org/~bcrl/pppol2tp/l2tp_test.c 
(just pass --local=<ip> --remote=<ip> /usr/sbin/pppd nodetach ... to get it 
to run a connection) .  I'm planning on adding support to the Babylon stack 
to use the native Linux L2TP stack, but I just haven't had much time to 
work on this during the last few weeks.  Comments on this version?

		-ben

 include/linux/if_pppol2tp.h |   28 ++++++++++++++
 include/linux/if_pppox.h    |   12 ++++++
 net/ipv6/udp.c              |   31 ++++++++++++++++
 net/l2tp/l2tp_core.c        |   83 +++++++++++++++++++++++++++++++++++++-------
 net/l2tp/l2tp_ppp.c         |   44 ++++++++++++++++++++++-
 5 files changed, 183 insertions(+), 15 deletions(-)
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
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 8c25419..c0faad5 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -515,6 +515,37 @@ int udpv6_queue_rcv_skb(struct sock * sk, struct sk_buff *skb)
 	if (!xfrm6_policy_check(sk, XFRM_POLICY_IN, skb))
 		goto drop;
 
+	if (up->encap_type) {
+		int (*encap_rcv)(struct sock *sk, struct sk_buff *skb);
+
+		/*
+		 * This is an encapsulation socket so pass the skb to
+		 * the socket's udp_encap_rcv() hook. Otherwise, just
+		 * fall through and pass this up the UDP socket.
+		 * up->encap_rcv() returns the following value:
+		 * =0 if skb was successfully passed to the encap
+		 *    handler or was discarded by it.
+		 * >0 if skb should be passed on to UDP.
+		 * <0 if skb should be resubmitted as proto -N
+		 */
+
+		/* if we're overly short, let UDP handle it */
+		encap_rcv = ACCESS_ONCE(up->encap_rcv);
+		if (skb->len > sizeof(struct udphdr) && encap_rcv != NULL) {
+			int ret;
+
+			ret = encap_rcv(sk, skb);
+			if (ret <= 0) {
+				UDP6_INC_STATS_BH(sock_net(sk),
+						  UDP_MIB_INDATAGRAMS,
+						  is_udplite);
+				return -ret;
+			}
+		}
+
+		/* FALLTHROUGH -- it's a UDP Packet */
+	}
+
 	/*
 	 * UDP-Lite specific tests, ignored on UDP sockets (see net/ipv4/udp.c).
 	 */
diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index 89ff8c6..b45f5b4 100644
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
@@ -1021,6 +1051,30 @@ static inline void l2tp_skb_set_owner_w(struct sk_buff *skb, struct sock *sk)
 	skb->destructor = l2tp_sock_wfree;
 }
 
+#if IS_ENABLED(CONFIG_IPV6)
+static void l2tp_xmit_ipv6_csum(struct sock *sk, struct sk_buff *skb, int udp_len)
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
@@ -1089,6 +1143,11 @@ int l2tp_xmit_skb(struct l2tp_session *session, struct sk_buff *skb, int hdr_len
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
index 8a90d75..c871ced 100644
--- a/net/l2tp/l2tp_ppp.c
+++ b/net/l2tp/l2tp_ppp.c
@@ -915,8 +915,8 @@ static int pppol2tp_getname(struct socket *sock, struct sockaddr *uaddr,
 		goto end_put_sess;
 	}
 
-	inet = inet_sk(sk);
-	if (tunnel->version == 2) {
+	inet = inet_sk(tunnel->sock);
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

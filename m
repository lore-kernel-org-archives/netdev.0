From: Benjamin LaHaise <bcrl@kvack.org>
Subject: [RFC] l2tp/ipv6: support for L2TPv2 over UDP over IPv6
Date: Tue, 14 Feb 2012 17:31:12 -0500
Message-ID: <20120214223112.GB6806@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: James Chapman <jchapman@katalix.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:47749 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932117Ab2BNW7i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Feb 2012 17:59:38 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello folks,

Below is a patch that adds support for L2TPv2 over UDP over IPv6.  It's an 
RFC at present due to 2 outstanding issues: the first is that struct 
pppol2tp_addr and pppol2tpv3_addr have an embedded struct sockaddr_in, and 
these changes have not implemented a replacement of those socket addresses.  
Since the existing pppol2tp{,v3}_addr structures did not place the sockaddr_in 
at the end of the structure, IPv6 addresses cannot be embedded without 
changing the ABI.  The question becomes one of how: just add a version of the 
pppol2tp_addr structure with a sockaddr_in6 embedded in it (easily done, as 
the different in address structures can be detected via sin_family in the 
embedded address), or replace it wholesale with a new pppol2tp_addr that has 
the embedded address at the end of the structure?  That is:

	struct pppol2tp_addr_in6 {
		int			pid;
		int			fd;
		struct sockaddr_in6	addr;
		u16			s_tunnel, s_session;
		u16			d_tunnel, d_session;
	};

or

	struct new_pppol2tp_addr {
		int			pid;
		int			fd;
		u32			s_tunnel, s_session;
		u32			d_tunnel, d_session;
		struct sockaddr_in6	addr;
	};

Thoughts?

The second issue still outstanding is that I still have to test the transmit 
path with IPv6 hardware checksumming.  I've tested with virtio_net and 
pcnet32 with qemu, but would like to verify on real hardware.

This patch works for me as-is by passing in a connected IPv6 socket in the 
fd entry.  If anyone has any comments on the approach to fixing the ABI 
issues, I'll do a fresh spin incorporating whatever approach people are 
comfortable with.  As it stands, I'm leaning towards the first approach 
and keeping the existing socket addresses for IPv4 in order to minimise 
ABI distruption.  Cheers,

		-ben
---
 ipv6/udp.c       |   31 ++++++++++++++++++++++++++++
 l2tp/l2tp_core.c |   59 +++++++++++++++++++++++++++++++++++++++++++++++++------
 2 files changed, 84 insertions(+), 6 deletions(-)
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
index 89ff8c6..7473ae8 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -53,6 +53,7 @@
 #include <net/inet_common.h>
 #include <net/xfrm.h>
 #include <net/protocol.h>
+#include <net/inet6_connection_sock.h>
 
 #include <asm/byteorder.h>
 #include <linux/atomic.h>
@@ -446,15 +447,26 @@ static inline int l2tp_verify_udp_checksum(struct sock *sk,
 {
 	struct udphdr *uh = udp_hdr(skb);
 	u16 ulen = ntohs(uh->len);
-	struct inet_sock *inet;
 	__wsum psum;
 
-	if (sk->sk_no_check || skb_csum_unnecessary(skb) || !uh->check)
+	if (sk->sk_no_check || skb_csum_unnecessary(skb))
 		return 0;
 
-	inet = inet_sk(sk);
-	psum = csum_tcpudp_nofold(inet->inet_saddr, inet->inet_daddr, ulen,
-				  IPPROTO_UDP, 0);
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	if (sk->sk_family == PF_INET6) {
+		psum = csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
+				       &ipv6_hdr(skb)->daddr, ulen,
+				       IPPROTO_UDP, 0);
+	} else
+#endif
+	{
+		struct inet_sock *inet;
+		if (!uh->check)
+			return 0;
+		inet = inet_sk(sk);
+		psum = csum_tcpudp_nofold(inet->inet_saddr, inet->inet_daddr,
+					  ulen, IPPROTO_UDP, 0);
+	}
 
 	if ((skb->ip_summed == CHECKSUM_COMPLETE) &&
 	    !csum_fold(csum_add(psum, skb->csum)))
@@ -988,7 +1000,12 @@ static int l2tp_xmit_core(struct l2tp_session *session, struct sk_buff *skb,
 
 	/* Queue the packet to IP for output */
 	skb->local_df = 1;
-	error = ip_queue_xmit(skb, fl);
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	if (skb->sk->sk_family == PF_INET6)
+		error = inet6_csk_xmit(skb, NULL);
+	else
+#endif
+		error = ip_queue_xmit(skb, fl);
 
 	/* Update stats */
 	if (error >= 0) {
@@ -1021,6 +1038,31 @@ static inline void l2tp_skb_set_owner_w(struct sk_buff *skb, struct sock *sk)
 	skb->destructor = l2tp_sock_wfree;
 }
 
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+static void l2tp_xmit_ipv6_csum(struct sock *sk, struct sk_buff *skb, int udp_len)
+{
+	struct ipv6_pinfo *np = inet6_sk(sk);
+	struct udphdr *uh = udp_hdr(skb);
+
+	if (skb_dst(skb) && skb_dst(skb)->dev &&
+	    (!(skb_dst(skb)->dev->features & NETIF_F_V6_CSUM))) {
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
+		uh->check = csum_ipv6_magic(&np->saddr, &np->daddr,
+					    udp_len, IPPROTO_UDP, 0);
+	}
+
+}
+#endif
+
 /* If caller requires the skb to have a ppp header, the header must be
  * inserted in the skb data before calling this function.
  */
@@ -1089,6 +1131,11 @@ int l2tp_xmit_skb(struct l2tp_session *session, struct sk_buff *skb, int hdr_len
 		uh->check = 0;
 
 		/* Calculate UDP checksum if configured to do so */
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+		if (sk->sk_family == PF_INET6)
+			l2tp_xmit_ipv6_csum(sk, skb, udp_len);
+		else
+#endif
 		if (sk->sk_no_check == UDP_CSUM_NOXMIT)
 			skb->ip_summed = CHECKSUM_NONE;
 		else if ((skb_dst(skb) && skb_dst(skb)->dev) &&

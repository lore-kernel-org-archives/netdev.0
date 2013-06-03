From: Tom Parkin <tparkin@katalix.com>
Subject: [PATCH] l2tp: avoid checksum offload for fragmented packets
Date: Mon,  3 Jun 2013 08:49:22 +0100
Message-ID: <1370245762-5126-2-git-send-email-tparkin@katalix.com>
References: <1370245762-5126-1-git-send-email-tparkin@katalix.com>
Cc: jchapman@katalix.com, Tom Parkin <tparkin@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:41175 "EHLO bert.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752818Ab3FCHtd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jun 2013 03:49:33 -0400
In-Reply-To: <1370245762-5126-1-git-send-email-tparkin@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hardware offload for UDP datagram checksum calculation doesn't work with
fragmented IP packets -- the device will note the fragmentation and leave the
UDP checksum well alone.

As such, if we expect the L2TP packet to be fragmented by the IP layer we need
to perform the UDP checksum ourselves in software (ref: net/ipv4/udp.c).

This change modifies the L2TP xmit path to fallback to software checksum
calculation if the L2TP packet + IP header exceeds the tunnel device MTU.

Signed-off-by: Tom Parkin <tparkin@katalix.com>
Signed-off-by: James Chapman <jchapman@katalix.com>
---
 net/l2tp/l2tp_core.c |   65 +++++++++++++++++++++++++++++++++++---------------
 1 file changed, 46 insertions(+), 19 deletions(-)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index 6984c3a..2b08920 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -1114,9 +1114,18 @@ static void l2tp_xmit_ipv6_csum(struct sock *sk, struct sk_buff *skb,
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct udphdr *uh = udp_hdr(skb);
+	struct ipv6_txoptions *opt = np->opt;
+	size_t ip6hlen;
+
+	ip6hlen = sizeof(struct ipv6hdr);
+	if (opt)
+		ip6hlen += opt->opt_nflen + opt->opt_flen;
+	if (skb_dst(skb) && skb_dst(skb)->dev)
+		ip6hlen += LL_RESERVED_SPACE(skb_dst(skb)->dev);
 
 	if (!skb_dst(skb) || !skb_dst(skb)->dev ||
-	    !(skb_dst(skb)->dev->features & NETIF_F_IPV6_CSUM)) {
+	    !(skb_dst(skb)->dev->features & NETIF_F_IPV6_CSUM) ||
+	    (udp_len + ip6hlen) > dst_mtu(skb_dst(skb))) {
 		__wsum csum = skb_checksum(skb, 0, udp_len, 0);
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 		uh->check = csum_ipv6_magic(&np->saddr, &np->daddr, udp_len,
@@ -1133,6 +1142,40 @@ static void l2tp_xmit_ipv6_csum(struct sock *sk, struct sk_buff *skb,
 }
 #endif
 
+static void l2tp_xmit_ipv4_csum(struct sock *sk, struct sk_buff *skb,
+				int udp_len)
+{
+	struct udphdr *uh = udp_hdr(skb);
+	struct inet_sock *inet = inet_sk(sk);
+	struct ip_options_rcu *inet_opt;
+	size_t iphlen;
+
+	rcu_read_lock();
+	inet_opt = rcu_dereference(inet->inet_opt);
+	iphlen = sizeof(struct iphdr) + (inet_opt ? inet_opt->opt.optlen : 0);
+	rcu_read_unlock();
+
+	if (!skb_dst(skb) || !skb_dst(skb)->dev ||
+	    !(skb_dst(skb)->dev->features & NETIF_F_V4_CSUM) ||
+	    (udp_len + iphlen) > dst_mtu(skb_dst(skb))) {
+		__wsum csum;
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
+		csum = skb_checksum(skb, 0, udp_len, 0);
+		uh->check = csum_tcpudp_magic(inet->inet_saddr,
+				inet->inet_daddr,
+				udp_len, IPPROTO_UDP, csum);
+		if (uh->check == 0)
+			uh->check = CSUM_MANGLED_0;
+	} else {
+		skb->ip_summed = CHECKSUM_PARTIAL;
+		skb->csum_start = skb_transport_header(skb) - skb->head;
+		skb->csum_offset = offsetof(struct udphdr, check);
+		uh->check = ~csum_tcpudp_magic(inet->inet_saddr,
+				inet->inet_daddr,
+				udp_len, IPPROTO_UDP, 0);
+	}
+}
+
 /* If caller requires the skb to have a ppp header, the header must be
  * inserted in the skb data before calling this function.
  */
@@ -1144,7 +1187,6 @@ int l2tp_xmit_skb(struct l2tp_session *session, struct sk_buff *skb, int hdr_len
 	struct flowi *fl;
 	struct udphdr *uh;
 	struct inet_sock *inet;
-	__wsum csum;
 	int headroom;
 	int uhlen = (tunnel->encap == L2TP_ENCAPTYPE_UDP) ? sizeof(struct udphdr) : 0;
 	int udp_len;
@@ -1204,23 +1246,8 @@ int l2tp_xmit_skb(struct l2tp_session *session, struct sk_buff *skb, int hdr_len
 #endif
 		if (sk->sk_no_check == UDP_CSUM_NOXMIT)
 			skb->ip_summed = CHECKSUM_NONE;
-		else if ((skb_dst(skb) && skb_dst(skb)->dev) &&
-			 (!(skb_dst(skb)->dev->features & NETIF_F_V4_CSUM))) {
-			skb->ip_summed = CHECKSUM_COMPLETE;
-			csum = skb_checksum(skb, 0, udp_len, 0);
-			uh->check = csum_tcpudp_magic(inet->inet_saddr,
-						      inet->inet_daddr,
-						      udp_len, IPPROTO_UDP, csum);
-			if (uh->check == 0)
-				uh->check = CSUM_MANGLED_0;
-		} else {
-			skb->ip_summed = CHECKSUM_PARTIAL;
-			skb->csum_start = skb_transport_header(skb) - skb->head;
-			skb->csum_offset = offsetof(struct udphdr, check);
-			uh->check = ~csum_tcpudp_magic(inet->inet_saddr,
-						       inet->inet_daddr,
-						       udp_len, IPPROTO_UDP, 0);
-		}
+		else
+			l2tp_xmit_ipv4_csum(sk, skb, udp_len);
 		break;
 
 	case L2TP_ENCAPTYPE_IP:
-- 
1.7.9.5

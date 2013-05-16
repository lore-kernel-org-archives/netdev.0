From: Tom Parkin <tparkin@katalix.com>
Subject: [RFC] l2tp: avoid checksum offload for fragmented packets
Date: Thu, 16 May 2013 18:04:20 +0100
Message-ID: <1368723860-22749-2-git-send-email-tparkin@katalix.com>
References: <1368723860-22749-1-git-send-email-tparkin@katalix.com>
Cc: jchapman@katalix.com, Tom Parkin <tparkin@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:40302 "EHLO bert.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752565Ab3EPRE2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 May 2013 13:04:28 -0400
In-Reply-To: <1368723860-22749-1-git-send-email-tparkin@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hardware offload for UDP datagram checksum calculation doesn't work with
fragmented IP packets -- the device will note the fragmentation and leave the
UDP checksum well alone.

As such, if we expect the L2TP packet to be fragmented by the IP layer we need
to perform the UDP checksum ourselves in software (ref: net/ipv4/udp.c).

This change modifies the L2TP xmit path to fallback to software checksum
calculation if the L2TP packet + IP header exceeds the tunnel device MTU.
Since we don't know what the IP header length will be a priori, we assume the
worst-case of 60b.  This will likely result in unnecessary software
checksumming when packet sizes approach the MTU since it's probably not common
to be using the full IP header.

An alternative approach is to mimic UDP and use socket corking to allow us to
pass the skb to the IP layer prior to finally pushing the button on xmit.
This lets IP do his fragmentation before we authorise the packet send,
allowing us to check whether the packet was actually fragmented by IP or not.

Signed-off-by: Tom Parkin <tparkin@katalix.com>
---
 net/l2tp/l2tp_core.c |   53 ++++++++++++++++++++++++++++++--------------------
 1 file changed, 32 insertions(+), 21 deletions(-)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index 6984c3a..bc10658 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -1133,6 +1133,33 @@ static void l2tp_xmit_ipv6_csum(struct sock *sk, struct sk_buff *skb,
 }
 #endif
 
+static void l2tp_xmit_ipv4_csum(struct sock *sk, struct sk_buff *skb,
+				int udp_len)
+{
+	struct inet_sock *inet = inet_sk(sk);
+	struct udphdr *uh = udp_hdr(skb);
+
+	if (!skb_dst(skb) || !skb_dst(skb)->dev ||
+	    !(skb_dst(skb)->dev->features & NETIF_F_V4_CSUM) ||
+	    (udp_len + 60) > dst_mtu(skb_dst(skb))) {
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
@@ -1197,30 +1224,14 @@ int l2tp_xmit_skb(struct l2tp_session *session, struct sk_buff *skb, int hdr_len
 		uh->check = 0;
 
 		/* Calculate UDP checksum if configured to do so */
+		if (sk->sk_no_check == UDP_CSUM_NOXMIT)
+			skb->ip_summed = CHECKSUM_NONE;
 #if IS_ENABLED(CONFIG_IPV6)
-		if (sk->sk_family == PF_INET6)
+		else if (sk->sk_family == PF_INET6)
 			l2tp_xmit_ipv6_csum(sk, skb, udp_len);
-		else
 #endif
-		if (sk->sk_no_check == UDP_CSUM_NOXMIT)
-			skb->ip_summed = CHECKSUM_NONE;
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

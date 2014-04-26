From: Tom Herbert <therbert@google.com>
Subject: [PATCH 8/9 v2] net: Implmement RFC 6936 (zero RX csums for
 UDP/IPv6)
Date: Sat, 26 Apr 2014 14:26:20 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1404261402070.27247@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f73.google.com ([209.85.219.73]:55689 "EHLO
	mail-oa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752474AbaDZV0V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Apr 2014 17:26:21 -0400
Received: by mail-oa0-f73.google.com with SMTP id m1so1161713oag.4
        for <netdev@vger.kernel.org>; Sat, 26 Apr 2014 14:26:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RFC 6936 relaxes the requirement of RFC 2460 that UDP/IPv6 packets which
are received with a zero UDP checksum value must be dropped. RFC 6936
allows zero checksums to support tunnels over UDP.

When sk_no_check is set we allow on a socket we allow a zero IPv6
UDP checksum.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/ipv6/ip6_checksum.c | 19 ++++++++-----------
 net/ipv6/udp.c          | 32 ++++++++++++++++++++++++++++++++
 2 files changed, 40 insertions(+), 11 deletions(-)

diff --git a/net/ipv6/ip6_checksum.c b/net/ipv6/ip6_checksum.c
index c69fe37..ca9262a 100644
--- a/net/ipv6/ip6_checksum.c
+++ b/net/ipv6/ip6_checksum.c
@@ -75,16 +75,13 @@ int udp6_csum_init(struct sk_buff *skb, struct udphdr *uh, int proto)
 			return err;
 	}
 
-	if (uh->check == 0) {
-		/* RFC 2460 section 8.1 says that we SHOULD log
-		   this error. Well, it is reasonable.
-		 */
-		LIMIT_NETDEBUG(KERN_INFO "IPv6: udp checksum is 0 for [%pI6c]:%u->[%pI6c]:%u\n",
-			       &ipv6_hdr(skb)->saddr, ntohs(uh->source),
-			       &ipv6_hdr(skb)->daddr, ntohs(uh->dest));
-		return 1;
-	}
-
-	return skb_checksum_init(skb, IPPROTO_UDP, ip6_compute_pseudo);
+	/*
+	 * To support RFC 6936 (allow zero checksum in UDP/IPV6 for tunnels)
+	 * we accept a checksum of zero here. When we find the socket
+	 * for the UDP packet we'll check if that socket allows zero checksum
+	 * for IPv6 (set by socket option).
+	 */
+	return skb_checksum_init_zero_check(skb, proto, uh->check,
+					   ip6_compute_pseudo);
 }
 EXPORT_SYMBOL(udp6_csum_init);
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 1e586d9..787f9d0 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -760,6 +760,18 @@ static void flush_stack(struct sock **stack, unsigned int count,
 	if (unlikely(skb1))
 		kfree_skb(skb1);
 }
+
+static void udp6_csum_zero_error(struct sk_buff *skb)
+{
+	/*
+	 * RFC 2460 section 8.1 says that we SHOULD log
+	 * this error. Well, it is reasonable.
+	*/
+	LIMIT_NETDEBUG(KERN_INFO "IPv6: udp checksum is 0 for [%pI6c]:%u->[%pI6c]:%u\n",
+		       &ipv6_hdr(skb)->saddr, ntohs(udp_hdr(skb)->source),
+		       &ipv6_hdr(skb)->daddr, ntohs(udp_hdr(skb)->dest));
+}
+
 /*
  * Note: called only from the BH handler context,
  * so we don't need to lock the hashes.
@@ -779,6 +791,16 @@ static int __udp6_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 	dif = inet6_iif(skb);
 	sk = udp_v6_mcast_next(net, sk, uh->dest, daddr, uh->source, saddr, dif);
 	while (sk) {
+		if (!uh->check && !sk->sk_no_check) {
+			/*
+			 * If zero checksum and sk_no_check is not on for
+			 * the socket then skip it.
+			 */
+			sk = udp_v6_mcast_next(net, sk_nulls_next(sk),
+					       uh->dest, daddr,
+					       uh->source, saddr, dif);
+			continue;
+		}
 		stack[count++] = sk;
 		sk = udp_v6_mcast_next(net, sk_nulls_next(sk), uh->dest, daddr,
 				       uh->source, saddr, dif);
@@ -867,6 +889,11 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 	if (sk != NULL) {
 		int ret;
 
+		if (!uh->check && !sk->sk_no_check) {
+			udp6_csum_zero_error(skb);
+			goto csum_error;
+		}
+
 		ret = udpv6_queue_rcv_skb(sk, skb);
 		sock_put(sk);
 
@@ -879,6 +906,11 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 		return 0;
 	}
 
+	if (!uh->check) {
+		udp6_csum_zero_error(skb);
+		goto csum_error;
+	}
+
 	if (!xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb))
 		goto discard;
 
-- 
1.9.1.423.g4596e3a

From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH net-next-2.6 2/5] udpv6: Fix HW checksum support for
 outgoing UFO packets
Date: Thu, 09 Jul 2009 11:09:54 -0700
Message-ID: <1247162994.8649.91.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:55355 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753339AbZGISJ4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jul 2009 14:09:56 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e7.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n69HurPB020590
	for <netdev@vger.kernel.org>; Thu, 9 Jul 2009 13:56:53 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n69I9u3d257466
	for <netdev@vger.kernel.org>; Thu, 9 Jul 2009 14:09:56 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n69I9tMi000853
	for <netdev@vger.kernel.org>; Thu, 9 Jul 2009 14:09:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[PATCH net-next-2.6 2/6] udpv6: Fix HW checksum support for outgoing UFO packets

- add HW checksum support for outgoing large UDP/IPv6 packets destined for
  a UFO enabled device.

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

---
 net/ipv6/udp.c |   48 +++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 47 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 33b59bd..f31b1b9 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -638,6 +638,47 @@ static void udp_v6_flush_pending_frames(struct sock *sk)
 	}
 }
 
+/**
+ * 	udp6_hwcsum_outgoing  -  handle outgoing HW checksumming
+ * 	@sk: 	socket we are sending on
+ * 	@skb: 	sk_buff containing the filled-in UDP header
+ * 	        (checksum field must be zeroed out)
+ */
+static void udp6_hwcsum_outgoing(struct sock *sk, struct sk_buff *skb,
+				 const struct in6_addr *saddr,
+				 const struct in6_addr *daddr, int len)
+{
+	unsigned int offset;
+	struct udphdr *uh = udp_hdr(skb);
+	__wsum csum = 0;
+
+	if (skb_queue_len(&sk->sk_write_queue) == 1) {
+		/* Only one fragment on the socket.  */
+		skb->csum_start = skb_transport_header(skb) - skb->head;
+		skb->csum_offset = offsetof(struct udphdr, check);
+		uh->check = ~csum_ipv6_magic(saddr, daddr, len, IPPROTO_UDP, 0);
+	} else {
+		/*
+		 * HW-checksum won't work as there are two or more
+		 * fragments on the socket so that all csums of sk_buffs
+		 * should be together
+		 */
+		offset = skb_transport_offset(skb);
+		skb->csum = skb_checksum(skb, offset, skb->len - offset, 0);
+
+		skb->ip_summed = CHECKSUM_NONE;
+
+		skb_queue_walk(&sk->sk_write_queue, skb) {
+			csum = csum_add(csum, skb->csum);
+		}
+
+		uh->check = csum_ipv6_magic(saddr, daddr, len, IPPROTO_UDP,
+					    csum);
+		if (uh->check == 0)
+			uh->check = CSUM_MANGLED_0;
+	}
+}
+
 /*
  *	Sending
  */
@@ -668,7 +709,11 @@ static int udp_v6_push_pending_frames(struct sock *sk)
 
 	if (is_udplite)
 		csum = udplite_csum_outgoing(sk, skb);
-	 else
+	else if (skb->ip_summed == CHECKSUM_PARTIAL) { /* UDP hardware csum */
+		udp6_hwcsum_outgoing(sk, skb, &fl->fl6_src, &fl->fl6_dst,
+				     up->len);
+		goto send;
+	} else
 		csum = udp_csum_outgoing(sk, skb);
 
 	/* add protocol-dependent pseudo-header */
@@ -677,6 +722,7 @@ static int udp_v6_push_pending_frames(struct sock *sk)
 	if (uh->check == 0)
 		uh->check = CSUM_MANGLED_0;
 
+send:
 	err = ip6_push_pending_frames(sk);
 out:
 	up->len = 0;



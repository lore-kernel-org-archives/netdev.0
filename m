From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 3/6] udp: Add support for doing checksum unnecessary conversion
Date: Sun, 31 Aug 2014 15:12:43 -0700
Message-ID: <1409523166-9215-4-git-send-email-therbert@google.com>
References: <1409523166-9215-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34200 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752043AbaHaWNV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Aug 2014 18:13:21 -0400
Received: by mail-pa0-f49.google.com with SMTP id kq14so10540132pab.8
        for <netdev@vger.kernel.org>; Sun, 31 Aug 2014 15:13:20 -0700 (PDT)
In-Reply-To: <1409523166-9215-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for doing CHECKSUM_UNNECESSARY to CHECKSUM_COMPLETE
conversion in UDP tunneling path.

In the normal UDP path, we call skb_checksum_try_convert after locating
the UDP socket. The check is that checksum conversion is enabled for
the socket (new flag in UDP socket) and that checksum field is
non-zero.

In the UDP GRO path, we call skb_gro_checksum_try_convert after
checksum is validated and checksum field is non-zero. Since this is
already in GRO we assume that checksum conversion is always wanted.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/udp.h    | 16 +++++++++++++++-
 net/ipv4/udp.c         |  4 ++++
 net/ipv4/udp_offload.c | 25 +++++++++++++++++--------
 net/ipv6/udp.c         |  4 ++++
 net/ipv6/udp_offload.c | 24 +++++++++++++++++-------
 5 files changed, 57 insertions(+), 16 deletions(-)

diff --git a/include/linux/udp.h b/include/linux/udp.h
index 247cfdc..ee32775 100644
--- a/include/linux/udp.h
+++ b/include/linux/udp.h
@@ -49,7 +49,11 @@ struct udp_sock {
 	unsigned int	 corkflag;	/* Cork is required */
 	__u8		 encap_type;	/* Is this an Encapsulation socket? */
 	unsigned char	 no_check6_tx:1,/* Send zero UDP6 checksums on TX? */
-			 no_check6_rx:1;/* Allow zero UDP6 checksums on RX? */
+			 no_check6_rx:1,/* Allow zero UDP6 checksums on RX? */
+			 convert_csum:1;/* On receive, convert checksum
+					 * unnecessary to checksum complete
+					 * if possible.
+					 */
 	/*
 	 * Following member retains the information to create a UDP header
 	 * when the socket is uncorked.
@@ -98,6 +102,16 @@ static inline bool udp_get_no_check6_rx(struct sock *sk)
 	return udp_sk(sk)->no_check6_rx;
 }
 
+static inline void udp_set_convert_csum(struct sock *sk, bool val)
+{
+	udp_sk(sk)->convert_csum = val;
+}
+
+static inline bool udp_get_convert_csum(struct sock *sk)
+{
+	return udp_sk(sk)->convert_csum;
+}
+
 #define udp_portaddr_for_each_entry(__sk, node, list) \
 	hlist_nulls_for_each_entry(__sk, node, list, __sk_common.skc_portaddr_node)
 
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 3549c21..0da3849 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1788,6 +1788,10 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 	if (sk != NULL) {
 		int ret;
 
+		if (udp_sk(sk)->convert_csum && uh->check && !IS_UDPLITE(sk))
+			skb_checksum_try_convert(skb, IPPROTO_UDP, uh->check,
+						 inet_compute_pseudo);
+
 		ret = udp_queue_rcv_skb(sk, skb);
 		sock_put(sk);
 
diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index a6adff9..84e0e05 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -290,16 +290,25 @@ static struct sk_buff **udp4_gro_receive(struct sk_buff **head,
 {
 	struct udphdr *uh = udp_gro_udphdr(skb);
 
-	/* Don't bother verifying checksum if we're going to flush anyway. */
-	if (unlikely(!uh) ||
-	    (!NAPI_GRO_CB(skb)->flush &&
-	     skb_gro_checksum_validate_zero_check(skb, IPPROTO_UDP, uh->check,
-						  inet_gro_compute_pseudo))) {
-		NAPI_GRO_CB(skb)->flush = 1;
-		return NULL;
-	}
+	if (unlikely(!uh))
+		goto flush;
 
+	/* Don't bother verifying checksum if we're going to flush anyway. */
+	if (!NAPI_GRO_CB(skb)->flush)
+		goto skip;
+
+	if (skb_gro_checksum_validate_zero_check(skb, IPPROTO_UDP, uh->check,
+						 inet_gro_compute_pseudo))
+		goto flush;
+	else if (uh->check)
+		skb_gro_checksum_try_convert(skb, IPPROTO_UDP, uh->check,
+					     inet_gro_compute_pseudo);
+skip:
 	return udp_gro_receive(head, skb, uh);
+
+flush:
+	NAPI_GRO_CB(skb)->flush = 1;
+	return NULL;
 }
 
 int udp_gro_complete(struct sk_buff *skb, int nhoff)
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 12fcce8f..f6ba535 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -891,6 +891,10 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 			goto csum_error;
 		}
 
+		if (udp_sk(sk)->convert_csum && uh->check && !IS_UDPLITE(sk))
+			skb_checksum_try_convert(skb, IPPROTO_UDP, uh->check,
+						 ip6_compute_pseudo);
+
 		ret = udpv6_queue_rcv_skb(sk, skb);
 		sock_put(sk);
 
diff --git a/net/ipv6/udp_offload.c b/net/ipv6/udp_offload.c
index b13e377..89cb9a9 100644
--- a/net/ipv6/udp_offload.c
+++ b/net/ipv6/udp_offload.c
@@ -134,16 +134,26 @@ static struct sk_buff **udp6_gro_receive(struct sk_buff **head,
 {
 	struct udphdr *uh = udp_gro_udphdr(skb);
 
+	if (unlikely(!uh))
+		goto flush;
+
 	/* Don't bother verifying checksum if we're going to flush anyway. */
-	if (unlikely(!uh) ||
-	    (!NAPI_GRO_CB(skb)->flush &&
-	     skb_gro_checksum_validate_zero_check(skb, IPPROTO_UDP, uh->check,
-						  ip6_gro_compute_pseudo))) {
-		NAPI_GRO_CB(skb)->flush = 1;
-		return NULL;
-	}
+	if (!NAPI_GRO_CB(skb)->flush)
+		goto skip;
 
+	if (skb_gro_checksum_validate_zero_check(skb, IPPROTO_UDP, uh->check,
+						 ip6_gro_compute_pseudo))
+		goto flush;
+	else if (uh->check)
+		skb_gro_checksum_try_convert(skb, IPPROTO_UDP, uh->check,
+					     ip6_gro_compute_pseudo);
+
+skip:
 	return udp_gro_receive(head, skb, uh);
+
+flush:
+	NAPI_GRO_CB(skb)->flush = 1;
+	return NULL;
 }
 
 int udp6_gro_complete(struct sk_buff *skb, int nhoff)
-- 
2.1.0.rc2.206.gedb03e5

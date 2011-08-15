From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2 2/4] rps: Add flag to skb to indicate rxhash is based on
 L4 tuple
Date: Sun, 14 Aug 2011 22:45:55 -0700 (PDT)
Message-ID: <alpine.DEB.2.00.1108142138100.24814@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:62527 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752034Ab1HOFp7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2011 01:45:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The l4_rxhash flag was added to the skb structure to indicate
that the rxhash value was computed over the 4 tuple for the
packet which includes the port information in the encapsulated
transport packet.  This is used by the stack to preserve the
rxhash value in __skb_rx_tunnel.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/skbuff.h |    5 +++--
 include/net/dst.h      |    9 ++++++++-
 include/net/sock.h     |   15 ++++++++++++---
 net/core/dev.c         |   10 ++++++----
 net/core/skbuff.c      |    1 +
 net/ipv4/tcp_ipv4.c    |    6 +++---
 net/ipv4/udp.c         |    4 ++--
 net/ipv6/tcp_ipv6.c    |    6 +++---
 net/ipv6/udp.c         |    2 +-
 9 files changed, 39 insertions(+), 19 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 7b996ed..f902c33 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -414,6 +414,7 @@ struct sk_buff {
 	__u8			ndisc_nodetype:2;
 #endif
 	__u8			ooo_okay:1;
+	__u8			l4_rxhash:1;
 	kmemcheck_bitfield_end(flags2);
 
 	/* 0/13 bit hole */
@@ -572,11 +573,11 @@ extern unsigned int   skb_find_text(struct sk_buff *skb, unsigned int from,
 				    unsigned int to, struct ts_config *config,
 				    struct ts_state *state);
 
-extern __u32 __skb_get_rxhash(struct sk_buff *skb);
+extern void __skb_get_rxhash(struct sk_buff *skb);
 static inline __u32 skb_get_rxhash(struct sk_buff *skb)
 {
 	if (!skb->rxhash)
-		skb->rxhash = __skb_get_rxhash(skb);
+		__skb_get_rxhash(skb);
 
 	return skb->rxhash;
 }
diff --git a/include/net/dst.h b/include/net/dst.h
index 13d507d..4fb6c43 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -325,7 +325,14 @@ static inline void skb_dst_force(struct sk_buff *skb)
 static inline void __skb_tunnel_rx(struct sk_buff *skb, struct net_device *dev)
 {
 	skb->dev = dev;
-	skb->rxhash = 0;
+
+	/*
+	 * Clear rxhash so that we can recalulate the hash for the
+	 * encapsulated packet, unless we have already determine the hash
+	 * over the L4 4-tuple.
+	 */
+	if (!skb->l4_rxhash)
+		skb->rxhash = 0;
 	skb_set_queue_mapping(skb, 0);
 	skb_dst_drop(skb);
 	nf_reset(skb);
diff --git a/include/net/sock.h b/include/net/sock.h
index 8e4062f..5ac682f 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -686,16 +686,25 @@ static inline void sock_rps_reset_flow(const struct sock *sk)
 #endif
 }
 
-static inline void sock_rps_save_rxhash(struct sock *sk, u32 rxhash)
+static inline void sock_rps_save_rxhash(struct sock *sk,
+					const struct sk_buff *skb)
 {
 #ifdef CONFIG_RPS
-	if (unlikely(sk->sk_rxhash != rxhash)) {
+	if (unlikely(sk->sk_rxhash != skb->rxhash)) {
 		sock_rps_reset_flow(sk);
-		sk->sk_rxhash = rxhash;
+		sk->sk_rxhash = skb->rxhash;
 	}
 #endif
 }
 
+static inline void sock_rps_reset_rxhash(struct sock *sk)
+{
+#ifdef CONFIG_RPS
+	sock_rps_reset_flow(sk);
+	sk->sk_rxhash = 0;
+#endif
+}
+
 #define sk_wait_event(__sk, __timeo, __condition)			\
 	({	int __rc;						\
 		release_sock(__sk);					\
diff --git a/net/core/dev.c b/net/core/dev.c
index 6578d94..e485cb3 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2519,10 +2519,11 @@ static inline void ____napi_schedule(struct softnet_data *sd,
 
 /*
  * __skb_get_rxhash: calculate a flow hash based on src/dst addresses
- * and src/dst port numbers. Returns a non-zero hash number on success
- * and 0 on failure.
+ * and src/dst port numbers.  Sets rxhash in skb to non-zero hash value
+ * on success, zero indicates no valid hash.  Also, sets l4_rxhash in skb
+ * if hash is a canonical 4-tuple hash over transport ports.
  */
-__u32 __skb_get_rxhash(struct sk_buff *skb)
+void __skb_get_rxhash(struct sk_buff *skb)
 {
 	int nhoff, hash = 0, poff;
 	const struct ipv6hdr *ip6;
@@ -2574,6 +2575,7 @@ __u32 __skb_get_rxhash(struct sk_buff *skb)
 			ports.v32 = * (__force u32 *) (skb->data + nhoff);
 			if (ports.v16[1] < ports.v16[0])
 				swap(ports.v16[0], ports.v16[1]);
+			skb->l4_rxhash = 1;
 		}
 	}
 
@@ -2586,7 +2588,7 @@ __u32 __skb_get_rxhash(struct sk_buff *skb)
 		hash = 1;
 
 done:
-	return hash;
+	skb->rxhash = hash;
 }
 EXPORT_SYMBOL(__skb_get_rxhash);
 
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 27002df..edb66f3 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -529,6 +529,7 @@ static void __copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 	new->mac_header		= old->mac_header;
 	skb_dst_copy(new, old);
 	new->rxhash		= old->rxhash;
+	new->l4_rxhash		= old->l4_rxhash;
 #ifdef CONFIG_XFRM
 	new->sp			= secpath_get(old->sp);
 #endif
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 1c12b8e..b3f2611 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1578,7 +1578,7 @@ int tcp_v4_do_rcv(struct sock *sk, struct sk_buff *skb)
 #endif
 
 	if (sk->sk_state == TCP_ESTABLISHED) { /* Fast path */
-		sock_rps_save_rxhash(sk, skb->rxhash);
+		sock_rps_save_rxhash(sk, skb);
 		if (tcp_rcv_established(sk, skb, tcp_hdr(skb), skb->len)) {
 			rsk = sk;
 			goto reset;
@@ -1595,7 +1595,7 @@ int tcp_v4_do_rcv(struct sock *sk, struct sk_buff *skb)
 			goto discard;
 
 		if (nsk != sk) {
-			sock_rps_save_rxhash(nsk, skb->rxhash);
+			sock_rps_save_rxhash(nsk, skb);
 			if (tcp_child_process(sk, nsk, skb)) {
 				rsk = nsk;
 				goto reset;
@@ -1603,7 +1603,7 @@ int tcp_v4_do_rcv(struct sock *sk, struct sk_buff *skb)
 			return 0;
 		}
 	} else
-		sock_rps_save_rxhash(sk, skb->rxhash);
+		sock_rps_save_rxhash(sk, skb);
 
 	if (tcp_rcv_state_process(sk, skb, tcp_hdr(skb), skb->len)) {
 		rsk = sk;
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index c1d5fac..ebaa96b 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1267,7 +1267,7 @@ int udp_disconnect(struct sock *sk, int flags)
 	sk->sk_state = TCP_CLOSE;
 	inet->inet_daddr = 0;
 	inet->inet_dport = 0;
-	sock_rps_save_rxhash(sk, 0);
+	sock_rps_reset_rxhash(sk);
 	sk->sk_bound_dev_if = 0;
 	if (!(sk->sk_userlocks & SOCK_BINDADDR_LOCK))
 		inet_reset_saddr(sk);
@@ -1355,7 +1355,7 @@ static int __udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 	int rc;
 
 	if (inet_sk(sk)->inet_daddr)
-		sock_rps_save_rxhash(sk, skb->rxhash);
+		sock_rps_save_rxhash(sk, skb);
 
 	rc = ip_queue_rcv_skb(sk, skb);
 	if (rc < 0) {
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index d1fb63f..44a5859 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1628,7 +1628,7 @@ static int tcp_v6_do_rcv(struct sock *sk, struct sk_buff *skb)
 		opt_skb = skb_clone(skb, GFP_ATOMIC);
 
 	if (sk->sk_state == TCP_ESTABLISHED) { /* Fast path */
-		sock_rps_save_rxhash(sk, skb->rxhash);
+		sock_rps_save_rxhash(sk, skb);
 		if (tcp_rcv_established(sk, skb, tcp_hdr(skb), skb->len))
 			goto reset;
 		if (opt_skb)
@@ -1650,7 +1650,7 @@ static int tcp_v6_do_rcv(struct sock *sk, struct sk_buff *skb)
 		 * the new socket..
 		 */
 		if(nsk != sk) {
-			sock_rps_save_rxhash(nsk, skb->rxhash);
+			sock_rps_save_rxhash(nsk, skb);
 			if (tcp_child_process(sk, nsk, skb))
 				goto reset;
 			if (opt_skb)
@@ -1658,7 +1658,7 @@ static int tcp_v6_do_rcv(struct sock *sk, struct sk_buff *skb)
 			return 0;
 		}
 	} else
-		sock_rps_save_rxhash(sk, skb->rxhash);
+		sock_rps_save_rxhash(sk, skb);
 
 	if (tcp_rcv_state_process(sk, skb, tcp_hdr(skb), skb->len))
 		goto reset;
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 97e47f0..35bbdc4 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -509,7 +509,7 @@ int udpv6_queue_rcv_skb(struct sock * sk, struct sk_buff *skb)
 	int is_udplite = IS_UDPLITE(sk);
 
 	if (!ipv6_addr_any(&inet6_sk(sk)->daddr))
-		sock_rps_save_rxhash(sk, skb->rxhash);
+		sock_rps_save_rxhash(sk, skb);
 
 	if (!xfrm6_policy_check(sk, XFRM_POLICY_IN, skb))
 		goto drop;
-- 
1.7.3.1


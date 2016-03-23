From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH RFC 3/9] net: Add fast receive encapsulation
Date: Wed, 23 Mar 2016 15:36:52 -0700
Message-ID: <1458772618-845742-4-git-send-email-tom@herbertland.com>
References: <1458772618-845742-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:8750 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751945AbcCWWhO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2016 18:37:14 -0400
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u2NMahE2000539
	for <netdev@vger.kernel.org>; Wed, 23 Mar 2016 15:37:13 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 21uwsq9pja-1
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 23 Mar 2016 15:37:13 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 c8e99b0af14711e5ae670002c9521c9e-781fb3f0 for <netdev@vger.kernel.org>;	Wed,
 23 Mar 2016 15:37:12 -0700
In-Reply-To: <1458772618-845742-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows fast receive encapsulation processing. A configuration
flag, encap_fast, may be set in a UDP socket. When this flag is set
encap_rcv may be called without taking a reference to the the
encapsulation socket (which is usually unnecessary since the
encapsulation socket is not written to or saved in an skbuff).

In udp.c the logic to handle encapsulated packets is changed. When
receive a packet:

1) Perform a noref socket lookup.
2) If found socket is an encapsulation socket and encap_fast is set
   call encap_rcv with taking a reference
3) If further processing is needed, including calling encap_rcv
   when encap_fast is not set, the take a reference to the socket

This patch adds udp_encap_rcv_check to check and run encap_rcv.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/linux/udp.h |   5 +-
 net/ipv4/udp.c      | 165 ++++++++++++++++++++++++++++++----------------------
 net/ipv6/udp.c      |  91 +++++++++++------------------
 3 files changed, 133 insertions(+), 128 deletions(-)

diff --git a/include/linux/udp.h b/include/linux/udp.h
index 87c0949..f58213e 100644
--- a/include/linux/udp.h
+++ b/include/linux/udp.h
@@ -49,7 +49,8 @@ struct udp_sock {
 	unsigned int	 corkflag;	/* Cork is required */
 	__u8		 encap_type;	/* Is this an Encapsulation socket? */
 	unsigned char	 no_check6_tx:1,/* Send zero UDP6 checksums on TX? */
-			 no_check6_rx:1;/* Allow zero UDP6 checksums on RX? */
+			 no_check6_rx:1,/* Allow zero UDP6 checksums on RX? */
+			 encap_fast:1;	/* Can call encap_rcv wihout ref */
 	/*
 	 * Following member retains the information to create a UDP header
 	 * when the socket is uncorked.
@@ -98,6 +99,8 @@ static inline bool udp_get_no_check6_rx(struct sock *sk)
 	return udp_sk(sk)->no_check6_rx;
 }
 
+int udp_encap_rcv_check(struct sock *sk, struct sk_buff *skb);
+
 #define udp_portaddr_for_each_entry(__sk, node, list) \
 	hlist_nulls_for_each_entry(__sk, node, list, __sk_common.skc_portaddr_node)
 
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 324d008..cb13ec0 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -678,17 +678,6 @@ struct sock *udp4_lib_lookup(struct net *net, __be32 saddr, __be16 sport,
 }
 EXPORT_SYMBOL_GPL(udp4_lib_lookup);
 
-static inline struct sock *__udp4_lib_lookup_skb(struct sk_buff *skb,
-						 __be16 sport, __be16 dport,
-						 struct udp_table *udptable)
-{
-	const struct iphdr *iph = ip_hdr(skb);
-
-	return __udp4_lib_lookup(dev_net(skb_dst(skb)->dev), iph->saddr, sport,
-				 iph->daddr, dport, inet_iif(skb),
-				 udptable, skb);
-}
-
 static inline struct sock *__udp4_lib_lookup_skb_noref(struct sk_buff *skb,
 					__be16 sport, __be16 dport,
 					struct udp_table *udptable)
@@ -1611,9 +1600,65 @@ void udp_encap_enable(void)
 EXPORT_SYMBOL(udp_encap_enable);
 
 /* returns:
+ * =0 if skb was successfully passed to the encap
+ *    handler or was discarded by it.
+ * >0 if skb should be passed on to UDP.
+ * <0 if skb should be resubmitted as proto -N
+ *
+ * Note that in the success and error cases, the skb is assumed to
+ * have either been requeued or freed.
+ */
+int udp_encap_rcv_check(struct sock *sk, struct sk_buff *skb)
+{
+	struct udp_sock *up = udp_sk(sk);
+	int is_udplite = IS_UDPLITE(sk);
+
+	int (*encap_rcv)(struct sock *sk, struct sk_buff *skb);
+
+	if (!static_key_false(&udp_encap_needed))
+		return 1;
+	/* This is an encapsulation socket so pass the skb to
+	 * the socket's udp_encap_rcv() hook. Otherwise, just
+	 * fall through and pass this up the UDP socket.
+	 * up->encap_rcv() returns the following value:
+	 * =0 if skb was successfully passed to the encap
+	 *    handler or was discarded by it.
+	 * >0 if skb should be passed on to UDP.
+	 * <0 if skb should be resubmitted as proto -N
+	 */
+
+	/* if we're overly short, let UDP handle it */
+	encap_rcv = ACCESS_ONCE(up->encap_rcv);
+	if (skb->len > sizeof(struct udphdr) && encap_rcv) {
+		int ret;
+
+		/* Verify checksum before giving to encap */
+		if (udp_lib_checksum_complete(skb))
+			goto csum_error;
+
+		ret = encap_rcv(sk, skb);
+		if (ret <= 0) {
+			UDP_INC_STATS_BH(sock_net(sk),
+					 UDP_MIB_INDATAGRAMS,
+					 is_udplite);
+			return ret;
+		}
+	}
+
+	return 1; /* Continue UDP processing */
+
+csum_error:
+	UDP_INC_STATS_BH(sock_net(sk), UDP_MIB_CSUMERRORS, is_udplite);
+	UDP_INC_STATS_BH(sock_net(sk), UDP_MIB_INERRORS, is_udplite);
+	atomic_inc(&sk->sk_drops);
+	kfree_skb(skb);
+	return 0; /* Dropped */
+}
+EXPORT_SYMBOL(udp_encap_rcv_check);
+
+/* returns:
  *  -1: error
  *   0: success
- *  >0: "udp encap" protocol resubmission
  *
  * Note that in the success and error cases, the skb is assumed to
  * have either been requeued or freed.
@@ -1621,8 +1666,8 @@ EXPORT_SYMBOL(udp_encap_enable);
 int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 {
 	struct udp_sock *up = udp_sk(sk);
-	int rc;
 	int is_udplite = IS_UDPLITE(sk);
+	int rc;
 
 	/*
 	 *	Charge it to the socket, dropping if the queue is full.
@@ -1631,41 +1676,6 @@ int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 		goto drop;
 	nf_reset(skb);
 
-	if (static_key_false(&udp_encap_needed) && up->encap_type) {
-		int (*encap_rcv)(struct sock *sk, struct sk_buff *skb);
-
-		/*
-		 * This is an encapsulation socket so pass the skb to
-		 * the socket's udp_encap_rcv() hook. Otherwise, just
-		 * fall through and pass this up the UDP socket.
-		 * up->encap_rcv() returns the following value:
-		 * =0 if skb was successfully passed to the encap
-		 *    handler or was discarded by it.
-		 * >0 if skb should be passed on to UDP.
-		 * <0 if skb should be resubmitted as proto -N
-		 */
-
-		/* if we're overly short, let UDP handle it */
-		encap_rcv = ACCESS_ONCE(up->encap_rcv);
-		if (skb->len > sizeof(struct udphdr) && encap_rcv) {
-			int ret;
-
-			/* Verify checksum before giving to encap */
-			if (udp_lib_checksum_complete(skb))
-				goto csum_error;
-
-			ret = encap_rcv(sk, skb);
-			if (ret <= 0) {
-				UDP_INC_STATS_BH(sock_net(sk),
-						 UDP_MIB_INDATAGRAMS,
-						 is_udplite);
-				return -ret;
-			}
-		}
-
-		/* FALLTHROUGH -- it's a UDP Packet */
-	}
-
 	/*
 	 * 	UDP-Lite specific tests, ignored on UDP sockets
 	 */
@@ -1864,10 +1874,14 @@ static inline int udp4_csum_init(struct sk_buff *skb, struct udphdr *uh,
 					    inet_compute_pseudo);
 }
 
-/*
- *	All we need to do is get the socket, and then do a checksum.
+/* Process a received UDP packet. Validate the packet and checksum,
+ * lookup a socket, either receive packet on that socket or call
+ * the specified encapsulation receive function.
+ *
+ *	Returns:
+ *	  0: packet was received or consumed
+ *	  <0: "udp encap" protocol resubmission
  */
-
 int __udp4_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 		   int proto)
 {
@@ -1905,26 +1919,20 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 	sk = skb_steal_sock(skb);
 	if (sk) {
 		struct dst_entry *dst = skb_dst(skb);
-		int ret;
 
 		if (unlikely(sk->sk_rx_dst != dst))
 			udp_sk_rx_dst_set(sk, dst);
 
-		ret = udp_queue_rcv_skb(sk, skb);
-		sock_put(sk);
-		/* a return value > 0 means to resubmit the input, but
-		 * it wants the return to be -protocol, or 0
-		 */
-		if (ret > 0)
-			return -ret;
-		return 0;
+		goto have_ref_sock;
 	}
 
 	if (rt->rt_flags & (RTCF_BROADCAST|RTCF_MULTICAST))
 		return __udp4_lib_mcast_deliver(net, skb, uh,
 						saddr, daddr, udptable, proto);
 
-	sk = __udp4_lib_lookup_skb(skb, uh->source, uh->dest, udptable);
+	rcu_read_lock();
+	/* Don't take socket reference unless we need to */
+	sk = __udp4_lib_lookup_skb_noref(skb, uh->source, uh->dest, udptable);
 	if (sk) {
 		int ret;
 
@@ -1932,15 +1940,34 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 			skb_checksum_try_convert(skb, IPPROTO_UDP, uh->check,
 						 inet_compute_pseudo);
 
-		ret = udp_queue_rcv_skb(sk, skb);
-		sock_put(sk);
+		if (udp_sk(sk)->encap_type && udp_sk(sk)->encap_fast) {
+			ret = udp_encap_rcv_check(sk, skb);
+			if (ret <= 0) {
+				rcu_read_unlock();
+				return ret;
+			}
+		}
 
-		/* a return value > 0 means to resubmit the input, but
-		 * it wants the return to be -protocol, or 0
-		 */
-		if (ret > 0)
-			return -ret;
-		return 0;
+		/* Okay, need reference for futher processing */
+		sk = udp_get_ref(sk);
+		rcu_read_unlock();
+
+		if (sk) {
+have_ref_sock:
+			if (udp_sk(sk)->encap_type && !udp_sk(sk)->encap_fast) {
+				/* Did not check for encap yet */
+				ret = udp_encap_rcv_check(sk, skb);
+				if (ret <= 0) {
+					sock_put(sk);
+					return ret;
+				}
+			}
+			ret = udp_queue_rcv_skb(sk, skb);
+			sock_put(sk);
+			return ret;
+		}
+	} else {
+		rcu_read_unlock();
 	}
 
 	if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb))
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 281469c..cbcac8f 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -386,21 +386,6 @@ struct sock *__udp6_lib_lookup(struct net *net,
 }
 EXPORT_SYMBOL_GPL(__udp6_lib_lookup);
 
-static struct sock *__udp6_lib_lookup_skb(struct sk_buff *skb,
-					  __be16 sport, __be16 dport,
-					  struct udp_table *udptable)
-{
-	struct sock *sk;
-	const struct ipv6hdr *iph = ipv6_hdr(skb);
-
-	sk = skb_steal_sock(skb);
-	if (unlikely(sk))
-		return sk;
-	return __udp6_lib_lookup(dev_net(skb_dst(skb)->dev), &iph->saddr, sport,
-				 &iph->daddr, dport, inet6_iif(skb),
-				 udptable, skb);
-}
-
 struct sock *udp6_lib_lookup(struct net *net, const struct in6_addr *saddr, __be16 sport,
 			     const struct in6_addr *daddr, __be16 dport, int dif)
 {
@@ -676,41 +661,6 @@ int udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 	if (!xfrm6_policy_check(sk, XFRM_POLICY_IN, skb))
 		goto drop;
 
-	if (static_key_false(&udpv6_encap_needed) && up->encap_type) {
-		int (*encap_rcv)(struct sock *sk, struct sk_buff *skb);
-
-		/*
-		 * This is an encapsulation socket so pass the skb to
-		 * the socket's udp_encap_rcv() hook. Otherwise, just
-		 * fall through and pass this up the UDP socket.
-		 * up->encap_rcv() returns the following value:
-		 * =0 if skb was successfully passed to the encap
-		 *    handler or was discarded by it.
-		 * >0 if skb should be passed on to UDP.
-		 * <0 if skb should be resubmitted as proto -N
-		 */
-
-		/* if we're overly short, let UDP handle it */
-		encap_rcv = ACCESS_ONCE(up->encap_rcv);
-		if (skb->len > sizeof(struct udphdr) && encap_rcv) {
-			int ret;
-
-			/* Verify checksum before giving to encap */
-			if (udp_lib_checksum_complete(skb))
-				goto csum_error;
-
-			ret = encap_rcv(sk, skb);
-			if (ret <= 0) {
-				UDP_INC_STATS_BH(sock_net(sk),
-						 UDP_MIB_INDATAGRAMS,
-						 is_udplite);
-				return -ret;
-			}
-		}
-
-		/* FALLTHROUGH -- it's a UDP Packet */
-	}
-
 	/*
 	 * UDP-Lite specific tests, ignored on UDP sockets (see net/ipv4/udp.c).
 	 */
@@ -944,7 +894,13 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 	 * check socket cache ... must talk to Alan about his plans
 	 * for sock caches... i'll skip this for now.
 	 */
-	sk = __udp6_lib_lookup_skb(skb, uh->source, uh->dest, udptable);
+	sk = skb_steal_sock(skb);
+	if (unlikely(sk))
+		goto have_ref_sock;
+
+	rcu_read_lock();
+	/* Don't take socket reference unless we need to */
+	sk = __udp6_lib_lookup_skb_noref(skb, uh->source, uh->dest, udptable);
 	if (sk) {
 		int ret;
 
@@ -958,14 +914,33 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 			skb_checksum_try_convert(skb, IPPROTO_UDP, uh->check,
 						 ip6_compute_pseudo);
 
-		ret = udpv6_queue_rcv_skb(sk, skb);
-		sock_put(sk);
-
-		/* a return value > 0 means to resubmit the input */
-		if (ret > 0)
-			return ret;
+		if (udp_sk(sk)->encap_type && udp_sk(sk)->encap_fast) {
+			ret = udp_encap_rcv_check(sk, skb);
+			if (ret) {
+				rcu_read_unlock();
+				return ret > 0 ? -ret : 0;
+			}
+		}
 
-		return 0;
+		/* Okay, need reference for futher processing */
+		sk = udp_get_ref(sk);
+		rcu_read_unlock();
+
+		if (sk) {
+have_ref_sock:
+			if (udp_sk(sk)->encap_type && !udp_sk(sk)->encap_fast) {
+				/* Did not check for encap yet */
+				ret = udp_encap_rcv_check(sk, skb);
+				if (ret)
+					goto out;
+			}
+			ret = udpv6_queue_rcv_skb(sk, skb);
+out:
+			sock_put(sk);
+			return ret > 0 ? -ret : 0;
+		}
+	} else {
+		rcu_read_unlock();
 	}
 
 	if (!uh->check) {
-- 
2.8.0.rc2

From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next] net: Eliminate txhash in sock and reflect RX hash on transmit
Date: Fri, 20 Feb 2015 16:24:30 -0800
Message-ID: <1424478270-24783-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:43477 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754916AbbBUAYk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 19:24:40 -0500
Received: by mail-ig0-f176.google.com with SMTP id hl2so7039369igb.3
        for <netdev@vger.kernel.org>; Fri, 20 Feb 2015 16:24:40 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of having a separate hash value in sock structure for transmit
and receive, we can use the rxhash value for both and eliminate the
txhash value. This simplifies the code and reflects the receive hash a
device provides to the stack for packets transmitted on the associated
connection. The hash value returned by a device could have meaning when
used in transmit to identify a flow, for instance the hash may be a flow
key for a flow created in a (virtual) device. With the flow key provided
on transmit this can obviate the need to create the hash and do the
lookup on the fly in transmit.

This patch entails:
 - Always include sk_rxash (not dependent on CONFIG_RPS)
 - Remove sk_txhash and functions to set it
 - Add sock_init_rxhash which is used to initialize sk_rxhash. This
   uses a random value and is only relevant if CONFIG_RPS is not
   defined or traffic on socket is unidirectional send so we
   don't get ever get an rxhash from device. This random value should
   be overwritten with the first receive packet on the socket.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/net/ip.h    | 13 -------------
 include/net/ipv6.h  | 14 --------------
 include/net/sock.h  | 16 ++++++++--------
 net/ipv4/datagram.c |  2 +-
 net/ipv4/tcp_ipv4.c |  4 ++--
 net/ipv6/datagram.c |  2 +-
 net/ipv6/tcp_ipv6.c |  4 ++--
 7 files changed, 14 insertions(+), 41 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 025c61c..11991ed 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -352,19 +352,6 @@ static inline __wsum inet_compute_pseudo(struct sk_buff *skb, int proto)
 				  skb->len, proto, 0);
 }
 
-static inline void inet_set_txhash(struct sock *sk)
-{
-	struct inet_sock *inet = inet_sk(sk);
-	struct flow_keys keys;
-
-	keys.src = inet->inet_saddr;
-	keys.dst = inet->inet_daddr;
-	keys.port16[0] = inet->inet_sport;
-	keys.port16[1] = inet->inet_dport;
-
-	sk->sk_txhash = flow_hash_from_keys(&keys);
-}
-
 static inline __wsum inet_gro_compute_pseudo(struct sk_buff *skb, int proto)
 {
 	const struct iphdr *iph = skb_gro_network_header(skb);
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 4c9fe22..fd8d0e2 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -691,20 +691,6 @@ static inline int ip6_sk_dst_hoplimit(struct ipv6_pinfo *np, struct flowi6 *fl6,
 }
 
 #if IS_ENABLED(CONFIG_IPV6)
-static inline void ip6_set_txhash(struct sock *sk)
-{
-	struct inet_sock *inet = inet_sk(sk);
-	struct ipv6_pinfo *np = inet6_sk(sk);
-	struct flow_keys keys;
-
-	keys.src = (__force __be32)ipv6_addr_hash(&np->saddr);
-	keys.dst = (__force __be32)ipv6_addr_hash(&sk->sk_v6_daddr);
-	keys.port16[0] = inet->inet_sport;
-	keys.port16[1] = inet->inet_dport;
-
-	sk->sk_txhash = flow_hash_from_keys(&keys);
-}
-
 static inline __be32 ip6_make_flowlabel(struct net *net, struct sk_buff *skb,
 					__be32 flowlabel, bool autolabel)
 {
diff --git a/include/net/sock.h b/include/net/sock.h
index ab186b1..cebd9fb 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -51,6 +51,7 @@
 #include <linux/netdevice.h>
 #include <linux/skbuff.h>	/* struct sk_buff */
 #include <linux/mm.h>
+#include <linux/random.h>
 #include <linux/security.h>
 #include <linux/slab.h>
 #include <linux/uaccess.h>
@@ -274,7 +275,6 @@ struct cg_proto;
   *	@sk_sndtimeo: %SO_SNDTIMEO setting
   *	@sk_rxhash: flow hash received from netif layer
   *	@sk_incoming_cpu: record cpu processing incoming packets
-  *	@sk_txhash: computed flow hash for use on transmit
   *	@sk_filter: socket filtering instructions
   *	@sk_protinfo: private area, net family specific, when not using slab
   *	@sk_timer: sock cleanup timer
@@ -348,16 +348,13 @@ struct sock {
 	} sk_backlog;
 #define sk_rmem_alloc sk_backlog.rmem_alloc
 	int			sk_forward_alloc;
-#ifdef CONFIG_RPS
 	__u32			sk_rxhash;
-#endif
 	u16			sk_incoming_cpu;
 	/* 16bit hole
 	 * Warned : sk_incoming_cpu can be set from softirq,
 	 * Do not use this hole without fully understanding possible issues.
 	 */
 
-	__u32			sk_txhash;
 #ifdef CONFIG_NET_RX_BUSY_POLL
 	unsigned int		sk_napi_id;
 	unsigned int		sk_ll_usec;
@@ -875,9 +872,12 @@ static inline void sock_rps_save_rxhash(struct sock *sk,
 
 static inline void sock_rps_reset_rxhash(struct sock *sk)
 {
-#ifdef CONFIG_RPS
 	sk->sk_rxhash = 0;
-#endif
+}
+
+static inline void sock_init_rxhash(struct sock *sk)
+{
+	get_random_bytes(&sk->sk_rxhash, sizeof(u32));
 }
 
 #define sk_wait_event(__sk, __timeo, __condition)			\
@@ -1926,9 +1926,9 @@ static inline void sock_poll_wait(struct file *filp,
 
 static inline void skb_set_hash_from_sk(struct sk_buff *skb, struct sock *sk)
 {
-	if (sk->sk_txhash) {
+	if (sk->sk_rxhash) {
 		skb->l4_hash = 1;
-		skb->hash = sk->sk_txhash;
+		skb->hash = sk->sk_rxhash;
 	}
 }
 
diff --git a/net/ipv4/datagram.c b/net/ipv4/datagram.c
index 90c0e83..f6ef6a5 100644
--- a/net/ipv4/datagram.c
+++ b/net/ipv4/datagram.c
@@ -76,7 +76,7 @@ int ip4_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	inet->inet_daddr = fl4->daddr;
 	inet->inet_dport = usin->sin_port;
 	sk->sk_state = TCP_ESTABLISHED;
-	inet_set_txhash(sk);
+	sock_init_rxhash(sk);
 	inet->inet_id = jiffies;
 
 	sk_dst_set(sk, &rt->dst);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 5a2dfed..b153880 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -222,7 +222,7 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	if (err)
 		goto failure;
 
-	inet_set_txhash(sk);
+	sock_init_rxhash(sk);
 
 	rt = ip_route_newports(fl4, rt, orig_sport, orig_dport,
 			       inet->inet_sport, inet->inet_dport, sk);
@@ -1328,7 +1328,7 @@ struct sock *tcp_v4_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 	newinet->mc_ttl	      = ip_hdr(skb)->ttl;
 	newinet->rcv_tos      = ip_hdr(skb)->tos;
 	inet_csk(newsk)->icsk_ext_hdr_len = 0;
-	inet_set_txhash(newsk);
+	sock_init_rxhash(newsk);
 	if (inet_opt)
 		inet_csk(newsk)->icsk_ext_hdr_len = inet_opt->opt.optlen;
 	newinet->inet_id = newtp->write_seq ^ jiffies;
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index c215be7..2048518 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -199,7 +199,7 @@ ipv4_connected:
 		      NULL);
 
 	sk->sk_state = TCP_ESTABLISHED;
-	ip6_set_txhash(sk);
+	sock_init_rxhash(sk);
 out:
 	fl6_sock_release(flowlabel);
 	return err;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 5d46832..5d8b91d 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -295,7 +295,7 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 	if (err)
 		goto late_failure;
 
-	ip6_set_txhash(sk);
+	sock_init_rxhash(sk);
 
 	if (!tp->write_seq && likely(!tp->repair))
 		tp->write_seq = secure_tcpv6_sequence_number(np->saddr.s6_addr32,
@@ -1155,7 +1155,7 @@ static struct sock *tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 	newsk->sk_v6_rcv_saddr = ireq->ir_v6_loc_addr;
 	newsk->sk_bound_dev_if = ireq->ir_iif;
 
-	ip6_set_txhash(newsk);
+	sock_init_rxhash(newsk);
 
 	/* Now IPv6 options...
 
-- 
2.2.0.rc0.207.ga3a616c

From: Tom Herbert <therbert@google.com>
Subject: [PATCH 2/8] net: Save TX flow hash in sock and set in skbuf on
 xmit
Date: Tue, 1 Jul 2014 21:32:17 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1407012057310.24130@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f202.google.com ([209.85.213.202]:50312 "EHLO
	mail-ig0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751372AbaGBEcS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 00:32:18 -0400
Received: by mail-ig0-f202.google.com with SMTP id c1so618101igq.5
        for <netdev@vger.kernel.org>; Tue, 01 Jul 2014 21:32:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For a connected socket we can precompute the flow hash for setting
in skb->hash on output. This is a performance advantage over
calculating the skb->hash for every packet on the connection. The
computation is done using the common hash algorithm to be consistent
with computations done for packets of the connection in other states
where thers is no socket (e.g. time-wait, syn-recv, syn-cookies).

This patch adds sk_txhash to the sock structure. inet_set_txhash and
ip6_set_txhash functions are added which are called from points in
TCP and UDP where socket moves to established state.

skb_set_hash_from_sk is a function which sets skb->hash from the
sock txhash value. This is called in UDP and TCP transmit path when
transmitting within the context of a socket.

Tested: ran super_netperf with 200 TCP_RR streams over a vxlan
interface (in this case skb_get_hash called on every TX packet to
create a UDP source port).

Before fix:

  95.02% CPU utilization
  154/256/505 90/95/99% latencies
  1.13042e+06 tps

  Time in functions:
    0.28% skb_flow_dissect
    0.21% __skb_get_hash

After fix:

  94.95% CPU utilization
  156/254/485 90/95/99% latencies
  1.15447e+06

  Neither __skb_get_hash nor skb_flow_dissect appear in perf

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/net/ip.h      | 14 ++++++++++++++
 include/net/ipv6.h    | 15 +++++++++++++++
 include/net/sock.h    | 11 +++++++++++
 net/ipv4/datagram.c   |  1 +
 net/ipv4/tcp_ipv4.c   |  3 +++
 net/ipv4/tcp_output.c |  1 +
 net/ipv6/datagram.c   |  1 +
 net/ipv6/tcp_ipv6.c   |  4 ++++
 8 files changed, 50 insertions(+)

diff --git a/include/net/ip.h b/include/net/ip.h
index 0e795df..2e8f055 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -31,6 +31,7 @@
 #include <net/route.h>
 #include <net/snmp.h>
 #include <net/flow.h>
+#include <net/flow_keys.h>
 
 struct sock;
 
@@ -353,6 +354,19 @@ static inline __wsum inet_compute_pseudo(struct sk_buff *skb, int proto)
 				  skb->len, proto, 0);
 }
 
+static inline void inet_set_txhash(struct sock *sk)
+{
+	struct inet_sock *inet = inet_sk(sk);
+	struct flow_keys keys;
+
+	keys.src = inet->inet_saddr;
+	keys.dst = inet->inet_daddr;
+	keys.port16[0] = inet->inet_sport;
+	keys.port16[1] = inet->inet_dport;
+
+	sk->sk_txhash = flow_hash_from_keys(&keys);
+}
+
 /*
  *	Map a multicast IP onto multicast MAC for type ethernet.
  */
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 574337f..2aa86e1 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -19,6 +19,7 @@
 #include <net/if_inet6.h>
 #include <net/ndisc.h>
 #include <net/flow.h>
+#include <net/flow_keys.h>
 #include <net/snmp.h>
 
 #define SIN6_LEN_RFC2133	24
@@ -684,6 +685,20 @@ static inline int ip6_sk_dst_hoplimit(struct ipv6_pinfo *np, struct flowi6 *fl6,
 	return hlimit;
 }
 
+static inline void ip6_set_txhash(struct sock *sk)
+{
+	struct inet_sock *inet = inet_sk(sk);
+	struct ipv6_pinfo *np = inet6_sk(sk);
+	struct flow_keys keys;
+
+	keys.src = (__force __be32)ipv6_addr_hash(&np->saddr);
+	keys.dst = (__force __be32)ipv6_addr_hash(&sk->sk_v6_daddr);
+	keys.port16[0] = inet->inet_sport;
+	keys.port16[1] = inet->inet_dport;
+
+	sk->sk_txhash = flow_hash_from_keys(&keys);
+}
+
 /*
  *	Header manipulation
  */
diff --git a/include/net/sock.h b/include/net/sock.h
index 173cae4..f81b116 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -272,6 +272,7 @@ struct cg_proto;
   *	@sk_rcvtimeo: %SO_RCVTIMEO setting
   *	@sk_sndtimeo: %SO_SNDTIMEO setting
   *	@sk_rxhash: flow hash received from netif layer
+  *	@sk_txhash: computed flow hash for use on transmit
   *	@sk_filter: socket filtering instructions
   *	@sk_protinfo: private area, net family specific, when not using slab
   *	@sk_timer: sock cleanup timer
@@ -345,6 +346,7 @@ struct sock {
 #ifdef CONFIG_RPS
 	__u32			sk_rxhash;
 #endif
+	__u32			sk_txhash;
 #ifdef CONFIG_NET_RX_BUSY_POLL
 	unsigned int		sk_napi_id;
 	unsigned int		sk_ll_usec;
@@ -1978,6 +1980,14 @@ static inline void sock_poll_wait(struct file *filp,
 	}
 }
 
+static inline void skb_set_hash_from_sk(struct sk_buff *skb, struct sock *sk)
+{
+	if (sk->sk_txhash) {
+		skb->l4_hash = 1;
+		skb->hash = sk->sk_txhash;
+	}
+}
+
 /*
  *	Queue a received datagram if it will fit. Stream and sequenced
  *	protocols can't normally use this as they need to fit buffers in
@@ -1992,6 +2002,7 @@ static inline void skb_set_owner_w(struct sk_buff *skb, struct sock *sk)
 	skb_orphan(skb);
 	skb->sk = sk;
 	skb->destructor = sock_wfree;
+	skb_set_hash_from_sk(skb, sk);
 	/*
 	 * We used to take a refcount on sk, but following operation
 	 * is enough to guarantee sk_free() wont free this sock until
diff --git a/net/ipv4/datagram.c b/net/ipv4/datagram.c
index a3095fd..90c0e83 100644
--- a/net/ipv4/datagram.c
+++ b/net/ipv4/datagram.c
@@ -76,6 +76,7 @@ int ip4_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	inet->inet_daddr = fl4->daddr;
 	inet->inet_dport = usin->sin_port;
 	sk->sk_state = TCP_ESTABLISHED;
+	inet_set_txhash(sk);
 	inet->inet_id = jiffies;
 
 	sk_dst_set(sk, &rt->dst);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 5dfebd2..38562f6 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -208,6 +208,8 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	inet->inet_dport = usin->sin_port;
 	inet->inet_daddr = daddr;
 
+	inet_set_txhash(sk);
+
 	inet_csk(sk)->icsk_ext_hdr_len = 0;
 	if (inet_opt)
 		inet_csk(sk)->icsk_ext_hdr_len = inet_opt->opt.optlen;
@@ -1336,6 +1338,7 @@ struct sock *tcp_v4_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 	newinet->mc_ttl	      = ip_hdr(skb)->ttl;
 	newinet->rcv_tos      = ip_hdr(skb)->tos;
 	inet_csk(newsk)->icsk_ext_hdr_len = 0;
+	inet_set_txhash(newsk);
 	if (inet_opt)
 		inet_csk(newsk)->icsk_ext_hdr_len = inet_opt->opt.optlen;
 	newinet->inet_id = newtp->write_seq ^ jiffies;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index f8f2a94..bcee13c 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -916,6 +916,7 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 	skb_orphan(skb);
 	skb->sk = sk;
 	skb->destructor = tcp_wfree;
+	skb_set_hash_from_sk(skb, sk);
 	atomic_add(skb->truesize, &sk->sk_wmem_alloc);
 
 	/* Build TCP header and checksum it. */
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index c3bf2d2..2753319 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -199,6 +199,7 @@ ipv4_connected:
 		      NULL);
 
 	sk->sk_state = TCP_ESTABLISHED;
+	ip6_set_txhash(sk);
 out:
 	fl6_sock_release(flowlabel);
 	return err;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index bc24ee2..33d38c3 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -198,6 +198,8 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 	sk->sk_v6_daddr = usin->sin6_addr;
 	np->flow_label = fl6.flowlabel;
 
+	ip6_set_txhash(sk);
+
 	/*
 	 *	TCP over IPv4
 	 */
@@ -1134,6 +1136,8 @@ static struct sock *tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 	newsk->sk_v6_rcv_saddr = ireq->ir_v6_loc_addr;
 	newsk->sk_bound_dev_if = ireq->ir_iif;
 
+	ip6_set_txhash(newsk);
+
 	/* Now IPv6 options...
 
 	   First: no IPv4 options.
-- 
2.0.0.526.g5318336

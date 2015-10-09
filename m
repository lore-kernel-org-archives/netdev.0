From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v3 net-next 1/4] net: SO_INCOMING_CPU setsockopt() support
Date: Thu,  8 Oct 2015 19:33:21 -0700
Message-ID: <1444358004-26483-2-git-send-email-edumazet@google.com>
References: <1444358004-26483-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35541 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756401AbbJICdc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 22:33:32 -0400
Received: by pabve7 with SMTP id ve7so13201286pab.2
        for <netdev@vger.kernel.org>; Thu, 08 Oct 2015 19:33:32 -0700 (PDT)
In-Reply-To: <1444358004-26483-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SO_INCOMING_CPU as added in commit 2c8c56e15df3 was a getsockopt() command
to fetch incoming cpu handling a particular TCP flow after accept()

This commits adds setsockopt() support and extends SO_REUSEPORT selection
logic : If a TCP listener or UDP socket has this option set, a packet is
delivered to this socket only if CPU handling the packet matches the specified
one.

This allows to build very efficient TCP servers, using one listener per
RX queue, as the associated TCP listener should only accept flows handled
in softirq by the same cpu.
This provides optimal NUMA behavior and keep cpu caches hot.

Note that __inet_lookup_listener() still has to iterate over the list of
all listeners. Following patch puts sk_refcnt in a different cache line
to let this iteration hit only shared and read mostly cache lines.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/sock.h          | 10 ++++------
 net/core/sock.c             |  5 +++++
 net/ipv4/inet_hashtables.c  |  2 ++
 net/ipv4/udp.c              |  6 +++++-
 net/ipv6/inet6_hashtables.c |  2 ++
 net/ipv6/udp.c              | 11 +++++++----
 6 files changed, 25 insertions(+), 11 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index dfe2eb8e1132..08abffe32236 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -150,6 +150,7 @@ typedef __u64 __bitwise __addrpair;
  *	@skc_node: main hash linkage for various protocol lookup tables
  *	@skc_nulls_node: main hash linkage for TCP/UDP/UDP-Lite protocol
  *	@skc_tx_queue_mapping: tx queue number for this connection
+ *	@skc_incoming_cpu: record/match cpu processing incoming packets
  *	@skc_refcnt: reference count
  *
  *	This is the minimal network layer representation of sockets, the header
@@ -212,6 +213,8 @@ struct sock_common {
 		struct hlist_nulls_node skc_nulls_node;
 	};
 	int			skc_tx_queue_mapping;
+	int			skc_incoming_cpu;
+
 	atomic_t		skc_refcnt;
 	/* private: */
 	int                     skc_dontcopy_end[0];
@@ -274,7 +277,6 @@ struct cg_proto;
   *	@sk_rcvtimeo: %SO_RCVTIMEO setting
   *	@sk_sndtimeo: %SO_SNDTIMEO setting
   *	@sk_rxhash: flow hash received from netif layer
-  *	@sk_incoming_cpu: record cpu processing incoming packets
   *	@sk_txhash: computed flow hash for use on transmit
   *	@sk_filter: socket filtering instructions
   *	@sk_timer: sock cleanup timer
@@ -331,6 +333,7 @@ struct sock {
 #define sk_v6_daddr		__sk_common.skc_v6_daddr
 #define sk_v6_rcv_saddr	__sk_common.skc_v6_rcv_saddr
 #define sk_cookie		__sk_common.skc_cookie
+#define sk_incoming_cpu		__sk_common.skc_incoming_cpu
 
 	socket_lock_t		sk_lock;
 	struct sk_buff_head	sk_receive_queue;
@@ -353,11 +356,6 @@ struct sock {
 #ifdef CONFIG_RPS
 	__u32			sk_rxhash;
 #endif
-	u16			sk_incoming_cpu;
-	/* 16bit hole
-	 * Warned : sk_incoming_cpu can be set from softirq,
-	 * Do not use this hole without fully understanding possible issues.
-	 */
 
 	__u32			sk_txhash;
 #ifdef CONFIG_NET_RX_BUSY_POLL
diff --git a/net/core/sock.c b/net/core/sock.c
index 7dd1263e4c24..1071f9380250 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -988,6 +988,10 @@ set_rcvbuf:
 					 sk->sk_max_pacing_rate);
 		break;
 
+	case SO_INCOMING_CPU:
+		sk->sk_incoming_cpu = val;
+		break;
+
 	default:
 		ret = -ENOPROTOOPT;
 		break;
@@ -2353,6 +2357,7 @@ void sock_init_data(struct socket *sock, struct sock *sk)
 
 	sk->sk_max_pacing_rate = ~0U;
 	sk->sk_pacing_rate = ~0U;
+	sk->sk_incoming_cpu = -1;
 	/*
 	 * Before updating sk_refcnt, we must commit prior changes to memory
 	 * (Documentation/RCU/rculist_nulls.txt for details)
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index bed8886a4b6c..08643a3616af 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -185,6 +185,8 @@ static inline int compute_score(struct sock *sk, struct net *net,
 				return -1;
 			score += 4;
 		}
+		if (sk->sk_incoming_cpu == raw_smp_processor_id())
+			score++;
 	}
 	return score;
 }
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index e1fc129099ea..24ec14f9825c 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -375,7 +375,8 @@ static inline int compute_score(struct sock *sk, struct net *net,
 			return -1;
 		score += 4;
 	}
-
+	if (sk->sk_incoming_cpu == raw_smp_processor_id())
+		score++;
 	return score;
 }
 
@@ -419,6 +420,9 @@ static inline int compute_score2(struct sock *sk, struct net *net,
 		score += 4;
 	}
 
+	if (sk->sk_incoming_cpu == raw_smp_processor_id())
+		score++;
+
 	return score;
 }
 
diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index 6ac8dad0138a..21ace5a2bf7c 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -114,6 +114,8 @@ static inline int compute_score(struct sock *sk, struct net *net,
 				return -1;
 			score++;
 		}
+		if (sk->sk_incoming_cpu == raw_smp_processor_id())
+			score++;
 	}
 	return score;
 }
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 0aba654f5b91..01bcb49619ee 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -182,10 +182,12 @@ static inline int compute_score(struct sock *sk, struct net *net,
 		score++;
 	}
 
+	if (sk->sk_incoming_cpu == raw_smp_processor_id())
+		score++;
+
 	return score;
 }
 
-#define SCORE2_MAX (1 + 1 + 1)
 static inline int compute_score2(struct sock *sk, struct net *net,
 				 const struct in6_addr *saddr, __be16 sport,
 				 const struct in6_addr *daddr,
@@ -223,6 +225,9 @@ static inline int compute_score2(struct sock *sk, struct net *net,
 		score++;
 	}
 
+	if (sk->sk_incoming_cpu == raw_smp_processor_id())
+		score++;
+
 	return score;
 }
 
@@ -251,8 +256,7 @@ begin:
 				hash = udp6_ehashfn(net, daddr, hnum,
 						    saddr, sport);
 				matches = 1;
-			} else if (score == SCORE2_MAX)
-				goto exact_match;
+			}
 		} else if (score == badness && reuseport) {
 			matches++;
 			if (reciprocal_scale(hash, matches) == 0)
@@ -269,7 +273,6 @@ begin:
 		goto begin;
 
 	if (result) {
-exact_match:
 		if (unlikely(!atomic_inc_not_zero_hint(&result->sk_refcnt, 2)))
 			result = NULL;
 		else if (unlikely(compute_score2(result, net, saddr, sport,
-- 
2.6.0.rc2.230.g3dd15c0

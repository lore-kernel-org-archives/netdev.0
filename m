From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 1/4] net: SO_INCOMING_CPU setsockopt() support
Date: Thu,  8 Oct 2015 08:37:04 -0700
Message-ID: <1444318627-27883-2-git-send-email-edumazet@google.com>
References: <1444318627-27883-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:36165 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933809AbbJHPhU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 11:37:20 -0400
Received: by pablk4 with SMTP id lk4so58044541pab.3
        for <netdev@vger.kernel.org>; Thu, 08 Oct 2015 08:37:20 -0700 (PDT)
In-Reply-To: <1444318627-27883-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SO_INCOMING_CPU as added in commit 2c8c56e15df3 was a getsockopt() command
to fetch incoming cpu handling a particular TCP flow after accept()

This commits adds setsockopt() support and extends SO_REUSEPORT selection
logic : If a TCP listener or UDP socket has this option set, a packet is
delivered to this socket only if CPU handling the packet matches the specified one.

This allows to build very efficient TCP servers, using one thread per cpu,
as the associated TCP listener should only accept flows handled in softirq
by the same cpu. This provides optimal NUMA/SMP behavior and keep cpu caches hot.

Note that __inet_lookup_listener() still has to iterate over the list of
all listeners. Following patch puts sk_refcnt in a different cache line
to let this iteration hit only shared and read mostly cache lines.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/sock.h          | 11 +++++------
 net/core/sock.c             |  5 +++++
 net/ipv4/inet_hashtables.c  |  5 +++++
 net/ipv4/udp.c              | 12 +++++++++++-
 net/ipv6/inet6_hashtables.c |  5 +++++
 net/ipv6/udp.c              | 11 +++++++++++
 6 files changed, 42 insertions(+), 7 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index dfe2eb8e1132..00f60bea983b 100644
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
@@ -274,7 +277,7 @@ struct cg_proto;
   *	@sk_rcvtimeo: %SO_RCVTIMEO setting
   *	@sk_sndtimeo: %SO_SNDTIMEO setting
   *	@sk_rxhash: flow hash received from netif layer
-  *	@sk_incoming_cpu: record cpu processing incoming packets
+  *	@sk_incoming_cpu: record/match cpu processing incoming packets
   *	@sk_txhash: computed flow hash for use on transmit
   *	@sk_filter: socket filtering instructions
   *	@sk_timer: sock cleanup timer
@@ -331,6 +334,7 @@ struct sock {
 #define sk_v6_daddr		__sk_common.skc_v6_daddr
 #define sk_v6_rcv_saddr	__sk_common.skc_v6_rcv_saddr
 #define sk_cookie		__sk_common.skc_cookie
+#define sk_incoming_cpu		__sk_common.skc_incoming_cpu
 
 	socket_lock_t		sk_lock;
 	struct sk_buff_head	sk_receive_queue;
@@ -353,11 +357,6 @@ struct sock {
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
index bed8886a4b6c..eabcfbc13afb 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -185,6 +185,11 @@ static inline int compute_score(struct sock *sk, struct net *net,
 				return -1;
 			score += 4;
 		}
+		if (sk->sk_incoming_cpu != -1) {
+			if (sk->sk_incoming_cpu != raw_smp_processor_id())
+				return -1;
+			score++;
+		}
 	}
 	return score;
 }
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index e1fc129099ea..de675b796f78 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -375,7 +375,11 @@ static inline int compute_score(struct sock *sk, struct net *net,
 			return -1;
 		score += 4;
 	}
-
+	if (sk->sk_incoming_cpu != -1) {
+		if (sk->sk_incoming_cpu != raw_smp_processor_id())
+			return -1;
+		score++;
+	}
 	return score;
 }
 
@@ -419,6 +423,12 @@ static inline int compute_score2(struct sock *sk, struct net *net,
 		score += 4;
 	}
 
+	if (sk->sk_incoming_cpu != -1) {
+		if (sk->sk_incoming_cpu != raw_smp_processor_id())
+			return -1;
+		score++;
+	}
+
 	return score;
 }
 
diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index 6ac8dad0138a..af3d7f826bff 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -114,6 +114,11 @@ static inline int compute_score(struct sock *sk, struct net *net,
 				return -1;
 			score++;
 		}
+		if (sk->sk_incoming_cpu != -1) {
+			if (sk->sk_incoming_cpu != raw_smp_processor_id())
+				return -1;
+			score++;
+		}
 	}
 	return score;
 }
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 0aba654f5b91..222fdc780405 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -182,6 +182,12 @@ static inline int compute_score(struct sock *sk, struct net *net,
 		score++;
 	}
 
+	if (sk->sk_incoming_cpu != -1) {
+		if (sk->sk_incoming_cpu != raw_smp_processor_id())
+			return -1;
+		score++;
+	}
+
 	return score;
 }
 
@@ -223,6 +229,11 @@ static inline int compute_score2(struct sock *sk, struct net *net,
 		score++;
 	}
 
+	if (sk->sk_incoming_cpu != -1) {
+		if (sk->sk_incoming_cpu != raw_smp_processor_id())
+			return -1;
+		score++;
+	}
 	return score;
 }
 
-- 
2.6.0.rc2.230.g3dd15c0

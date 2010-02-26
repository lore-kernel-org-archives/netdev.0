From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH V2] net: add accounting for socket backlog
Date: Fri, 26 Feb 2010 17:27:44 +0800
Message-ID: <1267176464-426-1-git-send-email-yi.zhu@intel.com>
Cc: netdev@vger.kernel.org, Zhu Yi <yi.zhu@intel.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:29232 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935667Ab0BZJ0W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Feb 2010 04:26:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We got system OOM while running some UDP netperf testing on the loopback
device. The case is multiple senders sent stream UDP packets to a single
receiver via loopback on local host. Of course, the receiver is not able
to handle all the packets in time. But we surprisingly found that these
packets were not discarded due to the receiver's sk->sk_rcvbuf limit.
Instead, they are kept queuing to sk->sk_backlog and finally ate up all
the memory. We believe this is a secure hole that a none privileged user
can crash the system.

The root cause for this problem is, when the receiver is doing
__release_sock() (i.e. after userspace recv, kernel udp_recvmsg ->
skb_free_datagram_locked -> release_sock), it moves skbs from backlog to
sk_receive_queue with the softirq enabled. In the above case, multiple
busy senders will almost make it an endless loop. The skbs in the
backlog end up eat all the system memory.

The patch fixed this problem by adding accounting for the socket
backlog. So that the backlog size can be restricted by protocol's choice
(i.e. UDP).

Reported-by: Alex Shi <alex.shi@intel.com>
Cc: David Miller <davem@davemloft.net>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Zhu Yi <yi.zhu@intel.com>
---
V2: remove atomic operation for sk_backlog.len
    limit UDP backlog size to 2*sk->sk_rcvbuf

diff --git a/include/net/sock.h b/include/net/sock.h
index 3f1a480..9f6893b 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -253,6 +253,7 @@ struct sock {
 	struct {
 		struct sk_buff *head;
 		struct sk_buff *tail;
+		int len;
 	} sk_backlog;
 	wait_queue_head_t	*sk_sleep;
 	struct dst_entry	*sk_dst_cache;
@@ -583,11 +584,22 @@ static inline void sk_add_backlog(struct sock *sk, struct sk_buff *skb)
 		sk->sk_backlog.tail->next = skb;
 		sk->sk_backlog.tail = skb;
 	}
+	sk->sk_backlog.len += skb->truesize;
 	skb->next = NULL;
 }
 
+static inline int sk_add_backlog_limited(struct sock *sk, struct sk_buff *skb)
+{
+	if (sk->sk_backlog.len >= 2 * sk->sk_rcvbuf)
+		return -ENOBUFS;
+
+	sk_add_backlog(sk, skb);
+	return 0;
+}
+
 static inline int sk_backlog_rcv(struct sock *sk, struct sk_buff *skb)
 {
+	sk->sk_backlog.len -= skb->truesize;
 	return sk->sk_backlog_rcv(sk, skb);
 }
 
diff --git a/net/core/sock.c b/net/core/sock.c
index e1f6f22..82228ef 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1138,6 +1138,7 @@ struct sock *sk_clone(const struct sock *sk, const gfp_t priority)
 		sock_lock_init(newsk);
 		bh_lock_sock(newsk);
 		newsk->sk_backlog.head	= newsk->sk_backlog.tail = NULL;
+		newsk->sk_backlog.len = 0;
 
 		atomic_set(&newsk->sk_rmem_alloc, 0);
 		/*
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index f0126fd..7bb4568 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1372,8 +1372,10 @@ int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 	bh_lock_sock(sk);
 	if (!sock_owned_by_user(sk))
 		rc = __udp_queue_rcv_skb(sk, skb);
-	else
-		sk_add_backlog(sk, skb);
+	else if (sk_add_backlog_limited(sk, skb)) {
+		bh_unlock_sock(sk);
+		goto drop;
+	}
 	bh_unlock_sock(sk);
 
 	return rc;
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 69ebdbe..e4a8645 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -584,16 +584,19 @@ static void flush_stack(struct sock **stack, unsigned int count,
 			bh_lock_sock(sk);
 			if (!sock_owned_by_user(sk))
 				udpv6_queue_rcv_skb(sk, skb1);
-			else
-				sk_add_backlog(sk, skb1);
+			else if (sk_add_backlog_limited(sk, skb1)) {
+				bh_unlock_sock(sk);
+				goto drop;
+			}
 			bh_unlock_sock(sk);
-		} else {
-			atomic_inc(&sk->sk_drops);
-			UDP6_INC_STATS_BH(sock_net(sk),
-					UDP_MIB_RCVBUFERRORS, IS_UDPLITE(sk));
-			UDP6_INC_STATS_BH(sock_net(sk),
-					UDP_MIB_INERRORS, IS_UDPLITE(sk));
+			continue;
 		}
+drop:
+		atomic_inc(&sk->sk_drops);
+		UDP6_INC_STATS_BH(sock_net(sk),
+				UDP_MIB_RCVBUFERRORS, IS_UDPLITE(sk));
+		UDP6_INC_STATS_BH(sock_net(sk),
+				UDP_MIB_INERRORS, IS_UDPLITE(sk));
 	}
 }
 /*
@@ -756,8 +759,11 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 	bh_lock_sock(sk);
 	if (!sock_owned_by_user(sk))
 		udpv6_queue_rcv_skb(sk, skb);
-	else
-		sk_add_backlog(sk, skb);
+	else if (sk_add_backlog_limited(sk, skb)) {
+		bh_unlock_sock(sk);
+		sock_put(sk);
+		goto discard;
+	}
 	bh_unlock_sock(sk);
 	sock_put(sk);
 	return 0;

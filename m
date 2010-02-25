From: Zhu Yi <yi.zhu@intel.com>
Subject: [RFC PATCH] accounting for socket backlog
Date: Thu, 25 Feb 2010 11:13:13 +0800
Message-ID: <1267067593.16986.1583.camel@debian>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:38324 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758718Ab0BYDMH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Feb 2010 22:12:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

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

Signed-off-by: Zhu Yi <yi.zhu@intel.com>
---
diff --git a/include/net/sock.h b/include/net/sock.h
index 3f1a480..2e003b9 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -253,6 +253,7 @@ struct sock {
 	struct {
 		struct sk_buff *head;
 		struct sk_buff *tail;
+		atomic_t len;
 	} sk_backlog;
 	wait_queue_head_t	*sk_sleep;
 	struct dst_entry	*sk_dst_cache;
@@ -583,11 +584,13 @@ static inline void sk_add_backlog(struct sock *sk, struct sk_buff *skb)
 		sk->sk_backlog.tail->next = skb;
 		sk->sk_backlog.tail = skb;
 	}
+	atomic_add(skb->truesize, &sk->sk_backlog.len);
 	skb->next = NULL;
 }
 
 static inline int sk_backlog_rcv(struct sock *sk, struct sk_buff *skb)
 {
+	atomic_sub(skb->truesize, &sk->sk_backlog.len);
 	return sk->sk_backlog_rcv(sk, skb);
 }
 
diff --git a/net/core/sock.c b/net/core/sock.c
index e1f6f22..3b988f2 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1138,6 +1138,7 @@ struct sock *sk_clone(const struct sock *sk, const gfp_t priority)
 		sock_lock_init(newsk);
 		bh_lock_sock(newsk);
 		newsk->sk_backlog.head	= newsk->sk_backlog.tail = NULL;
+		atomic_set(&newsk->sk_backlog.len, 0);
 
 		atomic_set(&newsk->sk_rmem_alloc, 0);
 		/*
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index f0126fd..e019067 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1372,8 +1372,13 @@ int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 	bh_lock_sock(sk);
 	if (!sock_owned_by_user(sk))
 		rc = __udp_queue_rcv_skb(sk, skb);
-	else
+	else {
+		if (atomic_read(&sk->sk_backlog.len) >= sk->sk_rcvbuf) {
+			bh_unlock_sock(sk);
+			goto drop;
+		}
 		sk_add_backlog(sk, skb);
+	}
 	bh_unlock_sock(sk);
 
 	return rc;



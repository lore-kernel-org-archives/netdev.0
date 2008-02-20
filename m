From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 12/28] net: wrap sk->sk_backlog_rcv()
Date: Wed, 20 Feb 2008 15:46:22 +0100
Message-ID: <20080220150306.822025000@chello.nl>
References: <20080220144610.548202000@chello.nl>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fys.uio.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep18-int.chello.at ([213.46.255.22]:55922 "EHLO
	viefep19-int.chello.at" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752860AbYBTPSg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 10:18:36 -0500
Content-Disposition: inline; filename=net-backlog.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wrap calling sk->sk_backlog_rcv() in a function. This will allow extending the
generic sk_backlog_rcv behaviour.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/net/sock.h   |    5 +++++
 include/net/tcp.h    |    2 +-
 net/core/sock.c      |    4 ++--
 net/ipv4/tcp.c       |    2 +-
 net/ipv4/tcp_timer.c |    2 +-
 5 files changed, 10 insertions(+), 5 deletions(-)

Index: linux-2.6/include/net/sock.h
===================================================================
--- linux-2.6.orig/include/net/sock.h
+++ linux-2.6/include/net/sock.h
@@ -474,6 +474,11 @@ static inline void sk_add_backlog(struct
 	skb->next = NULL;
 }
 
+static inline int sk_backlog_rcv(struct sock *sk, struct sk_buff *skb)
+{
+	return sk->sk_backlog_rcv(sk, skb);
+}
+
 #define sk_wait_event(__sk, __timeo, __condition)			\
 	({	int __rc;						\
 		release_sock(__sk);					\
Index: linux-2.6/net/core/sock.c
===================================================================
--- linux-2.6.orig/net/core/sock.c
+++ linux-2.6/net/core/sock.c
@@ -325,7 +325,7 @@ int sk_receive_skb(struct sock *sk, stru
 		 */
 		mutex_acquire(&sk->sk_lock.dep_map, 0, 1, _RET_IP_);
 
-		rc = sk->sk_backlog_rcv(sk, skb);
+		rc = sk_backlog_rcv(sk, skb);
 
 		mutex_release(&sk->sk_lock.dep_map, 1, _RET_IP_);
 	} else
@@ -1360,7 +1360,7 @@ static void __release_sock(struct sock *
 			struct sk_buff *next = skb->next;
 
 			skb->next = NULL;
-			sk->sk_backlog_rcv(sk, skb);
+			sk_backlog_rcv(sk, skb);
 
 			/*
 			 * We are in process context here with softirqs
Index: linux-2.6/net/ipv4/tcp.c
===================================================================
--- linux-2.6.orig/net/ipv4/tcp.c
+++ linux-2.6/net/ipv4/tcp.c
@@ -1158,7 +1158,7 @@ static void tcp_prequeue_process(struct 
 	 * necessary */
 	local_bh_disable();
 	while ((skb = __skb_dequeue(&tp->ucopy.prequeue)) != NULL)
-		sk->sk_backlog_rcv(sk, skb);
+		sk_backlog_rcv(sk, skb);
 	local_bh_enable();
 
 	/* Clear memory counter. */
Index: linux-2.6/net/ipv4/tcp_timer.c
===================================================================
--- linux-2.6.orig/net/ipv4/tcp_timer.c
+++ linux-2.6/net/ipv4/tcp_timer.c
@@ -203,7 +203,7 @@ static void tcp_delack_timer(unsigned lo
 		NET_INC_STATS_BH(LINUX_MIB_TCPSCHEDULERFAILED);
 
 		while ((skb = __skb_dequeue(&tp->ucopy.prequeue)) != NULL)
-			sk->sk_backlog_rcv(sk, skb);
+			sk_backlog_rcv(sk, skb);
 
 		tp->ucopy.memory = 0;
 	}
Index: linux-2.6/include/net/tcp.h
===================================================================
--- linux-2.6.orig/include/net/tcp.h
+++ linux-2.6/include/net/tcp.h
@@ -879,7 +879,7 @@ static inline int tcp_prequeue(struct so
 			BUG_ON(sock_owned_by_user(sk));
 
 			while ((skb1 = __skb_dequeue(&tp->ucopy.prequeue)) != NULL) {
-				sk->sk_backlog_rcv(sk, skb1);
+				sk_backlog_rcv(sk, skb1);
 				NET_INC_STATS_BH(LINUX_MIB_TCPPREQUEUEDROPPED);
 			}
 

--


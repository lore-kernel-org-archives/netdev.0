From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] NET : keep sk_backlog near sk_lock
Date: Thu, 22 Feb 2007 15:50:15 +0100
Message-ID: <200702221550.15280.dada1@cosmosbay.com>
References: <1171583205.29021.44.camel@localhost> <20070222.012649.119274047.davem@davemloft.net> <200702221122.02806.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_n2a3F6onLC3fE3C"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:44945 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932123AbXBVOu0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Feb 2007 09:50:26 -0500
In-Reply-To: <200702221122.02806.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Boundary-00=_n2a3F6onLC3fE3C
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi David

sk_backlog is a critical field of struct sock. (known famous words)

It is (ab)used in hot paths, in particular in release_sock(), tcp_recvmsg(), 
tcp_v4_rcv(), sk_receive_skb().

It really makes sense to place it next to sk_lock, because sk_backlog is only 
used after sk_lock locked (and thus memory cache line in L1 cache). This 
should reduce cache misses and sk_lock acquisition time.

(In theory, we could only move the head pointer near sk_lock, and leaving tail 
far away, because 'tail' is normally not so hot, but keep it simple :) )

Thank you

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

--Boundary-00=_n2a3F6onLC3fE3C
Content-Type: text/plain;
  charset="utf-8";
  name="sk_backlog.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="sk_backlog.patch"

--- linux/include/net/sock.h	2007-02-22 16:21:36.000000000 +0100
+++ linux-ed/include/net/sock.h	2007-02-22 16:21:36.000000000 +0100
@@ -202,6 +202,15 @@ struct sock {
 	unsigned short		sk_type;
 	int			sk_rcvbuf;
 	socket_lock_t		sk_lock;
+	/*
+	 * The backlog queue is special, it is always used with
+	 * the per-socket spinlock held and requires low latency
+	 * access. Therefore we special case it's implementation.
+	 */
+	struct {
+		struct sk_buff *head;
+		struct sk_buff *tail;
+	} sk_backlog;
 	wait_queue_head_t	*sk_sleep;
 	struct dst_entry	*sk_dst_cache;
 	struct xfrm_policy	*sk_policy[2];
@@ -221,15 +230,6 @@ struct sock {
 	int			sk_rcvlowat;
 	unsigned long 		sk_flags;
 	unsigned long	        sk_lingertime;
-	/*
-	 * The backlog queue is special, it is always used with
-	 * the per-socket spinlock held and requires low latency
-	 * access. Therefore we special case it's implementation.
-	 */
-	struct {
-		struct sk_buff *head;
-		struct sk_buff *tail;
-	} sk_backlog;
 	struct sk_buff_head	sk_error_queue;
 	struct proto		*sk_prot_creator;
 	rwlock_t		sk_callback_lock;
--- linux/net/core/sock.c	2007-02-22 16:21:36.000000000 +0100
+++ linux-ed/net/core/sock.c	2007-02-22 16:21:36.000000000 +0100
@@ -904,6 +904,7 @@ struct sock *sk_clone(const struct sock 
 		sk_node_init(&newsk->sk_node);
 		sock_lock_init(newsk);
 		bh_lock_sock(newsk);
+		newsk->sk_backlog.head	= newsk->sk_backlog.tail = NULL;
 
 		atomic_set(&newsk->sk_rmem_alloc, 0);
 		atomic_set(&newsk->sk_wmem_alloc, 0);
@@ -923,7 +924,6 @@ struct sock *sk_clone(const struct sock 
 		newsk->sk_wmem_queued	= 0;
 		newsk->sk_forward_alloc = 0;
 		newsk->sk_send_head	= NULL;
-		newsk->sk_backlog.head	= newsk->sk_backlog.tail = NULL;
 		newsk->sk_userlocks	= sk->sk_userlocks & ~SOCK_BINDPORT_LOCK;
 
 		sock_reset_flag(newsk, SOCK_DONE);

--Boundary-00=_n2a3F6onLC3fE3C--

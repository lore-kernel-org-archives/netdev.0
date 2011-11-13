From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch 8/8 2.6.32] net: backlog functions rename
Date: Sun, 13 Nov 2011 23:19:57 +0300
Message-ID: <20111113201957.GI1362@elgon.mountain>
References: <20111113201336.GA1362@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Kroah-Hartman <greg@kroah.com>, Zhu Yi <yi.zhu@intel.com>,
	netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: stable@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:39884 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752764Ab1KMUUS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Nov 2011 15:20:18 -0500
Content-Disposition: inline
In-Reply-To: <20111113201336.GA1362@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I had to make some trivial changes here as a result of the changes I
made in [patch 2/8 2.6.32] udp: use limited socket backlog.

>From a3a858ff18a72a8d388e31ab0d98f7e944841a62 Mon Sep 17 00:00:00 2001
From: Zhu Yi <yi.zhu@intel.com>
Date: Thu, 4 Mar 2010 18:01:47 +0000
Subject: [PATCH] net: backlog functions rename

sk_add_backlog -> __sk_add_backlog
sk_add_backlog_limited -> sk_add_backlog

Signed-off-by: Zhu Yi <yi.zhu@intel.com>
Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---

diff --git a/include/net/sock.h b/include/net/sock.h
index 5a4844a..12fdc27 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -564,7 +564,7 @@ static inline int sk_stream_memory_free(struct sock *sk)
 }
 
 /* OOB backlog add */
-static inline void sk_add_backlog(struct sock *sk, struct sk_buff *skb)
+static inline void __sk_add_backlog(struct sock *sk, struct sk_buff *skb)
 {
 	if (!sk->sk_backlog.tail) {
 		sk->sk_backlog.head = sk->sk_backlog.tail = skb;
@@ -576,12 +576,12 @@ static inline void sk_add_backlog(struct sock *sk, struct sk_buff *skb)
 }
 
 /* The per-socket spinlock must be held here. */
-static inline int sk_add_backlog_limited(struct sock *sk, struct sk_buff *skb)
+static inline int sk_add_backlog(struct sock *sk, struct sk_buff *skb)
 {
 	if (sk->sk_backlog.len >= max(sk->sk_backlog.limit, sk->sk_rcvbuf << 1))
 		return -ENOBUFS;
 
-	sk_add_backlog(sk, skb);
+	__sk_add_backlog(sk, skb);
 	sk->sk_backlog.len += skb->truesize;
 	return 0;
 }
diff --git a/net/core/sock.c b/net/core/sock.c
index 5797dab..eb191dd 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -336,7 +336,7 @@ int sk_receive_skb(struct sock *sk, struct sk_buff *skb, const int nested)
 		rc = sk_backlog_rcv(sk, skb);
 
 		mutex_release(&sk->sk_lock.dep_map, 1, _RET_IP_);
-	} else if (sk_add_backlog_limited(sk, skb)) {
+	} else if (sk_add_backlog(sk, skb)) {
 		bh_unlock_sock(sk);
 		atomic_inc(&sk->sk_drops);
 		goto discard_and_relse;
diff --git a/net/dccp/minisocks.c b/net/dccp/minisocks.c
index 5ca49ce..1d5abd2 100644
--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -254,7 +254,7 @@ int dccp_child_process(struct sock *parent, struct sock *child,
 		 * in main socket hash table and lock on listening
 		 * socket does not protect us more.
 		 */
-		sk_add_backlog(child, skb);
+		__sk_add_backlog(child, skb);
 	}
 
 	bh_unlock_sock(child);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 6e824ac1..c64db81 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1635,7 +1635,7 @@ process:
 			if (!tcp_prequeue(sk, skb))
 				ret = tcp_v4_do_rcv(sk, skb);
 		}
-	} else if (sk_add_backlog_limited(sk, skb)) {
+	} else if (sk_add_backlog(sk, skb)) {
 		bh_unlock_sock(sk);
 		goto discard_and_relse;
 	}
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 4c03598..ab7ac46 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -702,7 +702,7 @@ int tcp_child_process(struct sock *parent, struct sock *child,
 		 * in main socket hash table and lock on listening
 		 * socket does not protect us more.
 		 */
-		sk_add_backlog(child, skb);
+		__sk_add_backlog(child, skb);
 	}
 
 	bh_unlock_sock(child);
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 2eaeaf1..be49cd4 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1177,7 +1177,7 @@ int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 	bh_lock_sock(sk);
 	if (!sock_owned_by_user(sk))
 		rc = __udp_queue_rcv_skb(sk, skb);
-	else if (sk_add_backlog_limited(sk, skb)) {
+	else if (sk_add_backlog(sk, skb)) {
 		bh_unlock_sock(sk);
 		goto drop;
 	}
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index dc06299..a1114ae 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1686,7 +1686,7 @@ process:
 			if (!tcp_prequeue(sk, skb))
 				ret = tcp_v6_do_rcv(sk, skb);
 		}
-	} else if (sk_add_backlog_limited(sk, skb)) {
+	} else if (sk_add_backlog(sk, skb)) {
 		bh_unlock_sock(sk);
 		goto discard_and_relse;
 	}
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 4400eb0..e0cf8f3 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -473,7 +473,7 @@ static int __udp6_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 			bh_lock_sock(sk2);
 			if (!sock_owned_by_user(sk2))
 				udpv6_queue_rcv_skb(sk2, buff);
-			else if (sk_add_backlog_limited(sk2, buff)) {
+			else if (sk_add_backlog(sk2, buff)) {
 				kfree_skb(buff);
 				bh_unlock_sock(sk2);
 				goto out;
@@ -484,7 +484,7 @@ static int __udp6_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 	bh_lock_sock(sk);
 	if (!sock_owned_by_user(sk))
 		udpv6_queue_rcv_skb(sk, skb);
-	else if (sk_add_backlog_limited(sk, skb))
+	else if (sk_add_backlog(sk, skb))
 		kfree_skb(skb);
 	bh_unlock_sock(sk);
 out:
@@ -604,7 +604,7 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 	bh_lock_sock(sk);
 	if (!sock_owned_by_user(sk))
 		udpv6_queue_rcv_skb(sk, skb);
-	else if (sk_add_backlog_limited(sk, skb)) {
+	else if (sk_add_backlog(sk, skb)) {
 		atomic_inc(&sk->sk_drops);
 		bh_unlock_sock(sk);
 		sock_put(sk);
diff --git a/net/llc/llc_c_ac.c b/net/llc/llc_c_ac.c
index 019c780..86d6985 100644
--- a/net/llc/llc_c_ac.c
+++ b/net/llc/llc_c_ac.c
@@ -1437,7 +1437,7 @@ static void llc_process_tmr_ev(struct sock *sk, struct sk_buff *skb)
 			llc_conn_state_process(sk, skb);
 		else {
 			llc_set_backlog_type(skb, LLC_EVENT);
-			sk_add_backlog(sk, skb);
+			__sk_add_backlog(sk, skb);
 		}
 	}
 }
diff --git a/net/llc/llc_conn.c b/net/llc/llc_conn.c
index 8f97546..c61ca88 100644
--- a/net/llc/llc_conn.c
+++ b/net/llc/llc_conn.c
@@ -756,7 +756,7 @@ void llc_conn_handler(struct llc_sap *sap, struct sk_buff *skb)
 	else {
 		dprintk("%s: adding to backlog...\n", __func__);
 		llc_set_backlog_type(skb, LLC_PACKET);
-		if (sk_add_backlog_limited(sk, skb))
+		if (sk_add_backlog(sk, skb))
 			goto drop_unlock;
 	}
 out:
diff --git a/net/sctp/input.c b/net/sctp/input.c
index 3271c7b..eaacf76 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -341,7 +341,7 @@ int sctp_backlog_rcv(struct sock *sk, struct sk_buff *skb)
 		sctp_bh_lock_sock(sk);
 
 		if (sock_owned_by_user(sk)) {
-			if (sk_add_backlog_limited(sk, skb))
+			if (sk_add_backlog(sk, skb))
 				sctp_chunk_free(chunk);
 			else
 				backloged = 1;
@@ -375,7 +375,7 @@ static int sctp_add_backlog(struct sock *sk, struct sk_buff *skb)
 	struct sctp_ep_common *rcvr = chunk->rcvr;
 	int ret;
 
-	ret = sk_add_backlog_limited(sk, skb);
+	ret = sk_add_backlog(sk, skb);
 	if (!ret) {
 		/* Hold the assoc/ep while hanging on the backlog queue.
 		 * This way, we know structures we need will not disappear
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index bf4b320..f1e6629 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1323,7 +1323,7 @@ static u32 dispatch(struct tipc_port *tport, struct sk_buff *buf)
 	if (!sock_owned_by_user(sk)) {
 		res = filter_rcv(sk, buf);
 	} else {
-		if (sk_add_backlog_limited(sk, buf))
+		if (sk_add_backlog(sk, buf))
 			res = TIPC_ERR_OVERLOAD;
 		else
 			res = TIPC_OK;
diff --git a/net/x25/x25_dev.c b/net/x25/x25_dev.c
index a9da0dc..52e3042 100644
--- a/net/x25/x25_dev.c
+++ b/net/x25/x25_dev.c
@@ -53,7 +53,7 @@ static int x25_receive_data(struct sk_buff *skb, struct x25_neigh *nb)
 		if (!sock_owned_by_user(sk)) {
 			queued = x25_process_rx_frame(sk, skb);
 		} else {
-			queued = !sk_add_backlog_limited(sk, skb);
+			queued = !sk_add_backlog(sk, skb);
 		}
 		bh_unlock_sock(sk);
 		sock_put(sk);

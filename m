From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH V2 7/7] net: backlog functions rename
Date: Wed,  3 Mar 2010 16:36:29 +0800
Message-ID: <1267605389-7369-7-git-send-email-yi.zhu@intel.com>
References: <1267605389-7369-1-git-send-email-yi.zhu@intel.com>
 <1267605389-7369-2-git-send-email-yi.zhu@intel.com>
 <1267605389-7369-3-git-send-email-yi.zhu@intel.com>
 <1267605389-7369-4-git-send-email-yi.zhu@intel.com>
 <1267605389-7369-5-git-send-email-yi.zhu@intel.com>
 <1267605389-7369-6-git-send-email-yi.zhu@intel.com>
Cc: Zhu Yi <yi.zhu@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:61407 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752293Ab0CCIev (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Mar 2010 03:34:51 -0500
In-Reply-To: <1267605389-7369-6-git-send-email-yi.zhu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sk_add_backlog -> __sk_add_backlog
sk_add_backlog_limited -> sk_add_backlog

Signed-off-by: Zhu Yi <yi.zhu@intel.com>
---
 include/net/sock.h       |    6 +++---
 net/core/sock.c          |    2 +-
 net/dccp/minisocks.c     |    2 +-
 net/ipv4/tcp_ipv4.c      |    2 +-
 net/ipv4/tcp_minisocks.c |    2 +-
 net/ipv4/udp.c           |    2 +-
 net/ipv6/tcp_ipv6.c      |    2 +-
 net/ipv6/udp.c           |    4 ++--
 net/llc/llc_c_ac.c       |    2 +-
 net/llc/llc_conn.c       |    2 +-
 net/sctp/input.c         |    4 ++--
 net/tipc/socket.c        |    2 +-
 net/x25/x25_dev.c        |    2 +-
 13 files changed, 17 insertions(+), 17 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 2516d76..170353d 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -592,7 +592,7 @@ static inline int sk_stream_memory_free(struct sock *sk)
 }
 
 /* OOB backlog add */
-static inline void sk_add_backlog(struct sock *sk, struct sk_buff *skb)
+static inline void __sk_add_backlog(struct sock *sk, struct sk_buff *skb)
 {
 	if (!sk->sk_backlog.tail) {
 		sk->sk_backlog.head = sk->sk_backlog.tail = skb;
@@ -604,12 +604,12 @@ static inline void sk_add_backlog(struct sock *sk, struct sk_buff *skb)
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
index 6e22dc9..61a65a2 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -340,7 +340,7 @@ int sk_receive_skb(struct sock *sk, struct sk_buff *skb, const int nested)
 		rc = sk_backlog_rcv(sk, skb);
 
 		mutex_release(&sk->sk_lock.dep_map, 1, _RET_IP_);
-	} else if (sk_add_backlog_limited(sk, skb)) {
+	} else if (sk_add_backlog(sk, skb)) {
 		bh_unlock_sock(sk);
 		atomic_inc(&sk->sk_drops);
 		goto discard_and_relse;
diff --git a/net/dccp/minisocks.c b/net/dccp/minisocks.c
index af226a0..0d508c3 100644
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
index 4baf194..1915f7d 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1682,7 +1682,7 @@ process:
 			if (!tcp_prequeue(sk, skb))
 				ret = tcp_v4_do_rcv(sk, skb);
 		}
-	} else if (sk_add_backlog_limited(sk, skb)) {
+	} else if (sk_add_backlog(sk, skb)) {
 		bh_unlock_sock(sk);
 		goto discard_and_relse;
 	}
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index f206ee5..4199bc6 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -728,7 +728,7 @@ int tcp_child_process(struct sock *parent, struct sock *child,
 		 * in main socket hash table and lock on listening
 		 * socket does not protect us more.
 		 */
-		sk_add_backlog(child, skb);
+		__sk_add_backlog(child, skb);
 	}
 
 	bh_unlock_sock(child);
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index e7eb47f..7af756d 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1371,7 +1371,7 @@ int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 	bh_lock_sock(sk);
 	if (!sock_owned_by_user(sk))
 		rc = __udp_queue_rcv_skb(sk, skb);
-	else if (sk_add_backlog_limited(sk, skb)) {
+	else if (sk_add_backlog(sk, skb)) {
 		bh_unlock_sock(sk);
 		goto drop;
 	}
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index c4ea9d5..2c378b1 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1740,7 +1740,7 @@ process:
 			if (!tcp_prequeue(sk, skb))
 				ret = tcp_v6_do_rcv(sk, skb);
 		}
-	} else if (sk_add_backlog_limited(sk, skb)) {
+	} else if (sk_add_backlog(sk, skb)) {
 		bh_unlock_sock(sk);
 		goto discard_and_relse;
 	}
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 6480491..3c0c9c7 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -583,7 +583,7 @@ static void flush_stack(struct sock **stack, unsigned int count,
 			bh_lock_sock(sk);
 			if (!sock_owned_by_user(sk))
 				udpv6_queue_rcv_skb(sk, skb1);
-			else if (sk_add_backlog_limited(sk, skb1)) {
+			else if (sk_add_backlog(sk, skb1)) {
 				kfree_skb(skb1);
 				bh_unlock_sock(sk);
 				goto drop;
@@ -758,7 +758,7 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
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
index c0539ff..a12144d 100644
--- a/net/llc/llc_conn.c
+++ b/net/llc/llc_conn.c
@@ -827,7 +827,7 @@ void llc_conn_handler(struct llc_sap *sap, struct sk_buff *skb)
 	else {
 		dprintk("%s: adding to backlog...\n", __func__);
 		llc_set_backlog_type(skb, LLC_PACKET);
-		if (sk_add_backlog_limited(sk, skb))
+		if (sk_add_backlog(sk, skb))
 			goto drop_unlock;
 	}
 out:
diff --git a/net/sctp/input.c b/net/sctp/input.c
index 20e69c3..ca42181 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -340,7 +340,7 @@ int sctp_backlog_rcv(struct sock *sk, struct sk_buff *skb)
 		sctp_bh_lock_sock(sk);
 
 		if (sock_owned_by_user(sk)) {
-			sk_add_backlog(sk, skb);
+			__sk_add_backlog(sk, skb);
 			backloged = 1;
 		} else
 			sctp_inq_push(inqueue, chunk);
@@ -381,7 +381,7 @@ static int sctp_add_backlog(struct sock *sk, struct sk_buff *skb)
 	else
 		BUG();
 
-	return sk_add_backlog_limited(sk, skb);
+	return sk_add_backlog(sk, skb);
 }
 
 /* Handle icmp frag needed error. */
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 22bfbc3..4b235fc 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1322,7 +1322,7 @@ static u32 dispatch(struct tipc_port *tport, struct sk_buff *buf)
 	if (!sock_owned_by_user(sk)) {
 		res = filter_rcv(sk, buf);
 	} else {
-		if (sk_add_backlog_limited(sk, buf))
+		if (sk_add_backlog(sk, buf))
 			res = TIPC_ERR_OVERLOAD;
 		else
 			res = TIPC_OK;
diff --git a/net/x25/x25_dev.c b/net/x25/x25_dev.c
index 3e1efe5..5688123 100644
--- a/net/x25/x25_dev.c
+++ b/net/x25/x25_dev.c
@@ -53,7 +53,7 @@ static int x25_receive_data(struct sk_buff *skb, struct x25_neigh *nb)
 		if (!sock_owned_by_user(sk)) {
 			queued = x25_process_rx_frame(sk, skb);
 		} else {
-			sk_add_backlog(sk, skb);
+			__sk_add_backlog(sk, skb);
 		}
 		bh_unlock_sock(sk);
 		sock_put(sk);
-- 
1.6.3.3


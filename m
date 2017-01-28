From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCHv2 RFC net-next 1/7] sock: add sk_dst_pending_confirm flag
Date: Sat, 28 Jan 2017 16:26:12 +0200
Message-ID: <1485613578-19973-2-git-send-email-ja@ssi.bg>
References: <1485613578-19973-1-git-send-email-ja@ssi.bg>
Cc: linux-sctp@vger.kernel.org, YueHaibing <yuehaibing@huawei.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:43490 "EHLO ja.ssi.bg"
        rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752003AbdA1O1z (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 28 Jan 2017 09:27:55 -0500
In-Reply-To: <1485613578-19973-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add new sock flag to allow sockets to confirm neighbour.
When same struct dst_entry can be used for many different
neighbours we can not use it for pending confirmations.
As not all call paths lock the socket use full word for
the flag.

Add sk_dst_confirm as replacement for dst_confirm when
called for received packets.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 include/net/sock.h | 12 ++++++++++++
 net/core/sock.c    |  2 ++
 2 files changed, 14 insertions(+)

diff --git a/include/net/sock.h b/include/net/sock.h
index 7144750..e113786 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -240,6 +240,7 @@ struct sock_common {
   *	@sk_wq: sock wait queue and async head
   *	@sk_rx_dst: receive input route used by early demux
   *	@sk_dst_cache: destination cache
+  *	@sk_dst_pending_confirm: need to confirm neighbour
   *	@sk_policy: flow policy
   *	@sk_receive_queue: incoming packets
   *	@sk_wmem_alloc: transmit queue bytes committed
@@ -393,6 +394,8 @@ struct sock {
 	struct sk_buff_head	sk_write_queue;
 	__s32			sk_peek_off;
 	int			sk_write_pending;
+	__u32			sk_dst_pending_confirm;
+	/* Note: 32bit hole on 64bit arches */
 	long			sk_sndtimeo;
 	struct timer_list	sk_timer;
 	__u32			sk_priority;
@@ -1764,6 +1767,7 @@ static inline void dst_negative_advice(struct sock *sk)
 		if (ndst != dst) {
 			rcu_assign_pointer(sk->sk_dst_cache, ndst);
 			sk_tx_queue_clear(sk);
+			sk->sk_dst_pending_confirm = 0;
 		}
 	}
 }
@@ -1774,6 +1778,7 @@ static inline void dst_negative_advice(struct sock *sk)
 	struct dst_entry *old_dst;
 
 	sk_tx_queue_clear(sk);
+	sk->sk_dst_pending_confirm = 0;
 	/*
 	 * This can be called while sk is owned by the caller only,
 	 * with no state that can be checked in a rcu_dereference_check() cond
@@ -1789,6 +1794,7 @@ static inline void dst_negative_advice(struct sock *sk)
 	struct dst_entry *old_dst;
 
 	sk_tx_queue_clear(sk);
+	sk->sk_dst_pending_confirm = 0;
 	old_dst = xchg((__force struct dst_entry **)&sk->sk_dst_cache, dst);
 	dst_release(old_dst);
 }
@@ -1809,6 +1815,12 @@ static inline void dst_negative_advice(struct sock *sk)
 
 struct dst_entry *sk_dst_check(struct sock *sk, u32 cookie);
 
+static inline void sk_dst_confirm(struct sock *sk)
+{
+	if (!sk->sk_dst_pending_confirm)
+		sk->sk_dst_pending_confirm = 1;
+}
+
 bool sk_mc_loop(struct sock *sk);
 
 static inline bool sk_can_gso(const struct sock *sk)
diff --git a/net/core/sock.c b/net/core/sock.c
index 8b35debf..b743565 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -502,6 +502,7 @@ struct dst_entry *__sk_dst_check(struct sock *sk, u32 cookie)
 
 	if (dst && dst->obsolete && dst->ops->check(dst, cookie) == NULL) {
 		sk_tx_queue_clear(sk);
+		sk->sk_dst_pending_confirm = 0;
 		RCU_INIT_POINTER(sk->sk_dst_cache, NULL);
 		dst_release(dst);
 		return NULL;
@@ -1519,6 +1520,7 @@ struct sock *sk_clone_lock(const struct sock *sk, const gfp_t priority)
 				af_family_clock_key_strings[newsk->sk_family]);
 
 		newsk->sk_dst_cache	= NULL;
+		newsk->sk_dst_pending_confirm = 0;
 		newsk->sk_wmem_queued	= 0;
 		newsk->sk_forward_alloc = 0;
 		atomic_set(&newsk->sk_drops, 0);
-- 
1.9.3

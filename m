From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net-next] tcp: socket option to set TCP fast open key
Date: Wed, 18 Oct 2017 11:22:51 -0700
Message-ID: <20171018182251.5486-1-ycheng@google.com>
Cc: netdev@vger.kernel.org, cpaasch@apple.com, edumazet@google.com,
        ncardwell@google.com, maheshb@google.com,
        Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:43826 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750800AbdJRSXO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 14:23:14 -0400
Received: by mail-io0-f196.google.com with SMTP id 134so7244666ioo.0
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 11:23:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

New socket option TCP_FASTOPEN_KEY to allow different keys per
listener.  The listener by default uses the global key until the
socket option is set.  The key is a 16 bytes long binary data. This
option has no effect on regular non-listener TCP sockets.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
Reviewed-by: Eric Dumazet <edumazet@google.com>
---
 include/net/request_sock.h |  2 ++
 include/net/tcp.h          |  5 +++--
 include/uapi/linux/tcp.h   |  1 +
 net/ipv4/sysctl_net_ipv4.c |  3 ++-
 net/ipv4/tcp.c             | 33 +++++++++++++++++++++++++++
 net/ipv4/tcp_fastopen.c    | 56 +++++++++++++++++++++++++++++++++-------------
 net/ipv4/tcp_ipv4.c        |  1 +
 7 files changed, 82 insertions(+), 19 deletions(-)

diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index 23e22054aa60..347015515a7d 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -150,6 +150,8 @@ struct fastopen_queue {
 	spinlock_t	lock;
 	int		qlen;		/* # of pending (TCP_SYN_RECV) reqs */
 	int		max_qlen;	/* != 0 iff TFO is currently enabled */
+
+	struct tcp_fastopen_context __rcu *ctx; /* cipher context for cookie */
 };
 
 /** struct request_sock_queue - queue of request_socks
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 3b3b9b968e2d..1efe8365cb28 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1555,9 +1555,10 @@ struct tcp_fastopen_request {
 	int				copied;	/* queued in tcp_connect() */
 };
 void tcp_free_fastopen_req(struct tcp_sock *tp);
-
+void tcp_fastopen_destroy_cipher(struct sock *sk);
 void tcp_fastopen_ctx_destroy(struct net *net);
-int tcp_fastopen_reset_cipher(struct net *net, void *key, unsigned int len);
+int tcp_fastopen_reset_cipher(struct net *net, struct sock *sk,
+			      void *key, unsigned int len);
 void tcp_fastopen_add_skb(struct sock *sk, struct sk_buff *skb);
 struct sock *tcp_try_fastopen(struct sock *sk, struct sk_buff *skb,
 			      struct request_sock *req,
diff --git a/include/uapi/linux/tcp.h b/include/uapi/linux/tcp.h
index 15c25eccab2b..69c7493e42f8 100644
--- a/include/uapi/linux/tcp.h
+++ b/include/uapi/linux/tcp.h
@@ -119,6 +119,7 @@ enum {
 #define TCP_FASTOPEN_CONNECT	30	/* Attempt FastOpen with connect */
 #define TCP_ULP			31	/* Attach a ULP to a TCP connection */
 #define TCP_MD5SIG_EXT		32	/* TCP MD5 Signature with extensions */
+#define TCP_FASTOPEN_KEY	33	/* Set the key for Fast Open (cookie) */
 
 struct tcp_repair_opt {
 	__u32	opt_code;
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index cac8dd309f39..81d218346cf7 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -284,7 +284,8 @@ static int proc_tcp_fastopen_key(struct ctl_table *table, int write,
 			ret = -EINVAL;
 			goto bad_key;
 		}
-		tcp_fastopen_reset_cipher(net, user_key, TCP_FASTOPEN_KEY_LENGTH);
+		tcp_fastopen_reset_cipher(net, NULL, user_key,
+					  TCP_FASTOPEN_KEY_LENGTH);
 	}
 
 bad_key:
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 3b34850d361f..8b1fa4dd4538 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2571,6 +2571,17 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 		release_sock(sk);
 		return err;
 	}
+	case TCP_FASTOPEN_KEY: {
+		__u8 key[TCP_FASTOPEN_KEY_LENGTH];
+
+		if (optlen != sizeof(key))
+			return -EINVAL;
+
+		if (copy_from_user(key, optval, optlen))
+			return -EFAULT;
+
+		return tcp_fastopen_reset_cipher(net, sk, key, sizeof(key));
+	}
 	default:
 		/* fallthru */
 		break;
@@ -3157,6 +3168,28 @@ static int do_tcp_getsockopt(struct sock *sk, int level,
 			return -EFAULT;
 		return 0;
 
+	case TCP_FASTOPEN_KEY: {
+		__u8 key[TCP_FASTOPEN_KEY_LENGTH];
+		struct tcp_fastopen_context *ctx;
+
+		if (get_user(len, optlen))
+			return -EFAULT;
+
+		rcu_read_lock();
+		ctx = rcu_dereference(icsk->icsk_accept_queue.fastopenq.ctx);
+		if (ctx)
+			memcpy(key, ctx->key, sizeof(key));
+		else
+			len = 0;
+		rcu_read_unlock();
+
+		len = min_t(unsigned int, len, sizeof(key));
+		if (put_user(len, optlen))
+			return -EFAULT;
+		if (copy_to_user(optval, key, len))
+			return -EFAULT;
+		return 0;
+	}
 	case TCP_THIN_LINEAR_TIMEOUTS:
 		val = tp->thin_lto;
 		break;
diff --git a/net/ipv4/tcp_fastopen.c b/net/ipv4/tcp_fastopen.c
index 7ee4aadcdd71..21075ce19cb6 100644
--- a/net/ipv4/tcp_fastopen.c
+++ b/net/ipv4/tcp_fastopen.c
@@ -29,7 +29,7 @@ void tcp_fastopen_init_key_once(struct net *net)
 	 * for a valid cookie, so this is an acceptable risk.
 	 */
 	get_random_bytes(key, sizeof(key));
-	tcp_fastopen_reset_cipher(net, key, sizeof(key));
+	tcp_fastopen_reset_cipher(net, NULL, key, sizeof(key));
 }
 
 static void tcp_fastopen_ctx_free(struct rcu_head *head)
@@ -40,6 +40,16 @@ static void tcp_fastopen_ctx_free(struct rcu_head *head)
 	kfree(ctx);
 }
 
+void tcp_fastopen_destroy_cipher(struct sock *sk)
+{
+	struct tcp_fastopen_context *ctx;
+
+	ctx = rcu_dereference_protected(
+			inet_csk(sk)->icsk_accept_queue.fastopenq.ctx, 1);
+	if (ctx)
+		call_rcu(&ctx->rcu, tcp_fastopen_ctx_free);
+}
+
 void tcp_fastopen_ctx_destroy(struct net *net)
 {
 	struct tcp_fastopen_context *ctxt;
@@ -55,10 +65,12 @@ void tcp_fastopen_ctx_destroy(struct net *net)
 		call_rcu(&ctxt->rcu, tcp_fastopen_ctx_free);
 }
 
-int tcp_fastopen_reset_cipher(struct net *net, void *key, unsigned int len)
+int tcp_fastopen_reset_cipher(struct net *net, struct sock *sk,
+			      void *key, unsigned int len)
 {
-	int err;
 	struct tcp_fastopen_context *ctx, *octx;
+	struct fastopen_queue *q;
+	int err;
 
 	ctx = kmalloc(sizeof(*ctx), GFP_KERNEL);
 	if (!ctx)
@@ -79,27 +91,39 @@ error:		kfree(ctx);
 	}
 	memcpy(ctx->key, key, len);
 
-	spin_lock(&net->ipv4.tcp_fastopen_ctx_lock);
 
-	octx = rcu_dereference_protected(net->ipv4.tcp_fastopen_ctx,
-				lockdep_is_held(&net->ipv4.tcp_fastopen_ctx_lock));
-	rcu_assign_pointer(net->ipv4.tcp_fastopen_ctx, ctx);
-	spin_unlock(&net->ipv4.tcp_fastopen_ctx_lock);
+	if (sk) {
+		q = &inet_csk(sk)->icsk_accept_queue.fastopenq;
+		spin_lock_bh(&q->lock);
+		octx = rcu_dereference_protected(q->ctx,
+						 lockdep_is_held(&q->lock));
+		rcu_assign_pointer(q->ctx, ctx);
+		spin_unlock_bh(&q->lock);
+	} else {
+		spin_lock(&net->ipv4.tcp_fastopen_ctx_lock);
+		octx = rcu_dereference_protected(net->ipv4.tcp_fastopen_ctx,
+			lockdep_is_held(&net->ipv4.tcp_fastopen_ctx_lock));
+		rcu_assign_pointer(net->ipv4.tcp_fastopen_ctx, ctx);
+		spin_unlock(&net->ipv4.tcp_fastopen_ctx_lock);
+	}
 
 	if (octx)
 		call_rcu(&octx->rcu, tcp_fastopen_ctx_free);
 	return err;
 }
 
-static bool __tcp_fastopen_cookie_gen(struct net *net,
-				      const void *path,
+static bool __tcp_fastopen_cookie_gen(struct sock *sk, const void *path,
 				      struct tcp_fastopen_cookie *foc)
 {
 	struct tcp_fastopen_context *ctx;
 	bool ok = false;
 
 	rcu_read_lock();
-	ctx = rcu_dereference(net->ipv4.tcp_fastopen_ctx);
+
+	ctx = rcu_dereference(inet_csk(sk)->icsk_accept_queue.fastopenq.ctx);
+	if (!ctx)
+		ctx = rcu_dereference(sock_net(sk)->ipv4.tcp_fastopen_ctx);
+
 	if (ctx) {
 		crypto_cipher_encrypt_one(ctx->tfm, foc->val, path);
 		foc->len = TCP_FASTOPEN_COOKIE_SIZE;
@@ -115,7 +139,7 @@ static bool __tcp_fastopen_cookie_gen(struct net *net,
  *
  * XXX (TFO) - refactor when TCP_FASTOPEN_COOKIE_SIZE != AES_BLOCK_SIZE.
  */
-static bool tcp_fastopen_cookie_gen(struct net *net,
+static bool tcp_fastopen_cookie_gen(struct sock *sk,
 				    struct request_sock *req,
 				    struct sk_buff *syn,
 				    struct tcp_fastopen_cookie *foc)
@@ -124,7 +148,7 @@ static bool tcp_fastopen_cookie_gen(struct net *net,
 		const struct iphdr *iph = ip_hdr(syn);
 
 		__be32 path[4] = { iph->saddr, iph->daddr, 0, 0 };
-		return __tcp_fastopen_cookie_gen(net, path, foc);
+		return __tcp_fastopen_cookie_gen(sk, path, foc);
 	}
 
 #if IS_ENABLED(CONFIG_IPV6)
@@ -132,13 +156,13 @@ static bool tcp_fastopen_cookie_gen(struct net *net,
 		const struct ipv6hdr *ip6h = ipv6_hdr(syn);
 		struct tcp_fastopen_cookie tmp;
 
-		if (__tcp_fastopen_cookie_gen(net, &ip6h->saddr, &tmp)) {
+		if (__tcp_fastopen_cookie_gen(sk, &ip6h->saddr, &tmp)) {
 			struct in6_addr *buf = &tmp.addr;
 			int i;
 
 			for (i = 0; i < 4; i++)
 				buf->s6_addr32[i] ^= ip6h->daddr.s6_addr32[i];
-			return __tcp_fastopen_cookie_gen(net, buf, foc);
+			return __tcp_fastopen_cookie_gen(sk, buf, foc);
 		}
 	}
 #endif
@@ -313,7 +337,7 @@ struct sock *tcp_try_fastopen(struct sock *sk, struct sk_buff *skb,
 		goto fastopen;
 
 	if (foc->len >= 0 &&  /* Client presents or requests a cookie */
-	    tcp_fastopen_cookie_gen(sock_net(sk), req, skb, &valid_foc) &&
+	    tcp_fastopen_cookie_gen(sk, req, skb, &valid_foc) &&
 	    foc->len == TCP_FASTOPEN_COOKIE_SIZE &&
 	    foc->len == valid_foc.len &&
 	    !memcmp(foc->val, valid_foc.val, foc->len)) {
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 5418ecf03b78..d80e1313200a 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1892,6 +1892,7 @@ void tcp_v4_destroy_sock(struct sock *sk)
 
 	/* If socket is aborted during connect operation */
 	tcp_free_fastopen_req(tp);
+	tcp_fastopen_destroy_cipher(sk);
 	tcp_saved_syn_free(tp);
 
 	sk_sockets_allocated_dec(sk);
-- 
2.15.0.rc1.287.g2b38de12cc-goog

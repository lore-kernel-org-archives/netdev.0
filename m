From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Subject: [Patch v3 2/3] ipv4: Namespaceify tcp_fastopen_key knob
Date: Tue, 19 Sep 2017 17:38:15 +0800
Message-ID: <1505813896-12121-2-git-send-email-yanhaishuang@cmss.chinamobile.com>
References: <1505813896-12121-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
To: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Eric Dumazet <edumazet@google.com>,
        Wei Wang <weiwan@google.com>, Luca BRUNO <lucab@debian.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1505813896-12121-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Different namespace application might require different tcp_fastopen_key
independently of the host.

Tested:
1. Container namespace:
# cat /proc/sys/net/ipv4/tcp_fastopen_key:
2817fff2-f803cf97-eadfd1f3-78c0992b

cookie key in tcp syn packets:
Fast Open Cookie
    Kind: TCP Fast Open Cookie (34)
    Length: 10
    Fast Open Cookie: 1e5dd82a8c492ca9

2. Host:
# cat /proc/sys/net/ipv4/tcp_fastopen_key:
107d7c5f-68eb2ac7-02fb06e6-ed341702

cookie key in tcp syn packets:
Fast Open Cookie
    Kind: TCP Fast Open Cookie (34)
    Length: 10
    Fast Open Cookie: e213c02bf0afbc8a

Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
---
 include/net/netns/ipv4.h   |  4 ++++
 include/net/tcp.h          |  5 ++---
 net/ipv4/af_inet.c         |  2 +-
 net/ipv4/sysctl_net_ipv4.c | 26 ++++++++++++------------
 net/ipv4/tcp.c             |  2 +-
 net/ipv4/tcp_fastopen.c    | 49 ++++++++++++++++++++++++++--------------------
 net/ipv4/tcp_ipv4.c        |  1 +
 7 files changed, 49 insertions(+), 40 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index ce6dde0..66b8335 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -36,6 +36,8 @@ struct inet_timewait_death_row {
 	int			sysctl_max_tw_buckets;
 };
 
+struct tcp_fastopen_context;
+
 struct netns_ipv4 {
 #ifdef CONFIG_SYSCTL
 	struct ctl_table_header	*forw_hdr;
@@ -128,6 +130,8 @@ struct netns_ipv4 {
 	struct inet_timewait_death_row tcp_death_row;
 	int sysctl_max_syn_backlog;
 	int sysctl_tcp_fastopen;
+	struct tcp_fastopen_context __rcu *tcp_fastopen_ctx;
+	spinlock_t tcp_fastopen_ctx_lock;
 
 #ifdef CONFIG_NET_L3_MASTER_DEV
 	int sysctl_udp_l3mdev_accept;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index f628967..f249c7e 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1556,13 +1556,12 @@ struct tcp_fastopen_request {
 };
 void tcp_free_fastopen_req(struct tcp_sock *tp);
 
-extern struct tcp_fastopen_context __rcu *tcp_fastopen_ctx;
-int tcp_fastopen_reset_cipher(void *key, unsigned int len);
+int tcp_fastopen_reset_cipher(struct net *net, void *key, unsigned int len);
 void tcp_fastopen_add_skb(struct sock *sk, struct sk_buff *skb);
 struct sock *tcp_try_fastopen(struct sock *sk, struct sk_buff *skb,
 			      struct request_sock *req,
 			      struct tcp_fastopen_cookie *foc);
-void tcp_fastopen_init_key_once(bool publish);
+void tcp_fastopen_init_key_once(struct net *net);
 bool tcp_fastopen_cookie_check(struct sock *sk, u16 *mss,
 			     struct tcp_fastopen_cookie *cookie);
 bool tcp_fastopen_defer_connect(struct sock *sk, int *err);
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 309b849..5d4d9a3 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -222,7 +222,7 @@ int inet_listen(struct socket *sock, int backlog)
 		    (tcp_fastopen & TFO_SERVER_ENABLE) &&
 		    !inet_csk(sk)->icsk_accept_queue.fastopenq.max_qlen) {
 			fastopen_queue_tune(sk, backlog);
-			tcp_fastopen_init_key_once(true);
+			tcp_fastopen_init_key_once(sock_net(sk));
 		}
 
 		err = inet_csk_listen_start(sk, backlog);
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index e31e853c..20e19fe 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -251,10 +251,12 @@ static int proc_allowed_congestion_control(struct ctl_table *ctl,
 	return ret;
 }
 
-static int proc_tcp_fastopen_key(struct ctl_table *ctl, int write,
+static int proc_tcp_fastopen_key(struct ctl_table *table, int write,
 				 void __user *buffer, size_t *lenp,
 				 loff_t *ppos)
 {
+	struct net *net = container_of(table->data, struct net,
+	    ipv4.sysctl_tcp_fastopen);
 	struct ctl_table tbl = { .maxlen = (TCP_FASTOPEN_KEY_LENGTH * 2 + 10) };
 	struct tcp_fastopen_context *ctxt;
 	int ret;
@@ -265,7 +267,7 @@ static int proc_tcp_fastopen_key(struct ctl_table *ctl, int write,
 		return -ENOMEM;
 
 	rcu_read_lock();
-	ctxt = rcu_dereference(tcp_fastopen_ctx);
+	ctxt = rcu_dereference(net->ipv4.tcp_fastopen_ctx);
 	if (ctxt)
 		memcpy(user_key, ctxt->key, TCP_FASTOPEN_KEY_LENGTH);
 	else
@@ -282,12 +284,7 @@ static int proc_tcp_fastopen_key(struct ctl_table *ctl, int write,
 			ret = -EINVAL;
 			goto bad_key;
 		}
-		/* Generate a dummy secret but don't publish it. This
-		 * is needed so we don't regenerate a new key on the
-		 * first invocation of tcp_fastopen_cookie_gen
-		 */
-		tcp_fastopen_init_key_once(false);
-		tcp_fastopen_reset_cipher(user_key, TCP_FASTOPEN_KEY_LENGTH);
+		tcp_fastopen_reset_cipher(net, user_key, TCP_FASTOPEN_KEY_LENGTH);
 	}
 
 bad_key:
@@ -401,12 +398,6 @@ static int proc_tcp_available_ulp(struct ctl_table *ctl,
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.procname	= "tcp_fastopen_key",
-		.mode		= 0600,
-		.maxlen		= ((TCP_FASTOPEN_KEY_LENGTH * 2) + 10),
-		.proc_handler	= proc_tcp_fastopen_key,
-	},
-	{
 		.procname	= "tcp_fastopen_blackhole_timeout_sec",
 		.data		= &sysctl_tcp_fastopen_blackhole_timeout,
 		.maxlen		= sizeof(int),
@@ -1085,6 +1076,13 @@ static int proc_tcp_available_ulp(struct ctl_table *ctl,
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
+	{
+		.procname	= "tcp_fastopen_key",
+		.mode		= 0600,
+		.data		= &init_net.ipv4.sysctl_tcp_fastopen,
+		.maxlen		= ((TCP_FASTOPEN_KEY_LENGTH * 2) + 10),
+		.proc_handler	= proc_tcp_fastopen_key,
+	},
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 	{
 		.procname	= "fib_multipath_use_neigh",
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index dac56c4..23225c9 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2749,7 +2749,7 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 	case TCP_FASTOPEN:
 		if (val >= 0 && ((1 << sk->sk_state) & (TCPF_CLOSE |
 		    TCPF_LISTEN))) {
-			tcp_fastopen_init_key_once(true);
+			tcp_fastopen_init_key_once(net);
 
 			fastopen_queue_tune(sk, val);
 		} else {
diff --git a/net/ipv4/tcp_fastopen.c b/net/ipv4/tcp_fastopen.c
index 9bd4ca5..21783c7 100644
--- a/net/ipv4/tcp_fastopen.c
+++ b/net/ipv4/tcp_fastopen.c
@@ -9,13 +9,18 @@
 #include <net/inetpeer.h>
 #include <net/tcp.h>
 
-struct tcp_fastopen_context __rcu *tcp_fastopen_ctx;
-
-static DEFINE_SPINLOCK(tcp_fastopen_ctx_lock);
-
-void tcp_fastopen_init_key_once(bool publish)
+void tcp_fastopen_init_key_once(struct net *net)
 {
-	static u8 key[TCP_FASTOPEN_KEY_LENGTH];
+	u8 key[TCP_FASTOPEN_KEY_LENGTH];
+	struct tcp_fastopen_context *ctxt;
+
+	rcu_read_lock();
+	ctxt = rcu_dereference(net->ipv4.tcp_fastopen_ctx);
+	if (ctxt) {
+		rcu_read_unlock();
+		return;
+	}
+	rcu_read_unlock();
 
 	/* tcp_fastopen_reset_cipher publishes the new context
 	 * atomically, so we allow this race happening here.
@@ -23,8 +28,8 @@ void tcp_fastopen_init_key_once(bool publish)
 	 * All call sites of tcp_fastopen_cookie_gen also check
 	 * for a valid cookie, so this is an acceptable risk.
 	 */
-	if (net_get_random_once(key, sizeof(key)) && publish)
-		tcp_fastopen_reset_cipher(key, sizeof(key));
+	get_random_bytes(key, sizeof(key));
+	tcp_fastopen_reset_cipher(net, key, sizeof(key));
 }
 
 static void tcp_fastopen_ctx_free(struct rcu_head *head)
@@ -35,7 +40,7 @@ static void tcp_fastopen_ctx_free(struct rcu_head *head)
 	kfree(ctx);
 }
 
-int tcp_fastopen_reset_cipher(void *key, unsigned int len)
+int tcp_fastopen_reset_cipher(struct net *net, void *key, unsigned int len)
 {
 	int err;
 	struct tcp_fastopen_context *ctx, *octx;
@@ -59,26 +64,27 @@ int tcp_fastopen_reset_cipher(void *key, unsigned int len)
 	}
 	memcpy(ctx->key, key, len);
 
-	spin_lock(&tcp_fastopen_ctx_lock);
+	spin_lock(&net->ipv4.tcp_fastopen_ctx_lock);
 
-	octx = rcu_dereference_protected(tcp_fastopen_ctx,
-				lockdep_is_held(&tcp_fastopen_ctx_lock));
-	rcu_assign_pointer(tcp_fastopen_ctx, ctx);
-	spin_unlock(&tcp_fastopen_ctx_lock);
+	octx = rcu_dereference_protected(net->ipv4.tcp_fastopen_ctx,
+				lockdep_is_held(&net->ipv4.tcp_fastopen_ctx_lock));
+	rcu_assign_pointer(net->ipv4.tcp_fastopen_ctx, ctx);
+	spin_unlock(&net->ipv4.tcp_fastopen_ctx_lock);
 
 	if (octx)
 		call_rcu(&octx->rcu, tcp_fastopen_ctx_free);
 	return err;
 }
 
-static bool __tcp_fastopen_cookie_gen(const void *path,
+static bool __tcp_fastopen_cookie_gen(struct net *net,
+				      const void *path,
 				      struct tcp_fastopen_cookie *foc)
 {
 	struct tcp_fastopen_context *ctx;
 	bool ok = false;
 
 	rcu_read_lock();
-	ctx = rcu_dereference(tcp_fastopen_ctx);
+	ctx = rcu_dereference(net->ipv4.tcp_fastopen_ctx);
 	if (ctx) {
 		crypto_cipher_encrypt_one(ctx->tfm, foc->val, path);
 		foc->len = TCP_FASTOPEN_COOKIE_SIZE;
@@ -94,7 +100,8 @@ static bool __tcp_fastopen_cookie_gen(const void *path,
  *
  * XXX (TFO) - refactor when TCP_FASTOPEN_COOKIE_SIZE != AES_BLOCK_SIZE.
  */
-static bool tcp_fastopen_cookie_gen(struct request_sock *req,
+static bool tcp_fastopen_cookie_gen(struct net *net,
+				    struct request_sock *req,
 				    struct sk_buff *syn,
 				    struct tcp_fastopen_cookie *foc)
 {
@@ -102,7 +109,7 @@ static bool tcp_fastopen_cookie_gen(struct request_sock *req,
 		const struct iphdr *iph = ip_hdr(syn);
 
 		__be32 path[4] = { iph->saddr, iph->daddr, 0, 0 };
-		return __tcp_fastopen_cookie_gen(path, foc);
+		return __tcp_fastopen_cookie_gen(net, path, foc);
 	}
 
 #if IS_ENABLED(CONFIG_IPV6)
@@ -110,13 +117,13 @@ static bool tcp_fastopen_cookie_gen(struct request_sock *req,
 		const struct ipv6hdr *ip6h = ipv6_hdr(syn);
 		struct tcp_fastopen_cookie tmp;
 
-		if (__tcp_fastopen_cookie_gen(&ip6h->saddr, &tmp)) {
+		if (__tcp_fastopen_cookie_gen(net, &ip6h->saddr, &tmp)) {
 			struct in6_addr *buf = &tmp.addr;
 			int i;
 
 			for (i = 0; i < 4; i++)
 				buf->s6_addr32[i] ^= ip6h->daddr.s6_addr32[i];
-			return __tcp_fastopen_cookie_gen(buf, foc);
+			return __tcp_fastopen_cookie_gen(net, buf, foc);
 		}
 	}
 #endif
@@ -296,7 +303,7 @@ struct sock *tcp_try_fastopen(struct sock *sk, struct sk_buff *skb,
 		goto fastopen;
 
 	if (foc->len >= 0 &&  /* Client presents or requests a cookie */
-	    tcp_fastopen_cookie_gen(req, skb, &valid_foc) &&
+	    tcp_fastopen_cookie_gen(sock_net(sk), req, skb, &valid_foc) &&
 	    foc->len == TCP_FASTOPEN_COOKIE_SIZE &&
 	    foc->len == valid_foc.len &&
 	    !memcmp(foc->val, valid_foc.val, foc->len)) {
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 88409b1..29e042c 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2473,6 +2473,7 @@ static int __net_init tcp_sk_init(struct net *net)
 	net->ipv4.sysctl_tcp_timestamps = 1;
 
 	net->ipv4.sysctl_tcp_fastopen = TFO_CLIENT_ENABLE;
+	spin_lock_init(&net->ipv4.tcp_fastopen_ctx_lock);
 
 	return 0;
 fail:
-- 
1.8.3.1

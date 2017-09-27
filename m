From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Subject: [PATCH v5 3/4] ipv4: Namespaceify tcp_fastopen_key knob
Date: Wed, 27 Sep 2017 11:35:42 +0800
Message-ID: <1506483343-11544-3-git-send-email-yanhaishuang@cmss.chinamobile.com>
References: <1506483343-11544-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
To: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Eric Dumazet <edumazet@google.com>,
        Wei Wang <weiwan@google.com>, Luca BRUNO <lucab@debian.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta2.chinamobile.com ([221.176.66.80]:19311 "EHLO
        cmccmta2.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1031773AbdI0DgJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2017 23:36:09 -0400
In-Reply-To: <1506483343-11544-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Different namespace application might require different tcp_fastopen_key
independently of the host.

David Miller pointed out there is a leak without releasing the context
of tcp_fastopen_key during netns teardown. So add the release action in
exit_batch path.

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
 include/net/netns/ipv4.h   |  4 +++
 include/net/tcp.h          |  6 ++---
 net/ipv4/af_inet.c         |  2 +-
 net/ipv4/sysctl_net_ipv4.c | 21 ++++++++-------
 net/ipv4/tcp.c             |  2 +-
 net/ipv4/tcp_fastopen.c    | 64 +++++++++++++++++++++++++++++++---------------
 net/ipv4/tcp_ipv4.c        |  6 +++++
 7 files changed, 70 insertions(+), 35 deletions(-)

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
index 061c128..e27bd18 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1556,13 +1556,13 @@ struct tcp_fastopen_request {
 };
 void tcp_free_fastopen_req(struct tcp_sock *tp);
 
-extern struct tcp_fastopen_context __rcu *tcp_fastopen_ctx;
-int tcp_fastopen_reset_cipher(void *key, unsigned int len);
+void tcp_fastopen_ctx_destroy(struct net *net);
+int tcp_fastopen_reset_cipher(struct net *net, void *key, unsigned int len);
 void tcp_fastopen_add_skb(struct sock *sk, struct sk_buff *skb);
 struct sock *tcp_try_fastopen(struct sock *sk, struct sk_buff *skb,
 			      struct request_sock *req,
 			      struct tcp_fastopen_cookie *foc);
-void tcp_fastopen_init_key_once(void);
+void tcp_fastopen_init_key_once(struct net *net);
 bool tcp_fastopen_cookie_check(struct sock *sk, u16 *mss,
 			     struct tcp_fastopen_cookie *cookie);
 bool tcp_fastopen_defer_connect(struct sock *sk, int *err);
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index e73ce79..43a1bbe 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -222,7 +222,7 @@ int inet_listen(struct socket *sock, int backlog)
 		    (tcp_fastopen & TFO_SERVER_ENABLE) &&
 		    !inet_csk(sk)->icsk_accept_queue.fastopenq.max_qlen) {
 			fastopen_queue_tune(sk, backlog);
-			tcp_fastopen_init_key_once();
+			tcp_fastopen_init_key_once(sock_net(sk));
 		}
 
 		err = inet_csk_listen_start(sk, backlog);
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index f6324ea..20e19fe 100644
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
@@ -282,7 +284,7 @@ static int proc_tcp_fastopen_key(struct ctl_table *ctl, int write,
 			ret = -EINVAL;
 			goto bad_key;
 		}
-		tcp_fastopen_reset_cipher(user_key, TCP_FASTOPEN_KEY_LENGTH);
+		tcp_fastopen_reset_cipher(net, user_key, TCP_FASTOPEN_KEY_LENGTH);
 	}
 
 bad_key:
@@ -396,12 +398,6 @@ static int proc_tcp_available_ulp(struct ctl_table *ctl,
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
@@ -1080,6 +1076,13 @@ static int proc_tcp_available_ulp(struct ctl_table *ctl,
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
index 4e39545..23225c9 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2749,7 +2749,7 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 	case TCP_FASTOPEN:
 		if (val >= 0 && ((1 << sk->sk_state) & (TCPF_CLOSE |
 		    TCPF_LISTEN))) {
-			tcp_fastopen_init_key_once();
+			tcp_fastopen_init_key_once(net);
 
 			fastopen_queue_tune(sk, val);
 		} else {
diff --git a/net/ipv4/tcp_fastopen.c b/net/ipv4/tcp_fastopen.c
index 8c8f0f0..4eae44a 100644
--- a/net/ipv4/tcp_fastopen.c
+++ b/net/ipv4/tcp_fastopen.c
@@ -9,13 +9,18 @@
 #include <net/inetpeer.h>
 #include <net/tcp.h>
 
-struct tcp_fastopen_context __rcu *tcp_fastopen_ctx;
-
-static DEFINE_SPINLOCK(tcp_fastopen_ctx_lock);
-
-void tcp_fastopen_init_key_once(void)
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
@@ -23,8 +28,8 @@ void tcp_fastopen_init_key_once(void)
 	 * All call sites of tcp_fastopen_cookie_gen also check
 	 * for a valid cookie, so this is an acceptable risk.
 	 */
-	if (net_get_random_once(key, sizeof(key)))
-		tcp_fastopen_reset_cipher(key, sizeof(key));
+	get_random_bytes(key, sizeof(key));
+	tcp_fastopen_reset_cipher(net, key, sizeof(key));
 }
 
 static void tcp_fastopen_ctx_free(struct rcu_head *head)
@@ -35,7 +40,22 @@ static void tcp_fastopen_ctx_free(struct rcu_head *head)
 	kfree(ctx);
 }
 
-int tcp_fastopen_reset_cipher(void *key, unsigned int len)
+void tcp_fastopen_ctx_destroy(struct net *net)
+{
+	struct tcp_fastopen_context *ctxt;
+
+	spin_lock(&net->ipv4.tcp_fastopen_ctx_lock);
+
+	ctxt = rcu_dereference_protected(net->ipv4.tcp_fastopen_ctx,
+				lockdep_is_held(&net->ipv4.tcp_fastopen_ctx_lock));
+	rcu_assign_pointer(net->ipv4.tcp_fastopen_ctx, NULL);
+	spin_unlock(&net->ipv4.tcp_fastopen_ctx_lock);
+
+	if (ctxt)
+		call_rcu(&ctxt->rcu, tcp_fastopen_ctx_free);
+}
+
+int tcp_fastopen_reset_cipher(struct net *net, void *key, unsigned int len)
 {
 	int err;
 	struct tcp_fastopen_context *ctx, *octx;
@@ -59,26 +79,27 @@ int tcp_fastopen_reset_cipher(void *key, unsigned int len)
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
@@ -94,7 +115,8 @@ static bool __tcp_fastopen_cookie_gen(const void *path,
  *
  * XXX (TFO) - refactor when TCP_FASTOPEN_COOKIE_SIZE != AES_BLOCK_SIZE.
  */
-static bool tcp_fastopen_cookie_gen(struct request_sock *req,
+static bool tcp_fastopen_cookie_gen(struct net *net,
+				    struct request_sock *req,
 				    struct sk_buff *syn,
 				    struct tcp_fastopen_cookie *foc)
 {
@@ -102,7 +124,7 @@ static bool tcp_fastopen_cookie_gen(struct request_sock *req,
 		const struct iphdr *iph = ip_hdr(syn);
 
 		__be32 path[4] = { iph->saddr, iph->daddr, 0, 0 };
-		return __tcp_fastopen_cookie_gen(path, foc);
+		return __tcp_fastopen_cookie_gen(net, path, foc);
 	}
 
 #if IS_ENABLED(CONFIG_IPV6)
@@ -110,13 +132,13 @@ static bool tcp_fastopen_cookie_gen(struct request_sock *req,
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
@@ -296,7 +318,7 @@ struct sock *tcp_try_fastopen(struct sock *sk, struct sk_buff *skb,
 		goto fastopen;
 
 	if (foc->len >= 0 &&  /* Client presents or requests a cookie */
-	    tcp_fastopen_cookie_gen(req, skb, &valid_foc) &&
+	    tcp_fastopen_cookie_gen(sock_net(sk), req, skb, &valid_foc) &&
 	    foc->len == TCP_FASTOPEN_COOKIE_SIZE &&
 	    foc->len == valid_foc.len &&
 	    !memcmp(foc->val, valid_foc.val, foc->len)) {
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 88409b1..49c74c0 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2473,6 +2473,7 @@ static int __net_init tcp_sk_init(struct net *net)
 	net->ipv4.sysctl_tcp_timestamps = 1;
 
 	net->ipv4.sysctl_tcp_fastopen = TFO_CLIENT_ENABLE;
+	spin_lock_init(&net->ipv4.tcp_fastopen_ctx_lock);
 
 	return 0;
 fail:
@@ -2483,7 +2484,12 @@ static int __net_init tcp_sk_init(struct net *net)
 
 static void __net_exit tcp_sk_exit_batch(struct list_head *net_exit_list)
 {
+	struct net *net;
+
 	inet_twsk_purge(&tcp_hashinfo, AF_INET);
+
+	list_for_each_entry(net, net_exit_list, exit_list)
+		tcp_fastopen_ctx_destroy(net);
 }
 
 static struct pernet_operations __net_initdata tcp_sk_ops = {
-- 
1.8.3.1

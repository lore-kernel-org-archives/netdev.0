From: kaber@trash.net
Subject: [PATCH 57/72] tproxy: fix hash locking issue when using port redirection in __inet_inherit_port()
Date: Thu, 21 Oct 2010 17:19:44 +0200
Message-ID: <1287674399-31455-58-git-send-email-kaber@trash.net>
References: <1287674399-31455-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1287674399-31455-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Balazs Scheidler <bazsi@balabit.hu>

When __inet_inherit_port() is called on a tproxy connection the wrong locks are
held for the inet_bind_bucket it is added to. __inet_inherit_port() made an
implicit assumption that the listener's port number (and thus its bind bucket).
Unfortunately, if you're using the TPROXY target to redirect skbs to a
transparent proxy that assumption is not true anymore and things break.

This patch adds code to __inet_inherit_port() so that it can handle this case
by looking up or creating a new bind bucket for the child socket and updates
callers of __inet_inherit_port() to gracefully handle __inet_inherit_port()
failing.

Reported by and original patch from Stephen Buck <stephen.buck@exinda.com>.
See http://marc.info/?t=128169268200001&r=1&w=2 for the original discussion.

Signed-off-by: KOVACS Krisztian <hidden@balabit.hu>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/net/inet_hashtables.h |    2 +-
 net/dccp/ipv4.c               |   10 +++++++---
 net/dccp/ipv6.c               |   10 +++++++---
 net/ipv4/inet_hashtables.c    |   28 ++++++++++++++++++++++++++--
 net/ipv4/tcp_ipv4.c           |   10 +++++++---
 net/ipv6/tcp_ipv6.c           |   12 ++++++++----
 6 files changed, 56 insertions(+), 16 deletions(-)

diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index 74358d1..e9c2ed8 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -245,7 +245,7 @@ static inline int inet_sk_listen_hashfn(const struct sock *sk)
 }
 
 /* Caller must disable local BH processing. */
-extern void __inet_inherit_port(struct sock *sk, struct sock *child);
+extern int __inet_inherit_port(struct sock *sk, struct sock *child);
 
 extern void inet_put_port(struct sock *sk);
 
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index d4a166f..3f69ea1 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -392,7 +392,7 @@ struct sock *dccp_v4_request_recv_sock(struct sock *sk, struct sk_buff *skb,
 
 	newsk = dccp_create_openreq_child(sk, req, skb);
 	if (newsk == NULL)
-		goto exit;
+		goto exit_nonewsk;
 
 	sk_setup_caps(newsk, dst);
 
@@ -409,16 +409,20 @@ struct sock *dccp_v4_request_recv_sock(struct sock *sk, struct sk_buff *skb,
 
 	dccp_sync_mss(newsk, dst_mtu(dst));
 
+	if (__inet_inherit_port(sk, newsk) < 0) {
+		sock_put(newsk);
+		goto exit;
+	}
 	__inet_hash_nolisten(newsk, NULL);
-	__inet_inherit_port(sk, newsk);
 
 	return newsk;
 
 exit_overflow:
 	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENOVERFLOWS);
+exit_nonewsk:
+	dst_release(dst);
 exit:
 	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENDROPS);
-	dst_release(dst);
 	return NULL;
 }
 
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 6e3f325..dca711d 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -564,7 +564,7 @@ static struct sock *dccp_v6_request_recv_sock(struct sock *sk,
 
 	newsk = dccp_create_openreq_child(sk, req, skb);
 	if (newsk == NULL)
-		goto out;
+		goto out_nonewsk;
 
 	/*
 	 * No need to charge this sock to the relevant IPv6 refcnt debug socks
@@ -632,18 +632,22 @@ static struct sock *dccp_v6_request_recv_sock(struct sock *sk,
 	newinet->inet_daddr = newinet->inet_saddr = LOOPBACK4_IPV6;
 	newinet->inet_rcv_saddr = LOOPBACK4_IPV6;
 
+	if (__inet_inherit_port(sk, newsk) < 0) {
+		sock_put(newsk);
+		goto out;
+	}
 	__inet6_hash(newsk, NULL);
-	__inet_inherit_port(sk, newsk);
 
 	return newsk;
 
 out_overflow:
 	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENOVERFLOWS);
+out_nonewsk:
+	dst_release(dst);
 out:
 	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENDROPS);
 	if (opt != NULL && opt != np->opt)
 		sock_kfree_s(sk, opt, opt->tot_len);
-	dst_release(dst);
 	return NULL;
 }
 
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index fb7ad5a..1b344f3 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -101,19 +101,43 @@ void inet_put_port(struct sock *sk)
 }
 EXPORT_SYMBOL(inet_put_port);
 
-void __inet_inherit_port(struct sock *sk, struct sock *child)
+int __inet_inherit_port(struct sock *sk, struct sock *child)
 {
 	struct inet_hashinfo *table = sk->sk_prot->h.hashinfo;
-	const int bhash = inet_bhashfn(sock_net(sk), inet_sk(child)->inet_num,
+	unsigned short port = inet_sk(child)->inet_num;
+	const int bhash = inet_bhashfn(sock_net(sk), port,
 			table->bhash_size);
 	struct inet_bind_hashbucket *head = &table->bhash[bhash];
 	struct inet_bind_bucket *tb;
 
 	spin_lock(&head->lock);
 	tb = inet_csk(sk)->icsk_bind_hash;
+	if (tb->port != port) {
+		/* NOTE: using tproxy and redirecting skbs to a proxy
+		 * on a different listener port breaks the assumption
+		 * that the listener socket's icsk_bind_hash is the same
+		 * as that of the child socket. We have to look up or
+		 * create a new bind bucket for the child here. */
+		struct hlist_node *node;
+		inet_bind_bucket_for_each(tb, node, &head->chain) {
+			if (net_eq(ib_net(tb), sock_net(sk)) &&
+			    tb->port == port)
+				break;
+		}
+		if (!node) {
+			tb = inet_bind_bucket_create(table->bind_bucket_cachep,
+						     sock_net(sk), head, port);
+			if (!tb) {
+				spin_unlock(&head->lock);
+				return -ENOMEM;
+			}
+		}
+	}
 	sk_add_bind_node(child, &tb->owners);
 	inet_csk(child)->icsk_bind_hash = tb;
 	spin_unlock(&head->lock);
+
+	return 0;
 }
 EXPORT_SYMBOL_GPL(__inet_inherit_port);
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index a0232f3..8f8527d 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1422,7 +1422,7 @@ struct sock *tcp_v4_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 
 	newsk = tcp_create_openreq_child(sk, req, skb);
 	if (!newsk)
-		goto exit;
+		goto exit_nonewsk;
 
 	newsk->sk_gso_type = SKB_GSO_TCPV4;
 	sk_setup_caps(newsk, dst);
@@ -1469,16 +1469,20 @@ struct sock *tcp_v4_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 	}
 #endif
 
+	if (__inet_inherit_port(sk, newsk) < 0) {
+		sock_put(newsk);
+		goto exit;
+	}
 	__inet_hash_nolisten(newsk, NULL);
-	__inet_inherit_port(sk, newsk);
 
 	return newsk;
 
 exit_overflow:
 	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENOVERFLOWS);
+exit_nonewsk:
+	dst_release(dst);
 exit:
 	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENDROPS);
-	dst_release(dst);
 	return NULL;
 }
 EXPORT_SYMBOL(tcp_v4_syn_recv_sock);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index fe6d404..ba5258e 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1409,7 +1409,7 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 
 	newsk = tcp_create_openreq_child(sk, req, skb);
 	if (newsk == NULL)
-		goto out;
+		goto out_nonewsk;
 
 	/*
 	 * No need to charge this sock to the relevant IPv6 refcnt debug socks
@@ -1497,18 +1497,22 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 	}
 #endif
 
+	if (__inet_inherit_port(sk, newsk) < 0) {
+		sock_put(newsk);
+		goto out;
+	}
 	__inet6_hash(newsk, NULL);
-	__inet_inherit_port(sk, newsk);
 
 	return newsk;
 
 out_overflow:
 	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENOVERFLOWS);
-out:
-	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENDROPS);
+out_nonewsk:
 	if (opt && opt != np->opt)
 		sock_kfree_s(sk, opt, opt->tot_len);
 	dst_release(dst);
+out:
+	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENDROPS);
 	return NULL;
 }
 
-- 
1.7.1


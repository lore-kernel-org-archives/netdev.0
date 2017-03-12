From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next RFC v1 06/27] afnetns: put afnetns pointer into struct sock
Date: Mon, 13 Mar 2017 00:01:30 +0100
Message-ID: <20170312230151.5185-7-hannes@stressinduktion.org>
References: <20170312230151.5185-1-hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:50793 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S935589AbdCLXCD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Mar 2017 19:02:03 -0400
Received: from compute7.internal (compute7.nyi.internal [10.202.2.47])
        by mailout.nyi.internal (Postfix) with ESMTP id EC33D20638
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 19:01:57 -0400 (EDT)
Received: from m.localhost.localhost (unknown [213.55.211.72])
        by mail.messagingengine.com (Postfix) with ESMTPA id 5D087240CF
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 19:01:57 -0400 (EDT)
In-Reply-To: <20170312230151.5185-1-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All sockets are associated to its creator's afnet namespace.

A little bit care must be taken about in-kernel socket creation.
Basically we associate kernel pointers to the current's net namespace
afnet and don't use the process contexts afnetns.

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/sock.h |  4 ++++
 net/core/sock.c    | 18 ++++++++++++++++--
 2 files changed, 20 insertions(+), 2 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 6db7693b9e6185..1e05d497db2520 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -183,6 +183,9 @@ struct sock_common {
 	};
 	struct proto		*skc_prot;
 	possible_net_t		skc_net;
+#if IS_ENABLED(CONFIG_AFNETNS)
+	struct afnetns		*skc_afnet;
+#endif
 
 #if IS_ENABLED(CONFIG_IPV6)
 	struct in6_addr		skc_v6_daddr;
@@ -337,6 +340,7 @@ struct sock {
 #define sk_bind_node		__sk_common.skc_bind_node
 #define sk_prot			__sk_common.skc_prot
 #define sk_net			__sk_common.skc_net
+#define sk_afnet		__sk_common.skc_afnet
 #define sk_v6_daddr		__sk_common.skc_v6_daddr
 #define sk_v6_rcv_saddr	__sk_common.skc_v6_rcv_saddr
 #define sk_cookie		__sk_common.skc_cookie
diff --git a/net/core/sock.c b/net/core/sock.c
index 768aedf238f5b4..542d496858f993 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1458,6 +1458,12 @@ struct sock *sk_alloc(struct net *net, int family, gfp_t priority,
 		if (likely(sk->sk_net_refcnt))
 			get_net(net);
 		sock_net_set(sk, net);
+#if IS_ENABLED(CONFIG_AFNETNS)
+		if (likely(sk->sk_net_refcnt))
+			sk->sk_afnet = afnetns_get(current->nsproxy->afnet_ns);
+		else
+			sk->sk_afnet = net->afnet_ns;
+#endif
 		atomic_set(&sk->sk_wmem_alloc, 1);
 
 		mem_cgroup_sk_alloc(sk);
@@ -1499,8 +1505,12 @@ static void __sk_destruct(struct rcu_head *head)
 	if (sk->sk_peer_cred)
 		put_cred(sk->sk_peer_cred);
 	put_pid(sk->sk_peer_pid);
-	if (likely(sk->sk_net_refcnt))
+	if (likely(sk->sk_net_refcnt)) {
 		put_net(sock_net(sk));
+#if IS_ENABLED(CONFIG_AFNETNS)
+		afnetns_put(sk->sk_afnet);
+#endif
+	}
 	sk_prot_free(sk->sk_prot_creator, sk);
 }
 
@@ -1572,8 +1582,12 @@ struct sock *sk_clone_lock(const struct sock *sk, const gfp_t priority)
 		sock_copy(newsk, sk);
 
 		/* SANITY */
-		if (likely(newsk->sk_net_refcnt))
+		if (likely(newsk->sk_net_refcnt)) {
 			get_net(sock_net(newsk));
+#if IS_ENABLED(CONFIG_AFNETNS)
+			afnetns_get(newsk->sk_afnet);
+#endif
+		}
 		sk_node_init(&newsk->sk_node);
 		sock_lock_init(newsk);
 		bh_lock_sock(newsk);
-- 
2.9.3

From: David Ahern <dsahern@gmail.com>
Subject: [RFC PATCH 03/29] net: Flip sock_common to net_ctx
Date: Wed,  4 Feb 2015 18:34:04 -0700
Message-ID: <1423100070-31848-4-git-send-email-dsahern@gmail.com>
References: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
Cc: ebiederm@xmission.com, David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:57595 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756049AbbBEBf4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 20:35:56 -0500
Received: by mail-ig0-f173.google.com with SMTP id a13so38990987igq.0
        for <netdev@vger.kernel.org>; Wed, 04 Feb 2015 17:35:56 -0800 (PST)
In-Reply-To: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enhances sockets from the current namespace only assignment to a
network context.

Define skc_net macro to handle existing code references.

Add macros for retrieving net_ctx struct given a sock struct (needed
because of the way net references are done) and for comparing a
given net_ctx struct to the context of a sock struct.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 include/net/sock.h | 17 ++++++++++++-----
 1 file changed, 12 insertions(+), 5 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 511ef7c8889b..e67347ed1555 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -146,7 +146,7 @@ typedef __u64 __bitwise __addrpair;
  *	@skc_bind_node: bind hash linkage for various protocol lookup tables
  *	@skc_portaddr_node: second hash linkage for UDP/UDP-Lite protocol
  *	@skc_prot: protocol handlers inside a network family
- *	@skc_net: reference to the network namespace of this socket
+ *	@skc_net_ctx: reference to network context of this socket
  *	@skc_node: main hash linkage for various protocol lookup tables
  *	@skc_nulls_node: main hash linkage for TCP/UDP/UDP-Lite protocol
  *	@skc_tx_queue_mapping: tx queue number for this connection
@@ -190,9 +190,8 @@ struct sock_common {
 		struct hlist_nulls_node skc_portaddr_node;
 	};
 	struct proto		*skc_prot;
-#ifdef CONFIG_NET_NS
-	struct net	 	*skc_net;
-#endif
+	struct net_ctx		skc_net_ctx;
+#define skc_net  skc_net_ctx.net
 
 #if IS_ENABLED(CONFIG_IPV6)
 	struct in6_addr		skc_v6_daddr;
@@ -326,7 +325,7 @@ struct sock {
 #define sk_bound_dev_if		__sk_common.skc_bound_dev_if
 #define sk_bind_node		__sk_common.skc_bind_node
 #define sk_prot			__sk_common.skc_prot
-#define sk_net			__sk_common.skc_net
+#define sk_net			__sk_common.skc_net_ctx.net
 #define sk_v6_daddr		__sk_common.skc_v6_daddr
 #define sk_v6_rcv_saddr	__sk_common.skc_v6_rcv_saddr
 
@@ -2197,6 +2196,14 @@ void sock_net_set(struct sock *sk, struct net *net)
 	write_pnet(&sk->sk_net, net);
 }
 
+#define SOCK_NET_CTX(sk)  { .net = sock_net((sk)) }
+
+static inline
+int sock_net_ctx_eq(struct sock *sk, struct net_ctx *ctx)
+{
+	return net_eq(sock_net(sk), ctx->net);
+}
+
 /*
  * Kernel sockets, f.e. rtnl or icmp_socket, are a part of a namespace.
  * They should not hold a reference to a namespace in order to allow
-- 
1.9.3 (Apple Git-50)

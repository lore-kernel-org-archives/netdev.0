From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] ipv6: do not clear pinet6 field
Date: Thu, 09 May 2013 13:28:16 -0700
Message-ID: <1368131296.13473.101.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f182.google.com ([209.85.210.182]:47029 "EHLO
	mail-ia0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752590Ab3EIU2T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 May 2013 16:28:19 -0400
Received: by mail-ia0-f182.google.com with SMTP id j5so1464124iaf.13
        for <netdev@vger.kernel.org>; Thu, 09 May 2013 13:28:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

We have seen multiple NULL dereferences in __inet6_lookup_established()

After analysis, I found that inet6_sk() could be NULL while the
check for sk_family == AF_INET6 was true.

Bug was added in linux-2.6.29 when RCU lookups were introduced in UDP
and TCP stacks.

Once an IPv6 socket, using SLAB_DESTROY_BY_RCU is inserted in a hash
table, we no longer can clear pinet6 field.

This patch extends logic used in commit fcbdf09d9652c891
("net: fix nulls list corruptions in sk_prot_alloc")

TCP/UDP/UDPLite IPv6 protocols provide their own .clear_sk() method
to make sure we do not clear pinet6 field.

At socket clone phase, we do not really care, as cloning the parent (non
NULL) pinet6 is not adding a fatal race.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/sock.h  |   12 ++++++++++++
 net/core/sock.c     |   12 ------------
 net/ipv6/tcp_ipv6.c |   12 ++++++++++++
 net/ipv6/udp.c      |   13 ++++++++++++-
 net/ipv6/udp_impl.h |    2 ++
 net/ipv6/udplite.c  |    2 +-
 6 files changed, 39 insertions(+), 14 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 5c97b0f..66772cf 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -866,6 +866,18 @@ struct inet_hashinfo;
 struct raw_hashinfo;
 struct module;
 
+/*
+ * caches using SLAB_DESTROY_BY_RCU should let .next pointer from nulls nodes
+ * un-modified. Special care is taken when initializing object to zero.
+ */
+static inline void sk_prot_clear_nulls(struct sock *sk, int size)
+{
+	if (offsetof(struct sock, sk_node.next) != 0)
+		memset(sk, 0, offsetof(struct sock, sk_node.next));
+	memset(&sk->sk_node.pprev, 0,
+	       size - offsetof(struct sock, sk_node.pprev));
+}
+
 /* Networking protocol blocks we attach to sockets.
  * socket layer -> transport layer interface
  * transport -> network interface is defined by struct inet_proto
diff --git a/net/core/sock.c b/net/core/sock.c
index d4f4cea..6ba327d 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1217,18 +1217,6 @@ static void sock_copy(struct sock *nsk, const struct sock *osk)
 #endif
 }
 
-/*
- * caches using SLAB_DESTROY_BY_RCU should let .next pointer from nulls nodes
- * un-modified. Special care is taken when initializing object to zero.
- */
-static inline void sk_prot_clear_nulls(struct sock *sk, int size)
-{
-	if (offsetof(struct sock, sk_node.next) != 0)
-		memset(sk, 0, offsetof(struct sock, sk_node.next));
-	memset(&sk->sk_node.pprev, 0,
-	       size - offsetof(struct sock, sk_node.pprev));
-}
-
 void sk_prot_clear_portaddr_nulls(struct sock *sk, int size)
 {
 	unsigned long nulls1, nulls2;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 7116706..0115aee 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1890,6 +1890,17 @@ void tcp6_proc_exit(struct net *net)
 }
 #endif
 
+static void tcp_v6_clear_sk(struct sock *sk, int size)
+{
+	struct inet_sock *inet = inet_sk(sk);
+
+	/* we do not want to clear pinet6 field, because of RCU lookups */
+	sk_prot_clear_nulls(sk, offsetof(struct inet_sock, pinet6));
+
+	size -= offsetof(struct inet_sock, pinet6) + sizeof(inet->pinet6);
+	memset(&inet->pinet6 + 1, 0, size);
+}
+
 struct proto tcpv6_prot = {
 	.name			= "TCPv6",
 	.owner			= THIS_MODULE,
@@ -1933,6 +1944,7 @@ struct proto tcpv6_prot = {
 #ifdef CONFIG_MEMCG_KMEM
 	.proto_cgroup		= tcp_proto_cgroup,
 #endif
+	.clear_sk		= tcp_v6_clear_sk,
 };
 
 static const struct inet6_protocol tcpv6_protocol = {
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index d4defdd..fc57d60 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1432,6 +1432,17 @@ void udp6_proc_exit(struct net *net) {
 }
 #endif /* CONFIG_PROC_FS */
 
+void udp_v6_clear_sk(struct sock *sk, int size)
+{
+	struct inet_sock *inet = inet_sk(sk);
+
+	/* we do not want to clear pinet6 field, because of RCU lookups */
+	sk_prot_clear_portaddr_nulls(sk, offsetof(struct inet_sock, pinet6));
+
+	size -= offsetof(struct inet_sock, pinet6) + sizeof(inet->pinet6);
+	memset(&inet->pinet6 + 1, 0, size);
+}
+
 /* ------------------------------------------------------------------------ */
 
 struct proto udpv6_prot = {
@@ -1462,7 +1473,7 @@ struct proto udpv6_prot = {
 	.compat_setsockopt = compat_udpv6_setsockopt,
 	.compat_getsockopt = compat_udpv6_getsockopt,
 #endif
-	.clear_sk	   = sk_prot_clear_portaddr_nulls,
+	.clear_sk	   = udp_v6_clear_sk,
 };
 
 static struct inet_protosw udpv6_protosw = {
diff --git a/net/ipv6/udp_impl.h b/net/ipv6/udp_impl.h
index d757104..4691ed5 100644
--- a/net/ipv6/udp_impl.h
+++ b/net/ipv6/udp_impl.h
@@ -31,6 +31,8 @@ extern int	udpv6_recvmsg(struct kiocb *iocb, struct sock *sk,
 extern int	udpv6_queue_rcv_skb(struct sock * sk, struct sk_buff *skb);
 extern void	udpv6_destroy_sock(struct sock *sk);
 
+extern void udp_v6_clear_sk(struct sock *sk, int size);
+
 #ifdef CONFIG_PROC_FS
 extern int	udp6_seq_show(struct seq_file *seq, void *v);
 #endif
diff --git a/net/ipv6/udplite.c b/net/ipv6/udplite.c
index 1d08e21..dfcc4be 100644
--- a/net/ipv6/udplite.c
+++ b/net/ipv6/udplite.c
@@ -56,7 +56,7 @@ struct proto udplitev6_prot = {
 	.compat_setsockopt = compat_udpv6_setsockopt,
 	.compat_getsockopt = compat_udpv6_getsockopt,
 #endif
-	.clear_sk	   = sk_prot_clear_portaddr_nulls,
+	.clear_sk	   = udp_v6_clear_sk,
 };
 
 static struct inet_protosw udplite6_protosw = {

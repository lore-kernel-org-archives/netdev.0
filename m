From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next] udplite: fix NULL pointer dereference
Date: Tue, 15 Nov 2016 16:37:53 +0100
Message-ID: <ac389a539b9299b44f63a2d1f744a637a8126943.1479223645.git.pabeni@redhat.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Andrei Vagin <avagin@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54094 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933203AbcKOPiJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Nov 2016 10:38:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit 850cbaddb52d ("udp: use it's own memory accounting schema")
assumes that the socket proto has memory accounting enabled,
but this is not the case for UDPLITE.
Fix it enabling memory accounting for UDPLITE and performing
fwd allocated memory reclaiming on socket shutdown.
UDP and UDPLITE share now the same memory accounting limits.
Also drop the backlog receive operation, since is no more needed.

Fixes: 850cbaddb52d ("udp: use it's own memory accounting schema")
Reported-by: Andrei Vagin <avagin@gmail.com>
Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 include/net/udp.h     | 1 +
 include/net/udplite.h | 1 +
 net/ipv4/udp.c        | 3 ++-
 net/ipv4/udplite.c    | 3 ++-
 net/ipv6/udplite.c    | 3 ++-
 5 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/include/net/udp.h b/include/net/udp.h
index e6e4e19..1661791 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -246,6 +246,7 @@ static inline __be16 udp_flow_src_port(struct net *net, struct sk_buff *skb,
 }
 
 /* net/ipv4/udp.c */
+void udp_destruct_sock(struct sock *sk);
 void skb_consume_udp(struct sock *sk, struct sk_buff *skb, int len);
 int __udp_enqueue_schedule_skb(struct sock *sk, struct sk_buff *skb);
 void udp_skb_destructor(struct sock *sk, struct sk_buff *skb);
diff --git a/include/net/udplite.h b/include/net/udplite.h
index 8076193..36097d3 100644
--- a/include/net/udplite.h
+++ b/include/net/udplite.h
@@ -27,6 +27,7 @@ static __inline__ int udplite_getfrag(void *from, char *to, int  offset,
 static inline int udplite_sk_init(struct sock *sk)
 {
 	udp_sk(sk)->pcflag = UDPLITE_BIT;
+	sk->sk_destruct = udp_destruct_sock;
 	return 0;
 }
 
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index c827e4e..9ae7c63 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1253,7 +1253,7 @@ int __udp_enqueue_schedule_skb(struct sock *sk, struct sk_buff *skb)
 }
 EXPORT_SYMBOL_GPL(__udp_enqueue_schedule_skb);
 
-static void udp_destruct_sock(struct sock *sk)
+void udp_destruct_sock(struct sock *sk)
 {
 	/* reclaim completely the forward allocated memory */
 	unsigned int total = 0;
@@ -1267,6 +1267,7 @@ static void udp_destruct_sock(struct sock *sk)
 
 	inet_sock_destruct(sk);
 }
+EXPORT_SYMBOL_GPL(udp_destruct_sock);
 
 int udp_init_sock(struct sock *sk)
 {
diff --git a/net/ipv4/udplite.c b/net/ipv4/udplite.c
index af81715..59f10fe 100644
--- a/net/ipv4/udplite.c
+++ b/net/ipv4/udplite.c
@@ -50,10 +50,11 @@ struct proto 	udplite_prot = {
 	.sendmsg	   = udp_sendmsg,
 	.recvmsg	   = udp_recvmsg,
 	.sendpage	   = udp_sendpage,
-	.backlog_rcv	   = udp_queue_rcv_skb,
 	.hash		   = udp_lib_hash,
 	.unhash		   = udp_lib_unhash,
 	.get_port	   = udp_v4_get_port,
+	.memory_allocated  = &udp_memory_allocated,
+	.sysctl_mem	   = sysctl_udp_mem,
 	.obj_size	   = sizeof(struct udp_sock),
 	.h.udp_table	   = &udplite_table,
 #ifdef CONFIG_COMPAT
diff --git a/net/ipv6/udplite.c b/net/ipv6/udplite.c
index 47d0d2b..2784cc3 100644
--- a/net/ipv6/udplite.c
+++ b/net/ipv6/udplite.c
@@ -45,10 +45,11 @@ struct proto udplitev6_prot = {
 	.getsockopt	   = udpv6_getsockopt,
 	.sendmsg	   = udpv6_sendmsg,
 	.recvmsg	   = udpv6_recvmsg,
-	.backlog_rcv	   = udpv6_queue_rcv_skb,
 	.hash		   = udp_lib_hash,
 	.unhash		   = udp_lib_unhash,
 	.get_port	   = udp_v6_get_port,
+	.memory_allocated  = &udp_memory_allocated,
+	.sysctl_mem	   = sysctl_udp_mem,
 	.obj_size	   = sizeof(struct udp6_sock),
 	.h.udp_table	   = &udplite_table,
 #ifdef CONFIG_COMPAT
-- 
1.8.3.1

From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 1/4] ipv6: udp: remove udp_v6_clear_sk()
Date: Tue, 23 Aug 2016 11:39:26 -0700
Message-ID: <1471977569-27190-2-git-send-email-edumazet@google.com>
References: <1471977569-27190-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:35507 "EHLO
        mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753849AbcHWSjy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 14:39:54 -0400
Received: by mail-pa0-f54.google.com with SMTP id hb8so31991365pac.2
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 11:39:54 -0700 (PDT)
In-Reply-To: <1471977569-27190-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now RCU lookups of ipv6 udp sockets no longer dereference
pinet6 field, we can get rid of udp_v6_clear_sk() helper.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv6/udp.c      | 13 +------------
 net/ipv6/udp_impl.h |  2 --
 net/ipv6/udplite.c  |  2 +-
 3 files changed, 2 insertions(+), 15 deletions(-)

diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 81e2f98b958d..c86b9417f44e 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1424,17 +1424,6 @@ void udp6_proc_exit(struct net *net)
 }
 #endif /* CONFIG_PROC_FS */
 
-void udp_v6_clear_sk(struct sock *sk, int size)
-{
-	struct inet_sock *inet = inet_sk(sk);
-
-	/* we do not want to clear pinet6 field, because of RCU lookups */
-	sk_prot_clear_portaddr_nulls(sk, offsetof(struct inet_sock, pinet6));
-
-	size -= offsetof(struct inet_sock, pinet6) + sizeof(inet->pinet6);
-	memset(&inet->pinet6 + 1, 0, size);
-}
-
 /* ------------------------------------------------------------------------ */
 
 struct proto udpv6_prot = {
@@ -1466,7 +1455,7 @@ struct proto udpv6_prot = {
 	.compat_setsockopt = compat_udpv6_setsockopt,
 	.compat_getsockopt = compat_udpv6_getsockopt,
 #endif
-	.clear_sk	   = udp_v6_clear_sk,
+	.clear_sk	   = sk_prot_clear_portaddr_nulls,
 };
 
 static struct inet_protosw udpv6_protosw = {
diff --git a/net/ipv6/udp_impl.h b/net/ipv6/udp_impl.h
index 0682c031ccdc..f6eb1ab34f4b 100644
--- a/net/ipv6/udp_impl.h
+++ b/net/ipv6/udp_impl.h
@@ -29,8 +29,6 @@ int udpv6_recvmsg(struct sock *sk, struct msghdr *msg, size_t len, int noblock,
 int udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb);
 void udpv6_destroy_sock(struct sock *sk);
 
-void udp_v6_clear_sk(struct sock *sk, int size);
-
 #ifdef CONFIG_PROC_FS
 int udp6_seq_show(struct seq_file *seq, void *v);
 #endif
diff --git a/net/ipv6/udplite.c b/net/ipv6/udplite.c
index 9cf097e206e9..118057a5b759 100644
--- a/net/ipv6/udplite.c
+++ b/net/ipv6/udplite.c
@@ -56,7 +56,7 @@ struct proto udplitev6_prot = {
 	.compat_setsockopt = compat_udpv6_setsockopt,
 	.compat_getsockopt = compat_udpv6_getsockopt,
 #endif
-	.clear_sk	   = udp_v6_clear_sk,
+	.clear_sk	   = sk_prot_clear_portaddr_nulls,
 };
 
 static struct inet_protosw udplite6_protosw = {
-- 
2.8.0.rc3.226.g39d4020

From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 2/4] udp: get rid of sk_prot_clear_portaddr_nulls()
Date: Tue, 23 Aug 2016 11:39:27 -0700
Message-ID: <1471977569-27190-3-git-send-email-edumazet@google.com>
References: <1471977569-27190-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:33842 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753849AbcHWSkA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 14:40:00 -0400
Received: by mail-pf0-f172.google.com with SMTP id p64so46216069pfb.1
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 11:40:00 -0700 (PDT)
In-Reply-To: <1471977569-27190-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since we no longer use SLAB_DESTROY_BY_RCU for UDP,
we do not need sk_prot_clear_portaddr_nulls() helper.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/sock.h |  2 --
 net/core/sock.c    | 18 ------------------
 net/ipv4/udp.c     |  1 -
 net/ipv4/udplite.c |  1 -
 net/ipv6/udp.c     |  1 -
 net/ipv6/udplite.c |  1 -
 6 files changed, 24 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 2aab9b63bf16..1bc57609f8e1 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1242,8 +1242,6 @@ static inline int __sk_prot_rehash(struct sock *sk)
 	return sk->sk_prot->hash(sk);
 }
 
-void sk_prot_clear_portaddr_nulls(struct sock *sk, int size);
-
 /* About 10 seconds */
 #define SOCK_DESTROY_TIME (10*HZ)
 
diff --git a/net/core/sock.c b/net/core/sock.c
index 25dab8b60223..2b09c2967e21 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1315,24 +1315,6 @@ static void sock_copy(struct sock *nsk, const struct sock *osk)
 #endif
 }
 
-void sk_prot_clear_portaddr_nulls(struct sock *sk, int size)
-{
-	unsigned long nulls1, nulls2;
-
-	nulls1 = offsetof(struct sock, __sk_common.skc_node.next);
-	nulls2 = offsetof(struct sock, __sk_common.skc_portaddr_node.next);
-	if (nulls1 > nulls2)
-		swap(nulls1, nulls2);
-
-	if (nulls1 != 0)
-		memset((char *)sk, 0, nulls1);
-	memset((char *)sk + nulls1 + sizeof(void *), 0,
-	       nulls2 - nulls1 - sizeof(void *));
-	memset((char *)sk + nulls2 + sizeof(void *), 0,
-	       size - nulls2 - sizeof(void *));
-}
-EXPORT_SYMBOL(sk_prot_clear_portaddr_nulls);
-
 static struct sock *sk_prot_alloc(struct proto *prot, gfp_t priority,
 		int family)
 {
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 8f5f7f6026f7..5c5807612cc0 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -2223,7 +2223,6 @@ struct proto udp_prot = {
 	.compat_setsockopt = compat_udp_setsockopt,
 	.compat_getsockopt = compat_udp_getsockopt,
 #endif
-	.clear_sk	   = sk_prot_clear_portaddr_nulls,
 };
 EXPORT_SYMBOL(udp_prot);
 
diff --git a/net/ipv4/udplite.c b/net/ipv4/udplite.c
index 3b3efbda48e1..67fc9d96e67d 100644
--- a/net/ipv4/udplite.c
+++ b/net/ipv4/udplite.c
@@ -61,7 +61,6 @@ struct proto 	udplite_prot = {
 	.compat_setsockopt = compat_udp_setsockopt,
 	.compat_getsockopt = compat_udp_getsockopt,
 #endif
-	.clear_sk	   = sk_prot_clear_portaddr_nulls,
 };
 EXPORT_SYMBOL(udplite_prot);
 
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index c86b9417f44e..9f0b025cc750 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1455,7 +1455,6 @@ struct proto udpv6_prot = {
 	.compat_setsockopt = compat_udpv6_setsockopt,
 	.compat_getsockopt = compat_udpv6_getsockopt,
 #endif
-	.clear_sk	   = sk_prot_clear_portaddr_nulls,
 };
 
 static struct inet_protosw udpv6_protosw = {
diff --git a/net/ipv6/udplite.c b/net/ipv6/udplite.c
index 118057a5b759..5cf0099b86f7 100644
--- a/net/ipv6/udplite.c
+++ b/net/ipv6/udplite.c
@@ -56,7 +56,6 @@ struct proto udplitev6_prot = {
 	.compat_setsockopt = compat_udpv6_setsockopt,
 	.compat_getsockopt = compat_udpv6_getsockopt,
 #endif
-	.clear_sk	   = sk_prot_clear_portaddr_nulls,
 };
 
 static struct inet_protosw udplite6_protosw = {
-- 
2.8.0.rc3.226.g39d4020

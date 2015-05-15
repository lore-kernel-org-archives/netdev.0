From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 1/6] net: fix sk_mem_reclaim_partial()
Date: Fri, 15 May 2015 07:53:53 -0700
Message-ID: <1431701638-24451-2-git-send-email-edumazet@google.com>
References: <1431701638-24451-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>, Jason Baron <jbaron@akamai.com>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f201.google.com ([209.85.192.201]:33530 "EHLO
	mail-pd0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932948AbbEOOyM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 10:54:12 -0400
Received: by pdjg10 with SMTP id g10so8046832pdj.0
        for <netdev@vger.kernel.org>; Fri, 15 May 2015 07:54:11 -0700 (PDT)
In-Reply-To: <1431701638-24451-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sk_mem_reclaim_partial() goal is to ensure each socket has
one SK_MEM_QUANTUM forward allocation. This is needed both for
performance and better handling of memory pressure situations in
follow up patches.

SK_MEM_QUANTUM is currently a page, but might be reduced to 4096 bytes
as some arches have 64KB pages.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/sock.h | 6 +++---
 net/core/sock.c    | 9 +++++----
 2 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index d882f4c8e438..4581a60636f8 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1368,7 +1368,7 @@ static inline struct inode *SOCK_INODE(struct socket *socket)
  * Functions for memory accounting
  */
 int __sk_mem_schedule(struct sock *sk, int size, int kind);
-void __sk_mem_reclaim(struct sock *sk);
+void __sk_mem_reclaim(struct sock *sk, int amount);
 
 #define SK_MEM_QUANTUM ((int)PAGE_SIZE)
 #define SK_MEM_QUANTUM_SHIFT ilog2(SK_MEM_QUANTUM)
@@ -1409,7 +1409,7 @@ static inline void sk_mem_reclaim(struct sock *sk)
 	if (!sk_has_account(sk))
 		return;
 	if (sk->sk_forward_alloc >= SK_MEM_QUANTUM)
-		__sk_mem_reclaim(sk);
+		__sk_mem_reclaim(sk, sk->sk_forward_alloc);
 }
 
 static inline void sk_mem_reclaim_partial(struct sock *sk)
@@ -1417,7 +1417,7 @@ static inline void sk_mem_reclaim_partial(struct sock *sk)
 	if (!sk_has_account(sk))
 		return;
 	if (sk->sk_forward_alloc > SK_MEM_QUANTUM)
-		__sk_mem_reclaim(sk);
+		__sk_mem_reclaim(sk, sk->sk_forward_alloc - 1);
 }
 
 static inline void sk_mem_charge(struct sock *sk, int size)
diff --git a/net/core/sock.c b/net/core/sock.c
index c18738a795b0..29124fcdc42a 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2069,12 +2069,13 @@ EXPORT_SYMBOL(__sk_mem_schedule);
 /**
  *	__sk_reclaim - reclaim memory_allocated
  *	@sk: socket
+ *	@amount: number of bytes (rounded down to a SK_MEM_QUANTUM multiple)
  */
-void __sk_mem_reclaim(struct sock *sk)
+void __sk_mem_reclaim(struct sock *sk, int amount)
 {
-	sk_memory_allocated_sub(sk,
-				sk->sk_forward_alloc >> SK_MEM_QUANTUM_SHIFT);
-	sk->sk_forward_alloc &= SK_MEM_QUANTUM - 1;
+	amount >>= SK_MEM_QUANTUM_SHIFT;
+	sk_memory_allocated_sub(sk, amount);
+	sk->sk_forward_alloc -= amount << SK_MEM_QUANTUM_SHIFT;
 
 	if (sk_under_memory_pressure(sk) &&
 	    (sk_memory_allocated(sk) < sk_prot_mem_limits(sk, 0)))
-- 
2.2.0.rc0.207.ga3a616c

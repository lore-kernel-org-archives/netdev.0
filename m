From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 net-next] net: set SK_MEM_QUANTUM to 4096
Date: Mon, 31 Oct 2016 13:32:55 -0700
Message-ID: <1477945975.7065.317.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1477940320.7065.312.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34430 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S946507AbcJaUc6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 16:32:58 -0400
Received: by mail-pf0-f195.google.com with SMTP id y68so3714986pfb.1
        for <netdev@vger.kernel.org>; Mon, 31 Oct 2016 13:32:57 -0700 (PDT)
In-Reply-To: <1477940320.7065.312.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Systems with large pages (64KB pages for example) do not always have
huge quantity of memory.

A big SK_MEM_QUANTUM value leads to fewer interactions with the
global counters (like tcp_memory_allocated) but might trigger
memory pressure much faster, giving suboptimal TCP performance
since windows are lowered to ridiculous values.

Note that sysctl_mem units being in pages and in ABI, we also need
to change sk_prot_mem_limits() accordingly.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/sock.h |   23 +++++++++++++++++------
 1 file changed, 17 insertions(+), 6 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index f13ac87a8015cb18c5d3fe5fdcf2d6a0592428f4..d904d1835e06c970fea958c048d927137171477f 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1162,11 +1162,6 @@ static inline void sk_enter_memory_pressure(struct sock *sk)
 	sk->sk_prot->enter_memory_pressure(sk);
 }
 
-static inline long sk_prot_mem_limits(const struct sock *sk, int index)
-{
-	return sk->sk_prot->sysctl_mem[index];
-}
-
 static inline long
 sk_memory_allocated(const struct sock *sk)
 {
@@ -1281,11 +1276,27 @@ int __sk_mem_schedule(struct sock *sk, int size, int kind);
 void __sk_mem_reduce_allocated(struct sock *sk, int amount);
 void __sk_mem_reclaim(struct sock *sk, int amount);
 
-#define SK_MEM_QUANTUM ((int)PAGE_SIZE)
+/* We used to have PAGE_SIZE here, but systems with 64KB pages
+ * do not necessarily have 16x time more memory than 4KB ones.
+ */
+#define SK_MEM_QUANTUM 4096
 #define SK_MEM_QUANTUM_SHIFT ilog2(SK_MEM_QUANTUM)
 #define SK_MEM_SEND	0
 #define SK_MEM_RECV	1
 
+/* sysctl_mem values are in pages, we convert them in SK_MEM_QUANTUM units */
+static inline long sk_prot_mem_limits(const struct sock *sk, int index)
+{
+	long val = sk->sk_prot->sysctl_mem[index];
+
+#if PAGE_SIZE > SK_MEM_QUANTUM
+	val <<= PAGE_SHIFT - SK_MEM_QUANTUM_SHIFT;
+#elif PAGE_SIZE < SK_MEM_QUANTUM
+	val >>= SK_MEM_QUANTUM_SHIFT - PAGE_SHIFT;
+#endif
+	return val;
+}
+
 static inline int sk_mem_pages(int amt)
 {
 	return (amt + SK_MEM_QUANTUM - 1) >> SK_MEM_QUANTUM_SHIFT;

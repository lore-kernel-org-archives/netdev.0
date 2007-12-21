From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [SOCK] Avoid divides in sk_stream_pages() and
 __sk_stream_mem_reclaim()
Date: Fri, 21 Dec 2007 15:45:08 +0100
Message-ID: <20071221154508.97aef5d9.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:53835 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751286AbXLUOpM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Dec 2007 09:45:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David

This is the last one of this boring patch suite.

I prefered to not change sk_forward_alloc type, I prefer to wait 
18 months more before taking this responsibility :)

Merry Christmas everybody

Eric

[SOCK] Avoid divides in sk_stream_pages() and __sk_stream_mem_reclaim()

sk_forward_alloc being signed, we should take care of divides by
SK_STREAM_MEM_QUANTUM we do in sk_stream_pages() and 
__sk_stream_mem_reclaim()

This patchs introduces SK_STREAM_MEM_QUANTUM_SHIFT, defined
as ilog2(SK_STREAM_MEM_QUANTUM), to be able to use right
shifts instead of plain divides.

This should help compiler to choose right shifts instead of
expensive divides (as seen with CONFIG_CC_OPTIMIZE_FOR_SIZE=y on x86)

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

diff --git a/include/net/sock.h b/include/net/sock.h
index 4456453..a134be1 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -716,10 +716,11 @@ extern void __sk_stream_mem_reclaim(struct sock *sk);
 extern int sk_stream_mem_schedule(struct sock *sk, int size, int kind);
 
 #define SK_STREAM_MEM_QUANTUM ((int)PAGE_SIZE)
+#define SK_STREAM_MEM_QUANTUM_SHIFT ilog2(SK_STREAM_MEM_QUANTUM)
 
 static inline int sk_stream_pages(int amt)
 {
-	return DIV_ROUND_UP(amt, SK_STREAM_MEM_QUANTUM);
+	return (amt + SK_STREAM_MEM_QUANTUM - 1) >> SK_STREAM_MEM_QUANTUM_SHIFT;
 }
 
 static inline void sk_stream_mem_reclaim(struct sock *sk)
diff --git a/net/core/stream.c b/net/core/stream.c
index 5586879..bf188ff 100644
--- a/net/core/stream.c
+++ b/net/core/stream.c
@@ -196,7 +196,7 @@ EXPORT_SYMBOL(sk_stream_error);
 
 void __sk_stream_mem_reclaim(struct sock *sk)
 {
-	atomic_sub(sk->sk_forward_alloc / SK_STREAM_MEM_QUANTUM,
+	atomic_sub(sk->sk_forward_alloc >> SK_STREAM_MEM_QUANTUM_SHIFT,
 		   sk->sk_prot->memory_allocated);
 	sk->sk_forward_alloc &= SK_STREAM_MEM_QUANTUM - 1;
 	if (*sk->sk_prot->memory_pressure &&

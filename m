From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [SOCK] Avoid integer divides where not necessary in include/net/sock.h
Date: Fri, 21 Dec 2007 07:18:40 +0100
Message-ID: <476B5AC0.9060604@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010501050605030704030001"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:51048 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751384AbXLUGSx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 01:18:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010501050605030704030001
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Because sk_wmem_queued, sk_sndbuf are signed, a divide per two
forces compiler to use an integer divide. We can instead use
a right shift.

SK_STREAM_MEM_QUANTUM deserves to be declared as an unsigned
quantity, so that sk_stream_pages() and __sk_stream_mem_reclaim()
can use right shifts instead of integer divides.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>


--------------010501050605030704030001
Content-Type: text/plain;
 name="sock_h.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="sock_h.patch"

diff --git a/include/net/sock.h b/include/net/sock.h
index 803d8f2..6da08fc 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -445,7 +445,7 @@ static inline int sk_acceptq_is_full(struct sock *sk)
  */
 static inline int sk_stream_min_wspace(struct sock *sk)
 {
-	return sk->sk_wmem_queued / 2;
+	return sk->sk_wmem_queued >> 1;
 }
 
 static inline int sk_stream_wspace(struct sock *sk)
@@ -715,7 +715,7 @@ static inline struct inode *SOCK_INODE(struct socket *socket)
 extern void __sk_stream_mem_reclaim(struct sock *sk);
 extern int sk_stream_mem_schedule(struct sock *sk, int size, int kind);
 
-#define SK_STREAM_MEM_QUANTUM ((int)PAGE_SIZE)
+#define SK_STREAM_MEM_QUANTUM ((unsigned int)PAGE_SIZE)
 
 static inline int sk_stream_pages(int amt)
 {
@@ -1187,7 +1187,7 @@ static inline void sk_wake_async(struct sock *sk, int how, int band)
 static inline void sk_stream_moderate_sndbuf(struct sock *sk)
 {
 	if (!(sk->sk_userlocks & SOCK_SNDBUF_LOCK)) {
-		sk->sk_sndbuf = min(sk->sk_sndbuf, sk->sk_wmem_queued / 2);
+		sk->sk_sndbuf = min(sk->sk_sndbuf, sk->sk_wmem_queued >> 1);
 		sk->sk_sndbuf = max(sk->sk_sndbuf, SOCK_MIN_SNDBUF);
 	}
 }
@@ -1211,7 +1211,7 @@ static inline struct page *sk_stream_alloc_page(struct sock *sk)
  */
 static inline int sock_writeable(const struct sock *sk) 
 {
-	return atomic_read(&sk->sk_wmem_alloc) < (sk->sk_sndbuf / 2);
+	return atomic_read(&sk->sk_wmem_alloc) < (sk->sk_sndbuf >> 1);
 }
 
 static inline gfp_t gfp_any(void)

--------------010501050605030704030001--

From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [SOCK] Avoid integer divides where not necessary in
 include/net/sock.h
Date: Fri, 21 Dec 2007 11:40:51 +0100
Message-ID: <20071221114051.f8310a6d.dada1@cosmosbay.com>
References: <476B5AC0.9060604@cosmosbay.com>
	<20071221.015543.19719154.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:49852 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750918AbXLUKk5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Dec 2007 05:40:57 -0500
In-Reply-To: <20071221.015543.19719154.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 21 Dec 2007 01:55:43 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Fri, 21 Dec 2007 07:18:40 +0100
> 
> > Because sk_wmem_queued, sk_sndbuf are signed, a divide per two
> > forces compiler to use an integer divide. We can instead use
> > a right shift.
> > 
> > SK_STREAM_MEM_QUANTUM deserves to be declared as an unsigned
> > quantity, so that sk_stream_pages() and __sk_stream_mem_reclaim()
> > can use right shifts instead of integer divides.
> > 
> > Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> 
> Everything that works with SK_STREAM_MEM_QUANTUM is an int.
> 
> We do a DIV_ROUND_UP() using SK_STREAM_MEM_QUANTUM and an int.
> 
> We do sk->sk_forward_alloc modifications using multiplies on
> SK_STREAM_MEM_QUANTUM and an int, sk_forward_alloc is an int
> too.
> 
> Changing the type of SK_STREAM_MEM_QUANTUM does nothing more than
> create an exception in the typing used in these operations for no real
> gain, in fact it makes this code's correctness harder to verify.
> 
> I'm fine with the rest of your change, so please resubmit this patch
> with the type change removed.

I cannot remove underlying divide without telling compiler *something* is unsigned,
or adding a new _SHIFT macro

We currently do

     int_value / int_constant

I was suggesting 

     int_value / uint_constant

Since you prefer to keep sk_forward_alloc as signed, 
the only clean (without casts) way is to do :

     int_value >> SK_STREAM_MEM_QUANTUM_SHIFT

Please tell me if you are OK with this solution, or if you prefer
I change sk_forward_alloc to be unsigned :)

Thank you 

Here is the patch handling the change on sk_wmem_queued, sk_sndbuf.
Keeping small patches may help future bisection anyway...

[SOCK] Avoid integer divides where not necessary in include/net/sock.h

Because sk_wmem_queued, sk_sndbuf are signed, a divide per two
may force compiler to use an integer divide.

We can instead use a right shift.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

diff --git a/include/net/sock.h b/include/net/sock.h
index 803d8f2..4456453 100644
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

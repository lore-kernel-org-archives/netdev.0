From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [DEBUG]: sk_forward_alloc assertion failures
Date: Fri, 14 Jan 2005 23:03:22 +1100
Message-ID: <20050114120322.GA28449@gondor.apana.org.au>
References: <20050113171234.3fde0925.davem@davemloft.net> <20050114012504.GF6309@krispykreme.ozlabs.ibm.com> <20050113201914.46b7c4a2.davem@davemloft.net> <20050114111648.GA27964@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="EVF5PPMfhYS0aIcm"
Cc: Anton Blanchard <anton@samba.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050114111648.GA27964@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--EVF5PPMfhYS0aIcm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Jan 14, 2005 at 10:16:48PM +1100, herbert wrote:
> 
> Since the packet is bounded by mss_now, and most of the time it
> will be exactly mss_now bytes long, how about if we simply
> replace tp->mss_cache by mss_now?

Doh! My patch is the same as the current code :)

What we need to do is to remember mss_now across sendpage calls.  
Luckily the value of truesize lets us deduce the value of mss_now.
To complicate the picture the mss might have been reduced between
sendpages calls.  So we take the minimum of the remembered mss
and the current mss.

Any brave souls out there to try this?
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--EVF5PPMfhYS0aIcm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/ipv4/tcp.c 1.88 vs edited =====
--- 1.88/net/ipv4/tcp.c	2005-01-07 10:13:39 +11:00
+++ edited/net/ipv4/tcp.c	2005-01-14 22:57:44 +11:00
@@ -654,23 +654,31 @@
 
 	while (psize > 0) {
 		struct sk_buff *skb = sk->sk_write_queue.prev;
+		int skb_mss;
 		struct page *page = pages[poffset / PAGE_SIZE];
 		int copy, i;
 		int offset = poffset % PAGE_SIZE;
 		int size = min_t(size_t, psize, PAGE_SIZE - offset);
 
-		if (!sk->sk_send_head || (copy = mss_now - skb->len) <= 0) {
+		if (!sk->sk_send_head)
+			goto new_segment;
+
+		skb_mss = skb_netsize(skb) - skb_headroom(skb);
+		if (mss_now < skb_mss)
+			skb_mss = mss_now;
+		if ((copy = skb_mss - skb->len) <= 0) {
 new_segment:
 			if (!sk_stream_memory_free(sk))
 				goto wait_for_sndbuf;
 
-			skb = sk_stream_alloc_pskb(sk, 0, tp->mss_cache,
+			skb = sk_stream_alloc_pskb(sk, 0, mss_now,
 						   sk->sk_allocation);
 			if (!skb)
 				goto wait_for_memory;
 
 			skb_entail(sk, tp, skb);
 			copy = mss_now;
+			skb_mss = mss_now;
 		}
 
 		if (copy > size)
@@ -702,14 +710,14 @@
 		if (!(psize -= copy))
 			goto out;
 
-		if (skb->len != mss_now || (flags & MSG_OOB))
+		if (skb->len != skb_mss || (flags & MSG_OOB))
 			continue;
 
 		if (forced_push(tp)) {
 			tcp_mark_push(tp, skb);
-			__tcp_push_pending_frames(sk, tp, mss_now, TCP_NAGLE_PUSH);
+			__tcp_push_pending_frames(sk, tp, skb_mss, TCP_NAGLE_PUSH);
 		} else if (skb == sk->sk_send_head)
-			tcp_push_one(sk, mss_now);
+			tcp_push_one(sk, skb_mss);
 		continue;
 
 wait_for_sndbuf:
===== include/linux/skbuff.h 1.58 vs edited =====
--- 1.58/include/linux/skbuff.h	2004-12-28 16:24:42 +11:00
+++ edited/include/linux/skbuff.h	2005-01-14 22:30:45 +11:00
@@ -1124,6 +1124,11 @@
 	return buffer;
 }
 
+static inline int skb_netsize(const struct sk_buff *skb)
+{
+	return skb->truesize - sizeof(struct sk_buff);
+}
+
 extern void skb_init(void);
 extern void skb_add_mtu(int mtu);
 

--EVF5PPMfhYS0aIcm--

From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [DEBUG]: sk_forward_alloc assertion failures
Date: Thu, 13 Jan 2005 20:19:14 -0800
Message-ID: <20050113201914.46b7c4a2.davem@davemloft.net>
References: <20050113171234.3fde0925.davem@davemloft.net>
	<20050114012504.GF6309@krispykreme.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, herbert@gondor.apana.org.au
Return-path: <netdev-bounce@oss.sgi.com>
To: Anton Blanchard <anton@samba.org>
In-Reply-To: <20050114012504.GF6309@krispykreme.ozlabs.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 14 Jan 2005 12:25:04 +1100
Anton Blanchard <anton@samba.org> wrote:

> Excellent! Ive forwarded it on, lets see if it reproduces.

I think Herbert and I may have zeroed in on the true cause
of this bug.  It's a bug older than TSO support, but it
never showed up because nothing really depended upon
skb->truesize being incredibly accurate.

do_tcp_sendpages(), when it allocates new SKBs, optimistically
sets skb->truesize to the struct sk_buff et al. overhead
plus tp->mss_cache.  This, in and of itself, leaves us generally
with a valid skb->truesize value.  At worst, it will be an
overestimate if we don't fully fill the SKB, but that's fine.
It's underestimates that can lead to the BUG case.

do_tcp_sendpages() aparently does this so it doesn't have to
keep adjusting skb->truesize, sk_wmem_queued, and sk_forward_alloc
as new page pieces are tacked onto the SKB.

tcp_sendmsg() works the other way, it actually does adjust all
the accounting knobs as each piece of user data is copied into
the packet.

So if tcp_sendmsg() creates the SKB, and then do_tcp_sendpages()
tacks pages onto the tail of that SKB, skb->truesize can be way
too small.

Later on if this were a TSO frame, and it gets deeply partially
acked, tcp_trim_skb() will underflow skb->truesize and this is
where all the trouble starts.

The easiest way to fix this is to simply make do_tcp_sendpages()
account just like tcp_sendmsg() does.  This is implemented below
and should be the real fix for the sk_forward_alloc assertion
failures.

===== net/ipv4/tcp.c 1.88 vs edited =====
--- 1.88/net/ipv4/tcp.c	2005-01-06 15:13:39 -08:00
+++ edited/net/ipv4/tcp.c	2005-01-13 19:44:36 -08:00
@@ -664,7 +664,7 @@
 			if (!sk_stream_memory_free(sk))
 				goto wait_for_sndbuf;
 
-			skb = sk_stream_alloc_pskb(sk, 0, tp->mss_cache,
+			skb = sk_stream_alloc_pskb(sk, 0, 0,
 						   sk->sk_allocation);
 			if (!skb)
 				goto wait_for_memory;
@@ -689,6 +689,9 @@
 
 		skb->len += copy;
 		skb->data_len += copy;
+		skb->truesize += copy;
+		sk->sk_wmem_queued += copy;
+		sk->sk_forward_alloc -= copy;
 		skb->ip_summed = CHECKSUM_HW;
 		tp->write_seq += copy;
 		TCP_SKB_CB(skb)->end_seq += copy;

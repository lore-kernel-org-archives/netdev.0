From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [DEBUG]: sk_forward_alloc assertion failures
Date: Fri, 14 Jan 2005 20:55:43 -0800
Message-ID: <20050114205543.5acb0d68.davem@davemloft.net>
References: <20050113201914.46b7c4a2.davem@davemloft.net>
	<20050114111648.GA27964@gondor.apana.org.au>
	<20050114120322.GA28449@gondor.apana.org.au>
	<20050114110352.23c94ab9.davem@davemloft.net>
	<20050114203452.GA1277@gondor.apana.org.au>
	<20050114132757.4ca3153a.davem@davemloft.net>
	<20050114213829.GA12454@gondor.apana.org.au>
	<20050114133611.69ff0bb2.davem@davemloft.net>
	<20050114215504.GA12569@gondor.apana.org.au>
	<20050114140426.5cf06f0c.davem@davemloft.net>
	<20050114224745.GA13180@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: anton@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050114224745.GA13180@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 15 Jan 2005 09:47:45 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> However, it's not all that difficult to fix up either.  We can adjust
> truesize to a more reasonable value in tcp_write_xmit().  Something
> like this will do.
> 
> Actually it happens in the case of sendmsg() too.  Unfortunately in
> that case we can't do a thing about it since the memory is allocated
> between skb->head and skb->tail.

Doing the adjustments at tcp_write_xmit() time also runs into the
problem you mentioned where we're just blindly subtracting from
sk_forward_alloc.

I really still feel that the best way is to "adjust as we add data".
sendmsg() does that already, I tried to add it simply to sendpage()
but it just needs some checks and wait_for_memory logic.

Here's a patch against current BK that tries to do that.  See any
holes? :-)

===== net/ipv4/tcp.c 1.89 vs edited =====
--- 1.89/net/ipv4/tcp.c	2005-01-13 19:57:57 -08:00
+++ edited/net/ipv4/tcp.c	2005-01-14 20:22:27 -08:00
@@ -655,7 +655,7 @@
 	while (psize > 0) {
 		struct sk_buff *skb = sk->sk_write_queue.prev;
 		struct page *page = pages[poffset / PAGE_SIZE];
-		int copy, i;
+		int copy, i, can_coalesce;
 		int offset = poffset % PAGE_SIZE;
 		int size = min_t(size_t, psize, PAGE_SIZE - offset);
 
@@ -677,14 +677,20 @@
 			copy = size;
 
 		i = skb_shinfo(skb)->nr_frags;
-		if (skb_can_coalesce(skb, i, page, offset)) {
+		can_coalesce = skb_can_coalesce(skb, i, page, offset);
+		if (!can_coalesce && i >= MAX_SKB_FRAGS) {
+			tcp_mark_push(tp, skb);
+			goto new_segment;
+		}
+		if (sk->sk_forward_alloc < copy &&
+		    !sk_stream_mem_schedule(sk, copy, 0))
+			goto wait_for_memory;
+		
+		if (can_coalesce) {
 			skb_shinfo(skb)->frags[i - 1].size += copy;
-		} else if (i < MAX_SKB_FRAGS) {
+		} else {
 			get_page(page);
 			skb_fill_page_desc(skb, i, page, offset, copy);
-		} else {
-			tcp_mark_push(tp, skb);
-			goto new_segment;
 		}
 
 		skb->len += copy;

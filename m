From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [DEBUG]: sk_forward_alloc assertion failures
Date: Sat, 15 Jan 2005 09:47:45 +1100
Message-ID: <20050114224745.GA13180@gondor.apana.org.au>
References: <20050113201914.46b7c4a2.davem@davemloft.net> <20050114111648.GA27964@gondor.apana.org.au> <20050114120322.GA28449@gondor.apana.org.au> <20050114110352.23c94ab9.davem@davemloft.net> <20050114203452.GA1277@gondor.apana.org.au> <20050114132757.4ca3153a.davem@davemloft.net> <20050114213829.GA12454@gondor.apana.org.au> <20050114133611.69ff0bb2.davem@davemloft.net> <20050114215504.GA12569@gondor.apana.org.au> <20050114140426.5cf06f0c.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="GvXjxJ+pjyke8COw"
Cc: anton@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050114140426.5cf06f0c.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--GvXjxJ+pjyke8COw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Jan 14, 2005 at 02:04:26PM -0800, David S. Miller wrote:
> 
> I see, but we don't want sendmsg() to charge a full MSS if the
> user is only writing 10 bytes of data onto the wire.  That seems
> to be what happens if we implement things the way you are suggesting.

Yes you're right.  Although I belive it only happens in the case of
sendpages().  It will allocate more memory than what's required in
that case.  I'd say that it should be rare to have a 10 byte packet with
sendfile() though.

However, it's not all that difficult to fix up either.  We can adjust
truesize to a more reasonable value in tcp_write_xmit().  Something
like this will do.

Actually it happens in the case of sendmsg() too.  Unfortunately in
that case we can't do a thing about it since the memory is allocated
between skb->head and skb->tail.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--GvXjxJ+pjyke8COw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/ipv4/tcp_output.c 1.75 vs edited =====
--- 1.75/net/ipv4/tcp_output.c	2004-12-29 05:22:40 +11:00
+++ edited/net/ipv4/tcp_output.c	2005-01-15 09:43:48 +11:00
@@ -750,9 +750,21 @@
 		       tcp_snd_test(tp, skb, mss_now,
 			       	    tcp_skb_is_last(sk, skb) ? nonagle :
 				    			       TCP_NAGLE_PUSH)) {
+			unsigned int len, used;
+
 			if (skb->len > mss_now) {
 				if (tcp_fragment(sk, skb, mss_now))
 					break;
+			}
+
+			len = skb_netsize(skb);
+			used = skb->data_len + (skb->end - skb->head);
+			if (len > used) {
+				len -= used;
+				skb->truesize	     -= len;
+				sk->sk_queue_shrunk   = 1;
+				sk->sk_wmem_queued   -= len;
+				sk->sk_forward_alloc += len;
 			}
 
 			TCP_SKB_CB(skb)->when = tcp_time_stamp;

--GvXjxJ+pjyke8COw--

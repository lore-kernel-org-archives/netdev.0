From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPV4] Check mtu instead of frag_list in ip_push_pending_frames
Date: Mon, 21 Mar 2005 21:56:22 +1100
Message-ID: <20050321105622.GA23809@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="nFreZHaLTZJo0R7j"
To: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--nFreZHaLTZJo0R7j
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

I still didn't like the fact that ip_append_data was the only user
of dst_pmtu :) So I went looking for bugs in the surrounding code.
I managed to find something in ip_push_pending_frames.

When dst_mtu < dst_pmtu - IPsec overhead (which can be caused by PMTU
discovery within an IPsec tunnel), and we transmit a packet that's
longer than dst_mtu but shorter than dst_pmtu - IPsec overhead, then
the DF bit will be incorrectly set in the inner IP header.

This will cause the packet to be dropped when it hits the router that
generated the original PMTU event.  Unfortunately the ICMP packet coming
back doesn't tell us anything new so the next time we send a packet we
will do exactly the same thing.

The fix is similar to what we did in ip_output.  Instead of checking
whether frag_list is empty, we check the condition skb->len <= dst_mtu
directly and set the DF bit based on that.

We can enumerate all the possibilities to see that this is correct.

If skb->len <= dst_mtu and frag_list is empty then this does the
samething as before and is obviously correct.

If skb->len <= dst_mtu and frag_list is non-empty then it implies
that dst_pmtu has increased since the fragments were constructed
as dst_pmtu = dst_mtu + IPsec overhead.  So the skb will now fit
within a single fragment which means that setting DF is correct.
The fragments will be merged by skb_linearise in dev_queue_xmit.

If skb->len > dst_mtu and frag_list is non-empty then again this
maintains the status quo.

If skb->len > dst_mtu and frag_list is empty then we will leave the
DF bit clear as the packet will need to be fragmented between the
remote IPsec gateway and the final destination.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--nFreZHaLTZJo0R7j
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/ipv4/ip_output.c 1.80 vs edited =====
--- 1.80/net/ipv4/ip_output.c	2005-03-19 05:43:26 +11:00
+++ edited/net/ipv4/ip_output.c	2005-03-21 21:36:51 +11:00
@@ -1152,7 +1152,8 @@
 	 * If local_df is set too, we still allow to fragment this frame
 	 * locally. */
 	if (inet->pmtudisc == IP_PMTUDISC_DO ||
-	    (!skb_shinfo(skb)->frag_list && ip_dont_fragment(sk, &rt->u.dst)))
+	    (skb->len <= dst_mtu(&rt->u.dst) &&
+	     ip_dont_fragment(sk, &rt->u.dst)))
 		df = htons(IP_DF);
 
 	if (inet->cork.flags & IPCORK_OPT)

--nFreZHaLTZJo0R7j--

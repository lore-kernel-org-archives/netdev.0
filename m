From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPV4/IPV6] Keep wmem accounting separate in ip*_push_pending_frames
Date: Sun, 15 May 2005 20:40:16 +1000
Message-ID: <20050515104016.GA24344@gondor.apana.org.au>
References: <20050514134834.GA2698@uganda.factory.vocord.ru> <E1DXE3h-0002jR-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="envbJBWh7q8WU6mo"
Cc: netdev@oss.sgi.com, davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Content-Disposition: inline
In-Reply-To: <E1DXE3h-0002jR-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--envbJBWh7q8WU6mo
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sun, May 15, 2005 at 06:01:09PM +1000, Herbert Xu wrote:
> 
> In fact you've uncovered a couple of bugs elsewhere too.  IPv4's
> ip_push_pending_frames attributes all the data to the first skb
> which breaks when the packet is sent through ip_fragment since
> the latter does not undo the truesize attribution.  skb_linearize
> is broken as well since it ignores truesize/owner altogether.

Here is a patch that addresses the first issue.


Since frag_list skb's constructed by ip*_push_pending_frames are
usually going to be fragmented in ip*_fragment and sent separately,
it makes no sense to account them all in the head skb.  Doing so
means that ip*_fragment would have to undo it all in order to keep
the correct wmem accounting.

In fact as it is IPv4 is attributing all the memory to the head skb
in ip_push_pending_frames and not undoing the attribution correctly
in ip_fragment.  On the fast path it will not undo the work at all
which means that as soon as the head skb is transmitted the quota
which may still be used by the other skb's can be used by new data.
On the slow path it double-charges the skb's which may unnecssarily
delay new data from being sent.

This patch simply leaves the wmem accounting with each skb.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--envbJBWh7q8WU6mo
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1138,10 +1138,6 @@ int ip_push_pending_frames(struct sock *
 		tail_skb = &(tmp_skb->next);
 		skb->len += tmp_skb->len;
 		skb->data_len += tmp_skb->len;
-		skb->truesize += tmp_skb->truesize;
-		__sock_put(tmp_skb->sk);
-		tmp_skb->destructor = NULL;
-		tmp_skb->sk = NULL;
 	}
 
 	/* Unless user demanded real pmtu discovery (IP_PMTUDISC_DO), we allow
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1116,12 +1116,6 @@ int ip6_push_pending_frames(struct sock 
 		tail_skb = &(tmp_skb->next);
 		skb->len += tmp_skb->len;
 		skb->data_len += tmp_skb->len;
-#if 0 /* Logically correct, but useless work, ip_fragment() will have to undo */
-		skb->truesize += tmp_skb->truesize;
-		__sock_put(tmp_skb->sk);
-		tmp_skb->destructor = NULL;
-		tmp_skb->sk = NULL;
-#endif
 	}
 
 	ipv6_addr_copy(final_dst, &fl->fl6_dst);

--envbJBWh7q8WU6mo--

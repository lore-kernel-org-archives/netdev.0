From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPV4/IPV6] Ensure all frag_list members have NULL sk
Date: Sun, 15 May 2005 22:22:56 +1000
Message-ID: <20050515122256.GA22251@gondor.apana.org.au>
References: <20050514134834.GA2698@uganda.factory.vocord.ru> <E1DXE3h-0002jR-00@gondolin.me.apana.org.au> <20050515104016.GA24344@gondor.apana.org.au> <20050515114121.GA4830@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="h31gzZEtNLTqOjlF"
Cc: netdev@oss.sgi.com, davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Content-Disposition: inline
In-Reply-To: <20050515114121.GA4830@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--h31gzZEtNLTqOjlF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sun, May 15, 2005 at 09:41:21PM +1000, herbert wrote:
> 
> I'll post a new patch soon.  However, since this is a pretty major change
> and the bugs it fixes aren't that important it should probably be delayed
> until 2.6.13.

Here it is:


Having frag_list members which holds wmem of an sk leads to nightmares
with partially cloned frag skb's.  The reason is that once you unleash
a skb with a frag_list that has individual sk ownerships into the stack
you can never undo those ownerships safely as they may have been cloned
by things like netfilter.  Since we have to undo them in order to make
skb_linearize happy this approach leads to a dead-end.

So let's go the other way and make this an invariant:

	For any skb on a frag_list, skb->sk must be NULL.

That is, the socket ownership always belongs to the head skb.
It turns out that the implementation is actually pretty simple.

The above invariant is actually violated in the following patch
for a short duration inside ip_fragment.  This is OK because the
offending frag_list member is either destroyed at the end of the
slow path without being sent anywhere, or it is detached from
the frag_list before being sent.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--h31gzZEtNLTqOjlF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -490,6 +490,14 @@ int ip_fragment(struct sk_buff *skb, int
 			/* Partially cloned skb? */
 			if (skb_shared(frag))
 				goto slow_path;
+
+			BUG_ON(frag->sk);
+			if (skb->sk) {
+				sock_hold(skb->sk);
+				frag->sk = skb->sk;
+				frag->destructor = sock_wfree;
+				skb->truesize -= frag->truesize;
+			}
 		}
 
 		/* Everything is OK. Generate! */
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -552,13 +552,17 @@ static int ip6_fragment(struct sk_buff *
 			    skb_headroom(frag) < hlen)
 			    goto slow_path;
 
-			/* Correct socket ownership. */
-			if (frag->sk == NULL)
-				goto slow_path;
-
 			/* Partially cloned skb? */
 			if (skb_shared(frag))
 				goto slow_path;
+
+			BUG_ON(frag->sk);
+			if (skb->sk) {
+				sock_hold(skb->sk);
+				frag->sk = skb->sk;
+				frag->destructor = sock_wfree;
+				skb->truesize -= frag->truesize;
+			}
 		}
 
 		err = 0;
@@ -1116,12 +1120,10 @@ int ip6_push_pending_frames(struct sock 
 		tail_skb = &(tmp_skb->next);
 		skb->len += tmp_skb->len;
 		skb->data_len += tmp_skb->len;
-#if 0 /* Logically correct, but useless work, ip_fragment() will have to undo */
 		skb->truesize += tmp_skb->truesize;
 		__sock_put(tmp_skb->sk);
 		tmp_skb->destructor = NULL;
 		tmp_skb->sk = NULL;
-#endif
 	}
 
 	ipv6_addr_copy(final_dst, &fl->fl6_dst);

--h31gzZEtNLTqOjlF--

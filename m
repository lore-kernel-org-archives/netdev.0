From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2.6]: Fix suboptimal fragment sizing for last fragment
Date: Fri, 3 Sep 2004 08:03:44 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040902220343.GA3250@gondor.apana.org.au>
References: <4137681D.3000902@trash.net> <20040902144436.2c8c1337.davem@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="fdj2RfSjLxBAspz7"
Cc: Patrick McHardy <kaber@trash.net>, yoshfuji@linux-ipv6.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040902144436.2c8c1337.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--fdj2RfSjLxBAspz7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Sep 02, 2004 at 02:44:36PM -0700, David S. Miller wrote:
> 
> I see only one remaining possible improvement.  If the fraggap
> area is paged data, we probably should try use page frags
> in the new SKB if this split occurs in ip_append_page().

Yes.  That could also tie into another optimisation.  But it's
an ugly one :) The sk->csum values are added up at the end of
the processing so when we move bytes to and fro the total csum
value stays the same even if the fragment csum values change.

Therefore we can get rid of the csum adjustments except for the
parity bit in the getfrag call.

Is this an acceptable optimisation to you guys?

Another thing we can do is to not always fill up the frags in the middle
and then move bytes off them.  As it is if you do a send that spans
multiple packets each fragment will be filled up to the full and then
chopped off when the next one is started.

And to finish it off, here is a really trivial patch to shave off 27
bytes from the source code :) It does nothing else, well unless your
compiler decides to compile csum_block_sub out-of-line.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--fdj2RfSjLxBAspz7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/ipv4/ip_output.c 1.65 vs edited =====
--- 1.65/net/ipv4/ip_output.c	2004-09-02 15:07:28 +10:00
+++ edited/net/ipv4/ip_output.c	2004-09-03 07:53:54 +10:00
@@ -896,8 +896,8 @@
 				skb->csum = skb_copy_and_csum_bits(
 					skb_prev, maxfraglen,
 					data + transhdrlen, fraggap, 0);
-				skb_prev->csum = csum_block_sub(
-					skb_prev->csum, skb->csum, 0);
+				skb_prev->csum = csum_sub(skb_prev->csum,
+							  skb->csum);
 				data += fraggap;
 				skb_trim(skb_prev, maxfraglen);
 			}
@@ -1094,8 +1094,8 @@
 				skb->csum = skb_copy_and_csum_bits(
 					skb_prev, maxfraglen,
 					data, fraggap, 0);
-				skb_prev->csum = csum_block_sub(
-					skb_prev->csum, skb->csum, 0);
+				skb_prev->csum = csum_sub(skb_prev->csum,
+							  skb->csum);
 				skb_trim(skb_prev, maxfraglen);
 			}
 
===== net/ipv6/ip6_output.c 1.70 vs edited =====
--- 1.70/net/ipv6/ip6_output.c	2004-09-02 15:07:29 +10:00
+++ edited/net/ipv6/ip6_output.c	2004-09-03 07:54:41 +10:00
@@ -985,8 +985,8 @@
 				skb->csum = skb_copy_and_csum_bits(
 					skb_prev, maxfraglen,
 					data + transhdrlen, fraggap, 0);
-				skb_prev->csum = csum_block_sub(
-					skb_prev->csum, skb->csum, 0);
+				skb_prev->csum = csum_sub(skb_prev->csum,
+							  skb->csum);
 				data += fraggap;
 				skb_trim(skb_prev, maxfraglen);
 			}

--fdj2RfSjLxBAspz7--

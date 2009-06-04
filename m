From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: net: Ensure partial checksum offset is inside the skb head
Date: Thu, 4 Jun 2009 21:22:01 +1000
Message-ID: <20090604112201.GA28820@gondor.apana.org.au>
References: <20090604110600.GA28453@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:44688 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751710AbZFDLWC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2009 07:22:02 -0400
Content-Disposition: inline
In-Reply-To: <20090604110600.GA28453@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 04, 2009 at 09:06:00PM +1000, Herbert Xu wrote:
> 
> tun: Optimise handling of bogus gso->hdr_len
> 
> As all current versions of virtio_net generate a value for the
> header length that's too small, we should optimise this so that
> we don't copy it twice.  This can be done by ensuring that it is
> at least as large as the place where we'll write the checksum.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

With this applied we can strengthen the partial checksum check:

net: Ensure partial checksum offset is inside the skb head

In skb_partial_csum_set we check to see if the checksum offset
is within the packet.  However, we really should check that it
is within the skb head as that's the only bit we can modify
without copying.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index e505b53..643c03d 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3016,12 +3016,12 @@ EXPORT_SYMBOL_GPL(skb_tstamp_tx);
  */
 bool skb_partial_csum_set(struct sk_buff *skb, u16 start, u16 off)
 {
-	if (unlikely(start > skb->len - 2) ||
-	    unlikely((int)start + off > skb->len - 2)) {
+	if (unlikely(start > skb_headlen(skb)) ||
+	    unlikely((int)start + off > skb_headlen(skb) - 2)) {
 		if (net_ratelimit())
 			printk(KERN_WARNING
 			       "bad partial csum: csum=%u/%u len=%u\n",
-			       start, off, skb->len);
+			       start, off, skb_headlen(skb));
 		return false;
 	}
 	skb->ip_summed = CHECKSUM_PARTIAL;

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

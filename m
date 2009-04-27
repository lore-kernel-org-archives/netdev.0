From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] myr10ge: again fix lro_gen_skb() alignment
Date: Mon, 27 Apr 2009 16:05:01 +0800
Message-ID: <20090427080501.GA21433@gondor.apana.org.au>
References: <20090415.030213.249634462.davem@davemloft.net> <49E5DABB.9070806@myri.com> <49E64BE4.1050908@myri.com> <20090415.164248.188350673.davem@davemloft.net> <20090416085022.GA19731@gondor.apana.org.au> <49EE1C32.1060202@myri.com> <20090422104811.GA30981@gondor.apana.org.au> <49EF39B4.1040607@myri.com> <20090424054557.GA24575@gondor.apana.org.au> <49F1E5C8.7010303@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, brice@myri.com,
	sgruszka@redhat.com, netdev@vger.kernel.org
To: Andrew Gallatin <gallatin@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:42040 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752761AbZD0IFP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2009 04:05:15 -0400
Content-Disposition: inline
In-Reply-To: <49F1E5C8.7010303@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 24, 2009 at 12:16:08PM -0400, Andrew Gallatin wrote:
>
> These results are indeed quite close, so the performance problem seems
> isolated to AMD CPUS, and perhaps due to the smaller caches.
> Do you have any AMD you can use as a receiver?

I now have an AMD with 512K cache to test this.  Unfortunately
I'd just locked it up before I got a chance to do any serious
testing.  So it might take a while.

> Note that the GRO results were still obtained by (bogusly) setting
> CHECKSUM_UNNECESSARY.  I tried to use your patch, and I see
> terrible performance. Netperf shows between 1Gb/s to 2Gb/s (compared
> to 5Gb/s with GRO disabled).  I don't see bad checksums in netstat
> on the receiver, but it *feels* like something like that.

OK, I'd created a silly bug with the skb_gro_* optimisation.
Here are two patches to fix them.

gro: Fix handling of headers that extend over the tail

The skb_gro_* code fails to handle the case where a header starts
in the linear area but ends in the frags area.  Since the goal
of skb_gro_* is to optimise the case of completely non-linear
packets, we can simply bail out if we have anything in the linear
area.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 2e7783f..0396447 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1145,7 +1145,7 @@ static inline void skb_gro_reset_offset(struct sk_buff *skb)
 
 static inline void *skb_gro_mac_header(struct sk_buff *skb)
 {
-	return skb_mac_header(skb) < skb->data ? skb_mac_header(skb) :
+	return skb_headlen(skb) ? skb_mac_header(skb) :
 	       page_address(skb_shinfo(skb)->frags[0].page) +
 	       skb_shinfo(skb)->frags[0].page_offset;
 }
diff --git a/net/core/dev.c b/net/core/dev.c
index 308a7d0..ef38e4f 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2378,18 +2378,13 @@ void *skb_gro_header(struct sk_buff *skb, unsigned int hlen)
 	unsigned int offset = skb_gro_offset(skb);
 
 	hlen += offset;
-	if (hlen <= skb_headlen(skb))
-		return skb->data + offset;
-
-	if (unlikely(!skb_shinfo(skb)->nr_frags ||
-		     skb_shinfo(skb)->frags[0].size <=
-		     hlen - skb_headlen(skb) ||
+	if (unlikely(skb_headlen(skb) ||
+		     skb_shinfo(skb)->frags[0].size < hlen ||
 		     PageHighMem(skb_shinfo(skb)->frags[0].page)))
 		return pskb_may_pull(skb, hlen) ? skb->data + offset : NULL;
 
 	return page_address(skb_shinfo(skb)->frags[0].page) +
-	       skb_shinfo(skb)->frags[0].page_offset +
-	       offset - skb_headlen(skb);
+	       skb_shinfo(skb)->frags[0].page_offset + offset;
 }
 EXPORT_SYMBOL(skb_gro_header);
 
Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

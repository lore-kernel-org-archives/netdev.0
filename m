From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: gro: Fix illegal merging of trailer trash
Date: Tue, 17 Nov 2009 20:44:14 +0800
Message-ID: <20091117124414.GA14951@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mark Wagner <mwagner@redhat.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:43428 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751445AbZKQMoL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 07:44:11 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave:

Just found this thanks to Mark Wagner testing GRO with Xen.
We'll need this for stable too.

gro: Fix illegal merging of trailer trash

When we've merged skb's with page frags, and subsequently receive
a trailer skb (< MSS) that is not completely non-linear (this can
occur on Intel NICs if the packet size falls below the threshold),
GRO ends up producing an illegal GSO skb with a frag_list.

This is harmless unless the skb is then forwarded through an
interface that requires software GSO, whereupon the GSO code
will BUG.

This patch detects this case in GRO and avoids merging the
trailer skb.

Reported-by: Mark Wagner <mwagner@redhat.com>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 80a9616..ec85681 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2701,7 +2701,8 @@ int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 
 		NAPI_GRO_CB(skb)->free = 1;
 		goto done;
-	}
+	} else if (skb_gro_len(p) != pinfo->gso_size)
+		return -E2BIG;
 
 	headroom = skb_headroom(p);
 	nskb = netdev_alloc_skb(p->dev, headroom + skb_gro_offset(p));

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

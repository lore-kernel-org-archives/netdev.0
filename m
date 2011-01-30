From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: gro: Reset dev pointer on reuse
Date: Sun, 30 Jan 2011 15:10:47 +1100
Message-ID: <20110130041047.GA6290@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:59560 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752252Ab1A3EKv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jan 2011 23:10:51 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

gro: Reset dev pointer on reuse

On older kernels the VLAN code may zero skb->dev before dropping
it and causing it to be reused by GRO.

Unfortunately we didn't reset skb->dev in that case which causes
the next GRO user to get a bogus skb->dev pointer.

This particular problem no longer happens with the current upstream
kernel due to changes in VLAN processing.

However, for correctness we should still reset the skb->dev pointer
in the GRO reuse function in case a future user does the same thing.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/core/dev.c b/net/core/dev.c
index 24ea2d7..93e44db 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3424,6 +3424,7 @@ static void napi_reuse_skb(struct napi_struct *napi, struct sk_buff *skb)
 	__skb_pull(skb, skb_headlen(skb));
 	skb_reserve(skb, NET_IP_ALIGN - skb_headroom(skb));
 	skb->vlan_tci = 0;
+	skb->dev = napi->dev;
 
 	napi->skb = skb;
 }

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

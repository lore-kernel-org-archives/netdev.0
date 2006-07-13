From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [NET]: Add missing UFO initialisations
Date: Thu, 13 Jul 2006 19:11:01 +1000
Message-ID: <20060713091101.GA28651@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:18441 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S964856AbWGMJLI
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Jul 2006 05:11:08 -0400
To: stable@kernel.org, "David S. Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi:

This is only needed for 2.6.17-stable.

[NET]: Add missing UFO initialisations

This bug was unknowingly fixed the GSO patches (or rather, its effect was
unknown at the time).

Thanks to Marco Berizzi's persistence which is documented in the thread
"ipsec tunnel asymmetrical mtu", we now know that it can have highly
non-obvious symptoms.

What happens is that uninitialised uso_size fields can cause packets to
be incorrectly identified as UFO, which means that it does not get
fragmented even if it's over the MTU.

The fix is simple enough.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/core/dev.c b/net/core/dev.c
index 4fba549..7d472ed 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1246,6 +1246,7 @@ int __skb_linearize(struct sk_buff *skb,
 	atomic_set(&ninfo->dataref, 1);
 	ninfo->tso_size = skb_shinfo(skb)->tso_size;
 	ninfo->tso_segs = skb_shinfo(skb)->tso_segs;
+	ninfo->ufo_size = skb_shinfo(skb)->ufo_size;
 	ninfo->nr_frags = 0;
 	ninfo->frag_list = NULL;
 
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index fb3770f..0280535 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -240,6 +240,7 @@ struct sk_buff *alloc_skb_from_cache(kme
 	skb_shinfo(skb)->nr_frags  = 0;
 	skb_shinfo(skb)->tso_size = 0;
 	skb_shinfo(skb)->tso_segs = 0;
+	skb_shinfo(skb)->ufo_size = 0;
 	skb_shinfo(skb)->frag_list = NULL;
 out:
 	return skb;
@@ -529,6 +530,7 @@ #endif
 	atomic_set(&new->users, 1);
 	skb_shinfo(new)->tso_size = skb_shinfo(old)->tso_size;
 	skb_shinfo(new)->tso_segs = skb_shinfo(old)->tso_segs;
+	skb_shinfo(new)->ufo_size = skb_shinfo(old)->ufo_size;
 }
 
 /**

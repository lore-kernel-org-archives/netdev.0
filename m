From: Mathias Krause <mathias.krause@secunet.com>
Subject: [PATCH net-next 3/3] net: allow to leave the buffer fragmented in skb_cow_data()
Date: Tue,  5 Nov 2013 14:54:11 +0100
Message-ID: <14f30e8f5f8405c1ca73b6d3a554441c1736142d.1381923854.git.mathias.krause@secunet.com>
References: <cover.1381923854.git.mathias.krause@secunet.com>
Cc: Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>,
	netdev@vger.kernel.org,
	Mathias Krause <mathias.krause@secunet.com>,
	"David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:52547 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755113Ab3KENy0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Nov 2013 08:54:26 -0500
In-Reply-To: <cover.1381923854.git.mathias.krause@secunet.com>
In-Reply-To: <cover.1381923854.git.mathias.krause@secunet.com>
References: <cover.1381923854.git.mathias.krause@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do not linearize the buffer per se but only if we're expected to expand
the tail. All callers can handle fragmented buffers and even expect
them!

Not linearizing the buffer leads to a small performance improvement for
the IPsec receive path in case the network driver passed us a fragmented
buffer.

With this patch applied I was able to increase the throughput of an
IPsec gateway from 7.12 Gbit/s to 7.28 Gbit/s.

Signed-off-by: Mathias Krause <mathias.krause@secunet.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
---
 net/core/skbuff.c |   29 ++++++++++++++++++-----------
 1 files changed, 18 insertions(+), 11 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 247023d..5eec1b9 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3207,7 +3207,7 @@ EXPORT_SYMBOL_GPL(skb_to_sgvec);
  *
  *	If @tailbits is given, make sure that there is space to write @tailbits
  *	bytes of data beyond current end of socket buffer.  @trailer will be
- *	set to point to the skb in which this space begins.
+ *	linearized and set to point to the skb in which this space begins.
  *
  *	The number of scatterlist elements required to completely map the
  *	COW'd and extended socket buffer will be returned.
@@ -3218,11 +3218,10 @@ int skb_cow_data(struct sk_buff *skb, int tailbits, struct sk_buff **trailer)
 	int elt;
 	struct sk_buff *skb1, **skb_p;
 
-	/* If skb is cloned or its head is paged, reallocate
-	 * head pulling out all the pages (pages are considered not writable
-	 * at the moment even if they are anonymous).
+	/* If skb is cloned reallocate head pulling out all the pages (pages are
+	 * considered not writable at the moment even if they are anonymous).
 	 */
-	if ((skb_cloned(skb) || skb_shinfo(skb)->nr_frags) &&
+	if (skb_cloned(skb) &&
 	    __pskb_pull_tail(skb, skb_pagelen(skb)-skb_headlen(skb)) == NULL)
 		return -ENOMEM;
 
@@ -3233,18 +3232,26 @@ int skb_cow_data(struct sk_buff *skb, int tailbits, struct sk_buff **trailer)
 		 * good frames. OK, on miss we reallocate and reserve even more
 		 * space, 128 bytes is fair. */
 
-		if (skb_tailroom(skb) < tailbits &&
-		    pskb_expand_head(skb, 0, tailbits-skb_tailroom(skb)+128, GFP_ATOMIC))
-			return -ENOMEM;
+		if (tailbits) {
+			if (skb_linearize(skb))
+				return -ENOMEM;
+
+			if (skb_tailroom(skb) < tailbits) {
+				int ntail = tailbits - skb_tailroom(skb) + 128;
+
+				if (pskb_expand_head(skb, 0, ntail, GFP_ATOMIC))
+					return -ENOMEM;
+			}
+		}
 
 		/* Voila! */
 		*trailer = skb;
-		return 1;
+		return skb_shinfo(skb)->nr_frags + 1;
 	}
 
 	/* Misery. We are in troubles, going to mincer fragments... */
 
-	elt = 1;
+	elt = skb_shinfo(skb)->nr_frags + 1;
 	skb_p = &skb_shinfo(skb)->frag_list;
 	copyflag = 0;
 
@@ -3296,7 +3303,7 @@ int skb_cow_data(struct sk_buff *skb, int tailbits, struct sk_buff **trailer)
 			kfree_skb(skb1);
 			skb1 = skb2;
 		}
-		elt++;
+		elt += skb_shinfo(skb1)->nr_frags + 1;
 		*trailer = skb1;
 		skb_p = &skb1->next;
 	}
-- 
1.7.2.5

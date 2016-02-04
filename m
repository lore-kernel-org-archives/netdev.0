From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH RFC 01/13] net: allow to leave the buffer fragmented in skb_cow_data()
Date: Thu, 4 Feb 2016 07:36:54 +0100
Message-ID: <1454567826-13018-2-git-send-email-steffen.klassert@secunet.com>
References: <1454567826-13018-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	Mathias Krause <mathias.krause@secunet.com>,
	<sowmini.varadhan@oracle.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:36678 "EHLO
	h-62.96.220.36.host.de.colt.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756498AbcBDHFu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2016 02:05:50 -0500
In-Reply-To: <1454567826-13018-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mathias Krause <mathias.krause@secunet.com>

Do not linearize the buffer per se but only if we're expected to expand
the tail. All callers can handle fragmented buffers and even expect
them!

Not linearizing the buffer leads to a small performance improvement for
the IPsec receive path in case the network driver passed us a fragmented
buffer.

With this patch applied I was able to increase the throughput of an
IPsec gateway from 7.12 Gbit/s to 7.28 Gbit/s.

Signed-off-by: Mathias Krause <mathias.krause@secunet.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/core/skbuff.c | 29 ++++++++++++++++++-----------
 1 file changed, 18 insertions(+), 11 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index b2df375..120add40 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3445,7 +3445,7 @@ EXPORT_SYMBOL_GPL(skb_to_sgvec);
  *
  *	If @tailbits is given, make sure that there is space to write @tailbits
  *	bytes of data beyond current end of socket buffer.  @trailer will be
- *	set to point to the skb in which this space begins.
+ *	linearized and set to point to the skb in which this space begins.
  *
  *	The number of scatterlist elements required to completely map the
  *	COW'd and extended socket buffer will be returned.
@@ -3456,11 +3456,10 @@ int skb_cow_data(struct sk_buff *skb, int tailbits, struct sk_buff **trailer)
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
 
@@ -3471,18 +3470,26 @@ int skb_cow_data(struct sk_buff *skb, int tailbits, struct sk_buff **trailer)
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
 
@@ -3534,7 +3541,7 @@ int skb_cow_data(struct sk_buff *skb, int tailbits, struct sk_buff **trailer)
 			kfree_skb(skb1);
 			skb1 = skb2;
 		}
-		elt++;
+		elt += skb_shinfo(skb1)->nr_frags + 1;
 		*trailer = skb1;
 		skb_p = &skb1->next;
 	}
-- 
1.9.1

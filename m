From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [NET]: Fix ___pskb_trim when entire frag_list needs dropping
Date: Sat, 29 Jul 2006 21:45:25 +1000
Message-ID: <20060729114525.GA10549@gondor.apana.org.au>
References: <20060713090341.GA28426@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marco Berizzi <pupilla@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:29711 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932650AbWG2Lpd
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Jul 2006 07:45:33 -0400
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20060713090341.GA28426@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 13, 2006 at 07:03:41PM +1000, herbert wrote:
> 
> This needs to go into stable as well.  In fact, there is another unrelated
> bug with exactly the same symptoms which was inadvertently fixed by the
> GSO patches.  So I'll send a simpler fix for that to stable.
> 
> [NET]: Update frag_list in pskb_trim

Marco told me that he was still seeing the same problem.  Turns out that
my patch missed one important case.  I hope this is really the last time
I have to look at this bug :)

[NET]: Fix ___pskb_trim when entire frag_list needs dropping

When the trim point is within the head and there is no paged data,
___pskb_trim fails to drop the first element in the frag_list.
This patch fixes this by moving the len <= offset case out of the
page data loop.

This patch also adds a missing kfree_skb on the frag that we just
cloned.
 
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 476aa39..d236f02 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -846,7 +846,11 @@ int ___pskb_trim(struct sk_buff *skb, un
 	    unlikely((err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC))))
 		return err;
 
-	for (i = 0; i < nfrags; i++) {
+	i = 0;
+	if (offset >= len)
+		goto drop_pages;
+
+	for (; i < nfrags; i++) {
 		int end = offset + skb_shinfo(skb)->frags[i].size;
 
 		if (end < len) {
@@ -854,9 +858,9 @@ int ___pskb_trim(struct sk_buff *skb, un
 			continue;
 		}
 
-		if (len > offset)
-			skb_shinfo(skb)->frags[i++].size = len - offset;
+		skb_shinfo(skb)->frags[i++].size = len - offset;
 
+drop_pages:
 		skb_shinfo(skb)->nr_frags = i;
 
 		for (; i < nfrags; i++)
@@ -864,7 +868,7 @@ int ___pskb_trim(struct sk_buff *skb, un
 
 		if (skb_shinfo(skb)->frag_list)
 			skb_drop_fraglist(skb);
-		break;
+		goto done;
 	}
 
 	for (fragp = &skb_shinfo(skb)->frag_list; (frag = *fragp);
@@ -879,6 +883,7 @@ int ___pskb_trim(struct sk_buff *skb, un
 				return -ENOMEM;
 
 			nfrag->next = frag->next;
+			kfree_skb(frag);
 			frag = nfrag;
 			*fragp = frag;
 		}
@@ -897,6 +902,7 @@ int ___pskb_trim(struct sk_buff *skb, un
 		break;
 	}
 
+done:
 	if (len > skb_headlen(skb)) {
 		skb->data_len -= skb->len - len;
 		skb->len       = len;

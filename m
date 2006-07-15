From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [NET]: Update frag_list in pskb_trim
Date: Sat, 15 Jul 2006 10:10:03 +1000
Message-ID: <20060715001003.GD9334@gondor.apana.org.au>
References: <20060713090341.GA28426@gondor.apana.org.au> <20060713.220526.55726160.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:43782 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1945930AbWGOAKP
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jul 2006 20:10:15 -0400
To: stable@kernel.org, David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060713.220526.55726160.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 13, 2006 at 10:05:26PM -0700, David Miller wrote:
> 
> As I noted already, this is in my tree and will go off to
> Linus soon.
> 
> Please toss this over to -stable under seperate cover, if
> you haven't done so already.  Please add my signoff:
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>

Great.  Here we go:

[NET]: Update frag_list in pskb_trim

When pskb_trim has to defer to ___pksb_trim to trim the frag_list part of
the packet, the frag_list is not updated to reflect the trimming.  This
will usually work fine until you hit something that uses the packet length
or tail from the frag_list.

Examples include esp_output and ip_fragment.

Another problem caused by this is that you can end up with a linear packet
with a frag_list attached.

It is possible to get away with this if we audit everything to make sure
that they always consult skb->len before going down onto frag_list.  In
fact we can do the samething for the paged part as well to avoid copying
the data area of the skb.  For now though, let's do the conservative fix
and update frag_list.

Many thanks to Marco Berizzi for helping me to track down this bug.

This 4-year old bug took 3 months to track down.  Marco was very patient
indeed :)

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: David S. Miller <davem@davemloft.net>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 44f6a18..476aa39 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -257,11 +257,11 @@ nodata:
 }
 
 
-static void skb_drop_fraglist(struct sk_buff *skb)
+static void skb_drop_list(struct sk_buff **listp)
 {
-	struct sk_buff *list = skb_shinfo(skb)->frag_list;
+	struct sk_buff *list = *listp;
 
-	skb_shinfo(skb)->frag_list = NULL;
+	*listp = NULL;
 
 	do {
 		struct sk_buff *this = list;
@@ -270,6 +270,11 @@ static void skb_drop_fraglist(struct sk_
 	} while (list);
 }
 
+static inline void skb_drop_fraglist(struct sk_buff *skb)
+{
+	skb_drop_list(&skb_shinfo(skb)->frag_list);
+}
+
 static void skb_clone_fraglist(struct sk_buff *skb)
 {
 	struct sk_buff *list;
@@ -830,41 +835,75 @@ free_skb:
 
 int ___pskb_trim(struct sk_buff *skb, unsigned int len)
 {
+	struct sk_buff **fragp;
+	struct sk_buff *frag;
 	int offset = skb_headlen(skb);
 	int nfrags = skb_shinfo(skb)->nr_frags;
 	int i;
+	int err;
+
+	if (skb_cloned(skb) &&
+	    unlikely((err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC))))
+		return err;
 
 	for (i = 0; i < nfrags; i++) {
 		int end = offset + skb_shinfo(skb)->frags[i].size;
-		if (end > len) {
-			if (skb_cloned(skb)) {
-				if (pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
-					return -ENOMEM;
-			}
-			if (len <= offset) {
-				put_page(skb_shinfo(skb)->frags[i].page);
-				skb_shinfo(skb)->nr_frags--;
-			} else {
-				skb_shinfo(skb)->frags[i].size = len - offset;
-			}
+
+		if (end < len) {
+			offset = end;
+			continue;
 		}
-		offset = end;
+
+		if (len > offset)
+			skb_shinfo(skb)->frags[i++].size = len - offset;
+
+		skb_shinfo(skb)->nr_frags = i;
+
+		for (; i < nfrags; i++)
+			put_page(skb_shinfo(skb)->frags[i].page);
+
+		if (skb_shinfo(skb)->frag_list)
+			skb_drop_fraglist(skb);
+		break;
 	}
 
-	if (offset < len) {
+	for (fragp = &skb_shinfo(skb)->frag_list; (frag = *fragp);
+	     fragp = &frag->next) {
+		int end = offset + frag->len;
+
+		if (skb_shared(frag)) {
+			struct sk_buff *nfrag;
+
+			nfrag = skb_clone(frag, GFP_ATOMIC);
+			if (unlikely(!nfrag))
+				return -ENOMEM;
+
+			nfrag->next = frag->next;
+			frag = nfrag;
+			*fragp = frag;
+		}
+
+		if (end < len) {
+			offset = end;
+			continue;
+		}
+
+		if (end > len &&
+		    unlikely((err = pskb_trim(frag, len - offset))))
+			return err;
+
+		if (frag->next)
+			skb_drop_list(&frag->next);
+		break;
+	}
+
+	if (len > skb_headlen(skb)) {
 		skb->data_len -= skb->len - len;
 		skb->len       = len;
 	} else {
-		if (len <= skb_headlen(skb)) {
-			skb->len      = len;
-			skb->data_len = 0;
-			skb->tail     = skb->data + len;
-			if (skb_shinfo(skb)->frag_list && !skb_cloned(skb))
-				skb_drop_fraglist(skb);
-		} else {
-			skb->data_len -= skb->len - len;
-			skb->len       = len;
-		}
+		skb->len       = len;
+		skb->data_len  = 0;
+		skb->tail      = skb->data + len;
 	}
 
 	return 0;

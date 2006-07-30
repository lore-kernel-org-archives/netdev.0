From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [stable] [NET]: Update frag_list in pskb_trim
Date: Mon, 31 Jul 2006 08:50:37 +1000
Message-ID: <20060730225037.GA21685@gondor.apana.org.au>
References: <20060713090341.GA28426@gondor.apana.org.au> <20060713.220526.55726160.davem@davemloft.net> <20060715001003.GD9334@gondor.apana.org.au> <20060717152244.GA2174@kroah.com> <20060717181329.GA5934@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stable@kernel.org, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:35591 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S964774AbWG3WwF
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Jul 2006 18:52:05 -0400
To: Greg KH <greg@kroah.com>
Content-Disposition: inline
In-Reply-To: <20060717181329.GA5934@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For stable only:

On Tue, Jul 18, 2006 at 04:13:29AM +1000, herbert wrote:
> 
> Here is a second attempt:
> 
> [NET]: Update frag_list in pskb_trim

Unfortunately there was a bug in the fix which is now fixed.  I presume
this hasn't been included yet so I'm simply regenerating the whole patch.
Let me know if you want an incremental version instead.

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
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index f8f2347..2c31bb0 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -967,15 +967,16 @@ #ifndef NET_SKB_PAD
 #define NET_SKB_PAD	16
 #endif
 
-extern int ___pskb_trim(struct sk_buff *skb, unsigned int len, int realloc);
+extern int ___pskb_trim(struct sk_buff *skb, unsigned int len);
 
 static inline void __skb_trim(struct sk_buff *skb, unsigned int len)
 {
-	if (!skb->data_len) {
-		skb->len  = len;
-		skb->tail = skb->data + len;
-	} else
-		___pskb_trim(skb, len, 0);
+	if (unlikely(skb->data_len)) {
+		WARN_ON(1);
+		return;
+	}
+	skb->len  = len;
+	skb->tail = skb->data + len;
 }
 
 /**
@@ -985,6 +986,7 @@ static inline void __skb_trim(struct sk_
  *
  *	Cut the length of a buffer down by removing data from the tail. If
  *	the buffer is already under the length specified it is not modified.
+ *	The skb must be linear.
  */
 static inline void skb_trim(struct sk_buff *skb, unsigned int len)
 {
@@ -995,12 +997,10 @@ static inline void skb_trim(struct sk_bu
 
 static inline int __pskb_trim(struct sk_buff *skb, unsigned int len)
 {
-	if (!skb->data_len) {
-		skb->len  = len;
-		skb->tail = skb->data+len;
-		return 0;
-	}
-	return ___pskb_trim(skb, len, 1);
+	if (skb->data_len)
+		return ___pskb_trim(skb, len);
+	__skb_trim(skb, len);
+	return 0;
 }
 
 static inline int pskb_trim(struct sk_buff *skb, unsigned int len)
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index fb3770f..f3cfb36 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -250,11 +250,11 @@ nodata:
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
@@ -263,6 +263,11 @@ static void skb_drop_fraglist(struct sk_
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
@@ -800,49 +805,86 @@ struct sk_buff *skb_pad(struct sk_buff *
 	return nskb;
 }	
  
-/* Trims skb to length len. It can change skb pointers, if "realloc" is 1.
- * If realloc==0 and trimming is impossible without change of data,
- * it is BUG().
+/* Trims skb to length len. It can change skb pointers.
  */
 
-int ___pskb_trim(struct sk_buff *skb, unsigned int len, int realloc)
+int ___pskb_trim(struct sk_buff *skb, unsigned int len)
 {
+	struct sk_buff **fragp;
+	struct sk_buff *frag;
 	int offset = skb_headlen(skb);
 	int nfrags = skb_shinfo(skb)->nr_frags;
 	int i;
+	int err;
 
-	for (i = 0; i < nfrags; i++) {
+	if (skb_cloned(skb) &&
+	    unlikely((err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC))))
+		return err;
+
+	i = 0;
+	if (offset >= len)
+		goto drop_pages;
+
+	for (; i < nfrags; i++) {
 		int end = offset + skb_shinfo(skb)->frags[i].size;
-		if (end > len) {
-			if (skb_cloned(skb)) {
-				BUG_ON(!realloc);
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
+		skb_shinfo(skb)->frags[i++].size = len - offset;
+
+drop_pages:
+		skb_shinfo(skb)->nr_frags = i;
+
+		for (; i < nfrags; i++)
+			put_page(skb_shinfo(skb)->frags[i].page);
+
+		if (skb_shinfo(skb)->frag_list)
+			skb_drop_fraglist(skb);
+		goto done;
+	}
+
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
+			kfree_skb(frag);
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
 	}
 
-	if (offset < len) {
+done:
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

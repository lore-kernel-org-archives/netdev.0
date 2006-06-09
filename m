From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [4/3] [NET]: Warn in __skb_trim if skb is paged
Date: Fri, 9 Jun 2006 17:55:39 +1000
Message-ID: <20060609075538.GA22828@gondor.apana.org.au>
References: <20060609074234.GA17580@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="d6Gm4EdcadzBjdND"
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:52497 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751392AbWFIHzr
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jun 2006 03:55:47 -0400
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20060609074234.GA17580@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--d6Gm4EdcadzBjdND
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

[NET]: Warn in __skb_trim if skb is paged

It's better to warn and fail rather than rarely triggering BUG on paths
that incorrectly call skb_trim/__skb_trim on a non-linear skb.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--d6Gm4EdcadzBjdND
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="p4.patch"

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 197f2d2..6ceec04 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -971,15 +971,16 @@ #ifndef NET_SKB_PAD
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
@@ -989,6 +990,7 @@ static inline void __skb_trim(struct sk_
  *
  *	Cut the length of a buffer down by removing data from the tail. If
  *	the buffer is already under the length specified it is not modified.
+ *	The skb must be linear.
  */
 static inline void skb_trim(struct sk_buff *skb, unsigned int len)
 {
@@ -999,12 +1001,10 @@ static inline void skb_trim(struct sk_bu
 
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
index fb3770f..0af4861 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -800,12 +800,10 @@ struct sk_buff *skb_pad(struct sk_buff *
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
 	int offset = skb_headlen(skb);
 	int nfrags = skb_shinfo(skb)->nr_frags;
@@ -815,7 +813,6 @@ int ___pskb_trim(struct sk_buff *skb, un
 		int end = offset + skb_shinfo(skb)->frags[i].size;
 		if (end > len) {
 			if (skb_cloned(skb)) {
-				BUG_ON(!realloc);
 				if (pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
 					return -ENOMEM;
 			}

--d6Gm4EdcadzBjdND--

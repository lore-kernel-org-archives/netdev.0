From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: [PATCH v6 1/5] skbuff: return -EMSGSIZE in skb_to_sgvec to prevent overflow
Date: Tue, 25 Apr 2017 20:47:30 +0200
Message-ID: <20170425184734.26563-1-Jason@zx2c4.com>
References: <20170425155215.4835-1-Jason@zx2c4.com>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        David.Laight@aculab.com, kernel-hardening@lists.openwall.com,
        davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:60783 "EHLO frisell.zx2c4.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1432015AbdDYSrn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 25 Apr 2017 14:47:43 -0400
In-Reply-To: <20170425155215.4835-1-Jason@zx2c4.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a defense-in-depth measure in response to bugs like
4d6fa57b4dab ("macsec: avoid heap overflow in skb_to_sgvec"). While
we're at it, we also limit the amount of recursion this function is
allowed to do. Not actually providing a bounded base case is a future
diaster that we can easily avoid here.

Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
---
Changes v5->v6:
  * Use unlikely() for the rare overflow conditions.
  * Also bound recursion, since this is a potential disaster we can avert.

 net/core/skbuff.c | 31 ++++++++++++++++++++++++-------
 1 file changed, 24 insertions(+), 7 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index f86bf69cfb8d..24fb53f8534e 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3489,16 +3489,22 @@ void __init skb_init(void)
  *	@len: Length of buffer space to be mapped
  *
  *	Fill the specified scatter-gather list with mappings/pointers into a
- *	region of the buffer space attached to a socket buffer.
+ *	region of the buffer space attached to a socket buffer. Returns either
+ *	the number of scatterlist items used, or -EMSGSIZE if the contents
+ *	could not fit.
  */
 static int
-__skb_to_sgvec(struct sk_buff *skb, struct scatterlist *sg, int offset, int len)
+__skb_to_sgvec(struct sk_buff *skb, struct scatterlist *sg, int offset, int len,
+	       unsigned int recursion_level)
 {
 	int start = skb_headlen(skb);
 	int i, copy = start - offset;
 	struct sk_buff *frag_iter;
 	int elt = 0;
 
+	if (unlikely(recursion_level >= 32))
+		return -EMSGSIZE;
+
 	if (copy > 0) {
 		if (copy > len)
 			copy = len;
@@ -3517,6 +3523,8 @@ __skb_to_sgvec(struct sk_buff *skb, struct scatterlist *sg, int offset, int len)
 		end = start + skb_frag_size(&skb_shinfo(skb)->frags[i]);
 		if ((copy = end - offset) > 0) {
 			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+			if (unlikely(elt && sg_is_last(&sg[elt - 1])))
+				return -EMSGSIZE;
 
 			if (copy > len)
 				copy = len;
@@ -3531,16 +3539,22 @@ __skb_to_sgvec(struct sk_buff *skb, struct scatterlist *sg, int offset, int len)
 	}
 
 	skb_walk_frags(skb, frag_iter) {
-		int end;
+		int end, ret;
 
 		WARN_ON(start > offset + len);
 
 		end = start + frag_iter->len;
 		if ((copy = end - offset) > 0) {
+			if (unlikely(elt && sg_is_last(&sg[elt - 1])))
+				return -EMSGSIZE;
+
 			if (copy > len)
 				copy = len;
-			elt += __skb_to_sgvec(frag_iter, sg+elt, offset - start,
-					      copy);
+			ret = __skb_to_sgvec(frag_iter, sg+elt, offset - start,
+					      copy, recursion_level + 1);
+			if (unlikely(ret < 0))
+				return ret;
+			elt += ret;
 			if ((len -= copy) == 0)
 				return elt;
 			offset += copy;
@@ -3573,13 +3587,16 @@ __skb_to_sgvec(struct sk_buff *skb, struct scatterlist *sg, int offset, int len)
 int skb_to_sgvec_nomark(struct sk_buff *skb, struct scatterlist *sg,
 			int offset, int len)
 {
-	return __skb_to_sgvec(skb, sg, offset, len);
+	return __skb_to_sgvec(skb, sg, offset, len, 0);
 }
 EXPORT_SYMBOL_GPL(skb_to_sgvec_nomark);
 
 int skb_to_sgvec(struct sk_buff *skb, struct scatterlist *sg, int offset, int len)
 {
-	int nsg = __skb_to_sgvec(skb, sg, offset, len);
+	int nsg = __skb_to_sgvec(skb, sg, offset, len, 0);
+
+	if (nsg <= 0)
+		return nsg;
 
 	sg_mark_end(&sg[nsg - 1]);
 
-- 
2.12.2

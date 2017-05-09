From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: [PATCH v7 1/5] skbuff: return -EMSGSIZE in skb_to_sgvec to prevent overflow
Date: Tue,  9 May 2017 15:50:05 +0200
Message-ID: <20170509135009.13751-2-Jason@zx2c4.com>
References: <20170509135009.13751-1-Jason@zx2c4.com>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        David Howells <dhowells@redhat.com>,
        Sabrina Dubroca <sd@queasysnail.net>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Jason Wang <jasowang@redhat.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        davem@davemloft.net, kernel-hardening@lists.openwall.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170509135009.13751-1-Jason@zx2c4.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a defense-in-depth measure in response to bugs like
4d6fa57b4dab ("macsec: avoid heap overflow in skb_to_sgvec"). There's
not only a potential overflow of sglist items, but also a stack overflow
potential, so we fix this by limiting the amount of recursion this function
is allowed to do. Not actually providing a bounded base case is a future
disaster that we can easily avoid here.

As a small matter of house keeping, we take this opportunity to move the
documentation comment over the actual function the documentation is for.

While this could be implemented by using an explicit stack of skbuffs,
when implementing this, the function complexity increased considerably,
and I don't think such complexity and bloat is actually worth it. So,
instead I built this and tested it on x86, x86_64, ARM, ARM64, and MIPS,
and measured the stack usage there. I also reverted the recent MIPS
changes that give it a separate IRQ stack, so that I could experience
some worst-case situations. I found that limiting it to 24 layers deep
yielded a good stack usage with room for safety, as well as being much
deeper than any driver actually ever creates.

Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
Cc: Steffen Klassert <steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: David Howells <dhowells@redhat.com>
Cc: Sabrina Dubroca <sd@queasysnail.net>
Cc: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
---
 net/core/skbuff.c | 65 +++++++++++++++++++++++++++++++++++--------------------
 1 file changed, 42 insertions(+), 23 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index f86bf69cfb8d..ab51b97d5600 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3481,24 +3481,18 @@ void __init skb_init(void)
 						NULL);
 }
 
-/**
- *	skb_to_sgvec - Fill a scatter-gather list from a socket buffer
- *	@skb: Socket buffer containing the buffers to be mapped
- *	@sg: The scatter-gather list to map into
- *	@offset: The offset into the buffer's contents to start mapping
- *	@len: Length of buffer space to be mapped
- *
- *	Fill the specified scatter-gather list with mappings/pointers into a
- *	region of the buffer space attached to a socket buffer.
- */
 static int
-__skb_to_sgvec(struct sk_buff *skb, struct scatterlist *sg, int offset, int len)
+__skb_to_sgvec(struct sk_buff *skb, struct scatterlist *sg, int offset, int len,
+	       unsigned int recursion_level)
 {
 	int start = skb_headlen(skb);
 	int i, copy = start - offset;
 	struct sk_buff *frag_iter;
 	int elt = 0;
 
+	if (unlikely(recursion_level >= 24))
+		return -EMSGSIZE;
+
 	if (copy > 0) {
 		if (copy > len)
 			copy = len;
@@ -3517,6 +3511,8 @@ __skb_to_sgvec(struct sk_buff *skb, struct scatterlist *sg, int offset, int len)
 		end = start + skb_frag_size(&skb_shinfo(skb)->frags[i]);
 		if ((copy = end - offset) > 0) {
 			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+			if (unlikely(elt && sg_is_last(&sg[elt - 1])))
+				return -EMSGSIZE;
 
 			if (copy > len)
 				copy = len;
@@ -3531,16 +3527,22 @@ __skb_to_sgvec(struct sk_buff *skb, struct scatterlist *sg, int offset, int len)
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
@@ -3551,6 +3553,31 @@ __skb_to_sgvec(struct sk_buff *skb, struct scatterlist *sg, int offset, int len)
 	return elt;
 }
 
+/**
+ *	skb_to_sgvec - Fill a scatter-gather list from a socket buffer
+ *	@skb: Socket buffer containing the buffers to be mapped
+ *	@sg: The scatter-gather list to map into
+ *	@offset: The offset into the buffer's contents to start mapping
+ *	@len: Length of buffer space to be mapped
+ *
+ *	Fill the specified scatter-gather list with mappings/pointers into a
+ *	region of the buffer space attached to a socket buffer. Returns either
+ *	the number of scatterlist items used, or -EMSGSIZE if the contents
+ *	could not fit.
+ */
+int skb_to_sgvec(struct sk_buff *skb, struct scatterlist *sg, int offset, int len)
+{
+	int nsg = __skb_to_sgvec(skb, sg, offset, len, 0);
+
+	if (nsg <= 0)
+		return nsg;
+
+	sg_mark_end(&sg[nsg - 1]);
+
+	return nsg;
+}
+EXPORT_SYMBOL_GPL(skb_to_sgvec);
+
 /* As compared with skb_to_sgvec, skb_to_sgvec_nomark only map skb to given
  * sglist without mark the sg which contain last skb data as the end.
  * So the caller can mannipulate sg list as will when padding new data after
@@ -3573,19 +3600,11 @@ __skb_to_sgvec(struct sk_buff *skb, struct scatterlist *sg, int offset, int len)
 int skb_to_sgvec_nomark(struct sk_buff *skb, struct scatterlist *sg,
 			int offset, int len)
 {
-	return __skb_to_sgvec(skb, sg, offset, len);
+	return __skb_to_sgvec(skb, sg, offset, len, 0);
 }
 EXPORT_SYMBOL_GPL(skb_to_sgvec_nomark);
 
-int skb_to_sgvec(struct sk_buff *skb, struct scatterlist *sg, int offset, int len)
-{
-	int nsg = __skb_to_sgvec(skb, sg, offset, len);
 
-	sg_mark_end(&sg[nsg - 1]);
-
-	return nsg;
-}
-EXPORT_SYMBOL_GPL(skb_to_sgvec);
 
 /**
  *	skb_cow_data - Check that a socket buffer's data buffers are writable
-- 
2.12.2

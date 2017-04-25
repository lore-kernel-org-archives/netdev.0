From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: [PATCH v3 1/5] skbuff: return -EMSGSIZE in skb_to_sgvec to prevent overflow
Date: Tue, 25 Apr 2017 16:21:12 +0200
Message-ID: <20170425142112.29702-1-Jason@zx2c4.com>
References: <20170425141609.28459-1-Jason@zx2c4.com>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>
To: netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	davem@davemloft.net,
	David.Laight@aculab.com,
	kernel-hardening@lists.openwall.com
Return-path: <kernel-hardening-return-7559-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20170425141609.28459-1-Jason@zx2c4.com>
List-Id: netdev.vger.kernel.org

This is a defense-in-depth measure in response to bugs like
4d6fa57b4dab0d77f4d8e9d9c73d1e63f6fe8fee.

Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
---
Sorry for the completely stupid amount of churn - v1,v2,v3 in the span of
two minutes. It's just that after noticing first that nsg needs to be checked,
I also noticed something a bit worse: that there was a bug (exploitable?) where
if skb_to_sgvec was called with empty values, there would be an out-of-bounds
write into sg[0 - 1]. So, this third (and hopefully final!) patch fixes that
bug while we're at it.

 net/core/skbuff.c | 13 ++++++++++++-
 1 file changed, 12 insertions(+), 1 deletion(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index f86bf69cfb8d..d103134deddb 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3489,7 +3489,9 @@ void __init skb_init(void)
  *	@len: Length of buffer space to be mapped
  *
  *	Fill the specified scatter-gather list with mappings/pointers into a
- *	region of the buffer space attached to a socket buffer.
+ *	region of the buffer space attached to a socket buffer. Returns either
+ *	the number of scatterlist items used, or -EMSGSIZE if the contents
+ *	could not fit.
  */
 static int
 __skb_to_sgvec(struct sk_buff *skb, struct scatterlist *sg, int offset, int len)
@@ -3512,6 +3514,9 @@ __skb_to_sgvec(struct sk_buff *skb, struct scatterlist *sg, int offset, int len)
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 		int end;
 
+		if (elt && sg_is_last(&sg[elt - 1]))
+			return -EMSGSIZE;
+
 		WARN_ON(start > offset + len);
 
 		end = start + skb_frag_size(&skb_shinfo(skb)->frags[i]);
@@ -3535,6 +3540,9 @@ __skb_to_sgvec(struct sk_buff *skb, struct scatterlist *sg, int offset, int len)
 
 		WARN_ON(start > offset + len);
 
+		if (elt && sg_is_last(&sg[elt - 1]))
+			return -EMSGSIZE;
+
 		end = start + frag_iter->len;
 		if ((copy = end - offset) > 0) {
 			if (copy > len)
@@ -3581,6 +3589,9 @@ int skb_to_sgvec(struct sk_buff *skb, struct scatterlist *sg, int offset, int le
 {
 	int nsg = __skb_to_sgvec(skb, sg, offset, len);
 
+	if (nsg <= 0)
+		return nsg;
+
 	sg_mark_end(&sg[nsg - 1]);
 
 	return nsg;
-- 
2.12.2

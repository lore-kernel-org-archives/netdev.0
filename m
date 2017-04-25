From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: [PATCH v4 1/5] skbuff: return -EMSGSIZE in skb_to_sgvec to prevent overflow
Date: Tue, 25 Apr 2017 17:04:19 +0200
Message-ID: <20170425150419.2060-1-Jason@zx2c4.com>
References: <20170425.104731.631398016575024152.davem@davemloft.net>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        davem@davemloft.net, David.Laight@aculab.com,
        kernel-hardening@lists.openwall.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170425.104731.631398016575024152.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a defense-in-depth measure in response to bugs like
4d6fa57b4dab ("macsec: avoid heap overflow in skb_to_sgvec")

Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
---
v4 fixes the commit message and moves the check into the inner-most if.

 net/core/skbuff.c | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index f86bf69cfb8d..e75640006d78 100644
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
@@ -3517,6 +3519,8 @@ __skb_to_sgvec(struct sk_buff *skb, struct scatterlist *sg, int offset, int len)
 		end = start + skb_frag_size(&skb_shinfo(skb)->frags[i]);
 		if ((copy = end - offset) > 0) {
 			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+			if (elt && sg_is_last(&sg[elt - 1]))
+				return -EMSGSIZE;
 
 			if (copy > len)
 				copy = len;
@@ -3537,6 +3541,9 @@ __skb_to_sgvec(struct sk_buff *skb, struct scatterlist *sg, int offset, int len)
 
 		end = start + frag_iter->len;
 		if ((copy = end - offset) > 0) {
+			if (elt && sg_is_last(&sg[elt - 1]))
+				return -EMSGSIZE;
+
 			if (copy > len)
 				copy = len;
 			elt += __skb_to_sgvec(frag_iter, sg+elt, offset - start,
@@ -3581,6 +3588,9 @@ int skb_to_sgvec(struct sk_buff *skb, struct scatterlist *sg, int offset, int le
 {
 	int nsg = __skb_to_sgvec(skb, sg, offset, len);
 
+	if (nsg <= 0)
+		return nsg;
+
 	sg_mark_end(&sg[nsg - 1]);
 
 	return nsg;
-- 
2.12.2

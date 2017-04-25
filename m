From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: [PATCH 1/5] skbuff: return -EMSGSIZE in skb_to_sgvec to prevent overflow
Date: Tue, 25 Apr 2017 16:08:05 +0200
Message-ID: <20170425140809.23881-1-Jason@zx2c4.com>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        davem@davemloft.net, David.Laight@aculab.com,
        kernel-hardening@lists.openwall.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a defense-in-depth measure in response to bugs like
4d6fa57b4dab0d77f4d8e9d9c73d1e63f6fe8fee.

Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
---
 net/core/skbuff.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index f86bf69cfb8d..3c2a7f323722 100644
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
-- 
2.12.2

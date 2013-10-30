From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 4/5] net: skb_checksum: allow custom update/combine for walking skb
Date: Wed, 30 Oct 2013 11:50:51 +0100
Message-ID: <1383130252-1515-5-git-send-email-dborkman@redhat.com>
References: <1383130252-1515-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33762 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751739Ab3J3KvO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Oct 2013 06:51:14 -0400
In-Reply-To: <1383130252-1515-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, skb_checksum walks over 1) linearized, 2) frags[], and
3) frag_list data and calculats the one's complement, a 32 bit
result suitable for feeding into itself or csum_tcpudp_magic(),
but unsuitable for SCTP as we're calculating CRC32c there.

Hence, in order to not re-implement the very same function in
SCTP (and maybe other protocols) over and over again, use an
update() + combine() callback internally to allow for walking
over the skb with different algorithms.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 include/linux/skbuff.h | 13 ++++++++++---
 include/net/checksum.h |  6 ++++++
 net/core/skbuff.c      | 31 +++++++++++++++++++++----------
 3 files changed, 37 insertions(+), 13 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 2c15497..44727b5 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2360,8 +2360,6 @@ int skb_copy_datagram_const_iovec(const struct sk_buff *from, int offset,
 void skb_free_datagram(struct sock *sk, struct sk_buff *skb);
 void skb_free_datagram_locked(struct sock *sk, struct sk_buff *skb);
 int skb_kill_datagram(struct sock *sk, struct sk_buff *skb, unsigned int flags);
-__wsum skb_checksum(const struct sk_buff *skb, int offset, int len,
-		    __wsum csum);
 int skb_copy_bits(const struct sk_buff *skb, int offset, void *to, int len);
 int skb_store_bits(struct sk_buff *skb, int offset, const void *from, int len);
 __wsum skb_copy_and_csum_bits(const struct sk_buff *skb, int offset, u8 *to,
@@ -2373,9 +2371,18 @@ void skb_copy_and_csum_dev(const struct sk_buff *skb, u8 *to);
 void skb_split(struct sk_buff *skb, struct sk_buff *skb1, const u32 len);
 int skb_shift(struct sk_buff *tgt, struct sk_buff *skb, int shiftlen);
 void skb_scrub_packet(struct sk_buff *skb, bool xnet);
-
 struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features);
 
+struct skb_checksum_ops {
+	__wsum (*update)(const void *mem, int len, __wsum wsum);
+	__wsum (*combine)(__wsum csum, __wsum csum2, int offset, int len);
+};
+
+__wsum __skb_checksum(const struct sk_buff *skb, int offset, int len,
+		      __wsum csum, const struct skb_checksum_ops *ops);
+__wsum skb_checksum(const struct sk_buff *skb, int offset, int len,
+		    __wsum csum);
+
 static inline void *skb_header_pointer(const struct sk_buff *skb, int offset,
 				       int len, void *buffer)
 {
diff --git a/include/net/checksum.h b/include/net/checksum.h
index 8f59ca5..15f33fd 100644
--- a/include/net/checksum.h
+++ b/include/net/checksum.h
@@ -79,6 +79,12 @@ csum_block_add(__wsum csum, __wsum csum2, int offset)
 }
 
 static inline __wsum
+csum_block_add_ext(__wsum csum, __wsum csum2, int offset, int len)
+{
+	return csum_block_add(csum, csum2, offset);
+}
+
+static inline __wsum
 csum_block_sub(__wsum csum, __wsum csum2, int offset)
 {
 	u32 sum = (__force u32)csum2;
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 0ab32fa..31aab53 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1928,9 +1928,8 @@ fault:
 EXPORT_SYMBOL(skb_store_bits);
 
 /* Checksum skb data. */
-
-__wsum skb_checksum(const struct sk_buff *skb, int offset,
-			  int len, __wsum csum)
+__wsum __skb_checksum(const struct sk_buff *skb, int offset, int len,
+		      __wsum csum, const struct skb_checksum_ops *ops)
 {
 	int start = skb_headlen(skb);
 	int i, copy = start - offset;
@@ -1941,7 +1940,7 @@ __wsum skb_checksum(const struct sk_buff *skb, int offset,
 	if (copy > 0) {
 		if (copy > len)
 			copy = len;
-		csum = csum_partial(skb->data + offset, copy, csum);
+		csum = ops->update(skb->data + offset, copy, csum);
 		if ((len -= copy) == 0)
 			return csum;
 		offset += copy;
@@ -1962,10 +1961,10 @@ __wsum skb_checksum(const struct sk_buff *skb, int offset,
 			if (copy > len)
 				copy = len;
 			vaddr = kmap_atomic(skb_frag_page(frag));
-			csum2 = csum_partial(vaddr + frag->page_offset +
-					     offset - start, copy, 0);
+			csum2 = ops->update(vaddr + frag->page_offset +
+					    offset - start, copy, 0);
 			kunmap_atomic(vaddr);
-			csum = csum_block_add(csum, csum2, pos);
+			csum = ops->combine(csum, csum2, pos, copy);
 			if (!(len -= copy))
 				return csum;
 			offset += copy;
@@ -1984,9 +1983,9 @@ __wsum skb_checksum(const struct sk_buff *skb, int offset,
 			__wsum csum2;
 			if (copy > len)
 				copy = len;
-			csum2 = skb_checksum(frag_iter, offset - start,
-					     copy, 0);
-			csum = csum_block_add(csum, csum2, pos);
+			csum2 = __skb_checksum(frag_iter, offset - start,
+					       copy, 0, ops);
+			csum = ops->combine(csum, csum2, pos, copy);
 			if ((len -= copy) == 0)
 				return csum;
 			offset += copy;
@@ -1998,6 +1997,18 @@ __wsum skb_checksum(const struct sk_buff *skb, int offset,
 
 	return csum;
 }
+EXPORT_SYMBOL(__skb_checksum);
+
+__wsum skb_checksum(const struct sk_buff *skb, int offset,
+		    int len, __wsum csum)
+{
+	const struct skb_checksum_ops ops = {
+		.update  = csum_partial,
+		.combine = csum_block_add_ext,
+	};
+
+	return __skb_checksum(skb, offset, len, csum, &ops);
+}
 EXPORT_SYMBOL(skb_checksum);
 
 /* Both of above in one bottle. */
-- 
1.8.3.1

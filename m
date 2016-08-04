From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net 2/3] bpf: fix checksum fixups on bpf_skb_store_bytes
Date: Thu,  4 Aug 2016 02:50:09 +0200
Message-ID: <2f540c548913c4daf4234fbe893d7714e73dfe88.1470270323.git.daniel@iogearbox.net>
References: <cover.1470270323.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:48984 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933278AbcHDAuY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2016 20:50:24 -0400
In-Reply-To: <cover.1470270323.git.daniel@iogearbox.net>
In-Reply-To: <cover.1470270323.git.daniel@iogearbox.net>
References: <cover.1470270323.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bpf_skb_store_bytes() invocations above L2 header need BPF_F_RECOMPUTE_CSUM
flag for updates, so that CHECKSUM_COMPLETE will be fixed up along the way.
Only other exception besides L2 header where BPF_F_RECOMPUTE_CSUM is not
passed to bpf_skb_store_bytes() are packet changes affecting pseudo headers
where we use bpf_l4_csum_replace() with BPF_F_PSEUDO_HDR flag that will
implicitly take care of CHECKSUM_COMPLETE.

Where we ran into an issue with bpf_skb_store_bytes() is when we did a
single-byte update on the IPv6 hoplimit despite using BPF_F_RECOMPUTE_CSUM
flag; simple ping via ICMPv6 triggered a hw csum failure as a result. The
underlying issue has been tracked down to a buffer alignment issue.

Meaning, that csum_partial() computations via skb_postpull_rcsum() and
skb_postpush_rcsum() pair invoked (due to passing BPF_F_PSEUDO_HDR flag)
had a wrong result since they operated on an odd address for the hoplimit,
while other computations were done on an even address. This mix doesn't
work as-is with skb_postpull_rcsum(), skb_postpush_rcsum() pair as it always
expects at least half-word alignment of input buffers, which is normally
the case. Thus, instead of these helpers using csum_sub() and (implicitly)
csum_add(), we need to use csum_block_sub(), csum_block_add(), respectively.
For unaligned offsets, they rotate the sum to align it to a half-word
boundary again, otherwise they do the same as csum_sub() and csum_add().

Adding __skb_postpull_rcsum(), __skb_postpush_rcsum() variants that take
the offset as an input and adapting bpf_skb_store_bytes() to them fixes
the hw csum failures again. The skb_postpull_rcsum(), skb_postpush_rcsum()
helpers use a 0 constant for offset so that the compiler optimizes the
offset & 1 test away and generates the same code as with csum_sub()/_add().

Fixes: 608cd71a9c7c ("tc: bpf: generalize pedit action")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 include/linux/skbuff.h | 38 ++++++++++++++++++++++----------------
 net/core/filter.c      |  4 ++--
 2 files changed, 24 insertions(+), 18 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 6f0b3e0..5f8c2fa 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2858,35 +2858,41 @@ static inline int skb_linearize_cow(struct sk_buff *skb)
  *	CHECKSUM_NONE so that it can be recomputed from scratch.
  */
 
-static inline void skb_postpull_rcsum(struct sk_buff *skb,
-				      const void *start, unsigned int len)
+static __always_inline void
+__skb_postpull_rcsum(struct sk_buff *skb, const void *start, unsigned int len,
+		     unsigned int off)
 {
 	if (skb->ip_summed == CHECKSUM_COMPLETE)
-		skb->csum = csum_sub(skb->csum, csum_partial(start, len, 0));
+		skb->csum = csum_block_sub(skb->csum,
+					   csum_partial(start, len, 0), off);
 	else if (skb->ip_summed == CHECKSUM_PARTIAL &&
 		 skb_checksum_start_offset(skb) < 0)
 		skb->ip_summed = CHECKSUM_NONE;
 }
 
-unsigned char *skb_pull_rcsum(struct sk_buff *skb, unsigned int len);
+static inline void skb_postpull_rcsum(struct sk_buff *skb,
+				      const void *start, unsigned int len)
+{
+	__skb_postpull_rcsum(skb, start, len, 0);
+}
+
+static __always_inline void
+__skb_postpush_rcsum(struct sk_buff *skb, const void *start, unsigned int len,
+		     unsigned int off)
+{
+	if (skb->ip_summed == CHECKSUM_COMPLETE)
+		skb->csum = csum_block_add(skb->csum,
+					   csum_partial(start, len, 0), off);
+}
 
 static inline void skb_postpush_rcsum(struct sk_buff *skb,
 				      const void *start, unsigned int len)
 {
-	/* For performing the reverse operation to skb_postpull_rcsum(),
-	 * we can instead of ...
-	 *
-	 *   skb->csum = csum_add(skb->csum, csum_partial(start, len, 0));
-	 *
-	 * ... just use this equivalent version here to save a few
-	 * instructions. Feeding csum of 0 in csum_partial() and later
-	 * on adding skb->csum is equivalent to feed skb->csum in the
-	 * first place.
-	 */
-	if (skb->ip_summed == CHECKSUM_COMPLETE)
-		skb->csum = csum_partial(start, len, skb->csum);
+	__skb_postpush_rcsum(skb, start, len, 0);
 }
 
+unsigned char *skb_pull_rcsum(struct sk_buff *skb, unsigned int len);
+
 /**
  *	skb_push_rcsum - push skb and update receive checksum
  *	@skb: buffer to update
diff --git a/net/core/filter.c b/net/core/filter.c
index c46244f..5ecd5c9 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1401,7 +1401,7 @@ static u64 bpf_skb_store_bytes(u64 r1, u64 r2, u64 r3, u64 r4, u64 flags)
 		return -EFAULT;
 
 	if (flags & BPF_F_RECOMPUTE_CSUM)
-		skb_postpull_rcsum(skb, ptr, len);
+		__skb_postpull_rcsum(skb, ptr, len, offset);
 
 	memcpy(ptr, from, len);
 
@@ -1410,7 +1410,7 @@ static u64 bpf_skb_store_bytes(u64 r1, u64 r2, u64 r3, u64 r4, u64 flags)
 		skb_store_bits(skb, offset, ptr, len);
 
 	if (flags & BPF_F_RECOMPUTE_CSUM)
-		skb_postpush_rcsum(skb, ptr, len);
+		__skb_postpush_rcsum(skb, ptr, len, offset);
 	if (flags & BPF_F_INVALIDATE_HASH)
 		skb_clear_hash(skb);
 
-- 
1.9.3

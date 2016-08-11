From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net] bpf: fix write helpers with regards to non-linear parts
Date: Thu, 11 Aug 2016 21:38:37 +0200
Message-ID: <c281218e107134c8d30d1aafe2aca15fcf8e43df.1470941847.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:51871 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752057AbcHKTis (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2016 15:38:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the bpf_try_make_writable() helper and all call sites we have in BPF,
it's currently defect with regards to skbs when the write_len spans into
non-linear parts, no matter if cloned or not.

There are multiple issues at once. First, using skb_store_bits() is not
correct since even if we have a cloned skb, page frags can still be shared.
To really make them private, we need to pull them in via __pskb_pull_tail()
first, which also gets us a private head via pskb_expand_head() implicitly.

This is for helpers like bpf_skb_store_bytes(), bpf_l3_csum_replace(),
bpf_l4_csum_replace(). Really, the only thing reasonable and working here
is to call skb_ensure_writable() before any write operation. Meaning, via
pskb_may_pull() it makes sure that parts we want to access are pulled in and
if not does so plus unclones the skb implicitly. If our write_len still fits
the headlen and we're cloned and our header of the clone is not writable,
then we need to make a private copy via pskb_expand_head(). skb_store_bits()
is a bit misleading and only safe to store into non-linear data in different
contexts such as 357b40a18b04 ("[IPV6]: IPV6_CHECKSUM socket option can
corrupt kernel memory").

For above BPF helper functions, it means after fixed bpf_try_make_writable(),
we've pulled in enough, so that we operate always based on skb->data. Thus,
the call to skb_header_pointer() and skb_store_bits() becomes superfluous.
In bpf_skb_store_bytes(), the len check is unnecessary too since it can
only pass in maximum of BPF stack size, so adding offset is guaranteed to
never overflow. Also bpf_l3/4_csum_replace() helpers must test for proper
offset alignment since they use __sum16 pointer for writing resulting csum.

The remaining helpers that change skb data not discussed here yet are
bpf_skb_vlan_push(), bpf_skb_vlan_pop() and bpf_skb_change_proto(). The
vlan helpers internally call either skb_ensure_writable() (pop case) and
skb_cow_head() (push case, for head expansion), respectively. Similarly,
bpf_skb_proto_xlat() takes care to not mangle page frags.

Fixes: 608cd71a9c7c ("tc: bpf: generalize pedit action")
Fixes: 91bc4822c3d6 ("tc: bpf: add checksum helpers")
Fixes: 3697649ff29e ("bpf: try harder on clones when writing into skb")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 net/core/filter.c | 70 ++++++++++++++-----------------------------------------
 1 file changed, 18 insertions(+), 52 deletions(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index b5add4e..927e136 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1355,13 +1355,9 @@ static inline int bpf_try_make_writable(struct sk_buff *skb,
 {
 	int err;
 
-	if (!skb_cloned(skb))
-		return 0;
-	if (skb_clone_writable(skb, write_len))
-		return 0;
-	err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
-	if (!err)
-		bpf_compute_data_end(skb);
+	err = skb_ensure_writable(skb, write_len);
+	bpf_compute_data_end(skb);
+
 	return err;
 }
 
@@ -1379,42 +1375,25 @@ static inline void bpf_pull_mac_rcsum(struct sk_buff *skb)
 
 static u64 bpf_skb_store_bytes(u64 r1, u64 r2, u64 r3, u64 r4, u64 flags)
 {
-	struct bpf_scratchpad *sp = this_cpu_ptr(&bpf_sp);
 	struct sk_buff *skb = (struct sk_buff *) (long) r1;
-	int offset = (int) r2;
+	unsigned int offset = (unsigned int) r2;
 	void *from = (void *) (long) r3;
 	unsigned int len = (unsigned int) r4;
 	void *ptr;
 
 	if (unlikely(flags & ~(BPF_F_RECOMPUTE_CSUM | BPF_F_INVALIDATE_HASH)))
 		return -EINVAL;
-
-	/* bpf verifier guarantees that:
-	 * 'from' pointer points to bpf program stack
-	 * 'len' bytes of it were initialized
-	 * 'len' > 0
-	 * 'skb' is a valid pointer to 'struct sk_buff'
-	 *
-	 * so check for invalid 'offset' and too large 'len'
-	 */
-	if (unlikely((u32) offset > 0xffff || len > sizeof(sp->buff)))
+	if (unlikely(offset > 0xffff))
 		return -EFAULT;
 	if (unlikely(bpf_try_make_writable(skb, offset + len)))
 		return -EFAULT;
 
-	ptr = skb_header_pointer(skb, offset, len, sp->buff);
-	if (unlikely(!ptr))
-		return -EFAULT;
-
+	ptr = skb->data + offset;
 	if (flags & BPF_F_RECOMPUTE_CSUM)
 		__skb_postpull_rcsum(skb, ptr, len, offset);
 
 	memcpy(ptr, from, len);
 
-	if (ptr == sp->buff)
-		/* skb_store_bits cannot return -EFAULT here */
-		skb_store_bits(skb, offset, ptr, len);
-
 	if (flags & BPF_F_RECOMPUTE_CSUM)
 		__skb_postpush_rcsum(skb, ptr, len, offset);
 	if (flags & BPF_F_INVALIDATE_HASH)
@@ -1437,12 +1416,12 @@ static const struct bpf_func_proto bpf_skb_store_bytes_proto = {
 static u64 bpf_skb_load_bytes(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
 {
 	const struct sk_buff *skb = (const struct sk_buff *)(unsigned long) r1;
-	int offset = (int) r2;
+	unsigned int offset = (unsigned int) r2;
 	void *to = (void *)(unsigned long) r3;
 	unsigned int len = (unsigned int) r4;
 	void *ptr;
 
-	if (unlikely((u32) offset > 0xffff))
+	if (unlikely(offset > 0xffff))
 		goto err_clear;
 
 	ptr = skb_header_pointer(skb, offset, len, to);
@@ -1470,20 +1449,17 @@ static const struct bpf_func_proto bpf_skb_load_bytes_proto = {
 static u64 bpf_l3_csum_replace(u64 r1, u64 r2, u64 from, u64 to, u64 flags)
 {
 	struct sk_buff *skb = (struct sk_buff *) (long) r1;
-	int offset = (int) r2;
-	__sum16 sum, *ptr;
+	unsigned int offset = (unsigned int) r2;
+	__sum16 *ptr;
 
 	if (unlikely(flags & ~(BPF_F_HDR_FIELD_MASK)))
 		return -EINVAL;
-	if (unlikely((u32) offset > 0xffff))
-		return -EFAULT;
-	if (unlikely(bpf_try_make_writable(skb, offset + sizeof(sum))))
+	if (unlikely(offset > 0xffff || offset & 1))
 		return -EFAULT;
-
-	ptr = skb_header_pointer(skb, offset, sizeof(sum), &sum);
-	if (unlikely(!ptr))
+	if (unlikely(bpf_try_make_writable(skb, offset + sizeof(*ptr))))
 		return -EFAULT;
 
+	ptr = (__sum16 *)(skb->data + offset);
 	switch (flags & BPF_F_HDR_FIELD_MASK) {
 	case 0:
 		if (unlikely(from != 0))
@@ -1501,10 +1477,6 @@ static u64 bpf_l3_csum_replace(u64 r1, u64 r2, u64 from, u64 to, u64 flags)
 		return -EINVAL;
 	}
 
-	if (ptr == &sum)
-		/* skb_store_bits guaranteed to not return -EFAULT here */
-		skb_store_bits(skb, offset, ptr, sizeof(sum));
-
 	return 0;
 }
 
@@ -1524,20 +1496,18 @@ static u64 bpf_l4_csum_replace(u64 r1, u64 r2, u64 from, u64 to, u64 flags)
 	struct sk_buff *skb = (struct sk_buff *) (long) r1;
 	bool is_pseudo = flags & BPF_F_PSEUDO_HDR;
 	bool is_mmzero = flags & BPF_F_MARK_MANGLED_0;
-	int offset = (int) r2;
-	__sum16 sum, *ptr;
+	unsigned int offset = (unsigned int) r2;
+	__sum16 *ptr;
 
 	if (unlikely(flags & ~(BPF_F_MARK_MANGLED_0 | BPF_F_PSEUDO_HDR |
 			       BPF_F_HDR_FIELD_MASK)))
 		return -EINVAL;
-	if (unlikely((u32) offset > 0xffff))
+	if (unlikely(offset > 0xffff || offset & 1))
 		return -EFAULT;
-	if (unlikely(bpf_try_make_writable(skb, offset + sizeof(sum))))
+	if (unlikely(bpf_try_make_writable(skb, offset + sizeof(*ptr))))
 		return -EFAULT;
 
-	ptr = skb_header_pointer(skb, offset, sizeof(sum), &sum);
-	if (unlikely(!ptr))
-		return -EFAULT;
+	ptr = (__sum16 *)(skb->data + offset);
 	if (is_mmzero && !*ptr)
 		return 0;
 
@@ -1560,10 +1530,6 @@ static u64 bpf_l4_csum_replace(u64 r1, u64 r2, u64 from, u64 to, u64 flags)
 
 	if (is_mmzero && !*ptr)
 		*ptr = CSUM_MANGLED_0;
-	if (ptr == &sum)
-		/* skb_store_bits guaranteed to not return -EFAULT here */
-		skb_store_bits(skb, offset, ptr, sizeof(sum));
-
 	return 0;
 }
 
-- 
1.9.3

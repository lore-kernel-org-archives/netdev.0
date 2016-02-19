From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 5/6] bpf: fix csum update in bpf_l4_csum_replace helper for udp
Date: Fri, 19 Feb 2016 23:05:26 +0100
Message-ID: <afa35b68009c7f0c1a028b9688293dfc18b986bb.1455899111.git.daniel@iogearbox.net>
References: <cover.1455899111.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:35346 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2993130AbcBSWFk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2016 17:05:40 -0500
In-Reply-To: <cover.1455899111.git.daniel@iogearbox.net>
In-Reply-To: <cover.1455899111.git.daniel@iogearbox.net>
References: <cover.1455899111.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When using this helper for updating UDP checksums, we need to extend
this in order to write CSUM_MANGLED_0 for csum computations that result
into 0 as sum. Reason we need this is because packets with a checksum
could otherwise become incorrectly marked as a packet without a checksum.
Likewise, if the user indicates BPF_F_MARK_MANGLED_0, then we should
not turn packets without a checksum into ones with a checksum.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 include/uapi/linux/bpf.h | 1 +
 net/core/filter.c        | 8 +++++++-
 2 files changed, 8 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 48d0a6c..6496f98 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -313,6 +313,7 @@ enum bpf_func_id {
 
 /* BPF_FUNC_l4_csum_replace flags. */
 #define BPF_F_PSEUDO_HDR		(1ULL << 4)
+#define BPF_F_MARK_MANGLED_0		(1ULL << 5)
 
 /* BPF_FUNC_clone_redirect and BPF_FUNC_redirect flags. */
 #define BPF_F_INGRESS			(1ULL << 0)
diff --git a/net/core/filter.c b/net/core/filter.c
index f031b82..8a0b8c3 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1477,10 +1477,12 @@ static u64 bpf_l4_csum_replace(u64 r1, u64 r2, u64 from, u64 to, u64 flags)
 {
 	struct sk_buff *skb = (struct sk_buff *) (long) r1;
 	bool is_pseudo = flags & BPF_F_PSEUDO_HDR;
+	bool is_mmzero = flags & BPF_F_MARK_MANGLED_0;
 	int offset = (int) r2;
 	__sum16 sum, *ptr;
 
-	if (unlikely(flags & ~(BPF_F_PSEUDO_HDR | BPF_F_HDR_FIELD_MASK)))
+	if (unlikely(flags & ~(BPF_F_MARK_MANGLED_0 | BPF_F_PSEUDO_HDR |
+			       BPF_F_HDR_FIELD_MASK)))
 		return -EINVAL;
 	if (unlikely((u32) offset > 0xffff))
 		return -EFAULT;
@@ -1490,6 +1492,8 @@ static u64 bpf_l4_csum_replace(u64 r1, u64 r2, u64 from, u64 to, u64 flags)
 	ptr = skb_header_pointer(skb, offset, sizeof(sum), &sum);
 	if (unlikely(!ptr))
 		return -EFAULT;
+	if (is_mmzero && !*ptr)
+		return 0;
 
 	switch (flags & BPF_F_HDR_FIELD_MASK) {
 	case 0:
@@ -1508,6 +1512,8 @@ static u64 bpf_l4_csum_replace(u64 r1, u64 r2, u64 from, u64 to, u64 flags)
 		return -EINVAL;
 	}
 
+	if (is_mmzero && !*ptr)
+		*ptr = CSUM_MANGLED_0;
 	if (ptr == &sum)
 		/* skb_store_bits guaranteed to not return -EFAULT here */
 		skb_store_bits(skb, offset, ptr, sizeof(sum));
-- 
1.9.3

From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 3/6] bpf: remove artificial bpf_skb_{load,store}_bytes buffer limitation
Date: Fri, 19 Feb 2016 23:05:24 +0100
Message-ID: <73de0c7bbbc55fc456d175d235a2b2735742f2cc.1455899111.git.daniel@iogearbox.net>
References: <cover.1455899111.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:35335 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2993021AbcBSWFi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2016 17:05:38 -0500
In-Reply-To: <cover.1455899111.git.daniel@iogearbox.net>
In-Reply-To: <cover.1455899111.git.daniel@iogearbox.net>
References: <cover.1455899111.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We currently limit bpf_skb_store_bytes() and bpf_skb_load_bytes()
helpers to only store or load a maximum buffer of 16 bytes. Thus,
loading, rewriting and storing headers require several bpf_skb_load_bytes()
and bpf_skb_store_bytes() calls.

Also here we can use a per-cpu scratch buffer instead in order to not
pressure stack space any further. I do suspect that this limit was mainly
set in place for this particular reason. So, ease program development
by removing this limitation and make the scratchpad generic, so it can
be reused.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 net/core/filter.c | 27 ++++++++++++++-------------
 1 file changed, 14 insertions(+), 13 deletions(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index bf504f8..ea391e6 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1333,15 +1333,22 @@ int sk_reuseport_attach_bpf(u32 ufd, struct sock *sk)
 	return 0;
 }
 
-#define BPF_LDST_LEN 16U
+struct bpf_scratchpad {
+	union {
+		__be32 diff[MAX_BPF_STACK / sizeof(__be32)];
+		u8     buff[MAX_BPF_STACK];
+	};
+};
+
+static DEFINE_PER_CPU(struct bpf_scratchpad, bpf_sp);
 
 static u64 bpf_skb_store_bytes(u64 r1, u64 r2, u64 r3, u64 r4, u64 flags)
 {
+	struct bpf_scratchpad *sp = this_cpu_ptr(&bpf_sp);
 	struct sk_buff *skb = (struct sk_buff *) (long) r1;
 	int offset = (int) r2;
 	void *from = (void *) (long) r3;
 	unsigned int len = (unsigned int) r4;
-	char buf[BPF_LDST_LEN];
 	void *ptr;
 
 	if (unlikely(flags & ~(BPF_F_RECOMPUTE_CSUM)))
@@ -1355,14 +1362,14 @@ static u64 bpf_skb_store_bytes(u64 r1, u64 r2, u64 r3, u64 r4, u64 flags)
 	 *
 	 * so check for invalid 'offset' and too large 'len'
 	 */
-	if (unlikely((u32) offset > 0xffff || len > sizeof(buf)))
+	if (unlikely((u32) offset > 0xffff || len > sizeof(sp->buff)))
 		return -EFAULT;
 
 	if (unlikely(skb_cloned(skb) &&
 		     !skb_clone_writable(skb, offset + len)))
 		return -EFAULT;
 
-	ptr = skb_header_pointer(skb, offset, len, buf);
+	ptr = skb_header_pointer(skb, offset, len, sp->buff);
 	if (unlikely(!ptr))
 		return -EFAULT;
 
@@ -1371,7 +1378,7 @@ static u64 bpf_skb_store_bytes(u64 r1, u64 r2, u64 r3, u64 r4, u64 flags)
 
 	memcpy(ptr, from, len);
 
-	if (ptr == buf)
+	if (ptr == sp->buff)
 		/* skb_store_bits cannot return -EFAULT here */
 		skb_store_bits(skb, offset, ptr, len);
 
@@ -1400,7 +1407,7 @@ static u64 bpf_skb_load_bytes(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
 	unsigned int len = (unsigned int) r4;
 	void *ptr;
 
-	if (unlikely((u32) offset > 0xffff || len > BPF_LDST_LEN))
+	if (unlikely((u32) offset > 0xffff || len > MAX_BPF_STACK))
 		return -EFAULT;
 
 	ptr = skb_header_pointer(skb, offset, len, to);
@@ -1525,15 +1532,9 @@ const struct bpf_func_proto bpf_l4_csum_replace_proto = {
 	.arg5_type	= ARG_ANYTHING,
 };
 
-struct bpf_csum_scratchpad {
-	__be32 diff[128];
-};
-
-static DEFINE_PER_CPU(struct bpf_csum_scratchpad, bpf_csum_sp);
-
 static u64 bpf_csum_diff(u64 r1, u64 from_size, u64 r3, u64 to_size, u64 seed)
 {
-	struct bpf_csum_scratchpad *sp = this_cpu_ptr(&bpf_csum_sp);
+	struct bpf_scratchpad *sp = this_cpu_ptr(&bpf_sp);
 	u64 diff_size = from_size + to_size;
 	__be32 *from = (__be32 *) (long) r1;
 	__be32 *to   = (__be32 *) (long) r3;
-- 
1.9.3

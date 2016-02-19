From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 2/6] bpf: add generic bpf_csum_diff helper
Date: Fri, 19 Feb 2016 23:05:23 +0100
Message-ID: <190fead2d6136865cb2c8f7e94bcf3fbf4eea23f.1455899111.git.daniel@iogearbox.net>
References: <cover.1455899111.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:35328 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757039AbcBSWFh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2016 17:05:37 -0500
In-Reply-To: <cover.1455899111.git.daniel@iogearbox.net>
In-Reply-To: <cover.1455899111.git.daniel@iogearbox.net>
References: <cover.1455899111.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For L4 checksums, we currently have bpf_l4_csum_replace() helper. It's
currently limited to handle 2 and 4 byte changes in a header and feeds the
from/to into inet_proto_csum_replace{2,4}() helpers of the kernel. When
working with IPv6, for example, this makes it rather cumbersome to deal
with, similarly when editing larger parts of a header.

Instead, extend the API in a more generic way: For bpf_l4_csum_replace(),
add a case for header field mask of 0 to change the checksum at a given
offset through inet_proto_csum_replace_by_diff(), and provide a helper
bpf_csum_diff() that can generically calculate a from/to diff for arbitrary
amounts of data.

This can be used in multiple ways: for the bpf_l4_csum_replace() only
part, this even provides us with the option to insert precalculated diffs
from user space f.e. from a map, or from bpf_csum_diff() during runtime.

bpf_csum_diff() has a optional from/to stack buffer input, so we can
calculate a diff by using a scratchbuffer for scenarios where we're
inserting (from is NULL), removing (to is NULL) or diffing (from/to buffers
don't need to be of equal size) data. Also, bpf_csum_diff() allows to
feed a previous csum into csum_partial(), so the function can also be
cascaded.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 include/uapi/linux/bpf.h | 11 ++++++++++
 net/core/filter.c        | 53 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 64 insertions(+)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index d3e77da..48d0a6c 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -287,6 +287,17 @@ enum bpf_func_id {
 	 * Return: >= 0 stackid on success or negative error
 	 */
 	BPF_FUNC_get_stackid,
+
+	/**
+	 * bpf_csum_diff(from, from_size, to, to_size, seed) - calculate csum diff
+	 * @from: raw from buffer
+	 * @from_size: length of from buffer
+	 * @to: raw to buffer
+	 * @to_size: length of to buffer
+	 * @seed: optional seed
+	 * Return: csum result
+	 */
+	BPF_FUNC_csum_diff,
 	__BPF_FUNC_MAX_ID,
 };
 
diff --git a/net/core/filter.c b/net/core/filter.c
index 2a6e956..bf504f8 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1491,6 +1491,12 @@ static u64 bpf_l4_csum_replace(u64 r1, u64 r2, u64 from, u64 to, u64 flags)
 		return -EFAULT;
 
 	switch (flags & BPF_F_HDR_FIELD_MASK) {
+	case 0:
+		if (unlikely(from != 0))
+			return -EINVAL;
+
+		inet_proto_csum_replace_by_diff(ptr, skb, to, is_pseudo);
+		break;
 	case 2:
 		inet_proto_csum_replace2(ptr, skb, from, to, is_pseudo);
 		break;
@@ -1519,6 +1525,51 @@ const struct bpf_func_proto bpf_l4_csum_replace_proto = {
 	.arg5_type	= ARG_ANYTHING,
 };
 
+struct bpf_csum_scratchpad {
+	__be32 diff[128];
+};
+
+static DEFINE_PER_CPU(struct bpf_csum_scratchpad, bpf_csum_sp);
+
+static u64 bpf_csum_diff(u64 r1, u64 from_size, u64 r3, u64 to_size, u64 seed)
+{
+	struct bpf_csum_scratchpad *sp = this_cpu_ptr(&bpf_csum_sp);
+	u64 diff_size = from_size + to_size;
+	__be32 *from = (__be32 *) (long) r1;
+	__be32 *to   = (__be32 *) (long) r3;
+	int i, j = 0;
+
+	/* This is quite flexible, some examples:
+	 *
+	 * from_size == 0, to_size > 0,  seed := csum --> pushing data
+	 * from_size > 0,  to_size == 0, seed := csum --> pulling data
+	 * from_size > 0,  to_size > 0,  seed := 0    --> diffing data
+	 *
+	 * Even for diffing, from_size and to_size don't need to be equal.
+	 */
+	if (unlikely(((from_size | to_size) & (sizeof(__be32) - 1)) ||
+		     diff_size > sizeof(sp->diff)))
+		return -EINVAL;
+
+	for (i = 0; i < from_size / sizeof(__be32); i++, j++)
+		sp->diff[j] = ~from[i];
+	for (i = 0; i <   to_size / sizeof(__be32); i++, j++)
+		sp->diff[j] = to[i];
+
+	return csum_partial(sp->diff, diff_size, seed);
+}
+
+const struct bpf_func_proto bpf_csum_diff_proto = {
+	.func		= bpf_csum_diff,
+	.gpl_only	= false,
+	.ret_type	= RET_INTEGER,
+	.arg1_type	= ARG_PTR_TO_STACK,
+	.arg2_type	= ARG_CONST_STACK_SIZE_OR_ZERO,
+	.arg3_type	= ARG_PTR_TO_STACK,
+	.arg4_type	= ARG_CONST_STACK_SIZE_OR_ZERO,
+	.arg5_type	= ARG_ANYTHING,
+};
+
 static u64 bpf_clone_redirect(u64 r1, u64 ifindex, u64 flags, u64 r4, u64 r5)
 {
 	struct sk_buff *skb = (struct sk_buff *) (long) r1, *skb2;
@@ -1849,6 +1900,8 @@ tc_cls_act_func_proto(enum bpf_func_id func_id)
 		return &bpf_skb_store_bytes_proto;
 	case BPF_FUNC_skb_load_bytes:
 		return &bpf_skb_load_bytes_proto;
+	case BPF_FUNC_csum_diff:
+		return &bpf_csum_diff_proto;
 	case BPF_FUNC_l3_csum_replace:
 		return &bpf_l3_csum_replace_proto;
 	case BPF_FUNC_l4_csum_replace:
-- 
1.9.3

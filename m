From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 3/4] bpf: enable event output helper also for xdp types
Date: Thu, 18 Aug 2016 01:00:40 +0200
Message-ID: <d6995fe463f2ddb169c44e4d31169483aa8e7254.1471473110.git.daniel@iogearbox.net>
References: <cover.1471473110.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:34695 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753342AbcHQXCA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 19:02:00 -0400
In-Reply-To: <cover.1471473110.git.daniel@iogearbox.net>
In-Reply-To: <cover.1471473110.git.daniel@iogearbox.net>
References: <cover.1471473110.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Follow-up to 555c8a8623a3 ("bpf: avoid stack copy and use skb ctx for
event output") for also adding the event output helper for XDP typed
programs. The event output helper has been very useful in particular for
debugging or event notification purposes, since it's much faster and
flexible than regular trace printk due to programmatically being able to
attach meta data. Same flags structure applies as with tc BPF programs.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 net/core/filter.c | 42 +++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 41 insertions(+), 1 deletion(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index abf546d..3b60dfd 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2408,6 +2408,41 @@ static const struct bpf_func_proto bpf_skb_under_cgroup_proto = {
 };
 #endif
 
+static unsigned long bpf_xdp_copy(void *dst_buff, const void *src_buff,
+				  unsigned long off, unsigned long len)
+{
+	memcpy(dst_buff, src_buff + off, len);
+	return 0;
+}
+
+static u64 bpf_xdp_event_output(u64 r1, u64 r2, u64 flags, u64 r4,
+				u64 meta_size)
+{
+	struct xdp_buff *xdp = (struct xdp_buff *)(long) r1;
+	struct bpf_map *map = (struct bpf_map *)(long) r2;
+	u64 xdp_size = (flags & BPF_F_CTXLEN_MASK) >> 32;
+	void *meta = (void *)(long) r4;
+
+	if (unlikely(flags & ~(BPF_F_CTXLEN_MASK | BPF_F_INDEX_MASK)))
+		return -EINVAL;
+	if (unlikely(xdp_size > (unsigned long)(xdp->data_end - xdp->data)))
+		return -EFAULT;
+
+	return bpf_event_output(map, flags, meta, meta_size, xdp, xdp_size,
+				bpf_xdp_copy);
+}
+
+static const struct bpf_func_proto bpf_xdp_event_output_proto = {
+	.func		= bpf_xdp_event_output,
+	.gpl_only	= true,
+	.ret_type	= RET_INTEGER,
+	.arg1_type	= ARG_PTR_TO_CTX,
+	.arg2_type	= ARG_CONST_MAP_PTR,
+	.arg3_type	= ARG_ANYTHING,
+	.arg4_type	= ARG_PTR_TO_STACK,
+	.arg5_type	= ARG_CONST_STACK_SIZE,
+};
+
 static const struct bpf_func_proto *
 sk_filter_func_proto(enum bpf_func_id func_id)
 {
@@ -2492,7 +2527,12 @@ tc_cls_act_func_proto(enum bpf_func_id func_id)
 static const struct bpf_func_proto *
 xdp_func_proto(enum bpf_func_id func_id)
 {
-	return sk_filter_func_proto(func_id);
+	switch (func_id) {
+	case BPF_FUNC_perf_event_output:
+		return &bpf_xdp_event_output_proto;
+	default:
+		return sk_filter_func_proto(func_id);
+	}
 }
 
 static bool __is_valid_access(int off, int size, enum bpf_access_type type)
-- 
1.9.3

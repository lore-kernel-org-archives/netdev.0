From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 2/4] bpf: add BPF_SIZEOF and BPF_FIELD_SIZEOF macros
Date: Fri,  9 Sep 2016 02:45:29 +0200
Message-ID: <8d12813d3ce88d8a44d5247a994a482674dc3297.1473381476.git.daniel@iogearbox.net>
References: <cover.1473381476.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch,
        netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:33176 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751271AbcIIApo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 20:45:44 -0400
In-Reply-To: <cover.1473381476.git.daniel@iogearbox.net>
In-Reply-To: <cover.1473381476.git.daniel@iogearbox.net>
References: <cover.1473381476.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add BPF_SIZEOF() and BPF_FIELD_SIZEOF() macros to improve the code a bit
which otherwise often result in overly long bytes_to_bpf_size(sizeof())
and bytes_to_bpf_size(FIELD_SIZEOF()) lines. So place them into a macro
helper instead. Moreover, we currently have a BUILD_BUG_ON(BPF_FIELD_SIZEOF())
check in convert_bpf_extensions(), but we should rather make that generic
as well and add a BUILD_BUG_ON() test in all BPF_SIZEOF()/BPF_FIELD_SIZEOF()
users to detect any rewriter size issues at compile time. Note, there are
currently none, but we want to assert that it stays this way.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 include/linux/filter.h   | 14 ++++++++++++++
 kernel/trace/bpf_trace.c | 12 ++++++------
 net/core/filter.c        | 15 +++++++--------
 3 files changed, 27 insertions(+), 14 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index a16439b..7fabad8 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -314,6 +314,20 @@ struct bpf_prog_aux;
 	bpf_size;						\
 })
 
+#define BPF_SIZEOF(type)					\
+	({							\
+		const int __size = bytes_to_bpf_size(sizeof(type)); \
+		BUILD_BUG_ON(__size < 0);			\
+		__size;						\
+	})
+
+#define BPF_FIELD_SIZEOF(type, field)				\
+	({							\
+		const int __size = bytes_to_bpf_size(FIELD_SIZEOF(type, field)); \
+		BUILD_BUG_ON(__size < 0);			\
+		__size;						\
+	})
+
 #ifdef CONFIG_COMPAT
 /* A struct sock_filter is architecture independent. */
 struct compat_sock_fprog {
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index d3869b0..e63d7d4 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -583,18 +583,18 @@ static u32 pe_prog_convert_ctx_access(enum bpf_access_type type, int dst_reg,
 	switch (ctx_off) {
 	case offsetof(struct bpf_perf_event_data, sample_period):
 		BUILD_BUG_ON(FIELD_SIZEOF(struct perf_sample_data, period) != sizeof(u64));
-		*insn++ = BPF_LDX_MEM(bytes_to_bpf_size(FIELD_SIZEOF(struct bpf_perf_event_data_kern, data)),
-				      dst_reg, src_reg,
+
+		*insn++ = BPF_LDX_MEM(BPF_FIELD_SIZEOF(struct bpf_perf_event_data_kern,
+						       data), dst_reg, src_reg,
 				      offsetof(struct bpf_perf_event_data_kern, data));
 		*insn++ = BPF_LDX_MEM(BPF_DW, dst_reg, dst_reg,
 				      offsetof(struct perf_sample_data, period));
 		break;
 	default:
-		*insn++ = BPF_LDX_MEM(bytes_to_bpf_size(FIELD_SIZEOF(struct bpf_perf_event_data_kern, regs)),
-				      dst_reg, src_reg,
+		*insn++ = BPF_LDX_MEM(BPF_FIELD_SIZEOF(struct bpf_perf_event_data_kern,
+						       regs), dst_reg, src_reg,
 				      offsetof(struct bpf_perf_event_data_kern, regs));
-		*insn++ = BPF_LDX_MEM(bytes_to_bpf_size(sizeof(long)),
-				      dst_reg, dst_reg, ctx_off);
+		*insn++ = BPF_LDX_MEM(BPF_SIZEOF(long), dst_reg, dst_reg, ctx_off);
 		break;
 	}
 
diff --git a/net/core/filter.c b/net/core/filter.c
index 628ed8c..120c813 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -233,9 +233,8 @@ static bool convert_bpf_extensions(struct sock_filter *fp,
 	case SKF_AD_OFF + SKF_AD_HATYPE:
 		BUILD_BUG_ON(FIELD_SIZEOF(struct net_device, ifindex) != 4);
 		BUILD_BUG_ON(FIELD_SIZEOF(struct net_device, type) != 2);
-		BUILD_BUG_ON(bytes_to_bpf_size(FIELD_SIZEOF(struct sk_buff, dev)) < 0);
 
-		*insn++ = BPF_LDX_MEM(bytes_to_bpf_size(FIELD_SIZEOF(struct sk_buff, dev)),
+		*insn++ = BPF_LDX_MEM(BPF_FIELD_SIZEOF(struct sk_buff, dev),
 				      BPF_REG_TMP, BPF_REG_CTX,
 				      offsetof(struct sk_buff, dev));
 		/* if (tmp != 0) goto pc + 1 */
@@ -2685,7 +2684,7 @@ static u32 bpf_net_convert_ctx_access(enum bpf_access_type type, int dst_reg,
 	case offsetof(struct __sk_buff, ifindex):
 		BUILD_BUG_ON(FIELD_SIZEOF(struct net_device, ifindex) != 4);
 
-		*insn++ = BPF_LDX_MEM(bytes_to_bpf_size(FIELD_SIZEOF(struct sk_buff, dev)),
+		*insn++ = BPF_LDX_MEM(BPF_FIELD_SIZEOF(struct sk_buff, dev),
 				      dst_reg, src_reg,
 				      offsetof(struct sk_buff, dev));
 		*insn++ = BPF_JMP_IMM(BPF_JEQ, dst_reg, 0, 1);
@@ -2750,7 +2749,7 @@ static u32 bpf_net_convert_ctx_access(enum bpf_access_type type, int dst_reg,
 		break;
 
 	case offsetof(struct __sk_buff, data):
-		*insn++ = BPF_LDX_MEM(bytes_to_bpf_size(FIELD_SIZEOF(struct sk_buff, data)),
+		*insn++ = BPF_LDX_MEM(BPF_FIELD_SIZEOF(struct sk_buff, data),
 				      dst_reg, src_reg,
 				      offsetof(struct sk_buff, data));
 		break;
@@ -2759,8 +2758,8 @@ static u32 bpf_net_convert_ctx_access(enum bpf_access_type type, int dst_reg,
 		ctx_off -= offsetof(struct __sk_buff, data_end);
 		ctx_off += offsetof(struct sk_buff, cb);
 		ctx_off += offsetof(struct bpf_skb_data_end, data_end);
-		*insn++ = BPF_LDX_MEM(bytes_to_bpf_size(sizeof(void *)),
-				      dst_reg, src_reg, ctx_off);
+		*insn++ = BPF_LDX_MEM(BPF_SIZEOF(void *), dst_reg, src_reg,
+				      ctx_off);
 		break;
 
 	case offsetof(struct __sk_buff, tc_index):
@@ -2795,12 +2794,12 @@ static u32 xdp_convert_ctx_access(enum bpf_access_type type, int dst_reg,
 
 	switch (ctx_off) {
 	case offsetof(struct xdp_md, data):
-		*insn++ = BPF_LDX_MEM(bytes_to_bpf_size(FIELD_SIZEOF(struct xdp_buff, data)),
+		*insn++ = BPF_LDX_MEM(BPF_FIELD_SIZEOF(struct xdp_buff, data),
 				      dst_reg, src_reg,
 				      offsetof(struct xdp_buff, data));
 		break;
 	case offsetof(struct xdp_md, data_end):
-		*insn++ = BPF_LDX_MEM(bytes_to_bpf_size(FIELD_SIZEOF(struct xdp_buff, data_end)),
+		*insn++ = BPF_LDX_MEM(BPF_FIELD_SIZEOF(struct xdp_buff, data_end),
 				      dst_reg, src_reg,
 				      offsetof(struct xdp_buff, data_end));
 		break;
-- 
1.9.3

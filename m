From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 2/5] bpf: enable load bytes helper for filter/reuseport progs
Date: Tue, 24 Jan 2017 01:06:27 +0100
Message-ID: <8acdd034730a3e3a62de1b079df17a9d5a253427.1485214851.git.daniel@iogearbox.net>
References: <cover.1485214851.git.daniel@iogearbox.net>
Cc: netdev@vger.kernel.org, ast@kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:44965 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751003AbdAXAGl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 19:06:41 -0500
In-Reply-To: <cover.1485214851.git.daniel@iogearbox.net>
In-Reply-To: <cover.1485214851.git.daniel@iogearbox.net>
References: <cover.1485214851.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

BPF_PROG_TYPE_SOCKET_FILTER are used in various facilities such as
for SO_REUSEPORT and packet fanout demuxing, packet filtering, kcm,
etc, and yet the only facility they can use is BPF_LD with {BPF_ABS,
BPF_IND} for single byte/half/word access.

Direct packet access is only restricted to tc programs right now,
but we can still facilitate usage by allowing skb_load_bytes() helper
added back then in 05c74e5e53f6 ("bpf: add bpf_skb_load_bytes helper")
that calls skb_header_pointer() similarly to bpf_load_pointer(), but
for stack buffers with larger access size.

Name the previous sk_filter_func_proto() as bpf_base_func_proto()
since this is used everywhere else as well, similarly for the ctx
converter, that is, bpf_convert_ctx_access().

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 net/core/filter.c | 41 ++++++++++++++++++++++++++---------------
 1 file changed, 26 insertions(+), 15 deletions(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index 883975f..e2263da 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2598,7 +2598,7 @@ static unsigned long bpf_xdp_copy(void *dst_buff, const void *src_buff,
 };
 
 static const struct bpf_func_proto *
-sk_filter_func_proto(enum bpf_func_id func_id)
+bpf_base_func_proto(enum bpf_func_id func_id)
 {
 	switch (func_id) {
 	case BPF_FUNC_map_lookup_elem:
@@ -2626,6 +2626,17 @@ static unsigned long bpf_xdp_copy(void *dst_buff, const void *src_buff,
 }
 
 static const struct bpf_func_proto *
+sk_filter_func_proto(enum bpf_func_id func_id)
+{
+	switch (func_id) {
+	case BPF_FUNC_skb_load_bytes:
+		return &bpf_skb_load_bytes_proto;
+	default:
+		return bpf_base_func_proto(func_id);
+	}
+}
+
+static const struct bpf_func_proto *
 tc_cls_act_func_proto(enum bpf_func_id func_id)
 {
 	switch (func_id) {
@@ -2680,7 +2691,7 @@ static unsigned long bpf_xdp_copy(void *dst_buff, const void *src_buff,
 	case BPF_FUNC_skb_under_cgroup:
 		return &bpf_skb_under_cgroup_proto;
 	default:
-		return sk_filter_func_proto(func_id);
+		return bpf_base_func_proto(func_id);
 	}
 }
 
@@ -2695,7 +2706,7 @@ static unsigned long bpf_xdp_copy(void *dst_buff, const void *src_buff,
 	case BPF_FUNC_xdp_adjust_head:
 		return &bpf_xdp_adjust_head_proto;
 	default:
-		return sk_filter_func_proto(func_id);
+		return bpf_base_func_proto(func_id);
 	}
 }
 
@@ -2706,7 +2717,7 @@ static unsigned long bpf_xdp_copy(void *dst_buff, const void *src_buff,
 	case BPF_FUNC_skb_load_bytes:
 		return &bpf_skb_load_bytes_proto;
 	default:
-		return sk_filter_func_proto(func_id);
+		return bpf_base_func_proto(func_id);
 	}
 }
 
@@ -2733,7 +2744,7 @@ static unsigned long bpf_xdp_copy(void *dst_buff, const void *src_buff,
 	case BPF_FUNC_skb_under_cgroup:
 		return &bpf_skb_under_cgroup_proto;
 	default:
-		return sk_filter_func_proto(func_id);
+		return bpf_base_func_proto(func_id);
 	}
 }
 
@@ -2983,10 +2994,10 @@ void bpf_warn_invalid_xdp_action(u32 act)
 }
 EXPORT_SYMBOL_GPL(bpf_warn_invalid_xdp_action);
 
-static u32 sk_filter_convert_ctx_access(enum bpf_access_type type,
-					const struct bpf_insn *si,
-					struct bpf_insn *insn_buf,
-					struct bpf_prog *prog)
+static u32 bpf_convert_ctx_access(enum bpf_access_type type,
+				  const struct bpf_insn *si,
+				  struct bpf_insn *insn_buf,
+				  struct bpf_prog *prog)
 {
 	struct bpf_insn *insn = insn_buf;
 	int off;
@@ -3210,7 +3221,7 @@ static u32 tc_cls_act_convert_ctx_access(enum bpf_access_type type,
 				      offsetof(struct net_device, ifindex));
 		break;
 	default:
-		return sk_filter_convert_ctx_access(type, si, insn_buf, prog);
+		return bpf_convert_ctx_access(type, si, insn_buf, prog);
 	}
 
 	return insn - insn_buf;
@@ -3242,7 +3253,7 @@ static u32 xdp_convert_ctx_access(enum bpf_access_type type,
 static const struct bpf_verifier_ops sk_filter_ops = {
 	.get_func_proto		= sk_filter_func_proto,
 	.is_valid_access	= sk_filter_is_valid_access,
-	.convert_ctx_access	= sk_filter_convert_ctx_access,
+	.convert_ctx_access	= bpf_convert_ctx_access,
 };
 
 static const struct bpf_verifier_ops tc_cls_act_ops = {
@@ -3261,24 +3272,24 @@ static u32 xdp_convert_ctx_access(enum bpf_access_type type,
 static const struct bpf_verifier_ops cg_skb_ops = {
 	.get_func_proto		= cg_skb_func_proto,
 	.is_valid_access	= sk_filter_is_valid_access,
-	.convert_ctx_access	= sk_filter_convert_ctx_access,
+	.convert_ctx_access	= bpf_convert_ctx_access,
 };
 
 static const struct bpf_verifier_ops lwt_inout_ops = {
 	.get_func_proto		= lwt_inout_func_proto,
 	.is_valid_access	= lwt_is_valid_access,
-	.convert_ctx_access	= sk_filter_convert_ctx_access,
+	.convert_ctx_access	= bpf_convert_ctx_access,
 };
 
 static const struct bpf_verifier_ops lwt_xmit_ops = {
 	.get_func_proto		= lwt_xmit_func_proto,
 	.is_valid_access	= lwt_is_valid_access,
-	.convert_ctx_access	= sk_filter_convert_ctx_access,
+	.convert_ctx_access	= bpf_convert_ctx_access,
 	.gen_prologue		= tc_cls_act_prologue,
 };
 
 static const struct bpf_verifier_ops cg_sock_ops = {
-	.get_func_proto		= sk_filter_func_proto,
+	.get_func_proto		= bpf_base_func_proto,
 	.is_valid_access	= sock_filter_is_valid_access,
 	.convert_ctx_access	= sock_filter_convert_ctx_access,
 };
-- 
1.9.3

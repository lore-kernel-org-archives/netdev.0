From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 3/4] bpf: add own ctx rewriter on ifindex for clsact progs
Date: Fri,  9 Sep 2016 02:45:30 +0200
Message-ID: <cd1f33979a95c8aeacc0d98dc8303708605d83c5.1473381476.git.daniel@iogearbox.net>
References: <cover.1473381476.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch,
        netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:33183 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751290AbcIIApp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 20:45:45 -0400
In-Reply-To: <cover.1473381476.git.daniel@iogearbox.net>
In-Reply-To: <cover.1473381476.git.daniel@iogearbox.net>
References: <cover.1473381476.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When fetching ifindex, we don't need to test dev for being NULL since
we're always guaranteed to have a valid dev for clsact programs. Thus,
avoid this test in fast path.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 net/core/filter.c | 37 +++++++++++++++++++++++++++++++------
 1 file changed, 31 insertions(+), 6 deletions(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index 120c813..d6d9bb8 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2634,10 +2634,10 @@ void bpf_warn_invalid_xdp_action(u32 act)
 }
 EXPORT_SYMBOL_GPL(bpf_warn_invalid_xdp_action);
 
-static u32 bpf_net_convert_ctx_access(enum bpf_access_type type, int dst_reg,
-				      int src_reg, int ctx_off,
-				      struct bpf_insn *insn_buf,
-				      struct bpf_prog *prog)
+static u32 sk_filter_convert_ctx_access(enum bpf_access_type type, int dst_reg,
+					int src_reg, int ctx_off,
+					struct bpf_insn *insn_buf,
+					struct bpf_prog *prog)
 {
 	struct bpf_insn *insn = insn_buf;
 
@@ -2785,6 +2785,31 @@ static u32 bpf_net_convert_ctx_access(enum bpf_access_type type, int dst_reg,
 	return insn - insn_buf;
 }
 
+static u32 tc_cls_act_convert_ctx_access(enum bpf_access_type type, int dst_reg,
+					 int src_reg, int ctx_off,
+					 struct bpf_insn *insn_buf,
+					 struct bpf_prog *prog)
+{
+	struct bpf_insn *insn = insn_buf;
+
+	switch (ctx_off) {
+	case offsetof(struct __sk_buff, ifindex):
+		BUILD_BUG_ON(FIELD_SIZEOF(struct net_device, ifindex) != 4);
+
+		*insn++ = BPF_LDX_MEM(BPF_FIELD_SIZEOF(struct sk_buff, dev),
+				      dst_reg, src_reg,
+				      offsetof(struct sk_buff, dev));
+		*insn++ = BPF_LDX_MEM(BPF_W, dst_reg, dst_reg,
+				      offsetof(struct net_device, ifindex));
+		break;
+	default:
+		return sk_filter_convert_ctx_access(type, dst_reg, src_reg,
+						    ctx_off, insn_buf, prog);
+	}
+
+	return insn - insn_buf;
+}
+
 static u32 xdp_convert_ctx_access(enum bpf_access_type type, int dst_reg,
 				  int src_reg, int ctx_off,
 				  struct bpf_insn *insn_buf,
@@ -2811,13 +2836,13 @@ static u32 xdp_convert_ctx_access(enum bpf_access_type type, int dst_reg,
 static const struct bpf_verifier_ops sk_filter_ops = {
 	.get_func_proto		= sk_filter_func_proto,
 	.is_valid_access	= sk_filter_is_valid_access,
-	.convert_ctx_access	= bpf_net_convert_ctx_access,
+	.convert_ctx_access	= sk_filter_convert_ctx_access,
 };
 
 static const struct bpf_verifier_ops tc_cls_act_ops = {
 	.get_func_proto		= tc_cls_act_func_proto,
 	.is_valid_access	= tc_cls_act_is_valid_access,
-	.convert_ctx_access	= bpf_net_convert_ctx_access,
+	.convert_ctx_access	= tc_cls_act_convert_ctx_access,
 };
 
 static const struct bpf_verifier_ops xdp_ops = {
-- 
1.9.3

From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH 07/10] bpf: add access to sock fields and pkt data
 from sk_skb programs
Date: Tue, 15 Aug 2017 22:33:09 -0700
Message-ID: <20170816053309.15445.97681.stgit@john-Precision-Tower-5810>
References: <20170816052338.15445.83732.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org, john.fastabend@gmail.com,
        tom@herbertland.com
To: davem@davemloft.net, daniel@iogearbox.net, ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:35414 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751494AbdHPFd0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 01:33:26 -0400
Received: by mail-pg0-f66.google.com with SMTP id l64so4387264pge.2
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 22:33:26 -0700 (PDT)
In-Reply-To: <20170816052338.15445.83732.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: John Fastabend <john.fastabend@gmail.com>
---
 include/uapi/linux/bpf.h |    9 ++
 kernel/bpf/verifier.c    |    1 
 net/core/filter.c        |  169 ++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 179 insertions(+)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 7f77476..5ecbe81 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -712,6 +712,15 @@ struct __sk_buff {
 	__u32 data;
 	__u32 data_end;
 	__u32 napi_id;
+
+	/* accessed by BPF_PROG_TYPE_sk_skb types */
+	__u32 family;
+	__u32 remote_ip4;	/* Stored in network byte order */
+	__u32 local_ip4;	/* Stored in network byte order */
+	__u32 remote_ip6[4];	/* Stored in network byte order */
+	__u32 local_ip6[4];	/* Stored in network byte order */
+	__u32 remote_port;	/* Stored in network byte order */
+	__u32 local_port;	/* stored in host byte order */
 };
 
 struct bpf_tunnel_key {
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index a439ad5..bfed82e 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -848,6 +848,7 @@ static bool may_access_direct_pkt_data(struct bpf_verifier_env *env,
 	case BPF_PROG_TYPE_SCHED_ACT:
 	case BPF_PROG_TYPE_XDP:
 	case BPF_PROG_TYPE_LWT_XMIT:
+	case BPF_PROG_TYPE_SK_SKB:
 		if (meta)
 			return meta->pkt_access;
 
diff --git a/net/core/filter.c b/net/core/filter.c
index 934b92f..9a9e31f 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -3278,8 +3278,16 @@ static unsigned long bpf_xdp_copy(void *dst_buff, const void *src_buff,
 static const struct bpf_func_proto *sk_skb_func_proto(enum bpf_func_id func_id)
 {
 	switch (func_id) {
+	case BPF_FUNC_skb_store_bytes:
+		return &bpf_skb_store_bytes_proto;
 	case BPF_FUNC_skb_load_bytes:
 		return &bpf_skb_load_bytes_proto;
+	case BPF_FUNC_skb_pull_data:
+		return &bpf_skb_pull_data_proto;
+	case BPF_FUNC_skb_change_tail:
+		return &bpf_skb_change_tail_proto;
+	case BPF_FUNC_skb_change_head:
+		return &bpf_skb_change_head_proto;
 	case BPF_FUNC_get_socket_cookie:
 		return &bpf_get_socket_cookie_proto;
 	case BPF_FUNC_get_socket_uid:
@@ -3343,6 +3351,10 @@ static bool bpf_skb_is_valid_access(int off, int size, enum bpf_access_type type
 		if (off + size > offsetofend(struct __sk_buff, cb[4]))
 			return false;
 		break;
+	case bpf_ctx_range_till(struct __sk_buff, remote_ip6[0], remote_ip6[3]):
+	case bpf_ctx_range_till(struct __sk_buff, local_ip6[0], local_ip6[3]):
+	case bpf_ctx_range_till(struct __sk_buff, remote_ip4, remote_ip4):
+	case bpf_ctx_range_till(struct __sk_buff, local_ip4, local_ip4):
 	case bpf_ctx_range(struct __sk_buff, data):
 	case bpf_ctx_range(struct __sk_buff, data_end):
 		if (size != size_default)
@@ -3371,6 +3383,7 @@ static bool sk_filter_is_valid_access(int off, int size,
 	case bpf_ctx_range(struct __sk_buff, tc_classid):
 	case bpf_ctx_range(struct __sk_buff, data):
 	case bpf_ctx_range(struct __sk_buff, data_end):
+	case bpf_ctx_range_till(struct __sk_buff, family, local_port):
 		return false;
 	}
 
@@ -3392,6 +3405,7 @@ static bool lwt_is_valid_access(int off, int size,
 {
 	switch (off) {
 	case bpf_ctx_range(struct __sk_buff, tc_classid):
+	case bpf_ctx_range_till(struct __sk_buff, family, local_port):
 		return false;
 	}
 
@@ -3505,6 +3519,8 @@ static bool tc_cls_act_is_valid_access(int off, int size,
 	case bpf_ctx_range(struct __sk_buff, data_end):
 		info->reg_type = PTR_TO_PACKET_END;
 		break;
+	case bpf_ctx_range_till(struct __sk_buff, family, local_port):
+		return false;
 	}
 
 	return bpf_skb_is_valid_access(off, size, type, info);
@@ -3582,11 +3598,63 @@ static bool sock_ops_is_valid_access(int off, int size,
 	return __is_valid_sock_ops_access(off, size);
 }
 
+static int sk_skb_prologue(struct bpf_insn *insn_buf, bool direct_write,
+			   const struct bpf_prog *prog)
+{
+	struct bpf_insn *insn = insn_buf;
+
+	if (!direct_write)
+		return 0;
+
+	/* if (!skb->cloned)
+	 *       goto start;
+	 *
+	 * (Fast-path, otherwise approximation that we might be
+	 *  a clone, do the rest in helper.)
+	 */
+	*insn++ = BPF_LDX_MEM(BPF_B, BPF_REG_6, BPF_REG_1, CLONED_OFFSET());
+	*insn++ = BPF_ALU32_IMM(BPF_AND, BPF_REG_6, CLONED_MASK);
+	*insn++ = BPF_JMP_IMM(BPF_JEQ, BPF_REG_6, 0, 7);
+
+	/* ret = bpf_skb_pull_data(skb, 0); */
+	*insn++ = BPF_MOV64_REG(BPF_REG_6, BPF_REG_1);
+	*insn++ = BPF_ALU64_REG(BPF_XOR, BPF_REG_2, BPF_REG_2);
+	*insn++ = BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+			       BPF_FUNC_skb_pull_data);
+	/* if (!ret)
+	 *      goto restore;
+	 * return SK_DROP;
+	 */
+	*insn++ = BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 2);
+	*insn++ = BPF_ALU32_IMM(BPF_MOV, BPF_REG_0, SK_DROP);
+	*insn++ = BPF_EXIT_INSN();
+
+	/* restore: */
+	*insn++ = BPF_MOV64_REG(BPF_REG_1, BPF_REG_6);
+	/* start: */
+	*insn++ = prog->insnsi[0];
+
+	return insn - insn_buf;
+}
+
 static bool sk_skb_is_valid_access(int off, int size,
 				   enum bpf_access_type type,
 				   struct bpf_insn_access_aux *info)
 {
+	if (type == BPF_WRITE) {
+		switch (off) {
+		case bpf_ctx_range(struct __sk_buff, mark):
+		case bpf_ctx_range(struct __sk_buff, tc_index):
+		case bpf_ctx_range(struct __sk_buff, priority):
+			break;
+		default:
+			return false;
+		}
+	}
+
 	switch (off) {
+	case bpf_ctx_range(struct __sk_buff, tc_classid):
+		return false;
 	case bpf_ctx_range(struct __sk_buff, data):
 		info->reg_type = PTR_TO_PACKET;
 		break;
@@ -3781,6 +3849,106 @@ static u32 bpf_convert_ctx_access(enum bpf_access_type type,
 		*insn++ = BPF_MOV64_IMM(si->dst_reg, 0);
 #endif
 		break;
+	case offsetof(struct __sk_buff, family):
+		BUILD_BUG_ON(FIELD_SIZEOF(struct sock_common, skc_family) != 2);
+
+		*insn++ = BPF_LDX_MEM(BPF_FIELD_SIZEOF(struct sk_buff, sk),
+				      si->dst_reg, si->src_reg,
+				      offsetof(struct sk_buff, sk));
+		*insn++ = BPF_LDX_MEM(BPF_H, si->dst_reg, si->dst_reg,
+				      bpf_target_off(struct sock_common,
+						     skc_family,
+						     2, target_size));
+		break;
+	case offsetof(struct __sk_buff, remote_ip4):
+		BUILD_BUG_ON(FIELD_SIZEOF(struct sock_common, skc_daddr) != 4);
+
+		*insn++ = BPF_LDX_MEM(BPF_FIELD_SIZEOF(struct sk_buff, sk),
+				      si->dst_reg, si->src_reg,
+				      offsetof(struct sk_buff, sk));
+		*insn++ = BPF_LDX_MEM(BPF_W, si->dst_reg, si->dst_reg,
+				      bpf_target_off(struct sock_common,
+						     skc_daddr,
+						     4, target_size));
+		break;
+	case offsetof(struct __sk_buff, local_ip4):
+		BUILD_BUG_ON(FIELD_SIZEOF(struct sock_common,
+					  skc_rcv_saddr) != 4);
+
+		*insn++ = BPF_LDX_MEM(BPF_FIELD_SIZEOF(struct sk_buff, sk),
+				      si->dst_reg, si->src_reg,
+				      offsetof(struct sk_buff, sk));
+		*insn++ = BPF_LDX_MEM(BPF_W, si->dst_reg, si->dst_reg,
+				      bpf_target_off(struct sock_common,
+						     skc_rcv_saddr,
+						     4, target_size));
+		break;
+	case offsetof(struct __sk_buff, remote_ip6[0]) ...
+	     offsetof(struct __sk_buff, remote_ip6[3]):
+#if IS_ENABLED(CONFIG_IPV6)
+		BUILD_BUG_ON(FIELD_SIZEOF(struct sock_common,
+					  skc_v6_daddr.s6_addr32[0]) != 4);
+
+		off = si->off;
+		off -= offsetof(struct __sk_buff, remote_ip6[0]);
+
+		*insn++ = BPF_LDX_MEM(BPF_FIELD_SIZEOF(struct sk_buff, sk),
+				      si->dst_reg, si->src_reg,
+				      offsetof(struct sk_buff, sk));
+		*insn++ = BPF_LDX_MEM(BPF_W, si->dst_reg, si->dst_reg,
+				      offsetof(struct sock_common,
+					       skc_v6_daddr.s6_addr32[0]) +
+				      off);
+#else
+		*insn++ = BPF_MOV32_IMM(si->dst_reg, 0);
+#endif
+		break;
+	case offsetof(struct __sk_buff, local_ip6[0]) ...
+	     offsetof(struct __sk_buff, local_ip6[3]):
+#if IS_ENABLED(CONFIG_IPV6)
+		BUILD_BUG_ON(FIELD_SIZEOF(struct sock_common,
+					  skc_v6_rcv_saddr.s6_addr32[0]) != 4);
+
+		off = si->off;
+		off -= offsetof(struct __sk_buff, local_ip6[0]);
+
+		*insn++ = BPF_LDX_MEM(BPF_FIELD_SIZEOF(struct sk_buff, sk),
+				      si->dst_reg, si->src_reg,
+				      offsetof(struct sk_buff, sk));
+		*insn++ = BPF_LDX_MEM(BPF_W, si->dst_reg, si->dst_reg,
+				      offsetof(struct sock_common,
+					       skc_v6_rcv_saddr.s6_addr32[0]) +
+				      off);
+#else
+		*insn++ = BPF_MOV32_IMM(si->dst_reg, 0);
+#endif
+		break;
+
+	case offsetof(struct __sk_buff, remote_port):
+		BUILD_BUG_ON(FIELD_SIZEOF(struct sock_common, skc_dport) != 2);
+
+		*insn++ = BPF_LDX_MEM(BPF_FIELD_SIZEOF(struct sk_buff, sk),
+				      si->dst_reg, si->src_reg,
+				      offsetof(struct sk_buff, sk));
+		*insn++ = BPF_LDX_MEM(BPF_H, si->dst_reg, si->dst_reg,
+				      bpf_target_off(struct sock_common,
+						     skc_dport,
+						     2, target_size));
+#ifndef __BIG_ENDIAN_BITFIELD
+		*insn++ = BPF_ALU32_IMM(BPF_LSH, si->dst_reg, 16);
+#endif
+		break;
+
+	case offsetof(struct __sk_buff, local_port):
+		BUILD_BUG_ON(FIELD_SIZEOF(struct sock_common, skc_num) != 2);
+
+		*insn++ = BPF_LDX_MEM(BPF_FIELD_SIZEOF(struct sk_buff, sk),
+				      si->dst_reg, si->src_reg,
+				      offsetof(struct sk_buff, sk));
+		*insn++ = BPF_LDX_MEM(BPF_H, si->dst_reg, si->dst_reg,
+				      bpf_target_off(struct sock_common,
+						     skc_num, 2, target_size));
+		break;
 	}
 
 	return insn - insn_buf;
@@ -4069,6 +4237,7 @@ static u32 sock_ops_convert_ctx_access(enum bpf_access_type type,
 	.get_func_proto		= sk_skb_func_proto,
 	.is_valid_access	= sk_skb_is_valid_access,
 	.convert_ctx_access	= bpf_convert_ctx_access,
+	.gen_prologue		= sk_skb_prologue,
 };
 
 int sk_detach_filter(struct sock *sk)

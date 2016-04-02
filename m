From: Brenden Blanco <bblanco@plumgrid.com>
Subject: [RFC PATCH 1/5] bpf: add PHYS_DEV prog type for early driver filter
Date: Fri,  1 Apr 2016 18:21:54 -0700
Message-ID: <1459560118-5582-2-git-send-email-bblanco@plumgrid.com>
References: <1459560118-5582-1-git-send-email-bblanco@plumgrid.com>
Cc: Brenden Blanco <bblanco@plumgrid.com>, netdev@vger.kernel.org,
	tom@herbertland.com, alexei.starovoitov@gmail.com,
	gerlitz@mellanox.com, daniel@iogearbox.net,
	john.fastabend@gmail.com, brouer@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:36408 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757042AbcDBBWN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 21:22:13 -0400
Received: by mail-pf0-f182.google.com with SMTP id e128so81002490pfe.3
        for <netdev@vger.kernel.org>; Fri, 01 Apr 2016 18:22:12 -0700 (PDT)
In-Reply-To: <1459560118-5582-1-git-send-email-bblanco@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a new bpf prog type that is intended to run in early stages of the
packet rx path. Only minimal packet metadata will be available, hence a new
context type, struct xdp_metadata, is exposed to userspace. So far only
expose the readable packet length, and only in read mode.

The PHYS_DEV name is chosen to represent that the program is meant only
for physical adapters, rather than all netdevs.

While the user visible struct is new, the underlying context must be
implemented as a minimal skb in order for the packet load_* instructions
to work. The skb filled in by the driver must have skb->len, skb->head,
and skb->data set, and skb->data_len == 0.

Signed-off-by: Brenden Blanco <bblanco@plumgrid.com>
---
 include/uapi/linux/bpf.h |  5 ++++
 kernel/bpf/verifier.c    |  1 +
 net/core/filter.c        | 68 ++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 74 insertions(+)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 924f537..b8a4ef2 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -92,6 +92,7 @@ enum bpf_prog_type {
 	BPF_PROG_TYPE_KPROBE,
 	BPF_PROG_TYPE_SCHED_CLS,
 	BPF_PROG_TYPE_SCHED_ACT,
+	BPF_PROG_TYPE_PHYS_DEV,
 };
 
 #define BPF_PSEUDO_MAP_FD	1
@@ -367,6 +368,10 @@ struct __sk_buff {
 	__u32 tc_classid;
 };
 
+struct xdp_metadata {
+	__u32 len;
+};
+
 struct bpf_tunnel_key {
 	__u32 tunnel_id;
 	union {
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 2e08f8e..804ca70 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -1340,6 +1340,7 @@ static bool may_access_skb(enum bpf_prog_type type)
 	case BPF_PROG_TYPE_SOCKET_FILTER:
 	case BPF_PROG_TYPE_SCHED_CLS:
 	case BPF_PROG_TYPE_SCHED_ACT:
+	case BPF_PROG_TYPE_PHYS_DEV:
 		return true;
 	default:
 		return false;
diff --git a/net/core/filter.c b/net/core/filter.c
index b7177d0..c417db6 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2018,6 +2018,12 @@ tc_cls_act_func_proto(enum bpf_func_id func_id)
 	}
 }
 
+static const struct bpf_func_proto *
+phys_dev_func_proto(enum bpf_func_id func_id)
+{
+	return sk_filter_func_proto(func_id);
+}
+
 static bool __is_valid_access(int off, int size, enum bpf_access_type type)
 {
 	/* check bounds */
@@ -2073,6 +2079,36 @@ static bool tc_cls_act_is_valid_access(int off, int size,
 	return __is_valid_access(off, size, type);
 }
 
+static bool __is_valid_xdp_access(int off, int size,
+				  enum bpf_access_type type)
+{
+	if (off < 0 || off >= sizeof(struct xdp_metadata))
+		return false;
+
+	if (off % size != 0)
+		return false;
+
+	if (size != 4)
+		return false;
+
+	return true;
+}
+
+static bool phys_dev_is_valid_access(int off, int size,
+				     enum bpf_access_type type)
+{
+	if (type == BPF_WRITE)
+		return false;
+
+	switch (off) {
+	case offsetof(struct xdp_metadata, len):
+		break;
+	default:
+		return false;
+	}
+	return __is_valid_xdp_access(off, size, type);
+}
+
 static u32 bpf_net_convert_ctx_access(enum bpf_access_type type, int dst_reg,
 				      int src_reg, int ctx_off,
 				      struct bpf_insn *insn_buf,
@@ -2210,6 +2246,26 @@ static u32 bpf_net_convert_ctx_access(enum bpf_access_type type, int dst_reg,
 	return insn - insn_buf;
 }
 
+static u32 bpf_phys_dev_convert_ctx_access(enum bpf_access_type type,
+					   int dst_reg, int src_reg,
+					   int ctx_off,
+					   struct bpf_insn *insn_buf,
+					   struct bpf_prog *prog)
+{
+	struct bpf_insn *insn = insn_buf;
+
+	switch (ctx_off) {
+	case offsetof(struct xdp_metadata, len):
+		BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, len) != 4);
+
+		*insn++ = BPF_LDX_MEM(BPF_W, dst_reg, src_reg,
+				      offsetof(struct sk_buff, len));
+		break;
+	}
+
+	return insn - insn_buf;
+}
+
 static const struct bpf_verifier_ops sk_filter_ops = {
 	.get_func_proto = sk_filter_func_proto,
 	.is_valid_access = sk_filter_is_valid_access,
@@ -2222,6 +2278,12 @@ static const struct bpf_verifier_ops tc_cls_act_ops = {
 	.convert_ctx_access = bpf_net_convert_ctx_access,
 };
 
+static const struct bpf_verifier_ops phys_dev_ops = {
+	.get_func_proto = phys_dev_func_proto,
+	.is_valid_access = phys_dev_is_valid_access,
+	.convert_ctx_access = bpf_phys_dev_convert_ctx_access,
+};
+
 static struct bpf_prog_type_list sk_filter_type __read_mostly = {
 	.ops = &sk_filter_ops,
 	.type = BPF_PROG_TYPE_SOCKET_FILTER,
@@ -2237,11 +2299,17 @@ static struct bpf_prog_type_list sched_act_type __read_mostly = {
 	.type = BPF_PROG_TYPE_SCHED_ACT,
 };
 
+static struct bpf_prog_type_list phys_dev_type __read_mostly = {
+	.ops = &phys_dev_ops,
+	.type = BPF_PROG_TYPE_PHYS_DEV,
+};
+
 static int __init register_sk_filter_ops(void)
 {
 	bpf_register_prog_type(&sk_filter_type);
 	bpf_register_prog_type(&sched_cls_type);
 	bpf_register_prog_type(&sched_act_type);
+	bpf_register_prog_type(&phys_dev_type);
 
 	return 0;
 }
-- 
2.8.0

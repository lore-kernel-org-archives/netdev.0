From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v2 net-next 2/2] bpf: allow programs to write to certain skb fields
Date: Thu,  4 Jun 2015 10:11:54 -0700
Message-ID: <1433437914-15808-2-git-send-email-ast@plumgrid.com>
References: <1433437914-15808-1-git-send-email-ast@plumgrid.com>
Cc: Eric Dumazet <edumazet@google.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f46.google.com ([209.85.192.46]:34930 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932154AbbFDRMD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 13:12:03 -0400
Received: by qgh73 with SMTP id 73so5567045qgh.2
        for <netdev@vger.kernel.org>; Thu, 04 Jun 2015 10:12:02 -0700 (PDT)
In-Reply-To: <1433437914-15808-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

allow programs read/write skb->mark, tc_index fields and
((struct qdisc_skb_cb *)cb)->data.

mark and tc_index are generically useful in TC.
cb[0]-cb[4] are primarily used to pass arguments from one
program to another called via bpf_tail_call() which can
be seen in sockex3_kern.c example.

All fields of 'struct __sk_buff' are readable to socket and tc_cls_act progs.
mark, tc_index are writeable from tc_cls_act only.
cb[0]-cb[4] are writeable by both sockets and tc_cls_act.

Add verifier tests and improve sample code.

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
v1->v2: no changes

This patch is independent from previous push/pull l2 patch, but
they both modify net/core/filter.c, so sent together.

 include/linux/bpf.h         |    3 +-
 include/uapi/linux/bpf.h    |    2 +
 kernel/bpf/verifier.c       |   37 ++++++++++++-----
 net/core/filter.c           |   94 +++++++++++++++++++++++++++++++++++++------
 samples/bpf/sockex3_kern.c  |   35 +++++-----------
 samples/bpf/test_verifier.c |   84 +++++++++++++++++++++++++++++++++++++-
 6 files changed, 207 insertions(+), 48 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index ca854e5bb2f7..2235aee8096a 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -105,7 +105,8 @@ struct bpf_verifier_ops {
 	 */
 	bool (*is_valid_access)(int off, int size, enum bpf_access_type type);
 
-	u32 (*convert_ctx_access)(int dst_reg, int src_reg, int ctx_off,
+	u32 (*convert_ctx_access)(enum bpf_access_type type, int dst_reg,
+				  int src_reg, int ctx_off,
 				  struct bpf_insn *insn);
 };
 
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 42aa19abab86..602f05b7a275 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -248,6 +248,8 @@ struct __sk_buff {
 	__u32 priority;
 	__u32 ingress_ifindex;
 	__u32 ifindex;
+	__u32 tc_index;
+	__u32 cb[5];
 };
 
 #endif /* _UAPI__LINUX_BPF_H__ */
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index cfd9a40b9a5a..039d866fd36a 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -1692,6 +1692,8 @@ static int do_check(struct verifier_env *env)
 			}
 
 		} else if (class == BPF_STX) {
+			enum bpf_reg_type dst_reg_type;
+
 			if (BPF_MODE(insn->code) == BPF_XADD) {
 				err = check_xadd(env, insn);
 				if (err)
@@ -1700,11 +1702,6 @@ static int do_check(struct verifier_env *env)
 				continue;
 			}
 
-			if (BPF_MODE(insn->code) != BPF_MEM ||
-			    insn->imm != 0) {
-				verbose("BPF_STX uses reserved fields\n");
-				return -EINVAL;
-			}
 			/* check src1 operand */
 			err = check_reg_arg(regs, insn->src_reg, SRC_OP);
 			if (err)
@@ -1714,6 +1711,8 @@ static int do_check(struct verifier_env *env)
 			if (err)
 				return err;
 
+			dst_reg_type = regs[insn->dst_reg].type;
+
 			/* check that memory (dst_reg + off) is writeable */
 			err = check_mem_access(env, insn->dst_reg, insn->off,
 					       BPF_SIZE(insn->code), BPF_WRITE,
@@ -1721,6 +1720,15 @@ static int do_check(struct verifier_env *env)
 			if (err)
 				return err;
 
+			if (insn->imm == 0) {
+				insn->imm = dst_reg_type;
+			} else if (dst_reg_type != insn->imm &&
+				   (dst_reg_type == PTR_TO_CTX ||
+				    insn->imm == PTR_TO_CTX)) {
+				verbose("same insn cannot be used with different pointers\n");
+				return -EINVAL;
+			}
+
 		} else if (class == BPF_ST) {
 			if (BPF_MODE(insn->code) != BPF_MEM ||
 			    insn->src_reg != BPF_REG_0) {
@@ -1839,12 +1847,18 @@ static int replace_map_fd_with_map_ptr(struct verifier_env *env)
 
 	for (i = 0; i < insn_cnt; i++, insn++) {
 		if (BPF_CLASS(insn->code) == BPF_LDX &&
-		    (BPF_MODE(insn->code) != BPF_MEM ||
-		     insn->imm != 0)) {
+		    (BPF_MODE(insn->code) != BPF_MEM || insn->imm != 0)) {
 			verbose("BPF_LDX uses reserved fields\n");
 			return -EINVAL;
 		}
 
+		if (BPF_CLASS(insn->code) == BPF_STX &&
+		    ((BPF_MODE(insn->code) != BPF_MEM &&
+		      BPF_MODE(insn->code) != BPF_XADD) || insn->imm != 0)) {
+			verbose("BPF_STX uses reserved fields\n");
+			return -EINVAL;
+		}
+
 		if (insn[0].code == (BPF_LD | BPF_IMM | BPF_DW)) {
 			struct bpf_map *map;
 			struct fd f;
@@ -1967,12 +1981,17 @@ static int convert_ctx_accesses(struct verifier_env *env)
 	struct bpf_prog *new_prog;
 	u32 cnt;
 	int i;
+	enum bpf_access_type type;
 
 	if (!env->prog->aux->ops->convert_ctx_access)
 		return 0;
 
 	for (i = 0; i < insn_cnt; i++, insn++) {
-		if (insn->code != (BPF_LDX | BPF_MEM | BPF_W))
+		if (insn->code == (BPF_LDX | BPF_MEM | BPF_W))
+			type = BPF_READ;
+		else if (insn->code == (BPF_STX | BPF_MEM | BPF_W))
+			type = BPF_WRITE;
+		else
 			continue;
 
 		if (insn->imm != PTR_TO_CTX) {
@@ -1982,7 +2001,7 @@ static int convert_ctx_accesses(struct verifier_env *env)
 		}
 
 		cnt = env->prog->aux->ops->
-			convert_ctx_access(insn->dst_reg, insn->src_reg,
+			convert_ctx_access(type, insn->dst_reg, insn->src_reg,
 					   insn->off, insn_buf);
 		if (cnt == 0 || cnt >= ARRAY_SIZE(insn_buf)) {
 			verbose("bpf verifier is misconfigured\n");
diff --git a/net/core/filter.c b/net/core/filter.c
index 36a69e33d76b..d271c06bf01f 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -46,6 +46,7 @@
 #include <linux/seccomp.h>
 #include <linux/if_vlan.h>
 #include <linux/bpf.h>
+#include <net/sch_generic.h>
 
 /**
  *	sk_filter - run a packet through a socket filter
@@ -1463,13 +1464,8 @@ tc_cls_act_func_proto(enum bpf_func_id func_id)
 	}
 }
 
-static bool sk_filter_is_valid_access(int off, int size,
-				      enum bpf_access_type type)
+static bool __is_valid_access(int off, int size, enum bpf_access_type type)
 {
-	/* only read is allowed */
-	if (type != BPF_READ)
-		return false;
-
 	/* check bounds */
 	if (off < 0 || off >= sizeof(struct __sk_buff))
 		return false;
@@ -1485,8 +1481,42 @@ static bool sk_filter_is_valid_access(int off, int size,
 	return true;
 }
 
-static u32 sk_filter_convert_ctx_access(int dst_reg, int src_reg, int ctx_off,
-					struct bpf_insn *insn_buf)
+static bool sk_filter_is_valid_access(int off, int size,
+				      enum bpf_access_type type)
+{
+	if (type == BPF_WRITE) {
+		switch (off) {
+		case offsetof(struct __sk_buff, cb[0]) ...
+			offsetof(struct __sk_buff, cb[4]):
+			break;
+		default:
+			return false;
+		}
+	}
+
+	return __is_valid_access(off, size, type);
+}
+
+static bool tc_cls_act_is_valid_access(int off, int size,
+				       enum bpf_access_type type)
+{
+	if (type == BPF_WRITE) {
+		switch (off) {
+		case offsetof(struct __sk_buff, mark):
+		case offsetof(struct __sk_buff, tc_index):
+		case offsetof(struct __sk_buff, cb[0]) ...
+			offsetof(struct __sk_buff, cb[4]):
+			break;
+		default:
+			return false;
+		}
+	}
+	return __is_valid_access(off, size, type);
+}
+
+static u32 bpf_net_convert_ctx_access(enum bpf_access_type type, int dst_reg,
+				      int src_reg, int ctx_off,
+				      struct bpf_insn *insn_buf)
 {
 	struct bpf_insn *insn = insn_buf;
 
@@ -1538,7 +1568,15 @@ static u32 sk_filter_convert_ctx_access(int dst_reg, int src_reg, int ctx_off,
 		break;
 
 	case offsetof(struct __sk_buff, mark):
-		return convert_skb_access(SKF_AD_MARK, dst_reg, src_reg, insn);
+		BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, mark) != 4);
+
+		if (type == BPF_WRITE)
+			*insn++ = BPF_STX_MEM(BPF_W, dst_reg, src_reg,
+					      offsetof(struct sk_buff, mark));
+		else
+			*insn++ = BPF_LDX_MEM(BPF_W, dst_reg, src_reg,
+					      offsetof(struct sk_buff, mark));
+		break;
 
 	case offsetof(struct __sk_buff, pkt_type):
 		return convert_skb_access(SKF_AD_PKTTYPE, dst_reg, src_reg, insn);
@@ -1553,6 +1591,38 @@ static u32 sk_filter_convert_ctx_access(int dst_reg, int src_reg, int ctx_off,
 	case offsetof(struct __sk_buff, vlan_tci):
 		return convert_skb_access(SKF_AD_VLAN_TAG,
 					  dst_reg, src_reg, insn);
+
+	case offsetof(struct __sk_buff, cb[0]) ...
+		offsetof(struct __sk_buff, cb[4]):
+		BUILD_BUG_ON(FIELD_SIZEOF(struct qdisc_skb_cb, data) < 20);
+
+		ctx_off -= offsetof(struct __sk_buff, cb[0]);
+		ctx_off += offsetof(struct sk_buff, cb);
+		ctx_off += offsetof(struct qdisc_skb_cb, data);
+		if (type == BPF_WRITE)
+			*insn++ = BPF_STX_MEM(BPF_W, dst_reg, src_reg, ctx_off);
+		else
+			*insn++ = BPF_LDX_MEM(BPF_W, dst_reg, src_reg, ctx_off);
+		break;
+
+	case offsetof(struct __sk_buff, tc_index):
+#ifdef CONFIG_NET_SCHED
+		BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, tc_index) != 2);
+
+		if (type == BPF_WRITE)
+			*insn++ = BPF_STX_MEM(BPF_H, dst_reg, src_reg,
+					      offsetof(struct sk_buff, tc_index));
+		else
+			*insn++ = BPF_LDX_MEM(BPF_H, dst_reg, src_reg,
+					      offsetof(struct sk_buff, tc_index));
+		break;
+#else
+		if (type == BPF_WRITE)
+			*insn++ = BPF_MOV64_REG(dst_reg, dst_reg);
+		else
+			*insn++ = BPF_MOV64_IMM(dst_reg, 0);
+		break;
+#endif
 	}
 
 	return insn - insn_buf;
@@ -1561,13 +1631,13 @@ static u32 sk_filter_convert_ctx_access(int dst_reg, int src_reg, int ctx_off,
 static const struct bpf_verifier_ops sk_filter_ops = {
 	.get_func_proto = sk_filter_func_proto,
 	.is_valid_access = sk_filter_is_valid_access,
-	.convert_ctx_access = sk_filter_convert_ctx_access,
+	.convert_ctx_access = bpf_net_convert_ctx_access,
 };
 
 static const struct bpf_verifier_ops tc_cls_act_ops = {
 	.get_func_proto = tc_cls_act_func_proto,
-	.is_valid_access = sk_filter_is_valid_access,
-	.convert_ctx_access = sk_filter_convert_ctx_access,
+	.is_valid_access = tc_cls_act_is_valid_access,
+	.convert_ctx_access = bpf_net_convert_ctx_access,
 };
 
 static struct bpf_prog_type_list sk_filter_type __read_mostly = {
diff --git a/samples/bpf/sockex3_kern.c b/samples/bpf/sockex3_kern.c
index 2625b987944f..41ae2fd21b13 100644
--- a/samples/bpf/sockex3_kern.c
+++ b/samples/bpf/sockex3_kern.c
@@ -89,7 +89,6 @@ static inline __u32 ipv6_addr_hash(struct __sk_buff *ctx, __u64 off)
 
 struct globals {
 	struct flow_keys flow;
-	__u32 nhoff;
 };
 
 struct bpf_map_def SEC("maps") percpu_map = {
@@ -139,7 +138,7 @@ static void update_stats(struct __sk_buff *skb, struct globals *g)
 static __always_inline void parse_ip_proto(struct __sk_buff *skb,
 					   struct globals *g, __u32 ip_proto)
 {
-	__u32 nhoff = g->nhoff;
+	__u32 nhoff = skb->cb[0];
 	int poff;
 
 	switch (ip_proto) {
@@ -165,7 +164,7 @@ static __always_inline void parse_ip_proto(struct __sk_buff *skb,
 		if (gre_flags & GRE_SEQ)
 			nhoff += 4;
 
-		g->nhoff = nhoff;
+		skb->cb[0] = nhoff;
 		parse_eth_proto(skb, gre_proto);
 		break;
 	}
@@ -195,7 +194,7 @@ PROG(PARSE_IP)(struct __sk_buff *skb)
 	if (!g)
 		return 0;
 
-	nhoff = g->nhoff;
+	nhoff = skb->cb[0];
 
 	if (unlikely(ip_is_fragment(skb, nhoff)))
 		return 0;
@@ -210,7 +209,7 @@ PROG(PARSE_IP)(struct __sk_buff *skb)
 	verlen = load_byte(skb, nhoff + 0/*offsetof(struct iphdr, ihl)*/);
 	nhoff += (verlen & 0xF) << 2;
 
-	g->nhoff = nhoff;
+	skb->cb[0] = nhoff;
 	parse_ip_proto(skb, g, ip_proto);
 	return 0;
 }
@@ -223,7 +222,7 @@ PROG(PARSE_IPV6)(struct __sk_buff *skb)
 	if (!g)
 		return 0;
 
-	nhoff = g->nhoff;
+	nhoff = skb->cb[0];
 
 	ip_proto = load_byte(skb,
 			     nhoff + offsetof(struct ipv6hdr, nexthdr));
@@ -233,25 +232,21 @@ PROG(PARSE_IPV6)(struct __sk_buff *skb)
 				     nhoff + offsetof(struct ipv6hdr, daddr));
 	nhoff += sizeof(struct ipv6hdr);
 
-	g->nhoff = nhoff;
+	skb->cb[0] = nhoff;
 	parse_ip_proto(skb, g, ip_proto);
 	return 0;
 }
 
 PROG(PARSE_VLAN)(struct __sk_buff *skb)
 {
-	struct globals *g = this_cpu_globals();
 	__u32 nhoff, proto;
 
-	if (!g)
-		return 0;
-
-	nhoff = g->nhoff;
+	nhoff = skb->cb[0];
 
 	proto = load_half(skb, nhoff + offsetof(struct vlan_hdr,
 						h_vlan_encapsulated_proto));
 	nhoff += sizeof(struct vlan_hdr);
-	g->nhoff = nhoff;
+	skb->cb[0] = nhoff;
 
 	parse_eth_proto(skb, proto);
 
@@ -260,17 +255,13 @@ PROG(PARSE_VLAN)(struct __sk_buff *skb)
 
 PROG(PARSE_MPLS)(struct __sk_buff *skb)
 {
-	struct globals *g = this_cpu_globals();
 	__u32 nhoff, label;
 
-	if (!g)
-		return 0;
-
-	nhoff = g->nhoff;
+	nhoff = skb->cb[0];
 
 	label = load_word(skb, nhoff);
 	nhoff += sizeof(struct mpls_label);
-	g->nhoff = nhoff;
+	skb->cb[0] = nhoff;
 
 	if (label & MPLS_LS_S_MASK) {
 		__u8 verlen = load_byte(skb, nhoff);
@@ -288,14 +279,10 @@ PROG(PARSE_MPLS)(struct __sk_buff *skb)
 SEC("socket/0")
 int main_prog(struct __sk_buff *skb)
 {
-	struct globals *g = this_cpu_globals();
 	__u32 nhoff = ETH_HLEN;
 	__u32 proto = load_half(skb, 12);
 
-	if (!g)
-		return 0;
-
-	g->nhoff = nhoff;
+	skb->cb[0] = nhoff;
 	parse_eth_proto(skb, proto);
 	return 0;
 }
diff --git a/samples/bpf/test_verifier.c b/samples/bpf/test_verifier.c
index 12f3780af73f..693605997abc 100644
--- a/samples/bpf/test_verifier.c
+++ b/samples/bpf/test_verifier.c
@@ -29,6 +29,7 @@ struct bpf_test {
 		ACCEPT,
 		REJECT
 	} result;
+	enum bpf_prog_type prog_type;
 };
 
 static struct bpf_test tests[] = {
@@ -743,6 +744,84 @@ static struct bpf_test tests[] = {
 		.errstr = "different pointers",
 		.result = REJECT,
 	},
+	{
+		"check skb->mark is not writeable by sockets",
+		.insns = {
+			BPF_STX_MEM(BPF_W, BPF_REG_1, BPF_REG_1,
+				    offsetof(struct __sk_buff, mark)),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid bpf_context access",
+		.result = REJECT,
+	},
+	{
+		"check skb->tc_index is not writeable by sockets",
+		.insns = {
+			BPF_STX_MEM(BPF_W, BPF_REG_1, BPF_REG_1,
+				    offsetof(struct __sk_buff, tc_index)),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid bpf_context access",
+		.result = REJECT,
+	},
+	{
+		"check non-u32 access to cb",
+		.insns = {
+			BPF_STX_MEM(BPF_H, BPF_REG_1, BPF_REG_1,
+				    offsetof(struct __sk_buff, cb[0])),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid bpf_context access",
+		.result = REJECT,
+	},
+	{
+		"check out of range skb->cb access",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, cb[60])),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid bpf_context access",
+		.result = REJECT,
+		.prog_type = BPF_PROG_TYPE_SCHED_ACT,
+	},
+	{
+		"write skb fields from socket prog",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, cb[4])),
+			BPF_JMP_IMM(BPF_JGE, BPF_REG_0, 0, 1),
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, mark)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, tc_index)),
+			BPF_JMP_IMM(BPF_JGE, BPF_REG_0, 0, 1),
+			BPF_STX_MEM(BPF_W, BPF_REG_1, BPF_REG_1,
+				    offsetof(struct __sk_buff, cb[0])),
+			BPF_STX_MEM(BPF_W, BPF_REG_1, BPF_REG_1,
+				    offsetof(struct __sk_buff, cb[2])),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+	},
+	{
+		"write skb fields from tc_cls_act prog",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, cb[0])),
+			BPF_STX_MEM(BPF_W, BPF_REG_1, BPF_REG_0,
+				    offsetof(struct __sk_buff, mark)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, tc_index)),
+			BPF_STX_MEM(BPF_W, BPF_REG_1, BPF_REG_0,
+				    offsetof(struct __sk_buff, tc_index)),
+			BPF_STX_MEM(BPF_W, BPF_REG_1, BPF_REG_0,
+				    offsetof(struct __sk_buff, cb[3])),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
 };
 
 static int probe_filter_length(struct bpf_insn *fp)
@@ -775,6 +854,7 @@ static int test(void)
 
 	for (i = 0; i < ARRAY_SIZE(tests); i++) {
 		struct bpf_insn *prog = tests[i].insns;
+		int prog_type = tests[i].prog_type;
 		int prog_len = probe_filter_length(prog);
 		int *fixup = tests[i].fixup;
 		int map_fd = -1;
@@ -789,8 +869,8 @@ static int test(void)
 		}
 		printf("#%d %s ", i, tests[i].descr);
 
-		prog_fd = bpf_prog_load(BPF_PROG_TYPE_SOCKET_FILTER, prog,
-					prog_len * sizeof(struct bpf_insn),
+		prog_fd = bpf_prog_load(prog_type ?: BPF_PROG_TYPE_SOCKET_FILTER,
+					prog, prog_len * sizeof(struct bpf_insn),
 					"GPL", 0);
 
 		if (tests[i].result == ACCEPT) {
-- 
1.7.9.5

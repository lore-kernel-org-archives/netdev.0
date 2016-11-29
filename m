From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next v3 3/4] bpf: BPF for lightweight tunnel infrastructure
Date: Tue, 29 Nov 2016 14:21:22 +0100
Message-ID: <7cc79a82e49996a9ebbff861af471018fdf118fb.1480424542.git.tgraf@suug.ch>
References: <cover.1480424542.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net, tom@herbertland.com,
        roopa@cumulusnetworks.com, hannes@stressinduktion.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:38918 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757457AbcK2NVg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 08:21:36 -0500
In-Reply-To: <cover.1480424542.git.tgraf@suug.ch>
In-Reply-To: <cover.1480424542.git.tgraf@suug.ch>
References: <cover.1480424542.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Registers new BPF program types which correspond to the LWT hooks:
  - BPF_PROG_TYPE_LWT_IN   => dst_input()
  - BPF_PROG_TYPE_LWT_OUT  => dst_output()
  - BPF_PROG_TYPE_LWT_XMIT => lwtunnel_xmit()

The separate program types are required to differentiate between the
capabilities each LWT hook allows:

 * Programs attached to dst_input() or dst_output() are restricted and
   may only read the data of an skb. This prevent modification and
   possible invalidation of already validated packet headers on receive
   and the construction of illegal headers while the IP headers are
   still being assembled.

 * Programs attached to lwtunnel_xmit() are allowed to modify packet
   content as well as prepending an L2 header via a newly introduced
   helper bpf_skb_push(). This is safe as lwtunnel_xmit() is invoked
   after the IP header has been assembled completely.

All BPF programs receive an skb with L3 headers attached and may return
one of the following error codes:

 BPF_OK - Continue routing as per nexthop
 BPF_DROP - Drop skb and return EPERM
 BPF_REDIRECT - Redirect skb to device as per redirect() helper.
                (Only valid in lwtunnel_xmit() context)

The return codes are binary compatible with their TC_ACT_
relatives to ease compatibility.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 include/linux/filter.h        |   2 +-
 include/uapi/linux/bpf.h      |  32 +++-
 include/uapi/linux/lwtunnel.h |  23 +++
 kernel/bpf/verifier.c         |  14 +-
 net/Kconfig                   |   8 +
 net/core/Makefile             |   1 +
 net/core/filter.c             | 148 +++++++++++++++-
 net/core/lwt_bpf.c            | 397 ++++++++++++++++++++++++++++++++++++++++++
 net/core/lwtunnel.c           |   2 +
 9 files changed, 621 insertions(+), 6 deletions(-)
 create mode 100644 net/core/lwt_bpf.c

diff --git a/include/linux/filter.h b/include/linux/filter.h
index 7f246a2..7ba6446 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -438,7 +438,7 @@ struct xdp_buff {
 };
 
 /* compute the linear packet data range [data, data_end) which
- * will be accessed by cls_bpf and act_bpf programs
+ * will be accessed by cls_bpf, act_bpf and lwt programs
  */
 static inline void bpf_compute_data_end(struct sk_buff *skb)
 {
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 1370a9d..81c02c5 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -101,6 +101,9 @@ enum bpf_prog_type {
 	BPF_PROG_TYPE_XDP,
 	BPF_PROG_TYPE_PERF_EVENT,
 	BPF_PROG_TYPE_CGROUP_SKB,
+	BPF_PROG_TYPE_LWT_IN,
+	BPF_PROG_TYPE_LWT_OUT,
+	BPF_PROG_TYPE_LWT_XMIT,
 };
 
 enum bpf_attach_type {
@@ -409,6 +412,16 @@ union bpf_attr {
  *
  * int bpf_get_numa_node_id()
  *     Return: Id of current NUMA node.
+ *
+ * int bpf_skb_push()
+ *     Add room to beginning of skb and adjusts MAC header offset accordingly.
+ *     Extends/reallocaes for needed skb headeroom automatically.
+ *     May change skb data pointer and will thus invalidate any check done
+ *     for direct packet access.
+ *     @skb: pointer to skb
+ *     @len: length of header to be pushed in front
+ *     @flags: Flags (unused for now)
+ *     Return: 0 on success or negative error
  */
 #define __BPF_FUNC_MAPPER(FN)		\
 	FN(unspec),			\
@@ -453,7 +466,8 @@ union bpf_attr {
 	FN(skb_pull_data),		\
 	FN(csum_update),		\
 	FN(set_hash_invalid),		\
-	FN(get_numa_node_id),
+	FN(get_numa_node_id),		\
+	FN(skb_push),
 
 /* integer value in 'imm' field of BPF_CALL instruction selects which helper
  * function eBPF program intends to call
@@ -537,6 +551,22 @@ struct bpf_tunnel_key {
 	__u32 tunnel_label;
 };
 
+/* Generic BPF return codes which all BPF program types may support.
+ * The values are binary compatible with their TC_ACT_* counter-part to
+ * provide backwards compatibility with existing SCHED_CLS and SCHED_ACT
+ * programs.
+ *
+ * XDP is handled seprately, see XDP_*.
+ */
+enum bpf_ret_code {
+	BPF_OK = 0,
+	/* 1 reserved */
+	BPF_DROP = 2,
+	/* 3-6 reserved */
+	BPF_REDIRECT = 7,
+	/* >127 are reserved for prog type specific return codes */
+};
+
 /* User return codes for XDP prog type.
  * A valid XDP program must return one of these defined values. All other
  * return codes are reserved for future use. Unknown return codes will result
diff --git a/include/uapi/linux/lwtunnel.h b/include/uapi/linux/lwtunnel.h
index 453cc62..937f660 100644
--- a/include/uapi/linux/lwtunnel.h
+++ b/include/uapi/linux/lwtunnel.h
@@ -10,6 +10,7 @@ enum lwtunnel_encap_types {
 	LWTUNNEL_ENCAP_ILA,
 	LWTUNNEL_ENCAP_IP6,
 	LWTUNNEL_ENCAP_SEG6,
+	LWTUNNEL_ENCAP_BPF,
 	__LWTUNNEL_ENCAP_MAX,
 };
 
@@ -43,4 +44,26 @@ enum lwtunnel_ip6_t {
 
 #define LWTUNNEL_IP6_MAX (__LWTUNNEL_IP6_MAX - 1)
 
+enum {
+	LWT_BPF_PROG_UNSPEC,
+	LWT_BPF_PROG_FD,
+	LWT_BPF_PROG_NAME,
+	__LWT_BPF_PROG_MAX,
+};
+
+#define LWT_BPF_PROG_MAX (__LWT_BPF_PROG_MAX - 1)
+
+enum {
+	LWT_BPF_UNSPEC,
+	LWT_BPF_IN,
+	LWT_BPF_OUT,
+	LWT_BPF_XMIT,
+	LWT_BPF_XMIT_HEADROOM,
+	__LWT_BPF_MAX,
+};
+
+#define LWT_BPF_MAX (__LWT_BPF_MAX - 1)
+
+#define LWT_BPF_MAX_HEADROOM 128
+
 #endif /* _UAPI_LWTUNNEL_H_ */
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 8740c5f..8135cb1 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -633,12 +633,19 @@ static int check_map_access(struct bpf_verifier_env *env, u32 regno, int off,
 #define MAX_PACKET_OFF 0xffff
 
 static bool may_access_direct_pkt_data(struct bpf_verifier_env *env,
-				       const struct bpf_call_arg_meta *meta)
+				       const struct bpf_call_arg_meta *meta,
+				       enum bpf_access_type t)
 {
 	switch (env->prog->type) {
+	case BPF_PROG_TYPE_LWT_IN:
+	case BPF_PROG_TYPE_LWT_OUT:
+		/* dst_input() and dst_output() can't write for now */
+		if (t == BPF_WRITE)
+			return false;
 	case BPF_PROG_TYPE_SCHED_CLS:
 	case BPF_PROG_TYPE_SCHED_ACT:
 	case BPF_PROG_TYPE_XDP:
+	case BPF_PROG_TYPE_LWT_XMIT:
 		if (meta)
 			return meta->pkt_access;
 
@@ -837,7 +844,7 @@ static int check_mem_access(struct bpf_verifier_env *env, u32 regno, int off,
 			err = check_stack_read(state, off, size, value_regno);
 		}
 	} else if (state->regs[regno].type == PTR_TO_PACKET) {
-		if (t == BPF_WRITE && !may_access_direct_pkt_data(env, NULL)) {
+		if (t == BPF_WRITE && !may_access_direct_pkt_data(env, NULL, t)) {
 			verbose("cannot write into packet\n");
 			return -EACCES;
 		}
@@ -970,7 +977,8 @@ static int check_func_arg(struct bpf_verifier_env *env, u32 regno,
 		return 0;
 	}
 
-	if (type == PTR_TO_PACKET && !may_access_direct_pkt_data(env, meta)) {
+	if (type == PTR_TO_PACKET &&
+	    !may_access_direct_pkt_data(env, meta, BPF_READ)) {
 		verbose("helper access to the packet is not allowed\n");
 		return -EACCES;
 	}
diff --git a/net/Kconfig b/net/Kconfig
index 7b6cd34..a100500 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -402,6 +402,14 @@ config LWTUNNEL
 	  weight tunnel endpoint. Tunnel encapsulation parameters are stored
 	  with light weight tunnel state associated with fib routes.
 
+config LWTUNNEL_BPF
+	bool "Execute BPF program as route nexthop action"
+	depends on LWTUNNEL
+	default y if LWTUNNEL=y
+	---help---
+	  Allows to run BPF programs as a nexthop action following a route
+	  lookup for incoming and outgoing packets.
+
 config DST_CACHE
 	bool
 	default n
diff --git a/net/core/Makefile b/net/core/Makefile
index d6508c2..f6761b6 100644
--- a/net/core/Makefile
+++ b/net/core/Makefile
@@ -24,6 +24,7 @@ obj-$(CONFIG_NET_PTP_CLASSIFY) += ptp_classifier.o
 obj-$(CONFIG_CGROUP_NET_PRIO) += netprio_cgroup.o
 obj-$(CONFIG_CGROUP_NET_CLASSID) += netclassid_cgroup.o
 obj-$(CONFIG_LWTUNNEL) += lwtunnel.o
+obj-$(CONFIG_LWTUNNEL_BPF) += lwt_bpf.o
 obj-$(CONFIG_DST_CACHE) += dst_cache.o
 obj-$(CONFIG_HWBM) += hwbm.o
 obj-$(CONFIG_NET_DEVLINK) += devlink.o
diff --git a/net/core/filter.c b/net/core/filter.c
index 698a262..1dafe37 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2188,6 +2188,50 @@ static const struct bpf_func_proto bpf_skb_change_tail_proto = {
 	.arg3_type	= ARG_ANYTHING,
 };
 
+static bool len_fits_mtu(struct sk_buff *skb, u32 len)
+{
+	u32 new_len = skb->len + len;
+
+	if (skb_is_gso(skb))
+		return skb_gso_validate_mtu(skb, skb->dev->mtu - len);
+
+	return new_len <= skb->dev->mtu && new_len >= skb->len;
+}
+
+BPF_CALL_3(bpf_skb_push, struct sk_buff *, skb, __u32, len, u64, flags)
+{
+	if (!len_fits_mtu(skb, len))
+		return -ERANGE;
+
+	if (flags)
+		return -EINVAL;
+
+	if (len > 0) {
+		int ret;
+
+		ret = skb_cow(skb, len);
+		if (unlikely(ret < 0))
+			return ret;
+
+		__skb_push(skb, len);
+		memset(skb->data, 0, len);
+	}
+
+	skb_reset_mac_header(skb);
+	bpf_compute_data_end(skb);
+
+	return 0;
+}
+
+static const struct bpf_func_proto bpf_skb_push_proto = {
+	.func		= bpf_skb_push,
+	.gpl_only	= false,
+	.ret_type	= RET_INTEGER,
+	.arg1_type	= ARG_PTR_TO_CTX,
+	.arg2_type	= ARG_ANYTHING,
+	.arg3_type	= ARG_ANYTHING,
+};
+
 bool bpf_helper_changes_skb_data(void *func)
 {
 	if (func == bpf_skb_vlan_push ||
@@ -2197,7 +2241,8 @@ bool bpf_helper_changes_skb_data(void *func)
 	    func == bpf_skb_change_tail ||
 	    func == bpf_skb_pull_data ||
 	    func == bpf_l3_csum_replace ||
-	    func == bpf_l4_csum_replace)
+	    func == bpf_l4_csum_replace ||
+	    func == bpf_skb_push)
 		return true;
 
 	return false;
@@ -2639,6 +2684,68 @@ cg_skb_func_proto(enum bpf_func_id func_id)
 	}
 }
 
+static const struct bpf_func_proto *
+lwt_inout_func_proto(enum bpf_func_id func_id)
+{
+	switch (func_id) {
+	case BPF_FUNC_skb_load_bytes:
+		return &bpf_skb_load_bytes_proto;
+	case BPF_FUNC_skb_pull_data:
+		return &bpf_skb_pull_data_proto;
+	case BPF_FUNC_csum_diff:
+		return &bpf_csum_diff_proto;
+	case BPF_FUNC_get_cgroup_classid:
+		return &bpf_get_cgroup_classid_proto;
+	case BPF_FUNC_get_route_realm:
+		return &bpf_get_route_realm_proto;
+	case BPF_FUNC_get_hash_recalc:
+		return &bpf_get_hash_recalc_proto;
+	case BPF_FUNC_perf_event_output:
+		return &bpf_skb_event_output_proto;
+	case BPF_FUNC_get_smp_processor_id:
+		return &bpf_get_smp_processor_id_proto;
+	case BPF_FUNC_skb_under_cgroup:
+		return &bpf_skb_under_cgroup_proto;
+	default:
+		return sk_filter_func_proto(func_id);
+	}
+}
+
+static const struct bpf_func_proto *
+lwt_xmit_func_proto(enum bpf_func_id func_id)
+{
+	switch (func_id) {
+	case BPF_FUNC_skb_get_tunnel_key:
+		return &bpf_skb_get_tunnel_key_proto;
+	case BPF_FUNC_skb_set_tunnel_key:
+		return bpf_get_skb_set_tunnel_proto(func_id);
+	case BPF_FUNC_skb_get_tunnel_opt:
+		return &bpf_skb_get_tunnel_opt_proto;
+	case BPF_FUNC_skb_set_tunnel_opt:
+		return bpf_get_skb_set_tunnel_proto(func_id);
+	case BPF_FUNC_redirect:
+		return &bpf_redirect_proto;
+	case BPF_FUNC_clone_redirect:
+		return &bpf_clone_redirect_proto;
+	case BPF_FUNC_skb_change_tail:
+		return &bpf_skb_change_tail_proto;
+	case BPF_FUNC_skb_push:
+		return &bpf_skb_push_proto;
+	case BPF_FUNC_skb_store_bytes:
+		return &bpf_skb_store_bytes_proto;
+	case BPF_FUNC_csum_update:
+		return &bpf_csum_update_proto;
+	case BPF_FUNC_l3_csum_replace:
+		return &bpf_l3_csum_replace_proto;
+	case BPF_FUNC_l4_csum_replace:
+		return &bpf_l4_csum_replace_proto;
+	case BPF_FUNC_set_hash_invalid:
+		return &bpf_set_hash_invalid_proto;
+	default:
+		return lwt_inout_func_proto(func_id);
+	}
+}
+
 static bool __is_valid_access(int off, int size, enum bpf_access_type type)
 {
 	if (off < 0 || off >= sizeof(struct __sk_buff))
@@ -3007,6 +3114,27 @@ static const struct bpf_verifier_ops cg_skb_ops = {
 	.convert_ctx_access	= sk_filter_convert_ctx_access,
 };
 
+static const struct bpf_verifier_ops lwt_in_ops = {
+	.get_func_proto		= lwt_inout_func_proto,
+	.is_valid_access	= tc_cls_act_is_valid_access,
+	.convert_ctx_access	= sk_filter_convert_ctx_access,
+	.gen_prologue		= tc_cls_act_prologue,
+};
+
+static const struct bpf_verifier_ops lwt_out_ops = {
+	.get_func_proto		= lwt_inout_func_proto,
+	.is_valid_access	= tc_cls_act_is_valid_access,
+	.convert_ctx_access	= sk_filter_convert_ctx_access,
+	.gen_prologue		= tc_cls_act_prologue,
+};
+
+static const struct bpf_verifier_ops lwt_xmit_ops = {
+	.get_func_proto		= lwt_xmit_func_proto,
+	.is_valid_access	= tc_cls_act_is_valid_access,
+	.convert_ctx_access	= sk_filter_convert_ctx_access,
+	.gen_prologue		= tc_cls_act_prologue,
+};
+
 static struct bpf_prog_type_list sk_filter_type __read_mostly = {
 	.ops	= &sk_filter_ops,
 	.type	= BPF_PROG_TYPE_SOCKET_FILTER,
@@ -3032,6 +3160,21 @@ static struct bpf_prog_type_list cg_skb_type __read_mostly = {
 	.type	= BPF_PROG_TYPE_CGROUP_SKB,
 };
 
+static struct bpf_prog_type_list lwt_in_type __read_mostly = {
+	.ops	= &lwt_in_ops,
+	.type	= BPF_PROG_TYPE_LWT_IN,
+};
+
+static struct bpf_prog_type_list lwt_out_type __read_mostly = {
+	.ops	= &lwt_out_ops,
+	.type	= BPF_PROG_TYPE_LWT_OUT,
+};
+
+static struct bpf_prog_type_list lwt_xmit_type __read_mostly = {
+	.ops	= &lwt_xmit_ops,
+	.type	= BPF_PROG_TYPE_LWT_XMIT,
+};
+
 static int __init register_sk_filter_ops(void)
 {
 	bpf_register_prog_type(&sk_filter_type);
@@ -3039,6 +3182,9 @@ static int __init register_sk_filter_ops(void)
 	bpf_register_prog_type(&sched_act_type);
 	bpf_register_prog_type(&xdp_type);
 	bpf_register_prog_type(&cg_skb_type);
+	bpf_register_prog_type(&lwt_in_type);
+	bpf_register_prog_type(&lwt_out_type);
+	bpf_register_prog_type(&lwt_xmit_type);
 
 	return 0;
 }
diff --git a/net/core/lwt_bpf.c b/net/core/lwt_bpf.c
new file mode 100644
index 0000000..fdbf6f4
--- /dev/null
+++ b/net/core/lwt_bpf.c
@@ -0,0 +1,397 @@
+/* Copyright (c) 2016 Thomas Graf <tgraf@tgraf.ch>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ */
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/types.h>
+#include <linux/bpf.h>
+#include <net/lwtunnel.h>
+
+struct bpf_lwt_prog {
+	struct bpf_prog *prog;
+	char *name;
+};
+
+struct bpf_lwt {
+	struct bpf_lwt_prog in;
+	struct bpf_lwt_prog out;
+	struct bpf_lwt_prog xmit;
+	int family;
+};
+
+#define MAX_PROG_NAME 256
+
+static inline struct bpf_lwt *bpf_lwt_lwtunnel(struct lwtunnel_state *lwt)
+{
+	return (struct bpf_lwt *)lwt->data;
+}
+
+#define NO_REDIRECT false
+#define CAN_REDIRECT true
+
+static int run_lwt_bpf(struct sk_buff *skb, struct bpf_lwt_prog *lwt,
+		       struct dst_entry *dst, bool can_redirect)
+{
+	int ret;
+
+	/* Preempt disable is needed to protect per-cpu redirect_info between
+	 * BPF prog and skb_do_redirect(). The call_rcu in bpf_prog_put() and
+	 * access to maps strictly require a rcu_read_lock() for protection,
+	 * mixing with BH RCU lock doesn't work.
+	 */
+	preempt_disable();
+	rcu_read_lock();
+	bpf_compute_data_end(skb);
+	ret = BPF_PROG_RUN(lwt->prog, skb);
+	rcu_read_unlock();
+
+	switch (ret) {
+	case BPF_OK:
+		break;
+
+	case BPF_REDIRECT:
+		if (!can_redirect) {
+			WARN_ONCE(1, "Illegal redirect return code in prog %s\n",
+				  lwt->name ? : "<unknown>");
+			ret = BPF_OK;
+		} else {
+			ret = skb_do_redirect(skb);
+			if (ret == 0)
+				ret = BPF_REDIRECT;
+		}
+		break;
+
+	case BPF_DROP:
+		kfree_skb(skb);
+		ret = -EPERM;
+		break;
+
+	default:
+		WARN_ONCE(1, "Illegal LWT BPF return value %u, expect packet loss\n",
+			  ret);
+		kfree_skb(skb);
+		ret = -EINVAL;
+		break;
+	}
+
+	preempt_enable();
+
+	return ret;
+}
+
+static int bpf_input(struct sk_buff *skb)
+{
+	struct dst_entry *dst = skb_dst(skb);
+	struct bpf_lwt *bpf;
+	int ret;
+
+	bpf = bpf_lwt_lwtunnel(dst->lwtstate);
+	if (bpf->in.prog) {
+		ret = run_lwt_bpf(skb, &bpf->in, dst, NO_REDIRECT);
+		if (ret < 0)
+			return ret;
+	}
+
+	if (unlikely(!dst->lwtstate->orig_input)) {
+		WARN_ONCE(1, "orig_input not set on dst for prog %s\n",
+			  bpf->out.name);
+		kfree_skb(skb);
+		return -EINVAL;
+	}
+
+	return dst->lwtstate->orig_input(skb);
+}
+
+static int bpf_output(struct net *net, struct sock *sk, struct sk_buff *skb)
+{
+	struct dst_entry *dst = skb_dst(skb);
+	struct bpf_lwt *bpf;
+	int ret;
+
+	bpf = bpf_lwt_lwtunnel(dst->lwtstate);
+	if (bpf->out.prog) {
+		ret = run_lwt_bpf(skb, &bpf->out, dst, NO_REDIRECT);
+		if (ret < 0)
+			return ret;
+	}
+
+	if (unlikely(!dst->lwtstate->orig_output)) {
+		WARN_ONCE(1, "orig_output not set on dst for prog %s\n",
+			  bpf->out.name);
+		kfree_skb(skb);
+		return -EINVAL;
+	}
+
+	return dst->lwtstate->orig_output(net, sk, skb);
+}
+
+static int xmit_check_hhlen(struct sk_buff *skb)
+{
+	int hh_len = skb_dst(skb)->dev->hard_header_len;
+
+	if (skb_headroom(skb) < hh_len) {
+		int nhead = HH_DATA_ALIGN(hh_len - skb_headroom(skb));
+
+		if (pskb_expand_head(skb, nhead, 0, GFP_ATOMIC))
+			return -ENOMEM;
+	}
+
+	return 0;
+}
+
+static int bpf_xmit(struct sk_buff *skb)
+{
+	struct dst_entry *dst = skb_dst(skb);
+	struct bpf_lwt *bpf;
+
+	bpf = bpf_lwt_lwtunnel(dst->lwtstate);
+	if (bpf->xmit.prog) {
+		int ret;
+
+		ret = run_lwt_bpf(skb, &bpf->xmit, dst, CAN_REDIRECT);
+		switch (ret) {
+		case BPF_OK:
+			/* If the L3 header was expanded, headroom might be too
+			 * small for L2 header now, expand as needed.
+			 */
+			ret = xmit_check_hhlen(skb);
+			if (unlikely(ret))
+				return ret;
+
+			return LWTUNNEL_XMIT_CONTINUE;
+		case BPF_REDIRECT:
+			return LWTUNNEL_XMIT_DONE;
+		default:
+			return ret;
+		}
+	}
+
+	return LWTUNNEL_XMIT_CONTINUE;
+}
+
+static void bpf_lwt_prog_destroy(struct bpf_lwt_prog *prog)
+{
+	if (prog->prog)
+		bpf_prog_put(prog->prog);
+
+	kfree(prog->name);
+}
+
+static void bpf_destroy_state(struct lwtunnel_state *lwt)
+{
+	struct bpf_lwt *bpf = bpf_lwt_lwtunnel(lwt);
+
+	bpf_lwt_prog_destroy(&bpf->in);
+	bpf_lwt_prog_destroy(&bpf->out);
+	bpf_lwt_prog_destroy(&bpf->xmit);
+}
+
+static const struct nla_policy bpf_prog_policy[LWT_BPF_PROG_MAX + 1] = {
+	[LWT_BPF_PROG_FD] = { .type = NLA_U32, },
+	[LWT_BPF_PROG_NAME] = { .type = NLA_NUL_STRING,
+				.len = MAX_PROG_NAME },
+};
+
+static int bpf_parse_prog(struct nlattr *attr, struct bpf_lwt_prog *prog,
+			  enum bpf_prog_type type)
+{
+	struct nlattr *tb[LWT_BPF_PROG_MAX + 1];
+	struct bpf_prog *p;
+	int ret;
+	u32 fd;
+
+	ret = nla_parse_nested(tb, LWT_BPF_PROG_MAX, attr, bpf_prog_policy);
+	if (ret < 0)
+		return ret;
+
+	if (!tb[LWT_BPF_PROG_FD] || !tb[LWT_BPF_PROG_NAME])
+		return -EINVAL;
+
+	prog->name = nla_memdup(tb[LWT_BPF_PROG_NAME], GFP_KERNEL);
+	if (!prog->name)
+		return -ENOMEM;
+
+	fd = nla_get_u32(tb[LWT_BPF_PROG_FD]);
+	p = bpf_prog_get_type(fd, type);
+	if (IS_ERR(p))
+		return PTR_ERR(p);
+
+	prog->prog = p;
+
+	return 0;
+}
+
+static const struct nla_policy bpf_nl_policy[LWT_BPF_MAX + 1] = {
+	[LWT_BPF_IN]		= { .type = NLA_NESTED, },
+	[LWT_BPF_OUT]		= { .type = NLA_NESTED, },
+	[LWT_BPF_XMIT]		= { .type = NLA_NESTED, },
+	[LWT_BPF_XMIT_HEADROOM]	= { .type = NLA_U32 },
+};
+
+static int bpf_build_state(struct net_device *dev, struct nlattr *nla,
+			   unsigned int family, const void *cfg,
+			   struct lwtunnel_state **ts)
+{
+	struct nlattr *tb[LWT_BPF_MAX + 1];
+	struct lwtunnel_state *newts;
+	struct bpf_lwt *bpf;
+	int ret;
+
+	if (family != AF_INET && family != AF_INET6)
+		return -EAFNOSUPPORT;
+
+	ret = nla_parse_nested(tb, LWT_BPF_MAX, nla, bpf_nl_policy);
+	if (ret < 0)
+		return ret;
+
+	if (!tb[LWT_BPF_IN] && !tb[LWT_BPF_OUT] && !tb[LWT_BPF_XMIT])
+		return -EINVAL;
+
+	newts = lwtunnel_state_alloc(sizeof(*bpf));
+	if (!newts)
+		return -ENOMEM;
+
+	newts->type = LWTUNNEL_ENCAP_BPF;
+	bpf = bpf_lwt_lwtunnel(newts);
+
+	if (tb[LWT_BPF_IN]) {
+		newts->flags |= LWTUNNEL_STATE_INPUT_REDIRECT;
+		ret = bpf_parse_prog(tb[LWT_BPF_IN], &bpf->in,
+				     BPF_PROG_TYPE_LWT_IN);
+		if (ret  < 0)
+			goto errout;
+	}
+
+	if (tb[LWT_BPF_OUT]) {
+		newts->flags |= LWTUNNEL_STATE_OUTPUT_REDIRECT;
+		ret = bpf_parse_prog(tb[LWT_BPF_OUT], &bpf->out,
+				     BPF_PROG_TYPE_LWT_OUT);
+		if (ret < 0)
+			goto errout;
+	}
+
+	if (tb[LWT_BPF_XMIT]) {
+		newts->flags |= LWTUNNEL_STATE_XMIT_REDIRECT;
+		ret = bpf_parse_prog(tb[LWT_BPF_XMIT], &bpf->xmit,
+				     BPF_PROG_TYPE_LWT_XMIT);
+		if (ret < 0)
+			goto errout;
+	}
+
+	if (tb[LWT_BPF_XMIT_HEADROOM]) {
+		u32 headroom = nla_get_u32(tb[LWT_BPF_XMIT_HEADROOM]);
+
+		if (headroom > LWT_BPF_MAX_HEADROOM) {
+			ret = -ERANGE;
+			goto errout;
+		}
+
+		newts->headroom = headroom;
+	}
+
+	bpf->family = family;
+	*ts = newts;
+
+	return 0;
+
+errout:
+	bpf_destroy_state(newts);
+	kfree(newts);
+	return ret;
+}
+
+static int bpf_fill_lwt_prog(struct sk_buff *skb, int attr,
+			     struct bpf_lwt_prog *prog)
+{
+	struct nlattr *nest;
+
+	if (!prog->prog)
+		return 0;
+
+	nest = nla_nest_start(skb, attr);
+	if (!nest)
+		return -EMSGSIZE;
+
+	if (prog->name &&
+	    nla_put_string(skb, LWT_BPF_PROG_NAME, prog->name))
+		return -EMSGSIZE;
+
+	return nla_nest_end(skb, nest);
+}
+
+static int bpf_fill_encap_info(struct sk_buff *skb, struct lwtunnel_state *lwt)
+{
+	struct bpf_lwt *bpf = bpf_lwt_lwtunnel(lwt);
+
+	if (bpf_fill_lwt_prog(skb, LWT_BPF_IN, &bpf->in) < 0 ||
+	    bpf_fill_lwt_prog(skb, LWT_BPF_OUT, &bpf->out) < 0 ||
+	    bpf_fill_lwt_prog(skb, LWT_BPF_XMIT, &bpf->xmit) < 0)
+		return -EMSGSIZE;
+
+	return 0;
+}
+
+static int bpf_encap_nlsize(struct lwtunnel_state *lwtstate)
+{
+	int nest_len = nla_total_size(sizeof(struct nlattr)) +
+		       nla_total_size(MAX_PROG_NAME) + /* LWT_BPF_PROG_NAME */
+		       0;
+
+	return nest_len + /* LWT_BPF_IN */
+	       nest_len + /* LWT_BPF_OUT */
+	       nest_len + /* LWT_BPF_XMIT */
+	       0;
+}
+
+int bpf_lwt_prog_cmp(struct bpf_lwt_prog *a, struct bpf_lwt_prog *b)
+{
+	/* FIXME:
+	 * The LWT state is currently rebuilt for delete requests which
+	 * results in a new bpf_prog instance. Comparing names for now.
+	 */
+	if (!a->name && !b->name)
+		return 0;
+
+	if (!a->name || !b->name)
+		return 1;
+
+	return strcmp(a->name, b->name);
+}
+
+static int bpf_encap_cmp(struct lwtunnel_state *a, struct lwtunnel_state *b)
+{
+	struct bpf_lwt *a_bpf = bpf_lwt_lwtunnel(a);
+	struct bpf_lwt *b_bpf = bpf_lwt_lwtunnel(b);
+
+	return bpf_lwt_prog_cmp(&a_bpf->in, &b_bpf->in) ||
+	       bpf_lwt_prog_cmp(&a_bpf->out, &b_bpf->out) ||
+	       bpf_lwt_prog_cmp(&a_bpf->xmit, &b_bpf->xmit);
+}
+
+static const struct lwtunnel_encap_ops bpf_encap_ops = {
+	.build_state	= bpf_build_state,
+	.destroy_state	= bpf_destroy_state,
+	.input		= bpf_input,
+	.output		= bpf_output,
+	.xmit		= bpf_xmit,
+	.fill_encap	= bpf_fill_encap_info,
+	.get_encap_size = bpf_encap_nlsize,
+	.cmp_encap	= bpf_encap_cmp,
+};
+
+static int __init bpf_lwt_init(void)
+{
+	return lwtunnel_encap_add_ops(&bpf_encap_ops, LWTUNNEL_ENCAP_BPF);
+}
+
+subsys_initcall(bpf_lwt_init)
diff --git a/net/core/lwtunnel.c b/net/core/lwtunnel.c
index 03976e9..a5d4e86 100644
--- a/net/core/lwtunnel.c
+++ b/net/core/lwtunnel.c
@@ -41,6 +41,8 @@ static const char *lwtunnel_encap_str(enum lwtunnel_encap_types encap_type)
 		return "ILA";
 	case LWTUNNEL_ENCAP_SEG6:
 		return "SEG6";
+	case LWTUNNEL_ENCAP_BPF:
+		return "BPF";
 	case LWTUNNEL_ENCAP_IP6:
 	case LWTUNNEL_ENCAP_IP:
 	case LWTUNNEL_ENCAP_NONE:
-- 
2.7.4

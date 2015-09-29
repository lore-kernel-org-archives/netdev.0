From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next v2 2/3] sched, bpf: add helper for retrieving routing realms
Date: Wed, 30 Sep 2015 01:41:51 +0200
Message-ID: <719d0c9b5f2919cf3d34735553318136a6df0b5f.1443567433.git.daniel@iogearbox.net>
References: <cover.1443567433.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:59688 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751027AbbI2Xl5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 19:41:57 -0400
In-Reply-To: <cover.1443567433.git.daniel@iogearbox.net>
In-Reply-To: <cover.1443567433.git.daniel@iogearbox.net>
References: <cover.1443567433.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using routing realms as part of the classifier is quite useful, it
can be viewed as a tag for one or multiple routing entries (think of
an analogy to net_cls cgroup for processes), set by user space routing
daemons or via iproute2 as an indicator for traffic classifiers and
later on processed in the eBPF program.

Unlike actions, the classifier can inspect device flags and enable
netif_keep_dst() if necessary. tc actions don't have that possibility,
but in case people know what they are doing, it can be used from there
as well (e.g. via devs that must keep dsts by design anyway).

If a realm is set, the handler returns the non-zero realm. User space
can set the full 32bit realm for the dst.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
---
 include/linux/filter.h   |  3 ++-
 include/uapi/linux/bpf.h |  7 +++++++
 kernel/bpf/syscall.c     |  2 ++
 net/core/filter.c        | 22 ++++++++++++++++++++++
 net/sched/cls_bpf.c      |  8 ++++++--
 5 files changed, 39 insertions(+), 3 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index bad618f..3d5fd24 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -328,7 +328,8 @@ struct bpf_prog {
 	u16			pages;		/* Number of allocated pages */
 	kmemcheck_bitfield_begin(meta);
 	u16			jited:1,	/* Is our filter JIT'ed? */
-				gpl_compatible:1; /* Is filter GPL compatible? */
+				gpl_compatible:1, /* Is filter GPL compatible? */
+				dst_needed:1;	/* Do we need dst entry? */
 	kmemcheck_bitfield_end(meta);
 	u32			len;		/* Number of filter blocks */
 	enum bpf_prog_type	type;		/* Type of BPF program */
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 4ec0b54..564f1f0 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -280,6 +280,13 @@ enum bpf_func_id {
 	 * Return: TC_ACT_REDIRECT
 	 */
 	BPF_FUNC_redirect,
+
+	/**
+	 * bpf_get_route_realm(skb) - retrieve a dst's tclassid
+	 * @skb: pointer to skb
+	 * Return: realm if != 0
+	 */
+	BPF_FUNC_get_route_realm,
 	__BPF_FUNC_MAX_ID,
 };
 
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 2190ab1..5f35f42 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -402,6 +402,8 @@ static void fixup_bpf_calls(struct bpf_prog *prog)
 			 */
 			BUG_ON(!prog->aux->ops->get_func_proto);
 
+			if (insn->imm == BPF_FUNC_get_route_realm)
+				prog->dst_needed = 1;
 			if (insn->imm == BPF_FUNC_tail_call) {
 				/* mark bpf_tail_call as different opcode
 				 * to avoid conditional branch in
diff --git a/net/core/filter.c b/net/core/filter.c
index 04664ac..45c69ce 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -49,6 +49,7 @@
 #include <net/sch_generic.h>
 #include <net/cls_cgroup.h>
 #include <net/dst_metadata.h>
+#include <net/dst.h>
 
 /**
  *	sk_filter - run a packet through a socket filter
@@ -1478,6 +1479,25 @@ static const struct bpf_func_proto bpf_get_cgroup_classid_proto = {
 	.arg1_type      = ARG_PTR_TO_CTX,
 };
 
+static u64 bpf_get_route_realm(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+{
+#ifdef CONFIG_IP_ROUTE_CLASSID
+	const struct dst_entry *dst;
+
+	dst = skb_dst((struct sk_buff *) (unsigned long) r1);
+	if (dst)
+		return dst->tclassid;
+#endif
+	return 0;
+}
+
+static const struct bpf_func_proto bpf_get_route_realm_proto = {
+	.func           = bpf_get_route_realm,
+	.gpl_only       = false,
+	.ret_type       = RET_INTEGER,
+	.arg1_type      = ARG_PTR_TO_CTX,
+};
+
 static u64 bpf_skb_vlan_push(u64 r1, u64 r2, u64 vlan_tci, u64 r4, u64 r5)
 {
 	struct sk_buff *skb = (struct sk_buff *) (long) r1;
@@ -1648,6 +1668,8 @@ tc_cls_act_func_proto(enum bpf_func_id func_id)
 		return bpf_get_skb_set_tunnel_key_proto();
 	case BPF_FUNC_redirect:
 		return &bpf_redirect_proto;
+	case BPF_FUNC_get_route_realm:
+		return &bpf_get_route_realm_proto;
 	default:
 		return sk_filter_func_proto(func_id);
 	}
diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index 7eeffaf6..5faaa54 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -262,7 +262,8 @@ static int cls_bpf_prog_from_ops(struct nlattr **tb, struct cls_bpf_prog *prog)
 	return 0;
 }
 
-static int cls_bpf_prog_from_efd(struct nlattr **tb, struct cls_bpf_prog *prog)
+static int cls_bpf_prog_from_efd(struct nlattr **tb, struct cls_bpf_prog *prog,
+				 const struct tcf_proto *tp)
 {
 	struct bpf_prog *fp;
 	char *name = NULL;
@@ -294,6 +295,9 @@ static int cls_bpf_prog_from_efd(struct nlattr **tb, struct cls_bpf_prog *prog)
 	prog->bpf_name = name;
 	prog->filter = fp;
 
+	if (fp->dst_needed)
+		netif_keep_dst(qdisc_dev(tp->q));
+
 	return 0;
 }
 
@@ -330,7 +334,7 @@ static int cls_bpf_modify_existing(struct net *net, struct tcf_proto *tp,
 	prog->exts_integrated = have_exts;
 
 	ret = is_bpf ? cls_bpf_prog_from_ops(tb, prog) :
-		       cls_bpf_prog_from_efd(tb, prog);
+		       cls_bpf_prog_from_efd(tb, prog, tp);
 	if (ret < 0) {
 		tcf_exts_destroy(&exts);
 		return ret;
-- 
1.9.3

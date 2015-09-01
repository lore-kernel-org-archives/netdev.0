From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 3/4] net: {cls,act}_bpf: add helper for retrieving routing realms
Date: Tue,  1 Sep 2015 18:34:24 +0200
Message-ID: <c6f07f7e5060e04af93886c639291af4e4f4ae1c.1441123709.git.daniel@iogearbox.net>
References: <cover.1441123709.git.daniel@iogearbox.net>
Cc: john.fastabend@gmail.com, ast@plumgrid.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:49543 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753276AbbIAQeb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 12:34:31 -0400
In-Reply-To: <cover.1441123709.git.daniel@iogearbox.net>
In-Reply-To: <cover.1441123709.git.daniel@iogearbox.net>
References: <cover.1441123709.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using routing realms as part of the classifier is quite useful. It can
be viewed as a tag for one or multiple routing entries (think of an
analogy to net_cls cgroup for processes), set by user space routing
daemons or via iproute2 as an indicator for traffic classifiers.

In case we use a ->preclassify() handler, we can read them out for free,
on other devices we need to indicate that the dst must be kept however
until skb destruction.

Unlike actions, at least the classifier can keep track of it and enable
netif_keep_dst() if necessary. tc actions don't have that possibility,
but in case people know exactly what they are doing, it can be used
from there as well (e.g. via preclassify()).

If a realm is set, the handler returns the non-zero realm. User space
can set the full 32bit realm for the dst.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
---
 include/linux/filter.h   |  3 ++-
 include/uapi/linux/bpf.h |  7 +++++++
 kernel/bpf/syscall.c     |  2 ++
 net/core/filter.c        | 22 ++++++++++++++++++++++
 net/sched/cls_bpf.c      |  9 ++++++---
 5 files changed, 39 insertions(+), 4 deletions(-)

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
index 92a48e2..5ea72bb 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -272,6 +272,13 @@ enum bpf_func_id {
 	BPF_FUNC_skb_get_tunnel_key,
 	BPF_FUNC_skb_set_tunnel_key,
 	BPF_FUNC_perf_event_read,	/* u64 bpf_perf_event_read(&map, index) */
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
index 2ba2881..a12046b 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -398,6 +398,8 @@ static void fixup_bpf_calls(struct bpf_prog *prog)
 			 */
 			BUG_ON(!prog->aux->ops->get_func_proto);
 
+			if (insn->imm == BPF_FUNC_get_route_realm)
+				prog->dst_needed = 1;
 			if (insn->imm == BPF_FUNC_tail_call) {
 				/* mark bpf_tail_call as different opcode
 				 * to avoid conditional branch in
diff --git a/net/core/filter.c b/net/core/filter.c
index e1c574c..3765ae1 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -49,6 +49,7 @@
 #include <net/sch_generic.h>
 #include <net/cls_cgroup.h>
 #include <net/dst_metadata.h>
+#include <net/dst.h>
 
 /**
  *	sk_filter - run a packet through a socket filter
@@ -1439,6 +1440,25 @@ static const struct bpf_func_proto bpf_get_cgroup_classid_proto = {
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
@@ -1607,6 +1627,8 @@ tc_cls_act_func_proto(enum bpf_func_id func_id)
 		return &bpf_skb_get_tunnel_key_proto;
 	case BPF_FUNC_skb_set_tunnel_key:
 		return bpf_get_skb_set_tunnel_key_proto();
+	case BPF_FUNC_get_route_realm:
+		return &bpf_get_route_realm_proto;
 	default:
 		return sk_filter_func_proto(func_id);
 	}
diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index e5168f8..b6163b2 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -237,8 +237,8 @@ static int cls_bpf_prog_from_ops(struct nlattr **tb,
 	return 0;
 }
 
-static int cls_bpf_prog_from_efd(struct nlattr **tb,
-				 struct cls_bpf_prog *prog, u32 classid)
+static int cls_bpf_prog_from_efd(struct nlattr **tb, struct cls_bpf_prog *prog,
+				 u32 classid, const struct tcf_proto *tp)
 {
 	struct bpf_prog *fp;
 	char *name = NULL;
@@ -272,6 +272,9 @@ static int cls_bpf_prog_from_efd(struct nlattr **tb,
 	prog->filter = fp;
 	prog->res.classid = classid;
 
+	if (fp->dst_needed && !tp->q->preclassify)
+		netif_keep_dst(qdisc_dev(tp->q));
+
 	return 0;
 }
 
@@ -300,7 +303,7 @@ static int cls_bpf_modify_existing(struct net *net, struct tcf_proto *tp,
 	classid = nla_get_u32(tb[TCA_BPF_CLASSID]);
 
 	ret = is_bpf ? cls_bpf_prog_from_ops(tb, prog, classid) :
-		       cls_bpf_prog_from_efd(tb, prog, classid);
+		       cls_bpf_prog_from_efd(tb, prog, classid, tp);
 	if (ret < 0) {
 		tcf_exts_destroy(&exts);
 		return ret;
-- 
1.9.3

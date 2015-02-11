From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 7/7] cls_bpf: add initial eBPF support for programmable classifiers
Date: Wed, 11 Feb 2015 01:15:18 +0100
Message-ID: <702088715132f9ce44aa1a875a8e75d5ad8ff8ce.1423610452.git.daniel@iogearbox.net>
References: <cover.1423610452.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:56184 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750808AbbBKAPh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2015 19:15:37 -0500
In-Reply-To: <cover.1423610452.git.daniel@iogearbox.net>
In-Reply-To: <cover.1423610452.git.daniel@iogearbox.net>
References: <cover.1423610452.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This work extends the classic BPF programmable classifier by extending
its scope also to native eBPF code. This allows for implementing
custom C-like classifiers, compiling them with the LLVM eBPF backend
and loading the resulting object file via tc into the kernel.

Simple, minimal toy example:

  #include <linux/ip.h>
  #include <linux/if_ether.h>
  #include <linux/bpf.h>

  #include "tc_bpf_api.h"

  __section("classify")
  int cls_main(struct sk_buff *skb)
  {
    return (0x800 << 16) | load_byte(skb, ETH_HLEN + __builtin_offsetof(struct iphdr, tos));
  }

  char __license[] __section("license") = "GPL";

The classifier can then be compiled into eBPF opcodes and loaded via
tc, f.e.:

  clang -O2 -emit-llvm -c cls.c -o - | llc -march=bpf -filetype=obj -o cls.o
  tc filter add dev em1 parent 1: bpf run object-file cls.o [...]

As it has been demonstrated, the scope can even reach up to a fully
fledged flow dissector (similarly as in samples/bpf/sockex2_kern.c).
For tc, maps are allowed to be used, but from kernel context only,
in other words eBPF code can keep state across filter invocations.
Similarly as in socket filters, we may extend functionality for eBPF
classifiers over time depending on the use cases. For that purpose,
I have added the BPF_PROG_TYPE_SCHED_CLS program type for the cls_bpf
classifier module, so we can allow additional functions/accessors.

I was wondering whether cls_bpf and act_bpf may share C programs, I
can imagine that at some point, we may introduce i) some common
handlers for both (or even beyond their scope), and/or ii) some
restricted function space for each of them. Both can be abstracted
through struct bpf_verifier_ops in future. The context of a cls_bpf
versus act_bpf is slightly different though: a cls_bpf program will
return a specific classid whereas act_bpf a drop/non-drop return
code. That said, we can surely have a "classify" and "action" section
in a single object file, or considered mentioned constraint add a
possibility of a shared section.

The workflow for getting native eBPF running from tc [1] is as
follows: for f_bpf, I've added a slightly modified ELF parser code
from Alexei's kernel sample, which reads out the LLVM compiled
object, sets up maps (and dynamically fixes up map fds) if any,
and loads the eBPF instructions all centrally through the bpf
syscall. The resulting fd from the loaded program itself is being
passed down to cls_bpf, which looks up struct bpf_prog from the
fd store, and holds reference, so that it stays available also
after tc program lifetime. On tc filter destruction, it will then
drop its reference.

  [1] http://git.breakpoint.cc/cgit/dborkman/iproute2.git/log/?h=ebpf

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/uapi/linux/bpf.h     |   1 +
 include/uapi/linux/pkt_cls.h |   1 +
 kernel/bpf/verifier.c        |  15 +++-
 net/sched/cls_bpf.c          | 200 ++++++++++++++++++++++++++++++++-----------
 4 files changed, 165 insertions(+), 52 deletions(-)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 0248180..3fa1af8 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -118,6 +118,7 @@ enum bpf_map_type {
 enum bpf_prog_type {
 	BPF_PROG_TYPE_UNSPEC,
 	BPF_PROG_TYPE_SOCKET_FILTER,
+	BPF_PROG_TYPE_SCHED_CLS,
 };
 
 #define BPF_PSEUDO_MAP_FD	1
diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
index 25731df..1f192cb 100644
--- a/include/uapi/linux/pkt_cls.h
+++ b/include/uapi/linux/pkt_cls.h
@@ -397,6 +397,7 @@ enum {
 	TCA_BPF_CLASSID,
 	TCA_BPF_OPS_LEN,
 	TCA_BPF_OPS,
+	TCA_BPF_EFD,
 	__TCA_BPF_MAX,
 };
 
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 857e2fc..9aa4747 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -1173,6 +1173,17 @@ static int check_ld_imm(struct verifier_env *env, struct bpf_insn *insn)
 	return 0;
 }
 
+static bool may_access_skb(enum bpf_prog_type type)
+{
+	switch (type) {
+	case BPF_PROG_TYPE_SOCKET_FILTER:
+	case BPF_PROG_TYPE_SCHED_CLS:
+		return true;
+	default:
+		return false;
+	}
+}
+
 /* verify safety of LD_ABS|LD_IND instructions:
  * - they can only appear in the programs where ctx == skb
  * - since they are wrappers of function calls, they scratch R1-R5 registers,
@@ -1195,8 +1206,8 @@ static int check_ld_abs(struct verifier_env *env, struct bpf_insn *insn)
 	struct reg_state *reg;
 	int i, err;
 
-	if (env->prog->aux->tl->type != BPF_PROG_TYPE_SOCKET_FILTER) {
-		verbose("BPF_LD_ABS|IND instructions are only allowed in socket filters\n");
+	if (!may_access_skb(env->prog->aux->tl->type)) {
+		verbose("BPF_LD_ABS|IND instructions not allowed for this program type\n");
 		return -EINVAL;
 	}
 
diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index 5f3ee9e..c6e1328 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -16,6 +16,8 @@
 #include <linux/types.h>
 #include <linux/skbuff.h>
 #include <linux/filter.h>
+#include <linux/bpf.h>
+
 #include <net/rtnetlink.h>
 #include <net/pkt_cls.h>
 #include <net/sock.h>
@@ -37,18 +39,27 @@ struct cls_bpf_prog {
 	struct tcf_result res;
 	struct list_head link;
 	u32 handle;
-	u16 bpf_num_ops;
+	union {
+		u32 bpf_fd;
+		u16 bpf_num_ops;
+	};
 	struct tcf_proto *tp;
 	struct rcu_head rcu;
 };
 
 static const struct nla_policy bpf_policy[TCA_BPF_MAX + 1] = {
 	[TCA_BPF_CLASSID]	= { .type = NLA_U32 },
+	[TCA_BPF_EFD]		= { .type = NLA_U32 },
 	[TCA_BPF_OPS_LEN]	= { .type = NLA_U16 },
 	[TCA_BPF_OPS]		= { .type = NLA_BINARY,
 				    .len = sizeof(struct sock_filter) * BPF_MAXINSNS },
 };
 
+static bool cls_bpf_is_ebpf(const struct cls_bpf_prog *prog)
+{
+	return prog->bpf_ops == NULL;
+}
+
 static int cls_bpf_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 			    struct tcf_result *res)
 {
@@ -94,7 +105,10 @@ static void cls_bpf_delete_prog(struct tcf_proto *tp, struct cls_bpf_prog *prog)
 {
 	tcf_exts_destroy(&prog->exts);
 
-	bpf_prog_destroy(prog->filter);
+	if (cls_bpf_is_ebpf(prog))
+		bpf_prog_put(prog->filter);
+	else
+		bpf_prog_destroy(prog->filter);
 
 	kfree(prog->bpf_ops);
 	kfree(prog);
@@ -114,6 +128,7 @@ static int cls_bpf_delete(struct tcf_proto *tp, unsigned long arg)
 	list_del_rcu(&prog->link);
 	tcf_unbind_filter(tp, &prog->res);
 	call_rcu(&prog->rcu, __cls_bpf_delete_prog);
+
 	return 0;
 }
 
@@ -151,69 +166,104 @@ static unsigned long cls_bpf_get(struct tcf_proto *tp, u32 handle)
 	return ret;
 }
 
-static int cls_bpf_modify_existing(struct net *net, struct tcf_proto *tp,
-				   struct cls_bpf_prog *prog,
-				   unsigned long base, struct nlattr **tb,
-				   struct nlattr *est, bool ovr)
+static int cls_bpf_prog_from_ops(struct nlattr **tb,
+				 struct cls_bpf_prog *prog, u32 classid)
 {
 	struct sock_filter *bpf_ops;
-	struct tcf_exts exts;
-	struct sock_fprog_kern tmp;
+	struct sock_fprog_kern fprog_tmp;
 	struct bpf_prog *fp;
 	u16 bpf_size, bpf_num_ops;
-	u32 classid;
 	int ret;
 
-	if (!tb[TCA_BPF_OPS_LEN] || !tb[TCA_BPF_OPS] || !tb[TCA_BPF_CLASSID])
-		return -EINVAL;
-
-	tcf_exts_init(&exts, TCA_BPF_ACT, TCA_BPF_POLICE);
-	ret = tcf_exts_validate(net, tp, tb, est, &exts, ovr);
-	if (ret < 0)
-		return ret;
-
-	classid = nla_get_u32(tb[TCA_BPF_CLASSID]);
 	bpf_num_ops = nla_get_u16(tb[TCA_BPF_OPS_LEN]);
-	if (bpf_num_ops > BPF_MAXINSNS || bpf_num_ops == 0) {
-		ret = -EINVAL;
-		goto errout;
-	}
+	if (bpf_num_ops > BPF_MAXINSNS || bpf_num_ops == 0)
+		return -EINVAL;
 
 	bpf_size = bpf_num_ops * sizeof(*bpf_ops);
-	if (bpf_size != nla_len(tb[TCA_BPF_OPS])) {
-		ret = -EINVAL;
-		goto errout;
-	}
+	if (bpf_size != nla_len(tb[TCA_BPF_OPS]))
+		return -EINVAL;
 
 	bpf_ops = kzalloc(bpf_size, GFP_KERNEL);
-	if (bpf_ops == NULL) {
-		ret = -ENOMEM;
-		goto errout;
-	}
+	if (bpf_ops == NULL)
+		return -ENOMEM;
 
 	memcpy(bpf_ops, nla_data(tb[TCA_BPF_OPS]), bpf_size);
 
-	tmp.len = bpf_num_ops;
-	tmp.filter = bpf_ops;
+	fprog_tmp.len = bpf_num_ops;
+	fprog_tmp.filter = bpf_ops;
 
-	ret = bpf_prog_create(&fp, &tmp);
-	if (ret)
-		goto errout_free;
+	ret = bpf_prog_create(&fp, &fprog_tmp);
+	if (ret < 0) {
+		kfree(bpf_ops);
+		return ret;
+	}
 
 	prog->bpf_num_ops = bpf_num_ops;
 	prog->bpf_ops = bpf_ops;
 	prog->filter = fp;
 	prog->res.classid = classid;
 
+	return 0;
+}
+
+static int cls_bpf_prog_from_efd(struct nlattr **tb,
+				 struct cls_bpf_prog *prog, u32 classid)
+{
+	struct bpf_prog *fp;
+	u32 bpf_fd;
+
+	bpf_fd = nla_get_u32(tb[TCA_BPF_EFD]);
+
+	fp = bpf_prog_get(bpf_fd);
+	if (IS_ERR(fp))
+		return PTR_ERR(fp);
+
+	if (fp->aux->tl->type != BPF_PROG_TYPE_SCHED_CLS) {
+		bpf_prog_put(fp);
+		return -EINVAL;
+	}
+
+	prog->bpf_ops = NULL;
+	prog->bpf_fd = bpf_fd;
+	prog->filter = fp;
+	prog->res.classid = classid;
+
+	return 0;
+}
+
+static int cls_bpf_modify_existing(struct net *net, struct tcf_proto *tp,
+				   struct cls_bpf_prog *prog,
+				   unsigned long base, struct nlattr **tb,
+				   struct nlattr *est, bool ovr)
+{
+	struct tcf_exts exts;
+	bool is_bpf, is_ebpf;
+	u32 classid;
+	int ret;
+
+	is_bpf = tb[TCA_BPF_OPS_LEN] && tb[TCA_BPF_OPS];
+	is_ebpf = tb[TCA_BPF_EFD];
+	if ((!is_bpf && !is_ebpf) || !tb[TCA_BPF_CLASSID])
+		return -EINVAL;
+
+	tcf_exts_init(&exts, TCA_BPF_ACT, TCA_BPF_POLICE);
+	ret = tcf_exts_validate(net, tp, tb, est, &exts, ovr);
+	if (ret < 0)
+		return ret;
+
+	classid = nla_get_u32(tb[TCA_BPF_CLASSID]);
+
+	ret = is_bpf ? cls_bpf_prog_from_ops(tb, prog, classid) :
+		       cls_bpf_prog_from_efd(tb, prog, classid);
+	if (ret < 0) {
+		tcf_exts_destroy(&exts);
+		return ret;
+	}
+
 	tcf_bind_filter(tp, &prog->res, base);
 	tcf_exts_change(tp, &prog->exts, &exts);
 
 	return 0;
-errout_free:
-	kfree(bpf_ops);
-errout:
-	tcf_exts_destroy(&exts);
-	return ret;
 }
 
 static u32 cls_bpf_grab_new_handle(struct tcf_proto *tp,
@@ -290,10 +340,10 @@ static int cls_bpf_change(struct net *net, struct sk_buff *in_skb,
 	}
 
 	*arg = (unsigned long) prog;
+
 	return 0;
 errout:
 	kfree(prog);
-
 	return ret;
 }
 
@@ -301,7 +351,7 @@ static int cls_bpf_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 			struct sk_buff *skb, struct tcmsg *tm)
 {
 	struct cls_bpf_prog *prog = (struct cls_bpf_prog *) fh;
-	struct nlattr *nest, *nla;
+	struct nlattr *nest;
 
 	if (prog == NULL)
 		return skb->len;
@@ -314,15 +364,23 @@ static int cls_bpf_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 
 	if (nla_put_u32(skb, TCA_BPF_CLASSID, prog->res.classid))
 		goto nla_put_failure;
-	if (nla_put_u16(skb, TCA_BPF_OPS_LEN, prog->bpf_num_ops))
-		goto nla_put_failure;
 
-	nla = nla_reserve(skb, TCA_BPF_OPS, prog->bpf_num_ops *
-			  sizeof(struct sock_filter));
-	if (nla == NULL)
-		goto nla_put_failure;
+	if (cls_bpf_is_ebpf(prog)) {
+		if (nla_put_u32(skb, TCA_BPF_EFD, prog->bpf_fd))
+			goto nla_put_failure;
+	} else {
+		struct nlattr *nla;
+
+		if (nla_put_u16(skb, TCA_BPF_OPS_LEN, prog->bpf_num_ops))
+			goto nla_put_failure;
 
-	memcpy(nla_data(nla), prog->bpf_ops, nla_len(nla));
+		nla = nla_reserve(skb, TCA_BPF_OPS, prog->bpf_num_ops *
+				  sizeof(struct sock_filter));
+		if (nla == NULL)
+			goto nla_put_failure;
+
+		memcpy(nla_data(nla), prog->bpf_ops, nla_len(nla));
+	}
 
 	if (tcf_exts_dump(skb, &prog->exts) < 0)
 		goto nla_put_failure;
@@ -356,6 +414,37 @@ skip:
 	}
 }
 
+static const struct bpf_func_proto *bpf_cls_func_proto(enum bpf_func_id func_id)
+{
+	switch (func_id) {
+	default:
+		return NULL;
+	case BPF_FUNC_map_lookup_elem:
+		return &bpf_map_lookup_elem_proto;
+	case BPF_FUNC_map_update_elem:
+		return &bpf_map_update_elem_proto;
+	case BPF_FUNC_map_delete_elem:
+		return &bpf_map_delete_elem_proto;
+	}
+}
+
+static bool bpf_cls_valid_access(int off, int size, enum bpf_access_type type)
+{
+	/* TODO: skb fields cannot be accessed yet */
+	return false;
+}
+
+static const struct bpf_verifier_ops bpf_cls_vops = {
+	.get_func_proto		= bpf_cls_func_proto,
+	.is_valid_access	= bpf_cls_valid_access,
+};
+
+static struct bpf_prog_type_list bpf_cls_type = {
+	.ops = &bpf_cls_vops,
+	.type = BPF_PROG_TYPE_SCHED_CLS,
+	.owner = THIS_MODULE,
+};
+
 static struct tcf_proto_ops cls_bpf_ops __read_mostly = {
 	.kind		=	"bpf",
 	.owner		=	THIS_MODULE,
@@ -371,12 +460,23 @@ static struct tcf_proto_ops cls_bpf_ops __read_mostly = {
 
 static int __init cls_bpf_init_mod(void)
 {
-	return register_tcf_proto_ops(&cls_bpf_ops);
+	int ret;
+
+	ret = bpf_register_prog_type(&bpf_cls_type);
+	if (ret)
+		return ret;
+
+	ret = register_tcf_proto_ops(&cls_bpf_ops);
+	if (ret)
+		bpf_unregister_prog_type(&bpf_cls_type);
+
+	return ret;
 }
 
 static void __exit cls_bpf_exit_mod(void)
 {
 	unregister_tcf_proto_ops(&cls_bpf_ops);
+	bpf_unregister_prog_type(&bpf_cls_type);
 }
 
 module_init(cls_bpf_init_mod);
-- 
1.9.3

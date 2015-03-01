From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next v2 8/8] cls_bpf: add initial eBPF support for programmable classifiers
Date: Sun,  1 Mar 2015 12:31:48 +0100
Message-ID: <a1b5793acce38e3ee23d49749f37b627aad89ba0.1425208502.git.daniel@iogearbox.net>
References: <cover.1425208501.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Jiri Pirko <jiri@resnulli.us>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:52054 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752408AbbCALcW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2015 06:32:22 -0500
In-Reply-To: <cover.1425208501.git.daniel@iogearbox.net>
In-Reply-To: <cover.1425208501.git.daniel@iogearbox.net>
References: <cover.1425208501.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This work extends the "classic" BPF programmable tc classifier by
extending its scope also to native eBPF code!

This allows for user space to implement own custom, 'safe' C like
classifiers (or whatever other frontend language LLVM et al may
provide in future), that can then be compiled with the LLVM eBPF
backend to an eBPF elf file. The result of this can be loaded into
the kernel via iproute2's tc. In the kernel, they can be JITed on
major archs and thus run in native performance.

Simple, minimal toy example to demonstrate the workflow:

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

The classifier can then be compiled into eBPF opcodes and loaded
via tc, for example:

  clang -O2 -emit-llvm -c cls.c -o - | llc -march=bpf -filetype=obj -o cls.o
  tc filter add dev em1 parent 1: bpf cls.o [...]

As it has been demonstrated, the scope can even reach up to a fully
fledged flow dissector (similarly as in samples/bpf/sockex2_kern.c).

For tc, maps are allowed to be used, but from kernel context only,
in other words, eBPF code can keep state across filter invocations.
In future, we perhaps may reattach from a different application to
those maps e.g., to read out collected statistics/state.

Similarly as in socket filters, we may extend functionality for eBPF
classifiers over time depending on the use cases. For that purpose,
cls_bpf programs are using BPF_PROG_TYPE_SCHED_CLS program type, so
we can allow additional functions/accessors (e.g. an ABI compatible
offset translation to skb fields/metadata). For an initial cls_bpf
support, we allow the same set of helper functions as eBPF socket
filters, but we could diverge at some point in time w/o problem.

I was wondering whether cls_bpf and act_bpf could share C programs,
I can imagine that at some point, we introduce i) further common
handlers for both (or even beyond their scope), and/or if truly needed
ii) some restricted function space for each of them. Both can be
abstracted easily through struct bpf_verifier_ops in future.

The context of cls_bpf versus act_bpf is slightly different though:
a cls_bpf program will return a specific classid whereas act_bpf a
drop/non-drop return code, latter may also in future mangle skbs.
That said, we can surely have a "classify" and "action" section in
a single object file, or considered mentioned constraint add a
possibility of a shared section.

The workflow for getting native eBPF running from tc [1] is as
follows: for f_bpf, I've added a slightly modified ELF parser code
from Alexei's kernel sample, which reads out the LLVM compiled
object, sets up maps (and dynamically fixes up map fds) if any, and
loads the eBPF instructions all centrally through the bpf syscall.

The resulting fd from the loaded program itself is being passed down
to cls_bpf, which looks up struct bpf_prog from the fd store, and
holds reference, so that it stays available also after tc program
lifetime. On tc filter destruction, it will then drop its reference.

Moreover, I've also added the optional possibility to annotate an
eBPF filter with a name (e.g. path to object file, or something
else if preferred) so that when tc dumps currently installed filters,
some more context can be given to an admin for a given instance (as
opposed to just the file descriptor number).

Last but not least, bpf_prog_get() and bpf_prog_put() needed to be
exported, so that eBPF can be used from cls_bpf built as a module.
Thanks to 60a3b2253c41 ("net: bpf: make eBPF interpreter images
read-only") I think this is of no concern since anything wanting to
alter eBPF opcode after verification stage would crash the kernel.

  [1] http://git.breakpoint.cc/cgit/dborkman/iproute2.git/log/?h=ebpf

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: Jiri Pirko <jiri@resnulli.us>
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
---
 include/uapi/linux/pkt_cls.h |   2 +
 kernel/bpf/syscall.c         |   2 +
 net/sched/cls_bpf.c          | 206 ++++++++++++++++++++++++++++++++-----------
 3 files changed, 158 insertions(+), 52 deletions(-)

diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
index 25731df..bf08e76 100644
--- a/include/uapi/linux/pkt_cls.h
+++ b/include/uapi/linux/pkt_cls.h
@@ -397,6 +397,8 @@ enum {
 	TCA_BPF_CLASSID,
 	TCA_BPF_OPS_LEN,
 	TCA_BPF_OPS,
+	TCA_BPF_FD,
+	TCA_BPF_NAME,
 	__TCA_BPF_MAX,
 };
 
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 0d69449..669719c 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -419,6 +419,7 @@ void bpf_prog_put(struct bpf_prog *prog)
 		bpf_prog_free(prog);
 	}
 }
+EXPORT_SYMBOL_GPL(bpf_prog_put);
 
 static int bpf_prog_release(struct inode *inode, struct file *filp)
 {
@@ -466,6 +467,7 @@ struct bpf_prog *bpf_prog_get(u32 ufd)
 	fdput(f);
 	return prog;
 }
+EXPORT_SYMBOL_GPL(bpf_prog_get);
 
 /* last field in 'union bpf_attr' used by this command */
 #define	BPF_PROG_LOAD_LAST_FIELD log_buf
diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index 5f3ee9e..6f7ed8f 100644
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
@@ -24,6 +26,8 @@ MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Daniel Borkmann <dborkman@redhat.com>");
 MODULE_DESCRIPTION("TC BPF based classifier");
 
+#define CLS_BPF_NAME_LEN	256
+
 struct cls_bpf_head {
 	struct list_head plist;
 	u32 hgen;
@@ -32,18 +36,24 @@ struct cls_bpf_head {
 
 struct cls_bpf_prog {
 	struct bpf_prog *filter;
-	struct sock_filter *bpf_ops;
-	struct tcf_exts exts;
-	struct tcf_result res;
 	struct list_head link;
+	struct tcf_result res;
+	struct tcf_exts exts;
 	u32 handle;
-	u16 bpf_num_ops;
+	union {
+		u32 bpf_fd;
+		u16 bpf_num_ops;
+	};
+	struct sock_filter *bpf_ops;
+	const char *bpf_name;
 	struct tcf_proto *tp;
 	struct rcu_head rcu;
 };
 
 static const struct nla_policy bpf_policy[TCA_BPF_MAX + 1] = {
 	[TCA_BPF_CLASSID]	= { .type = NLA_U32 },
+	[TCA_BPF_FD]		= { .type = NLA_U32 },
+	[TCA_BPF_NAME]		= { .type = NLA_NUL_STRING, .len = CLS_BPF_NAME_LEN },
 	[TCA_BPF_OPS_LEN]	= { .type = NLA_U16 },
 	[TCA_BPF_OPS]		= { .type = NLA_BINARY,
 				    .len = sizeof(struct sock_filter) * BPF_MAXINSNS },
@@ -76,6 +86,11 @@ static int cls_bpf_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 	return -1;
 }
 
+static bool cls_bpf_is_ebpf(const struct cls_bpf_prog *prog)
+{
+	return !prog->bpf_ops;
+}
+
 static int cls_bpf_init(struct tcf_proto *tp)
 {
 	struct cls_bpf_head *head;
@@ -94,8 +109,12 @@ static void cls_bpf_delete_prog(struct tcf_proto *tp, struct cls_bpf_prog *prog)
 {
 	tcf_exts_destroy(&prog->exts);
 
-	bpf_prog_destroy(prog->filter);
+	if (cls_bpf_is_ebpf(prog))
+		bpf_prog_put(prog->filter);
+	else
+		bpf_prog_destroy(prog->filter);
 
+	kfree(prog->bpf_name);
 	kfree(prog->bpf_ops);
 	kfree(prog);
 }
@@ -114,6 +133,7 @@ static int cls_bpf_delete(struct tcf_proto *tp, unsigned long arg)
 	list_del_rcu(&prog->link);
 	tcf_unbind_filter(tp, &prog->res);
 	call_rcu(&prog->rcu, __cls_bpf_delete_prog);
+
 	return 0;
 }
 
@@ -151,69 +171,121 @@ static unsigned long cls_bpf_get(struct tcf_proto *tp, u32 handle)
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
 
-	prog->bpf_num_ops = bpf_num_ops;
 	prog->bpf_ops = bpf_ops;
+	prog->bpf_num_ops = bpf_num_ops;
+	prog->bpf_name = NULL;
+
 	prog->filter = fp;
 	prog->res.classid = classid;
 
+	return 0;
+}
+
+static int cls_bpf_prog_from_efd(struct nlattr **tb,
+				 struct cls_bpf_prog *prog, u32 classid)
+{
+	struct bpf_prog *fp;
+	char *name = NULL;
+	u32 bpf_fd;
+
+	bpf_fd = nla_get_u32(tb[TCA_BPF_FD]);
+
+	fp = bpf_prog_get(bpf_fd);
+	if (IS_ERR(fp))
+		return PTR_ERR(fp);
+
+	if (fp->type != BPF_PROG_TYPE_SCHED_CLS) {
+		bpf_prog_put(fp);
+		return -EINVAL;
+	}
+
+	if (tb[TCA_BPF_NAME]) {
+		name = kmemdup(nla_data(tb[TCA_BPF_NAME]),
+			       nla_len(tb[TCA_BPF_NAME]),
+			       GFP_KERNEL);
+		if (!name) {
+			bpf_prog_put(fp);
+			return -ENOMEM;
+		}
+	}
+
+	prog->bpf_ops = NULL;
+	prog->bpf_fd = bpf_fd;
+	prog->bpf_name = name;
+
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
+	is_ebpf = tb[TCA_BPF_FD];
+
+	if ((!is_bpf && !is_ebpf) || (is_bpf && is_ebpf) ||
+	    !tb[TCA_BPF_CLASSID])
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
@@ -297,11 +369,43 @@ errout:
 	return ret;
 }
 
+static int cls_bpf_dump_bpf_info(const struct cls_bpf_prog *prog,
+				 struct sk_buff *skb)
+{
+	struct nlattr *nla;
+
+	if (nla_put_u16(skb, TCA_BPF_OPS_LEN, prog->bpf_num_ops))
+		return -EMSGSIZE;
+
+	nla = nla_reserve(skb, TCA_BPF_OPS, prog->bpf_num_ops *
+			  sizeof(struct sock_filter));
+	if (nla == NULL)
+		return -EMSGSIZE;
+
+	memcpy(nla_data(nla), prog->bpf_ops, nla_len(nla));
+
+	return 0;
+}
+
+static int cls_bpf_dump_ebpf_info(const struct cls_bpf_prog *prog,
+				  struct sk_buff *skb)
+{
+	if (nla_put_u32(skb, TCA_BPF_FD, prog->bpf_fd))
+		return -EMSGSIZE;
+
+	if (prog->bpf_name &&
+	    nla_put_string(skb, TCA_BPF_NAME, prog->bpf_name))
+		return -EMSGSIZE;
+
+	return 0;
+}
+
 static int cls_bpf_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 			struct sk_buff *skb, struct tcmsg *tm)
 {
 	struct cls_bpf_prog *prog = (struct cls_bpf_prog *) fh;
-	struct nlattr *nest, *nla;
+	struct nlattr *nest;
+	int ret;
 
 	if (prog == NULL)
 		return skb->len;
@@ -314,16 +418,14 @@ static int cls_bpf_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 
 	if (nla_put_u32(skb, TCA_BPF_CLASSID, prog->res.classid))
 		goto nla_put_failure;
-	if (nla_put_u16(skb, TCA_BPF_OPS_LEN, prog->bpf_num_ops))
-		goto nla_put_failure;
 
-	nla = nla_reserve(skb, TCA_BPF_OPS, prog->bpf_num_ops *
-			  sizeof(struct sock_filter));
-	if (nla == NULL)
+	if (cls_bpf_is_ebpf(prog))
+		ret = cls_bpf_dump_ebpf_info(prog, skb);
+	else
+		ret = cls_bpf_dump_bpf_info(prog, skb);
+	if (ret)
 		goto nla_put_failure;
 
-	memcpy(nla_data(nla), prog->bpf_ops, nla_len(nla));
-
 	if (tcf_exts_dump(skb, &prog->exts) < 0)
 		goto nla_put_failure;
 
-- 
1.9.3

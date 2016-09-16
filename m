From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCHv5 net-next 02/15] net: cls_bpf: limit hardware offload by software-only flag
Date: Fri, 16 Sep 2016 10:36:49 +0100
Message-ID: <1474018622-10653-3-git-send-email-jakub.kicinski@netronome.com>
References: <1474018622-10653-1-git-send-email-jakub.kicinski@netronome.com>
Cc: ast@kernel.org, daniel@iogearbox.net,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:38206 "EHLO
        mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753435AbcIPJhh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2016 05:37:37 -0400
Received: by mail-wm0-f46.google.com with SMTP id 1so30498105wmz.1
        for <netdev@vger.kernel.org>; Fri, 16 Sep 2016 02:37:36 -0700 (PDT)
In-Reply-To: <1474018622-10653-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add cls_bpf support for the TCA_CLS_FLAGS_SKIP_HW flag.
Unlike U32 and flower cls_bpf already has some netlink
flags defined.  Create a new attribute to be able to use
the same flag values as the above.

Unlike U32 and flower reject unknown flags.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
v3:
 - reject (instead of clear) unsupported flags;
 - fix error handling.
v2:
 - rename TCA_BPF_GEN_TCA_FLAGS -> TCA_BPF_FLAGS_GEN;
 - add comment about clearing unsupported flags;
 - validate flags after clearing unsupported.
---
 include/net/pkt_cls.h        |  1 +
 include/uapi/linux/pkt_cls.h |  1 +
 net/sched/cls_bpf.c          | 22 ++++++++++++++++++++--
 3 files changed, 22 insertions(+), 2 deletions(-)

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index 41e8071dff87..57af9f3032ff 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -498,6 +498,7 @@ struct tc_cls_bpf_offload {
 	struct bpf_prog *prog;
 	const char *name;
 	bool exts_integrated;
+	u32 gen_flags;
 };
 
 #endif
diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
index 8915b61bbf83..8fd715f806a2 100644
--- a/include/uapi/linux/pkt_cls.h
+++ b/include/uapi/linux/pkt_cls.h
@@ -396,6 +396,7 @@ enum {
 	TCA_BPF_FD,
 	TCA_BPF_NAME,
 	TCA_BPF_FLAGS,
+	TCA_BPF_FLAGS_GEN,
 	__TCA_BPF_MAX,
 };
 
diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index 3ca9502a881c..46af423a8a8f 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -27,6 +27,8 @@ MODULE_AUTHOR("Daniel Borkmann <dborkman@redhat.com>");
 MODULE_DESCRIPTION("TC BPF based classifier");
 
 #define CLS_BPF_NAME_LEN	256
+#define CLS_BPF_SUPPORTED_GEN_FLAGS		\
+	TCA_CLS_FLAGS_SKIP_HW
 
 struct cls_bpf_head {
 	struct list_head plist;
@@ -40,6 +42,7 @@ struct cls_bpf_prog {
 	struct tcf_result res;
 	bool exts_integrated;
 	bool offloaded;
+	u32 gen_flags;
 	struct tcf_exts exts;
 	u32 handle;
 	union {
@@ -55,6 +58,7 @@ struct cls_bpf_prog {
 static const struct nla_policy bpf_policy[TCA_BPF_MAX + 1] = {
 	[TCA_BPF_CLASSID]	= { .type = NLA_U32 },
 	[TCA_BPF_FLAGS]		= { .type = NLA_U32 },
+	[TCA_BPF_FLAGS_GEN]	= { .type = NLA_U32 },
 	[TCA_BPF_FD]		= { .type = NLA_U32 },
 	[TCA_BPF_NAME]		= { .type = NLA_NUL_STRING, .len = CLS_BPF_NAME_LEN },
 	[TCA_BPF_OPS_LEN]	= { .type = NLA_U16 },
@@ -153,6 +157,7 @@ static int cls_bpf_offload_cmd(struct tcf_proto *tp, struct cls_bpf_prog *prog,
 	bpf_offload.prog = prog->filter;
 	bpf_offload.name = prog->bpf_name;
 	bpf_offload.exts_integrated = prog->exts_integrated;
+	bpf_offload.gen_flags = prog->gen_flags;
 
 	return dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle,
 					     tp->protocol, &offload);
@@ -166,14 +171,14 @@ static void cls_bpf_offload(struct tcf_proto *tp, struct cls_bpf_prog *prog,
 	enum tc_clsbpf_command cmd;
 
 	if (oldprog && oldprog->offloaded) {
-		if (tc_should_offload(dev, tp, 0)) {
+		if (tc_should_offload(dev, tp, prog->gen_flags)) {
 			cmd = TC_CLSBPF_REPLACE;
 		} else {
 			obj = oldprog;
 			cmd = TC_CLSBPF_DESTROY;
 		}
 	} else {
-		if (!tc_should_offload(dev, tp, 0))
+		if (!tc_should_offload(dev, tp, prog->gen_flags))
 			return;
 		cmd = TC_CLSBPF_ADD;
 	}
@@ -369,6 +374,7 @@ static int cls_bpf_modify_existing(struct net *net, struct tcf_proto *tp,
 {
 	bool is_bpf, is_ebpf, have_exts = false;
 	struct tcf_exts exts;
+	u32 gen_flags = 0;
 	int ret;
 
 	is_bpf = tb[TCA_BPF_OPS_LEN] && tb[TCA_BPF_OPS];
@@ -393,8 +399,17 @@ static int cls_bpf_modify_existing(struct net *net, struct tcf_proto *tp,
 
 		have_exts = bpf_flags & TCA_BPF_FLAG_ACT_DIRECT;
 	}
+	if (tb[TCA_BPF_FLAGS_GEN]) {
+		gen_flags = nla_get_u32(tb[TCA_BPF_FLAGS_GEN]);
+		if (gen_flags & ~CLS_BPF_SUPPORTED_GEN_FLAGS ||
+		    !tc_flags_valid(gen_flags)) {
+			ret = -EINVAL;
+			goto errout;
+		}
+	}
 
 	prog->exts_integrated = have_exts;
+	prog->gen_flags = gen_flags;
 
 	ret = is_bpf ? cls_bpf_prog_from_ops(tb, prog) :
 		       cls_bpf_prog_from_efd(tb, prog, tp);
@@ -566,6 +581,9 @@ static int cls_bpf_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 		bpf_flags |= TCA_BPF_FLAG_ACT_DIRECT;
 	if (bpf_flags && nla_put_u32(skb, TCA_BPF_FLAGS, bpf_flags))
 		goto nla_put_failure;
+	if (prog->gen_flags &&
+	    nla_put_u32(skb, TCA_BPF_FLAGS_GEN, prog->gen_flags))
+		goto nla_put_failure;
 
 	nla_nest_end(skb, nest);
 
-- 
1.9.1

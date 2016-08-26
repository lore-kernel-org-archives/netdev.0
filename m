From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [RFCv2 03/16] net: cls_bpf: limit hardware offload by software-only flag
Date: Fri, 26 Aug 2016 19:06:02 +0100
Message-ID: <1472234775-29453-4-git-send-email-jakub.kicinski@netronome.com>
References: <1472234775-29453-1-git-send-email-jakub.kicinski@netronome.com>
Cc: ast@kernel.org, daniel@iogearbox.net,
        dinan.gunawardena@netronome.com, jiri@resnulli.us,
        john.fastabend@gmail.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:35778 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752303AbcHZSOM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2016 14:14:12 -0400
Received: by mail-wm0-f41.google.com with SMTP id f65so3013598wmi.0
        for <netdev@vger.kernel.org>; Fri, 26 Aug 2016 11:14:01 -0700 (PDT)
In-Reply-To: <1472234775-29453-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add cls_bpf support for the TCA_CLS_FLAGS_SKIP_HW flag.
Unlike U32 and flower cls_bpf already has some netlink
flags defined.  I chose to create a new attribute to be
able to use the same flag values as the above.

Unknown flags are ignored and not reported upon dump.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
v2:
 - rename TCA_BPF_GEN_TCA_FLAGS -> TCA_BPF_FLAGS_GEN;
 - add comment about clearing unsupported flags;
 - validate flags after clearing unsupported.
---
 include/net/pkt_cls.h        |  1 +
 include/uapi/linux/pkt_cls.h |  1 +
 net/sched/cls_bpf.c          | 21 +++++++++++++++++++--
 3 files changed, 21 insertions(+), 2 deletions(-)

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index a86262f0d93a..0a4a51f339b4 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -498,6 +498,7 @@ struct tc_cls_bpf_offload {
 	struct bpf_prog *filter;
 	const char *name;
 	bool exts_integrated;
+	u32 gen_flags;
 };
 
 #endif
diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
index 51b5b247fb5a..5cb7ba5efe57 100644
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
index ea87595c49ad..1999f44075f0 100644
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
@@ -156,6 +160,7 @@ static int cls_bpf_offload_cmd(struct tcf_proto *tp, struct cls_bpf_prog *prog,
 	bpf_offload.filter = prog->filter;
 	bpf_offload.name = prog->bpf_name;
 	bpf_offload.exts_integrated = prog->exts_integrated;
+	bpf_offload.gen_flags = prog->gen_flags;
 
 	return dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle,
 					     tp->protocol, &offload);
@@ -169,14 +174,14 @@ static void cls_bpf_offload(struct tcf_proto *tp, struct cls_bpf_prog *prog,
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
@@ -372,6 +377,7 @@ static int cls_bpf_modify_existing(struct net *net, struct tcf_proto *tp,
 {
 	bool is_bpf, is_ebpf, have_exts = false;
 	struct tcf_exts exts;
+	u32 gen_flags = 0;
 	int ret;
 
 	is_bpf = tb[TCA_BPF_OPS_LEN] && tb[TCA_BPF_OPS];
@@ -396,8 +402,16 @@ static int cls_bpf_modify_existing(struct net *net, struct tcf_proto *tp,
 
 		have_exts = bpf_flags & TCA_BPF_FLAG_ACT_DIRECT;
 	}
+	if (tb[TCA_BPF_FLAGS_GEN]) {
+		gen_flags = nla_get_u32(tb[TCA_BPF_FLAGS_GEN]);
+		/* Make sure dump doesn't report back flags we don't handle */
+		gen_flags &= CLS_BPF_SUPPORTED_GEN_FLAGS;
+		if (!tc_flags_valid(gen_flags))
+			return -EINVAL;
+	}
 
 	prog->exts_integrated = have_exts;
+	prog->gen_flags = gen_flags;
 
 	ret = is_bpf ? cls_bpf_prog_from_ops(tb, prog) :
 		       cls_bpf_prog_from_efd(tb, prog, tp);
@@ -569,6 +583,9 @@ static int cls_bpf_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 		bpf_flags |= TCA_BPF_FLAG_ACT_DIRECT;
 	if (bpf_flags && nla_put_u32(skb, TCA_BPF_FLAGS, bpf_flags))
 		goto nla_put_failure;
+	if (prog->gen_flags &&
+	    nla_put_u32(skb, TCA_BPF_FLAGS_GEN, prog->gen_flags))
+		goto nla_put_failure;
 
 	nla_nest_end(skb, nest);
 
-- 
1.9.1

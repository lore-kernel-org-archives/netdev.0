From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [RFC 03/12] net: cls_bpf: limit hardware offload by software-only flag
Date: Wed,  1 Jun 2016 17:50:05 +0100
Message-ID: <1464799814-4453-4-git-send-email-jakub.kicinski@netronome.com>
References: <1464799814-4453-1-git-send-email-jakub.kicinski@netronome.com>
Cc: ast@kernel.org, daniel@iogearbox.net,
	dinan.gunawardena@netronome.com,
	Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:38150 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756148AbcFAQvq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 12:51:46 -0400
Received: by mail-wm0-f52.google.com with SMTP id a20so35118457wma.1
        for <netdev@vger.kernel.org>; Wed, 01 Jun 2016 09:51:45 -0700 (PDT)
In-Reply-To: <1464799814-4453-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add cls_bpf support for the TCA_CLS_FLAGS_SKIP_HW flag.
Unlike U32 and flower cls_bpf already has some netlink
flags defined.  I chose to create a new attribute to be
able to use the same flag values as the above.

Unknown flags are ignored and not reported upon dump.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Dinan Gunawardena <dgunawardena@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 include/net/pkt_cls.h        |  1 +
 include/uapi/linux/pkt_cls.h |  1 +
 net/sched/cls_bpf.c          | 16 ++++++++++++++--
 3 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index 10b7e8cdc98c..e6b3dfb3159b 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -450,6 +450,7 @@ struct tc_cls_bpf_offload {
 	struct bpf_prog *filter;
 	const char *name;
 	bool exts_integrated;
+	u32 gen_flags;
 };
 
 #endif
diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
index f4297c8a42fe..93a86edf3bd8 100644
--- a/include/uapi/linux/pkt_cls.h
+++ b/include/uapi/linux/pkt_cls.h
@@ -395,6 +395,7 @@ enum {
 	TCA_BPF_FD,
 	TCA_BPF_NAME,
 	TCA_BPF_FLAGS,
+	TCA_BPF_GEN_TCA_FLAGS,
 	__TCA_BPF_MAX,
 };
 
diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index b7c4c6dd6ad6..9f1bc37dcbbc 100644
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
+	[TCA_BPF_GEN_TCA_FLAGS]	= { .type = NLA_U32 },
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
-		if (tc_should_offload(dev, 0)) {
+		if (tc_should_offload(dev, prog->gen_flags)) {
 			cmd = TC_CLSBPF_REPLACE;
 		} else {
 			obj = oldprog;
 			cmd = TC_CLSBPF_DESTROY;
 		}
 	} else {
-		if (!tc_should_offload(dev, 0))
+		if (!tc_should_offload(dev, prog->gen_flags))
 			return;
 		cmd = TC_CLSBPF_ADD;
 	}
@@ -378,6 +383,7 @@ static int cls_bpf_modify_existing(struct net *net, struct tcf_proto *tp,
 {
 	bool is_bpf, is_ebpf, have_exts = false;
 	struct tcf_exts exts;
+	u32 gen_flags = 0;
 	int ret;
 
 	is_bpf = tb[TCA_BPF_OPS_LEN] && tb[TCA_BPF_OPS];
@@ -400,8 +406,11 @@ static int cls_bpf_modify_existing(struct net *net, struct tcf_proto *tp,
 
 		have_exts = bpf_flags & TCA_BPF_FLAG_ACT_DIRECT;
 	}
+	if (tb[TCA_BPF_GEN_TCA_FLAGS])
+		gen_flags = nla_get_u32(tb[TCA_BPF_GEN_TCA_FLAGS]);
 
 	prog->exts_integrated = have_exts;
+	prog->gen_flags = gen_flags & CLS_BPF_SUPPORTED_GEN_FLAGS;
 
 	ret = is_bpf ? cls_bpf_prog_from_ops(tb, prog) :
 		       cls_bpf_prog_from_efd(tb, prog, tp);
@@ -568,6 +577,9 @@ static int cls_bpf_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 		bpf_flags |= TCA_BPF_FLAG_ACT_DIRECT;
 	if (bpf_flags && nla_put_u32(skb, TCA_BPF_FLAGS, bpf_flags))
 		goto nla_put_failure;
+	if (prog->gen_flags &&
+	    nla_put_u32(skb, TCA_BPF_GEN_TCA_FLAGS, prog->gen_flags))
+		goto nla_put_failure;
 
 	nla_nest_end(skb, nest);
 
-- 
1.9.1

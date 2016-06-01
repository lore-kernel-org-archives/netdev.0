From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [RFC 04/12] net: cls_bpf: add support for marking filters as hardware-only
Date: Wed,  1 Jun 2016 17:50:06 +0100
Message-ID: <1464799814-4453-5-git-send-email-jakub.kicinski@netronome.com>
References: <1464799814-4453-1-git-send-email-jakub.kicinski@netronome.com>
Cc: ast@kernel.org, daniel@iogearbox.net,
	dinan.gunawardena@netronome.com,
	Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:37733 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932307AbcFAQvr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 12:51:47 -0400
Received: by mail-wm0-f50.google.com with SMTP id z87so37552725wmh.0
        for <netdev@vger.kernel.org>; Wed, 01 Jun 2016 09:51:46 -0700 (PDT)
In-Reply-To: <1464799814-4453-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add cls_bpf support for the TCA_CLS_FLAGS_SKIP_SW flag.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Dinan Gunawardena <dgunawardena@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 net/sched/cls_bpf.c | 39 +++++++++++++++++++++++++++++----------
 1 file changed, 29 insertions(+), 10 deletions(-)

diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index 9f1bc37dcbbc..1083910cebaf 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -28,7 +28,7 @@ MODULE_DESCRIPTION("TC BPF based classifier");
 
 #define CLS_BPF_NAME_LEN	256
 #define CLS_BPF_SUPPORTED_GEN_FLAGS		\
-	TCA_CLS_FLAGS_SKIP_HW
+	(TCA_CLS_FLAGS_SKIP_HW | TCA_CLS_FLAGS_SKIP_SW)
 
 struct cls_bpf_head {
 	struct list_head plist;
@@ -98,7 +98,9 @@ static int cls_bpf_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 
 		qdisc_skb_cb(skb)->tc_classid = prog->res.classid;
 
-		if (at_ingress) {
+		if (tc_skip_sw(prog->gen_flags)) {
+			filter_res = 0;
+		} else if (at_ingress) {
 			/* It is safe to push/pull even if skb_shared() */
 			__skb_push(skb, skb->mac_len);
 			bpf_compute_data_end(skb);
@@ -166,32 +168,42 @@ static int cls_bpf_offload_cmd(struct tcf_proto *tp, struct cls_bpf_prog *prog,
 					     tp->protocol, &offload);
 }
 
-static void cls_bpf_offload(struct tcf_proto *tp, struct cls_bpf_prog *prog,
-			    struct cls_bpf_prog *oldprog)
+static int cls_bpf_offload(struct tcf_proto *tp, struct cls_bpf_prog *prog,
+			   struct cls_bpf_prog *oldprog)
 {
 	struct net_device *dev = tp->q->dev_queue->dev;
 	struct cls_bpf_prog *obj = prog;
 	enum tc_clsbpf_command cmd;
+	bool skip_sw;
+	int ret;
+
+	skip_sw = tc_skip_sw(prog->gen_flags) ||
+		(oldprog && tc_skip_sw(oldprog->gen_flags));
 
 	if (oldprog && oldprog->offloaded) {
 		if (tc_should_offload(dev, prog->gen_flags)) {
 			cmd = TC_CLSBPF_REPLACE;
-		} else {
+		} else if (!tc_skip_sw(prog->gen_flags)) {
 			obj = oldprog;
 			cmd = TC_CLSBPF_DESTROY;
+		} else {
+			return -EINVAL;
 		}
 	} else {
 		if (!tc_should_offload(dev, prog->gen_flags))
-			return;
+			return skip_sw ? -EINVAL : 0;;
 		cmd = TC_CLSBPF_ADD;
 	}
 
-	if (cls_bpf_offload_cmd(tp, obj, cmd))
-		return;
+	ret = cls_bpf_offload_cmd(tp, obj, cmd);
+	if (ret)
+		return skip_sw ? ret : 0;
 
 	obj->offloaded = true;
 	if (oldprog)
 		oldprog->offloaded = false;
+
+	return 0;
 }
 
 static void cls_bpf_stop_offload(struct tcf_proto *tp,
@@ -406,8 +418,11 @@ static int cls_bpf_modify_existing(struct net *net, struct tcf_proto *tp,
 
 		have_exts = bpf_flags & TCA_BPF_FLAG_ACT_DIRECT;
 	}
-	if (tb[TCA_BPF_GEN_TCA_FLAGS])
+	if (tb[TCA_BPF_GEN_TCA_FLAGS]) {
 		gen_flags = nla_get_u32(tb[TCA_BPF_GEN_TCA_FLAGS]);
+		if (!tc_flags_valid(gen_flags))
+			return -EINVAL;
+	}
 
 	prog->exts_integrated = have_exts;
 	prog->gen_flags = gen_flags & CLS_BPF_SUPPORTED_GEN_FLAGS;
@@ -493,7 +508,11 @@ static int cls_bpf_change(struct net *net, struct sk_buff *in_skb,
 	if (ret < 0)
 		goto errout;
 
-	cls_bpf_offload(tp, prog, oldprog);
+	ret = cls_bpf_offload(tp, prog, oldprog);
+	if (ret) {
+		cls_bpf_delete_prog(tp, prog);
+		return ret;
+	}
 
 	if (oldprog) {
 		list_replace_rcu(&oldprog->link, &prog->link);
-- 
1.9.1

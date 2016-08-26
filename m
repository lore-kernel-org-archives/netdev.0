From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [RFCv2 04/16] net: cls_bpf: add support for marking filters as hardware-only
Date: Fri, 26 Aug 2016 19:06:03 +0100
Message-ID: <1472234775-29453-5-git-send-email-jakub.kicinski@netronome.com>
References: <1472234775-29453-1-git-send-email-jakub.kicinski@netronome.com>
Cc: ast@kernel.org, daniel@iogearbox.net,
        dinan.gunawardena@netronome.com, jiri@resnulli.us,
        john.fastabend@gmail.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:37155 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753702AbcHZSNY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2016 14:13:24 -0400
Received: by mail-wm0-f47.google.com with SMTP id i5so3538511wmg.0
        for <netdev@vger.kernel.org>; Fri, 26 Aug 2016 11:13:23 -0700 (PDT)
In-Reply-To: <1472234775-29453-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add cls_bpf support for the TCA_CLS_FLAGS_SKIP_SW flag.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 net/sched/cls_bpf.c | 34 +++++++++++++++++++++++++---------
 1 file changed, 25 insertions(+), 9 deletions(-)

diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index 1999f44075f0..630f296f5a90 100644
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
+			filter_res = prog->exts_integrated ? TC_ACT_UNSPEC : 0;
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
 		if (tc_should_offload(dev, tp, prog->gen_flags)) {
 			cmd = TC_CLSBPF_REPLACE;
-		} else {
+		} else if (!tc_skip_sw(prog->gen_flags)) {
 			obj = oldprog;
 			cmd = TC_CLSBPF_DESTROY;
+		} else {
+			return -EINVAL;
 		}
 	} else {
 		if (!tc_should_offload(dev, tp, prog->gen_flags))
-			return;
+			return skip_sw ? -EINVAL : 0;
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
@@ -498,7 +510,11 @@ static int cls_bpf_change(struct net *net, struct sk_buff *in_skb,
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

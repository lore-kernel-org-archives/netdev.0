From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCHv5 net-next 03/15] net: cls_bpf: add support for marking filters as hardware-only
Date: Fri, 16 Sep 2016 10:36:50 +0100
Message-ID: <1474018622-10653-4-git-send-email-jakub.kicinski@netronome.com>
References: <1474018622-10653-1-git-send-email-jakub.kicinski@netronome.com>
Cc: ast@kernel.org, daniel@iogearbox.net,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:38222 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754368AbcIPJhj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2016 05:37:39 -0400
Received: by mail-wm0-f54.google.com with SMTP id 1so30498867wmz.1
        for <netdev@vger.kernel.org>; Fri, 16 Sep 2016 02:37:38 -0700 (PDT)
In-Reply-To: <1474018622-10653-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add cls_bpf support for the TCA_CLS_FLAGS_SKIP_SW flag.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 net/sched/cls_bpf.c | 34 +++++++++++++++++++++++++---------
 1 file changed, 25 insertions(+), 9 deletions(-)

diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index 46af423a8a8f..18f9869cd4da 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -28,7 +28,7 @@ MODULE_DESCRIPTION("TC BPF based classifier");
 
 #define CLS_BPF_NAME_LEN	256
 #define CLS_BPF_SUPPORTED_GEN_FLAGS		\
-	TCA_CLS_FLAGS_SKIP_HW
+	(TCA_CLS_FLAGS_SKIP_HW | TCA_CLS_FLAGS_SKIP_SW)
 
 struct cls_bpf_head {
 	struct list_head plist;
@@ -95,7 +95,9 @@ static int cls_bpf_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 
 		qdisc_skb_cb(skb)->tc_classid = prog->res.classid;
 
-		if (at_ingress) {
+		if (tc_skip_sw(prog->gen_flags)) {
+			filter_res = prog->exts_integrated ? TC_ACT_UNSPEC : 0;
+		} else if (at_ingress) {
 			/* It is safe to push/pull even if skb_shared() */
 			__skb_push(skb, skb->mac_len);
 			bpf_compute_data_end(skb);
@@ -163,32 +165,42 @@ static int cls_bpf_offload_cmd(struct tcf_proto *tp, struct cls_bpf_prog *prog,
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
@@ -496,7 +508,11 @@ static int cls_bpf_change(struct net *net, struct sk_buff *in_skb,
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

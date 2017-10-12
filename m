From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 19/34] net: sched: cls_bpf: call block callbacks for offload
Date: Thu, 12 Oct 2017 19:18:08 +0200
Message-ID: <20171012171823.1431-20-jiri@resnulli.us>
References: <20171012171823.1431-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        michael.chan@broadcom.com, ganeshgr@chelsio.com,
        jeffrey.t.kirsher@intel.com, saeedm@mellanox.com,
        matanb@mellanox.com, leonro@mellanox.com, idosch@mellanox.com,
        jakub.kicinski@netronome.com, ast@kernel.org, daniel@iogearbox.net,
        simon.horman@netronome.com, pieter.jansenvanvuuren@netronome.com,
        john.hurley@netronome.com, edumazet@google.com, dsahern@gmail.com,
        alexander.h.duyck@intel.com, john.fastabend@gmail.com,
        willemb@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:48723 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755144AbdJLRSn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 13:18:43 -0400
Received: by mail-wm0-f68.google.com with SMTP id i124so14949846wmf.3
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 10:18:42 -0700 (PDT)
In-Reply-To: <20171012171823.1431-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Use the newly introduced callbacks infrastructure and call block
callbacks alongside with the existing per-netdev ndo_setup_tc.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/sched/cls_bpf.c | 40 ++++++++++++++++++++++++++++++++--------
 1 file changed, 32 insertions(+), 8 deletions(-)

diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index 6c6b21f..e379fdf 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -147,7 +147,10 @@ static bool cls_bpf_is_ebpf(const struct cls_bpf_prog *prog)
 static int cls_bpf_offload_cmd(struct tcf_proto *tp, struct cls_bpf_prog *prog,
 			       enum tc_clsbpf_command cmd)
 {
+	bool addorrep = cmd == TC_CLSBPF_ADD || cmd == TC_CLSBPF_REPLACE;
 	struct net_device *dev = tp->q->dev_queue->dev;
+	struct tcf_block *block = tp->chain->block;
+	bool skip_sw = tc_skip_sw(prog->gen_flags);
 	struct tc_cls_bpf_offload cls_bpf = {};
 	int err;
 
@@ -159,17 +162,38 @@ static int cls_bpf_offload_cmd(struct tcf_proto *tp, struct cls_bpf_prog *prog,
 	cls_bpf.exts_integrated = prog->exts_integrated;
 	cls_bpf.gen_flags = prog->gen_flags;
 
-	err = dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSBPF, &cls_bpf);
-	if (!err && (cmd == TC_CLSBPF_ADD || cmd == TC_CLSBPF_REPLACE))
-		prog->gen_flags |= TCA_CLS_FLAGS_IN_HW;
+	if (tc_can_offload(dev)) {
+		err = dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSBPF,
+						    &cls_bpf);
+		if (addorrep) {
+			if (err) {
+				if (skip_sw)
+					return err;
+			} else {
+				prog->gen_flags |= TCA_CLS_FLAGS_IN_HW;
+			}
+		}
+	}
+
+	err = tc_setup_cb_call(block, NULL, TC_SETUP_CLSBPF, &cls_bpf, skip_sw);
+	if (addorrep) {
+		if (err < 0) {
+			cls_bpf_offload_cmd(tp, prog, TC_CLSBPF_DESTROY);
+			return err;
+		} else if (err > 0) {
+			prog->gen_flags |= TCA_CLS_FLAGS_IN_HW;
+		}
+	}
 
-	return err;
+	if (addorrep && skip_sw && !(prog->gen_flags && TCA_CLS_FLAGS_IN_HW))
+		return -EINVAL;
+
+	return 0;
 }
 
 static int cls_bpf_offload(struct tcf_proto *tp, struct cls_bpf_prog *prog,
 			   struct cls_bpf_prog *oldprog)
 {
-	struct net_device *dev = tp->q->dev_queue->dev;
 	struct cls_bpf_prog *obj = prog;
 	enum tc_clsbpf_command cmd;
 	bool skip_sw;
@@ -179,7 +203,7 @@ static int cls_bpf_offload(struct tcf_proto *tp, struct cls_bpf_prog *prog,
 		(oldprog && tc_skip_sw(oldprog->gen_flags));
 
 	if (oldprog && oldprog->offloaded) {
-		if (tc_should_offload(dev, prog->gen_flags)) {
+		if (!tc_skip_hw(prog->gen_flags)) {
 			cmd = TC_CLSBPF_REPLACE;
 		} else if (!tc_skip_sw(prog->gen_flags)) {
 			obj = oldprog;
@@ -188,14 +212,14 @@ static int cls_bpf_offload(struct tcf_proto *tp, struct cls_bpf_prog *prog,
 			return -EINVAL;
 		}
 	} else {
-		if (!tc_should_offload(dev, prog->gen_flags))
+		if (tc_skip_hw(prog->gen_flags))
 			return skip_sw ? -EINVAL : 0;
 		cmd = TC_CLSBPF_ADD;
 	}
 
 	ret = cls_bpf_offload_cmd(tp, obj, cmd);
 	if (ret)
-		return skip_sw ? ret : 0;
+		return ret;
 
 	obj->offloaded = true;
 	if (oldprog)
-- 
2.9.5

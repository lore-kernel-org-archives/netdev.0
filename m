From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCHv6 net-next 01/15] net: cls_bpf: add hardware offload
Date: Sun, 18 Sep 2016 16:09:11 +0100
Message-ID: <1474211365-20088-2-git-send-email-jakub.kicinski@netronome.com>
References: <1474211365-20088-1-git-send-email-jakub.kicinski@netronome.com>
Cc: ast@kernel.org, daniel@iogearbox.net,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:35090 "EHLO
        mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752725AbcIRPJr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2016 11:09:47 -0400
Received: by mail-wm0-f43.google.com with SMTP id l132so112194549wmf.0
        for <netdev@vger.kernel.org>; Sun, 18 Sep 2016 08:09:47 -0700 (PDT)
In-Reply-To: <1474211365-20088-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds hardware offload capability to cls_bpf classifier,
similar to what have been done with U32 and flower.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
v3:
 - s/filter/prog/ in struct tc_cls_bpf_offload.
v2:
 - drop unnecessary WARN_ON;
 - reformat error handling a bit.
---
 include/linux/netdevice.h |  2 ++
 include/net/pkt_cls.h     | 14 ++++++++++
 net/sched/cls_bpf.c       | 70 +++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 86 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 2095b6ab3661..3c50db29a114 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -789,6 +789,7 @@ enum {
 	TC_SETUP_CLSU32,
 	TC_SETUP_CLSFLOWER,
 	TC_SETUP_MATCHALL,
+	TC_SETUP_CLSBPF,
 };
 
 struct tc_cls_u32_offload;
@@ -800,6 +801,7 @@ struct tc_to_netdev {
 		struct tc_cls_u32_offload *cls_u32;
 		struct tc_cls_flower_offload *cls_flower;
 		struct tc_cls_matchall_offload *cls_mall;
+		struct tc_cls_bpf_offload *cls_bpf;
 	};
 };
 
diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index a459be5fe1c2..41e8071dff87 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -486,4 +486,18 @@ struct tc_cls_matchall_offload {
 	unsigned long cookie;
 };
 
+enum tc_clsbpf_command {
+	TC_CLSBPF_ADD,
+	TC_CLSBPF_REPLACE,
+	TC_CLSBPF_DESTROY,
+};
+
+struct tc_cls_bpf_offload {
+	enum tc_clsbpf_command command;
+	struct tcf_exts *exts;
+	struct bpf_prog *prog;
+	const char *name;
+	bool exts_integrated;
+};
+
 #endif
diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index 1d92d4d3f222..3ca9502a881c 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -39,6 +39,7 @@ struct cls_bpf_prog {
 	struct list_head link;
 	struct tcf_result res;
 	bool exts_integrated;
+	bool offloaded;
 	struct tcf_exts exts;
 	u32 handle;
 	union {
@@ -137,6 +138,71 @@ static bool cls_bpf_is_ebpf(const struct cls_bpf_prog *prog)
 	return !prog->bpf_ops;
 }
 
+static int cls_bpf_offload_cmd(struct tcf_proto *tp, struct cls_bpf_prog *prog,
+			       enum tc_clsbpf_command cmd)
+{
+	struct net_device *dev = tp->q->dev_queue->dev;
+	struct tc_cls_bpf_offload bpf_offload = {};
+	struct tc_to_netdev offload;
+
+	offload.type = TC_SETUP_CLSBPF;
+	offload.cls_bpf = &bpf_offload;
+
+	bpf_offload.command = cmd;
+	bpf_offload.exts = &prog->exts;
+	bpf_offload.prog = prog->filter;
+	bpf_offload.name = prog->bpf_name;
+	bpf_offload.exts_integrated = prog->exts_integrated;
+
+	return dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle,
+					     tp->protocol, &offload);
+}
+
+static void cls_bpf_offload(struct tcf_proto *tp, struct cls_bpf_prog *prog,
+			    struct cls_bpf_prog *oldprog)
+{
+	struct net_device *dev = tp->q->dev_queue->dev;
+	struct cls_bpf_prog *obj = prog;
+	enum tc_clsbpf_command cmd;
+
+	if (oldprog && oldprog->offloaded) {
+		if (tc_should_offload(dev, tp, 0)) {
+			cmd = TC_CLSBPF_REPLACE;
+		} else {
+			obj = oldprog;
+			cmd = TC_CLSBPF_DESTROY;
+		}
+	} else {
+		if (!tc_should_offload(dev, tp, 0))
+			return;
+		cmd = TC_CLSBPF_ADD;
+	}
+
+	if (cls_bpf_offload_cmd(tp, obj, cmd))
+		return;
+
+	obj->offloaded = true;
+	if (oldprog)
+		oldprog->offloaded = false;
+}
+
+static void cls_bpf_stop_offload(struct tcf_proto *tp,
+				 struct cls_bpf_prog *prog)
+{
+	int err;
+
+	if (!prog->offloaded)
+		return;
+
+	err = cls_bpf_offload_cmd(tp, prog, TC_CLSBPF_DESTROY);
+	if (err) {
+		pr_err("Stopping hardware offload failed: %d\n", err);
+		return;
+	}
+
+	prog->offloaded = false;
+}
+
 static int cls_bpf_init(struct tcf_proto *tp)
 {
 	struct cls_bpf_head *head;
@@ -176,6 +242,7 @@ static int cls_bpf_delete(struct tcf_proto *tp, unsigned long arg)
 {
 	struct cls_bpf_prog *prog = (struct cls_bpf_prog *) arg;
 
+	cls_bpf_stop_offload(tp, prog);
 	list_del_rcu(&prog->link);
 	tcf_unbind_filter(tp, &prog->res);
 	call_rcu(&prog->rcu, __cls_bpf_delete_prog);
@@ -192,6 +259,7 @@ static bool cls_bpf_destroy(struct tcf_proto *tp, bool force)
 		return false;
 
 	list_for_each_entry_safe(prog, tmp, &head->plist, link) {
+		cls_bpf_stop_offload(tp, prog);
 		list_del_rcu(&prog->link);
 		tcf_unbind_filter(tp, &prog->res);
 		call_rcu(&prog->rcu, __cls_bpf_delete_prog);
@@ -413,6 +481,8 @@ static int cls_bpf_change(struct net *net, struct sk_buff *in_skb,
 	if (ret < 0)
 		goto errout;
 
+	cls_bpf_offload(tp, prog, oldprog);
+
 	if (oldprog) {
 		list_replace_rcu(&oldprog->link, &prog->link);
 		tcf_unbind_filter(tp, &oldprog->res);
-- 
1.9.1

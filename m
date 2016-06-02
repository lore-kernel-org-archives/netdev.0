From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [RFC 02/12] net: cls_bpf: add hardware offload
Date: Thu, 2 Jun 2016 09:17:15 +0200
Message-ID: <20160602071715.GB1987@nanopsycho>
References: <1464799814-4453-1-git-send-email-jakub.kicinski@netronome.com>
 <1464799814-4453-3-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, ast@kernel.org, daniel@iogearbox.net,
	dinan.gunawardena@netronome.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35768 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750744AbcFBHRS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2016 03:17:18 -0400
Received: by mail-wm0-f68.google.com with SMTP id e3so13114920wme.2
        for <netdev@vger.kernel.org>; Thu, 02 Jun 2016 00:17:17 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1464799814-4453-3-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Jun 01, 2016 at 06:50:04PM CEST, jakub.kicinski@netronome.com wrote:
>This patch adds hardware offload capability to cls_bpf classifier,
>similar to what have been done with U32 and flower.
>
>Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
>Reviewed-by: Dinan Gunawardena <dgunawardena@netronome.com>
>Reviewed-by: Simon Horman <simon.horman@netronome.com>
>---
> include/linux/netdevice.h |  2 ++
> include/net/pkt_cls.h     | 14 ++++++++++
> net/sched/cls_bpf.c       | 71 +++++++++++++++++++++++++++++++++++++++++++++++
> 3 files changed, 87 insertions(+)
>
>diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>index f45929ce8157..6c8364b8aae9 100644
>--- a/include/linux/netdevice.h
>+++ b/include/linux/netdevice.h
>@@ -785,6 +785,7 @@ enum {
> 	TC_SETUP_MQPRIO,
> 	TC_SETUP_CLSU32,
> 	TC_SETUP_CLSFLOWER,
>+	TC_SETUP_CLSBPF,
> };
> 
> struct tc_cls_u32_offload;
>@@ -795,6 +796,7 @@ struct tc_to_netdev {
> 		u8 tc;
> 		struct tc_cls_u32_offload *cls_u32;
> 		struct tc_cls_flower_offload *cls_flower;
>+		struct tc_cls_bpf_offload *cls_bpf;
> 	};
> };
> 
>diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
>index 0f7efa88f210..10b7e8cdc98c 100644
>--- a/include/net/pkt_cls.h
>+++ b/include/net/pkt_cls.h
>@@ -438,4 +438,18 @@ struct tc_cls_flower_offload {
> 	struct tcf_exts *exts;
> };
> 
>+enum tc_clsbpf_command {
>+	TC_CLSBPF_ADD,
>+	TC_CLSBPF_REPLACE,
>+	TC_CLSBPF_DESTROY,
>+};
>+
>+struct tc_cls_bpf_offload {
>+	enum tc_clsbpf_command command;
>+	struct tcf_exts *exts;
>+	struct bpf_prog *filter;
>+	const char *name;
>+	bool exts_integrated;
>+};
>+
> #endif
>diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
>index 7b342c779da7..b7c4c6dd6ad6 100644
>--- a/net/sched/cls_bpf.c
>+++ b/net/sched/cls_bpf.c
>@@ -39,6 +39,7 @@ struct cls_bpf_prog {
> 	struct list_head link;
> 	struct tcf_result res;
> 	bool exts_integrated;
>+	bool offloaded;
> 	struct tcf_exts exts;
> 	u32 handle;
> 	union {
>@@ -140,6 +141,72 @@ static bool cls_bpf_is_ebpf(const struct cls_bpf_prog *prog)
> 	return !prog->bpf_ops;
> }
> 
>+static int cls_bpf_offload_cmd(struct tcf_proto *tp, struct cls_bpf_prog *prog,
>+			       enum tc_clsbpf_command cmd)
>+{
>+	struct net_device *dev = tp->q->dev_queue->dev;
>+	struct tc_cls_bpf_offload bpf_offload = {};
>+	struct tc_to_netdev offload;
>+
>+	offload.type = TC_SETUP_CLSBPF;
>+	offload.cls_bpf = &bpf_offload;
>+
>+	bpf_offload.command = cmd;
>+	bpf_offload.exts = &prog->exts;
>+	bpf_offload.filter = prog->filter;
>+	bpf_offload.name = prog->bpf_name;
>+	bpf_offload.exts_integrated = prog->exts_integrated;
>+
>+	return dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle,
>+					     tp->protocol, &offload);
>+}
>+
>+static void cls_bpf_offload(struct tcf_proto *tp, struct cls_bpf_prog *prog,
>+			    struct cls_bpf_prog *oldprog)
>+{
>+	struct net_device *dev = tp->q->dev_queue->dev;
>+	struct cls_bpf_prog *obj = prog;
>+	enum tc_clsbpf_command cmd;
>+
>+	if (oldprog && oldprog->offloaded) {
>+		if (tc_should_offload(dev, 0)) {
>+			cmd = TC_CLSBPF_REPLACE;
>+		} else {
>+			obj = oldprog;
>+			cmd = TC_CLSBPF_DESTROY;
>+		}
>+	} else {
>+		if (!tc_should_offload(dev, 0))
>+			return;
>+		cmd = TC_CLSBPF_ADD;
>+	}
>+
>+	if (cls_bpf_offload_cmd(tp, obj, cmd))
>+		return;
>+
>+	obj->offloaded = true;
>+	if (oldprog)
>+		oldprog->offloaded = false;
>+}
>+
>+static void cls_bpf_stop_offload(struct tcf_proto *tp,
>+				 struct cls_bpf_prog *prog)
>+{
>+	struct net_device *dev = tp->q->dev_queue->dev;
>+
>+	if (!prog->offloaded)
>+		return;
>+	if (WARN_ON(!tc_should_offload(dev, 0)))
>+		return;
>+
>+	if (cls_bpf_offload_cmd(tp, prog, TC_CLSBPF_DESTROY)) {

Please do:
err = 
if (err)



>+		pr_err("Stopping hardware offload failed!\n");
>+		return;
>+	}
>+
>+	prog->offloaded = false;
>+}
>+
> static int cls_bpf_init(struct tcf_proto *tp)
> {
> 	struct cls_bpf_head *head;
>@@ -179,6 +246,7 @@ static int cls_bpf_delete(struct tcf_proto *tp, unsigned long arg)
> {
> 	struct cls_bpf_prog *prog = (struct cls_bpf_prog *) arg;
> 
>+	cls_bpf_stop_offload(tp, prog);
> 	list_del_rcu(&prog->link);
> 	tcf_unbind_filter(tp, &prog->res);
> 	call_rcu(&prog->rcu, __cls_bpf_delete_prog);
>@@ -195,6 +263,7 @@ static bool cls_bpf_destroy(struct tcf_proto *tp, bool force)
> 		return false;
> 
> 	list_for_each_entry_safe(prog, tmp, &head->plist, link) {
>+		cls_bpf_stop_offload(tp, prog);
> 		list_del_rcu(&prog->link);
> 		tcf_unbind_filter(tp, &prog->res);
> 		call_rcu(&prog->rcu, __cls_bpf_delete_prog);
>@@ -415,6 +484,8 @@ static int cls_bpf_change(struct net *net, struct sk_buff *in_skb,
> 	if (ret < 0)
> 		goto errout;
> 
>+	cls_bpf_offload(tp, prog, oldprog);
>+
> 	if (oldprog) {
> 		list_replace_rcu(&oldprog->link, &prog->link);
> 		tcf_unbind_filter(tp, &oldprog->res);
>-- 
>1.9.1
>

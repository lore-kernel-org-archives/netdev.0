From: Amir Vadai <amir@vadai.me>
Subject: [RFC net-next 3/9] net/act: Offload support by tc actions
Date: Mon,  1 Feb 2016 08:34:39 +0000
Message-ID: <1454315685-32202-4-git-send-email-amir@vadai.me>
References: <1454315685-32202-1-git-send-email-amir@vadai.me>
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Amir Vadai <amir@vadai.me>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:32888 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752004AbcBAIgn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Feb 2016 03:36:43 -0500
In-Reply-To: <1454315685-32202-1-git-send-email-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to support hardware offloading, an action should implment the
new offload_init() callback.
During filter initialization, offload_init() will be called to add
the action description to the actions object that will be used by the
filter to configure the hardware.

Signed-off-by: Amir Vadai <amir@vadai.me>
---
 include/net/act_api.h |  3 +++
 include/net/pkt_cls.h |  2 ++
 net/sched/cls_api.c   | 27 +++++++++++++++++++++++++++
 3 files changed, 32 insertions(+)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index 9d446f13..fcabe93 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -7,6 +7,7 @@
 
 #include <net/sch_generic.h>
 #include <net/pkt_sched.h>
+#include <net/switchdev.h>
 
 struct tcf_common {
 	struct hlist_node		tcfc_head;
@@ -108,6 +109,8 @@ struct tc_action_ops {
 			struct nlattr *est, struct tc_action *act, int ovr,
 			int bind);
 	int     (*walk)(struct sk_buff *, struct netlink_callback *, int, struct tc_action *);
+	int	(*offload_init)(struct tc_action *,
+				struct switchdev_obj_port_flow_act *);
 };
 
 int tcf_hash_search(struct tc_action *a, u32 index);
diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index bc49967..7eb8ee9 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -130,6 +130,8 @@ tcf_exts_exec(struct sk_buff *skb, struct tcf_exts *exts,
 	return 0;
 }
 
+int tcf_exts_offload_init(struct tcf_exts *e,
+			  struct switchdev_obj_port_flow_act *actions);
 int tcf_exts_validate(struct net *net, struct tcf_proto *tp,
 		      struct nlattr **tb, struct nlattr *rate_tlv,
 		      struct tcf_exts *exts, bool ovr);
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index a75864d..d675c31 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -29,6 +29,7 @@
 #include <net/netlink.h>
 #include <net/pkt_sched.h>
 #include <net/pkt_cls.h>
+#include <net/switchdev.h>
 
 /* The list of all installed classifier types */
 static LIST_HEAD(tcf_proto_base);
@@ -551,6 +552,32 @@ int tcf_exts_validate(struct net *net, struct tcf_proto *tp, struct nlattr **tb,
 }
 EXPORT_SYMBOL(tcf_exts_validate);
 
+int tcf_exts_offload_init(struct tcf_exts *e,
+			  struct switchdev_obj_port_flow_act *actions)
+{
+#ifdef CONFIG_NET_CLS_ACT
+	struct tc_action *act;
+	int err = 0;
+
+	list_for_each_entry(act, &e->actions, list) {
+		if (!act->ops->offload_init) {
+			pr_err("Action %s doesn't have offload support\n",
+			       act->ops->kind);
+			err = -EINVAL;
+			break;
+		}
+		err = act->ops->offload_init(act, actions);
+		if (err)
+			break;
+	}
+
+	return err;
+#else
+	return -EOPNOTSUPP;
+#endif
+}
+EXPORT_SYMBOL(tcf_exts_offload_init);
+
 void tcf_exts_change(struct tcf_proto *tp, struct tcf_exts *dst,
 		     struct tcf_exts *src)
 {
-- 
2.7.0

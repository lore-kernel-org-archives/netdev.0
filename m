From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 10/10] net: sched: add termination action to allow goto chain
Date: Tue, 16 May 2017 19:28:02 +0200
Message-ID: <20170516172802.1317-11-jiri@resnulli.us>
References: <20170516172802.1317-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        dsa@cumulusnetworks.com, edumazet@google.com,
        stephen@networkplumber.org, daniel@iogearbox.net,
        alexander.h.duyck@intel.com, simon.horman@netronome.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:34452 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753400AbdEPR2U (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 13:28:20 -0400
Received: by mail-wr0-f194.google.com with SMTP id 6so14901106wrb.1
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 10:28:19 -0700 (PDT)
In-Reply-To: <20170516172802.1317-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Introduce new type of termination action called "goto_chain". This allows
user to specify a chain to be processed. This action type is
then processed as a return value in tcf_classify loop in similar
way as "reclassify" is, only it does not reset to the first filter
in chain but rather reset to the first filter of the desired chain.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/act_api.h        |  1 +
 include/net/sch_generic.h    |  9 +++++++--
 include/uapi/linux/pkt_cls.h |  1 +
 net/sched/act_api.c          | 40 ++++++++++++++++++++++++++++++++++++++++
 net/sched/cls_api.c          |  8 ++++++--
 5 files changed, 55 insertions(+), 4 deletions(-)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index b22c6f3..26ffd83 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -42,6 +42,7 @@ struct tc_action {
 	struct gnet_stats_basic_cpu __percpu *cpu_bstats;
 	struct gnet_stats_queue __percpu *cpu_qstats;
 	struct tc_cookie	*act_cookie;
+	struct tcf_chain	*goto_chain;
 };
 #define tcf_head	common.tcfa_head
 #define tcf_index	common.tcfa_index
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 569b565..3688501 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -193,8 +193,13 @@ struct Qdisc_ops {
 
 
 struct tcf_result {
-	unsigned long	class;
-	u32		classid;
+	union {
+		struct {
+			unsigned long	class;
+			u32		classid;
+		};
+		const struct tcf_proto *goto_tp;
+	};
 };
 
 struct tcf_proto_ops {
diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
index d613be3..1b9aa9e 100644
--- a/include/uapi/linux/pkt_cls.h
+++ b/include/uapi/linux/pkt_cls.h
@@ -51,6 +51,7 @@ enum {
 	(((combined) & (~TC_ACT_EXT_VAL_MASK)) == opcode)
 
 #define TC_ACT_JUMP __TC_ACT_EXT(1)
+#define TC_ACT_GOTO_CHAIN __TC_ACT_EXT(2)
 
 /* Action type identifiers*/
 enum {
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index e389eb4..0ecf2a8 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -28,6 +28,31 @@
 #include <net/act_api.h>
 #include <net/netlink.h>
 
+static int tcf_action_goto_chain_init(struct tc_action *a, struct tcf_proto *tp)
+{
+	u32 chain_index = a->tcfa_action & TC_ACT_EXT_VAL_MASK;
+
+	if (!tp)
+		return -EINVAL;
+	a->goto_chain = tcf_chain_get(tp->chain->block, chain_index);
+	if (!a->goto_chain)
+		return -ENOMEM;
+	return 0;
+}
+
+static void tcf_action_goto_chain_fini(struct tc_action *a)
+{
+	tcf_chain_put(a->goto_chain);
+}
+
+static void tcf_action_goto_chain_exec(const struct tc_action *a,
+				       struct tcf_result *res)
+{
+	const struct tcf_chain *chain = a->goto_chain;
+
+	res->goto_tp = rcu_dereference_bh(chain->filter_chain);
+}
+
 static void free_tcf(struct rcu_head *head)
 {
 	struct tc_action *p = container_of(head, struct tc_action, tcfa_rcu);
@@ -39,6 +64,8 @@ static void free_tcf(struct rcu_head *head)
 		kfree(p->act_cookie->data);
 		kfree(p->act_cookie);
 	}
+	if (p->goto_chain)
+		tcf_action_goto_chain_fini(p);
 
 	kfree(p);
 }
@@ -465,6 +492,8 @@ int tcf_action_exec(struct sk_buff *skb, struct tc_action **actions,
 				else /* faulty graph, stop pipeline */
 					return TC_ACT_OK;
 			}
+		} else if (TC_ACT_EXT_CMP(ret, TC_ACT_GOTO_CHAIN)) {
+			tcf_action_goto_chain_exec(a, res);
 		}
 
 		if (ret != TC_ACT_PIPE)
@@ -657,6 +686,17 @@ struct tc_action *tcf_action_init_1(struct net *net, struct tcf_proto *tp,
 	if (err != ACT_P_CREATED)
 		module_put(a_o->owner);
 
+	if (TC_ACT_EXT_CMP(a->tcfa_action, TC_ACT_GOTO_CHAIN)) {
+		err = tcf_action_goto_chain_init(a, tp);
+		if (err) {
+			LIST_HEAD(actions);
+
+			list_add_tail(&a->list, &actions);
+			tcf_action_destroy(&actions, bind);
+			return ERR_PTR(err);
+		}
+	}
+
 	return a;
 
 err_mod:
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 1112a2b..f8f2ca6 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -304,10 +304,14 @@ int tcf_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 			continue;
 
 		err = tp->classify(skb, tp, res);
-		if (unlikely(err == TC_ACT_RECLASSIFY && !compat_mode))
+		if (unlikely(err == TC_ACT_RECLASSIFY && !compat_mode)) {
 			goto reset;
-		if (err >= 0)
+		} else if (unlikely(TC_ACT_EXT_CMP(err, TC_ACT_GOTO_CHAIN))) {
+			old_tp = res->goto_tp;
+			goto reset;
+		} else if (err >= 0) {
 			return err;
+		}
 	}
 
 	return TC_ACT_UNSPEC; /* signal: continue lookup */
-- 
2.9.3

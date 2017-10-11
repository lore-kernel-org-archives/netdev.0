From: Alexander Aring <aring@mojatatu.com>
Subject: [PATCH net-next 3/3] sched: act: ife: update parameters via rcu handling
Date: Wed, 11 Oct 2017 17:16:08 -0400
Message-ID: <20171011211608.22692-4-aring@mojatatu.com>
References: <20171011211608.22692-1-aring@mojatatu.com>
Cc: xiyou.wangcong@gmail.com, jiri@resnulli.us, netdev@vger.kernel.org,
        eric.dumazet@gmail.com, bjb@mojatatu.com,
        Alexander Aring <aring@mojatatu.com>
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:48210 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757971AbdJKVQm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 17:16:42 -0400
Received: by mail-io0-f195.google.com with SMTP id j17so3299740iod.5
        for <netdev@vger.kernel.org>; Wed, 11 Oct 2017 14:16:41 -0700 (PDT)
In-Reply-To: <20171011211608.22692-1-aring@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes the parameter updating via RCU and not protected by a
spinlock anymore. This reduce the time that the spinlock is being held.

Signed-off-by: Alexander Aring <aring@mojatatu.com>
---
 include/net/tc_act/tc_ife.h | 10 ++++--
 net/sched/act_ife.c         | 87 ++++++++++++++++++++++++++++++---------------
 2 files changed, 67 insertions(+), 30 deletions(-)

diff --git a/include/net/tc_act/tc_ife.h b/include/net/tc_act/tc_ife.h
index 30ba459ddd34..16a84f6d43e2 100644
--- a/include/net/tc_act/tc_ife.h
+++ b/include/net/tc_act/tc_ife.h
@@ -6,12 +6,18 @@
 #include <linux/rtnetlink.h>
 #include <linux/module.h>
 
-struct tcf_ife_info {
-	struct tc_action common;
+struct tcf_ife_params {
 	u8 eth_dst[ETH_ALEN];
 	u8 eth_src[ETH_ALEN];
 	u16 eth_type;
 	u16 flags;
+
+	struct rcu_head rcu;
+};
+
+struct tcf_ife_info {
+	struct tc_action common;
+	struct tcf_ife_params __rcu *params;
 	/* list of metaids allowed */
 	struct list_head metalist;
 };
diff --git a/net/sched/act_ife.c b/net/sched/act_ife.c
index f0d86b182387..2ef25c5582bb 100644
--- a/net/sched/act_ife.c
+++ b/net/sched/act_ife.c
@@ -392,10 +392,14 @@ static void _tcf_ife_cleanup(struct tc_action *a, int bind)
 static void tcf_ife_cleanup(struct tc_action *a, int bind)
 {
 	struct tcf_ife_info *ife = to_ife(a);
+	struct tcf_ife_params *p;
 
 	spin_lock_bh(&ife->tcf_lock);
 	_tcf_ife_cleanup(a, bind);
 	spin_unlock_bh(&ife->tcf_lock);
+
+	p = rcu_dereference_protected(ife->params, 1);
+	kfree_rcu(p, rcu);
 }
 
 /* under ife->tcf_lock for existing action */
@@ -432,6 +436,7 @@ static int tcf_ife_init(struct net *net, struct nlattr *nla,
 	struct tc_action_net *tn = net_generic(net, ife_net_id);
 	struct nlattr *tb[TCA_IFE_MAX + 1];
 	struct nlattr *tb2[IFE_META_MAX + 1];
+	struct tcf_ife_params *p, *p_old;
 	struct tcf_ife_info *ife;
 	u16 ife_type = ETH_P_IFE;
 	struct tc_ife *parm;
@@ -457,24 +462,34 @@ static int tcf_ife_init(struct net *net, struct nlattr *nla,
 	if (parm->flags & ~IFE_ENCODE)
 		return -EINVAL;
 
+	p = kzalloc(sizeof(*p), GFP_KERNEL);
+	if (!p)
+		return -ENOMEM;
+
 	exists = tcf_idr_check(tn, parm->index, a, bind);
-	if (exists && bind)
+	if (exists && bind) {
+		kfree(p);
 		return 0;
+	}
 
 	if (!exists) {
 		ret = tcf_idr_create(tn, parm->index, est, a, &act_ife_ops,
 				     bind, true);
-		if (ret)
+		if (ret) {
+			kfree(p);
 			return ret;
+		}
 		ret = ACT_P_CREATED;
 	} else {
 		tcf_idr_release(*a, bind);
-		if (!ovr)
+		if (!ovr) {
+			kfree(p);
 			return -EEXIST;
+		}
 	}
 
 	ife = to_ife(*a);
-	ife->flags = parm->flags;
+	p->flags = parm->flags;
 
 	if (parm->flags & IFE_ENCODE) {
 		if (tb[TCA_IFE_TYPE])
@@ -485,24 +500,25 @@ static int tcf_ife_init(struct net *net, struct nlattr *nla,
 			saddr = nla_data(tb[TCA_IFE_SMAC]);
 	}
 
-	if (exists)
-		spin_lock_bh(&ife->tcf_lock);
 	ife->tcf_action = parm->action;
 
 	if (parm->flags & IFE_ENCODE) {
 		if (daddr)
-			ether_addr_copy(ife->eth_dst, daddr);
+			ether_addr_copy(p->eth_dst, daddr);
 		else
-			eth_zero_addr(ife->eth_dst);
+			eth_zero_addr(p->eth_dst);
 
 		if (saddr)
-			ether_addr_copy(ife->eth_src, saddr);
+			ether_addr_copy(p->eth_src, saddr);
 		else
-			eth_zero_addr(ife->eth_src);
+			eth_zero_addr(p->eth_src);
 
-		ife->eth_type = ife_type;
+		p->eth_type = ife_type;
 	}
 
+	if (exists)
+		spin_lock_bh(&ife->tcf_lock);
+
 	if (ret == ACT_P_CREATED)
 		INIT_LIST_HEAD(&ife->metalist);
 
@@ -518,6 +534,7 @@ static int tcf_ife_init(struct net *net, struct nlattr *nla,
 
 			if (exists)
 				spin_unlock_bh(&ife->tcf_lock);
+			kfree(p);
 			return err;
 		}
 
@@ -538,6 +555,7 @@ static int tcf_ife_init(struct net *net, struct nlattr *nla,
 
 			if (exists)
 				spin_unlock_bh(&ife->tcf_lock);
+			kfree(p);
 			return err;
 		}
 	}
@@ -545,6 +563,11 @@ static int tcf_ife_init(struct net *net, struct nlattr *nla,
 	if (exists)
 		spin_unlock_bh(&ife->tcf_lock);
 
+	p_old = rtnl_dereference(ife->params);
+	rcu_assign_pointer(ife->params, p);
+	if (p_old)
+		kfree_rcu(p_old, rcu);
+
 	if (ret == ACT_P_CREATED)
 		tcf_idr_insert(tn, *a);
 
@@ -556,12 +579,13 @@ static int tcf_ife_dump(struct sk_buff *skb, struct tc_action *a, int bind,
 {
 	unsigned char *b = skb_tail_pointer(skb);
 	struct tcf_ife_info *ife = to_ife(a);
+	struct tcf_ife_params *p = rtnl_dereference(ife->params);
 	struct tc_ife opt = {
 		.index = ife->tcf_index,
 		.refcnt = ife->tcf_refcnt - ref,
 		.bindcnt = ife->tcf_bindcnt - bind,
 		.action = ife->tcf_action,
-		.flags = ife->flags,
+		.flags = p->flags,
 	};
 	struct tcf_t t;
 
@@ -572,17 +596,17 @@ static int tcf_ife_dump(struct sk_buff *skb, struct tc_action *a, int bind,
 	if (nla_put_64bit(skb, TCA_IFE_TM, sizeof(t), &t, TCA_IFE_PAD))
 		goto nla_put_failure;
 
-	if (!is_zero_ether_addr(ife->eth_dst)) {
-		if (nla_put(skb, TCA_IFE_DMAC, ETH_ALEN, ife->eth_dst))
+	if (!is_zero_ether_addr(p->eth_dst)) {
+		if (nla_put(skb, TCA_IFE_DMAC, ETH_ALEN, p->eth_dst))
 			goto nla_put_failure;
 	}
 
-	if (!is_zero_ether_addr(ife->eth_src)) {
-		if (nla_put(skb, TCA_IFE_SMAC, ETH_ALEN, ife->eth_src))
+	if (!is_zero_ether_addr(p->eth_src)) {
+		if (nla_put(skb, TCA_IFE_SMAC, ETH_ALEN, p->eth_src))
 			goto nla_put_failure;
 	}
 
-	if (nla_put(skb, TCA_IFE_TYPE, 2, &ife->eth_type))
+	if (nla_put(skb, TCA_IFE_TYPE, 2, &p->eth_type))
 		goto nla_put_failure;
 
 	if (dump_metalist(skb, ife)) {
@@ -684,7 +708,7 @@ static int ife_get_sz(struct sk_buff *skb, struct tcf_ife_info *ife)
 }
 
 static int tcf_ife_encode(struct sk_buff *skb, const struct tc_action *a,
-			  struct tcf_result *res)
+			  struct tcf_result *res, struct tcf_ife_params *p)
 {
 	struct tcf_ife_info *ife = to_ife(a);
 	int action = ife->tcf_action;
@@ -748,19 +772,18 @@ static int tcf_ife_encode(struct sk_buff *skb, const struct tc_action *a,
 		}
 		skboff += err;
 	}
+	spin_unlock(&ife->tcf_lock);
 	oethh = (struct ethhdr *)skb->data;
 
-	if (!is_zero_ether_addr(ife->eth_src))
-		ether_addr_copy(oethh->h_source, ife->eth_src);
-	if (!is_zero_ether_addr(ife->eth_dst))
-		ether_addr_copy(oethh->h_dest, ife->eth_dst);
-	oethh->h_proto = htons(ife->eth_type);
+	if (!is_zero_ether_addr(p->eth_src))
+		ether_addr_copy(oethh->h_source, p->eth_src);
+	if (!is_zero_ether_addr(p->eth_dst))
+		ether_addr_copy(oethh->h_dest, p->eth_dst);
+	oethh->h_proto = htons(p->eth_type);
 
 	if (skb_at_tc_ingress(skb))
 		skb_pull(skb, skb->dev->hard_header_len);
 
-	spin_unlock(&ife->tcf_lock);
-
 	return action;
 }
 
@@ -768,9 +791,17 @@ static int tcf_ife_act(struct sk_buff *skb, const struct tc_action *a,
 		       struct tcf_result *res)
 {
 	struct tcf_ife_info *ife = to_ife(a);
-
-	if (ife->flags & IFE_ENCODE)
-		return tcf_ife_encode(skb, a, res);
+	struct tcf_ife_params *p;
+	int ret;
+
+	rcu_read_lock();
+	p = rcu_dereference(ife->params);
+	if (p->flags & IFE_ENCODE) {
+		ret = tcf_ife_encode(skb, a, res, p);
+		rcu_read_unlock();
+		return ret;
+	}
+	rcu_read_unlock();
 
 	return tcf_ife_decode(skb, a, res);
 }
-- 
2.11.0

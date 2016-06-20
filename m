From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net 1/2] act_ife: only acquire tcf_lock for existing actions
Date: Mon, 20 Jun 2016 13:37:18 -0700
Message-ID: <1466455039-23268-2-git-send-email-xiyou.wangcong@gmail.com>
References: <1466455039-23268-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: khoroshilov@ispras.ru, Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:35343 "EHLO
	mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751628AbcFTWgn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 18:36:43 -0400
Received: by mail-pa0-f65.google.com with SMTP id hf6so11746953pac.2
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2016 15:35:09 -0700 (PDT)
In-Reply-To: <1466455039-23268-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexey reported that we have GFP_KERNEL allocation when
holding the spinlock tcf_lock. Actually we don't have
to take that spinlock for all the cases, especially
for the new one we just create. To modify the existing
actions, we still need this spinlock to make sure
the whole update is atomic.

For net-next, we can get rid of this spinlock because
we already hold the RTNL lock on slow path, and on fast
path we can use RCU to protect the metalist.

Joint work with Jamal.

Reported-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/tc_act/tc_ife.h |  6 ++---
 net/sched/act_ife.c         | 55 +++++++++++++++++++++++++--------------------
 2 files changed, 34 insertions(+), 27 deletions(-)

diff --git a/include/net/tc_act/tc_ife.h b/include/net/tc_act/tc_ife.h
index dc9a09a..c55facd 100644
--- a/include/net/tc_act/tc_ife.h
+++ b/include/net/tc_act/tc_ife.h
@@ -36,7 +36,7 @@ struct tcf_meta_ops {
 	int	(*encode)(struct sk_buff *, void *, struct tcf_meta_info *);
 	int	(*decode)(struct sk_buff *, void *, u16 len);
 	int	(*get)(struct sk_buff *skb, struct tcf_meta_info *mi);
-	int	(*alloc)(struct tcf_meta_info *, void *);
+	int	(*alloc)(struct tcf_meta_info *, void *, gfp_t);
 	void	(*release)(struct tcf_meta_info *);
 	int	(*validate)(void *val, int len);
 	struct module	*owner;
@@ -48,8 +48,8 @@ int ife_get_meta_u32(struct sk_buff *skb, struct tcf_meta_info *mi);
 int ife_get_meta_u16(struct sk_buff *skb, struct tcf_meta_info *mi);
 int ife_tlv_meta_encode(void *skbdata, u16 attrtype, u16 dlen,
 			const void *dval);
-int ife_alloc_meta_u32(struct tcf_meta_info *mi, void *metaval);
-int ife_alloc_meta_u16(struct tcf_meta_info *mi, void *metaval);
+int ife_alloc_meta_u32(struct tcf_meta_info *mi, void *metaval, gfp_t gfp);
+int ife_alloc_meta_u16(struct tcf_meta_info *mi, void *metaval, gfp_t gfp);
 int ife_check_meta_u32(u32 metaval, struct tcf_meta_info *mi);
 int ife_encode_meta_u32(u32 metaval, void *skbdata, struct tcf_meta_info *mi);
 int ife_validate_meta_u32(void *val, int len);
diff --git a/net/sched/act_ife.c b/net/sched/act_ife.c
index 658046d..e407659 100644
--- a/net/sched/act_ife.c
+++ b/net/sched/act_ife.c
@@ -106,9 +106,9 @@ int ife_get_meta_u16(struct sk_buff *skb, struct tcf_meta_info *mi)
 }
 EXPORT_SYMBOL_GPL(ife_get_meta_u16);
 
-int ife_alloc_meta_u32(struct tcf_meta_info *mi, void *metaval)
+int ife_alloc_meta_u32(struct tcf_meta_info *mi, void *metaval, gfp_t gfp)
 {
-	mi->metaval = kmemdup(metaval, sizeof(u32), GFP_KERNEL);
+	mi->metaval = kmemdup(metaval, sizeof(u32), gfp);
 	if (!mi->metaval)
 		return -ENOMEM;
 
@@ -116,9 +116,9 @@ int ife_alloc_meta_u32(struct tcf_meta_info *mi, void *metaval)
 }
 EXPORT_SYMBOL_GPL(ife_alloc_meta_u32);
 
-int ife_alloc_meta_u16(struct tcf_meta_info *mi, void *metaval)
+int ife_alloc_meta_u16(struct tcf_meta_info *mi, void *metaval, gfp_t gfp)
 {
-	mi->metaval = kmemdup(metaval, sizeof(u16), GFP_KERNEL);
+	mi->metaval = kmemdup(metaval, sizeof(u16), gfp);
 	if (!mi->metaval)
 		return -ENOMEM;
 
@@ -240,10 +240,10 @@ static int ife_validate_metatype(struct tcf_meta_ops *ops, void *val, int len)
 }
 
 /* called when adding new meta information
- * under ife->tcf_lock
+ * under ife->tcf_lock for existing action
 */
 static int load_metaops_and_vet(struct tcf_ife_info *ife, u32 metaid,
-				void *val, int len)
+				void *val, int len, bool exists)
 {
 	struct tcf_meta_ops *ops = find_ife_oplist(metaid);
 	int ret = 0;
@@ -251,11 +251,13 @@ static int load_metaops_and_vet(struct tcf_ife_info *ife, u32 metaid,
 	if (!ops) {
 		ret = -ENOENT;
 #ifdef CONFIG_MODULES
-		spin_unlock_bh(&ife->tcf_lock);
+		if (exists)
+			spin_unlock_bh(&ife->tcf_lock);
 		rtnl_unlock();
 		request_module("ifemeta%u", metaid);
 		rtnl_lock();
-		spin_lock_bh(&ife->tcf_lock);
+		if (exists)
+			spin_lock_bh(&ife->tcf_lock);
 		ops = find_ife_oplist(metaid);
 #endif
 	}
@@ -272,10 +274,10 @@ static int load_metaops_and_vet(struct tcf_ife_info *ife, u32 metaid,
 }
 
 /* called when adding new meta information
- * under ife->tcf_lock
+ * under ife->tcf_lock for existing action
 */
 static int add_metainfo(struct tcf_ife_info *ife, u32 metaid, void *metaval,
-			int len)
+			int len, bool exists)
 {
 	struct tcf_meta_info *mi = NULL;
 	struct tcf_meta_ops *ops = find_ife_oplist(metaid);
@@ -284,7 +286,7 @@ static int add_metainfo(struct tcf_ife_info *ife, u32 metaid, void *metaval,
 	if (!ops)
 		return -ENOENT;
 
-	mi = kzalloc(sizeof(*mi), GFP_KERNEL);
+	mi = kzalloc(sizeof(*mi), exists ? GFP_ATOMIC : GFP_KERNEL);
 	if (!mi) {
 		/*put back what find_ife_oplist took */
 		module_put(ops->owner);
@@ -294,7 +296,7 @@ static int add_metainfo(struct tcf_ife_info *ife, u32 metaid, void *metaval,
 	mi->metaid = metaid;
 	mi->ops = ops;
 	if (len > 0) {
-		ret = ops->alloc(mi, metaval);
+		ret = ops->alloc(mi, metaval, exists ? GFP_ATOMIC : GFP_KERNEL);
 		if (ret != 0) {
 			kfree(mi);
 			module_put(ops->owner);
@@ -307,14 +309,14 @@ static int add_metainfo(struct tcf_ife_info *ife, u32 metaid, void *metaval,
 	return ret;
 }
 
-static int use_all_metadata(struct tcf_ife_info *ife)
+static int use_all_metadata(struct tcf_ife_info *ife, bool exists)
 {
 	struct tcf_meta_ops *o;
 	int rc = 0;
 	int installed = 0;
 
 	list_for_each_entry(o, &ifeoplist, list) {
-		rc = add_metainfo(ife, o->metaid, NULL, 0);
+		rc = add_metainfo(ife, o->metaid, NULL, 0, exists);
 		if (rc == 0)
 			installed += 1;
 	}
@@ -385,8 +387,9 @@ static void tcf_ife_cleanup(struct tc_action *a, int bind)
 	spin_unlock_bh(&ife->tcf_lock);
 }
 
-/* under ife->tcf_lock */
-static int populate_metalist(struct tcf_ife_info *ife, struct nlattr **tb)
+/* under ife->tcf_lock for existing action */
+static int populate_metalist(struct tcf_ife_info *ife, struct nlattr **tb,
+			     bool exists)
 {
 	int len = 0;
 	int rc = 0;
@@ -398,11 +401,11 @@ static int populate_metalist(struct tcf_ife_info *ife, struct nlattr **tb)
 			val = nla_data(tb[i]);
 			len = nla_len(tb[i]);
 
-			rc = load_metaops_and_vet(ife, i, val, len);
+			rc = load_metaops_and_vet(ife, i, val, len, exists);
 			if (rc != 0)
 				return rc;
 
-			rc = add_metainfo(ife, i, val, len);
+			rc = add_metainfo(ife, i, val, len, exists);
 			if (rc)
 				return rc;
 		}
@@ -474,7 +477,8 @@ static int tcf_ife_init(struct net *net, struct nlattr *nla,
 			saddr = nla_data(tb[TCA_IFE_SMAC]);
 	}
 
-	spin_lock_bh(&ife->tcf_lock);
+	if (exists)
+		spin_lock_bh(&ife->tcf_lock);
 	ife->tcf_action = parm->action;
 
 	if (parm->flags & IFE_ENCODE) {
@@ -504,11 +508,12 @@ static int tcf_ife_init(struct net *net, struct nlattr *nla,
 			if (ret == ACT_P_CREATED)
 				_tcf_ife_cleanup(a, bind);
 
-			spin_unlock_bh(&ife->tcf_lock);
+			if (exists)
+				spin_unlock_bh(&ife->tcf_lock);
 			return err;
 		}
 
-		err = populate_metalist(ife, tb2);
+		err = populate_metalist(ife, tb2, exists);
 		if (err)
 			goto metadata_parse_err;
 
@@ -518,17 +523,19 @@ static int tcf_ife_init(struct net *net, struct nlattr *nla,
 		 * as we can. You better have at least one else we are
 		 * going to bail out
 		 */
-		err = use_all_metadata(ife);
+		err = use_all_metadata(ife, exists);
 		if (err) {
 			if (ret == ACT_P_CREATED)
 				_tcf_ife_cleanup(a, bind);
 
-			spin_unlock_bh(&ife->tcf_lock);
+			if (exists)
+				spin_unlock_bh(&ife->tcf_lock);
 			return err;
 		}
 	}
 
-	spin_unlock_bh(&ife->tcf_lock);
+	if (exists)
+		spin_unlock_bh(&ife->tcf_lock);
 
 	if (ret == ACT_P_CREATED)
 		tcf_hash_insert(tn, a);
-- 
2.1.0

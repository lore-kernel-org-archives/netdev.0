From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [Patch net-next] net_sched: act: remove unnecessary checks for act->ops
Date: Sun, 22 Dec 2013 10:13:02 -0500
Message-ID: <52B7017E.30203@mojatatu.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010603050101040609090809"
To: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:50597 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753843Ab3LVPNI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Dec 2013 10:13:08 -0500
Received: by mail-ig0-f169.google.com with SMTP id hk11so19171695igb.0
        for <netdev@vger.kernel.org>; Sun, 22 Dec 2013 07:13:05 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010603050101040609090809
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


As promised to Eric. There are still a few needed for setup - just not
the fast path.

cheers,
jamal

--------------010603050101040609090809
Content-Type: text/plain; charset=us-ascii;
 name="remove-ops-check"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="remove-ops-check"

commit 7f48355fee65a850714b71222fc27b4d17230f45
Author: Jamal Hadi Salim <hadi@mojatatu.com>
Date:   Sun Dec 22 10:07:30 2013 -0500

    Remove unnecessary checks for act->ops (suggested by Eric Dumazet).
    
    Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index dce2b6e..9907794 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -354,18 +354,16 @@ int tcf_action_exec(struct sk_buff *skb, const struct list_head *actions,
 	}
 	list_for_each_entry(a, actions, list) {
 repeat:
-		if (a->ops) {
-			ret = a->ops->act(skb, a, res);
-			if (TC_MUNGED & skb->tc_verd) {
-				/* copied already, allow trampling */
-				skb->tc_verd = SET_TC_OK2MUNGE(skb->tc_verd);
-				skb->tc_verd = CLR_TC_MUNGED(skb->tc_verd);
-			}
-			if (ret == TC_ACT_REPEAT)
-				goto repeat;	/* we need a ttl - JHS */
-			if (ret != TC_ACT_PIPE)
-				goto exec_done;
+		ret = a->ops->act(skb, a, res);
+		if (TC_MUNGED & skb->tc_verd) {
+			/* copied already, allow trampling */
+			skb->tc_verd = SET_TC_OK2MUNGE(skb->tc_verd);
+			skb->tc_verd = CLR_TC_MUNGED(skb->tc_verd);
 		}
+		if (ret == TC_ACT_REPEAT)
+			goto repeat;	/* we need a ttl - JHS */
+		if (ret != TC_ACT_PIPE)
+			goto exec_done;
 	}
 exec_done:
 	return ret;
@@ -377,27 +375,16 @@ void tcf_action_destroy(struct list_head *actions, int bind)
 	struct tc_action *a, *tmp;
 
 	list_for_each_entry_safe(a, tmp, actions, list) {
-		if (a->ops) {
-			if (a->ops->cleanup(a, bind) == ACT_P_DELETED)
-				module_put(a->ops->owner);
-			list_del(&a->list);
-			kfree(a);
-		} else {
-			/*FIXME: Remove later - catch insertion bugs*/
-			WARN(1, "tcf_action_destroy: BUG? destroying NULL ops\n");
-			list_del(&a->list);
-			kfree(a);
-		}
+		if (a->ops->cleanup(a, bind) == ACT_P_DELETED)
+			module_put(a->ops->owner);
+		list_del(&a->list);
+		kfree(a);
 	}
 }
 
 int
 tcf_action_dump_old(struct sk_buff *skb, struct tc_action *a, int bind, int ref)
 {
-	int err = -EINVAL;
-
-	if (a->ops == NULL)
-		return err;
 	return a->ops->dump(skb, a, bind, ref);
 }
 
@@ -408,9 +395,6 @@ tcf_action_dump_1(struct sk_buff *skb, struct tc_action *a, int bind, int ref)
 	unsigned char *b = skb_tail_pointer(skb);
 	struct nlattr *nest;
 
-	if (a->ops == NULL)
-		return err;
-
 	if (nla_put_string(skb, TCA_KIND, a->ops->kind))
 		goto nla_put_failure;
 	if (tcf_action_copy_stats(skb, a, 0))
@@ -686,7 +670,7 @@ tcf_action_get_1(struct nlattr *nla, struct nlmsghdr *n, u32 portid)
 	INIT_LIST_HEAD(&a->list);
 	err = -EINVAL;
 	a->ops = tc_lookup_action(tb[TCA_ACT_KIND]);
-	if (a->ops == NULL)
+	if (a->ops == NULL) /* could happen in batch of actions */
 		goto err_free;
 	err = -ENOENT;
 	if (a->ops->lookup(a, index) == 0)
@@ -762,7 +746,7 @@ static int tca_action_flush(struct net *net, struct nlattr *nla,
 	err = -EINVAL;
 	kind = tb[TCA_ACT_KIND];
 	a->ops = tc_lookup_action(kind);
-	if (a->ops == NULL)
+	if (a->ops == NULL) /*some idjot trying to flush unknown action */
 		goto err_out;
 
 	nlh = nlmsg_put(skb, portid, n->nlmsg_seq, RTM_DELACTION, sizeof(*t), 0);
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 12e882e..d8c42b1 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -577,7 +577,7 @@ int tcf_exts_dump(struct sk_buff *skb, struct tcf_exts *exts)
 		} else if (exts->police) {
 			struct tc_action *act = tcf_exts_first_act(exts);
 			nest = nla_nest_start(skb, exts->police);
-			if (nest == NULL)
+			if (nest == NULL || !act)
 				goto nla_put_failure;
 			if (tcf_action_dump_old(skb, act, 0, 0) < 0)
 				goto nla_put_failure;

--------------010603050101040609090809--

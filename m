From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net v4 7/7] net_sched: allow flushing tc police actions
Date: Sat, 13 Aug 2016 22:35:02 -0700
Message-ID: <1471152902-12444-8-git-send-email-xiyou.wangcong@gmail.com>
References: <1471152902-12444-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: jhs@mojatatu.com, Cong Wang <xiyou.wangcong@gmail.com>,
	Roman Mashak <mrv@mojatatu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34472 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750701AbcHNJmh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Aug 2016 05:42:37 -0400
Received: by mail-pf0-f194.google.com with SMTP id g202so2059775pfb.1
        for <netdev@vger.kernel.org>; Sun, 14 Aug 2016 02:42:37 -0700 (PDT)
In-Reply-To: <1471152902-12444-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roman Mashak <mrv@mojatatu.com>

The act_police uses its own code to walk the
action hashtable, which leads to that we could
not flush standalone tc police actions, so just
switch to tcf_generic_walker() like other actions.

(Joint work from Roman and Cong.)

Signed-off-by: Roman Mashak <mrv@mojatatu.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/act_police.c | 43 +------------------------------------------
 1 file changed, 1 insertion(+), 42 deletions(-)

diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index 259352d..8a3be1d 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -63,49 +63,8 @@ static int tcf_act_police_walker(struct net *net, struct sk_buff *skb,
 				 const struct tc_action_ops *ops)
 {
 	struct tc_action_net *tn = net_generic(net, police_net_id);
-	struct tcf_hashinfo *hinfo = tn->hinfo;
-	int err = 0, index = -1, i = 0, s_i = 0, n_i = 0;
-	struct nlattr *nest;
-
-	spin_lock_bh(&hinfo->lock);
-
-	s_i = cb->args[0];
-
-	for (i = 0; i < (POL_TAB_MASK + 1); i++) {
-		struct hlist_head *head;
-		struct tc_action *p;
-
-		head = &hinfo->htab[tcf_hash(i, POL_TAB_MASK)];
-
-		hlist_for_each_entry_rcu(p, head, tcfa_head) {
-			index++;
-			if (index < s_i)
-				continue;
-			nest = nla_nest_start(skb, index);
-			if (nest == NULL)
-				goto nla_put_failure;
-			if (type == RTM_DELACTION)
-				err = tcf_action_dump_1(skb, p, 0, 1);
-			else
-				err = tcf_action_dump_1(skb, p, 0, 0);
-			if (err < 0) {
-				index--;
-				nla_nest_cancel(skb, nest);
-				goto done;
-			}
-			nla_nest_end(skb, nest);
-			n_i++;
-		}
-	}
-done:
-	spin_unlock_bh(&hinfo->lock);
-	if (n_i)
-		cb->args[0] += n_i;
-	return n_i;
 
-nla_put_failure:
-	nla_nest_cancel(skb, nest);
-	goto done;
+	return tcf_generic_walker(tn, skb, cb, type, ops);
 }
 
 static const struct nla_policy police_policy[TCA_POLICE_MAX + 1] = {
-- 
1.8.4.5

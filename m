From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net] sched: cls_flower: remove from hashtable only in case skip sw flag is not set
Date: Mon, 28 Nov 2016 15:40:13 +0100
Message-ID: <1480344013-4812-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, idosch@mellanox.com,
        eladr@mellanox.com, ogerlitz@mellanox.com, hadarh@mellanox.com,
        amir@vadai.me
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f196.google.com ([209.85.210.196]:35891 "EHLO
        mail-wj0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933286AbcK1OkQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 09:40:16 -0500
Received: by mail-wj0-f196.google.com with SMTP id jb2so14348977wjb.3
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 06:40:15 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Be symmetric to hashtable insert and remove filter from hashtable only
in case skip sw flag is not set.

Fixes: e69985c67c33 ("net/sched: cls_flower: Introduce support in SKIP SW flag")
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/sched/cls_flower.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index f6f40fb..641c44c 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -711,8 +711,9 @@ static int fl_change(struct net *net, struct sk_buff *in_skb,
 		goto errout;
 
 	if (fold) {
-		rhashtable_remove_fast(&head->ht, &fold->ht_node,
-				       head->ht_params);
+		if (!tc_skip_sw(fold->flags))
+			rhashtable_remove_fast(&head->ht, &fold->ht_node,
+					       head->ht_params);
 		fl_hw_destroy_filter(tp, (unsigned long)fold);
 	}
 
@@ -739,8 +740,9 @@ static int fl_delete(struct tcf_proto *tp, unsigned long arg)
 	struct cls_fl_head *head = rtnl_dereference(tp->root);
 	struct cls_fl_filter *f = (struct cls_fl_filter *) arg;
 
-	rhashtable_remove_fast(&head->ht, &f->ht_node,
-			       head->ht_params);
+	if (!tc_skip_sw(f->flags))
+		rhashtable_remove_fast(&head->ht, &f->ht_node,
+				       head->ht_params);
 	list_del_rcu(&f->list);
 	fl_hw_destroy_filter(tp, (unsigned long)f);
 	tcf_unbind_filter(tp, &f->res);
-- 
2.7.4

From: Roi Dayan <roid@mellanox.com>
Subject: [PATCH net-next 2/2] net/sched: cls_flower: merge filter delete/destroy common code
Date: Tue,  1 Nov 2016 16:08:29 +0200
Message-ID: <1478009309-63180-3-git-send-email-roid@mellanox.com>
References: <1478009309-63180-1-git-send-email-roid@mellanox.com>
Cc: netdev@vger.kernel.org, Jiri Pirko <jiri@mellanox.com>,
        Roi Dayan <roid@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:35505 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S966027AbcKAOIi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 10:08:38 -0400
In-Reply-To: <1478009309-63180-1-git-send-email-roid@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move common code from fl_delete and fl_detroy to __fl_delete.

Signed-off-by: Roi Dayan <roid@mellanox.com>
---
 net/sched/cls_flower.c | 21 +++++++++++----------
 1 file changed, 11 insertions(+), 10 deletions(-)

diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index a5f6370..a8fb1ca 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -269,6 +269,14 @@ static void fl_hw_update_stats(struct tcf_proto *tp, struct cls_fl_filter *f)
 	dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle, tp->protocol, &tc);
 }
 
+static void __fl_delete(struct tcf_proto *tp, struct cls_fl_filter *f)
+{
+	list_del_rcu(&f->list);
+	fl_hw_destroy_filter(tp, (unsigned long)f);
+	tcf_unbind_filter(tp, &f->res);
+	call_rcu(&f->rcu, fl_destroy_filter);
+}
+
 static bool fl_destroy(struct tcf_proto *tp, bool force)
 {
 	struct cls_fl_head *head = rtnl_dereference(tp->root);
@@ -277,12 +285,8 @@ static bool fl_destroy(struct tcf_proto *tp, bool force)
 	if (!force && !list_empty(&head->filters))
 		return false;
 
-	list_for_each_entry_safe(f, next, &head->filters, list) {
-		fl_hw_destroy_filter(tp, (unsigned long)f);
-		list_del_rcu(&f->list);
-		tcf_unbind_filter(tp, &f->res);
-		call_rcu(&f->rcu, fl_destroy_filter);
-	}
+	list_for_each_entry_safe(f, next, &head->filters, list)
+		__fl_delete(tp, f);
 	RCU_INIT_POINTER(tp->root, NULL);
 	if (head->mask_assigned)
 		rhashtable_destroy(&head->ht);
@@ -742,10 +746,7 @@ static int fl_delete(struct tcf_proto *tp, unsigned long arg)
 
 	rhashtable_remove_fast(&head->ht, &f->ht_node,
 			       head->ht_params);
-	list_del_rcu(&f->list);
-	fl_hw_destroy_filter(tp, (unsigned long)f);
-	tcf_unbind_filter(tp, &f->res);
-	call_rcu(&f->rcu, fl_destroy_filter);
+	__fl_delete(tp, f);
 	return 0;
 }
 
-- 
2.7.4

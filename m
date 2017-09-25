From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next v2] net_sched: use idr to allocate basic filter handles
Date: Mon, 25 Sep 2017 10:13:50 -0700
Message-ID: <20170925171351.4956-2-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Chris Mi <chrism@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:37488 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935534AbdIYROC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 13:14:02 -0400
Received: by mail-pg0-f65.google.com with SMTP id v5so5180550pgn.4
        for <netdev@vger.kernel.org>; Mon, 25 Sep 2017 10:14:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of calling basic_get() in a loop to find
a unused handle, just switch to idr API to allocate
new handles.

Cc: Chris Mi <chrism@mellanox.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/cls_basic.c | 37 ++++++++++++++++++++++---------------
 1 file changed, 22 insertions(+), 15 deletions(-)

diff --git a/net/sched/cls_basic.c b/net/sched/cls_basic.c
index d89ebafd2239..cfeb6f158566 100644
--- a/net/sched/cls_basic.c
+++ b/net/sched/cls_basic.c
@@ -17,13 +17,14 @@
 #include <linux/errno.h>
 #include <linux/rtnetlink.h>
 #include <linux/skbuff.h>
+#include <linux/idr.h>
 #include <net/netlink.h>
 #include <net/act_api.h>
 #include <net/pkt_cls.h>
 
 struct basic_head {
-	u32			hgenerator;
 	struct list_head	flist;
+	struct idr		handle_idr;
 	struct rcu_head		rcu;
 };
 
@@ -78,6 +79,7 @@ static int basic_init(struct tcf_proto *tp)
 	if (head == NULL)
 		return -ENOBUFS;
 	INIT_LIST_HEAD(&head->flist);
+	idr_init(&head->handle_idr);
 	rcu_assign_pointer(tp->root, head);
 	return 0;
 }
@@ -99,8 +101,10 @@ static void basic_destroy(struct tcf_proto *tp)
 	list_for_each_entry_safe(f, n, &head->flist, link) {
 		list_del_rcu(&f->link);
 		tcf_unbind_filter(tp, &f->res);
+		idr_remove_ext(&head->handle_idr, f->handle);
 		call_rcu(&f->rcu, basic_delete_filter);
 	}
+	idr_destroy(&head->handle_idr);
 	kfree_rcu(head, rcu);
 }
 
@@ -111,6 +115,7 @@ static int basic_delete(struct tcf_proto *tp, void *arg, bool *last)
 
 	list_del_rcu(&f->link);
 	tcf_unbind_filter(tp, &f->res);
+	idr_remove_ext(&head->handle_idr, f->handle);
 	call_rcu(&f->rcu, basic_delete_filter);
 	*last = list_empty(&head->flist);
 	return 0;
@@ -154,6 +159,7 @@ static int basic_change(struct net *net, struct sk_buff *in_skb,
 	struct nlattr *tb[TCA_BASIC_MAX + 1];
 	struct basic_filter *fold = (struct basic_filter *) *arg;
 	struct basic_filter *fnew;
+	unsigned long idr_index;
 
 	if (tca[TCA_OPTIONS] == NULL)
 		return -EINVAL;
@@ -179,30 +185,31 @@ static int basic_change(struct net *net, struct sk_buff *in_skb,
 	err = -EINVAL;
 	if (handle) {
 		fnew->handle = handle;
-	} else if (fold) {
-		fnew->handle = fold->handle;
+		if (!fold) {
+			err = idr_alloc_ext(&head->handle_idr, fnew, &idr_index,
+					    handle, handle + 1, GFP_KERNEL);
+			if (err)
+				goto errout;
+		}
 	} else {
-		unsigned int i = 0x80000000;
-		do {
-			if (++head->hgenerator == 0x7FFFFFFF)
-				head->hgenerator = 1;
-		} while (--i > 0 && basic_get(tp, head->hgenerator));
-
-		if (i <= 0) {
-			pr_err("Insufficient number of handles\n");
+		err = idr_alloc_ext(&head->handle_idr, fnew, &idr_index,
+				    1, 0x7FFFFFFF, GFP_KERNEL);
+		if (err)
 			goto errout;
-		}
-
-		fnew->handle = head->hgenerator;
+		fnew->handle = idr_index;
 	}
 
 	err = basic_set_parms(net, tp, fnew, base, tb, tca[TCA_RATE], ovr);
-	if (err < 0)
+	if (err < 0) {
+		if (!fold)
+			idr_remove_ext(&head->handle_idr, fnew->handle);
 		goto errout;
+	}
 
 	*arg = fnew;
 
 	if (fold) {
+		idr_replace_ext(&head->handle_idr, fnew, fnew->handle);
 		list_replace_rcu(&fold->link, &fnew->link);
 		tcf_unbind_filter(tp, &fold->res);
 		call_rcu(&fold->rcu, basic_delete_filter);
-- 
2.13.0

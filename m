From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net 02/16] net_sched: use tcf_queue_work() in basic filter
Date: Thu, 26 Oct 2017 18:24:29 -0700
Message-ID: <20171027012443.3306-3-xiyou.wangcong@gmail.com>
References: <20171027012443.3306-1-xiyou.wangcong@gmail.com>
Cc: Chris Mi <chrism@mellanox.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Jiri Pirko <jiri@resnulli.us>,
        John Fastabend <john.fastabend@gmail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:51529 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751959AbdJ0BZB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 21:25:01 -0400
Received: by mail-pf0-f193.google.com with SMTP id n14so3764012pfh.8
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 18:25:00 -0700 (PDT)
In-Reply-To: <20171027012443.3306-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Defer the tcf_exts_destroy() in RCU callback to
tc filter workqueue and get RTNL lock.

Reported-by: Chris Mi <chrism@mellanox.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Jiri Pirko <jiri@resnulli.us>
Cc: John Fastabend <john.fastabend@gmail.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/cls_basic.c | 20 +++++++++++++++++---
 1 file changed, 17 insertions(+), 3 deletions(-)

diff --git a/net/sched/cls_basic.c b/net/sched/cls_basic.c
index d89ebafd2239..f177649a2419 100644
--- a/net/sched/cls_basic.c
+++ b/net/sched/cls_basic.c
@@ -34,7 +34,10 @@ struct basic_filter {
 	struct tcf_result	res;
 	struct tcf_proto	*tp;
 	struct list_head	link;
-	struct rcu_head		rcu;
+	union {
+		struct work_struct	work;
+		struct rcu_head		rcu;
+	};
 };
 
 static int basic_classify(struct sk_buff *skb, const struct tcf_proto *tp,
@@ -82,15 +85,26 @@ static int basic_init(struct tcf_proto *tp)
 	return 0;
 }
 
-static void basic_delete_filter(struct rcu_head *head)
+static void basic_delete_filter_work(struct work_struct *work)
 {
-	struct basic_filter *f = container_of(head, struct basic_filter, rcu);
+	struct basic_filter *f = container_of(work, struct basic_filter, work);
 
+	rtnl_lock();
 	tcf_exts_destroy(&f->exts);
 	tcf_em_tree_destroy(&f->ematches);
+	rtnl_unlock();
+
 	kfree(f);
 }
 
+static void basic_delete_filter(struct rcu_head *head)
+{
+	struct basic_filter *f = container_of(head, struct basic_filter, rcu);
+
+	INIT_WORK(&f->work, basic_delete_filter_work);
+	tcf_queue_work(&f->work);
+}
+
 static void basic_destroy(struct tcf_proto *tp)
 {
 	struct basic_head *head = rtnl_dereference(tp->root);
-- 
2.13.0

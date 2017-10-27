From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net 08/16] net_sched: use tcf_queue_work() in matchall filter
Date: Thu, 26 Oct 2017 18:24:35 -0700
Message-ID: <20171027012443.3306-9-xiyou.wangcong@gmail.com>
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
Received: from mail-pf0-f196.google.com ([209.85.192.196]:43880 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751947AbdJ0BZI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 21:25:08 -0400
Received: by mail-pf0-f196.google.com with SMTP id a8so3783453pfc.0
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 18:25:07 -0700 (PDT)
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
 net/sched/cls_matchall.c | 19 ++++++++++++++++---
 1 file changed, 16 insertions(+), 3 deletions(-)

diff --git a/net/sched/cls_matchall.c b/net/sched/cls_matchall.c
index eeac606c95ab..c33f711b9019 100644
--- a/net/sched/cls_matchall.c
+++ b/net/sched/cls_matchall.c
@@ -21,7 +21,10 @@ struct cls_mall_head {
 	struct tcf_result res;
 	u32 handle;
 	u32 flags;
-	struct rcu_head	rcu;
+	union {
+		struct work_struct work;
+		struct rcu_head	rcu;
+	};
 };
 
 static int mall_classify(struct sk_buff *skb, const struct tcf_proto *tp,
@@ -41,13 +44,23 @@ static int mall_init(struct tcf_proto *tp)
 	return 0;
 }
 
+static void mall_destroy_work(struct work_struct *work)
+{
+	struct cls_mall_head *head = container_of(work, struct cls_mall_head,
+						  work);
+	rtnl_lock();
+	tcf_exts_destroy(&head->exts);
+	kfree(head);
+	rtnl_unlock();
+}
+
 static void mall_destroy_rcu(struct rcu_head *rcu)
 {
 	struct cls_mall_head *head = container_of(rcu, struct cls_mall_head,
 						  rcu);
 
-	tcf_exts_destroy(&head->exts);
-	kfree(head);
+	INIT_WORK(&head->work, mall_destroy_work);
+	tcf_queue_work(&head->work);
 }
 
 static int mall_replace_hw_filter(struct tcf_proto *tp,
-- 
2.13.0

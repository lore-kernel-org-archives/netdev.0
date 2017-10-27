From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net 06/16] net_sched: use tcf_queue_work() in flower filter
Date: Thu, 26 Oct 2017 18:24:33 -0700
Message-ID: <20171027012443.3306-7-xiyou.wangcong@gmail.com>
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
Received: from mail-pg0-f65.google.com ([74.125.83.65]:55297 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751932AbdJ0BZF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 21:25:05 -0400
Received: by mail-pg0-f65.google.com with SMTP id 15so4040899pgc.12
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 18:25:05 -0700 (PDT)
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
 net/sched/cls_flower.c | 19 ++++++++++++++++---
 1 file changed, 16 insertions(+), 3 deletions(-)

diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index b480d7c792ba..5b5722c8b32c 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -87,7 +87,10 @@ struct cls_fl_filter {
 	struct list_head list;
 	u32 handle;
 	u32 flags;
-	struct rcu_head	rcu;
+	union {
+		struct work_struct work;
+		struct rcu_head	rcu;
+	};
 	struct net_device *hw_dev;
 };
 
@@ -215,12 +218,22 @@ static int fl_init(struct tcf_proto *tp)
 	return 0;
 }
 
-static void fl_destroy_filter(struct rcu_head *head)
+static void fl_destroy_filter_work(struct work_struct *work)
 {
-	struct cls_fl_filter *f = container_of(head, struct cls_fl_filter, rcu);
+	struct cls_fl_filter *f = container_of(work, struct cls_fl_filter, work);
 
+	rtnl_lock();
 	tcf_exts_destroy(&f->exts);
 	kfree(f);
+	rtnl_unlock();
+}
+
+static void fl_destroy_filter(struct rcu_head *head)
+{
+	struct cls_fl_filter *f = container_of(head, struct cls_fl_filter, rcu);
+
+	INIT_WORK(&f->work, fl_destroy_filter_work);
+	tcf_queue_work(&f->work);
 }
 
 static void fl_hw_destroy_filter(struct tcf_proto *tp, struct cls_fl_filter *f)
-- 
2.13.0

From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net 10/16] net_sched: use tcf_queue_work() in route filter
Date: Thu, 26 Oct 2017 18:24:37 -0700
Message-ID: <20171027012443.3306-11-xiyou.wangcong@gmail.com>
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
Received: from mail-pg0-f65.google.com ([74.125.83.65]:46471 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932376AbdJ0BZK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 21:25:10 -0400
Received: by mail-pg0-f65.google.com with SMTP id k7so4062345pga.3
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 18:25:10 -0700 (PDT)
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
 net/sched/cls_route.c | 19 ++++++++++++++++---
 1 file changed, 16 insertions(+), 3 deletions(-)

diff --git a/net/sched/cls_route.c b/net/sched/cls_route.c
index 9ddde65915d2..4b14ccd8b8f2 100644
--- a/net/sched/cls_route.c
+++ b/net/sched/cls_route.c
@@ -57,7 +57,10 @@ struct route4_filter {
 	u32			handle;
 	struct route4_bucket	*bkt;
 	struct tcf_proto	*tp;
-	struct rcu_head		rcu;
+	union {
+		struct work_struct	work;
+		struct rcu_head		rcu;
+	};
 };
 
 #define ROUTE4_FAILURE ((struct route4_filter *)(-1L))
@@ -254,12 +257,22 @@ static int route4_init(struct tcf_proto *tp)
 	return 0;
 }
 
-static void route4_delete_filter(struct rcu_head *head)
+static void route4_delete_filter_work(struct work_struct *work)
 {
-	struct route4_filter *f = container_of(head, struct route4_filter, rcu);
+	struct route4_filter *f = container_of(work, struct route4_filter, work);
 
+	rtnl_lock();
 	tcf_exts_destroy(&f->exts);
 	kfree(f);
+	rtnl_unlock();
+}
+
+static void route4_delete_filter(struct rcu_head *head)
+{
+	struct route4_filter *f = container_of(head, struct route4_filter, rcu);
+
+	INIT_WORK(&f->work, route4_delete_filter_work);
+	tcf_queue_work(&f->work);
 }
 
 static void route4_destroy(struct tcf_proto *tp)
-- 
2.13.0

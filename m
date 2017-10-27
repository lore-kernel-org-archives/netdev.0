From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net 12/16] net_sched: use tcf_queue_work() in tcindex filter
Date: Thu, 26 Oct 2017 18:24:39 -0700
Message-ID: <20171027012443.3306-13-xiyou.wangcong@gmail.com>
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
Received: from mail-pg0-f68.google.com ([74.125.83.68]:49073 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932413AbdJ0BZN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 21:25:13 -0400
Received: by mail-pg0-f68.google.com with SMTP id v78so4060054pgb.5
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 18:25:13 -0700 (PDT)
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
 net/sched/cls_tcindex.c | 38 +++++++++++++++++++++++++++++++++-----
 1 file changed, 33 insertions(+), 5 deletions(-)

diff --git a/net/sched/cls_tcindex.c b/net/sched/cls_tcindex.c
index 14a7e08b2fa9..beaa95e09c25 100644
--- a/net/sched/cls_tcindex.c
+++ b/net/sched/cls_tcindex.c
@@ -27,14 +27,20 @@
 struct tcindex_filter_result {
 	struct tcf_exts		exts;
 	struct tcf_result	res;
-	struct rcu_head		rcu;
+	union {
+		struct work_struct	work;
+		struct rcu_head		rcu;
+	};
 };
 
 struct tcindex_filter {
 	u16 key;
 	struct tcindex_filter_result result;
 	struct tcindex_filter __rcu *next;
-	struct rcu_head rcu;
+	union {
+		struct work_struct work;
+		struct rcu_head rcu;
+	};
 };
 
 
@@ -133,12 +139,34 @@ static int tcindex_init(struct tcf_proto *tp)
 	return 0;
 }
 
+static void tcindex_destroy_rexts_work(struct work_struct *work)
+{
+	struct tcindex_filter_result *r;
+
+	r = container_of(work, struct tcindex_filter_result, work);
+	rtnl_lock();
+	tcf_exts_destroy(&r->exts);
+	rtnl_unlock();
+}
+
 static void tcindex_destroy_rexts(struct rcu_head *head)
 {
 	struct tcindex_filter_result *r;
 
 	r = container_of(head, struct tcindex_filter_result, rcu);
-	tcf_exts_destroy(&r->exts);
+	INIT_WORK(&r->work, tcindex_destroy_rexts_work);
+	tcf_queue_work(&r->work);
+}
+
+static void tcindex_destroy_fexts_work(struct work_struct *work)
+{
+	struct tcindex_filter *f = container_of(work, struct tcindex_filter,
+						work);
+
+	rtnl_lock();
+	tcf_exts_destroy(&f->result.exts);
+	kfree(f);
+	rtnl_unlock();
 }
 
 static void tcindex_destroy_fexts(struct rcu_head *head)
@@ -146,8 +174,8 @@ static void tcindex_destroy_fexts(struct rcu_head *head)
 	struct tcindex_filter *f = container_of(head, struct tcindex_filter,
 						rcu);
 
-	tcf_exts_destroy(&f->result.exts);
-	kfree(f);
+	INIT_WORK(&f->work, tcindex_destroy_fexts_work);
+	tcf_queue_work(&f->work);
 }
 
 static int tcindex_delete(struct tcf_proto *tp, void *arg, bool *last)
-- 
2.13.0

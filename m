From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net 09/16] net_sched: use tcf_queue_work() in u32 filter
Date: Thu, 26 Oct 2017 18:24:36 -0700
Message-ID: <20171027012443.3306-10-xiyou.wangcong@gmail.com>
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
Received: from mail-pg0-f66.google.com ([74.125.83.66]:50277 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932345AbdJ0BZJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 21:25:09 -0400
Received: by mail-pg0-f66.google.com with SMTP id y5so4055300pgq.7
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 18:25:09 -0700 (PDT)
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
 net/sched/cls_u32.c | 29 ++++++++++++++++++++++++++---
 1 file changed, 26 insertions(+), 3 deletions(-)

diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index 10b8d851fc6b..dadd1b344497 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -68,7 +68,10 @@ struct tc_u_knode {
 	u32 __percpu		*pcpu_success;
 #endif
 	struct tcf_proto	*tp;
-	struct rcu_head		rcu;
+	union {
+		struct work_struct	work;
+		struct rcu_head		rcu;
+	};
 	/* The 'sel' field MUST be the last field in structure to allow for
 	 * tc_u32_keys allocated at end of structure.
 	 */
@@ -418,11 +421,21 @@ static int u32_destroy_key(struct tcf_proto *tp, struct tc_u_knode *n,
  * this the u32_delete_key_rcu variant does not free the percpu
  * statistics.
  */
+static void u32_delete_key_work(struct work_struct *work)
+{
+	struct tc_u_knode *key = container_of(work, struct tc_u_knode, work);
+
+	rtnl_lock();
+	u32_destroy_key(key->tp, key, false);
+	rtnl_unlock();
+}
+
 static void u32_delete_key_rcu(struct rcu_head *rcu)
 {
 	struct tc_u_knode *key = container_of(rcu, struct tc_u_knode, rcu);
 
-	u32_destroy_key(key->tp, key, false);
+	INIT_WORK(&key->work, u32_delete_key_work);
+	tcf_queue_work(&key->work);
 }
 
 /* u32_delete_key_freepf_rcu is the rcu callback variant
@@ -432,11 +445,21 @@ static void u32_delete_key_rcu(struct rcu_head *rcu)
  * for the variant that should be used with keys return from
  * u32_init_knode()
  */
+static void u32_delete_key_freepf_work(struct work_struct *work)
+{
+	struct tc_u_knode *key = container_of(work, struct tc_u_knode, work);
+
+	rtnl_lock();
+	u32_destroy_key(key->tp, key, true);
+	rtnl_unlock();
+}
+
 static void u32_delete_key_freepf_rcu(struct rcu_head *rcu)
 {
 	struct tc_u_knode *key = container_of(rcu, struct tc_u_knode, rcu);
 
-	u32_destroy_key(key->tp, key, true);
+	INIT_WORK(&key->work, u32_delete_key_freepf_work);
+	tcf_queue_work(&key->work);
 }
 
 static int u32_delete_key(struct tcf_proto *tp, struct tc_u_knode *key)
-- 
2.13.0

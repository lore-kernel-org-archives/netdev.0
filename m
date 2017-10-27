From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net 07/16] net_sched: use tcf_queue_work() in fw filter
Date: Thu, 26 Oct 2017 18:24:34 -0700
Message-ID: <20171027012443.3306-8-xiyou.wangcong@gmail.com>
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
Received: from mail-pf0-f196.google.com ([209.85.192.196]:45023 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752003AbdJ0BZG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 21:25:06 -0400
Received: by mail-pf0-f196.google.com with SMTP id x7so3784249pfa.1
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 18:25:06 -0700 (PDT)
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
 net/sched/cls_fw.c | 19 ++++++++++++++++---
 1 file changed, 16 insertions(+), 3 deletions(-)

diff --git a/net/sched/cls_fw.c b/net/sched/cls_fw.c
index 941245ad07fd..99183b8621ec 100644
--- a/net/sched/cls_fw.c
+++ b/net/sched/cls_fw.c
@@ -46,7 +46,10 @@ struct fw_filter {
 #endif /* CONFIG_NET_CLS_IND */
 	struct tcf_exts		exts;
 	struct tcf_proto	*tp;
-	struct rcu_head		rcu;
+	union {
+		struct work_struct	work;
+		struct rcu_head		rcu;
+	};
 };
 
 static u32 fw_hash(u32 handle)
@@ -119,12 +122,22 @@ static int fw_init(struct tcf_proto *tp)
 	return 0;
 }
 
-static void fw_delete_filter(struct rcu_head *head)
+static void fw_delete_filter_work(struct work_struct *work)
 {
-	struct fw_filter *f = container_of(head, struct fw_filter, rcu);
+	struct fw_filter *f = container_of(work, struct fw_filter, work);
 
+	rtnl_lock();
 	tcf_exts_destroy(&f->exts);
 	kfree(f);
+	rtnl_unlock();
+}
+
+static void fw_delete_filter(struct rcu_head *head)
+{
+	struct fw_filter *f = container_of(head, struct fw_filter, rcu);
+
+	INIT_WORK(&f->work, fw_delete_filter_work);
+	tcf_queue_work(&f->work);
 }
 
 static void fw_destroy(struct tcf_proto *tp)
-- 
2.13.0

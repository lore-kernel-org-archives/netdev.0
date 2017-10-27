From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net 11/16] net_sched: use tcf_queue_work() in rsvp filter
Date: Thu, 26 Oct 2017 18:24:38 -0700
Message-ID: <20171027012443.3306-12-xiyou.wangcong@gmail.com>
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
Received: from mail-pf0-f194.google.com ([209.85.192.194]:46887 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932381AbdJ0BZM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 21:25:12 -0400
Received: by mail-pf0-f194.google.com with SMTP id p87so3779128pfj.3
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 18:25:12 -0700 (PDT)
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
 net/sched/cls_rsvp.h | 19 ++++++++++++++++---
 1 file changed, 16 insertions(+), 3 deletions(-)

diff --git a/net/sched/cls_rsvp.h b/net/sched/cls_rsvp.h
index b1f6ed48bc72..bdbc541787f8 100644
--- a/net/sched/cls_rsvp.h
+++ b/net/sched/cls_rsvp.h
@@ -97,7 +97,10 @@ struct rsvp_filter {
 
 	u32				handle;
 	struct rsvp_session		*sess;
-	struct rcu_head			rcu;
+	union {
+		struct work_struct		work;
+		struct rcu_head			rcu;
+	};
 };
 
 static inline unsigned int hash_dst(__be32 *dst, u8 protocol, u8 tunnelid)
@@ -282,12 +285,22 @@ static int rsvp_init(struct tcf_proto *tp)
 	return -ENOBUFS;
 }
 
-static void rsvp_delete_filter_rcu(struct rcu_head *head)
+static void rsvp_delete_filter_work(struct work_struct *work)
 {
-	struct rsvp_filter *f = container_of(head, struct rsvp_filter, rcu);
+	struct rsvp_filter *f = container_of(work, struct rsvp_filter, work);
 
+	rtnl_lock();
 	tcf_exts_destroy(&f->exts);
 	kfree(f);
+	rtnl_unlock();
+}
+
+static void rsvp_delete_filter_rcu(struct rcu_head *head)
+{
+	struct rsvp_filter *f = container_of(head, struct rsvp_filter, rcu);
+
+	INIT_WORK(&f->work, rsvp_delete_filter_work);
+	tcf_queue_work(&f->work);
 }
 
 static void rsvp_delete_filter(struct tcf_proto *tp, struct rsvp_filter *f)
-- 
2.13.0

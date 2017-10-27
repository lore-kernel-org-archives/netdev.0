From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net 03/16] net_sched: use tcf_queue_work() in bpf filter
Date: Thu, 26 Oct 2017 18:24:30 -0700
Message-ID: <20171027012443.3306-4-xiyou.wangcong@gmail.com>
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
Received: from mail-pf0-f195.google.com ([209.85.192.195]:45732 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751932AbdJ0BZB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 21:25:01 -0400
Received: by mail-pf0-f195.google.com with SMTP id d28so3776422pfe.2
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 18:25:01 -0700 (PDT)
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
 net/sched/cls_bpf.c | 19 +++++++++++++++++--
 1 file changed, 17 insertions(+), 2 deletions(-)

diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index 520c5027646a..037a3ae86829 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -49,7 +49,10 @@ struct cls_bpf_prog {
 	struct sock_filter *bpf_ops;
 	const char *bpf_name;
 	struct tcf_proto *tp;
-	struct rcu_head rcu;
+	union {
+		struct work_struct work;
+		struct rcu_head rcu;
+	};
 };
 
 static const struct nla_policy bpf_policy[TCA_BPF_MAX + 1] = {
@@ -257,9 +260,21 @@ static void __cls_bpf_delete_prog(struct cls_bpf_prog *prog)
 	kfree(prog);
 }
 
+static void cls_bpf_delete_prog_work(struct work_struct *work)
+{
+	struct cls_bpf_prog *prog = container_of(work, struct cls_bpf_prog, work);
+
+	rtnl_lock();
+	__cls_bpf_delete_prog(prog);
+	rtnl_unlock();
+}
+
 static void cls_bpf_delete_prog_rcu(struct rcu_head *rcu)
 {
-	__cls_bpf_delete_prog(container_of(rcu, struct cls_bpf_prog, rcu));
+	struct cls_bpf_prog *prog = container_of(rcu, struct cls_bpf_prog, rcu);
+
+	INIT_WORK(&prog->work, cls_bpf_delete_prog_work);
+	tcf_queue_work(&prog->work);
 }
 
 static void __cls_bpf_delete(struct tcf_proto *tp, struct cls_bpf_prog *prog)
-- 
2.13.0

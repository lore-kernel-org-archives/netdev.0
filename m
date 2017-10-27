From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net 01/16] net_sched: introduce a workqueue for RCU callbacks of tc filter
Date: Thu, 26 Oct 2017 18:24:28 -0700
Message-ID: <20171027012443.3306-2-xiyou.wangcong@gmail.com>
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
Received: from mail-pf0-f196.google.com ([209.85.192.196]:49809 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751947AbdJ0BY7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 21:24:59 -0400
Received: by mail-pf0-f196.google.com with SMTP id i5so3774498pfe.6
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 18:24:59 -0700 (PDT)
In-Reply-To: <20171027012443.3306-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch introduces a dedicated workqueue for tc filters
so that each tc filter's RCU callback could defer their
action destroy work to this workqueue. The helper
tcf_queue_work() is introduced for them to use.

Because we hold RTNL lock when calling tcf_block_put(), we
can not simply flush works inside it, therefore we have to
defer it again to this workqueue and make sure all flying RCU
callbacks have already queued their work before this one, in
other words, to ensure this is the last one to execute to
prevent any use-after-free.

On the other hand, this makes tcf_block_put() ugly and
harder to understand. Since David and Eric strongly dislike
adding synchronize_rcu(), this is probably the only
solution that could make everyone happy.

Please also see the code comments below.

Reported-by: Chris Mi <chrism@mellanox.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Jiri Pirko <jiri@resnulli.us>
Cc: John Fastabend <john.fastabend@gmail.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/pkt_cls.h     |  3 +++
 include/net/sch_generic.h |  2 ++
 net/sched/cls_api.c       | 68 +++++++++++++++++++++++++++++++++++------------
 3 files changed, 56 insertions(+), 17 deletions(-)

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index e80edd8879ef..3009547f3c66 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -2,6 +2,7 @@
 #define __NET_PKT_CLS_H
 
 #include <linux/pkt_cls.h>
+#include <linux/workqueue.h>
 #include <net/sch_generic.h>
 #include <net/act_api.h>
 
@@ -17,6 +18,8 @@ struct tcf_walker {
 int register_tcf_proto_ops(struct tcf_proto_ops *ops);
 int unregister_tcf_proto_ops(struct tcf_proto_ops *ops);
 
+bool tcf_queue_work(struct work_struct *work);
+
 #ifdef CONFIG_NET_CLS
 struct tcf_chain *tcf_chain_get(struct tcf_block *block, u32 chain_index,
 				bool create);
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 135f5a2dd931..0dec8a23be57 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -10,6 +10,7 @@
 #include <linux/dynamic_queue_limits.h>
 #include <linux/list.h>
 #include <linux/refcount.h>
+#include <linux/workqueue.h>
 #include <net/gen_stats.h>
 #include <net/rtnetlink.h>
 
@@ -271,6 +272,7 @@ struct tcf_chain {
 
 struct tcf_block {
 	struct list_head chain_list;
+	struct work_struct work;
 };
 
 static inline void qdisc_cb_private_validate(const struct sk_buff *skb, int sz)
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 0b2219adf520..045d13679ad6 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -77,6 +77,8 @@ int register_tcf_proto_ops(struct tcf_proto_ops *ops)
 }
 EXPORT_SYMBOL(register_tcf_proto_ops);
 
+static struct workqueue_struct *tc_filter_wq;
+
 int unregister_tcf_proto_ops(struct tcf_proto_ops *ops)
 {
 	struct tcf_proto_ops *t;
@@ -86,6 +88,7 @@ int unregister_tcf_proto_ops(struct tcf_proto_ops *ops)
 	 * tcf_proto_ops's destroy() handler.
 	 */
 	rcu_barrier();
+	flush_workqueue(tc_filter_wq);
 
 	write_lock(&cls_mod_lock);
 	list_for_each_entry(t, &tcf_proto_base, head) {
@@ -100,6 +103,12 @@ int unregister_tcf_proto_ops(struct tcf_proto_ops *ops)
 }
 EXPORT_SYMBOL(unregister_tcf_proto_ops);
 
+bool tcf_queue_work(struct work_struct *work)
+{
+	return queue_work(tc_filter_wq, work);
+}
+EXPORT_SYMBOL(tcf_queue_work);
+
 /* Select new prio value from the range, managed by kernel. */
 
 static inline u32 tcf_auto_prio(struct tcf_proto *tp)
@@ -266,23 +275,30 @@ int tcf_block_get(struct tcf_block **p_block,
 }
 EXPORT_SYMBOL(tcf_block_get);
 
-void tcf_block_put(struct tcf_block *block)
+static void tcf_block_put_final(struct work_struct *work)
 {
+	struct tcf_block *block = container_of(work, struct tcf_block, work);
 	struct tcf_chain *chain, *tmp;
 
-	if (!block)
-		return;
-
-	/* XXX: Standalone actions are not allowed to jump to any chain, and
-	 * bound actions should be all removed after flushing. However,
-	 * filters are destroyed in RCU callbacks, we have to hold the chains
-	 * first, otherwise we would always race with RCU callbacks on this list
-	 * without proper locking.
-	 */
+	/* At this point, all the chains should have refcnt == 1. */
+	rtnl_lock();
+	list_for_each_entry_safe(chain, tmp, &block->chain_list, list)
+		tcf_chain_put(chain);
+	rtnl_unlock();
+	kfree(block);
+}
 
-	/* Wait for existing RCU callbacks to cool down. */
-	rcu_barrier();
+/* XXX: Standalone actions are not allowed to jump to any chain, and bound
+ * actions should be all removed after flushing. However, filters are destroyed
+ * in RCU callbacks, we have to hold the chains first, otherwise we would
+ * always race with RCU callbacks on this list without proper locking.
+ */
+static void tcf_block_put_deferred(struct work_struct *work)
+{
+	struct tcf_block *block = container_of(work, struct tcf_block, work);
+	struct tcf_chain *chain;
 
+	rtnl_lock();
 	/* Hold a refcnt for all chains, except 0, in case they are gone. */
 	list_for_each_entry(chain, &block->chain_list, list)
 		if (chain->index)
@@ -292,13 +308,27 @@ void tcf_block_put(struct tcf_block *block)
 	list_for_each_entry(chain, &block->chain_list, list)
 		tcf_chain_flush(chain);
 
-	/* Wait for RCU callbacks to release the reference count. */
+	INIT_WORK(&block->work, tcf_block_put_final);
+	/* Wait for RCU callbacks to release the reference count and make
+	 * sure their works have been queued before this.
+	 */
 	rcu_barrier();
+	tcf_queue_work(&block->work);
+	rtnl_unlock();
+}
 
-	/* At this point, all the chains should have refcnt == 1. */
-	list_for_each_entry_safe(chain, tmp, &block->chain_list, list)
-		tcf_chain_put(chain);
-	kfree(block);
+void tcf_block_put(struct tcf_block *block)
+{
+	if (!block)
+		return;
+
+	INIT_WORK(&block->work, tcf_block_put_deferred);
+	/* Wait for existing RCU callbacks to cool down, make sure their works
+	 * have been queued before this. We can not flush pending works here
+	 * because we are holding the RTNL lock.
+	 */
+	rcu_barrier();
+	tcf_queue_work(&block->work);
 }
 EXPORT_SYMBOL(tcf_block_put);
 
@@ -1030,6 +1060,10 @@ EXPORT_SYMBOL(tcf_exts_get_dev);
 
 static int __init tc_filter_init(void)
 {
+	tc_filter_wq = alloc_ordered_workqueue("tc_filter_workqueue", 0);
+	if (!tc_filter_wq)
+		return -ENOMEM;
+
 	rtnl_register(PF_UNSPEC, RTM_NEWTFILTER, tc_ctl_tfilter, NULL, 0);
 	rtnl_register(PF_UNSPEC, RTM_DELTFILTER, tc_ctl_tfilter, NULL, 0);
 	rtnl_register(PF_UNSPEC, RTM_GETTFILTER, tc_ctl_tfilter,
-- 
2.13.0

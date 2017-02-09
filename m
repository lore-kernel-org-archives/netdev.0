From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/6] sched: move tcf_proto_destroy and tcf_destroy_chain helpers into cls_api
Date: Thu,  9 Feb 2017 14:38:56 +0100
Message-ID: <1486647540-14656-3-git-send-email-jiri@resnulli.us>
References: <1486647540-14656-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:38782 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752445AbdBIOhZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 09:37:25 -0500
Received: by mail-wm0-f54.google.com with SMTP id r141so21176923wmg.1
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 06:37:21 -0800 (PST)
In-Reply-To: <1486647540-14656-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Creation is done in this file, move destruction to be at the same place.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/pkt_cls.h     |  2 ++
 include/net/sch_generic.h |  2 --
 net/sched/cls_api.c       | 21 +++++++++++++++++++++
 net/sched/sch_api.c       | 22 ----------------------
 net/sched/sch_atm.c       |  1 +
 net/sched/sch_cbq.c       |  1 +
 net/sched/sch_choke.c     |  1 +
 net/sched/sch_dsmark.c    |  1 +
 net/sched/sch_fq_codel.c  |  1 +
 net/sched/sch_htb.c       |  1 +
 net/sched/sch_ingress.c   |  1 +
 net/sched/sch_multiq.c    |  2 +-
 net/sched/sch_prio.c      |  2 +-
 net/sched/sch_sfb.c       |  1 +
 net/sched/sch_sfq.c       |  1 +
 15 files changed, 34 insertions(+), 26 deletions(-)

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index dabb00a..71b266c 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -17,6 +17,8 @@ struct tcf_walker {
 int register_tcf_proto_ops(struct tcf_proto_ops *ops);
 int unregister_tcf_proto_ops(struct tcf_proto_ops *ops);
 
+void tcf_destroy_chain(struct tcf_proto __rcu **fl);
+
 static inline unsigned long
 __cls_set_class(unsigned long *clp, unsigned long cl)
 {
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 4533506..aeec408 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -405,8 +405,6 @@ struct Qdisc *qdisc_create_dflt(struct netdev_queue *dev_queue,
 				const struct Qdisc_ops *ops, u32 parentid);
 void __qdisc_calculate_pkt_len(struct sk_buff *skb,
 			       const struct qdisc_size_table *stab);
-bool tcf_proto_destroy(struct tcf_proto *tp, bool force);
-void tcf_destroy_chain(struct tcf_proto __rcu **fl);
 int skb_do_redirect(struct sk_buff *);
 
 static inline void skb_reset_tc(struct sk_buff *skb)
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 90536eb..4efa4df 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -127,6 +127,27 @@ static inline u32 tcf_auto_prio(struct tcf_proto *tp)
 	return first;
 }
 
+static bool tcf_proto_destroy(struct tcf_proto *tp, bool force)
+{
+	if (tp->ops->destroy(tp, force)) {
+		module_put(tp->ops->owner);
+		kfree_rcu(tp, rcu);
+		return true;
+	}
+	return false;
+}
+
+void tcf_destroy_chain(struct tcf_proto __rcu **fl)
+{
+	struct tcf_proto *tp;
+
+	while ((tp = rtnl_dereference(*fl)) != NULL) {
+		RCU_INIT_POINTER(*fl, tp->next);
+		tcf_proto_destroy(tp, true);
+	}
+}
+EXPORT_SYMBOL(tcf_destroy_chain);
+
 /* Add/change/delete/get a filter node */
 
 static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n)
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index f30b517..adeabae 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1900,28 +1900,6 @@ int tc_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 }
 EXPORT_SYMBOL(tc_classify);
 
-bool tcf_proto_destroy(struct tcf_proto *tp, bool force)
-{
-	if (tp->ops->destroy(tp, force)) {
-		module_put(tp->ops->owner);
-		kfree_rcu(tp, rcu);
-		return true;
-	}
-
-	return false;
-}
-
-void tcf_destroy_chain(struct tcf_proto __rcu **fl)
-{
-	struct tcf_proto *tp;
-
-	while ((tp = rtnl_dereference(*fl)) != NULL) {
-		RCU_INIT_POINTER(*fl, tp->next);
-		tcf_proto_destroy(tp, true);
-	}
-}
-EXPORT_SYMBOL(tcf_destroy_chain);
-
 #ifdef CONFIG_PROC_FS
 static int psched_show(struct seq_file *seq, void *v)
 {
diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index 481e4f1..2209c2d 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -15,6 +15,7 @@
 #include <linux/file.h>		/* for fput */
 #include <net/netlink.h>
 #include <net/pkt_sched.h>
+#include <net/pkt_cls.h>
 
 /*
  * The ATM queuing discipline provides a framework for invoking classifiers
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index f120758..d6ca18dc 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -19,6 +19,7 @@
 #include <linux/skbuff.h>
 #include <net/netlink.h>
 #include <net/pkt_sched.h>
+#include <net/pkt_cls.h>
 
 
 /*	Class-Based Queueing (CBQ) algorithm.
diff --git a/net/sched/sch_choke.c b/net/sched/sch_choke.c
index 3b6d5bd..3b86a97 100644
--- a/net/sched/sch_choke.c
+++ b/net/sched/sch_choke.c
@@ -16,6 +16,7 @@
 #include <linux/skbuff.h>
 #include <linux/vmalloc.h>
 #include <net/pkt_sched.h>
+#include <net/pkt_cls.h>
 #include <net/inet_ecn.h>
 #include <net/red.h>
 #include <net/flow_dissector.h>
diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index 1308bbf..802ac7c 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -13,6 +13,7 @@
 #include <linux/rtnetlink.h>
 #include <linux/bitops.h>
 #include <net/pkt_sched.h>
+#include <net/pkt_cls.h>
 #include <net/dsfield.h>
 #include <net/inet_ecn.h>
 #include <asm/byteorder.h>
diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
index 2f50e4c..9f3a884 100644
--- a/net/sched/sch_fq_codel.c
+++ b/net/sched/sch_fq_codel.c
@@ -23,6 +23,7 @@
 #include <linux/vmalloc.h>
 #include <net/netlink.h>
 #include <net/pkt_sched.h>
+#include <net/pkt_cls.h>
 #include <net/codel.h>
 #include <net/codel_impl.h>
 #include <net/codel_qdisc.h>
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 760f39e..4cd5fb1 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -40,6 +40,7 @@
 #include <net/netlink.h>
 #include <net/sch_generic.h>
 #include <net/pkt_sched.h>
+#include <net/pkt_cls.h>
 
 /* HTB algorithm.
     Author: devik@cdi.cz
diff --git a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
index 8fe6999..3bab5f6 100644
--- a/net/sched/sch_ingress.c
+++ b/net/sched/sch_ingress.c
@@ -16,6 +16,7 @@
 
 #include <net/netlink.h>
 #include <net/pkt_sched.h>
+#include <net/pkt_cls.h>
 
 static struct Qdisc *ingress_leaf(struct Qdisc *sch, unsigned long arg)
 {
diff --git a/net/sched/sch_multiq.c b/net/sched/sch_multiq.c
index 9ffbb02..e7839a0 100644
--- a/net/sched/sch_multiq.c
+++ b/net/sched/sch_multiq.c
@@ -25,7 +25,7 @@
 #include <linux/skbuff.h>
 #include <net/netlink.h>
 #include <net/pkt_sched.h>
-
+#include <net/pkt_cls.h>
 
 struct multiq_sched_data {
 	u16 bands;
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index 8f57589..d4d7db2 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -20,7 +20,7 @@
 #include <linux/skbuff.h>
 #include <net/netlink.h>
 #include <net/pkt_sched.h>
-
+#include <net/pkt_cls.h>
 
 struct prio_sched_data {
 	int bands;
diff --git a/net/sched/sch_sfb.c b/net/sched/sch_sfb.c
index 20a350b..fe6963d 100644
--- a/net/sched/sch_sfb.c
+++ b/net/sched/sch_sfb.c
@@ -25,6 +25,7 @@
 #include <linux/jhash.h>
 #include <net/ip.h>
 #include <net/pkt_sched.h>
+#include <net/pkt_cls.h>
 #include <net/inet_ecn.h>
 
 /*
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 7f195ed..83d06e2 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -23,6 +23,7 @@
 #include <linux/vmalloc.h>
 #include <net/netlink.h>
 #include <net/pkt_sched.h>
+#include <net/pkt_cls.h>
 #include <net/red.h>
 
 
-- 
2.7.4

From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] qdisc: allow setting default queuing discipline
Date: Tue, 27 Aug 2013 16:19:08 -0700
Message-ID: <20130827161908.26062336@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:44596 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751522Ab3H0XTM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 19:19:12 -0400
Received: by mail-pd0-f169.google.com with SMTP id r10so5542026pdi.28
        for <netdev@vger.kernel.org>; Tue, 27 Aug 2013 16:19:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By default, the pfifo_fast queue discipline has been used by default
for all devices. But we have better choices now.

This patch allow setting the default queueing discipline with sysctl.
This allows easy use of better queueing disciplines on all devices
without having to use tc qdisc scripts. It is intended to allow
an easy path for distributions to make fq_codel or sfq the default
qdisc.

This patch also makes pfifo_fast more of a first class qdisc, since
it is now possible to manually override the default and explicitly
use pfifo_fast. The behavior for systems who do not use the sysctl
is unchanged, they still get pfifo_fast

Also removes leftover random # in sysctl net core.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

---
 Documentation/sysctl/net.txt |   13 +++++++++
 include/net/pkt_sched.h      |    3 ++
 include/net/sch_generic.h    |    1 
 net/core/sysctl_net_core.c   |   30 +++++++++++++++++++++-
 net/sched/sch_api.c          |   58 +++++++++++++++++++++++++++++++++++++++++++
 net/sched/sch_generic.c      |   11 ++++----
 net/sched/sch_mq.c           |    2 -
 net/sched/sch_mqprio.c       |    2 -
 8 files changed, 112 insertions(+), 8 deletions(-)

--- a/net/core/sysctl_net_core.c	2013-08-25 22:08:17.927755151 -0700
+++ b/net/core/sysctl_net_core.c	2013-08-25 22:09:21.918913894 -0700
@@ -20,6 +20,7 @@
 #include <net/sock.h>
 #include <net/net_ratelimit.h>
 #include <net/busy_poll.h>
+#include <net/pkt_sched.h>
 
 static int zero = 0;
 static int one = 1;
@@ -193,6 +194,26 @@ static int flow_limit_table_len_sysctl(s
 }
 #endif /* CONFIG_NET_FLOW_LIMIT */
 
+#ifdef CONFIG_NET_SCHED
+static int set_default_qdisc(struct ctl_table *table, int write,
+			     void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	char id[IFNAMSIZ];
+	struct ctl_table tbl = {
+		.data = id,
+		.maxlen = IFNAMSIZ,
+	};
+	int ret;
+
+	qdisc_get_default(id, IFNAMSIZ);
+
+	ret = proc_dostring(&tbl, write, buffer, lenp, ppos);
+	if (write && ret == 0)
+		ret = qdisc_set_default(id);
+	return ret;
+}
+#endif
+
 static struct ctl_table net_core_table[] = {
 #ifdef CONFIG_NET
 	{
@@ -315,7 +336,14 @@ static struct ctl_table net_core_table[]
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
-#
+#endif
+#ifdef CONFIG_NET_SCHED
+	{
+		.procname	= "default_qdisc",
+		.mode		= 0644,
+		.maxlen		= IFNAMSIZ,
+		.proc_handler	= set_default_qdisc
+	},
 #endif
 #endif /* CONFIG_NET */
 	{
--- a/include/net/pkt_sched.h	2013-08-25 22:08:17.927755151 -0700
+++ b/include/net/pkt_sched.h	2013-08-25 22:09:21.918913894 -0700
@@ -85,6 +85,9 @@ struct Qdisc *fifo_create_dflt(struct Qd
 
 int register_qdisc(struct Qdisc_ops *qops);
 int unregister_qdisc(struct Qdisc_ops *qops);
+void qdisc_get_default(char *id, size_t len);
+int qdisc_set_default(const char *id);
+
 void qdisc_list_del(struct Qdisc *q);
 struct Qdisc *qdisc_lookup(struct net_device *dev, u32 handle);
 struct Qdisc *qdisc_lookup_class(struct net_device *dev, u32 handle);
--- a/include/net/sch_generic.h	2013-08-25 22:08:19.703731803 -0700
+++ b/include/net/sch_generic.h	2013-08-26 08:27:55.003303740 -0700
@@ -316,6 +316,7 @@ extern struct Qdisc noop_qdisc;
 extern struct Qdisc_ops noop_qdisc_ops;
 extern struct Qdisc_ops pfifo_fast_ops;
 extern struct Qdisc_ops mq_qdisc_ops;
+extern const struct Qdisc_ops *default_qdisc_ops;
 
 struct Qdisc_class_common {
 	u32			classid;
--- a/net/sched/sch_api.c	2013-08-25 22:08:17.927755151 -0700
+++ b/net/sched/sch_api.c	2013-08-26 08:35:17.793894501 -0700
@@ -131,6 +131,11 @@ static DEFINE_RWLOCK(qdisc_mod_lock);
  ************************************************/
 
 
+/* Qdisc to use by default */
+
+const struct Qdisc_ops *default_qdisc_ops = &pfifo_fast_ops;
+EXPORT_SYMBOL(default_qdisc_ops);
+
 /* The list of all installed queueing disciplines. */
 
 static struct Qdisc_ops *qdisc_base;
@@ -200,6 +205,58 @@ int unregister_qdisc(struct Qdisc_ops *q
 }
 EXPORT_SYMBOL(unregister_qdisc);
 
+/* Get default qdisc if not otherwise specified */
+void qdisc_get_default(char *name, size_t len)
+{
+	read_lock(&qdisc_mod_lock);
+	strlcpy(name, default_qdisc_ops->id, len);
+	read_unlock(&qdisc_mod_lock);
+}
+
+static struct Qdisc_ops *qdisc_lookup_default(const char *name)
+{
+	struct Qdisc_ops *q = NULL;
+
+	for (q = qdisc_base; q; q = q->next) {
+		if (!strcmp(name, q->id)) {
+			if (!try_module_get(q->owner))
+				q = NULL;
+			break;
+		}
+	}
+
+	return q;
+}
+
+/* Set new default qdisc to use */
+int qdisc_set_default(const char *name)
+{
+	const struct Qdisc_ops *ops;
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	write_lock(&qdisc_mod_lock);
+	ops = qdisc_lookup_default(name);
+	if (!ops) {
+		/* Not found, drop lock and try to load module */
+		write_unlock(&qdisc_mod_lock);
+		request_module("sch_%s", name);
+		write_lock(&qdisc_mod_lock);
+
+		ops = qdisc_lookup_default(name);
+	}
+
+	if (ops) {
+		/* Set new default */
+		module_put(default_qdisc_ops->owner);
+		default_qdisc_ops = ops;
+	}
+	write_unlock(&qdisc_mod_lock);
+
+	return ops ? 0 : -ENOENT;
+}
+
 /* We know handle. Find qdisc among all qdisc's attached to device
    (root qdisc, all its children, children of children etc.)
  */
@@ -1854,6 +1911,7 @@ static int __init pktsched_init(void)
 		return err;
 	}
 
+	register_qdisc(&pfifo_fast_ops);
 	register_qdisc(&pfifo_qdisc_ops);
 	register_qdisc(&bfifo_qdisc_ops);
 	register_qdisc(&pfifo_head_drop_qdisc_ops);
--- a/net/sched/sch_generic.c	2013-08-25 22:08:51.911308395 -0700
+++ b/net/sched/sch_generic.c	2013-08-26 08:27:27.819607861 -0700
@@ -530,7 +530,6 @@ struct Qdisc_ops pfifo_fast_ops __read_m
 	.dump		=	pfifo_fast_dump,
 	.owner		=	THIS_MODULE,
 };
-EXPORT_SYMBOL(pfifo_fast_ops);
 
 static struct lock_class_key qdisc_tx_busylock;
 
@@ -584,6 +583,9 @@ struct Qdisc *qdisc_create_dflt(struct n
 {
 	struct Qdisc *sch;
 
+	if (!try_module_get(ops->owner))
+		goto errout;
+
 	sch = qdisc_alloc(dev_queue, ops);
 	if (IS_ERR(sch))
 		goto errout;
@@ -687,7 +689,7 @@ static void attach_one_default_qdisc(str
 
 	if (dev->tx_queue_len) {
 		qdisc = qdisc_create_dflt(dev_queue,
-					  &pfifo_fast_ops, TC_H_ROOT);
+					  default_qdisc_ops, TC_H_ROOT);
 		if (!qdisc) {
 			netdev_info(dev, "activation failed\n");
 			return;
@@ -740,9 +742,8 @@ void dev_activate(struct net_device *dev
 	int need_watchdog;
 
 	/* No queueing discipline is attached to device;
-	   create default one i.e. pfifo_fast for devices,
-	   which need queueing and noqueue_qdisc for
-	   virtual interfaces
+	 * create default one for devices, which need queueing
+	 * and noqueue_qdisc for virtual interfaces
 	 */
 
 	if (dev->qdisc == &noop_qdisc)
--- a/net/sched/sch_mq.c	2013-08-25 22:08:17.927755151 -0700
+++ b/net/sched/sch_mq.c	2013-08-25 22:09:21.918913894 -0700
@@ -57,7 +57,7 @@ static int mq_init(struct Qdisc *sch, st
 
 	for (ntx = 0; ntx < dev->num_tx_queues; ntx++) {
 		dev_queue = netdev_get_tx_queue(dev, ntx);
-		qdisc = qdisc_create_dflt(dev_queue, &pfifo_fast_ops,
+		qdisc = qdisc_create_dflt(dev_queue, default_qdisc_ops,
 					  TC_H_MAKE(TC_H_MAJ(sch->handle),
 						    TC_H_MIN(ntx + 1)));
 		if (qdisc == NULL)
--- a/net/sched/sch_mqprio.c	2013-08-25 22:08:17.927755151 -0700
+++ b/net/sched/sch_mqprio.c	2013-08-25 22:09:21.918913894 -0700
@@ -124,7 +124,7 @@ static int mqprio_init(struct Qdisc *sch
 
 	for (i = 0; i < dev->num_tx_queues; i++) {
 		dev_queue = netdev_get_tx_queue(dev, i);
-		qdisc = qdisc_create_dflt(dev_queue, &pfifo_fast_ops,
+		qdisc = qdisc_create_dflt(dev_queue, default_qdisc_ops,
 					  TC_H_MAKE(TC_H_MAJ(sch->handle),
 						    TC_H_MIN(i + 1)));
 		if (qdisc == NULL) {
--- a/Documentation/sysctl/net.txt	2013-08-10 10:36:08.097545035 -0700
+++ b/Documentation/sysctl/net.txt	2013-08-25 22:37:26.658331785 -0700
@@ -50,6 +50,19 @@ The maximum number of packets that kerne
 it's a Per-CPU variable.
 Default: 64
 
+default_qdisc
+--------------
+
+The default queuing discipline to use for network devices. This allows
+overriding the default queue discipline of pfifo_fast with an
+alternative. Since the default queuing discipline is created with the
+no additional parameters so is best suited to queuing disciplines that
+work well without configuration like stochastic fair queue (sfq),
+CoDel (codel) or fair queue CoDel (fq_codel). Dont' use queuing disciplines
+like Hierarchical Token Bucket or Deficit Round Robin which require setting
+up classes and bandwidths.
+Default: pfifo_fast
+
 busy_read
 ----------------
 Low latency busy poll timeout for socket reads. (needs CONFIG_NET_RX_BUSY_POLL)

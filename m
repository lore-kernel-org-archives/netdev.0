From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [RFC net-next] net: sch_clsact: add support for global per-netns classifier mode
Date: Tue,  5 Sep 2017 15:48:21 +0300
Message-ID: <1504615701-20912-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, dsa@cumulusnetworks.com,
        jiri@resnulli.us, xiyou.wangcong@gmail.com, jhs@mojatatu.com,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:35233 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751031AbdIENKX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2017 09:10:23 -0400
Received: by mail-wm0-f47.google.com with SMTP id h144so5278375wme.0
        for <netdev@vger.kernel.org>; Tue, 05 Sep 2017 06:10:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,
This RFC adds a new mode for clsact which designates a device's egress
classifier as global per netns. The packets that are not classified for
a particular device will be classified using the global classifier.
We have needed a global classifier for some time now for various
purposes and setting the single bridge or loopback/vrf device as the
global classifier device is acceptable for us. Doing it this way avoids
the act/cls device and queue dependencies.

This is strictly an RFC patch just to show the intent, if we agree on
the details the proposed patch will have support for both ingress and
egress, and will be using a static key to avoid the fast path test when no
global classifier has been configured.

Example (need a modified tc that adds TCA_OPTIONS when using q_clsact):
$ tc qdisc add dev lo clsact global
$ tc filter add dev lo egress protocol ip u32 match ip dst 4.3.2.1/32 action drop

the last filter will be global for all devices that don't have a
specific egress_cl_list (i.e. have clsact configured).

Any comments and thoughts would be greatly appreciated.

Thanks!

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 include/linux/rtnetlink.h   |  1 +
 include/net/net_namespace.h |  3 +++
 include/net/sch_generic.h   |  1 +
 net/core/dev.c              | 36 ++++++++++++++++++++++++++++++++++--
 net/sched/sch_ingress.c     | 15 +++++++++++++--
 5 files changed, 52 insertions(+), 4 deletions(-)

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index dea59c8eec54..cb97973b8555 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -88,6 +88,7 @@ void net_dec_ingress_queue(void);
 #ifdef CONFIG_NET_EGRESS
 void net_inc_egress_queue(void);
 void net_dec_egress_queue(void);
+int net_set_global_egress_cls_dev(struct net *net, struct net_device *dev);
 #endif
 
 void rtnetlink_init(void);
diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 57faa375eab9..3fef53dfdbfc 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -149,6 +149,9 @@ struct net {
 #endif
 	struct sock		*diag_nlsk;
 	atomic_t		fnhe_genid;
+#ifdef CONFIG_NET_EGRESS
+	struct net_device __rcu *global_egress_dev;
+#endif
 } __randomize_layout;
 
 #include <linux/seq_file_net.h>
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 135f5a2dd931..a37c37062446 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -69,6 +69,7 @@ struct Qdisc {
 				      * qdisc_tree_decrease_qlen() should stop.
 				      */
 #define TCQ_F_INVISIBLE		0x80 /* invisible by default in dump */
+#define TCQ_F_GLOBAL		0x100 /* device is used as global clsact dev */
 	u32			limit;
 	const struct Qdisc_ops	*ops;
 	struct qdisc_size_table	__rcu *stab;
diff --git a/net/core/dev.c b/net/core/dev.c
index 6f845e4fec17..cf883b2470a5 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1718,6 +1718,31 @@ void net_dec_egress_queue(void)
 	static_key_slow_dec(&egress_needed);
 }
 EXPORT_SYMBOL_GPL(net_dec_egress_queue);
+
+int net_set_global_egress_cls_dev(struct net *net, struct net_device *dev)
+{
+	struct net_device *cur_dev;
+
+	ASSERT_RTNL();
+
+	cur_dev = rtnl_dereference(net->global_egress_dev);
+	if (dev) {
+		/* replace not allowed */
+		if (cur_dev)
+			return -EBUSY;
+		/* global cls devices should not change netns */
+		if (!(dev->features & NETIF_F_NETNS_LOCAL))
+			return -EINVAL;
+	}
+
+	/* set or clear based on dev */
+	rcu_assign_pointer(net->global_egress_dev, dev);
+	if (!dev)
+		synchronize_rcu_bh();
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(net_set_global_egress_cls_dev);
 #endif
 
 static struct static_key netstamp_needed __read_mostly;
@@ -3244,8 +3269,15 @@ sch_handle_egress(struct sk_buff *skb, int *ret, struct net_device *dev)
 	struct tcf_proto *cl = rcu_dereference_bh(dev->egress_cl_list);
 	struct tcf_result cl_res;
 
-	if (!cl)
-		return skb;
+	if (!cl) {
+		struct net_device *gdev;
+
+		gdev = rcu_dereference_bh(dev_net(dev)->global_egress_dev);
+		if (gdev)
+			cl = rcu_dereference_bh(gdev->egress_cl_list);
+		if (!cl)
+			return skb;
+	}
 
 	/* qdisc_skb_cb(skb)->pkt_len was already set by the caller. */
 	qdisc_bstats_cpu_update(cl->q, skb);
diff --git a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
index 44de4ee51ce9..a4871f138904 100644
--- a/net/sched/sch_ingress.c
+++ b/net/sched/sch_ingress.c
@@ -153,6 +153,9 @@ static int clsact_init(struct Qdisc *sch, struct nlattr *opt)
 	struct net_device *dev = qdisc_dev(sch);
 	int err;
 
+	net_inc_ingress_queue();
+	net_inc_egress_queue();
+
 	err = tcf_block_get(&q->ingress_block, &dev->ingress_cl_list);
 	if (err)
 		return err;
@@ -161,8 +164,12 @@ static int clsact_init(struct Qdisc *sch, struct nlattr *opt)
 	if (err)
 		return err;
 
-	net_inc_ingress_queue();
-	net_inc_egress_queue();
+	if (opt) {
+		err = net_set_global_egress_cls_dev(dev_net(dev), dev);
+		if (err)
+			return err;
+		sch->flags |= TCQ_F_GLOBAL;
+	}
 
 	sch->flags |= TCQ_F_CPUSTATS;
 
@@ -172,6 +179,10 @@ static int clsact_init(struct Qdisc *sch, struct nlattr *opt)
 static void clsact_destroy(struct Qdisc *sch)
 {
 	struct clsact_sched_data *q = qdisc_priv(sch);
+	struct net_device *dev = qdisc_dev(sch);
+
+	if (sch->flags & TCQ_F_GLOBAL)
+		WARN_ON_ONCE(net_set_global_egress_cls_dev(dev_net(dev), NULL));
 
 	tcf_block_put(q->egress_block);
 	tcf_block_put(q->ingress_block);
-- 
2.1.4

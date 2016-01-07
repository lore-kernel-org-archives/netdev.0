From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next v2] net, sched: add clsact qdisc
Date: Thu,  7 Jan 2016 22:29:47 +0100
Message-ID: <61198814638d88ce3555dbecf8ef875523b95743.1452197856.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, jhs@mojatatu.com,
	john.fastabend@gmail.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:52442 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752525AbcAGV34 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 16:29:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This work adds a generalization of the ingress qdisc as a qdisc holding
only classifiers. The clsact qdisc works on ingress, but also on egress.
In both cases, it's execution happens without taking the qdisc lock, and
the main difference for the egress part compared to prior version of [1]
is that this can be applied with _any_ underlying real egress qdisc (also
classless ones).

Besides solving the use-case of [1], that is, allowing for more programmability
on assigning skb->priority for the mqprio case that is supported by most
popular 10G+ NICs, it also opens up a lot more flexibility for other tc
applications. The main work on classification can already be done at clsact
egress time if the use-case allows and state stored for later retrieval
f.e. again in skb->priority with major/minors (which is checked by most
classful qdiscs before consulting tc_classify()) and/or in other skb fields
like skb->tc_index for some light-weight post-processing to get to the
eventual classid in case of a classful qdisc. Another use case is that
the clsact egress part allows to have a central egress counterpart to
the ingress classifiers, so that classifiers can easily share state (e.g.
in cls_bpf via eBPF maps) for ingress and egress.

Currently, default setups like mq + pfifo_fast would require for this to
use, for example, prio qdisc instead (to get a tc_classify() run) and to
duplicate the egress classifier for each queue. With clsact, it allows
for leaving the setup as is, it can additionally assign skb->priority to
put the skb in one of pfifo_fast's bands and it can share state with maps.
Moreover, we can access the skb's dst entry (f.e. to retrieve tclassid)
w/o the need to perform a skb_dst_force() to hold on to it any longer. In
lwt case, we can also use this facility to setup dst metadata via cls_bpf
(bpf_skb_set_tunnel_key()) without needing a real egress qdisc just for
that (case of IFF_NO_QUEUE devices, for example).

The realization can be done without any changes to the scheduler core
framework. All it takes is that we have two a-priori defined minors/child
classes, where we can mux between ingress and egress classifier list
(dev->ingress_cl_list and dev->egress_cl_list, latter stored close to
dev->_tx to avoid extra cacheline miss for moderate loads). The egress
part is a bit similar modelled to handle_ing() and patched to a noop in
case the functionality is not used. Both handlers are now called
sch_handle_ingress() and sch_handle_egress(), code sharing among the two
doesn't seem practical as there are various minor differences in both
paths, so that making them conditional in a single handler would rather
slow things down.

Full compatibility to ingress qdisc is provided as well. Since both
piggyback on TC_H_CLSACT, only one of them (ingress/clsact) can exist
per netdevice, and thus ingress qdisc specific behaviour can be retained
for user space. This means, either a user does 'tc qdisc add dev foo ingress'
and configures ingress qdisc as usual, or the 'tc qdisc add dev foo clsact'
alternative, where both, ingress and egress classifier can be configured
as in the below example. ingress qdisc supports attaching classifier to any
minor number whereas clsact has two fixed minors for muxing between the
lists, therefore to not break user space setups, they are better done as
two separate qdiscs.

I decided to extend the sch_ingress module with clsact functionality so
that commonly used code can be reused, the module is being aliased with
sch_clsact so that it can be auto-loaded properly. Alternative would have been
to add a flag when initializing ingress to alter its behaviour plus aliasing
to a different name (as it's more than just ingress). However, the first would
end up, based on the flag, choosing the new/old behaviour by calling different
function implementations to handle each anyway, the latter would require to
register ingress qdisc once again under different alias. So, this really begs
to provide a minimal, cleaner approach to have Qdisc_ops and Qdisc_class_ops
by its own that share callbacks used by both.

Example, adding qdisc:

   # tc qdisc add dev foo clsact
   # tc qdisc show dev foo
   qdisc mq 0: root
   qdisc pfifo_fast 0: parent :1 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
   qdisc pfifo_fast 0: parent :2 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
   qdisc pfifo_fast 0: parent :3 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
   qdisc pfifo_fast 0: parent :4 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
   qdisc clsact ffff: parent ffff:fff1

Adding filters (deleting, etc works analogous by specifying ingress/egress):

   # tc filter add dev foo ingress bpf da obj bar.o sec ingress
   # tc filter add dev foo egress  bpf da obj bar.o sec egress
   # tc filter show dev foo ingress
   filter protocol all pref 49152 bpf
   filter protocol all pref 49152 bpf handle 0x1 bar.o:[ingress] direct-action
   # tc filter show dev foo egress
   filter protocol all pref 49152 bpf
   filter protocol all pref 49152 bpf handle 0x1 bar.o:[egress] direct-action

A 'tc filter show dev foo' or 'tc filter show dev foo parent ffff:' will
show an empty list for clsact. Either using the parent names (ingress/egress)
or specifying the full major/minor will then show the related filter lists.

Prior work on a mqprio prequeue() facility [1] was done mainly by John Fastabend.

  [1] http://patchwork.ozlabs.org/patch/512949/

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 v1 -> v2:
  - Moved qdisc_pkt_len_init(), thanks Eric!

 ( Note, I took out internal renaming of TCQ_F_INGRESS, TC_H_INGRESS etc from
   this patch [set] as it's not really necessary for this functionality to work.
   If really wished, I could follow-up with renaming these into something more
   generic in sch_api.c etc as well. )

 include/linux/netdevice.h      |  4 +-
 include/linux/rtnetlink.h      |  5 +++
 include/uapi/linux/pkt_sched.h |  4 ++
 net/Kconfig                    |  3 ++
 net/core/dev.c                 | 82 +++++++++++++++++++++++++++++++++++----
 net/sched/Kconfig              | 14 +++++--
 net/sched/cls_bpf.c            |  2 +-
 net/sched/sch_ingress.c        | 88 +++++++++++++++++++++++++++++++++++++++++-
 8 files changed, 186 insertions(+), 16 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 8d8e5ca..2285596 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1739,7 +1739,9 @@ struct net_device {
 #ifdef CONFIG_XPS
 	struct xps_dev_maps __rcu *xps_maps;
 #endif
-
+#ifdef CONFIG_NET_CLS_ACT
+	struct tcf_proto __rcu  *egress_cl_list;
+#endif
 #ifdef CONFIG_NET_SWITCHDEV
 	u32			offload_fwd_mark;
 #endif
diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 4be5048..c006cc9 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -84,6 +84,11 @@ void net_inc_ingress_queue(void);
 void net_dec_ingress_queue(void);
 #endif
 
+#ifdef CONFIG_NET_EGRESS
+void net_inc_egress_queue(void);
+void net_dec_egress_queue(void);
+#endif
+
 extern void rtnetlink_init(void);
 extern void __rtnl_unlock(void);
 
diff --git a/include/uapi/linux/pkt_sched.h b/include/uapi/linux/pkt_sched.h
index 8d2530d..8cb18b4 100644
--- a/include/uapi/linux/pkt_sched.h
+++ b/include/uapi/linux/pkt_sched.h
@@ -72,6 +72,10 @@ struct tc_estimator {
 #define TC_H_UNSPEC	(0U)
 #define TC_H_ROOT	(0xFFFFFFFFU)
 #define TC_H_INGRESS    (0xFFFFFFF1U)
+#define TC_H_CLSACT	TC_H_INGRESS
+
+#define TC_H_MIN_INGRESS	0xFFF2U
+#define TC_H_MIN_EGRESS		0xFFF3U
 
 /* Need to corrospond to iproute2 tc/tc_core.h "enum link_layer" */
 enum tc_link_layer {
diff --git a/net/Kconfig b/net/Kconfig
index 11f8c22..1743546 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -48,6 +48,9 @@ config COMPAT_NETLINK_MESSAGES
 config NET_INGRESS
 	bool
 
+config NET_EGRESS
+	bool
+
 menu "Networking options"
 
 source "net/packet/Kconfig"
diff --git a/net/core/dev.c b/net/core/dev.c
index 914b4a2..0ca95d5 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1676,6 +1676,22 @@ void net_dec_ingress_queue(void)
 EXPORT_SYMBOL_GPL(net_dec_ingress_queue);
 #endif
 
+#ifdef CONFIG_NET_EGRESS
+static struct static_key egress_needed __read_mostly;
+
+void net_inc_egress_queue(void)
+{
+	static_key_slow_inc(&egress_needed);
+}
+EXPORT_SYMBOL_GPL(net_inc_egress_queue);
+
+void net_dec_egress_queue(void)
+{
+	static_key_slow_dec(&egress_needed);
+}
+EXPORT_SYMBOL_GPL(net_dec_egress_queue);
+#endif
+
 static struct static_key netstamp_needed __read_mostly;
 #ifdef HAVE_JUMP_LABEL
 /* We are not allowed to call static_key_slow_dec() from irq context
@@ -3007,7 +3023,6 @@ static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
 	bool contended;
 	int rc;
 
-	qdisc_pkt_len_init(skb);
 	qdisc_calculate_pkt_len(skb, q);
 	/*
 	 * Heuristic to force contended enqueues to serialize on a
@@ -3100,6 +3115,49 @@ int dev_loopback_xmit(struct net *net, struct sock *sk, struct sk_buff *skb)
 }
 EXPORT_SYMBOL(dev_loopback_xmit);
 
+#ifdef CONFIG_NET_EGRESS
+static struct sk_buff *
+sch_handle_egress(struct sk_buff *skb, int *ret, struct net_device *dev)
+{
+	struct tcf_proto *cl = rcu_dereference_bh(dev->egress_cl_list);
+	struct tcf_result cl_res;
+
+	if (!cl)
+		return skb;
+
+	/* skb->tc_verd and qdisc_skb_cb(skb)->pkt_len were already set
+	 * earlier by the caller.
+	 */
+	qdisc_bstats_cpu_update(cl->q, skb);
+
+	switch (tc_classify(skb, cl, &cl_res, false)) {
+	case TC_ACT_OK:
+	case TC_ACT_RECLASSIFY:
+		skb->tc_index = TC_H_MIN(cl_res.classid);
+		break;
+	case TC_ACT_SHOT:
+		qdisc_qstats_cpu_drop(cl->q);
+		*ret = NET_XMIT_DROP;
+		goto drop;
+	case TC_ACT_STOLEN:
+	case TC_ACT_QUEUED:
+		*ret = NET_XMIT_SUCCESS;
+drop:
+		kfree_skb(skb);
+		return NULL;
+	case TC_ACT_REDIRECT:
+		/* No need to push/pop skb's mac_header here on egress! */
+		skb_do_redirect(skb);
+		*ret = NET_XMIT_SUCCESS;
+		return NULL;
+	default:
+		break;
+	}
+
+	return skb;
+}
+#endif /* CONFIG_NET_EGRESS */
+
 static inline int get_xps_queue(struct net_device *dev, struct sk_buff *skb)
 {
 #ifdef CONFIG_XPS
@@ -3226,6 +3284,17 @@ static int __dev_queue_xmit(struct sk_buff *skb, void *accel_priv)
 
 	skb_update_prio(skb);
 
+	qdisc_pkt_len_init(skb);
+#ifdef CONFIG_NET_CLS_ACT
+	skb->tc_verd = SET_TC_AT(skb->tc_verd, AT_EGRESS);
+# ifdef CONFIG_NET_EGRESS
+	if (static_key_false(&egress_needed)) {
+		skb = sch_handle_egress(skb, &rc, dev);
+		if (!skb)
+			goto out;
+	}
+# endif
+#endif
 	/* If device/qdisc don't need skb->dst, release it right now while
 	 * its hot in this cpu cache.
 	 */
@@ -3247,9 +3316,6 @@ static int __dev_queue_xmit(struct sk_buff *skb, void *accel_priv)
 	txq = netdev_pick_tx(dev, skb, accel_priv);
 	q = rcu_dereference_bh(txq->qdisc);
 
-#ifdef CONFIG_NET_CLS_ACT
-	skb->tc_verd = SET_TC_AT(skb->tc_verd, AT_EGRESS);
-#endif
 	trace_net_dev_queue(skb);
 	if (q->enqueue) {
 		rc = __dev_xmit_skb(skb, q, dev, txq);
@@ -3806,9 +3872,9 @@ int (*br_fdb_test_addr_hook)(struct net_device *dev,
 EXPORT_SYMBOL_GPL(br_fdb_test_addr_hook);
 #endif
 
-static inline struct sk_buff *handle_ing(struct sk_buff *skb,
-					 struct packet_type **pt_prev,
-					 int *ret, struct net_device *orig_dev)
+static inline struct sk_buff *
+sch_handle_ingress(struct sk_buff *skb, struct packet_type **pt_prev, int *ret,
+		   struct net_device *orig_dev)
 {
 #ifdef CONFIG_NET_CLS_ACT
 	struct tcf_proto *cl = rcu_dereference_bh(skb->dev->ingress_cl_list);
@@ -4002,7 +4068,7 @@ another_round:
 skip_taps:
 #ifdef CONFIG_NET_INGRESS
 	if (static_key_false(&ingress_needed)) {
-		skb = handle_ing(skb, &pt_prev, &ret, orig_dev);
+		skb = sch_handle_ingress(skb, &pt_prev, &ret, orig_dev);
 		if (!skb)
 			goto out;
 
diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index daa3343..8283082 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -310,15 +310,21 @@ config NET_SCH_PIE
 	  If unsure, say N.
 
 config NET_SCH_INGRESS
-	tristate "Ingress Qdisc"
+	tristate "Ingress/classifier-action Qdisc"
 	depends on NET_CLS_ACT
 	select NET_INGRESS
+	select NET_EGRESS
 	---help---
-	  Say Y here if you want to use classifiers for incoming packets.
+	  Say Y here if you want to use classifiers for incoming and/or outgoing
+	  packets. This qdisc doesn't do anything else besides running classifiers,
+	  which can also have actions attached to them. In case of outgoing packets,
+	  classifiers that this qdisc holds are executed in the transmit path
+	  before real enqueuing to an egress qdisc happens.
+
 	  If unsure, say Y.
 
-	  To compile this code as a module, choose M here: the
-	  module will be called sch_ingress.
+	  To compile this code as a module, choose M here: the module will be
+	  called sch_ingress with alias of sch_clsact.
 
 config NET_SCH_PLUG
 	tristate "Plug network traffic until release (PLUG)"
diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index b3c8bb4..8dc8430 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -291,7 +291,7 @@ static int cls_bpf_prog_from_efd(struct nlattr **tb, struct cls_bpf_prog *prog,
 	prog->bpf_name = name;
 	prog->filter = fp;
 
-	if (fp->dst_needed)
+	if (fp->dst_needed && !(tp->q->flags & TCQ_F_INGRESS))
 		netif_keep_dst(qdisc_dev(tp->q));
 
 	return 0;
diff --git a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
index e7c648f..10adbc6 100644
--- a/net/sched/sch_ingress.c
+++ b/net/sched/sch_ingress.c
@@ -1,4 +1,5 @@
-/* net/sched/sch_ingress.c - Ingress qdisc
+/* net/sched/sch_ingress.c - Ingress and clsact qdisc
+ *
  *              This program is free software; you can redistribute it and/or
  *              modify it under the terms of the GNU General Public License
  *              as published by the Free Software Foundation; either version
@@ -98,17 +99,100 @@ static struct Qdisc_ops ingress_qdisc_ops __read_mostly = {
 	.owner		=	THIS_MODULE,
 };
 
+static unsigned long clsact_get(struct Qdisc *sch, u32 classid)
+{
+	switch (TC_H_MIN(classid)) {
+	case TC_H_MIN(TC_H_MIN_INGRESS):
+	case TC_H_MIN(TC_H_MIN_EGRESS):
+		return TC_H_MIN(classid);
+	default:
+		return 0;
+	}
+}
+
+static unsigned long clsact_bind_filter(struct Qdisc *sch,
+					unsigned long parent, u32 classid)
+{
+	return clsact_get(sch, classid);
+}
+
+static struct tcf_proto __rcu **clsact_find_tcf(struct Qdisc *sch,
+						unsigned long cl)
+{
+	struct net_device *dev = qdisc_dev(sch);
+
+	switch (cl) {
+	case TC_H_MIN(TC_H_MIN_INGRESS):
+		return &dev->ingress_cl_list;
+	case TC_H_MIN(TC_H_MIN_EGRESS):
+		return &dev->egress_cl_list;
+	default:
+		return NULL;
+	}
+}
+
+static int clsact_init(struct Qdisc *sch, struct nlattr *opt)
+{
+	net_inc_ingress_queue();
+	net_inc_egress_queue();
+
+	sch->flags |= TCQ_F_CPUSTATS;
+
+	return 0;
+}
+
+static void clsact_destroy(struct Qdisc *sch)
+{
+	struct net_device *dev = qdisc_dev(sch);
+
+	tcf_destroy_chain(&dev->ingress_cl_list);
+	tcf_destroy_chain(&dev->egress_cl_list);
+
+	net_dec_ingress_queue();
+	net_dec_egress_queue();
+}
+
+static const struct Qdisc_class_ops clsact_class_ops = {
+	.leaf		=	ingress_leaf,
+	.get		=	clsact_get,
+	.put		=	ingress_put,
+	.walk		=	ingress_walk,
+	.tcf_chain	=	clsact_find_tcf,
+	.bind_tcf	=	clsact_bind_filter,
+	.unbind_tcf	=	ingress_put,
+};
+
+static struct Qdisc_ops clsact_qdisc_ops __read_mostly = {
+	.cl_ops		=	&clsact_class_ops,
+	.id		=	"clsact",
+	.init		=	clsact_init,
+	.destroy	=	clsact_destroy,
+	.dump		=	ingress_dump,
+	.owner		=	THIS_MODULE,
+};
+
 static int __init ingress_module_init(void)
 {
-	return register_qdisc(&ingress_qdisc_ops);
+	int ret;
+
+	ret = register_qdisc(&ingress_qdisc_ops);
+	if (!ret) {
+		ret = register_qdisc(&clsact_qdisc_ops);
+		if (ret)
+			unregister_qdisc(&ingress_qdisc_ops);
+	}
+
+	return ret;
 }
 
 static void __exit ingress_module_exit(void)
 {
 	unregister_qdisc(&ingress_qdisc_ops);
+	unregister_qdisc(&clsact_qdisc_ops);
 }
 
 module_init(ingress_module_init);
 module_exit(ingress_module_exit);
 
+MODULE_ALIAS("sch_clsact");
 MODULE_LICENSE("GPL");
-- 
1.9.3

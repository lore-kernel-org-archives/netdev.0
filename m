From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2/11] PKT_SCHED: Add net/sch_generic.h with generic sched definitions
Date: Wed, 27 Oct 2004 00:23:36 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041026222336.GC12289@postel.suug.ch>
References: <20041026222148.GA12289@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, hadi@cyberus.ca
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041026222148.GA12289@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Adds net/sch_generic.h containing all bits directly referenced by
schedulers and classifiers. Map of users:

Group 1)
 struct qdisc_rate_table         sch_*, tcf_police -> cls_*

   Could theoretically be moved to pkt_sched.h with Patch 4
   but the long term goal it so make net/act_api.h to being
   dependent on net/pkt_sched.h

Group 2)
 struct Qdisc                    sch_*, tcf_proto -> cls_*
 struct Qdisc_ops                sch_*, tcf_proto -> cls_*
 struct Qdisc_class_ops          sch_*, tcf_proto -> cls_*
 struct tcf_proto_ops            sch_*, cls_*
 struct tcf_proto                sch_*, cls_*

   Obviously used by schedulers but also by classifiers to
   bind classes (tcf_proto -> Qdisc -> Qdisc_ops ->
   Qdisc_class_ops). tcf_proto OTOH is used by schedulers,
   (neat cross usage).

Group 3)
 struct tcf_result               sch_*, cls_*

   Used to communicate between scheduler and classifer
   to report classify result.
 
Group 4)
 sch_tree_(un)lock               sch_*, cls_*
 tcf_tree_(un)lock               sch_*, cls_*
 qdisc(un)lock_tree              sch_*, cls_*
   
   Randomly used in schedulers and classifiers.
 
Group 5)
 tcf_destroy                     sch_*, cls_api.c

   Coud theoretically be moved to pkt_sched.h if we include
   pkt_sched.h in cls_api.c but this is really generic and
   it seemd cleaner to have it here. This would be the only
   classifier related action in pkt_sched.h

The following types are referenced in sch_generic.h but defined in
either pkt_cls.h or pkt_sched.h because they will never be used
by the other side:

  - qdisc_walker (pkt_sched.h)
  - tcf_walker (pkt_cls.h)

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.10-rc1-bk1.orig/include/net/sch_generic.h	1970-01-01 01:00:00.000000000 +0100
+++ linux-2.6.10-rc1-bk1/include/net/sch_generic.h	2004-10-26 23:18:41.000000000 +0200
@@ -0,0 +1,175 @@
+#ifndef __NET_SCHED_GENERIC_H
+#define __NET_SCHED_GENERIC_H
+
+#include <linux/config.h>
+#include <linux/netdevice.h>
+#include <linux/types.h>
+#include <linux/rcupdate.h>
+#include <linux/module.h>
+#include <linux/rtnetlink.h>
+#include <linux/pkt_sched.h>
+#include <linux/pkt_cls.h>
+#include <net/gen_stats.h>
+
+struct Qdisc_ops;
+struct qdisc_walker;
+struct tcf_walker;
+struct module;
+
+struct qdisc_rate_table
+{
+	struct tc_ratespec rate;
+	u32		data[256];
+	struct qdisc_rate_table *next;
+	int		refcnt;
+};
+
+struct Qdisc
+{
+	int 			(*enqueue)(struct sk_buff *skb, struct Qdisc *dev);
+	struct sk_buff *	(*dequeue)(struct Qdisc *dev);
+	unsigned		flags;
+#define TCQ_F_BUILTIN	1
+#define TCQ_F_THROTTLED	2
+#define TCQ_F_INGRESS	4
+	int			padded;
+	struct Qdisc_ops	*ops;
+	u32			handle;
+	u32			parent;
+	atomic_t		refcnt;
+	struct sk_buff_head	q;
+	struct net_device	*dev;
+	struct list_head	list;
+
+	struct gnet_stats_basic	bstats;
+	struct gnet_stats_queue	qstats;
+	struct gnet_stats_rate_est	rate_est;
+	spinlock_t		*stats_lock;
+	struct rcu_head 	q_rcu;
+	int			(*reshape_fail)(struct sk_buff *skb,
+					struct Qdisc *q);
+
+	/* This field is deprecated, but it is still used by CBQ
+	 * and it will live until better solution will be invented.
+	 */
+	struct Qdisc		*__parent;
+};
+
+struct Qdisc_class_ops
+{
+	/* Child qdisc manipulation */
+	int			(*graft)(struct Qdisc *, unsigned long cl,
+					struct Qdisc *, struct Qdisc **);
+	struct Qdisc *		(*leaf)(struct Qdisc *, unsigned long cl);
+
+	/* Class manipulation routines */
+	unsigned long		(*get)(struct Qdisc *, u32 classid);
+	void			(*put)(struct Qdisc *, unsigned long);
+	int			(*change)(struct Qdisc *, u32, u32,
+					struct rtattr **, unsigned long *);
+	int			(*delete)(struct Qdisc *, unsigned long);
+	void			(*walk)(struct Qdisc *, struct qdisc_walker * arg);
+
+	/* Filter manipulation */
+	struct tcf_proto **	(*tcf_chain)(struct Qdisc *, unsigned long);
+	unsigned long		(*bind_tcf)(struct Qdisc *, unsigned long,
+					u32 classid);
+	void			(*unbind_tcf)(struct Qdisc *, unsigned long);
+
+	/* rtnetlink specific */
+	int			(*dump)(struct Qdisc *, unsigned long,
+					struct sk_buff *skb, struct tcmsg*);
+	int			(*dump_stats)(struct Qdisc *, unsigned long,
+					struct gnet_dump *);
+};
+
+struct Qdisc_ops
+{
+	struct Qdisc_ops	*next;
+	struct Qdisc_class_ops	*cl_ops;
+	char			id[IFNAMSIZ];
+	int			priv_size;
+
+	int 			(*enqueue)(struct sk_buff *, struct Qdisc *);
+	struct sk_buff *	(*dequeue)(struct Qdisc *);
+	int 			(*requeue)(struct sk_buff *, struct Qdisc *);
+	unsigned int		(*drop)(struct Qdisc *);
+
+	int			(*init)(struct Qdisc *, struct rtattr *arg);
+	void			(*reset)(struct Qdisc *);
+	void			(*destroy)(struct Qdisc *);
+	int			(*change)(struct Qdisc *, struct rtattr *arg);
+
+	int			(*dump)(struct Qdisc *, struct sk_buff *);
+	int			(*dump_stats)(struct Qdisc *, struct gnet_dump *);
+
+	struct module		*owner;
+};
+
+
+struct tcf_result
+{
+	unsigned long	class;
+	u32		classid;
+};
+
+struct tcf_proto_ops
+{
+	struct tcf_proto_ops	*next;
+	char			kind[IFNAMSIZ];
+
+	int			(*classify)(struct sk_buff*, struct tcf_proto*,
+					struct tcf_result *);
+	int			(*init)(struct tcf_proto*);
+	void			(*destroy)(struct tcf_proto*);
+
+	unsigned long		(*get)(struct tcf_proto*, u32 handle);
+	void			(*put)(struct tcf_proto*, unsigned long);
+	int			(*change)(struct tcf_proto*, unsigned long,
+					u32 handle, struct rtattr **,
+					unsigned long *);
+	int			(*delete)(struct tcf_proto*, unsigned long);
+	void			(*walk)(struct tcf_proto*, struct tcf_walker *arg);
+
+	/* rtnetlink specific */
+	int			(*dump)(struct tcf_proto*, unsigned long,
+					struct sk_buff *skb, struct tcmsg*);
+
+	struct module		*owner;
+};
+
+struct tcf_proto
+{
+	/* Fast access part */
+	struct tcf_proto	*next;
+	void			*root;
+	int			(*classify)(struct sk_buff*, struct tcf_proto*,
+					struct tcf_result *);
+	u32			protocol;
+
+	/* All the rest */
+	u32			prio;
+	u32			classid;
+	struct Qdisc		*q;
+	void			*data;
+	struct tcf_proto_ops	*ops;
+};
+
+
+extern void qdisc_lock_tree(struct net_device *dev);
+extern void qdisc_unlock_tree(struct net_device *dev);
+
+#define sch_tree_lock(q)	qdisc_lock_tree((q)->dev)
+#define sch_tree_unlock(q)	qdisc_unlock_tree((q)->dev)
+#define tcf_tree_lock(tp)	qdisc_lock_tree((tp)->q->dev)
+#define tcf_tree_unlock(tp)	qdisc_unlock_tree((tp)->q->dev)
+
+static inline void
+tcf_destroy(struct tcf_proto *tp)
+{
+	tp->ops->destroy(tp);
+	module_put(tp->ops->owner);
+	kfree(tp);
+}
+
+#endif

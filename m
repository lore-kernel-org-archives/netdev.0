From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 4/11] PKT_SCHED: Add net/act_api.h with public action/policer bits
Date: Wed, 27 Oct 2004 00:25:09 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041026222509.GE12289@postel.suug.ch>
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

Adds net/act_api.h containing all public action/policer bits used
by schedulers and classifiers

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.10-rc1-bk1.orig/include/net/act_api.h	1970-01-01 01:00:00.000000000 +0100
+++ linux-2.6.10-rc1-bk1/include/net/act_api.h	2004-10-26 23:04:24.000000000 +0200
@@ -0,0 +1,122 @@
+#ifndef __NET_ACT_API_H
+#define __NET_ACT_API_H
+
+/*
+ * Public police action API for classifiers/qdiscs
+ */
+
+#include <net/sch_generic.h>
+#include <net/pkt_sched.h>
+
+struct tcf_police
+{
+	struct tcf_police *next;
+	int		refcnt;
+#ifdef CONFIG_NET_CLS_ACT
+	int		bindcnt;
+#endif
+	u32		index;
+	int		action;
+	int		result;
+	u32		ewma_rate;
+	u32		burst;
+	u32		mtu;
+	u32		toks;
+	u32		ptoks;
+	psched_time_t	t_c;
+	spinlock_t	lock;
+	struct qdisc_rate_table *R_tab;
+	struct qdisc_rate_table *P_tab;
+
+	struct tc_stats	stats;
+	spinlock_t	*stats_lock;
+};
+
+#ifdef CONFIG_NET_CLS_ACT
+
+#define ACT_P_CREATED 1
+#define ACT_P_DELETED 1
+#define tca_gen(name) \
+struct tcf_##name *next; \
+	u32 index; \
+	int refcnt; \
+	int bindcnt; \
+	u32 capab; \
+	int action; \
+	struct tcf_t tm; \
+	struct tc_stats stats; \
+	spinlock_t *stats_lock; \
+	spinlock_t lock
+
+
+struct tc_action
+{
+	void *priv;
+	struct tc_action_ops *ops;
+	__u32   type;   /* for backward compat(TCA_OLD_COMPAT) */
+	__u32   order; 
+	struct tc_action *next;
+};
+
+#define TCA_CAP_NONE 0
+struct tc_action_ops
+{
+	struct tc_action_ops *next;
+	char    kind[IFNAMSIZ];
+	__u32   type; /* TBD to match kind */
+	__u32 	capab;  /* capabilities includes 4 bit version */
+	struct module		*owner;
+	int     (*act)(struct sk_buff **, struct tc_action *);
+	int     (*get_stats)(struct sk_buff *, struct tc_action *);
+	int     (*dump)(struct sk_buff *, struct tc_action *,int , int);
+	int     (*cleanup)(struct tc_action *, int bind);
+	int     (*lookup)(struct tc_action *, u32 );
+	int     (*init)(struct rtattr *,struct rtattr *,struct tc_action *, int , int );
+	int     (*walk)(struct sk_buff *, struct netlink_callback *, int , struct tc_action *);
+};
+
+extern int tcf_register_action(struct tc_action_ops *a);
+extern int tcf_unregister_action(struct tc_action_ops *a);
+extern void tcf_action_destroy(struct tc_action *a, int bind);
+extern int tcf_action_exec(struct sk_buff *skb, struct tc_action *a, struct tcf_result *res);
+extern int tcf_action_init(struct rtattr *rta, struct rtattr *est, struct tc_action *a,char *n, int ovr, int bind);
+extern int tcf_action_init_1(struct rtattr *rta, struct rtattr *est, struct tc_action *a,char *n, int ovr, int bind);
+extern int tcf_action_dump(struct sk_buff *skb, struct tc_action *a, int, int);
+extern int tcf_action_dump_old(struct sk_buff *skb, struct tc_action *a, int, int);
+extern int tcf_action_dump_1(struct sk_buff *skb, struct tc_action *a, int, int);
+extern int tcf_action_copy_stats (struct sk_buff *,struct tc_action *);
+extern int tcf_act_police_locate(struct rtattr *rta, struct rtattr *est,struct tc_action *,int , int );
+extern int tcf_act_police_dump(struct sk_buff *, struct tc_action *, int, int);
+extern int tcf_act_police(struct sk_buff **skb, struct tc_action *a);
+#endif /* CONFIG_NET_CLS_ACT */
+
+extern int tcf_police(struct sk_buff *skb, struct tcf_police *p);
+extern int qdisc_copy_stats(struct sk_buff *skb, struct tc_stats *st, spinlock_t *lock);
+extern void tcf_police_destroy(struct tcf_police *p);
+extern struct tcf_police * tcf_police_locate(struct rtattr *rta, struct rtattr *est);
+extern int tcf_police_dump(struct sk_buff *skb, struct tcf_police *p);
+
+static inline int
+tcf_police_release(struct tcf_police *p, int bind)
+{
+	int ret = 0;
+#ifdef CONFIG_NET_CLS_ACT
+	if (p) {
+		if (bind) {
+			 p->bindcnt--;
+		}
+		p->refcnt--;
+		if (p->refcnt <= 0 && !p->bindcnt) {
+			tcf_police_destroy(p);
+			ret = 1;
+		}
+	}
+#else
+	if (p && --p->refcnt == 0)
+		tcf_police_destroy(p);
+
+#endif /* CONFIG_NET_CLS_ACT */
+	return ret;
+}
+
+#endif

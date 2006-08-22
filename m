From: David Miller <davem@davemloft.net>
Subject: Re: 800+ byte inlines in include/net/pkt_act.h
Date: Mon, 21 Aug 2006 23:56:53 -0700 (PDT)
Message-ID: <20060821.235653.64812442.davem@davemloft.net>
References: <200608201933.10293.vda.linux@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:59530
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751098AbWHVG4p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Aug 2006 02:56:45 -0400
To: vda.linux@googlemail.com
In-Reply-To: <200608201933.10293.vda.linux@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I've checked in the following to net-2.6.19 to fix this
stuff.  Thanks for pointing it out Denis.

commit e4fa535c2177fcc92116c397534429feb0f5c0b1
Author: David S. Miller <davem@sunset.davemloft.net>
Date:   Mon Aug 21 23:54:55 2006 -0700

    [PKT_SCHED]: Kill pkt_act.h inlining.
    
    This was simply making templates of functions and mostly causing a lot
    of code duplication in the classifier action modules.
    
    We solve this more cleanly by having a common "struct tcf_common" that
    hash worker functions contained once in act_api.c can work with.
    
    Callers work with real action objects that have the common struct
    plus their module specific struct members.  You go from a common
    object to the higher level one using a "to_foo()" macro which makes
    use of container_of() to do the dirty work.
    
    This also kills off act_generic.h which was only used by act_simple.c
    and keeping it around was more work than the it's value.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/net/act_api.h b/include/net/act_api.h
index 11e9eaf..f56957e 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -8,70 +8,110 @@ #define __NET_ACT_API_H
 #include <net/sch_generic.h>
 #include <net/pkt_sched.h>
 
-#define tca_gen(name) \
-struct tcf_##name *next; \
-	u32 index; \
-	int refcnt; \
-	int bindcnt; \
-	u32 capab; \
-	int action; \
-	struct tcf_t tm; \
-	struct gnet_stats_basic bstats; \
-	struct gnet_stats_queue qstats; \
-	struct gnet_stats_rate_est rate_est; \
-	spinlock_t *stats_lock; \
-	spinlock_t lock
-
-struct tcf_police
-{
-	tca_gen(police);
-	int		result;
-	u32		ewma_rate;
-	u32		burst;
-	u32		mtu;
-	u32		toks;
-	u32		ptoks;
-	psched_time_t	t_c;
-	struct qdisc_rate_table *R_tab;
-	struct qdisc_rate_table *P_tab;
+struct tcf_common {
+	struct tcf_common		*tcfc_next;
+	u32				tcfc_index;
+	int				tcfc_refcnt;
+	int				tcfc_bindcnt;
+	u32				tcfc_capab;
+	int				tcfc_action;
+	struct tcf_t			tcfc_tm;
+	struct gnet_stats_basic		tcfc_bstats;
+	struct gnet_stats_queue		tcfc_qstats;
+	struct gnet_stats_rate_est	tcfc_rate_est;
+	spinlock_t			*tcfc_stats_lock;
+	spinlock_t			tcfc_lock;
+};
+#define tcf_next	common.tcfc_next
+#define tcf_index	common.tcfc_index
+#define tcf_refcnt	common.tcfc_refcnt
+#define tcf_bindcnt	common.tcfc_bindcnt
+#define tcf_capab	common.tcfc_capab
+#define tcf_action	common.tcfc_action
+#define tcf_tm		common.tcfc_tm
+#define tcf_bstats	common.tcfc_bstats
+#define tcf_qstats	common.tcfc_qstats
+#define tcf_rate_est	common.tcfc_rate_est
+#define tcf_stats_lock	common.tcfc_stats_lock
+#define tcf_lock	common.tcfc_lock
+
+struct tcf_police {
+	struct tcf_common	common;
+	int			tcfp_result;
+	u32			tcfp_ewma_rate;
+	u32			tcfp_burst;
+	u32			tcfp_mtu;
+	u32			tcfp_toks;
+	u32			tcfp_ptoks;
+	psched_time_t		tcfp_t_c;
+	struct qdisc_rate_table	*tcfp_R_tab;
+	struct qdisc_rate_table	*tcfp_P_tab;
 };
+#define to_police(pc)	\
+	container_of(pc, struct tcf_police, common)
+
+struct tcf_hashinfo {
+	struct tcf_common	**htab;
+	unsigned int		hmask;
+	rwlock_t		*lock;
+};
+
+static inline unsigned int tcf_hash(u32 index, unsigned int hmask)
+{
+	return index & hmask;
+}
 
 #ifdef CONFIG_NET_CLS_ACT
 
 #define ACT_P_CREATED 1
 #define ACT_P_DELETED 1
 
-struct tcf_act_hdr
-{
-	tca_gen(act_hdr);
+struct tcf_act_hdr {
+	struct tcf_common	common;
 };
 
-struct tc_action
-{
-	void *priv;
-	struct tc_action_ops *ops;
-	__u32   type;   /* for backward compat(TCA_OLD_COMPAT) */
-	__u32   order; 
-	struct tc_action *next;
+struct tc_action {
+	void			*priv;
+	struct tc_action_ops	*ops;
+	__u32			type; /* for backward compat(TCA_OLD_COMPAT) */
+	__u32			order; 
+	struct tc_action	*next;
 };
 
 #define TCA_CAP_NONE 0
-struct tc_action_ops
-{
+struct tc_action_ops {
 	struct tc_action_ops *next;
+	struct tcf_hashinfo *hinfo;
 	char    kind[IFNAMSIZ];
 	__u32   type; /* TBD to match kind */
 	__u32 	capab;  /* capabilities includes 4 bit version */
 	struct module		*owner;
 	int     (*act)(struct sk_buff *, struct tc_action *, struct tcf_result *);
 	int     (*get_stats)(struct sk_buff *, struct tc_action *);
-	int     (*dump)(struct sk_buff *, struct tc_action *,int , int);
+	int     (*dump)(struct sk_buff *, struct tc_action *, int, int);
 	int     (*cleanup)(struct tc_action *, int bind);
-	int     (*lookup)(struct tc_action *, u32 );
-	int     (*init)(struct rtattr *,struct rtattr *,struct tc_action *, int , int );
-	int     (*walk)(struct sk_buff *, struct netlink_callback *, int , struct tc_action *);
+	int     (*lookup)(struct tc_action *, u32);
+	int     (*init)(struct rtattr *, struct rtattr *, struct tc_action *, int , int);
+	int     (*walk)(struct sk_buff *, struct netlink_callback *, int, struct tc_action *);
 };
 
+extern struct tcf_common *tcf_hash_lookup(u32 index,
+					  struct tcf_hashinfo *hinfo);
+extern void tcf_hash_destroy(struct tcf_common *p, struct tcf_hashinfo *hinfo);
+extern int tcf_hash_release(struct tcf_common *p, int bind,
+			    struct tcf_hashinfo *hinfo);
+extern int tcf_generic_walker(struct sk_buff *skb, struct netlink_callback *cb,
+			      int type, struct tc_action *a);
+extern u32 tcf_hash_new_index(u32 *idx_gen, struct tcf_hashinfo *hinfo);
+extern int tcf_hash_search(struct tc_action *a, u32 index);
+extern struct tcf_common *tcf_hash_check(u32 index, struct tc_action *a,
+					 int bind, struct tcf_hashinfo *hinfo);
+extern struct tcf_common *tcf_hash_create(u32 index, struct rtattr *est,
+					  struct tc_action *a, int size,
+					  int bind, u32 *idx_gen,
+					  struct tcf_hashinfo *hinfo);
+extern void tcf_hash_insert(struct tcf_common *p, struct tcf_hashinfo *hinfo);
+
 extern int tcf_register_action(struct tc_action_ops *a);
 extern int tcf_unregister_action(struct tc_action_ops *a);
 extern void tcf_action_destroy(struct tc_action *a, int bind);
@@ -96,17 +136,17 @@ tcf_police_release(struct tcf_police *p,
 	int ret = 0;
 #ifdef CONFIG_NET_CLS_ACT
 	if (p) {
-		if (bind) {
-			 p->bindcnt--;
-		}
-		p->refcnt--;
-		if (p->refcnt <= 0 && !p->bindcnt) {
+		if (bind)
+			p->tcf_bindcnt--;
+
+		p->tcf_refcnt--;
+		if (p->tcf_refcnt <= 0 && !p->tcf_bindcnt) {
 			tcf_police_destroy(p);
 			ret = 1;
 		}
 	}
 #else
-	if (p && --p->refcnt == 0)
+	if (p && --p->tcf_refcnt == 0)
 		tcf_police_destroy(p);
 
 #endif /* CONFIG_NET_CLS_ACT */
diff --git a/include/net/act_generic.h b/include/net/act_generic.h
deleted file mode 100644
index c9daa7e..0000000
--- a/include/net/act_generic.h
+++ /dev/null
@@ -1,142 +0,0 @@
-/*
- * include/net/act_generic.h
- *
-*/
-#ifndef _NET_ACT_GENERIC_H
-#define _NET_ACT_GENERIC_H
-static inline int tcf_defact_release(struct tcf_defact *p, int bind)
-{
-	int ret = 0;
-	if (p) {
-		if (bind) {
-			p->bindcnt--;
-		}
-		p->refcnt--;
-		if (p->bindcnt <= 0 && p->refcnt <= 0) {
-			kfree(p->defdata);
-			tcf_hash_destroy(p);
-			ret = 1;
-		}
-	}
-	return ret;
-}
-
-static inline int
-alloc_defdata(struct tcf_defact *p, u32 datalen, void *defdata)
-{
-	p->defdata = kmalloc(datalen, GFP_KERNEL);
-	if (p->defdata == NULL)
-		return -ENOMEM;
-	p->datalen = datalen;
-	memcpy(p->defdata, defdata, datalen);
-	return 0;
-}
-
-static inline int
-realloc_defdata(struct tcf_defact *p, u32 datalen, void *defdata)
-{
-	/* safer to be just brute force for now */
-	kfree(p->defdata);
-	return alloc_defdata(p, datalen, defdata);
-}
-
-static inline int
-tcf_defact_init(struct rtattr *rta, struct rtattr *est,
-		struct tc_action *a, int ovr, int bind)
-{
-	struct rtattr *tb[TCA_DEF_MAX];
-	struct tc_defact *parm;
-	struct tcf_defact *p;
-	void *defdata;
-	u32 datalen = 0;
-	int ret = 0;
-
-	if (rta == NULL || rtattr_parse_nested(tb, TCA_DEF_MAX, rta) < 0)
-		return -EINVAL;
-
-	if (tb[TCA_DEF_PARMS - 1] == NULL || 
-	    RTA_PAYLOAD(tb[TCA_DEF_PARMS - 1]) < sizeof(*parm))
-		return -EINVAL;
-
-	parm = RTA_DATA(tb[TCA_DEF_PARMS - 1]);
-	defdata = RTA_DATA(tb[TCA_DEF_DATA - 1]);
-	if (defdata == NULL)
-		return -EINVAL;
-
-	datalen = RTA_PAYLOAD(tb[TCA_DEF_DATA - 1]);
-	if (datalen <= 0)
-		return -EINVAL;
-
-	p = tcf_hash_check(parm->index, a, ovr, bind);
-	if (p == NULL) {
-		p = tcf_hash_create(parm->index, est, a, sizeof(*p), ovr, bind);
-		if (p == NULL)
-			return -ENOMEM;
-
-		ret = alloc_defdata(p, datalen, defdata);
-		if (ret < 0) {
-			kfree(p);
-			return ret;
-		}
-		ret = ACT_P_CREATED;
-	} else {
-		if (!ovr) {
-			tcf_defact_release(p, bind);
-			return -EEXIST;
-		}
-		realloc_defdata(p, datalen, defdata);
-	}
-
-	spin_lock_bh(&p->lock);
-	p->action = parm->action;
-	spin_unlock_bh(&p->lock);
-	if (ret == ACT_P_CREATED)
-		tcf_hash_insert(p);
-	return ret;
-}
-
-static inline int tcf_defact_cleanup(struct tc_action *a, int bind)
-{
-	struct tcf_defact *p = PRIV(a, defact);
-
-	if (p != NULL)
-		return tcf_defact_release(p, bind);
-	return 0;
-}
-
-static inline int
-tcf_defact_dump(struct sk_buff *skb, struct tc_action *a, int bind, int ref)
-{
-	unsigned char *b = skb->tail;
-	struct tc_defact opt;
-	struct tcf_defact *p = PRIV(a, defact);
-	struct tcf_t t;
-
-	opt.index = p->index;
-	opt.refcnt = p->refcnt - ref;
-	opt.bindcnt = p->bindcnt - bind;
-	opt.action = p->action;
-	RTA_PUT(skb, TCA_DEF_PARMS, sizeof(opt), &opt);
-	RTA_PUT(skb, TCA_DEF_DATA, p->datalen, p->defdata);
-	t.install = jiffies_to_clock_t(jiffies - p->tm.install);
-	t.lastuse = jiffies_to_clock_t(jiffies - p->tm.lastuse);
-	t.expires = jiffies_to_clock_t(p->tm.expires);
-	RTA_PUT(skb, TCA_DEF_TM, sizeof(t), &t);
-	return skb->len;
-
-rtattr_failure:
-	skb_trim(skb, b - skb->data);
-	return -1;
-}
-
-#define tca_use_default_ops \
-	.dump           =       tcf_defact_dump, \
-	.cleanup        =       tcf_defact_cleanup, \
-	.init           =       tcf_defact_init, \
-	.walk           =       tcf_generic_walker, \
-
-#define tca_use_default_defines(name) \
-	static u32 idx_gen; \
-	static struct tcf_defact *tcf_##name_ht[MY_TAB_SIZE]; \
-	static DEFINE_RWLOCK(##name_lock);
-#endif /* _NET_ACT_GENERIC_H */
diff --git a/include/net/pkt_act.h b/include/net/pkt_act.h
deleted file mode 100644
index cf5e4d2..0000000
--- a/include/net/pkt_act.h
+++ /dev/null
@@ -1,273 +0,0 @@
-#ifndef __NET_PKT_ACT_H
-#define __NET_PKT_ACT_H
-
-#include <asm/uaccess.h>
-#include <asm/system.h>
-#include <linux/bitops.h>
-#include <linux/types.h>
-#include <linux/kernel.h>
-#include <linux/sched.h>
-#include <linux/string.h>
-#include <linux/mm.h>
-#include <linux/socket.h>
-#include <linux/sockios.h>
-#include <linux/in.h>
-#include <linux/errno.h>
-#include <linux/interrupt.h>
-#include <linux/skbuff.h>
-#include <linux/rtnetlink.h>
-#include <linux/module.h>
-#include <linux/init.h>
-#include <linux/proc_fs.h>
-#include <net/sock.h>
-#include <net/pkt_sched.h>
-
-#define tca_st(val) (struct tcf_##val *)
-#define PRIV(a,name) ( tca_st(name) (a)->priv)
-
-#if 0 /* control */
-#define DPRINTK(format,args...) printk(KERN_DEBUG format,##args)
-#else
-#define DPRINTK(format,args...)
-#endif
-
-#if 0 /* data */
-#define D2PRINTK(format,args...) printk(KERN_DEBUG format,##args)
-#else
-#define D2PRINTK(format,args...)
-#endif
-
-static __inline__ unsigned
-tcf_hash(u32 index)
-{
-	return index & MY_TAB_MASK;
-}
-
-/* probably move this from being inline
- * and put into act_generic
-*/
-static inline void
-tcf_hash_destroy(struct tcf_st *p)
-{
-	unsigned h = tcf_hash(p->index);
-	struct tcf_st **p1p;
-
-	for (p1p = &tcf_ht[h]; *p1p; p1p = &(*p1p)->next) {
-		if (*p1p == p) {
-			write_lock_bh(&tcf_t_lock);
-			*p1p = p->next;
-			write_unlock_bh(&tcf_t_lock);
-#ifdef CONFIG_NET_ESTIMATOR
-			gen_kill_estimator(&p->bstats, &p->rate_est);
-#endif
-			kfree(p);
-			return;
-		}
-	}
-	BUG_TRAP(0);
-}
-
-static inline int
-tcf_hash_release(struct tcf_st *p, int bind )
-{
-	int ret = 0;
-	if (p) {
-		if (bind) {
-			p->bindcnt--;
-		}
-		p->refcnt--;
-	       	if(p->bindcnt <=0 && p->refcnt <= 0) {
-			tcf_hash_destroy(p);
-			ret = 1;
-		}
-	}
-	return ret;
-}
-
-static __inline__ int
-tcf_dump_walker(struct sk_buff *skb, struct netlink_callback *cb,
-		struct tc_action *a)
-{
-	struct tcf_st *p;
-	int err =0, index =  -1,i= 0, s_i = 0, n_i = 0;
-	struct rtattr *r ;
-
-	read_lock(&tcf_t_lock);
-
-	s_i = cb->args[0];
-
-	for (i = 0; i < MY_TAB_SIZE; i++) {
-		p = tcf_ht[tcf_hash(i)];
-
-		for (; p; p = p->next) {
-			index++;
-			if (index < s_i)
-				continue;
-			a->priv = p;
-			a->order = n_i;
-			r = (struct rtattr*) skb->tail;
-			RTA_PUT(skb, a->order, 0, NULL);
-			err = tcf_action_dump_1(skb, a, 0, 0);
-			if (0 > err) {
-				index--;
-				skb_trim(skb, (u8*)r - skb->data);
-				goto done;
-			}
-			r->rta_len = skb->tail - (u8*)r;
-			n_i++;
-			if (n_i >= TCA_ACT_MAX_PRIO) {
-				goto done;
-			}
-		}
-	}
-done:
-	read_unlock(&tcf_t_lock);
-	if (n_i)
-		cb->args[0] += n_i;
-	return n_i;
-
-rtattr_failure:
-	skb_trim(skb, (u8*)r - skb->data);
-	goto done;
-}
-
-static __inline__ int
-tcf_del_walker(struct sk_buff *skb, struct tc_action *a)
-{
-	struct tcf_st *p, *s_p;
-	struct rtattr *r ;
-	int i= 0, n_i = 0;
-
-	r = (struct rtattr*) skb->tail;
-	RTA_PUT(skb, a->order, 0, NULL);
-	RTA_PUT(skb, TCA_KIND, IFNAMSIZ, a->ops->kind);
-	for (i = 0; i < MY_TAB_SIZE; i++) {
-		p = tcf_ht[tcf_hash(i)];
-
-		while (p != NULL) {
-			s_p = p->next;
-			if (ACT_P_DELETED == tcf_hash_release(p, 0)) {
-				 module_put(a->ops->owner);
-			}
-			n_i++;
-			p = s_p;
-		}
-	}
-	RTA_PUT(skb, TCA_FCNT, 4, &n_i);
-	r->rta_len = skb->tail - (u8*)r;
-
-	return n_i;
-rtattr_failure:
-	skb_trim(skb, (u8*)r - skb->data);
-	return -EINVAL;
-}
-
-static __inline__ int
-tcf_generic_walker(struct sk_buff *skb, struct netlink_callback *cb, int type,
-		struct tc_action *a)
-{
-		if (type == RTM_DELACTION) {
-			return tcf_del_walker(skb,a);
-		} else if (type == RTM_GETACTION) {
-			return tcf_dump_walker(skb,cb,a);
-		} else {
-			printk("tcf_generic_walker: unknown action %d\n",type);
-			return -EINVAL;
-		}
-}
-
-static __inline__ struct tcf_st *
-tcf_hash_lookup(u32 index)
-{
-	struct tcf_st *p;
-
-	read_lock(&tcf_t_lock);
-	for (p = tcf_ht[tcf_hash(index)]; p; p = p->next) {
-		if (p->index == index)
-			break;
-	}
-	read_unlock(&tcf_t_lock);
-	return p;
-}
-
-static __inline__ u32
-tcf_hash_new_index(void)
-{
-	do {
-		if (++idx_gen == 0)
-			idx_gen = 1;
-	} while (tcf_hash_lookup(idx_gen));
-
-	return idx_gen;
-}
-
-
-static inline int
-tcf_hash_search(struct tc_action *a, u32 index)
-{
-	struct tcf_st *p = tcf_hash_lookup(index);
-
-	if (p != NULL) {
-		a->priv = p;
-		return 1;
-	}
-	return 0;
-}
-
-#ifdef CONFIG_NET_ACT_INIT
-static inline struct tcf_st *
-tcf_hash_check(u32 index, struct tc_action *a, int ovr, int bind)
-{
-	struct tcf_st *p = NULL;
-	if (index && (p = tcf_hash_lookup(index)) != NULL) {
-		if (bind) {
-			p->bindcnt++;
-			p->refcnt++;
-		}
-		a->priv = p;
-	}
-	return p;
-}
-
-static inline struct tcf_st *
-tcf_hash_create(u32 index, struct rtattr *est, struct tc_action *a, int size, int ovr, int bind)
-{
-	struct tcf_st *p = NULL;
-
-	p = kmalloc(size, GFP_KERNEL);
-	if (p == NULL)
-		return p;
-
-	memset(p, 0, size);
-	p->refcnt = 1;
-
-	if (bind) {
-		p->bindcnt = 1;
-	}
-
-	spin_lock_init(&p->lock);
-	p->stats_lock = &p->lock;
-	p->index = index ? : tcf_hash_new_index();
-	p->tm.install = jiffies;
-	p->tm.lastuse = jiffies;
-#ifdef CONFIG_NET_ESTIMATOR
-	if (est)
-		gen_new_estimator(&p->bstats, &p->rate_est, p->stats_lock, est);
-#endif
-	a->priv = (void *) p;
-	return p;
-}
-
-static inline void tcf_hash_insert(struct tcf_st *p)
-{
-	unsigned h = tcf_hash(p->index);
-
-	write_lock_bh(&tcf_t_lock);
-	p->next = tcf_ht[h];
-	tcf_ht[h] = p;
-	write_unlock_bh(&tcf_t_lock);
-}
-
-#endif
-
-#endif
diff --git a/include/net/tc_act/tc_defact.h b/include/net/tc_act/tc_defact.h
index 463aa67..65f024b 100644
--- a/include/net/tc_act/tc_defact.h
+++ b/include/net/tc_act/tc_defact.h
@@ -3,11 +3,12 @@ #define __NET_TC_DEF_H
 
 #include <net/act_api.h>
 
-struct tcf_defact
-{
-	tca_gen(defact);
-	u32     datalen;
-	void    *defdata;
+struct tcf_defact {
+	struct tcf_common	common;
+	u32     		tcfd_datalen;
+	void    		*tcfd_defdata;
 };
+#define to_defact(pc) \
+	container_of(pc, struct tcf_defact, common)
 
-#endif
+#endif /* __NET_TC_DEF_H */
diff --git a/include/net/tc_act/tc_gact.h b/include/net/tc_act/tc_gact.h
index 59f0d96..9e3f676 100644
--- a/include/net/tc_act/tc_gact.h
+++ b/include/net/tc_act/tc_gact.h
@@ -3,15 +3,15 @@ #define __NET_TC_GACT_H
 
 #include <net/act_api.h>
 
-struct tcf_gact
-{
-        tca_gen(gact);
+struct tcf_gact {
+	struct tcf_common	common;
 #ifdef CONFIG_GACT_PROB
-        u16                 ptype;
-        u16                 pval;
-        int                 paction;
+        u16			tcfg_ptype;
+        u16			tcfg_pval;
+        int			tcfg_paction;
 #endif
-                                                                                
 };
-                                                                                
-#endif
+#define to_gact(pc) \
+	container_of(pc, struct tcf_gact, common)
+
+#endif /* __NET_TC_GACT_H */
diff --git a/include/net/tc_act/tc_ipt.h b/include/net/tc_act/tc_ipt.h
index cb37ad0..f7d25df 100644
--- a/include/net/tc_act/tc_ipt.h
+++ b/include/net/tc_act/tc_ipt.h
@@ -5,12 +5,13 @@ #include <net/act_api.h>
 
 struct xt_entry_target;
 
-struct tcf_ipt
-{
-	tca_gen(ipt);
-	u32 hook;
-	char *tname;
-	struct xt_entry_target *t;
+struct tcf_ipt {
+	struct tcf_common	common;
+	u32			tcfi_hook;
+	char			*tcfi_tname;
+	struct xt_entry_target	*tcfi_t;
 };
+#define to_ipt(pc) \
+	container_of(pc, struct tcf_ipt, common)
 
-#endif
+#endif /* __NET_TC_IPT_H */
diff --git a/include/net/tc_act/tc_mirred.h b/include/net/tc_act/tc_mirred.h
index b5c32f6..ceac661 100644
--- a/include/net/tc_act/tc_mirred.h
+++ b/include/net/tc_act/tc_mirred.h
@@ -3,13 +3,14 @@ #define __NET_TC_MIR_H
 
 #include <net/act_api.h>
 
-struct tcf_mirred
-{
-	tca_gen(mirred);
-	int eaction;
-	int ifindex;
-	int ok_push;
-	struct net_device *dev;
+struct tcf_mirred {
+	struct tcf_common	common;
+	int			tcfm_eaction;
+	int			tcfm_ifindex;
+	int			tcfm_ok_push;
+	struct net_device	*tcfm_dev;
 };
+#define to_mirred(pc) \
+	container_of(pc, struct tcf_mirred, common)
 
-#endif
+#endif /* __NET_TC_MIR_H */
diff --git a/include/net/tc_act/tc_pedit.h b/include/net/tc_act/tc_pedit.h
index eb21689..e6f6e15 100644
--- a/include/net/tc_act/tc_pedit.h
+++ b/include/net/tc_act/tc_pedit.h
@@ -3,12 +3,13 @@ #define __NET_TC_PED_H
 
 #include <net/act_api.h>
 
-struct tcf_pedit
-{
-	tca_gen(pedit);
-	unsigned char           nkeys;
-	unsigned char           flags;
-	struct tc_pedit_key     *keys;
+struct tcf_pedit {
+	struct tcf_common	common;
+	unsigned char		tcfp_nkeys;
+	unsigned char		tcfp_flags;
+	struct tc_pedit_key	*tcfp_keys;
 };
+#define to_pedit(pc) \
+	container_of(pc, struct tcf_pedit, common)
 
-#endif
+#endif /* __NET_TC_PED_H */
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 6990747..835070e 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -33,16 +33,230 @@ #include <net/sock.h>
 #include <net/sch_generic.h>
 #include <net/act_api.h>
 
-#if 0 /* control */
-#define DPRINTK(format, args...) printk(KERN_DEBUG format, ##args)
-#else
-#define DPRINTK(format, args...)
+void tcf_hash_destroy(struct tcf_common *p, struct tcf_hashinfo *hinfo)
+{
+	unsigned int h = tcf_hash(p->tcfc_index, hinfo->hmask);
+	struct tcf_common **p1p;
+
+	for (p1p = &hinfo->htab[h]; *p1p; p1p = &(*p1p)->tcfc_next) {
+		if (*p1p == p) {
+			write_lock_bh(hinfo->lock);
+			*p1p = p->tcfc_next;
+			write_unlock_bh(hinfo->lock);
+#ifdef CONFIG_NET_ESTIMATOR
+			gen_kill_estimator(&p->tcfc_bstats,
+					   &p->tcfc_rate_est);
 #endif
-#if 0 /* data */
-#define D2PRINTK(format, args...) printk(KERN_DEBUG format, ##args)
-#else
-#define D2PRINTK(format, args...)
+			kfree(p);
+			return;
+		}
+	}
+	BUG_TRAP(0);
+}
+EXPORT_SYMBOL(tcf_hash_destroy);
+
+int tcf_hash_release(struct tcf_common *p, int bind,
+		     struct tcf_hashinfo *hinfo)
+{
+	int ret = 0;
+
+	if (p) {
+		if (bind)
+			p->tcfc_bindcnt--;
+
+		p->tcfc_refcnt--;
+	       	if (p->tcfc_bindcnt <= 0 && p->tcfc_refcnt <= 0) {
+			tcf_hash_destroy(p, hinfo);
+			ret = 1;
+		}
+	}
+	return ret;
+}
+EXPORT_SYMBOL(tcf_hash_release);
+
+static int tcf_dump_walker(struct sk_buff *skb, struct netlink_callback *cb,
+			   struct tc_action *a, struct tcf_hashinfo *hinfo)
+{
+	struct tcf_common *p;
+	int err = 0, index = -1,i = 0, s_i = 0, n_i = 0;
+	struct rtattr *r ;
+
+	read_lock(hinfo->lock);
+
+	s_i = cb->args[0];
+
+	for (i = 0; i < (hinfo->hmask + 1); i++) {
+		p = hinfo->htab[tcf_hash(i, hinfo->hmask)];
+
+		for (; p; p = p->tcfc_next) {
+			index++;
+			if (index < s_i)
+				continue;
+			a->priv = p;
+			a->order = n_i;
+			r = (struct rtattr*) skb->tail;
+			RTA_PUT(skb, a->order, 0, NULL);
+			err = tcf_action_dump_1(skb, a, 0, 0);
+			if (err < 0) {
+				index--;
+				skb_trim(skb, (u8*)r - skb->data);
+				goto done;
+			}
+			r->rta_len = skb->tail - (u8*)r;
+			n_i++;
+			if (n_i >= TCA_ACT_MAX_PRIO)
+				goto done;
+		}
+	}
+done:
+	read_unlock(hinfo->lock);
+	if (n_i)
+		cb->args[0] += n_i;
+	return n_i;
+
+rtattr_failure:
+	skb_trim(skb, (u8*)r - skb->data);
+	goto done;
+}
+
+static int tcf_del_walker(struct sk_buff *skb, struct tc_action *a,
+			  struct tcf_hashinfo *hinfo)
+{
+	struct tcf_common *p, *s_p;
+	struct rtattr *r ;
+	int i= 0, n_i = 0;
+
+	r = (struct rtattr*) skb->tail;
+	RTA_PUT(skb, a->order, 0, NULL);
+	RTA_PUT(skb, TCA_KIND, IFNAMSIZ, a->ops->kind);
+	for (i = 0; i < (hinfo->hmask + 1); i++) {
+		p = hinfo->htab[tcf_hash(i, hinfo->hmask)];
+
+		while (p != NULL) {
+			s_p = p->tcfc_next;
+			if (ACT_P_DELETED == tcf_hash_release(p, 0, hinfo))
+				 module_put(a->ops->owner);
+			n_i++;
+			p = s_p;
+		}
+	}
+	RTA_PUT(skb, TCA_FCNT, 4, &n_i);
+	r->rta_len = skb->tail - (u8*)r;
+
+	return n_i;
+rtattr_failure:
+	skb_trim(skb, (u8*)r - skb->data);
+	return -EINVAL;
+}
+
+int tcf_generic_walker(struct sk_buff *skb, struct netlink_callback *cb,
+		       int type, struct tc_action *a)
+{
+	struct tcf_hashinfo *hinfo = a->ops->hinfo;
+
+	if (type == RTM_DELACTION) {
+		return tcf_del_walker(skb, a, hinfo);
+	} else if (type == RTM_GETACTION) {
+		return tcf_dump_walker(skb, cb, a, hinfo);
+	} else {
+		printk("tcf_generic_walker: unknown action %d\n", type);
+		return -EINVAL;
+	}
+}
+EXPORT_SYMBOL(tcf_generic_walker);
+
+struct tcf_common *tcf_hash_lookup(u32 index, struct tcf_hashinfo *hinfo)
+{
+	struct tcf_common *p;
+
+	read_lock(hinfo->lock);
+	for (p = hinfo->htab[tcf_hash(index, hinfo->hmask)]; p;
+	     p = p->tcfc_next) {
+		if (p->tcfc_index == index)
+			break;
+	}
+	read_unlock(hinfo->lock);
+
+	return p;
+}
+EXPORT_SYMBOL(tcf_hash_lookup);
+
+u32 tcf_hash_new_index(u32 *idx_gen, struct tcf_hashinfo *hinfo)
+{
+	u32 val = *idx_gen;
+
+	do {
+		if (++val == 0)
+			val = 1;
+	} while (tcf_hash_lookup(val, hinfo));
+
+	return (*idx_gen = val);
+}
+EXPORT_SYMBOL(tcf_hash_new_index);
+
+int tcf_hash_search(struct tc_action *a, u32 index)
+{
+	struct tcf_hashinfo *hinfo = a->ops->hinfo;
+	struct tcf_common *p = tcf_hash_lookup(index, hinfo);
+
+	if (p) {
+		a->priv = p;
+		return 1;
+	}
+	return 0;
+}
+EXPORT_SYMBOL(tcf_hash_search);
+
+struct tcf_common *tcf_hash_check(u32 index, struct tc_action *a, int bind,
+				  struct tcf_hashinfo *hinfo)
+{
+	struct tcf_common *p = NULL;
+	if (index && (p = tcf_hash_lookup(index, hinfo)) != NULL) {
+		if (bind) {
+			p->tcfc_bindcnt++;
+			p->tcfc_refcnt++;
+		}
+		a->priv = p;
+	}
+	return p;
+}
+EXPORT_SYMBOL(tcf_hash_check);
+
+struct tcf_common *tcf_hash_create(u32 index, struct rtattr *est, struct tc_action *a, int size, int bind, u32 *idx_gen, struct tcf_hashinfo *hinfo)
+{
+	struct tcf_common *p = kzalloc(size, GFP_KERNEL);
+
+	if (unlikely(!p))
+		return p;
+	p->tcfc_refcnt = 1;
+	if (bind)
+		p->tcfc_bindcnt = 1;
+
+	spin_lock_init(&p->tcfc_lock);
+	p->tcfc_stats_lock = &p->tcfc_lock;
+	p->tcfc_index = index ? index : tcf_hash_new_index(idx_gen, hinfo);
+	p->tcfc_tm.install = jiffies;
+	p->tcfc_tm.lastuse = jiffies;
+#ifdef CONFIG_NET_ESTIMATOR
+	if (est)
+		gen_new_estimator(&p->tcfc_bstats, &p->tcfc_rate_est,
+				  p->tcfc_stats_lock, est);
 #endif
+	a->priv = (void *) p;
+	return p;
+}
+EXPORT_SYMBOL(tcf_hash_create);
+
+void tcf_hash_insert(struct tcf_common *p, struct tcf_hashinfo *hinfo)
+{
+	unsigned int h = tcf_hash(p->tcfc_index, hinfo->hmask);
+
+	write_lock_bh(hinfo->lock);
+	p->tcfc_next = hinfo->htab[h];
+	hinfo->htab[h] = p;
+	write_unlock_bh(hinfo->lock);
+}
+EXPORT_SYMBOL(tcf_hash_insert);
 
 static struct tc_action_ops *act_base = NULL;
 static DEFINE_RWLOCK(act_mod_lock);
@@ -155,9 +369,6 @@ int tcf_action_exec(struct sk_buff *skb,
 
 	if (skb->tc_verd & TC_NCLS) {
 		skb->tc_verd = CLR_TC_NCLS(skb->tc_verd);
-		D2PRINTK("(%p)tcf_action_exec: cleared TC_NCLS in %s out %s\n",
-		         skb, skb->input_dev ? skb->input_dev->name : "xxx",
-		         skb->dev->name);
 		ret = TC_ACT_OK;
 		goto exec_done;
 	}
@@ -187,8 +398,6 @@ void tcf_action_destroy(struct tc_action
 
 	for (a = act; a; a = act) {
 		if (a->ops && a->ops->cleanup) {
-			DPRINTK("tcf_action_destroy destroying %p next %p\n",
-			        a, a->next);
 			if (a->ops->cleanup(a, bind) == ACT_P_DELETED)
 				module_put(a->ops->owner);
 			act = act->next;
@@ -331,7 +540,6 @@ #endif
 	if (*err != ACT_P_CREATED)
 		module_put(a_o->owner);
 	a->ops = a_o;
-	DPRINTK("tcf_action_init_1: successfull %s\n", act_name);
 
 	*err = 0;
 	return a;
@@ -392,12 +600,12 @@ int tcf_action_copy_stats(struct sk_buff
 	if (compat_mode) {
 		if (a->type == TCA_OLD_COMPAT)
 			err = gnet_stats_start_copy_compat(skb, 0,
-				TCA_STATS, TCA_XSTATS, h->stats_lock, &d);
+				TCA_STATS, TCA_XSTATS, h->tcf_stats_lock, &d);
 		else
 			return 0;
 	} else
 		err = gnet_stats_start_copy(skb, TCA_ACT_STATS,
-			h->stats_lock, &d);
+			h->tcf_stats_lock, &d);
 
 	if (err < 0)
 		goto errout;
@@ -406,11 +614,11 @@ int tcf_action_copy_stats(struct sk_buff
 		if (a->ops->get_stats(skb, a) < 0)
 			goto errout;
 
-	if (gnet_stats_copy_basic(&d, &h->bstats) < 0 ||
+	if (gnet_stats_copy_basic(&d, &h->tcf_bstats) < 0 ||
 #ifdef CONFIG_NET_ESTIMATOR
-	    gnet_stats_copy_rate_est(&d, &h->rate_est) < 0 ||
+	    gnet_stats_copy_rate_est(&d, &h->tcf_rate_est) < 0 ||
 #endif
-	    gnet_stats_copy_queue(&d, &h->qstats) < 0)
+	    gnet_stats_copy_queue(&d, &h->tcf_qstats) < 0)
 		goto errout;
 
 	if (gnet_stats_finish_copy(&d) < 0)
diff --git a/net/sched/act_gact.c b/net/sched/act_gact.c
index e75a147..6cff566 100644
--- a/net/sched/act_gact.c
+++ b/net/sched/act_gact.c
@@ -34,48 +34,43 @@ #include <net/pkt_sched.h>
 #include <linux/tc_act/tc_gact.h>
 #include <net/tc_act/tc_gact.h>
 
-/* use generic hash table */
-#define MY_TAB_SIZE	16
-#define MY_TAB_MASK	15
-
-static u32 idx_gen;
-static struct tcf_gact *tcf_gact_ht[MY_TAB_SIZE];
+#define GACT_TAB_MASK	15
+static struct tcf_common *tcf_gact_ht[GACT_TAB_MASK + 1];
+static u32 gact_idx_gen;
 static DEFINE_RWLOCK(gact_lock);
 
-/* ovewrride the defaults */
-#define tcf_st		tcf_gact
-#define tc_st		tc_gact
-#define tcf_t_lock	gact_lock
-#define tcf_ht		tcf_gact_ht
-
-#define CONFIG_NET_ACT_INIT 1
-#include <net/pkt_act.h>
+static struct tcf_hashinfo gact_hash_info = {
+	.htab	=	tcf_gact_ht,
+	.hmask	=	GACT_TAB_MASK,
+	.lock	=	&gact_lock,
+};
 
 #ifdef CONFIG_GACT_PROB
-static int gact_net_rand(struct tcf_gact *p)
+static int gact_net_rand(struct tcf_gact *gact)
 {
-	if (net_random()%p->pval)
-		return p->action;
-	return p->paction;
+	if (net_random() % gact->tcfg_pval)
+		return gact->tcf_action;
+	return gact->tcfg_paction;
 }
 
-static int gact_determ(struct tcf_gact *p)
+static int gact_determ(struct tcf_gact *gact)
 {
-	if (p->bstats.packets%p->pval)
-		return p->action;
-	return p->paction;
+	if (gact->tcf_bstats.packets % gact->tcfg_pval)
+		return gact->tcf_action;
+	return gact->tcfg_paction;
 }
 
-typedef int (*g_rand)(struct tcf_gact *p);
+typedef int (*g_rand)(struct tcf_gact *gact);
 static g_rand gact_rand[MAX_RAND]= { NULL, gact_net_rand, gact_determ };
-#endif
+#endif /* CONFIG_GACT_PROB */
 
 static int tcf_gact_init(struct rtattr *rta, struct rtattr *est,
                          struct tc_action *a, int ovr, int bind)
 {
 	struct rtattr *tb[TCA_GACT_MAX];
 	struct tc_gact *parm;
-	struct tcf_gact *p;
+	struct tcf_gact *gact;
+	struct tcf_common *pc;
 	int ret = 0;
 
 	if (rta == NULL || rtattr_parse_nested(tb, TCA_GACT_MAX, rta) < 0)
@@ -94,105 +89,106 @@ #else
 		return -EOPNOTSUPP;
 #endif
 
-	p = tcf_hash_check(parm->index, a, ovr, bind);
-	if (p == NULL) {
-		p = tcf_hash_create(parm->index, est, a, sizeof(*p), ovr, bind);
-		if (p == NULL)
+	pc = tcf_hash_check(parm->index, a, bind, &gact_hash_info);
+	if (!pc) {
+		pc = tcf_hash_create(parm->index, est, a, sizeof(*gact),
+				     bind, &gact_idx_gen, &gact_hash_info);
+		if (unlikely(!pc))
 			return -ENOMEM;
 		ret = ACT_P_CREATED;
 	} else {
 		if (!ovr) {
-			tcf_hash_release(p, bind);
+			tcf_hash_release(pc, bind, &gact_hash_info);
 			return -EEXIST;
 		}
 	}
 
-	spin_lock_bh(&p->lock);
-	p->action = parm->action;
+	gact = to_gact(pc);
+
+	spin_lock_bh(&gact->tcf_lock);
+	gact->tcf_action = parm->action;
 #ifdef CONFIG_GACT_PROB
 	if (tb[TCA_GACT_PROB-1] != NULL) {
 		struct tc_gact_p *p_parm = RTA_DATA(tb[TCA_GACT_PROB-1]);
-		p->paction = p_parm->paction;
-		p->pval    = p_parm->pval;
-		p->ptype   = p_parm->ptype;
+		gact->tcfg_paction = p_parm->paction;
+		gact->tcfg_pval    = p_parm->pval;
+		gact->tcfg_ptype   = p_parm->ptype;
 	}
 #endif
-	spin_unlock_bh(&p->lock);
+	spin_unlock_bh(&gact->tcf_lock);
 	if (ret == ACT_P_CREATED)
-		tcf_hash_insert(p);
+		tcf_hash_insert(pc, &gact_hash_info);
 	return ret;
 }
 
-static int
-tcf_gact_cleanup(struct tc_action *a, int bind)
+static int tcf_gact_cleanup(struct tc_action *a, int bind)
 {
-	struct tcf_gact *p = PRIV(a, gact);
+	struct tcf_gact *gact = a->priv;
 
-	if (p != NULL)
-		return tcf_hash_release(p, bind);
+	if (gact)
+		return tcf_hash_release(&gact->common, bind, &gact_hash_info);
 	return 0;
 }
 
-static int
-tcf_gact(struct sk_buff *skb, struct tc_action *a, struct tcf_result *res)
+static int tcf_gact(struct sk_buff *skb, struct tc_action *a, struct tcf_result *res)
 {
-	struct tcf_gact *p = PRIV(a, gact);
+	struct tcf_gact *gact = a->priv;
 	int action = TC_ACT_SHOT;
 
-	spin_lock(&p->lock);
+	spin_lock(&gact->tcf_lock);
 #ifdef CONFIG_GACT_PROB
-	if (p->ptype && gact_rand[p->ptype] != NULL)
-		action = gact_rand[p->ptype](p);
+	if (gact->tcfg_ptype && gact_rand[gact->tcfg_ptype] != NULL)
+		action = gact_rand[gact->tcfg_ptype](gact);
 	else
-		action = p->action;
+		action = gact->tcf_action;
 #else
-	action = p->action;
+	action = gact->tcf_action;
 #endif
-	p->bstats.bytes += skb->len;
-	p->bstats.packets++;
+	gact->tcf_bstats.bytes += skb->len;
+	gact->tcf_bstats.packets++;
 	if (action == TC_ACT_SHOT)
-		p->qstats.drops++;
-	p->tm.lastuse = jiffies;
-	spin_unlock(&p->lock);
+		gact->tcf_qstats.drops++;
+	gact->tcf_tm.lastuse = jiffies;
+	spin_unlock(&gact->tcf_lock);
 
 	return action;
 }
 
-static int
-tcf_gact_dump(struct sk_buff *skb, struct tc_action *a, int bind, int ref)
+static int tcf_gact_dump(struct sk_buff *skb, struct tc_action *a, int bind, int ref)
 {
 	unsigned char *b = skb->tail;
 	struct tc_gact opt;
-	struct tcf_gact *p = PRIV(a, gact);
+	struct tcf_gact *gact = a->priv;
 	struct tcf_t t;
 
-	opt.index = p->index;
-	opt.refcnt = p->refcnt - ref;
-	opt.bindcnt = p->bindcnt - bind;
-	opt.action = p->action;
+	opt.index = gact->tcf_index;
+	opt.refcnt = gact->tcf_refcnt - ref;
+	opt.bindcnt = gact->tcf_bindcnt - bind;
+	opt.action = gact->tcf_action;
 	RTA_PUT(skb, TCA_GACT_PARMS, sizeof(opt), &opt);
 #ifdef CONFIG_GACT_PROB
-	if (p->ptype) {
+	if (gact->tcfg_ptype) {
 		struct tc_gact_p p_opt;
-		p_opt.paction = p->paction;
-		p_opt.pval = p->pval;
-		p_opt.ptype = p->ptype;
+		p_opt.paction = gact->tcfg_paction;
+		p_opt.pval = gact->tcfg_pval;
+		p_opt.ptype = gact->tcfg_ptype;
 		RTA_PUT(skb, TCA_GACT_PROB, sizeof(p_opt), &p_opt);
 	}
 #endif
-	t.install = jiffies_to_clock_t(jiffies - p->tm.install);
-	t.lastuse = jiffies_to_clock_t(jiffies - p->tm.lastuse);
-	t.expires = jiffies_to_clock_t(p->tm.expires);
+	t.install = jiffies_to_clock_t(jiffies - gact->tcf_tm.install);
+	t.lastuse = jiffies_to_clock_t(jiffies - gact->tcf_tm.lastuse);
+	t.expires = jiffies_to_clock_t(gact->tcf_tm.expires);
 	RTA_PUT(skb, TCA_GACT_TM, sizeof(t), &t);
 	return skb->len;
 
-      rtattr_failure:
+rtattr_failure:
 	skb_trim(skb, b - skb->data);
 	return -1;
 }
 
 static struct tc_action_ops act_gact_ops = {
 	.kind		=	"gact",
+	.hinfo		=	&gact_hash_info,
 	.type		=	TCA_ACT_GACT,
 	.capab		=	TCA_CAP_NONE,
 	.owner		=	THIS_MODULE,
@@ -208,8 +204,7 @@ MODULE_AUTHOR("Jamal Hadi Salim(2002-4)"
 MODULE_DESCRIPTION("Generic Classifier actions");
 MODULE_LICENSE("GPL");
 
-static int __init
-gact_init_module(void)
+static int __init gact_init_module(void)
 {
 #ifdef CONFIG_GACT_PROB
 	printk("GACT probability on\n");
@@ -219,8 +214,7 @@ #endif
 	return tcf_register_action(&act_gact_ops);
 }
 
-static void __exit
-gact_cleanup_module(void)
+static void __exit gact_cleanup_module(void)
 {
 	tcf_unregister_action(&act_gact_ops);
 }
diff --git a/net/sched/act_ipt.c b/net/sched/act_ipt.c
index d799e01..224c078 100644
--- a/net/sched/act_ipt.c
+++ b/net/sched/act_ipt.c
@@ -38,25 +38,19 @@ #include <net/tc_act/tc_ipt.h>
 
 #include <linux/netfilter_ipv4/ip_tables.h>
 
-/* use generic hash table */
-#define MY_TAB_SIZE     16
-#define MY_TAB_MASK     15
 
-static u32 idx_gen;
-static struct tcf_ipt *tcf_ipt_ht[MY_TAB_SIZE];
-/* ipt hash table lock */
+#define IPT_TAB_MASK     15
+static struct tcf_common *tcf_ipt_ht[IPT_TAB_MASK + 1];
+static u32 ipt_idx_gen;
 static DEFINE_RWLOCK(ipt_lock);
 
-/* ovewrride the defaults */
-#define tcf_st		tcf_ipt
-#define tcf_t_lock	ipt_lock
-#define tcf_ht		tcf_ipt_ht
-
-#define CONFIG_NET_ACT_INIT
-#include <net/pkt_act.h>
+static struct tcf_hashinfo ipt_hash_info = {
+	.htab	=	tcf_ipt_ht,
+	.hmask	=	IPT_TAB_MASK,
+	.lock	=	&ipt_lock,
+};
 
-static int
-ipt_init_target(struct ipt_entry_target *t, char *table, unsigned int hook)
+static int ipt_init_target(struct ipt_entry_target *t, char *table, unsigned int hook)
 {
 	struct ipt_target *target;
 	int ret = 0;
@@ -65,7 +59,6 @@ ipt_init_target(struct ipt_entry_target 
 	if (!target)
 		return -ENOENT;
 
-	DPRINTK("ipt_init_target: found %s\n", target->name);
 	t->u.kernel.target = target;
 
 	ret = xt_check_target(target, AF_INET, t->u.target_size - sizeof(*t),
@@ -78,8 +71,6 @@ ipt_init_target(struct ipt_entry_target 
 		    			       t->u.kernel.target, t->data,
 					       t->u.target_size - sizeof(*t),
 					       hook)) {
-		DPRINTK("ipt_init_target: check failed for `%s'.\n",
-			t->u.kernel.target->name);
 		module_put(t->u.kernel.target->me);
 		ret = -EINVAL;
 	}
@@ -87,8 +78,7 @@ ipt_init_target(struct ipt_entry_target 
 	return ret;
 }
 
-static void
-ipt_destroy_target(struct ipt_entry_target *t)
+static void ipt_destroy_target(struct ipt_entry_target *t)
 {
 	if (t->u.kernel.target->destroy)
 		t->u.kernel.target->destroy(t->u.kernel.target, t->data,
@@ -96,31 +86,30 @@ ipt_destroy_target(struct ipt_entry_targ
         module_put(t->u.kernel.target->me);
 }
 
-static int
-tcf_ipt_release(struct tcf_ipt *p, int bind)
+static int tcf_ipt_release(struct tcf_ipt *ipt, int bind)
 {
 	int ret = 0;
-	if (p) {
+	if (ipt) {
 		if (bind)
-			p->bindcnt--;
-		p->refcnt--;
-		if (p->bindcnt <= 0 && p->refcnt <= 0) {
-			ipt_destroy_target(p->t);
-			kfree(p->tname);
-			kfree(p->t);
-			tcf_hash_destroy(p);
+			ipt->tcf_bindcnt--;
+		ipt->tcf_refcnt--;
+		if (ipt->tcf_bindcnt <= 0 && ipt->tcf_refcnt <= 0) {
+			ipt_destroy_target(ipt->tcfi_t);
+			kfree(ipt->tcfi_tname);
+			kfree(ipt->tcfi_t);
+			tcf_hash_destroy(&ipt->common, &ipt_hash_info);
 			ret = ACT_P_DELETED;
 		}
 	}
 	return ret;
 }
 
-static int
-tcf_ipt_init(struct rtattr *rta, struct rtattr *est, struct tc_action *a,
-             int ovr, int bind)
+static int tcf_ipt_init(struct rtattr *rta, struct rtattr *est,
+			struct tc_action *a, int ovr, int bind)
 {
 	struct rtattr *tb[TCA_IPT_MAX];
-	struct tcf_ipt *p;
+	struct tcf_ipt *ipt;
+	struct tcf_common *pc;
 	struct ipt_entry_target *td, *t;
 	char *tname;
 	int ret = 0, err;
@@ -144,49 +133,51 @@ tcf_ipt_init(struct rtattr *rta, struct 
 	    RTA_PAYLOAD(tb[TCA_IPT_INDEX-1]) >= sizeof(u32))
 		index = *(u32 *)RTA_DATA(tb[TCA_IPT_INDEX-1]);
 
-	p = tcf_hash_check(index, a, ovr, bind);
-	if (p == NULL) {
-		p = tcf_hash_create(index, est, a, sizeof(*p), ovr, bind);
-		if (p == NULL)
+	pc = tcf_hash_check(index, a, bind, &ipt_hash_info);
+	if (!pc) {
+		pc = tcf_hash_create(index, est, a, sizeof(*ipt), bind,
+				     &ipt_idx_gen, &ipt_hash_info);
+		if (unlikely(!pc))
 			return -ENOMEM;
 		ret = ACT_P_CREATED;
 	} else {
 		if (!ovr) {
-			tcf_ipt_release(p, bind);
+			tcf_ipt_release(to_ipt(pc), bind);
 			return -EEXIST;
 		}
 	}
+	ipt = to_ipt(pc);
 
 	hook = *(u32 *)RTA_DATA(tb[TCA_IPT_HOOK-1]);
 
 	err = -ENOMEM;
 	tname = kmalloc(IFNAMSIZ, GFP_KERNEL);
-	if (tname == NULL)
+	if (unlikely(!tname))
 		goto err1;
 	if (tb[TCA_IPT_TABLE - 1] == NULL ||
 	    rtattr_strlcpy(tname, tb[TCA_IPT_TABLE-1], IFNAMSIZ) >= IFNAMSIZ)
 		strcpy(tname, "mangle");
 
 	t = kmalloc(td->u.target_size, GFP_KERNEL);
-	if (t == NULL)
+	if (unlikely(!t))
 		goto err2;
 	memcpy(t, td, td->u.target_size);
 
 	if ((err = ipt_init_target(t, tname, hook)) < 0)
 		goto err3;
 
-	spin_lock_bh(&p->lock);
+	spin_lock_bh(&ipt->tcf_lock);
 	if (ret != ACT_P_CREATED) {
-		ipt_destroy_target(p->t);
-		kfree(p->tname);
-		kfree(p->t);
+		ipt_destroy_target(ipt->tcfi_t);
+		kfree(ipt->tcfi_tname);
+		kfree(ipt->tcfi_t);
 	}
-	p->tname = tname;
-	p->t     = t;
-	p->hook  = hook;
-	spin_unlock_bh(&p->lock);
+	ipt->tcfi_tname = tname;
+	ipt->tcfi_t     = t;
+	ipt->tcfi_hook  = hook;
+	spin_unlock_bh(&ipt->tcf_lock);
 	if (ret == ACT_P_CREATED)
-		tcf_hash_insert(p);
+		tcf_hash_insert(pc, &ipt_hash_info);
 	return ret;
 
 err3:
@@ -194,33 +185,32 @@ err3:
 err2:
 	kfree(tname);
 err1:
-	kfree(p);
+	kfree(pc);
 	return err;
 }
 
-static int
-tcf_ipt_cleanup(struct tc_action *a, int bind)
+static int tcf_ipt_cleanup(struct tc_action *a, int bind)
 {
-	struct tcf_ipt *p = PRIV(a, ipt);
-	return tcf_ipt_release(p, bind);
+	struct tcf_ipt *ipt = a->priv;
+	return tcf_ipt_release(ipt, bind);
 }
 
-static int
-tcf_ipt(struct sk_buff *skb, struct tc_action *a, struct tcf_result *res)
+static int tcf_ipt(struct sk_buff *skb, struct tc_action *a,
+		   struct tcf_result *res)
 {
 	int ret = 0, result = 0;
-	struct tcf_ipt *p = PRIV(a, ipt);
+	struct tcf_ipt *ipt = a->priv;
 
 	if (skb_cloned(skb)) {
 		if (pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
 			return TC_ACT_UNSPEC;
 	}
 
-	spin_lock(&p->lock);
+	spin_lock(&ipt->tcf_lock);
 
-	p->tm.lastuse = jiffies;
-	p->bstats.bytes += skb->len;
-	p->bstats.packets++;
+	ipt->tcf_tm.lastuse = jiffies;
+	ipt->tcf_bstats.bytes += skb->len;
+	ipt->tcf_bstats.packets++;
 
 	/* yes, we have to worry about both in and out dev
 	 worry later - danger - this API seems to have changed
@@ -229,16 +219,17 @@ tcf_ipt(struct sk_buff *skb, struct tc_a
 	/* iptables targets take a double skb pointer in case the skb
 	 * needs to be replaced. We don't own the skb, so this must not
 	 * happen. The pskb_expand_head above should make sure of this */
-	ret = p->t->u.kernel.target->target(&skb, skb->dev, NULL, p->hook,
-					    p->t->u.kernel.target, p->t->data,
-					    NULL);
+	ret = ipt->tcfi_t->u.kernel.target->target(&skb, skb->dev, NULL,
+						   ipt->tcfi_hook,
+						   ipt->tcfi_t->u.kernel.target,
+						   ipt->tcfi_t->data, NULL);
 	switch (ret) {
 	case NF_ACCEPT:
 		result = TC_ACT_OK;
 		break;
 	case NF_DROP:
 		result = TC_ACT_SHOT;
-		p->qstats.drops++;
+		ipt->tcf_qstats.drops++;
 		break;
 	case IPT_CONTINUE:
 		result = TC_ACT_PIPE;
@@ -249,53 +240,46 @@ tcf_ipt(struct sk_buff *skb, struct tc_a
 		result = TC_POLICE_OK;
 		break;
 	}
-	spin_unlock(&p->lock);
+	spin_unlock(&ipt->tcf_lock);
 	return result;
 
 }
 
-static int
-tcf_ipt_dump(struct sk_buff *skb, struct tc_action *a, int bind, int ref)
+static int tcf_ipt_dump(struct sk_buff *skb, struct tc_action *a, int bind, int ref)
 {
+	unsigned char *b = skb->tail;
+	struct tcf_ipt *ipt = a->priv;
 	struct ipt_entry_target *t;
 	struct tcf_t tm;
 	struct tc_cnt c;
-	unsigned char *b = skb->tail;
-	struct tcf_ipt *p = PRIV(a, ipt);
 
 	/* for simple targets kernel size == user size
 	** user name = target name
 	** for foolproof you need to not assume this
 	*/
 
-	t = kmalloc(p->t->u.user.target_size, GFP_ATOMIC);
-	if (t == NULL)
+	t = kmalloc(ipt->tcfi_t->u.user.target_size, GFP_ATOMIC);
+	if (unlikely(!t))
 		goto rtattr_failure;
 
-	c.bindcnt = p->bindcnt - bind;
-	c.refcnt = p->refcnt - ref;
-	memcpy(t, p->t, p->t->u.user.target_size);
-	strcpy(t->u.user.name, p->t->u.kernel.target->name);
-
-	DPRINTK("\ttcf_ipt_dump tablename %s length %d\n", p->tname,
-		strlen(p->tname));
-	DPRINTK("\tdump target name %s size %d size user %d "
-	        "data[0] %x data[1] %x\n", p->t->u.kernel.target->name,
-	        p->t->u.target_size, p->t->u.user.target_size,
-	        p->t->data[0], p->t->data[1]);
-	RTA_PUT(skb, TCA_IPT_TARG, p->t->u.user.target_size, t);
-	RTA_PUT(skb, TCA_IPT_INDEX, 4, &p->index);
-	RTA_PUT(skb, TCA_IPT_HOOK, 4, &p->hook);
+	c.bindcnt = ipt->tcf_bindcnt - bind;
+	c.refcnt = ipt->tcf_refcnt - ref;
+	memcpy(t, ipt->tcfi_t, ipt->tcfi_t->u.user.target_size);
+	strcpy(t->u.user.name, ipt->tcfi_t->u.kernel.target->name);
+
+	RTA_PUT(skb, TCA_IPT_TARG, ipt->tcfi_t->u.user.target_size, t);
+	RTA_PUT(skb, TCA_IPT_INDEX, 4, &ipt->tcf_index);
+	RTA_PUT(skb, TCA_IPT_HOOK, 4, &ipt->tcfi_hook);
 	RTA_PUT(skb, TCA_IPT_CNT, sizeof(struct tc_cnt), &c);
-	RTA_PUT(skb, TCA_IPT_TABLE, IFNAMSIZ, p->tname);
-	tm.install = jiffies_to_clock_t(jiffies - p->tm.install);
-	tm.lastuse = jiffies_to_clock_t(jiffies - p->tm.lastuse);
-	tm.expires = jiffies_to_clock_t(p->tm.expires);
+	RTA_PUT(skb, TCA_IPT_TABLE, IFNAMSIZ, ipt->tcfi_tname);
+	tm.install = jiffies_to_clock_t(jiffies - ipt->tcf_tm.install);
+	tm.lastuse = jiffies_to_clock_t(jiffies - ipt->tcf_tm.lastuse);
+	tm.expires = jiffies_to_clock_t(ipt->tcf_tm.expires);
 	RTA_PUT(skb, TCA_IPT_TM, sizeof (tm), &tm);
 	kfree(t);
 	return skb->len;
 
-      rtattr_failure:
+rtattr_failure:
 	skb_trim(skb, b - skb->data);
 	kfree(t);
 	return -1;
@@ -303,6 +287,7 @@ tcf_ipt_dump(struct sk_buff *skb, struct
 
 static struct tc_action_ops act_ipt_ops = {
 	.kind		=	"ipt",
+	.hinfo		=	&ipt_hash_info,
 	.type		=	TCA_ACT_IPT,
 	.capab		=	TCA_CAP_NONE,
 	.owner		=	THIS_MODULE,
@@ -318,14 +303,12 @@ MODULE_AUTHOR("Jamal Hadi Salim(2002-4)"
 MODULE_DESCRIPTION("Iptables target actions");
 MODULE_LICENSE("GPL");
 
-static int __init
-ipt_init_module(void)
+static int __init ipt_init_module(void)
 {
 	return tcf_register_action(&act_ipt_ops);
 }
 
-static void __exit
-ipt_cleanup_module(void)
+static void __exit ipt_cleanup_module(void)
 {
 	tcf_unregister_action(&act_ipt_ops);
 }
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index fc56204..4838972 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -39,46 +39,39 @@ #include <net/tc_act/tc_mirred.h>
 #include <linux/etherdevice.h>
 #include <linux/if_arp.h>
 
-
-/* use generic hash table */
-#define MY_TAB_SIZE     8
-#define MY_TAB_MASK     (MY_TAB_SIZE - 1)
-static u32 idx_gen;
-static struct tcf_mirred *tcf_mirred_ht[MY_TAB_SIZE];
+#define MIRRED_TAB_MASK     7
+static struct tcf_common *tcf_mirred_ht[MIRRED_TAB_MASK + 1];
+static u32 mirred_idx_gen;
 static DEFINE_RWLOCK(mirred_lock);
 
-/* ovewrride the defaults */
-#define tcf_st		tcf_mirred
-#define tc_st		tc_mirred
-#define tcf_t_lock	mirred_lock
-#define tcf_ht		tcf_mirred_ht
-
-#define CONFIG_NET_ACT_INIT 1
-#include <net/pkt_act.h>
+static struct tcf_hashinfo mirred_hash_info = {
+	.htab	=	tcf_mirred_ht,
+	.hmask	=	MIRRED_TAB_MASK,
+	.lock	=	&mirred_lock,
+};
 
-static inline int
-tcf_mirred_release(struct tcf_mirred *p, int bind)
+static inline int tcf_mirred_release(struct tcf_mirred *m, int bind)
 {
-	if (p) {
+	if (m) {
 		if (bind)
-			p->bindcnt--;
-		p->refcnt--;
-		if(!p->bindcnt && p->refcnt <= 0) {
-			dev_put(p->dev);
-			tcf_hash_destroy(p);
+			m->tcf_bindcnt--;
+		m->tcf_refcnt--;
+		if(!m->tcf_bindcnt && m->tcf_refcnt <= 0) {
+			dev_put(m->tcfm_dev);
+			tcf_hash_destroy(&m->common, &mirred_hash_info);
 			return 1;
 		}
 	}
 	return 0;
 }
 
-static int
-tcf_mirred_init(struct rtattr *rta, struct rtattr *est, struct tc_action *a,
-                int ovr, int bind)
+static int tcf_mirred_init(struct rtattr *rta, struct rtattr *est,
+			   struct tc_action *a, int ovr, int bind)
 {
 	struct rtattr *tb[TCA_MIRRED_MAX];
 	struct tc_mirred *parm;
-	struct tcf_mirred *p;
+	struct tcf_mirred *m;
+	struct tcf_common *pc;
 	struct net_device *dev = NULL;
 	int ret = 0;
 	int ok_push = 0;
@@ -110,64 +103,62 @@ tcf_mirred_init(struct rtattr *rta, stru
 		}
 	}
 
-	p = tcf_hash_check(parm->index, a, ovr, bind);
-	if (p == NULL) {
+	pc = tcf_hash_check(parm->index, a, bind, &mirred_hash_info);
+	if (!pc) {
 		if (!parm->ifindex)
 			return -EINVAL;
-		p = tcf_hash_create(parm->index, est, a, sizeof(*p), ovr, bind);
-		if (p == NULL)
+		pc = tcf_hash_create(parm->index, est, a, sizeof(*m), bind,
+				     &mirred_idx_gen, &mirred_hash_info);
+		if (unlikely(!pc))
 			return -ENOMEM;
 		ret = ACT_P_CREATED;
 	} else {
 		if (!ovr) {
-			tcf_mirred_release(p, bind);
+			tcf_mirred_release(to_mirred(pc), bind);
 			return -EEXIST;
 		}
 	}
+	m = to_mirred(pc);
 
-	spin_lock_bh(&p->lock);
-	p->action = parm->action;
-	p->eaction = parm->eaction;
+	spin_lock_bh(&m->tcf_lock);
+	m->tcf_action = parm->action;
+	m->tcfm_eaction = parm->eaction;
 	if (parm->ifindex) {
-		p->ifindex = parm->ifindex;
+		m->tcfm_ifindex = parm->ifindex;
 		if (ret != ACT_P_CREATED)
-			dev_put(p->dev);
-		p->dev = dev;
+			dev_put(m->tcfm_dev);
+		m->tcfm_dev = dev;
 		dev_hold(dev);
-		p->ok_push = ok_push;
+		m->tcfm_ok_push = ok_push;
 	}
-	spin_unlock_bh(&p->lock);
+	spin_unlock_bh(&m->tcf_lock);
 	if (ret == ACT_P_CREATED)
-		tcf_hash_insert(p);
+		tcf_hash_insert(pc, &mirred_hash_info);
 
-	DPRINTK("tcf_mirred_init index %d action %d eaction %d device %s "
-	        "ifindex %d\n", parm->index, parm->action, parm->eaction,
-	        dev->name, parm->ifindex);
 	return ret;
 }
 
-static int
-tcf_mirred_cleanup(struct tc_action *a, int bind)
+static int tcf_mirred_cleanup(struct tc_action *a, int bind)
 {
-	struct tcf_mirred *p = PRIV(a, mirred);
+	struct tcf_mirred *m = a->priv;
 
-	if (p != NULL)
-		return tcf_mirred_release(p, bind);
+	if (m)
+		return tcf_mirred_release(m, bind);
 	return 0;
 }
 
-static int
-tcf_mirred(struct sk_buff *skb, struct tc_action *a, struct tcf_result *res)
+static int tcf_mirred(struct sk_buff *skb, struct tc_action *a,
+		      struct tcf_result *res)
 {
-	struct tcf_mirred *p = PRIV(a, mirred);
+	struct tcf_mirred *m = a->priv;
 	struct net_device *dev;
 	struct sk_buff *skb2 = NULL;
 	u32 at = G_TC_AT(skb->tc_verd);
 
-	spin_lock(&p->lock);
+	spin_lock(&m->tcf_lock);
 
-	dev = p->dev;
-	p->tm.lastuse = jiffies;
+	dev = m->tcfm_dev;
+	m->tcf_tm.lastuse = jiffies;
 
 	if (!(dev->flags&IFF_UP) ) {
 		if (net_ratelimit())
@@ -176,10 +167,10 @@ tcf_mirred(struct sk_buff *skb, struct t
 bad_mirred:
 		if (skb2 != NULL)
 			kfree_skb(skb2);
-		p->qstats.overlimits++;
-		p->bstats.bytes += skb->len;
-		p->bstats.packets++;
-		spin_unlock(&p->lock);
+		m->tcf_qstats.overlimits++;
+		m->tcf_bstats.bytes += skb->len;
+		m->tcf_bstats.packets++;
+		spin_unlock(&m->tcf_lock);
 		/* should we be asking for packet to be dropped?
 		 * may make sense for redirect case only
 		*/
@@ -189,59 +180,59 @@ bad_mirred:
 	skb2 = skb_clone(skb, GFP_ATOMIC);
 	if (skb2 == NULL)
 		goto bad_mirred;
-	if (p->eaction != TCA_EGRESS_MIRROR && p->eaction != TCA_EGRESS_REDIR) {
+	if (m->tcfm_eaction != TCA_EGRESS_MIRROR &&
+	    m->tcfm_eaction != TCA_EGRESS_REDIR) {
 		if (net_ratelimit())
-			printk("tcf_mirred unknown action %d\n", p->eaction);
+			printk("tcf_mirred unknown action %d\n",
+			       m->tcfm_eaction);
 		goto bad_mirred;
 	}
 
-	p->bstats.bytes += skb2->len;
-	p->bstats.packets++;
+	m->tcf_bstats.bytes += skb2->len;
+	m->tcf_bstats.packets++;
 	if (!(at & AT_EGRESS))
-		if (p->ok_push)
+		if (m->tcfm_ok_push)
 			skb_push(skb2, skb2->dev->hard_header_len);
 
 	/* mirror is always swallowed */
-	if (p->eaction != TCA_EGRESS_MIRROR)
+	if (m->tcfm_eaction != TCA_EGRESS_MIRROR)
 		skb2->tc_verd = SET_TC_FROM(skb2->tc_verd, at);
 
 	skb2->dev = dev;
 	skb2->input_dev = skb->dev;
 	dev_queue_xmit(skb2);
-	spin_unlock(&p->lock);
-	return p->action;
+	spin_unlock(&m->tcf_lock);
+	return m->tcf_action;
 }
 
-static int
-tcf_mirred_dump(struct sk_buff *skb, struct tc_action *a, int bind, int ref)
+static int tcf_mirred_dump(struct sk_buff *skb, struct tc_action *a, int bind, int ref)
 {
 	unsigned char *b = skb->tail;
+	struct tcf_mirred *m = a->priv;
 	struct tc_mirred opt;
-	struct tcf_mirred *p = PRIV(a, mirred);
 	struct tcf_t t;
 
-	opt.index = p->index;
-	opt.action = p->action;
-	opt.refcnt = p->refcnt - ref;
-	opt.bindcnt = p->bindcnt - bind;
-	opt.eaction = p->eaction;
-	opt.ifindex = p->ifindex;
-	DPRINTK("tcf_mirred_dump index %d action %d eaction %d ifindex %d\n",
-	         p->index, p->action, p->eaction, p->ifindex);
+	opt.index = m->tcf_index;
+	opt.action = m->tcf_action;
+	opt.refcnt = m->tcf_refcnt - ref;
+	opt.bindcnt = m->tcf_bindcnt - bind;
+	opt.eaction = m->tcfm_eaction;
+	opt.ifindex = m->tcfm_ifindex;
 	RTA_PUT(skb, TCA_MIRRED_PARMS, sizeof(opt), &opt);
-	t.install = jiffies_to_clock_t(jiffies - p->tm.install);
-	t.lastuse = jiffies_to_clock_t(jiffies - p->tm.lastuse);
-	t.expires = jiffies_to_clock_t(p->tm.expires);
+	t.install = jiffies_to_clock_t(jiffies - m->tcf_tm.install);
+	t.lastuse = jiffies_to_clock_t(jiffies - m->tcf_tm.lastuse);
+	t.expires = jiffies_to_clock_t(m->tcf_tm.expires);
 	RTA_PUT(skb, TCA_MIRRED_TM, sizeof(t), &t);
 	return skb->len;
 
-      rtattr_failure:
+rtattr_failure:
 	skb_trim(skb, b - skb->data);
 	return -1;
 }
 
 static struct tc_action_ops act_mirred_ops = {
 	.kind		=	"mirred",
+	.hinfo		=	&mirred_hash_info,
 	.type		=	TCA_ACT_MIRRED,
 	.capab		=	TCA_CAP_NONE,
 	.owner		=	THIS_MODULE,
@@ -257,15 +248,13 @@ MODULE_AUTHOR("Jamal Hadi Salim(2002)");
 MODULE_DESCRIPTION("Device Mirror/redirect actions");
 MODULE_LICENSE("GPL");
 
-static int __init
-mirred_init_module(void)
+static int __init mirred_init_module(void)
 {
 	printk("Mirror/redirect action on\n");
 	return tcf_register_action(&act_mirred_ops);
 }
 
-static void __exit
-mirred_cleanup_module(void)
+static void __exit mirred_cleanup_module(void)
 {
 	tcf_unregister_action(&act_mirred_ops);
 }
diff --git a/net/sched/act_pedit.c b/net/sched/act_pedit.c
index f257475..8ac65c2 100644
--- a/net/sched/act_pedit.c
+++ b/net/sched/act_pedit.c
@@ -33,32 +33,25 @@ #include <net/pkt_sched.h>
 #include <linux/tc_act/tc_pedit.h>
 #include <net/tc_act/tc_pedit.h>
 
-
-#define PEDIT_DEB 1
-
-/* use generic hash table */
-#define MY_TAB_SIZE     16
-#define MY_TAB_MASK     15
-static u32 idx_gen;
-static struct tcf_pedit *tcf_pedit_ht[MY_TAB_SIZE];
+#define PEDIT_TAB_MASK	15
+static struct tcf_common *tcf_pedit_ht[PEDIT_TAB_MASK + 1];
+static u32 pedit_idx_gen;
 static DEFINE_RWLOCK(pedit_lock);
 
-#define tcf_st		tcf_pedit
-#define tc_st		tc_pedit
-#define tcf_t_lock	pedit_lock
-#define tcf_ht		tcf_pedit_ht
-
-#define CONFIG_NET_ACT_INIT 1
-#include <net/pkt_act.h>
+static struct tcf_hashinfo pedit_hash_info = {
+	.htab	=	tcf_pedit_ht,
+	.hmask	=	PEDIT_TAB_MASK,
+	.lock	=	&pedit_lock,
+};
 
-static int
-tcf_pedit_init(struct rtattr *rta, struct rtattr *est, struct tc_action *a,
-               int ovr, int bind)
+static int tcf_pedit_init(struct rtattr *rta, struct rtattr *est,
+			  struct tc_action *a, int ovr, int bind)
 {
 	struct rtattr *tb[TCA_PEDIT_MAX];
 	struct tc_pedit *parm;
 	int ret = 0;
 	struct tcf_pedit *p;
+	struct tcf_common *pc;
 	struct tc_pedit_key *keys = NULL;
 	int ksize;
 
@@ -73,54 +66,56 @@ tcf_pedit_init(struct rtattr *rta, struc
 	if (RTA_PAYLOAD(tb[TCA_PEDIT_PARMS-1]) < sizeof(*parm) + ksize)
 		return -EINVAL;
 
-	p = tcf_hash_check(parm->index, a, ovr, bind);
-	if (p == NULL) {
+	pc = tcf_hash_check(parm->index, a, bind, &pedit_hash_info);
+	if (!pc) {
 		if (!parm->nkeys)
 			return -EINVAL;
-		p = tcf_hash_create(parm->index, est, a, sizeof(*p), ovr, bind);
-		if (p == NULL)
+		pc = tcf_hash_create(parm->index, est, a, sizeof(*p), bind,
+				     &pedit_idx_gen, &pedit_hash_info);
+		if (unlikely(!pc))
 			return -ENOMEM;
+		p = to_pedit(pc);
 		keys = kmalloc(ksize, GFP_KERNEL);
 		if (keys == NULL) {
-			kfree(p);
+			kfree(pc);
 			return -ENOMEM;
 		}
 		ret = ACT_P_CREATED;
 	} else {
+		p = to_pedit(pc);
 		if (!ovr) {
-			tcf_hash_release(p, bind);
+			tcf_hash_release(pc, bind, &pedit_hash_info);
 			return -EEXIST;
 		}
-		if (p->nkeys && p->nkeys != parm->nkeys) {
+		if (p->tcfp_nkeys && p->tcfp_nkeys != parm->nkeys) {
 			keys = kmalloc(ksize, GFP_KERNEL);
 			if (keys == NULL)
 				return -ENOMEM;
 		}
 	}
 
-	spin_lock_bh(&p->lock);
-	p->flags = parm->flags;
-	p->action = parm->action;
+	spin_lock_bh(&p->tcf_lock);
+	p->tcfp_flags = parm->flags;
+	p->tcf_action = parm->action;
 	if (keys) {
-		kfree(p->keys);
-		p->keys = keys;
-		p->nkeys = parm->nkeys;
+		kfree(p->tcfp_keys);
+		p->tcfp_keys = keys;
+		p->tcfp_nkeys = parm->nkeys;
 	}
-	memcpy(p->keys, parm->keys, ksize);
-	spin_unlock_bh(&p->lock);
+	memcpy(p->tcfp_keys, parm->keys, ksize);
+	spin_unlock_bh(&p->tcf_lock);
 	if (ret == ACT_P_CREATED)
-		tcf_hash_insert(p);
+		tcf_hash_insert(pc, &pedit_hash_info);
 	return ret;
 }
 
-static int
-tcf_pedit_cleanup(struct tc_action *a, int bind)
+static int tcf_pedit_cleanup(struct tc_action *a, int bind)
 {
-	struct tcf_pedit *p = PRIV(a, pedit);
+	struct tcf_pedit *p = a->priv;
 
-	if (p != NULL) {
-		struct tc_pedit_key *keys = p->keys;
-		if (tcf_hash_release(p, bind)) {
+	if (p) {
+		struct tc_pedit_key *keys = p->tcfp_keys;
+		if (tcf_hash_release(&p->common, bind, &pedit_hash_info)) {
 			kfree(keys);
 			return 1;
 		}
@@ -128,30 +123,30 @@ tcf_pedit_cleanup(struct tc_action *a, i
 	return 0;
 }
 
-static int
-tcf_pedit(struct sk_buff *skb, struct tc_action *a, struct tcf_result *res)
+static int tcf_pedit(struct sk_buff *skb, struct tc_action *a,
+		     struct tcf_result *res)
 {
-	struct tcf_pedit *p = PRIV(a, pedit);
+	struct tcf_pedit *p = a->priv;
 	int i, munged = 0;
 	u8 *pptr;
 
 	if (!(skb->tc_verd & TC_OK2MUNGE)) {
 		/* should we set skb->cloned? */
 		if (pskb_expand_head(skb, 0, 0, GFP_ATOMIC)) {
-			return p->action;
+			return p->tcf_action;
 		}
 	}
 
 	pptr = skb->nh.raw;
 
-	spin_lock(&p->lock);
+	spin_lock(&p->tcf_lock);
 
-	p->tm.lastuse = jiffies;
+	p->tcf_tm.lastuse = jiffies;
 
-	if (p->nkeys > 0) {
-		struct tc_pedit_key *tkey = p->keys;
+	if (p->tcfp_nkeys > 0) {
+		struct tc_pedit_key *tkey = p->tcfp_keys;
 
-		for (i = p->nkeys; i > 0; i--, tkey++) {
+		for (i = p->tcfp_nkeys; i > 0; i--, tkey++) {
 			u32 *ptr;
 			int offset = tkey->off;
 
@@ -169,7 +164,8 @@ tcf_pedit(struct sk_buff *skb, struct tc
 				printk("offset must be on 32 bit boundaries\n");
 				goto bad;
 			}
-			if (skb->len < 0 || (offset > 0 && offset > skb->len)) {
+			if (skb->len < 0 ||
+			    (offset > 0 && offset > skb->len)) {
 				printk("offset %d cant exceed pkt length %d\n",
 				       offset, skb->len);
 				goto bad;
@@ -185,63 +181,47 @@ tcf_pedit(struct sk_buff *skb, struct tc
 			skb->tc_verd = SET_TC_MUNGED(skb->tc_verd);
 		goto done;
 	} else {
-		printk("pedit BUG: index %d\n",p->index);
+		printk("pedit BUG: index %d\n", p->tcf_index);
 	}
 
 bad:
-	p->qstats.overlimits++;
+	p->tcf_qstats.overlimits++;
 done:
-	p->bstats.bytes += skb->len;
-	p->bstats.packets++;
-	spin_unlock(&p->lock);
-	return p->action;
+	p->tcf_bstats.bytes += skb->len;
+	p->tcf_bstats.packets++;
+	spin_unlock(&p->tcf_lock);
+	return p->tcf_action;
 }
 
-static int
-tcf_pedit_dump(struct sk_buff *skb, struct tc_action *a,int bind, int ref)
+static int tcf_pedit_dump(struct sk_buff *skb, struct tc_action *a,
+			  int bind, int ref)
 {
 	unsigned char *b = skb->tail;
+	struct tcf_pedit *p = a->priv;
 	struct tc_pedit *opt;
-	struct tcf_pedit *p = PRIV(a, pedit);
 	struct tcf_t t;
 	int s; 
 		
-	s = sizeof(*opt) + p->nkeys * sizeof(struct tc_pedit_key);
+	s = sizeof(*opt) + p->tcfp_nkeys * sizeof(struct tc_pedit_key);
 
 	/* netlink spinlocks held above us - must use ATOMIC */
 	opt = kzalloc(s, GFP_ATOMIC);
-	if (opt == NULL)
+	if (unlikely(!opt))
 		return -ENOBUFS;
 
-	memcpy(opt->keys, p->keys, p->nkeys * sizeof(struct tc_pedit_key));
-	opt->index = p->index;
-	opt->nkeys = p->nkeys;
-	opt->flags = p->flags;
-	opt->action = p->action;
-	opt->refcnt = p->refcnt - ref;
-	opt->bindcnt = p->bindcnt - bind;
-
-
-#ifdef PEDIT_DEB
-	{                
-		/* Debug - get rid of later */
-		int i;
-		struct tc_pedit_key *key = opt->keys;
-
-		for (i=0; i<opt->nkeys; i++, key++) {
-			printk( "\n key #%d",i);
-			printk( "  at %d: val %08x mask %08x",
-			(unsigned int)key->off,
-			(unsigned int)key->val,
-			(unsigned int)key->mask);
-		}
-	}
-#endif
+	memcpy(opt->keys, p->tcfp_keys,
+	       p->tcfp_nkeys * sizeof(struct tc_pedit_key));
+	opt->index = p->tcf_index;
+	opt->nkeys = p->tcfp_nkeys;
+	opt->flags = p->tcfp_flags;
+	opt->action = p->tcf_action;
+	opt->refcnt = p->tcf_refcnt - ref;
+	opt->bindcnt = p->tcf_bindcnt - bind;
 
 	RTA_PUT(skb, TCA_PEDIT_PARMS, s, opt);
-	t.install = jiffies_to_clock_t(jiffies - p->tm.install);
-	t.lastuse = jiffies_to_clock_t(jiffies - p->tm.lastuse);
-	t.expires = jiffies_to_clock_t(p->tm.expires);
+	t.install = jiffies_to_clock_t(jiffies - p->tcf_tm.install);
+	t.lastuse = jiffies_to_clock_t(jiffies - p->tcf_tm.lastuse);
+	t.expires = jiffies_to_clock_t(p->tcf_tm.expires);
 	RTA_PUT(skb, TCA_PEDIT_TM, sizeof(t), &t);
 	kfree(opt);
 	return skb->len;
@@ -252,9 +232,9 @@ rtattr_failure:
 	return -1;
 }
 
-static
-struct tc_action_ops act_pedit_ops = {
+static struct tc_action_ops act_pedit_ops = {
 	.kind		=	"pedit",
+	.hinfo		=	&pedit_hash_info,
 	.type		=	TCA_ACT_PEDIT,
 	.capab		=	TCA_CAP_NONE,
 	.owner		=	THIS_MODULE,
@@ -270,14 +250,12 @@ MODULE_AUTHOR("Jamal Hadi Salim(2002-4)"
 MODULE_DESCRIPTION("Generic Packet Editor actions");
 MODULE_LICENSE("GPL");
 
-static int __init
-pedit_init_module(void)
+static int __init pedit_init_module(void)
 {
 	return tcf_register_action(&act_pedit_ops);
 }
 
-static void __exit
-pedit_cleanup_module(void)
+static void __exit pedit_cleanup_module(void)
 {
 	tcf_unregister_action(&act_pedit_ops);
 }
diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index da905d7..fed47b6 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -32,43 +32,27 @@ #include <linux/init.h>
 #include <net/sock.h>
 #include <net/act_api.h>
 
-#define L2T(p,L)   ((p)->R_tab->data[(L)>>(p)->R_tab->rate.cell_log])
-#define L2T_P(p,L) ((p)->P_tab->data[(L)>>(p)->P_tab->rate.cell_log])
-#define PRIV(a) ((struct tcf_police *) (a)->priv)
-
-/* use generic hash table */
-#define MY_TAB_SIZE     16
-#define MY_TAB_MASK     15
-static u32 idx_gen;
-static struct tcf_police *tcf_police_ht[MY_TAB_SIZE];
-/* Policer hash table lock */
-static DEFINE_RWLOCK(police_lock);
-
-/* Each policer is serialized by its individual spinlock */
+#define L2T(p,L)   ((p)->tcfp_R_tab->data[(L)>>(p)->tcfp_R_tab->rate.cell_log])
+#define L2T_P(p,L) ((p)->tcfp_P_tab->data[(L)>>(p)->tcfp_P_tab->rate.cell_log])
 
-static __inline__ unsigned tcf_police_hash(u32 index)
-{
-	return index&0xF;
-}
+#define POL_TAB_MASK     15
+static struct tcf_common *tcf_police_ht[POL_TAB_MASK + 1];
+static u32 police_idx_gen;
+static DEFINE_RWLOCK(police_lock);
 
-static __inline__ struct tcf_police * tcf_police_lookup(u32 index)
-{
-	struct tcf_police *p;
+static struct tcf_hashinfo police_hash_info = {
+	.htab	=	tcf_police_ht,
+	.hmask	=	POL_TAB_MASK,
+	.lock	=	&police_lock,
+};
 
-	read_lock(&police_lock);
-	for (p = tcf_police_ht[tcf_police_hash(index)]; p; p = p->next) {
-		if (p->index == index)
-			break;
-	}
-	read_unlock(&police_lock);
-	return p;
-}
+/* Each policer is serialized by its individual spinlock */
 
 #ifdef CONFIG_NET_CLS_ACT
 static int tcf_act_police_walker(struct sk_buff *skb, struct netlink_callback *cb,
                               int type, struct tc_action *a)
 {
-	struct tcf_police *p;
+	struct tcf_common *p;
 	int err = 0, index = -1, i = 0, s_i = 0, n_i = 0;
 	struct rtattr *r;
 
@@ -76,10 +60,10 @@ static int tcf_act_police_walker(struct 
 
 	s_i = cb->args[0];
 
-	for (i = 0; i < MY_TAB_SIZE; i++) {
-		p = tcf_police_ht[tcf_police_hash(i)];
+	for (i = 0; i < (POL_TAB_MASK + 1); i++) {
+		p = tcf_police_ht[tcf_hash(i, POL_TAB_MASK)];
 
-		for (; p; p = p->next) {
+		for (; p; p = p->tcfc_next) {
 			index++;
 			if (index < s_i)
 				continue;
@@ -110,48 +94,26 @@ rtattr_failure:
 	skb_trim(skb, (u8*)r - skb->data);
 	goto done;
 }
-
-static inline int
-tcf_act_police_hash_search(struct tc_action *a, u32 index)
-{
-	struct tcf_police *p = tcf_police_lookup(index);
-
-	if (p != NULL) {
-		a->priv = p;
-		return 1;
-	} else {
-		return 0;
-	}
-}
 #endif
 
-static inline u32 tcf_police_new_index(void)
-{
-	do {
-		if (++idx_gen == 0)
-			idx_gen = 1;
-	} while (tcf_police_lookup(idx_gen));
-
-	return idx_gen;
-}
-
 void tcf_police_destroy(struct tcf_police *p)
 {
-	unsigned h = tcf_police_hash(p->index);
-	struct tcf_police **p1p;
+	unsigned int h = tcf_hash(p->tcf_index, POL_TAB_MASK);
+	struct tcf_common **p1p;
 	
-	for (p1p = &tcf_police_ht[h]; *p1p; p1p = &(*p1p)->next) {
-		if (*p1p == p) {
+	for (p1p = &tcf_police_ht[h]; *p1p; p1p = &(*p1p)->tcfc_next) {
+		if (*p1p == &p->common) {
 			write_lock_bh(&police_lock);
-			*p1p = p->next;
+			*p1p = p->tcf_next;
 			write_unlock_bh(&police_lock);
 #ifdef CONFIG_NET_ESTIMATOR
-			gen_kill_estimator(&p->bstats, &p->rate_est);
+			gen_kill_estimator(&p->tcf_bstats,
+					   &p->tcf_rate_est);
 #endif
-			if (p->R_tab)
-				qdisc_put_rtab(p->R_tab);
-			if (p->P_tab)
-				qdisc_put_rtab(p->P_tab);
+			if (p->tcfp_R_tab)
+				qdisc_put_rtab(p->tcfp_R_tab);
+			if (p->tcfp_P_tab)
+				qdisc_put_rtab(p->tcfp_P_tab);
 			kfree(p);
 			return;
 		}
@@ -167,7 +129,7 @@ static int tcf_act_police_locate(struct 
 	int ret = 0, err;
 	struct rtattr *tb[TCA_POLICE_MAX];
 	struct tc_police *parm;
-	struct tcf_police *p;
+	struct tcf_police *police;
 	struct qdisc_rate_table *R_tab = NULL, *P_tab = NULL;
 
 	if (rta == NULL || rtattr_parse_nested(tb, TCA_POLICE_MAX, rta) < 0)
@@ -185,27 +147,32 @@ static int tcf_act_police_locate(struct 
 	    RTA_PAYLOAD(tb[TCA_POLICE_RESULT-1]) != sizeof(u32))
 		return -EINVAL;
 
-	if (parm->index && (p = tcf_police_lookup(parm->index)) != NULL) {
-		a->priv = p;
-		if (bind) {
-			p->bindcnt += 1;
-			p->refcnt += 1;
+	if (parm->index) {
+		struct tcf_common *pc;
+
+		pc = tcf_hash_lookup(parm->index, &police_hash_info);
+		if (pc != NULL) {
+			a->priv = pc;
+			police = to_police(pc);
+			if (bind) {
+				police->tcf_bindcnt += 1;
+				police->tcf_refcnt += 1;
+			}
+			if (ovr)
+				goto override;
+			return ret;
 		}
-		if (ovr)
-			goto override;
-		return ret;
 	}
 
-	p = kzalloc(sizeof(*p), GFP_KERNEL);
-	if (p == NULL)
+	police = kzalloc(sizeof(*police), GFP_KERNEL);
+	if (police == NULL)
 		return -ENOMEM;
-
 	ret = ACT_P_CREATED;
-	p->refcnt = 1;
-	spin_lock_init(&p->lock);
-	p->stats_lock = &p->lock;
+	police->tcf_refcnt = 1;
+	spin_lock_init(&police->tcf_lock);
+	police->tcf_stats_lock = &police->tcf_lock;
 	if (bind)
-		p->bindcnt = 1;
+		police->tcf_bindcnt = 1;
 override:
 	if (parm->rate.rate) {
 		err = -ENOMEM;
@@ -215,67 +182,71 @@ override:
 		if (parm->peakrate.rate) {
 			P_tab = qdisc_get_rtab(&parm->peakrate,
 					       tb[TCA_POLICE_PEAKRATE-1]);
-			if (p->P_tab == NULL) {
+			if (P_tab == NULL) {
 				qdisc_put_rtab(R_tab);
 				goto failure;
 			}
 		}
 	}
 	/* No failure allowed after this point */
-	spin_lock_bh(&p->lock);
+	spin_lock_bh(&police->tcf_lock);
 	if (R_tab != NULL) {
-		qdisc_put_rtab(p->R_tab);
-		p->R_tab = R_tab;
+		qdisc_put_rtab(police->tcfp_R_tab);
+		police->tcfp_R_tab = R_tab;
 	}
 	if (P_tab != NULL) {
-		qdisc_put_rtab(p->P_tab);
-		p->P_tab = P_tab;
+		qdisc_put_rtab(police->tcfp_P_tab);
+		police->tcfp_P_tab = P_tab;
 	}
 
 	if (tb[TCA_POLICE_RESULT-1])
-		p->result = *(u32*)RTA_DATA(tb[TCA_POLICE_RESULT-1]);
-	p->toks = p->burst = parm->burst;
-	p->mtu = parm->mtu;
-	if (p->mtu == 0) {
-		p->mtu = ~0;
-		if (p->R_tab)
-			p->mtu = 255<<p->R_tab->rate.cell_log;
+		police->tcfp_result = *(u32*)RTA_DATA(tb[TCA_POLICE_RESULT-1]);
+	police->tcfp_toks = police->tcfp_burst = parm->burst;
+	police->tcfp_mtu = parm->mtu;
+	if (police->tcfp_mtu == 0) {
+		police->tcfp_mtu = ~0;
+		if (police->tcfp_R_tab)
+			police->tcfp_mtu = 255<<police->tcfp_R_tab->rate.cell_log;
 	}
-	if (p->P_tab)
-		p->ptoks = L2T_P(p, p->mtu);
-	p->action = parm->action;
+	if (police->tcfp_P_tab)
+		police->tcfp_ptoks = L2T_P(police, police->tcfp_mtu);
+	police->tcf_action = parm->action;
 
 #ifdef CONFIG_NET_ESTIMATOR
 	if (tb[TCA_POLICE_AVRATE-1])
-		p->ewma_rate = *(u32*)RTA_DATA(tb[TCA_POLICE_AVRATE-1]);
+		police->tcfp_ewma_rate =
+			*(u32*)RTA_DATA(tb[TCA_POLICE_AVRATE-1]);
 	if (est)
-		gen_replace_estimator(&p->bstats, &p->rate_est, p->stats_lock, est);
+		gen_replace_estimator(&police->tcf_bstats,
+				      &police->tcf_rate_est,
+				      police->tcf_stats_lock, est);
 #endif
 
-	spin_unlock_bh(&p->lock);
+	spin_unlock_bh(&police->tcf_lock);
 	if (ret != ACT_P_CREATED)
 		return ret;
 
-	PSCHED_GET_TIME(p->t_c);
-	p->index = parm->index ? : tcf_police_new_index();
-	h = tcf_police_hash(p->index);
+	PSCHED_GET_TIME(police->tcfp_t_c);
+	police->tcf_index = parm->index ? parm->index :
+		tcf_hash_new_index(&police_idx_gen, &police_hash_info);
+	h = tcf_hash(police->tcf_index, POL_TAB_MASK);
 	write_lock_bh(&police_lock);
-	p->next = tcf_police_ht[h];
-	tcf_police_ht[h] = p;
+	police->tcf_next = tcf_police_ht[h];
+	tcf_police_ht[h] = &police->common;
 	write_unlock_bh(&police_lock);
 
-	a->priv = p;
+	a->priv = police;
 	return ret;
 
 failure:
 	if (ret == ACT_P_CREATED)
-		kfree(p);
+		kfree(police);
 	return err;
 }
 
 static int tcf_act_police_cleanup(struct tc_action *a, int bind)
 {
-	struct tcf_police *p = PRIV(a);
+	struct tcf_police *p = a->priv;
 
 	if (p != NULL)
 		return tcf_police_release(p, bind);
@@ -285,86 +256,87 @@ static int tcf_act_police_cleanup(struct
 static int tcf_act_police(struct sk_buff *skb, struct tc_action *a,
                           struct tcf_result *res)
 {
+	struct tcf_police *police = a->priv;
 	psched_time_t now;
-	struct tcf_police *p = PRIV(a);
 	long toks;
 	long ptoks = 0;
 
-	spin_lock(&p->lock);
+	spin_lock(&police->tcf_lock);
 
-	p->bstats.bytes += skb->len;
-	p->bstats.packets++;
+	police->tcf_bstats.bytes += skb->len;
+	police->tcf_bstats.packets++;
 
 #ifdef CONFIG_NET_ESTIMATOR
-	if (p->ewma_rate && p->rate_est.bps >= p->ewma_rate) {
-		p->qstats.overlimits++;
-		spin_unlock(&p->lock);
-		return p->action;
+	if (police->tcfp_ewma_rate &&
+	    police->tcf_rate_est.bps >= police->tcfp_ewma_rate) {
+		police->tcf_qstats.overlimits++;
+		spin_unlock(&police->tcf_lock);
+		return police->tcf_action;
 	}
 #endif
 
-	if (skb->len <= p->mtu) {
-		if (p->R_tab == NULL) {
-			spin_unlock(&p->lock);
-			return p->result;
+	if (skb->len <= police->tcfp_mtu) {
+		if (police->tcfp_R_tab == NULL) {
+			spin_unlock(&police->tcf_lock);
+			return police->tcfp_result;
 		}
 
 		PSCHED_GET_TIME(now);
 
-		toks = PSCHED_TDIFF_SAFE(now, p->t_c, p->burst);
-
-		if (p->P_tab) {
-			ptoks = toks + p->ptoks;
-			if (ptoks > (long)L2T_P(p, p->mtu))
-				ptoks = (long)L2T_P(p, p->mtu);
-			ptoks -= L2T_P(p, skb->len);
+		toks = PSCHED_TDIFF_SAFE(now, police->tcfp_t_c,
+					 police->tcfp_burst);
+		if (police->tcfp_P_tab) {
+			ptoks = toks + police->tcfp_ptoks;
+			if (ptoks > (long)L2T_P(police, police->tcfp_mtu))
+				ptoks = (long)L2T_P(police, police->tcfp_mtu);
+			ptoks -= L2T_P(police, skb->len);
 		}
-		toks += p->toks;
-		if (toks > (long)p->burst)
-			toks = p->burst;
-		toks -= L2T(p, skb->len);
-
+		toks += police->tcfp_toks;
+		if (toks > (long)police->tcfp_burst)
+			toks = police->tcfp_burst;
+		toks -= L2T(police, skb->len);
 		if ((toks|ptoks) >= 0) {
-			p->t_c = now;
-			p->toks = toks;
-			p->ptoks = ptoks;
-			spin_unlock(&p->lock);
-			return p->result;
+			police->tcfp_t_c = now;
+			police->tcfp_toks = toks;
+			police->tcfp_ptoks = ptoks;
+			spin_unlock(&police->tcf_lock);
+			return police->tcfp_result;
 		}
 	}
 
-	p->qstats.overlimits++;
-	spin_unlock(&p->lock);
-	return p->action;
+	police->tcf_qstats.overlimits++;
+	spin_unlock(&police->tcf_lock);
+	return police->tcf_action;
 }
 
 static int
 tcf_act_police_dump(struct sk_buff *skb, struct tc_action *a, int bind, int ref)
 {
 	unsigned char	 *b = skb->tail;
+	struct tcf_police *police = a->priv;
 	struct tc_police opt;
-	struct tcf_police *p = PRIV(a);
-
-	opt.index = p->index;
-	opt.action = p->action;
-	opt.mtu = p->mtu;
-	opt.burst = p->burst;
-	opt.refcnt = p->refcnt - ref;
-	opt.bindcnt = p->bindcnt - bind;
-	if (p->R_tab)
-		opt.rate = p->R_tab->rate;
+
+	opt.index = police->tcf_index;
+	opt.action = police->tcf_action;
+	opt.mtu = police->tcfp_mtu;
+	opt.burst = police->tcfp_burst;
+	opt.refcnt = police->tcf_refcnt - ref;
+	opt.bindcnt = police->tcf_bindcnt - bind;
+	if (police->tcfp_R_tab)
+		opt.rate = police->tcfp_R_tab->rate;
 	else
 		memset(&opt.rate, 0, sizeof(opt.rate));
-	if (p->P_tab)
-		opt.peakrate = p->P_tab->rate;
+	if (police->tcfp_P_tab)
+		opt.peakrate = police->tcfp_P_tab->rate;
 	else
 		memset(&opt.peakrate, 0, sizeof(opt.peakrate));
 	RTA_PUT(skb, TCA_POLICE_TBF, sizeof(opt), &opt);
-	if (p->result)
-		RTA_PUT(skb, TCA_POLICE_RESULT, sizeof(int), &p->result);
+	if (police->tcfp_result)
+		RTA_PUT(skb, TCA_POLICE_RESULT, sizeof(int),
+			&police->tcfp_result);
 #ifdef CONFIG_NET_ESTIMATOR
-	if (p->ewma_rate)
-		RTA_PUT(skb, TCA_POLICE_AVRATE, 4, &p->ewma_rate);
+	if (police->tcfp_ewma_rate)
+		RTA_PUT(skb, TCA_POLICE_AVRATE, 4, &police->tcfp_ewma_rate);
 #endif
 	return skb->len;
 
@@ -379,13 +351,14 @@ MODULE_LICENSE("GPL");
 
 static struct tc_action_ops act_police_ops = {
 	.kind		=	"police",
+	.hinfo		=	&police_hash_info,
 	.type		=	TCA_ID_POLICE,
 	.capab		=	TCA_CAP_NONE,
 	.owner		=	THIS_MODULE,
 	.act		=	tcf_act_police,
 	.dump		=	tcf_act_police_dump,
 	.cleanup	=	tcf_act_police_cleanup,
-	.lookup		=	tcf_act_police_hash_search,
+	.lookup		=	tcf_hash_search,
 	.init		=	tcf_act_police_locate,
 	.walk		=	tcf_act_police_walker
 };
@@ -407,10 +380,39 @@ module_exit(police_cleanup_module);
 
 #else /* CONFIG_NET_CLS_ACT */
 
-struct tcf_police * tcf_police_locate(struct rtattr *rta, struct rtattr *est)
+static struct tcf_common *tcf_police_lookup(u32 index)
 {
-	unsigned h;
-	struct tcf_police *p;
+	struct tcf_hashinfo *hinfo = &police_hash_info;
+	struct tcf_common *p;
+
+	read_lock(hinfo->lock);
+	for (p = hinfo->htab[tcf_hash(index, hinfo->hmask)]; p;
+	     p = p->tcfc_next) {
+		if (p->tcfc_index == index)
+			break;
+	}
+	read_unlock(hinfo->lock);
+
+	return p;
+}
+
+static u32 tcf_police_new_index(void)
+{
+	u32 *idx_gen = &police_idx_gen;
+	u32 val = *idx_gen;
+
+	do {
+		if (++val == 0)
+			val = 1;
+	} while (tcf_police_lookup(val));
+
+	return (*idx_gen = val);
+}
+
+struct tcf_police *tcf_police_locate(struct rtattr *rta, struct rtattr *est)
+{
+	unsigned int h;
+	struct tcf_police *police;
 	struct rtattr *tb[TCA_POLICE_MAX];
 	struct tc_police *parm;
 
@@ -423,149 +425,158 @@ struct tcf_police * tcf_police_locate(st
 
 	parm = RTA_DATA(tb[TCA_POLICE_TBF-1]);
 
-	if (parm->index && (p = tcf_police_lookup(parm->index)) != NULL) {
-		p->refcnt++;
-		return p;
-	}
+	if (parm->index) {
+		struct tcf_common *pc;
 
-	p = kzalloc(sizeof(*p), GFP_KERNEL);
-	if (p == NULL)
+		pc = tcf_police_lookup(parm->index);
+		if (pc) {
+			police = to_police(pc);
+			police->tcf_refcnt++;
+			return police;
+		}
+	}
+	police = kzalloc(sizeof(*police), GFP_KERNEL);
+	if (unlikely(!police))
 		return NULL;
 
-	p->refcnt = 1;
-	spin_lock_init(&p->lock);
-	p->stats_lock = &p->lock;
+	police->tcf_refcnt = 1;
+	spin_lock_init(&police->tcf_lock);
+	police->tcf_stats_lock = &police->tcf_lock;
 	if (parm->rate.rate) {
-		p->R_tab = qdisc_get_rtab(&parm->rate, tb[TCA_POLICE_RATE-1]);
-		if (p->R_tab == NULL)
+		police->tcfp_R_tab =
+			qdisc_get_rtab(&parm->rate, tb[TCA_POLICE_RATE-1]);
+		if (police->tcfp_R_tab == NULL)
 			goto failure;
 		if (parm->peakrate.rate) {
-			p->P_tab = qdisc_get_rtab(&parm->peakrate,
-			                          tb[TCA_POLICE_PEAKRATE-1]);
-			if (p->P_tab == NULL)
+			police->tcfp_P_tab =
+				qdisc_get_rtab(&parm->peakrate,
+					       tb[TCA_POLICE_PEAKRATE-1]);
+			if (police->tcfp_P_tab == NULL)
 				goto failure;
 		}
 	}
 	if (tb[TCA_POLICE_RESULT-1]) {
 		if (RTA_PAYLOAD(tb[TCA_POLICE_RESULT-1]) != sizeof(u32))
 			goto failure;
-		p->result = *(u32*)RTA_DATA(tb[TCA_POLICE_RESULT-1]);
+		police->tcfp_result = *(u32*)RTA_DATA(tb[TCA_POLICE_RESULT-1]);
 	}
 #ifdef CONFIG_NET_ESTIMATOR
 	if (tb[TCA_POLICE_AVRATE-1]) {
 		if (RTA_PAYLOAD(tb[TCA_POLICE_AVRATE-1]) != sizeof(u32))
 			goto failure;
-		p->ewma_rate = *(u32*)RTA_DATA(tb[TCA_POLICE_AVRATE-1]);
+		police->tcfp_ewma_rate =
+			*(u32*)RTA_DATA(tb[TCA_POLICE_AVRATE-1]);
 	}
 #endif
-	p->toks = p->burst = parm->burst;
-	p->mtu = parm->mtu;
-	if (p->mtu == 0) {
-		p->mtu = ~0;
-		if (p->R_tab)
-			p->mtu = 255<<p->R_tab->rate.cell_log;
+	police->tcfp_toks = police->tcfp_burst = parm->burst;
+	police->tcfp_mtu = parm->mtu;
+	if (police->tcfp_mtu == 0) {
+		police->tcfp_mtu = ~0;
+		if (police->tcfp_R_tab)
+			police->tcfp_mtu = 255<<police->tcfp_R_tab->rate.cell_log;
 	}
-	if (p->P_tab)
-		p->ptoks = L2T_P(p, p->mtu);
-	PSCHED_GET_TIME(p->t_c);
-	p->index = parm->index ? : tcf_police_new_index();
-	p->action = parm->action;
+	if (police->tcfp_P_tab)
+		police->tcfp_ptoks = L2T_P(police, police->tcfp_mtu);
+	PSCHED_GET_TIME(police->tcfp_t_c);
+	police->tcf_index = parm->index ? parm->index :
+		tcf_police_new_index();
+	police->tcf_action = parm->action;
 #ifdef CONFIG_NET_ESTIMATOR
 	if (est)
-		gen_new_estimator(&p->bstats, &p->rate_est, p->stats_lock, est);
+		gen_new_estimator(&police->tcf_bstats, &police->tcf_rate_est,
+				  police->tcf_stats_lock, est);
 #endif
-	h = tcf_police_hash(p->index);
+	h = tcf_hash(police->tcf_index, POL_TAB_MASK);
 	write_lock_bh(&police_lock);
-	p->next = tcf_police_ht[h];
-	tcf_police_ht[h] = p;
+	police->tcf_next = tcf_police_ht[h];
+	tcf_police_ht[h] = &police->common;
 	write_unlock_bh(&police_lock);
-	return p;
+	return police;
 
 failure:
-	if (p->R_tab)
-		qdisc_put_rtab(p->R_tab);
-	kfree(p);
+	if (police->tcfp_R_tab)
+		qdisc_put_rtab(police->tcfp_R_tab);
+	kfree(police);
 	return NULL;
 }
 
-int tcf_police(struct sk_buff *skb, struct tcf_police *p)
+int tcf_police(struct sk_buff *skb, struct tcf_police *police)
 {
 	psched_time_t now;
 	long toks;
 	long ptoks = 0;
 
-	spin_lock(&p->lock);
+	spin_lock(&police->tcf_lock);
 
-	p->bstats.bytes += skb->len;
-	p->bstats.packets++;
+	police->tcf_bstats.bytes += skb->len;
+	police->tcf_bstats.packets++;
 
 #ifdef CONFIG_NET_ESTIMATOR
-	if (p->ewma_rate && p->rate_est.bps >= p->ewma_rate) {
-		p->qstats.overlimits++;
-		spin_unlock(&p->lock);
-		return p->action;
+	if (police->tcfp_ewma_rate &&
+	    police->tcf_rate_est.bps >= police->tcfp_ewma_rate) {
+		police->tcf_qstats.overlimits++;
+		spin_unlock(&police->tcf_lock);
+		return police->tcf_action;
 	}
 #endif
-
-	if (skb->len <= p->mtu) {
-		if (p->R_tab == NULL) {
-			spin_unlock(&p->lock);
-			return p->result;
+	if (skb->len <= police->tcfp_mtu) {
+		if (police->tcfp_R_tab == NULL) {
+			spin_unlock(&police->tcf_lock);
+			return police->tcfp_result;
 		}
 
 		PSCHED_GET_TIME(now);
-
-		toks = PSCHED_TDIFF_SAFE(now, p->t_c, p->burst);
-
-		if (p->P_tab) {
-			ptoks = toks + p->ptoks;
-			if (ptoks > (long)L2T_P(p, p->mtu))
-				ptoks = (long)L2T_P(p, p->mtu);
-			ptoks -= L2T_P(p, skb->len);
+		toks = PSCHED_TDIFF_SAFE(now, police->tcfp_t_c,
+					 police->tcfp_burst);
+		if (police->tcfp_P_tab) {
+			ptoks = toks + police->tcfp_ptoks;
+			if (ptoks > (long)L2T_P(police, police->tcfp_mtu))
+				ptoks = (long)L2T_P(police, police->tcfp_mtu);
+			ptoks -= L2T_P(police, skb->len);
 		}
-		toks += p->toks;
-		if (toks > (long)p->burst)
-			toks = p->burst;
-		toks -= L2T(p, skb->len);
-
+		toks += police->tcfp_toks;
+		if (toks > (long)police->tcfp_burst)
+			toks = police->tcfp_burst;
+		toks -= L2T(police, skb->len);
 		if ((toks|ptoks) >= 0) {
-			p->t_c = now;
-			p->toks = toks;
-			p->ptoks = ptoks;
-			spin_unlock(&p->lock);
-			return p->result;
+			police->tcfp_t_c = now;
+			police->tcfp_toks = toks;
+			police->tcfp_ptoks = ptoks;
+			spin_unlock(&police->tcf_lock);
+			return police->tcfp_result;
 		}
 	}
 
-	p->qstats.overlimits++;
-	spin_unlock(&p->lock);
-	return p->action;
+	police->tcf_qstats.overlimits++;
+	spin_unlock(&police->tcf_lock);
+	return police->tcf_action;
 }
 EXPORT_SYMBOL(tcf_police);
 
-int tcf_police_dump(struct sk_buff *skb, struct tcf_police *p)
+int tcf_police_dump(struct sk_buff *skb, struct tcf_police *police)
 {
-	unsigned char	 *b = skb->tail;
+	unsigned char *b = skb->tail;
 	struct tc_police opt;
 
-	opt.index = p->index;
-	opt.action = p->action;
-	opt.mtu = p->mtu;
-	opt.burst = p->burst;
-	if (p->R_tab)
-		opt.rate = p->R_tab->rate;
+	opt.index = police->tcf_index;
+	opt.action = police->tcf_action;
+	opt.mtu = police->tcfp_mtu;
+	opt.burst = police->tcfp_burst;
+	if (police->tcfp_R_tab)
+		opt.rate = police->tcfp_R_tab->rate;
 	else
 		memset(&opt.rate, 0, sizeof(opt.rate));
-	if (p->P_tab)
-		opt.peakrate = p->P_tab->rate;
+	if (police->tcfp_P_tab)
+		opt.peakrate = police->tcfp_P_tab->rate;
 	else
 		memset(&opt.peakrate, 0, sizeof(opt.peakrate));
 	RTA_PUT(skb, TCA_POLICE_TBF, sizeof(opt), &opt);
-	if (p->result)
-		RTA_PUT(skb, TCA_POLICE_RESULT, sizeof(int), &p->result);
+	if (police->tcfp_result)
+		RTA_PUT(skb, TCA_POLICE_RESULT, sizeof(int),
+			&police->tcfp_result);
 #ifdef CONFIG_NET_ESTIMATOR
-	if (p->ewma_rate)
-		RTA_PUT(skb, TCA_POLICE_AVRATE, 4, &p->ewma_rate);
+	if (police->tcfp_ewma_rate)
+		RTA_PUT(skb, TCA_POLICE_AVRATE, 4, &police->tcfp_ewma_rate);
 #endif
 	return skb->len;
 
@@ -574,19 +585,20 @@ rtattr_failure:
 	return -1;
 }
 
-int tcf_police_dump_stats(struct sk_buff *skb, struct tcf_police *p)
+int tcf_police_dump_stats(struct sk_buff *skb, struct tcf_police *police)
 {
 	struct gnet_dump d;
 	
 	if (gnet_stats_start_copy_compat(skb, TCA_STATS2, TCA_STATS,
-			TCA_XSTATS, p->stats_lock, &d) < 0)
+					 TCA_XSTATS, police->tcf_stats_lock,
+					 &d) < 0)
 		goto errout;
 	
-	if (gnet_stats_copy_basic(&d, &p->bstats) < 0 ||
+	if (gnet_stats_copy_basic(&d, &police->tcf_bstats) < 0 ||
 #ifdef CONFIG_NET_ESTIMATOR
-	    gnet_stats_copy_rate_est(&d, &p->rate_est) < 0 ||
+	    gnet_stats_copy_rate_est(&d, &police->tcf_rate_est) < 0 ||
 #endif
-	    gnet_stats_copy_queue(&d, &p->qstats) < 0)
+	    gnet_stats_copy_queue(&d, &police->tcf_qstats) < 0)
 		goto errout;
 
 	if (gnet_stats_finish_copy(&d) < 0)
diff --git a/net/sched/act_simple.c b/net/sched/act_simple.c
index 17105c8..6f1eb66 100644
--- a/net/sched/act_simple.c
+++ b/net/sched/act_simple.c
@@ -20,54 +20,175 @@ #include <net/pkt_sched.h>
 
 #define TCA_ACT_SIMP 22
 
-/* XXX: Hide all these common elements under some macro 
- * probably
-*/
 #include <linux/tc_act/tc_defact.h>
 #include <net/tc_act/tc_defact.h>
 
-/* use generic hash table with 8 buckets */
-#define MY_TAB_SIZE     8
-#define MY_TAB_MASK     (MY_TAB_SIZE - 1)
-static u32 idx_gen;
-static struct tcf_defact *tcf_simp_ht[MY_TAB_SIZE];
+#define SIMP_TAB_MASK     7
+static struct tcf_common *tcf_simp_ht[SIMP_TAB_MASK + 1];
+static u32 simp_idx_gen;
 static DEFINE_RWLOCK(simp_lock);
 
-/* override the defaults */
-#define tcf_st		tcf_defact
-#define tc_st		tc_defact
-#define tcf_t_lock	simp_lock
-#define tcf_ht		tcf_simp_ht
-
-#define CONFIG_NET_ACT_INIT 1
-#include <net/pkt_act.h>
-#include <net/act_generic.h>
+struct tcf_hashinfo simp_hash_info = {
+	.htab	=	tcf_simp_ht,
+	.hmask	=	SIMP_TAB_MASK,
+	.lock	=	&simp_lock,
+};
 
 static int tcf_simp(struct sk_buff *skb, struct tc_action *a, struct tcf_result *res)
 {
-	struct tcf_defact *p = PRIV(a, defact);
+	struct tcf_defact *d = a->priv;
 
-	spin_lock(&p->lock);
-	p->tm.lastuse = jiffies;
-	p->bstats.bytes += skb->len;
-	p->bstats.packets++;
+	spin_lock(&d->tcf_lock);
+	d->tcf_tm.lastuse = jiffies;
+	d->tcf_bstats.bytes += skb->len;
+	d->tcf_bstats.packets++;
 
 	/* print policy string followed by _ then packet count 
 	 * Example if this was the 3rd packet and the string was "hello" 
 	 * then it would look like "hello_3" (without quotes) 
 	 **/
-	printk("simple: %s_%d\n", (char *)p->defdata, p->bstats.packets);
-	spin_unlock(&p->lock);
-	return p->action;
+	printk("simple: %s_%d\n",
+	       (char *)d->tcfd_defdata, d->tcf_bstats.packets);
+	spin_unlock(&d->tcf_lock);
+	return d->tcf_action;
+}
+
+static int tcf_simp_release(struct tcf_defact *d, int bind)
+{
+	int ret = 0;
+	if (d) {
+		if (bind)
+			d->tcf_bindcnt--;
+		d->tcf_refcnt--;
+		if (d->tcf_bindcnt <= 0 && d->tcf_refcnt <= 0) {
+			kfree(d->tcfd_defdata);
+			tcf_hash_destroy(&d->common, &simp_hash_info);
+			ret = 1;
+		}
+	}
+	return ret;
+}
+
+static int alloc_defdata(struct tcf_defact *d, u32 datalen, void *defdata)
+{
+	d->tcfd_defdata = kmalloc(datalen, GFP_KERNEL);
+	if (unlikely(!d->tcfd_defdata))
+		return -ENOMEM;
+	d->tcfd_datalen = datalen;
+	memcpy(d->tcfd_defdata, defdata, datalen);
+	return 0;
+}
+
+static int realloc_defdata(struct tcf_defact *d, u32 datalen, void *defdata)
+{
+	kfree(d->tcfd_defdata);
+	return alloc_defdata(d, datalen, defdata);
+}
+
+static int tcf_simp_init(struct rtattr *rta, struct rtattr *est,
+			 struct tc_action *a, int ovr, int bind)
+{
+	struct rtattr *tb[TCA_DEF_MAX];
+	struct tc_defact *parm;
+	struct tcf_defact *d;
+	struct tcf_common *pc;
+	void *defdata;
+	u32 datalen = 0;
+	int ret = 0;
+
+	if (rta == NULL || rtattr_parse_nested(tb, TCA_DEF_MAX, rta) < 0)
+		return -EINVAL;
+
+	if (tb[TCA_DEF_PARMS - 1] == NULL || 
+	    RTA_PAYLOAD(tb[TCA_DEF_PARMS - 1]) < sizeof(*parm))
+		return -EINVAL;
+
+	parm = RTA_DATA(tb[TCA_DEF_PARMS - 1]);
+	defdata = RTA_DATA(tb[TCA_DEF_DATA - 1]);
+	if (defdata == NULL)
+		return -EINVAL;
+
+	datalen = RTA_PAYLOAD(tb[TCA_DEF_DATA - 1]);
+	if (datalen <= 0)
+		return -EINVAL;
+
+	pc = tcf_hash_check(parm->index, a, bind, &simp_hash_info);
+	if (!pc) {
+		pc = tcf_hash_create(parm->index, est, a, sizeof(*d), bind,
+				     &simp_idx_gen, &simp_hash_info);
+		if (unlikely(!pc))
+			return -ENOMEM;
+
+		d = to_defact(pc);
+		ret = alloc_defdata(d, datalen, defdata);
+		if (ret < 0) {
+			kfree(pc);
+			return ret;
+		}
+		ret = ACT_P_CREATED;
+	} else {
+		d = to_defact(pc);
+		if (!ovr) {
+			tcf_simp_release(d, bind);
+			return -EEXIST;
+		}
+		realloc_defdata(d, datalen, defdata);
+	}
+
+	spin_lock_bh(&d->tcf_lock);
+	d->tcf_action = parm->action;
+	spin_unlock_bh(&d->tcf_lock);
+
+	if (ret == ACT_P_CREATED)
+		tcf_hash_insert(pc, &simp_hash_info);
+	return ret;
+}
+
+static inline int tcf_simp_cleanup(struct tc_action *a, int bind)
+{
+	struct tcf_defact *d = a->priv;
+
+	if (d)
+		return tcf_simp_release(d, bind);
+	return 0;
+}
+
+static inline int tcf_simp_dump(struct sk_buff *skb, struct tc_action *a,
+				int bind, int ref)
+{
+	unsigned char *b = skb->tail;
+	struct tcf_defact *d = a->priv;
+	struct tc_defact opt;
+	struct tcf_t t;
+
+	opt.index = d->tcf_index;
+	opt.refcnt = d->tcf_refcnt - ref;
+	opt.bindcnt = d->tcf_bindcnt - bind;
+	opt.action = d->tcf_action;
+	RTA_PUT(skb, TCA_DEF_PARMS, sizeof(opt), &opt);
+	RTA_PUT(skb, TCA_DEF_DATA, d->tcfd_datalen, d->tcfd_defdata);
+	t.install = jiffies_to_clock_t(jiffies - d->tcf_tm.install);
+	t.lastuse = jiffies_to_clock_t(jiffies - d->tcf_tm.lastuse);
+	t.expires = jiffies_to_clock_t(d->tcf_tm.expires);
+	RTA_PUT(skb, TCA_DEF_TM, sizeof(t), &t);
+	return skb->len;
+
+rtattr_failure:
+	skb_trim(skb, b - skb->data);
+	return -1;
 }
 
 static struct tc_action_ops act_simp_ops = {
-	.kind = "simple",
-	.type = TCA_ACT_SIMP,
-	.capab = TCA_CAP_NONE,
-	.owner = THIS_MODULE,
-	.act = tcf_simp,
-	tca_use_default_ops
+	.kind		=	"simple",
+	.hinfo		=	&simp_hash_info,
+	.type		=	TCA_ACT_SIMP,
+	.capab		=	TCA_CAP_NONE,
+	.owner		=	THIS_MODULE,
+	.act		=	tcf_simp,
+	.dump		=	tcf_simp_dump,
+	.cleanup	=	tcf_simp_cleanup,
+	.init		=	tcf_simp_init,
+	.walk		=	tcf_generic_walker,
 };
 
 MODULE_AUTHOR("Jamal Hadi Salim(2005)");

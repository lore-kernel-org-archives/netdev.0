From: Thomas Graf <tgraf@suug.ch>
Subject: [RFC] meta ematch
Date: Thu, 13 Jan 2005 18:41:11 +0100
Message-ID: <20050113174111.GP26856@postel.suug.ch>
References: <20050105110048.GO26856@postel.suug.ch> <1104931991.1117.152.camel@jzny.localdomain> <20050105144514.GQ26856@postel.suug.ch> <1105019225.2312.7.camel@jzny.localdomain> <20050106194102.GW26856@postel.suug.ch> <1105105511.1046.77.camel@jzny.localdomain> <20050108145457.GZ26856@postel.suug.ch> <1105363582.1041.162.camel@jzny.localdomain> <20050110211747.GA26856@postel.suug.ch> <1105394738.1085.63.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1105394738.1085.63.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1105394738.1085.63.camel@jzny.localdomain> 2005-01-10 17:05
> 
> Ok, you make a convincing arguement ;-> No more concerns from my side.
> Churn that code!
> 
Found some cycles today and wrote the meta ematch. It tried to
find a good compromise between speed and power.

So far I added the following matching possibilies:
 - random
 - load average (0,1,2)
 - dev (numeric and string)
 - indev (numeric and string)
 - realdev (numeric and string)
 - skb priority
 - ... protocol
 - ... security
 - ... pkttype (to easly match on multicast/broadcast)
 - ... pktlen
 - ... datalen
 - ... maclen
 - netfilter mark
 - ... cache
 - ... conntrack info
 - ... debug variable
 - tc index
 - ... verdict
 - ... classid
 - routing classid
 - .... iif

Yet to come are more routing and socket attributes such as queue
sizes, backlog sizes, neighbour attribute of the route found, ...

It is also possible to compare two kernel meta values, e.g
realdev equals dev.

Numeric matches may be modified via shift and mask operators
to for example only consider a part of nfmark.

Binary matches may have a shift modifier to only consider
a certain amount of the data, e.g. "eth1" with shift 1 would
end up with "eth". I added this because I wanted something
like eth% but didn't want to implement expensive string
operations.

If its not obvious, random and loadavg are intended for
load balancing purposes, i.e.
tc filter add ... basic meta random mask 1 eq 1 and \
loadavg_5 lt 10 action redirect ...



diff -Nru linux-2.6.10-bk14.orig/include/linux/pkt_cls.h linux-2.6.10-bk14/include/linux/pkt_cls.h
--- linux-2.6.10-bk14.orig/include/linux/pkt_cls.h	2005-01-13 11:18:05.000000000 +0100
+++ linux-2.6.10-bk14/include/linux/pkt_cls.h	2005-01-13 11:17:52.000000000 +0100
@@ -352,6 +352,7 @@
 	TCF_EM_CMP,
 	TCF_EM_NBYTE,
 	TCF_EM_U32,
+	TCF_EM_META,
 	__TCF_EM_MAX
 };
 
diff -Nru linux-2.6.10-bk14.orig/include/linux/tc_ematch/tc_em_meta.h linux-2.6.10-bk14/include/linux/tc_ematch/tc_em_meta.h
--- linux-2.6.10-bk14.orig/include/linux/tc_ematch/tc_em_meta.h	1970-01-01 01:00:00.000000000 +0100
+++ linux-2.6.10-bk14/include/linux/tc_ematch/tc_em_meta.h	2005-01-13 17:20:59.000000000 +0100
@@ -0,0 +1,71 @@
+#ifndef __LINUX_TC_EM_META_H
+#define __LINUX_TC_EM_META_H
+
+#include <linux/pkt_cls.h>
+
+enum
+{
+	TCA_EM_META_HDR,
+	TCA_EM_META_LVALUE,
+	TCA_EM_META_RVALUE,
+	__TCA_EM_META_MAX
+};
+#define TCA_EM_META_MAX (__TCA_EM_META_MAX - 1)
+
+struct tcf_meta_val
+{
+	__u16			kind;
+	__u8			shift;
+	__u8			op;
+};
+
+#define TCF_META_TYPE_MASK	(0xf << 12)
+#define TCF_META_TYPE(kind)	(((kind) & TCF_META_TYPE_MASK) >> 12)
+#define TCF_META_ID_MASK	0x7ff
+#define TCF_META_ID(kind)	((kind) & TCF_META_ID_MASK)
+
+enum
+{
+	TCF_META_TYPE_VAR,
+	TCF_META_TYPE_INT,
+	__TCF_META_TYPE_MAX
+};
+#define TCF_META_TYPE_MAX (__TCF_META_TYPE_MAX - 1)
+
+enum
+{
+	TCF_META_ID_VALUE,
+	TCF_META_ID_RANDOM,
+	TCF_META_ID_LOADAVG_0,
+	TCF_META_ID_LOADAVG_1,
+	TCF_META_ID_LOADAVG_2,
+	TCF_META_ID_DEV,
+	TCF_META_ID_INDEV,
+	TCF_META_ID_REALDEV,
+	TCF_META_ID_PRIORITY,
+	TCF_META_ID_PROTOCOL,
+	TCF_META_ID_SECURITY,
+	TCF_META_ID_PKTTYPE,
+	TCF_META_ID_PKTLEN,
+	TCF_META_ID_DATALEN,
+	TCF_META_ID_MACLEN,
+	TCF_META_ID_NFMARK,
+	TCF_META_ID_NFCACHE,
+	TCF_META_ID_NFCTINFO,
+	TCF_META_ID_NFDEBUG,
+	TCF_META_ID_TCINDEX,
+	TCF_META_ID_TCVERDICT,
+	TCF_META_ID_TCCLASSID,
+	TCF_META_ID_RTCLASSID,
+	TCF_META_ID_RTIIF,
+	__TCF_META_ID_MAX
+};
+#define TCF_META_ID_MAX (__TCF_META_ID_MAX - 1)
+
+struct tcf_meta_hdr
+{
+	struct tcf_meta_val	left;
+	struct tcf_meta_val	right;
+};
+
+#endif
diff -Nru linux-2.6.10-bk14.orig/net/sched/Kconfig linux-2.6.10-bk14/net/sched/Kconfig
--- linux-2.6.10-bk14.orig/net/sched/Kconfig	2005-01-13 11:18:05.000000000 +0100
+++ linux-2.6.10-bk14/net/sched/Kconfig	2005-01-13 11:17:52.000000000 +0100
@@ -428,6 +428,16 @@
 	  To compile this code as a module, choose M here: the
 	  module will be called em_u32.
 
+config NET_EMATCH_META
+	tristate "Metadata"
+	depends on NET_EMATCH
+	---help---
+	  Say Y here if you want to be ablt to classify packets based on
+	  metadata.
+
+	  To compile this code as a module, choose M here: the
+	  module will be called em_meta.
+
 config NET_CLS_ACT
 	bool "Packet ACTION"
 	depends on EXPERIMENTAL && NET_CLS && NET_QOS
diff -Nru linux-2.6.10-bk14.orig/net/sched/Makefile linux-2.6.10-bk14/net/sched/Makefile
--- linux-2.6.10-bk14.orig/net/sched/Makefile	2005-01-13 11:18:05.000000000 +0100
+++ linux-2.6.10-bk14/net/sched/Makefile	2005-01-13 11:17:52.000000000 +0100
@@ -37,3 +37,4 @@
 obj-$(CONFIG_NET_EMATCH_CMP)	+= em_cmp.o
 obj-$(CONFIG_NET_EMATCH_NBYTE)	+= em_nbyte.o
 obj-$(CONFIG_NET_EMATCH_U32)	+= em_u32.o
+obj-$(CONFIG_NET_EMATCH_META)	+= em_meta.o
diff -Nru linux-2.6.10-bk14.orig/net/sched/em_meta.c linux-2.6.10-bk14/net/sched/em_meta.c
--- linux-2.6.10-bk14.orig/net/sched/em_meta.c	1970-01-01 01:00:00.000000000 +0100
+++ linux-2.6.10-bk14/net/sched/em_meta.c	2005-01-13 18:07:04.000000000 +0100
@@ -0,0 +1,566 @@
+/*
+ * net/sched/em_meta.c	Metadata ematch
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Thomas Graf <tgraf@suug.ch>
+ */
+
+#include <linux/config.h>
+#include <linux/module.h>
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/string.h>
+#include <linux/skbuff.h>
+#include <linux/random.h>
+#include <linux/tc_ematch/tc_em_meta.h>
+#include <net/dst.h>
+#include <net/route.h>
+#include <net/pkt_cls.h>
+
+struct meta_value
+{
+	struct tcf_meta_val	hdr;
+	unsigned long		value;
+	unsigned int		len;
+};
+
+struct meta_match
+{
+	struct meta_value	lvalue;
+	struct meta_value	rvalue;
+};
+
+#define meta_id(value) (TCF_META_ID((value)->hdr.kind))
+#define meta_type(value) (TCF_META_TYPE((value)->hdr.kind))
+
+/**************************************************************************
+ * System status & misc
+ **************************************************************************/
+
+static int meta_int_random(struct sk_buff *skb, struct tcf_pkt_info *info,
+			   struct meta_value *v, struct meta_value *dst)
+{
+	get_random_bytes(&dst->value, sizeof(dst->value));
+	return 0;
+}
+
+static inline unsigned long fixed_loadavg(unsigned long v)
+{
+	return (v + (FIXED_1/200)) >> FSHIFT;
+}
+
+static int meta_int_loadavg_0(struct sk_buff *skb, struct tcf_pkt_info *info,
+			      struct meta_value *v, struct meta_value *dst)
+{
+	dst->value = fixed_loadavg(avenrun[0]);
+	return 0;
+}
+
+static int meta_int_loadavg_1(struct sk_buff *skb, struct tcf_pkt_info *info,
+			      struct meta_value *v, struct meta_value *dst)
+{
+	dst->value = fixed_loadavg(avenrun[1]);
+	return 0;
+}
+
+static int meta_int_loadavg_2(struct sk_buff *skb, struct tcf_pkt_info *info,
+			      struct meta_value *v, struct meta_value *dst)
+{
+	dst->value = fixed_loadavg(avenrun[2]);
+	return 0;
+}
+
+/**************************************************************************
+ * Device names & indices
+ **************************************************************************/
+
+static inline int int_dev(struct net_device *dev, struct meta_value *dst)
+{
+	if (unlikely(dev == NULL))
+		return -1;
+
+	dst->value = dev->ifindex;
+	return 0;
+}
+
+static inline int var_dev(struct net_device *dev, struct meta_value *dst)
+{
+	if (unlikely(dev == NULL))
+		return -1;
+
+	dst->value = (unsigned long) dev->name;
+	dst->len = strlen(dev->name);
+	return 0;
+}
+
+static int meta_int_dev(struct sk_buff *skb, struct tcf_pkt_info *info,
+			struct meta_value *v, struct meta_value *dst)
+{
+	return int_dev(skb->dev, dst);
+}
+
+static int meta_var_dev(struct sk_buff *skb, struct tcf_pkt_info *info,
+			struct meta_value *v, struct meta_value *dst)
+{
+	return var_dev(skb->dev, dst);
+}
+
+static int meta_int_indev(struct sk_buff *skb, struct tcf_pkt_info *info,
+			  struct meta_value *v, struct meta_value *dst)
+{
+	return int_dev(skb->input_dev, dst);
+}
+
+static int meta_var_indev(struct sk_buff *skb, struct tcf_pkt_info *info,
+			  struct meta_value *v, struct meta_value *dst)
+{
+	return var_dev(skb->input_dev, dst);
+}
+
+static int meta_int_realdev(struct sk_buff *skb, struct tcf_pkt_info *info,
+			    struct meta_value *v, struct meta_value *dst)
+{
+	return int_dev(skb->real_dev, dst);
+}
+
+static int meta_var_realdev(struct sk_buff *skb, struct tcf_pkt_info *info,
+			    struct meta_value *v, struct meta_value *dst)
+{
+	return var_dev(skb->real_dev, dst);
+}
+
+/**************************************************************************
+ * skb attributes
+ **************************************************************************/
+
+static int meta_int_priority(struct sk_buff *skb, struct tcf_pkt_info *info,
+			     struct meta_value *v, struct meta_value *dst)
+{
+	dst->value = skb->priority;
+	return 0;
+}
+
+static int meta_int_protocol(struct sk_buff *skb, struct tcf_pkt_info *info,
+			     struct meta_value *v, struct meta_value *dst)
+{
+	dst->value = skb->protocol;
+	return 0;
+}
+
+static int meta_int_security(struct sk_buff *skb, struct tcf_pkt_info *info,
+			     struct meta_value *v, struct meta_value *dst)
+{
+	dst->value = skb->security;
+	return 0;
+}
+
+static int meta_int_pkttype(struct sk_buff *skb, struct tcf_pkt_info *info,
+			    struct meta_value *v, struct meta_value *dst)
+{
+	dst->value = skb->pkt_type;
+	return 0;
+}
+
+static int meta_int_pktlen(struct sk_buff *skb, struct tcf_pkt_info *info,
+			   struct meta_value *v, struct meta_value *dst)
+{
+	dst->value = skb->len;
+	return 0;
+}
+
+static int meta_int_datalen(struct sk_buff *skb, struct tcf_pkt_info *info,
+			   struct meta_value *v, struct meta_value *dst)
+{
+	dst->value = skb->data_len;
+	return 0;
+}
+
+static int meta_int_maclen(struct sk_buff *skb, struct tcf_pkt_info *info,
+			   struct meta_value *v, struct meta_value *dst)
+{
+	dst->value = skb->mac_len;
+	return 0;
+}
+
+/**************************************************************************
+ * Netfilter
+ **************************************************************************/
+
+#ifdef CONFIG_NETFILTER
+static int meta_int_nfmark(struct sk_buff *skb, struct tcf_pkt_info *info,
+			   struct meta_value *v, struct meta_value *dst)
+{
+	dst->value = skb->nfmark;
+	return 0;
+}
+
+static int meta_int_nfcache(struct sk_buff *skb, struct tcf_pkt_info *info,
+			    struct meta_value *v, struct meta_value *dst)
+{
+	dst->value = skb->nfcache;
+	return 0;
+}
+
+static int meta_int_nfctinfo(struct sk_buff *skb, struct tcf_pkt_info *info,
+			     struct meta_value *v, struct meta_value *dst)
+{
+	dst->value = skb->nfctinfo;
+	return 0;
+}
+
+#ifdef CONFIG_NETFILTER_DEBUG
+static int meta_int_nfdebug(struct sk_buff *skb, struct tcf_pkt_info *info,
+			    struct meta_value *v, struct meta_value *dst)
+{
+	dst->value = skb->nf_debug;
+	return 0;
+}
+#endif
+#endif
+
+/**************************************************************************
+ * Traffic Control
+ **************************************************************************/
+
+static int meta_int_tcindex(struct sk_buff *skb, struct tcf_pkt_info *info,
+			    struct meta_value *v, struct meta_value *dst)
+{
+	dst->value = skb->tc_index;
+	return 0;
+}
+
+#ifdef CONFIG_NET_CLS_ACT
+static int meta_int_tcverd(struct sk_buff *skb, struct tcf_pkt_info *info,
+			   struct meta_value *v, struct meta_value *dst)
+{
+	dst->value = skb->tc_verd;
+	return 0;
+}
+
+static int meta_int_tcclassid(struct sk_buff *skb, struct tcf_pkt_info *info,
+			      struct meta_value *v, struct meta_value *dst)
+{
+	dst->value = skb->tc_classid;
+	return 0;
+}
+#endif
+
+/**************************************************************************
+ * Routing
+ **************************************************************************/
+
+#ifdef CONFIG_NET_CLS_ROUTE
+static int meta_int_rtclassid(struct sk_buff *skb, struct tcf_pkt_info *info,
+			      struct meta_value *v, struct meta_value *dst)
+{
+	if (unlikely(skb->dst == NULL))
+		return -1;
+
+	dst->value = skb->dst->tclassid;
+	return 0;
+}
+#endif
+
+static int meta_int_rtiif(struct sk_buff *skb, struct tcf_pkt_info *info,
+			  struct meta_value *v, struct meta_value *dst)
+{
+	if (unlikely(skb->dst == NULL))
+		return -1;
+
+	dst->value = ((struct rtable*) skb->dst)->fl.iif;
+	return 0;
+}
+
+struct meta_ops
+{
+	int		(*get)(struct sk_buff *, struct tcf_pkt_info *,
+			       struct meta_value *, struct meta_value *);
+};
+
+static struct meta_ops __meta_ops[TCF_META_TYPE_MAX+1][TCF_META_ID_MAX+1] = {
+	[TCF_META_TYPE_VAR] = {
+		[TCF_META_ID_DEV]	= { .get = meta_var_dev },
+		[TCF_META_ID_INDEV]	= { .get = meta_var_indev },
+		[TCF_META_ID_REALDEV]	= { .get = meta_var_realdev }
+	},
+	[TCF_META_TYPE_INT] = {
+		[TCF_META_ID_RANDOM]	= { .get = meta_int_random },
+		[TCF_META_ID_LOADAVG_0]	= { .get = meta_int_loadavg_0 },
+		[TCF_META_ID_LOADAVG_1]	= { .get = meta_int_loadavg_1 },
+		[TCF_META_ID_LOADAVG_2]	= { .get = meta_int_loadavg_2 },
+		[TCF_META_ID_DEV]	= { .get = meta_int_dev },
+		[TCF_META_ID_INDEV]	= { .get = meta_int_indev },
+		[TCF_META_ID_REALDEV]	= { .get = meta_int_realdev },
+		[TCF_META_ID_PRIORITY]	= { .get = meta_int_priority },
+		[TCF_META_ID_PROTOCOL]	= { .get = meta_int_protocol },
+		[TCF_META_ID_SECURITY]	= { .get = meta_int_security },
+		[TCF_META_ID_PKTTYPE]	= { .get = meta_int_pkttype },
+		[TCF_META_ID_PKTLEN]	= { .get = meta_int_pktlen },
+		[TCF_META_ID_DATALEN]	= { .get = meta_int_datalen },
+		[TCF_META_ID_MACLEN]	= { .get = meta_int_maclen },
+#ifdef CONFIG_NETFILTER
+		[TCF_META_ID_NFMARK]	= { .get = meta_int_nfmark },
+		[TCF_META_ID_NFCACHE]	= { .get = meta_int_nfcache },
+		[TCF_META_ID_NFCTINFO]	= { .get = meta_int_nfctinfo },
+#ifdef CONFIG_NETFILTER_DEBUG
+		[TCF_META_ID_NFDEBUG]	= { .get = meta_int_nfdebug },
+#endif
+#endif
+		[TCF_META_ID_TCINDEX]	= { .get = meta_int_tcindex },
+#ifdef CONFIG_NET_CLS_ACT
+		[TCF_META_ID_TCVERDICT]	= { .get = meta_int_tcverd },
+		[TCF_META_ID_TCCLASSID]	= { .get = meta_int_tcclassid },
+#endif
+#ifdef CONFIG_NET_CLS_ROUTE
+		[TCF_META_ID_RTCLASSID]	= { .get = meta_int_rtclassid },
+#endif
+		[TCF_META_ID_RTIIF]	= { .get = meta_int_rtiif }
+	}
+};
+
+static inline struct meta_ops * meta_ops(struct meta_value *v)
+{
+	return &__meta_ops[meta_type(v)][meta_id(v)];
+}
+
+static int meta_var_compare(struct meta_value *a, struct meta_value *b)
+{
+	int r = a->len - b->len;
+
+	if (r == 0)
+		r = memcmp((void *) a->value, (void *) b->value, a->len);
+
+	return r;
+}
+
+static int meta_var_change(struct meta_value *dst, struct rtattr *rta)
+{
+	int len = RTA_PAYLOAD(rta);
+
+	dst->value = (unsigned long) kmalloc(len, GFP_KERNEL);
+	if (dst->value == 0UL)
+		return -ENOMEM;
+	memcpy((void *) dst->value, RTA_DATA(rta), len);
+	dst->len = len;
+	return 0;
+}
+
+static void meta_var_destroy(struct meta_value *v)
+{
+	kfree((void *) v->value);
+}
+
+static void meta_var_apply_extras(struct meta_value *v,
+				  struct meta_value *dst)
+{
+	int shift = v->hdr.shift;
+
+	if (shift && shift < dst->len)
+		dst->len -= shift;
+}
+
+static int meta_int_compare(struct meta_value *a, struct meta_value *b)
+{
+	return a->value - b->value;
+}
+
+static int meta_int_change(struct meta_value *dst, struct rtattr *rta)
+{
+	if (RTA_PAYLOAD(rta) < sizeof(u32))
+		return -EINVAL;
+	dst->value = *(u32*) RTA_DATA(rta);
+	dst->len = sizeof(u32);
+	return 0;
+}
+
+static void meta_int_apply_extras(struct meta_value *v,
+				  struct meta_value *dst)
+{
+	if (v->hdr.shift)
+		dst->value >>= v->hdr.shift;
+
+	if (v->value)
+		dst->value &= v->value;
+}
+
+struct meta_type_ops
+{
+	void	(*destroy)(struct meta_value *);
+	int	(*compare)(struct meta_value *, struct meta_value *);
+	int	(*change)(struct meta_value *, struct rtattr *);
+	void	(*apply_extras)(struct meta_value *, struct meta_value *);
+};
+
+static struct meta_type_ops __meta_type_ops[TCF_META_TYPE_MAX+1] = {
+	[TCF_META_TYPE_VAR] = {
+		.destroy = meta_var_destroy,
+		.compare = meta_var_compare,
+		.change = meta_var_change,
+		.apply_extras = meta_var_apply_extras
+	},
+	[TCF_META_TYPE_INT] = {
+		.compare = meta_int_compare,
+		.change = meta_int_change,
+		.apply_extras = meta_int_apply_extras
+	}
+};
+
+static inline struct meta_type_ops * meta_type_ops(struct meta_value *v)
+{
+	return &__meta_type_ops[meta_type(v)];
+}
+
+static inline int meta_get(struct sk_buff *skb, struct tcf_pkt_info *info, 
+			   struct meta_value *v, struct meta_value *dst)
+{
+	int err;
+
+	if (meta_id(v) == TCF_META_ID_VALUE) {
+		dst->value = v->value;
+		dst->len = v->len;
+		return 0;
+	}
+
+	err = meta_ops(v)->get(skb, info, v, dst);
+	if (err < 0)
+		return err;
+
+	if (meta_type_ops(v)->apply_extras)
+	    meta_type_ops(v)->apply_extras(v, dst);
+
+	return 0;
+}
+
+static int em_meta_match(struct sk_buff *skb, struct tcf_ematch *m,
+			 struct tcf_pkt_info *info)
+{
+	int r;
+	struct meta_match *meta = (struct meta_match *) m->data;
+	struct meta_value l_value, r_value;
+
+	if (meta_get(skb, info, &meta->lvalue, &l_value) < 0 ||
+	    meta_get(skb, info, &meta->rvalue, &r_value) < 0)
+		return 0;
+
+	r = meta_type_ops(&meta->lvalue)->compare(&l_value, &r_value);
+
+	switch (meta->lvalue.hdr.op) {
+		case TCF_EM_OPND_EQ:
+			return !r;
+		case TCF_EM_OPND_LT:
+			return r < 0;
+		case TCF_EM_OPND_GT:
+			return r > 0;
+	}
+
+	return 0;
+}
+
+static inline void meta_delete(struct meta_match *meta)
+{
+	struct meta_type_ops *ops = meta_type_ops(&meta->lvalue);
+
+	if (ops && ops->destroy) {
+		ops->destroy(&meta->lvalue);
+		ops->destroy(&meta->rvalue);
+	}
+
+	kfree(meta);
+}
+
+static inline int meta_change_data(struct meta_value *dst, struct rtattr *rta)
+{
+	if (rta) {
+		if (RTA_PAYLOAD(rta) == 0)
+			return -EINVAL;
+
+		return meta_type_ops(dst)->change(dst, rta);
+	}
+
+	return 0;
+}
+
+static int em_meta_change(struct tcf_proto *tp, void *data, int len,
+			  struct tcf_ematch *m)
+{
+	int err = -EINVAL;
+	struct rtattr *tb[TCA_EM_META_MAX];
+	struct tcf_meta_hdr *hdr;
+	struct meta_match *meta = NULL;
+	
+	if (rtattr_parse(tb, TCA_EM_META_MAX, data, len) < 0)
+		goto errout;
+
+	if (tb[TCA_EM_META_HDR-1] == NULL ||
+	    RTA_PAYLOAD(tb[TCA_EM_META_HDR-1]) < sizeof(*hdr))
+		goto errout;
+	hdr = RTA_DATA(tb[TCA_EM_META_HDR-1]);
+
+	if (TCF_META_TYPE(hdr->left.kind) != TCF_META_TYPE(hdr->right.kind) ||
+	    TCF_META_TYPE(hdr->left.kind) > TCF_META_TYPE_MAX ||
+	    TCF_META_ID(hdr->left.kind) > TCF_META_ID_MAX ||
+	    TCF_META_ID(hdr->right.kind) > TCF_META_ID_MAX)
+		goto errout;
+
+	meta = kmalloc(sizeof(*meta), GFP_KERNEL);
+	if (meta == NULL)
+		goto errout;
+	memset(meta, 0, sizeof(*meta));
+
+	memcpy(&meta->lvalue.hdr, &hdr->left, sizeof(hdr->left));
+	memcpy(&meta->rvalue.hdr, &hdr->right, sizeof(hdr->right));
+
+	if (meta_ops(&meta->lvalue)->get == NULL ||
+	    meta_ops(&meta->rvalue)->get == NULL) {
+		err = -EOPNOTSUPP;
+		goto errout;
+	}
+
+	if (meta_change_data(&meta->lvalue, tb[TCA_EM_META_LVALUE-1]) < 0 ||
+	    meta_change_data(&meta->rvalue, tb[TCA_EM_META_RVALUE-1]) < 0)
+		goto errout;
+
+	m->datalen = sizeof(*meta);
+	m->data = (unsigned long) meta;
+
+	err = 0;
+errout:
+	if (err && meta)
+		meta_delete(meta);
+	return err;
+}
+
+static void em_meta_destroy(struct tcf_proto *tp, struct tcf_ematch *m)
+{
+	meta_delete((struct meta_match *) m->data);
+}
+
+static struct tcf_ematch_ops em_meta_ops = {
+	.kind	  = TCF_EM_META,
+	.change	  = em_meta_change,
+	.match	  = em_meta_match,
+	.destroy  = em_meta_destroy,
+	.owner	  = THIS_MODULE,
+	.link	  = LIST_HEAD_INIT(em_meta_ops.link)
+};
+
+static int __init init_em_meta(void)
+{
+	return tcf_em_register(&em_meta_ops);
+}
+
+static void __exit exit_em_meta(void) 
+{
+	tcf_em_unregister(&em_meta_ops);
+}
+
+MODULE_LICENSE("GPL");
+
+module_init(init_em_meta);
+module_exit(exit_em_meta);
+

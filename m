From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] meta ematch
Date: Fri, 14 Jan 2005 16:14:07 +0100
Message-ID: <20050114151407.GR26856@postel.suug.ch>
References: <20050106194102.GW26856@postel.suug.ch> <1105105511.1046.77.camel@jzny.localdomain> <20050108145457.GZ26856@postel.suug.ch> <1105363582.1041.162.camel@jzny.localdomain> <20050110211747.GA26856@postel.suug.ch> <1105394738.1085.63.camel@jzny.localdomain> <20050113174111.GP26856@postel.suug.ch> <41E6C3E5.2020908@trash.net> <20050113192047.GQ26856@postel.suug.ch> <41E71CC4.3020102@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamal <hadi@cyberus.ca>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <41E71CC4.3020102@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Patrick McHardy <41E71CC4.3020102@trash.net> 2005-01-14 02:13
> True. nfctinfo is even useful for more, the direction of a connection
> might be interesting. connmark, conntrack counters, src-ip before SNAT
> etc. might also be interesting, but they are horrible to implement cleanly
> because any dependency on ip_conntrack_lock will automatically load
> ip_conntrack. Perhaps we should add something like nf_ct_get_afinfo() to
> return a set of conntrack operations to nf_conntrack.

Yes, I'm kind of afraid to create a too big dependency on netfilter,
so I sticked to the easly reachable values.

I think I'll remove the netfilter attributes again except for nfmark
and readd them together with the more complicated routing information
and the socket attributes to not delay the whole ematch patch for too long.

> For things beside the nf* fields: I think we should make it very clear
> that everything that isn't already visible to userspace in some way, and
> thus won't disappear (like priority, nfmark, load average ...), can get
> changed/removed any time.

Agreed.

> >The `dst` meta_value is the l_value/r_lvalue from em_meta_match and
> >never gets destroyed. I reused meta_data to store address & length.
> >It might be a good idea to make a new struct for this to make it
> >more readable though.
> >
> Looks good to me already. I only looked at the diff, so I didn't really
> follow the codepath.

I changed it anyway, it looks a lot cleaner now.

> Shouldn't be too hard to get right. In the kernel you can decide based
> on RTA_PAYLOAD. Userspace needs some other way to notice it is running
> as a 32-bit binary on a 64-bit kernel, but that's something you can't
> solve in the kernel anyway.

Both have their drawbacks but I think yours is a bit simpler. I changed
it to the code below and gave responsibility to userspace.

+	if (RTA_PAYLOAD(rta) >= sizeof(unsigned long)) {
+		dst->val = *(unsigned long *) RTA_DATA(rta);
+		dst->len = sizeof(unsigned long);
+	} else if (RTA_PAYLOAD(rta) == sizeof(u32)) {
+		dst->val = *(u32 *) RTA_DATA(rta);
+		dst->len = sizeof(u32);
+	} else
+		return -EINVAL;

Here's a revised patch. I fixed the numeric comparison issues and
added meta_obj instead of using meta_data to give a better impression
on the difference of a comparable object and meta data definitions.

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
+++ linux-2.6.10-bk14/include/linux/tc_ematch/tc_em_meta.h	2005-01-13 22:16:40.000000000 +0100
@@ -0,0 +1,72 @@
+#ifndef __LINUX_TC_EM_META_H
+#define __LINUX_TC_EM_META_H
+
+#include <linux/pkt_cls.h>
+
+enum
+{
+	TCA_EM_META_UNSPEC,
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
+++ linux-2.6.10-bk14/net/sched/Kconfig	2005-01-14 14:09:41.000000000 +0100
@@ -428,6 +428,17 @@
 	  To compile this code as a module, choose M here: the
 	  module will be called em_u32.
 
+config NET_EMATCH_META
+	tristate "Metadata"
+	depends on NET_EMATCH
+	---help---
+	  Say Y here if you want to be ablt to classify packets based on
+	  metadata such as load average, netfilter attributes, socket
+	  attributes and routing decisions.
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
+++ linux-2.6.10-bk14/net/sched/em_meta.c	2005-01-14 14:08:41.000000000 +0100
@@ -0,0 +1,587 @@
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
+struct meta_obj
+{
+	unsigned long		value;
+	unsigned int		len;
+};
+
+struct meta_value
+{
+	struct tcf_meta_val	hdr;
+	unsigned long		val;
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
+			   struct meta_value *v, struct meta_obj *dst)
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
+			      struct meta_value *v, struct meta_obj *dst)
+{
+	dst->value = fixed_loadavg(avenrun[0]);
+	return 0;
+}
+
+static int meta_int_loadavg_1(struct sk_buff *skb, struct tcf_pkt_info *info,
+			      struct meta_value *v, struct meta_obj *dst)
+{
+	dst->value = fixed_loadavg(avenrun[1]);
+	return 0;
+}
+
+static int meta_int_loadavg_2(struct sk_buff *skb, struct tcf_pkt_info *info,
+			      struct meta_value *v, struct meta_obj *dst)
+{
+	dst->value = fixed_loadavg(avenrun[2]);
+	return 0;
+}
+
+/**************************************************************************
+ * Device names & indices
+ **************************************************************************/
+
+static inline int int_dev(struct net_device *dev, struct meta_obj *dst)
+{
+	if (unlikely(dev == NULL))
+		return -1;
+
+	dst->value = dev->ifindex;
+	return 0;
+}
+
+static inline int var_dev(struct net_device *dev, struct meta_obj *dst)
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
+			struct meta_value *v, struct meta_obj *dst)
+{
+	return int_dev(skb->dev, dst);
+}
+
+static int meta_var_dev(struct sk_buff *skb, struct tcf_pkt_info *info,
+			struct meta_value *v, struct meta_obj *dst)
+{
+	return var_dev(skb->dev, dst);
+}
+
+static int meta_int_indev(struct sk_buff *skb, struct tcf_pkt_info *info,
+			  struct meta_value *v, struct meta_obj *dst)
+{
+	return int_dev(skb->input_dev, dst);
+}
+
+static int meta_var_indev(struct sk_buff *skb, struct tcf_pkt_info *info,
+			  struct meta_value *v, struct meta_obj *dst)
+{
+	return var_dev(skb->input_dev, dst);
+}
+
+static int meta_int_realdev(struct sk_buff *skb, struct tcf_pkt_info *info,
+			    struct meta_value *v, struct meta_obj *dst)
+{
+	return int_dev(skb->real_dev, dst);
+}
+
+static int meta_var_realdev(struct sk_buff *skb, struct tcf_pkt_info *info,
+			    struct meta_value *v, struct meta_obj *dst)
+{
+	return var_dev(skb->real_dev, dst);
+}
+
+/**************************************************************************
+ * skb attributes
+ **************************************************************************/
+
+static int meta_int_priority(struct sk_buff *skb, struct tcf_pkt_info *info,
+			     struct meta_value *v, struct meta_obj *dst)
+{
+	dst->value = skb->priority;
+	return 0;
+}
+
+static int meta_int_protocol(struct sk_buff *skb, struct tcf_pkt_info *info,
+			     struct meta_value *v, struct meta_obj *dst)
+{
+	/* Let userspace take care of the byte ordering */
+	dst->value = skb->protocol;
+	return 0;
+}
+
+static int meta_int_security(struct sk_buff *skb, struct tcf_pkt_info *info,
+			     struct meta_value *v, struct meta_obj *dst)
+{
+	dst->value = skb->security;
+	return 0;
+}
+
+static int meta_int_pkttype(struct sk_buff *skb, struct tcf_pkt_info *info,
+			    struct meta_value *v, struct meta_obj *dst)
+{
+	dst->value = skb->pkt_type;
+	return 0;
+}
+
+static int meta_int_pktlen(struct sk_buff *skb, struct tcf_pkt_info *info,
+			   struct meta_value *v, struct meta_obj *dst)
+{
+	dst->value = skb->len;
+	return 0;
+}
+
+static int meta_int_datalen(struct sk_buff *skb, struct tcf_pkt_info *info,
+			   struct meta_value *v, struct meta_obj *dst)
+{
+	dst->value = skb->data_len;
+	return 0;
+}
+
+static int meta_int_maclen(struct sk_buff *skb, struct tcf_pkt_info *info,
+			   struct meta_value *v, struct meta_obj *dst)
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
+			   struct meta_value *v, struct meta_obj *dst)
+{
+	dst->value = skb->nfmark;
+	return 0;
+}
+
+static int meta_int_nfcache(struct sk_buff *skb, struct tcf_pkt_info *info,
+			    struct meta_value *v, struct meta_obj *dst)
+{
+	dst->value = skb->nfcache;
+	return 0;
+}
+
+static int meta_int_nfctinfo(struct sk_buff *skb, struct tcf_pkt_info *info,
+			     struct meta_value *v, struct meta_obj *dst)
+{
+	dst->value = skb->nfctinfo;
+	return 0;
+}
+
+#ifdef CONFIG_NETFILTER_DEBUG
+static int meta_int_nfdebug(struct sk_buff *skb, struct tcf_pkt_info *info,
+			    struct meta_value *v, struct meta_obj *dst)
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
+			    struct meta_value *v, struct meta_obj *dst)
+{
+	dst->value = skb->tc_index;
+	return 0;
+}
+
+#ifdef CONFIG_NET_CLS_ACT
+static int meta_int_tcverd(struct sk_buff *skb, struct tcf_pkt_info *info,
+			   struct meta_value *v, struct meta_obj *dst)
+{
+	dst->value = skb->tc_verd;
+	return 0;
+}
+
+static int meta_int_tcclassid(struct sk_buff *skb, struct tcf_pkt_info *info,
+			      struct meta_value *v, struct meta_obj *dst)
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
+			      struct meta_value *v, struct meta_obj *dst)
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
+			  struct meta_value *v, struct meta_obj *dst)
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
+			       struct meta_value *, struct meta_obj *);
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
+static int meta_var_compare(struct meta_obj *a, struct meta_obj *b)
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
+	dst->val = (unsigned long) kmalloc(len, GFP_KERNEL);
+	if (dst->val == 0UL)
+		return -ENOMEM;
+	memcpy((void *) dst->val, RTA_DATA(rta), len);
+	dst->len = len;
+	return 0;
+}
+
+static void meta_var_destroy(struct meta_value *v)
+{
+	kfree((void *) v->val);
+}
+
+static void meta_var_apply_extras(struct meta_value *v,
+				  struct meta_obj *dst)
+{
+	int shift = v->hdr.shift;
+
+	if (shift && shift < dst->len)
+		dst->len -= shift;
+}
+
+static int meta_int_compare(struct meta_obj *a, struct meta_obj *b)
+{
+	/* Let gcc optimize it, the unlikely is not really based on
+	 * some numbers but jump free code for missmatches seems
+	 * more logical.
+	 */
+	if (unlikely(a == b))
+		return 0;
+	else if (a < b)
+		return -1;
+	else
+		return 1;
+}
+
+static int meta_int_change(struct meta_value *dst, struct rtattr *rta)
+{
+	if (RTA_PAYLOAD(rta) >= sizeof(unsigned long)) {
+		dst->val = *(unsigned long *) RTA_DATA(rta);
+		dst->len = sizeof(unsigned long);
+	} else if (RTA_PAYLOAD(rta) == sizeof(u32)) {
+		dst->val = *(u32 *) RTA_DATA(rta);
+		dst->len = sizeof(u32);
+	} else
+		return -EINVAL;
+
+	return 0;
+}
+
+static void meta_int_apply_extras(struct meta_value *v,
+				  struct meta_obj *dst)
+{
+	if (v->hdr.shift)
+		dst->value >>= v->hdr.shift;
+
+	if (v->val)
+		dst->value &= v->val;
+}
+
+struct meta_type_ops
+{
+	void	(*destroy)(struct meta_value *);
+	int	(*compare)(struct meta_obj *, struct meta_obj *);
+	int	(*change)(struct meta_value *, struct rtattr *);
+	void	(*apply_extras)(struct meta_value *, struct meta_obj *);
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
+			   struct meta_value *v, struct meta_obj *dst)
+{
+	int err;
+
+	if (meta_id(v) == TCF_META_ID_VALUE) {
+		dst->value = v->val;
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
+	struct meta_obj l_value, r_value;
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

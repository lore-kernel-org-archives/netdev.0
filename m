From: jamal <hadi@cyberus.ca>
Subject: PATCH: Allow Simple actions WAS(Re: patch: introduce simple actions
Date: 06 Apr 2005 09:29:02 -0400
Message-ID: <1112794142.1098.56.camel@jzny.localdomain>
References: <1111345551.1095.82.camel@jzny.localdomain>
	 <423DCD8C.6030100@trash.net> <1111347345.1094.98.camel@jzny.localdomain>
	 <423DD5E6.2020708@trash.net> <1111349853.1093.136.camel@jzny.localdomain>
	 <20050322195827.5ecd0c33.davem@davemloft.net>
	 <1111550799.1116.28.camel@jzny.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-kbyROQh80Y7V+WN2x4yB"
Cc: kaber@trash.net, netdev <netdev@oss.sgi.com>, tgraf@suug.ch
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <1111550799.1116.28.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-kbyROQh80Y7V+WN2x4yB
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Tue, 2005-03-22 at 23:06, Jamal Hadi Salim wrote:
> On Tue, 2005-03-22 at 22:58, David S. Miller wrote:
> > I'm waiting for this, send whenever it's ready.
> > 
> 
> I will tommorow - need to plonk tonight 


That was some plonk ;->

Anyways, here it is with suggestions incorporated. 
I could probably split it into two patches one for
the base and the other for the simple action. Let me
know if you want me to do this.

description: 
-Allow simple actions
-introduce a simple action example to demonstrate usage

signed off by: Jamal Hadi Salim <hadi@cyberus.ca>

cheers,
jamal


--=-kbyROQh80Y7V+WN2x4yB
Content-Disposition: attachment; filename=simp_p
Content-Type: text/plain; name=simp_p; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

--- /dev/null	2005-04-06 08:24:31.814336808 -0400
+++ b/include/net/act_generic.h	2005-04-06 08:51:52.000000000 -0400
@@ -0,0 +1,142 @@
+/*
+ * include/net/act_generic.h
+ *
+*/
+#ifndef ACT_GENERIC_H
+#define ACT_GENERIC_H
+static inline int tcf_defact_release(struct tcf_defact *p, int bind)
+{
+	int ret = 0;
+	if (p) {
+		if (bind) {
+			p->bindcnt--;
+		}
+		p->refcnt--;
+		if (p->bindcnt <= 0 && p->refcnt <= 0) {
+			kfree(p->defdata);
+			tcf_hash_destroy(p);
+			ret = 1;
+		}
+	}
+	return ret;
+}
+
+static inline int
+alloc_defdata(struct tcf_defact *p, u32 datalen, void *defdata)
+{
+	p->defdata = kmalloc(datalen, GFP_KERNEL);
+	if (p->defdata == NULL)
+		return -ENOMEM;
+	p->datalen = datalen;
+	memcpy(p->defdata, defdata, datalen);
+	return 0;
+}
+
+static inline int
+realloc_defdata(struct tcf_defact *p, u32 datalen, void *defdata)
+{
+	/* safer to be just brute force for now */
+	kfree(p->defdata);
+	return alloc_defdata(p, datalen, defdata);
+}
+
+static inline int
+tcf_defact_init(struct rtattr *rta, struct rtattr *est,
+		struct tc_action *a, int ovr, int bind)
+{
+	struct rtattr *tb[TCA_DEF_MAX];
+	struct tc_defact *parm;
+	struct tcf_defact *p;
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
+	p = tcf_hash_check(parm->index, a, ovr, bind);
+	if (p == NULL) {
+		p = tcf_hash_create(parm->index, est, a, sizeof(*p), ovr, bind);
+		if (p == NULL)
+			return -ENOMEM;
+
+		ret = alloc_defdata(p, datalen, defdata);
+		if (ret < 0) {
+			kfree(p);
+			return ret;
+		}
+		ret = ACT_P_CREATED;
+	} else {
+		if (!ovr) {
+			tcf_defact_release(p, bind);
+			return -EEXIST;
+		}
+		realloc_defdata(p, datalen, defdata);
+	}
+
+	spin_lock_bh(&p->lock);
+	p->action = parm->action;
+	spin_unlock_bh(&p->lock);
+	if (ret == ACT_P_CREATED)
+		tcf_hash_insert(p);
+	return ret;
+}
+
+static inline int tcf_defact_cleanup(struct tc_action *a, int bind)
+{
+	struct tcf_defact *p = PRIV(a, defact);
+
+	if (p != NULL)
+		return tcf_defact_release(p, bind);
+	return 0;
+}
+
+static inline int
+tcf_defact_dump(struct sk_buff *skb, struct tc_action *a, int bind, int ref)
+{
+	unsigned char *b = skb->tail;
+	struct tc_defact opt;
+	struct tcf_defact *p = PRIV(a, defact);
+	struct tcf_t t;
+
+	opt.index = p->index;
+	opt.refcnt = p->refcnt - ref;
+	opt.bindcnt = p->bindcnt - bind;
+	opt.action = p->action;
+	RTA_PUT(skb, TCA_DEF_PARMS, sizeof(opt), &opt);
+	RTA_PUT(skb, TCA_DEF_DATA, p->datalen, p->defdata);
+	t.install = jiffies_to_clock_t(jiffies - p->tm.install);
+	t.lastuse = jiffies_to_clock_t(jiffies - p->tm.lastuse);
+	t.expires = jiffies_to_clock_t(p->tm.expires);
+	RTA_PUT(skb, TCA_DEF_TM, sizeof(t), &t);
+	return skb->len;
+
+rtattr_failure:
+	skb_trim(skb, b - skb->data);
+	return -1;
+}
+
+#define tca_use_default_ops \
+	.dump           =       tcf_defact_dump, \
+	.cleanup        =       tcf_defact_cleanup, \
+	.init           =       tcf_defact_init, \
+	.walk           =       tcf_generic_walker, \
+
+#define tca_use_default_defines(name) \
+	static u32 idx_gen; \
+	static struct tcf_defact *tcf_##name_ht[MY_TAB_SIZE]; \
+	static DEFINE_RWLOCK(##name_lock);
+#endif /* _NET_ACT_GENERIC_H */
--- /dev/null	2005-04-06 08:24:31.814336808 -0400
+++ b/include/net/tc_act/tc_defact.h	2005-04-06 08:38:47.000000000 -0400
@@ -0,0 +1,13 @@
+#ifndef __NET_TC_DEF_H
+#define __NET_TC_DEF_H
+
+#include <net/act_api.h>
+
+struct tcf_defact
+{
+	tca_gen(defact);
+	u32     datalen;
+	void    *defdata;
+};
+
+#endif
--- /dev/null	2005-04-06 08:24:31.814336808 -0400
+++ b/include/linux/tc_act/tc_defact.h	2005-04-06 08:38:47.000000000 -0400
@@ -0,0 +1,21 @@
+#ifndef __LINUX_TC_DEF_H
+#define __LINUX_TC_DEF_H
+
+#include <linux/pkt_cls.h>
+
+struct tc_defact
+{
+	tc_gen;
+};
+                                                                                
+enum
+{
+	TCA_DEF_UNSPEC,
+	TCA_DEF_TM,
+	TCA_DEF_PARMS,
+	TCA_DEF_DATA,
+	__TCA_DEF_MAX
+};
+#define TCA_DEF_MAX (__TCA_DEF_MAX - 1)
+
+#endif
--- /dev/null	2005-04-06 08:24:31.814336808 -0400
+++ b/net/sched/simple.c	2005-04-06 08:53:31.000000000 -0400
@@ -0,0 +1,107 @@
+/*
+ * net/sched/simp.c	Simple example of an action
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Jamal Hadi Salim (2005)
+ *
+ */
+
+#include <asm/uaccess.h>
+#include <asm/system.h>
+#include <asm/bitops.h>
+#include <linux/config.h>
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/string.h>
+#include <linux/mm.h>
+#include <linux/socket.h>
+#include <linux/sockios.h>
+#include <linux/in.h>
+#include <linux/errno.h>
+#include <linux/interrupt.h>
+#include <linux/netdevice.h>
+#include <linux/skbuff.h>
+#include <linux/rtnetlink.h>
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/proc_fs.h>
+#include <net/sock.h>
+#include <net/pkt_sched.h>
+
+#define TCA_ACT_SIMP 22
+
+/* XXX: Hide all these common elements under some macro 
+ * probably
+*/
+#include <linux/tc_act/tc_defact.h>
+#include <net/tc_act/tc_defact.h>
+
+/* use generic hash table with 8 buckets */
+#define MY_TAB_SIZE     8
+#define MY_TAB_MASK     (MY_TAB_SIZE - 1)
+static u32 idx_gen;
+static struct tcf_defact *tcf_simp_ht[MY_TAB_SIZE];
+static DEFINE_RWLOCK(simp_lock);
+
+/* override the defaults */
+#define tcf_st		tcf_defact
+#define tc_st		tc_defact
+#define tcf_t_lock	simp_lock
+#define tcf_ht		tcf_simp_ht
+
+#define CONFIG_NET_ACT_INIT 1
+#include <net/pkt_act.h>
+#include <net/act_generic.h>
+
+static int tcf_simp(struct sk_buff **pskb, struct tc_action *a)
+{
+	struct sk_buff *skb = *pskb;
+	struct tcf_defact *p = PRIV(a, defact);
+
+	spin_lock(&p->lock);
+	p->tm.lastuse = jiffies;
+	p->bstats.bytes += skb->len;
+	p->bstats.packets++;
+
+	/* print policy string followed by _ then packet count 
+	 * Example if this was the 3rd packet and the string was "hello" 
+	 * then it would look like "hello_3" (without quotes) 
+	 **/
+	printk("simple: %s_%d\n", (char *)p->defdata, p->bstats.packets);
+	spin_unlock(&p->lock);
+	return p->action;
+}
+
+static struct tc_action_ops act_simp_ops = {
+	.kind = "simple",
+	.type = TCA_ACT_SIMP,
+	.capab = TCA_CAP_NONE,
+	.owner = THIS_MODULE,
+	.act = tcf_simp,
+	tca_use_default_ops
+};
+
+MODULE_AUTHOR("Jamal Hadi Salim(2005)");
+MODULE_DESCRIPTION("Simple example action");
+MODULE_LICENSE("GPL");
+
+static int __init simp_init_module(void)
+{
+	int ret = tcf_register_action(&act_simp_ops);
+	if (!ret)
+		printk("Simple TC action Loaded\n");
+	return ret;
+}
+
+static void __exit simp_cleanup_module(void)
+{
+	tcf_unregister_action(&act_simp_ops);
+}
+
+module_init(simp_init_module);
+module_exit(simp_cleanup_module);
--- b/net/sched/Kconfig	2005/04/06 12:58:03	1.1
+++ b/net/sched/Kconfig	2005/04/06 13:04:03
@@ -506,3 +506,13 @@
 	  Say Y to support traffic policing (bandwidth limits).  Needed for
 	  ingress and egress rate limiting.
 
+config NET_ACT_SIMP
+        tristate "Simple action"
+        depends on NET_CLS_ACT
+        ---help---
+        You must have new iproute2 to use this feature.
+        This adds a very simple action for demonstration purposes
+	The idea is to give action authors a basic example to look at.
+	All this action will do is print on the console the configured
+	policy string followed by _ then packet count.
+
--- b/net/sched/Makefile	2005/04/06 13:10:39	1.1
+++ b/net/sched/Makefile	2005/04/06 13:12:25
@@ -6,13 +6,14 @@
 
 obj-$(CONFIG_NET_SCHED)		+= sch_api.o sch_fifo.o
 obj-$(CONFIG_NET_CLS)		+= cls_api.o
-obj-$(CONFIG_NET_CLS_ACT)       += act_api.o
+obj-$(CONFIG_NET_CLS_ACT)	+= act_api.o
 obj-$(CONFIG_NET_ACT_POLICE)	+= police.o
 obj-$(CONFIG_NET_CLS_POLICE)	+= police.o
-obj-$(CONFIG_NET_ACT_GACT)      += gact.o
-obj-$(CONFIG_NET_ACT_MIRRED)    += mirred.o
-obj-$(CONFIG_NET_ACT_IPT)       += ipt.o
-obj-$(CONFIG_NET_ACT_PEDIT)     += pedit.o
+obj-$(CONFIG_NET_ACT_GACT)	+= gact.o
+obj-$(CONFIG_NET_ACT_MIRRED)	+= mirred.o
+obj-$(CONFIG_NET_ACT_IPT)	+= ipt.o
+obj-$(CONFIG_NET_ACT_PEDIT)	+= pedit.o
+obj-$(CONFIG_NET_ACT_SIMP)	+= simple.o
 obj-$(CONFIG_NET_SCH_CBQ)	+= sch_cbq.o
 obj-$(CONFIG_NET_SCH_HTB)	+= sch_htb.o
 obj-$(CONFIG_NET_SCH_HPFQ)	+= sch_hpfq.o

--=-kbyROQh80Y7V+WN2x4yB--

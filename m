From: jamal <hadi@cyberus.ca>
Subject: instead of eaction
Date: 06 Feb 2005 17:13:41 -0500
Message-ID: <1107728020.1055.50.camel@jzny.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-ib5mRFwAOsTDqQaOBM5K"
Cc: netdev@oss.sgi.com
To: Thomas Graf <tgraf@suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-ib5mRFwAOsTDqQaOBM5K
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


I think i am going to throw out the idea of eaction; instead
just provide some defaults.
First patch adds some defaults and second a quick simple example.

I have to take off; but maybe i will get time to work on meta action as
well as csum action when i get back.

Comments welcome

cheers,
jamal

--=-ib5mRFwAOsTDqQaOBM5K
Content-Disposition: attachment; filename=p15
Content-Type: text/plain; name=p15; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

--- /dev/null	2004-01-29 13:33:32.773091056 -0500
+++ 2611-rc3+bk3/include/net/act_generic.h	2005-02-06 15:55:36.000000000 -0500
@@ -0,0 +1,135 @@
+/*
+*/
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
+	if (tb[TCA_DEF_PARMS - 1] == NULL)
+		return -EINVAL;
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
--- /dev/null	2004-01-29 13:33:32.773091056 -0500
+++ 2611-rc3+bk3/include/net/tc_act/tc_defact.h	2005-02-06 15:03:05.000000000 -0500
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
--- /dev/null	2004-01-29 13:33:32.773091056 -0500
+++ 2611-rc3+bk3/include/linux/tc_act/tc_defact.h	2005-02-06 16:47:20.039209336 -0500
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

--=-ib5mRFwAOsTDqQaOBM5K
Content-Disposition: attachment; filename=p16
Content-Type: text/plain; name=p16; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

--- /dev/null	2004-01-29 13:33:32.773091056 -0500
+++ 2611-rc3+bk3/net/sched/simple.c	2005-02-06 15:55:57.000000000 -0500
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

--=-ib5mRFwAOsTDqQaOBM5K--

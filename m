From: jamal <hadi@cyberus.ca>
Subject: Re: RFC:  Redirect-Device
Date: 31 Mar 2005 18:46:48 -0500
Message-ID: <1112312808.1096.36.camel@jzny.localdomain>
References: <424C6089.1080507@candelatech.com>
	 <1112303627.1073.71.camel@jzny.localdomain>
	 <424C6B10.6030200@candelatech.com>
	 <1112306031.1073.109.camel@jzny.localdomain>
	 <424C7813.4000101@candelatech.com>
	 <1112311240.1096.13.camel@jzny.localdomain>
	 <424C893A.20601@candelatech.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-5e89gxDK/C7u7yRd5WeI"
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <424C893A.20601@candelatech.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-5e89gxDK/C7u7yRd5WeI
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Thu, 2005-03-31 at 18:35, Ben Greear wrote:
> jamal wrote:
> 
> > One thing you probably havent understood is that all the action stuff
> > that happens on ingress happens before dev.c pkt receive.
> 
> Could you point me to where this is, or give me something to
> search for?  I'm curious how/where it does the hook, and if I
> understand that better, maybe I can start thinking about how
> to make use of it for future hacks...

dev.c
search for CONFIG_NET_CLS_ACT

To see how simple an action can look like, take a look at
net/sched/gact.c (which does simple drop/accept etc); I have some
patches i need to submit to Dave that would make it even simpler to use
(and write less code). Attached is an example. 

Actually gact may have gotten a little bit complex because it now allows
you to add randomness to accepting, dropping, going to next action etc.

The one thing you have to understand is filters and actions are
separate. So what i am pointing to you is a simple action that is
executed after a packet matches a specified filter. Thomas has been
working on providing what are know as ematches which are very simple
filters that you could program.
You can match a packet and pass it through a series of actions of your
choice.

Also note: This stuff can be done at egress (not just restricted to
ingress).

cheers,
jamal

--=-5e89gxDK/C7u7yRd5WeI
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

--=-5e89gxDK/C7u7yRd5WeI--

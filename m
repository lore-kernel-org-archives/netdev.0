From: Jamal Hadi Salim <hadi@znyx.com>
Subject: Re: patch: introduce simple actions
Date: 20 Mar 2005 14:35:45 -0500
Message-ID: <1111347345.1094.98.camel@jzny.localdomain>
References: <1111345551.1095.82.camel@jzny.localdomain>
	 <423DCD8C.6030100@trash.net>
Reply-To: hadi@znyx.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-c9/4dXqnMUKz+Hz7wNN4"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        Thomas Graf <tgraf@suug.ch>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <423DCD8C.6030100@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-c9/4dXqnMUKz+Hz7wNN4
Content-Transfer-Encoding: 7bit
Content-Type: text/plain

On Sun, 2005-03-20 at 14:22, Patrick McHardy wrote:
> Jamal Hadi Salim wrote:
> > Ive posted this before - dont want it to sit here rotting. 
> > If theres nothing glaringly wrong with it (Thomas/Patrick?) then Dave
> > please apply so i can start shooting other patches based on it.
> 
> Any reasons why all of these need to be inline functions?


A lot of the code is very common. 
I am essentially sticking some common code as inlines to allow someone
to write some very simple code - probably just the packet processing
function - see attached simple action.
Inlines seem easy to allow this.

> One of the next things I wanted to do in this area was
> moving all the large inline functions to act_generic.c,
> so if possible I would prefer not to put these in a header
> file.
> 

These are small functions. Take a look at the simple action i attached.
If you can give me the same functionality and still move things
de_inlined to act_generic.c i would be fine with it.

cheers,
jamal

--=-c9/4dXqnMUKz+Hz7wNN4
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=p16
Content-Type: text/plain; name=p16; charset=ISO-8859-1

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

--=-c9/4dXqnMUKz+Hz7wNN4--

From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] ematch API, u32 ematch, nbyte ematch, basic classifier
Date: Wed, 5 Jan 2005 17:48:32 +0100
Message-ID: <20050105164832.GB17836@postel.suug.ch>
References: <20050103125635.GB26856@postel.suug.ch> <20050104223612.GN26856@postel.suug.ch> <1104894728.1117.56.camel@jzny.localdomain> <20050105110048.GO26856@postel.suug.ch> <1104931991.1117.152.camel@jzny.localdomain> <20050105144514.GQ26856@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <20050105144514.GQ26856@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Most importantly I don't want to touch any of the hashing code in u32.
> I really like and it should stay as it is. The existing u32 match can
> be easly made an ematch so this would safe us the extra work in u32 to
> implement logic relations again and to fiddle with complicated selector
> TLVs. The only problem with this is the nexthdr bits because it relies
> on the hashing code. So we have to make this data available to the
> ematch which is actually not a bad idea anyway. So I'm thinking about
> introducing a new structure tcf_em_pkt_info or alike which carries
> some additional information found out by the classifiers which can be
> used by ematches. This can be information about the next header,
> already extracted dscp values, etc.

Here's what I mean, it moves the u32 match as-is to an ematch so it
benefits from logic relations, inversion and can be used from other
classifiers as well. All we have to do is set info->ptr and
info->nexthdr to ptr respetively off2 before we evaluate the ematch
tree. The pkt_info struct is then passed to tcf_em_tree_match and
made available to every ematch.

Thoughts?

diff -Nru linux-2.6.10-bk8.orig/include/linux/pkt_cls.h linux-2.6.10-bk8/include/linux/pkt_cls.h
--- linux-2.6.10-bk8.orig/include/linux/pkt_cls.h	2005-01-05 17:40:02.000000000 +0100
+++ linux-2.6.10-bk8/include/linux/pkt_cls.h	2005-01-05 17:38:42.000000000 +0100
@@ -351,6 +351,7 @@
 	TCF_EM_CONTAINER,
 	TCF_EM_CMP,
 	TCF_EM_NBYTE,
+	TCF_EM_U32,
 	__TCF_EM_MAX
 };
 
diff -Nru linux-2.6.10-bk8.orig/include/net/pkt_cls.h linux-2.6.10-bk8/include/net/pkt_cls.h
--- linux-2.6.10-bk8.orig/include/net/pkt_cls.h	2005-01-05 17:40:02.000000000 +0100
+++ linux-2.6.10-bk8/include/net/pkt_cls.h	2005-01-05 17:39:08.000000000 +0100
@@ -274,6 +274,8 @@
 
 struct tcf_pkt_info
 {
+	u8 *			ptr;
+	int			nexthdr;
 };
 
 static inline u32 tcf_read_bucket(u8 *ptr, u8 align)
diff -Nru linux-2.6.10-bk8.orig/net/sched/Kconfig linux-2.6.10-bk8/net/sched/Kconfig
--- linux-2.6.10-bk8.orig/net/sched/Kconfig	2005-01-05 17:38:26.000000000 +0100
+++ linux-2.6.10-bk8/net/sched/Kconfig	2005-01-05 17:41:59.000000000 +0100
@@ -408,6 +408,12 @@
 	  To compile this code as a module, choose M here: the
 	  module will be called em_nbyte.
 
+config NET_EMATCH_U32
+	tristate "U32 hashing key"
+	depends on NET_EMATCH
+	---help---
+	  TODO
+
 config NET_CLS_ACT
 	bool "Packet ACTION"
 	depends on EXPERIMENTAL && NET_CLS && NET_QOS
diff -Nru linux-2.6.10-bk8.orig/net/sched/Makefile linux-2.6.10-bk8/net/sched/Makefile
--- linux-2.6.10-bk8.orig/net/sched/Makefile	2005-01-05 17:38:26.000000000 +0100
+++ linux-2.6.10-bk8/net/sched/Makefile	2005-01-05 17:40:15.000000000 +0100
@@ -36,3 +36,4 @@
 obj-$(CONFIG_NET_EMATCH)	+= ematch.o
 obj-$(CONFIG_NET_EMATCH_CMP)	+= em_cmp.o
 obj-$(CONFIG_NET_EMATCH_NBYTE)	+= em_nbyte.o
+obj-$(CONFIG_NET_EMATCH_U32)	+= em_u32.o
diff -Nru linux-2.6.10-bk8.orig/net/sched/em_u32.c linux-2.6.10-bk8/net/sched/em_u32.c
--- linux-2.6.10-bk8.orig/net/sched/em_u32.c	1970-01-01 01:00:00.000000000 +0100
+++ linux-2.6.10-bk8/net/sched/em_u32.c	2005-01-05 17:38:42.000000000 +0100
@@ -0,0 +1,53 @@
+/*
+ * net/sched/em_u32.c	U32 Ematch
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Thomas Graf <tgraf@suug.ch>
+ *		Alexey Kuznetsov, <kuznet@ms2.inr.ac.ru>
+ *
+ * Based on net/sched/cls_u32.c
+ */
+
+#include <linux/config.h>
+#include <linux/module.h>
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/skbuff.h>
+#include <net/pkt_cls.h>
+
+static int em_u32_match(struct sk_buff *skb, struct tcf_ematch *m,
+			struct tcf_pkt_info *info)
+{
+	struct tc_u32_key *k = (struct tc_u32_key *) m->data;
+	u8 *ptr = info->ptr + k->off + (info->nexthdr & k->offmask);
+
+	return !((*(u32*) ptr ^ k->val) & k->mask);
+}
+
+static struct tcf_ematch_ops em_u32_ops = {
+	.kind	  = TCF_EM_U32,
+	.datalen  = sizeof(struct tc_u32_key),
+	.match	  = em_u32_match,
+	.owner	  = THIS_MODULE,
+	.link	  = LIST_HEAD_INIT(em_u32_ops.link)
+};
+
+static int __init init_em_u32(void)
+{
+	return tcf_em_register(&em_u32_ops);
+}
+
+static void __exit exit_em_u32(void) 
+{
+	tcf_em_unregister(&em_u32_ops);
+}
+
+MODULE_LICENSE("GPL");
+
+module_init(init_em_u32);
+module_exit(exit_em_u32);
+

From: Thomas Graf <tgraf@suug.ch>
Subject: [RESEND 4/6] PKT_SCHED: u32 ematch
Date: Wed, 26 Jan 2005 00:24:30 +0100
Message-ID: <20050125232430.GJ31837@postel.suug.ch>
References: <20050123230012.GB23931@postel.suug.ch> <20050123230354.GF23931@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050123230354.GF23931@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Resend with offset validation as Patrick suggested.

The u32 ematch behaves exactly the same as a u32 match and will replace
it in the long term. It allows the underlying classifiers to give hints
about the position of the next protocol header (i.e. nexthdr+).

Signed-off-by: Thomas Graf <tgraf@suug.ch>

diff -Nru linux-2.6.11-rc2-bk3.orig/include/linux/pkt_cls.h linux-2.6.11-rc2-bk3/include/linux/pkt_cls.h
--- linux-2.6.11-rc2-bk3.orig/include/linux/pkt_cls.h	2005-01-25 23:58:04.000000000 +0100
+++ linux-2.6.11-rc2-bk3/include/linux/pkt_cls.h	2005-01-25 23:58:20.000000000 +0100
@@ -385,6 +385,7 @@
 	TCF_EM_CONTAINER,
 	TCF_EM_CMP,
 	TCF_EM_NBYTE,
+	TCF_EM_U32,
 	__TCF_EM_MAX
 };
 
diff -Nru linux-2.6.11-rc2-bk3.orig/include/net/pkt_cls.h linux-2.6.11-rc2-bk3/include/net/pkt_cls.h
--- linux-2.6.11-rc2-bk3.orig/include/net/pkt_cls.h	2005-01-25 23:57:30.000000000 +0100
+++ linux-2.6.11-rc2-bk3/include/net/pkt_cls.h	2005-01-25 23:58:20.000000000 +0100
@@ -153,6 +153,8 @@
  */
 struct tcf_pkt_info
 {
+	unsigned char *		ptr;
+	int			nexthdr;
 };
 
 #ifdef CONFIG_NET_EMATCH
diff -Nru linux-2.6.11-rc2-bk3.orig/net/sched/Kconfig linux-2.6.11-rc2-bk3/net/sched/Kconfig
--- linux-2.6.11-rc2-bk3.orig/net/sched/Kconfig	2005-01-25 23:58:04.000000000 +0100
+++ linux-2.6.11-rc2-bk3/net/sched/Kconfig	2005-01-25 23:58:20.000000000 +0100
@@ -418,6 +418,16 @@
 	  To compile this code as a module, choose M here: the
 	  module will be called em_nbyte.
 
+config NET_EMATCH_U32
+	tristate "U32 hashing key"
+	depends on NET_EMATCH
+	---help---
+	  Say Y here if you want to be able to classify packets using
+	  the famous u32 key in combination with logic relations.
+
+	  To compile this code as a module, choose M here: the
+	  module will be called em_u32.
+
 config NET_CLS_ACT
 	bool "Packet ACTION"
 	depends on EXPERIMENTAL && NET_CLS && NET_QOS
diff -Nru linux-2.6.11-rc2-bk3.orig/net/sched/Makefile linux-2.6.11-rc2-bk3/net/sched/Makefile
--- linux-2.6.11-rc2-bk3.orig/net/sched/Makefile	2005-01-25 23:58:04.000000000 +0100
+++ linux-2.6.11-rc2-bk3/net/sched/Makefile	2005-01-25 23:58:20.000000000 +0100
@@ -36,3 +36,4 @@
 obj-$(CONFIG_NET_EMATCH)	+= ematch.o
 obj-$(CONFIG_NET_EMATCH_CMP)	+= em_cmp.o
 obj-$(CONFIG_NET_EMATCH_NBYTE)	+= em_nbyte.o
+obj-$(CONFIG_NET_EMATCH_U32)	+= em_u32.o
diff -Nru linux-2.6.11-rc2-bk3.orig/net/sched/em_u32.c linux-2.6.11-rc2-bk3/net/sched/em_u32.c
--- linux-2.6.11-rc2-bk3.orig/net/sched/em_u32.c	1970-01-01 01:00:00.000000000 +0100
+++ linux-2.6.11-rc2-bk3/net/sched/em_u32.c	2005-01-26 00:06:03.000000000 +0100
@@ -0,0 +1,63 @@
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
+static int em_u32_match(struct sk_buff *skb, struct tcf_ematch *em,
+			struct tcf_pkt_info *info)
+{
+	struct tc_u32_key *key = (struct tc_u32_key *) em->data;
+	unsigned char *ptr = skb->nh.raw;
+	
+	if (info) {
+		if (info->ptr)
+			ptr = info->ptr;
+		ptr += (info->nexthdr & key->offmask);
+	}
+
+	ptr += key->off;
+
+	if (!tcf_valid_offset(skb, ptr, sizeof(u32)))
+		return 0;
+	
+	return !(((*(u32*) ptr)  ^ key->val) & key->mask);
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

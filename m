From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 3/6] PKT_SCHED: Multi byte comparison ematch (nbyte)
Date: Mon, 24 Jan 2005 00:03:14 +0100
Message-ID: <20050123230314.GE23931@postel.suug.ch>
References: <20050123230012.GB23931@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050123230012.GB23931@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The nbyte ematch allows comparing any number of bytes at an arbitary
offset based on one of the skb layers. Its main usage is intended
for IPv6 addresses but may be used for any kind of pattern.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

diff -Nru linux-2.6.11-rc2-bk1.orig/include/linux/pkt_cls.h linux-2.6.11-rc2-bk1/include/linux/pkt_cls.h
--- linux-2.6.11-rc2-bk1.orig/include/linux/pkt_cls.h	2005-01-23 17:33:14.000000000 +0100
+++ linux-2.6.11-rc2-bk1/include/linux/pkt_cls.h	2005-01-23 17:33:26.000000000 +0100
@@ -384,6 +384,7 @@
 {
 	TCF_EM_CONTAINER,
 	TCF_EM_CMP,
+	TCF_EM_NBYTE,
 	__TCF_EM_MAX
 };
 
diff -Nru linux-2.6.11-rc2-bk1.orig/include/linux/tc_ematch/tc_em_nbyte.h linux-2.6.11-rc2-bk1/include/linux/tc_ematch/tc_em_nbyte.h
--- linux-2.6.11-rc2-bk1.orig/include/linux/tc_ematch/tc_em_nbyte.h	1970-01-01 01:00:00.000000000 +0100
+++ linux-2.6.11-rc2-bk1/include/linux/tc_ematch/tc_em_nbyte.h	2005-01-23 17:33:26.000000000 +0100
@@ -0,0 +1,13 @@
+#ifndef __LINUX_TC_EM_NBYTE_H
+#define __LINUX_TC_EM_NBYTE_H
+
+#include <linux/pkt_cls.h>
+
+struct tcf_em_nbyte
+{
+	__u16		off;
+	__u16		len:12;
+	__u8		layer:4;
+};
+
+#endif
diff -Nru linux-2.6.11-rc2-bk1.orig/net/sched/Kconfig linux-2.6.11-rc2-bk1/net/sched/Kconfig
--- linux-2.6.11-rc2-bk1.orig/net/sched/Kconfig	2005-01-23 17:33:14.000000000 +0100
+++ linux-2.6.11-rc2-bk1/net/sched/Kconfig	2005-01-23 17:33:26.000000000 +0100
@@ -408,6 +408,16 @@
 	  To compile this code as a module, choose M here: the
 	  module will be called em_cmp.
 
+config NET_EMATCH_NBYTE
+	tristate "Multi byte comparison"
+	depends on NET_EMATCH
+	---help---
+	  Say Y here if you want to be able to classify packets based on
+	  multiple byte comparisons mainly useful for IPv6 address comparisons.
+
+	  To compile this code as a module, choose M here: the
+	  module will be called em_nbyte.
+
 config NET_CLS_ACT
 	bool "Packet ACTION"
 	depends on EXPERIMENTAL && NET_CLS && NET_QOS
diff -Nru linux-2.6.11-rc2-bk1.orig/net/sched/Makefile linux-2.6.11-rc2-bk1/net/sched/Makefile
--- linux-2.6.11-rc2-bk1.orig/net/sched/Makefile	2005-01-23 17:33:14.000000000 +0100
+++ linux-2.6.11-rc2-bk1/net/sched/Makefile	2005-01-23 17:33:26.000000000 +0100
@@ -35,3 +35,4 @@
 obj-$(CONFIG_NET_CLS_RSVP6)	+= cls_rsvp6.o
 obj-$(CONFIG_NET_EMATCH)	+= ematch.o
 obj-$(CONFIG_NET_EMATCH_CMP)	+= em_cmp.o
+obj-$(CONFIG_NET_EMATCH_NBYTE)	+= em_nbyte.o
diff -Nru linux-2.6.11-rc2-bk1.orig/net/sched/em_nbyte.c linux-2.6.11-rc2-bk1/net/sched/em_nbyte.c
--- linux-2.6.11-rc2-bk1.orig/net/sched/em_nbyte.c	1970-01-01 01:00:00.000000000 +0100
+++ linux-2.6.11-rc2-bk1/net/sched/em_nbyte.c	2005-01-23 17:36:08.000000000 +0100
@@ -0,0 +1,82 @@
+/*
+ * net/sched/em_nbyte.c	N-Byte ematch
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
+#include <linux/tc_ematch/tc_em_nbyte.h>
+#include <net/pkt_cls.h>
+
+struct nbyte_data
+{
+	struct tcf_em_nbyte	hdr;
+	char			pattern[0];
+};
+	
+static int em_nbyte_change(struct tcf_proto *tp, void *data, int data_len,
+			   struct tcf_ematch *em)
+{
+	struct tcf_em_nbyte *nbyte = data;
+
+	if (data_len < sizeof(*nbyte) ||
+	    data_len < (sizeof(*nbyte) + nbyte->len))
+		return -EINVAL;
+
+	em->datalen = sizeof(*nbyte) + nbyte->len;
+	em->data = (unsigned long) kmalloc(em->datalen, GFP_KERNEL);
+	if (em->data == 0UL)
+		return -ENOBUFS;
+
+	memcpy((void *) em->data, data, em->datalen);
+
+	return 0;
+}
+
+static int em_nbyte_match(struct sk_buff *skb, struct tcf_ematch *em,
+			  struct tcf_pkt_info *info)
+{
+	struct nbyte_data *nbyte = (struct nbyte_data *) em->data;
+	unsigned char *ptr = tcf_get_base_ptr(skb, nbyte->hdr.layer);
+
+	ptr += nbyte->hdr.off;
+
+	if (!tcf_valid_offset(skb, ptr, nbyte->hdr.len))
+		return 0;
+
+	return !memcmp(ptr + nbyte->hdr.off, nbyte->pattern, nbyte->hdr.len);
+}
+
+static struct tcf_ematch_ops em_nbyte_ops = {
+	.kind	  = TCF_EM_NBYTE,
+	.change	  = em_nbyte_change,
+	.match	  = em_nbyte_match,
+	.owner	  = THIS_MODULE,
+	.link	  = LIST_HEAD_INIT(em_nbyte_ops.link)
+};
+
+static int __init init_em_nbyte(void)
+{
+	return tcf_em_register(&em_nbyte_ops);
+}
+
+static void __exit exit_em_nbyte(void) 
+{
+	tcf_em_unregister(&em_nbyte_ops);
+}
+
+MODULE_LICENSE("GPL");
+
+module_init(init_em_nbyte);
+module_exit(exit_em_nbyte);

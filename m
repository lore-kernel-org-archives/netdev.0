From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2/6] PKT_SCHED: Simple comparison ematch (cmp)
Date: Mon, 24 Jan 2005 00:02:21 +0100
Message-ID: <20050123230221.GD23931@postel.suug.ch>
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

The cmp ematch compares a static value provided by userspace against
a 8, 16, or 32bit chunk read from the packet. The reading offset is
provided by userspace and based on one of the skb layers (mac|nh|h).
The ematch provides functionality to transform the byte order of
the chunk and/or apply a mask and understands the operands eq, lt,
and gt. Basically, it is very similiar to the u32 (e)match but tries
filling the gaps left behind.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

diff -Nru linux-2.6.11-rc2-bk1.orig/include/linux/pkt_cls.h linux-2.6.11-rc2-bk1/include/linux/pkt_cls.h
--- linux-2.6.11-rc2-bk1.orig/include/linux/pkt_cls.h	2005-01-23 17:29:35.000000000 +0100
+++ linux-2.6.11-rc2-bk1/include/linux/pkt_cls.h	2005-01-23 17:29:40.000000000 +0100
@@ -383,6 +383,7 @@
 enum
 {
 	TCF_EM_CONTAINER,
+	TCF_EM_CMP,
 	__TCF_EM_MAX
 };
 
@@ -391,4 +392,11 @@
 	TCF_EM_PROG_TC
 };
 
+enum
+{
+	TCF_EM_OPND_EQ,
+	TCF_EM_OPND_GT,
+	TCF_EM_OPND_LT
+};
+
 #endif
diff -Nru linux-2.6.11-rc2-bk1.orig/include/linux/tc_ematch/tc_em_cmp.h linux-2.6.11-rc2-bk1/include/linux/tc_ematch/tc_em_cmp.h
--- linux-2.6.11-rc2-bk1.orig/include/linux/tc_ematch/tc_em_cmp.h	1970-01-01 01:00:00.000000000 +0100
+++ linux-2.6.11-rc2-bk1/include/linux/tc_ematch/tc_em_cmp.h	2005-01-23 17:29:40.000000000 +0100
@@ -0,0 +1,26 @@
+#ifndef __LINUX_TC_EM_CMP_H
+#define __LINUX_TC_EM_CMP_H
+
+#include <linux/pkt_cls.h>
+
+struct tcf_em_cmp
+{
+	__u32		val;
+	__u32		mask;
+	__u16		off;
+	__u8		align:4;
+	__u8		flags:4;
+	__u8		layer:4;
+	__u8		opnd:4;
+};
+
+enum
+{
+	TCF_EM_ALIGN_U8  = 1,
+	TCF_EM_ALIGN_U16 = 2,
+	TCF_EM_ALIGN_U32 = 4
+};
+
+#define TCF_EM_CMP_TRANS	1
+
+#endif
diff -Nru linux-2.6.11-rc2-bk1.orig/include/net/pkt_cls.h linux-2.6.11-rc2-bk1/include/net/pkt_cls.h
--- linux-2.6.11-rc2-bk1.orig/include/net/pkt_cls.h	2005-01-23 17:29:35.000000000 +0100
+++ linux-2.6.11-rc2-bk1/include/net/pkt_cls.h	2005-01-23 17:30:55.000000000 +0100
@@ -318,6 +318,26 @@
 
 #endif /* CONFIG_NET_EMATCH */
 
+static inline unsigned char * tcf_get_base_ptr(struct sk_buff *skb, int layer)
+{
+	switch (layer) {
+		case TCF_LAYER_LINK:
+			return skb->data;
+		case TCF_LAYER_NETWORK:
+			return skb->nh.raw;
+		case TCF_LAYER_TRANSPORT:
+			return skb->h.raw;
+	}
+
+	return NULL;
+}
+
+static inline int tcf_valid_offset(struct sk_buff *skb, unsigned char *ptr,
+				   int len)
+{
+	return unlikely((ptr + len) < skb->tail && ptr > skb->head);
+}
+
 #ifdef CONFIG_NET_CLS_IND
 static inline int
 tcf_change_indev(struct tcf_proto *tp, char *indev, struct rtattr *indev_tlv)
diff -Nru linux-2.6.11-rc2-bk1.orig/net/sched/Kconfig linux-2.6.11-rc2-bk1/net/sched/Kconfig
--- linux-2.6.11-rc2-bk1.orig/net/sched/Kconfig	2005-01-23 17:29:35.000000000 +0100
+++ linux-2.6.11-rc2-bk1/net/sched/Kconfig	2005-01-23 17:29:40.000000000 +0100
@@ -398,6 +398,16 @@
 	  encapsulated precedences. Every level requires 4 bytes of addtional
 	  stack space.
 
+config NET_EMATCH_CMP
+	tristate "Simple packet data comparison"
+	depends on NET_EMATCH
+	---help---
+	  Say Y here if you want to be able to classify packets based on
+	  simple packet data comparisons for 8, 16, and 32bit values.
+
+	  To compile this code as a module, choose M here: the
+	  module will be called em_cmp.
+
 config NET_CLS_ACT
 	bool "Packet ACTION"
 	depends on EXPERIMENTAL && NET_CLS && NET_QOS
diff -Nru linux-2.6.11-rc2-bk1.orig/net/sched/Makefile linux-2.6.11-rc2-bk1/net/sched/Makefile
--- linux-2.6.11-rc2-bk1.orig/net/sched/Makefile	2005-01-23 17:29:35.000000000 +0100
+++ linux-2.6.11-rc2-bk1/net/sched/Makefile	2005-01-23 17:29:40.000000000 +0100
@@ -34,3 +34,4 @@
 obj-$(CONFIG_NET_CLS_TCINDEX)	+= cls_tcindex.o
 obj-$(CONFIG_NET_CLS_RSVP6)	+= cls_rsvp6.o
 obj-$(CONFIG_NET_EMATCH)	+= ematch.o
+obj-$(CONFIG_NET_EMATCH_CMP)	+= em_cmp.o
diff -Nru linux-2.6.11-rc2-bk1.orig/net/sched/em_cmp.c linux-2.6.11-rc2-bk1/net/sched/em_cmp.c
--- linux-2.6.11-rc2-bk1.orig/net/sched/em_cmp.c	1970-01-01 01:00:00.000000000 +0100
+++ linux-2.6.11-rc2-bk1/net/sched/em_cmp.c	2005-01-23 17:31:03.000000000 +0100
@@ -0,0 +1,101 @@
+/*
+ * net/sched/em_cmp.c	Simple packet data comparison ematch
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
+#include <linux/skbuff.h>
+#include <linux/tc_ematch/tc_em_cmp.h>
+#include <net/pkt_cls.h>
+
+static inline int cmp_needs_transformation(struct tcf_em_cmp *cmp)
+{
+	return unlikely(cmp->flags & TCF_EM_CMP_TRANS);
+}
+
+static int em_cmp_match(struct sk_buff *skb, struct tcf_ematch *em,
+			struct tcf_pkt_info *info)
+{
+	struct tcf_em_cmp *cmp = (struct tcf_em_cmp *) em->data;
+	unsigned char *ptr = tcf_get_base_ptr(skb, cmp->layer) + cmp->off;
+	u32 val = 0;
+
+	if (!tcf_valid_offset(skb, ptr, cmp->align))
+		return 0;
+
+	switch (cmp->align) {
+		case TCF_EM_ALIGN_U8:
+			val = *ptr;
+			break;
+
+		case TCF_EM_ALIGN_U16:
+			val = *ptr << 8;
+			val |= *(ptr+1);
+
+			if (cmp_needs_transformation(cmp))
+				val = be16_to_cpu(val);
+			break;
+
+		case TCF_EM_ALIGN_U32:
+			/* Worth checking boundries? The branching seems
+			 * to get worse. Visit again. */
+			val = *ptr << 24;
+			val |= *(ptr+1) << 16;
+			val |= *(ptr+2) << 8;
+			val |= *(ptr+3);
+
+			if (cmp_needs_transformation(cmp))
+				val = be32_to_cpu(val);
+			break;
+
+		default:
+			return 0;
+	}
+
+	if (cmp->mask)
+		val &= cmp->mask;
+
+	switch (cmp->opnd) {
+		case TCF_EM_OPND_EQ:
+			return val == cmp->val;
+		case TCF_EM_OPND_LT:
+			return val < cmp->val;
+		case TCF_EM_OPND_GT:
+			return val > cmp->val;
+	}
+
+	return 0;
+}
+
+static struct tcf_ematch_ops em_cmp_ops = {
+	.kind	  = TCF_EM_CMP,
+	.datalen  = sizeof(struct tcf_em_cmp),
+	.match	  = em_cmp_match,
+	.owner	  = THIS_MODULE,
+	.link	  = LIST_HEAD_INIT(em_cmp_ops.link)
+};
+
+static int __init init_em_cmp(void)
+{
+	return tcf_em_register(&em_cmp_ops);
+}
+
+static void __exit exit_em_cmp(void) 
+{
+	tcf_em_unregister(&em_cmp_ops);
+}
+
+MODULE_LICENSE("GPL");
+
+module_init(init_em_cmp);
+module_exit(exit_em_cmp);
+

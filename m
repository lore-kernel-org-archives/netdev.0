From: Thomas Graf <tgraf@suug.ch>
Subject: [RFC] string matching ematch
Date: Wed, 26 Jan 2005 16:07:14 +0100
Message-ID: <20050126150714.GL31837@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jamal Hadi Salim <hadi@cyberus.ca>, Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I'd like to discuss the string matching ematch, I don't care about the
algorithm used but rather whether to make it stateful, match over
fragments, etc. I attached a simple stateless string matching ematch
using the Knuth-Morris-Pratt algorithm as a starting point.

KMP   ::= pattern [ BEGIN ] [ END ]
BEGIN ::= from OFFSET [ layer LAYER ]
END   ::= to OFFSET [ layer LAYER ]

where:
 default value for BEGIN: skb->h.raw
 default value for END: skb->tail

The prefix table used by the KMP algorithm is calculated in userspace.

The layering schema used is the one I introduced in the ematch patchset
which is likely to be extended by another layer dynamically calculated
from the packet payload.

The limitation is pretty obvious, it relies on linear skbs and is not
quite limited in matching the payload of a stream based protocol.

Making it aware of non-linear skbs isn't that hard, the matcher gets
a bit more complicated but shouldn't slow down too much so this is
probably worth doing.

Making it aware of a state gets much more complicated and if we don't
queue packets we can only classify on the packet holding the last
part of the pattern. So we need to either tell the underlying qdisc
to hold the packet for some time or accept this limitation. The
state of the matcher could be stored in the conntrack entry so the
match can be resumed when the relevent packet arrives. We're moving
more and more towards netfilter and application level filtering and
I think this should be covered by netfilter itself. If we do this,
we should at least share the code with netfilter.

Thoughts?

diff -Nru linux-2.6.11-rc2-bk3.orig/include/linux/pkt_cls.h linux-2.6.11-rc2-bk3/include/linux/pkt_cls.h
--- linux-2.6.11-rc2-bk3.orig/include/linux/pkt_cls.h	2005-01-26 13:28:25.000000000 +0100
+++ linux-2.6.11-rc2-bk3/include/linux/pkt_cls.h	2005-01-26 14:03:42.000000000 +0100
@@ -401,6 +401,7 @@
 	TCF_EM_NBYTE,
 	TCF_EM_U32,
 	TCF_EM_META,
+	TCF_EM_KMP,
 	__TCF_EM_MAX
 };
 
diff -Nru linux-2.6.11-rc2-bk3.orig/include/linux/tc_ematch/tc_em_kmp.h linux-2.6.11-rc2-bk3/include/linux/tc_ematch/tc_em_kmp.h
--- linux-2.6.11-rc2-bk3.orig/include/linux/tc_ematch/tc_em_kmp.h	1970-01-01 01:00:00.000000000 +0100
+++ linux-2.6.11-rc2-bk3/include/linux/tc_ematch/tc_em_kmp.h	2005-01-26 13:42:49.000000000 +0100
@@ -0,0 +1,24 @@
+#ifndef __LINUX_TC_EM_KMP_H
+#define __LINUX_TC_EM_KMP_H
+
+#include <linux/pkt_cls.h>
+
+enum
+{
+	TCA_EM_KMP_UNSPEC,
+	TCA_EM_KMP_FROM,	/* struct tcf_kmp_offset */
+	TCA_EM_KMP_TO,		/* struct tcf_kmp_offset */
+	TCA_EM_KMP_LENGTH,	/* u32 */
+	TCA_EM_KMP_PATTERN,	/* unsigned char[] */
+	TCA_EM_KMP_PREFIX_TBL,	/* u32[] */
+	__TCA_EM_KMP_MAX
+};
+#define TCA_EM_KMP_MAX (__TCA_EM_KMP_MAX - 1)
+
+struct tcf_kmp_offset
+{
+	__u16		off;
+	__u16		layer;
+};
+
+#endif
diff -Nru linux-2.6.11-rc2-bk3.orig/net/sched/Kconfig linux-2.6.11-rc2-bk3/net/sched/Kconfig
--- linux-2.6.11-rc2-bk3.orig/net/sched/Kconfig	2005-01-26 13:28:25.000000000 +0100
+++ linux-2.6.11-rc2-bk3/net/sched/Kconfig	2005-01-26 14:19:59.000000000 +0100
@@ -449,6 +449,16 @@
 	  To compile this code as a module, choose M here: the
 	  module will be called em_meta.
 
+config NET_EMATCH_KMP
+	tristate "Knuth-Morris-Pratt string matching"
+	depends on NET_EMATCH
+	---help---
+	  Say Y here if you want to be able to classify packets by
+	  matching strings using the KMP string matching algorithm.
+	  
+	  To compile this code as a module, choose M here: the
+	  module will be called em_kmp.
+
 config NET_CLS_ACT
 	bool "Packet ACTION"
 	depends on EXPERIMENTAL && NET_CLS && NET_QOS
diff -Nru linux-2.6.11-rc2-bk3.orig/net/sched/Makefile linux-2.6.11-rc2-bk3/net/sched/Makefile
--- linux-2.6.11-rc2-bk3.orig/net/sched/Makefile	2005-01-26 13:28:25.000000000 +0100
+++ linux-2.6.11-rc2-bk3/net/sched/Makefile	2005-01-26 14:22:54.000000000 +0100
@@ -39,3 +39,4 @@
 obj-$(CONFIG_NET_EMATCH_NBYTE)	+= em_nbyte.o
 obj-$(CONFIG_NET_EMATCH_U32)	+= em_u32.o
 obj-$(CONFIG_NET_EMATCH_META)	+= em_meta.o
+obj-$(CONFIG_NET_EMATCH_KMP)	+= em_kmp.o
diff -Nru linux-2.6.11-rc2-bk3.orig/net/sched/em_kmp.c linux-2.6.11-rc2-bk3/net/sched/em_kmp.c
--- linux-2.6.11-rc2-bk3.orig/net/sched/em_kmp.c	1970-01-01 01:00:00.000000000 +0100
+++ linux-2.6.11-rc2-bk3/net/sched/em_kmp.c	2005-01-26 14:25:18.000000000 +0100
@@ -0,0 +1,175 @@
+/*
+ * net/sched/em_kmp.c	Knuth-Morris-Pratt string matching
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
+#include <linux/tc_ematch/tc_em_kmp.h>
+#include <net/pkt_cls.h>
+
+struct kmp_data
+{
+	struct tcf_kmp_offset	from;
+	struct tcf_kmp_offset	to;
+	u32			len;
+	u32			prefix_tbl[0];
+};
+
+#define KMP_PATTERN(kmp) \
+	((void*) (kmp) + sizeof(struct kmp_data) + ((kmp)->len * sizeof(u32)))
+
+static int em_kmp_change(struct tcf_proto *tp, void *data, int data_len,
+			 struct tcf_ematch *em)
+{
+	int kmp_size, err = -EINVAL;
+	struct rtattr *tb[TCA_EM_KMP_MAX];
+	struct tcf_kmp_offset *koff;
+	struct kmp_data *kmp;
+	u32 len;
+	
+	if (rtattr_parse(tb, TCA_EM_KMP_MAX, data, data_len) < 0)
+		goto errout;
+
+	if (tb[TCA_EM_KMP_LENGTH-1] == NULL ||
+	    tb[TCA_EM_KMP_PATTERN-1] == NULL ||
+	    tb[TCA_EM_KMP_PREFIX_TBL-1] == NULL)
+		goto errout;
+
+	if (RTA_PAYLOAD(tb[TCA_EM_KMP_LENGTH-1]) < sizeof(len))
+		goto errout;
+	len = *(u32 *) RTA_DATA(tb[TCA_EM_KMP_LENGTH-1]);
+
+	if (RTA_PAYLOAD(tb[TCA_EM_KMP_PATTERN-1]) < len ||
+	    RTA_PAYLOAD(tb[TCA_EM_KMP_PREFIX_TBL-1]) < (len * sizeof(u32)))
+		goto errout;
+
+	if (tb[TCA_EM_KMP_FROM-1])
+		if (RTA_PAYLOAD(tb[TCA_EM_KMP_FROM-1]) < sizeof(*koff))
+			goto errout;
+	
+	if (tb[TCA_EM_KMP_TO-1])
+		if (RTA_PAYLOAD(tb[TCA_EM_KMP_TO-1]) < sizeof(*koff))
+			goto errout;
+
+	kmp_size = sizeof(*kmp) + (len * sizeof(u32)) + len;
+	kmp = kmalloc(kmp_size, GFP_KERNEL);
+	if (kmp == NULL) {
+		err = -ENOMEM;
+		goto errout;
+	}
+	memset(kmp, 0, kmp_size);
+
+	kmp->len = len;
+
+	if (tb[TCA_EM_KMP_FROM-1]) {
+		koff = RTA_DATA(tb[TCA_EM_KMP_FROM-1]);
+		memcpy(&kmp->from, koff, sizeof(*koff));
+	} else
+		kmp->from.layer = TCF_LAYER_TRANSPORT;
+
+	if (tb[TCA_EM_KMP_TO-1]) {
+		koff = RTA_DATA(tb[TCA_EM_KMP_TO-1]);
+		memcpy(&kmp->to, koff, sizeof(*koff));
+	}
+
+	memcpy(kmp->prefix_tbl, RTA_DATA(tb[TCA_EM_KMP_PREFIX_TBL-1]),
+		len * sizeof(u32));
+
+	memcpy(KMP_PATTERN(kmp), RTA_DATA(tb[TCA_EM_KMP_PATTERN-1]), len);
+	
+	em->datalen = kmp_size;
+	em->data = (unsigned long) kmp;
+
+	err = 0;
+errout:
+	return err;
+}
+
+static int em_kmp_match(struct sk_buff *skb, struct tcf_ematch *em,
+			struct tcf_pkt_info *info)
+{
+	struct kmp_data *kmp = (struct kmp_data *) em->data;
+	unsigned char *begin, *end;
+	unsigned char *pattern = KMP_PATTERN(kmp);
+	int q;
+
+	begin = tcf_get_base_ptr(skb, kmp->from.layer);
+	begin += kmp->from.off;
+
+	if (kmp->to.off || kmp->to.layer) {
+		end = tcf_get_base_ptr(skb, kmp->to.layer);
+		end += kmp->to.off;
+	} else
+		end = skb->tail;
+
+	if (!tcf_valid_offset(skb, begin, kmp->len) ||
+	    !tcf_valid_offset(skb, end, 0) ||
+	    (end - kmp->len) < begin)
+		return 0;
+
+	for (q = 0; begin < end; begin++) {
+		while (q > 0 && pattern[q] != *begin)
+			q = kmp->prefix_tbl[q - 1];
+		if (pattern[q] == *begin)
+			q++;
+		if (q == kmp->len)
+			return 1;
+	}
+
+	return 0;
+}
+
+static int em_kmp_dump(struct sk_buff *skb, struct tcf_ematch *em)
+{
+	struct kmp_data *kmp = (struct kmp_data *) em->data;
+
+	RTA_PUT(skb, TCA_EM_KMP_FROM, sizeof(kmp->from), &kmp->from);
+
+	if (kmp->to.off || kmp->to.layer)
+		RTA_PUT(skb, TCA_EM_KMP_TO, sizeof(kmp->to), &kmp->to);
+
+	RTA_PUT(skb, TCA_EM_KMP_LENGTH, sizeof(kmp->len), &kmp->len);
+	RTA_PUT(skb, TCA_EM_KMP_PATTERN, kmp->len, KMP_PATTERN(kmp));
+	RTA_PUT(skb, TCA_EM_KMP_PREFIX_TBL, kmp->len * sizeof(u32),
+		kmp->prefix_tbl);
+
+	return 0;
+rtattr_failure:
+	return -1;
+}
+
+static struct tcf_ematch_ops em_kmp_ops = {
+	.kind	  = TCF_EM_KMP,
+	.change	  = em_kmp_change,
+	.match	  = em_kmp_match,
+	.dump	  = em_kmp_dump,
+	.owner	  = THIS_MODULE,
+	.link	  = LIST_HEAD_INIT(em_kmp_ops.link)
+};
+
+static int __init init_em_kmp(void)
+{
+	return tcf_em_register(&em_kmp_ops);
+}
+
+static void __exit exit_em_kmp(void) 
+{
+	tcf_em_unregister(&em_kmp_ops);
+}
+
+MODULE_LICENSE("GPL");
+
+module_init(init_em_kmp);
+module_exit(exit_em_kmp);

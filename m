From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/6] PKT_SCHED: Simple comparison ematch (cmp)
Date: Mon, 24 Jan 2005 01:14:12 +0100
Message-ID: <41F43DD4.8070306@trash.net>
References: <20050123230012.GB23931@postel.suug.ch> <20050123230221.GD23931@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050123230221.GD23931@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:

>diff -Nru linux-2.6.11-rc2-bk1.orig/net/sched/em_cmp.c linux-2.6.11-rc2-bk1/net/sched/em_cmp.c
>--- linux-2.6.11-rc2-bk1.orig/net/sched/em_cmp.c	1970-01-01 01:00:00.000000000 +0100
>+++ linux-2.6.11-rc2-bk1/net/sched/em_cmp.c	2005-01-23 17:31:03.000000000 +0100
>@@ -0,0 +1,101 @@
>+/*
>+ * net/sched/em_cmp.c	Simple packet data comparison ematch
>+ *
>+ *		This program is free software; you can redistribute it and/or
>+ *		modify it under the terms of the GNU General Public License
>+ *		as published by the Free Software Foundation; either version
>+ *		2 of the License, or (at your option) any later version.
>+ *
>+ * Authors:	Thomas Graf <tgraf@suug.ch>
>+ */
>+
>+#include <linux/config.h>
>+#include <linux/module.h>
>+#include <linux/types.h>
>+#include <linux/kernel.h>
>+#include <linux/skbuff.h>
>+#include <linux/tc_ematch/tc_em_cmp.h>
>+#include <net/pkt_cls.h>
>+
>+static inline int cmp_needs_transformation(struct tcf_em_cmp *cmp)
>+{
>+	return unlikely(cmp->flags & TCF_EM_CMP_TRANS);
>+}
>+
>+static int em_cmp_match(struct sk_buff *skb, struct tcf_ematch *em,
>+			struct tcf_pkt_info *info)
>+{
>+	struct tcf_em_cmp *cmp = (struct tcf_em_cmp *) em->data;
>+	unsigned char *ptr = tcf_get_base_ptr(skb, cmp->layer) + cmp->off;
>+	u32 val = 0;
>+
>+	if (!tcf_valid_offset(skb, ptr, cmp->align))
>+		return 0;
>+
>+	switch (cmp->align) {
>+		case TCF_EM_ALIGN_U8:
>+			val = *ptr;
>+			break;
>+
>+		case TCF_EM_ALIGN_U16:
>+			val = *ptr << 8;
>+			val |= *(ptr+1);
>+
>+			if (cmp_needs_transformation(cmp))
>+				val = be16_to_cpu(val);
>  
>
Why not simply convert cmp->val in userspace ?

>+			break;
>+
>+		case TCF_EM_ALIGN_U32:
>+			/* Worth checking boundries? The branching seems
>+			 * to get worse. Visit again. */
>+			val = *ptr << 24;
>+			val |= *(ptr+1) << 16;
>+			val |= *(ptr+2) << 8;
>+			val |= *(ptr+3);
>+
>+			if (cmp_needs_transformation(cmp))
>+				val = be32_to_cpu(val);
>+			break;
>+
>+		default:
>+			return 0;
>+	}
>+
>+	if (cmp->mask)
>+		val &= cmp->mask;
>+
>+	switch (cmp->opnd) {
>+		case TCF_EM_OPND_EQ:
>+			return val == cmp->val;
>+		case TCF_EM_OPND_LT:
>+			return val < cmp->val;
>+		case TCF_EM_OPND_GT:
>+			return val > cmp->val;
>+	}
>+
>+	return 0;
>+}
>+
>+static struct tcf_ematch_ops em_cmp_ops = {
>+	.kind	  = TCF_EM_CMP,
>+	.datalen  = sizeof(struct tcf_em_cmp),
>+	.match	  = em_cmp_match,
>+	.owner	  = THIS_MODULE,
>+	.link	  = LIST_HEAD_INIT(em_cmp_ops.link)
>+};
>+
>+static int __init init_em_cmp(void)
>+{
>+	return tcf_em_register(&em_cmp_ops);
>+}
>+
>+static void __exit exit_em_cmp(void) 
>+{
>+	tcf_em_unregister(&em_cmp_ops);
>+}
>+
>+MODULE_LICENSE("GPL");
>+
>+module_init(init_em_cmp);
>+module_exit(exit_em_cmp);
>+
>
>  
>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [net-next PATCH v2 5/5] Support to encoding decoding skb queue map on IFE action
Date: Tue, 23 Feb 2016 07:49:20 -0500
Message-ID: <1456231760-2513-6-git-send-email-jhs@emojatatu.com>
References: <1456231760-2513-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
	xiyou.wangcong@gmail.com, alexei.starovoitov@gmail.com,
	john.fastabend@gmail.com, dj@verizon.com,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:33973 "EHLO
	mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751873AbcBWMtj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 07:49:39 -0500
Received: by mail-io0-f182.google.com with SMTP id 9so213248891iom.1
        for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 04:49:39 -0800 (PST)
In-Reply-To: <1456231760-2513-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

hard code static value of 10 for qmap
mark of 12
prio of 13
and hashid of 11

sudo tc filter add dev $ETH parent 1: protocol ip prio 10 \
u32 match ip protocol 1 0xff flowid 1:2 \
action ife encode \
type 0xDEAD \
use mark 12 \
use prio 13 \
use hashid 11 \
use qmap 10 \
dst 02:15:15:15:15:15

Note: If you try to use skbedit to change inherit passed queue mapping
it may not work out of the box.
You need to do the following (to quote John Fastabend):
".. disable XPS and get sk_tx_queue() to return -1. This is because
XPS and socket mappings have a higher precedence in queue selection."

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 net/sched/Kconfig         |  5 +++
 net/sched/Makefile        |  1 +
 net/sched/act_meta_qmap.c | 96 +++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 102 insertions(+)
 create mode 100644 net/sched/act_meta_qmap.c

diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index 4c0c694..c25b192 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -766,6 +766,11 @@ config NET_IFE_SKBHASH
         depends on NET_ACT_IFE
         ---help---
 
+config NET_IFE_SKBQMAP
+        tristate "Support to encoding decoding skb queue_map on IFE action"
+        depends on NET_ACT_IFE
+        ---help---
+
 config NET_CLS_IND
 	bool "Incoming device classification"
 	depends on NET_CLS_U32 || NET_CLS_FW
diff --git a/net/sched/Makefile b/net/sched/Makefile
index 321a9bc..fa97501 100644
--- a/net/sched/Makefile
+++ b/net/sched/Makefile
@@ -23,6 +23,7 @@ obj-$(CONFIG_NET_ACT_IFE)	+= act_ife.o
 obj-$(CONFIG_NET_IFE_SKBMARK)	+= act_meta_mark.o
 obj-$(CONFIG_NET_IFE_SKBPRIO)	+= act_meta_skbprio.o
 obj-$(CONFIG_NET_IFE_SKBHASH)	+= act_meta_skbhash.o
+obj-$(CONFIG_NET_IFE_SKBQMAP)	+= act_meta_qmap.o
 obj-$(CONFIG_NET_SCH_FIFO)	+= sch_fifo.o
 obj-$(CONFIG_NET_SCH_CBQ)	+= sch_cbq.o
 obj-$(CONFIG_NET_SCH_HTB)	+= sch_htb.o
diff --git a/net/sched/act_meta_qmap.c b/net/sched/act_meta_qmap.c
new file mode 100644
index 0000000..e463a1e
--- /dev/null
+++ b/net/sched/act_meta_qmap.c
@@ -0,0 +1,96 @@
+/*
+ * net/sched/act_meta_qmap.c skb queue map encoder/decoder
+ *
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * copyright 	Jamal Hadi Salim (2015)
+ *
+*/
+
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/string.h>
+#include <linux/errno.h>
+#include <linux/skbuff.h>
+#include <linux/rtnetlink.h>
+#include <linux/module.h>
+#include <linux/init.h>
+#include <net/netlink.h>
+#include <net/pkt_sched.h>
+#include <uapi/linux/tc_act/tc_ife.h>
+#include <net/tc_act/tc_ife.h>
+
+int skbqmap_check(struct sk_buff *skb, struct tcf_meta_info *e)
+{
+	/*XXX: skb_get_queue_mapping()?*/
+	u32 ifeqmap = skb->queue_mapping;
+
+	if (e->metaval) {
+		ifeqmap = *(u32 *)e->metaval;
+	}
+
+	if (!ifeqmap)
+		return 0;
+	/* data + pad + LV = 2+2+4 */
+	return 8;
+}
+
+int skbqmap_encode(struct sk_buff *skb, void *skbdata, struct tcf_meta_info *e)
+{
+	/*(XXX: skb_get_queue_mapping()? */
+	u16 ifeqmap = skb->queue_mapping;
+
+	if (e->metaval) {
+		ifeqmap = *(u16 *)e->metaval;
+	}
+
+	if (!ifeqmap)
+		return 0;
+
+	ifeqmap = htons(ifeqmap);
+
+	return tlv_meta_encode(skbdata, e->metaid, 2, &ifeqmap);
+}
+
+int qmap_decode(struct sk_buff *skb, void *data, u16 len)
+{
+	u16 qm = *(u16 *) data;
+
+	skb->queue_mapping = ntohs(qm);
+	return 0;
+}
+
+static struct tcf_meta_ops ife_qmap_ops = {
+	.metaid = IFE_META_QMAP,
+	.metatype = NLA_U16,
+	.name = "skbqmap",
+	.synopsis = "skb queue map 16 bit metadata",
+	.check_presence = skbqmap_check,
+	.encode = skbqmap_encode,
+	.decode = qmap_decode,
+	.get = get_meta_u16,
+	.alloc = alloc_meta_u16,
+	.owner = THIS_MODULE,
+};
+
+static int __init ifeqmap_init_module(void)
+{
+	return register_ife_op(&ife_qmap_ops);
+}
+
+static void __exit ifeqmap_cleanup_module(void)
+{
+	unregister_ife_op(&ife_qmap_ops);
+}
+
+module_init(ifeqmap_init_module);
+module_exit(ifeqmap_cleanup_module);
+
+MODULE_AUTHOR("Jamal Hadi Salim(2015)");
+MODULE_DESCRIPTION("Inter-FE skb qmap metadata action");
+MODULE_LICENSE("GPL");
+MODULE_ALIAS_IFE_META(IFE_META_QMAP);
-- 
1.9.1

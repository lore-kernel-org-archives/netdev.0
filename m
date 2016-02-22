From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [net-next PATCH 4/5] Support to encoding decoding skb hashid on IFE action
Date: Mon, 22 Feb 2016 08:21:43 -0500
Message-ID: <1456147304-13355-5-git-send-email-jhs@emojatatu.com>
References: <1456147304-13355-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
	xiyou.wangcong@gmail.com, alexei.starovoitov@gmail.com,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f175.google.com ([209.85.223.175]:33892 "EHLO
	mail-io0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754934AbcBVNWD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2016 08:22:03 -0500
Received: by mail-io0-f175.google.com with SMTP id 9so177816007iom.1
        for <netdev@vger.kernel.org>; Mon, 22 Feb 2016 05:22:03 -0800 (PST)
In-Reply-To: <1456147304-13355-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

        Example usage:
        allow skb hash to be encoded as metadata

        sudo tc qdisc add dev $ETH root handle 1: prio
        sudo tc filter add dev $ETH parent 1: protocol ip prio 10 \
        u32 match ip protocol 1 0xff flowid 1:2 \
        action ife encode \
        allow hashid \
        dst 02:15:15:15:15:15

        Note: A zero skb hash will not be sent

        Alternative hard code static hashid of 11
        priority 16
        mark 33

        sudo $TC filter add dev $ETH parent 1: protocol ip prio 10 \
        u32 match ip protocol 1 0xff flowid 1:2 \
        action ife encode \
        type 0xDEAD \
	use hashid 11 \
        use prio 16 \
        use mark 33 \
        dst 02:15:15:15:15:15

        Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 net/sched/Kconfig            |  5 +++
 net/sched/Makefile           |  1 +
 net/sched/act_meta_skbhash.c | 87 ++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 93 insertions(+)
 create mode 100644 net/sched/act_meta_skbhash.c

diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index b148302..4c0c694 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -761,6 +761,11 @@ config NET_IFE_SKBPRIO
         depends on NET_ACT_IFE
         ---help---
 
+config NET_IFE_SKBHASH
+        tristate "Support to encoding decoding skb hashid on IFE action"
+        depends on NET_ACT_IFE
+        ---help---
+
 config NET_CLS_IND
 	bool "Incoming device classification"
 	depends on NET_CLS_U32 || NET_CLS_FW
diff --git a/net/sched/Makefile b/net/sched/Makefile
index 84bddb3..321a9bc 100644
--- a/net/sched/Makefile
+++ b/net/sched/Makefile
@@ -22,6 +22,7 @@ obj-$(CONFIG_NET_ACT_CONNMARK)	+= act_connmark.o
 obj-$(CONFIG_NET_ACT_IFE)	+= act_ife.o
 obj-$(CONFIG_NET_IFE_SKBMARK)	+= act_meta_mark.o
 obj-$(CONFIG_NET_IFE_SKBPRIO)	+= act_meta_skbprio.o
+obj-$(CONFIG_NET_IFE_SKBHASH)	+= act_meta_skbhash.o
 obj-$(CONFIG_NET_SCH_FIFO)	+= sch_fifo.o
 obj-$(CONFIG_NET_SCH_CBQ)	+= sch_cbq.o
 obj-$(CONFIG_NET_SCH_HTB)	+= sch_htb.o
diff --git a/net/sched/act_meta_skbhash.c b/net/sched/act_meta_skbhash.c
new file mode 100644
index 0000000..c3140ea
--- /dev/null
+++ b/net/sched/act_meta_skbhash.c
@@ -0,0 +1,87 @@
+/*
+ * net/sched/act_meta_skbhash.c IFE skb->hash metadata module
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
+static int skbhash_check(struct sk_buff *skb, struct tcf_meta_info *e)
+{
+	u32 skbhash = skb->hash;
+
+	if (e->metaval) {
+		skbhash = *(u32 *)e->metaval;
+	}
+	if (!skbhash)
+		return 0;
+
+	return 8;
+}
+
+static int skbhash_encode(struct sk_buff *skb, void *skbdata,
+			  struct tcf_meta_info *e)
+{
+	u32 skbhash = skb->hash;
+
+	return encode_meta_u32(skbhash, skbdata, e);
+}
+
+static int skbhash_decode(struct sk_buff *skb, void *data, u16 len)
+{
+	u32 skbhash = *(u32 *) data;
+
+	skb->hash = ntohl(skbhash);
+	return 0;
+}
+
+static struct tcf_meta_ops ife_skbhash_ops = {
+	.metaid = IFE_META_HASHID,
+	.metatype = NLA_U32,
+	.name = "skbhash",
+	.synopsis = "skb hash metadata",
+	.check_presence = skbhash_check,
+	.encode = skbhash_encode,
+	.decode = skbhash_decode,
+	.get = get_meta_u32,
+	.alloc = alloc_meta_u32,
+	.owner = THIS_MODULE,
+};
+
+static int __init ifeskbhash_init_module(void)
+{
+	pr_info("Loaded IFE skbhash\n");
+
+	return register_ife_op(&ife_skbhash_ops);
+}
+
+static void __exit ifeskbhash_cleanup_module(void)
+{
+	pr_info("Unloaded IFE skb hash\n");
+	unregister_ife_op(&ife_skbhash_ops);
+}
+
+module_init(ifeskbhash_init_module);
+module_exit(ifeskbhash_cleanup_module);
+
+MODULE_AUTHOR("Jamal Hadi Salim(2015)");
+MODULE_DESCRIPTION("Inter-FE skb hash meta action");
+MODULE_LICENSE("GPL");
+MODULE_ALIAS_IFE_META(IFE_META_HASHID);
-- 
1.9.1

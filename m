From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [net-next-2.6 PATCH v4 3/3] Support to encoding decoding skb prio on IFE action
Date: Sat, 27 Feb 2016 08:08:56 -0500
Message-ID: <1456578536-17732-4-git-send-email-jhs@emojatatu.com>
References: <1456578536-17732-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
	daniel@iogearbox.net, Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f195.google.com ([209.85.213.195]:36005 "EHLO
	mail-ig0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756603AbcB0NJT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Feb 2016 08:09:19 -0500
Received: by mail-ig0-f195.google.com with SMTP id xg9so5783889igb.3
        for <netdev@vger.kernel.org>; Sat, 27 Feb 2016 05:09:18 -0800 (PST)
In-Reply-To: <1456578536-17732-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

    Example usage:
    Set the skb priority using skbedit then allow it to be encoded

    sudo tc qdisc add dev $ETH root handle 1: prio
    sudo tc filter add dev $ETH parent 1: protocol ip prio 10 \
    u32 match ip protocol 1 0xff flowid 1:2 \
    action skbedit prio 17 \
    action ife encode \
    allow prio \
    dst 02:15:15:15:15:15

    Note: You dont need the skbedit action if you are already encoding the
    skb priority earlier. A zero skb priority will not be sent

    Alternative hard code static priority of decimal 33 (unlike skbedit)
    then mark of 0x12 every time the filter matches

    sudo $TC filter add dev $ETH parent 1: protocol ip prio 10 \
    u32 match ip protocol 1 0xff flowid 1:2 \
    action ife encode \
    type 0xDEAD \
    use prio 33 \
    use mark 0x12 \
    dst 02:15:15:15:15:15

    Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 net/sched/Kconfig            |  5 +++
 net/sched/Makefile           |  1 +
 net/sched/act_meta_skbprio.c | 76 ++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 82 insertions(+)
 create mode 100644 net/sched/act_meta_skbprio.c

diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index 85854c0..b148302 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -756,6 +756,11 @@ config NET_IFE_SKBMARK
         depends on NET_ACT_IFE
         ---help---
 
+config NET_IFE_SKBPRIO
+        tristate "Support to encoding decoding skb prio on IFE action"
+        depends on NET_ACT_IFE
+        ---help---
+
 config NET_CLS_IND
 	bool "Incoming device classification"
 	depends on NET_CLS_U32 || NET_CLS_FW
diff --git a/net/sched/Makefile b/net/sched/Makefile
index 3f7a182..84bddb3 100644
--- a/net/sched/Makefile
+++ b/net/sched/Makefile
@@ -21,6 +21,7 @@ obj-$(CONFIG_NET_ACT_BPF)	+= act_bpf.o
 obj-$(CONFIG_NET_ACT_CONNMARK)	+= act_connmark.o
 obj-$(CONFIG_NET_ACT_IFE)	+= act_ife.o
 obj-$(CONFIG_NET_IFE_SKBMARK)	+= act_meta_mark.o
+obj-$(CONFIG_NET_IFE_SKBPRIO)	+= act_meta_skbprio.o
 obj-$(CONFIG_NET_SCH_FIFO)	+= sch_fifo.o
 obj-$(CONFIG_NET_SCH_CBQ)	+= sch_cbq.o
 obj-$(CONFIG_NET_SCH_HTB)	+= sch_htb.o
diff --git a/net/sched/act_meta_skbprio.c b/net/sched/act_meta_skbprio.c
new file mode 100644
index 0000000..26bf4d8
--- /dev/null
+++ b/net/sched/act_meta_skbprio.c
@@ -0,0 +1,76 @@
+/*
+ * net/sched/act_meta_prio.c IFE skb->priority metadata module
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * copyright Jamal Hadi Salim (2015)
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
+static int skbprio_check(struct sk_buff *skb, struct tcf_meta_info *e)
+{
+	return ife_check_meta_u32(skb->priority, e);
+}
+
+static int skbprio_encode(struct sk_buff *skb, void *skbdata,
+			  struct tcf_meta_info *e)
+{
+	u32 ifeprio = skb->priority; /* avoid having to cast skb->priority*/
+
+	return ife_encode_meta_u32(ifeprio, skbdata, e);
+}
+
+static int skbprio_decode(struct sk_buff *skb, void *data, u16 len)
+{
+	u32 ifeprio = *(u32 *)data;
+
+	skb->priority = ntohl(ifeprio);
+	return 0;
+}
+
+static struct tcf_meta_ops ife_prio_ops = {
+	.metaid = IFE_META_PRIO,
+	.metatype = NLA_U32,
+	.name = "skbprio",
+	.synopsis = "skb prio metadata",
+	.check_presence = skbprio_check,
+	.encode = skbprio_encode,
+	.decode = skbprio_decode,
+	.get = ife_get_meta_u32,
+	.alloc = ife_alloc_meta_u32,
+	.owner = THIS_MODULE,
+};
+
+static int __init ifeprio_init_module(void)
+{
+	return register_ife_op(&ife_prio_ops);
+}
+
+static void __exit ifeprio_cleanup_module(void)
+{
+	unregister_ife_op(&ife_prio_ops);
+}
+
+module_init(ifeprio_init_module);
+module_exit(ifeprio_cleanup_module);
+
+MODULE_AUTHOR("Jamal Hadi Salim(2015)");
+MODULE_DESCRIPTION("Inter-FE skb prio metadata action");
+MODULE_LICENSE("GPL");
+MODULE_ALIAS_IFE_META(IFE_META_PRIO);
-- 
1.9.1

From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [net-next PATCH 2/5] Support to encoding decoding skb mark on IFE action
Date: Mon, 22 Feb 2016 08:21:41 -0500
Message-ID: <1456147304-13355-3-git-send-email-jhs@emojatatu.com>
References: <1456147304-13355-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
	xiyou.wangcong@gmail.com, alexei.starovoitov@gmail.com,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:38062 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754217AbcBVNWA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2016 08:22:00 -0500
Received: by mail-ig0-f174.google.com with SMTP id y8so79698199igp.1
        for <netdev@vger.kernel.org>; Mon, 22 Feb 2016 05:22:00 -0800 (PST)
In-Reply-To: <1456147304-13355-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

Example usage:
Set the skb using skbedit then allow it to be encoded

sudo tc qdisc add dev $ETH root handle 1: prio
sudo tc filter add dev $ETH parent 1: protocol ip prio 10 \
u32 match ip protocol 1 0xff flowid 1:2 \
action skbedit mark 17 \
action ife encode \
allow mark \
dst 02:15:15:15:15:15

Note: You dont need the skbedit action if you are already encoding the
skb mark earlier. A zero skb mark will not be allowed

Alternative hard code static mark of 0x12 every time the filter matches

sudo $TC filter add dev $ETH parent 1: protocol ip prio 10 \
u32 match ip protocol 1 0xff flowid 1:2 \
action ife encode \
type 0xDEAD \
use mark 0x12 \
dst 02:15:15:15:15:15

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 net/sched/Kconfig         |  5 +++
 net/sched/Makefile        |  1 +
 net/sched/act_meta_mark.c | 81 +++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 87 insertions(+)
 create mode 100644 net/sched/act_meta_mark.c

diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index 4d48ef5..85854c0 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -751,6 +751,11 @@ config NET_ACT_IFE
 	  To compile this code as a module, choose M here: the
 	  module will be called act_ife.
 
+config NET_IFE_SKBMARK
+        tristate "Support to encoding decoding skb mark on IFE action"
+        depends on NET_ACT_IFE
+        ---help---
+
 config NET_CLS_IND
 	bool "Incoming device classification"
 	depends on NET_CLS_U32 || NET_CLS_FW
diff --git a/net/sched/Makefile b/net/sched/Makefile
index 3d17667..3f7a182 100644
--- a/net/sched/Makefile
+++ b/net/sched/Makefile
@@ -20,6 +20,7 @@ obj-$(CONFIG_NET_ACT_VLAN)	+= act_vlan.o
 obj-$(CONFIG_NET_ACT_BPF)	+= act_bpf.o
 obj-$(CONFIG_NET_ACT_CONNMARK)	+= act_connmark.o
 obj-$(CONFIG_NET_ACT_IFE)	+= act_ife.o
+obj-$(CONFIG_NET_IFE_SKBMARK)	+= act_meta_mark.o
 obj-$(CONFIG_NET_SCH_FIFO)	+= sch_fifo.o
 obj-$(CONFIG_NET_SCH_CBQ)	+= sch_cbq.o
 obj-$(CONFIG_NET_SCH_HTB)	+= sch_htb.o
diff --git a/net/sched/act_meta_mark.c b/net/sched/act_meta_mark.c
new file mode 100644
index 0000000..f3e1a44
--- /dev/null
+++ b/net/sched/act_meta_mark.c
@@ -0,0 +1,81 @@
+/*
+ * net/sched/act_meta_mark.c IFE skb->mark metadata module
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
+#include <linux/rtnetlink.h>
+
+static int skbmark_encode(struct sk_buff *skb, void *skbdata,
+			  struct tcf_meta_info *e)
+{
+	u32 ifemark = skb->mark;
+
+	return encode_meta_u32(ifemark, skbdata, e);
+}
+
+static int skbmark_decode(struct sk_buff *skb, void *data, u16 len)
+{
+	u32 ifemark = *(u32 *) data;
+
+	skb->mark = ntohl(ifemark);
+	return 0;
+}
+
+static int skbmark_check(struct sk_buff *skb, struct tcf_meta_info *e)
+{
+	return check_meta_u32(skb->mark, e);
+}
+
+static struct tcf_meta_ops ife_skbmark_ops = {
+	.metaid = IFE_META_SKBMARK,
+	.metatype = NLA_U32,
+	.name = "skbmark",
+	.synopsis = "skb mark 32 bit metadata",
+	.check_presence = skbmark_check,
+	.encode = skbmark_encode,
+	.decode = skbmark_decode,
+	.get = get_meta_u32,
+	.alloc = alloc_meta_u32,
+	.release = release_meta_gen,
+	.validate = validate_meta_u32,
+	.owner = THIS_MODULE,
+};
+
+static int __init ifemark_init_module(void)
+{
+	pr_info("Loaded IFE skb MARK\n");
+	return register_ife_op(&ife_skbmark_ops);
+}
+
+static void __exit ifemark_cleanup_module(void)
+{
+	pr_info("Unloaded IFE MARK\n");
+	unregister_ife_op(&ife_skbmark_ops);
+}
+
+module_init(ifemark_init_module);
+module_exit(ifemark_cleanup_module);
+
+MODULE_AUTHOR("Jamal Hadi Salim(2015)");
+MODULE_DESCRIPTION("Inter-FE skb mark metadata module");
+MODULE_LICENSE("GPL");
+MODULE_ALIAS_IFE_META(IFE_META_SKBMARK);
-- 
1.9.1

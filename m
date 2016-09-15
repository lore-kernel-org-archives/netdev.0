From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH net-next 2/2] net sched ife action: Introduce skb tcindex metadata encap decap
Date: Thu, 15 Sep 2016 06:49:54 -0400
Message-ID: <1473936594-5152-2-git-send-email-jhs@emojatatu.com>
References: <1473936594-5152-1-git-send-email-jhs@emojatatu.com>
Cc: daniel@iogearbox.net, xiyou.wangcong@gmail.com,
        netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:34174 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755629AbcIOKuE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 06:50:04 -0400
Received: by mail-it0-f66.google.com with SMTP id 186so4135567itf.1
        for <netdev@vger.kernel.org>; Thu, 15 Sep 2016 03:50:04 -0700 (PDT)
In-Reply-To: <1473936594-5152-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

Sample use case of how this is encoded:
user space via tuntap (or a connected VM/Machine/container)
encodes the tcindex TLV.

Sample use case of decoding:
IFE action decodes it and the skb->tc_index is then used to classify.
So something like this for encoded ICMP packets:

.. first decode then reclassify... skb->tcindex will be set
sudo $TC filter add dev $ETH parent ffff: prio 2 protocol 0xbeef \
u32 match u32 0 0 flowid 1:1 \
action ife decode reclassify

...next match the decode icmp packet...
sudo $TC filter add dev $ETH parent ffff: prio 4 protocol ip \
u32 match ip protocol 1 0xff flowid 1:1 \
action continue
... last classify it using the tcindex classifier and do someaction..
sudo $TC filter add dev $ETH parent ffff: prio 5 protocol ip \
handle 0x11 tcindex classid 1:1 \
action blah..

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 include/uapi/linux/tc_act/tc_ife.h |  3 +-
 net/sched/Kconfig                  |  5 +++
 net/sched/Makefile                 |  1 +
 net/sched/act_meta_skbtcindex.c    | 81 ++++++++++++++++++++++++++++++++++++++
 4 files changed, 89 insertions(+), 1 deletion(-)
 create mode 100644 net/sched/act_meta_skbtcindex.c

diff --git a/include/uapi/linux/tc_act/tc_ife.h b/include/uapi/linux/tc_act/tc_ife.h
index 4ece02a..cd18360 100644
--- a/include/uapi/linux/tc_act/tc_ife.h
+++ b/include/uapi/linux/tc_act/tc_ife.h
@@ -32,8 +32,9 @@ enum {
 #define IFE_META_HASHID 2
 #define	IFE_META_PRIO 3
 #define	IFE_META_QMAP 4
+#define	IFE_META_TCINDEX 5
 /*Can be overridden at runtime by module option*/
-#define	__IFE_META_MAX 5
+#define	__IFE_META_MAX 6
 #define IFE_META_MAX (__IFE_META_MAX - 1)
 
 #endif
diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index 7795d5a..87956a7 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -793,6 +793,11 @@ config NET_IFE_SKBPRIO
         depends on NET_ACT_IFE
         ---help---
 
+config NET_IFE_SKBTCINDEX
+        tristate "Support to encoding decoding skb tcindex on IFE action"
+        depends on NET_ACT_IFE
+        ---help---
+
 config NET_CLS_IND
 	bool "Incoming device classification"
 	depends on NET_CLS_U32 || NET_CLS_FW
diff --git a/net/sched/Makefile b/net/sched/Makefile
index 148ae0d..4bdda36 100644
--- a/net/sched/Makefile
+++ b/net/sched/Makefile
@@ -23,6 +23,7 @@ obj-$(CONFIG_NET_ACT_SKBMOD)	+= act_skbmod.o
 obj-$(CONFIG_NET_ACT_IFE)	+= act_ife.o
 obj-$(CONFIG_NET_IFE_SKBMARK)	+= act_meta_mark.o
 obj-$(CONFIG_NET_IFE_SKBPRIO)	+= act_meta_skbprio.o
+obj-$(CONFIG_NET_IFE_SKBTCINDEX)	+= act_meta_skbtcindex.o
 obj-$(CONFIG_NET_ACT_TUNNEL_KEY)+= act_tunnel_key.o
 obj-$(CONFIG_NET_SCH_FIFO)	+= sch_fifo.o
 obj-$(CONFIG_NET_SCH_CBQ)	+= sch_cbq.o
diff --git a/net/sched/act_meta_skbtcindex.c b/net/sched/act_meta_skbtcindex.c
new file mode 100644
index 0000000..ec43327
--- /dev/null
+++ b/net/sched/act_meta_skbtcindex.c
@@ -0,0 +1,81 @@
+/*
+ * net/sched/act_meta_tc_index.c IFE skb->tc_index metadata module
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * copyright Jamal Hadi Salim (2016)
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
+static int skbtcindex_encode(struct sk_buff *skb, void *skbdata,
+			     struct tcf_meta_info *e)
+{
+	u32 ifetc_index = skb->tc_index;
+
+	return ife_encode_meta_u16(ifetc_index, skbdata, e);
+}
+
+static int skbtcindex_decode(struct sk_buff *skb, void *data, u16 len)
+{
+	u16 ifetc_index = *(u16 *)data;
+
+	skb->tc_index = ntohs(ifetc_index);
+	return 0;
+}
+
+static int skbtcindex_check(struct sk_buff *skb, struct tcf_meta_info *e)
+{
+	return ife_check_meta_u16(skb->tc_index, e);
+}
+
+static struct tcf_meta_ops ife_skbtcindex_ops = {
+	.metaid = IFE_META_TCINDEX,
+	.metatype = NLA_U16,
+	.name = "tc_index",
+	.synopsis = "skb tc_index 16 bit metadata",
+	.check_presence = skbtcindex_check,
+	.encode = skbtcindex_encode,
+	.decode = skbtcindex_decode,
+	.get = ife_get_meta_u16,
+	.alloc = ife_alloc_meta_u16,
+	.release = ife_release_meta_gen,
+	.validate = ife_validate_meta_u16,
+	.owner = THIS_MODULE,
+};
+
+static int __init ifetc_index_init_module(void)
+{
+	pr_emerg("Loaded IFE tc_index\n");
+	return register_ife_op(&ife_skbtcindex_ops);
+}
+
+static void __exit ifetc_index_cleanup_module(void)
+{
+	pr_emerg("Unloaded IFE tc_index\n");
+	unregister_ife_op(&ife_skbtcindex_ops);
+}
+
+module_init(ifetc_index_init_module);
+module_exit(ifetc_index_cleanup_module);
+
+MODULE_AUTHOR("Jamal Hadi Salim(2016)");
+MODULE_DESCRIPTION("Inter-FE skb tc_index metadata module");
+MODULE_LICENSE("GPL");
+MODULE_ALIAS_IFE_META(IFE_META_SKBTCINDEX);
-- 
1.9.1

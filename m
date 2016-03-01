From: Brian Russell <brussell@brocade.com>
Subject: [PATCH net-next v3 3/3] nsh: netfilter target
Date: Tue, 1 Mar 2016 11:11:49 +0000
Message-ID: <1456830709-32052-4-git-send-email-brussell@brocade.com>
References: <1456830709-32052-1-git-send-email-brussell@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:17026 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752628AbcCALMJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 06:12:09 -0500
Received: from pps.filterd (m0048192.ppops.net [127.0.0.1])
	by mx0b-000f0801.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id u21B3Woq025326
	for <netdev@vger.kernel.org>; Tue, 1 Mar 2016 03:12:09 -0800
Received: from brmwp-exmb12.corp.brocade.com ([208.47.132.227])
	by mx0b-000f0801.pphosted.com with ESMTP id 21bbyayhth-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 01 Mar 2016 03:12:09 -0800
In-Reply-To: <1456830709-32052-1-git-send-email-brussell@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add an NSH netfilter target, to add NSH encap'd metadata to outgoing
packets.

Signed-off-by: Brian Russell <brussell@brocade.com>
---
 include/uapi/linux/netfilter/xt_NSH.h | 25 +++++++++
 net/netfilter/Kconfig                 |  9 ++++
 net/netfilter/Makefile                |  1 +
 net/netfilter/xt_NSH.c                | 95 +++++++++++++++++++++++++++++++++++
 4 files changed, 130 insertions(+)
 create mode 100644 include/uapi/linux/netfilter/xt_NSH.h
 create mode 100644 net/netfilter/xt_NSH.c

diff --git a/include/uapi/linux/netfilter/xt_NSH.h b/include/uapi/linux/netfilter/xt_NSH.h
new file mode 100644
index 0000000..82b76f6
--- /dev/null
+++ b/include/uapi/linux/netfilter/xt_NSH.h
@@ -0,0 +1,25 @@
+/* Header file for NSH target extension for xtables.
+ *
+ * Copyright (c) 2016 by Brocade Communications Systems, Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+#ifndef _XT_NSH_H
+#define _XT_NSH_H
+
+struct xt_nsh_info {
+	__u32 service_path_id;
+	__u8 service_index;
+	__u8 metadata_type;
+	__u16 t2_class;
+	__u8 t2_type;
+	__u8 t2_len;
+	__u32 value1;
+	__u32 value2;
+	__u32 value3;
+	__u32 value4;
+};
+
+#endif /* _XT_NSH_H */
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 95e757c..6349d56 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -863,6 +863,15 @@ config NETFILTER_XT_TARGET_NOTRACK
 	depends on NETFILTER_ADVANCED
 	select NETFILTER_XT_TARGET_CT
 
+config NETFILTER_XT_TARGET_NSH
+       tristate '"NSH" target support'
+       depends on NETFILTER_ADVANCED
+       help
+         This options adds a `NSH' target, which allows to add NSH metadata
+	 to outgoing packets.
+
+         To compile it as a module, choose M here.  If unsure, say N.
+
 config NETFILTER_XT_TARGET_RATEEST
 	tristate '"RATEEST" target support'
 	depends on NETFILTER_ADVANCED
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 6913454..59ea6f6 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -120,6 +120,7 @@ obj-$(CONFIG_NETFILTER_XT_TARGET_LOG) += xt_LOG.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_NETMAP) += xt_NETMAP.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_NFLOG) += xt_NFLOG.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_NFQUEUE) += xt_NFQUEUE.o
+obj-$(CONFIG_NETFILTER_XT_TARGET_NSH) += xt_NSH.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_RATEEST) += xt_RATEEST.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_REDIRECT) += xt_REDIRECT.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_SECMARK) += xt_SECMARK.o
diff --git a/net/netfilter/xt_NSH.c b/net/netfilter/xt_NSH.c
new file mode 100644
index 0000000..b1c930c
--- /dev/null
+++ b/net/netfilter/xt_NSH.c
@@ -0,0 +1,95 @@
+/* Network Service Header (NSH) target extension for xtables.
+ *
+ * Copyright (c) 2016 by Brocade Communications Systems, Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+#include <linux/module.h>
+#include <linux/netfilter.h>
+#include <linux/skbuff.h>
+#include <linux/notifier.h>
+#include <linux/netfilter/x_tables.h>
+#include <uapi/linux/netfilter/xt_NSH.h>
+#include <net/nsh.h>
+
+static unsigned int nsh_tg(struct sk_buff *skb,
+			   const struct xt_action_param *par)
+{
+	const struct xt_nsh_info *info = par->targinfo;
+	struct nsh_metadata ctx_hdr;
+	u32 data[4];
+	int err;
+
+	skb->protocol = htons(ETH_P_NSH);
+
+	if (info->metadata_type == NSH_MD_TYPE_1) {
+		ctx_hdr.class = NSH_MD_CLASS_TYPE_1;
+		ctx_hdr.type = NSH_MD_TYPE_TYPE_1;
+		ctx_hdr.len = NSH_MD_LEN_TYPE_1;
+	} else {
+		ctx_hdr.class = info->t2_class;
+		ctx_hdr.type = info->t2_type;
+		ctx_hdr.len = info->t2_len;
+	}
+
+	data[0] = info->value1;
+	data[1] = info->value2;
+	data[2] = info->value3;
+	data[3] = info->value4;
+
+	ctx_hdr.data = &data;
+	ctx_hdr.crit = 1;
+
+	err = nsh_encap(skb, info->service_path_id, info->service_index,
+			NSH_NEXT_PROTO_IPv4, 1, &ctx_hdr);
+	if (err < 0)
+		return NF_DROP;
+
+	return NF_ACCEPT;
+}
+
+static int nsh_tg_check(const struct xt_tgchk_param *par)
+{
+	struct xt_nsh_info *info = par->targinfo;
+
+	if (info->metadata_type != NSH_MD_TYPE_1 &&
+	    info->metadata_type != NSH_MD_TYPE_2)
+		return -EINVAL;
+	if (info->service_path_id >= NSH_N_SPI)
+		return -EINVAL;
+	if (info->metadata_type == NSH_MD_TYPE_2 &&
+	    (info->t2_len > 4 || info->t2_class == NSH_MD_CLASS_TYPE_1))
+		return -EINVAL;
+	return 0;
+}
+
+static struct xt_target nsh_tg_reg[] __read_mostly = {
+	{
+		.name     = "NSH",
+		.revision = 0,
+		.family   = NFPROTO_IPV4,
+		.target   = nsh_tg,
+		.targetsize = sizeof(struct xt_nsh_info),
+		.checkentry = nsh_tg_check,
+		.me       = THIS_MODULE,
+	},
+};
+
+static int __init nsh_tg_init(void)
+{
+	return xt_register_targets(nsh_tg_reg, ARRAY_SIZE(nsh_tg_reg));
+}
+
+static void __exit nsh_tg_exit(void)
+{
+	xt_unregister_targets(nsh_tg_reg, ARRAY_SIZE(nsh_tg_reg));
+}
+
+module_init(nsh_tg_init);
+module_exit(nsh_tg_exit);
+MODULE_AUTHOR("Brian Russell <brussell@brocade.com>");
+MODULE_DESCRIPTION("Xtables: Add NSH metadata");
+MODULE_LICENSE("GPL");
+MODULE_ALIAS("ipt_NSH");
-- 
2.1.4

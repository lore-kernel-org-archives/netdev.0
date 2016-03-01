From: Brian Russell <brussell@brocade.com>
Subject: [PATCH net-next v3 2/3] nsh: logging module
Date: Tue, 1 Mar 2016 11:11:48 +0000
Message-ID: <1456830709-32052-3-git-send-email-brussell@brocade.com>
References: <1456830709-32052-1-git-send-email-brussell@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:34279 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752680AbcCALMH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 06:12:07 -0500
Received: from pps.filterd (m0000700.ppops.net [127.0.0.1])
	by mx0b-000f0801.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id u21B5w3G029033
	for <netdev@vger.kernel.org>; Tue, 1 Mar 2016 03:12:06 -0800
Received: from brmwp-exmb11.corp.brocade.com ([208.47.132.227])
	by mx0b-000f0801.pphosted.com with ESMTP id 21baa5frhx-4
	(version=TLSv1/SSLv3 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 01 Mar 2016 03:12:06 -0800
In-Reply-To: <1456830709-32052-1-git-send-email-brussell@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Module can register for Type 1 or specified classes of Type 2 metadata
and will then log incoming matching packets.

Signed-off-by: Brian Russell <brussell@brocade.com>
---
 net/ipv4/Kconfig   |   8 ++++
 net/ipv4/Makefile  |   1 +
 net/ipv4/nsh_log.c | 135 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 144 insertions(+)
 create mode 100644 net/ipv4/nsh_log.c

diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index df14c59..87b6dde 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -223,6 +223,14 @@ config NET_NSH
 
           To compile it as a module, choose M here.  If unsure, say N.
 
+config NET_NSH_LOG
+        tristate 'NSH Metadata Logger'
+	depends on NET_NSH
+	help
+          Log packets with incoming NSH metadata.
+
+          To compile it as a module, choose M here.  If unsure, say N.
+
 config IP_MROUTE
 	bool "IP: multicast routing"
 	depends on IP_MULTICAST
diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
index 14b7995..69377fb 100644
--- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -25,6 +25,7 @@ obj-$(CONFIG_NET_FOU) += fou.o
 obj-$(CONFIG_NET_IPGRE_DEMUX) += gre.o
 obj-$(CONFIG_NET_IPGRE) += ip_gre.o
 obj-$(CONFIG_NET_NSH) += nsh.o
+obj-$(CONFIG_NET_NSH_LOG) += nsh_log.o
 obj-$(CONFIG_NET_UDP_TUNNEL) += udp_tunnel.o
 obj-$(CONFIG_NET_IPVTI) += ip_vti.o
 obj-$(CONFIG_SYN_COOKIES) += syncookies.o
diff --git a/net/ipv4/nsh_log.c b/net/ipv4/nsh_log.c
new file mode 100644
index 0000000..3d774ed
--- /dev/null
+++ b/net/ipv4/nsh_log.c
@@ -0,0 +1,135 @@
+/*
+ * Network Service Header (NSH) logging module.
+ *
+ * Copyright (c) 2016 by Brocade Communications Systems, Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+#include <linux/module.h>
+#include <linux/netdevice.h>
+#include <net/nsh.h>
+
+static bool t1_enabled = false;
+module_param(t1_enabled, bool, 0444);
+MODULE_PARM_DESC(t1_enabled, "Type 1 Metadata log enabled");
+
+#define MAX_T2_CLASSES 10
+static unsigned int t2_classes[MAX_T2_CLASSES];
+static int num_t2 = 0;
+module_param_array(t2_classes, uint, &num_t2, 0444);
+MODULE_PARM_DESC(t2_classes, "Type 2 Metadata classes log enabled");
+
+static const char *nsh_next_proto(u8 next_proto)
+{
+	switch (next_proto) {
+	case NSH_NEXT_PROTO_IPv4:
+		return "IPv4";
+	case NSH_NEXT_PROTO_IPv6:
+		return "IPv6";
+	case NSH_NEXT_PROTO_ETH:
+		return "Eth";
+	default:
+		return "Unknown";
+	}
+}
+
+/* Type 1 metadata has fixed length, 4 x 32-bit words */
+static int nsh_log_t1(struct sk_buff *skb, u32 service_path_id,
+		      u8 service_index, u8 next_proto,
+		      struct nsh_metadata *ctx_hdr, unsigned int num_ctx_hdrs)
+{
+	u32 *data;
+
+	if ((ctx_hdr->class != NSH_MD_CLASS_TYPE_1) ||
+	    (ctx_hdr->type != NSH_MD_TYPE_TYPE_1) ||
+	    (ctx_hdr->len != NSH_MD_LEN_TYPE_1) ||
+	    (num_ctx_hdrs != 1))
+		return -EINVAL;
+
+	data = ctx_hdr->data;
+	pr_info("NSH T1 Rx(%s): SPI=%u SI=%u Next=%s"
+		" MD 0x%08x 0x%08x 0x%08x 0x%08x\n", skb->dev->name,
+		service_path_id, service_index, nsh_next_proto(next_proto),
+		data[0], data[1], data[2], data[3]);
+
+	return 0;
+}
+
+/* Type 2 metadata consists of a variable number of TLVs */
+#define T2_BUFSIZE 512
+static int nsh_log_t2(struct sk_buff *skb, u32 service_path_id,
+		      u8 service_index, u8 next_proto,
+		      struct nsh_metadata *ctx_hdrs, unsigned int num_ctx_hdrs)
+{
+	char t2_buf[T2_BUFSIZE];
+	int wrlen;
+	u32 *data;
+	int i,j;
+
+	wrlen = snprintf(t2_buf, T2_BUFSIZE,
+			 "NSH T2 Class %u Rx(%s): SPI=%u SI=%u Next=%s MD",
+			 ctx_hdrs[0].class, skb->dev->name, service_path_id,
+			 service_index, nsh_next_proto(next_proto));
+
+	for (i = 0; i < num_ctx_hdrs; i++) {
+		wrlen += snprintf(t2_buf+wrlen, T2_BUFSIZE-wrlen,
+				  " TLV%d Type=%u Len=%u", i+1,
+				  ctx_hdrs[i].type, ctx_hdrs[i].len);
+		data = ctx_hdrs[i].data;
+		for (j = 0; j < ctx_hdrs[i].len; j++)
+			wrlen += snprintf(t2_buf+wrlen, T2_BUFSIZE-wrlen,
+					  " 0x%08x", data[j]);
+	}
+	pr_info("%s\n", t2_buf);
+	return 0;
+}
+
+static struct nsh_listener nsh_log_t1_entry = {
+	.class = NSH_MD_CLASS_TYPE_1,
+	.notify = nsh_log_t1,
+};
+
+static struct nsh_listener nsh_log_t2_entry[MAX_T2_CLASSES];
+
+static int __init nsh_log_init(void)
+{
+	int i, err;
+
+	if (t1_enabled) {
+		err = nsh_register_listener(&nsh_log_t1_entry);
+
+		if (err)
+			return err;
+	}
+
+	for (i = 0; i < num_t2; i++) {
+		nsh_log_t2_entry[i].class = t2_classes[i];
+		nsh_log_t2_entry[i].notify = nsh_log_t2;
+
+		err = nsh_register_listener(&nsh_log_t2_entry[i]);
+
+		if (err)
+			return err;
+	}
+	return 0;
+}
+
+static void __exit nsh_log_exit(void)
+{
+	int i;
+
+	if (t1_enabled)
+		nsh_unregister_listener(&nsh_log_t1_entry);
+
+	for (i = 0; i < num_t2; i++)
+		nsh_unregister_listener(&nsh_log_t2_entry[i]);
+}
+
+module_init(nsh_log_init);
+module_exit(nsh_log_exit);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Brian Russell <brussell@brocade.com>");
+MODULE_DESCRIPTION("NSH Metadata logger");
-- 
2.1.4

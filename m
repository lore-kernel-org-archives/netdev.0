From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH] extensions: add SYNPROXY extension
Date: Tue, 27 Aug 2013 08:58:09 +0200
Message-ID: <1377586689-8119-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	mph@one.com, jesper.brouer@gmail.com, as@one.com
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58826 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752057Ab3H0G6M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 02:58:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 extensions/libxt_SYNPROXY.c           | 127 ++++++++++++++++++++++++++++++++++
 include/linux/netfilter/xt_SYNPROXY.h |  16 +++++
 2 files changed, 143 insertions(+)
 create mode 100644 extensions/libxt_SYNPROXY.c
 create mode 100644 include/linux/netfilter/xt_SYNPROXY.h

diff --git a/extensions/libxt_SYNPROXY.c b/extensions/libxt_SYNPROXY.c
new file mode 100644
index 0000000..475590e
--- /dev/null
+++ b/extensions/libxt_SYNPROXY.c
@@ -0,0 +1,127 @@
+
+/*
+ * Copyright (c) 2013 Patrick McHardy <kaber@trash.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <stdbool.h>
+#include <stdio.h>
+#include <xtables.h>
+#include <linux/netfilter/xt_SYNPROXY.h>
+
+enum {
+	O_SACK_PERM = 0,
+	O_TIMESTAMP,
+	O_WSCALE,
+	O_MSS,
+	O_ECN,
+};
+
+static void SYNPROXY_help(void)
+{
+	printf(
+"SYNPROXY target options:\n"
+"  --sack-perm                        Set SACK_PERM\n"
+"  --timestamp                        Set TIMESTAMP\n"
+"  --wscale value                     Set window scaling factor\n"
+"  --mss value                        Set MSS value\n"
+"  --ecn                              Set ECN\n");
+}
+
+static const struct xt_option_entry SYNPROXY_opts[] = {
+	{.name = "sack-perm", .id = O_SACK_PERM, .type = XTTYPE_NONE, },
+	{.name = "timestamp", .id = O_TIMESTAMP, .type = XTTYPE_NONE, },
+	{.name = "wscale",    .id = O_WSCALE,    .type = XTTYPE_UINT32, },
+	{.name = "mss",       .id = O_MSS,       .type = XTTYPE_UINT32, },
+	{.name = "ecn",       .id = O_ECN,	 .type = XTTYPE_NONE, },
+	XTOPT_TABLEEND,
+};
+
+static void SYNPROXY_parse(struct xt_option_call *cb)
+{
+	struct xt_synproxy_info *info = cb->data;
+
+	xtables_option_parse(cb);
+	switch (cb->entry->id) {
+	case O_SACK_PERM:
+		info->options |= XT_SYNPROXY_OPT_SACK_PERM;
+		break;
+	case O_TIMESTAMP:
+		info->options |= XT_SYNPROXY_OPT_TIMESTAMP;
+		break;
+	case O_WSCALE:
+		info->options |= XT_SYNPROXY_OPT_WSCALE;
+		info->wscale = cb->val.u32;
+		break;
+	case O_MSS:
+		info->options |= XT_SYNPROXY_OPT_MSS;
+		info->mss = cb->val.u32;
+		break;
+	case O_ECN:
+		info->options |= XT_SYNPROXY_OPT_ECN;
+		break;
+	}
+}
+
+static void SYNPROXY_check(struct xt_fcheck_call *cb)
+{
+}
+
+static void SYNPROXY_print(const void *ip, const struct xt_entry_target *target,
+                           int numeric)
+{
+	const struct xt_synproxy_info *info =
+		(const struct xt_synproxy_info *)target->data;
+
+	printf(" SYNPROXY ");
+	if (info->options & XT_SYNPROXY_OPT_SACK_PERM)
+		printf("sack-perm ");
+	if (info->options & XT_SYNPROXY_OPT_TIMESTAMP)
+		printf("timestamp ");
+	if (info->options & XT_SYNPROXY_OPT_WSCALE)
+		printf("wscale %u ", info->wscale);
+	if (info->options & XT_SYNPROXY_OPT_MSS)
+		printf("mss %u ", info->mss);
+	if (info->options & XT_SYNPROXY_OPT_ECN)
+		printf("ecn ");
+}
+
+static void SYNPROXY_save(const void *ip, const struct xt_entry_target *target)
+{
+	const struct xt_synproxy_info *info =
+		(const struct xt_synproxy_info *)target->data;
+
+	if (info->options & XT_SYNPROXY_OPT_SACK_PERM)
+		printf(" --sack-perm");
+	if (info->options & XT_SYNPROXY_OPT_TIMESTAMP)
+		printf(" --timestamp");
+	if (info->options & XT_SYNPROXY_OPT_WSCALE)
+		printf(" --wscale %u", info->wscale);
+	if (info->options & XT_SYNPROXY_OPT_MSS)
+		printf(" --mss %u", info->mss);
+	if (info->options & XT_SYNPROXY_OPT_ECN)
+		printf(" --ecn");
+}
+
+static struct xtables_target synproxy_tg_reg = {
+	.family        = NFPROTO_UNSPEC,
+	.name          = "SYNPROXY",
+	.version       = XTABLES_VERSION,
+	.revision      = 0,
+	.size          = XT_ALIGN(sizeof(struct xt_synproxy_info)),
+	.userspacesize = XT_ALIGN(sizeof(struct xt_synproxy_info)),
+	.help          = SYNPROXY_help,
+	.print         = SYNPROXY_print,
+	.save          = SYNPROXY_save,
+	.x6_parse      = SYNPROXY_parse,
+	.x6_fcheck     = SYNPROXY_check,
+	.x6_options    = SYNPROXY_opts,
+};
+
+void _init(void)
+{
+	xtables_register_target(&synproxy_tg_reg);
+}
diff --git a/include/linux/netfilter/xt_SYNPROXY.h b/include/linux/netfilter/xt_SYNPROXY.h
new file mode 100644
index 0000000..2d59fba
--- /dev/null
+++ b/include/linux/netfilter/xt_SYNPROXY.h
@@ -0,0 +1,16 @@
+#ifndef _XT_SYNPROXY_H
+#define _XT_SYNPROXY_H
+
+#define XT_SYNPROXY_OPT_MSS		0x01
+#define XT_SYNPROXY_OPT_WSCALE		0x02
+#define XT_SYNPROXY_OPT_SACK_PERM	0x04
+#define XT_SYNPROXY_OPT_TIMESTAMP	0x08
+#define XT_SYNPROXY_OPT_ECN		0x10
+
+struct xt_synproxy_info {
+	__u8	options;
+	__u8	wscale;
+	__u16	mss;
+};
+
+#endif /* _XT_SYNPROXY_H */
-- 
1.8.1.4

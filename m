From: Eldad Zack <eldad@fogrefinery.com>
Subject: [PATCH 3/8] LLDP: Sysctl interface
Date: Mon, 25 Jun 2012 20:28:15 +0200
Message-ID: <1340648900-6547-4-git-send-email-eldad@fogrefinery.com>
References: <1340648900-6547-1-git-send-email-eldad@fogrefinery.com>
Cc: Eldad Zack <eldad@fogrefinery.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f174.google.com ([209.85.161.174]:56156 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755772Ab2FYS2o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 14:28:44 -0400
Received: by gglu4 with SMTP id u4so3093894ggl.19
        for <netdev@vger.kernel.org>; Mon, 25 Jun 2012 11:28:43 -0700 (PDT)
In-Reply-To: <1340648900-6547-1-git-send-email-eldad@fogrefinery.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add 3 config items to LLDP via sysctl:
* Operational mode
* Message transmission interval
* Hold multiplier

Signed-off-by: Eldad Zack <eldad@fogrefinery.com>
---
 net/lldp/sysctl_net_lldp.c |   94 ++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 94 insertions(+)
 create mode 100644 net/lldp/sysctl_net_lldp.c

diff --git a/net/lldp/sysctl_net_lldp.c b/net/lldp/sysctl_net_lldp.c
new file mode 100644
index 0000000..dd5f5e3
--- /dev/null
+++ b/net/lldp/sysctl_net_lldp.c
@@ -0,0 +1,94 @@
+/* LLDP		Link Layer Discovery Protocol impementation for Linux
+ *		IEEE Std 802.1ab
+ *
+ * Author:	Eldad Zack <eldad@fogrefinery.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+
+#include <linux/sysctl.h>
+#include <linux/skbuff.h>
+#include <linux/socket.h>
+#include <linux/netdevice.h>
+#include <linux/init.h>
+#include "lldp.h"
+
+static int lldp_ttl_min = 1;
+static int lldp_ttl_max = 65535;
+
+/* Validate: (10.5.3, 10.5.4.1)
+ * 0 < transmit_interval * hold_multiplier <= 65535
+ */
+static int proc_dointvec_lldp_validate_ttl(ctl_table *table, int write,
+					void __user *buffer,
+					size_t *lenp, loff_t *ppos)
+{
+	int val, val2, ttl, ret;
+
+	ctl_table tmp = {
+		.data =		&val,
+		.maxlen =	sizeof(int),
+		.mode =		table->mode,
+		.extra1 =	&lldp_ttl_min,
+		.extra2 =	&lldp_ttl_max,
+	};
+
+	if (!write)
+		return proc_dointvec(table, write, buffer, lenp, ppos);
+
+	ret = proc_dointvec_minmax(&tmp, write, buffer, lenp, ppos);
+	if (ret == 0) {
+		val2 = *((int *)table->extra1);
+		ttl = val * val2;
+
+		if ((ttl >= lldp_ttl_min) && (ttl <= lldp_ttl_max))
+			*((int *)table->data) = val;
+		else
+			return -EINVAL;
+	}
+
+	return ret;
+}
+
+static struct ctl_table_header *lldp_table_header;
+
+static struct ctl_table lldp_table[] = {
+	{
+		.procname =	"lldp_op_mode",
+		.data =		&sysctl_lldp_operational_mode,
+		.maxlen =	sizeof(int),
+		.mode =		0644,
+		.proc_handler =	proc_dointvec,
+	},
+	{
+		.procname =	"transmit_interval",
+		.data =		&sysctl_lldp_transmit_interval,
+		.maxlen =	sizeof(int),
+		.mode =		0644,
+		.proc_handler =	proc_dointvec_lldp_validate_ttl,
+		.extra1 =	&sysctl_lldp_hold_multiplier,
+	},
+	{
+		.procname =	"hold_multiplier",
+		.data =		&sysctl_lldp_hold_multiplier,
+		.maxlen =	sizeof(int),
+		.mode =		0644,
+		.proc_handler =	proc_dointvec_lldp_validate_ttl,
+		.extra1 =	&sysctl_lldp_transmit_interval,
+	},
+	{ 0, },
+};
+
+void __init lldp_register_sysctl(void)
+{
+	lldp_table_header = register_net_sysctl(&init_net, "net/lldp",
+		lldp_table);
+}
+
+void __exit lldp_unregister_sysctl(void)
+{
+	unregister_net_sysctl_table(lldp_table_header);
+}
-- 
1.7.10

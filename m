From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 08/21] RDS: sysctls
Date: Mon, 26 Jan 2009 18:17:45 -0800
Message-ID: <1233022678-9259-9-git-send-email-andy.grover@oracle.com>
References: <1233022678-9259-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com, general@lists.openfabrics.org,
	netdev@vger.kernel.org
To: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:19587 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753544AbZA0CS1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2009 21:18:27 -0500
In-Reply-To: <1233022678-9259-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In addition to some tunable parameters, we also make protocol #
available here, since until accepted in upstream we do not have
a fixed number assigned. This can be removed once upstream.

Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 drivers/infiniband/ulp/rds/sysctl.c |  164 +++++++++++++++++++++++++++++++++++
 1 files changed, 164 insertions(+), 0 deletions(-)
 create mode 100644 drivers/infiniband/ulp/rds/sysctl.c

diff --git a/drivers/infiniband/ulp/rds/sysctl.c b/drivers/infiniband/ulp/rds/sysctl.c
new file mode 100644
index 0000000..3337a3e
--- /dev/null
+++ b/drivers/infiniband/ulp/rds/sysctl.c
@@ -0,0 +1,164 @@
+/*
+ * Copyright (c) 2006 Oracle.  All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ *
+ */
+#include <linux/kernel.h>
+#include <linux/sysctl.h>
+#include <linux/proc_fs.h>
+
+#include "rds.h"
+
+static struct ctl_table_header *rds_sysctl_reg_table;
+
+static unsigned long rds_sysctl_reconnect_min = 1;
+static unsigned long rds_sysctl_reconnect_max = ~0UL;
+
+unsigned long rds_sysctl_reconnect_min_jiffies;
+unsigned long rds_sysctl_reconnect_max_jiffies = HZ;
+
+unsigned int  rds_sysctl_max_unacked_packets = 8;
+unsigned int  rds_sysctl_max_unacked_bytes = (16 << 20);
+
+unsigned int rds_sysctl_ping_enable = 1;
+
+unsigned long rds_sysctl_trace_flags = 0;
+unsigned int  rds_sysctl_trace_level = 0;
+
+/* 
+ * These can change over time until they're official.  Until that time we'll
+ * give apps a way to figure out what the values are in a given machine.
+ */
+static int rds_sysctl_pf_rds = PF_RDS;
+static int rds_sysctl_sol_rds = SOL_RDS;
+
+static ctl_table rds_sysctl_rds_table[] = {
+	{
+		.ctl_name       = CTL_UNNUMBERED,
+		.procname       = "reconnect_min_delay_ms",
+		.data		= &rds_sysctl_reconnect_min_jiffies,
+		.maxlen         = sizeof(unsigned long),
+		.mode           = 0644,
+		.proc_handler   = &proc_doulongvec_ms_jiffies_minmax,
+		.extra1		= &rds_sysctl_reconnect_min,
+		.extra2		= &rds_sysctl_reconnect_max_jiffies,
+	},
+	{
+		.ctl_name       = CTL_UNNUMBERED,
+		.procname       = "reconnect_max_delay_ms",
+		.data		= &rds_sysctl_reconnect_max_jiffies,
+		.maxlen         = sizeof(unsigned long),
+		.mode           = 0644,
+		.proc_handler   = &proc_doulongvec_ms_jiffies_minmax,
+		.extra1		= &rds_sysctl_reconnect_min_jiffies,
+		.extra2		= &rds_sysctl_reconnect_max,
+	},
+	{
+		.ctl_name       = CTL_UNNUMBERED,
+		.procname       = "pf_rds",
+		.data		= &rds_sysctl_pf_rds,
+		.maxlen         = sizeof(int),
+		.mode           = 0444,
+		.proc_handler   = &proc_dointvec,
+	},
+	{
+		.ctl_name       = CTL_UNNUMBERED,
+		.procname       = "sol_rds",
+		.data		= &rds_sysctl_sol_rds,
+		.maxlen         = sizeof(int),
+		.mode           = 0444,
+		.proc_handler   = &proc_dointvec,
+	},
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "max_unacked_packets",
+		.data		= &rds_sysctl_max_unacked_packets,
+		.maxlen         = sizeof(unsigned long),
+		.mode           = 0644,
+		.proc_handler   = &proc_dointvec,
+	},
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "max_unacked_bytes",
+		.data		= &rds_sysctl_max_unacked_bytes,
+		.maxlen         = sizeof(unsigned long),
+		.mode           = 0644,
+		.proc_handler   = &proc_dointvec,
+	},
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "ping_enable",
+		.data		= &rds_sysctl_ping_enable,
+		.maxlen         = sizeof(int),
+		.mode           = 0644,
+		.proc_handler   = &proc_dointvec,
+	},
+        {
+                .ctl_name       = CTL_UNNUMBERED,
+                .procname       = "trace_flags",
+                .data           = &rds_sysctl_trace_flags,
+                .maxlen         = sizeof(unsigned long),
+                .mode           = 0644,
+                .proc_handler   = &proc_dointvec,
+        },
+        {
+                .ctl_name       = CTL_UNNUMBERED,
+                .procname       = "trace_level",
+                .data           = &rds_sysctl_trace_level,
+                .maxlen         = sizeof(unsigned int),
+                .mode           = 0644,
+                .proc_handler   = &proc_dointvec,
+        },
+	{ .ctl_name = 0}
+};
+
+static struct ctl_path rds_sysctl_path[] = {
+	{ .procname = "net", .ctl_name = CTL_NET, },
+	{ .procname = "rds", .ctl_name = CTL_UNNUMBERED, },
+	{ }
+};
+
+
+void rds_sysctl_exit(void)
+{
+	if (rds_sysctl_reg_table)
+		unregister_sysctl_table(rds_sysctl_reg_table);
+}
+
+int __init rds_sysctl_init(void)
+{
+	rds_sysctl_reconnect_min = msecs_to_jiffies(1);
+	rds_sysctl_reconnect_min_jiffies = rds_sysctl_reconnect_min;
+
+	rds_sysctl_reg_table = register_sysctl_paths(rds_sysctl_path, rds_sysctl_rds_table);
+	if (rds_sysctl_reg_table == NULL)
+		return -ENOMEM;
+	return 0;
+}
-- 
1.5.6.3


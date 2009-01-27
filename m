From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 18/21] RDS/IB: Stats and sysctls
Date: Mon, 26 Jan 2009 18:17:55 -0800
Message-ID: <1233022678-9259-19-git-send-email-andy.grover@oracle.com>
References: <1233022678-9259-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com, general@lists.openfabrics.org,
	netdev@vger.kernel.org
To: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:19778 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753259AbZA0CSv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2009 21:18:51 -0500
In-Reply-To: <1233022678-9259-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IB-specific stats and sysctls.

Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 drivers/infiniband/ulp/rds/ib_stats.c  |   95 ++++++++++++++++++++++
 drivers/infiniband/ulp/rds/ib_sysctl.c |  137 ++++++++++++++++++++++++++++++++
 2 files changed, 232 insertions(+), 0 deletions(-)
 create mode 100644 drivers/infiniband/ulp/rds/ib_stats.c
 create mode 100644 drivers/infiniband/ulp/rds/ib_sysctl.c

diff --git a/drivers/infiniband/ulp/rds/ib_stats.c b/drivers/infiniband/ulp/rds/ib_stats.c
new file mode 100644
index 0000000..02e3e3d
--- /dev/null
+++ b/drivers/infiniband/ulp/rds/ib_stats.c
@@ -0,0 +1,95 @@
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
+#include <linux/percpu.h>
+#include <linux/seq_file.h>
+#include <linux/proc_fs.h>
+
+#include "rds.h"
+#include "ib.h"
+
+DEFINE_PER_CPU(struct rds_ib_statistics, rds_ib_stats) ____cacheline_aligned;
+
+static char *rds_ib_stat_names[] = {
+	"ib_connect_raced",
+	"ib_listen_closed_stale",
+	"ib_tx_cq_call",
+	"ib_tx_cq_event",
+	"ib_tx_ring_full",
+	"ib_tx_throttle",
+	"ib_tx_sg_mapping_failure",
+	"ib_tx_stalled",
+	"ib_tx_credit_updates",
+	"ib_rx_cq_call",
+	"ib_rx_cq_event",
+	"ib_rx_ring_empty",
+	"ib_rx_refill_from_cq",
+	"ib_rx_refill_from_thread",
+	"ib_rx_alloc_limit",
+	"ib_rx_credit_updates",
+	"ib_ack_sent",
+	"ib_ack_send_failure",
+	"ib_ack_send_delayed",
+	"ib_ack_send_piggybacked",
+	"ib_ack_received",
+	"ib_rdma_mr_alloc",
+	"ib_rdma_mr_free",
+	"ib_rdma_mr_used",
+	"ib_rdma_mr_pool_flush",
+	"ib_rdma_mr_pool_wait",
+	"ib_rdma_mr_pool_depleted",
+};
+
+unsigned int rds_ib_stats_info_copy(struct rds_info_iterator *iter,
+				    unsigned int avail)
+{
+	struct rds_ib_statistics stats = {0, };
+	uint64_t *src;
+	uint64_t *sum;
+	size_t i;
+	int cpu;
+
+	if (avail < ARRAY_SIZE(rds_ib_stat_names))
+		goto out;
+
+	for_each_online_cpu(cpu) {
+		src = (uint64_t *)&(per_cpu(rds_ib_stats, cpu));
+		sum = (uint64_t *)&stats;
+		for (i = 0; i < sizeof(stats) / sizeof(uint64_t); i++)
+			*(sum++) += *(src++);
+	}
+
+	rds_stats_info_copy(iter, (uint64_t *)&stats, rds_ib_stat_names,
+			    ARRAY_SIZE(rds_ib_stat_names));
+out:
+	return ARRAY_SIZE(rds_ib_stat_names);
+}
diff --git a/drivers/infiniband/ulp/rds/ib_sysctl.c b/drivers/infiniband/ulp/rds/ib_sysctl.c
new file mode 100644
index 0000000..d87830d
--- /dev/null
+++ b/drivers/infiniband/ulp/rds/ib_sysctl.c
@@ -0,0 +1,137 @@
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
+#include "ib.h"
+
+static struct ctl_table_header *rds_ib_sysctl_hdr;
+
+unsigned long rds_ib_sysctl_max_send_wr = RDS_IB_DEFAULT_SEND_WR;
+unsigned long rds_ib_sysctl_max_recv_wr = RDS_IB_DEFAULT_RECV_WR;
+unsigned long rds_ib_sysctl_max_recv_allocation = (128 * 1024 * 1024) / RDS_FRAG_SIZE;
+static unsigned long rds_ib_sysctl_max_wr_min = 1;
+/* hardware will fail CQ creation long before this */
+static unsigned long rds_ib_sysctl_max_wr_max = (u32)~0;
+
+unsigned long rds_ib_sysctl_max_unsig_wrs = 16;
+static unsigned long rds_ib_sysctl_max_unsig_wr_min = 1;
+static unsigned long rds_ib_sysctl_max_unsig_wr_max = 64;
+
+unsigned long rds_ib_sysctl_max_unsig_bytes = (16 << 20);
+static unsigned long rds_ib_sysctl_max_unsig_bytes_min = 1;
+static unsigned long rds_ib_sysctl_max_unsig_bytes_max = ~0UL;
+
+unsigned int rds_ib_sysctl_flow_control = 1;
+
+ctl_table rds_ib_sysctl_table[] = {
+	{
+		.ctl_name       = CTL_UNNUMBERED,
+		.procname       = "max_send_wr",
+		.data		= &rds_ib_sysctl_max_send_wr,
+		.maxlen         = sizeof(unsigned long),
+		.mode           = 0644,
+		.proc_handler   = &proc_doulongvec_minmax,
+		.extra1		= &rds_ib_sysctl_max_wr_min,
+		.extra2		= &rds_ib_sysctl_max_wr_max,
+	},
+	{
+		.ctl_name       = CTL_UNNUMBERED,
+		.procname       = "max_recv_wr",
+		.data		= &rds_ib_sysctl_max_recv_wr,
+		.maxlen         = sizeof(unsigned long),
+		.mode           = 0644,
+		.proc_handler   = &proc_doulongvec_minmax,
+		.extra1		= &rds_ib_sysctl_max_wr_min,
+		.extra2		= &rds_ib_sysctl_max_wr_max,
+	},
+	{
+		.ctl_name       = CTL_UNNUMBERED,
+		.procname       = "max_unsignaled_wr",
+		.data		= &rds_ib_sysctl_max_unsig_wrs,
+		.maxlen         = sizeof(unsigned long),
+		.mode           = 0644,
+		.proc_handler   = &proc_doulongvec_minmax,
+		.extra1		= &rds_ib_sysctl_max_unsig_wr_min,
+		.extra2		= &rds_ib_sysctl_max_unsig_wr_max,
+	},
+	{
+		.ctl_name       = CTL_UNNUMBERED,
+		.procname       = "max_unsignaled_bytes",
+		.data		= &rds_ib_sysctl_max_unsig_bytes,
+		.maxlen         = sizeof(unsigned long),
+		.mode           = 0644,
+		.proc_handler   = &proc_doulongvec_minmax,
+		.extra1		= &rds_ib_sysctl_max_unsig_bytes_min,
+		.extra2		= &rds_ib_sysctl_max_unsig_bytes_max,
+	},
+	{
+		.ctl_name       = CTL_UNNUMBERED,
+		.procname       = "max_recv_allocation",
+		.data		= &rds_ib_sysctl_max_recv_allocation,
+		.maxlen         = sizeof(unsigned long),
+		.mode           = 0644,
+		.proc_handler   = &proc_doulongvec_minmax,
+	},
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "flow_control",
+		.data		= &rds_ib_sysctl_flow_control,
+		.maxlen		= sizeof(rds_ib_sysctl_flow_control),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
+	{ .ctl_name = 0}
+};
+
+static struct ctl_path rds_ib_sysctl_path[] = {
+	{ .procname = "net", .ctl_name = CTL_NET, },
+	{ .procname = "rds", .ctl_name = CTL_UNNUMBERED, },
+	{ .procname = "ib", .ctl_name = CTL_UNNUMBERED, },
+	{ }
+};
+
+void rds_ib_sysctl_exit(void)
+{
+	if (rds_ib_sysctl_hdr)
+		unregister_sysctl_table(rds_ib_sysctl_hdr);
+}
+
+int __init rds_ib_sysctl_init(void)
+{
+	rds_ib_sysctl_hdr = register_sysctl_paths(rds_ib_sysctl_path, rds_ib_sysctl_table);
+	if (rds_ib_sysctl_hdr == NULL)
+		return -ENOMEM;
+	return 0;
+}
-- 
1.5.6.3


From: George Zhang <georgezhang@vmware.com>
Subject: [PATCH 4/6] VSOCK: statistics implementation.
Date: Tue, 08 Jan 2013 16:00:07 -0800
Message-ID: <20130109000000.3719.88358.stgit@promb-2n-dhcp175.eng.vmware.com>
References: <20130108235633.3719.6085.stgit@promb-2n-dhcp175.eng.vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pv-drivers@vmware.com, gregkh@linuxfoundation.org, davem@davemloft.net
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	georgezhang@vmware.com, virtualization@lists.linux-foundation.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20130108235633.3719.6085.stgit@promb-2n-dhcp175.eng.vmware.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

VSOCK stats for VMCI Stream Sockets protocol.

Signed-off-by: George Zhang <georgezhang@vmware.com>
Acked-by: Andy king <acking@vmware.com>
Acked-by: Dmitry Torokhov <dtor@vmware.com>
---
 net/vmw_vsock/stats.c |   30 ++++++++++
 net/vmw_vsock/stats.h |  150 +++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 180 insertions(+), 0 deletions(-)
 create mode 100644 net/vmw_vsock/stats.c
 create mode 100644 net/vmw_vsock/stats.h

diff --git a/net/vmw_vsock/stats.c b/net/vmw_vsock/stats.c
new file mode 100644
index 0000000..49e09bb
--- /dev/null
+++ b/net/vmw_vsock/stats.c
@@ -0,0 +1,30 @@
+/*
+ * VMware vSockets Driver
+ *
+ * Copyright (C) 2009-2012 VMware, Inc. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License as published by the Free
+ * Software Foundation version 2 and no later version.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ */
+
+#include <linux/types.h>
+#include <linux/socket.h>
+#include <linux/stddef.h>
+#include <net/sock.h>
+
+#include "af_vsock.h"
+#include "stats.h"
+
+#ifdef VSOCK_GATHER_STATISTICS
+u64 vsock_stats_ctl_pkt_count[VSOCK_PACKET_TYPE_MAX];
+u64 vsock_stats_consume_queue_hist[VSOCK_NUM_QUEUE_LEVEL_BUCKETS];
+u64 vsock_stats_produce_queue_hist[VSOCK_NUM_QUEUE_LEVEL_BUCKETS];
+atomic64_t vsock_stats_consume_total;
+atomic64_t vsock_stats_produce_total;
+#endif
diff --git a/net/vmw_vsock/stats.h b/net/vmw_vsock/stats.h
new file mode 100644
index 0000000..07e2bf0
--- /dev/null
+++ b/net/vmw_vsock/stats.h
@@ -0,0 +1,150 @@
+/*
+ * VMware vSockets Driver
+ *
+ * Copyright (C) 2009-2012 VMware, Inc. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License as published by the Free
+ * Software Foundation version 2 and no later version.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ */
+
+#ifndef __STATS_H__
+#define __STATS_H__
+
+#include <linux/types.h>
+
+#include "vsock_common.h"
+#include "vsock_packet.h"
+
+/* Define VSOCK_GATHER_STATISTICS to turn on statistics gathering. Currently
+ * this consists of 3 types of stats: 1. The number of control datagram
+ * messages sent. 2. The level of queuepair fullness (in 10% buckets) whenever
+ * data is about to be enqueued or dequeued from the queuepair. 3. The total
+ * number of bytes enqueued/dequeued.
+ */
+
+#ifdef VSOCK_GATHER_STATISTICS
+
+#define VSOCK_NUM_QUEUE_LEVEL_BUCKETS 10
+extern u64 vsock_stats_ctl_pkt_count[VSOCK_PACKET_TYPE_MAX];
+extern u64 vsock_stats_consume_queue_hist[VSOCK_NUM_QUEUE_LEVEL_BUCKETS];
+extern u64 vsock_stats_produce_queue_hist[VSOCK_NUM_QUEUE_LEVEL_BUCKETS];
+extern atomic64_t vsock_stats_consume_total;
+extern atomic64_t vsock_stats_produce_total;
+
+#define VSOCK_STATS_STREAM_CONSUME_HIST(vsk)				\
+	vsock_vmci_stats_update_queue_bucket_count((vsk)->qpair,	\
+				(vsk)->consume_size,	\
+				vmci_qpair_consume_buf_ready((vsk)->qpair), \
+				vsock_stats_consume_queue_hist)
+#define VSOCK_STATS_STREAM_PRODUCE_HIST(vsk)				\
+	vsock_vmci_stats_update_queue_bucket_count((vsk)->qpair,	\
+				(vsk)->produce_size,	\
+				vmci_qpair_produce_buf_ready((vsk)->qpair), \
+				vsock_stats_produce_queue_hist)
+#define VSOCK_STATS_CTLPKT_LOG(pkt_type)	\
+		(++vsock_stats_ctl_pkt_count[pkt_type])
+#define VSOCK_STATS_STREAM_CONSUME(bytes)		\
+	atomic64_add(&vsock_stats_consume_total, bytes)
+#define VSOCK_STATS_STREAM_PRODUCE(bytes)		\
+	atomic64_add(&vsock_stats_produce_total, bytes)
+#define VSOCK_STATS_CTLPKT_DUMP_ALL() vsock_vmci_stats_ctl_pkt_dump_all()
+#define VSOCK_STATS_HIST_DUMP_ALL()   vsock_vmci_stats_hist_dump_all()
+#define VSOCK_STATS_TOTALS_DUMP_ALL() vsock_vmci_stats_totals_dump_all()
+#define VSOCK_STATS_RESET()           vsock_vmci_stats_reset()
+
+static inline void
+vsock_vmci_stats_update_queue_bucket_count(vmci_qpair *qpair,
+					   u64 queue_size,
+					   u64 data_ready,
+					   u64 queue_hist[])
+{
+	u64 bucket = 0;
+	u32 remainder = 0;
+
+	/* We can't do 64 / 64 = 64 bit divides on linux because it requires a
+	 * libgcc which is not linked into the kernel module. Since this code
+	 * is only used by developers we just limit the queue_size to be less
+	 * than MAX_UINT for now.
+	 */
+	Div643264(data_ready * 10, queue_size, &bucket, &remainder);
+	++queue_hist[bucket];
+}
+
+static inline void vsock_vmci_stats_ctl_pkt_dump_all(void)
+{
+	int index;
+
+	BUILD_BUG_ON(VSOCK_PACKET_TYPE_MAX !=
+			ARRAY_SIZE(vsock_stats_ctl_pkt_count));
+
+	for (index = 0; index < ARRAY_SIZE(vsock_stats_ctl_pkt_count);
+	     index++) {
+		pr_info("Control packet: Type = %u, Count = %" FMT64
+		       "u\n", index, vsock_stats_ctl_pkt_count[index]);
+	}
+}
+
+static inline void vsock_vmci_stats_hist_dump_all(void)
+{
+	int index;
+
+#define VSOCK_DUMP_HIST(strname, name) do {		    \
+		for (index = 0; index < ARRAY_SIZE(name); index++) {	\
+			printk(strname " Bucket count %u = %"FMT64"u\n", \
+			       index, name[index]);			\
+		}							\
+	} while (0)
+
+	VSOCK_DUMP_HIST("Produce Queue", vsock_stats_produce_queue_hist);
+	VSOCK_DUMP_HIST("Consume Queue", vsock_stats_consume_queue_hist);
+
+#undef VSOCK_DUMP_HIST
+}
+
+static inline void vsock_vmci_stats_totals_dump_all(void)
+{
+	pr_info("Produced %" FMT64 "u total bytes\n",
+	       atomic64_read(&vsock_stats_produce_total));
+	pr_info("Consumed %" FMT64 "u total bytes\n",
+	       atomic64_read(&vsock_stats_consume_total));
+}
+
+static inline void vsock_vmci_stats_reset(void)
+{
+	int index;
+
+#define VSOCK_RESET_ARRAY(name) do {			   \
+		for (index = 0; index < ARRAY_SIZE(name); index++) {	\
+			name[index] = 0;				\
+		}							\
+	} while (0)
+
+	VSOCK_RESET_ARRAY(vsock_stats_ctl_pkt_count);
+	VSOCK_RESET_ARRAY(vsock_stats_produce_queue_hist);
+	VSOCK_RESET_ARRAY(vsock_stats_consume_queue_hist);
+
+#undef VSOCK_RESET_ARRAY
+
+	atomic64_set(&vsock_stats_consume_total, 0);
+	atomic64_set(&vsock_stats_produce_total, 0);
+}
+
+#else
+#define VSOCK_STATS_STREAM_CONSUME_HIST(vsk)
+#define VSOCK_STATS_STREAM_PRODUCE_HIST(vsk)
+#define VSOCK_STATS_STREAM_PRODUCE(bytes)
+#define VSOCK_STATS_STREAM_CONSUME(bytes)
+#define VSOCK_STATS_CTLPKT_LOG(pkt_type)
+#define VSOCK_STATS_CTLPKT_DUMP_ALL()
+#define VSOCK_STATS_HIST_DUMP_ALL()
+#define VSOCK_STATS_TOTALS_DUMP_ALL()
+#define VSOCK_STATS_RESET()
+#endif
+
+#endif

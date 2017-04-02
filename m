From: Sagi Grimberg <sagi@grimberg.me>
Subject: [PATCH rfc 5/6] block: Add rdma affinity based queue mapping helper
Date: Sun,  2 Apr 2017 16:41:31 +0300
Message-ID: <1491140492-25703-6-git-send-email-sagi@grimberg.me>
References: <1491140492-25703-1-git-send-email-sagi@grimberg.me>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Christoph Hellwig <hch@lst.de>
To: linux-rdma@vger.kernel.org, linux-nvme@lists.infradead.org,
        linux-block@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:46173 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751536AbdDBNmN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 2 Apr 2017 09:42:13 -0400
In-Reply-To: <1491140492-25703-1-git-send-email-sagi@grimberg.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Like pci and virtio, we add a rdma helper for affinity
spreading. This achieves optimal mq affinity assignments
according to the underlying rdma device affinity maps.

Signed-off-by: Sagi Grimberg <sagi@grimberg.me>
---
 block/Kconfig               |  5 ++++
 block/Makefile              |  1 +
 block/blk-mq-rdma.c         | 56 +++++++++++++++++++++++++++++++++++++++++++++
 include/linux/blk-mq-rdma.h | 10 ++++++++
 4 files changed, 72 insertions(+)
 create mode 100644 block/blk-mq-rdma.c
 create mode 100644 include/linux/blk-mq-rdma.h

diff --git a/block/Kconfig b/block/Kconfig
index 89cd28f8d051..3ab42bbb06d5 100644
--- a/block/Kconfig
+++ b/block/Kconfig
@@ -206,4 +206,9 @@ config BLK_MQ_VIRTIO
 	depends on BLOCK && VIRTIO
 	default y
 
+config BLK_MQ_RDMA
+	bool
+	depends on BLOCK && INFINIBAND
+	default y
+
 source block/Kconfig.iosched
diff --git a/block/Makefile b/block/Makefile
index 081bb680789b..4498603dbc83 100644
--- a/block/Makefile
+++ b/block/Makefile
@@ -26,6 +26,7 @@ obj-$(CONFIG_BLK_CMDLINE_PARSER)	+= cmdline-parser.o
 obj-$(CONFIG_BLK_DEV_INTEGRITY) += bio-integrity.o blk-integrity.o t10-pi.o
 obj-$(CONFIG_BLK_MQ_PCI)	+= blk-mq-pci.o
 obj-$(CONFIG_BLK_MQ_VIRTIO)	+= blk-mq-virtio.o
+obj-$(CONFIG_BLK_MQ_RDMA)	+= blk-mq-rdma.o
 obj-$(CONFIG_BLK_DEV_ZONED)	+= blk-zoned.o
 obj-$(CONFIG_BLK_WBT)		+= blk-wbt.o
 obj-$(CONFIG_BLK_DEBUG_FS)	+= blk-mq-debugfs.o
diff --git a/block/blk-mq-rdma.c b/block/blk-mq-rdma.c
new file mode 100644
index 000000000000..d402f7c93528
--- /dev/null
+++ b/block/blk-mq-rdma.c
@@ -0,0 +1,56 @@
+/*
+ * Copyright (c) 2017 Sagi Grimberg.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ */
+#include <linux/blk-mq.h>
+#include <linux/blk-mq-rdma.h>
+#include <rdma/ib_verbs.h>
+#include <linux/module.h>
+#include "blk-mq.h"
+
+/**
+ * blk_mq_rdma_map_queues - provide a default queue mapping for rdma device
+ * @set:	tagset to provide the mapping for
+ * @dev:	rdma device associated with @set.
+ * @first_vec:	first interrupt vectors to use for queues (usually 0)
+ *
+ * This function assumes the rdma device @dev has at least as many available
+ * interrupt vetors as @set has queues.  It will then query it's affinity mask
+ * and built queue mapping that maps a queue to the CPUs that have irq affinity
+ * for the corresponding vector.
+ *
+ * In case either the driver passed a @dev with less vectors than
+ * @set->nr_hw_queues, or @dev does not provide an affinity mask for a
+ * vector, we fallback to the naive mapping.
+ */
+int blk_mq_rdma_map_queues(struct blk_mq_tag_set *set,
+		struct ib_device *dev, int first_vec)
+{
+	const struct cpumask *mask;
+	unsigned int queue, cpu;
+
+	if (set->nr_hw_queues > dev->num_comp_vectors)
+		goto fallback;
+
+	for (queue = 0; queue < set->nr_hw_queues; queue++) {
+		mask = ib_get_vector_affinity(dev, first_vec + queue);
+		if (!mask)
+			goto fallback;
+
+		for_each_cpu(cpu, mask)
+			set->mq_map[cpu] = queue;
+	}
+
+	return 0;
+fallback:
+	return blk_mq_map_queues(set);
+}
+EXPORT_SYMBOL_GPL(blk_mq_rdma_map_queues);
diff --git a/include/linux/blk-mq-rdma.h b/include/linux/blk-mq-rdma.h
new file mode 100644
index 000000000000..b4ade198007d
--- /dev/null
+++ b/include/linux/blk-mq-rdma.h
@@ -0,0 +1,10 @@
+#ifndef _LINUX_BLK_MQ_RDMA_H
+#define _LINUX_BLK_MQ_RDMA_H
+
+struct blk_mq_tag_set;
+struct ib_device;
+
+int blk_mq_rdma_map_queues(struct blk_mq_tag_set *set,
+		struct ib_device *dev, int first_vec);
+
+#endif /* _LINUX_BLK_MQ_RDMA_H */
-- 
2.7.4

From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH] dma: Add a benchmark for using SRAM memory as receiver buffers.
Date: Sat,  4 Jun 2016 21:16:51 +0200
Message-ID: <1465067829-1875-2-git-send-email-andrew@lunn.ch>
References: <1465067829-1875-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Shawn Guo <shawnguo@kernel.org>,
	Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:59580 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751105AbcFDTY7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Jun 2016 15:24:59 -0400
In-Reply-To: <1465067829-1875-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

---
 drivers/dma/Kconfig                 |   5 +
 drivers/dma/Makefile                |   1 +
 drivers/dma/dma_sram_rx_benchmark.c | 231 ++++++++++++++++++++++++++++++++++++
 3 files changed, 237 insertions(+)
 create mode 100644 drivers/dma/dma_sram_rx_benchmark.c

diff --git a/drivers/dma/Kconfig b/drivers/dma/Kconfig
index 4f6956ebd4dc..807d5eb7088a 100644
--- a/drivers/dma/Kconfig
+++ b/drivers/dma/Kconfig
@@ -585,6 +585,11 @@ config DMA_COHERENT_RX_BENCHMARK
 	help
 	  Simple benchmark for RX performance using coherent memory.
 
+config DMA_SRAM_RX_BENCHMARK
+	tristate "DMA SRAM RX Benchmark"
+	help
+	  Simple benchmark for RX performance using SRAM memory.
+
 config DMA_ENGINE_RAID
 	bool
 
diff --git a/drivers/dma/Makefile b/drivers/dma/Makefile
index d435b92a1a43..f9cb715cfc67 100644
--- a/drivers/dma/Makefile
+++ b/drivers/dma/Makefile
@@ -14,6 +14,7 @@ obj-$(CONFIG_DMATEST) += dmatest.o
 # simple RX Benchmark
 obj-$(CONFIG_DMA_RX_BENCHMARK) += dma_rx_benchmark.o
 obj-$(CONFIG_DMA_COHERENT_RX_BENCHMARK) += dma_coherent_rx_benchmark.o
+obj-$(CONFIG_DMA_SRAM_RX_BENCHMARK) += dma_sram_rx_benchmark.o
 
 #devices
 obj-$(CONFIG_AMBA_PL08X) += amba-pl08x.o
diff --git a/drivers/dma/dma_sram_rx_benchmark.c b/drivers/dma/dma_sram_rx_benchmark.c
new file mode 100644
index 000000000000..23a6e675fddf
--- /dev/null
+++ b/drivers/dma/dma_sram_rx_benchmark.c
@@ -0,0 +1,231 @@
+/* DMA API benchmark
+ * Copyright(c) 2016 Andrew Lunn <andrew@lunn.ch>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, see <http://www.gnu.org/licenses/>.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ */
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/types.h>
+#include <linux/dma-mapping.h>
+#include <linux/genalloc.h>
+#include <linux/of.h>
+#include <linux/of_platform.h>
+#include <linux/platform_device.h>
+#include <linux/io.h>
+#include <asm/page.h>
+
+#define MAX_BUFS 1024
+
+struct device dev;
+static void *bufs[MAX_BUFS];
+dma_addr_t dma_handles[MAX_BUFS];
+
+static struct gen_pool *pool;
+
+static char discard[1500];
+
+static int alloc_ring(struct device *dev, int num_bufs)
+{
+	struct platform_device *pdev;
+	struct device_node *node;
+	int ret;
+	int i;
+
+	if (num_bufs > MAX_BUFS)
+		return -EINVAL;
+
+	node = of_find_compatible_node(NULL, NULL, "mmio-sram");
+	if (!node) {
+		dev_warn(dev, "failed to find sram node\n");
+		return -ENODEV;
+	}
+
+	pdev = of_find_device_by_node(node);
+	if (!pdev) {
+		dev_warn(dev, "failed to find sram device\n");
+		ret = -ENODEV;
+		goto put_node;
+	}
+
+	pool = gen_pool_get(&pdev->dev, NULL);
+	if (!pool) {
+		dev_warn(dev, "ocram pool unavailable\n");
+		ret = -ENODEV;
+		goto put_node;
+	}
+
+	for (i = 0; i < num_bufs; i++) {
+		bufs[i] = gen_pool_dma_alloc(pool, 2048, &dma_handles[i]);
+		dev_info(dev, "%p %x\n", bufs[i], dma_handles[i]);
+		if (!bufs[i]) {
+			dev_warn(dev, "Out of pool memory\n");
+			ret = -ENOMEM;
+			goto put_node;
+		}
+	}
+	return 0;
+
+put_node:
+	of_node_put(node);
+
+	return ret;
+}
+
+static void free_ring(struct device *dev, int num_bufs)
+{
+	int i;
+
+	for (i = 0; i < num_bufs; i++)
+		gen_pool_free(pool, (unsigned long)bufs[i], 2048);
+}
+
+/* Give all but the first buffer to the device */
+static void prime_ring_sync(struct device *dev, int num_bufs)
+{
+	int i;
+
+	for (i = 1; i < num_bufs - 1; i++)
+		dma_sync_single_range_for_device(dev, dma_handles[i], 0,
+						 2048, DMA_FROM_DEVICE);
+}
+
+static void give_to_device(struct device *dev, int num_buf)
+{
+	dma_sync_single_range_for_device(dev, dma_handles[num_buf],
+					 0, 2048, DMA_FROM_DEVICE);
+}
+
+static void take_from_device(struct device *dev, int num_buf)
+{
+
+	dma_sync_single_range_for_cpu(dev, dma_handles[num_buf],
+				      0, 2048, DMA_FROM_DEVICE);
+
+	memcpy(discard, (void *)bufs[num_buf], 1500);
+}
+
+
+static void run_ring_once(struct device *dev, int num_bufs)
+{
+	int i;
+
+	for (i = 0; i < num_bufs - 1; i++)
+		memcpy(discard, bufs[i], 2048);
+}
+
+static void run_ring(struct device *dev, int num_bufs)
+{
+	unsigned long elapsed;
+	unsigned long start;
+	unsigned long now;
+	int count = 0;
+
+	start = jiffies;
+
+	do {
+		run_ring_once(dev, num_bufs);
+		count += (num_bufs - 1);
+		now = jiffies;
+		elapsed = now - start;
+	} while (elapsed < (HZ * 2));
+
+	dev_info(dev, "%3d: %d\n", num_bufs, count);
+}
+
+static void run_ring_sync_once(struct device *dev, int num_bufs)
+{
+	int i;
+
+	for (i = 0; i < num_bufs - 1; i++) {
+		give_to_device(dev, i);
+		take_from_device(dev, i + 1);
+	}
+}
+
+static void run_ring_sync(struct device *dev, int num_bufs)
+{
+	unsigned long elapsed;
+	unsigned long start;
+	unsigned long now;
+	int count = 0;
+
+	start = jiffies;
+
+	do {
+		run_ring_sync_once(dev, num_bufs);
+		count += num_bufs;
+		now = jiffies;
+		elapsed = now - start;
+	} while (elapsed < (HZ * 2));
+
+	dev_info(dev, "sync: %3d: %d\n", num_bufs, count);
+}
+
+static __exit void rx_benchmark_release(struct device *dev)
+{
+}
+
+static int __init rx_coherent_benchmark_init(void)
+{
+	int err;
+	int i;
+
+	memset(&dev, 0, sizeof(dev));
+
+	dev_set_name(&dev, "rx_benchmark");
+	dev.release = rx_benchmark_release;
+	dev.coherent_dma_mask = DMA_BIT_MASK(32);
+
+	err = device_register(&dev);
+	if (err)
+		return err;
+
+	for (i = 4; i <= 16; i += 2) {
+		err = alloc_ring(&dev, i);
+		if (err)
+			goto out_unregister;
+
+		run_ring(&dev, i);
+		free_ring(&dev, i);
+		schedule();
+	}
+
+	for (i = 4; i <= 16; i += 2) {
+		err = alloc_ring(&dev, i);
+		if (err)
+			goto out_unregister;
+
+		prime_ring_sync(&dev, i);
+		run_ring_sync(&dev, i);
+		free_ring(&dev, i);
+		schedule();
+	}
+
+out_unregister:
+	return 0;
+}
+
+static void __exit rx_coherent_benchmark_exit(void)
+{
+	device_unregister(&dev);
+}
+
+module_init(rx_coherent_benchmark_init);
+module_exit(rx_coherent_benchmark_exit);
+MODULE_AUTHOR("Andrew Lunn (andrew@lunn.ch)");
+MODULE_LICENSE("GPL v2");
-- 
2.8.1

From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: [PATCH v2 net-next 7/8] net: add a hardware buffer management helper API
Date: Tue, 16 Feb 2016 16:33:42 +0100
Message-ID: <1455636823-14470-8-git-send-email-gregory.clement@free-electrons.com>
References: <1455636823-14470-1-git-send-email-gregory.clement@free-electrons.com>
Cc: Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org,
	Lior Amsalem <alior@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>,
	Marcin Wojtas <mw@semihalf.com>,
	Simon Guinot <simon.guinot@sequanux.org>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Willy Tarreau <w@1wt.eu>, Timor Kardashov <timork@marvell.com>,
	Sebastian Careba <nitroshift@yahoo.com>
To: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455636823-14470-1-git-send-email-gregory.clement@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This basic implementation allows to share code between driver using
hardware buffer management. As the code is hardware agnostic, there is
few helpers, most of the optimization brought by the an HW BM has to be
done at driver level.

Signed-off-by: Gregory CLEMENT <gregory.clement@free-electrons.com>
---
 include/net/hwbm.h | 21 +++++++++++++
 net/Kconfig        |  3 ++
 net/core/Makefile  |  1 +
 net/core/hwbm.c    | 87 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 112 insertions(+)
 create mode 100644 include/net/hwbm.h
 create mode 100644 net/core/hwbm.c

diff --git a/include/net/hwbm.h b/include/net/hwbm.h
new file mode 100644
index 000000000000..9ae9449a7eda
--- /dev/null
+++ b/include/net/hwbm.h
@@ -0,0 +1,21 @@
+#ifndef _HWBM_H
+#define _HWBM_H
+
+struct hwbm_pool {
+	/* Size of the buffers managed */
+	int size;
+	/* Number of buffers currently used by this pool */
+	int buf_num;
+	/* constructor called during alocation */
+	int (*construct)(struct hwbm_pool *bm_pool, void *buf);
+	/* protect acces to the buffer counter*/
+	spinlock_t lock;
+	/* private data */
+	void *priv;
+};
+
+void hwbm_buf_free(struct hwbm_pool *bm_pool, void *buf);
+int hwbm_pool_refill(struct hwbm_pool *bm_pool, gfp_t gfp);
+int hwbm_pool_add(struct hwbm_pool *bm_pool, unsigned int buf_num, gfp_t gfp);
+
+#endif /* _HWBM_H */
diff --git a/net/Kconfig b/net/Kconfig
index 174354618f8a..f50c8af4308b 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -253,6 +253,9 @@ config XPS
 	depends on SMP
 	default y
 
+config HWBM
+       bool
+
 config SOCK_CGROUP_DATA
 	bool
 	default n
diff --git a/net/core/Makefile b/net/core/Makefile
index 0b835de04de3..57e6dd81c6be 100644
--- a/net/core/Makefile
+++ b/net/core/Makefile
@@ -24,3 +24,4 @@ obj-$(CONFIG_NET_PTP_CLASSIFY) += ptp_classifier.o
 obj-$(CONFIG_CGROUP_NET_PRIO) += netprio_cgroup.o
 obj-$(CONFIG_CGROUP_NET_CLASSID) += netclassid_cgroup.o
 obj-$(CONFIG_LWTUNNEL) += lwtunnel.o
+obj-$(CONFIG_HWBM) += hwbm.o
diff --git a/net/core/hwbm.c b/net/core/hwbm.c
new file mode 100644
index 000000000000..a98d2a74ca02
--- /dev/null
+++ b/net/core/hwbm.c
@@ -0,0 +1,87 @@
+/* Support for hardware buffer manager.
+ *
+ * Copyright (C) 2016 Marvell
+ *
+ * Gregory CLEMENT <gregory.clement@free-electrons.com>
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License, or
+ *  (at your option) any later version.
+ */
+#include <linux/kernel.h>
+#include <linux/printk.h>
+#include <linux/skbuff.h>
+#include <net/hwbm.h>
+
+void hwbm_buf_free(struct hwbm_pool *bm_pool, void *buf)
+{
+	if (likely(bm_pool->size <= PAGE_SIZE))
+		skb_free_frag(buf);
+	else
+		kfree(buf);
+}
+EXPORT_SYMBOL_GPL(hwbm_buf_free);
+
+/* Refill processing for HW buffer management */
+int hwbm_pool_refill(struct hwbm_pool *bm_pool, gfp_t gfp)
+{
+	int frag_size = bm_pool->size;
+	void *buf;
+
+	if (likely(frag_size <= PAGE_SIZE))
+		buf = netdev_alloc_frag(frag_size);
+	else
+		buf = kmalloc(frag_size, gfp);
+
+	if (!buf)
+		return -ENOMEM;
+
+	if (bm_pool->construct)
+		if (bm_pool->construct(bm_pool, buf)) {
+			hwbm_buf_free(bm_pool, buf);
+			return -ENOMEM;
+		}
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(hwbm_pool_refill);
+
+int hwbm_pool_add(struct hwbm_pool *bm_pool, unsigned int buf_num, gfp_t gfp)
+{
+	int err, i;
+	unsigned long flags;
+
+	spin_lock_irqsave(&bm_pool->lock, flags);
+	if (bm_pool->buf_num == bm_pool->size) {
+		pr_warn("pool already filled\n");
+		return bm_pool->buf_num;
+	}
+
+	if (buf_num + bm_pool->buf_num > bm_pool->size) {
+		pr_warn("cannot allocate %d buffers for pool\n",
+			buf_num);
+		return 0;
+	}
+
+	if ((buf_num + bm_pool->buf_num) < bm_pool->buf_num) {
+		pr_warn("Adding %d buffers to the %d current buffers will overflow\n",
+			buf_num,  bm_pool->buf_num);
+		return 0;
+	}
+
+	for (i = 0; i < buf_num; i++) {
+		err = hwbm_pool_refill(bm_pool, gfp);
+		if (err < 0)
+			break;
+	}
+
+	/* Update BM driver with number of buffers added to pool */
+	bm_pool->buf_num += i;
+
+	pr_debug("hwpm pool: %d of %d buffers added\n", i, buf_num);
+	spin_unlock_irqrestore(&bm_pool->lock, flags);
+
+	return i;
+}
+EXPORT_SYMBOL_GPL(hwbm_pool_add);
-- 
2.5.0

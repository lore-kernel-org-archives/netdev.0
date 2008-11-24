From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 36/39] i2400m/SDIO: write transactions to the SDIO device
Date: Mon, 24 Nov 2008 13:50:59 -0800
Message-ID: <7dd8ac4dcc204b4ad480a8b36640d5bf1d41dd1e.1227562829.git.inaky@linux.intel.com>
References: <cover.1227562829.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga12.intel.com ([143.182.124.36]:21168 "EHLO
	azsmga102.ch.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753250AbYKXVvt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 16:51:49 -0500
In-Reply-To: <cover.1227562829.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implements the backend so that the generic driver can send data to the
SDIO device. When kicked by the generic driver, this will schedule
work on a driver-specific workqueue that pulls data from the TX FIFO
and sends it to the device until it drains it.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/sdio-tx.c |  153 ++++++++++++++++++++++++++++++++++++
 1 files changed, 153 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/wimax/i2400m/sdio-tx.c

diff --git a/drivers/net/wimax/i2400m/sdio-tx.c b/drivers/net/wimax/i2400m/sdio-tx.c
new file mode 100644
index 0000000..8f29a3b
--- /dev/null
+++ b/drivers/net/wimax/i2400m/sdio-tx.c
@@ -0,0 +1,153 @@
+/*
+ * Intel Wireless WiMAX Connection 2400m
+ * SDIO TX transaction backends
+ *
+ *
+ * Copyright (C) 2007-2008 Intel Corporation. All rights reserved.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ *
+ *   * Redistributions of source code must retain the above copyright
+ *     notice, this list of conditions and the following disclaimer.
+ *   * Redistributions in binary form must reproduce the above copyright
+ *     notice, this list of conditions and the following disclaimer in
+ *     the documentation and/or other materials provided with the
+ *     distribution.
+ *   * Neither the name of Intel Corporation nor the names of its
+ *     contributors may be used to endorse or promote products derived
+ *     from this software without specific prior written permission.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
+ * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
+ * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
+ * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
+ * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
+ * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
+ * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
+ * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
+ * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
+ * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ *
+ * Intel Corporation <linux-wimax@intel.com>
+ * Dirk Brandewie <dirk.j.brandewie@intel.com>
+ *  - Initial implementation
+ *
+ *
+ * Takes the TX messages in the i2400m's driver TX FIFO and sends them
+ * to the device until there are no more.
+ *
+ * If we fail sending the message, we just drop it. There isn't much
+ * we can do at this point. Most of the traffic is network, which has
+ * recovery methods for dropped packets.
+ *
+ * The SDIO functions are not atomic, so we can't run from the context
+ * where i2400m->bus_tx_kick() [i2400ms_bus_tx_kick()] is being called
+ * (some times atomic). Thus, the actual TX work is deferred to a
+ * workqueue.
+ *
+ * ROADMAP
+ *
+ * i2400ms_bus_tx_kick()
+ *   i2400ms_tx_submit()     [through workqueue]
+ *
+ * i2400m_tx_setup()
+ *
+ * i2400m_tx_release()
+ */
+#include <linux/mmc/sdio_func.h>
+#include "i2400m-sdio.h"
+
+#define D_SUBMODULE sdio_tx
+#include "sdio-debug-levels.h"
+
+
+/*
+ * Pull TX transations from the TX FIFO and send them to the device
+ * until there are no more.
+ */
+static
+void i2400ms_tx_submit(struct work_struct *ws)
+{
+	int result;
+	struct i2400ms *i2400ms = container_of(ws, struct i2400ms, tx_worker);
+	struct i2400m *i2400m = &i2400ms->i2400m;
+	struct sdio_func *func = i2400ms->func;
+	struct device *dev = &func->dev;
+	struct i2400m_msg_hdr *tx_msg;
+	size_t tx_msg_size;
+
+	d_fnstart(4, dev, "(i2400ms %p, i2400m %p)\n", i2400ms, i2400ms);
+
+	while (NULL != (tx_msg = i2400m_tx_msg_get(i2400m, &tx_msg_size))) {
+		d_printf(2, dev, "TX: submitting %zu bytes\n", tx_msg_size);
+		d_dump(5, dev, tx_msg, tx_msg_size);
+
+		sdio_claim_host(func);
+		result = sdio_memcpy_toio(func, 0, tx_msg, tx_msg_size);
+		sdio_release_host(func);
+
+		i2400m_tx_msg_sent(i2400m);
+
+		if (result < 0) {
+			dev_err(dev, "TX: cannot submit TX; tx_msg @%zu %zu B:"
+				" %d\n", (void *) tx_msg - i2400m->tx_buf,
+				tx_msg_size, result);
+		}
+
+		d_printf(2, dev, "TX: %zub submitted\n", tx_msg_size);
+	}
+
+	d_fnend(4, dev, "(i2400ms %p) = void\n", i2400ms);
+}
+
+
+/*
+ * The generic driver notifies us that there is data ready for TX
+ *
+ * Schedule a run of i2400ms_tx_submit() to handle it.
+ */
+void i2400ms_bus_tx_kick(struct i2400m *i2400m)
+{
+	struct i2400ms *i2400ms = container_of(i2400m, struct i2400ms, i2400m);
+	struct device *dev = &i2400ms->func->dev;
+
+	d_fnstart(3, dev, "(i2400m %p) = void\n", i2400m);
+
+	/* schedule tx work, this is because tx may block, therefore
+	 * it has to run in a thread context.
+	 */
+	queue_work(i2400ms->tx_workqueue, &i2400ms->tx_worker);
+
+	d_fnend(3, dev, "(i2400m %p) = void\n", i2400m);
+}
+
+int i2400ms_tx_setup(struct i2400ms *i2400ms)
+{
+	int result;
+	struct device *dev = &i2400ms->func->dev;
+	struct i2400m *i2400m = &i2400ms->i2400m;
+
+	d_fnstart(5, dev, "(i2400ms %p)\n", i2400ms);
+
+	INIT_WORK(&i2400ms->tx_worker, i2400ms_tx_submit);
+	snprintf(i2400ms->tx_wq_name, sizeof(i2400ms->tx_wq_name),
+		 "%s-tx", i2400m->wimax_dev.name);
+	i2400ms->tx_workqueue =
+		create_singlethread_workqueue(i2400ms->tx_wq_name);
+	if (NULL == i2400ms->tx_workqueue) {
+		dev_err(dev, "TX: failed to create workqueue\n");
+		result = -ENOMEM;
+	} else
+		result = 0;
+	d_fnend(5, dev, "(i2400ms %p) = %d\n", i2400ms, result);
+	return result;
+}
+
+void i2400ms_tx_release(struct i2400ms *i2400ms)
+{
+	destroy_workqueue(i2400ms->tx_workqueue);
+}
-- 
1.5.6.5


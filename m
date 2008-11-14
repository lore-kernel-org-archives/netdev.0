From: Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH 02/13] dmaengine: remove dependency on async_tx
Date: Fri, 14 Nov 2008 14:34:27 -0700
Message-ID: <20081114213426.32354.75721.stgit@dwillia2-linux.ch.intel.com>
References: <20081114213300.32354.1154.stgit@dwillia2-linux.ch.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: maciej.sosnowski@intel.com, hskinnemoen@atmel.com,
	g.liakhovetski@gmx.de, nicolas.ferre@atmel.com
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:20671 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751840AbYKNVe2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Nov 2008 16:34:28 -0500
In-Reply-To: <20081114213300.32354.1154.stgit@dwillia2-linux.ch.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

async_tx.ko is a consumer of dma channels.  A circular dependency arises
if modules in drivers/dma rely on common code in async_tx.ko.  It
prevents either module from being unloaded.

Move dma_wait_for_async_tx and async_tx_run_dependencies to dmaeninge.o
where they should have been from the beginning.

Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---

 crypto/async_tx/async_tx.c |   75 --------------------------------------------
 drivers/dma/Kconfig        |    2 -
 drivers/dma/dmaengine.c    |   75 ++++++++++++++++++++++++++++++++++++++++++++
 drivers/dma/iop-adma.c     |    3 +-
 drivers/dma/mv_xor.c       |    3 +-
 include/linux/async_tx.h   |   15 ---------
 include/linux/dmaengine.h  |    9 +++++
 7 files changed, 86 insertions(+), 96 deletions(-)

diff --git a/crypto/async_tx/async_tx.c b/crypto/async_tx/async_tx.c
index dcbf1be..8cfac18 100644
--- a/crypto/async_tx/async_tx.c
+++ b/crypto/async_tx/async_tx.c
@@ -72,81 +72,6 @@ void async_tx_issue_pending_all(void)
 }
 EXPORT_SYMBOL_GPL(async_tx_issue_pending_all);
 
-/* dma_wait_for_async_tx - spin wait for a transcation to complete
- * @tx: transaction to wait on
- */
-enum dma_status
-dma_wait_for_async_tx(struct dma_async_tx_descriptor *tx)
-{
-	enum dma_status status;
-	struct dma_async_tx_descriptor *iter;
-	struct dma_async_tx_descriptor *parent;
-
-	if (!tx)
-		return DMA_SUCCESS;
-
-	/* poll through the dependency chain, return when tx is complete */
-	do {
-		iter = tx;
-
-		/* find the root of the unsubmitted dependency chain */
-		do {
-			parent = iter->parent;
-			if (!parent)
-				break;
-			else
-				iter = parent;
-		} while (parent);
-
-		/* there is a small window for ->parent == NULL and
-		 * ->cookie == -EBUSY
-		 */
-		while (iter->cookie == -EBUSY)
-			cpu_relax();
-
-		status = dma_sync_wait(iter->chan, iter->cookie);
-	} while (status == DMA_IN_PROGRESS || (iter != tx));
-
-	return status;
-}
-EXPORT_SYMBOL_GPL(dma_wait_for_async_tx);
-
-/* async_tx_run_dependencies - helper routine for dma drivers to process
- *	(start) dependent operations on their target channel
- * @tx: transaction with dependencies
- */
-void async_tx_run_dependencies(struct dma_async_tx_descriptor *tx)
-{
-	struct dma_async_tx_descriptor *dep = tx->next;
-	struct dma_async_tx_descriptor *dep_next;
-	struct dma_chan *chan;
-
-	if (!dep)
-		return;
-
-	chan = dep->chan;
-
-	/* keep submitting up until a channel switch is detected
-	 * in that case we will be called again as a result of
-	 * processing the interrupt from async_tx_channel_switch
-	 */
-	for (; dep; dep = dep_next) {
-		spin_lock_bh(&dep->lock);
-		dep->parent = NULL;
-		dep_next = dep->next;
-		if (dep_next && dep_next->chan == chan)
-			dep->next = NULL; /* ->next will be submitted */
-		else
-			dep_next = NULL; /* submit current dep and terminate */
-		spin_unlock_bh(&dep->lock);
-
-		dep->tx_submit(dep);
-	}
-
-	chan->device->device_issue_pending(chan);
-}
-EXPORT_SYMBOL_GPL(async_tx_run_dependencies);
-
 static void
 free_dma_chan_ref(struct rcu_head *rcu)
 {
diff --git a/drivers/dma/Kconfig b/drivers/dma/Kconfig
index 904e575..e34b064 100644
--- a/drivers/dma/Kconfig
+++ b/drivers/dma/Kconfig
@@ -33,7 +33,6 @@ config INTEL_IOATDMA
 config INTEL_IOP_ADMA
 	tristate "Intel IOP ADMA support"
 	depends on ARCH_IOP32X || ARCH_IOP33X || ARCH_IOP13XX
-	select ASYNC_CORE
 	select DMA_ENGINE
 	help
 	  Enable support for the Intel(R) IOP Series RAID engines.
@@ -59,7 +58,6 @@ config FSL_DMA
 config MV_XOR
 	bool "Marvell XOR engine support"
 	depends on PLAT_ORION
-	select ASYNC_CORE
 	select DMA_ENGINE
 	---help---
 	  Enable support for the Marvell XOR engine.
diff --git a/drivers/dma/dmaengine.c b/drivers/dma/dmaengine.c
index 5317e08..5410c04 100644
--- a/drivers/dma/dmaengine.c
+++ b/drivers/dma/dmaengine.c
@@ -623,6 +623,81 @@ void dma_async_tx_descriptor_init(struct dma_async_tx_descriptor *tx,
 }
 EXPORT_SYMBOL(dma_async_tx_descriptor_init);
 
+/* dma_wait_for_async_tx - spin wait for a transcation to complete
+ * @tx: transaction to wait on
+ */
+enum dma_status
+dma_wait_for_async_tx(struct dma_async_tx_descriptor *tx)
+{
+	enum dma_status status;
+	struct dma_async_tx_descriptor *iter;
+	struct dma_async_tx_descriptor *parent;
+
+	if (!tx)
+		return DMA_SUCCESS;
+
+	/* poll through the dependency chain, return when tx is complete */
+	do {
+		iter = tx;
+
+		/* find the root of the unsubmitted dependency chain */
+		do {
+			parent = iter->parent;
+			if (!parent)
+				break;
+			else
+				iter = parent;
+		} while (parent);
+
+		/* there is a small window for ->parent == NULL and
+		 * ->cookie == -EBUSY
+		 */
+		while (iter->cookie == -EBUSY)
+			cpu_relax();
+
+		status = dma_sync_wait(iter->chan, iter->cookie);
+	} while (status == DMA_IN_PROGRESS || (iter != tx));
+
+	return status;
+}
+EXPORT_SYMBOL_GPL(dma_wait_for_async_tx);
+
+/* dma_run_dependencies - helper routine for dma drivers to process
+ *	(start) dependent operations on their target channel
+ * @tx: transaction with dependencies
+ */
+void dma_run_dependencies(struct dma_async_tx_descriptor *tx)
+{
+	struct dma_async_tx_descriptor *dep = tx->next;
+	struct dma_async_tx_descriptor *dep_next;
+	struct dma_chan *chan;
+
+	if (!dep)
+		return;
+
+	chan = dep->chan;
+
+	/* keep submitting up until a channel switch is detected
+	 * in that case we will be called again as a result of
+	 * processing the interrupt from async_tx_channel_switch
+	 */
+	for (; dep; dep = dep_next) {
+		spin_lock_bh(&dep->lock);
+		dep->parent = NULL;
+		dep_next = dep->next;
+		if (dep_next && dep_next->chan == chan)
+			dep->next = NULL; /* ->next will be submitted */
+		else
+			dep_next = NULL; /* submit current dep and terminate */
+		spin_unlock_bh(&dep->lock);
+
+		dep->tx_submit(dep);
+	}
+
+	chan->device->device_issue_pending(chan);
+}
+EXPORT_SYMBOL_GPL(dma_run_dependencies);
+
 static int __init dma_bus_init(void)
 {
 	mutex_init(&dma_list_mutex);
diff --git a/drivers/dma/iop-adma.c b/drivers/dma/iop-adma.c
index c7a9306..f008ab2 100644
--- a/drivers/dma/iop-adma.c
+++ b/drivers/dma/iop-adma.c
@@ -24,7 +24,6 @@
 
 #include <linux/init.h>
 #include <linux/module.h>
-#include <linux/async_tx.h>
 #include <linux/delay.h>
 #include <linux/dma-mapping.h>
 #include <linux/spinlock.h>
@@ -106,7 +105,7 @@ iop_adma_run_tx_complete_actions(struct iop_adma_desc_slot *desc,
 	}
 
 	/* run dependent operations */
-	async_tx_run_dependencies(&desc->async_tx);
+	dma_run_dependencies(&desc->async_tx);
 
 	return cookie;
 }
diff --git a/drivers/dma/mv_xor.c b/drivers/dma/mv_xor.c
index 0328da0..c3fcaa8 100644
--- a/drivers/dma/mv_xor.c
+++ b/drivers/dma/mv_xor.c
@@ -18,7 +18,6 @@
 
 #include <linux/init.h>
 #include <linux/module.h>
-#include <linux/async_tx.h>
 #include <linux/delay.h>
 #include <linux/dma-mapping.h>
 #include <linux/spinlock.h>
@@ -331,7 +330,7 @@ mv_xor_run_tx_complete_actions(struct mv_xor_desc_slot *desc,
 	}
 
 	/* run dependent operations */
-	async_tx_run_dependencies(&desc->async_tx);
+	dma_run_dependencies(&desc->async_tx);
 
 	return cookie;
 }
diff --git a/include/linux/async_tx.h b/include/linux/async_tx.h
index 0f50d4c..1c81677 100644
--- a/include/linux/async_tx.h
+++ b/include/linux/async_tx.h
@@ -60,8 +60,6 @@ enum async_tx_flags {
 
 #ifdef CONFIG_DMA_ENGINE
 void async_tx_issue_pending_all(void);
-enum dma_status dma_wait_for_async_tx(struct dma_async_tx_descriptor *tx);
-void async_tx_run_dependencies(struct dma_async_tx_descriptor *tx);
 #ifdef CONFIG_ARCH_HAS_ASYNC_TX_FIND_CHANNEL
 #include <asm/async_tx.h>
 #else
@@ -77,19 +75,6 @@ static inline void async_tx_issue_pending_all(void)
 	do { } while (0);
 }
 
-static inline enum dma_status
-dma_wait_for_async_tx(struct dma_async_tx_descriptor *tx)
-{
-	return DMA_SUCCESS;
-}
-
-static inline void
-async_tx_run_dependencies(struct dma_async_tx_descriptor *tx,
-	struct dma_chan *host_chan)
-{
-	do { } while (0);
-}
-
 static inline struct dma_chan *
 async_tx_find_channel(struct dma_async_tx_descriptor *depend_tx,
 	enum dma_transaction_type tx_type, struct page **dst, int dst_count,
diff --git a/include/linux/dmaengine.h b/include/linux/dmaengine.h
index adb0b08..e4ec7e7 100644
--- a/include/linux/dmaengine.h
+++ b/include/linux/dmaengine.h
@@ -475,11 +475,20 @@ static inline enum dma_status dma_async_is_complete(dma_cookie_t cookie,
 }
 
 enum dma_status dma_sync_wait(struct dma_chan *chan, dma_cookie_t cookie);
+#ifdef CONFIG_DMA_ENGINE
+enum dma_status dma_wait_for_async_tx(struct dma_async_tx_descriptor *tx);
+#else
+static inline enum dma_status dma_wait_for_async_tx(struct dma_async_tx_descriptor *tx)
+{
+	return DMA_SUCCESS;
+}
+#endif
 
 /* --- DMA device --- */
 
 int dma_async_device_register(struct dma_device *device);
 void dma_async_device_unregister(struct dma_device *device);
+void dma_run_dependencies(struct dma_async_tx_descriptor *tx);
 
 /* --- Helper iov-locking functions --- */
 


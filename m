From: Mika Westerberg <mika.westerberg@linux.intel.com>
Subject: [PATCH v3 10/19] thunderbolt: Export ring handling functions to modules
Date: Mon,  2 Oct 2017 13:38:37 +0300
Message-ID: <20171002103846.64602-11-mika.westerberg@linux.intel.com>
References: <20171002103846.64602-1-mika.westerberg@linux.intel.com>
Cc: Andreas Noever <andreas.noever@gmail.com>,
        Michael Jamet <michael.jamet@intel.com>,
        Yehezkel Bernat <yehezkel.bernat@intel.com>,
        Amir Levy <amir.jer.levy@intel.com>,
        Mario.Limonciello@dell.com, Lukas Wunner <lukas@wunner.de>,
        Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Mika Westerberg <mika.westerberg@linux.intel.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171002103846.64602-1-mika.westerberg@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These are used by Thunderbolt services to send and receive frames over
the high-speed DMA rings.

We also put the functions to tb_ namespace to make sure we do not
collide with others and add missing kernel-doc comments for the exported
functions.

Signed-off-by: Mika Westerberg <mika.westerberg@linux.intel.com>
Reviewed-by: Michael Jamet <michael.jamet@intel.com>
Reviewed-by: Yehezkel Bernat <yehezkel.bernat@intel.com>
Reviewed-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 drivers/thunderbolt/ctl.c   |  20 +++---
 drivers/thunderbolt/nhi.c   |  62 +++++++++++------
 drivers/thunderbolt/nhi.h   | 147 +----------------------------------------
 include/linux/thunderbolt.h | 158 ++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 211 insertions(+), 176 deletions(-)

diff --git a/drivers/thunderbolt/ctl.c b/drivers/thunderbolt/ctl.c
index 05400b77dcd7..dd10789e1dbb 100644
--- a/drivers/thunderbolt/ctl.c
+++ b/drivers/thunderbolt/ctl.c
@@ -359,7 +359,7 @@ static int tb_ctl_tx(struct tb_ctl *ctl, const void *data, size_t len,
 	cpu_to_be32_array(pkg->buffer, data, len / 4);
 	*(__be32 *) (pkg->buffer + len) = tb_crc(pkg->buffer, len);
 
-	res = ring_tx(ctl->tx, &pkg->frame);
+	res = tb_ring_tx(ctl->tx, &pkg->frame);
 	if (res) /* ring is stopped */
 		tb_ctl_pkg_free(pkg);
 	return res;
@@ -376,7 +376,7 @@ static bool tb_ctl_handle_event(struct tb_ctl *ctl, enum tb_cfg_pkg_type type,
 
 static void tb_ctl_rx_submit(struct ctl_pkg *pkg)
 {
-	ring_rx(pkg->ctl->rx, &pkg->frame); /*
+	tb_ring_rx(pkg->ctl->rx, &pkg->frame); /*
 					     * We ignore failures during stop.
 					     * All rx packets are referenced
 					     * from ctl->rx_packets, so we do
@@ -614,11 +614,11 @@ struct tb_ctl *tb_ctl_alloc(struct tb_nhi *nhi, event_cb cb, void *cb_data)
 	if (!ctl->frame_pool)
 		goto err;
 
-	ctl->tx = ring_alloc_tx(nhi, 0, 10, RING_FLAG_NO_SUSPEND);
+	ctl->tx = tb_ring_alloc_tx(nhi, 0, 10, RING_FLAG_NO_SUSPEND);
 	if (!ctl->tx)
 		goto err;
 
-	ctl->rx = ring_alloc_rx(nhi, 0, 10, RING_FLAG_NO_SUSPEND, 0xffff,
+	ctl->rx = tb_ring_alloc_rx(nhi, 0, 10, RING_FLAG_NO_SUSPEND, 0xffff,
 				0xffff);
 	if (!ctl->rx)
 		goto err;
@@ -652,9 +652,9 @@ void tb_ctl_free(struct tb_ctl *ctl)
 		return;
 
 	if (ctl->rx)
-		ring_free(ctl->rx);
+		tb_ring_free(ctl->rx);
 	if (ctl->tx)
-		ring_free(ctl->tx);
+		tb_ring_free(ctl->tx);
 
 	/* free RX packets */
 	for (i = 0; i < TB_CTL_RX_PKG_COUNT; i++)
@@ -673,8 +673,8 @@ void tb_ctl_start(struct tb_ctl *ctl)
 {
 	int i;
 	tb_ctl_info(ctl, "control channel starting...\n");
-	ring_start(ctl->tx); /* is used to ack hotplug packets, start first */
-	ring_start(ctl->rx);
+	tb_ring_start(ctl->tx); /* is used to ack hotplug packets, start first */
+	tb_ring_start(ctl->rx);
 	for (i = 0; i < TB_CTL_RX_PKG_COUNT; i++)
 		tb_ctl_rx_submit(ctl->rx_packets[i]);
 
@@ -695,8 +695,8 @@ void tb_ctl_stop(struct tb_ctl *ctl)
 	ctl->running = false;
 	mutex_unlock(&ctl->request_queue_lock);
 
-	ring_stop(ctl->rx);
-	ring_stop(ctl->tx);
+	tb_ring_stop(ctl->rx);
+	tb_ring_stop(ctl->tx);
 
 	if (!list_empty(&ctl->request_queue))
 		tb_ctl_WARN(ctl, "dangling request in request_queue\n");
diff --git a/drivers/thunderbolt/nhi.c b/drivers/thunderbolt/nhi.c
index bebcad3d2c1f..e0a47f7581cb 100644
--- a/drivers/thunderbolt/nhi.c
+++ b/drivers/thunderbolt/nhi.c
@@ -253,7 +253,7 @@ static void ring_work(struct work_struct *work)
 	}
 }
 
-int __ring_enqueue(struct tb_ring *ring, struct ring_frame *frame)
+int __tb_ring_enqueue(struct tb_ring *ring, struct ring_frame *frame)
 {
 	int ret = 0;
 	mutex_lock(&ring->lock);
@@ -266,6 +266,7 @@ int __ring_enqueue(struct tb_ring *ring, struct ring_frame *frame)
 	mutex_unlock(&ring->lock);
 	return ret;
 }
+EXPORT_SYMBOL_GPL(__tb_ring_enqueue);
 
 static irqreturn_t ring_msix(int irq, void *data)
 {
@@ -309,9 +310,9 @@ static void ring_release_msix(struct tb_ring *ring)
 	ring->irq = 0;
 }
 
-static struct tb_ring *ring_alloc(struct tb_nhi *nhi, u32 hop, int size,
-				  bool transmit, unsigned int flags,
-				  u16 sof_mask, u16 eof_mask)
+static struct tb_ring *tb_ring_alloc(struct tb_nhi *nhi, u32 hop, int size,
+				     bool transmit, unsigned int flags,
+				     u16 sof_mask, u16 eof_mask)
 {
 	struct tb_ring *ring = NULL;
 	dev_info(&nhi->pdev->dev, "allocating %s ring %d of size %d\n",
@@ -377,24 +378,42 @@ static struct tb_ring *ring_alloc(struct tb_nhi *nhi, u32 hop, int size,
 	return NULL;
 }
 
-struct tb_ring *ring_alloc_tx(struct tb_nhi *nhi, int hop, int size,
-			      unsigned int flags)
+/**
+ * tb_ring_alloc_tx() - Allocate DMA ring for transmit
+ * @nhi: Pointer to the NHI the ring is to be allocated
+ * @hop: HopID (ring) to allocate
+ * @size: Number of entries in the ring
+ * @flags: Flags for the ring
+ */
+struct tb_ring *tb_ring_alloc_tx(struct tb_nhi *nhi, int hop, int size,
+				 unsigned int flags)
 {
-	return ring_alloc(nhi, hop, size, true, flags, 0, 0);
+	return tb_ring_alloc(nhi, hop, size, true, flags, 0, 0);
 }
+EXPORT_SYMBOL_GPL(tb_ring_alloc_tx);
 
-struct tb_ring *ring_alloc_rx(struct tb_nhi *nhi, int hop, int size,
-			      unsigned int flags, u16 sof_mask, u16 eof_mask)
+/**
+ * tb_ring_alloc_rx() - Allocate DMA ring for receive
+ * @nhi: Pointer to the NHI the ring is to be allocated
+ * @hop: HopID (ring) to allocate
+ * @size: Number of entries in the ring
+ * @flags: Flags for the ring
+ * @sof_mask: Mask of PDF values that start a frame
+ * @eof_mask: Mask of PDF values that end a frame
+ */
+struct tb_ring *tb_ring_alloc_rx(struct tb_nhi *nhi, int hop, int size,
+				 unsigned int flags, u16 sof_mask, u16 eof_mask)
 {
-	return ring_alloc(nhi, hop, size, false, flags, sof_mask, eof_mask);
+	return tb_ring_alloc(nhi, hop, size, false, flags, sof_mask, eof_mask);
 }
+EXPORT_SYMBOL_GPL(tb_ring_alloc_rx);
 
 /**
- * ring_start() - enable a ring
+ * tb_ring_start() - enable a ring
  *
- * Must not be invoked in parallel with ring_stop().
+ * Must not be invoked in parallel with tb_ring_stop().
  */
-void ring_start(struct tb_ring *ring)
+void tb_ring_start(struct tb_ring *ring)
 {
 	u16 frame_size;
 	u32 flags;
@@ -450,21 +469,22 @@ void ring_start(struct tb_ring *ring)
 	mutex_unlock(&ring->lock);
 	mutex_unlock(&ring->nhi->lock);
 }
-
+EXPORT_SYMBOL_GPL(tb_ring_start);
 
 /**
- * ring_stop() - shutdown a ring
+ * tb_ring_stop() - shutdown a ring
  *
  * Must not be invoked from a callback.
  *
- * This method will disable the ring. Further calls to ring_tx/ring_rx will
- * return -ESHUTDOWN until ring_stop has been called.
+ * This method will disable the ring. Further calls to
+ * tb_ring_tx/tb_ring_rx will return -ESHUTDOWN until ring_stop has been
+ * called.
  *
  * All enqueued frames will be canceled and their callbacks will be executed
  * with frame->canceled set to true (on the callback thread). This method
  * returns only after all callback invocations have finished.
  */
-void ring_stop(struct tb_ring *ring)
+void tb_ring_stop(struct tb_ring *ring)
 {
 	mutex_lock(&ring->nhi->lock);
 	mutex_lock(&ring->lock);
@@ -497,9 +517,10 @@ void ring_stop(struct tb_ring *ring)
 	schedule_work(&ring->work);
 	flush_work(&ring->work);
 }
+EXPORT_SYMBOL_GPL(tb_ring_stop);
 
 /*
- * ring_free() - free ring
+ * tb_ring_free() - free ring
  *
  * When this method returns all invocations of ring->callback will have
  * finished.
@@ -508,7 +529,7 @@ void ring_stop(struct tb_ring *ring)
  *
  * Must NOT be called from ring_frame->callback!
  */
-void ring_free(struct tb_ring *ring)
+void tb_ring_free(struct tb_ring *ring)
 {
 	mutex_lock(&ring->nhi->lock);
 	/*
@@ -550,6 +571,7 @@ void ring_free(struct tb_ring *ring)
 	mutex_destroy(&ring->lock);
 	kfree(ring);
 }
+EXPORT_SYMBOL_GPL(tb_ring_free);
 
 /**
  * nhi_mailbox_cmd() - Send a command through NHI mailbox
diff --git a/drivers/thunderbolt/nhi.h b/drivers/thunderbolt/nhi.h
index 4503ddbeccb3..771d09ca5dc5 100644
--- a/drivers/thunderbolt/nhi.h
+++ b/drivers/thunderbolt/nhi.h
@@ -7,152 +7,7 @@
 #ifndef DSL3510_H_
 #define DSL3510_H_
 
-#include <linux/idr.h>
-#include <linux/mutex.h>
-#include <linux/workqueue.h>
-
-/**
- * struct tb_nhi - thunderbolt native host interface
- * @lock: Must be held during ring creation/destruction. Is acquired by
- *	  interrupt_work when dispatching interrupts to individual rings.
- * @pdev: Pointer to the PCI device
- * @iobase: MMIO space of the NHI
- * @tx_rings: All Tx rings available on this host controller
- * @rx_rings: All Rx rings available on this host controller
- * @msix_ida: Used to allocate MSI-X vectors for rings
- * @going_away: The host controller device is about to disappear so when
- *		this flag is set, avoid touching the hardware anymore.
- * @interrupt_work: Work scheduled to handle ring interrupt when no
- *		    MSI-X is used.
- * @hop_count: Number of rings (end point hops) supported by NHI.
- */
-struct tb_nhi {
-	struct mutex lock;
-	struct pci_dev *pdev;
-	void __iomem *iobase;
-	struct tb_ring **tx_rings;
-	struct tb_ring **rx_rings;
-	struct ida msix_ida;
-	bool going_away;
-	struct work_struct interrupt_work;
-	u32 hop_count;
-};
-
-/**
- * struct tb_ring - thunderbolt TX or RX ring associated with a NHI
- * @lock: Lock serializing actions to this ring. Must be acquired after
- *	  nhi->lock.
- * @nhi: Pointer to the native host controller interface
- * @size: Size of the ring
- * @hop: Hop (DMA channel) associated with this ring
- * @head: Head of the ring (write next descriptor here)
- * @tail: Tail of the ring (complete next descriptor here)
- * @descriptors: Allocated descriptors for this ring
- * @queue: Queue holding frames to be transferred over this ring
- * @in_flight: Queue holding frames that are currently in flight
- * @work: Interrupt work structure
- * @is_tx: Is the ring Tx or Rx
- * @running: Is the ring running
- * @irq: MSI-X irq number if the ring uses MSI-X. %0 otherwise.
- * @vector: MSI-X vector number the ring uses (only set if @irq is > 0)
- * @flags: Ring specific flags
- * @sof_mask: Bit mask used to detect start of frame PDF
- * @eof_mask: Bit mask used to detect end of frame PDF
- */
-struct tb_ring {
-	struct mutex lock;
-	struct tb_nhi *nhi;
-	int size;
-	int hop;
-	int head;
-	int tail;
-	struct ring_desc *descriptors;
-	dma_addr_t descriptors_dma;
-	struct list_head queue;
-	struct list_head in_flight;
-	struct work_struct work;
-	bool is_tx:1;
-	bool running:1;
-	int irq;
-	u8 vector;
-	unsigned int flags;
-	u16 sof_mask;
-	u16 eof_mask;
-};
-
-/* Leave ring interrupt enabled on suspend */
-#define RING_FLAG_NO_SUSPEND	BIT(0)
-/* Configure the ring to be in frame mode */
-#define RING_FLAG_FRAME		BIT(1)
-/* Enable end-to-end flow control */
-#define RING_FLAG_E2E		BIT(2)
-
-struct ring_frame;
-typedef void (*ring_cb)(struct tb_ring*, struct ring_frame*, bool canceled);
-
-/**
- * struct ring_frame - for use with ring_rx/ring_tx
- */
-struct ring_frame {
-	dma_addr_t buffer_phy;
-	ring_cb callback;
-	struct list_head list;
-	u32 size:12; /* TX: in, RX: out*/
-	u32 flags:12; /* RX: out */
-	u32 eof:4; /* TX:in, RX: out */
-	u32 sof:4; /* TX:in, RX: out */
-};
-
-#define TB_FRAME_SIZE 0x100    /* minimum size for ring_rx */
-
-struct tb_ring *ring_alloc_tx(struct tb_nhi *nhi, int hop, int size,
-			      unsigned int flags);
-struct tb_ring *ring_alloc_rx(struct tb_nhi *nhi, int hop, int size,
-			      unsigned int flags, u16 sof_mask, u16 eof_mask);
-void ring_start(struct tb_ring *ring);
-void ring_stop(struct tb_ring *ring);
-void ring_free(struct tb_ring *ring);
-
-int __ring_enqueue(struct tb_ring *ring, struct ring_frame *frame);
-
-/**
- * ring_rx() - enqueue a frame on an RX ring
- *
- * frame->buffer, frame->buffer_phy and frame->callback have to be set. The
- * buffer must contain at least TB_FRAME_SIZE bytes.
- *
- * frame->callback will be invoked with frame->size, frame->flags, frame->eof,
- * frame->sof set once the frame has been received.
- *
- * If ring_stop is called after the packet has been enqueued frame->callback
- * will be called with canceled set to true.
- *
- * Return: Returns ESHUTDOWN if ring_stop has been called. Zero otherwise.
- */
-static inline int ring_rx(struct tb_ring *ring, struct ring_frame *frame)
-{
-	WARN_ON(ring->is_tx);
-	return __ring_enqueue(ring, frame);
-}
-
-/**
- * ring_tx() - enqueue a frame on an TX ring
- *
- * frame->buffer, frame->buffer_phy, frame->callback, frame->size, frame->eof
- * and frame->sof have to be set.
- *
- * frame->callback will be invoked with once the frame has been transmitted.
- *
- * If ring_stop is called after the packet has been enqueued frame->callback
- * will be called with canceled set to true.
- *
- * Return: Returns ESHUTDOWN if ring_stop has been called. Zero otherwise.
- */
-static inline int ring_tx(struct tb_ring *ring, struct ring_frame *frame)
-{
-	WARN_ON(!ring->is_tx);
-	return __ring_enqueue(ring, frame);
-}
+#include <linux/thunderbolt.h>
 
 enum nhi_fw_mode {
 	NHI_FW_SAFE_MODE,
diff --git a/include/linux/thunderbolt.h b/include/linux/thunderbolt.h
index 18c0e3d5e85c..9ddb83ad890f 100644
--- a/include/linux/thunderbolt.h
+++ b/include/linux/thunderbolt.h
@@ -15,10 +15,12 @@
 #define THUNDERBOLT_H_
 
 #include <linux/device.h>
+#include <linux/idr.h>
 #include <linux/list.h>
 #include <linux/mutex.h>
 #include <linux/mod_devicetable.h>
 #include <linux/uuid.h>
+#include <linux/workqueue.h>
 
 enum tb_cfg_pkg_type {
 	TB_CFG_PKG_READ = 1,
@@ -397,4 +399,160 @@ static inline struct tb_xdomain *tb_service_parent(struct tb_service *svc)
 	return tb_to_xdomain(svc->dev.parent);
 }
 
+/**
+ * struct tb_nhi - thunderbolt native host interface
+ * @lock: Must be held during ring creation/destruction. Is acquired by
+ *	  interrupt_work when dispatching interrupts to individual rings.
+ * @pdev: Pointer to the PCI device
+ * @iobase: MMIO space of the NHI
+ * @tx_rings: All Tx rings available on this host controller
+ * @rx_rings: All Rx rings available on this host controller
+ * @msix_ida: Used to allocate MSI-X vectors for rings
+ * @going_away: The host controller device is about to disappear so when
+ *		this flag is set, avoid touching the hardware anymore.
+ * @interrupt_work: Work scheduled to handle ring interrupt when no
+ *		    MSI-X is used.
+ * @hop_count: Number of rings (end point hops) supported by NHI.
+ */
+struct tb_nhi {
+	struct mutex lock;
+	struct pci_dev *pdev;
+	void __iomem *iobase;
+	struct tb_ring **tx_rings;
+	struct tb_ring **rx_rings;
+	struct ida msix_ida;
+	bool going_away;
+	struct work_struct interrupt_work;
+	u32 hop_count;
+};
+
+/**
+ * struct tb_ring - thunderbolt TX or RX ring associated with a NHI
+ * @lock: Lock serializing actions to this ring. Must be acquired after
+ *	  nhi->lock.
+ * @nhi: Pointer to the native host controller interface
+ * @size: Size of the ring
+ * @hop: Hop (DMA channel) associated with this ring
+ * @head: Head of the ring (write next descriptor here)
+ * @tail: Tail of the ring (complete next descriptor here)
+ * @descriptors: Allocated descriptors for this ring
+ * @queue: Queue holding frames to be transferred over this ring
+ * @in_flight: Queue holding frames that are currently in flight
+ * @work: Interrupt work structure
+ * @is_tx: Is the ring Tx or Rx
+ * @running: Is the ring running
+ * @irq: MSI-X irq number if the ring uses MSI-X. %0 otherwise.
+ * @vector: MSI-X vector number the ring uses (only set if @irq is > 0)
+ * @flags: Ring specific flags
+ * @sof_mask: Bit mask used to detect start of frame PDF
+ * @eof_mask: Bit mask used to detect end of frame PDF
+ */
+struct tb_ring {
+	struct mutex lock;
+	struct tb_nhi *nhi;
+	int size;
+	int hop;
+	int head;
+	int tail;
+	struct ring_desc *descriptors;
+	dma_addr_t descriptors_dma;
+	struct list_head queue;
+	struct list_head in_flight;
+	struct work_struct work;
+	bool is_tx:1;
+	bool running:1;
+	int irq;
+	u8 vector;
+	unsigned int flags;
+	u16 sof_mask;
+	u16 eof_mask;
+};
+
+/* Leave ring interrupt enabled on suspend */
+#define RING_FLAG_NO_SUSPEND	BIT(0)
+/* Configure the ring to be in frame mode */
+#define RING_FLAG_FRAME		BIT(1)
+/* Enable end-to-end flow control */
+#define RING_FLAG_E2E		BIT(2)
+
+struct ring_frame;
+typedef void (*ring_cb)(struct tb_ring *, struct ring_frame *, bool canceled);
+
+/**
+ * struct ring_frame - For use with ring_rx/ring_tx
+ * @buffer_phy: DMA mapped address of the frame
+ * @callback: Callback called when the frame is finished
+ * @list: Frame is linked to a queue using this
+ * @size: Size of the frame in bytes (%0 means %4096)
+ * @flags: Flags for the frame (see &enum ring_desc_flags)
+ * @eof: End of frame protocol defined field
+ * @sof: Start of frame protocol defined field
+ */
+struct ring_frame {
+	dma_addr_t buffer_phy;
+	ring_cb callback;
+	struct list_head list;
+	u32 size:12;
+	u32 flags:12;
+	u32 eof:4;
+	u32 sof:4;
+};
+
+/* Minimum size for ring_rx */
+#define TB_FRAME_SIZE		0x100
+
+struct tb_ring *tb_ring_alloc_tx(struct tb_nhi *nhi, int hop, int size,
+				 unsigned int flags);
+struct tb_ring *tb_ring_alloc_rx(struct tb_nhi *nhi, int hop, int size,
+				 unsigned int flags, u16 sof_mask,
+				 u16 eof_mask);
+void tb_ring_start(struct tb_ring *ring);
+void tb_ring_stop(struct tb_ring *ring);
+void tb_ring_free(struct tb_ring *ring);
+
+int __tb_ring_enqueue(struct tb_ring *ring, struct ring_frame *frame);
+
+/**
+ * tb_ring_rx() - enqueue a frame on an RX ring
+ * @ring: Ring to enqueue the frame
+ * @frame: Frame to enqueue
+ *
+ * @frame->buffer, @frame->buffer_phy and @frame->callback have to be set. The
+ * buffer must contain at least %TB_FRAME_SIZE bytes.
+ *
+ * @frame->callback will be invoked with @frame->size, @frame->flags,
+ * @frame->eof, @frame->sof set once the frame has been received.
+ *
+ * If ring_stop() is called after the packet has been enqueued
+ * @frame->callback will be called with canceled set to true.
+ *
+ * Return: Returns %-ESHUTDOWN if ring_stop has been called. Zero otherwise.
+ */
+static inline int tb_ring_rx(struct tb_ring *ring, struct ring_frame *frame)
+{
+	WARN_ON(ring->is_tx);
+	return __tb_ring_enqueue(ring, frame);
+}
+
+/**
+ * tb_ring_tx() - enqueue a frame on an TX ring
+ * @ring: Ring the enqueue the frame
+ * @frame: Frame to enqueue
+ *
+ * @frame->buffer, @frame->buffer_phy, @frame->callback, @frame->size,
+ * @frame->eof and @frame->sof have to be set.
+ *
+ * @frame->callback will be invoked with once the frame has been transmitted.
+ *
+ * If ring_stop() is called after the packet has been enqueued @frame->callback
+ * will be called with canceled set to true.
+ *
+ * Return: Returns %-ESHUTDOWN if ring_stop has been called. Zero otherwise.
+ */
+static inline int tb_ring_tx(struct tb_ring *ring, struct ring_frame *frame)
+{
+	WARN_ON(!ring->is_tx);
+	return __tb_ring_enqueue(ring, frame);
+}
+
 #endif /* THUNDERBOLT_H_ */
-- 
2.14.2

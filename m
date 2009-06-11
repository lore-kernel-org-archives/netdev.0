From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [2.6.31 17/21] wimax/i2400m/sdio: Move all the RX code to a unified, IRQ based receive routine
Date: Thu, 11 Jun 2009 14:35:54 -0700
Message-ID: <16820c166d3ad5973d388b5aa70ee7e535386657.1244755662.git.inaky@linux.intel.com>
References: <cover.1244755662.git.inaky@linux.intel.com>
Cc: Dirk Brandewie <dirk.j.brandewie@intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:17677 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756412AbZFKVgv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2009 17:36:51 -0400
In-Reply-To: <cover.1244755662.git.inaky@linux.intel.com>
In-Reply-To: <cover.1244755662.git.inaky@linux.intel.com>
References: <cover.1244755662.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current SDIO code was working in polling mode for boot-mode
(firmware load) mode. This was causing issues on some hardware.

Moved all the RX code to use a unified IRQ handler that based on the
type of data the device is sending can discriminate and decide which
is the right destination.

As well, all the reads from the device are made to be at least the
block size (256); the driver will ignore the rest when not needed.

Signed-off-by: Dirk Brandewie <dirk.j.brandewie@intel.com>
Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/i2400m-sdio.h |    7 ++
 drivers/net/wimax/i2400m/sdio-fw.c     |  109 ++++++++++++++------------------
 drivers/net/wimax/i2400m/sdio-rx.c     |   47 +++++++++++---
 drivers/net/wimax/i2400m/sdio.c        |   18 +++--
 4 files changed, 101 insertions(+), 80 deletions(-)

diff --git a/drivers/net/wimax/i2400m/i2400m-sdio.h b/drivers/net/wimax/i2400m/i2400m-sdio.h
index 2071721..9c4e318 100644
--- a/drivers/net/wimax/i2400m/i2400m-sdio.h
+++ b/drivers/net/wimax/i2400m/i2400m-sdio.h
@@ -107,6 +107,10 @@ struct i2400ms {
 	char tx_wq_name[32];
 
 	struct dentry *debugfs_dentry;
+
+	wait_queue_head_t bm_wfa_wq;
+	int bm_wait_result;
+	size_t bm_ack_size;
 };
 
 
@@ -131,4 +135,7 @@ extern ssize_t i2400ms_bus_bm_cmd_send(struct i2400m *,
 extern ssize_t i2400ms_bus_bm_wait_for_ack(struct i2400m *,
 					   struct i2400m_bootrom_header *,
 					   size_t);
+extern void i2400ms_bus_bm_release(struct i2400m *);
+extern int i2400ms_bus_bm_setup(struct i2400m *);
+
 #endif /* #ifndef __I2400M_SDIO_H__ */
diff --git a/drivers/net/wimax/i2400m/sdio-fw.c b/drivers/net/wimax/i2400m/sdio-fw.c
index 3487205..7d6ec0f 100644
--- a/drivers/net/wimax/i2400m/sdio-fw.c
+++ b/drivers/net/wimax/i2400m/sdio-fw.c
@@ -46,17 +46,24 @@
  * Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>
  *  - SDIO rehash for changes in the bus-driver model
  *
+ * Dirk Brandewie <dirk.j.brandewie@intel.com>
+ *  - Make it IRQ based, not polling
+ *
  * THE PROCEDURE
  *
  * See fw.c for the generic description of this procedure.
  *
  * This file implements only the SDIO specifics. It boils down to how
  * to send a command and waiting for an acknowledgement from the
- * device. We do polled reads.
+ * device.
+ *
+ * All this code is sequential -- all i2400ms_bus_bm_*() functions are
+ * executed in the same thread, except i2400ms_bm_irq() [on its own by
+ * the SDIO driver]. This makes it possible to avoid locking.
  *
  * COMMAND EXECUTION
  *
- * THe generic firmware upload code will call i2400m_bus_bm_cmd_send()
+ * The generic firmware upload code will call i2400m_bus_bm_cmd_send()
  * to send commands.
  *
  * The SDIO devices expects things in 256 byte blocks, so it will pad
@@ -64,12 +71,15 @@
  *
  * ACK RECEPTION
  *
- * This works in polling mode -- the fw loader says when to wait for
- * data and for that it calls i2400ms_bus_bm_wait_for_ack().
+ * This works in IRQ mode -- the fw loader says when to wait for data
+ * and for that it calls i2400ms_bus_bm_wait_for_ack().
  *
- * This will poll the device for data until it is received. We need to
- * receive at least as much bytes as where asked for (although it'll
- * always be a multiple of 256 bytes).
+ * This checks if there is any data available (RX size > 0); if not,
+ * waits for the IRQ handler to notify about it. Once there is data,
+ * it is read and passed to the caller. Doing it this way we don't
+ * need much coordination/locking, and it makes it much more difficult
+ * for an interrupt to be lost and the wait_for_ack() function getting
+ * stuck even when data is pending.
  */
 #include <linux/mmc/sdio_func.h>
 #include "i2400m-sdio.h"
@@ -78,6 +88,7 @@
 #define D_SUBMODULE fw
 #include "sdio-debug-levels.h"
 
+
 /*
  * Send a boot-mode command to the SDIO function
  *
@@ -139,7 +150,7 @@ error_too_big:
 
 
 /*
- * Read an ack from the device's boot-mode (polling)
+ * Read an ack from the device's boot-mode
  *
  * @i2400m:
  * @_ack: pointer to where to store the read data
@@ -150,75 +161,49 @@ error_too_big:
  * The ACK for a BM command is always at least sizeof(*ack) bytes, so
  * check for that. We don't need to check for device reboots
  *
- * NOTE: We do an artificial timeout of 1 sec over the SDIO timeout;
- *     this way we have control over it...there is no way that I know
- *     of setting an SDIO transaction timeout.
  */
 ssize_t i2400ms_bus_bm_wait_for_ack(struct i2400m *i2400m,
 				    struct i2400m_bootrom_header *ack,
 				    size_t ack_size)
 {
-	int result;
-	ssize_t rx_size;
-	u64 timeout;
+	ssize_t result;
 	struct i2400ms *i2400ms = container_of(i2400m, struct i2400ms, i2400m);
 	struct sdio_func *func = i2400ms->func;
 	struct device *dev = &func->dev;
+	int size;
 
 	BUG_ON(sizeof(*ack) > ack_size);
 
 	d_fnstart(5, dev, "(i2400m %p ack %p size %zu)\n",
 		  i2400m, ack, ack_size);
 
-	timeout = get_jiffies_64() + 2 * HZ;
-	sdio_claim_host(func);
-	while (1) {
-		if (time_after64(get_jiffies_64(), timeout)) {
-			rx_size = -ETIMEDOUT;
-			dev_err(dev, "timeout waiting for ack data\n");
-			goto error_timedout;
-		}
+	spin_lock(&i2400m->rx_lock);
+	i2400ms->bm_ack_size = -EINPROGRESS;
+	spin_unlock(&i2400m->rx_lock);
 
-		/* Find the RX size, check if it fits or not -- it if
-		 * doesn't fit, fail, as we have no way to dispose of
-		 * the extra data. */
-		rx_size = __i2400ms_rx_get_size(i2400ms);
-		if (rx_size < 0)
-			goto error_rx_get_size;
-		result = -ENOSPC;		/* Check it fits */
-		if (rx_size < sizeof(*ack)) {
-			rx_size = -EIO;
-			dev_err(dev, "HW BUG? received is too small (%zu vs "
-				"%zu needed)\n", sizeof(*ack), rx_size);
-			goto error_too_small;
-		}
-		if (rx_size > I2400M_BM_ACK_BUF_SIZE) {
-			dev_err(dev, "SW BUG? BM_ACK_BUF is too small (%u vs "
-				"%zu needed)\n", I2400M_BM_ACK_BUF_SIZE,
-				rx_size);
-			goto error_too_small;
-		}
+	result = wait_event_timeout(i2400ms->bm_wfa_wq,
+				    i2400ms->bm_ack_size != -EINPROGRESS,
+				    2 * HZ);
+	if (result == 0) {
+		result = -ETIMEDOUT;
+		dev_err(dev, "BM: error waiting for an ack\n");
+		goto error_timeout;
+	}
 
-		/* Read it */
-		result = sdio_memcpy_fromio(func, i2400m->bm_ack_buf,
-					    I2400MS_DATA_ADDR, rx_size);
-		if (result == -ETIMEDOUT || result == -ETIME)
-			continue;
-		if (result < 0) {
-			dev_err(dev, "BM SDIO receive (%zu B) failed: %d\n",
-				rx_size, result);
-			goto error_read;
-		} else
-			break;
+	spin_lock(&i2400m->rx_lock);
+	result = i2400ms->bm_ack_size;
+	BUG_ON(result == -EINPROGRESS);
+	if (result < 0)        /* so we exit when rx_release() is called */
+		dev_err(dev, "BM: %s failed: %zd\n", __func__, result);
+	else {
+		size = min(ack_size, i2400ms->bm_ack_size);
+		memcpy(ack, i2400m->bm_ack_buf, size);
 	}
-	rx_size = min((ssize_t)ack_size, rx_size);
-	memcpy(ack, i2400m->bm_ack_buf, rx_size);
-error_read:
-error_too_small:
-error_rx_get_size:
-error_timedout:
-	sdio_release_host(func);
-	d_fnend(5, dev, "(i2400m %p ack %p size %zu) = %ld\n",
-		i2400m, ack, ack_size, (long) rx_size);
-	return rx_size;
+	i2400ms->bm_ack_size = -EINPROGRESS;
+	spin_unlock(&i2400m->rx_lock);
+
+error_timeout:
+	d_fnend(5, dev, "(i2400m %p ack %p size %zu) = %zd\n",
+		i2400m, ack, ack_size, result);
+	return result;
 }
diff --git a/drivers/net/wimax/i2400m/sdio-rx.c b/drivers/net/wimax/i2400m/sdio-rx.c
index a3008b9..321bead 100644
--- a/drivers/net/wimax/i2400m/sdio-rx.c
+++ b/drivers/net/wimax/i2400m/sdio-rx.c
@@ -69,6 +69,13 @@
 #define D_SUBMODULE rx
 #include "sdio-debug-levels.h"
 
+static const __le32 i2400m_ACK_BARKER[4] = {
+	__constant_cpu_to_le32(I2400M_ACK_BARKER),
+	__constant_cpu_to_le32(I2400M_ACK_BARKER),
+	__constant_cpu_to_le32(I2400M_ACK_BARKER),
+	__constant_cpu_to_le32(I2400M_ACK_BARKER)
+};
+
 
 /*
  * Read and return the amount of bytes available for RX
@@ -131,25 +138,35 @@ void i2400ms_rx(struct i2400ms *i2400ms)
 		ret = rx_size;
 		goto error_get_size;
 	}
+
 	ret = -ENOMEM;
 	skb = alloc_skb(rx_size, GFP_ATOMIC);
 	if (NULL == skb) {
 		dev_err(dev, "RX: unable to alloc skb\n");
 		goto error_alloc_skb;
 	}
-
 	ret = sdio_memcpy_fromio(func, skb->data,
 				 I2400MS_DATA_ADDR, rx_size);
 	if (ret < 0) {
 		dev_err(dev, "RX: SDIO data read failed: %d\n", ret);
 		goto error_memcpy_fromio;
 	}
-	/* Check if device has reset */
-	if (!memcmp(skb->data, i2400m_NBOOT_BARKER,
-		    sizeof(i2400m_NBOOT_BARKER))
-	    || !memcmp(skb->data, i2400m_SBOOT_BARKER,
-		       sizeof(i2400m_SBOOT_BARKER))) {
+
+	rmb();	/* make sure we get boot_mode from dev_reset_handle */
+	if (i2400m->boot_mode == 1) {
+		spin_lock(&i2400m->rx_lock);
+		i2400ms->bm_ack_size = rx_size;
+		spin_unlock(&i2400m->rx_lock);
+		memcpy(i2400m->bm_ack_buf, skb->data, rx_size);
+		wake_up(&i2400ms->bm_wfa_wq);
+		dev_err(dev, "RX: SDIO boot mode message\n");
+		kfree_skb(skb);
+	} else if (unlikely(!memcmp(skb->data, i2400m_NBOOT_BARKER,
+				    sizeof(i2400m_NBOOT_BARKER))
+			    || !memcmp(skb->data, i2400m_SBOOT_BARKER,
+				       sizeof(i2400m_SBOOT_BARKER)))) {
 		ret = i2400m_dev_reset_handle(i2400m);
+		dev_err(dev, "RX: SDIO reboot barker\n");
 		kfree_skb(skb);
 	} else {
 		skb_put(skb, rx_size);
@@ -179,7 +196,6 @@ void i2400ms_irq(struct sdio_func *func)
 {
 	int ret;
 	struct i2400ms *i2400ms = sdio_get_drvdata(func);
-	struct i2400m *i2400m = &i2400ms->i2400m;
 	struct device *dev = &func->dev;
 	int val;
 
@@ -194,10 +210,7 @@ void i2400ms_irq(struct sdio_func *func)
 		goto error_no_irq;
 	}
 	sdio_writeb(func, 1, I2400MS_INTR_CLEAR_ADDR, &ret);
-	if (WARN_ON(i2400m->boot_mode != 0))
-		dev_err(dev, "RX: SW BUG? boot mode and IRQ is up?\n");
-	else
-		i2400ms_rx(i2400ms);
+	i2400ms_rx(i2400ms);
 error_no_irq:
 	d_fnend(6, dev, "(i2400ms %p) = void\n", i2400ms);
 	return;
@@ -214,8 +227,15 @@ int i2400ms_rx_setup(struct i2400ms *i2400ms)
 	int result;
 	struct sdio_func *func = i2400ms->func;
 	struct device *dev = &func->dev;
+	struct i2400m *i2400m = &i2400ms->i2400m;
 
 	d_fnstart(5, dev, "(i2400ms %p)\n", i2400ms);
+
+	init_waitqueue_head(&i2400ms->bm_wfa_wq);
+	spin_lock(&i2400m->rx_lock);
+	i2400ms->bm_wait_result = -EINPROGRESS;
+	spin_unlock(&i2400m->rx_lock);
+
 	sdio_claim_host(func);
 	result = sdio_claim_irq(func, i2400ms_irq);
 	if (result < 0) {
@@ -245,8 +265,13 @@ void i2400ms_rx_release(struct i2400ms *i2400ms)
 	int result;
 	struct sdio_func *func = i2400ms->func;
 	struct device *dev = &func->dev;
+	struct i2400m *i2400m = &i2400ms->i2400m;
 
 	d_fnstart(5, dev, "(i2400ms %p)\n", i2400ms);
+	spin_lock(&i2400m->rx_lock);
+	i2400ms->bm_ack_size = -EINTR;
+	spin_unlock(&i2400m->rx_lock);
+	wake_up_all(&i2400ms->bm_wfa_wq);
 	sdio_claim_host(func);
 	sdio_writeb(func, 0, I2400MS_INTR_ENABLE_ADDR, &result);
 	sdio_release_irq(func);
diff --git a/drivers/net/wimax/i2400m/sdio.c b/drivers/net/wimax/i2400m/sdio.c
index 74de174..2538825 100644
--- a/drivers/net/wimax/i2400m/sdio.c
+++ b/drivers/net/wimax/i2400m/sdio.c
@@ -156,19 +156,14 @@ int i2400ms_bus_dev_start(struct i2400m *i2400m)
 
 	d_fnstart(3, dev, "(i2400m %p)\n", i2400m);
 	msleep(200);
-	result = i2400ms_rx_setup(i2400ms);
-	if (result < 0)
-		goto error_rx_setup;
 	result = i2400ms_tx_setup(i2400ms);
 	if (result < 0)
 		goto error_tx_setup;
 	d_fnend(3, dev, "(i2400m %p) = %d\n", i2400m, result);
 	return result;
 
-	i2400ms_tx_release(i2400ms);
 error_tx_setup:
-	i2400ms_rx_release(i2400ms);
-error_rx_setup:
+	i2400ms_tx_release(i2400ms);
 	d_fnend(3, dev, "(i2400m %p) = void\n", i2400m);
 	return result;
 }
@@ -182,7 +177,6 @@ void i2400ms_bus_dev_stop(struct i2400m *i2400m)
 	struct device *dev = &func->dev;
 
 	d_fnstart(3, dev, "(i2400m %p)\n", i2400m);
-	i2400ms_rx_release(i2400ms);
 	i2400ms_tx_release(i2400ms);
 	d_fnend(3, dev, "(i2400m %p) = void\n", i2400m);
 }
@@ -296,6 +290,7 @@ do_bus_reset:
 		if (i2400m->wimax_dev.net_dev->reg_state == NETREG_REGISTERED)
 			netif_tx_disable(i2400m->wimax_dev.net_dev);
 
+		i2400ms_rx_release(i2400ms);
 		sdio_claim_host(i2400ms->func);
 		sdio_disable_func(i2400ms->func);
 		sdio_release_host(i2400ms->func);
@@ -304,6 +299,8 @@ do_bus_reset:
 		msleep(40);
 
 		result = i2400ms_enable_function(i2400ms->func);
+		if (result >= 0)
+			i2400ms_rx_setup(i2400ms);
 	} else
 		BUG();
 	if (result < 0 && rt != I2400M_RT_BUS) {
@@ -449,6 +446,10 @@ int i2400ms_probe(struct sdio_func *func,
 		goto error_func_enable;
 	}
 
+	result = i2400ms_rx_setup(i2400ms);
+	if (result < 0)
+		goto error_rx_setup;
+
 	result = i2400m_setup(i2400m, I2400M_BRI_NO_REBOOT);
 	if (result < 0) {
 		dev_err(dev, "cannot setup device: %d\n", result);
@@ -466,6 +467,8 @@ int i2400ms_probe(struct sdio_func *func,
 error_debugfs_add:
 	i2400m_release(i2400m);
 error_setup:
+	i2400ms_rx_release(i2400ms);
+error_rx_setup:
 	sdio_claim_host(func);
 	sdio_disable_func(func);
 	sdio_release_host(func);
@@ -488,6 +491,7 @@ void i2400ms_remove(struct sdio_func *func)
 
 	d_fnstart(3, dev, "SDIO func %p\n", func);
 	debugfs_remove_recursive(i2400ms->debugfs_dentry);
+	i2400ms_rx_release(i2400ms);
 	i2400m_release(i2400m);
 	sdio_set_drvdata(func, NULL);
 	sdio_claim_host(func);
-- 
1.6.2.3


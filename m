From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2.6.33/3 11/13] wimax/i2400m: introduce i2400m->bus_setup/release
Date: Wed,  4 Nov 2009 13:40:02 -0800
Message-ID: <0856ccf29dfbaf957e4be80dd3eb88d97810b633.1257370736.git.inaky@linux.intel.com>
References: <cover.1257370736.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:20707 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932734AbZKDVmI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:42:08 -0500
In-Reply-To: <cover.1257370736.git.inaky@linux.intel.com>
In-Reply-To: <cover.1257370736.git.inaky@linux.intel.com>
References: <cover.1257370736.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The SDIO subdriver of the i2400m requires certain steps to be done
before we do any acces to the device, even for doing firmware upload.

This lead to a few ugly hacks, which basically involve doing those
steps in probe() before calling i2400m_setup() and undoing them in
disconnect() after claling i2400m_release(); but then, much of those
steps have to be repeated when resetting the device, suspending, etc
(in upcoming pre/post reset support).

Thus, a new pair of optional, bus-specific calls
i2400m->bus_{setup/release} are introduced. These are used to setup
basic infrastructure needed to load firmware onto the device.

This commit also updates the SDIO subdriver to use said calls.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/driver.c |   20 +++++++-
 drivers/net/wimax/i2400m/i2400m.h |   27 ++++++++++
 drivers/net/wimax/i2400m/sdio.c   |  100 +++++++++++++++++++++++-------------
 drivers/net/wimax/i2400m/usb.c    |    2 +
 4 files changed, 111 insertions(+), 38 deletions(-)

diff --git a/drivers/net/wimax/i2400m/driver.c b/drivers/net/wimax/i2400m/driver.c
index 6280646..c57020f 100644
--- a/drivers/net/wimax/i2400m/driver.c
+++ b/drivers/net/wimax/i2400m/driver.c
@@ -41,8 +41,10 @@
  *     __i2400m_dev_start()
  *
  * i2400m_setup()
+ *   i2400m->bus_setup()
  *   i2400m_bootrom_init()
  *   register_netdev()
+ *   wimax_dev_add()
  *   i2400m_dev_start()
  *     __i2400m_dev_start()
  *       i2400m_dev_bootstrap()
@@ -50,15 +52,15 @@
  *       i2400m->bus_dev_start()
  *       i2400m_firmware_check()
  *       i2400m_check_mac_addr()
- *   wimax_dev_add()
  *
  * i2400m_release()
- *   wimax_dev_rm()
  *   i2400m_dev_stop()
  *     __i2400m_dev_stop()
  *       i2400m_dev_shutdown()
  *       i2400m->bus_dev_stop()
  *       i2400m_tx_release()
+ *   i2400m->bus_release()
+ *   wimax_dev_rm()
  *   unregister_netdev()
  */
 #include "i2400m.h"
@@ -784,6 +786,15 @@ int i2400m_setup(struct i2400m *i2400m, enum i2400m_bri bm_flags)
 	snprintf(wimax_dev->name, sizeof(wimax_dev->name),
 		 "i2400m-%s:%s", dev->bus->name, dev_name(dev));
 
+	if (i2400m->bus_setup) {
+		result = i2400m->bus_setup(i2400m);
+		if (result < 0) {
+			dev_err(dev, "bus-specific setup failed: %d\n",
+				result);
+			goto error_bus_setup;
+		}
+	}
+
 	result = i2400m_bootrom_init(i2400m, bm_flags);
 	if (result < 0) {
 		dev_err(dev, "read mac addr: bootrom init "
@@ -846,6 +857,9 @@ error_register_netdev:
 	unregister_pm_notifier(&i2400m->pm_notifier);
 error_read_mac_addr:
 error_bootrom_init:
+	if (i2400m->bus_release)
+		i2400m->bus_release(i2400m);
+error_bus_setup:
 	d_fnend(3, dev, "(i2400m %p) = %d\n", i2400m, result);
 	return result;
 }
@@ -872,6 +886,8 @@ void i2400m_release(struct i2400m *i2400m)
 	wimax_dev_rm(&i2400m->wimax_dev);
 	unregister_netdev(i2400m->wimax_dev.net_dev);
 	unregister_pm_notifier(&i2400m->pm_notifier);
+	if (i2400m->bus_release)
+		i2400m->bus_release(i2400m);
 	i2400m_bm_buf_free(i2400m);
 	d_fnend(3, dev, "(i2400m %p) = void\n", i2400m);
 }
diff --git a/drivers/net/wimax/i2400m/i2400m.h b/drivers/net/wimax/i2400m/i2400m.h
index fbc156d..407d097 100644
--- a/drivers/net/wimax/i2400m/i2400m.h
+++ b/drivers/net/wimax/i2400m/i2400m.h
@@ -123,6 +123,7 @@
  *
  * bus_probe()
  *   i2400m_setup()
+ *     i2400m->bus_setup()
  *     boot rom initialization / read mac addr
  *     network / WiMAX stacks registration
  *     i2400m_dev_start()
@@ -137,6 +138,7 @@
  *       i2400m_dev_shutdown()
  *       i2400m->bus_dev_stop()
  *     network / WiMAX stack unregistration
+ *     i2400m->bus_release()
  *
  * At this point, control and data communications are possible.
  *
@@ -214,12 +216,35 @@ struct i2400m_barker_db;
  * Members marked with [fill] must be filled out/initialized before
  * calling i2400m_setup().
  *
+ * Note the @bus_setup/@bus_release, @bus_dev_start/@bus_dev_release
+ * call pairs are very much doing almost the same, and depending on
+ * the underlying bus, some stuff has to be put in one or the
+ * other. The idea of setup/release is that they setup the minimal
+ * amount needed for loading firmware, where us dev_start/stop setup
+ * the rest needed to do full data/control traffic.
+ *
  * @bus_tx_block_size: [fill] SDIO imposes a 256 block size, USB 16,
  *     so we have a tx_blk_size variable that the bus layer sets to
  *     tell the engine how much of that we need.
  *
  * @bus_pl_size_max: [fill] Maximum payload size.
  *
+ * @bus_setup: [optional fill] Function called by the bus-generic code
+ *     [i2400m_setup()] to setup the basic bus-specific communications
+ *     to the the device needed to load firmware. See LIFE CYCLE above.
+ *
+ *     NOTE: Doesn't need to upload the firmware, as that is taken
+ *     care of by the bus-generic code.
+ *
+ * @bus_release: [optional fill] Function called by the bus-generic
+ *     code [i2400m_release()] to shutdown the basic bus-specific
+ *     communications to the the device needed to load firmware. See
+ *     LIFE CYCLE above.
+ *
+ *     This function does not need to reset the device, just tear down
+ *     all the host resources created to  handle communication with
+ *     the device.
+ *
  * @bus_dev_start: [fill] Function called by the bus-generic code
  *     [i2400m_dev_start()] to setup the bus-specific communications
  *     to the the device. See LIFE CYCLE above.
@@ -490,8 +515,10 @@ struct i2400m {
 	size_t bus_pl_size_max;
 	unsigned bus_bm_retries;
 
+	int (*bus_setup)(struct i2400m *);
 	int (*bus_dev_start)(struct i2400m *);
 	void (*bus_dev_stop)(struct i2400m *);
+	void (*bus_release)(struct i2400m *);
 	void (*bus_tx_kick)(struct i2400m *);
 	int (*bus_reset)(struct i2400m *, enum i2400m_reset_type);
 	ssize_t (*bus_bm_cmd_send)(struct i2400m *,
diff --git a/drivers/net/wimax/i2400m/sdio.c b/drivers/net/wimax/i2400m/sdio.c
index de158ee..6e39665 100644
--- a/drivers/net/wimax/i2400m/sdio.c
+++ b/drivers/net/wimax/i2400m/sdio.c
@@ -165,6 +165,66 @@ function_enabled:
 
 
 /*
+ * Setup minimal device communication infrastructure needed to at
+ * least be able to update the firmware.
+ */
+static
+int i2400ms_bus_setup(struct i2400m *i2400m)
+{
+	int result;
+	struct i2400ms *i2400ms =
+		container_of(i2400m, struct i2400ms, i2400m);
+	struct device *dev = i2400m_dev(i2400m);
+	struct sdio_func *func = i2400ms->func;
+
+	sdio_claim_host(func);
+	result = sdio_set_block_size(func, I2400MS_BLK_SIZE);
+	sdio_release_host(func);
+	if (result < 0) {
+		dev_err(dev, "Failed to set block size: %d\n", result);
+		goto error_set_blk_size;
+	}
+
+	result = i2400ms_enable_function(func, 1);
+	if (result < 0) {
+		dev_err(dev, "Cannot enable SDIO function: %d\n", result);
+		goto error_func_enable;
+	}
+
+	result = i2400ms_rx_setup(i2400ms);
+	if (result < 0)
+		goto error_rx_setup;
+	return 0;
+
+error_rx_setup:
+	sdio_claim_host(func);
+	sdio_disable_func(func);
+	sdio_release_host(func);
+error_func_enable:
+error_set_blk_size:
+	return result;
+}
+
+
+/*
+ * Tear down minimal device communication infrastructure needed to at
+ * least be able to update the firmware.
+ */
+static
+void i2400ms_bus_release(struct i2400m *i2400m)
+{
+	struct i2400ms *i2400ms =
+		container_of(i2400m, struct i2400ms, i2400m);
+	struct sdio_func *func = i2400ms->func;
+
+	i2400ms_rx_release(i2400ms);
+	sdio_claim_host(func);
+	sdio_disable_func(func);
+	sdio_release_host(func);
+}
+
+
+/*
  * Setup driver resources needed to communicate with the device
  *
  * The fw needs some time to settle, and it was just uploaded,
@@ -315,17 +375,12 @@ do_bus_reset:
 		if (i2400m->wimax_dev.net_dev->reg_state == NETREG_REGISTERED)
 			netif_tx_disable(i2400m->wimax_dev.net_dev);
 
-		i2400ms_rx_release(i2400ms);
-		sdio_claim_host(i2400ms->func);
-		sdio_disable_func(i2400ms->func);
-		sdio_release_host(i2400ms->func);
+		i2400ms_bus_release(i2400m);
 
 		/* Wait for the device to settle */
 		msleep(40);
 
-		result = i2400ms_enable_function(i2400ms->func, 0);
-		if (result >= 0)
-			i2400ms_rx_setup(i2400ms);
+		result =  i2400ms_bus_setup(i2400m);
 	} else
 		BUG();
 	if (result < 0 && rt != I2400M_RT_BUS) {
@@ -449,8 +504,10 @@ int i2400ms_probe(struct sdio_func *func,
 
 	i2400m->bus_tx_block_size = I2400MS_BLK_SIZE;
 	i2400m->bus_pl_size_max = I2400MS_PL_SIZE_MAX;
+	i2400m->bus_setup = i2400ms_bus_setup;
 	i2400m->bus_dev_start = i2400ms_bus_dev_start;
 	i2400m->bus_dev_stop = i2400ms_bus_dev_stop;
+	i2400m->bus_release = i2400ms_bus_release;
 	i2400m->bus_tx_kick = i2400ms_bus_tx_kick;
 	i2400m->bus_reset = i2400ms_bus_reset;
 	/* The iwmc3200-wimax sometimes requires the driver to try
@@ -462,20 +519,6 @@ int i2400ms_probe(struct sdio_func *func,
 	i2400m->bus_bm_mac_addr_impaired = 1;
 	i2400m->bus_bm_pokes_table = &i2400ms_pokes[0];
 
-	sdio_claim_host(func);
-	result = sdio_set_block_size(func, I2400MS_BLK_SIZE);
-	sdio_release_host(func);
-	if (result < 0) {
-		dev_err(dev, "Failed to set block size: %d\n", result);
-		goto error_set_blk_size;
-	}
-
-	result = i2400ms_enable_function(i2400ms->func, 1);
-	if (result < 0) {
-		dev_err(dev, "Cannot enable SDIO function: %d\n", result);
-		goto error_func_enable;
-	}
-
 	/*
 	 * Before we are enabling the device interrupt register, make
 	 * sure the buffer used during bootmode operation is setup so
@@ -488,10 +531,6 @@ int i2400ms_probe(struct sdio_func *func,
 		goto error_bootmode_buf_setup;
 	}
 
-	result = i2400ms_rx_setup(i2400ms);
-	if (result < 0)
-		goto error_rx_setup;
-
 	result = i2400m_setup(i2400m, I2400M_BRI_NO_REBOOT);
 	if (result < 0) {
 		dev_err(dev, "cannot setup device: %d\n", result);
@@ -509,15 +548,8 @@ int i2400ms_probe(struct sdio_func *func,
 error_debugfs_add:
 	i2400m_release(i2400m);
 error_setup:
-	i2400ms_rx_release(i2400ms);
-error_rx_setup:
 	i2400m_bm_buf_free(i2400m);
 error_bootmode_buf_setup:
-	sdio_claim_host(func);
-	sdio_disable_func(func);
-	sdio_release_host(func);
-error_func_enable:
-error_set_blk_size:
 	sdio_set_drvdata(func, NULL);
 	free_netdev(net_dev);
 error_alloc_netdev:
@@ -535,12 +567,8 @@ void i2400ms_remove(struct sdio_func *func)
 
 	d_fnstart(3, dev, "SDIO func %p\n", func);
 	debugfs_remove_recursive(i2400ms->debugfs_dentry);
-	i2400ms_rx_release(i2400ms);
 	i2400m_release(i2400m);
 	sdio_set_drvdata(func, NULL);
-	sdio_claim_host(func);
-	sdio_disable_func(func);
-	sdio_release_host(func);
 	free_netdev(net_dev);
 	d_fnend(3, dev, "SDIO func %p\n", func);
 }
diff --git a/drivers/net/wimax/i2400m/usb.c b/drivers/net/wimax/i2400m/usb.c
index f4dfb60..3bf3f72 100644
--- a/drivers/net/wimax/i2400m/usb.c
+++ b/drivers/net/wimax/i2400m/usb.c
@@ -416,8 +416,10 @@ int i2400mu_probe(struct usb_interface *iface,
 
 	i2400m->bus_tx_block_size = I2400MU_BLK_SIZE;
 	i2400m->bus_pl_size_max = I2400MU_PL_SIZE_MAX;
+	i2400m->bus_setup = NULL;
 	i2400m->bus_dev_start = i2400mu_bus_dev_start;
 	i2400m->bus_dev_stop = i2400mu_bus_dev_stop;
+	i2400m->bus_release = NULL;
 	i2400m->bus_tx_kick = i2400mu_bus_tx_kick;
 	i2400m->bus_reset = i2400mu_bus_reset;
 	i2400m->bus_bm_retries = I2400M_USB_BOOT_RETRIES;
-- 
1.6.2.5


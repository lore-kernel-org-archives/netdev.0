From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2.6.33/3 12/13] wimax/i2400m: do bootmode buffer management in i2400m_setup/release()
Date: Wed,  4 Nov 2009 13:40:03 -0800
Message-ID: <2869da8587604e3fea5f85aeade486a08e8313bf.1257370736.git.inaky@linux.intel.com>
References: <cover.1257370736.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:20716 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932750AbZKDVmJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:42:09 -0500
In-Reply-To: <cover.1257370736.git.inaky@linux.intel.com>
In-Reply-To: <cover.1257370736.git.inaky@linux.intel.com>
References: <cover.1257370736.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After the introduction of i2400m->bus_setup/release, there is no more
race condition where the bootmode buffers are needed before
i2400m_setup() is called.

Before, the SDIO driver would setup RX before calling i2400m_setup()
and thus need those buffers; now RX setup is done in
i2400m->bus_setup(), which is called by i2400m_setup().

Thus, all the bootmode buffer management can now be done completely
inside i2400m_setup()/i2400m_release(), removing complexity from the
bus-specific drivers.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/driver.c |   28 +++++++++++++++++-----------
 drivers/net/wimax/i2400m/i2400m.h |    2 --
 drivers/net/wimax/i2400m/sdio.c   |   14 --------------
 drivers/net/wimax/i2400m/usb.c    |    8 --------
 4 files changed, 17 insertions(+), 35 deletions(-)

diff --git a/drivers/net/wimax/i2400m/driver.c b/drivers/net/wimax/i2400m/driver.c
index c57020f..4fcdb18 100644
--- a/drivers/net/wimax/i2400m/driver.c
+++ b/drivers/net/wimax/i2400m/driver.c
@@ -723,12 +723,13 @@ int i2400m_dev_reset_handle(struct i2400m *i2400m, const char *reason)
 EXPORT_SYMBOL_GPL(i2400m_dev_reset_handle);
 
 
-/**
- * i2400m_bm_buf_alloc - Alloc the command and ack buffers for boot mode
+/*
+ * Alloc the command and ack buffers for boot mode
  *
  * Get the buffers needed to deal with boot mode messages.  These
  * buffers need to be allocated before the sdio recieve irq is setup.
  */
+static
 int i2400m_bm_buf_alloc(struct i2400m *i2400m)
 {
 	int result;
@@ -747,22 +748,19 @@ error_bm_ack_buf_kzalloc:
 error_bm_cmd_kzalloc:
 	return result;
 }
-EXPORT_SYMBOL_GPL(i2400m_bm_buf_alloc);
 
-/**
- * i2400m_bm_buf_free - Free boot mode command and ack buffers.
- *
- * Free the command and ack buffers
- *
+
+/*
+ * Free boot mode command and ack buffers.
  */
+static
 void i2400m_bm_buf_free(struct i2400m *i2400m)
 {
 	kfree(i2400m->bm_ack_buf);
 	kfree(i2400m->bm_cmd_buf);
-	return;
 }
-EXPORT_SYMBOL_GPL(i2400m_bm_buf_free
-);
+
+
 /**
  * i2400m_setup - bus-generic setup function for the i2400m device
  *
@@ -786,6 +784,12 @@ int i2400m_setup(struct i2400m *i2400m, enum i2400m_bri bm_flags)
 	snprintf(wimax_dev->name, sizeof(wimax_dev->name),
 		 "i2400m-%s:%s", dev->bus->name, dev_name(dev));
 
+	result = i2400m_bm_buf_alloc(i2400m);
+	if (result < 0) {
+		dev_err(dev, "cannot allocate bootmode scratch buffers\n");
+		goto error_bm_buf_alloc;
+	}
+
 	if (i2400m->bus_setup) {
 		result = i2400m->bus_setup(i2400m);
 		if (result < 0) {
@@ -860,6 +864,8 @@ error_bootrom_init:
 	if (i2400m->bus_release)
 		i2400m->bus_release(i2400m);
 error_bus_setup:
+	i2400m_bm_buf_free(i2400m);
+error_bm_buf_alloc:
 	d_fnend(3, dev, "(i2400m %p) = %d\n", i2400m, result);
 	return result;
 }
diff --git a/drivers/net/wimax/i2400m/i2400m.h b/drivers/net/wimax/i2400m/i2400m.h
index 407d097..1724955 100644
--- a/drivers/net/wimax/i2400m/i2400m.h
+++ b/drivers/net/wimax/i2400m/i2400m.h
@@ -817,8 +817,6 @@ void i2400m_put(struct i2400m *i2400m)
 }
 
 extern int i2400m_dev_reset_handle(struct i2400m *, const char *);
-extern int i2400m_bm_buf_alloc(struct i2400m *i2400m);
-extern void i2400m_bm_buf_free(struct i2400m *i2400m);
 
 /*
  * _setup()/_release() are called by the probe/disconnect functions of
diff --git a/drivers/net/wimax/i2400m/sdio.c b/drivers/net/wimax/i2400m/sdio.c
index 6e39665..14e66f0 100644
--- a/drivers/net/wimax/i2400m/sdio.c
+++ b/drivers/net/wimax/i2400m/sdio.c
@@ -519,18 +519,6 @@ int i2400ms_probe(struct sdio_func *func,
 	i2400m->bus_bm_mac_addr_impaired = 1;
 	i2400m->bus_bm_pokes_table = &i2400ms_pokes[0];
 
-	/*
-	 * Before we are enabling the device interrupt register, make
-	 * sure the buffer used during bootmode operation is setup so
-	 * when the first D2H data interrupt comes, the memory is
-	 * available for copying the D2H data.
-	 */
-	result = i2400m_bm_buf_alloc(i2400m);
-	if (result < 0) {
-		dev_err(dev, "cannot allocate SDIO bootmode buffer\n");
-		goto error_bootmode_buf_setup;
-	}
-
 	result = i2400m_setup(i2400m, I2400M_BRI_NO_REBOOT);
 	if (result < 0) {
 		dev_err(dev, "cannot setup device: %d\n", result);
@@ -548,8 +536,6 @@ int i2400ms_probe(struct sdio_func *func,
 error_debugfs_add:
 	i2400m_release(i2400m);
 error_setup:
-	i2400m_bm_buf_free(i2400m);
-error_bootmode_buf_setup:
 	sdio_set_drvdata(func, NULL);
 	free_netdev(net_dev);
 error_alloc_netdev:
diff --git a/drivers/net/wimax/i2400m/usb.c b/drivers/net/wimax/i2400m/usb.c
index 3bf3f72..7756797 100644
--- a/drivers/net/wimax/i2400m/usb.c
+++ b/drivers/net/wimax/i2400m/usb.c
@@ -447,12 +447,6 @@ int i2400mu_probe(struct usb_interface *iface,
 	usb_dev->autosuspend_disabled = 0;
 #endif
 
-	result = i2400m_bm_buf_alloc(i2400m);
-	if (result < 0) {
-		dev_err(dev, "cannot allocate USB bootmode buffer\n");
-		goto error_bm_buf_alloc;
-	}
-
 	result = i2400m_setup(i2400m, I2400M_BRI_MAC_REINIT);
 	if (result < 0) {
 		dev_err(dev, "cannot setup device: %d\n", result);
@@ -468,8 +462,6 @@ int i2400mu_probe(struct usb_interface *iface,
 error_debugfs_add:
 	i2400m_release(i2400m);
 error_setup:
-	i2400m_bm_buf_free(i2400m);
-error_bm_buf_alloc:
 	usb_set_intfdata(iface, NULL);
 	usb_put_dev(i2400mu->usb_dev);
 	free_netdev(net_dev);
-- 
1.6.2.5


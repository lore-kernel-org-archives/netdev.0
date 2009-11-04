From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2.6.33/3 13/13] wimax/i2400m: Implement pre/post reset support in the USB driver
Date: Wed,  4 Nov 2009 13:40:04 -0800
Message-ID: <3725d8c97436aeaa03eeb0c25361a7ec0f3f5bd2.1257370736.git.inaky@linux.intel.com>
References: <cover.1257370736.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:20718 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932753AbZKDVmJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:42:09 -0500
In-Reply-To: <cover.1257370736.git.inaky@linux.intel.com>
In-Reply-To: <cover.1257370736.git.inaky@linux.intel.com>
References: <cover.1257370736.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The USB stack can callback a driver is about to be reset by an
external entity and right after it, so the driver can save state and
then restore it.

This commit implements said support; it is implemented actually in the
core, bus-generic driver [i2400m_{pre,post}_reset()] and used by the
bus-specific drivers. This way the SDIO driver can also use it once
said support is brought to the SDIO stack.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/driver.c |   81 +++++++++++++++++++++++++++++++++++++
 drivers/net/wimax/i2400m/i2400m.h |    2 +
 drivers/net/wimax/i2400m/usb.c    |   33 +++++++++++++++
 3 files changed, 116 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wimax/i2400m/driver.c b/drivers/net/wimax/i2400m/driver.c
index 4fcdb18..1f6aa2a 100644
--- a/drivers/net/wimax/i2400m/driver.c
+++ b/drivers/net/wimax/i2400m/driver.c
@@ -620,6 +620,87 @@ int i2400m_pm_notifier(struct notifier_block *notifier,
 
 
 /*
+ * pre-reset is called before a device is going on reset
+ *
+ * This has to be followed by a call to i2400m_post_reset(), otherwise
+ * bad things might happen.
+ */
+int i2400m_pre_reset(struct i2400m *i2400m)
+{
+	int result;
+	struct device *dev = i2400m_dev(i2400m);
+
+	d_fnstart(3, dev, "(i2400m %p)\n", i2400m);
+	d_printf(1, dev, "pre-reset shut down\n");
+
+	result = 0;
+	mutex_lock(&i2400m->init_mutex);
+	if (i2400m->updown) {
+		netif_tx_disable(i2400m->wimax_dev.net_dev);
+		__i2400m_dev_stop(i2400m);
+		result = 0;
+		/* down't set updown to zero -- this way
+		 * post_reset can restore properly */
+	}
+	mutex_unlock(&i2400m->init_mutex);
+	if (i2400m->bus_release)
+		i2400m->bus_release(i2400m);
+	d_fnend(3, dev, "(i2400m %p) = %d\n", i2400m, result);
+	return result;
+}
+EXPORT_SYMBOL_GPL(i2400m_pre_reset);
+
+
+/*
+ * Restore device state after a reset
+ *
+ * Do the work needed after a device reset to bring it up to the same
+ * state as it was before the reset.
+ *
+ * NOTE: this requires i2400m->init_mutex taken
+ */
+int i2400m_post_reset(struct i2400m *i2400m)
+{
+	int result = 0;
+	struct device *dev = i2400m_dev(i2400m);
+
+	d_fnstart(3, dev, "(i2400m %p)\n", i2400m);
+	d_printf(1, dev, "post-reset start\n");
+	if (i2400m->bus_setup) {
+		result = i2400m->bus_setup(i2400m);
+		if (result < 0) {
+			dev_err(dev, "bus-specific setup failed: %d\n",
+				result);
+			goto error_bus_setup;
+		}
+	}
+	mutex_lock(&i2400m->init_mutex);
+	if (i2400m->updown) {
+		result = __i2400m_dev_start(
+			i2400m, I2400M_BRI_SOFT | I2400M_BRI_MAC_REINIT);
+		if (result < 0)
+			goto error_dev_start;
+	}
+	mutex_unlock(&i2400m->init_mutex);
+	d_fnend(3, dev, "(i2400m %p) = %d\n", i2400m, result);
+	return result;
+
+error_dev_start:
+	if (i2400m->bus_release)
+		i2400m->bus_release(i2400m);
+error_bus_setup:
+	/* even if the device was up, it could not be recovered, so we
+	 * mark it as down. */
+	i2400m->updown = 0;
+	wmb();		/* see i2400m->updown's documentation  */
+	mutex_unlock(&i2400m->init_mutex);
+	d_fnend(3, dev, "(i2400m %p) = %d\n", i2400m, result);
+	return result;
+}
+EXPORT_SYMBOL_GPL(i2400m_post_reset);
+
+
+/*
  * The device has rebooted; fix up the device and the driver
  *
  * Tear down the driver communication with the device, reload the
diff --git a/drivers/net/wimax/i2400m/i2400m.h b/drivers/net/wimax/i2400m/i2400m.h
index 1724955..8fc8a0c 100644
--- a/drivers/net/wimax/i2400m/i2400m.h
+++ b/drivers/net/wimax/i2400m/i2400m.h
@@ -817,6 +817,8 @@ void i2400m_put(struct i2400m *i2400m)
 }
 
 extern int i2400m_dev_reset_handle(struct i2400m *, const char *);
+extern int i2400m_pre_reset(struct i2400m *);
+extern int i2400m_post_reset(struct i2400m *);
 
 /*
  * _setup()/_release() are called by the probe/disconnect functions of
diff --git a/drivers/net/wimax/i2400m/usb.c b/drivers/net/wimax/i2400m/usb.c
index 7756797..8b246cc 100644
--- a/drivers/net/wimax/i2400m/usb.c
+++ b/drivers/net/wimax/i2400m/usb.c
@@ -637,6 +637,37 @@ int i2400mu_reset_resume(struct usb_interface *iface)
 }
 
 
+/*
+ * Another driver or user space is triggering a reset on the device
+ * which contains the interface passed as an argument. Cease IO and
+ * save any device state you need to restore.
+ *
+ * If you need to allocate memory here, use GFP_NOIO or GFP_ATOMIC, if
+ * you are in atomic context.
+ */
+static
+int i2400mu_pre_reset(struct usb_interface *iface)
+{
+	struct i2400mu *i2400mu = usb_get_intfdata(iface);
+	return i2400m_pre_reset(&i2400mu->i2400m);
+}
+
+
+/*
+ * The reset has completed.  Restore any saved device state and begin
+ * using the device again.
+ *
+ * If you need to allocate memory here, use GFP_NOIO or GFP_ATOMIC, if
+ * you are in atomic context.
+ */
+static
+int i2400mu_post_reset(struct usb_interface *iface)
+{
+	struct i2400mu *i2400mu = usb_get_intfdata(iface);
+	return i2400m_post_reset(&i2400mu->i2400m);
+}
+
+
 static
 struct usb_device_id i2400mu_id_table[] = {
 	{ USB_DEVICE(0x8086, USB_DEVICE_ID_I6050) },
@@ -660,6 +691,8 @@ struct usb_driver i2400mu_driver = {
 	.reset_resume = i2400mu_reset_resume,
 	.probe = i2400mu_probe,
 	.disconnect = i2400mu_disconnect,
+	.pre_reset = i2400mu_pre_reset,
+	.post_reset = i2400mu_post_reset,
 	.id_table = i2400mu_id_table,
 	.supports_autosuspend = 1,
 };
-- 
1.6.2.5


From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2.6.33/3 09/13] wimax/i2400m: cleanup initialization/destruction flow
Date: Wed,  4 Nov 2009 13:40:00 -0800
Message-ID: <8f90f3ee83dc54e182d6a7548727cbae4b523e6e.1257370736.git.inaky@linux.intel.com>
References: <cover.1257370736.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:20718 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932749AbZKDVmI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:42:08 -0500
In-Reply-To: <cover.1257370736.git.inaky@linux.intel.com>
In-Reply-To: <cover.1257370736.git.inaky@linux.intel.com>
References: <cover.1257370736.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the i2400m driver was starting in a weird way: registering a
network device, setting the device up and then registering a WiMAX
device.

This is an historic artifact, and was causing issues, a some early
reports the device sends were getting lost by issue of the wimax_dev
not being registered.

Fix said situation by doing the wimax device registration in
i2400m_setup() after network device registration and before starting
thed device.

As well, removed spurious setting of the state to UNINITIALIZED;
i2400m.dev_start() does that already.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/driver.c |   32 ++++++++++++++------------------
 drivers/net/wimax/i2400m/i2400m.h |   30 +++++++++++++++++++++---------
 drivers/net/wimax/i2400m/netdev.c |   10 ++++++----
 3 files changed, 41 insertions(+), 31 deletions(-)

diff --git a/drivers/net/wimax/i2400m/driver.c b/drivers/net/wimax/i2400m/driver.c
index a33df04..a0ae199 100644
--- a/drivers/net/wimax/i2400m/driver.c
+++ b/drivers/net/wimax/i2400m/driver.c
@@ -754,13 +754,9 @@ EXPORT_SYMBOL_GPL(i2400m_bm_buf_free
  *
  * Returns: 0 if ok, < 0 errno code on error.
  *
- * Initializes the bus-generic parts of the i2400m driver; the
- * bus-specific parts have been initialized, function pointers filled
- * out by the bus-specific probe function.
- *
- * As well, this registers the WiMAX and net device nodes. Once this
- * function returns, the device is operative and has to be ready to
- * receive and send network traffic and WiMAX control operations.
+ * Sets up basic device comunication infrastructure, boots the ROM to
+ * read the MAC address, registers with the WiMAX and network stacks
+ * and then brings up the device.
  */
 int i2400m_setup(struct i2400m *i2400m, enum i2400m_bri bm_flags)
 {
@@ -796,18 +792,13 @@ int i2400m_setup(struct i2400m *i2400m, enum i2400m_bri bm_flags)
 	}
 	netif_carrier_off(net_dev);
 
-	result = i2400m_dev_start(i2400m, bm_flags);
-	if (result < 0)
-		goto error_dev_start;
-
 	i2400m->wimax_dev.op_msg_from_user = i2400m_op_msg_from_user;
 	i2400m->wimax_dev.op_rfkill_sw_toggle = i2400m_op_rfkill_sw_toggle;
 	i2400m->wimax_dev.op_reset = i2400m_op_reset;
+
 	result = wimax_dev_add(&i2400m->wimax_dev, net_dev);
 	if (result < 0)
 		goto error_wimax_dev_add;
-	/* User space needs to do some init stuff */
-	wimax_state_change(wimax_dev, WIMAX_ST_UNINITIALIZED);
 
 	/* Now setup all that requires a registered net and wimax device. */
 	result = sysfs_create_group(&net_dev->dev.kobj, &i2400m_dev_attr_group);
@@ -815,22 +806,27 @@ int i2400m_setup(struct i2400m *i2400m, enum i2400m_bri bm_flags)
 		dev_err(dev, "cannot setup i2400m's sysfs: %d\n", result);
 		goto error_sysfs_setup;
 	}
+
 	result = i2400m_debugfs_add(i2400m);
 	if (result < 0) {
 		dev_err(dev, "cannot setup i2400m's debugfs: %d\n", result);
 		goto error_debugfs_setup;
 	}
+
+	result = i2400m_dev_start(i2400m, bm_flags);
+	if (result < 0)
+		goto error_dev_start;
 	d_fnend(3, dev, "(i2400m %p) = %d\n", i2400m, result);
 	return result;
 
+error_dev_start:
+	i2400m_debugfs_rm(i2400m);
 error_debugfs_setup:
 	sysfs_remove_group(&i2400m->wimax_dev.net_dev->dev.kobj,
 			   &i2400m_dev_attr_group);
 error_sysfs_setup:
 	wimax_dev_rm(&i2400m->wimax_dev);
 error_wimax_dev_add:
-	i2400m_dev_stop(i2400m);
-error_dev_start:
 	unregister_netdev(net_dev);
 error_register_netdev:
 	unregister_pm_notifier(&i2400m->pm_notifier);
@@ -854,15 +850,15 @@ void i2400m_release(struct i2400m *i2400m)
 	d_fnstart(3, dev, "(i2400m %p)\n", i2400m);
 	netif_stop_queue(i2400m->wimax_dev.net_dev);
 
+	i2400m_dev_stop(i2400m);
+
 	i2400m_debugfs_rm(i2400m);
 	sysfs_remove_group(&i2400m->wimax_dev.net_dev->dev.kobj,
 			   &i2400m_dev_attr_group);
 	wimax_dev_rm(&i2400m->wimax_dev);
-	i2400m_dev_stop(i2400m);
 	unregister_netdev(i2400m->wimax_dev.net_dev);
 	unregister_pm_notifier(&i2400m->pm_notifier);
-	kfree(i2400m->bm_ack_buf);
-	kfree(i2400m->bm_cmd_buf);
+	i2400m_bm_buf_free(i2400m);
 	d_fnend(3, dev, "(i2400m %p) = void\n", i2400m);
 }
 EXPORT_SYMBOL_GPL(i2400m_release);
diff --git a/drivers/net/wimax/i2400m/i2400m.h b/drivers/net/wimax/i2400m/i2400m.h
index 303eb78..2b9c400 100644
--- a/drivers/net/wimax/i2400m/i2400m.h
+++ b/drivers/net/wimax/i2400m/i2400m.h
@@ -117,16 +117,28 @@
  * well as i2400m->wimax_dev.net_dev and call i2400m_setup(). The
  * i2400m driver will only register with the WiMAX and network stacks;
  * the only access done to the device is to read the MAC address so we
- * can register a network device. This calls i2400m_dev_start() to
- * load firmware, setup communication with the device and configure it
- * for operation.
+ * can register a network device.
  *
- * At this point, control and data communications are possible.
+ * The high-level call flow is:
+ *
+ * bus_probe()
+ *   i2400m_setup()
+ *     boot rom initialization / read mac addr
+ *     network / WiMAX stacks registration
+ *     i2400m_dev_start()
+ *       i2400m->bus_dev_start()
+ *       i2400m_dev_initialize()
+ *
+ * The reverse applies for a disconnect() call:
  *
- * On disconnect/driver unload, the bus-specific disconnect function
- * calls i2400m_release() to undo i2400m_setup(). i2400m_dev_stop()
- * shuts the firmware down and releases resources uses to communicate
- * with the device.
+ * bus_disconnect()
+ *   i2400m_release()
+ *     i2400m_dev_stop()
+ *       i2400m_dev_shutdown()
+ *       i2400m->bus_dev_stop()
+ *     network / WiMAX stack unregistration
+ *
+ * At this point, control and data communications are possible.
  *
  * While the device is up, it might reset. The bus-specific driver has
  * to catch that situation and call i2400m_dev_reset_handle() to deal
@@ -706,7 +718,7 @@ static inline int i2400m_debugfs_add(struct i2400m *i2400m)
 static inline void i2400m_debugfs_rm(struct i2400m *i2400m) {}
 #endif
 
-/* Called by _dev_start()/_dev_stop() to initialize the device itself */
+/* Initialize/shutdown the device */
 extern int i2400m_dev_initialize(struct i2400m *);
 extern void i2400m_dev_shutdown(struct i2400m *);
 
diff --git a/drivers/net/wimax/i2400m/netdev.c b/drivers/net/wimax/i2400m/netdev.c
index 0e8f6a0..fefd794 100644
--- a/drivers/net/wimax/i2400m/netdev.c
+++ b/drivers/net/wimax/i2400m/netdev.c
@@ -102,11 +102,13 @@ int i2400m_open(struct net_device *net_dev)
 	struct device *dev = i2400m_dev(i2400m);
 
 	d_fnstart(3, dev, "(net_dev %p [i2400m %p])\n", net_dev, i2400m);
-	if (i2400m->ready == 0) {
-		dev_err(dev, "Device is still initializing\n");
-		result = -EBUSY;
-	} else
+	/* Make sure we wait until init is complete... */
+	mutex_lock(&i2400m->init_mutex);
+	if (i2400m->updown)
 		result = 0;
+	else
+		result = -EBUSY;
+	mutex_unlock(&i2400m->init_mutex);
 	d_fnend(3, dev, "(net_dev %p [i2400m %p]) = %d\n",
 		net_dev, i2400m, result);
 	return result;
-- 
1.6.2.5


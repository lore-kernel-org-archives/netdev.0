From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2.6.33/3 05/13] wimax/i2400m: cache firmware on system suspend
Date: Wed,  4 Nov 2009 13:39:56 -0800
Message-ID: <7b43ca708a767a5f68eeeb732c569c0f11a7d6f7.1257370736.git.inaky@linux.intel.com>
References: <cover.1257370736.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:20716 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932740AbZKDVmF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:42:05 -0500
In-Reply-To: <cover.1257370736.git.inaky@linux.intel.com>
In-Reply-To: <cover.1257370736.git.inaky@linux.intel.com>
References: <cover.1257370736.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for a reset_resume implementation, have the firmware
image be cached in memory when the system goes to suspend and released
when out.

This is needed in case the device resets during suspend; the driver
can't load firmware until resume is completed or bad deadlocks
happen.

The modus operandi for this was copied from the Orinoco USB driver.

The caching is done with a kobject to avoid race conditions when
releasing it. The fw loader path is altered only to first check for a
cached image before trying to load from disk. A Power Management event
notifier is register to call i2400m_fw_cache() or i2400m_fw_uncache()
which take care of the actual cache management.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/driver.c |   51 ++++++++++++
 drivers/net/wimax/i2400m/fw.c     |  159 ++++++++++++++++++++++++++++++++++---
 drivers/net/wimax/i2400m/i2400m.h |   16 ++++
 3 files changed, 213 insertions(+), 13 deletions(-)

diff --git a/drivers/net/wimax/i2400m/driver.c b/drivers/net/wimax/i2400m/driver.c
index f07d852..07d12be 100644
--- a/drivers/net/wimax/i2400m/driver.c
+++ b/drivers/net/wimax/i2400m/driver.c
@@ -66,6 +66,7 @@
 #include <linux/wimax/i2400m.h>
 #include <linux/module.h>
 #include <linux/moduleparam.h>
+#include <linux/suspend.h>
 
 #define D_SUBMODULE driver
 #include "debug-levels.h"
@@ -555,6 +556,51 @@ void i2400m_dev_stop(struct i2400m *i2400m)
 
 
 /*
+ * Listen to PM events to cache the firmware before suspend/hibernation
+ *
+ * When the device comes out of suspend, it might go into reset and
+ * firmware has to be uploaded again. At resume, most of the times, we
+ * can't load firmware images from disk, so we need to cache it.
+ *
+ * i2400m_fw_cache() will allocate a kobject and attach the firmware
+ * to it; that way we don't have to worry too much about the fw loader
+ * hitting a race condition.
+ *
+ * Note: modus operandi stolen from the Orinoco driver; thx.
+ */
+static
+int i2400m_pm_notifier(struct notifier_block *notifier,
+		       unsigned long pm_event,
+		       void *unused)
+{
+	struct i2400m *i2400m =
+		container_of(notifier, struct i2400m, pm_notifier);
+	struct device *dev = i2400m_dev(i2400m);
+
+	d_fnstart(3, dev, "(i2400m %p pm_event %lx)\n", i2400m, pm_event);
+	switch (pm_event) {
+	case PM_HIBERNATION_PREPARE:
+	case PM_SUSPEND_PREPARE:
+		i2400m_fw_cache(i2400m);
+		break;
+	case PM_POST_RESTORE:
+		/* Restore from hibernation failed. We need to clean
+		 * up in exactly the same way, so fall through. */
+	case PM_POST_HIBERNATION:
+	case PM_POST_SUSPEND:
+		i2400m_fw_uncache(i2400m);
+		break;
+
+	case PM_RESTORE_PREPARE:
+	default:
+		break;
+	}
+	d_fnend(3, dev, "(i2400m %p pm_event %lx) = void\n", i2400m, pm_event);
+	return NOTIFY_DONE;
+}
+
+
+/*
  * The device has rebooted; fix up the device and the driver
  *
  * Tear down the driver communication with the device, reload the
@@ -738,6 +784,9 @@ int i2400m_setup(struct i2400m *i2400m, enum i2400m_bri bm_flags)
 		goto error_read_mac_addr;
 	random_ether_addr(i2400m->src_mac_addr);
 
+	i2400m->pm_notifier.notifier_call = i2400m_pm_notifier;
+	register_pm_notifier(&i2400m->pm_notifier);
+
 	result = register_netdev(net_dev);	/* Okey dokey, bring it up */
 	if (result < 0) {
 		dev_err(dev, "cannot register i2400m network device: %d\n",
@@ -783,6 +832,7 @@ error_wimax_dev_add:
 error_dev_start:
 	unregister_netdev(net_dev);
 error_register_netdev:
+	unregister_pm_notifier(&i2400m->pm_notifier);
 error_read_mac_addr:
 error_bootrom_init:
 	d_fnend(3, dev, "(i2400m %p) = %d\n", i2400m, result);
@@ -809,6 +859,7 @@ void i2400m_release(struct i2400m *i2400m)
 	wimax_dev_rm(&i2400m->wimax_dev);
 	i2400m_dev_stop(i2400m);
 	unregister_netdev(i2400m->wimax_dev.net_dev);
+	unregister_pm_notifier(&i2400m->pm_notifier);
 	kfree(i2400m->bm_ack_buf);
 	kfree(i2400m->bm_cmd_buf);
 	d_fnend(3, dev, "(i2400m %p) = void\n", i2400m);
diff --git a/drivers/net/wimax/i2400m/fw.c b/drivers/net/wimax/i2400m/fw.c
index 5719f4a..69f9e45 100644
--- a/drivers/net/wimax/i2400m/fw.c
+++ b/drivers/net/wimax/i2400m/fw.c
@@ -105,6 +105,13 @@
  * read an acknolwedgement from it (or an asynchronous notification)
  * from it.
  *
+ * FIRMWARE LOADING
+ *
+ * Note that in some cases, we can't just load a firmware file (for
+ * example, when resuming). For that, we might cache the firmware
+ * file. Thus, when doing the bootstrap, if there is a cache firmware
+ * file, it is used; if not, loading from disk is attempted.
+ *
  * ROADMAP
  *
  * i2400m_barker_db_init              Called by i2400m_driver_init()
@@ -114,9 +121,10 @@
  *
  * i2400m_dev_bootstrap               Called by __i2400m_dev_start()
  *   request_firmware
- *   i2400m_fw_check
- *     i2400m_fw_hdr_check
- *   i2400m_fw_dnload
+ *   i2400m_fw_bootstrap
+ *     i2400m_fw_check
+ *       i2400m_fw_hdr_check
+ *     i2400m_fw_dnload
  *   release_firmware
  *
  * i2400m_fw_dnload
@@ -141,6 +149,10 @@
  *
  * i2400m_bm_cmd_prepare              Used by bus-drivers to prep
  *                                    commands before sending
+ *
+ * i2400m_pm_notifier                 Called on Power Management events
+ *   i2400m_fw_cache
+ *   i2400m_fw_uncache
  */
 #include <linux/firmware.h>
 #include <linux/sched.h>
@@ -1459,6 +1471,61 @@ error_dev_rebooted:
 	goto hw_reboot;
 }
 
+static
+int i2400m_fw_bootstrap(struct i2400m *i2400m, const struct firmware *fw,
+			enum i2400m_bri flags)
+{
+	int ret;
+	struct device *dev = i2400m_dev(i2400m);
+	const struct i2400m_bcf_hdr *bcf;	/* Firmware data */
+
+	d_fnstart(5, dev, "(i2400m %p)\n", i2400m);
+	bcf = (void *) fw->data;
+	ret = i2400m_fw_check(i2400m, bcf, fw->size);
+	if (ret >= 0)
+		ret = i2400m_fw_dnload(i2400m, bcf, fw->size, flags);
+	if (ret < 0)
+		dev_err(dev, "%s: cannot use: %d, skipping\n",
+			i2400m->fw_name, ret);
+	kfree(i2400m->fw_hdrs);
+	i2400m->fw_hdrs = NULL;
+	d_fnend(5, dev, "(i2400m %p) = %d\n", i2400m, ret);
+	return ret;
+}
+
+
+/* Refcounted container for firmware data */
+struct i2400m_fw {
+	struct kref kref;
+	const struct firmware *fw;
+};
+
+
+static
+void i2400m_fw_destroy(struct kref *kref)
+{
+	struct i2400m_fw *i2400m_fw =
+		container_of(kref, struct i2400m_fw, kref);
+	release_firmware(i2400m_fw->fw);
+	kfree(i2400m_fw);
+}
+
+
+static
+struct i2400m_fw *i2400m_fw_get(struct i2400m_fw *i2400m_fw)
+{
+	if (i2400m_fw != NULL && i2400m_fw != (void *) ~0)
+		kref_get(&i2400m_fw->kref);
+	return i2400m_fw;
+}
+
+
+static
+void i2400m_fw_put(struct i2400m_fw *i2400m_fw)
+{
+	kref_put(&i2400m_fw->kref, i2400m_fw_destroy);
+}
+
 
 /**
  * i2400m_dev_bootstrap - Bring the device to a known state and upload firmware
@@ -1479,12 +1546,28 @@ int i2400m_dev_bootstrap(struct i2400m *i2400m, enum i2400m_bri flags)
 {
 	int ret, itr;
 	struct device *dev = i2400m_dev(i2400m);
-	const struct firmware *fw;
+	struct i2400m_fw *i2400m_fw;
 	const struct i2400m_bcf_hdr *bcf;	/* Firmware data */
+	const struct firmware *fw;
 	const char *fw_name;
 
 	d_fnstart(5, dev, "(i2400m %p)\n", i2400m);
 
+	ret = -ENODEV;
+	spin_lock(&i2400m->rx_lock);
+	i2400m_fw = i2400m_fw_get(i2400m->fw_cached);
+	spin_unlock(&i2400m->rx_lock);
+	if (i2400m_fw == (void *) ~0) {
+		dev_err(dev, "can't load firmware now!");
+		goto out;
+	} else if (i2400m_fw != NULL) {
+		dev_info(dev, "firmware %s: loading from cache\n",
+			 i2400m->fw_name);
+		ret = i2400m_fw_bootstrap(i2400m, i2400m_fw->fw, flags);
+		i2400m_fw_put(i2400m_fw);
+		goto out;
+	}
+
 	/* Load firmware files to memory. */
 	for (itr = 0, bcf = NULL, ret = -ENOENT; ; itr++) {
 		fw_name = i2400m->bus_fw_names[itr];
@@ -1500,21 +1583,71 @@ int i2400m_dev_bootstrap(struct i2400m *i2400m, enum i2400m_bri flags)
 				fw_name, ret);
 			continue;
 		}
-		bcf = (void *) fw->data;
 		i2400m->fw_name = fw_name;
-		ret = i2400m_fw_check(i2400m, bcf, fw->size);
-		if (ret >= 0)
-			ret = i2400m_fw_dnload(i2400m, bcf, fw->size, flags);
-		if (ret < 0)
-			dev_err(dev, "%s: cannot use: %d, skipping\n",
-				fw_name, ret);
-		kfree(i2400m->fw_hdrs);
-		i2400m->fw_hdrs = NULL;
+		ret = i2400m_fw_bootstrap(i2400m, fw, flags);
 		release_firmware(fw);
 		if (ret >= 0)	/* firmware loaded succesfully */
 			break;
+		i2400m->fw_name = NULL;
 	}
+out:
 	d_fnend(5, dev, "(i2400m %p) = %d\n", i2400m, ret);
 	return ret;
 }
 EXPORT_SYMBOL_GPL(i2400m_dev_bootstrap);
+
+
+void i2400m_fw_cache(struct i2400m *i2400m)
+{
+	int result;
+	struct i2400m_fw *i2400m_fw;
+	struct device *dev = i2400m_dev(i2400m);
+
+	/* if there is anything there, free it -- now, this'd be weird */
+	spin_lock(&i2400m->rx_lock);
+	i2400m_fw = i2400m->fw_cached;
+	spin_unlock(&i2400m->rx_lock);
+	if (i2400m_fw != NULL && i2400m_fw != (void *) ~0) {
+		i2400m_fw_put(i2400m_fw);
+		WARN(1, "%s:%u: still cached fw still present?\n",
+		     __func__, __LINE__);
+	}
+
+	if (i2400m->fw_name == NULL) {
+		dev_err(dev, "firmware n/a: can't cache\n");
+		i2400m_fw = (void *) ~0;
+		goto out;
+	}
+
+	i2400m_fw = kzalloc(sizeof(*i2400m_fw), GFP_ATOMIC);
+	if (i2400m_fw == NULL)
+		goto out;
+	kref_init(&i2400m_fw->kref);
+	result = request_firmware(&i2400m_fw->fw, i2400m->fw_name, dev);
+	if (result < 0) {
+		dev_err(dev, "firmware %s: failed to cache: %d\n",
+			i2400m->fw_name, result);
+		kfree(i2400m_fw);
+		i2400m_fw = (void *) ~0;
+	} else
+		dev_info(dev, "firmware %s: cached\n", i2400m->fw_name);
+out:
+	spin_lock(&i2400m->rx_lock);
+	i2400m->fw_cached = i2400m_fw;
+	spin_unlock(&i2400m->rx_lock);
+}
+
+
+void i2400m_fw_uncache(struct i2400m *i2400m)
+{
+	struct i2400m_fw *i2400m_fw;
+
+	spin_lock(&i2400m->rx_lock);
+	i2400m_fw = i2400m->fw_cached;
+	i2400m->fw_cached = NULL;
+	spin_unlock(&i2400m->rx_lock);
+
+	if (i2400m_fw != NULL && i2400m_fw != (void *) ~0)
+		i2400m_fw_put(i2400m_fw);
+}
+
diff --git a/drivers/net/wimax/i2400m/i2400m.h b/drivers/net/wimax/i2400m/i2400m.h
index 0c165de..916b1d3 100644
--- a/drivers/net/wimax/i2400m/i2400m.h
+++ b/drivers/net/wimax/i2400m/i2400m.h
@@ -424,11 +424,21 @@ struct i2400m_barker_db;
  * @fw_hdrs: NULL terminated array of pointers to the firmware
  *     headers. This is only available during firmware load time.
  *
+ * @fw_cached: Used to cache firmware when the system goes to
+ *     suspend/standby/hibernation (as on resume we can't read it). If
+ *     NULL, no firmware was cached, read it. If ~0, you can't read
+ *     any firmware files (the system still didn't come out of suspend
+ *     and failed to cache one), so abort; otherwise, a valid cached
+ *     firmware to be used. Access to this variable is protected by
+ *     the spinlock i2400m->rx_lock.
+ *
  * @barker: barker type that the device uses; this is initialized by
  *     i2400m_is_boot_barker() the first time it is called. Then it
  *     won't change during the life cycle of the device and everytime
  *     a boot barker is received, it is just verified for it being the
  *     same.
+ *
+ * @pm_notifier: used to register for PM events
  */
 struct i2400m {
 	struct wimax_dev wimax_dev;	/* FIRST! See doc */
@@ -495,7 +505,10 @@ struct i2400m {
 	const char *fw_name;		/* name of the current firmware image */
 	unsigned long fw_version;	/* version of the firmware interface */
 	const struct i2400m_bcf_hdr **fw_hdrs;
+	struct i2400m_fw *fw_cached;	/* protected by rx_lock */
 	struct i2400m_barker_db *barker;
+
+	struct notifier_block pm_notifier;
 };
 
 
@@ -671,6 +684,9 @@ extern void i2400m_tx_release(struct i2400m *);
 extern int i2400m_rx_setup(struct i2400m *);
 extern void i2400m_rx_release(struct i2400m *);
 
+extern void i2400m_fw_cache(struct i2400m *);
+extern void i2400m_fw_uncache(struct i2400m *);
+
 extern void i2400m_net_rx(struct i2400m *, struct sk_buff *, unsigned,
 			  const void *, int);
 extern void i2400m_net_erx(struct i2400m *, struct sk_buff *,
-- 
1.6.2.5


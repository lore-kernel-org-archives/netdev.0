From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2.6.33/3 04/13] wimax/i2400m: add reason argument to i2400m_dev_reset_handle()
Date: Wed,  4 Nov 2009 13:39:55 -0800
Message-ID: <3ef6129e57b04c116b1907b72c7a20720e6dde75.1257370736.git.inaky@linux.intel.com>
References: <cover.1257370736.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:20707 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932735AbZKDVmF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:42:05 -0500
In-Reply-To: <cover.1257370736.git.inaky@linux.intel.com>
In-Reply-To: <cover.1257370736.git.inaky@linux.intel.com>
References: <cover.1257370736.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for reset_resume support, in which the same code path
is going to be used, add a diagnostic message to dev_reset_handle()
that can be used to distinguish how the device got there.

This uses the new payload argument added to i2400m_schedule_work() by
the previous commit.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/driver.c    |   27 +++++++++++++++++++--------
 drivers/net/wimax/i2400m/i2400m.h    |    2 +-
 drivers/net/wimax/i2400m/sdio-rx.c   |    2 +-
 drivers/net/wimax/i2400m/usb-notif.c |    2 +-
 4 files changed, 22 insertions(+), 11 deletions(-)

diff --git a/drivers/net/wimax/i2400m/driver.c b/drivers/net/wimax/i2400m/driver.c
index 5803a2b..f07d852 100644
--- a/drivers/net/wimax/i2400m/driver.c
+++ b/drivers/net/wimax/i2400m/driver.c
@@ -573,18 +573,28 @@ void i2400m_dev_stop(struct i2400m *i2400m)
  *       _stop()], don't do anything, let it fail and handle it.
  *
  * This function is ran always in a thread context
+ *
+ * This function gets passed, as payload to i2400m_work() a 'const
+ * char *' ptr with a "reason" why the reset happened (for messages).
  */
 static
 void __i2400m_dev_reset_handle(struct work_struct *ws)
 {
 	int result;
 	struct i2400m_work *iw = container_of(ws, struct i2400m_work, ws);
+	const char *reason;
 	struct i2400m *i2400m = iw->i2400m;
 	struct device *dev = i2400m_dev(i2400m);
 	enum wimax_st wimax_state;
 	struct i2400m_reset_ctx *ctx = i2400m->reset_ctx;
 
-	d_fnstart(3, dev, "(ws %p i2400m %p)\n", ws, i2400m);
+	if (WARN_ON(iw->pl_size != sizeof(reason)))
+		reason = "SW BUG: reason n/a";
+	else
+		memcpy(&reason, iw->pl, sizeof(reason));
+
+	d_fnstart(3, dev, "(ws %p i2400m %p reason %s)\n", ws, i2400m, reason);
+
 	result = 0;
 	if (mutex_trylock(&i2400m->init_mutex) == 0) {
 		/* We are still in i2400m_dev_start() [let it fail] or
@@ -597,17 +607,17 @@ void __i2400m_dev_reset_handle(struct work_struct *ws)
 	}
 	wimax_state = wimax_state_get(&i2400m->wimax_dev);
 	if (wimax_state < WIMAX_ST_UNINITIALIZED) {
-		dev_info(dev, "device rebooted: it is down, ignoring\n");
+		dev_info(dev, "%s: it is down, ignoring\n", reason);
 		goto out_unlock;	/* ifconfig up/down wasn't called */
 	}
-	dev_err(dev, "device rebooted: reinitializing driver\n");
+	dev_err(dev, "%s: reinitializing driver\n", reason);
 	__i2400m_dev_stop(i2400m);
 	i2400m->updown = 0;
 	result = __i2400m_dev_start(i2400m,
 				    I2400M_BRI_SOFT | I2400M_BRI_MAC_REINIT);
 	if (result < 0) {
-		dev_err(dev, "device reboot: cannot start the device: %d\n",
-			result);
+		dev_err(dev, "%s: cannot start the device: %d\n",
+			reason, result);
 		result = i2400m->bus_reset(i2400m, I2400M_RT_BUS);
 		if (result >= 0)
 			result = -ENODEV;
@@ -622,7 +632,8 @@ out_unlock:
 out:
 	i2400m_put(i2400m);
 	kfree(iw);
-	d_fnend(3, dev, "(ws %p i2400m %p) = void\n", ws, i2400m);
+	d_fnend(3, dev, "(ws %p i2400m %p reason %s) = void\n",
+		ws, i2400m, reason);
 	return;
 }
 
@@ -639,12 +650,12 @@ out:
  * reinitializing the driver to handle the reset, calling into the
  * bus-specific functions ops as needed.
  */
-int i2400m_dev_reset_handle(struct i2400m *i2400m)
+int i2400m_dev_reset_handle(struct i2400m *i2400m, const char *reason)
 {
 	i2400m->boot_mode = 1;
 	wmb();		/* Make sure i2400m_msg_to_dev() sees boot_mode */
 	return i2400m_schedule_work(i2400m, __i2400m_dev_reset_handle,
-				    GFP_ATOMIC, NULL, 0);
+				    GFP_ATOMIC, &reason, sizeof(reason));
 }
 EXPORT_SYMBOL_GPL(i2400m_dev_reset_handle);
 
diff --git a/drivers/net/wimax/i2400m/i2400m.h b/drivers/net/wimax/i2400m/i2400m.h
index 700f87b..0c165de 100644
--- a/drivers/net/wimax/i2400m/i2400m.h
+++ b/drivers/net/wimax/i2400m/i2400m.h
@@ -739,7 +739,7 @@ void i2400m_put(struct i2400m *i2400m)
 	dev_put(i2400m->wimax_dev.net_dev);
 }
 
-extern int i2400m_dev_reset_handle(struct i2400m *);
+extern int i2400m_dev_reset_handle(struct i2400m *, const char *);
 extern int i2400m_bm_buf_alloc(struct i2400m *i2400m);
 extern void i2400m_bm_buf_free(struct i2400m *i2400m);
 
diff --git a/drivers/net/wimax/i2400m/sdio-rx.c b/drivers/net/wimax/i2400m/sdio-rx.c
index 87263be..98ee7fd 100644
--- a/drivers/net/wimax/i2400m/sdio-rx.c
+++ b/drivers/net/wimax/i2400m/sdio-rx.c
@@ -179,7 +179,7 @@ void i2400ms_rx(struct i2400ms *i2400ms)
 		i2400m_rx(i2400m, skb);
 	} else if (unlikely(i2400m_is_boot_barker(i2400m,
 						  skb->data, rx_size))) {
-		ret = i2400m_dev_reset_handle(i2400m);
+		ret = i2400m_dev_reset_handle(i2400m, "device rebooted");
 		dev_err(dev, "RX: SDIO reboot barker\n");
 		kfree_skb(skb);
 	} else {
diff --git a/drivers/net/wimax/i2400m/usb-notif.c b/drivers/net/wimax/i2400m/usb-notif.c
index a0751a3..f88d1c6 100644
--- a/drivers/net/wimax/i2400m/usb-notif.c
+++ b/drivers/net/wimax/i2400m/usb-notif.c
@@ -98,7 +98,7 @@ int i2400mu_notification_grok(struct i2400mu *i2400mu, const void *buf,
 	}
 	ret = i2400m_is_boot_barker(i2400m, buf, buf_len);
 	if (unlikely(ret >= 0))
-		ret = i2400m_dev_reset_handle(i2400m);
+		ret = i2400m_dev_reset_handle(i2400m, "device rebooted");
 	else	/* Unknown or unexpected data in the notif message */
 		i2400m_unknown_barker(i2400m, buf, buf_len);
 error_bad_size:
-- 
1.6.2.5


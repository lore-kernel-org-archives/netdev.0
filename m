From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2.6.33/4 08/13] wimax/i2400m: fix deadlock: don't do BUS reset under i2400m->init_mutex
Date: Wed,  4 Nov 2009 13:40:03 -0800
Message-ID: <b9ee95010bee6c0e17d18bc9d9c0cfab6e8cb73a.1257370737.git.inaky@linux.intel.com>
References: <cover.1257370737.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga12.intel.com ([143.182.124.36]:45111 "EHLO
	azsmga102.ch.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932773AbZKDVmN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:42:13 -0500
In-Reply-To: <cover.1257370737.git.inaky@linux.intel.com>
In-Reply-To: <cover.1257370737.git.inaky@linux.intel.com>
References: <cover.1257370737.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since the addition of the pre/post reset handlers, it became clear
that we cannot do a I2400M-RT-BUS type reset while holding the
init_mutex, as in the case of USB, it will deadlock when trying to
call i2400m_pre_reset().

Thus, the following changes:

 - clarify the fact that calling bus_reset() w/ I2400M_RT_BUS while
   holding init_mutex is a no-no.

 - i2400m_dev_reset_handle() will do a BUS reset to recover a gone
   device after unlocking init_mutex.

 - in the USB reset implementation, when cold and warm reset fails,
   fallback to QUEUING a usb reset, not executing a USB reset, so it
   happens from another context and does not deadlock.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/driver.c |   10 +++++++---
 drivers/net/wimax/i2400m/i2400m.h |    3 +++
 drivers/net/wimax/i2400m/usb.c    |   14 ++++++++++----
 3 files changed, 20 insertions(+), 7 deletions(-)

diff --git a/drivers/net/wimax/i2400m/driver.c b/drivers/net/wimax/i2400m/driver.c
index 810eda7..10673af 100644
--- a/drivers/net/wimax/i2400m/driver.c
+++ b/drivers/net/wimax/i2400m/driver.c
@@ -765,9 +765,7 @@ void __i2400m_dev_reset_handle(struct work_struct *ws)
 		wmb();		/* see i2400m->updown's documentation  */
 		dev_err(dev, "%s: cannot start the device: %d\n",
 			reason, result);
-		result = i2400m->bus_reset(i2400m, I2400M_RT_BUS);
-		if (result >= 0)
-			result = -ENODEV;
+		result = -EUCLEAN;
 	}
 out_unlock:
 	if (i2400m->reset_ctx) {
@@ -775,6 +773,12 @@ out_unlock:
 		complete(&ctx->completion);
 	}
 	mutex_unlock(&i2400m->init_mutex);
+	if (result == -EUCLEAN) {
+		/* ops, need to clean up [w/ init_mutex not held] */
+		result = i2400m->bus_reset(i2400m, I2400M_RT_BUS);
+		if (result >= 0)
+			result = -ENODEV;
+	}
 out:
 	i2400m_put(i2400m);
 	kfree(iw);
diff --git a/drivers/net/wimax/i2400m/i2400m.h b/drivers/net/wimax/i2400m/i2400m.h
index 8fc8a0c..f5ed7d5 100644
--- a/drivers/net/wimax/i2400m/i2400m.h
+++ b/drivers/net/wimax/i2400m/i2400m.h
@@ -281,6 +281,9 @@ struct i2400m_barker_db;
  *     process, so it cannot rely on common infrastructure being laid
  *     out.
  *
+ *     IMPORTANT: don't call reset on RT_BUS with i2400m->init_mutex
+ *     held, as the .pre/.post reset handlers will deadlock.
+ *
  * @bus_bm_retries: [fill] How many times shall a firmware upload /
  *     device initialization be retried? Different models of the same
  *     device might need different values, hence it is set by the
diff --git a/drivers/net/wimax/i2400m/usb.c b/drivers/net/wimax/i2400m/usb.c
index 8b246cc..418db12 100644
--- a/drivers/net/wimax/i2400m/usb.c
+++ b/drivers/net/wimax/i2400m/usb.c
@@ -254,7 +254,6 @@ int i2400mu_bus_reset(struct i2400m *i2400m, enum i2400m_reset_type rt)
 			sizeof(i2400m_COLD_BOOT_BARKER),
 			i2400mu->endpoint_cfg.reset_cold);
 	else if (rt == I2400M_RT_BUS) {
-do_bus_reset:
 		result = usb_reset_device(i2400mu->usb_dev);
 		switch (result) {
 		case 0:
@@ -262,7 +261,7 @@ do_bus_reset:
 		case -ENODEV:
 		case -ENOENT:
 		case -ESHUTDOWN:
-			result = rt == I2400M_RT_WARM ? -ENODEV : 0;
+			result = 0;
 			break;	/* We assume the device is disconnected */
 		default:
 			dev_err(dev, "USB reset failed (%d), giving up!\n",
@@ -275,10 +274,17 @@ do_bus_reset:
 	if (result < 0
 	    && result != -EINVAL	/* device is gone */
 	    && rt != I2400M_RT_BUS) {
+		/*
+		 * Things failed -- resort to lower level reset, that
+		 * we queue in another context; the reason for this is
+		 * that the pre and post reset functionality requires
+		 * the i2400m->init_mutex; RT_WARM and RT_COLD can
+		 * come from areas where i2400m->init_mutex is taken.
+		 */
 		dev_err(dev, "%s reset failed (%d); trying USB reset\n",
 			rt == I2400M_RT_WARM ? "warm" : "cold", result);
-		rt = I2400M_RT_BUS;
-		goto do_bus_reset;
+		usb_queue_reset_device(i2400mu->usb_iface);
+		result = -ENODEV;
 	}
 	d_fnend(3, dev, "(i2400m %p rt %u) = %d\n", i2400m, rt, result);
 	return result;
-- 
1.6.2.5


From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 8/9] i2400m: drop i2400m_schedule_work()
Date: Sun, 12 Dec 2010 16:53:04 +0100
Message-ID: <1292169185-10579-9-git-send-email-tj@kernel.org>
References: <1292169185-10579-1-git-send-email-tj@kernel.org>
Cc: Tejun Heo <tj@kernel.org>,
	Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>,
	linux-wimax@intel.com
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:56552 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753181Ab0LLPxW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Dec 2010 10:53:22 -0500
In-Reply-To: <1292169185-10579-1-git-send-email-tj@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

i2400m implements dynamic work allocation and queueing mechanism in
i2400_schedule_work(); however, this is only used for reset and
recovery which can be served equally well with preallocated per device
works.

Replace i2400m_schedule_work() with two work structs in struct i2400m.
These works are explicitly canceled when the device is released making
calls to flush_scheduled_work(), which is being deprecated,
unnecessary.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>
Cc: linux-wimax@intel.com
Cc: netdev@vger.kernel.org
---
 drivers/net/wimax/i2400m/driver.c |   96 ++++++------------------------------
 drivers/net/wimax/i2400m/i2400m.h |   19 ++-----
 drivers/net/wimax/i2400m/sdio.c   |    1 -
 drivers/net/wimax/i2400m/usb.c    |    1 -
 4 files changed, 21 insertions(+), 96 deletions(-)

diff --git a/drivers/net/wimax/i2400m/driver.c b/drivers/net/wimax/i2400m/driver.c
index cdedab4..f060332 100644
--- a/drivers/net/wimax/i2400m/driver.c
+++ b/drivers/net/wimax/i2400m/driver.c
@@ -92,54 +92,6 @@ MODULE_PARM_DESC(barkers,
 		 "signal; values are appended to a list--setting one value "
 		 "as zero cleans the existing list and starts a new one.");
 
-static
-struct i2400m_work *__i2400m_work_setup(
-	struct i2400m *i2400m, void (*fn)(struct work_struct *),
-	gfp_t gfp_flags, const void *pl, size_t pl_size)
-{
-	struct i2400m_work *iw;
-
-	iw = kzalloc(sizeof(*iw) + pl_size, gfp_flags);
-	if (iw == NULL)
-		return NULL;
-	iw->i2400m = i2400m_get(i2400m);
-	iw->pl_size = pl_size;
-	memcpy(iw->pl, pl, pl_size);
-	INIT_WORK(&iw->ws, fn);
-	return iw;
-}
-
-
-/*
- * Schedule i2400m's specific work on the system's queue.
- *
- * Used for a few cases where we really need it; otherwise, identical
- * to i2400m_queue_work().
- *
- * Returns < 0 errno code on error, 1 if ok.
- *
- * If it returns zero, something really bad happened, as it means the
- * works struct was already queued, but we have just allocated it, so
- * it should not happen.
- */
-static int i2400m_schedule_work(struct i2400m *i2400m,
-			 void (*fn)(struct work_struct *), gfp_t gfp_flags,
-			 const void *pl, size_t pl_size)
-{
-	int result;
-	struct i2400m_work *iw;
-
-	result = -ENOMEM;
-	iw = __i2400m_work_setup(i2400m, fn, gfp_flags, pl, pl_size);
-	if (iw != NULL) {
-		result = schedule_work(&iw->ws);
-		if (WARN_ON(result == 0))
-			result = -ENXIO;
-	}
-	return result;
-}
-
-
 /*
  * WiMAX stack operation: relay a message from user space
  *
@@ -648,17 +600,11 @@ EXPORT_SYMBOL_GPL(i2400m_post_reset);
 static
 void __i2400m_dev_reset_handle(struct work_struct *ws)
 {
-	int result;
-	struct i2400m_work *iw = container_of(ws, struct i2400m_work, ws);
-	const char *reason;
-	struct i2400m *i2400m = iw->i2400m;
+	struct i2400m *i2400m = container_of(ws, struct i2400m, reset_ws);
+	const char *reason = i2400m->reset_reason;
 	struct device *dev = i2400m_dev(i2400m);
 	struct i2400m_reset_ctx *ctx = i2400m->reset_ctx;
-
-	if (WARN_ON(iw->pl_size != sizeof(reason)))
-		reason = "SW BUG: reason n/a";
-	else
-		memcpy(&reason, iw->pl, sizeof(reason));
+	int result;
 
 	d_fnstart(3, dev, "(ws %p i2400m %p reason %s)\n", ws, i2400m, reason);
 
@@ -733,8 +679,6 @@ void __i2400m_dev_reset_handle(struct work_struct *ws)
 		}
 	}
 out:
-	i2400m_put(i2400m);
-	kfree(iw);
 	d_fnend(3, dev, "(ws %p i2400m %p reason %s) = void\n",
 		ws, i2400m, reason);
 }
@@ -754,8 +698,8 @@ out:
  */
 int i2400m_dev_reset_handle(struct i2400m *i2400m, const char *reason)
 {
-	return i2400m_schedule_work(i2400m, __i2400m_dev_reset_handle,
-				    GFP_ATOMIC, &reason, sizeof(reason));
+	i2400m->reset_reason = reason;
+	return schedule_work(&i2400m->reset_ws);
 }
 EXPORT_SYMBOL_GPL(i2400m_dev_reset_handle);
 
@@ -768,14 +712,9 @@ EXPORT_SYMBOL_GPL(i2400m_dev_reset_handle);
 static
 void __i2400m_error_recovery(struct work_struct *ws)
 {
-	struct i2400m_work *iw = container_of(ws, struct i2400m_work, ws);
-	struct i2400m *i2400m = iw->i2400m;
+	struct i2400m *i2400m = container_of(ws, struct i2400m, recovery_ws);
 
 	i2400m_reset(i2400m, I2400M_RT_BUS);
-
-	i2400m_put(i2400m);
-	kfree(iw);
-	return;
 }
 
 /*
@@ -805,18 +744,10 @@ void __i2400m_error_recovery(struct work_struct *ws)
  */
 void i2400m_error_recovery(struct i2400m *i2400m)
 {
-	struct device *dev = i2400m_dev(i2400m);
-
-	if (atomic_add_return(1, &i2400m->error_recovery) == 1) {
-		if (i2400m_schedule_work(i2400m, __i2400m_error_recovery,
-			GFP_ATOMIC, NULL, 0) < 0) {
-			dev_err(dev, "run out of memory for "
-				"scheduling an error recovery ?\n");
-			atomic_dec(&i2400m->error_recovery);
-		}
-	} else
+	if (atomic_add_return(1, &i2400m->error_recovery) == 1)
+		schedule_work(&i2400m->recovery_ws);
+	else
 		atomic_dec(&i2400m->error_recovery);
-	return;
 }
 EXPORT_SYMBOL_GPL(i2400m_error_recovery);
 
@@ -886,6 +817,10 @@ void i2400m_init(struct i2400m *i2400m)
 
 	mutex_init(&i2400m->init_mutex);
 	/* wake_tx_ws is initialized in i2400m_tx_setup() */
+
+	INIT_WORK(&i2400m->reset_ws, __i2400m_dev_reset_handle);
+	INIT_WORK(&i2400m->recovery_ws, __i2400m_error_recovery);
+
 	atomic_set(&i2400m->bus_reset_retries, 0);
 
 	i2400m->alive = 0;
@@ -1040,6 +975,9 @@ void i2400m_release(struct i2400m *i2400m)
 
 	i2400m_dev_stop(i2400m);
 
+	cancel_work_sync(&i2400m->reset_ws);
+	cancel_work_sync(&i2400m->recovery_ws);
+
 	i2400m_debugfs_rm(i2400m);
 	sysfs_remove_group(&i2400m->wimax_dev.net_dev->dev.kobj,
 			   &i2400m_dev_attr_group);
@@ -1083,8 +1021,6 @@ module_init(i2400m_driver_init);
 static
 void __exit i2400m_driver_exit(void)
 {
-	/* for scheds i2400m_dev_reset_handle() */
-	flush_scheduled_work();
 	i2400m_barker_db_exit();
 }
 module_exit(i2400m_driver_exit);
diff --git a/drivers/net/wimax/i2400m/i2400m.h b/drivers/net/wimax/i2400m/i2400m.h
index 59ac770..17ecaa4 100644
--- a/drivers/net/wimax/i2400m/i2400m.h
+++ b/drivers/net/wimax/i2400m/i2400m.h
@@ -632,6 +632,11 @@ struct i2400m {
 	struct work_struct wake_tx_ws;
 	struct sk_buff *wake_tx_skb;
 
+	struct work_struct reset_ws;
+	const char *reset_reason;
+
+	struct work_struct recovery_ws;
+
 	struct dentry *debugfs_dentry;
 	const char *fw_name;		/* name of the current firmware image */
 	unsigned long fw_version;	/* version of the firmware interface */
@@ -896,20 +901,6 @@ struct device *i2400m_dev(struct i2400m *i2400m)
 	return i2400m->wimax_dev.net_dev->dev.parent;
 }
 
-/*
- * Helper for scheduling simple work functions
- *
- * This struct can get any kind of payload attached (normally in the
- * form of a struct where you pack the stuff you want to pass to the
- * _work function).
- */
-struct i2400m_work {
-	struct work_struct ws;
-	struct i2400m *i2400m;
-	size_t pl_size;
-	u8 pl[0];
-};
-
 extern int i2400m_msg_check_status(const struct i2400m_l3l4_hdr *,
 				   char *, size_t);
 extern int i2400m_msg_size_check(struct i2400m *,
diff --git a/drivers/net/wimax/i2400m/sdio.c b/drivers/net/wimax/i2400m/sdio.c
index 9bfc26e..be428ca 100644
--- a/drivers/net/wimax/i2400m/sdio.c
+++ b/drivers/net/wimax/i2400m/sdio.c
@@ -590,7 +590,6 @@ module_init(i2400ms_driver_init);
 static
 void __exit i2400ms_driver_exit(void)
 {
-	flush_scheduled_work();	/* for the stuff we schedule */
 	sdio_unregister_driver(&i2400m_sdio_driver);
 }
 module_exit(i2400ms_driver_exit);
diff --git a/drivers/net/wimax/i2400m/usb.c b/drivers/net/wimax/i2400m/usb.c
index d3365ac..10e3ab3 100644
--- a/drivers/net/wimax/i2400m/usb.c
+++ b/drivers/net/wimax/i2400m/usb.c
@@ -780,7 +780,6 @@ module_init(i2400mu_driver_init);
 static
 void __exit i2400mu_driver_exit(void)
 {
-	flush_scheduled_work();	/* for the stuff we schedule from sysfs.c */
 	usb_deregister(&i2400mu_driver);
 }
 module_exit(i2400mu_driver_exit);
-- 
1.7.1


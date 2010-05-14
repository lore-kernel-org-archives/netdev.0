From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [patch 2.6.35 07/25] wimax/i2400m: add the error recovery mechanism on TX path
Date: Fri, 14 May 2010 14:45:06 -0700
Message-ID: <599e59538448ee49d5470f226bb191b2f78aa3a2.1273708027.git.inaky.perez-gonzalez@intel.com>
References: <cover.1273708027.git.inaky.perez-gonzalez@intel.com>
Cc: Cindy H Kao <cindy.h.kao@intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:50303 "EHLO
	fmsmga101.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932514Ab0ENVtJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 May 2010 17:49:09 -0400
In-Reply-To: <cover.1273708027.git.inaky.perez-gonzalez@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cindy H Kao <cindy.h.kao@intel.com>

This patch adds an error recovery mechanism on TX path.
The intention is to bring back the device to some known state
whenever TX sees -110 (-ETIMEOUT) on copying the data to the HW FIFO.

The TX failure could mean a device bus stuck or function stuck, so
the current error recovery implementation is to trigger a bus reset
and expect this can bring back the device.

Since the TX work is done in a thread context, there may be a queue of TX works
already that all hit the -ETIMEOUT error condition because the device has
somewhat stuck already. We don't want any consecutive bus resets simply because
multiple TX works in the queue all hit the same device erratum, the flag
"error_recovery" is introduced to denote if we are ready for taking any
error recovery. See @error_recovery doc in i2400m.h.

Signed-off-by: Cindy H Kao <cindy.h.kao@intel.com>
---
 drivers/net/wimax/i2400m/driver.c  |   74 ++++++++++++++++++++++++++++++++++++
 drivers/net/wimax/i2400m/i2400m.h  |   14 +++++++
 drivers/net/wimax/i2400m/sdio-tx.c |    4 ++
 3 files changed, 92 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wimax/i2400m/driver.c b/drivers/net/wimax/i2400m/driver.c
index 1674dba..d83fe84 100644
--- a/drivers/net/wimax/i2400m/driver.c
+++ b/drivers/net/wimax/i2400m/driver.c
@@ -395,6 +395,16 @@ retry:
 	result = i2400m_dev_initialize(i2400m);
 	if (result < 0)
 		goto error_dev_initialize;
+
+	/* We don't want any additional unwanted error recovery triggered
+	 * from any other context so if anything went wrong before we come
+	 * here, let's keep i2400m->error_recovery untouched and leave it to
+	 * dev_reset_handle(). See dev_reset_handle(). */
+
+	atomic_dec(&i2400m->error_recovery);
+	/* Every thing works so far, ok, now we are ready to
+	 * take error recovery if it's required. */
+
 	/* At this point, reports will come for the device and set it
 	 * to the right state if it is different than UNINITIALIZED */
 	d_fnend(3, dev, "(net_dev %p [i2400m %p]) = %d\n",
@@ -770,6 +780,66 @@ int i2400m_dev_reset_handle(struct i2400m *i2400m, const char *reason)
 EXPORT_SYMBOL_GPL(i2400m_dev_reset_handle);
 
 
+ /*
+ * The actual work of error recovery.
+ *
+ * The current implementation of error recovery is to trigger a bus reset.
+ */
+static
+void __i2400m_error_recovery(struct work_struct *ws)
+{
+	struct i2400m_work *iw = container_of(ws, struct i2400m_work, ws);
+	struct i2400m *i2400m = iw->i2400m;
+
+	i2400m_reset(i2400m, I2400M_RT_BUS);
+
+	i2400m_put(i2400m);
+	kfree(iw);
+	return;
+}
+
+/*
+ * Schedule a work struct for error recovery.
+ *
+ * The intention of error recovery is to bring back the device to some
+ * known state whenever TX sees -110 (-ETIMEOUT) on copying the data to
+ * the device. The TX failure could mean a device bus stuck, so the current
+ * error recovery implementation is to trigger a bus reset to the device
+ * and hopefully it can bring back the device.
+ *
+ * The actual work of error recovery has to be in a thread context because
+ * it is kicked off in the TX thread (i2400ms->tx_workqueue) which is to be
+ * destroyed by the error recovery mechanism (currently a bus reset).
+ *
+ * Also, there may be already a queue of TX works that all hit
+ * the -ETIMEOUT error condition because the device is stuck already.
+ * Since bus reset is used as the error recovery mechanism and we don't
+ * want consecutive bus resets simply because the multiple TX works
+ * in the queue all hit the same device erratum, the flag "error_recovery"
+ * is introduced for preventing unwanted consecutive bus resets.
+ *
+ * Error recovery shall only be invoked again if previous one was completed.
+ * The flag error_recovery is set when error recovery mechanism is scheduled,
+ * and is checked when we need to schedule another error recovery. If it is
+ * in place already, then we shouldn't schedule another one.
+ */
+void i2400m_error_recovery(struct i2400m *i2400m)
+{
+	struct device *dev = i2400m_dev(i2400m);
+
+	if (atomic_add_return(1, &i2400m->error_recovery) == 1) {
+		if (i2400m_schedule_work(i2400m, __i2400m_error_recovery,
+			GFP_ATOMIC, NULL, 0) < 0) {
+			dev_err(dev, "run out of memory for "
+				"scheduling an error recovery ?\n");
+			atomic_dec(&i2400m->error_recovery);
+		}
+	} else
+		atomic_dec(&i2400m->error_recovery);
+	return;
+}
+EXPORT_SYMBOL_GPL(i2400m_error_recovery);
+
 /*
  * Alloc the command and ack buffers for boot mode
  *
@@ -839,6 +909,10 @@ void i2400m_init(struct i2400m *i2400m)
 	atomic_set(&i2400m->bus_reset_retries, 0);
 
 	i2400m->alive = 0;
+
+	/* initialize error_recovery to 1 for denoting we
+	 * are not yet ready to take any error recovery */
+	atomic_set(&i2400m->error_recovery, 1);
 }
 EXPORT_SYMBOL_GPL(i2400m_init);
 
diff --git a/drivers/net/wimax/i2400m/i2400m.h b/drivers/net/wimax/i2400m/i2400m.h
index ad8e6a3..7a9c2c5 100644
--- a/drivers/net/wimax/i2400m/i2400m.h
+++ b/drivers/net/wimax/i2400m/i2400m.h
@@ -545,6 +545,15 @@ struct i2400m_barker_db;
  *	all the device reboot events detected can be still handled properly
  *	by either dev_reset_handle() or .pre_reset/.post_reset as long as
  *	the driver presents. It is set 0 along with @updown in dev_stop().
+ *
+ * @error_recovery: flag to denote if we are ready to take an error recovery.
+ *	0 for ready to take an error recovery; 1 for not ready. It is
+ *	initialized to 1 while probe() since we don't tend to take any error
+ *	recovery during probe(). It is decremented by 1 whenever dev_start()
+ *	succeeds to indicate we are ready to take error recovery from now on.
+ *	It is checked every time we wanna schedule an error recovery. If an
+ *	error recovery is already in place (error_recovery was set 1), we
+ *	should not schedule another one until the last one is done.
  */
 struct i2400m {
 	struct wimax_dev wimax_dev;	/* FIRST! See doc */
@@ -625,6 +634,10 @@ struct i2400m {
 
 	/* if the device is expected to be alive */
 	unsigned alive;
+
+	/* 0 if we are ready for error recovery; 1 if not ready  */
+	atomic_t error_recovery;
+
 };
 
 
@@ -847,6 +860,7 @@ void i2400m_put(struct i2400m *i2400m)
 extern int i2400m_dev_reset_handle(struct i2400m *, const char *);
 extern int i2400m_pre_reset(struct i2400m *);
 extern int i2400m_post_reset(struct i2400m *);
+extern void i2400m_error_recovery(struct i2400m *);
 
 /*
  * _setup()/_release() are called by the probe/disconnect functions of
diff --git a/drivers/net/wimax/i2400m/sdio-tx.c b/drivers/net/wimax/i2400m/sdio-tx.c
index 412b6a8..b53cd1c 100644
--- a/drivers/net/wimax/i2400m/sdio-tx.c
+++ b/drivers/net/wimax/i2400m/sdio-tx.c
@@ -98,6 +98,10 @@ void i2400ms_tx_submit(struct work_struct *ws)
 				tx_msg_size, result);
 		}
 
+		if (result == -ETIMEDOUT) {
+			i2400m_error_recovery(i2400m);
+			break;
+		}
 		d_printf(2, dev, "TX: %zub submitted\n", tx_msg_size);
 	}
 
-- 
1.6.6.1


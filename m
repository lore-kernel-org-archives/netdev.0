From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [patch 2.6.35 06/25] wimax/i2400m: fix for missed reset events if triggered by dev_reset_handle()
Date: Fri, 14 May 2010 14:45:05 -0700
Message-ID: <f4e413458104210bc29aa5c437882c68b4b20100.1273708027.git.inaky.perez-gonzalez@intel.com>
References: <cover.1273708027.git.inaky.perez-gonzalez@intel.com>
Cc: Cindy H Kao <cindy.h.kao@intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:52953 "EHLO
	fmsmga101.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932507Ab0ENVtJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 May 2010 17:49:09 -0400
In-Reply-To: <cover.1273708027.git.inaky.perez-gonzalez@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cindy H Kao <cindy.h.kao@intel.com>

The problem is only seen on SDIO interface since on USB, a bus reset would
really re-probe the driver, but on SDIO interface, a bus reset will not
re-enumerate the SDIO bus, so no driver re-probe is happening. Therefore,
on SDIO interface, the reset event should be still detected and handled by
dev_reset_handle().

Problem description:
Whenever a reboot barker is received during operational mode (i2400m->boot_mode == 0),
dev_reset_handle() is invoked to handle that function reset event.
dev_reset_handle() then sets the flag i2400m->boot_mode to 1 indicating the device is
back to bootmode before proceeding to dev_stop() and dev_start().
If dev_start() returns failure, a bus reset is triggered by dev_reset_handle().

The flag i2400m->boot_mode then remains 1 when the second reboot barker arrives.
However the interrupt service routine i2400ms_rx() instead of invoking dev_reset_handle()
to handle that reset event, it filters out that boot event to bootmode because it sees
the flag i2400m->boot_mode equal to 1.

The fix:
Maintain the flag i2400m->boot_mode within dev_reset_handle() and set the flag
i2400m->boot_mode to 1 when entering dev_reset_handle(). It remains 1
until the dev_reset_handle() issues a bus reset. ie: the bus reset is
taking place just like it happens for the first time during operational mode.

To denote the actual device state and the state we expect, a flag i2400m->alive
is introduced in addition to the existing flag i2400m->updown.
It's maintained with the same way for i2400m->updown but instead of reflecting
the actual state like i2400m->updown does, i2400m->alive maintains the state
we expect. i2400m->alive is set 1 just like whenever i2400m->updown is set 1.
Yet i2400m->alive remains 1 since we expect the device to be up all the time
until the driver is removed. See the doc for @alive in i2400m.h.

An enumeration I2400M_BUS_RESET_RETRIES is added to define the maximum number of
bus resets that a device reboot can retry.

A counter i2400m->bus_reset_retries is added to track how many bus resets
have been retried in one device reboot. If I2400M_BUS_RESET_RETRIES bus resets
were retried in this boot, we give up any further retrying so the device would enter
low power state. The counter i2400m->bus_reset_retries is incremented whenever
dev_reset_handle() is issuing a bus reset and is cleared to 0 when dev_start() is
successfully done, ie: a successful reboot.

Signed-off-by: Cindy H Kao <cindy.h.kao@intel.com>
---
 drivers/net/wimax/i2400m/driver.c |   68 ++++++++++++++++++++++++++++---------
 drivers/net/wimax/i2400m/i2400m.h |   34 ++++++++++++++++++
 2 files changed, 86 insertions(+), 16 deletions(-)

diff --git a/drivers/net/wimax/i2400m/driver.c b/drivers/net/wimax/i2400m/driver.c
index 3a6c8dd..1674dba 100644
--- a/drivers/net/wimax/i2400m/driver.c
+++ b/drivers/net/wimax/i2400m/driver.c
@@ -436,7 +436,8 @@ int i2400m_dev_start(struct i2400m *i2400m, enum i2400m_bri bm_flags)
 		result = __i2400m_dev_start(i2400m, bm_flags);
 		if (result >= 0) {
 			i2400m->updown = 1;
-			wmb();	/* see i2400m->updown's documentation */
+			i2400m->alive = 1;
+			wmb();/* see i2400m->updown and i2400m->alive's doc */
 		}
 	}
 	mutex_unlock(&i2400m->init_mutex);
@@ -497,7 +498,8 @@ void i2400m_dev_stop(struct i2400m *i2400m)
 	if (i2400m->updown) {
 		__i2400m_dev_stop(i2400m);
 		i2400m->updown = 0;
-		wmb();	/* see i2400m->updown's documentation  */
+		i2400m->alive = 0;
+		wmb();	/* see i2400m->updown and i2400m->alive's doc */
 	}
 	mutex_unlock(&i2400m->init_mutex);
 }
@@ -669,6 +671,9 @@ void __i2400m_dev_reset_handle(struct work_struct *ws)
 
 	d_fnstart(3, dev, "(ws %p i2400m %p reason %s)\n", ws, i2400m, reason);
 
+	i2400m->boot_mode = 1;
+	wmb();		/* Make sure i2400m_msg_to_dev() sees boot_mode */
+
 	result = 0;
 	if (mutex_trylock(&i2400m->init_mutex) == 0) {
 		/* We are still in i2400m_dev_start() [let it fail] or
@@ -679,32 +684,62 @@ void __i2400m_dev_reset_handle(struct work_struct *ws)
 		complete(&i2400m->msg_completion);
 		goto out;
 	}
-	if (i2400m->updown == 0)  {
-		dev_info(dev, "%s: device is down, doing nothing\n", reason);
-		goto out_unlock;
-	}
+
 	dev_err(dev, "%s: reinitializing driver\n", reason);
-	__i2400m_dev_stop(i2400m);
-	result = __i2400m_dev_start(i2400m,
-				    I2400M_BRI_SOFT | I2400M_BRI_MAC_REINIT);
-	if (result < 0) {
+	rmb();
+	if (i2400m->updown) {
+		__i2400m_dev_stop(i2400m);
 		i2400m->updown = 0;
 		wmb();		/* see i2400m->updown's documentation  */
-		dev_err(dev, "%s: cannot start the device: %d\n",
-			reason, result);
-		result = -EUCLEAN;
 	}
-out_unlock:
+
+	if (i2400m->alive) {
+		result = __i2400m_dev_start(i2400m,
+				    I2400M_BRI_SOFT | I2400M_BRI_MAC_REINIT);
+		if (result < 0) {
+			dev_err(dev, "%s: cannot start the device: %d\n",
+				reason, result);
+			result = -EUCLEAN;
+			if (atomic_read(&i2400m->bus_reset_retries)
+					>= I2400M_BUS_RESET_RETRIES) {
+				result = -ENODEV;
+				dev_err(dev, "tried too many times to "
+					"reset the device, giving up\n");
+			}
+		}
+	}
+
 	if (i2400m->reset_ctx) {
 		ctx->result = result;
 		complete(&ctx->completion);
 	}
 	mutex_unlock(&i2400m->init_mutex);
 	if (result == -EUCLEAN) {
+		/*
+		 * We come here because the reset during operational mode
+		 * wasn't successully done and need to proceed to a bus
+		 * reset. For the dev_reset_handle() to be able to handle
+		 * the reset event later properly, we restore boot_mode back
+		 * to the state before previous reset. ie: just like we are
+		 * issuing the bus reset for the first time
+		 */
+		i2400m->boot_mode = 0;
+		wmb();
+
+		atomic_inc(&i2400m->bus_reset_retries);
 		/* ops, need to clean up [w/ init_mutex not held] */
 		result = i2400m_reset(i2400m, I2400M_RT_BUS);
 		if (result >= 0)
 			result = -ENODEV;
+	} else {
+		rmb();
+		if (i2400m->alive) {
+			/* great, we expect the device state up and
+			 * dev_start() actually brings the device state up */
+			i2400m->updown = 1;
+			wmb();
+			atomic_set(&i2400m->bus_reset_retries, 0);
+		}
 	}
 out:
 	i2400m_put(i2400m);
@@ -729,8 +764,6 @@ out:
  */
 int i2400m_dev_reset_handle(struct i2400m *i2400m, const char *reason)
 {
-	i2400m->boot_mode = 1;
-	wmb();		/* Make sure i2400m_msg_to_dev() sees boot_mode */
 	return i2400m_schedule_work(i2400m, __i2400m_dev_reset_handle,
 				    GFP_ATOMIC, &reason, sizeof(reason));
 }
@@ -803,6 +836,9 @@ void i2400m_init(struct i2400m *i2400m)
 
 	mutex_init(&i2400m->init_mutex);
 	/* wake_tx_ws is initialized in i2400m_tx_setup() */
+	atomic_set(&i2400m->bus_reset_retries, 0);
+
+	i2400m->alive = 0;
 }
 EXPORT_SYMBOL_GPL(i2400m_init);
 
diff --git a/drivers/net/wimax/i2400m/i2400m.h b/drivers/net/wimax/i2400m/i2400m.h
index da218b9..ad8e6a3 100644
--- a/drivers/net/wimax/i2400m/i2400m.h
+++ b/drivers/net/wimax/i2400m/i2400m.h
@@ -177,6 +177,11 @@ enum {
 	I2400M_BM_ACK_BUF_SIZE = 256,
 };
 
+enum {
+	/* Maximum number of bus reset can be retried */
+	I2400M_BUS_RESET_RETRIES = 3,
+};
+
 /**
  * struct i2400m_poke_table - Hardware poke table for the Intel 2400m
  *
@@ -517,6 +522,29 @@ struct i2400m_barker_db;
  *     same.
  *
  * @pm_notifier: used to register for PM events
+ *
+ * @bus_reset_retries: counter for the number of bus resets attempted for
+ *	this boot. It's not for tracking the number of bus resets during
+ *	the whole driver life cycle (from insmod to rmmod) but for the
+ *	number of dev_start() executed until dev_start() returns a success
+ *	(ie: a good boot means a dev_stop() followed by a successful
+ *	dev_start()). dev_reset_handler() increments this counter whenever
+ *	it is triggering a bus reset. It checks this counter to decide if a
+ *	subsequent bus reset should be retried. dev_reset_handler() retries
+ *	the bus reset until dev_start() succeeds or the counter reaches
+ *	I2400M_BUS_RESET_RETRIES. The counter is cleared to 0 in
+ *	dev_reset_handle() when dev_start() returns a success,
+ *	ie: a successul boot is completed.
+ *
+ * @alive: flag to denote if the device *should* be alive. This flag is
+ *	everything like @updown (see doc for @updown) except reflecting
+ *	the device state *we expect* rather than the actual state as denoted
+ *	by @updown. It is set 1 whenever @updown is set 1 in dev_start().
+ *	Then the device is expected to be alive all the time
+ *	(i2400m->alive remains 1) until the driver is removed. Therefore
+ *	all the device reboot events detected can be still handled properly
+ *	by either dev_reset_handle() or .pre_reset/.post_reset as long as
+ *	the driver presents. It is set 0 along with @updown in dev_stop().
  */
 struct i2400m {
 	struct wimax_dev wimax_dev;	/* FIRST! See doc */
@@ -591,6 +619,12 @@ struct i2400m {
 	struct i2400m_barker_db *barker;
 
 	struct notifier_block pm_notifier;
+
+	/* counting bus reset retries in this boot */
+	atomic_t bus_reset_retries;
+
+	/* if the device is expected to be alive */
+	unsigned alive;
 };
 
 
-- 
1.6.6.1


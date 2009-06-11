From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [2.6.31 03/21] wimax/i2400m: i2400m's work queue should be initialized before RX support
Date: Thu, 11 Jun 2009 14:35:40 -0700
Message-ID: <e9a6b45be580d648ed2f21646214733504bd4d6f.1244755662.git.inaky@linux.intel.com>
References: <cover.1244755662.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:27879 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755578AbZFKVgk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2009 17:36:40 -0400
In-Reply-To: <cover.1244755662.git.inaky@linux.intel.com>
In-Reply-To: <cover.1244755662.git.inaky@linux.intel.com>
References: <cover.1244755662.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RX support is the only user of the work-queue, to process
reports/notifications from the device. Thus, it needs the work queue
to be initialized first.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/driver.c |   21 ++++++++++++++-------
 1 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/drivers/net/wimax/i2400m/driver.c b/drivers/net/wimax/i2400m/driver.c
index 86dd18a..006eb12 100644
--- a/drivers/net/wimax/i2400m/driver.c
+++ b/drivers/net/wimax/i2400m/driver.c
@@ -385,6 +385,11 @@ error:
  * Uploads firmware and brings up all the resources needed to be able
  * to communicate with the device.
  *
+ * The workqueue has to be setup early, at least before RX handling
+ * (it's only real user for now) so it can process reports as they
+ * arrive. We also want to destroy it if we retry, to make sure it is
+ * flushed...easier like this.
+ *
  * TX needs to be setup before the bus-specific code (otherwise on
  * shutdown, the bus-tx code could try to access it).
  */
@@ -410,15 +415,15 @@ retry:
 	result = i2400m_rx_setup(i2400m);
 	if (result < 0)
 		goto error_rx_setup;
-	result = i2400m->bus_dev_start(i2400m);
-	if (result < 0)
-		goto error_bus_dev_start;
 	i2400m->work_queue = create_singlethread_workqueue(wimax_dev->name);
 	if (i2400m->work_queue == NULL) {
 		result = -ENOMEM;
 		dev_err(dev, "cannot create workqueue\n");
 		goto error_create_workqueue;
 	}
+	result = i2400m->bus_dev_start(i2400m);
+	if (result < 0)
+		goto error_bus_dev_start;
 	result = i2400m_firmware_check(i2400m);	/* fw versions ok? */
 	if (result < 0)
 		goto error_fw_check;
@@ -440,10 +445,10 @@ retry:
 error_dev_initialize:
 error_check_mac_addr:
 error_fw_check:
-	destroy_workqueue(i2400m->work_queue);
-error_create_workqueue:
 	i2400m->bus_dev_stop(i2400m);
 error_bus_dev_start:
+	destroy_workqueue(i2400m->work_queue);
+error_create_workqueue:
 	i2400m_rx_release(i2400m);
 error_rx_setup:
 	i2400m_tx_release(i2400m);
@@ -479,7 +484,9 @@ int i2400m_dev_start(struct i2400m *i2400m, enum i2400m_bri bm_flags)
  *
  * Returns: 0 if ok, < 0 errno code on error.
  *
- * Releases all the resources allocated to communicate with the device.
+ * Releases all the resources allocated to communicate with the
+ * device. Note we cannot destroy the workqueue earlier as until RX is
+ * fully destroyed, it could still try to schedule jobs.
  */
 static
 void __i2400m_dev_stop(struct i2400m *i2400m)
@@ -491,8 +498,8 @@ void __i2400m_dev_stop(struct i2400m *i2400m)
 	wimax_state_change(wimax_dev, __WIMAX_ST_QUIESCING);
 	i2400m_dev_shutdown(i2400m);
 	i2400m->ready = 0;
-	destroy_workqueue(i2400m->work_queue);
 	i2400m->bus_dev_stop(i2400m);
+	destroy_workqueue(i2400m->work_queue);
 	i2400m_rx_release(i2400m);
 	i2400m_tx_release(i2400m);
 	wimax_state_change(wimax_dev, WIMAX_ST_DOWN);
-- 
1.6.2.3


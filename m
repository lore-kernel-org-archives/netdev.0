From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2.6.33/5 01/12] wimax/i2400m: make i2400m->bus_dev_{stop,start}() optional
Date: Wed,  4 Nov 2009 13:40:06 -0800
Message-ID: <097acbeff98178e01c2f6adb2259ab4d811340cc.1257370738.git.inaky@linux.intel.com>
References: <cover.1257370738.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:28863 "EHLO
	fmsmga101.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932730AbZKDVmS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:42:18 -0500
In-Reply-To: <cover.1257370738.git.inaky@linux.intel.com>
In-Reply-To: <cover.1257370738.git.inaky@linux.intel.com>
References: <cover.1257370738.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In coming commits, the i2400m SDIO driver will not use
i2400m->bus_dev_stop().

Thus changed to check before calling, as an empty stub has more
overhead than a call to check if the function pointer is non-NULL.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/driver.c |   14 +++++++++-----
 drivers/net/wimax/i2400m/i2400m.h |   14 +++++++-------
 2 files changed, 16 insertions(+), 12 deletions(-)

diff --git a/drivers/net/wimax/i2400m/driver.c b/drivers/net/wimax/i2400m/driver.c
index cc900b9..cc58a86 100644
--- a/drivers/net/wimax/i2400m/driver.c
+++ b/drivers/net/wimax/i2400m/driver.c
@@ -384,9 +384,11 @@ retry:
 		dev_err(dev, "cannot create workqueue\n");
 		goto error_create_workqueue;
 	}
-	result = i2400m->bus_dev_start(i2400m);
-	if (result < 0)
-		goto error_bus_dev_start;
+	if (i2400m->bus_dev_start) {
+		result = i2400m->bus_dev_start(i2400m);
+		if (result < 0)
+			goto error_bus_dev_start;
+	}
 	i2400m->ready = 1;
 	wmb();		/* see i2400m->ready's documentation  */
 	/* process pending reports from the device */
@@ -413,7 +415,8 @@ error_check_mac_addr:
 	wmb();		/* see i2400m->ready's documentation  */
 	flush_workqueue(i2400m->work_queue);
 error_fw_check:
-	i2400m->bus_dev_stop(i2400m);
+	if (i2400m->bus_dev_stop)
+		i2400m->bus_dev_stop(i2400m);
 error_bus_dev_start:
 	destroy_workqueue(i2400m->work_queue);
 error_create_workqueue:
@@ -480,7 +483,8 @@ void __i2400m_dev_stop(struct i2400m *i2400m)
 	wmb();		/* see i2400m->ready's documentation  */
 	flush_workqueue(i2400m->work_queue);
 
-	i2400m->bus_dev_stop(i2400m);
+	if (i2400m->bus_dev_stop)
+		i2400m->bus_dev_stop(i2400m);
 	destroy_workqueue(i2400m->work_queue);
 	i2400m_rx_release(i2400m);
 	i2400m_tx_release(i2400m);
diff --git a/drivers/net/wimax/i2400m/i2400m.h b/drivers/net/wimax/i2400m/i2400m.h
index 55bca43..5eee985 100644
--- a/drivers/net/wimax/i2400m/i2400m.h
+++ b/drivers/net/wimax/i2400m/i2400m.h
@@ -245,19 +245,19 @@ struct i2400m_barker_db;
  *     all the host resources created to  handle communication with
  *     the device.
  *
- * @bus_dev_start: [fill] Function called by the bus-generic code
- *     [i2400m_dev_start()] to setup the bus-specific communications
- *     to the the device. See LIFE CYCLE above.
+ * @bus_dev_start: [optional fill] Function called by the bus-generic
+ *     code [i2400m_dev_start()] to do things needed to start the
+ *     device. See LIFE CYCLE above.
  *
  *     NOTE: Doesn't need to upload the firmware, as that is taken
  *     care of by the bus-generic code.
  *
- * @bus_dev_stop: [fill] Function called by the bus-generic code
- *     [i2400m_dev_stop()] to shutdown the bus-specific communications
- *     to the the device. See LIFE CYCLE above.
+ * @bus_dev_stop: [optional fill] Function called by the bus-generic
+ *     code [i2400m_dev_stop()] to do things needed for stopping the
+ *     device. See LIFE CYCLE above.
  *
  *     This function does not need to reset the device, just tear down
- *     all the host resources created to  handle communication with
+ *     all the host resources created to handle communication with
  *     the device.
  *
  * @bus_tx_kick: [fill] Function called by the bus-generic code to let
-- 
1.6.2.5


From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [2.6.31 10/21] wimax/i2400m: don't reset device on i2400m_dev_shutdown()
Date: Thu, 11 Jun 2009 14:35:47 -0700
Message-ID: <b4bd07e3b13e3c848c7678c4fc870cca1d22ed4e.1244755662.git.inaky@linux.intel.com>
References: <cover.1244755662.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:27879 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751641AbZFKVgj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2009 17:36:39 -0400
In-Reply-To: <cover.1244755662.git.inaky@linux.intel.com>
In-Reply-To: <cover.1244755662.git.inaky@linux.intel.com>
References: <cover.1244755662.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

i2400m_dev_shutdown() tried to reset the device to put it in a known
state before shutting down.

But that turned out to be pointless. We reach this case in two paths:

 1 - when the device resets, to clean up state
 2 - when the driver is unloaded, for the same

however, in both cases it is pointless; in (1) the device is already
reset, why do it again? in (2) we can't -- the USB stack, for example,
doesn't allow communicating with the device when the driver is being
unbound and if the device is disconnected, the device is gone already.

So just remove it. Leave the function as a placeholder for future
cleanups that will be done from data allocated by the driver during
device operation.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/control.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/wimax/i2400m/control.c b/drivers/net/wimax/i2400m/control.c
index 89cdfe4..d8e0cdf 100644
--- a/drivers/net/wimax/i2400m/control.c
+++ b/drivers/net/wimax/i2400m/control.c
@@ -1396,16 +1396,16 @@ error:
  *
  * @i2400m: device descriptor
  *
- * Gracefully stops the device, moving it to the lowest power
- * consumption state possible.
+ * Release resources acquired during the running of the device; in
+ * theory, should also tell the device to go to sleep, switch off the
+ * radio, all that, but at this point, in most cases (driver
+ * disconnection, reset handling) we can't even talk to the device.
  */
 void i2400m_dev_shutdown(struct i2400m *i2400m)
 {
-	int result = -ENODEV;
 	struct device *dev = i2400m_dev(i2400m);
 
 	d_fnstart(3, dev, "(i2400m %p)\n", i2400m);
-	result = i2400m->bus_reset(i2400m, I2400M_RT_WARM);
-	d_fnend(3, dev, "(i2400m %p) = void [%d]\n", i2400m, result);
+	d_fnend(3, dev, "(i2400m %p) = void\n", i2400m);
 	return;
 }
-- 
1.6.2.3


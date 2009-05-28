From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [patch 2.6.31 09/10] wimax/i2400m: usb: fix device reset on autosuspend while not yet idle
Date: Wed, 27 May 2009 18:05:14 -0700
Message-ID: <5b274b76ee31802e4376f44bc96a4b3bc9f8b918.1243472510.git.inaky@linux.intel.com>
References: <cover.1243472509.git.inaky@linux.intel.com>
 <e9de4b9426eeeddf56110425cfd88e43828e7146.1243472510.git.inaky@linux.intel.com>
 <22d4458f609ba31f1382e25844125e421dcd4163.1243472510.git.inaky@linux.intel.com>
 <05962df1398ad316feb1e20160b7502731bebc97.1243472510.git.inaky@linux.intel.com>
 <ba98dde3cde9f5910789b32852c692fc8cd0a4aa.1243472510.git.inaky@linux.intel.com>
 <74bd64a25b220d21e50c7c9a85f26ff6617b3728.1243472510.git.inaky@linux.intel.com>
 <f3aea79091a4fc501235f2e743cc073ebd962934.1243472510.git.inaky@linux.intel.com>
 <d791bac79c5e9840a3e5317a4bb79acafde911f9.1243472510.git.inaky@linux.intel.com>
 <4d58364611c66a20ea1e28223b8f638fd2e35981.1243472510.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:59892 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757603AbZE1BFt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2009 21:05:49 -0400
In-Reply-To: <4d58364611c66a20ea1e28223b8f638fd2e35981.1243472510.git.inaky@linux.intel.com>
In-Reply-To: <cover.1243472509.git.inaky@linux.intel.com>
References: <cover.1243472509.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the i2400m is connected to a network, the host interface (USB)
cannot be suspended. For that to happen, the device has to have
negotiated with the basestation to put the link on IDLE state.

If the host tries to put the device in standby while it is connected
but not idle, the device resets, as the driver should not do that.

To avoid triggering that, when the USB susbsytem requires the driver
to autosuspend the device, the driver checks if the device is not yet
idle. If it is not, the request is requested (will be retried again
later on after the autosuspend timeout). At some point the device will
enter idle and the request will succeed (unless of course, there is
network traffic, but at that point, there is no idle neither in the
link or the host interface).

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/usb.c |   35 ++++++++++++++++++++++++++++++-----
 1 files changed, 30 insertions(+), 5 deletions(-)

diff --git a/drivers/net/wimax/i2400m/usb.c b/drivers/net/wimax/i2400m/usb.c
index ca4151a..1785132 100644
--- a/drivers/net/wimax/i2400m/usb.c
+++ b/drivers/net/wimax/i2400m/usb.c
@@ -505,27 +505,52 @@ int i2400mu_suspend(struct usb_interface *iface, pm_message_t pm_msg)
 #ifdef CONFIG_PM
 	struct usb_device *usb_dev = i2400mu->usb_dev;
 #endif
+	unsigned is_autosuspend = 0;
 	struct i2400m *i2400m = &i2400mu->i2400m;
 
+#ifdef CONFIG_PM
+	if (usb_dev->auto_pm > 0)
+		is_autosuspend = 1;
+#endif
+
 	d_fnstart(3, dev, "(iface %p pm_msg %u)\n", iface, pm_msg.event);
 	if (i2400m->updown == 0)
 		goto no_firmware;
-	d_printf(1, dev, "fw up, requesting standby\n");
+	if (i2400m->state == I2400M_SS_DATA_PATH_CONNECTED && is_autosuspend) {
+		/* ugh -- the device is connected and this suspend
+		 * request is an autosuspend one (not a system standby
+		 * / hibernate).
+		 *
+		 * The only way the device can go to standby is if the
+		 * link with the base station is in IDLE mode; that
+		 * were the case, we'd be in status
+		 * I2400M_SS_CONNECTED_IDLE. But we are not.
+		 *
+		 * If we *tell* him to go power save now, it'll reset
+		 * as a precautionary measure, so if this is an
+		 * autosuspend thing, say no and it'll come back
+		 * later, when the link is IDLE
+		 */
+		result = -EBADF;
+		d_printf(1, dev, "fw up, link up, not-idle, autosuspend: "
+			 "not entering powersave\n");
+		goto error_not_now;
+	}
+	d_printf(1, dev, "fw up: entering powersave\n");
 	atomic_dec(&i2400mu->do_autopm);
 	result = i2400m_cmd_enter_powersave(i2400m);
 	atomic_inc(&i2400mu->do_autopm);
-#ifdef CONFIG_PM
-	if (result < 0 && usb_dev->auto_pm == 0) {
+	if (result < 0 && !is_autosuspend) {
 		/* System suspend, can't fail */
 		dev_err(dev, "failed to suspend, will reset on resume\n");
 		result = 0;
 	}
-#endif
 	if (result < 0)
 		goto error_enter_powersave;
 	i2400mu_notification_release(i2400mu);
-	d_printf(1, dev, "fw up, got standby\n");
+	d_printf(1, dev, "powersave requested\n");
 error_enter_powersave:
+error_not_now:
 no_firmware:
 	d_fnend(3, dev, "(iface %p pm_msg %u) = %d\n",
 		iface, pm_msg.event, result);
-- 
1.6.2.3


From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [2.6.31 19/21] wimax/i2400m: use -EL3RST to indicate device reset instead of -ERESTARTSYS
Date: Thu, 11 Jun 2009 14:35:56 -0700
Message-ID: <0bcfc5ef016e8217709c65c5a7335e40ceabc99c.1244755662.git.inaky@linux.intel.com>
References: <cover.1244755662.git.inaky@linux.intel.com>
Cc: Cindy H Kao <cindy.h.kao@intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:28457 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756351AbZFKVgu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2009 17:36:50 -0400
In-Reply-To: <cover.1244755662.git.inaky@linux.intel.com>
In-Reply-To: <cover.1244755662.git.inaky@linux.intel.com>
References: <cover.1244755662.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cindy H Kao <cindy.h.kao@intel.com>

When the i2400m device resets, the driver code will force some
functions to return a -ERESTARTSYS error code, which can is used by
the caller to determine which recovery actions to take.

However, in certain situations the only thing that can be done is to
bubble up said error code to user space, for handling.

However, -ERESTARSYS was a poor choice, as it is supposed to be used
by the kernel only.

As such, replace -ERESTARTSYS with -EL3RST; as well, in
i2400m_msg_to_dev(), when the device is in boot mode (following a
recent reset), return -EL3RST instead of -ENODEV (meaning the device
is in bootrom mode after a reset, not that the device was
disconnected, and thus, normal commands cannot be executed).

Signed-off-by: Cindy H Kao <cindy.h.kao@intel.com>
---
 drivers/net/wimax/i2400m/control.c |    2 +-
 drivers/net/wimax/i2400m/driver.c  |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wimax/i2400m/control.c b/drivers/net/wimax/i2400m/control.c
index f9399f2..0730868 100644
--- a/drivers/net/wimax/i2400m/control.c
+++ b/drivers/net/wimax/i2400m/control.c
@@ -697,7 +697,7 @@ struct sk_buff *i2400m_msg_to_dev(struct i2400m *i2400m,
 
 	rmb();		/* Make sure we see what i2400m_dev_reset_handle() */
 	if (i2400m->boot_mode)
-		return ERR_PTR(-ENODEV);
+		return ERR_PTR(-EL3RST);
 
 	msg_l3l4_hdr = buf;
 	/* Check msg & payload consistency */
diff --git a/drivers/net/wimax/i2400m/driver.c b/drivers/net/wimax/i2400m/driver.c
index 2a093c5..304f044 100644
--- a/drivers/net/wimax/i2400m/driver.c
+++ b/drivers/net/wimax/i2400m/driver.c
@@ -453,7 +453,7 @@ error_rx_setup:
 	i2400m_tx_release(i2400m);
 error_tx_setup:
 error_bootstrap:
-	if (result == -ERESTARTSYS && times-- > 0) {
+	if (result == -EL3RST && times-- > 0) {
 		flags = I2400M_BRI_SOFT|I2400M_BRI_MAC_REINIT;
 		goto retry;
 	}
@@ -560,7 +560,7 @@ void __i2400m_dev_reset_handle(struct work_struct *ws)
 		 * i2400m_dev_stop() [we are shutting down anyway, so
 		 * ignore it] or we are resetting somewhere else. */
 		dev_err(dev, "device rebooted\n");
-		i2400m_msg_to_dev_cancel_wait(i2400m, -ERESTARTSYS);
+		i2400m_msg_to_dev_cancel_wait(i2400m, -EL3RST);
 		complete(&i2400m->msg_completion);
 		goto out;
 	}
-- 
1.6.2.3


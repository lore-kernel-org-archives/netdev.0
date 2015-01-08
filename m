From: Chunyan Zhang <zhang.chunyan@linaro.org>
Subject: [PATCH v2 3/6] irda: irda-usb: Replace timeval with ktime_t
Date: Thu,  8 Jan 2015 12:01:29 +0800
Message-ID: <1420689692-8760-4-git-send-email-zhang.chunyan@linaro.org>
References: <driver-irda-v2>
 <1420689692-8760-1-git-send-email-zhang.chunyan@linaro.org>
Cc: arnd@arndb.de, zhang.lyra@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: samuel@sortiz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:42366 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753352AbbAHECr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 23:02:47 -0500
Received: by mail-pa0-f54.google.com with SMTP id fb1so9090810pad.13
        for <netdev@vger.kernel.org>; Wed, 07 Jan 2015 20:02:47 -0800 (PST)
In-Reply-To: <1420689692-8760-1-git-send-email-zhang.chunyan@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The irda usb driver uses 'timeval', which we try to remove in the kernel
because all 32-bit time types will break in the year 2038.

This patch also changes do_gettimeofday() to ktime_get() accordingly,
since ktime_get returns a ktime_t, but do_gettimeofday returns a
struct timeval, and the other reason is that ktime_get() uses
the monotonic clock.

This patch uses ktime_us_delta to get the elapsed time, and in this
way it no longer needs to check for the overflow, because
ktime_us_delta returns time difference of microsecond.

Signed-off-by: Chunyan Zhang <zhang.chunyan@linaro.org>
Reviewed-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/irda/irda-usb.c |   10 ++--------
 drivers/net/irda/irda-usb.h |    5 ++---
 2 files changed, 4 insertions(+), 11 deletions(-)

diff --git a/drivers/net/irda/irda-usb.c b/drivers/net/irda/irda-usb.c
index 48b2f9a..f6c9163 100644
--- a/drivers/net/irda/irda-usb.c
+++ b/drivers/net/irda/irda-usb.c
@@ -495,18 +495,12 @@ static netdev_tx_t irda_usb_hard_xmit(struct sk_buff *skb,
 		mtt = irda_get_mtt(skb);
 		if (mtt) {
 			int diff;
-			do_gettimeofday(&self->now);
-			diff = self->now.tv_usec - self->stamp.tv_usec;
+			diff = ktime_us_delta(ktime_get(), self->stamp);
 #ifdef IU_USB_MIN_RTT
 			/* Factor in USB delays -> Get rid of udelay() that
 			 * would be lost in the noise - Jean II */
 			diff += IU_USB_MIN_RTT;
 #endif /* IU_USB_MIN_RTT */
-			/* If the usec counter did wraparound, the diff will
-			 * go negative (tv_usec is a long), so we need to
-			 * correct it by one second. Jean II */
-			if (diff < 0)
-				diff += 1000000;
 
 		        /* Check if the mtt is larger than the time we have
 			 * already used by all the protocol processing
@@ -869,7 +863,7 @@ static void irda_usb_receive(struct urb *urb)
 	 * reduce the min turn time a bit since we will know
 	 * how much time we have used for protocol processing
 	 */
-        do_gettimeofday(&self->stamp);
+	self->stamp = ktime_get();
 
 	/* Check if we need to copy the data to a new skb or not.
 	 * For most frames, we use ZeroCopy and pass the already
diff --git a/drivers/net/irda/irda-usb.h b/drivers/net/irda/irda-usb.h
index 58ddb52..8ac389f 100644
--- a/drivers/net/irda/irda-usb.h
+++ b/drivers/net/irda/irda-usb.h
@@ -29,7 +29,7 @@
  *
  *****************************************************************************/
 
-#include <linux/time.h>
+#include <linux/ktime.h>
 
 #include <net/irda/irda.h>
 #include <net/irda/irda_device.h>      /* struct irlap_cb */
@@ -157,8 +157,7 @@ struct irda_usb_cb {
 	char *speed_buff;		/* Buffer for speed changes */
 	char *tx_buff;
 
-	struct timeval stamp;
-	struct timeval now;
+	ktime_t stamp;
 
 	spinlock_t lock;		/* For serializing Tx operations */
 
-- 
1.7.9.5

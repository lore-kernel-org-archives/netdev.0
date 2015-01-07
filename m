From: Chunyan Zhang <zhang.chunyan@linaro.org>
Subject: [PATCH 3/6] driver/net/irda: Replace timeval with ktime_t in irda-usb
Date: Wed,  7 Jan 2015 11:39:35 +0800
Message-ID: <1420601978-15866-4-git-send-email-zhang.chunyan@linaro.org>
References: <driver-irda>
 <1420601978-15866-1-git-send-email-zhang.chunyan@linaro.org>
Cc: arnd@linaro.org, zhang.lyra@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: samuel@sortiz.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1420601978-15866-1-git-send-email-zhang.chunyan@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch changes the 32-bit time type (timeval) to the 64-bit one
(ktime_t), since 32-bit time types will break in the year 2038.
So, I use ktime_t instead of all uses of timeval.

This patch also changes do_gettimeofday() to ktime_get() accordingly,
since ktime_get returns a ktime_t, but do_gettimeofday returns a
struct timeval, and the other reason is that ktime_get() uses
the monotonic clock.

This patch use ktime_us_delta to get the elapsed time, and in this
way it no longer needs to check for the overflow, because
ktime_us_delta returns time difference of microsecond.

Signed-off-by: Chunyan Zhang <zhang.chunyan@linaro.org>
---
 drivers/net/irda/irda-usb.c |   11 +++--------
 drivers/net/irda/irda-usb.h |    6 +++---
 2 files changed, 6 insertions(+), 11 deletions(-)

diff --git a/drivers/net/irda/irda-usb.c b/drivers/net/irda/irda-usb.c
index 48b2f9a..be86840 100644
--- a/drivers/net/irda/irda-usb.c
+++ b/drivers/net/irda/irda-usb.c
@@ -495,18 +495,13 @@ static netdev_tx_t irda_usb_hard_xmit(struct sk_buff *skb,
 		mtt = irda_get_mtt(skb);
 		if (mtt) {
 			int diff;
-			do_gettimeofday(&self->now);
-			diff = self->now.tv_usec - self->stamp.tv_usec;
+			self->now = ktime_get();
+			diff = ktime_us_delta(self->now, self->stamp);
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
@@ -869,7 +864,7 @@ static void irda_usb_receive(struct urb *urb)
 	 * reduce the min turn time a bit since we will know
 	 * how much time we have used for protocol processing
 	 */
-        do_gettimeofday(&self->stamp);
+	self->stamp = ktime_get();
 
 	/* Check if we need to copy the data to a new skb or not.
 	 * For most frames, we use ZeroCopy and pass the already
diff --git a/drivers/net/irda/irda-usb.h b/drivers/net/irda/irda-usb.h
index 58ddb52..8093216 100644
--- a/drivers/net/irda/irda-usb.h
+++ b/drivers/net/irda/irda-usb.h
@@ -29,7 +29,7 @@
  *
  *****************************************************************************/
 
-#include <linux/time.h>
+#include <linux/ktime.h>
 
 #include <net/irda/irda.h>
 #include <net/irda/irda_device.h>      /* struct irlap_cb */
@@ -157,8 +157,8 @@ struct irda_usb_cb {
 	char *speed_buff;		/* Buffer for speed changes */
 	char *tx_buff;
 
-	struct timeval stamp;
-	struct timeval now;
+	ktime_t stamp;
+	ktime_t now;
 
 	spinlock_t lock;		/* For serializing Tx operations */
 
-- 
1.7.9.5

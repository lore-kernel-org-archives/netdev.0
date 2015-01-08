From: Chunyan Zhang <zhang.chunyan@linaro.org>
Subject: [PATCH v2 2/6] irda: ali-ircc: Replace timeval with ktime_t
Date: Thu,  8 Jan 2015 12:01:28 +0800
Message-ID: <1420689692-8760-3-git-send-email-zhang.chunyan@linaro.org>
References: <driver-irda-v2>
 <1420689692-8760-1-git-send-email-zhang.chunyan@linaro.org>
Cc: arnd@arndb.de, zhang.lyra@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: samuel@sortiz.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1420689692-8760-1-git-send-email-zhang.chunyan@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ali ircc driver uses 'timeval', which we try to remove in the kernel
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
 drivers/net/irda/ali-ircc.c |   11 +++--------
 drivers/net/irda/ali-ircc.h |    5 ++---
 2 files changed, 5 insertions(+), 11 deletions(-)

diff --git a/drivers/net/irda/ali-ircc.c b/drivers/net/irda/ali-ircc.c
index 58f98f4..58ae11a 100644
--- a/drivers/net/irda/ali-ircc.c
+++ b/drivers/net/irda/ali-ircc.c
@@ -1462,17 +1462,12 @@ static netdev_tx_t ali_ircc_fir_hard_xmit(struct sk_buff *skb,
 		if (mtt) 
 		{
 			/* Check how much time we have used already */
-			do_gettimeofday(&self->now);
-			
-			diff = self->now.tv_usec - self->stamp.tv_usec;
+			diff = ktime_us_delta(ktime_get(), self->stamp);
 			/* self->stamp is set from ali_ircc_dma_receive_complete() */
 							
 			pr_debug("%s(), ******* diff = %d *******\n",
 				 __func__, diff);
-			
-			if (diff < 0) 
-				diff += 1000000;
-			
+
 			/* Check if the mtt is larger than the time we have
 			 * already used by all the protocol processing
 			 */
@@ -1884,7 +1879,7 @@ static int  ali_ircc_dma_receive_complete(struct ali_ircc_cb *self)
 			 * reduce the min turn time a bit since we will know
 			 * how much time we have used for protocol processing
 			 */
-			do_gettimeofday(&self->stamp);
+			self->stamp = ktime_get();
 
 			skb = dev_alloc_skb(len+1);
 			if (skb == NULL)  
diff --git a/drivers/net/irda/ali-ircc.h b/drivers/net/irda/ali-ircc.h
index 0c8edb4..c2d9747 100644
--- a/drivers/net/irda/ali-ircc.h
+++ b/drivers/net/irda/ali-ircc.h
@@ -22,7 +22,7 @@
 #ifndef ALI_IRCC_H
 #define ALI_IRCC_H
 
-#include <linux/time.h>
+#include <linux/ktime.h>
 
 #include <linux/spinlock.h>
 #include <linux/pm.h>
@@ -209,8 +209,7 @@ struct ali_ircc_cb {
 	
 	unsigned char rcvFramesOverflow;
 		
-	struct timeval stamp;
-	struct timeval now;
+	ktime_t stamp;
 
 	spinlock_t lock;           /* For serializing operations */
 	
-- 
1.7.9.5

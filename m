From: Chunyan Zhang <zhang.chunyan@linaro.org>
Subject: [PATCH v2 4/6] irda: nsc-ircc: Replace timeval with ktime_t
Date: Thu,  8 Jan 2015 12:01:30 +0800
Message-ID: <1420689692-8760-5-git-send-email-zhang.chunyan@linaro.org>
References: <driver-irda-v2>
 <1420689692-8760-1-git-send-email-zhang.chunyan@linaro.org>
Cc: arnd@arndb.de, zhang.lyra@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: samuel@sortiz.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1420689692-8760-1-git-send-email-zhang.chunyan@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The nsc ircc driver uses 'timeval', which we try to remove in the kernel
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
 drivers/net/irda/nsc-ircc.c |    7 ++-----
 drivers/net/irda/nsc-ircc.h |    5 ++---
 2 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/drivers/net/irda/nsc-ircc.c b/drivers/net/irda/nsc-ircc.c
index e7317b1..dc0dbd8 100644
--- a/drivers/net/irda/nsc-ircc.c
+++ b/drivers/net/irda/nsc-ircc.c
@@ -1501,10 +1501,7 @@ static netdev_tx_t nsc_ircc_hard_xmit_fir(struct sk_buff *skb,
 		mtt = irda_get_mtt(skb);
 		if (mtt) {
 			/* Check how much time we have used already */
-			do_gettimeofday(&self->now);
-			diff = self->now.tv_usec - self->stamp.tv_usec;
-			if (diff < 0) 
-				diff += 1000000;
+			diff = ktime_us_delta(ktime_get(), self->stamp);
 			
 			/* Check if the mtt is larger than the time we have
 			 * already used by all the protocol processing
@@ -1867,7 +1864,7 @@ static int nsc_ircc_dma_receive_complete(struct nsc_ircc_cb *self, int iobase)
 			 * reduce the min turn time a bit since we will know
 			 * how much time we have used for protocol processing
 			 */
-			do_gettimeofday(&self->stamp);
+			self->stamp = ktime_get();
 
 			skb = dev_alloc_skb(len+1);
 			if (skb == NULL)  {
diff --git a/drivers/net/irda/nsc-ircc.h b/drivers/net/irda/nsc-ircc.h
index 32fa582..7be5acb 100644
--- a/drivers/net/irda/nsc-ircc.h
+++ b/drivers/net/irda/nsc-ircc.h
@@ -28,7 +28,7 @@
 #ifndef NSC_IRCC_H
 #define NSC_IRCC_H
 
-#include <linux/time.h>
+#include <linux/ktime.h>
 
 #include <linux/spinlock.h>
 #include <linux/pm.h>
@@ -263,8 +263,7 @@ struct nsc_ircc_cb {
 
 	__u8 ier;                  /* Interrupt enable register */
 
-	struct timeval stamp;
-	struct timeval now;
+	ktime_t stamp;
 
 	spinlock_t lock;           /* For serializing operations */
 	
-- 
1.7.9.5

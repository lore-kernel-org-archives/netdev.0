From: Chunyan Zhang <zhang.chunyan@linaro.org>
Subject: [PATCH 4/6] driver/net/irda: Replace timeval with ktime_t in nsc-ircc
Date: Wed,  7 Jan 2015 11:39:36 +0800
Message-ID: <1420601978-15866-5-git-send-email-zhang.chunyan@linaro.org>
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
 drivers/net/irda/nsc-ircc.c |    8 +++-----
 drivers/net/irda/nsc-ircc.h |    6 +++---
 2 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/drivers/net/irda/nsc-ircc.c b/drivers/net/irda/nsc-ircc.c
index e7317b1..cabb82e 100644
--- a/drivers/net/irda/nsc-ircc.c
+++ b/drivers/net/irda/nsc-ircc.c
@@ -1501,10 +1501,8 @@ static netdev_tx_t nsc_ircc_hard_xmit_fir(struct sk_buff *skb,
 		mtt = irda_get_mtt(skb);
 		if (mtt) {
 			/* Check how much time we have used already */
-			do_gettimeofday(&self->now);
-			diff = self->now.tv_usec - self->stamp.tv_usec;
-			if (diff < 0) 
-				diff += 1000000;
+			self->now = ktime_get();
+			diff = ktime_us_delta(self->now, self->stamp);
 			
 			/* Check if the mtt is larger than the time we have
 			 * already used by all the protocol processing
@@ -1867,7 +1865,7 @@ static int nsc_ircc_dma_receive_complete(struct nsc_ircc_cb *self, int iobase)
 			 * reduce the min turn time a bit since we will know
 			 * how much time we have used for protocol processing
 			 */
-			do_gettimeofday(&self->stamp);
+			self->stamp = ktime_get();
 
 			skb = dev_alloc_skb(len+1);
 			if (skb == NULL)  {
diff --git a/drivers/net/irda/nsc-ircc.h b/drivers/net/irda/nsc-ircc.h
index 32fa582..dd2185a 100644
--- a/drivers/net/irda/nsc-ircc.h
+++ b/drivers/net/irda/nsc-ircc.h
@@ -28,7 +28,7 @@
 #ifndef NSC_IRCC_H
 #define NSC_IRCC_H
 
-#include <linux/time.h>
+#include <linux/ktime.h>
 
 #include <linux/spinlock.h>
 #include <linux/pm.h>
@@ -263,8 +263,8 @@ struct nsc_ircc_cb {
 
 	__u8 ier;                  /* Interrupt enable register */
 
-	struct timeval stamp;
-	struct timeval now;
+	ktime_t stamp;
+	ktime_t	now;
 
 	spinlock_t lock;           /* For serializing operations */
 	
-- 
1.7.9.5

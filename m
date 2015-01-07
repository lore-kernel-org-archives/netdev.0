From: Chunyan Zhang <zhang.chunyan@linaro.org>
Subject: [PATCH 2/6] driver/net/irda: Replace timeval with ktime_t in ali-ircc
Date: Wed,  7 Jan 2015 11:39:34 +0800
Message-ID: <1420601978-15866-3-git-send-email-zhang.chunyan@linaro.org>
References: <driver-irda>
 <1420601978-15866-1-git-send-email-zhang.chunyan@linaro.org>
Cc: arnd@linaro.org, zhang.lyra@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: samuel@sortiz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:58751 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756713AbbAGDky (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 22:40:54 -0500
Received: by mail-pd0-f170.google.com with SMTP id v10so1947795pde.1
        for <netdev@vger.kernel.org>; Tue, 06 Jan 2015 19:40:54 -0800 (PST)
In-Reply-To: <1420601978-15866-1-git-send-email-zhang.chunyan@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
 drivers/net/irda/ali-ircc.c |   12 ++++--------
 drivers/net/irda/ali-ircc.h |    6 +++---
 2 files changed, 7 insertions(+), 11 deletions(-)

diff --git a/drivers/net/irda/ali-ircc.c b/drivers/net/irda/ali-ircc.c
index 58f98f4..ab041a4 100644
--- a/drivers/net/irda/ali-ircc.c
+++ b/drivers/net/irda/ali-ircc.c
@@ -1462,17 +1462,13 @@ static netdev_tx_t ali_ircc_fir_hard_xmit(struct sk_buff *skb,
 		if (mtt) 
 		{
 			/* Check how much time we have used already */
-			do_gettimeofday(&self->now);
-			
-			diff = self->now.tv_usec - self->stamp.tv_usec;
+			self->now = ktime_get();
+			diff = ktime_us_delta(self->now, self->stamp);
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
@@ -1884,7 +1880,7 @@ static int  ali_ircc_dma_receive_complete(struct ali_ircc_cb *self)
 			 * reduce the min turn time a bit since we will know
 			 * how much time we have used for protocol processing
 			 */
-			do_gettimeofday(&self->stamp);
+			self->stamp = ktime_get();
 
 			skb = dev_alloc_skb(len+1);
 			if (skb == NULL)  
diff --git a/drivers/net/irda/ali-ircc.h b/drivers/net/irda/ali-ircc.h
index 0c8edb4..164ee42 100644
--- a/drivers/net/irda/ali-ircc.h
+++ b/drivers/net/irda/ali-ircc.h
@@ -22,7 +22,7 @@
 #ifndef ALI_IRCC_H
 #define ALI_IRCC_H
 
-#include <linux/time.h>
+#include <linux/ktime.h>
 
 #include <linux/spinlock.h>
 #include <linux/pm.h>
@@ -209,8 +209,8 @@ struct ali_ircc_cb {
 	
 	unsigned char rcvFramesOverflow;
 		
-	struct timeval stamp;
-	struct timeval now;
+	ktime_t stamp;
+	ktime_t now;
 
 	spinlock_t lock;           /* For serializing operations */
 	
-- 
1.7.9.5

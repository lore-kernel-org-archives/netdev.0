From: Chunyan Zhang <zhang.chunyan@linaro.org>
Subject: [PATCH 5/6] driver/net/irda: Replace timeval with ktime_t in stir4200
Date: Wed,  7 Jan 2015 11:39:37 +0800
Message-ID: <1420601978-15866-6-git-send-email-zhang.chunyan@linaro.org>
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

This patch use ktime_us_delta to get the elapsed time of microsecond.

Signed-off-by: Chunyan Zhang <zhang.chunyan@linaro.org>
---
 drivers/net/irda/stir4200.c |   18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/irda/stir4200.c b/drivers/net/irda/stir4200.c
index dd1bd10..008e12d 100644
--- a/drivers/net/irda/stir4200.c
+++ b/drivers/net/irda/stir4200.c
@@ -40,6 +40,7 @@
 #include <linux/moduleparam.h>
 
 #include <linux/kernel.h>
+#include <linux/ktime.h>
 #include <linux/types.h>
 #include <linux/time.h>
 #include <linux/skbuff.h>
@@ -174,7 +175,7 @@ struct stir_cb {
 	__u8		  *fifo_status;
 
 	iobuff_t  	  rx_buff;	/* receive unwrap state machine */
-	struct timeval	  rx_time;
+	ktime_t		rx_time;
 	int		  receiving;
 	struct urb	 *rx_urb;
 };
@@ -650,15 +651,14 @@ static int fifo_txwait(struct stir_cb *stir, int space)
 static void turnaround_delay(const struct stir_cb *stir, long us)
 {
 	long ticks;
-	struct timeval now;
+	ktime_t now;
 
 	if (us <= 0)
 		return;
 
-	do_gettimeofday(&now);
-	if (now.tv_sec - stir->rx_time.tv_sec > 0)
-		us -= USEC_PER_SEC;
-	us -= now.tv_usec - stir->rx_time.tv_usec;
+	now = ktime_get();
+	us -= ktime_us_delta(now, stir->rx_time);
+
 	if (us < 10)
 		return;
 
@@ -823,8 +823,8 @@ static void stir_rcv_irq(struct urb *urb)
 		pr_debug("receive %d\n", urb->actual_length);
 		unwrap_chars(stir, urb->transfer_buffer,
 			     urb->actual_length);
-		
-		do_gettimeofday(&stir->rx_time);
+
+		stir->rx_time = ktime_get();
 	}
 
 	/* kernel thread is stopping receiver don't resubmit */
@@ -876,7 +876,7 @@ static int stir_net_open(struct net_device *netdev)
 
 	skb_reserve(stir->rx_buff.skb, 1);
 	stir->rx_buff.head = stir->rx_buff.skb->data;
-	do_gettimeofday(&stir->rx_time);
+	stir->rx_time = ktime_get();
 
 	stir->rx_urb = usb_alloc_urb(0, GFP_KERNEL);
 	if (!stir->rx_urb) 
-- 
1.7.9.5

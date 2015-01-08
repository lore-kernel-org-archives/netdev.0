From: Chunyan Zhang <zhang.chunyan@linaro.org>
Subject: [PATCH v2 5/6] irda: stir4200: Replace timeval with ktime_t
Date: Thu,  8 Jan 2015 12:01:31 +0800
Message-ID: <1420689692-8760-6-git-send-email-zhang.chunyan@linaro.org>
References: <driver-irda-v2>
 <1420689692-8760-1-git-send-email-zhang.chunyan@linaro.org>
Cc: arnd@arndb.de, zhang.lyra@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: samuel@sortiz.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1420689692-8760-1-git-send-email-zhang.chunyan@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The stir4200 driver uses 'timeval', which we try to remove in the kernel
because all 32-bit time types will break in the year 2038.

This patch also changes do_gettimeofday() to ktime_get() accordingly,
since ktime_get returns a ktime_t, but do_gettimeofday returns a
struct timeval, and the other reason is that ktime_get() uses
the monotonic clock.

This patch uses ktime_us_delta to get the elapsed time of microsecond.

Signed-off-by: Chunyan Zhang <zhang.chunyan@linaro.org>
Reviewed-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/irda/stir4200.c |   16 +++++++---------
 1 file changed, 7 insertions(+), 9 deletions(-)

diff --git a/drivers/net/irda/stir4200.c b/drivers/net/irda/stir4200.c
index dd1bd10..83cc48a 100644
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
@@ -650,15 +651,12 @@ static int fifo_txwait(struct stir_cb *stir, int space)
 static void turnaround_delay(const struct stir_cb *stir, long us)
 {
 	long ticks;
-	struct timeval now;
 
 	if (us <= 0)
 		return;
 
-	do_gettimeofday(&now);
-	if (now.tv_sec - stir->rx_time.tv_sec > 0)
-		us -= USEC_PER_SEC;
-	us -= now.tv_usec - stir->rx_time.tv_usec;
+	us -= ktime_us_delta(ktime_get(), stir->rx_time);
+
 	if (us < 10)
 		return;
 
@@ -823,8 +821,8 @@ static void stir_rcv_irq(struct urb *urb)
 		pr_debug("receive %d\n", urb->actual_length);
 		unwrap_chars(stir, urb->transfer_buffer,
 			     urb->actual_length);
-		
-		do_gettimeofday(&stir->rx_time);
+
+		stir->rx_time = ktime_get();
 	}
 
 	/* kernel thread is stopping receiver don't resubmit */
@@ -876,7 +874,7 @@ static int stir_net_open(struct net_device *netdev)
 
 	skb_reserve(stir->rx_buff.skb, 1);
 	stir->rx_buff.head = stir->rx_buff.skb->data;
-	do_gettimeofday(&stir->rx_time);
+	stir->rx_time = ktime_get();
 
 	stir->rx_urb = usb_alloc_urb(0, GFP_KERNEL);
 	if (!stir->rx_urb) 
-- 
1.7.9.5

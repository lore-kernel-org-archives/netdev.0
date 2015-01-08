From: Chunyan Zhang <zhang.chunyan@linaro.org>
Subject: [PATCH v2 6/6] irda: vlsi_ir: Replace timeval with ktime_t
Date: Thu,  8 Jan 2015 12:01:32 +0800
Message-ID: <1420689692-8760-7-git-send-email-zhang.chunyan@linaro.org>
References: <driver-irda-v2>
 <1420689692-8760-1-git-send-email-zhang.chunyan@linaro.org>
Cc: arnd@arndb.de, zhang.lyra@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: samuel@sortiz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:48806 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932200AbbAHEC6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 23:02:58 -0500
Received: by mail-pd0-f176.google.com with SMTP id r10so8717190pdi.7
        for <netdev@vger.kernel.org>; Wed, 07 Jan 2015 20:02:57 -0800 (PST)
In-Reply-To: <1420689692-8760-1-git-send-email-zhang.chunyan@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The vlsi ir driver uses 'timeval', which we try to remove in the kernel
because all 32-bit time types will break in the year 2038.

This patch also changes do_gettimeofday() to ktime_get() accordingly,
since ktime_get returns a ktime_t, but do_gettimeofday returns a
struct timeval, and the other reason is that ktime_get() uses
the monotonic clock.

This patch uses ktime_us_delta to get the elapsed time of microsecond,
and uses div_s64_rem to get what seconds & microseconds time elapsed
for printing.

This patch also changes the function 'vlsi_hard_start_xmit' to do the
same things as the others drivers, that is passing the remaining time
into udelay() instead of looping until enough time has passed.

Signed-off-by: Chunyan Zhang <zhang.chunyan@linaro.org>
Reviewed-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/irda/vlsi_ir.c |   46 +++++++++++++-------------------------------
 drivers/net/irda/vlsi_ir.h |    2 +-
 2 files changed, 14 insertions(+), 34 deletions(-)

diff --git a/drivers/net/irda/vlsi_ir.c b/drivers/net/irda/vlsi_ir.c
index ac39d9f..a0849f4 100644
--- a/drivers/net/irda/vlsi_ir.c
+++ b/drivers/net/irda/vlsi_ir.c
@@ -33,6 +33,7 @@ MODULE_LICENSE("GPL");
 /********************************************************/
 
 #include <linux/kernel.h>
+#include <linux/ktime.h>
 #include <linux/init.h>
 #include <linux/interrupt.h>
 #include <linux/pci.h>
@@ -40,9 +41,9 @@ MODULE_LICENSE("GPL");
 #include <linux/netdevice.h>
 #include <linux/skbuff.h>
 #include <linux/delay.h>
-#include <linux/time.h>
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
+#include <linux/math64.h>
 #include <linux/mutex.h>
 #include <asm/uaccess.h>
 #include <asm/byteorder.h>
@@ -180,8 +181,7 @@ static void vlsi_proc_ndev(struct seq_file *seq, struct net_device *ndev)
 	vlsi_irda_dev_t *idev = netdev_priv(ndev);
 	u8 byte;
 	u16 word;
-	unsigned delta1, delta2;
-	struct timeval now;
+	s32 sec, usec;
 	unsigned iobase = ndev->base_addr;
 
 	seq_printf(seq, "\n%s link state: %s / %s / %s / %s\n", ndev->name,
@@ -277,17 +277,9 @@ static void vlsi_proc_ndev(struct seq_file *seq, struct net_device *ndev)
 	seq_printf(seq, "\nsw-state:\n");
 	seq_printf(seq, "IrPHY setup: %d baud - %s encoding\n", idev->baud, 
 		(idev->mode==IFF_SIR)?"SIR":((idev->mode==IFF_MIR)?"MIR":"FIR"));
-	do_gettimeofday(&now);
-	if (now.tv_usec >= idev->last_rx.tv_usec) {
-		delta2 = now.tv_usec - idev->last_rx.tv_usec;
-		delta1 = 0;
-	}
-	else {
-		delta2 = 1000000 + now.tv_usec - idev->last_rx.tv_usec;
-		delta1 = 1;
-	}
-	seq_printf(seq, "last rx: %lu.%06u sec\n",
-		now.tv_sec - idev->last_rx.tv_sec - delta1, delta2);	
+	sec = div_s64_rem(ktime_us_delta(ktime_get(), idev->last_rx),
+			  USEC_PER_SEC, &usec);
+	seq_printf(seq, "last rx: %ul.%06u sec\n", sec, usec);
 
 	seq_printf(seq, "RX: packets=%lu / bytes=%lu / errors=%lu / dropped=%lu",
 		ndev->stats.rx_packets, ndev->stats.rx_bytes, ndev->stats.rx_errors,
@@ -661,7 +653,7 @@ static void vlsi_rx_interrupt(struct net_device *ndev)
 		}
 	}
 
-	do_gettimeofday(&idev->last_rx); /* remember "now" for later mtt delay */
+	idev->last_rx = ktime_get(); /* remember "now" for later mtt delay */
 
 	vlsi_fill_rx(r);
 
@@ -858,9 +850,8 @@ static netdev_tx_t vlsi_hard_start_xmit(struct sk_buff *skb,
 	unsigned iobase = ndev->base_addr;
 	u8 status;
 	u16 config;
-	int mtt;
+	int mtt, diff;
 	int len, speed;
-	struct timeval  now, ready;
 	char *msg = NULL;
 
 	speed = irda_get_next_speed(skb);
@@ -940,21 +931,10 @@ static netdev_tx_t vlsi_hard_start_xmit(struct sk_buff *skb,
 	spin_unlock_irqrestore(&idev->lock, flags);
 
 	if ((mtt = irda_get_mtt(skb)) > 0) {
-	
-		ready.tv_usec = idev->last_rx.tv_usec + mtt;
-		ready.tv_sec = idev->last_rx.tv_sec;
-		if (ready.tv_usec >= 1000000) {
-			ready.tv_usec -= 1000000;
-			ready.tv_sec++;		/* IrLAP 1.1: mtt always < 1 sec */
-		}
-		for(;;) {
-			do_gettimeofday(&now);
-			if (now.tv_sec > ready.tv_sec ||
-			    (now.tv_sec==ready.tv_sec && now.tv_usec>=ready.tv_usec))
-			    	break;
-			udelay(100);
+		diff = ktime_us_delta(ktime_get(), idev->last_rx);
+		if (mtt > diff)
+			udelay(mtt - diff);
 			/* must not sleep here - called under netif_tx_lock! */
-		}
 	}
 
 	/* tx buffer already owned by CPU due to pci_dma_sync_single_for_cpu()
@@ -1333,7 +1313,7 @@ static int vlsi_start_hw(vlsi_irda_dev_t *idev)
 
 	vlsi_fill_rx(idev->rx_ring);
 
-	do_gettimeofday(&idev->last_rx);	/* first mtt may start from now on */
+	idev->last_rx = ktime_get();	/* first mtt may start from now on */
 
 	outw(0, iobase+VLSI_PIO_PROMPT);	/* kick hw state machine */
 
@@ -1520,7 +1500,7 @@ static int vlsi_open(struct net_device *ndev)
 	if (!idev->irlap)
 		goto errout_free_ring;
 
-	do_gettimeofday(&idev->last_rx);  /* first mtt may start from now on */
+	idev->last_rx = ktime_get();  /* first mtt may start from now on */
 
 	idev->new_baud = 9600;		/* start with IrPHY using 9600(SIR) mode */
 
diff --git a/drivers/net/irda/vlsi_ir.h b/drivers/net/irda/vlsi_ir.h
index f9119c6..f9db2ce 100644
--- a/drivers/net/irda/vlsi_ir.h
+++ b/drivers/net/irda/vlsi_ir.h
@@ -723,7 +723,7 @@ typedef struct vlsi_irda_dev {
 	void			*virtaddr;
 	struct vlsi_ring	*tx_ring, *rx_ring;
 
-	struct timeval		last_rx;
+	ktime_t			last_rx;
 
 	spinlock_t		lock;
 	struct mutex		mtx;
-- 
1.7.9.5

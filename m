From: Matt Mackall <mpm@selenic.com>
Subject: [patch] tg3 ring buffer allocation error handling
Date: Wed, 14 Apr 2004 13:46:42 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040414184642.GZ1175@waste.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


tg3 - handle ring buffer allocation failure

Try to allocate rx ring buffer and properly clean up and exit on
failure.


 tiny-mpm/drivers/net/tg3.c |   21 ++++++++++++++-------
 1 files changed, 14 insertions(+), 7 deletions(-)

diff -puN drivers/net/tg3.c~tg3-oops drivers/net/tg3.c
--- tiny/drivers/net/tg3.c~tg3-oops	2004-03-20 20:08:42.000000000 -0600
+++ tiny-mpm/drivers/net/tg3.c	2004-03-20 20:08:42.000000000 -0600
@@ -3092,7 +3092,7 @@ static void tg3_free_rings(struct tg3 *t
  * end up in the driver.  tp->{tx,}lock are held and thus
  * we may not sleep.
  */
-static void tg3_init_rings(struct tg3 *tp)
+static int tg3_init_rings(struct tg3 *tp)
 {
 	unsigned long start, end;
 	u32 i;
@@ -3151,18 +3151,23 @@ static void tg3_init_rings(struct tg3 *t
 
 	/* Now allocate fresh SKBs for each rx ring. */
 	for (i = 0; i < tp->rx_pending; i++) {
-		if (tg3_alloc_rx_skb(tp, RXD_OPAQUE_RING_STD,
-				     -1, i) < 0)
-			break;
+		if (tg3_alloc_rx_skb(tp, RXD_OPAQUE_RING_STD, -1, i) < 0) {
+			printk("tg3_alloc_rx_skb %d failed\n", i);
+			return -ENOMEM;
+		}
 	}
 
 	if (tp->tg3_flags & TG3_FLAG_JUMBO_ENABLE) {
 		for (i = 0; i < tp->rx_jumbo_pending; i++) {
 			if (tg3_alloc_rx_skb(tp, RXD_OPAQUE_RING_JUMBO,
-					     -1, i) < 0)
-				break;
+					     -1, i) < 0) {
+				printk("tg3_alloc_rx_skb %d failed\n", i);
+				return -ENOMEM;
+			}
 		}
 	}
+
+	return 0;
 }
 
 /*
@@ -4557,7 +4562,9 @@ static int tg3_reset_hw(struct tg3 *tp)
 	 * can only do this after the hardware has been
 	 * successfully reset.
 	 */
-	tg3_init_rings(tp);
+	err = tg3_init_rings(tp);
+	if (err)
+		return err;
 
 	/* This value is determined during the probe time DMA
 	 * engine test, tg3_test_dma.

_

-- 
Matt Mackall : http://www.selenic.com : Linux development and consulting

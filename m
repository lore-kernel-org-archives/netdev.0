From: Paul Gortmaker <p_gortmaker@yahoo.com>
Subject: [PATCH] Remove obsolete code in 8390 driver
Date: Mon, 26 Jul 2004 01:25:00 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <410495AC.5040108@yahoo.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040100050904050704010802"
Cc: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040100050904050704010802
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

The 8390 drivers had provision for using a single Tx buffer,
which was educational back in the day when it served as an
example driver, but it really hasn't been used and can go
away which will make future maintenance easier.  Patch
against vanilla 2.6.7.

Thanks,
Paul.


--------------040100050904050704010802
Content-Type: text/plain;
 name="2.6.7-8390-no-1Tx-diff0"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="2.6.7-8390-no-1Tx-diff0"

diff -ur linux/drivers/net/8390.c linux-8390/drivers/net/8390.c
--- linux/drivers/net/8390.c	Sun May  9 19:33:36 2004
+++ linux-8390/drivers/net/8390.c	Mon Jul 26 01:15:39 2004
@@ -41,6 +41,7 @@
 			  module by all drivers that require it.
   Alan Cox		: Spinlocking work, added 'BUG_83C690'
   Paul Gortmaker	: Separate out Tx timeout code from Tx path.
+  Paul Gortmaker	: Remove old unused single Tx buffer code.
 
   Sources:
   The National Semiconductor LAN Databook, and the 3Com 3c503 databook.
@@ -289,8 +290,6 @@
 
 	send_length = ETH_ZLEN < length ? length : ETH_ZLEN;
     
-#ifdef EI_PINGPONG
-
 	/*
 	 * We have two Tx slots available for use. Find the first free
 	 * slot, and then perform some sanity checks. With two Tx bufs,
@@ -309,7 +308,7 @@
 	}
 	else if (ei_local->tx2 == 0) 
 	{
-		output_page = ei_local->tx_start_page + TX_1X_PAGES;
+		output_page = ei_local->tx_start_page + TX_PAGES/2;
 		ei_local->tx2 = send_length;
 		if (ei_debug  &&  ei_local->tx1 > 0)
 			printk(KERN_DEBUG "%s: idle transmitter, tx1=%d, lasttx=%d, txing=%d.\n",
@@ -366,28 +365,6 @@
 	else
 		netif_start_queue(dev);
 
-#else	/* EI_PINGPONG */
-
-	/*
-	 * Only one Tx buffer in use. You need two Tx bufs to come close to
-	 * back-to-back transmits. Expect a 20 -> 25% performance hit on
-	 * reasonable hardware if you only use one Tx buffer.
-	 */
-
-	if (length == send_length)
-		ei_block_output(dev, length, skb->data, ei_local->tx_start_page);
-	else {
-		memset(scratch, 0, ETH_ZLEN);
-		memcpy(scratch, skb->data, skb->len);
-		ei_block_output(dev, ETH_ZLEN, scratch, ei_local->tx_start_page);
-	}
-	ei_local->txing = 1;
-	NS8390_trigger_send(dev, send_length, ei_local->tx_start_page);
-	dev->trans_start = jiffies;
-	netif_stop_queue(dev);
-
-#endif	/* EI_PINGPONG */
-
 	/* Turn 8390 interrupts back on. */
 	ei_local->irqlock = 0;
 	outb_p(ENISR_ALL, e8390_base + EN0_IMR);
@@ -590,8 +567,6 @@
     
 	outb_p(ENISR_TX, e8390_base + EN0_ISR); /* Ack intr. */
 
-#ifdef EI_PINGPONG
-
 	/*
 	 * There are two Tx buffers, see which one finished, and trigger
 	 * the send of another one if it exists.
@@ -633,13 +608,6 @@
 	}
 //	else printk(KERN_WARNING "%s: unexpected TX-done interrupt, lasttx=%d.\n",
 //			dev->name, ei_local->lasttx);
-
-#else	/* EI_PINGPONG */
-	/*
-	 *  Single Tx buffer: mark it free so another packet can be loaded.
-	 */
-	ei_local->txing = 0;
-#endif
 
 	/* Minimize Tx latency: update the statistics after we restart TXing. */
 	if (status & ENTSR_COL)
diff -ur linux/drivers/net/8390.h linux-8390/drivers/net/8390.h
--- linux/drivers/net/8390.h	Tue Jun 15 22:20:42 2004
+++ linux-8390/drivers/net/8390.h	Mon Jul 26 01:10:51 2004
@@ -12,17 +12,7 @@
 #include <linux/ioport.h>
 #include <linux/skbuff.h>
 
-#define TX_2X_PAGES 12
-#define TX_1X_PAGES 6
-
-/* Should always use two Tx slots to get back-to-back transmits. */
-#define EI_PINGPONG
-
-#ifdef EI_PINGPONG
-#define TX_PAGES TX_2X_PAGES
-#else
-#define TX_PAGES TX_1X_PAGES
-#endif
+#define TX_PAGES 12	/* Two Tx slots */
 
 #define ETHER_ADDR_LEN 6
 

--------------040100050904050704010802--

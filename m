From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [patch 2/2] 2.6.6-rc1-mm1 - code removal in the epic100 irq handler
Date: Mon, 19 Apr 2004 23:52:25 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040419235225.A20535@electric-eye.fr.zoreil.com>
References: <20040419235014.A20504@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Content-Disposition: inline
In-Reply-To: <20040419235014.A20504@electric-eye.fr.zoreil.com>; from romieu@fr.zoreil.com on Mon, Apr 19, 2004 at 11:50:14PM +0200
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


The loop in the irq handler is not needed any more as the high frequency
events have been deferred due to napi usage.

diff -puN drivers/net/epic100.c~epic100-napi-50 drivers/net/epic100.c
--- linux-2.6.6-rc1/drivers/net/epic100.c~epic100-napi-50	2004-04-20 00:37:16.000000000 +0200
+++ linux-2.6.6-rc1-fr/drivers/net/epic100.c	2004-04-20 00:37:16.000000000 +0200
@@ -77,8 +77,6 @@
    These may be modified when a driver module is loaded.*/
 
 static int debug = 1;			/* 1 normal messages, 0 quiet .. 7 verbose. */
-/* Maximum events (Rx packets, etc.) to handle at each interrupt. */
-static int max_interrupt_work = 32;
 
 /* Used to pass the full-duplex flag, etc. */
 #define MAX_UNITS 8		/* More are supported, limit only on options */
@@ -155,12 +153,10 @@ MODULE_DESCRIPTION("SMC 83c170 EPIC seri
 MODULE_LICENSE("GPL");
 
 MODULE_PARM(debug, "i");
-MODULE_PARM(max_interrupt_work, "i");
 MODULE_PARM(rx_copybreak, "i");
 MODULE_PARM(options, "1-" __MODULE_STRING(MAX_UNITS) "i");
 MODULE_PARM(full_duplex, "1-" __MODULE_STRING(MAX_UNITS) "i");
 MODULE_PARM_DESC(debug, "EPIC/100 debug level (0-5)");
-MODULE_PARM_DESC(max_interrupt_work, "EPIC/100 maximum events handled per interrupt");
 MODULE_PARM_DESC(options, "EPIC/100: Bits 0-3: media type, bit 4: full duplex");
 MODULE_PARM_DESC(rx_copybreak, "EPIC/100 copy breakpoint for copy-only-tiny-frames");
 MODULE_PARM_DESC(full_duplex, "EPIC/100 full duplex setting(s) (1)");
@@ -1162,74 +1158,66 @@ static irqreturn_t epic_interrupt(int ir
 	struct net_device *dev = dev_instance;
 	struct epic_private *ep = dev->priv;
 	long ioaddr = dev->base_addr;
-	int status, boguscnt = max_interrupt_work;
 	unsigned int handled = 0;
+	int status;
 
-	do {
-		status = inl(ioaddr + INTSTAT);
-		/* Acknowledge all of the current interrupt sources ASAP. */
-		outl(status & EpicNormalEvent, ioaddr + INTSTAT);
+	status = inl(ioaddr + INTSTAT);
+	/* Acknowledge all of the current interrupt sources ASAP. */
+	outl(status & EpicNormalEvent, ioaddr + INTSTAT);
 
-		if (debug > 4)
-			printk(KERN_DEBUG "%s: Interrupt, status=%#8.8x new "
-				   "intstat=%#8.8x.\n",
-				   dev->name, status, (int)inl(ioaddr + INTSTAT));
+	if (debug > 4) {
+		printk(KERN_DEBUG "%s: Interrupt, status=%#8.8x new "
+				   "intstat=%#8.8x.\n", dev->name, status,
+				   (int)inl(ioaddr + INTSTAT));
+	}
 
-		if ((status & IntrSummary) == 0)
-			break;
-		handled = 1;
+	if ((status & IntrSummary) == 0)
+		goto out;
 
-		if ((status & EpicNapiEvent) && !ep->reschedule_in_poll) {
-			spin_lock(&ep->napi_lock);
-			if (netif_rx_schedule_prep(dev)) {
-				epic_napi_irq_off(dev, ep);
-				__netif_rx_schedule(dev);
-			} else
-				ep->reschedule_in_poll++;
-			spin_unlock(&ep->napi_lock);
-		}
-		status &= ~EpicNapiEvent;
+	handled = 1;
 
-		/* Check uncommon events all at once. */
-		if (status &
-		    (CntFull | TxUnderrun | PCIBusErr170 | PCIBusErr175)) {
-			if (status == EpicRemoved)
-				break;
-			/* Always update the error counts to avoid overhead later. */
-			ep->stats.rx_missed_errors += inb(ioaddr + MPCNT);
-			ep->stats.rx_frame_errors += inb(ioaddr + ALICNT);
-			ep->stats.rx_crc_errors += inb(ioaddr + CRCCNT);
-
-			if (status & TxUnderrun) { /* Tx FIFO underflow. */
-				ep->stats.tx_fifo_errors++;
-				outl(ep->tx_threshold += 128, ioaddr + TxThresh);
-				/* Restart the transmit process. */
-				outl(RestartTx, ioaddr + COMMAND);
-			}
-			if (status & PCIBusErr170) {
-				printk(KERN_ERR "%s: PCI Bus Error!  EPIC status %4.4x.\n",
-					   dev->name, status);
-				epic_pause(dev);
-				epic_restart(dev);
-			}
-			/* Clear all error sources. */
-			outl(status & 0x7f18, ioaddr + INTSTAT);
+	if ((status & EpicNapiEvent) && !ep->reschedule_in_poll) {
+		spin_lock(&ep->napi_lock);
+		if (netif_rx_schedule_prep(dev)) {
+			epic_napi_irq_off(dev, ep);
+			__netif_rx_schedule(dev);
+		} else
+			ep->reschedule_in_poll++;
+		spin_unlock(&ep->napi_lock);
+	}
+	status &= ~EpicNapiEvent;
+
+	/* Check uncommon events all at once. */
+	if (status & (CntFull | TxUnderrun | PCIBusErr170 | PCIBusErr175)) {
+		if (status == EpicRemoved)
+			goto out;
+
+		/* Always update the error counts to avoid overhead later. */
+		ep->stats.rx_missed_errors += inb(ioaddr + MPCNT);
+		ep->stats.rx_frame_errors += inb(ioaddr + ALICNT);
+		ep->stats.rx_crc_errors += inb(ioaddr + CRCCNT);
+
+		if (status & TxUnderrun) { /* Tx FIFO underflow. */
+			ep->stats.tx_fifo_errors++;
+			outl(ep->tx_threshold += 128, ioaddr + TxThresh);
+			/* Restart the transmit process. */
+			outl(RestartTx, ioaddr + COMMAND);
 		}
-		if (!(status & EpicNormalEvent))
-			break;
-		if (--boguscnt < 0) {
-			printk(KERN_ERR "%s: Too much work at interrupt, "
-				   "IntrStatus=0x%8.8x.\n",
-				   dev->name, status);
-			/* Clear all interrupt sources. */
-			outl(0x0001ffff, ioaddr + INTSTAT);
-			break;
+		if (status & PCIBusErr170) {
+			printk(KERN_ERR "%s: PCI Bus Error! status %4.4x.\n",
+					 dev->name, status);
+			epic_pause(dev);
+			epic_restart(dev);
 		}
-	} while (1);
+		/* Clear all error sources. */
+		outl(status & 0x7f18, ioaddr + INTSTAT);
+	}
 
-	if (debug > 3)
-		printk(KERN_DEBUG "%s: exiting interrupt, intr_status=%#4.4x.\n",
-			   dev->name, status);
+out:
+	if (debug > 3) {
+		printk(KERN_DEBUG "%s: exit interrupt, intr_status=%#4.4x.\n",
+				   dev->name, status);
+	}
 
 	return IRQ_RETVAL(handled);
 }

_

From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH,RFC] Re: r8169 driver problem with RTL8110SB chip (on iop3xx ARM board)
Date: Fri, 18 Aug 2006 23:28:52 +0200
Message-ID: <20060818212852.GA5379@xi.wantstofly.org>
References: <20060728101109.GA25854@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, tbm@cyrius.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:46557 "EHLO
	xi.wantstofly.org") by vger.kernel.org with ESMTP id S1751493AbWHRV2z
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Aug 2006 17:28:55 -0400
To: romieu@fr.zoreil.com
Content-Disposition: inline
In-Reply-To: <20060728101109.GA25854@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 28, 2006 at 12:11:09PM +0200, Lennert Buytenhek wrote:

> We're currently working on getting the Thecus n2100 supported in 2.6.
> 
> 	http://www.thecus.com/products_over.php?cid=1&pid=1
> 
> Amongst other nice goodies, it has two on-board RTL8110SB gigabit
> controllers.  The realtek-supplied 'r1000' driver kind of sort of works,
> if you don't mind the machine hanging or crashing if you unplug the cable
> at the wrong moment.
> 
> The in-kernel 'r8169' drivers in 2.6.17 and 2.6.18-rc2 appear to work
> initially, but they don't actually seem to transmit any packets on the
> wire, nor do they receive any.

The hack patch below makes it work.  There's two issues here:

1. Writing zero to the upper part of the TxDescStartAddr register (via
   the MMIO region) somehow also clears the lower part, and writing the
   upper and lower halves the other way round fixes it.  The RxDescAddr
   register doesn't seem to suffer from this problem.

   The Realtek r1000 driver writes the two halves in the same order as
   r8169, but it doesn't happen there, which is a bit of a mystery to
   me.

2. SYSErr asserts pretty soon after upping eth0, and the PCI status
   register reports a parity error when this happens.  In this case,
   the restart logic seems to make things worse, and in fact, when
   commenting it out, things work a lot better.

Have you ever seen these issues before?  Any suggestions on how to
cleanly fix these issues?


cheers,
Lennert


Signed-off-by: Lennert Buytenhek <buytenh@wantstofly.org>

Index: linux-2.6.18-rc2/drivers/net/r8169.c
===================================================================
--- linux-2.6.18-rc2.orig/drivers/net/r8169.c
+++ linux-2.6.18-rc2/drivers/net/r8169.c
@@ -484,7 +488,7 @@ static int rtl8169_poll(struct net_devic
 #endif
 
 static const u16 rtl8169_intr_mask =
-	SYSErr | LinkChg | RxOverflow | RxFIFOOver | TxErr | TxOK | RxErr | RxOK;
+	LinkChg | RxOverflow | RxFIFOOver | TxErr | TxOK | RxErr | RxOK;
 static const u16 rtl8169_napi_event =
 	RxOK | RxOverflow | RxFIFOOver | TxOK | TxErr;
 static const unsigned int rtl8169_rx_config =
@@ -1825,8 +1829,8 @@ rtl8169_hw_start(struct net_device *dev)
 	 */
 	RTL_W16(IntrMitigate, 0x0000);
 
-	RTL_W32(TxDescStartAddrLow, ((u64) tp->TxPhyAddr & DMA_32BIT_MASK));
 	RTL_W32(TxDescStartAddrHigh, ((u64) tp->TxPhyAddr >> 32));
+	RTL_W32(TxDescStartAddrLow, ((u64) tp->TxPhyAddr & DMA_32BIT_MASK));
 	RTL_W32(RxDescAddrLow, ((u64) tp->RxPhyAddr & DMA_32BIT_MASK));
 	RTL_W32(RxDescAddrHigh, ((u64) tp->RxPhyAddr >> 32));
 	RTL_W8(Cfg9346, Cfg9346_Lock);
@@ -2527,10 +2531,12 @@ rtl8169_interrupt(int irq, void *dev_ins
 		if (!(status & rtl8169_intr_mask))
 			break;
 
+#if 0
 		if (unlikely(status & SYSErr)) {
 			rtl8169_pcierr_interrupt(dev);
 			break;
 		}
+#endif
 
 		if (status & LinkChg)
 			rtl8169_check_link_status(dev, tp, ioaddr);

From: Ralf Baechle <ralf@linux-mips.org>
Subject: [NET] MIPSsim: General cleanup
Date: Fri, 12 Oct 2007 14:59:56 +0100
Message-ID: <20071012135956.GA16163@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:47644 "EHLO
	ftp.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752317AbXJLOAE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2007 10:00:04 -0400
Received: from localhost.localdomain ([127.0.0.1]:9139 "EHLO
	dl5rb.ham-radio-op.net") by ftp.linux-mips.org with ESMTP
	id S20025322AbXJLOAA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Oct 2007 15:00:00 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

General cleanups mostly as suggested by checkpatch plus getting rid of
homebrew version of offsetof().

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>
---

 drivers/net/mipsnet.c |   63 ++++++++++++++++++-------------------
 drivers/net/mipsnet.h |   83 ++++++++++++++++++++++++++------------------------
 2 files changed, 75 insertions(+), 71 deletions(-)

diff --git a/drivers/net/mipsnet.c b/drivers/net/mipsnet.c
index d593175..37707a0 100644
--- a/drivers/net/mipsnet.c
+++ b/drivers/net/mipsnet.c
@@ -7,12 +7,12 @@
 #define DEBUG
 
 #include <linux/init.h>
+#include <linux/io.h>
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/platform_device.h>
-#include <asm/io.h>
 #include <asm/mips-boards/simint.h>
 
 #include "mipsnet.h"		/* actual device IO mapping */
@@ -33,9 +33,8 @@ static int ioiocpy_frommipsnet(struct net_device *dev, unsigned char *kdata,
 	if (available_len < len)
 		return -EFAULT;
 
-	for (; len > 0; len--, kdata++) {
+	for (; len > 0; len--, kdata++)
 		*kdata = inb(mipsnet_reg_address(dev, rxDataBuffer));
-	}
 
 	return inl(mipsnet_reg_address(dev, rxDataCount));
 }
@@ -47,16 +46,15 @@ static inline ssize_t mipsnet_put_todevice(struct net_device *dev,
 	char *buf_ptr = skb->data;
 
 	pr_debug("%s: %s(): telling MIPSNET txDataCount(%d)\n",
-	         dev->name, __FUNCTION__, skb->len);
+		 dev->name, __FUNCTION__, skb->len);
 
 	outl(skb->len, mipsnet_reg_address(dev, txDataCount));
 
 	pr_debug("%s: %s(): sending data to MIPSNET txDataBuffer(%d)\n",
-	         dev->name, __FUNCTION__, skb->len);
+		 dev->name, __FUNCTION__, skb->len);
 
-	for (; count_to_go; buf_ptr++, count_to_go--) {
+	for (; count_to_go; buf_ptr++, count_to_go--)
 		outb(*buf_ptr, mipsnet_reg_address(dev, txDataBuffer));
-	}
 
 	dev->stats.tx_packets++;
 	dev->stats.tx_bytes += skb->len;
@@ -67,7 +65,7 @@ static inline ssize_t mipsnet_put_todevice(struct net_device *dev,
 static int mipsnet_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	pr_debug("%s:%s(): transmitting %d bytes\n",
-	         dev->name, __FUNCTION__, skb->len);
+		 dev->name, __FUNCTION__, skb->len);
 
 	/* Only one packet at a time. Once TXDONE interrupt is serviced, the
 	 * queue will be restarted.
@@ -83,7 +81,8 @@ static inline ssize_t mipsnet_get_fromdev(struct net_device *dev, size_t count)
 	struct sk_buff *skb;
 	size_t len = count;
 
-	if (!(skb = alloc_skb(len + 2, GFP_KERNEL))) {
+	skb = alloc_skb(len + 2, GFP_KERNEL);
+	if (!skb) {
 		dev->stats.rx_dropped++;
 		return -ENOMEM;
 	}
@@ -96,7 +95,7 @@ static inline ssize_t mipsnet_get_fromdev(struct net_device *dev, size_t count)
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
 
 	pr_debug("%s:%s(): pushing RXed data to kernel\n",
-	         dev->name, __FUNCTION__);
+		 dev->name, __FUNCTION__);
 	netif_rx(skb);
 
 	dev->stats.rx_packets++;
@@ -114,42 +113,44 @@ static irqreturn_t mipsnet_interrupt(int irq, void *dev_id)
 
 	if (irq == dev->irq) {
 		pr_debug("%s:%s(): irq %d for device\n",
-		         dev->name, __FUNCTION__, irq);
+			 dev->name, __FUNCTION__, irq);
 
 		retval = IRQ_HANDLED;
 
 		interruptFlags =
 		    inl(mipsnet_reg_address(dev, interruptControl));
 		pr_debug("%s:%s(): intCtl=0x%016llx\n", dev->name,
-		         __FUNCTION__, interruptFlags);
+			 __FUNCTION__, interruptFlags);
 
 		if (interruptFlags & MIPSNET_INTCTL_TXDONE) {
 			pr_debug("%s:%s(): got TXDone\n",
-			         dev->name, __FUNCTION__);
+				 dev->name, __FUNCTION__);
 			outl(MIPSNET_INTCTL_TXDONE,
 			     mipsnet_reg_address(dev, interruptControl));
-			// only one packet at a time, we are done.
+			/* only one packet at a time, we are done. */
 			netif_wake_queue(dev);
 		} else if (interruptFlags & MIPSNET_INTCTL_RXDONE) {
 			pr_debug("%s:%s(): got RX data\n",
-			         dev->name, __FUNCTION__);
+				 dev->name, __FUNCTION__);
 			mipsnet_get_fromdev(dev,
-			            inl(mipsnet_reg_address(dev, rxDataCount)));
+				    inl(mipsnet_reg_address(dev, rxDataCount)));
 			pr_debug("%s:%s(): clearing RX int\n",
-			         dev->name, __FUNCTION__);
+				 dev->name, __FUNCTION__);
 			outl(MIPSNET_INTCTL_RXDONE,
 			     mipsnet_reg_address(dev, interruptControl));
 
 		} else if (interruptFlags & MIPSNET_INTCTL_TESTBIT) {
 			pr_debug("%s:%s(): got test interrupt\n",
-			         dev->name, __FUNCTION__);
-			// TESTBIT is cleared on read.
-			//    And takes effect after a write with 0
+				 dev->name, __FUNCTION__);
+			/*
+			 * TESTBIT is cleared on read.
+			 * And takes effect after a write with 0
+			 */
 			outl(0, mipsnet_reg_address(dev, interruptControl));
 		} else {
 			pr_debug("%s:%s(): no valid fags 0x%016llx\n",
-			         dev->name, __FUNCTION__, interruptFlags);
-			// Maybe shared IRQ, just ignore, no clearing.
+				 dev->name, __FUNCTION__, interruptFlags);
+			/* Maybe shared IRQ, just ignore, no clearing. */
 			retval = IRQ_NONE;
 		}
 
@@ -159,7 +160,7 @@ static irqreturn_t mipsnet_interrupt(int irq, void *dev_id)
 		retval = IRQ_NONE;
 	}
 	return retval;
-}				//mipsnet_interrupt()
+}
 
 static int mipsnet_open(struct net_device *dev)
 {
@@ -171,18 +172,18 @@ static int mipsnet_open(struct net_device *dev)
 
 	if (err) {
 		pr_debug("%s: %s(): can't get irq %d\n",
-		         dev->name, __FUNCTION__, dev->irq);
+			 dev->name, __FUNCTION__, dev->irq);
 		release_region(dev->base_addr, MIPSNET_IO_EXTENT);
 		return err;
 	}
 
 	pr_debug("%s: %s(): got IO region at 0x%04lx and irq %d for dev.\n",
-	         dev->name, __FUNCTION__, dev->base_addr, dev->irq);
+		 dev->name, __FUNCTION__, dev->base_addr, dev->irq);
 
 
 	netif_start_queue(dev);
 
-	// test interrupt handler
+	/* test interrupt handler */
 	outl(MIPSNET_INTCTL_TESTBIT,
 	     mipsnet_reg_address(dev, interruptControl));
 
@@ -199,8 +200,6 @@ static int mipsnet_close(struct net_device *dev)
 
 static void mipsnet_set_mclist(struct net_device *dev)
 {
-	// we don't do anything
-	return;
 }
 
 static int __init mipsnet_probe(struct device *dev)
@@ -226,13 +225,13 @@ static int __init mipsnet_probe(struct device *dev)
 	 */
 	netdev->base_addr = 0x4200;
 	netdev->irq = MIPS_CPU_IRQ_BASE + MIPSCPU_INT_MB0 +
-	              inl(mipsnet_reg_address(netdev, interruptInfo));
+		      inl(mipsnet_reg_address(netdev, interruptInfo));
 
-	// Get the io region now, get irq on open()
+	/* Get the io region now, get irq on open() */
 	if (!request_region(netdev->base_addr, MIPSNET_IO_EXTENT, "mipsnet")) {
 		pr_debug("%s: %s(): IO region {start: 0x%04lux, len: %d} "
-		         "for dev is not availble.\n", netdev->name,
-		         __FUNCTION__, netdev->base_addr, MIPSNET_IO_EXTENT);
+			 "for dev is not availble.\n", netdev->name,
+			 __FUNCTION__, netdev->base_addr, MIPSNET_IO_EXTENT);
 		err = -EBUSY;
 		goto out_free_netdev;
 	}
diff --git a/drivers/net/mipsnet.h b/drivers/net/mipsnet.h
index 026c732..0132c67 100644
--- a/drivers/net/mipsnet.h
+++ b/drivers/net/mipsnet.h
@@ -9,32 +9,34 @@
 /*
  *  Id of this Net device, as seen by the core.
  */
-#define MIPS_NET_DEV_ID ((uint64_t)           \
-	                     ((uint64_t)'M'<< 0)| \
-	                     ((uint64_t)'I'<< 8)| \
-	                     ((uint64_t)'P'<<16)| \
-	                     ((uint64_t)'S'<<24)| \
-	                     ((uint64_t)'N'<<32)| \
-	                     ((uint64_t)'E'<<40)| \
-	                     ((uint64_t)'T'<<48)| \
-	                     ((uint64_t)'0'<<56))
+#define MIPS_NET_DEV_ID ((uint64_t)	   \
+			     ((uint64_t) 'M' <<  0)| \
+			     ((uint64_t) 'I' <<  8)| \
+			     ((uint64_t) 'P' << 16)| \
+			     ((uint64_t) 'S' << 24)| \
+			     ((uint64_t) 'N' << 32)| \
+			     ((uint64_t) 'E' << 40)| \
+			     ((uint64_t) 'T' << 48)| \
+			     ((uint64_t) '0' << 56))
 
 /*
  * Net status/control block as seen by sw in the core.
  * (Why not use bit fields? can't be bothered with cross-platform struct
  *  packing.)
  */
-typedef struct _net_control_block {
-	/// dev info for probing
-	///  reads as MIPSNET%d where %d is some form of version
-	uint64_t devId;		/*0x00 */
+struct net_control_block {
+	/*
+	 * dev info for probing
+	 * reads as MIPSNET%d where %d is some form of version
+	 */
+	uint64_t devId;		/* 0x00 */
 
 	/*
 	 * read only busy flag.
 	 * Set and cleared by the Net Device to indicate that an rx or a tx
 	 * is in progress.
 	 */
-	uint32_t busy;		/*0x08 */
+	uint32_t busy;		/* 0x08 */
 
 	/*
 	 * Set by the Net Device.
@@ -43,16 +45,16 @@ typedef struct _net_control_block {
 	 * rxDataBuffer.  The value will decrease till 0 until all the data
 	 * from rxDataBuffer has been read.
 	 */
-	uint32_t rxDataCount;	/*0x0c */
+	uint32_t rxDataCount;	/* 0x0c */
 #define MIPSNET_MAX_RXTX_DATACOUNT (1<<16)
 
 	/*
-	 * Settable from the MIPS core, cleared by the Net Device.
-	 * The core should set the number of bytes it wants to send,
-	 *   then it should write those bytes of data to txDataBuffer.
-	 * The device will clear txDataCount has been processed (not necessarily sent).
+	 * Settable from the MIPS core, cleared by the Net Device.  The core
+	 * should set the number of bytes it wants to send, then it should
+	 * write those bytes of data to txDataBuffer.  The device will clear
+	 * txDataCount has been processed (not necessarily sent).
 	 */
-	uint32_t txDataCount;	/*0x10 */
+	uint32_t txDataCount;	/* 0x10 */
 
 	/*
 	 * Interrupt control
@@ -69,39 +71,42 @@ typedef struct _net_control_block {
 	 *    To clear the test interrupt, write 0 to this register.
 	 */
 	uint32_t interruptControl;	/*0x14 */
-#define MIPSNET_INTCTL_TXDONE     ((uint32_t)(1<< 0))
-#define MIPSNET_INTCTL_RXDONE     ((uint32_t)(1<< 1))
-#define MIPSNET_INTCTL_TESTBIT    ((uint32_t)(1<<31))
-#define MIPSNET_INTCTL_ALLSOURCES (MIPSNET_INTCTL_TXDONE|MIPSNET_INTCTL_RXDONE|MIPSNET_INTCTL_TESTBIT)
+#define MIPSNET_INTCTL_TXDONE     ((uint32_t)(1 <<  0))
+#define MIPSNET_INTCTL_RXDONE     ((uint32_t)(1 <<  1))
+#define MIPSNET_INTCTL_TESTBIT    ((uint32_t)(1 << 31))
+#define MIPSNET_INTCTL_ALLSOURCES	(MIPSNET_INTCTL_TXDONE | \
+					 MIPSNET_INTCTL_RXDONE | \
+					 MIPSNET_INTCTL_TESTBIT)
 
 	/*
-	 * Readonly core-specific interrupt info for the device to signal the core.
-	 * The meaning of the contents of this field might change.
-	 */
-	/*###\todo: the whole memIntf interrupt scheme is messy: the device should have
-	 *  no control what so ever of what VPE/register set is being used.
-	 *  The MemIntf should only expose interrupt lines, and something in the
-	 *  config should be responsible for the line<->core/vpe bindings.
+	 * Readonly core-specific interrupt info for the device to signal the
+	 * core.  The meaning of the contents of this field might change.
+	 *
+	 * TODO: the whole memIntf interrupt scheme is messy: the device should
+	 *       have no control what so ever of what VPE/register set is being
+	 *       used.  The MemIntf should only expose interrupt lines, and
+	 *       something in the config should be responsible for the
+	 *       line<->core/vpe bindings.
 	 */
-	uint32_t interruptInfo;	/*0x18 */
+	uint32_t interruptInfo;	/* 0x18 */
 
 	/*
 	 *  This is where the received data is read out.
 	 *  There is more data to read until rxDataReady is 0.
 	 *  Only 1 byte at this regs offset is used.
 	 */
-	uint32_t rxDataBuffer;	/*0x1c */
+	uint32_t rxDataBuffer;	/* 0x1c */
 
 	/*
-	 * This is where the data to transmit is written.
-	 * Data should be written for the amount specified in the txDataCount register.
-	 *  Only 1 byte at this regs offset is used.
+	 * This is where the data to transmit is written.  Data should be
+	 * written for the amount specified in the txDataCount register.  Only
+	 * 1 byte at this regs offset is used.
 	 */
-	uint32_t txDataBuffer;	/*0x20 */
-} MIPS_T_NetControl;
+	uint32_t txDataBuffer;	/* 0x20 */
+};
 
 #define MIPSNET_IO_EXTENT 0x40	/* being generous */
 
-#define field_offset(field) ((int)&((MIPS_T_NetControl*)(0))->field)
+#define field_offset(field) (offsetof(struct net_control_block, field))
 
 #endif /* __MIPSNET_H */

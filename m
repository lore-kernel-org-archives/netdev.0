From: "Figo.zhang" <figo1802@gmail.com>
Subject: [PATCH against V2]NET/KS8695: add support NAPI for Rx
Date: Thu, 29 Oct 2009 22:04:48 +0800
Message-ID: <1256825088.2148.77.camel@myhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Ben Dooks <ben@simtec.co.uk>
To: Daniel Silverstone <dsilvers@simtec.co.uk>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f179.google.com ([209.85.216.179]:53830 "EHLO
	mail-px0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753498AbZJ2OFJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 10:05:09 -0400
Received: by pxi9 with SMTP id 9so1190940pxi.4
        for <netdev@vger.kernel.org>; Thu, 29 Oct 2009 07:05:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Add support NAPI Rx API for KS8695NET driver.

v2, change the Rx function to NAPI.

in <KS8695X Integrated Multi-port Gateway Solution Register Description
 v1.0>:
Interrupt Enable Register (offset 0xE204)
Bit29 : WAN MAC Receive Interrupt Enable
Bit16 : LAN MAC Receive Interrupt Enable

Interrupt Status Register (Offset 0xF208)
Bit29: WAN MAC Receive Status
Bit16: LAN MAC Receive Status

see arch/arm/mach-ks8695/devices.c:
ks8695_wan_resources[] and ks8695_lan_resources[]
have IORESOURCE_IRQ , it have define the RX irq,
for wan, irq = 29; for lan ,irq = 16.
so we can do this read the interrupt status:

unsigned long mask_bit = 1 << ksp->rx_irq;
status = readl(KS8695_IRQ_VA + KS8695_INTST);

In this version is against v2, some changes that adviced by Daniel
Silverstone and Ben Dooks.

Add k8695_get_rx_enable_bit() for get Rx interrupt enable/status
bit.

Signed-off-by: Figo.zhang <figo1802@gmail.com>
--- 
drivers/net/arm/ks8695net.c |   69 ++++++++++++++++++++++++++++++++++--------
 1 files changed, 56 insertions(+), 13 deletions(-)

diff --git a/drivers/net/arm/ks8695net.c b/drivers/net/arm/ks8695net.c
index ed0b0f3..b4f5994 100644
--- a/drivers/net/arm/ks8695net.c
+++ b/drivers/net/arm/ks8695net.c
@@ -41,8 +41,7 @@
 #include "ks8695net.h"
 
 #define MODULENAME	"ks8695_ether"
-#define MODULEVERSION	"1.01"
-
+#define MODULEVERSION	"1.02"
 
 /*
  * Transmit and device reset timeout, default 5 seconds.
@@ -98,6 +97,9 @@ struct ks8695_skbuff {
 #define MAX_RX_DESC 16
 #define MAX_RX_DESC_MASK 0xf
 
+/*napi_weight have better more than rx DMA buffers*/
+#define NAPI_WEIGHT   64
+
 #define MAX_RXBUF_SIZE 0x700
 
 #define TX_RING_DMA_SIZE (sizeof(struct tx_ring_desc) * MAX_TX_DESC)
@@ -123,6 +125,7 @@ enum ks8695_dtype {
  *	@dev: The platform device object for this interface
  *	@dtype: The type of this device
  *	@io_regs: The ioremapped registers for this interface
+ *      @napi : Add support NAPI for Rx
  *	@rx_irq_name: The textual name of the RX IRQ from the platform data
  *	@tx_irq_name: The textual name of the TX IRQ from the platform data
  *	@link_irq_name: The textual name of the link IRQ from the
@@ -146,6 +149,7 @@ enum ks8695_dtype {
  *	@rx_ring_dma: The DMA mapped equivalent of rx_ring
  *	@rx_buffers: The sk_buff mappings for the RX ring
  *	@next_rx_desc_read: The next RX descriptor to read from on IRQ
+ *      @rx_lock: A lock to protect Rx irq function
  *	@msg_enable: The flags for which messages to emit
  */
 struct ks8695_priv {
@@ -398,11 +402,30 @@ ks8695_tx_irq(int irq, void *dev_id)
 }
 
 /**
+ *	ks8695_get_rx_enable_bit - Get rx interrupt enable/status bit
+ *	@ksp: Private data for the KS8695 Ethernet
+ *
+ *    For KS8695 document:
+ *    Interrupt Enable Register (offset 0xE204)
+ *        Bit29 : WAN MAC Receive Interrupt Enable
+ *        Bit16 : LAN MAC Receive Interrupt Enable
+ *    Interrupt Status Register (Offset 0xF208)
+ *        Bit29: WAN MAC Receive Status
+ *        Bit16: LAN MAC Receive Status
+ *    So, this Rx interrrupt enable/status bit number is equal
+ *    as Rx IRQ number.
+ */
+static inline u32 ks8695_get_rx_enable_bit(struct ks8695_priv *ksp)
+{
+	return ksp->rx_irq;
+}
+
+/**
  *	ks8695_rx_irq - Receive IRQ handler
  *	@irq: The IRQ which went off (ignored)
  *	@dev_id: The net_device for the interrupt
  *
- *	Use NAPI to receive packets.
+ *	Inform NAPI that packet reception needs to be scheduled
  */
 
 static irqreturn_t
@@ -412,7 +435,7 @@ ks8695_rx_irq(int irq, void *dev_id)
 	struct ks8695_priv *ksp = netdev_priv(ndev);
 	unsigned long status;
 
-	unsigned long mask_bit = 1 << ksp->rx_irq;
+	unsigned long mask_bit = 1 << ks8695_get_rx_enable_bit(ksp);
 
 	spin_lock(&ksp->rx_lock);
 
@@ -434,9 +457,15 @@ ks8695_rx_irq(int irq, void *dev_id)
 	return IRQ_HANDLED;
 }
 
-static int ks8695_rx(struct net_device *ndev, int budget)
+/**
+ *	ks8695_rx - Receive packets  called by NAPI poll method
+ *	@ksp: Private data for the KS8695 Ethernet
+ *	@budget: The max packets would be receive
+ */
+
+static int ks8695_rx(struct ks8695_priv *ksp, int budget)
 {
-	struct ks8695_priv *ksp = netdev_priv(ndev);
+	struct net_device *ndev = ksp->ndev;
 	struct sk_buff *skb;
 	int buff_n;
 	u32 flags;
@@ -526,20 +555,32 @@ rx_finished:
 
 			/* And refill the buffers */
 			ks8695_refill_rxbuffers(ksp);
+
+			/* Kick the RX DMA engine, in case it became
+			 *  suspended */
+			ks8695_writereg(ksp, KS8695_DRSC, 0);
 	}
 	return received;
 }
 
+
+/**
+ *	ks8695_poll - Receive packet by NAPI poll method
+ *	@ksp: Private data for the KS8695 Ethernet
+ *	@budget: The remaining number packets for network subsystem
+ *
+ *     Invoked by the network core when it requests for new
+ *     packets from the driver
+ */
 static int ks8695_poll(struct napi_struct *napi, int budget)
 {
 	struct ks8695_priv *ksp = container_of(napi, struct ks8695_priv, napi);
-	struct net_device *dev = ksp->ndev;
-	unsigned long mask_bit = 1 << ksp->rx_irq;
-	unsigned long isr = readl(KS8695_IRQ_VA + KS8695_INTEN);
+	unsigned long  work_done;
 
-	unsigned long  work_done ;
+	unsigned long isr = readl(KS8695_IRQ_VA + KS8695_INTEN);
+	unsigned long mask_bit = 1 << ks8695_get_rx_enable_bit(ksp);
 
-	work_done = ks8695_rx(dev, budget);
+	work_done = ks8695_rx(ksp, budget);
 
 	if (work_done < budget) {
 		unsigned long flags;
@@ -1302,6 +1343,7 @@ ks8695_stop(struct net_device *ndev)
 	struct ks8695_priv *ksp = netdev_priv(ndev);
 
 	netif_stop_queue(ndev);
+	napi_disable(&ksp->napi);
 	netif_carrier_off(ndev);
 
 	ks8695_shutdown(ksp);
@@ -1335,7 +1377,8 @@ ks8695_open(struct net_device *ndev)
 		ks8695_shutdown(ksp);
 		return ret;
 	}
-
+	
+	napi_enable(&ksp->napi);
 	netif_start_queue(ndev);
 
 	return 0;
@@ -1521,7 +1564,7 @@ ks8695_probe(struct platform_device *pdev)
 	SET_ETHTOOL_OPS(ndev, &ks8695_ethtool_ops);
 	ndev->watchdog_timeo	 = msecs_to_jiffies(watchdog);
 
-	netif_napi_add(ndev, &ksp->napi, ks8695_poll, 64);
+	netif_napi_add(ndev, &ksp->napi, ks8695_poll, NAPI_WEIGHT);
 
 	/* Retrieve the default MAC addr from the chip. */
 	/* The bootloader should have left it in there for us. */



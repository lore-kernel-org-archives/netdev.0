From: "Figo.zhang" <figo1802@gmail.com>
Subject: [PATCH V2]NET/KS8695: add support NAPI for Rx
Date: Tue, 27 Oct 2009 22:23:42 +0800
Message-ID: <1256653422.2148.23.camel@myhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Ben Dooks <ben@simtec.co.uk>
To: Daniel Silverstone <dsilvers@simtec.co.uk>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gv-out-0910.google.com ([216.239.58.189]:61976 "EHLO
	gv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752537AbZJ0OYH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2009 10:24:07 -0400
Received: by gv-out-0910.google.com with SMTP id r4so41091gve.37
        for <netdev@vger.kernel.org>; Tue, 27 Oct 2009 07:24:11 -0700 (PDT)
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

Signed-off-by: Figo.zhang <figo1802@gmail.com>
--- 
drivers/net/arm/ks8695net.c |  103 ++++++++++++++++++++++++++++++++----------
 1 files changed, 78 insertions(+), 25 deletions(-)

diff --git a/drivers/net/arm/ks8695net.c b/drivers/net/arm/ks8695net.c
index 2a7b774..ed0b0f3 100644
--- a/drivers/net/arm/ks8695net.c
+++ b/drivers/net/arm/ks8695net.c
@@ -35,12 +35,15 @@
 
 #include <mach/regs-switch.h>
 #include <mach/regs-misc.h>
+#include <asm/mach/irq.h>
+#include <mach/regs-irq.h>
 
 #include "ks8695net.h"
 
 #define MODULENAME	"ks8695_ether"
 #define MODULEVERSION	"1.01"
 
+
 /*
  * Transmit and device reset timeout, default 5 seconds.
  */
@@ -152,6 +155,8 @@ struct ks8695_priv {
 	enum ks8695_dtype dtype;
 	void __iomem *io_regs;
 
+	struct napi_struct	napi;
+
 	const char *rx_irq_name, *tx_irq_name, *link_irq_name;
 	int rx_irq, tx_irq, link_irq;
 
@@ -172,6 +177,7 @@ struct ks8695_priv {
 	dma_addr_t rx_ring_dma;
 	struct ks8695_skbuff rx_buffers[MAX_RX_DESC];
 	int next_rx_desc_read;
+	spinlock_t rx_lock;
 
 	int msg_enable;
 };
@@ -396,25 +402,53 @@ ks8695_tx_irq(int irq, void *dev_id)
  *	@irq: The IRQ which went off (ignored)
  *	@dev_id: The net_device for the interrupt
  *
- *	Process the RX ring, passing any received packets up to the
- *	host.  If we received anything other than errors, we then
- *	refill the ring.
+ *	Use NAPI to receive packets.
  */
+
 static irqreturn_t
 ks8695_rx_irq(int irq, void *dev_id)
 {
 	struct net_device *ndev = (struct net_device *)dev_id;
 	struct ks8695_priv *ksp = netdev_priv(ndev);
+	unsigned long status;
+
+	unsigned long mask_bit = 1 << ksp->rx_irq;
+
+	spin_lock(&ksp->rx_lock);
+
+	status = readl(KS8695_IRQ_VA + KS8695_INTST);
+
+	/*clean rx status bit*/
+	writel(status | mask_bit , KS8695_IRQ_VA + KS8695_INTST);
+
+	if (status & mask_bit) {
+		if (napi_schedule_prep(&ksp->napi)) {
+			/*disable rx interrupt*/
+			status &= ~mask_bit;
+			writel(status , KS8695_IRQ_VA + KS8695_INTEN);
+			__napi_schedule(&ksp->napi);
+		}
+	}
+
+	spin_unlock(&ksp->rx_lock);
+	return IRQ_HANDLED;
+}
+
+static int ks8695_rx(struct net_device *ndev, int budget)
+{
+	struct ks8695_priv *ksp = netdev_priv(ndev);
 	struct sk_buff *skb;
 	int buff_n;
 	u32 flags;
 	int pktlen;
 	int last_rx_processed = -1;
+	int received = 0;
 
 	buff_n = ksp->next_rx_desc_read;
-	do {
-		if (ksp->rx_buffers[buff_n].skb &&
-		    !(ksp->rx_ring[buff_n].status & cpu_to_le32(RDES_OWN))) {
+	while (received < budget
+			&& ksp->rx_buffers[buff_n].skb
+			&& (!(ksp->rx_ring[buff_n].status &
+					cpu_to_le32(RDES_OWN)))) {
 			rmb();
 			flags = le32_to_cpu(ksp->rx_ring[buff_n].status);
 			/* Found an SKB which we own, this means we
@@ -464,7 +498,7 @@ ks8695_rx_irq(int irq, void *dev_id)
 			/* Relinquish the SKB to the network layer */
 			skb_put(skb, pktlen);
 			skb->protocol = eth_type_trans(skb, ndev);
-			netif_rx(skb);
+			netif_receive_skb(skb);
 
 			/* Record stats */
 			ndev->stats.rx_packets++;
@@ -478,29 +512,44 @@ rx_failure:
 			/* Give the ring entry back to the hardware */
 			ksp->rx_ring[buff_n].status = cpu_to_le32(RDES_OWN);
 rx_finished:
+			received++;
 			/* And note this as processed so we can start
 			 * from here next time
 			 */
 			last_rx_processed = buff_n;
-		} else {
-			/* Ran out of things to process, stop now */
-			break;
-		}
-		buff_n = (buff_n + 1) & MAX_RX_DESC_MASK;
-	} while (buff_n != ksp->next_rx_desc_read);
-
-	/* And note which RX descriptor we last did anything with */
-	if (likely(last_rx_processed != -1))
-		ksp->next_rx_desc_read =
-			(last_rx_processed + 1) & MAX_RX_DESC_MASK;
-
-	/* And refill the buffers */
-	ks8695_refill_rxbuffers(ksp);
-
-	/* Kick the RX DMA engine, in case it became suspended */
-	ks8695_writereg(ksp, KS8695_DRSC, 0);
+			buff_n = (buff_n + 1) & MAX_RX_DESC_MASK;
+			/*And note which RX descriptor we last did */
+			if (likely(last_rx_processed != -1))
+				ksp->next_rx_desc_read =
+					(last_rx_processed + 1) &
+					MAX_RX_DESC_MASK;
+
+			/* And refill the buffers */
+			ks8695_refill_rxbuffers(ksp);
+	}
+	return received;
+}
 
-	return IRQ_HANDLED;
+static int ks8695_poll(struct napi_struct *napi, int budget)
+{
+	struct ks8695_priv *ksp = container_of(napi, struct ks8695_priv, napi);
+	struct net_device *dev = ksp->ndev;
+	unsigned long mask_bit = 1 << ksp->rx_irq;
+	unsigned long isr = readl(KS8695_IRQ_VA + KS8695_INTEN);
+
+	unsigned long  work_done ;
+
+	work_done = ks8695_rx(dev, budget);
+
+	if (work_done < budget) {
+		unsigned long flags;
+		spin_lock_irqsave(&ksp->rx_lock, flags);
+		/*enable rx interrupt*/
+		writel(isr | mask_bit, KS8695_IRQ_VA + KS8695_INTEN);
+		__napi_complete(napi);
+		spin_unlock_irqrestore(&ksp->rx_lock, flags);
+	}
+	return work_done;
 }
 
 /**
@@ -1472,6 +1521,8 @@ ks8695_probe(struct platform_device *pdev)
 	SET_ETHTOOL_OPS(ndev, &ks8695_ethtool_ops);
 	ndev->watchdog_timeo	 = msecs_to_jiffies(watchdog);
 
+	netif_napi_add(ndev, &ksp->napi, ks8695_poll, 64);
+
 	/* Retrieve the default MAC addr from the chip. */
 	/* The bootloader should have left it in there for us. */
 
@@ -1505,6 +1556,7 @@ ks8695_probe(struct platform_device *pdev)
 
 	/* And initialise the queue's lock */
 	spin_lock_init(&ksp->txq_lock);
+	spin_lock_init(&ksp->rx_lock);
 
 	/* Specify the RX DMA ring buffer */
 	ksp->rx_ring = ksp->ring_base + TX_RING_DMA_SIZE;
@@ -1626,6 +1678,7 @@ ks8695_drv_remove(struct platform_device *pdev)
 	struct ks8695_priv *ksp = netdev_priv(ndev);
 
 	platform_set_drvdata(pdev, NULL);
+	netif_napi_del(&ksp->napi);
 
 	unregister_netdev(ndev);
 	ks8695_release_device(ksp);



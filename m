From: "Figo.zhang" <figo1802@gmail.com>
Subject: [PATCH]NET/KS8695: add support NAPI for Rx
Date: Tue, 27 Oct 2009 00:00:28 +0800
Message-ID: <1256572828.2148.5.camel@myhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Vincent Sanders <vince@simtec.co.uk>,
	Ben Dooks <ben@simtec.co.uk>
To: Daniel Silverstone <dsilvers@simtec.co.uk>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.221.174]:43025 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753018AbZJZQAv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2009 12:00:51 -0400
Received: by qyk4 with SMTP id 4so7740553qyk.33
        for <netdev@vger.kernel.org>; Mon, 26 Oct 2009 09:00:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Add support NAPI Rx API for KS8695NET driver.

Signed-off-by: Figo.zhang <figo1802@gmail.com>
--- 
drivers/net/arm/ks8695net.c |  165 +++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 165 insertions(+), 0 deletions(-)

diff --git a/drivers/net/arm/ks8695net.c b/drivers/net/arm/ks8695net.c
index 2a7b774..7f9d4bd 100644
--- a/drivers/net/arm/ks8695net.c
+++ b/drivers/net/arm/ks8695net.c
@@ -35,12 +35,16 @@
 
 #include <mach/regs-switch.h>
 #include <mach/regs-misc.h>
+#include <asm/mach/irq.h>
+#include <mach/regs-irq.h>
 
 #include "ks8695net.h"
 
 #define MODULENAME	"ks8695_ether"
 #define MODULEVERSION	"1.01"
 
+#define KS8695NET_NAPI  1
+
 /*
  * Transmit and device reset timeout, default 5 seconds.
  */
@@ -152,6 +156,10 @@ struct ks8695_priv {
 	enum ks8695_dtype dtype;
 	void __iomem *io_regs;
 
+	#ifdef KS8695NET_NAPI
+	struct napi_struct	napi;
+	#endif
+
 	const char *rx_irq_name, *tx_irq_name, *link_irq_name;
 	int rx_irq, tx_irq, link_irq;
 
@@ -172,6 +180,7 @@ struct ks8695_priv {
 	dma_addr_t rx_ring_dma;
 	struct ks8695_skbuff rx_buffers[MAX_RX_DESC];
 	int next_rx_desc_read;
+	spinlock_t rx_lock;
 
 	int msg_enable;
 };
@@ -391,6 +400,155 @@ ks8695_tx_irq(int irq, void *dev_id)
 	return IRQ_HANDLED;
 }
 
+#ifdef KS8695NET_NAPI
+static irqreturn_t
+ks8695_rx_irq(int irq, void *dev_id)
+{
+	struct net_device *ndev = (struct net_device *)dev_id;
+	struct ks8695_priv *ksp = netdev_priv(ndev);
+	unsigned long status;
+
+	unsigned long mask_bit = 1 << ksp->rx_irq;
+
+	spin_lock(&ksp->rx_lock);
+
+	status = __raw_readl(KS8695_IRQ_VA + KS8695_INTST);
+
+	/*clean rx status bit*/
+	__raw_writel(status | mask_bit , KS8695_IRQ_VA + KS8695_INTST);
+
+	if (status & mask_bit) {
+		if (napi_schedule_prep(&ksp->napi)) {
+			/*disable rx interrupt*/
+			status &= ~mask_bit;
+			__raw_writel(status , KS8695_IRQ_VA + KS8695_INTEN);
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
+	struct sk_buff *skb;
+	int buff_n;
+	u32 flags;
+	int pktlen;
+	int last_rx_processed = -1;
+	int received = 0;
+
+	buff_n = ksp->next_rx_desc_read;
+	while (netif_running(ndev) && received < budget
+			&& ksp->rx_buffers[buff_n].skb
+			&& (!(ksp->rx_ring[buff_n].status &
+					cpu_to_le32(RDES_OWN)))) {
+			rmb();
+			flags = le32_to_cpu(ksp->rx_ring[buff_n].status);
+			/* Found an SKB which we own, this means we
+			 * received a packet
+			 */
+			if ((flags & (RDES_FS | RDES_LS)) !=
+			    (RDES_FS | RDES_LS)) {
+				/* This packet is not the first and
+				 * the last segment.  Therefore it is
+				 * a "spanning" packet and we can't
+				 * handle it
+				 */
+				goto rx_failure;
+			}
+
+			if (flags & (RDES_ES | RDES_RE)) {
+				/* It's an error packet */
+				ndev->stats.rx_errors++;
+				if (flags & RDES_TL)
+					ndev->stats.rx_length_errors++;
+				if (flags & RDES_RF)
+					ndev->stats.rx_length_errors++;
+				if (flags & RDES_CE)
+					ndev->stats.rx_crc_errors++;
+				if (flags & RDES_RE)
+					ndev->stats.rx_missed_errors++;
+
+				goto rx_failure;
+			}
+
+			pktlen = flags & RDES_FLEN;
+			pktlen -= 4; /* Drop the CRC */
+
+			/* Retrieve the sk_buff */
+			skb = ksp->rx_buffers[buff_n].skb;
+
+			/* Clear it from the ring */
+			ksp->rx_buffers[buff_n].skb = NULL;
+			ksp->rx_ring[buff_n].data_ptr = 0;
+
+			/* Unmap the SKB */
+			dma_unmap_single(ksp->dev,
+					 ksp->rx_buffers[buff_n].dma_ptr,
+					 ksp->rx_buffers[buff_n].length,
+					 DMA_FROM_DEVICE);
+
+			/* Relinquish the SKB to the network layer */
+			skb_put(skb, pktlen);
+			skb->protocol = eth_type_trans(skb, ndev);
+			netif_receive_skb(skb);
+
+			/* Record stats */
+			ndev->stats.rx_packets++;
+			ndev->stats.rx_bytes += pktlen;
+			goto rx_finished;
+
+rx_failure:
+			/* This ring entry is an error, but we can
+			 * re-use the skb
+			 */
+			/* Give the ring entry back to the hardware */
+			ksp->rx_ring[buff_n].status = cpu_to_le32(RDES_OWN);
+rx_finished:
+			received++;
+			/* And note this as processed so we can start
+			 * from here next time
+			 */
+			last_rx_processed = buff_n;
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
+
+static int ks8695_poll(struct napi_struct *napi, int budget)
+{
+	struct ks8695_priv *ksp = container_of(napi, struct ks8695_priv, napi);
+	struct net_device *dev = ksp->ndev;
+	unsigned long mask_bit = 1 << ksp->rx_irq;
+	unsigned long isr = __raw_readl(KS8695_IRQ_VA + KS8695_INTEN);
+
+	unsigned long  work_done = 0;
+
+	work_done = ks8695_rx(dev, budget);
+
+	if (work_done < budget) {
+		unsigned long flags;
+		spin_lock_irqsave(&ksp->rx_lock, flags);
+		/*enable rx interrupt*/
+		__raw_writel(isr | mask_bit, KS8695_IRQ_VA + KS8695_INTEN);
+		__napi_complete(napi);
+		spin_unlock_irqrestore(&ksp->rx_lock, flags);
+	}
+	return work_done;
+}
+
+#else
 /**
  *	ks8695_rx_irq - Receive IRQ handler
  *	@irq: The IRQ which went off (ignored)
@@ -503,6 +661,8 @@ rx_finished:
 	return IRQ_HANDLED;
 }
 
+#endif
+
 /**
  *	ks8695_link_irq - Link change IRQ handler
  *	@irq: The IRQ which went off (ignored)
@@ -1472,6 +1632,10 @@ ks8695_probe(struct platform_device *pdev)
 	SET_ETHTOOL_OPS(ndev, &ks8695_ethtool_ops);
 	ndev->watchdog_timeo	 = msecs_to_jiffies(watchdog);
 
+#ifdef KS8695NET_NAPI
+	netif_napi_add(ndev, &ksp->napi, ks8695_poll, 64);
+#endif
+
 	/* Retrieve the default MAC addr from the chip. */
 	/* The bootloader should have left it in there for us. */
 
@@ -1505,6 +1669,7 @@ ks8695_probe(struct platform_device *pdev)
 
 	/* And initialise the queue's lock */
 	spin_lock_init(&ksp->txq_lock);
+	spin_lock_init(&ksp->rx_lock);
 
 	/* Specify the RX DMA ring buffer */
 	ksp->rx_ring = ksp->ring_base + TX_RING_DMA_SIZE;



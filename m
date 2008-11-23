From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [RFC PATCH 1/2] smsc911x: add support for sh3 RX DMA
Date: Sun, 23 Nov 2008 16:04:33 +0000
Message-ID: <1227456274-10388-1-git-send-email-steve.glendinning@smsc.com>
Cc: linux-sh@vger.kernel.org, Ian Saturley <ian.saturley@smsc.com>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I've been working on adding DMA support to the smsc911x driver.  As this 
family of devices is non-pci, DMA transfers must be initiated and 
controlled by the host CPU.  Unfortunately this makes some of the code 
necessarily platform-specific.

This patch adds RX DMA support for the sh architecture.  Tested on 
SH7709S (sh3), where it gives a small (~10%) iperf tcp throughput 
increase.  DMA or PIO is selected at compile-time.

My first attempt stopped NAPI polling during a DMA transfer, then used 
DMA completion interrupts to pass the packet up and re-enable polling.
Obviously this defeats the interrupt-mitigation of NAPI, and on my test 
platform actually *reduced* performance!

This patch leaves NAPI polling enabled, so a later poll completes the 
transfer.  I'm concerned this is essentially busy-waiting on the 
transfer, but it does show a small performance gain.  Is this a good or 
bad idea?

I'd be interested to hear if anyone has advice on how to make this 
patch more generic.  There's definitely been interest from arm pxa
users in adding DMA, and some of this code must be re-usable for this.

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 drivers/net/smsc911x.c   |  131 ++++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/smsc911x.h   |    4 ++
 include/linux/smsc911x.h |    3 +
 3 files changed, 138 insertions(+), 0 deletions(-)

diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
index 4b8ff84..b3d9f9e 100644
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -52,6 +52,11 @@
 #include <linux/smsc911x.h>
 #include "smsc911x.h"
 
+#ifdef SMSC_USE_SH_RX_DMA
+#include <asm/dma.h>
+#include <../arch/sh/drivers/dma/dma-sh.h>
+#endif
+
 #define SMSC_CHIPNAME		"smsc911x"
 #define SMSC_MDIONAME		"smsc911x-mdio"
 #define SMSC_DRV_VERSION	"2008-10-21"
@@ -116,6 +121,10 @@ struct smsc911x_data {
 	unsigned int clear_bits_mask;
 	unsigned int hashhi;
 	unsigned int hashlo;
+
+#ifdef SMSC_USE_SH_RX_DMA
+	struct sk_buff *rx_skb;
+#endif
 };
 
 /* The 16-bit access functions are significantly slower, due to the locking
@@ -962,12 +971,37 @@ smsc911x_rx_counterrors(struct net_device *dev, unsigned int rxstat)
 	}
 }
 
+#ifdef SMSC_USE_SH_RX_DMA
+static void smsc911x_set_rx_cfg_for_dma(struct smsc911x_data *pdata)
+{
+	/* set RX Data offset and end alignment for DMA transfers */
+	switch (dma_get_cache_alignment()) {
+	case 16:
+		smsc911x_reg_write(pdata, RX_CFG, 0x40000200);
+		break;
+
+	case 32:
+		smsc911x_reg_write(pdata, RX_CFG, 0x80001200);
+		break;
+
+	default:
+		BUG();
+		break;
+	}
+}
+#endif
+
 /* Quickly dumps bad packets */
 static void
 smsc911x_rx_fastforward(struct smsc911x_data *pdata, unsigned int pktbytes)
 {
 	unsigned int pktwords = (pktbytes + NET_IP_ALIGN + 3) >> 2;
 
+#ifdef SMSC_USE_SH_RX_DMA
+	/* Remove extra DMA padding */
+	smsc911x_reg_write(pdata, RX_CFG, NET_IP_ALIGN << 8);
+#endif
+
 	if (likely(pktwords >= 4)) {
 		unsigned int timeout = 500;
 		unsigned int val;
@@ -985,6 +1019,11 @@ smsc911x_rx_fastforward(struct smsc911x_data *pdata, unsigned int pktbytes)
 		while (pktwords--)
 			temp = smsc911x_reg_read(pdata, RX_DATA_FIFO);
 	}
+
+#ifdef SMSC_USE_SH_RX_DMA
+	/* restore RX Data offset and end alignment for DMA transfers */
+	smsc911x_set_rx_cfg_for_dma(pdata);
+#endif
 }
 
 /* NAPI poll function */
@@ -995,11 +1034,33 @@ static int smsc911x_poll(struct napi_struct *napi, int budget)
 	struct net_device *dev = pdata->dev;
 	int npackets = 0;
 
+#ifdef SMSC_USE_SH_RX_DMA
+	/* check for pending transfer */
+	if (pdata->rx_skb) {
+		/* return immediately if the transfer hasn't finished */
+		if (get_dma_residue(pdata->config.rx_dma_ch))
+			return npackets;
+
+		/* transfer is complete, pass packet up */
+		pdata->rx_skb->dev = pdata->dev;
+		pdata->rx_skb->protocol =
+			eth_type_trans(pdata->rx_skb, pdata->dev);
+		pdata->rx_skb->ip_summed = CHECKSUM_NONE;
+		netif_receive_skb(pdata->rx_skb);
+		pdata->rx_skb = 0;
+	}
+#endif
+
 	while (likely(netif_running(dev)) && (npackets < budget)) {
 		unsigned int pktlength;
 		unsigned int pktwords;
 		struct sk_buff *skb;
 		unsigned int rxstat = smsc911x_rx_get_rxstatus(pdata);
+#ifdef SMSC_USE_SH_RX_DMA
+		unsigned long physaddrfrom, physaddrto;
+		int cachebytes = dma_get_cache_alignment();
+		unsigned long alignmask = cachebytes - 1;
+#endif
 
 		if (!rxstat) {
 			unsigned int temp;
@@ -1018,7 +1079,13 @@ static int smsc911x_poll(struct napi_struct *napi, int budget)
 		npackets++;
 
 		pktlength = ((rxstat & 0x3FFF0000) >> 16);
+#ifdef SMSC_USE_SH_RX_DMA
+		pktwords = (pktlength + (cachebytes - 14) + cachebytes - 1) &
+			(~alignmask);
+#else
 		pktwords = (pktlength + NET_IP_ALIGN + 3) >> 2;
+#endif
+
 		smsc911x_rx_counterrors(dev, rxstat);
 
 		if (unlikely(rxstat & RX_STS_ES_)) {
@@ -1031,7 +1098,11 @@ static int smsc911x_poll(struct napi_struct *napi, int budget)
 			continue;
 		}
 
+#ifdef SMSC_USE_SH_RX_DMA
+		skb = netdev_alloc_skb(dev, pktlength + (2 * cachebytes));
+#else
 		skb = netdev_alloc_skb(dev, pktlength + NET_IP_ALIGN);
+#endif
 		if (unlikely(!skb)) {
 			SMSC_WARNING(RX_ERR,
 				"Unable to allocate skb for rx packet");
@@ -1041,22 +1112,51 @@ static int smsc911x_poll(struct napi_struct *napi, int budget)
 			break;
 		}
 
+#ifdef SMSC_USE_SH_RX_DMA
+		pdata->rx_skb = skb;
+#endif
+
 		skb->data = skb->head;
 		skb_reset_tail_pointer(skb);
 
 		/* Align IP on 16B boundary */
+#ifdef SMSC_USE_SH_RX_DMA
+		skb_reserve(skb, cachebytes - 14);
+#else
 		skb_reserve(skb, NET_IP_ALIGN);
+#endif
 		skb_put(skb, pktlength - 4);
+
+#ifdef SMSC_USE_SH_RX_DMA
+		/* Calculate the physical transfer addresses */
+		physaddrfrom = virt_to_phys(pdata->ioaddr + RX_DATA_FIFO);
+		physaddrto = virt_to_phys(skb->head);
+		BUG_ON(physaddrfrom & alignmask);
+		BUG_ON(physaddrto & alignmask);
+
+		/* Flush cache */
+		dma_cache_sync(NULL, skb->head, pktwords, DMA_FROM_DEVICE);
+
+		/* Start the DMA transfer */
+		dma_read(pdata->config.rx_dma_ch, physaddrfrom, physaddrto,
+			 pktwords);
+#else
 		smsc911x_rx_readfifo(pdata, (unsigned int *)skb->head,
 				     pktwords);
 		skb->protocol = eth_type_trans(skb, dev);
 		skb->ip_summed = CHECKSUM_NONE;
 		netif_receive_skb(skb);
+#endif
 
 		/* Update counters */
 		dev->stats.rx_packets++;
 		dev->stats.rx_bytes += (pktlength - 4);
 		dev->last_rx = jiffies;
+
+#ifdef SMSC_USE_SH_RX_DMA
+		/* Packet scheduled, break out of loop */
+		break;
+#endif
 	}
 
 	/* Return total received packets */
@@ -1261,8 +1361,34 @@ static int smsc911x_open(struct net_device *dev)
 	temp &= ~(FIFO_INT_RX_STS_LEVEL_);
 	smsc911x_reg_write(pdata, FIFO_INT, temp);
 
+#ifdef SMSC_USE_SH_RX_DMA
+	/* set RX Data offset to 2 bytes for alignment and set end alignment
+	 * for DMA transfers */
+	smsc911x_set_rx_cfg_for_dma(pdata);
+#else
 	/* set RX Data offset to 2 bytes for alignment */
 	smsc911x_reg_write(pdata, RX_CFG, (2 << 8));
+#endif
+
+#ifdef SMSC_USE_SH_RX_DMA
+	/* Configure Rx DMA channel for fixed source address and incremented
+	 * destination address */
+	dma_configure_channel(pdata->config.rx_dma_ch,
+		DM_INC | TS_128 | 0x400 | TM_BUR);
+
+	if (request_dma(pdata->config.rx_dma_ch, SMSC_CHIPNAME) < 0) {
+		SMSC_WARNING(DRV, "Error requesting Rx DMA channel %d",
+			pdata->config.rx_dma_ch);
+		return -ENODEV;
+	}
+
+	printk(KERN_INFO "%s: Rx DMA %i\n", dev->name,
+		pdata->config.rx_dma_ch);
+#else
+	printk(KERN_INFO "%s: Rx PIO\n", dev->name);
+#endif
+
+	printk(KERN_INFO "%s: Tx PIO\n", dev->name);
 
 	/* enable NAPI polling before enabling RX interrupts */
 	napi_enable(&pdata->napi);
@@ -1307,6 +1433,11 @@ static int smsc911x_stop(struct net_device *dev)
 	/* Bring the PHY down */
 	phy_stop(pdata->phy_dev);
 
+	/* Free DMA channels */
+#ifdef SMSC_USE_SH_RX_DMA
+	free_dma(pdata->config.rx_dma_ch);
+#endif
+
 	SMSC_TRACE(IFDOWN, "Interface stopped");
 	return 0;
 }
diff --git a/drivers/net/smsc911x.h b/drivers/net/smsc911x.h
index f818cf0..4634dcf 100644
--- a/drivers/net/smsc911x.h
+++ b/drivers/net/smsc911x.h
@@ -33,6 +33,10 @@
  * can be succesfully looped back */
 #define USE_PHY_WORK_AROUND
 
+#ifdef CONFIG_SH_DMA
+#define SMSC_USE_SH_RX_DMA
+#endif /* CONFIG_SH_DMA */
+
 #define DPRINTK(nlevel, klevel, fmt, args...) \
 	((void)((NETIF_MSG_##nlevel & pdata->msg_enable) && \
 	printk(KERN_##klevel "%s: %s: " fmt "\n", \
diff --git a/include/linux/smsc911x.h b/include/linux/smsc911x.h
index 1cbf031..0d9408a 100644
--- a/include/linux/smsc911x.h
+++ b/include/linux/smsc911x.h
@@ -30,6 +30,9 @@ struct smsc911x_platform_config {
 	unsigned int irq_type;
 	unsigned int flags;
 	phy_interface_t phy_interface;
+#ifdef CONFIG_SH_DMA
+	int rx_dma_ch;
+#endif
 };
 
 /* Constants for platform_device irq polarity configuration */
-- 
1.5.6.5


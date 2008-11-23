From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [RFC PATCH 2/2] smsc911x: add support for sh3 TX DMA
Date: Sun, 23 Nov 2008 16:04:34 +0000
Message-ID: <1227456274-10388-2-git-send-email-steve.glendinning@smsc.com>
References: <1227456274-10388-1-git-send-email-steve.glendinning@smsc.com>
Cc: linux-sh@vger.kernel.org, Ian Saturley <ian.saturley@smsc.com>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [86.54.240.115] ([86.54.240.115]:35224 "EHLO drevil.shawell.net"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755360AbYKWQEb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Nov 2008 11:04:31 -0500
In-Reply-To: <1227456274-10388-1-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following on from the RX DMA patch, this patch also adds TX DMA support 
for the sh architecture.  Tested on SH7709S (sh3), where it works but 
actually *reduces* throughput (by about 30%).

The patch disables TX during the transfer, and uses the DMA completion 
interrupt to re-enable TX.  This causes 1 interrupt per packet, which is 
most likely responsible for the bulk of the performance loss.

This implementation is quite a nasty hack, as the sh DMA subsystem also 
attaches a DMA completion isr (so dma-sh.c must be modified to also
request the isr as shared).  The sh dma subsystem has a wait queue for
this purpose, but I don't think we can sleep in hard_start_xmit?

As with the RX patch, I'm interested to hear any advice on making this 
more generic.

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 drivers/net/smsc911x.c   |  139 +++++++++++++++++++++++++++++++++++++++++++++-
 drivers/net/smsc911x.h   |    1 +
 include/linux/smsc911x.h |    1 +
 3 files changed, 140 insertions(+), 1 deletions(-)

diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
index b3d9f9e..90ab783 100644
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -52,7 +52,7 @@
 #include <linux/smsc911x.h>
 #include "smsc911x.h"
 
-#ifdef SMSC_USE_SH_RX_DMA
+#if defined(SMSC_USE_SH_TX_DMA) || defined(SMSC_USE_SH_RX_DMA)
 #include <asm/dma.h>
 #include <../arch/sh/drivers/dma/dma-sh.h>
 #endif
@@ -125,6 +125,10 @@ struct smsc911x_data {
 #ifdef SMSC_USE_SH_RX_DMA
 	struct sk_buff *rx_skb;
 #endif
+
+#ifdef SMSC_USE_SH_TX_DMA
+	struct sk_buff *tx_skb;
+#endif
 };
 
 /* The 16-bit access functions are significantly slower, due to the locking
@@ -1253,6 +1257,40 @@ smsc911x_set_mac_address(struct smsc911x_data *pdata, u8 dev_addr[6])
 	smsc911x_mac_write(pdata, ADDRL, mac_low32);
 }
 
+#ifdef SMSC_USE_SH_TX_DMA
+static irqreturn_t smsc911x_tx_dma_irqhandler(int irq, void *dev_id)
+{
+	struct net_device *dev = dev_id;
+	struct smsc911x_data *pdata = netdev_priv(dev);
+	unsigned int freespace;
+
+	if (!pdata->tx_skb)
+		return IRQ_NONE;
+
+	/* make sure the channel has finished running */
+	BUG_ON(get_dma_residue(pdata->config.tx_dma_ch));
+
+	dev_kfree_skb_irq(pdata->tx_skb);
+	pdata->tx_skb = NULL;
+
+	freespace = smsc911x_reg_read(pdata, TX_FIFO_INF) & TX_FIFO_INF_TDFREE_;
+
+	if (freespace < TX_FIFO_LOW_THRESHOLD) {
+		/* free space low, leave tx disabled and enable the
+		 * tx fifo level interrupt */
+		unsigned int temp = smsc911x_reg_read(pdata, FIFO_INT);
+		temp &= 0x00FFFFFF;
+		temp |= 0x32000000;
+		smsc911x_reg_write(pdata, FIFO_INT, temp);
+	} else {
+		/* free space not low, re-enable the tx queue */
+		netif_wake_queue(pdata->dev);
+	}
+
+	return IRQ_HANDLED;
+}
+#endif
+
 static int smsc911x_open(struct net_device *dev)
 {
 	struct smsc911x_data *pdata = netdev_priv(dev);
@@ -1388,7 +1426,30 @@ static int smsc911x_open(struct net_device *dev)
 	printk(KERN_INFO "%s: Rx PIO\n", dev->name);
 #endif
 
+#ifdef SMSC_USE_SH_TX_DMA
+	/* Configure Tx DMA channel for incremented source address, fixed
+	 * destination address and enable the transfer complete interrupt */
+	dma_configure_channel(pdata->config.tx_dma_ch,
+		SM_INC | TS_128 | CHCR_IE | 0x400 | TM_BUR);
+
+	if (request_dma(pdata->config.tx_dma_ch, SMSC_CHIPNAME) < 0) {
+		SMSC_WARNING(DRV, "Error requesting Tx DMA channel %d",
+			pdata->config.tx_dma_ch);
+		goto out_release_rx_dma_1;
+	}
+
+	/* TODO: fix this hardcoded IRQ */
+	if (request_irq(DMTE1_IRQ, smsc911x_tx_dma_irqhandler,
+		IRQF_SHARED | IRQF_DISABLED, SMSC_CHIPNAME " Tx DMA", dev)) {
+		SMSC_WARNING(DRV, "Error requesting Tx DMA irq");
+		goto out_release_tx_dma_2;
+	}
+
+	printk(KERN_INFO "%s: Tx DMA %i\n", dev->name,
+		pdata->config.tx_dma_ch);
+#else
 	printk(KERN_INFO "%s: Tx PIO\n", dev->name);
+#endif
 
 	/* enable NAPI polling before enabling RX interrupts */
 	napi_enable(&pdata->napi);
@@ -1407,6 +1468,16 @@ static int smsc911x_open(struct net_device *dev)
 
 	netif_start_queue(dev);
 	return 0;
+
+#ifdef SMSC_USE_SH_TX_DMA
+out_release_tx_dma_2:
+	free_dma(pdata->config.tx_dma_ch);
+out_release_rx_dma_1:
+#ifdef SMSC_USE_SH_RX_DMA
+	free_dma(pdata->config.rx_dma_ch);
+#endif
+	return -ENODEV;
+#endif
 }
 
 /* Entry point for stopping the interface */
@@ -1434,6 +1505,9 @@ static int smsc911x_stop(struct net_device *dev)
 	phy_stop(pdata->phy_dev);
 
 	/* Free DMA channels */
+#ifdef SMSC_USE_SH_TX_DMA
+	free_dma(pdata->config.tx_dma_ch);
+#endif
 #ifdef SMSC_USE_SH_RX_DMA
 	free_dma(pdata->config.rx_dma_ch);
 #endif
@@ -1449,9 +1523,23 @@ static int smsc911x_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	unsigned int freespace;
 	unsigned int tx_cmd_a;
 	unsigned int tx_cmd_b;
+#ifdef SMSC_USE_SH_TX_DMA
+	unsigned int dma_cnt;
+	unsigned long physaddrfrom, physaddrto;
+	int cachebytes = dma_get_cache_alignment();
+	unsigned long alignmask = cachebytes - 1;
+	void *dma_buf;
+#else
 	unsigned int temp;
 	u32 wrsz;
 	ulong bufp;
+#endif
+
+#ifdef SMSC_USE_SH_TX_DMA
+	/* make sure the channel is not already running */
+	BUG_ON(pdata->tx_skb);
+	BUG_ON(get_dma_residue(pdata->config.tx_dma_ch));
+#endif
 
 	freespace = smsc911x_reg_read(pdata, TX_FIFO_INF) & TX_FIFO_INF_TDFREE_;
 
@@ -1459,17 +1547,62 @@ static int smsc911x_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		SMSC_WARNING(TX_ERR,
 			"Tx data fifo low, space available: %d", freespace);
 
+#ifdef SMSC_USE_SH_TX_DMA
+	/* 16/32 Byte start alignment */
+	tx_cmd_a = (((unsigned int)skb->data) & alignmask) << 16;
+
+	switch (cachebytes) {
+	case 16:
+		tx_cmd_a |= 0x01 << 24; /* 16 byte end alignment */
+		break;
+
+	case 32:
+		tx_cmd_a |= 0x02 << 24; /* 32 byte end alignment */
+		break;
+
+	default:
+		SMSC_WARNING(DRV, "Unknown DMA alignment");
+		break;
+	}
+#else
 	/* Word alignment adjustment */
 	tx_cmd_a = (u32)((ulong)skb->data & 0x03) << 16;
+#endif
+
 	tx_cmd_a |= TX_CMD_A_FIRST_SEG_ | TX_CMD_A_LAST_SEG_;
 	tx_cmd_a |= (unsigned int)skb->len;
 
 	tx_cmd_b = ((unsigned int)skb->len) << 16;
 	tx_cmd_b |= (unsigned int)skb->len;
 
+#ifdef SMSC_USE_SH_TX_DMA
+	dma_buf = (void *)(((unsigned long)skb->data) & (~alignmask));
+	dma_cnt = (((u32)skb->len) + alignmask +
+		   (((unsigned long)skb->data) & alignmask)) & (~alignmask);
+#endif
+
 	smsc911x_reg_write(pdata, TX_DATA_FIFO, tx_cmd_a);
 	smsc911x_reg_write(pdata, TX_DATA_FIFO, tx_cmd_b);
 
+#ifdef SMSC_USE_SH_TX_DMA
+	/* store the skb for the completion isr */
+	pdata->tx_skb = skb;
+
+	/* Calculate the physical transfer addresses */
+	physaddrfrom = virt_to_phys(dma_buf);
+	physaddrto = virt_to_phys(pdata->ioaddr + TX_DATA_FIFO);
+	BUG_ON(physaddrfrom & alignmask);
+	BUG_ON(physaddrto & alignmask);
+
+	/* Flush cache */
+	dma_cache_sync(NULL, dma_buf, dma_cnt, DMA_TO_DEVICE);
+
+	/* stop Tx until the DMA transaction is complete */
+	netif_stop_queue(dev);
+
+	/* Start the DMA transfer */
+	dma_write(pdata->config.tx_dma_ch, physaddrfrom, physaddrto, dma_cnt);
+#else
 	bufp = (ulong)skb->data & (~0x3);
 	wrsz = (u32)skb->len + 3;
 	wrsz += (u32)((ulong)skb->data & 0x3);
@@ -1478,11 +1611,14 @@ static int smsc911x_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	smsc911x_tx_writefifo(pdata, (unsigned int *)bufp, wrsz);
 	freespace -= (skb->len + 32);
 	dev_kfree_skb(skb);
+#endif
+
 	dev->trans_start = jiffies;
 
 	if (unlikely(smsc911x_tx_get_txstatcount(pdata) >= 30))
 		smsc911x_tx_update_txcounters(dev);
 
+#ifndef SMSC_USE_SH_TX_DMA
 	if (freespace < TX_FIFO_LOW_THRESHOLD) {
 		netif_stop_queue(dev);
 		temp = smsc911x_reg_read(pdata, FIFO_INT);
@@ -1490,6 +1626,7 @@ static int smsc911x_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		temp |= 0x32000000;
 		smsc911x_reg_write(pdata, FIFO_INT, temp);
 	}
+#endif
 
 	return NETDEV_TX_OK;
 }
diff --git a/drivers/net/smsc911x.h b/drivers/net/smsc911x.h
index 4634dcf..c21b1f9 100644
--- a/drivers/net/smsc911x.h
+++ b/drivers/net/smsc911x.h
@@ -35,6 +35,7 @@
 
 #ifdef CONFIG_SH_DMA
 #define SMSC_USE_SH_RX_DMA
+#define SMSC_USE_SH_TX_DMA
 #endif /* CONFIG_SH_DMA */
 
 #define DPRINTK(nlevel, klevel, fmt, args...) \
diff --git a/include/linux/smsc911x.h b/include/linux/smsc911x.h
index 0d9408a..d764f01 100644
--- a/include/linux/smsc911x.h
+++ b/include/linux/smsc911x.h
@@ -32,6 +32,7 @@ struct smsc911x_platform_config {
 	phy_interface_t phy_interface;
 #ifdef CONFIG_SH_DMA
 	int rx_dma_ch;
+	int tx_dma_ch;
 #endif
 };
 
-- 
1.5.6.5


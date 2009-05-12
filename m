From: Li Yang <leoli@freescale.com>
Subject: [PATCH 4/6] rionet: add memory access to simulated Ethernet over rapidio
Date: Tue, 12 May 2009 16:36:01 +0800
Message-ID: <1242117363-14949-4-git-send-email-leoli@freescale.com>
References: <1242117363-14949-1-git-send-email-leoli@freescale.com>
 <1242117363-14949-2-git-send-email-leoli@freescale.com>
 <1242117363-14949-3-git-send-email-leoli@freescale.com>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, Li Yang <leoli@freescale.com>,
	Zhang Wei <zw@zh-kernel.org>
To: akpm@linux-foundation.org, galak@kernel.crashing.org,
	davem@davemloft.net, mporter@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:55508 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758052AbZELIlm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2009 04:41:42 -0400
In-Reply-To: <1242117363-14949-3-git-send-email-leoli@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Through the newly added IO memory access of RapidIO, sender can
write directly to recipient's rx buffer, either by cpu or DMA engine.

Signed-off-by: Zhang Wei <zw@zh-kernel.org>
Signed-off-by: Li Yang <leoli@freescale.com>
---
 drivers/net/Kconfig  |   10 ++
 drivers/net/rionet.c |  365 +++++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 371 insertions(+), 4 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 214a92d..1e88e26 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2736,6 +2736,16 @@ config RIONET_RX_SIZE
 	depends on RIONET
 	default "128"
 
+config RIONET_MEMMAP
+	bool "Use memory map instead of message"
+	depends on RIONET
+	default n
+
+config RIONET_DMA
+	bool "Use DMA for memory mapping data transfer"
+	depends on RIONET_MEMMAP && FSL_DMA
+	default y
+
 config FDDI
 	tristate "FDDI driver support"
 	depends on (PCI || EISA || TC)
diff --git a/drivers/net/rionet.c b/drivers/net/rionet.c
index ec59e29..c38e51e 100644
--- a/drivers/net/rionet.c
+++ b/drivers/net/rionet.c
@@ -1,6 +1,8 @@
 /*
  * rionet - Ethernet driver over RapidIO messaging services
  *
+ * Copyright (C) 2007-2009 Freescale Semiconductor, Inc.
+ *
  * Copyright 2005 MontaVista Software, Inc.
  * Matt Porter <mporter@kernel.crashing.org>
  *
@@ -23,6 +25,7 @@
 #include <linux/skbuff.h>
 #include <linux/crc32.h>
 #include <linux/ethtool.h>
+#include <linux/dmaengine.h>
 
 #define DRV_NAME        "rionet"
 #define DRV_VERSION     "0.2"
@@ -40,13 +43,48 @@ MODULE_LICENSE("GPL");
 			 NETIF_MSG_TX_ERR)
 
 #define RIONET_DOORBELL_JOIN	0x1000
+#ifdef CONFIG_RIONET_MEMMAP
+#define RIONET_DOORBELL_SEND	0x1001
+#define RIONET_DOORBELL_LEAVE	0x1002
+#else
 #define RIONET_DOORBELL_LEAVE	0x1001
+#endif
 
 #define RIONET_MAILBOX		0
 
 #define RIONET_TX_RING_SIZE	CONFIG_RIONET_TX_SIZE
 #define RIONET_RX_RING_SIZE	CONFIG_RIONET_RX_SIZE
 
+#define ERR(fmt, arg...) \
+	printk(KERN_ERR "ERROR %s - %s: " fmt,  __FILE__, __func__, ## arg)
+
+#ifdef CONFIG_RIONET_MEMMAP
+/* Definitions for rionet memory map driver */
+#define RIONET_DRVID		0x101
+#define RIONET_MAX_SK_DATA_SIZE	0x1000
+#define RIONET_MEM_RIO_BASE	0x10000000
+#define RIONET_TX_RX_BUFF_SIZE	(0x1000 * (128 + 128))
+#define RIONET_QUEUE_NEXT(x)	(((x) < 127) ? ((x) + 1) : 0)
+#define RIONET_QUEUE_INC(x)	(x = RIONET_QUEUE_NEXT(x))
+
+struct sk_data {
+	u8	data[0x1000];
+};
+
+#define RIONET_SKDATA_EN	0x80000000
+struct rionet_tx_rx_buff {
+	int		enqueue;		/* enqueue point */
+	int		dequeue;		/* dequeue point */
+	u32		size[128];		/* size[i] is skdata[i] size
+						 * the most high bit [31] is
+						 * enable bit. The
+						 * max size is 4096.
+						 */
+	u8		rev1[3576];
+	struct sk_data	skdata[128];		/* all size are 0x1000 * 128 */
+};
+#endif /* CONFIG_RIONET_MEMMAP */
+
 static LIST_HEAD(rionet_peers);
 
 struct rionet_private {
@@ -60,6 +98,19 @@ struct rionet_private {
 	spinlock_t lock;
 	spinlock_t tx_lock;
 	u32 msg_enable;
+#ifdef CONFIG_RIONET_MEMMAP
+	struct rionet_tx_rx_buff *rxbuff;
+	struct rionet_tx_rx_buff __iomem *txbuff;
+	dma_addr_t rx_addr;
+	phys_addr_t tx_addr;
+	struct resource *riores;
+#ifdef CONFIG_RIONET_DMA
+	struct dma_chan *txdmachan;
+	struct dma_chan *rxdmachan;
+	struct dma_client rio_dma_client;
+	spinlock_t rio_dma_event_lock;
+#endif
+#endif
 };
 
 struct rionet_peer {
@@ -90,6 +141,7 @@ static struct rio_dev **rionet_active;
 #define RIONET_MAC_MATCH(x)	(*(u32 *)x == 0x00010001)
 #define RIONET_GET_DESTID(x)	(*(u16 *)(x + 4))
 
+#ifndef CONFIG_RIONET_MEMMAP
 static int rionet_rx_clean(struct net_device *ndev)
 {
 	int i;
@@ -108,9 +160,11 @@ static int rionet_rx_clean(struct net_device *ndev)
 
 		rnet->rx_skb[i]->data = data;
 		skb_put(rnet->rx_skb[i], RIO_MAX_MSG_SIZE);
+		rnet->rx_skb[i]->dev = ndev;
 		rnet->rx_skb[i]->protocol =
 		    eth_type_trans(rnet->rx_skb[i], ndev);
 		error = netif_rx(rnet->rx_skb[i]);
+		rnet->rx_skb[i] = NULL;
 
 		if (error == NET_RX_DROP) {
 			ndev->stats.rx_dropped++;
@@ -128,6 +182,7 @@ static int rionet_rx_clean(struct net_device *ndev)
 
 	return i;
 }
+#endif
 
 static void rionet_rx_fill(struct net_device *ndev, int end)
 {
@@ -141,19 +196,86 @@ static void rionet_rx_fill(struct net_device *ndev, int end)
 		if (!rnet->rx_skb[i])
 			break;
 
+#ifndef CONFIG_RIONET_MEMMAP
 		rio_add_inb_buffer(rnet->mport, RIONET_MAILBOX,
 				   rnet->rx_skb[i]->data);
+#endif
 	} while ((i = (i + 1) % RIONET_RX_RING_SIZE) != end);
 
 	rnet->rx_slot = i;
 }
 
+#ifdef CONFIG_RIONET_MEMMAP
+static int rio_send_mem(struct sk_buff *skb,
+				struct net_device *ndev, struct rio_dev *rdev)
+{
+	struct rionet_private *rnet = netdev_priv(ndev);
+	int enqueue, dequeue;
+
+	if (!rdev)
+		return -EFAULT;
+
+	if (skb->len > RIONET_MAX_SK_DATA_SIZE) {
+		printk(KERN_ERR "Frame len is more than RIONET max sk_data!\n");
+		return -EINVAL;
+	}
+
+	rio_map_outb_region(rnet->mport, rdev->destid, rnet->riores,
+			rnet->tx_addr, 0);
+
+	enqueue = in_be32(&rnet->txbuff->enqueue);
+	dequeue = in_be32(&rnet->txbuff->dequeue);
+
+	if (!(in_be32(&rnet->txbuff->size[enqueue]) & RIONET_SKDATA_EN)
+			&& (RIONET_QUEUE_NEXT(enqueue) != dequeue)) {
+#ifdef CONFIG_RIONET_DMA
+		struct dma_device *dmadev;
+		struct dma_async_tx_descriptor *tx;
+		dma_cookie_t tx_cookie = 0;
+
+		dmadev = rnet->txdmachan->device;
+		tx = dmadev->device_prep_dma_memcpy(rnet->txdmachan,
+			(void *)rnet->txbuff->skdata[enqueue].data
+			  - (void *)rnet->txbuff rnet->tx_addr,
+			dma_map_single(&ndev->dev, skb->data, skb->len,
+			  DMA_TO_DEVICE), skb->len, DMA_CTRL_ACK);
+		if (!tx)
+			return -EFAULT;
+		tx_cookie = tx->tx_submit(tx);
+
+		dma_async_memcpy_issue_pending(rnet->txdmachan);
+		while (dma_async_memcpy_complete(rnet->txdmachan,
+				tx_cookie, NULL, NULL) == DMA_IN_PROGRESS) ;
+#else
+		memcpy(rnet->txbuff->skdata[enqueue].data, skb->data, skb->len);
+#endif /* CONFIG_RIONET_DMA */
+		out_be32(&rnet->txbuff->size[enqueue],
+						RIONET_SKDATA_EN | skb->len);
+		out_be32(&rnet->txbuff->enqueue,
+						RIONET_QUEUE_NEXT(enqueue));
+		in_be32(&rnet->txbuff->enqueue);	/* verify read */
+	} else if (netif_msg_tx_err(rnet))
+		printk(KERN_ERR "rionmet(memmap): txbuff is busy!\n");
+
+	rio_unmap_outb_region(rnet->mport, rnet->tx_addr);
+	rio_send_doorbell(rdev, RIONET_DOORBELL_SEND);
+	return 0;
+}
+#endif
+
 static int rionet_queue_tx_msg(struct sk_buff *skb, struct net_device *ndev,
 			       struct rio_dev *rdev)
 {
 	struct rionet_private *rnet = netdev_priv(ndev);
 
+#ifdef CONFIG_RIONET_MEMMAP
+	int ret = 0;
+	ret = rio_send_mem(skb, ndev, rdev);
+	if (ret)
+		return ret;
+#else
 	rio_add_outb_message(rnet->mport, rdev, 0, skb->data, skb->len);
+#endif
 	rnet->tx_skb[rnet->tx_slot] = skb;
 
 	ndev->stats.tx_packets++;
@@ -165,6 +287,19 @@ static int rionet_queue_tx_msg(struct sk_buff *skb, struct net_device *ndev,
 	++rnet->tx_slot;
 	rnet->tx_slot &= (RIONET_TX_RING_SIZE - 1);
 
+#ifdef CONFIG_RIONET_MEMMAP
+	while (rnet->tx_cnt && (rnet->ack_slot != rnet->tx_slot)) {
+		/* dma unmap single */
+		dev_kfree_skb_any(rnet->tx_skb[rnet->ack_slot]);
+		rnet->tx_skb[rnet->ack_slot] = NULL;
+		++rnet->ack_slot;
+		rnet->ack_slot &= (RIONET_TX_RING_SIZE - 1);
+		rnet->tx_cnt--;
+	}
+
+	if (rnet->tx_cnt < RIONET_TX_RING_SIZE)
+		netif_wake_queue(ndev);
+#endif
 	if (netif_msg_tx_queued(rnet))
 		printk(KERN_INFO "%s: queued skb %8.8x len %8.8x\n", DRV_NAME,
 		       (u32) skb, skb->len);
@@ -211,6 +346,92 @@ static int rionet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	return 0;
 }
 
+#ifdef CONFIG_RIONET_MEMMAP
+static void rio_recv_mem(struct net_device *ndev)
+{
+	struct rionet_private *rnet = netdev_priv(ndev);
+	struct sk_buff *skb;
+	u32 enqueue, dequeue, size;
+	int error = 0;
+#ifdef CONFIG_RIONET_DMA
+	dma_cookie_t rx_cookie = 0;
+	struct dma_device *dmadev;
+	struct dma_async_tx_descriptor *tx;
+#endif
+
+	dequeue = rnet->rxbuff->dequeue;
+	enqueue = rnet->rxbuff->enqueue;
+
+	while (enqueue != dequeue) {
+		size = rnet->rxbuff->size[dequeue];
+		if (!(size & RIONET_SKDATA_EN))
+			return;
+		size &= ~RIONET_SKDATA_EN;
+
+		skb = dev_alloc_skb(size + 2);
+		if (!skb)
+			return;
+
+#ifdef CONFIG_RIONET_DMA
+		dmadev = rnet->rxdmachan->device;
+		tx = dmadev->device_prep_dma_memcpy(rnet->rxdmachan,
+			dma_map_single(&ndev->dev, skb_put(skb, size),
+			  size, DMA_FROM_DEVICE),
+			(void *)rnet->rxbuff->skdata[dequeue].data
+			  - (void *)rnet->rxbuff + rnet->rx_addr,
+			size, DMA_CTRL_ACK);
+		if (!tx)
+			return;
+		rx_cookie = tx->tx_submit(tx);
+		dma_async_memcpy_issue_pending(rnet->rxdmachan);
+		while (dma_async_memcpy_complete(rnet->rxdmachan,
+				rx_cookie, NULL, NULL) == DMA_IN_PROGRESS);
+#else
+		memcpy(skb_put(skb, size),
+				rnet->rxbuff->skdata[dequeue].data,
+				size);
+#endif /* CONFIG_RIONET_DMA */
+		skb->dev = ndev;
+		skb->protocol = eth_type_trans(skb, ndev);
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
+
+		error = netif_rx(skb);
+
+		rnet->rxbuff->size[dequeue] &= ~RIONET_SKDATA_EN;
+		rnet->rxbuff->dequeue = RIONET_QUEUE_NEXT(dequeue);
+		dequeue = RIONET_QUEUE_NEXT(dequeue);
+
+		if (error == NET_RX_DROP) {
+			ndev->stats.rx_dropped++;
+		} else if (error == NET_RX_BAD) {
+			if (netif_msg_rx_err(rnet))
+				printk(KERN_WARNING "%s: bad rx packet\n",
+				       DRV_NAME);
+			ndev->stats.rx_errors++;
+		} else {
+			ndev->stats.rx_packets++;
+			ndev->stats.rx_bytes += RIO_MAX_MSG_SIZE;
+		}
+	}
+}
+
+static void rionet_inb_recv_event(struct rio_mport *mport, void *dev_id)
+{
+	struct net_device *ndev = dev_id;
+	struct rionet_private *rnet = netdev_priv(ndev);
+	unsigned long flags;
+
+	if (netif_msg_intr(rnet))
+		printk(KERN_INFO "%s: inbound memory data receive event\n",
+		       DRV_NAME);
+
+	spin_lock_irqsave(&rnet->lock, flags);
+	rio_recv_mem(ndev);
+	spin_unlock_irqrestore(&rnet->lock, flags);
+}
+#endif
+
+
 static void rionet_dbell_event(struct rio_mport *mport, void *dev_id, u16 sid, u16 tid,
 			       u16 info)
 {
@@ -232,6 +453,10 @@ static void rionet_dbell_event(struct rio_mport *mport, void *dev_id, u16 sid, u
 		}
 	} else if (info == RIONET_DOORBELL_LEAVE) {
 		rionet_active[sid] = NULL;
+#ifdef CONFIG_RIONET_MEMMAP
+	} else if (info == RIONET_DOORBELL_SEND) {
+		rionet_inb_recv_event(mport, ndev);
+#endif
 	} else {
 		if (netif_msg_intr(rnet))
 			printk(KERN_WARNING "%s: unhandled doorbell\n",
@@ -239,6 +464,7 @@ static void rionet_dbell_event(struct rio_mport *mport, void *dev_id, u16 sid, u
 	}
 }
 
+#ifndef CONFIG_RIONET_MEMMAP
 static void rionet_inb_msg_event(struct rio_mport *mport, void *dev_id, int mbox, int slot)
 {
 	int n;
@@ -281,6 +507,58 @@ static void rionet_outb_msg_event(struct rio_mport *mport, void *dev_id, int mbo
 
 	spin_unlock(&rnet->lock);
 }
+#endif
+
+#ifdef CONFIG_RIONET_DMA
+static enum dma_state_client rionet_dma_event(struct dma_client *client,
+		struct dma_chan *chan, enum dma_state state)
+{
+	struct rionet_private *rnet = container_of(client,
+			struct rionet_private, rio_dma_client);
+	enum dma_state_client ack = DMA_DUP;
+
+	spin_lock(&rnet->lock);
+	switch (state) {
+	case DMA_RESOURCE_AVAILABLE:
+		if (!rnet->txdmachan) {
+			ack = DMA_ACK;
+			rnet->txdmachan = chan;
+		} else if (!rnet->rxdmachan) {
+			ack = DMA_ACK;
+			rnet->rxdmachan = chan;
+		}
+		break;
+	case DMA_RESOURCE_REMOVED:
+		if (rnet->txdmachan == chan) {
+			ack = DMA_ACK;
+			rnet->txdmachan = NULL;
+		} else if (rnet->rxdmachan == chan) {
+			ack = DMA_ACK;
+			rnet->rxdmachan = NULL;
+		}
+		break;
+	default:
+		break;
+	}
+	spin_unlock(&rnet->lock);
+	return ack;
+}
+
+static int rionet_dma_register(struct rionet_private *rnet)
+{
+	int rc = 0;
+	spin_lock_init(&rnet->rio_dma_event_lock);
+	rnet->rio_dma_client.event_callback = rionet_dma_event;
+	dma_cap_set(DMA_MEMCPY, rnet->rio_dma_client.cap_mask);
+	dma_async_client_register(&rnet->rio_dma_client);
+	dma_async_client_chan_request(&rnet->rio_dma_client);
+
+	if (!rnet->txdmachan || !rnet->rxdmachan)
+		rc = -ENODEV;
+
+	return rc;
+}
+#endif
 
 static int rionet_open(struct net_device *ndev)
 {
@@ -297,21 +575,63 @@ static int rionet_open(struct net_device *ndev)
 					RIONET_DOORBELL_JOIN,
 					RIONET_DOORBELL_LEAVE,
 					rionet_dbell_event)) < 0)
-		goto out;
+		return rc;
+
+#ifdef CONFIG_RIONET_MEMMAP
+	if (!request_rio_region(RIONET_MEM_RIO_BASE, RIONET_TX_RX_BUFF_SIZE,
+				ndev->name, 0)) {
+		dev_err(&ndev->dev, "RapidIO space busy\n");
+		rc = -EBUSY;
+		goto out1;
+	}
 
+	rnet->riores = kmalloc(sizeof(struct resource), GFP_KERNEL);
+	if (!rnet->riores) {
+		rc = -ENOMEM;
+		goto out2;
+	}
+	rnet->riores->start = RIONET_MEM_RIO_BASE;
+	rnet->riores->end = RIONET_MEM_RIO_BASE + RIONET_TX_RX_BUFF_SIZE - 1;
+	rnet->rxbuff = dma_alloc_coherent(&ndev->dev, RIONET_TX_RX_BUFF_SIZE,
+			&rnet->rx_addr, GFP_KERNEL);
+	if (!rnet->rxbuff) {
+		rc = -ENOMEM;
+		goto out3;
+	}
+	rc = rio_map_inb_region(rnet->mport, rnet->riores, rnet->rx_addr, 0);
+	if (rc) {
+		rc = -EBUSY;
+		goto out4;
+	}
+	
+	/* Use space right after the doorbell window, aligned to
+	 * size of RIONET_TX_RX_BUFF_SIZE */
+	rnet->tx_addr = rnet->mport->iores.start + 0x500000;
+	rnet->txbuff = ioremap(rnet->tx_addr, resource_size(rnet->riores));
+	if (!rnet->txbuff) {
+		rc = -ENOMEM;
+		goto out5;
+	}
+#ifdef CONFIG_RIONET_DMA
+	rc = rionet_dma_register(rnet);
+	if (rc)
+		goto out6;
+#endif /* CONFIG_RIONET_DMA */
+#else
 	if ((rc = rio_request_inb_mbox(rnet->mport,
 				       (void *)ndev,
 				       RIONET_MAILBOX,
 				       RIONET_RX_RING_SIZE,
 				       rionet_inb_msg_event)) < 0)
-		goto out;
+		goto out1;
 
 	if ((rc = rio_request_outb_mbox(rnet->mport,
 					(void *)ndev,
 					RIONET_MAILBOX,
 					RIONET_TX_RING_SIZE,
 					rionet_outb_msg_event)) < 0)
-		goto out;
+		goto out8;
+#endif
 
 	/* Initialize inbound message ring */
 	for (i = 0; i < RIONET_RX_RING_SIZE; i++)
@@ -344,8 +664,31 @@ static int rionet_open(struct net_device *ndev)
 		if (pwdcsr & RIO_DOORBELL_AVAIL)
 			rio_send_doorbell(peer->rdev, RIONET_DOORBELL_JOIN);
 	}
+	return 0;
 
-      out:
+#ifndef CONFIG_RIONET_MEMMAP
+out8:
+	rio_release_inb_mbox(rnet->mport, RIONET_MAILBOX);
+#else
+#ifdef CONFIG_RIONET_DMA
+out6:
+	iounmap(rnet->txbuff);
+#endif
+out5:
+	rio_unmap_inb_region(rnet->mport, rnet->rx_addr);
+out4:
+	dma_free_coherent(&ndev->dev, RIONET_TX_RX_BUFF_SIZE,
+			rnet->rxbuff, rnet->rx_addr);
+	rnet->rxbuff = NULL;
+	rnet->txbuff = NULL;
+out3:
+	kfree(rnet->riores);
+out2:
+	release_rio_region(RIONET_MEM_RIO_BASE, RIONET_TX_RX_BUFF_SIZE);
+#endif
+out1:
+	rio_release_inb_dbell(rnet->mport, RIONET_DOORBELL_JOIN,
+			RIONET_DOORBELL_LEAVE);
 	return rc;
 }
 
@@ -374,8 +717,22 @@ static int rionet_close(struct net_device *ndev)
 
 	rio_release_inb_dbell(rnet->mport, RIONET_DOORBELL_JOIN,
 			      RIONET_DOORBELL_LEAVE);
+#ifdef CONFIG_RIONET_MEMMAP
+	rio_unmap_inb_region(rnet->mport, rnet->rx_addr);
+	iounmap(rnet->txbuff);
+	dma_free_coherent(&ndev->dev, RIONET_TX_RX_BUFF_SIZE,
+			rnet->rxbuff, rnet->rx_addr);
+	kfree(rnet->riores);
+	release_rio_region(RIONET_MEM_RIO_BASE, RIONET_TX_RX_BUFF_SIZE);
+	rnet->rxbuff = NULL;
+	rnet->txbuff = NULL;
+#ifdef CONFIG_RIONET_DMA
+	dma_async_client_unregister(&rnet->rio_dma_client);
+#endif
+#else
 	rio_release_inb_mbox(rnet->mport, RIONET_MAILBOX);
 	rio_release_outb_mbox(rnet->mport, RIONET_MAILBOX);
+#endif
 
 	return 0;
 }
-- 
1.5.4


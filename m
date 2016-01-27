From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 4/9] net: moxart: use correct accessors for DMA memory
Date: Wed, 27 Jan 2016 15:04:54 +0100
Message-ID: <1453903507-3427225-5-git-send-email-arnd@arndb.de>
References: <1453903507-3427225-1-git-send-email-arnd@arndb.de>
Cc: linux-arm-kernel@lists.infradead.org,
	Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
	=?UTF-8?q?fran=C3=A7ois=20romieu?= <romieu@fr.zoreil.com>,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1453903507-3427225-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The moxart ethernet driver confuses coherent DMA buffers with
MMIO registers.

moxart_ether.c: In function 'moxart_mac_setup_desc_ring':
moxart_ether.c:146:428: error: passing argument 1 of '__fswab32' makes integer from pointer without a cast [-Werror=int-conversion]
moxart_ether.c:74:39: warning: incorrect type in argument 3 (different address spaces)
moxart_ether.c:74:39:    expected void *cpu_addr
moxart_ether.c:74:39:    got void [noderef] <asn:2>*tx_desc_base

This leaves the basic logic alone and uses normal pointers for
the virtual address of the descriptor. As we cannot use readl/writel
to access them, we also introduce our own moxart_desc_read
moxart_desc_write helpers that perform the same endianess swap
as the original code, but without the extra barriers and address
space conversion.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/moxa/moxart_ether.c | 42 ++++++++++++++++++++------------
 drivers/net/ethernet/moxa/moxart_ether.h |  4 +--
 2 files changed, 28 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/moxa/moxart_ether.c b/drivers/net/ethernet/moxa/moxart_ether.c
index a10c928bbd6b..b2f1c0db9445 100644
--- a/drivers/net/ethernet/moxa/moxart_ether.c
+++ b/drivers/net/ethernet/moxa/moxart_ether.c
@@ -28,6 +28,16 @@
 
 #include "moxart_ether.h"
 
+static inline void moxart_desc_write(u32 data, u32 *desc)
+{
+	*desc = cpu_to_le32(data);
+}
+
+static inline u32 moxart_desc_read(u32 *desc)
+{
+	return le32_to_cpu(*desc);
+}
+
 static inline void moxart_emac_write(struct net_device *ndev,
 				     unsigned int reg, unsigned long value)
 {
@@ -112,7 +122,7 @@ static void moxart_mac_enable(struct net_device *ndev)
 static void moxart_mac_setup_desc_ring(struct net_device *ndev)
 {
 	struct moxart_mac_priv_t *priv = netdev_priv(ndev);
-	void __iomem *desc;
+	void *desc;
 	int i;
 
 	for (i = 0; i < TX_DESC_NUM; i++) {
@@ -121,7 +131,7 @@ static void moxart_mac_setup_desc_ring(struct net_device *ndev)
 
 		priv->tx_buf[i] = priv->tx_buf_base + priv->tx_buf_size * i;
 	}
-	writel(TX_DESC1_END, desc + TX_REG_OFFSET_DESC1);
+	moxart_desc_write(TX_DESC1_END, desc + TX_REG_OFFSET_DESC1);
 
 	priv->tx_head = 0;
 	priv->tx_tail = 0;
@@ -129,8 +139,8 @@ static void moxart_mac_setup_desc_ring(struct net_device *ndev)
 	for (i = 0; i < RX_DESC_NUM; i++) {
 		desc = priv->rx_desc_base + i * RX_REG_DESC_SIZE;
 		memset(desc, 0, RX_REG_DESC_SIZE);
-		writel(RX_DESC0_DMA_OWN, desc + RX_REG_OFFSET_DESC0);
-		writel(RX_BUF_SIZE & RX_DESC1_BUF_SIZE_MASK,
+		moxart_desc_write(RX_DESC0_DMA_OWN, desc + RX_REG_OFFSET_DESC0);
+		moxart_desc_write(RX_BUF_SIZE & RX_DESC1_BUF_SIZE_MASK,
 		       desc + RX_REG_OFFSET_DESC1);
 
 		priv->rx_buf[i] = priv->rx_buf_base + priv->rx_buf_size * i;
@@ -141,12 +151,12 @@ static void moxart_mac_setup_desc_ring(struct net_device *ndev)
 		if (dma_mapping_error(&ndev->dev, priv->rx_mapping[i]))
 			netdev_err(ndev, "DMA mapping error\n");
 
-		writel(priv->rx_mapping[i],
+		moxart_desc_write(priv->rx_mapping[i],
 		       desc + RX_REG_OFFSET_DESC2 + RX_DESC2_ADDRESS_PHYS);
-		writel(priv->rx_buf[i],
+		moxart_desc_write((uintptr_t)priv->rx_buf[i],
 		       desc + RX_REG_OFFSET_DESC2 + RX_DESC2_ADDRESS_VIRT);
 	}
-	writel(RX_DESC1_END, desc + RX_REG_OFFSET_DESC1);
+	moxart_desc_write(RX_DESC1_END, desc + RX_REG_OFFSET_DESC1);
 
 	priv->rx_head = 0;
 
@@ -201,14 +211,14 @@ static int moxart_rx_poll(struct napi_struct *napi, int budget)
 						      napi);
 	struct net_device *ndev = priv->ndev;
 	struct sk_buff *skb;
-	void __iomem *desc;
+	void *desc;
 	unsigned int desc0, len;
 	int rx_head = priv->rx_head;
 	int rx = 0;
 
 	while (rx < budget) {
 		desc = priv->rx_desc_base + (RX_REG_DESC_SIZE * rx_head);
-		desc0 = readl(desc + RX_REG_OFFSET_DESC0);
+		desc0 = moxart_desc_read(desc + RX_REG_OFFSET_DESC0);
 
 		if (desc0 & RX_DESC0_DMA_OWN)
 			break;
@@ -250,7 +260,7 @@ static int moxart_rx_poll(struct napi_struct *napi, int budget)
 			priv->stats.multicast++;
 
 rx_next:
-		writel(RX_DESC0_DMA_OWN, desc + RX_REG_OFFSET_DESC0);
+		moxart_desc_write(RX_DESC0_DMA_OWN, desc + RX_REG_OFFSET_DESC0);
 
 		rx_head = RX_NEXT(rx_head);
 		priv->rx_head = rx_head;
@@ -310,7 +320,7 @@ static irqreturn_t moxart_mac_interrupt(int irq, void *dev_id)
 static int moxart_mac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 {
 	struct moxart_mac_priv_t *priv = netdev_priv(ndev);
-	void __iomem *desc;
+	void *desc;
 	unsigned int len;
 	unsigned int tx_head = priv->tx_head;
 	u32 txdes1;
@@ -319,7 +329,7 @@ static int moxart_mac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	desc = priv->tx_desc_base + (TX_REG_DESC_SIZE * tx_head);
 
 	spin_lock_irq(&priv->txlock);
-	if (readl(desc + TX_REG_OFFSET_DESC0) & TX_DESC0_DMA_OWN) {
+	if (moxart_desc_read(desc + TX_REG_OFFSET_DESC0) & TX_DESC0_DMA_OWN) {
 		net_dbg_ratelimited("no TX space for packet\n");
 		priv->stats.tx_dropped++;
 		goto out_unlock;
@@ -337,9 +347,9 @@ static int moxart_mac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	priv->tx_len[tx_head] = len;
 	priv->tx_skb[tx_head] = skb;
 
-	writel(priv->tx_mapping[tx_head],
+	moxart_desc_write(priv->tx_mapping[tx_head],
 	       desc + TX_REG_OFFSET_DESC2 + TX_DESC2_ADDRESS_PHYS);
-	writel(skb->data,
+	moxart_desc_write((uintptr_t)skb->data,
 	       desc + TX_REG_OFFSET_DESC2 + TX_DESC2_ADDRESS_VIRT);
 
 	if (skb->len < ETH_ZLEN) {
@@ -354,8 +364,8 @@ static int moxart_mac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	txdes1 = TX_DESC1_LTS | TX_DESC1_FTS | (len & TX_DESC1_BUF_SIZE_MASK);
 	if (tx_head == TX_DESC_NUM_MASK)
 		txdes1 |= TX_DESC1_END;
-	writel(txdes1, desc + TX_REG_OFFSET_DESC1);
-	writel(TX_DESC0_DMA_OWN, desc + TX_REG_OFFSET_DESC0);
+	moxart_desc_write(txdes1, desc + TX_REG_OFFSET_DESC1);
+	moxart_desc_write(TX_DESC0_DMA_OWN, desc + TX_REG_OFFSET_DESC0);
 
 	/* start to send packet */
 	writel(0xffffffff, priv->base + REG_TX_POLL_DEMAND);
diff --git a/drivers/net/ethernet/moxa/moxart_ether.h b/drivers/net/ethernet/moxa/moxart_ether.h
index 2be9280d608c..93a9563ac7c6 100644
--- a/drivers/net/ethernet/moxa/moxart_ether.h
+++ b/drivers/net/ethernet/moxa/moxart_ether.h
@@ -300,7 +300,7 @@ struct moxart_mac_priv_t {
 
 	dma_addr_t rx_base;
 	dma_addr_t rx_mapping[RX_DESC_NUM];
-	void __iomem *rx_desc_base;
+	void *rx_desc_base;
 	unsigned char *rx_buf_base;
 	unsigned char *rx_buf[RX_DESC_NUM];
 	unsigned int rx_head;
@@ -308,7 +308,7 @@ struct moxart_mac_priv_t {
 
 	dma_addr_t tx_base;
 	dma_addr_t tx_mapping[TX_DESC_NUM];
-	void __iomem *tx_desc_base;
+	void *tx_desc_base;
 	unsigned char *tx_buf_base;
 	unsigned char *tx_buf[RX_DESC_NUM];
 	unsigned int tx_head;
-- 
2.7.0

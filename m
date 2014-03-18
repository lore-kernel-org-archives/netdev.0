From: Zhangfei Gao <zhangfei.gao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: [PATCH 3/3] net: hisilicon: new hip04 ethernet driver
Date: Tue, 18 Mar 2014 16:40:17 +0800
Message-ID: <1395132017-15928-4-git-send-email-zhangfei.gao@linaro.org>
References: <1395132017-15928-1-git-send-email-zhangfei.gao@linaro.org>
Cc: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Zhangfei Gao <zhangfei.gao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1395132017-15928-1-git-send-email-zhangfei.gao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Support Hisilicon hip04 ethernet driver, including 100M / 1000M controller

Signed-off-by: Zhangfei Gao <zhangfei.gao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
---
 drivers/net/ethernet/hisilicon/Makefile    |    2 +-
 drivers/net/ethernet/hisilicon/hip04_eth.c |  717 ++++++++++++++++++++++++++++
 2 files changed, 718 insertions(+), 1 deletion(-)
 create mode 100644 drivers/net/ethernet/hisilicon/hip04_eth.c

diff --git a/drivers/net/ethernet/hisilicon/Makefile b/drivers/net/ethernet/hisilicon/Makefile
index 1d6eb6e..e6fe7af 100644
--- a/drivers/net/ethernet/hisilicon/Makefile
+++ b/drivers/net/ethernet/hisilicon/Makefile
@@ -2,4 +2,4 @@
 # Makefile for the HISILICON network device drivers.
 #
 
-obj-$(CONFIG_HIP04_ETH) += hip04_mdio.o
+obj-$(CONFIG_HIP04_ETH) += hip04_eth.o hip04_mdio.o
diff --git a/drivers/net/ethernet/hisilicon/hip04_eth.c b/drivers/net/ethernet/hisilicon/hip04_eth.c
new file mode 100644
index 0000000..b12e0df
--- /dev/null
+++ b/drivers/net/ethernet/hisilicon/hip04_eth.c
@@ -0,0 +1,717 @@
+
+/* Copyright (c) 2014 Linaro Ltd.
+ * Copyright (c) 2014 Hisilicon Limited.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include <linux/module.h>
+#include <linux/etherdevice.h>
+#include <linux/platform_device.h>
+#include <linux/interrupt.h>
+#include <linux/of_address.h>
+#include <linux/dmapool.h>
+#include <linux/phy.h>
+#include <linux/of_mdio.h>
+
+#define PPE_CFG_RX_CFF_ADDR		0x100
+#define PPE_CFG_POOL_GRP		0x300
+#define PPE_CFG_RX_BUF_SIZE		0x400
+#define PPE_CFG_RX_FIFO_SIZE		0x500
+#define PPE_CURR_BUF_CNT_REG		0xa200
+
+#define GE_DUPLEX_TYPE			0x8
+#define GE_MAX_FRM_SIZE_REG		0x3c
+#define GE_PORT_MODE			0x40
+#define GE_PORT_EN			0x44
+#define GE_SHORT_RUNTS_THR_REG		0x50
+#define GE_TX_LOCAL_PAGE_REG		0x5c
+#define GE_TRANSMIT_CONTROL_REG		0x60
+#define GE_CF_CRC_STRIP_REG		0x1b0
+#define GE_MODE_CHANGE_EN		0x1b4
+#define GE_RECV_CONTROL_REG		0x1e0
+#define GE_STATION_MAC_ADDRESS		0x210
+#define PPE_CFG_TX_PKT_BD_ADDR		0x420
+#define PPE_CFG_MAX_FRAME_LEN_REG	0x408
+#define PPE_CFG_BUS_CTRL_REG		0x424
+#define PPE_CFG_RX_CTRL_REG		0x428
+#define PPE_CFG_RX_PKT_MODE_REG		0x438
+#define PPE_CFG_QOS_VMID_GEN		0x500
+#define PPE_CFG_RX_PKT_INT		0x538
+#define PPE_INTEN			0x600
+#define PPE_INTSTS			0x608
+#define PPE_RINT			0x604
+#define PPE_CFG_STS_MODE		0x700
+#define PPE_HIS_RX_PKT_CNT		0x804
+
+/* REG_INTERRUPT */
+#define RCV_INT				BIT(10)
+#define RCV_NOBUF			BIT(8)
+#define DEF_INT_MASK			0x41fdf
+
+#define RX_DESC_NUM			64
+#define TX_DESC_NUM			64
+#define TX_NEXT(N)			(((N) + 1) & (TX_DESC_NUM-1))
+#define RX_NEXT(N)			(((N) + 1) & (RX_DESC_NUM-1))
+
+#define GMAC_PPE_RX_PKT_MAX_LEN		379
+#define GMAC_MAX_PKT_LEN		1516
+#define DESC_DEF_CFG			0x14
+#define RX_BUF_SIZE			1600
+#define TX_TIMEOUT			(6 * HZ)
+
+#define DRV_NAME			"hip04-ether"
+
+struct tx_desc {
+	u32 send_addr;
+	u16 send_size;
+	u16 reserved[3];
+	u32 cfg;
+	u32 wb_addr;
+};
+
+struct rx_desc {
+	u16 pkt_len;
+	u16 reserved_16;
+	u32 reserve[8];
+};
+
+struct hip04_priv {
+	void __iomem *base;
+	unsigned int port;
+	unsigned int speed;
+	unsigned int duplex;
+	unsigned int id;
+	unsigned int reg_inten;
+
+	struct napi_struct napi;
+	struct net_device *ndev;
+	struct dma_pool *desc_pool;
+
+	struct sk_buff *tx_skb[TX_DESC_NUM];
+	struct tx_desc *td_ring[TX_DESC_NUM];
+	dma_addr_t td_phys[TX_DESC_NUM];
+	spinlock_t txlock;
+	unsigned int tx_head;
+	unsigned int tx_tail;
+	unsigned int tx_count;
+
+	unsigned char *rx_buf[RX_DESC_NUM];
+	unsigned int rx_head;
+	unsigned int rx_buf_size;
+
+	struct device_node *phy_node;
+	struct phy_device *phy;
+};
+
+static void __iomem *ppebase;
+
+static void hip04_config_port(struct hip04_priv *priv, u32 speed, u32 duplex)
+{
+	u32 val;
+
+	priv->speed = speed;
+	priv->duplex = duplex;
+
+	switch (speed) {
+	case SPEED_1000:
+		val = 8;
+		break;
+	case SPEED_100:
+		if (priv->id)
+			val = 7;
+		else
+			val = 1;
+		break;
+	default:
+		val = 0;
+		break;
+	}
+	writel_relaxed(val, priv->base + GE_PORT_MODE);
+
+	val = (duplex) ? BIT(0) : 0;
+	writel_relaxed(val, priv->base + GE_DUPLEX_TYPE);
+
+	val = BIT(0);
+	writel_relaxed(val, priv->base + GE_MODE_CHANGE_EN);
+}
+
+static void hip04_reset_ppe(struct hip04_priv *priv)
+{
+	u32 val;
+
+	do {
+		val =
+		readl_relaxed(ppebase + priv->port * 4 + PPE_CURR_BUF_CNT_REG);
+		readl_relaxed(ppebase + priv->port * 4 + PPE_CFG_RX_CFF_ADDR);
+	} while (val & 0xfff);
+}
+
+static void hip04_config_fifo(struct hip04_priv *priv)
+{
+	u32 val;
+
+	val = readl_relaxed(priv->base + PPE_CFG_STS_MODE);
+	val |= BIT(12);			/* PPE_HIS_RX_PKT_CNT read clear */
+	writel_relaxed(val, priv->base + PPE_CFG_STS_MODE);
+
+	val = BIT(priv->port);
+	writel_relaxed(val, ppebase + priv->port * 4 + PPE_CFG_POOL_GRP);
+
+	val = priv->port << 8;
+	val |= BIT(14);
+	writel_relaxed(val, priv->base + PPE_CFG_QOS_VMID_GEN);
+
+	val = RX_BUF_SIZE;
+	writel_relaxed(val, ppebase + priv->port * 4 + PPE_CFG_RX_BUF_SIZE);
+
+	val = RX_DESC_NUM << 16;	/* depth */
+	val |= BIT(11);			/* seq: first set first ues */
+	val |= RX_DESC_NUM * priv->id;	/* start_addr */
+	writel_relaxed(val, ppebase + priv->port * 4 + PPE_CFG_RX_FIFO_SIZE);
+
+	/* pkt store format */
+	val = NET_IP_ALIGN << 11;	/* align */
+	writel_relaxed(val, priv->base + PPE_CFG_RX_CTRL_REG);
+
+	/* following cfg required for 1000M */
+	/* pkt mode */
+	val = BIT(18);			/* align */
+	writel_relaxed(val, priv->base + PPE_CFG_RX_PKT_MODE_REG);
+
+	/* set bus ctrl */
+	val = BIT(14);			/* buffer locally release */
+	val |= BIT(0);			/* big endian */
+	writel_relaxed(val, priv->base + PPE_CFG_BUS_CTRL_REG);
+
+	/* set max pkt len, curtail if exceed */
+	val = GMAC_PPE_RX_PKT_MAX_LEN;	/* max buffer len */
+	writel_relaxed(val, priv->base + PPE_CFG_MAX_FRAME_LEN_REG);
+
+	/* set max len of each pkt */
+	val = GMAC_MAX_PKT_LEN;		/* max buffer len */
+	writel_relaxed(val, priv->base + GE_MAX_FRM_SIZE_REG);
+
+	/* set min len of each pkt */
+	val = 31;			/* min buffer len */
+	writel_relaxed(val, priv->base + GE_SHORT_RUNTS_THR_REG);
+
+	/* tx */
+	val = readl_relaxed(priv->base + GE_TRANSMIT_CONTROL_REG);
+	val |= BIT(5);			/* tx auto neg */
+	val |= BIT(6);			/* tx add crc */
+	val |= BIT(7);			/* tx short pad through */
+	writel_relaxed(val, priv->base + GE_TRANSMIT_CONTROL_REG);
+
+	/* rx crc */
+	val = BIT(0);			/* rx strip crc */
+	writel_relaxed(val, priv->base + GE_CF_CRC_STRIP_REG);
+
+	/* rx */
+	val = readl_relaxed(priv->base + GE_RECV_CONTROL_REG);
+	val |= BIT(3);			/* rx strip pad */
+	val |= BIT(4);			/* run pkt en */
+	writel_relaxed(val, priv->base + GE_RECV_CONTROL_REG);
+
+	/* auto neg control */
+	val = BIT(0);
+	writel_relaxed(val, priv->base + GE_TX_LOCAL_PAGE_REG);
+}
+
+static void hip04_mac_enable(struct net_device *ndev, bool enable)
+{
+	struct hip04_priv *priv = netdev_priv(ndev);
+	u32 val;
+
+	if (enable) {
+		/* enable tx & rx */
+		val = readl_relaxed(priv->base + GE_PORT_EN);
+		val |= BIT(1);		/* rx*/
+		val |= BIT(2);		/* tx*/
+		writel_relaxed(val, priv->base + GE_PORT_EN);
+
+		/* enable interrupt */
+		priv->reg_inten = DEF_INT_MASK;
+		writel_relaxed(priv->reg_inten, priv->base + PPE_INTEN);
+
+		/* clear rx int */
+		val = RCV_INT;
+		writel_relaxed(val, priv->base + PPE_RINT);
+
+		/* config recv int*/
+		val = BIT(6);		/* int threshold 1 package */
+		val |= 0x4;		/* recv timeout */
+		writel_relaxed(val, priv->base + PPE_CFG_RX_PKT_INT);
+	} else {
+		/* disable int */
+		priv->reg_inten &= ~(RCV_INT | RCV_NOBUF);
+		writel_relaxed(priv->reg_inten, priv->base + PPE_INTEN);
+
+		/* disable tx & rx */
+		val = readl_relaxed(priv->base + GE_PORT_EN);
+		val &= ~(BIT(1));	/* rx*/
+		val &= ~(BIT(2));	/* tx*/
+		writel_relaxed(val, priv->base + GE_PORT_EN);
+	}
+}
+
+static void hip04_set_xmit_desc(struct hip04_priv *priv, dma_addr_t phys)
+{
+	writel_relaxed(phys, priv->base + PPE_CFG_TX_PKT_BD_ADDR);
+}
+
+static void hip04_set_recv_desc(struct hip04_priv *priv, dma_addr_t phys)
+{
+	writel_relaxed(phys, ppebase + priv->port * 4 + PPE_CFG_RX_CFF_ADDR);
+}
+
+static u32 hip04_recv_cnt(struct hip04_priv *priv)
+{
+	return readl_relaxed(priv->base + PPE_HIS_RX_PKT_CNT);
+}
+
+static void hip04_update_mac_address(struct net_device *ndev)
+{
+	struct hip04_priv *priv = netdev_priv(ndev);
+
+	writel_relaxed(((ndev->dev_addr[0] << 8) | (ndev->dev_addr[1])),
+			priv->base + GE_STATION_MAC_ADDRESS);
+	writel_relaxed(((ndev->dev_addr[2] << 24) | (ndev->dev_addr[3] << 16) |
+			(ndev->dev_addr[4] << 8) | (ndev->dev_addr[5])),
+			priv->base + GE_STATION_MAC_ADDRESS + 4);
+}
+
+static int hip04_set_mac_address(struct net_device *ndev, void *addr)
+{
+	eth_mac_addr(ndev, addr);
+	hip04_update_mac_address(ndev);
+	return 0;
+}
+
+static void endian_change(void *p, int size)
+{
+	unsigned int *to_cover = (unsigned int *)p;
+	int i;
+
+	size = size >> 2;
+	for (i = 0; i < size; i++)
+		*(to_cover+i) = htonl(*(to_cover+i));
+}
+
+static int hip04_rx_poll(struct napi_struct *napi, int budget)
+{
+	struct hip04_priv *priv = container_of(napi,
+			      struct hip04_priv, napi);
+	struct net_device *ndev = priv->ndev;
+	struct sk_buff *skb;
+	struct rx_desc *desc;
+	unsigned char *buf;
+	int rx = 0;
+	unsigned int cnt = hip04_recv_cnt(priv);
+	unsigned int len, tmp[16];
+
+	while (cnt) {
+		buf = priv->rx_buf[priv->rx_head];
+		skb = build_skb(buf, priv->rx_buf_size);
+		if (unlikely(!skb))
+			net_dbg_ratelimited("build_skb failed\n");
+		dma_map_single(&ndev->dev, skb->data,
+			RX_BUF_SIZE, DMA_FROM_DEVICE);
+		memcpy(tmp, skb->data, 64);
+		endian_change((void *)tmp, 64);
+		desc = (struct rx_desc *)tmp;
+		len = desc->pkt_len;
+
+		if (len > RX_BUF_SIZE)
+			len = RX_BUF_SIZE;
+		if (0 == len)
+			break;
+
+		skb_reserve(skb, NET_SKB_PAD + NET_IP_ALIGN);
+		skb_put(skb, len);
+		skb->protocol = eth_type_trans(skb, ndev);
+		napi_gro_receive(&priv->napi, skb);
+
+		buf = netdev_alloc_frag(priv->rx_buf_size);
+		if (!buf)
+			return -ENOMEM;
+		priv->rx_buf[priv->rx_head] = buf;
+		dma_map_single(&ndev->dev, buf, RX_BUF_SIZE, DMA_TO_DEVICE);
+		hip04_set_recv_desc(priv, virt_to_phys(buf));
+
+		priv->rx_head = RX_NEXT(priv->rx_head);
+		if (rx++ >= budget)
+			break;
+
+		if (--cnt == 0)
+			cnt = hip04_recv_cnt(priv);
+	}
+
+	if (rx < budget) {
+		napi_gro_flush(napi, false);
+		__napi_complete(napi);
+	}
+
+	/* enable rx interrupt */
+	priv->reg_inten |= RCV_INT | RCV_NOBUF;
+	writel_relaxed(priv->reg_inten, priv->base + PPE_INTEN);
+
+	return rx;
+}
+
+static irqreturn_t hip04_mac_interrupt(int irq, void *dev_id)
+{
+	struct net_device *ndev = (struct net_device *) dev_id;
+	struct hip04_priv *priv = netdev_priv(ndev);
+	u32 ists = readl_relaxed(priv->base + PPE_INTSTS);
+	u32 val = DEF_INT_MASK;
+
+	writel_relaxed(val, priv->base + PPE_RINT);
+
+	if ((ists & RCV_INT) || (ists & RCV_NOBUF)) {
+		if (napi_schedule_prep(&priv->napi)) {
+			/* disable rx interrupt */
+			priv->reg_inten &= ~(RCV_INT | RCV_NOBUF);
+			writel_relaxed(priv->reg_inten, priv->base + PPE_INTEN);
+			__napi_schedule(&priv->napi);
+		}
+	}
+
+	return IRQ_HANDLED;
+}
+
+static void hip04_tx_reclaim(struct net_device *ndev, bool force)
+{
+	struct hip04_priv *priv = netdev_priv(ndev);
+	unsigned tx_head = priv->tx_head;
+	unsigned tx_tail = priv->tx_tail;
+	struct tx_desc *desc = priv->td_ring[priv->tx_tail];
+
+	spin_lock_irq(&priv->txlock);
+	while (tx_tail != tx_head) {
+		if (desc->send_addr != 0) {
+			if (force)
+				desc->send_addr = 0;
+			else
+				break;
+		}
+		dev_kfree_skb_irq(priv->tx_skb[tx_tail]);
+		priv->tx_skb[tx_tail] = NULL;
+		tx_tail = TX_NEXT(tx_tail);
+		priv->tx_count--;
+	}
+	priv->tx_tail = tx_tail;
+	spin_unlock_irq(&priv->txlock);
+}
+
+static int hip04_mac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
+{
+	struct hip04_priv *priv = netdev_priv(ndev);
+	struct tx_desc *desc = priv->td_ring[priv->tx_head];
+	unsigned int tx_head = priv->tx_head;
+	int ret;
+
+	hip04_tx_reclaim(ndev, false);
+
+	spin_lock_irq(&priv->txlock);
+	if (priv->tx_count++ >= TX_DESC_NUM) {
+		net_dbg_ratelimited("no TX space for packet\n");
+		netif_stop_queue(ndev);
+		ret = NETDEV_TX_BUSY;
+		goto out_unlock;
+	}
+
+	priv->tx_skb[tx_head] = skb;
+	dma_map_single(&ndev->dev, skb->data, skb->len, DMA_TO_DEVICE);
+	memset((void *)desc, 0, sizeof(*desc));
+	desc->send_addr = (unsigned int)virt_to_phys(skb->data);
+	desc->send_size = skb->len;
+	desc->cfg = DESC_DEF_CFG;
+	desc->wb_addr = priv->td_phys[tx_head];
+	endian_change(desc, 64);
+	skb_tx_timestamp(skb);
+	hip04_set_xmit_desc(priv, priv->td_phys[tx_head]);
+
+	priv->tx_head = TX_NEXT(tx_head);
+	ret = NETDEV_TX_OK;
+out_unlock:
+	spin_unlock_irq(&priv->txlock);
+
+	return ret;
+}
+
+static void hip04_adjust_link(struct net_device *ndev)
+{
+	struct hip04_priv *priv = netdev_priv(ndev);
+	struct phy_device *phy = priv->phy;
+
+	if ((priv->speed != phy->speed) || (priv->duplex != phy->duplex)) {
+		hip04_config_port(priv, phy->speed, phy->duplex);
+		phy_print_status(phy);
+	}
+}
+
+static int hip04_mac_open(struct net_device *ndev)
+{
+	struct hip04_priv *priv = netdev_priv(ndev);
+	int i;
+
+	hip04_reset_ppe(priv);
+	for (i = 0; i < RX_DESC_NUM; i++) {
+		dma_map_single(&ndev->dev, priv->rx_buf[i],
+				RX_BUF_SIZE, DMA_TO_DEVICE);
+		hip04_set_recv_desc(priv, virt_to_phys(priv->rx_buf[i]));
+	}
+	priv->rx_head = 0;
+	priv->tx_head = 0;
+	priv->tx_tail = 0;
+	priv->tx_count = 0;
+
+	if (priv->phy_node) {
+		priv->phy = of_phy_connect(ndev, priv->phy_node,
+			&hip04_adjust_link, 0, PHY_INTERFACE_MODE_GMII);
+		if (!priv->phy)
+			return -ENODEV;
+		phy_start(priv->phy);
+	}
+
+	netif_start_queue(ndev);
+	hip04_mac_enable(ndev, true);
+	napi_enable(&priv->napi);
+	return 0;
+}
+
+static int hip04_mac_stop(struct net_device *ndev)
+{
+	struct hip04_priv *priv = netdev_priv(ndev);
+
+	if (priv->phy)
+		phy_disconnect(priv->phy);
+	priv->phy = NULL;
+
+	napi_disable(&priv->napi);
+	netif_stop_queue(ndev);
+	hip04_mac_enable(ndev, false);
+	hip04_tx_reclaim(ndev, true);
+	hip04_reset_ppe(priv);
+	return 0;
+}
+
+static void hip04_timeout(struct net_device *ndev)
+{
+	netif_wake_queue(ndev);
+	return;
+}
+
+static struct net_device_ops hip04_netdev_ops = {
+	.ndo_open		= hip04_mac_open,
+	.ndo_stop		= hip04_mac_stop,
+	.ndo_start_xmit		= hip04_mac_start_xmit,
+	.ndo_set_mac_address	= hip04_set_mac_address,
+	.ndo_tx_timeout         = hip04_timeout,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_change_mtu		= eth_change_mtu,
+};
+
+static int hip04_alloc_ring(struct net_device *ndev, struct device *d)
+{
+	struct hip04_priv *priv = netdev_priv(ndev);
+	int i;
+
+	priv->rx_buf_size = RX_BUF_SIZE +
+			    SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
+
+	priv->desc_pool = dma_pool_create(DRV_NAME, d, sizeof(struct tx_desc),
+				SKB_DATA_ALIGN(sizeof(struct tx_desc)),	0);
+	if (!priv->desc_pool)
+		return -ENOMEM;
+
+	for (i = 0; i < TX_DESC_NUM; i++) {
+		priv->td_ring[i] = dma_pool_alloc(priv->desc_pool,
+					GFP_ATOMIC, &priv->td_phys[i]);
+		if (!priv->td_ring[i])
+			return -ENOMEM;
+	}
+
+	for (i = 0; i < RX_DESC_NUM; i++) {
+		priv->rx_buf[i] = netdev_alloc_frag(priv->rx_buf_size);
+		if (!priv->rx_buf[i])
+			return -ENOMEM;
+	}
+
+	return 0;
+}
+
+static void hip04_free_ring(struct net_device *ndev)
+{
+	struct hip04_priv *priv = netdev_priv(ndev);
+	int i;
+
+	for (i = 0; i < RX_DESC_NUM; i++)
+		if (priv->rx_buf[i])
+			put_page(virt_to_head_page(priv->rx_buf[i]));
+
+	for (i = 0; i < TX_DESC_NUM; i++) {
+		if (priv->tx_skb[i])
+			dev_kfree_skb_any(priv->tx_skb[i]);
+		if ((priv->desc_pool) && (priv->td_ring[i]))
+			dma_pool_free(priv->desc_pool, priv->td_ring[i],
+					priv->td_phys[i]);
+	}
+
+	if (priv->desc_pool)
+		dma_pool_destroy(priv->desc_pool);
+}
+
+static int hip04_mac_probe(struct platform_device *pdev)
+{
+	struct device *d = &pdev->dev;
+	struct device_node *node = d->of_node;
+	struct net_device *ndev;
+	struct hip04_priv *priv;
+	struct resource *res;
+	unsigned int irq, val;
+	int ret;
+
+	ndev = alloc_etherdev(sizeof(struct hip04_priv));
+	if (!ndev)
+		return -ENOMEM;
+
+	priv = netdev_priv(ndev);
+	priv->ndev = ndev;
+	platform_set_drvdata(pdev, ndev);
+	spin_lock_init(&priv->txlock);
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	if (!res) {
+		ret = -EINVAL;
+		goto init_fail;
+	}
+	ndev->base_addr = res->start;
+	priv->base = devm_ioremap_resource(d, res);
+	ret = IS_ERR(priv->base);
+	if (ret) {
+		dev_err(d, "devm_ioremap_resource failed\n");
+		goto init_fail;
+	}
+
+	if (!ppebase) {
+		struct device_node *n;
+
+		n = of_find_compatible_node(NULL, NULL, "hisilicon,hip04-ppebase");
+		if (!n) {
+			ret = -EINVAL;
+			netdev_err(ndev, "not find hisilicon,ppebase\n");
+			goto init_fail;
+		}
+		ppebase = of_iomap(n, 0);
+	}
+
+	ret = of_property_read_u32(node, "port", &val);
+	if (ret) {
+		dev_warn(d, "not find port info\n");
+		goto init_fail;
+	}
+	priv->port = val & 0x1f;
+
+	ret = of_property_read_u32(node, "speed", &val);
+	if (ret) {
+		dev_warn(d, "not find speed info\n");
+		priv->speed = SPEED_1000;
+	}
+
+	if (SPEED_100 == val)
+		priv->speed = SPEED_100;
+	else
+		priv->speed = SPEED_1000;
+	priv->duplex = DUPLEX_FULL;
+
+	ret = of_property_read_u32(node, "id", &priv->id);
+	if (ret) {
+		dev_warn(d, "not find id info\n");
+		goto init_fail;
+	}
+	irq = platform_get_irq(pdev, 0);
+	if (irq <= 0) {
+		ret = -EINVAL;
+		goto init_fail;
+	}
+	ether_setup(ndev);
+	ndev->netdev_ops = &hip04_netdev_ops;
+	ndev->watchdog_timeo = TX_TIMEOUT;
+	ndev->priv_flags |= IFF_UNICAST_FLT;
+	ndev->irq = irq;
+	netif_napi_add(ndev, &priv->napi, hip04_rx_poll, RX_DESC_NUM);
+	SET_NETDEV_DEV(ndev, &pdev->dev);
+
+	hip04_reset_ppe(priv);
+	hip04_config_port(priv, priv->speed, priv->duplex);
+	hip04_config_fifo(priv);
+	random_ether_addr(ndev->dev_addr);
+	hip04_update_mac_address(ndev);
+
+	ret = hip04_alloc_ring(ndev, d);
+	if (ret) {
+		netdev_err(ndev, "alloc ring fail\n");
+		goto alloc_fail;
+	}
+
+	ret = devm_request_irq(d, irq, hip04_mac_interrupt,
+					0, pdev->name, ndev);
+	if (ret) {
+		netdev_err(ndev, "devm_request_irq failed\n");
+		goto alloc_fail;
+	}
+
+	priv->phy_node = of_parse_phandle(node, "phy-handle", 0);
+
+	ret = register_netdev(ndev);
+	if (ret) {
+		free_netdev(ndev);
+		goto alloc_fail;
+	}
+
+	return 0;
+alloc_fail:
+	hip04_free_ring(ndev);
+init_fail:
+	of_node_put(priv->phy_node);
+	free_netdev(ndev);
+	return ret;
+}
+
+static int hip04_remove(struct platform_device *pdev)
+{
+	struct net_device *ndev = platform_get_drvdata(pdev);
+	struct hip04_priv *priv = netdev_priv(ndev);
+
+	hip04_free_ring(ndev);
+	unregister_netdev(ndev);
+	free_irq(ndev->irq, ndev);
+	of_node_put(priv->phy_node);
+	free_netdev(ndev);
+
+	return 0;
+}
+
+static const struct of_device_id hip04_mac_match[] = {
+	{ .compatible = "hisilicon,hip04-mac" },
+	{ }
+};
+
+static struct platform_driver hip04_mac_driver = {
+	.probe	= hip04_mac_probe,
+	.remove	= hip04_remove,
+	.driver	= {
+		.name		= DRV_NAME,
+		.owner		= THIS_MODULE,
+		.of_match_table	= hip04_mac_match,
+	},
+};
+module_platform_driver(hip04_mac_driver);
+
+MODULE_DESCRIPTION("HISILICON P04 Ethernet driver");
+MODULE_LICENSE("GPL v2");
+MODULE_ALIAS("platform:hip04-ether");
-- 
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

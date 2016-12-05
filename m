From: Dongpo Li <lidongpo@hisilicon.com>
Subject: [PATCH v2 2/4] net: hix5hd2_gmac: add tx scatter-gather feature
Date: Mon, 5 Dec 2016 21:27:59 +0800
Message-ID: <1480944481-118803-3-git-send-email-lidongpo@hisilicon.com>
References: <1480944481-118803-1-git-send-email-lidongpo@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <xuejiancheng@hisilicon.com>, <benjamin.chenhao@hisilicon.com>,
        <caizhiyong@hisilicon.com>, <netdev@vger.kernel.org>,
        <devicetree@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        Dongpo Li <lidongpo@hisilicon.com>
To: <robh+dt@kernel.org>, <mark.rutland@arm.com>,
        <mturquette@baylibre.com>, <sboyd@codeaurora.org>,
        <linux@armlinux.org.uk>, <zhangfei.gao@linaro.org>,
        <yisen.zhuang@huawei.com>, <salil.mehta@huawei.com>,
        <davem@davemloft.net>, <arnd@arndb.de>, <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:61789 "EHLO
        szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751340AbcLENfI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 08:35:08 -0500
In-Reply-To: <1480944481-118803-1-git-send-email-lidongpo@hisilicon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"hisi-gemac-v2" adds the SG/TXCSUM/TSO/UFO features.
This patch only adds the SG(scatter-gather) driver for transmitting,
the drivers of other features will be submitted later.

Signed-off-by: Dongpo Li <lidongpo@hisilicon.com>
---
 drivers/net/ethernet/hisilicon/hix5hd2_gmac.c | 198 ++++++++++++++++++++++++--
 1 file changed, 187 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hix5hd2_gmac.c b/drivers/net/ethernet/hisilicon/hix5hd2_gmac.c
index 27cb2e6..18af55b 100644
--- a/drivers/net/ethernet/hisilicon/hix5hd2_gmac.c
+++ b/drivers/net/ethernet/hisilicon/hix5hd2_gmac.c
@@ -11,6 +11,7 @@
 #include <linux/interrupt.h>
 #include <linux/etherdevice.h>
 #include <linux/platform_device.h>
+#include <linux/of_device.h>
 #include <linux/of_net.h>
 #include <linux/of_mdio.h>
 #include <linux/clk.h>
@@ -183,6 +184,8 @@
 #define DESC_DATA_LEN_OFF		16
 #define DESC_BUFF_LEN_OFF		0
 #define DESC_DATA_MASK			0x7ff
+#define DESC_SG				BIT(30)
+#define DESC_FRAGS_NUM_OFF		11
 
 /* DMA descriptor ring helpers */
 #define dma_ring_incr(n, s)		(((n) + 1) & ((s) - 1))
@@ -192,6 +195,7 @@
 #define HW_CAP_TSO			BIT(0)
 #define GEMAC_V1			0
 #define GEMAC_V2			(GEMAC_V1 | HW_CAP_TSO)
+#define HAS_CAP_TSO(hw_cap)		((hw_cap) & HW_CAP_TSO)
 
 struct hix5hd2_desc {
 	__le32 buff_addr;
@@ -205,6 +209,27 @@ struct hix5hd2_desc_sw {
 	unsigned int	size;
 };
 
+struct hix5hd2_sg_desc_ring {
+	struct sg_desc *desc;
+	dma_addr_t phys_addr;
+};
+
+struct frags_info {
+	__le32 addr;
+	__le32 size;
+};
+
+/* hardware supported max skb frags num */
+#define SG_MAX_SKB_FRAGS	17
+struct sg_desc {
+	__le32 total_len;
+	__le32 resvd0;
+	__le32 linear_addr;
+	__le32 linear_len;
+	/* reserve one more frags for memory alignment */
+	struct frags_info frags[SG_MAX_SKB_FRAGS + 1];
+};
+
 #define QUEUE_NUMS	4
 struct hix5hd2_priv {
 	struct hix5hd2_desc_sw pool[QUEUE_NUMS];
@@ -212,6 +237,7 @@ struct hix5hd2_priv {
 #define rx_bq		pool[1]
 #define tx_bq		pool[2]
 #define tx_rq		pool[3]
+	struct hix5hd2_sg_desc_ring tx_ring;
 
 	void __iomem *base;
 	void __iomem *ctrl_base;
@@ -225,6 +251,7 @@ struct hix5hd2_priv {
 	struct device_node *phy_node;
 	phy_interface_t	phy_mode;
 
+	unsigned long hw_cap;
 	unsigned int speed;
 	unsigned int duplex;
 
@@ -515,6 +542,27 @@ static int hix5hd2_rx(struct net_device *dev, int limit)
 	return num;
 }
 
+static void hix5hd2_clean_sg_desc(struct hix5hd2_priv *priv,
+				  struct sk_buff *skb, u32 pos)
+{
+	struct sg_desc *desc;
+	dma_addr_t addr;
+	u32 len;
+	int i;
+
+	desc = priv->tx_ring.desc + pos;
+
+	addr = le32_to_cpu(desc->linear_addr);
+	len = le32_to_cpu(desc->linear_len);
+	dma_unmap_single(priv->dev, addr, len, DMA_TO_DEVICE);
+
+	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
+		addr = le32_to_cpu(desc->frags[i].addr);
+		len = le32_to_cpu(desc->frags[i].size);
+		dma_unmap_page(priv->dev, addr, len, DMA_TO_DEVICE);
+	}
+}
+
 static void hix5hd2_xmit_reclaim(struct net_device *dev)
 {
 	struct sk_buff *skb;
@@ -542,8 +590,15 @@ static void hix5hd2_xmit_reclaim(struct net_device *dev)
 		pkts_compl++;
 		bytes_compl += skb->len;
 		desc = priv->tx_rq.desc + pos;
-		addr = le32_to_cpu(desc->buff_addr);
-		dma_unmap_single(priv->dev, addr, skb->len, DMA_TO_DEVICE);
+
+		if (skb_shinfo(skb)->nr_frags) {
+			hix5hd2_clean_sg_desc(priv, skb, pos);
+		} else {
+			addr = le32_to_cpu(desc->buff_addr);
+			dma_unmap_single(priv->dev, addr, skb->len,
+					 DMA_TO_DEVICE);
+		}
+
 		priv->tx_skb[pos] = NULL;
 		dev_consume_skb_any(skb);
 		pos = dma_ring_incr(pos, TX_DESC_NUM);
@@ -604,12 +659,66 @@ static irqreturn_t hix5hd2_interrupt(int irq, void *dev_id)
 	return IRQ_HANDLED;
 }
 
+static u32 hix5hd2_get_desc_cmd(struct sk_buff *skb, unsigned long hw_cap)
+{
+	u32 cmd = 0;
+
+	if (HAS_CAP_TSO(hw_cap)) {
+		if (skb_shinfo(skb)->nr_frags)
+			cmd |= DESC_SG;
+		cmd |= skb_shinfo(skb)->nr_frags << DESC_FRAGS_NUM_OFF;
+	} else {
+		cmd |= DESC_FL_FULL |
+			((skb->len & DESC_DATA_MASK) << DESC_BUFF_LEN_OFF);
+	}
+
+	cmd |= (skb->len & DESC_DATA_MASK) << DESC_DATA_LEN_OFF;
+	cmd |= DESC_VLD_BUSY;
+
+	return cmd;
+}
+
+static int hix5hd2_fill_sg_desc(struct hix5hd2_priv *priv,
+				struct sk_buff *skb, u32 pos)
+{
+	struct sg_desc *desc;
+	dma_addr_t addr;
+	int ret;
+	int i;
+
+	desc = priv->tx_ring.desc + pos;
+
+	desc->total_len = cpu_to_le32(skb->len);
+	addr = dma_map_single(priv->dev, skb->data, skb_headlen(skb),
+			      DMA_TO_DEVICE);
+	if (unlikely(dma_mapping_error(priv->dev, addr)))
+		return -EINVAL;
+	desc->linear_addr = cpu_to_le32(addr);
+	desc->linear_len = cpu_to_le32(skb_headlen(skb));
+
+	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
+		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+		int len = frag->size;
+
+		addr = skb_frag_dma_map(priv->dev, frag, 0, len, DMA_TO_DEVICE);
+		ret = dma_mapping_error(priv->dev, addr);
+		if (unlikely(ret))
+			return -EINVAL;
+		desc->frags[i].addr = cpu_to_le32(addr);
+		desc->frags[i].size = cpu_to_le32(len);
+	}
+
+	return 0;
+}
+
 static int hix5hd2_net_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct hix5hd2_priv *priv = netdev_priv(dev);
 	struct hix5hd2_desc *desc;
 	dma_addr_t addr;
 	u32 pos;
+	u32 cmd;
+	int ret;
 
 	/* software write pointer */
 	pos = dma_cnt(readl_relaxed(priv->base + TX_BQ_WR_ADDR));
@@ -620,18 +729,31 @@ static int hix5hd2_net_xmit(struct sk_buff *skb, struct net_device *dev)
 		return NETDEV_TX_BUSY;
 	}
 
-	addr = dma_map_single(priv->dev, skb->data, skb->len, DMA_TO_DEVICE);
-	if (dma_mapping_error(priv->dev, addr)) {
-		dev_kfree_skb_any(skb);
-		return NETDEV_TX_OK;
-	}
-
 	desc = priv->tx_bq.desc + pos;
+
+	cmd = hix5hd2_get_desc_cmd(skb, priv->hw_cap);
+	desc->cmd = cpu_to_le32(cmd);
+
+	if (skb_shinfo(skb)->nr_frags) {
+		ret = hix5hd2_fill_sg_desc(priv, skb, pos);
+		if (unlikely(ret)) {
+			dev_kfree_skb_any(skb);
+			dev->stats.tx_dropped++;
+			return NETDEV_TX_OK;
+		}
+		addr = priv->tx_ring.phys_addr + pos * sizeof(struct sg_desc);
+	} else {
+		addr = dma_map_single(priv->dev, skb->data, skb->len,
+				      DMA_TO_DEVICE);
+		if (unlikely(dma_mapping_error(priv->dev, addr))) {
+			dev_kfree_skb_any(skb);
+			dev->stats.tx_dropped++;
+			return NETDEV_TX_OK;
+		}
+	}
 	desc->buff_addr = cpu_to_le32(addr);
+
 	priv->tx_skb[pos] = skb;
-	desc->cmd = cpu_to_le32(DESC_VLD_BUSY | DESC_FL_FULL |
-				(skb->len & DESC_DATA_MASK) << DESC_DATA_LEN_OFF |
-				(skb->len & DESC_DATA_MASK) << DESC_BUFF_LEN_OFF);
 
 	/* ensure desc updated */
 	wmb();
@@ -866,10 +988,40 @@ static int hix5hd2_init_hw_desc_queue(struct hix5hd2_priv *priv)
 	return -ENOMEM;
 }
 
+static int hix5hd2_init_sg_desc_queue(struct hix5hd2_priv *priv)
+{
+	struct sg_desc *desc;
+	dma_addr_t phys_addr;
+
+	desc = (struct sg_desc *)dma_alloc_coherent(priv->dev,
+				TX_DESC_NUM * sizeof(struct sg_desc),
+				&phys_addr, GFP_KERNEL);
+	if (!desc)
+		return -ENOMEM;
+
+	priv->tx_ring.desc = desc;
+	priv->tx_ring.phys_addr = phys_addr;
+
+	return 0;
+}
+
+static void hix5hd2_destroy_sg_desc_queue(struct hix5hd2_priv *priv)
+{
+	if (priv->tx_ring.desc) {
+		dma_free_coherent(priv->dev,
+				  TX_DESC_NUM * sizeof(struct sg_desc),
+				  priv->tx_ring.desc, priv->tx_ring.phys_addr);
+		priv->tx_ring.desc = NULL;
+	}
+}
+
+static const struct of_device_id hix5hd2_of_match[];
+
 static int hix5hd2_dev_probe(struct platform_device *pdev)
 {
 	struct device *dev = &pdev->dev;
 	struct device_node *node = dev->of_node;
+	const struct of_device_id *of_id = NULL;
 	struct net_device *ndev;
 	struct hix5hd2_priv *priv;
 	struct resource *res;
@@ -887,6 +1039,13 @@ static int hix5hd2_dev_probe(struct platform_device *pdev)
 	priv->dev = dev;
 	priv->netdev = ndev;
 
+	of_id = of_match_device(hix5hd2_of_match, dev);
+	if (!of_id) {
+		ret = -EINVAL;
+		goto out_free_netdev;
+	}
+	priv->hw_cap = (unsigned long)of_id->data;
+
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	priv->base = devm_ioremap_resource(dev, res);
 	if (IS_ERR(priv->base)) {
@@ -976,11 +1135,24 @@ static int hix5hd2_dev_probe(struct platform_device *pdev)
 	ndev->ethtool_ops = &hix5hd2_ethtools_ops;
 	SET_NETDEV_DEV(ndev, dev);
 
+	if (HAS_CAP_TSO(priv->hw_cap))
+		ndev->hw_features |= NETIF_F_SG;
+
+	ndev->features |= ndev->hw_features | NETIF_F_HIGHDMA;
+	ndev->vlan_features |= ndev->features;
+
 	ret = hix5hd2_init_hw_desc_queue(priv);
 	if (ret)
 		goto out_phy_node;
 
 	netif_napi_add(ndev, &priv->napi, hix5hd2_poll, NAPI_POLL_WEIGHT);
+
+	if (HAS_CAP_TSO(priv->hw_cap)) {
+		ret = hix5hd2_init_sg_desc_queue(priv);
+		if (ret)
+			goto out_destroy_queue;
+	}
+
 	ret = register_netdev(priv->netdev);
 	if (ret) {
 		netdev_err(ndev, "register_netdev failed!");
@@ -992,6 +1164,8 @@ static int hix5hd2_dev_probe(struct platform_device *pdev)
 	return ret;
 
 out_destroy_queue:
+	if (HAS_CAP_TSO(priv->hw_cap))
+		hix5hd2_destroy_sg_desc_queue(priv);
 	netif_napi_del(&priv->napi);
 	hix5hd2_destroy_hw_desc_queue(priv);
 out_phy_node:
@@ -1016,6 +1190,8 @@ static int hix5hd2_dev_remove(struct platform_device *pdev)
 	mdiobus_unregister(priv->bus);
 	mdiobus_free(priv->bus);
 
+	if (HAS_CAP_TSO(priv->hw_cap))
+		hix5hd2_destroy_sg_desc_queue(priv);
 	hix5hd2_destroy_hw_desc_queue(priv);
 	of_node_put(priv->phy_node);
 	cancel_work_sync(&priv->tx_timeout_task);
-- 
2.8.2

From: Jonas Jensen <jonas.jensen@gmail.com>
Subject: [PATCH v5] net: Add MOXA ART SoCs ethernet driver
Date: Thu,  8 Aug 2013 13:34:54 +0200
Message-ID: <1375961694-5375-1-git-send-email-jonas.jensen@gmail.com>
References: <1375349968-16059-1-git-send-email-jonas.jensen@gmail.com>
Cc: davem@davemloft.net, linux-doc@vger.kernel.org,
	devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, arm@kernel.org, florian@openwrt.org,
	joe@perches.com, mark.rutland@arm.com,
	Jonas Jensen <jonas.jensen@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1375349968-16059-1-git-send-email-jonas.jensen@gmail.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The MOXA UC-711X hardware(s) has an ethernet controller that seem
to be developed internally. The IC used is "RTL8201CP".

Since there is no public documentation, this driver is mostly the
one published by MOXA that has been heavily cleaned up / ported
from linux 2.6.9.

Signed-off-by: Jonas Jensen <jonas.jensen@gmail.com>
---

Notes:
    The flash mapped in v4 is not part of the MAC controller,
    leaving it to user-space per Florian and Mark's comments.
    
    Changes since v4:
    
    1. don't rely on structs for register offsets
    2. don't map flash storage register
    3. remove code related to flash storage
    4. reformat header file, use single line comments
    5. move devm_request_irq() earlier in probe path
    6. save return values in probe fail path
    7. check/handle irq_of_parse_and_map() return value
    
    device tree bindings document:
    8. remove references to flash storage register
    
    Applies to next-20130808

 .../devicetree/bindings/net/moxa,moxart-mac.txt    |  21 +
 drivers/net/ethernet/Kconfig                       |   1 +
 drivers/net/ethernet/Makefile                      |   1 +
 drivers/net/ethernet/moxa/Kconfig                  |  30 ++
 drivers/net/ethernet/moxa/Makefile                 |   5 +
 drivers/net/ethernet/moxa/moxart_ether.c           | 559 +++++++++++++++++++++
 drivers/net/ethernet/moxa/moxart_ether.h           | 330 ++++++++++++
 7 files changed, 947 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/moxa,moxart-mac.txt
 create mode 100644 drivers/net/ethernet/moxa/Kconfig
 create mode 100644 drivers/net/ethernet/moxa/Makefile
 create mode 100644 drivers/net/ethernet/moxa/moxart_ether.c
 create mode 100644 drivers/net/ethernet/moxa/moxart_ether.h

diff --git a/Documentation/devicetree/bindings/net/moxa,moxart-mac.txt b/Documentation/devicetree/bindings/net/moxa,moxart-mac.txt
new file mode 100644
index 0000000..583418b
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/moxa,moxart-mac.txt
@@ -0,0 +1,21 @@
+MOXA ART Ethernet Controller
+
+Required properties:
+
+- compatible : Must be "moxa,moxart-mac"
+- reg : Should contain register location and length
+- interrupts : Should contain the mac interrupt number
+
+Example:
+
+	mac0: mac@90900000 {
+		compatible = "moxa,moxart-mac";
+		reg =	<0x90900000 0x100>;
+		interrupts = <25 0>;
+	};
+
+	mac1: mac@92000000 {
+		compatible = "moxa,moxart-mac";
+		reg =	<0x92000000 0x100>;
+		interrupts = <27 0>;
+	};
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 2037080..506b024 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -90,6 +90,7 @@ source "drivers/net/ethernet/marvell/Kconfig"
 source "drivers/net/ethernet/mellanox/Kconfig"
 source "drivers/net/ethernet/micrel/Kconfig"
 source "drivers/net/ethernet/microchip/Kconfig"
+source "drivers/net/ethernet/moxa/Kconfig"
 source "drivers/net/ethernet/myricom/Kconfig"
 
 config FEALNX
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 390bd0b..c0b8789 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -42,6 +42,7 @@ obj-$(CONFIG_NET_VENDOR_MARVELL) += marvell/
 obj-$(CONFIG_NET_VENDOR_MELLANOX) += mellanox/
 obj-$(CONFIG_NET_VENDOR_MICREL) += micrel/
 obj-$(CONFIG_NET_VENDOR_MICROCHIP) += microchip/
+obj-$(CONFIG_NET_VENDOR_MOXART) += moxa/
 obj-$(CONFIG_NET_VENDOR_MYRI) += myricom/
 obj-$(CONFIG_FEALNX) += fealnx.o
 obj-$(CONFIG_NET_VENDOR_NATSEMI) += natsemi/
diff --git a/drivers/net/ethernet/moxa/Kconfig b/drivers/net/ethernet/moxa/Kconfig
new file mode 100644
index 0000000..1731e05
--- /dev/null
+++ b/drivers/net/ethernet/moxa/Kconfig
@@ -0,0 +1,30 @@
+#
+# MOXART device configuration
+#
+
+config NET_VENDOR_MOXART
+	bool "MOXA ART devices"
+	default y
+	depends on (ARM && ARCH_MOXART)
+	---help---
+	  If you have a network (Ethernet) card belonging to this class, say Y
+	  and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about MOXA ART devices. If you say Y, you will be asked
+	  for your specific card in the following questions.
+
+if NET_VENDOR_MOXART
+
+config ARM_MOXART_ETHER
+	tristate "MOXART Ethernet support"
+	depends on ARM && ARCH_MOXART
+	select NET_CORE
+	---help---
+	  If you wish to compile a kernel for a hardware with MOXA ART SoC and
+	  want to use the internal ethernet then you should answer Y to this.
+
+
+endif # NET_VENDOR_MOXART
diff --git a/drivers/net/ethernet/moxa/Makefile b/drivers/net/ethernet/moxa/Makefile
new file mode 100644
index 0000000..aa3c73e9
--- /dev/null
+++ b/drivers/net/ethernet/moxa/Makefile
@@ -0,0 +1,5 @@
+#
+# Makefile for the MOXART network device drivers.
+#
+
+obj-$(CONFIG_ARM_MOXART_ETHER) += moxart_ether.o
diff --git a/drivers/net/ethernet/moxa/moxart_ether.c b/drivers/net/ethernet/moxa/moxart_ether.c
new file mode 100644
index 0000000..e1aa0f0
--- /dev/null
+++ b/drivers/net/ethernet/moxa/moxart_ether.c
@@ -0,0 +1,559 @@
+/* MOXA ART Ethernet (RTL8201CP) driver.
+ *
+ * Copyright (C) 2013 Jonas Jensen
+ *
+ * Jonas Jensen <jonas.jensen@gmail.com>
+ *
+ * Based on code from
+ * Moxa Technology Co., Ltd. <www.moxa.com>
+ *
+ * This file is licensed under the terms of the GNU General Public
+ * License version 2.  This program is licensed "as is" without any
+ * warranty of any kind, whether express or implied.
+ */
+
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/skbuff.h>
+#include <linux/dma-mapping.h>
+#include <linux/ethtool.h>
+#include <linux/platform_device.h>
+#include <linux/interrupt.h>
+#include <linux/irq.h>
+#include <linux/of_address.h>
+#include <linux/of_irq.h>
+#include <linux/crc32.h>
+#include <linux/crc32c.h>
+#include <linux/dma-mapping.h>
+
+#include "moxart_ether.h"
+
+static inline void moxart_emac_write(struct net_device *ndev,
+				     unsigned int reg, unsigned long value)
+{
+	struct moxart_mac_priv_t *priv = netdev_priv(ndev);
+
+	writel(value, priv->base + reg);
+}
+
+static void moxart_update_mac_address(struct net_device *ndev)
+{
+	moxart_emac_write(ndev, REG_MAC_MS_ADDRESS,
+			  ((ndev->dev_addr[0] << 8) | (ndev->dev_addr[1])));
+	moxart_emac_write(ndev, REG_MAC_MS_ADDRESS + 4,
+			  ((ndev->dev_addr[2] << 24) |
+			   (ndev->dev_addr[3] << 16) |
+			   (ndev->dev_addr[4] << 8) |
+			   (ndev->dev_addr[5])));
+}
+
+static int moxart_set_mac_address(struct net_device *ndev, void *addr)
+{
+	struct sockaddr *address = addr;
+
+	if (!is_valid_ether_addr(address->sa_data))
+		return -EADDRNOTAVAIL;
+
+	memcpy(ndev->dev_addr, address->sa_data, ndev->addr_len);
+	moxart_update_mac_address(ndev);
+
+	return 0;
+}
+
+static void moxart_mac_free_memory(struct net_device *ndev)
+{
+	struct moxart_mac_priv_t *priv = netdev_priv(ndev);
+	int i;
+
+	for (i = 0; i < RX_DESC_NUM; i++)
+		dma_unmap_single(&ndev->dev, priv->rx_mapping[i],
+				 priv->rx_buf_size, DMA_FROM_DEVICE);
+
+	if (priv->tx_desc_base)
+		dma_free_coherent(NULL, TX_REG_DESC_SIZE * TX_DESC_NUM,
+				  priv->tx_desc_base, priv->tx_base);
+
+	if (priv->rx_desc_base)
+		dma_free_coherent(NULL, RX_REG_DESC_SIZE * RX_DESC_NUM,
+				  priv->rx_desc_base, priv->rx_base);
+
+	kfree(priv->tx_buf_base);
+	kfree(priv->rx_buf_base);
+}
+
+static void moxart_mac_reset(struct net_device *ndev)
+{
+	struct moxart_mac_priv_t *priv = netdev_priv(ndev);
+
+	writel(SW_RST, priv->base + REG_MAC_CTRL);
+	while (readl(priv->base + REG_MAC_CTRL) & SW_RST)
+		mdelay(10);
+
+	writel(0, priv->base + REG_INTERRUPT_MASK);
+
+	priv->reg_maccr = RX_BROADPKT | FULLDUP | CRC_APD | RX_FTL;
+}
+
+static void moxart_mac_enable(struct net_device *ndev)
+{
+	struct moxart_mac_priv_t *priv = netdev_priv(ndev);
+
+	writel(0x00001010, priv->base + REG_INT_TIMER_CTRL);
+	writel(0x00000001, priv->base + REG_APOLL_TIMER_CTRL);
+	writel(0x00000390, priv->base + REG_DMA_BLEN_CTRL);
+
+	priv->reg_imr |= (RPKT_FINISH_M | XPKT_FINISH_M);
+	writel(priv->reg_imr, priv->base + REG_INTERRUPT_MASK);
+
+	priv->reg_maccr |= (RCV_EN | XMT_EN | RDMA_EN | XDMA_EN);
+	writel(priv->reg_maccr, priv->base + REG_MAC_CTRL);
+}
+
+static void moxart_mac_setup_desc_ring(struct net_device *ndev)
+{
+	struct moxart_mac_priv_t *priv = netdev_priv(ndev);
+	void __iomem *desc;
+	int i;
+
+	for (i = 0; i < TX_DESC_NUM; i++) {
+		desc = priv->tx_desc_base + i * TX_REG_DESC_SIZE;
+		memset(desc, 0, TX_REG_DESC_SIZE);
+
+		priv->tx_buf[i] = priv->tx_buf_base + priv->tx_buf_size * i;
+	}
+	writel(TX_DESC1_END, desc + TX_REG_OFFSET_DESC1);
+
+	priv->tx_head = 0;
+	priv->tx_tail = 0;
+
+	for (i = 0; i < RX_DESC_NUM; i++) {
+		desc = priv->rx_desc_base + i * RX_REG_DESC_SIZE;
+		memset(desc, 0, RX_REG_DESC_SIZE);
+		writel(RX_DESC0_DMA_OWN, desc + RX_REG_OFFSET_DESC0);
+		writel(RX_BUF_SIZE & RX_DESC1_BUF_SIZE_MASK,
+		       desc + RX_REG_OFFSET_DESC1);
+
+		priv->rx_buf[i] = priv->rx_buf_base + priv->rx_buf_size * i;
+		priv->rx_mapping[i] = dma_map_single(&ndev->dev,
+						     priv->rx_buf[i],
+						     priv->rx_buf_size,
+						     DMA_FROM_DEVICE);
+		if (dma_mapping_error(&ndev->dev, priv->rx_mapping[i]))
+			netdev_err(ndev, "DMA mapping error\n");
+
+		writel(priv->rx_mapping[i],
+		       desc + RX_REG_OFFSET_DESC2 + RX_DESC2_ADDRESS_PHYS);
+		writel(priv->rx_buf[i],
+		       desc + RX_REG_OFFSET_DESC2 + RX_DESC2_ADDRESS_VIRT);
+	}
+	writel(RX_DESC1_END, desc + RX_REG_OFFSET_DESC1);
+
+	priv->rx_head = 0;
+
+	/* reset the MAC controler TX/RX desciptor base address */
+	writel(priv->tx_base, priv->base + REG_TXR_BASE_ADDRESS);
+	writel(priv->rx_base, priv->base + REG_RXR_BASE_ADDRESS);
+}
+
+static int moxart_mac_open(struct net_device *ndev)
+{
+	struct moxart_mac_priv_t *priv = netdev_priv(ndev);
+
+	if (!is_valid_ether_addr(ndev->dev_addr))
+		return -EADDRNOTAVAIL;
+
+	napi_enable(&priv->napi);
+
+	moxart_mac_reset(ndev);
+	moxart_update_mac_address(ndev);
+	moxart_mac_setup_desc_ring(ndev);
+	moxart_mac_enable(ndev);
+	netif_start_queue(ndev);
+
+	netdev_dbg(ndev, "%s: IMR=0x%x, MACCR=0x%x\n",
+		   __func__, readl(priv->base + REG_INTERRUPT_MASK),
+		   readl(priv->base + REG_MAC_CTRL));
+
+	return 0;
+}
+
+static int moxart_mac_stop(struct net_device *ndev)
+{
+	struct moxart_mac_priv_t *priv = netdev_priv(ndev);
+
+	napi_disable(&priv->napi);
+
+	netif_stop_queue(ndev);
+
+	/* disable all interrupts */
+	writel(0, priv->base + REG_INTERRUPT_MASK);
+
+	/* disable all functions */
+	writel(0, priv->base + REG_MAC_CTRL);
+
+	return 0;
+}
+
+static int moxart_rx_poll(struct napi_struct *napi, int budget)
+{
+	struct moxart_mac_priv_t *priv = container_of(napi,
+						      struct moxart_mac_priv_t,
+						      napi);
+	struct net_device *ndev = priv->ndev;
+	struct sk_buff *skb;
+	void __iomem *desc;
+	unsigned int desc0, len;
+	int rx_head = priv->rx_head;
+	int rx = 0;
+
+	while (1) {
+		desc = priv->rx_desc_base + (RX_REG_DESC_SIZE * rx_head);
+		desc0 = readl(desc + RX_REG_OFFSET_DESC0);
+
+		if (desc0 & RX_DESC0_DMA_OWN)
+			break;
+
+		if (desc0 & (RX_DESC0_ERR | RX_DESC0_CRC_ERR | RX_DESC0_FTL |
+			     RX_DESC0_RUNT | RX_DESC0_ODD_NB)) {
+			net_dbg_ratelimited("packet error\n");
+			priv->stats.rx_dropped++;
+			priv->stats.rx_errors++;
+			continue;
+		}
+
+		len = desc0 & RX_DESC0_FRAME_LEN_MASK;
+
+		if (len > RX_BUF_SIZE)
+			len = RX_BUF_SIZE;
+
+		skb = build_skb(priv->rx_buf[rx_head], priv->rx_buf_size);
+		if (unlikely(!skb)) {
+			net_dbg_ratelimited("build_skb failed\n");
+			priv->stats.rx_dropped++;
+			priv->stats.rx_errors++;
+		}
+
+		skb_put(skb, len);
+		skb->protocol = eth_type_trans(skb, ndev);
+		napi_gro_receive(&priv->napi, skb);
+		rx++;
+
+		ndev->last_rx = jiffies;
+		priv->stats.rx_packets++;
+		priv->stats.rx_bytes += len;
+		if (desc0 & RX_DESC0_MULTICAST)
+			priv->stats.multicast++;
+
+		writel(RX_DESC0_DMA_OWN, desc + RX_REG_OFFSET_DESC0);
+
+		rx_head = RX_NEXT(rx_head);
+		priv->rx_head = rx_head;
+
+		if (rx >= budget)
+			break;
+	}
+
+	if (rx < budget) {
+		napi_gro_flush(napi, false);
+		__napi_complete(napi);
+	}
+
+	priv->reg_imr |= RPKT_FINISH_M;
+	writel(priv->reg_imr, priv->base + REG_INTERRUPT_MASK);
+
+	return rx;
+}
+
+static void moxart_tx_finished(struct net_device *ndev)
+{
+	struct moxart_mac_priv_t *priv = netdev_priv(ndev);
+	unsigned tx_head = priv->tx_head;
+	unsigned tx_tail = priv->tx_tail;
+
+	while (tx_tail != tx_head) {
+		dma_unmap_single(&ndev->dev, priv->tx_mapping[tx_tail],
+				 priv->tx_len[tx_tail], DMA_TO_DEVICE);
+
+		priv->stats.tx_packets++;
+		priv->stats.tx_bytes += priv->tx_skb[tx_tail]->len;
+
+		dev_kfree_skb_irq(priv->tx_skb[tx_tail]);
+		priv->tx_skb[tx_tail] = NULL;
+
+		tx_tail = TX_NEXT(tx_tail);
+	}
+	priv->tx_tail = tx_tail;
+}
+
+static irqreturn_t moxart_mac_interrupt(int irq, void *dev_id)
+{
+	struct net_device *ndev = (struct net_device *) dev_id;
+	struct moxart_mac_priv_t *priv = netdev_priv(ndev);
+	unsigned int ists = readl(priv->base + REG_INTERRUPT_STATUS);
+
+	if (ists & XPKT_OK_INT_STS)
+		moxart_tx_finished(ndev);
+
+	if (ists & RPKT_FINISH) {
+		if (napi_schedule_prep(&priv->napi)) {
+			priv->reg_imr &= ~RPKT_FINISH_M;
+			writel(priv->reg_imr, priv->base + REG_INTERRUPT_MASK);
+			__napi_schedule(&priv->napi);
+		}
+	}
+
+	return IRQ_HANDLED;
+}
+
+static int moxart_mac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
+{
+	struct moxart_mac_priv_t *priv = netdev_priv(ndev);
+	void __iomem *desc;
+	unsigned int len;
+	unsigned int tx_head = priv->tx_head;
+	u32 txdes1;
+
+	desc = priv->tx_desc_base + (TX_REG_DESC_SIZE * tx_head);
+
+	spin_lock_irq(&priv->txlock);
+	if (readl(desc + TX_REG_OFFSET_DESC0) & TX_DESC0_DMA_OWN) {
+		net_dbg_ratelimited("no TX space for packet\n");
+		priv->stats.tx_dropped++;
+		return NETDEV_TX_BUSY;
+	}
+
+	len = skb->len > TX_BUF_SIZE ? TX_BUF_SIZE : skb->len;
+
+	priv->tx_mapping[tx_head] = dma_map_single(&ndev->dev, skb->data,
+						   len, DMA_TO_DEVICE);
+	if (dma_mapping_error(&ndev->dev, priv->tx_mapping[tx_head])) {
+		netdev_err(ndev, "DMA mapping error\n");
+		return NETDEV_TX_BUSY;
+	}
+
+	priv->tx_len[tx_head] = len;
+	priv->tx_skb[tx_head] = skb;
+
+	writel(priv->tx_mapping[tx_head],
+	       desc + TX_REG_OFFSET_DESC2 + TX_DESC2_ADDRESS_PHYS);
+	writel(skb->data,
+	       desc + TX_REG_OFFSET_DESC2 + TX_DESC2_ADDRESS_VIRT);
+
+	if (skb->len < ETH_ZLEN) {
+		memset(&skb->data[skb->len],
+		       0, ETH_ZLEN - skb->len);
+		len = ETH_ZLEN;
+	}
+
+	txdes1 = readl(desc + TX_REG_OFFSET_DESC1);
+	txdes1 |= TX_DESC1_LTS | TX_DESC1_FTS;
+	txdes1 &= ~(TX_DESC1_FIFO_COMPLETE | TX_DESC1_INTR_COMPLETE);
+	txdes1 |= (len & TX_DESC1_BUF_SIZE_MASK);
+	writel(txdes1, desc + TX_REG_OFFSET_DESC1);
+	writel(TX_DESC0_DMA_OWN, desc + TX_REG_OFFSET_DESC0);
+
+	/* start to send packet */
+	writel(0xffffffff, priv->base + REG_TX_POLL_DEMAND);
+
+	priv->tx_head = TX_NEXT(tx_head);
+
+	ndev->trans_start = jiffies;
+
+	spin_unlock_irq(&priv->txlock);
+
+	return NETDEV_TX_OK;
+}
+
+static struct net_device_stats *moxart_mac_get_stats(struct net_device *ndev)
+{
+	struct moxart_mac_priv_t *priv = netdev_priv(ndev);
+
+	return &priv->stats;
+}
+
+static void moxart_mac_setmulticast(struct net_device *ndev)
+{
+	struct moxart_mac_priv_t *priv = netdev_priv(ndev);
+	struct netdev_hw_addr *ha;
+	int crc_val;
+
+	netdev_for_each_mc_addr(ha, ndev) {
+		crc_val = crc32_le(~0, ha->addr, ETH_ALEN);
+		crc_val = (crc_val >> 26) & 0x3f;
+		if (crc_val >= 32) {
+			writel(readl(priv->base + REG_MCAST_HASH_TABLE1) |
+			       (1UL << (crc_val - 32)),
+			       priv->base + REG_MCAST_HASH_TABLE1);
+		} else {
+			writel(readl(priv->base + REG_MCAST_HASH_TABLE0) |
+			       (1UL << crc_val),
+			       priv->base + REG_MCAST_HASH_TABLE0);
+		}
+	}
+}
+
+static void moxart_mac_set_rx_mode(struct net_device *ndev)
+{
+	struct moxart_mac_priv_t *priv = netdev_priv(ndev);
+
+	spin_lock_irq(&priv->txlock);
+
+	(ndev->flags & IFF_PROMISC) ? (priv->reg_maccr |= RCV_ALL) :
+				      (priv->reg_maccr &= ~RCV_ALL);
+
+	(ndev->flags & IFF_ALLMULTI) ? (priv->reg_maccr |= RX_MULTIPKT) :
+				       (priv->reg_maccr &= ~RX_MULTIPKT);
+
+	if ((ndev->flags & IFF_MULTICAST) && netdev_mc_count(ndev)) {
+		priv->reg_maccr |= HT_MULTI_EN;
+		moxart_mac_setmulticast(ndev);
+	} else {
+		priv->reg_maccr &= ~HT_MULTI_EN;
+	}
+
+	writel(priv->reg_maccr, priv->base + REG_MAC_CTRL);
+
+	spin_unlock_irq(&priv->txlock);
+}
+
+static struct net_device_ops moxart_netdev_ops = {
+	.ndo_open		= moxart_mac_open,
+	.ndo_stop		= moxart_mac_stop,
+	.ndo_start_xmit		= moxart_mac_start_xmit,
+	.ndo_get_stats		= moxart_mac_get_stats,
+	.ndo_set_rx_mode	= moxart_mac_set_rx_mode,
+	.ndo_set_mac_address	= moxart_set_mac_address,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_change_mtu		= eth_change_mtu,
+};
+
+static int moxart_mac_probe(struct platform_device *pdev)
+{
+	struct device *p_dev = &pdev->dev;
+	struct device_node *node = p_dev->of_node;
+	struct net_device *ndev;
+	struct moxart_mac_priv_t *priv;
+	struct resource *res;
+	unsigned int irq;
+	int ret;
+
+	ndev = alloc_etherdev(sizeof(struct moxart_mac_priv_t));
+	if (!ndev)
+		return -ENOMEM;
+
+	irq = irq_of_parse_and_map(node, 0);
+	if (irq <= 0) {
+		netdev_err(ndev, "irq_of_parse_and_map failed\n");
+		return -EINVAL;
+	}
+
+	priv = netdev_priv(ndev);
+	priv->ndev = ndev;
+
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	ndev->base_addr = res->start;
+	priv->base = devm_ioremap_resource(p_dev, res);
+	ret = IS_ERR(priv->base);
+	if (ret) {
+		dev_err(p_dev, "devm_ioremap_resource failed\n");
+		goto init_fail;
+	}
+
+	spin_lock_init(&priv->txlock);
+
+	priv->tx_buf_size = TX_BUF_SIZE;
+	priv->rx_buf_size = RX_BUF_SIZE +
+			    SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
+
+	priv->tx_desc_base = dma_alloc_coherent(NULL, TX_REG_DESC_SIZE *
+						TX_DESC_NUM, &priv->tx_base,
+						GFP_DMA | GFP_KERNEL);
+	if (priv->tx_desc_base == NULL)
+		goto init_fail;
+
+	priv->rx_desc_base = dma_alloc_coherent(NULL, RX_REG_DESC_SIZE *
+						RX_DESC_NUM, &priv->rx_base,
+						GFP_DMA | GFP_KERNEL);
+	if (priv->rx_desc_base == NULL)
+		goto init_fail;
+
+	priv->tx_buf_base = kmalloc(priv->tx_buf_size * TX_DESC_NUM,
+				    GFP_ATOMIC);
+	if (!priv->tx_buf_base)
+		goto init_fail;
+
+	priv->rx_buf_base = kmalloc(priv->rx_buf_size * RX_DESC_NUM,
+				    GFP_ATOMIC);
+	if (!priv->rx_buf_base)
+		goto init_fail;
+
+	platform_set_drvdata(pdev, ndev);
+
+	ret = devm_request_irq(p_dev, irq, moxart_mac_interrupt, 0,
+			       pdev->name, ndev);
+	if (ret) {
+		netdev_err(ndev, "devm_request_irq failed\n");
+		goto init_fail;
+	}
+
+	ether_setup(ndev);
+	ndev->netdev_ops = &moxart_netdev_ops;
+	netif_napi_add(ndev, &priv->napi, moxart_rx_poll, RX_DESC_NUM);
+	ndev->priv_flags |= IFF_UNICAST_FLT;
+	ndev->irq = irq;
+
+	SET_NETDEV_DEV(ndev, &pdev->dev);
+
+	ret = register_netdev(ndev);
+	if (ret) {
+		free_netdev(ndev);
+		goto init_fail;
+	}
+
+	netdev_dbg(ndev, "%s: IRQ=%d address=%pM\n",
+		   __func__, ndev->irq, ndev->dev_addr);
+
+	return 0;
+
+init_fail:
+	netdev_err(ndev, "init failed\n");
+	moxart_mac_free_memory(ndev);
+
+	return ret;
+}
+
+static int moxart_remove(struct platform_device *pdev)
+{
+	struct net_device *ndev = platform_get_drvdata(pdev);
+
+	unregister_netdev(ndev);
+	free_irq(ndev->irq, ndev);
+	moxart_mac_free_memory(ndev);
+	platform_set_drvdata(pdev, NULL);
+	free_netdev(ndev);
+
+	return 0;
+}
+
+static const struct of_device_id moxart_mac_match[] = {
+	{ .compatible = "moxa,moxart-mac" },
+	{ }
+};
+
+struct __initdata platform_driver moxart_mac_driver = {
+	.probe	= moxart_mac_probe,
+	.remove	= moxart_remove,
+	.driver	= {
+		.name		= "moxart-ethernet",
+		.owner		= THIS_MODULE,
+		.of_match_table	= moxart_mac_match,
+	},
+};
+module_platform_driver(moxart_mac_driver);
+
+MODULE_DESCRIPTION("MOXART RTL8201CP Ethernet driver");
+MODULE_LICENSE("GPL v2");
+MODULE_AUTHOR("Jonas Jensen <jonas.jensen@gmail.com>");
+
diff --git a/drivers/net/ethernet/moxa/moxart_ether.h b/drivers/net/ethernet/moxa/moxart_ether.h
new file mode 100644
index 0000000..2be9280
--- /dev/null
+++ b/drivers/net/ethernet/moxa/moxart_ether.h
@@ -0,0 +1,330 @@
+/* MOXA ART Ethernet (RTL8201CP) driver.
+ *
+ * Copyright (C) 2013 Jonas Jensen
+ *
+ * Jonas Jensen <jonas.jensen@gmail.com>
+ *
+ * Based on code from
+ * Moxa Technology Co., Ltd. <www.moxa.com>
+ *
+ * This file is licensed under the terms of the GNU General Public
+ * License version 2.  This program is licensed "as is" without any
+ * warranty of any kind, whether express or implied.
+ */
+
+#ifndef _MOXART_ETHERNET_H
+#define _MOXART_ETHERNET_H
+
+#define TX_REG_OFFSET_DESC0	0
+#define TX_REG_OFFSET_DESC1	4
+#define TX_REG_OFFSET_DESC2	8
+#define TX_REG_DESC_SIZE	16
+
+#define RX_REG_OFFSET_DESC0	0
+#define RX_REG_OFFSET_DESC1	4
+#define RX_REG_OFFSET_DESC2	8
+#define RX_REG_DESC_SIZE	16
+
+#define TX_DESC0_PKT_LATE_COL	0x1		/* abort, late collision */
+#define TX_DESC0_RX_PKT_EXS_COL	0x2		/* abort, >16 collisions */
+#define TX_DESC0_DMA_OWN	0x80000000	/* owned by controller */
+#define TX_DESC1_BUF_SIZE_MASK	0x7ff
+#define TX_DESC1_LTS		0x8000000	/* last TX packet */
+#define TX_DESC1_FTS		0x10000000	/* first TX packet */
+#define TX_DESC1_FIFO_COMPLETE	0x20000000
+#define TX_DESC1_INTR_COMPLETE	0x40000000
+#define TX_DESC1_END		0x80000000
+#define TX_DESC2_ADDRESS_PHYS	0
+#define TX_DESC2_ADDRESS_VIRT	4
+
+#define RX_DESC0_FRAME_LEN	0
+#define RX_DESC0_FRAME_LEN_MASK	0x7FF
+#define RX_DESC0_MULTICAST	0x10000
+#define RX_DESC0_BROADCAST	0x20000
+#define RX_DESC0_ERR		0x40000
+#define RX_DESC0_CRC_ERR	0x80000
+#define RX_DESC0_FTL		0x100000
+#define RX_DESC0_RUNT		0x200000	/* packet less than 64 bytes */
+#define RX_DESC0_ODD_NB		0x400000	/* receive odd nibbles */
+#define RX_DESC0_LRS		0x10000000	/* last receive segment */
+#define RX_DESC0_FRS		0x20000000	/* first receive segment */
+#define RX_DESC0_DMA_OWN	0x80000000
+#define RX_DESC1_BUF_SIZE_MASK	0x7FF
+#define RX_DESC1_END		0x80000000
+#define RX_DESC2_ADDRESS_PHYS	0
+#define RX_DESC2_ADDRESS_VIRT	4
+
+#define TX_DESC_NUM		64
+#define TX_DESC_NUM_MASK	(TX_DESC_NUM-1)
+#define TX_NEXT(N)		(((N) + 1) & (TX_DESC_NUM_MASK))
+#define TX_BUF_SIZE		1600
+#define TX_BUF_SIZE_MAX		(TX_DESC1_BUF_SIZE_MASK+1)
+
+#define RX_DESC_NUM		64
+#define RX_DESC_NUM_MASK	(RX_DESC_NUM-1)
+#define RX_NEXT(N)		(((N) + 1) & (RX_DESC_NUM_MASK))
+#define RX_BUF_SIZE		1600
+#define RX_BUF_SIZE_MAX		(RX_DESC1_BUF_SIZE_MASK+1)
+
+#define REG_INTERRUPT_STATUS	0
+#define REG_INTERRUPT_MASK	4
+#define REG_MAC_MS_ADDRESS	8
+#define REG_MAC_LS_ADDRESS	12
+#define REG_MCAST_HASH_TABLE0	16
+#define REG_MCAST_HASH_TABLE1	20
+#define REG_TX_POLL_DEMAND	24
+#define REG_RX_POLL_DEMAND	28
+#define REG_TXR_BASE_ADDRESS	32
+#define REG_RXR_BASE_ADDRESS	36
+#define REG_INT_TIMER_CTRL	40
+#define REG_APOLL_TIMER_CTRL	44
+#define REG_DMA_BLEN_CTRL	48
+#define REG_RESERVED1		52
+#define REG_MAC_CTRL		136
+#define REG_MAC_STATUS		140
+#define REG_PHY_CTRL		144
+#define REG_PHY_WRITE_DATA	148
+#define REG_FLOW_CTRL		152
+#define REG_BACK_PRESSURE	156
+#define REG_RESERVED2		160
+#define REG_TEST_SEED		196
+#define REG_DMA_FIFO_STATE	200
+#define REG_TEST_MODE		204
+#define REG_RESERVED3		208
+#define REG_TX_COL_COUNTER	212
+#define REG_RPF_AEP_COUNTER	216
+#define REG_XM_PG_COUNTER	220
+#define REG_RUNT_TLC_COUNTER	224
+#define REG_CRC_FTL_COUNTER	228
+#define REG_RLC_RCC_COUNTER	232
+#define REG_BROC_COUNTER	236
+#define REG_MULCA_COUNTER	240
+#define REG_RP_COUNTER		244
+#define REG_XP_COUNTER		248
+
+#define REG_PHY_CTRL_OFFSET	0x0
+#define REG_PHY_STATUS		0x1
+#define REG_PHY_ID1		0x2
+#define REG_PHY_ID2		0x3
+#define REG_PHY_ANA		0x4
+#define REG_PHY_ANLPAR		0x5
+#define REG_PHY_ANE		0x6
+#define REG_PHY_ECTRL1		0x10
+#define REG_PHY_QPDS		0x11
+#define REG_PHY_10BOP		0x12
+#define REG_PHY_ECTRL2		0x13
+#define REG_PHY_FTMAC100_WRITE	0x8000000
+#define REG_PHY_FTMAC100_READ	0x4000000
+
+/* REG_INTERRUPT_STATUS */
+#define RPKT_FINISH		BIT(0)	/* DMA data received */
+#define NORXBUF			BIT(1)	/* receive buffer unavailable */
+#define XPKT_FINISH		BIT(2)	/* DMA moved data to TX FIFO */
+#define NOTXBUF			BIT(3)	/* transmit buffer unavailable */
+#define XPKT_OK_INT_STS		BIT(4)	/* transmit to ethernet success */
+#define XPKT_LOST_INT_STS	BIT(5)	/* transmit ethernet lost (collision) */
+#define RPKT_SAV		BIT(6)	/* FIFO receive success */
+#define RPKT_LOST_INT_STS	BIT(7)	/* FIFO full, receive failed */
+#define AHB_ERR			BIT(8)	/* AHB error */
+#define PHYSTS_CHG		BIT(9)	/* PHY link status change */
+
+/* REG_INTERRUPT_MASK */
+#define RPKT_FINISH_M		BIT(0)
+#define NORXBUF_M		BIT(1)
+#define XPKT_FINISH_M		BIT(2)
+#define NOTXBUF_M		BIT(3)
+#define XPKT_OK_M		BIT(4)
+#define XPKT_LOST_M		BIT(5)
+#define RPKT_SAV_M		BIT(6)
+#define RPKT_LOST_M		BIT(7)
+#define AHB_ERR_M		BIT(8)
+#define PHYSTS_CHG_M		BIT(9)
+
+/* REG_MAC_MS_ADDRESS */
+#define MAC_MADR_MASK		0xffff	/* 2 MSB MAC address */
+
+/* REG_INT_TIMER_CTRL */
+#define TXINT_TIME_SEL		BIT(15)	/* TX cycle time period */
+#define TXINT_THR_MASK		0x7000
+#define TXINT_CNT_MASK		0xf00
+#define RXINT_TIME_SEL		BIT(7)	/* RX cycle time period */
+#define RXINT_THR_MASK		0x70
+#define RXINT_CNT_MASK		0xF
+
+/* REG_APOLL_TIMER_CTRL */
+#define TXPOLL_TIME_SEL		BIT(12)	/* TX poll time period */
+#define TXPOLL_CNT_MASK		0xf00
+#define TXPOLL_CNT_SHIFT_BIT	8
+#define RXPOLL_TIME_SEL		BIT(4)	/* RX poll time period */
+#define RXPOLL_CNT_MASK		0xF
+#define RXPOLL_CNT_SHIFT_BIT	0
+
+/* REG_DMA_BLEN_CTRL */
+#define RX_THR_EN		BIT(9)	/* RX FIFO threshold arbitration */
+#define RXFIFO_HTHR_MASK	0x1c0
+#define RXFIFO_LTHR_MASK	0x38
+#define INCR16_EN		BIT(2)	/* AHB bus INCR16 burst command */
+#define INCR8_EN		BIT(1)	/* AHB bus INCR8 burst command */
+#define INCR4_EN		BIT(0)	/* AHB bus INCR4 burst command */
+
+/* REG_MAC_CTRL */
+#define RX_BROADPKT		BIT(17)	/* receive broadcast packets */
+#define RX_MULTIPKT		BIT(16)	/* receive all multicast packets */
+#define FULLDUP			BIT(15)	/* full duplex */
+#define CRC_APD			BIT(14)	/* append CRC to transmitted packet */
+#define RCV_ALL			BIT(12)	/* ignore incoming packet destination */
+#define RX_FTL			BIT(11)	/* accept packets larger than 1518 B */
+#define RX_RUNT			BIT(10)	/* accept packets smaller than 64 B */
+#define HT_MULTI_EN		BIT(9)	/* accept on hash and mcast pass */
+#define RCV_EN			BIT(8)	/* receiver enable */
+#define ENRX_IN_HALFTX		BIT(6)	/* enable receive in half duplex mode */
+#define XMT_EN			BIT(5)	/* transmit enable */
+#define CRC_DIS			BIT(4)	/* disable CRC check when receiving */
+#define LOOP_EN			BIT(3)	/* internal loop-back */
+#define SW_RST			BIT(2)	/* software reset, last 64 AHB clocks */
+#define RDMA_EN			BIT(1)	/* enable receive DMA chan */
+#define XDMA_EN			BIT(0)	/* enable transmit DMA chan */
+
+/* REG_MAC_STATUS */
+#define COL_EXCEED		BIT(11)	/* more than 16 collisions */
+#define LATE_COL		BIT(10)	/* transmit late collision detected */
+#define XPKT_LOST		BIT(9)	/* transmit to ethernet lost */
+#define XPKT_OK			BIT(8)	/* transmit to ethernet success */
+#define RUNT_MAC_STS		BIT(7)	/* receive runt detected */
+#define FTL_MAC_STS		BIT(6)	/* receive frame too long detected */
+#define CRC_ERR_MAC_STS		BIT(5)
+#define RPKT_LOST		BIT(4)	/* RX FIFO full, receive failed */
+#define RPKT_SAVE		BIT(3)	/* RX FIFO receive success */
+#define COL			BIT(2)	/* collision, incoming packet dropped */
+#define MCPU_BROADCAST		BIT(1)
+#define MCPU_MULTICAST		BIT(0)
+
+/* REG_PHY_CTRL */
+#define MIIWR			BIT(27)	/* init write sequence (auto cleared)*/
+#define MIIRD			BIT(26)
+#define REGAD_MASK		0x3e00000
+#define PHYAD_MASK		0x1f0000
+#define MIIRDATA_MASK		0xffff
+
+/* REG_PHY_WRITE_DATA */
+#define MIIWDATA_MASK		0xffff
+
+/* REG_FLOW_CTRL */
+#define PAUSE_TIME_MASK		0xffff0000
+#define FC_HIGH_MASK		0xf000
+#define FC_LOW_MASK		0xf00
+#define RX_PAUSE		BIT(4)	/* receive pause frame */
+#define TX_PAUSED		BIT(3)	/* transmit pause due to receive */
+#define FCTHR_EN		BIT(2)	/* enable threshold mode. */
+#define TX_PAUSE		BIT(1)	/* transmit pause frame */
+#define FC_EN			BIT(0)	/* flow control mode enable */
+
+/* REG_BACK_PRESSURE */
+#define BACKP_LOW_MASK		0xf00
+#define BACKP_JAM_LEN_MASK	0xf0
+#define BACKP_MODE		BIT(1)	/* address mode */
+#define BACKP_ENABLE		BIT(0)
+
+/* REG_TEST_SEED */
+#define TEST_SEED_MASK		0x3fff
+
+/* REG_DMA_FIFO_STATE */
+#define TX_DMA_REQUEST		BIT(31)
+#define RX_DMA_REQUEST		BIT(30)
+#define TX_DMA_GRANT		BIT(29)
+#define RX_DMA_GRANT		BIT(28)
+#define TX_FIFO_EMPTY		BIT(27)
+#define RX_FIFO_EMPTY		BIT(26)
+#define TX_DMA2_SM_MASK		0x7000
+#define TX_DMA1_SM_MASK		0xf00
+#define RX_DMA2_SM_MASK		0x70
+#define RX_DMA1_SM_MASK		0xF
+
+/* REG_TEST_MODE */
+#define SINGLE_PKT		BIT(26)	/* single packet mode */
+#define PTIMER_TEST		BIT(25)	/* automatic polling timer test mode */
+#define ITIMER_TEST		BIT(24)	/* interrupt timer test mode */
+#define TEST_SEED_SELECT	BIT(22)
+#define SEED_SELECT		BIT(21)
+#define TEST_MODE		BIT(20)
+#define TEST_TIME_MASK		0xffc00
+#define TEST_EXCEL_MASK		0x3e0
+
+/* REG_TX_COL_COUNTER */
+#define TX_MCOL_MASK		0xffff0000
+#define TX_MCOL_SHIFT_BIT	16
+#define TX_SCOL_MASK		0xffff
+#define TX_SCOL_SHIFT_BIT	0
+
+/* REG_RPF_AEP_COUNTER */
+#define RPF_MASK		0xffff0000
+#define RPF_SHIFT_BIT		16
+#define AEP_MASK		0xffff
+#define AEP_SHIFT_BIT		0
+
+/* REG_XM_PG_COUNTER */
+#define XM_MASK			0xffff0000
+#define XM_SHIFT_BIT		16
+#define PG_MASK			0xffff
+#define PG_SHIFT_BIT		0
+
+/* REG_RUNT_TLC_COUNTER */
+#define RUNT_CNT_MASK		0xffff0000
+#define RUNT_CNT_SHIFT_BIT	16
+#define TLCC_MASK		0xffff
+#define TLCC_SHIFT_BIT		0
+
+/* REG_CRC_FTL_COUNTER */
+#define CRCER_CNT_MASK		0xffff0000
+#define CRCER_CNT_SHIFT_BIT	16
+#define FTL_CNT_MASK		0xffff
+#define FTL_CNT_SHIFT_BIT	0
+
+/* REG_RLC_RCC_COUNTER */
+#define RLC_MASK		0xffff0000
+#define RLC_SHIFT_BIT		16
+#define RCC_MASK		0xffff
+#define RCC_SHIFT_BIT		0
+
+/* REG_PHY_STATUS */
+#define AN_COMPLETE		0x20
+#define LINK_STATUS		0x4
+
+struct moxart_mac_priv_t {
+	void __iomem *base;
+	struct net_device_stats stats;
+	unsigned int reg_maccr;
+	unsigned int reg_imr;
+	struct napi_struct napi;
+	struct net_device *ndev;
+
+	dma_addr_t rx_base;
+	dma_addr_t rx_mapping[RX_DESC_NUM];
+	void __iomem *rx_desc_base;
+	unsigned char *rx_buf_base;
+	unsigned char *rx_buf[RX_DESC_NUM];
+	unsigned int rx_head;
+	unsigned int rx_buf_size;
+
+	dma_addr_t tx_base;
+	dma_addr_t tx_mapping[TX_DESC_NUM];
+	void __iomem *tx_desc_base;
+	unsigned char *tx_buf_base;
+	unsigned char *tx_buf[RX_DESC_NUM];
+	unsigned int tx_head;
+	unsigned int tx_buf_size;
+
+	spinlock_t txlock;
+	unsigned int tx_len[TX_DESC_NUM];
+	struct sk_buff *tx_skb[TX_DESC_NUM];
+	unsigned int tx_tail;
+};
+
+#if TX_BUF_SIZE >= TX_BUF_SIZE_MAX
+#error MOXA ART Ethernet device driver TX buffer is too large!
+#endif
+#if RX_BUF_SIZE >= RX_BUF_SIZE_MAX
+#error MOXA ART Ethernet device driver RX buffer is too large!
+#endif
+
+#endif
-- 
1.8.2.1


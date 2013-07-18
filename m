From: Jonas Jensen <jonas.jensen@gmail.com>
Subject: [PATCH] net: Add MOXA ART SoCs ethernet driver
Date: Thu, 18 Jul 2013 11:46:46 +0200
Message-ID: <1374140806-12485-1-git-send-email-jonas.jensen@gmail.com>
Cc: devicetree-discuss@lists.ozlabs.org, linux-doc@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	arm@kernel.org, Jonas Jensen <jonas.jensen@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-doc-owner@vger.kernel.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The MOXA UC-711X hardware(s) has an ethernet controller that seem to be
developed internally. The IC used is "RTL8201CP".

Since there is no public documentation, this driver is mostly the one
published by MOXA that has been heavily cleaned up / ported from linux 2.6.9.

Signed-off-by: Jonas Jensen <jonas.jensen@gmail.com>
---

Notes:
    Applies to next-20130716

 .../devicetree/bindings/net/moxa,moxart-mac.txt    |  25 +
 drivers/net/ethernet/Kconfig                       |   1 +
 drivers/net/ethernet/Makefile                      |   1 +
 drivers/net/ethernet/moxa/Kconfig                  |  30 ++
 drivers/net/ethernet/moxa/Makefile                 |   6 +
 drivers/net/ethernet/moxa/moxart_ether.c           | 544 +++++++++++++++++++++
 drivers/net/ethernet/moxa/moxart_ether.h           | 525 ++++++++++++++++++++
 7 files changed, 1132 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/moxa,moxart-mac.txt
 create mode 100644 drivers/net/ethernet/moxa/Kconfig
 create mode 100644 drivers/net/ethernet/moxa/Makefile
 create mode 100644 drivers/net/ethernet/moxa/moxart_ether.c
 create mode 100644 drivers/net/ethernet/moxa/moxart_ether.h

diff --git a/Documentation/devicetree/bindings/net/moxa,moxart-mac.txt b/Documentation/devicetree/bindings/net/moxa,moxart-mac.txt
new file mode 100644
index 0000000..12e12a5
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/moxa,moxart-mac.txt
@@ -0,0 +1,25 @@
+MOXA ART Ethernet Controller
+
+Required properties:
+
+- compatible : Should be "moxa,moxart-mac"
+- reg : Should contain registers location and length
+  index 0 : main register
+  index 1 : mac address (stored on flash)
+- interrupts : Should contain the mac interrupt number
+
+Example:
+
+	mac0: mac@90900000 {
+		compatible = "moxa,moxart-mac";
+		reg =	<0x90900000 0x100>,
+			<0x80000050 0x6>;
+		interrupts = <25 0>;
+	};
+
+	mac1: mac@92000000 {
+		compatible = "moxa,moxart-mac";
+		reg =	<0x92000000 0x100>,
+			<0x80000056 0x6>;
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
index 0000000..d757a78
--- /dev/null
+++ b/drivers/net/ethernet/moxa/Makefile
@@ -0,0 +1,6 @@
+#
+# Makefile for the MOXART network device drivers.
+#
+
+obj-$(CONFIG_ARM_MOXART_ETHER) += moxart_ether.o
+
diff --git a/drivers/net/ethernet/moxa/moxart_ether.c b/drivers/net/ethernet/moxa/moxart_ether.c
new file mode 100644
index 0000000..172f718
--- /dev/null
+++ b/drivers/net/ethernet/moxa/moxart_ether.c
@@ -0,0 +1,544 @@
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
+
+#include "moxart_ether.h"
+
+static inline unsigned long moxart_emac_read(struct net_device *ndev,
+					     unsigned int reg)
+{
+	struct moxart_mac_priv_t *priv = netdev_priv(ndev);
+
+	return readl(priv->base + reg);
+}
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
+	moxart_emac_write(ndev, MAC_MADR_REG_OFFSET,
+			  ((ndev->dev_addr[0] << 8) | (ndev->dev_addr[1])));
+	moxart_emac_write(ndev, MAC_MADR_REG_OFFSET + 4,
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
+
+	if (priv->virt_tx_desc_baseaddr)
+		dma_free_coherent(NULL, sizeof(struct tx_desc_t)*TX_DESC_NUM,
+				  priv->virt_tx_desc_baseaddr,
+				  priv->phy_tx_desc_baseaddr);
+	if (priv->virt_rx_desc_baseaddr)
+		dma_free_coherent(NULL, sizeof(struct rx_desc_t)*RX_DESC_NUM,
+				  priv->virt_rx_desc_baseaddr,
+				  priv->phy_rx_desc_baseaddr);
+	if (priv->virt_tx_buf_baseaddr)
+		dma_free_coherent(NULL, TX_BUF_SIZE*TX_DESC_NUM,
+				  priv->virt_tx_buf_baseaddr,
+				  priv->phy_tx_buf_baseaddr);
+	if (priv->virt_rx_buf_baseaddr)
+		dma_free_coherent(NULL, RX_BUF_SIZE*RX_DESC_NUM,
+				  priv->virt_rx_buf_baseaddr,
+				  priv->phy_rx_buf_baseaddr);
+}
+
+static void moxart_mac_reset(struct net_device *ndev)
+{
+	struct moxart_mac_priv_t *priv = netdev_priv(ndev);
+
+	writel(SW_RST, priv->base + MACCR_REG_OFFSET);
+	while (readl(priv->base + MACCR_REG_OFFSET) & SW_RST)
+		mdelay(10);
+
+	writel(0, priv->base + IMR_REG_OFFSET);
+
+	priv->maccr = RX_BROADPKT | FULLDUP | CRC_APD | RX_FTL;
+}
+
+static void moxart_mac_enable(struct net_device *ndev)
+{
+	struct moxart_mac_priv_t *priv = netdev_priv(ndev);
+
+	writel(0x00001010, priv->base + ITC_REG_OFFSET);
+	writel(0x00000001, priv->base + APTC_REG_OFFSET);
+	writel(0x00000390, priv->base + DBLAC_REG_OFFSET);
+
+	writel(RPKT_FINISH_M, priv->base + IMR_REG_OFFSET);
+	priv->maccr |= (RCV_EN | XMT_EN | RDMA_EN | XDMA_EN);
+	writel(priv->maccr, priv->base + MACCR_REG_OFFSET);
+}
+
+static void moxart_mac_setup_desc_ring(struct net_device *ndev)
+{
+	struct moxart_mac_priv_t *priv = netdev_priv(ndev);
+	struct tx_desc_t *txdesc;
+	struct rx_desc_t *rxdesc;
+	unsigned char *virtbuf;
+	unsigned int phybuf;
+	int i;
+
+	virtbuf = priv->virt_tx_buf_baseaddr;
+	phybuf = priv->phy_tx_buf_baseaddr;
+	for (i = 0; i < TX_DESC_NUM; i++,
+		virtbuf += TX_BUF_SIZE, phybuf += TX_BUF_SIZE) {
+		txdesc = &priv->virt_tx_desc_baseaddr[i];
+		memset(txdesc, 0, sizeof(struct tx_desc_t));
+		txdesc->txdes2.phy_tx_buf_baseaddr = phybuf;
+		txdesc->txdes2.virt_tx_buf_baseaddr = virtbuf;
+	}
+	priv->virt_tx_desc_baseaddr[TX_DESC_NUM - 1].txdes1.ubit.edotr = 1;
+	priv->tx_desc_now = 0;
+
+	virtbuf = priv->virt_rx_buf_baseaddr;
+	phybuf = priv->phy_rx_buf_baseaddr;
+	for (i = 0; i < RX_DESC_NUM; i++,
+		virtbuf += RX_BUF_SIZE, phybuf += RX_BUF_SIZE) {
+		rxdesc = &priv->virt_rx_desc_baseaddr[i];
+		memset(rxdesc, 0, sizeof(struct rx_desc_t));
+		rxdesc->rxdes0.ubit.rx_dma_own = 1;
+		rxdesc->rxdes1.ubit.rx_buf_size = RX_BUF_SIZE;
+		rxdesc->rxdes2.phy_rx_buf_baseaddr = phybuf;
+		rxdesc->rxdes2.virt_rx_buf_baseaddr = virtbuf;
+	}
+	priv->virt_rx_desc_baseaddr[RX_DESC_NUM - 1].rxdes1.ubit.edorr = 1;
+	priv->rx_desc_now = 0;
+
+	/* reset the MAC controler TX/RX desciptor base address */
+	writel(priv->phy_tx_desc_baseaddr, priv->base + TXR_BADR_REG_OFFSET);
+	writel(priv->phy_rx_desc_baseaddr, priv->base + RXR_BADR_REG_OFFSET);
+}
+
+static int moxart_mac_open(struct net_device *ndev)
+{
+	struct moxart_mac_priv_t *priv = netdev_priv(ndev);
+
+	if (!is_valid_ether_addr(ndev->dev_addr))
+		return -EADDRNOTAVAIL;
+
+	spin_lock_irq(&priv->txlock);
+	moxart_mac_reset(ndev);
+	moxart_update_mac_address(ndev);
+	moxart_mac_setup_desc_ring(ndev);
+	moxart_mac_enable(ndev);
+	spin_unlock_irq(&priv->txlock);
+	netif_start_queue(ndev);
+
+	netdev_dbg(ndev, "%s: IMR=0x%x, MACCR=0x%x\n",
+		   __func__, readl(priv->base + IMR_REG_OFFSET),
+		   readl(priv->base + MACCR_REG_OFFSET));
+
+	return 0;
+}
+
+static int moxart_mac_stop(struct net_device *ndev)
+{
+	struct moxart_mac_priv_t *priv = netdev_priv(ndev);
+
+	netif_stop_queue(ndev);
+	spin_lock_irq(&priv->txlock);
+
+	/* disable all interrupts */
+	writel(0, priv->base + IMR_REG_OFFSET);
+
+	/* disable all functions */
+	writel(0, priv->base + MACCR_REG_OFFSET);
+
+	spin_unlock_irq(&priv->txlock);
+
+	return 0;
+}
+
+static void moxart_mac_recv(struct work_struct *ptr)
+{
+	struct net_device *ndev = (struct net_device *) ptr;
+	struct moxart_mac_priv_t *priv = netdev_priv((struct net_device *)ptr);
+	struct rx_desc_t *rxdesc;
+	struct sk_buff *skb;
+	unsigned int ui, len;
+	int rxnow = priv->rx_desc_now;
+	int loops = RX_DESC_NUM;
+
+repeat_recv:
+	rxdesc = &priv->virt_rx_desc_baseaddr[rxnow];
+	ui = rxdesc->rxdes0.ui;
+
+	if (ui & RXDMA_OWN)
+		return;
+
+	if (ui & (RX_ERR | CRC_ERR | FTL | RUNT | RX_ODD_NB)) {
+		netdev_err(ndev, "%s: packet error\n", __func__);
+		priv->stats.rx_dropped++;
+		priv->stats.rx_errors++;
+		goto recv_finish;
+	}
+
+	len = ui & RFL_MASK;
+
+	if (len > RX_BUF_SIZE)
+		len = RX_BUF_SIZE;
+
+	skb = dev_alloc_skb(len + 2);
+	if (skb == NULL) {
+		netdev_err(ndev, "%s: dev_alloc_skb failed\n", __func__);
+		priv->stats.rx_dropped++;
+		goto recv_finish;
+	}
+
+	skb_reserve(skb, 2);
+	skb->dev = ndev;
+	memcpy(skb_put(skb, len), rxdesc->rxdes2.virt_rx_buf_baseaddr, len);
+	netif_rx(skb);
+	skb->protocol = eth_type_trans(skb, ndev);
+	ndev->last_rx = jiffies;
+	priv->stats.rx_packets++;
+	priv->stats.rx_bytes += len;
+	if (ui & MULTICAST_RXDES0)
+		priv->stats.multicast++;
+
+recv_finish:
+	rxdesc->rxdes0.ui = RXDMA_OWN;
+	rxnow++;
+	rxnow &= RX_DESC_NUM_MASK;
+	priv->rx_desc_now = rxnow;
+	if (loops-- > 0)
+		goto repeat_recv;
+}
+
+static irqreturn_t moxart_mac_interrupt(int irq, void *dev_id)
+{
+	struct net_device *ndev = (struct net_device *) dev_id;
+	struct moxart_mac_priv_t *priv = netdev_priv(ndev);
+	unsigned int ists = readl(priv->base + ISR_REG_OFFSET);
+
+	if (ists & RPKT_FINISH)
+		moxart_mac_recv((void *) ndev);
+
+	return IRQ_HANDLED;
+}
+
+static int moxart_mac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
+{
+	struct moxart_mac_priv_t *priv = netdev_priv(ndev);
+	struct tx_desc_t *txdesc;
+	int len;
+	int txnow = priv->tx_desc_now;
+
+	spin_lock_irq(&priv->txlock);
+	txdesc = &priv->virt_tx_desc_baseaddr[txnow];
+	if (txdesc->txdes0.ubit.tx_dma_own) {
+		netdev_err(ndev, "%s: no TX space for packet\n", __func__);
+		priv->stats.tx_dropped++;
+		goto xmit_final;
+	}
+
+	len = skb->len > TX_BUF_SIZE ? TX_BUF_SIZE : skb->len;
+	memcpy(txdesc->txdes2.virt_tx_buf_baseaddr, skb->data, len);
+
+	if (skb->len < ETH_ZLEN) {
+		memset(&txdesc->txdes2.virt_tx_buf_baseaddr[skb->len],
+		       0, ETH_ZLEN - skb->len);
+		len = ETH_ZLEN;
+	}
+
+	txdesc->txdes1.ubit.lts = 1;
+	txdesc->txdes1.ubit.fts = 1;
+	txdesc->txdes1.ubit.tx2_fic = 0;
+	txdesc->txdes1.ubit.tx_ic = 0;
+	txdesc->txdes1.ubit.tx_buf_size = len;
+	txdesc->txdes0.ui = TXDMA_OWN;
+
+	/* start to send packet */
+	writel(0xffffffff, priv->base + TXPD_REG_OFFSET);
+
+	txnow++;
+	txnow &= TX_DESC_NUM_MASK;
+	priv->tx_desc_now = txnow;
+	ndev->trans_start = jiffies;
+	priv->stats.tx_packets++;
+	priv->stats.tx_bytes += len;
+
+xmit_final:
+	spin_unlock_irq(&priv->txlock);
+	dev_kfree_skb_any(skb);
+
+	return NETDEV_TX_OK;
+}
+
+static struct net_device_stats *moxart_mac_get_stats(struct net_device *ndev)
+{
+	struct moxart_mac_priv_t *priv = netdev_priv(ndev);
+	int desc = priv->rx_desc_now;
+
+	desc++;
+	desc &= RX_DESC_NUM_MASK;
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
+			writel(readl(priv->base + MATH1_REG_OFFSET) |
+			       (1UL << (crc_val - 32)),
+			       priv->base + MATH1_REG_OFFSET);
+		} else {
+			writel(readl(priv->base + MATH0_REG_OFFSET) |
+			       (1UL << crc_val),
+			       priv->base + MATH0_REG_OFFSET);
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
+	(ndev->flags & IFF_PROMISC) ? (priv->maccr |= RCV_ALL) :
+				      (priv->maccr &= ~RCV_ALL);
+
+	(ndev->flags & IFF_ALLMULTI) ? (priv->maccr |= RX_MULTIPKT) :
+				       (priv->maccr &= ~RX_MULTIPKT);
+
+	if ((ndev->flags & IFF_MULTICAST) && netdev_mc_count(ndev)) {
+		priv->maccr |= HT_MULTI_EN;
+		moxart_mac_setmulticast(ndev);
+	} else {
+		priv->maccr &= ~HT_MULTI_EN;
+	}
+
+	writel(priv->maccr, priv->base + MACCR_REG_OFFSET);
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
+static void moxart_get_mac_address(struct net_device *ndev)
+{
+	struct moxart_mac_priv_t *priv = netdev_priv(ndev);
+	int i;
+
+	for (i = 0; i <= 5; i++)
+		ndev->dev_addr[i] = readb(priv->flash_base + i);
+}
+
+static int moxart_mac_probe(struct platform_device *pdev)
+{
+	struct device *p_dev = &pdev->dev;
+	struct device_node *node = p_dev->of_node;
+	struct net_device *ndev;
+	struct moxart_mac_priv_t *priv;
+	struct resource *res;
+	unsigned int irq;
+	void *tmp;
+
+	ndev = alloc_etherdev(sizeof(struct moxart_mac_priv_t));
+	if (!ndev)
+		return -ENOMEM;
+
+	irq = irq_of_parse_and_map(node, 0);
+
+	priv = netdev_priv(ndev);
+
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	ndev->base_addr = res->start;
+	priv->base = devm_ioremap_resource(p_dev, res);
+	if (IS_ERR(priv->base)) {
+		dev_err(p_dev, "%s: devm_ioremap_resource res_mac failed\n",
+			__func__);
+		goto init_fail;
+	}
+
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 1);
+
+	/* the flash driver (physmap_of) requests the same region
+	 * so use ioremap instead of devm_ioremap_resource
+	 */
+	priv->flash_base = ioremap(res->start, resource_size(res));
+	if (IS_ERR(priv->flash_base)) {
+		dev_err(p_dev, "%s: devm_ioremap_resource res_flash failed\n",
+			__func__);
+		goto init_fail;
+	}
+
+	spin_lock_init(&priv->txlock);
+
+	tmp = dma_alloc_coherent(NULL, sizeof(struct tx_desc_t) * TX_DESC_NUM,
+				 (dma_addr_t *) &priv->phy_tx_desc_baseaddr,
+				 GFP_DMA | GFP_KERNEL);
+	priv->virt_tx_desc_baseaddr = (struct tx_desc_t *) tmp;
+	if (priv->virt_tx_desc_baseaddr == NULL ||
+	    (priv->phy_tx_desc_baseaddr & 0x0f)) {
+		netdev_err(ndev, "TX descriptor alloc failed\n");
+		goto init_fail;
+	}
+
+	tmp = dma_alloc_coherent(NULL, sizeof(struct rx_desc_t) * RX_DESC_NUM,
+				 (dma_addr_t *)&priv->phy_rx_desc_baseaddr,
+				 GFP_DMA | GFP_KERNEL);
+	priv->virt_rx_desc_baseaddr = (struct rx_desc_t *) tmp;
+	if (priv->virt_rx_desc_baseaddr == NULL ||
+	    (priv->phy_rx_desc_baseaddr & 0x0f)) {
+		netdev_err(ndev, "RX descriptor alloc failed\n");
+		goto init_fail;
+	}
+
+	tmp = dma_alloc_coherent(NULL, TX_BUF_SIZE * TX_DESC_NUM,
+				 (dma_addr_t *)&priv->phy_tx_buf_baseaddr,
+				 GFP_DMA | GFP_KERNEL);
+	priv->virt_tx_buf_baseaddr = (unsigned char *) tmp;
+	if (priv->virt_tx_buf_baseaddr == NULL ||
+	    (priv->phy_tx_buf_baseaddr & 0x03)) {
+		netdev_err(ndev, "TX buffer alloc failed\n");
+		goto init_fail;
+	}
+
+	tmp = dma_alloc_coherent(NULL, RX_BUF_SIZE * RX_DESC_NUM,
+				 (dma_addr_t *)&priv->phy_rx_buf_baseaddr,
+				 GFP_DMA | GFP_KERNEL);
+	priv->virt_rx_buf_baseaddr = (unsigned char *) tmp;
+	if (priv->virt_rx_buf_baseaddr == NULL ||
+	    (priv->phy_rx_buf_baseaddr & 0x03)) {
+		netdev_err(ndev, "RX buffer alloc failed\n");
+		goto init_fail;
+	}
+
+	platform_set_drvdata(pdev, ndev);
+
+	ether_setup(ndev);
+	ndev->netdev_ops = &moxart_netdev_ops;
+	ndev->priv_flags |= IFF_UNICAST_FLT;
+
+	SET_NETDEV_DEV(ndev, &pdev->dev);
+
+	moxart_get_mac_address(ndev);
+	moxart_update_mac_address(ndev);
+
+	if (register_netdev(ndev)) {
+		free_netdev(ndev);
+		goto init_fail;
+	}
+
+	ndev->irq = irq;
+
+	if (devm_request_irq(p_dev, irq, moxart_mac_interrupt, 0,
+			     pdev->name, ndev)) {
+		netdev_err(ndev, "%s: devm_request_irq failed\n", __func__);
+		free_netdev(ndev);
+		return -EBUSY;
+	}
+
+	netdev_dbg(ndev, "%s: IRQ=%d address=%02x:%02x:%02x:%02x:%02x:%02x\n",
+		   __func__, ndev->irq,
+		   ndev->dev_addr[0], ndev->dev_addr[1], ndev->dev_addr[2],
+		   ndev->dev_addr[3], ndev->dev_addr[4], ndev->dev_addr[5]);
+
+	return 0;
+
+init_fail:
+	netdev_err(ndev, "%s: init failed\n", __func__);
+	moxart_mac_free_memory(ndev);
+
+	return -ENOMEM;
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
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Jonas Jensen <jonas.jensen@gmail.com>");
+
diff --git a/drivers/net/ethernet/moxa/moxart_ether.h b/drivers/net/ethernet/moxa/moxart_ether.h
new file mode 100644
index 0000000..9c477f6
--- /dev/null
+++ b/drivers/net/ethernet/moxa/moxart_ether.h
@@ -0,0 +1,525 @@
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
+#define TX_DESC_NUM		64
+#define TX_DESC_NUM_MASK	(TX_DESC_NUM-1)
+#define RX_DESC_NUM		64
+#define RX_DESC_NUM_MASK	(RX_DESC_NUM-1)
+#define TX_BUF_SIZE		1600
+#define RX_BUF_SIZE		1600
+
+struct tx_desc_t {
+	union {
+#define TXDMA_OWN		BIT(31)
+#define TXPKT_EXSCOL		BIT(1)
+#define TXPKT_LATECOL		BIT(0)
+		unsigned int ui;
+
+		struct {
+			/* is aborted due to late collision */
+			unsigned int tx_pkt_late_col:1;
+
+			/* is aborted after 16 collisions */
+			unsigned int rx_pkt_exs_col:1;
+
+			unsigned int reserved1:29;
+
+			/* is owned by the MAC controller */
+			unsigned int tx_dma_own:1;
+		} ubit;
+	} txdes0;
+
+	union {
+#define EDOTR			BIT(31)
+#define TXIC			BIT(30)
+#define TX2FIC			BIT(29)
+#define FTS			BIT(28)
+#define LTS			BIT(27)
+#define TXBUF_SIZE_MASK		0x7ff
+#define TXBUF_SIZE_MAX		(TXBUF_SIZE_MASK+1)
+		unsigned int ui;
+
+		struct {
+			/* transmit buffer size in byte */
+			unsigned int tx_buf_size:11;
+
+			unsigned int reserved2:16;
+
+			/* is the last descriptor of a Tx packet */
+			unsigned int lts:1;
+
+			/* is the first descriptor of a Tx packet */
+			unsigned int fts:1;
+
+			/* transmit to FIFO interrupt on completion */
+			unsigned int tx2_fic:1;
+
+			/* transmit interrupt on completion */
+			unsigned int tx_ic:1;
+
+			/* end descriptor of transmit ring */
+			unsigned int edotr:1;
+		} ubit;
+	} txdes1;
+
+	struct {
+		/* transmit buffer physical base address */
+		unsigned int phy_tx_buf_baseaddr;
+
+		/* transmit buffer virtual base address */
+		unsigned char *virt_tx_buf_baseaddr;
+	} txdes2;
+};
+
+struct rx_desc_t {
+	union {
+#define RXDMA_OWN		BIT(31)
+#define FRS			BIT(29)
+#define LRS			BIT(28)
+#define RX_ODD_NB		BIT(22)
+#define RUNT			BIT(21)
+#define FTL			BIT(20)
+#define CRC_ERR			BIT(19)
+#define RX_ERR			BIT(18)
+#define BROADCAST_RXDES0	BIT(17)
+#define MULTICAST_RXDES0	BIT(16)
+#define RFL_MASK		0x7ff
+#define RFL_MAX			(RFL_MASK+1)
+		unsigned int ui;
+
+		struct {
+			/* receive frame length */
+			unsigned int recv_frame_len:11;
+			unsigned int reserved1:5;
+
+			/* multicast frame */
+			unsigned int multicast:1;
+
+			/* broadcast frame */
+			unsigned int broadcast:1;
+			unsigned int rx_err:1;		/* receive error */
+			unsigned int crc_err:1;		/* CRC error */
+			unsigned int ftl:1;		/* frame too long */
+
+			/* runt packet, less than 64 bytes */
+			unsigned int runt:1;
+
+			/* receive odd nibbles */
+			unsigned int rx_odd_nb:1;
+			unsigned int reserved2:5;
+
+			/* last receive segment descriptor */
+			unsigned int lrs:1;
+
+			/* first receive segment descriptor */
+			unsigned int frs:1;
+
+			unsigned int reserved3:1;
+			unsigned int rx_dma_own:1;	/* RXDMA onwership */
+		} ubit;
+	} rxdes0;
+
+	union {
+#define EDORR			BIT(31)
+#define RXBUF_SIZE_MASK		0x7ff
+#define RXBUF_SIZE_MAX		(RXBUF_SIZE_MASK+1)
+		unsigned int ui;
+
+		struct {
+			/* receive buffer size */
+			unsigned int rx_buf_size:11;
+
+			unsigned int reserved4:20;
+
+			/* end descriptor of receive ring */
+			unsigned int edorr:1;
+		} ubit;
+	} rxdes1;
+
+	struct {
+		/* receive buffer physical base address */
+		unsigned int phy_rx_buf_baseaddr;
+
+		/* receive buffer virtual base address */
+		unsigned char *virt_rx_buf_baseaddr;
+	} rxdes2;
+};
+
+struct mac_control_reg_t {
+
+/* RXDMA has received packets into RX buffer successfully */
+#define RPKT_FINISH		BIT(0)
+/* receive buffer unavailable */
+#define NORXBUF			BIT(1)
+/* TXDMA has moved data into the TX FIFO */
+#define XPKT_FINISH		BIT(2)
+/* transmit buffer unavailable */
+#define NOTXBUF			BIT(3)
+/* packets transmitted to ethernet successfully */
+#define XPKT_OK_INT_STS		BIT(4)
+/* packets transmitted to ethernet lost due to late
+ * collision or excessive collision
+ */
+#define XPKT_LOST_INT_STS	BIT(5)
+/* packets received into RX FIFO successfully */
+#define RPKT_SAV		BIT(6)
+/* received packet lost due to RX FIFO full */
+#define RPKT_LOST_INT_STS	BIT(7)
+#define AHB_ERR			BIT(8)		/* AHB error */
+#define PHYSTS_CHG		BIT(9)		/* PHY link status change */
+	unsigned int isr;			/* interrupt status, 0x0 */
+
+#define RPKT_FINISH_M		BIT(0)		/* interrupt mask of ISR[0] */
+#define NORXBUF_M		BIT(1)		/* interrupt mask of ISR[1] */
+#define XPKT_FINISH_M		BIT(2)		/* interrupt mask of ISR[2] */
+#define NOTXBUF_M		BIT(3)		/* interrupt mask of ISR[3] */
+#define XPKT_OK_M		BIT(4)		/* interrupt mask of ISR[4] */
+#define XPKT_LOST_M		BIT(5)		/* interrupt mask of ISR[5] */
+#define RPKT_SAV_M		BIT(6)		/* interrupt mask of ISR[6] */
+#define RPKT_LOST_M		BIT(7)		/* interrupt mask of ISR[7] */
+#define AHB_ERR_M		BIT(8)		/* interrupt mask of ISR[8] */
+#define PHYSTS_CHG_M		BIT(9)		/* interrupt mask of ISR[9] */
+	unsigned int imr;			/* interrupt mask, 0x4 */
+
+/* the most significant 2 bytes of MAC address */
+#define MAC_MADR_MASK		0xffff
+	/* MAC most significant address, 0x8 */
+	unsigned int mac_madr;
+
+	/* MAC least significant address, 0xc */
+	unsigned int mac_ldar;
+
+	/* multicast address hash table 0, 0x10 */
+	unsigned int matht0;
+
+	/* multicast address hash table 1, 0x14 */
+	unsigned int matht1;
+
+	/* transmit poll demand, 0x18 */
+	unsigned int txpd;
+
+	/* receive poll demand, 0x1c */
+	unsigned int rxpd;
+
+	/* transmit ring base address, 0x20 */
+	unsigned int txr_badr;
+
+	/* receive ring base address, 0x24 */
+	unsigned int rxr_badr;
+
+/* defines the period of TX cycle time */
+#define TXINT_TIME_SEL		BIT(15)
+#define TXINT_THR_MASK		0x7000
+#define TXINT_CNT_MASK		0xf00
+/* defines the period of RX cycle time */
+#define RXINT_TIME_SEL		BIT(7)
+#define RXINT_THR_MASK		0x70
+#define RXINT_CNT_MASK		0xF
+	/* interrupt timer control, 0x28 */
+	unsigned int itc;
+
+/* defines the period of TX poll time */
+#define TXPOLL_TIME_SEL		BIT(12)
+#define TXPOLL_CNT_MASK		0xf00
+#define TXPOLL_CNT_SHIFT_BIT	8
+/* defines the period of RX poll time */
+#define RXPOLL_TIME_SEL		BIT(4)
+#define RXPOLL_CNT_MASK		0xF
+#define RXPOLL_CNT_SHIFT_BIT	0
+	/* automatic polling timer control, 0x2c */
+	unsigned int aptc;
+
+/* enable RX FIFO threshold arbitration */
+#define RX_THR_EN		BIT(9)
+#define RXFIFO_HTHR_MASK	0x1c0
+#define RXFIFO_LTHR_MASK	0x38
+/* use INCR16 burst command in AHB bus */
+#define INCR16_EN		BIT(2)
+/* use INCR8 burst command in AHB bus */
+#define INCR8_EN		BIT(1)
+/* use INCR4 burst command in AHB bus */
+#define INCR4_EN		BIT(0)
+	/* DMA burst length and arbitration control, 0x30 */
+	unsigned int dblac;
+
+	unsigned int reserved1[21];		/* 0x34 - 0x84 */
+
+#define RX_BROADPKT		BIT(17)		/* receive boradcast packet */
+/* receive all multicast packet */
+#define RX_MULTIPKT		BIT(16)
+#define FULLDUP			BIT(15)		/* full duplex */
+/* append CRC to transmitted packet */
+#define CRC_APD			BIT(14)
+/* do not check incoming packet's destination address */
+#define RCV_ALL			BIT(12)
+/* store incoming packet even if its length is great than 1518 bytes */
+#define RX_FTL			BIT(11)
+/* store incoming packet even if its length is less than 64 bytes */
+#define RX_RUNT			BIT(10)
+/* enable storing incoming packet if the packet passes hash table
+ * address filtering and is a multicast packet
+ */
+#define HT_MULTI_EN		BIT(9)
+#define RCV_EN			BIT(8)		/* receiver enable */
+/* enable packet reception when transmitting packet in half duplex mode */
+#define ENRX_IN_HALFTX		BIT(6)
+#define XMT_EN			BIT(5)		/* transmitter enable */
+/* disable CRC check when receiving packets */
+#define CRC_DIS			BIT(4)
+#define LOOP_EN			BIT(3)		/* internal loop-back */
+/* software reset, last 64 AHB bus clocks */
+#define SW_RST			BIT(2)
+#define RDMA_EN			BIT(1)		/* enable receive DMA chan */
+#define XDMA_EN			BIT(0)		/* enable transmit DMA chan */
+	unsigned int maccr;			/* MAC control, 0x88 */
+
+#define COL_EXCEED		BIT(11)		/* collisions exceeds 16 */
+/* transmitter detects late collision */
+#define LATE_COL		BIT(10)
+/* packet transmitted to ethernet lost due to late collision
+ * or excessive collision
+ */
+#define XPKT_LOST		BIT(9)
+/* packets transmitted to ethernet successfully */
+#define XPKT_OK			BIT(8)
+/* receiver detects a runt packet */
+#define RUNT_MAC_STS		BIT(7)
+/* receiver detects a frame that is too long */
+#define FTL_MAC_STS		BIT(6)
+#define CRC_ERR_MAC_STS		BIT(5)
+/* received packets list due to RX FIFO full */
+#define RPKT_LOST		BIT(4)
+/* packets received into RX FIFO successfully */
+#define RPKT_SAVE		BIT(3)
+/* incoming packet dropped due to collision */
+#define COL			BIT(2)
+#define MCPU_BROADCAST		BIT(1)
+#define MCPU_MULTICAST		BIT(0)
+	unsigned int macsr;			/* MAC status, 0x8c */
+
+/* initialize a write sequence to PHY by setting this bit to 1
+ * this bit would be auto cleared after the write operation is finished.
+ */
+#define MIIWR			BIT(27)
+#define MIIRD			BIT(26)
+#define REGAD_MASK		0x3e00000
+#define PHYAD_MASK		0x1f0000
+#define MIIRDATA_MASK		0xffff
+	unsigned int phycr;			/* PHY control, 0x90 */
+
+#define MIIWDATA_MASK		0xffff
+	unsigned int phywdata;			/* PHY write data, 0x94 */
+
+#define PAUSE_TIME_MASK		0xffff0000
+#define FC_HIGH_MASK		0xf000
+#define FC_LOW_MASK		0xf00
+#define RX_PAUSE		BIT(4)		/* receive pause frame */
+/* packet transmission is paused due to receive */
+#define TXPAUSED		BIT(3)
+	/* pause frame */
+/* enable flow control threshold mode. */
+#define FCTHR_EN		BIT(2)
+#define TX_PAUSE		BIT(1)		/* transmit pause frame */
+#define FC_EN			BIT(0)		/* flow control mode enable */
+	unsigned int fcr;			/* flow control, 0x98 */
+
+#define BK_LOW_MASK		0xf00
+#define BKJAM_LEN_MASK		0xf0
+#define BK_MODE			BIT(1)		/* back pressure address mode */
+#define BK_EN			BIT(0)		/* back pressure mode enable */
+	unsigned int bpr;			/* back pressure, 0x9c */
+
+	unsigned int reserved2[9];		/* 0xa0 - 0xc0 */
+
+#define TEST_SEED_MASK      0x3fff
+	unsigned int ts;			/* test seed, 0xc4 */
+
+#define TXD_REQ			BIT(31)		/* TXDMA request */
+#define RXD_REQ			BIT(30)		/* RXDMA request */
+#define DARB_TXGNT		BIT(29)		/* TXDMA grant */
+#define DARB_RXGNT		BIT(28)		/* RXDMA grant */
+#define TXFIFO_EMPTY		BIT(27)		/* TX FIFO is empty */
+#define RXFIFO_EMPTY		BIT(26)		/* RX FIFO is empty */
+#define TXDMA2_SM_MASK		0x7000
+#define TXDMA1_SM_MASK		0xf00
+#define RXDMA2_SM_MASK		0x70
+#define RXDMA1_SM_MASK		0xF
+	unsigned int dmafifos;			/* DMA/FIFO state, 0xc8 */
+
+#define SINGLE_PKT		BIT(26)		/* single packet mode */
+/* automatic polling timer test mode */
+#define PTIMER_TEST		BIT(25)
+#define ITIMER_TEST		BIT(24)		/* interrupt timer test mode */
+#define TEST_SEED_SEL		BIT(22)		/* test seed select */
+#define SEED_SEL		BIT(21)		/* seed select */
+#define TEST_MODE		BIT(20)		/* transmission test mode */
+#define TEST_TIME_MASK		0xffc00
+#define TEST_EXCEL_MASK		0x3e0
+	unsigned int tm;			/* test mode, 0xcc */
+
+	unsigned int reserved3;			/* 0xd0 */
+
+#define TX_MCOL_MASK		0xffff0000
+#define TX_MCOL_SHIFT_BIT	16
+#define TX_SCOL_MASK		0xffff
+#define TX_SCOL_SHIFT_BIT	0
+	/* TX_MCOL and TX_SCOL counter, 0xd4 */
+	unsigned int txmcol_xscol;
+
+#define RPF_MASK		0xffff0000
+#define RPF_SHIFT_BIT		16
+#define AEP_MASK		0xffff
+#define AEP_SHIFT_BIT		0
+	unsigned int rpf_aep;			/* RPF and AEP counter, 0xd8 */
+
+#define XM_MASK			0xffff0000
+#define XM_SHIFT_BIT		16
+#define PG_MASK			0xffff
+#define PG_SHIFT_BIT		0
+	unsigned int xm_pg;			/* XM and PG counter, 0xdc */
+
+#define RUNT_CNT_MASK		0xffff0000
+#define RUNT_CNT_SHIFT_BIT	16
+#define TLCC_MASK		0xffff
+#define TLCC_SHIFT_BIT		0
+	/* RUNT_CNT and TLCC counter, 0xe0 */
+	unsigned int runtcnt_tlcc;
+
+#define CRCER_CNT_MASK		0xffff0000
+#define CRCER_CNT_SHIFT_BIT	16
+#define FTL_CNT_MASK		0xffff
+#define FTL_CNT_SHIFT_BIT	0
+	/* CRCER_CNT and FTL_CNT counter, 0xe4 */
+	unsigned int crcercnt_ftlcnt;
+
+#define RLC_MASK		0xffff0000
+#define RLC_SHIFT_BIT		16
+#define RCC_MASK		0xffff
+#define RCC_SHIFT_BIT		0
+	unsigned int rlc_rcc;		/* RLC and RCC counter, 0xe8 */
+
+	unsigned int broc;		/* BROC counter, 0xec */
+	unsigned int mulca;		/* MULCA counter, 0xf0 */
+	unsigned int rp;		/* RP counter, 0xf4 */
+	unsigned int xp;		/* XP counter, 0xf8 */
+};
+
+#define ISR_REG_OFFSET			0x0
+#define IMR_REG_OFFSET			0x4
+#define MAC_MADR_REG_OFFSET		0x8
+#define MAC_LADR_REG_OFFSET		0xC
+#define MATH0_REG_OFFSET		0x10
+#define MATH1_REG_OFFSET		0x14
+#define TXPD_REG_OFFSET			0x18
+#define RXPD_REG_OFFSET			0x1C
+#define TXR_BADR_REG_OFFSET		0x20
+#define RXR_BADR_REG_OFFSET		0x24
+#define ITC_REG_OFFSET			0x28
+#define APTC_REG_OFFSET			0x2C
+#define DBLAC_REG_OFFSET		0x30
+#define MACCR_REG_OFFSET		0x88
+#define MACSR_REG_OFFSET		0x8C
+#define PHYCR_REG_OFFSET		0x90
+#define PHYWDATA_REG_OFFSET		0x94
+#define FCR_REG_OFFSET			0x98
+#define BPR_REG_OFFSET			0x9C
+#define TS_REG_OFFSET			0xC4
+#define DMAFIFOS_REG_OFFSET		0xC8
+#define TM_REG_OFFSET			0xCC
+#define TX_MCOL_TX_SCOL_REG_OFFSET	0xD4
+#define RPF_AEP_REG_OFFSET		0xD8
+#define XM_PG_REG_OFFSET		0xDC
+#define RUNT_CNT_TLCC_REG_OFFSET	0xE0
+#define CRCER_CNT_FTL_CNT_REG_OFFSET	0xE4
+#define RLC_RCC_REG_OFFSET		0xE8
+#define BROC_REG_OFFSET			0xEC
+#define MULCA_REG_OFFSET		0xF0
+#define RP_REG_OFFSET			0xF4
+#define XP_REG_OFFSET			0xF8
+#define PHY_CNTL_REG			0x0
+#define PHY_STATUS_REG			0x1
+#define PHY_ID_REG1			0x2
+#define PHY_ID_REG2			0x3
+#define PHY_ANA_REG			0x4
+#define PHY_ANLPAR_REG			0x5
+#define PHY_ANE_REG			0x6
+#define PHY_ECNTL_REG1			0x10
+#define PHY_QPDS_REG			0x11
+#define PHY_10BOP_REG			0x12
+#define PHY_ECNTL_REG2			0x13
+#define FTMAC100_REG_PHY_WRITE		0x8000000
+#define FTMAC100_REG_PHY_READ		0x4000000
+
+/* PHY Status register */
+#define AN_COMPLETE			0x20
+
+#define LINK_STATUS			0x4
+
+struct moxart_mac_priv_t {
+	void __iomem *base;
+	void __iomem *flash_base;
+
+	/* Tx descriptor physical base address */
+	unsigned int phy_tx_desc_baseaddr;
+
+	/* Tx descriptor virtual base address */
+	struct tx_desc_t *virt_tx_desc_baseaddr;
+
+	/* Rx descriptor physical base address */
+	unsigned int phy_rx_desc_baseaddr;
+
+	/* Rx descriptor virtual base address */
+	struct rx_desc_t *virt_rx_desc_baseaddr;
+
+	/* Tx buffer physical base address */
+	unsigned int phy_tx_buf_baseaddr;
+
+	/* Tx buffer virtual base address */
+	unsigned char *virt_tx_buf_baseaddr;
+
+	/* Rx buffer physical base address */
+	unsigned int phy_rx_buf_baseaddr;
+
+	/* Rx buffer virtual base address */
+	unsigned char *virt_rx_buf_baseaddr;
+
+	/* Tx descriptor now first used index */
+	int tx_desc_now;
+
+	/* Rx descriptor now first used index */
+	int rx_desc_now;
+
+	/* OS about the ethernet statistics */
+	struct net_device_stats stats;
+
+	spinlock_t txlock;
+	spinlock_t rxlock;
+
+	/* store the maccr control register value */
+	unsigned int maccr;
+
+	struct work_struct rqueue;
+};
+
+#if TX_BUF_SIZE >= TXBUF_SIZE_MAX
+#error MOXA ART Ethernet device driver Tx buffer size too large !
+#endif
+#if RX_BUF_SIZE >= RXBUF_SIZE_MAX
+#error MOXA ART Ethernet device driver Rx buffer size too large !
+#endif
+
+#endif
-- 
1.8.2.1


From: John Crispin <blogic@openwrt.org>
Subject: [PATCH 2/3] MIPS: lantiq: add ethernet driver
Date: Tue, 12 Apr 2011 18:11:14 +0200
Message-ID: <1302624675-18652-3-git-send-email-blogic@openwrt.org>
References: <1302624675-18652-1-git-send-email-blogic@openwrt.org>
Cc: John Crispin <blogic@openwrt.org>,
	Ralph Hempel <ralph.hempel@lantiq.com>,
	linux-mips@linux-mips.org, netdev@vger.kernel.org
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:49406 "EHLO nbd.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757651Ab1DLQJt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Apr 2011 12:09:49 -0400
In-Reply-To: <1302624675-18652-1-git-send-email-blogic@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the driver for the ETOP Packet Processing Engine (PPE32) found
inside the XWAY family of Lantiq MIPS SoCs. This driver makes 100MBit ethernet
work. Support for all 8 dma channels, gbit and the embedded switch found on
the ar9/vr9 still needs to be implemented.

Signed-off-by: John Crispin <blogic@openwrt.org>
Signed-off-by: Ralph Hempel <ralph.hempel@lantiq.com>
Cc: linux-mips@linux-mips.org
Cc: netdev@vger.kernel.org

--

This Patch thould go via the MIPS tree.

 .../mips/include/asm/mach-lantiq/lantiq_platform.h |   14 +
 .../mips/include/asm/mach-lantiq/xway/lantiq_soc.h |    4 +-
 drivers/net/Kconfig                                |    7 +
 drivers/net/Makefile                               |    1 +
 drivers/net/lantiq_etop.c                          |  710 ++++++++++++++++++++
 5 files changed, 734 insertions(+), 2 deletions(-)
 create mode 100644 drivers/net/lantiq_etop.c

diff --git a/arch/mips/include/asm/mach-lantiq/lantiq_platform.h b/arch/mips/include/asm/mach-lantiq/lantiq_platform.h
index 1f1dba6..d6b600c 100644
--- a/arch/mips/include/asm/mach-lantiq/lantiq_platform.h
+++ b/arch/mips/include/asm/mach-lantiq/lantiq_platform.h
@@ -10,6 +10,7 @@
 #define _LANTIQ_PLATFORM_H__
 
 #include <linux/mtd/partitions.h>
+#include <linux/socket.h>
 
 /* struct used to pass info to the pci core */
 enum {
@@ -43,4 +44,17 @@ struct ltq_pci_data {
 	int irq[16];
 };
 
+/* struct used to pass info to network drivers */
+enum {
+	MII_MODE,
+	REV_MII_MODE,
+};
+
+#define LTQ_ETH_DATA_CHAN_MAX	0x8
+struct ltq_eth_data {
+	struct sockaddr mac;
+	int mii_mode;
+	int channel[LTQ_ETH_DATA_CHAN_MAX];
+};
+
 #endif
diff --git a/arch/mips/include/asm/mach-lantiq/xway/lantiq_soc.h b/arch/mips/include/asm/mach-lantiq/xway/lantiq_soc.h
index 95f1882..0213601 100644
--- a/arch/mips/include/asm/mach-lantiq/xway/lantiq_soc.h
+++ b/arch/mips/include/asm/mach-lantiq/xway/lantiq_soc.h
@@ -81,8 +81,8 @@
 #define PMU_SWITCH		0x10000000
 
 /* ETOP - ethernet */
-#define LTQ_PPE32_BASE_ADDR	0xBE180000
-#define LTQ_PPE32_SIZE		0x40000
+#define LTQ_ETOP_BASE_ADDR	0x1E180000
+#define LTQ_ETOP_SIZE		0x40000
 
 /* DMA */
 #define LTQ_DMA_BASE_ADDR	0x1E104100
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index b30c688..4878587 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2017,6 +2017,13 @@ config FTMAC100
 	  from Faraday. It is used on Faraday A320, Andes AG101 and some
 	  other ARM/NDS32 SoC's.
 
+config LANTIQ_ETOP
+	tristate "Lantiq SoC ETOP driver"
+	depends on SOC_TYPE_XWAY
+	help
+	  Support for the MII0 inside the Lantiq SoC
+
+
 source "drivers/net/fs_enet/Kconfig"
 
 source "drivers/net/octeon/Kconfig"
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index fbfca11..df71da7 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -261,6 +261,7 @@ obj-$(CONFIG_MLX4_CORE) += mlx4/
 obj-$(CONFIG_ENC28J60) += enc28j60.o
 obj-$(CONFIG_ETHOC) += ethoc.o
 obj-$(CONFIG_GRETH) += greth.o
+obj-$(CONFIG_LANTIQ_ETOP) += lantiq_etop.o
 
 obj-$(CONFIG_XTENSA_XT2000_SONIC) += xtsonic.o
 
diff --git a/drivers/net/lantiq_etop.c b/drivers/net/lantiq_etop.c
new file mode 100644
index 0000000..ec70a24
--- /dev/null
+++ b/drivers/net/lantiq_etop.c
@@ -0,0 +1,710 @@
+/*
+ *   This program is free software; you can redistribute it and/or modify it
+ *   under the terms of the GNU General Public License version 2 as published
+ *   by the Free Software Foundation.
+ *
+ *   This program is distributed in the hope that it will be useful,
+ *   but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *   GNU General Public License for more details.
+ *
+ *   You should have received a copy of the GNU General Public License
+ *   along with this program; if not, write to the Free Software
+ *   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307, USA.
+ *
+ *   Copyright (C) 2011 John Crispin <blogic@openwrt.org>
+ */
+
+#include <linux/kernel.h>
+#include <linux/slab.h>
+#include <linux/errno.h>
+#include <linux/types.h>
+#include <linux/interrupt.h>
+#include <linux/uaccess.h>
+#include <linux/in.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/phy.h>
+#include <linux/ip.h>
+#include <linux/tcp.h>
+#include <linux/skbuff.h>
+#include <linux/mm.h>
+#include <linux/platform_device.h>
+#include <linux/ethtool.h>
+#include <linux/init.h>
+#include <linux/delay.h>
+#include <linux/io.h>
+
+#include <asm/checksum.h>
+
+#include <lantiq_soc.h>
+#include <xway_dma.h>
+#include <lantiq_platform.h>
+
+#define LTQ_ETOP_MDIO		0x11804
+#define MDIO_REQUEST		0x80000000
+#define MDIO_READ		0x40000000
+#define MDIO_ADDR_MASK		0x1f
+#define MDIO_ADDR_OFFSET	0x15
+#define MDIO_REG_MASK		0x1f
+#define MDIO_REG_OFFSET		0x10
+#define MDIO_VAL_MASK		0xffff
+
+#define PPE32_CGEN		0x800
+#define LQ_PPE32_ENET_MAC_CFG	0x1840
+
+#define LTQ_ETOP_ENETS0		0x11850
+#define LTQ_ETOP_MAC_DA0	0x1186C
+#define LTQ_ETOP_MAC_DA1	0x11870
+#define LTQ_ETOP_CFG		0x16020
+#define LTQ_ETOP_IGPLEN		0x16080
+
+#define MAX_DMA_CHAN            0x8
+#define MAX_DMA_CRC_LEN		0x4
+#define MAX_DMA_DATA_LEN	0x600
+
+#define ETOP_FTCU		BIT(28)
+#define ETOP_MII_MASK		0xf
+#define ETOP_MII_NORMAL		0xd
+#define ETOP_MII_REVERSE	0xe
+#define ETOP_PLEN_UNDER		0x40
+#define ETOP_CGEN		0x800
+
+#define IS_TX(x)		(x % 2)
+
+#define ltq_etop_r32(x)		ltq_r32(ltq_etop_membase + (x))
+#define ltq_etop_w32(x, y)	ltq_w32(x, ltq_etop_membase + (y))
+#define ltq_etop_w32_mask(x, y, z)	\
+		ltq_w32_mask(x, y, ltq_etop_membase + (z))
+
+static void __iomem *ltq_etop_membase;
+
+struct ltq_mii_priv {
+	struct ltq_eth_data *pldata;
+	struct resource *res;
+	struct net_device_stats stats;
+
+	struct mii_bus *mii_bus;
+	struct phy_device *phydev;
+
+	struct ltq_dma_channel dma[MAX_DMA_CHAN];
+	struct sk_buff *tx_skb[MAX_DMA_CHAN >> 1][LTQ_DESC_NUM];
+	struct sk_buff *rx_skb[MAX_DMA_CHAN >> 1][LTQ_DESC_NUM];
+
+	struct tasklet_struct rx_tasklet;
+	int rx_tasklet_running;
+	u32 rx_channel_mask;
+
+	struct tasklet_struct tx_tasklet;
+	int tx_tasklet_running;
+	u32 tx_channel_mask;
+	int tx_free[MAX_DMA_CHAN >> 1];
+};
+
+static int
+ltq_etop_alloc_rx_skb(struct ltq_mii_priv *priv, int ch, int desc)
+{
+	int idx = ch >> 1;
+
+	priv->rx_skb[idx][desc] = dev_alloc_skb(MAX_DMA_DATA_LEN);
+	if (!priv->rx_skb[idx][desc])
+		return -ENOMEM;
+
+	priv->dma[ch].desc_base[desc].addr = dma_map_single(NULL,
+			priv->rx_skb[idx][desc]->data,
+			MAX_DMA_DATA_LEN, DMA_FROM_DEVICE);
+	priv->dma[ch].desc_base[desc].addr =
+		CPHYSADDR(priv->rx_skb[idx][desc]->data);
+	priv->dma[ch].desc_base[desc].ctl =
+		LTQ_DMA_OWN | LTQ_DMA_RX_OFFSET(2) | MAX_DMA_DATA_LEN;
+	skb_reserve(priv->rx_skb[idx][desc], 2);
+	return 0;
+}
+
+static void
+ltq_etop_hw_receive(struct net_device *dev, struct ltq_mii_priv *priv, int ch)
+{
+	struct ltq_dma_desc *d = &priv->dma[ch].desc_base[priv->dma[ch].desc];
+	int len = (d->ctl & LTQ_DMA_SIZE_MASK) - MAX_DMA_CRC_LEN;
+	struct sk_buff *skb = priv->rx_skb[ch >> 1][priv->dma[ch].desc];
+
+	if (ltq_etop_alloc_rx_skb(priv, ch, priv->dma[ch].desc)) {
+		netdev_err(dev,
+			"failed to allocate new rx buffer, stopping DMA\n");
+		ltq_dma_close(&priv->dma[ch]);
+	}
+
+	priv->dma[ch].desc++;
+	priv->dma[ch].desc %= LTQ_DESC_NUM;
+
+	skb_put(skb, len);
+	skb->dev = dev;
+	skb->protocol = eth_type_trans(skb, dev);
+	netif_rx(skb);
+	priv->stats.rx_packets++;
+	priv->stats.rx_bytes += len;
+}
+
+static void
+ltq_etop_rx_tasklet(unsigned long _dev)
+{
+	struct net_device *dev = (struct net_device *)_dev;
+	struct ltq_mii_priv *priv = netdev_priv(dev);
+	unsigned long flags;
+	int max_irq = 16;
+
+	while (priv->rx_channel_mask && max_irq--) {
+		int ch = __fls(priv->rx_channel_mask);
+		int idx = priv->dma[ch].desc;
+		struct ltq_dma_desc *desc = &priv->dma[ch].desc_base[idx];
+
+		if ((desc->ctl & (LTQ_DMA_OWN | LTQ_DMA_C)) == LTQ_DMA_C) {
+			/* this is a completed rx transaction */
+			ltq_etop_hw_receive(dev, priv, ch);
+		} else {
+			/* there are no more complete descriptors */
+			priv->rx_channel_mask &= ~BIT(ch);
+			ltq_dma_ack_irq(&priv->dma[ch]);
+		}
+	}
+
+	local_irq_save(flags);
+	priv->rx_tasklet_running = 0;
+	if (priv->rx_channel_mask) {
+		priv->rx_tasklet_running = 1;
+		tasklet_schedule(&priv->rx_tasklet);
+	}
+	local_irq_restore(flags);
+}
+
+static int
+ltq_etop_tx_housekeeping(struct net_device *dev, int ch)
+{
+	struct ltq_mii_priv *priv = netdev_priv(dev);
+	int idx = ch >> 1;
+	int start_queue = 0;
+
+	while ((priv->dma[ch].desc_base[priv->tx_free[idx]].ctl &
+			(LTQ_DMA_OWN | LTQ_DMA_C)) == LTQ_DMA_C) {
+		dev_kfree_skb_any(priv->tx_skb[idx][priv->tx_free[idx]]);
+		priv->tx_skb[idx][priv->tx_free[idx]] = NULL;
+		memset(&priv->dma[ch].desc_base[priv->tx_free[idx]], 0,
+			sizeof(struct ltq_dma_desc));
+		priv->tx_free[idx]++;
+		priv->tx_free[idx] %= LTQ_DESC_NUM;
+		start_queue = 1;
+	}
+	return start_queue;
+}
+
+static void
+ltq_etop_tx_tasklet(unsigned long _dev)
+{
+	struct net_device *dev = (struct net_device *)_dev;
+	struct ltq_mii_priv *priv = netdev_priv(dev);
+	int start_queue = 0;
+
+	while (priv->tx_channel_mask) {
+		int ch = __fls(priv->tx_channel_mask);
+		priv->tx_channel_mask &= ~BIT(ch);
+		start_queue |= ltq_etop_tx_housekeeping(dev, ch);
+		ltq_dma_ack_irq(&priv->dma[ch]);
+	}
+	if (start_queue)
+		netif_start_queue(dev);
+	priv->tx_tasklet_running = 0;
+}
+
+static irqreturn_t
+ltq_etop_dma_irq(int irq, void *_priv)
+{
+	struct ltq_mii_priv *priv = _priv;
+	int ch = irq - LTQ_DMA_CH0_INT;
+
+	if (!IS_TX(ch) && !priv->rx_tasklet_running) {
+		priv->rx_channel_mask |= BIT(ch);
+		priv->rx_tasklet_running = 1;
+		tasklet_schedule(&priv->rx_tasklet);
+	}
+
+	if (IS_TX(ch) && !priv->tx_tasklet_running) {
+		priv->tx_channel_mask |= BIT(ch);
+		priv->tx_tasklet_running = 1;
+		tasklet_schedule(&priv->tx_tasklet);
+	}
+	return IRQ_HANDLED;
+}
+
+static void
+ltq_etop_free_channel(struct net_device *dev, struct ltq_dma_channel *ch)
+{
+	struct ltq_mii_priv *priv = netdev_priv(dev);
+
+	ltq_dma_free(ch);
+	if (ch->irq)
+		free_irq(ch->irq, priv);
+
+	if (!IS_TX(ch->nr)) {
+		int desc;
+		for (desc = 0; desc < LTQ_DESC_NUM; desc++)
+			if (priv->rx_skb[ch->nr >> 1][desc])
+				dev_kfree_skb_any(
+					priv->rx_skb[ch->nr >> 1][desc]);
+	}
+}
+
+static void
+ltq_etop_hw_exit(struct net_device *dev)
+{
+	struct ltq_mii_priv *priv = netdev_priv(dev);
+	int ch;
+
+	ltq_pmu_disable(PMU_PPE);
+	for (ch = 0; ch < MAX_DMA_CHAN; ch++)
+		if (priv->pldata->channel[ch])
+			ltq_etop_free_channel(dev, &priv->dma[ch]);
+}
+
+static int
+ltq_etop_hw_init(struct net_device *dev)
+{
+	struct ltq_mii_priv *priv = netdev_priv(dev);
+	int ch;
+
+	ltq_pmu_enable(PMU_PPE);
+
+	if (priv->pldata->mii_mode == REV_MII_MODE)
+		ltq_etop_w32_mask(ETOP_MII_MASK,
+			ETOP_MII_REVERSE, LTQ_ETOP_CFG);
+	else
+		ltq_etop_w32_mask(ETOP_MII_MASK,
+			ETOP_MII_NORMAL, LTQ_ETOP_CFG);
+	ltq_etop_w32(PPE32_CGEN, LQ_PPE32_ENET_MAC_CFG);
+
+	ltq_dma_init_port(DMA_PORT_ETOP);
+
+	for (ch = 0; ch < MAX_DMA_CHAN; ch++) {
+		int irq = LTQ_DMA_CH0_INT + ch;
+
+		if (!priv->pldata->channel[ch])
+			continue;
+
+		priv->dma[ch].nr = ch;
+
+		if (IS_TX(priv->dma[ch].nr)) {
+			ltq_dma_alloc_tx(&priv->dma[ch]);
+			request_irq(irq, ltq_etop_dma_irq,
+				IRQF_DISABLED, "etop_tx", priv);
+		} else {
+			int desc;
+			ltq_dma_alloc_rx(&priv->dma[ch]);
+			for (desc = 0; desc < LTQ_DESC_NUM; desc++)
+				if (ltq_etop_alloc_rx_skb(priv, ch, desc))
+					return -ENOMEM;
+			request_irq(irq, ltq_etop_dma_irq,
+				IRQF_DISABLED, "etop_rx", priv);
+		}
+		priv->dma[ch].irq = irq;
+	}
+	tasklet_init(&priv->rx_tasklet, ltq_etop_rx_tasklet,
+		(unsigned long)dev);
+	tasklet_init(&priv->tx_tasklet, ltq_etop_tx_tasklet,
+		(unsigned long)dev);
+	return 0;
+}
+
+static int
+ltq_etop_mdio_wr(struct mii_bus *bus, int phy_addr, int phy_reg, u16 phy_data)
+{
+	u32 val = MDIO_REQUEST |
+		((phy_addr & MDIO_ADDR_MASK) << MDIO_ADDR_OFFSET) |
+		((phy_reg & MDIO_REG_MASK) << MDIO_REG_OFFSET) |
+		phy_data;
+
+	while (ltq_etop_r32(LTQ_ETOP_MDIO) & MDIO_REQUEST)
+		;
+	ltq_etop_w32(val, LTQ_ETOP_MDIO);
+	return 0;
+}
+
+static int
+ltq_etop_mdio_rd(struct mii_bus *bus, int phy_addr, int phy_reg)
+{
+	u32 val = MDIO_REQUEST | MDIO_READ |
+		((phy_addr & MDIO_ADDR_MASK) << MDIO_ADDR_OFFSET) |
+		((phy_reg & MDIO_REG_MASK) << MDIO_REG_OFFSET);
+
+	while (ltq_etop_r32(LTQ_ETOP_MDIO) & MDIO_REQUEST)
+		;
+	ltq_etop_w32(val, LTQ_ETOP_MDIO);
+	while (ltq_etop_r32(LTQ_ETOP_MDIO) & MDIO_REQUEST)
+		;
+	val = ltq_etop_r32(LTQ_ETOP_MDIO) & MDIO_VAL_MASK;
+	return val;
+}
+
+static void
+ltq_etop_mdio_link(struct net_device *dev)
+{
+	struct ltq_mii_priv *priv = netdev_priv(dev);
+	struct phy_device *phydev = priv->phydev;
+
+	phy_print_status(phydev);
+}
+
+static int
+ltq_etop_mdio_probe(struct net_device *dev)
+{
+	struct ltq_mii_priv *priv = netdev_priv(dev);
+	struct phy_device *phydev = NULL;
+	int phy_addr;
+
+	for (phy_addr = 0; phy_addr < PHY_MAX_ADDR; phy_addr++) {
+		if (priv->mii_bus->phy_map[phy_addr]) {
+			phydev = priv->mii_bus->phy_map[phy_addr];
+			break;
+		}
+	}
+
+	if (!phydev) {
+		netdev_err(dev, "no PHY found\n");
+		return -ENODEV;
+	}
+
+	phydev = phy_connect(dev, dev_name(&phydev->dev), &ltq_etop_mdio_link,
+			0, PHY_INTERFACE_MODE_MII);
+
+	if (IS_ERR(phydev)) {
+		netdev_err(dev, "Could not attach to PHY\n");
+		return PTR_ERR(phydev);
+	}
+
+	phydev->supported &= (SUPPORTED_10baseT_Half
+			      | SUPPORTED_10baseT_Full
+			      | SUPPORTED_100baseT_Half
+			      | SUPPORTED_100baseT_Full
+			      | SUPPORTED_Autoneg
+			      | SUPPORTED_MII
+			      | SUPPORTED_TP);
+
+	phydev->advertising = phydev->supported;
+	priv->phydev = phydev;
+	pr_info("%s: attached PHY [%s] (phy_addr=%s, irq=%d)\n",
+	       dev->name, phydev->drv->name,
+	       dev_name(&phydev->dev), phydev->irq);
+
+	return 0;
+}
+
+static int
+ltq_etop_mdio_init(struct net_device *dev)
+{
+	struct ltq_mii_priv *priv = netdev_priv(dev);
+	int i;
+	int err;
+
+	priv->mii_bus = mdiobus_alloc();
+	if (!priv->mii_bus) {
+		netdev_err(dev, "failed to allocate mii bus\n");
+		err = -ENOMEM;
+		goto err_out;
+	}
+
+	priv->mii_bus->priv = dev;
+	priv->mii_bus->read = ltq_etop_mdio_rd;
+	priv->mii_bus->write = ltq_etop_mdio_wr;
+	priv->mii_bus->name = "ltq_mii";
+	snprintf(priv->mii_bus->id, MII_BUS_ID_SIZE, "%x", 0);
+	priv->mii_bus->irq = kmalloc(sizeof(int) * PHY_MAX_ADDR, GFP_KERNEL);
+	if (!priv->mii_bus->irq) {
+		err = -ENOMEM;
+		goto err_out_free_mdiobus;
+	}
+
+	for (i = 0; i < PHY_MAX_ADDR; ++i)
+		priv->mii_bus->irq[i] = PHY_POLL;
+
+	if (mdiobus_register(priv->mii_bus)) {
+		err = -ENXIO;
+		goto err_out_free_mdio_irq;
+	}
+
+	if (ltq_etop_mdio_probe(dev)) {
+		err = -ENXIO;
+		goto err_out_unregister_bus;
+	}
+	return 0;
+
+err_out_unregister_bus:
+	mdiobus_unregister(priv->mii_bus);
+err_out_free_mdio_irq:
+	kfree(priv->mii_bus->irq);
+err_out_free_mdiobus:
+	mdiobus_free(priv->mii_bus);
+err_out:
+	return err;
+}
+
+static void
+ltq_etop_mdio_cleanup(struct net_device *dev)
+{
+	struct ltq_mii_priv *priv = netdev_priv(dev);
+	phy_disconnect(priv->phydev);
+	mdiobus_unregister(priv->mii_bus);
+	kfree(priv->mii_bus->irq);
+	mdiobus_free(priv->mii_bus);
+}
+
+static int
+ltq_etop_open(struct net_device *dev)
+{
+	struct ltq_mii_priv *priv = netdev_priv(dev);
+	int ch;
+
+	for (ch = 0; ch < MAX_DMA_CHAN; ch++)
+		if (priv->pldata->channel[ch])
+			ltq_dma_open(&priv->dma[ch]);
+	netif_start_queue(dev);
+	return 0;
+}
+
+static int
+ltq_etop_stop(struct net_device *dev)
+{
+	struct ltq_mii_priv *priv = netdev_priv(dev);
+	int ch;
+
+	for (ch = 0; ch < MAX_DMA_CHAN; ch++)
+		if (priv->pldata->channel[ch])
+			ltq_dma_close(&priv->dma[ch]);
+	netif_stop_queue(dev);
+	return 0;
+}
+
+static int
+ltq_etop_tx(struct sk_buff *skb, struct net_device *dev)
+{
+	int ch = 1;
+	struct ltq_mii_priv *priv = netdev_priv(dev);
+	struct ltq_dma_desc *d = &priv->dma[ch].desc_base[priv->dma[ch].desc];
+	int len;
+	unsigned long flags;
+	u32 byte_offset;
+
+	len = skb->len < ETH_ZLEN ? ETH_ZLEN : skb->len;
+	dev->trans_start = jiffies;
+
+	if ((d->ctl & (LTQ_DMA_OWN | LTQ_DMA_C)) ||
+			priv->tx_skb[ch >> 1][priv->dma[ch].desc]) {
+		priv->stats.tx_errors++;
+		priv->stats.tx_dropped++;
+		dev_kfree_skb_any(skb);
+		netdev_err(dev, "tx ring full\n");
+		netif_stop_queue(dev);
+		return NETDEV_TX_BUSY;
+	}
+
+	/* dma needs to start on a 16 byte aligned address */
+	byte_offset = CPHYSADDR(skb->data) % 16;
+	priv->tx_skb[ch >> 1][priv->dma[ch].desc] = skb;
+
+	local_irq_save(flags);
+	d->addr = ((unsigned int) dma_map_single(NULL, skb->data, len,
+						DMA_TO_DEVICE)) - byte_offset;
+	wmb();
+	d->ctl = LTQ_DMA_OWN | LTQ_DMA_SOP | LTQ_DMA_EOP |
+		LTQ_DMA_TX_OFFSET(byte_offset) | (len & LTQ_DMA_SIZE_MASK);
+	local_irq_restore(flags);
+
+	priv->dma[ch].desc++;
+	priv->dma[ch].desc %= LTQ_DESC_NUM;
+
+	if (priv->dma[ch].desc_base[priv->dma[ch].desc].ctl & LTQ_DMA_OWN)
+		netif_stop_queue(dev);
+
+	priv->stats.tx_packets++;
+	priv->stats.tx_bytes += len;
+	return NETDEV_TX_OK;
+}
+
+static void
+ltq_etop_tx_timeout(struct net_device *dev)
+{
+	struct ltq_mii_priv *priv = netdev_priv(dev);
+
+	priv->stats.tx_errors++;
+	netif_wake_queue(dev);
+}
+
+static int
+ltq_etop_change_mtu(struct net_device *dev, int new_mtu)
+{
+	int retval = eth_change_mtu(dev, new_mtu);
+
+	if (!retval)
+		ltq_etop_w32((ETOP_PLEN_UNDER << 16) | new_mtu,
+			LTQ_ETOP_IGPLEN);
+	return retval;
+}
+
+static int
+ltq_etop_set_mac_address(struct net_device *dev, void *p)
+{
+	int retcode = eth_mac_addr(dev, p);
+
+	if (!retcode) {
+		/* store the mac for the unicast filter */
+		ltq_etop_w32(*((u32 *)dev->dev_addr), LTQ_ETOP_MAC_DA0);
+		ltq_etop_w32(*((u16 *)&dev->dev_addr[4]) << 16,
+			LTQ_ETOP_MAC_DA1);
+	}
+	return retcode;
+}
+
+static void
+ltq_etop_set_multicast_list(struct net_device *dev)
+{
+	/* ensure that the unicast filter is not enabled in promiscious mode */
+	if ((dev->flags & IFF_PROMISC) || (dev->flags & IFF_ALLMULTI))
+		ltq_etop_w32_mask(ETOP_FTCU, 0, LTQ_ETOP_ENETS0);
+	else
+		ltq_etop_w32_mask(0, ETOP_FTCU, LTQ_ETOP_ENETS0);
+}
+
+static int
+ltq_etop_init(struct net_device *dev)
+{
+	struct ltq_mii_priv *priv = netdev_priv(dev);
+	int err;
+
+	ether_setup(dev);
+	dev->watchdog_timeo = 10 * HZ;
+	err = ltq_etop_hw_init(dev);
+	if (err)
+		goto err_hw;
+	ltq_etop_change_mtu(dev, 1500);
+	err = ltq_etop_set_mac_address(dev, &priv->pldata->mac);
+	if (err)
+		goto err_netdev;
+	ltq_etop_set_multicast_list(dev);
+	err = ltq_etop_mdio_init(dev);
+	if (err)
+		goto err_netdev;
+	return 0;
+
+err_netdev:
+	unregister_netdev(dev);
+	free_netdev(dev);
+err_hw:
+	ltq_etop_hw_exit(dev);
+	return err;
+}
+
+static const struct net_device_ops ltq_eth_netdev_ops = {
+	.ndo_open = ltq_etop_open,
+	.ndo_stop = ltq_etop_stop,
+	.ndo_start_xmit = ltq_etop_tx,
+	.ndo_tx_timeout = ltq_etop_tx_timeout,
+	.ndo_change_mtu = ltq_etop_change_mtu,
+	.ndo_set_mac_address = ltq_etop_set_mac_address,
+	.ndo_validate_addr = eth_validate_addr,
+	.ndo_set_multicast_list = ltq_etop_set_multicast_list,
+	.ndo_init = ltq_etop_init,
+};
+
+static int __init
+ltq_etop_probe(struct platform_device *pdev)
+{
+	struct net_device *dev;
+	struct ltq_mii_priv *priv;
+	struct resource *res;
+	int err;
+
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	if (!res) {
+		dev_err(&pdev->dev, "failed to get etop resource\n");
+		err = -ENOENT;
+		goto err_out;
+	}
+
+	res = devm_request_mem_region(&pdev->dev, res->start,
+		resource_size(res), dev_name(&pdev->dev));
+	if (!res) {
+		dev_err(&pdev->dev, "failed to request etop resource\n");
+		err = -EBUSY;
+		goto err_out;
+	}
+
+	ltq_etop_membase = devm_ioremap_nocache(&pdev->dev,
+		res->start, resource_size(res));
+	if (!ltq_etop_membase) {
+		dev_err(&pdev->dev, "failed to remap etop engine %d\n",
+			pdev->id);
+		err = -ENOMEM;
+		goto err_out;
+	}
+
+	dev = alloc_etherdev(sizeof(struct ltq_mii_priv));
+	strcpy(dev->name, "eth%d");
+	dev->netdev_ops = &ltq_eth_netdev_ops;
+	priv = netdev_priv(dev);
+	priv->res = res;
+	priv->pldata = dev_get_platdata(&pdev->dev);
+
+	err = register_netdev(dev);
+	if (err)
+		goto err_free;
+
+	platform_set_drvdata(pdev, dev);
+	return 0;
+
+err_free:
+	kfree(dev);
+err_out:
+	return err;
+}
+
+static int __devexit
+ltq_etop_remove(struct platform_device *pdev)
+{
+	struct net_device *dev = platform_get_drvdata(pdev);
+
+	if (dev) {
+		netif_stop_queue(dev);
+		ltq_etop_hw_exit(dev);
+		ltq_etop_mdio_cleanup(dev);
+		unregister_netdev(dev);
+	}
+	return 0;
+}
+
+static struct platform_driver ltq_mii_driver = {
+	.remove = __devexit_p(ltq_etop_remove),
+	.driver = {
+		.name = "ltq_etop",
+		.owner = THIS_MODULE,
+	},
+};
+
+int __init
+init_ltq_etop(void)
+{
+	int ret = platform_driver_probe(&ltq_mii_driver, ltq_etop_probe);
+
+	if (ret)
+		pr_err("ltq_etop: Error registering platfom driver!");
+	return ret;
+}
+
+static void __exit
+exit_ltq_etop(void)
+{
+	platform_driver_unregister(&ltq_mii_driver);
+}
+
+module_init(init_ltq_etop);
+module_exit(exit_ltq_etop);
+
+MODULE_AUTHOR("John Crispin <blogic@openwrt.org>");
+MODULE_DESCRIPTION("Lantiq SoC ETOP");
+MODULE_LICENSE("GPL");
-- 
1.7.2.3


From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH] smsc9420: SMSC LAN9420 10/100 PCI ethernet adapter
Date: Tue,  9 Dec 2008 14:57:43 +0000
Message-ID: <1228834663-20907-1-git-send-email-steve.glendinning@smsc.com>
Cc: Vlad Lyalikov <vlad.lyalikov@smsc.com>,
	Ian Saturley <ian.saturley@smsc.com>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [86.54.240.115] ([86.54.240.115]:51172 "EHLO
	drevil2.shawell.net" rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751419AbYLIO5b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2008 09:57:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a driver for the LAN9240 PCI ethernet adapter.

For review, I'll re-submit later for inclusion (incorporating any
feedback as necessary).

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 MAINTAINERS            |    6 +
 drivers/net/Kconfig    |   16 +
 drivers/net/Makefile   |    1 +
 drivers/net/smsc9420.c | 1588 ++++++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/smsc9420.h |  304 +++++++++
 5 files changed, 1915 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/smsc9420.c
 create mode 100644 drivers/net/smsc9420.h

diff --git a/MAINTAINERS b/MAINTAINERS
index 2859e9a..c3074e2 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3915,6 +3915,12 @@ M:	steve.glendinning@smsc.com
 L:	netdev@vger.kernel.org
 S:	Supported
 
+SMSC9420 PCI ETHERNET DRIVER
+P:	Steve Glendinning
+M:	steve.glendinning@smsc.com
+L:	netdev@vger.kernel.org
+S:	Supported
+
 SMX UIO Interface
 P:	Ben Nizette
 M:	bn@niasdigital.com
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index e93f5d3..4490c08 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1638,6 +1638,22 @@ config EPIC100
 	  More specific information and updates are available from
 	  <http://www.scyld.com/network/epic100.html>.
 
+config SMSC9420
+	tristate "SMSC LAN9420 PCI ethernet adapter support"
+	depends on NET_PCI && PCI
+	select CRC32
+	select PHYLIB
+	select SMSC_PHY
+	help
+	  This is a driver for SMSC's LAN9420 PCI ethernet adapter.
+	  Say Y if you want it compiled into the kernel,
+	  and read the Ethernet-HOWTO, available from
+	  <http://www.linuxdoc.org/docs.html#howto>.
+
+	  This driver is also available as a module. The module will be
+	  called smsc9420.  If you want to compile it as a module, say M
+	  here and read <file:Documentation/kbuild/modules.txt>
+
 config SUNDANCE
 	tristate "Sundance Alta support"
 	depends on NET_PCI && PCI
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 35fbe12..e5c34b4 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -56,6 +56,7 @@ obj-$(CONFIG_PCNET32) += pcnet32.o
 obj-$(CONFIG_E100) += e100.o
 obj-$(CONFIG_TLAN) += tlan.o
 obj-$(CONFIG_EPIC100) += epic100.o
+obj-$(CONFIG_SMSC9420) += smsc9420.o
 obj-$(CONFIG_SIS190) += sis190.o
 obj-$(CONFIG_SIS900) += sis900.o
 obj-$(CONFIG_R6040) += r6040.o
diff --git a/drivers/net/smsc9420.c b/drivers/net/smsc9420.c
new file mode 100644
index 0000000..026513f
--- /dev/null
+++ b/drivers/net/smsc9420.c
@@ -0,0 +1,1588 @@
+ /***************************************************************************
+ *
+ * Copyright (C) 2007,2008  SMSC
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
+ *
+ ***************************************************************************
+ */
+
+#include <linux/kernel.h>
+#include <linux/netdevice.h>
+#include <linux/phy.h>
+#include <linux/pci.h>
+#include <linux/if_vlan.h>
+#include <linux/dma-mapping.h>
+#include <linux/crc32.h>
+#include <asm/unaligned.h>
+#include "smsc9420.h"
+
+#define DRV_NAME		"smsc9420"
+#define DRV_MDIONAME		"smsc9420-mdio"
+#define DRV_DESCRIPTION		"SMSC LAN9420 driver"
+#define DRV_VERSION		"1.00"
+
+MODULE_LICENSE("GPL");
+MODULE_VERSION(DRV_VERSION);
+
+struct smsc9420_dma_desc {
+	u32 status;
+	u32 length;
+	u32 buffer1;
+	u32 buffer2;
+};
+
+struct smsc9420_ring_info {
+	struct sk_buff *skb;
+	dma_addr_t mapping;
+};
+
+struct smsc9420_pdata {
+	void __iomem *base_addr;
+	struct pci_dev *pdev;
+	struct net_device *dev;
+
+	struct smsc9420_dma_desc *rx_ring;
+	struct smsc9420_dma_desc *tx_ring;
+	struct smsc9420_ring_info *tx_buffers;
+	struct smsc9420_ring_info *rx_buffers;
+	dma_addr_t rx_dma_addr;
+	dma_addr_t tx_dma_addr;
+	int tx_ring_head, tx_ring_tail;
+	int rx_ring_head, rx_ring_tail;
+
+	spinlock_t int_lock;
+	spinlock_t phy_lock;
+
+	struct napi_struct napi;
+
+	bool software_irq_signal;
+	bool rx_csum;
+	u32 debug_mode;
+
+	struct phy_device *phy_dev;
+	struct mii_bus *mii_bus;
+	int phy_irq[PHY_MAX_ADDR];
+	int last_duplex;
+	int last_carrier;
+};
+
+static const struct pci_device_id smsc9420_id_table[] = {
+	{ PCI_VENDOR_ID_9420, PCI_DEVICE_ID_9420, PCI_ANY_ID, PCI_ANY_ID, },
+	{ 0, }
+};
+
+MODULE_DEVICE_TABLE(pci, smsc9420_id_table);
+
+uint debug_mode = (DBG_MCAST | DBG_WARNING | DBG_INIT | DBG_CLOSE | DBG_LINK |
+	DBG_PWR);
+module_param(debug_mode, uint, 0);
+MODULE_PARM_DESC(debug_mode, "enables debugging messages");
+
+static inline u32 smsc9420_reg_read(struct smsc9420_pdata *pd, u32 offset)
+{
+	return ioread32(pd->base_addr + offset);
+}
+
+static inline void
+smsc9420_reg_write(struct smsc9420_pdata *pd, u32 offset, u32 value)
+{
+	iowrite32(value, pd->base_addr + offset);
+}
+
+static inline void smsc9420_pci_flush_write(struct smsc9420_pdata *pd)
+{
+	/* to ensure PCI write completion, we must perform a PCI read */
+	smsc9420_reg_read(pd, ID_REV);
+}
+
+static int smsc9420_mii_read(struct mii_bus *bus, int phyaddr, int regidx)
+{
+	struct smsc9420_pdata *pd = (struct smsc9420_pdata *)bus->priv;
+	unsigned long flags;
+	u32 addr;
+	int i, reg = -EIO;
+
+	spin_lock_irqsave(&pd->phy_lock, flags);
+
+	/*  confirm MII not busy */
+	if ((smsc9420_reg_read(pd, MII_ACCESS) & MII_ACCESS_MII_BUSY_)) {
+		SMSC_WARNING("MII is busy???");
+		goto out;
+	}
+
+	/* set the address, index & direction (read from PHY) */
+	addr = ((phyaddr & 0x1F) << 11) | ((regidx & 0x1F) << 6) |
+		MII_ACCESS_MII_READ_;
+	smsc9420_reg_write(pd, MII_ACCESS, addr);
+
+	/* wait for read to complete with 50us timeout */
+	for (i = 0; i < 5; i++) {
+		if (!(smsc9420_reg_read(pd, MII_ACCESS) &
+			MII_ACCESS_MII_BUSY_)) {
+			reg = (u16)smsc9420_reg_read(pd, MII_DATA);
+			goto out;
+		}
+		udelay(10);
+	}
+
+	SMSC_WARNING("MII busy timeout!");
+
+out:
+	spin_unlock_irqrestore(&pd->phy_lock, flags);
+	return reg;
+}
+
+static int smsc9420_mii_write(struct mii_bus *bus, int phyaddr, int regidx,
+			   u16 val)
+{
+	struct smsc9420_pdata *pd = (struct smsc9420_pdata *)bus->priv;
+	unsigned long flags;
+	u32 addr;
+	int i, reg = -EIO;
+
+	spin_lock_irqsave(&pd->phy_lock, flags);
+
+	/* confirm MII not busy */
+	if ((smsc9420_reg_read(pd, MII_ACCESS) & MII_ACCESS_MII_BUSY_)) {
+		SMSC_WARNING("MII is busy???");
+		goto out;
+	}
+
+	/* put the data to write in the MAC */
+	smsc9420_reg_write(pd, MII_DATA, (u32)val);
+
+	/* set the address, index & direction (write to PHY) */
+	addr = ((phyaddr & 0x1F) << 11) | ((regidx & 0x1F) << 6) |
+		MII_ACCESS_MII_WRITE_;
+	smsc9420_reg_write(pd, MII_ACCESS, addr);
+
+	/* wait for write to complete with 50us timeout */
+	for (i = 0; i < 5; i++) {
+		if (!(smsc9420_reg_read(pd, MII_ACCESS) &
+			MII_ACCESS_MII_BUSY_)) {
+			reg = 0;
+			goto out;
+		}
+		udelay(10);
+	}
+
+	SMSC_WARNING("MII busy timeout!");
+
+out:
+	spin_unlock_irqrestore(&pd->phy_lock, flags);
+	return reg;
+}
+
+/* Returns hash bit number for given MAC address
+ * Example:
+ * 01 00 5E 00 00 01 -> returns bit number 31 */
+static u32 smsc9420_hash(u8 addr[ETH_ALEN])
+{
+	return (ether_crc(ETH_ALEN, addr) >> 26) & 0x3f;
+}
+
+static int smsc9420_eeprom_reload(struct smsc9420_pdata *pd)
+{
+	int timeout = 100000;
+
+	BUG_ON(!pd);
+
+	if (smsc9420_reg_read(pd, E2P_CMD) & E2P_CMD_EPC_BUSY_) {
+		SMSC_TRACE(DBG_INIT, "smsc9420_eeprom_reload: Eeprom busy");
+		return -EIO;
+	}
+
+	smsc9420_reg_write(pd, E2P_CMD,
+		(E2P_CMD_EPC_BUSY_ | E2P_CMD_EPC_CMD_RELOAD_));
+
+	do {
+		udelay(10);
+		if (!(smsc9420_reg_read(pd, E2P_CMD) & E2P_CMD_EPC_BUSY_))
+			return 0;
+	} while (timeout--);
+
+	SMSC_WARNING("smsc9420_eeprom_reload: Eeprom timed out");
+	return -EIO;
+}
+
+/* Standard ioctls for mii-tool */
+static int smsc9420_do_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
+{
+	struct smsc9420_pdata *pd = netdev_priv(dev);
+
+	if (!netif_running(dev) || !pd->phy_dev)
+		return -EINVAL;
+
+	return phy_mii_ioctl(pd->phy_dev, if_mii(ifr), cmd);
+}
+
+static int smsc9420_ethtool_get_settings(struct net_device *dev,
+					 struct ethtool_cmd *cmd)
+{
+	struct smsc9420_pdata *pd = netdev_priv(dev);
+
+	cmd->maxtxpkt = 1;
+	cmd->maxrxpkt = 1;
+	return phy_ethtool_gset(pd->phy_dev, cmd);
+}
+
+static int smsc9420_ethtool_set_settings(struct net_device *dev,
+					 struct ethtool_cmd *cmd)
+{
+	struct smsc9420_pdata *pd = netdev_priv(dev);
+
+	return phy_ethtool_sset(pd->phy_dev, cmd);
+}
+
+static void smsc9420_ethtool_get_drvinfo(struct net_device *netdev,
+					 struct ethtool_drvinfo *drvinfo)
+{
+	struct smsc9420_pdata *pd = netdev_priv(netdev);
+
+	strcpy(drvinfo->driver, DRV_NAME);
+	strcpy(drvinfo->bus_info, pci_name(pd->pdev));
+	strcpy(drvinfo->version, DRV_VERSION);
+}
+
+static u32 smsc9420_ethtool_get_msglevel(struct net_device *netdev)
+{
+	struct smsc9420_pdata *pd = netdev_priv(netdev);
+	return pd->debug_mode;
+}
+
+static void smsc9420_ethtool_set_msglevel(struct net_device *netdev, u32 data)
+{
+	struct smsc9420_pdata *pd = netdev_priv(netdev);
+	pd->debug_mode = data;
+}
+
+static int smsc9420_ethtool_nway_reset(struct net_device *netdev)
+{
+	struct smsc9420_pdata *pd = netdev_priv(netdev);
+	return phy_start_aneg(pd->phy_dev);
+}
+
+static const struct ethtool_ops smsc9420_ethtool_ops = {
+	.get_settings = smsc9420_ethtool_get_settings,
+	.set_settings = smsc9420_ethtool_set_settings,
+	.get_drvinfo = smsc9420_ethtool_get_drvinfo,
+	.get_msglevel = smsc9420_ethtool_get_msglevel,
+	.set_msglevel = smsc9420_ethtool_set_msglevel,
+	.nway_reset = smsc9420_ethtool_nway_reset,
+	.get_link = ethtool_op_get_link,
+};
+
+/* Sets the device MAC address to dev_addr */
+static void smsc9420_set_mac_address(struct net_device *dev)
+{
+	struct smsc9420_pdata *pd = netdev_priv(dev);
+	u8 *dev_addr = dev->dev_addr;
+	u32 mac_high16 = (dev_addr[5] << 8) | dev_addr[4];
+	u32 mac_low32 = (dev_addr[3] << 24) | (dev_addr[2] << 16) |
+	    (dev_addr[1] << 8) | dev_addr[0];
+
+	smsc9420_reg_write(pd, ADDRH, mac_high16);
+	smsc9420_reg_write(pd, ADDRL, mac_low32);
+}
+
+static void smsc9420_check_mac_address(struct net_device *dev)
+{
+	struct smsc9420_pdata *pd = netdev_priv(dev);
+
+	/* Check if mac address has been specified when bringing interface up */
+	if (is_valid_ether_addr(dev->dev_addr)) {
+		smsc9420_set_mac_address(dev);
+		SMSC_TRACE(DBG_INIT,
+			"MAC Address is specified by configuration");
+	} else {
+		/* Try reading mac address from device. if EEPROM is present
+		 * it will already have been set */
+		u32 mac_high16 = smsc9420_reg_read(pd, ADDRH);
+		u32 mac_low32 = smsc9420_reg_read(pd, ADDRL);
+		dev->dev_addr[0] = (u8)(mac_low32);
+		dev->dev_addr[1] = (u8)(mac_low32 >> 8);
+		dev->dev_addr[2] = (u8)(mac_low32 >> 16);
+		dev->dev_addr[3] = (u8)(mac_low32 >> 24);
+		dev->dev_addr[4] = (u8)(mac_high16);
+		dev->dev_addr[5] = (u8)(mac_high16 >> 8);
+
+		if (is_valid_ether_addr(dev->dev_addr)) {
+			/* eeprom values are valid  so use them */
+			SMSC_TRACE(DBG_INIT,
+				"Mac Address is read from EEPROM");
+		} else {
+			/* eeprom values are invalid, generate random MAC */
+			random_ether_addr(dev->dev_addr);
+			smsc9420_set_mac_address(dev);
+			SMSC_TRACE(DBG_INIT,
+				"MAC Address is set to random_ether_addr");
+		}
+	}
+}
+
+static void smsc9420_stop_tx(struct smsc9420_pdata *pd)
+{
+	u32 dmac_control, mac_cr, dma_intr_ena;
+	int timeOut = 1000;
+
+	/* disable TX DMAC */
+	dmac_control = smsc9420_reg_read(pd, DMAC_CONTROL);
+	dmac_control &= (~DMAC_CONTROL_ST_);
+	smsc9420_reg_write(pd, DMAC_CONTROL, dmac_control);
+
+	/* Wait max 10ms for transmit process to stop */
+	while (timeOut--) {
+		if (smsc9420_reg_read(pd, DMAC_STATUS) & DMAC_STS_TS_)
+			break;
+		udelay(10);
+	}
+
+	if (!timeOut)
+		SMSC_WARNING("TX DMAC failed to stop");
+
+	/* ACK Tx DMAC stop bit */
+	smsc9420_reg_write(pd, DMAC_STATUS, DMAC_STS_TXPS_);
+
+	/* mask TX DMAC interrupts */
+	dma_intr_ena = smsc9420_reg_read(pd, DMAC_INTR_ENA);
+	dma_intr_ena &= ~(DMAC_INTR_ENA_TX_);
+	smsc9420_reg_write(pd, DMAC_INTR_ENA, dma_intr_ena);
+	smsc9420_pci_flush_write(pd);
+
+	/* stop MAC TX */
+	mac_cr = smsc9420_reg_read(pd, MAC_CR) & (~MAC_CR_TXEN_);
+	smsc9420_reg_write(pd, MAC_CR, mac_cr);
+	smsc9420_pci_flush_write(pd);
+}
+
+static void smsc9420_free_tx_ring(struct smsc9420_pdata *pd)
+{
+	int i;
+
+	BUG_ON(!pd->tx_ring);
+
+	if (!pd->tx_buffers)
+		return;
+
+	for (i = 0; i < TX_RING_SIZE; i++) {
+		struct sk_buff *skb = pd->tx_buffers[i].skb;
+
+		if (skb) {
+			BUG_ON(!pd->tx_buffers[i].mapping);
+			pci_unmap_single(pd->pdev, pd->tx_buffers[i].mapping,
+					 skb->len, PCI_DMA_TODEVICE);
+			dev_kfree_skb_any(skb);
+		}
+
+		pd->tx_ring[i].status = 0;
+		pd->tx_ring[i].length = 0;
+		pd->tx_ring[i].buffer1 = 0;
+		pd->tx_ring[i].buffer2 = 0;
+	}
+	wmb();
+
+	kfree(pd->tx_buffers);
+	pd->tx_buffers = NULL;
+
+	pd->tx_ring_head = 0;
+	pd->tx_ring_tail = 0;
+}
+
+static void smsc9420_free_rx_ring(struct smsc9420_pdata *pd)
+{
+	int i;
+
+	BUG_ON(!pd->rx_ring);
+
+	if (!pd->rx_buffers)
+		return;
+
+	for (i = 0; i < RX_RING_SIZE; i++) {
+		if (pd->rx_buffers[i].skb)
+			dev_kfree_skb_any(pd->rx_buffers[i].skb);
+
+		if (pd->rx_buffers[i].mapping)
+			pci_unmap_single(pd->pdev, pd->rx_buffers[i].mapping,
+				PKT_BUF_SZ, PCI_DMA_FROMDEVICE);
+
+		pd->rx_ring[i].status = 0;
+		pd->rx_ring[i].length = 0;
+		pd->rx_ring[i].buffer1 = 0;
+		pd->rx_ring[i].buffer2 = 0;
+	}
+	wmb();
+
+	kfree(pd->rx_buffers);
+	pd->rx_buffers = NULL;
+
+	pd->rx_ring_head = 0;
+	pd->rx_ring_tail = 0;
+}
+
+static void smsc9420_stop_rx(struct smsc9420_pdata *pd)
+{
+	int timeOut = 1000;
+	u32 mac_cr, dmac_control, dma_intr_ena;
+
+	/* mask RX DMAC interrupts */
+	dma_intr_ena = smsc9420_reg_read(pd, DMAC_INTR_ENA);
+	dma_intr_ena &= (~DMAC_INTR_ENA_RX_);
+	smsc9420_reg_write(pd, DMAC_INTR_ENA, dma_intr_ena);
+	smsc9420_pci_flush_write(pd);
+
+	/* stop RX MAC prior to stoping DMA */
+	mac_cr = smsc9420_reg_read(pd, MAC_CR) & (~MAC_CR_RXEN_);
+	smsc9420_reg_write(pd, MAC_CR, mac_cr);
+	smsc9420_pci_flush_write(pd);
+
+	/* stop RX DMAC */
+	dmac_control = smsc9420_reg_read(pd, DMAC_CONTROL);
+	dmac_control &= (~DMAC_CONTROL_SR_);
+	smsc9420_reg_write(pd, DMAC_CONTROL, dmac_control);
+	smsc9420_pci_flush_write(pd);
+
+	/* wait up to 10ms for receive to stop */
+	while (timeOut--) {
+		if (smsc9420_reg_read(pd, DMAC_STATUS) & DMAC_STS_RS_)
+			break;
+		udelay(10);
+	}
+
+	if (!timeOut)
+		SMSC_WARNING("RX DMAC did not stop! timeout.");
+
+	/* ACK the Rx DMAC stop bit */
+	smsc9420_reg_write(pd, DMAC_STATUS, DMAC_STS_RXPS_);
+}
+
+static irqreturn_t smsc9420_isr(int irq, void *dev_id)
+{
+	struct smsc9420_pdata *pd = dev_id;
+	u32 int_cfg, int_sts, int_ctl;
+	irqreturn_t ret = IRQ_NONE;
+	ulong flags;
+
+	BUG_ON(!pd);
+	BUG_ON(!pd->base_addr);
+
+	int_cfg = smsc9420_reg_read(pd, INT_CFG);
+
+	/* check if it's our interrupt */
+	if ((int_cfg & (INT_CFG_IRQ_EN_ | INT_CFG_IRQ_INT_)) !=
+	    (INT_CFG_IRQ_EN_ | INT_CFG_IRQ_INT_))
+		return IRQ_NONE;
+
+	int_sts = smsc9420_reg_read(pd, INT_STAT);
+
+	if (likely(INT_STAT_DMAC_INT_ & int_sts)) {
+		u32 status = smsc9420_reg_read(pd, DMAC_STATUS);
+		u32 ints_to_clear = 0;
+
+		if (status & DMAC_STS_TX_) {
+			ints_to_clear |= (DMAC_STS_TX_ | DMAC_STS_NIS_);
+			netif_wake_queue(pd->dev);
+		}
+
+		if (status & DMAC_STS_RX_) {
+			/* mask RX DMAC interrupts */
+			u32 dma_intr_ena = smsc9420_reg_read(pd, DMAC_INTR_ENA);
+			dma_intr_ena &= (~DMAC_INTR_ENA_RX_);
+			smsc9420_reg_write(pd, DMAC_INTR_ENA, dma_intr_ena);
+			smsc9420_pci_flush_write(pd);
+
+			ints_to_clear |= (DMAC_STS_RX_ | DMAC_STS_NIS_);
+			netif_rx_schedule(pd->dev, &pd->napi);
+		}
+
+		if (ints_to_clear)
+			smsc9420_reg_write(pd, DMAC_STATUS, ints_to_clear);
+
+		ret = IRQ_HANDLED;
+	}
+
+	if (unlikely(INT_STAT_SW_INT_ & int_sts)) {
+		/* mask software interrupt */
+		spin_lock_irqsave(&pd->int_lock, flags);
+		int_ctl = smsc9420_reg_read(pd, INT_CTL);
+		int_ctl &= (~INT_CTL_SW_INT_EN_);
+		smsc9420_reg_write(pd, INT_CTL, int_ctl);
+		spin_unlock_irqrestore(&pd->int_lock, flags);
+
+		smsc9420_reg_write(pd, INT_STAT, INT_STAT_SW_INT_);
+		pd->software_irq_signal = true;
+		smp_wmb();
+
+		ret = IRQ_HANDLED;
+	}
+
+	/* to ensure PCI write completion, we must perform a PCI read */
+	smsc9420_pci_flush_write(pd);
+
+	return ret;
+}
+
+static void smsc9420_dmac_soft_reset(struct smsc9420_pdata *pd)
+{
+	smsc9420_reg_write(pd, BUS_MODE, BUS_MODE_SWR_);
+	smsc9420_reg_read(pd, BUS_MODE);
+	udelay(2);
+	if (smsc9420_reg_read(pd, BUS_MODE) & BUS_MODE_SWR_)
+		SMSC_WARNING("Software reset not cleared");
+}
+
+static int smsc9420_stop(struct net_device *dev)
+{
+	struct smsc9420_pdata *pd = netdev_priv(dev);
+	u32 int_cfg;
+	ulong flags;
+
+	BUG_ON(!pd);
+	BUG_ON(!pd->phy_dev);
+
+	/* disable master interrupt */
+	spin_lock_irqsave(&pd->int_lock, flags);
+	int_cfg = smsc9420_reg_read(pd, INT_CFG) & (~INT_CFG_IRQ_EN_);
+	smsc9420_reg_write(pd, INT_CFG, int_cfg);
+	spin_unlock_irqrestore(&pd->int_lock, flags);
+
+	netif_tx_disable(dev);
+	napi_disable(&pd->napi);
+
+	smsc9420_stop_tx(pd);
+	smsc9420_free_tx_ring(pd);
+
+	smsc9420_stop_rx(pd);
+	smsc9420_free_rx_ring(pd);
+
+	free_irq(dev->irq, pd);
+
+	smsc9420_dmac_soft_reset(pd);
+
+	phy_stop(pd->phy_dev);
+
+	phy_disconnect(pd->phy_dev);
+	pd->phy_dev = NULL;
+	mdiobus_unregister(pd->mii_bus);
+	mdiobus_free(pd->mii_bus);
+
+	return 0;
+}
+
+static void smsc9420_rx_count_stats(struct net_device *dev, u32 desc_status)
+{
+	if (unlikely(desc_status & RDES0_ERROR_SUMMARY_)) {
+		dev->stats.rx_errors++;
+		if (desc_status & RDES0_DESCRIPTOR_ERROR_)
+			dev->stats.rx_over_errors++;
+		else if (desc_status & (RDES0_FRAME_TOO_LONG_ |
+			RDES0_RUNT_FRAME_ | RDES0_COLLISION_SEEN_))
+			dev->stats.rx_frame_errors++;
+		else if (desc_status & RDES0_CRC_ERROR_)
+			dev->stats.rx_crc_errors++;
+	}
+
+	if (unlikely(desc_status & RDES0_LENGTH_ERROR_))
+		dev->stats.rx_length_errors++;
+
+	if (unlikely(!((desc_status & RDES0_LAST_DESCRIPTOR_) &&
+		(desc_status & RDES0_FIRST_DESCRIPTOR_))))
+		dev->stats.rx_length_errors++;
+
+	if (desc_status & RDES0_MULTICAST_FRAME_)
+		dev->stats.multicast++;
+}
+
+static void smsc9420_rx_handoff(struct smsc9420_pdata *pd, const int index,
+				const u32 status)
+{
+	struct net_device *dev = pd->dev;
+	struct sk_buff *skb;
+	u16 packet_length = (status & RDES0_FRAME_LENGTH_MASK_)
+		>> RDES0_FRAME_LENGTH_SHFT_;
+
+	/* remove crc from packet lendth */
+	packet_length -= 4;
+
+	if (pd->rx_csum)
+		packet_length -= 2;
+
+	dev->stats.rx_packets++;
+	dev->stats.rx_bytes += packet_length;
+
+	pci_unmap_single(pd->pdev, pd->rx_buffers[index].mapping,
+		PKT_BUF_SZ, PCI_DMA_FROMDEVICE);
+	pd->rx_buffers[index].mapping = 0;
+
+	skb = pd->rx_buffers[index].skb;
+	pd->rx_buffers[index].skb = NULL;
+
+	if (pd->rx_csum) {
+		u16 hw_csum = get_unaligned_le16(skb_tail_pointer(skb) +
+			NET_IP_ALIGN + packet_length + 4);
+		put_unaligned_le16(cpu_to_le16(hw_csum), &skb->csum);
+		skb->ip_summed = CHECKSUM_COMPLETE;
+	}
+
+	skb_reserve(skb, NET_IP_ALIGN);
+	skb_put(skb, packet_length);
+
+	skb->protocol = eth_type_trans(skb, dev);
+
+	netif_receive_skb(skb);
+	dev->last_rx = jiffies;
+}
+
+static int smsc9420_alloc_rx_buffer(struct smsc9420_pdata *pd, int index)
+{
+	struct sk_buff *skb = netdev_alloc_skb(pd->dev, PKT_BUF_SZ);
+	dma_addr_t mapping;
+
+	BUG_ON(pd->rx_buffers[index].skb);
+	BUG_ON(pd->rx_buffers[index].mapping);
+
+	if (unlikely(!skb)) {
+		SMSC_WARNING("Failed to allocate new skb!");
+		return -ENOMEM;
+	}
+
+	skb->dev = pd->dev;
+
+	mapping = pci_map_single(pd->pdev, skb_tail_pointer(skb),
+				 PKT_BUF_SZ, PCI_DMA_FROMDEVICE);
+	if (pci_dma_mapping_error(pd->pdev, mapping)) {
+		dev_kfree_skb_any(skb);
+		SMSC_WARNING("pci_map_single failed!");
+		return -ENOMEM;
+	}
+
+	pd->rx_buffers[index].skb = skb;
+	pd->rx_buffers[index].mapping = mapping;
+	pd->rx_ring[index].buffer1 = mapping + NET_IP_ALIGN;
+	pd->rx_ring[index].status = RDES0_OWN_;
+	wmb();
+
+	return 0;
+}
+
+static void smsc9420_alloc_new_rx_buffers(struct smsc9420_pdata *pd)
+{
+	while (pd->rx_ring_tail != pd->rx_ring_head) {
+		if (smsc9420_alloc_rx_buffer(pd, pd->rx_ring_tail))
+			break;
+
+		pd->rx_ring_tail = (pd->rx_ring_tail + 1) % RX_RING_SIZE;
+	}
+}
+
+static int smsc9420_rx_poll(struct napi_struct *napi, int budget)
+{
+	struct smsc9420_pdata *pd =
+		container_of(napi, struct smsc9420_pdata, napi);
+	struct net_device *dev = pd->dev;
+	u32 drop_frame_cnt, dma_intr_ena, status;
+	int work_done;
+
+	for (work_done = 0; work_done < budget; work_done++) {
+		rmb();
+		status = pd->rx_ring[pd->rx_ring_head].status;
+
+		/* stop if DMAC owns this dma descriptor */
+		if (status & RDES0_OWN_)
+			break;
+
+		smsc9420_rx_count_stats(dev, status);
+		smsc9420_rx_handoff(pd, pd->rx_ring_head, status);
+		pd->rx_ring_head = (pd->rx_ring_head + 1) % RX_RING_SIZE;
+		smsc9420_alloc_new_rx_buffers(pd);
+	}
+
+	drop_frame_cnt = smsc9420_reg_read(pd, MISS_FRAME_CNTR);
+	dev->stats.rx_dropped +=
+	    (drop_frame_cnt & 0xFFFF) + ((drop_frame_cnt >> 17) & 0x3FF);
+
+	/* Kick RXDMA */
+	smsc9420_reg_write(pd, RX_POLL_DEMAND, 1);
+	smsc9420_pci_flush_write(pd);
+
+	if (work_done < budget) {
+		netif_rx_complete(dev, &pd->napi);
+
+		/* re-enable RX DMA interrupts */
+		dma_intr_ena = smsc9420_reg_read(pd, DMAC_INTR_ENA);
+		dma_intr_ena |= (DMAC_INTR_ENA_RX_ | DMAC_INTR_ENA_NIS_);
+		smsc9420_reg_write(pd, DMAC_INTR_ENA, dma_intr_ena);
+		smsc9420_pci_flush_write(pd);
+	}
+	return work_done;
+}
+
+static void
+smsc9420_tx_update_stats(struct net_device *dev, u32 status, u32 length)
+{
+	if (unlikely(status & TDES0_ERROR_SUMMARY_)) {
+		dev->stats.tx_errors++;
+		if (status & (TDES0_EXCESSIVE_DEFERRAL_ |
+			TDES0_EXCESSIVE_COLLISIONS_))
+			dev->stats.tx_aborted_errors++;
+
+		if (status & (TDES0_LOSS_OF_CARRIER_ | TDES0_NO_CARRIER_))
+			dev->stats.tx_carrier_errors++;
+	} else {
+		dev->stats.tx_packets++;
+		dev->stats.tx_bytes += (length & 0x7FF);
+	}
+
+	if (unlikely(status & TDES0_EXCESSIVE_COLLISIONS_)) {
+		dev->stats.collisions += 16;
+	} else {
+		dev->stats.collisions +=
+			(status & TDES0_COLLISION_COUNT_MASK_) >>
+			TDES0_COLLISION_COUNT_SHFT_;
+	}
+
+	if (unlikely(status & TDES0_HEARTBEAT_FAIL_))
+		dev->stats.tx_heartbeat_errors++;
+}
+
+/* Check for completed dma transfers, update stats and free skbs */
+static void smsc9420_complete_tx(struct net_device *dev)
+{
+	struct smsc9420_pdata *pd = netdev_priv(dev);
+
+	while (pd->tx_ring_tail != pd->tx_ring_head) {
+		int index = pd->tx_ring_tail;
+		u32 status, length;
+
+		rmb();
+		status = pd->tx_ring[index].status;
+		length = pd->tx_ring[index].length;
+
+		/* Check if DMA still owns this descriptor */
+		if (unlikely(TDES0_OWN_ & status))
+			break;
+
+		smsc9420_tx_update_stats(dev, status, length);
+
+		BUG_ON(!pd->tx_buffers[index].skb);
+		BUG_ON(!pd->tx_buffers[index].mapping);
+
+		pci_unmap_single(pd->pdev, pd->tx_buffers[index].mapping,
+			pd->tx_buffers[index].skb->len, PCI_DMA_TODEVICE);
+		pd->tx_buffers[index].mapping = 0;
+
+		dev_kfree_skb_any(pd->tx_buffers[index].skb);
+		pd->tx_buffers[index].skb = NULL;
+
+		pd->tx_ring[index].buffer1 = 0;
+		wmb();
+
+		pd->tx_ring_tail = (pd->tx_ring_tail + 1) % TX_RING_SIZE;
+	}
+}
+
+static int smsc9420_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct smsc9420_pdata *pd = netdev_priv(dev);
+	dma_addr_t mapping;
+	int index = pd->tx_ring_head;
+	u32 tmp_desc1;
+	bool about_to_take_last_desc =
+		(((pd->tx_ring_head + 2) % TX_RING_SIZE) == pd->tx_ring_tail);
+
+	smsc9420_complete_tx(dev);
+
+	rmb();
+	BUG_ON(pd->tx_ring[index].status & TDES0_OWN_);
+	BUG_ON(pd->tx_buffers[index].skb);
+	BUG_ON(pd->tx_buffers[index].mapping);
+
+	mapping = pci_map_single(pd->pdev, skb->data,
+				 skb->len, PCI_DMA_TODEVICE);
+	if (pci_dma_mapping_error(pd->pdev, mapping)) {
+		SMSC_WARNING("pci_map_single failed, dropping packet");
+		return NETDEV_TX_BUSY;
+	}
+
+	pd->tx_buffers[index].skb = skb;
+	pd->tx_buffers[index].mapping = mapping;
+
+	tmp_desc1 = (TDES1_LS_ | ((u32)skb->len & 0x7FF));
+	if (unlikely(about_to_take_last_desc)) {
+		tmp_desc1 |= TDES1_IC_;
+		netif_stop_queue(pd->dev);
+	}
+
+	/* check if we are at the last descriptor and need to set EOR */
+	if (unlikely(index == (TX_RING_SIZE - 1)))
+		tmp_desc1 |= TDES1_TER_;
+
+	pd->tx_ring[index].buffer1 = mapping;
+	pd->tx_ring[index].length = tmp_desc1;
+	wmb();
+
+	/* increment head */
+	pd->tx_ring_head = (pd->tx_ring_head + 1) % TX_RING_SIZE;
+
+	/* assign ownership to DMAC */
+	pd->tx_ring[index].status = TDES0_OWN_;
+	wmb();
+
+	/* kick the DMA */
+	smsc9420_reg_write(pd, TX_POLL_DEMAND, 1);
+	smsc9420_pci_flush_write(pd);
+
+	dev->trans_start = jiffies;
+
+	return NETDEV_TX_OK;
+}
+
+static struct net_device_stats *smsc9420_get_stats(struct net_device *dev)
+{
+	struct smsc9420_pdata *pd = netdev_priv(dev);
+	u32 counter = smsc9420_reg_read(pd, MISS_FRAME_CNTR);
+	dev->stats.rx_dropped +=
+	    (counter & 0x0000FFFF) + ((counter >> 17) & 0x000003FF);
+	return &dev->stats;
+}
+
+static void smsc9420_set_multicast_list(struct net_device *dev)
+{
+	struct smsc9420_pdata *pd = netdev_priv(dev);
+	u32 mac_cr = smsc9420_reg_read(pd, MAC_CR);
+
+	if (dev->flags & IFF_PROMISC) {
+		SMSC_TRACE(DBG_MCAST, "Promiscuous Mode Enabled");
+		mac_cr |= MAC_CR_PRMS_;
+		mac_cr &= (~MAC_CR_MCPAS_);
+		mac_cr &= (~MAC_CR_HPFILT_);
+	} else if (dev->flags & IFF_ALLMULTI) {
+		SMSC_TRACE(DBG_MCAST, "Receive all Multicast Enabled");
+		mac_cr &= (~MAC_CR_PRMS_);
+		mac_cr |= MAC_CR_MCPAS_;
+		mac_cr &= (~MAC_CR_HPFILT_);
+	} else if (dev->mc_count > 0) {
+		struct dev_mc_list *mc_list = dev->mc_list;
+		u32 hash_lo = 0, hash_hi = 0;
+
+		SMSC_TRACE(DBG_MCAST, "Multicast filter enabled");
+		while (mc_list) {
+			u32 bit_num = smsc9420_hash(mc_list->dmi_addr);
+			u32 mask = 1 << (bit_num & 0x1F);
+
+			if (bit_num & 0x20)
+				hash_hi |= mask;
+			else
+				hash_lo |= mask;
+
+			mc_list = mc_list->next;
+		}
+		smsc9420_reg_write(pd, HASHH, hash_hi);
+		smsc9420_reg_write(pd, HASHL, hash_lo);
+
+		mac_cr &= (~MAC_CR_PRMS_);
+		mac_cr &= (~MAC_CR_MCPAS_);
+		mac_cr |= MAC_CR_HPFILT_;
+	} else {
+		SMSC_TRACE(DBG_MCAST, "Receive own packets only.");
+		smsc9420_reg_write(pd, HASHH, 0);
+		smsc9420_reg_write(pd, HASHL, 0);
+
+		mac_cr &= (~MAC_CR_PRMS_);
+		mac_cr &= (~MAC_CR_MCPAS_);
+		mac_cr &= (~MAC_CR_HPFILT_);
+	}
+
+	smsc9420_reg_write(pd, MAC_CR, mac_cr);
+	smsc9420_pci_flush_write(pd);
+}
+
+static u8 smsc9420_resolve_flowctrl_fulldplx(u16 lcladv, u16 rmtadv)
+{
+	u8 cap = 0;
+
+	if (lcladv & ADVERTISE_PAUSE_CAP) {
+		if (lcladv & ADVERTISE_PAUSE_ASYM) {
+			if (rmtadv & LPA_PAUSE_CAP)
+				cap = FLOW_CTRL_TX | FLOW_CTRL_RX;
+			else if (rmtadv & LPA_PAUSE_ASYM)
+				cap = FLOW_CTRL_RX;
+		} else {
+			if (rmtadv & LPA_PAUSE_CAP)
+				cap = FLOW_CTRL_TX | FLOW_CTRL_RX;
+		}
+	} else if (lcladv & ADVERTISE_PAUSE_ASYM) {
+		if ((rmtadv & LPA_PAUSE_CAP) && (rmtadv & LPA_PAUSE_ASYM))
+			cap = FLOW_CTRL_TX;
+	}
+
+	return cap;
+}
+
+static void smsc9420_phy_update_flowcontrol(struct smsc9420_pdata *pd)
+{
+	struct phy_device *phy_dev = pd->phy_dev;
+	u32 flow;
+
+	if (phy_dev->duplex == DUPLEX_FULL) {
+		u16 lcladv = phy_read(phy_dev, MII_ADVERTISE);
+		u16 rmtadv = phy_read(phy_dev, MII_LPA);
+		u8 cap = smsc9420_resolve_flowctrl_fulldplx(lcladv, rmtadv);
+
+		if (cap & FLOW_CTRL_RX)
+			flow = 0xFFFF0002;
+		else
+			flow = 0;
+
+		SMSC_TRACE(DBG_LINK, "rx pause %s, tx pause %s",
+			(cap & FLOW_CTRL_RX ? "enabled" : "disabled"),
+			(cap & FLOW_CTRL_TX ? "enabled" : "disabled"));
+	} else {
+		SMSC_TRACE(DBG_LINK, "half duplex");
+		flow = 0;
+	}
+
+	smsc9420_reg_write(pd, FLOW, flow);
+}
+
+/* Update link mode if anything has changed.  Called periodically when the
+ * PHY is in polling mode, even if nothing has changed. */
+static void smsc9420_phy_adjust_link(struct net_device *dev)
+{
+	struct smsc9420_pdata *pd = netdev_priv(dev);
+	struct phy_device *phy_dev = pd->phy_dev;
+	int carrier;
+
+	if (phy_dev->duplex != pd->last_duplex) {
+		unsigned int mac_cr;
+		SMSC_TRACE(DBG_LINK, "duplex state has changed");
+
+		mac_cr = smsc9420_reg_read(pd, MAC_CR);
+		if (phy_dev->duplex) {
+			SMSC_TRACE(DBG_LINK, "full duplex mode");
+			mac_cr |= MAC_CR_FDPX_;
+		} else {
+			SMSC_TRACE(DBG_LINK, "half duplex mode");
+			mac_cr &= ~MAC_CR_FDPX_;
+		}
+		smsc9420_reg_write(pd, MAC_CR, mac_cr);
+
+		smsc9420_phy_update_flowcontrol(pd);
+		pd->last_duplex = phy_dev->duplex;
+	}
+
+	carrier = netif_carrier_ok(dev);
+	if (carrier != pd->last_carrier) {
+		if (carrier)
+			SMSC_TRACE(DBG_LINK, "carrier OK");
+		else
+			SMSC_TRACE(DBG_LINK, "no carrier");
+		pd->last_carrier = carrier;
+	}
+}
+
+static int smsc9420_mii_probe(struct net_device *dev)
+{
+	struct smsc9420_pdata *pd = netdev_priv(dev);
+	struct phy_device *phydev = NULL;
+
+	BUG_ON(pd->phy_dev);
+
+	/* Device only supports internal PHY at address 1 */
+	if (!pd->mii_bus->phy_map[1]) {
+		pr_err("%s: no PHY found at address 1\n", dev->name);
+		return -ENODEV;
+	}
+
+	phydev = pd->mii_bus->phy_map[1];
+	SMSC_TRACE(DBG_INIT, "PHY addr %d, phy_id 0x%08X", phydev->addr,
+		phydev->phy_id);
+
+	phydev = phy_connect(dev, phydev->dev.bus_id,
+		&smsc9420_phy_adjust_link, 0, PHY_INTERFACE_MODE_MII);
+
+	if (IS_ERR(phydev)) {
+		pr_err("%s: Could not attach to PHY\n", dev->name);
+		return PTR_ERR(phydev);
+	}
+
+	pr_info("%s: attached PHY driver [%s] (mii_bus:phy_addr=%s, irq=%d)\n",
+		dev->name, phydev->drv->name, phydev->dev.bus_id, phydev->irq);
+
+	/* mask with MAC supported features */
+	phydev->supported &= (PHY_BASIC_FEATURES | SUPPORTED_Pause |
+			      SUPPORTED_Asym_Pause);
+	phydev->advertising = phydev->supported;
+
+	pd->phy_dev = phydev;
+	pd->last_duplex = -1;
+	pd->last_carrier = -1;
+
+	SMSC_TRACE(DBG_INIT, "phy initialised succesfully");
+	return 0;
+}
+
+static int smsc9420_mii_init(struct net_device *dev)
+{
+	struct smsc9420_pdata *pd = netdev_priv(dev);
+	int err = -ENXIO, i;
+
+	pd->mii_bus = mdiobus_alloc();
+	if (!pd->mii_bus) {
+		err = -ENOMEM;
+		goto err_out_1;
+	}
+	pd->mii_bus->name = DRV_MDIONAME;
+	snprintf(pd->mii_bus->id, MII_BUS_ID_SIZE, "%x",
+		(pd->pdev->bus->number << 8) | pd->pdev->devfn);
+	pd->mii_bus->priv = pd;
+	pd->mii_bus->read = smsc9420_mii_read;
+	pd->mii_bus->write = smsc9420_mii_write;
+	pd->mii_bus->irq = pd->phy_irq;
+	for (i = 0; i < PHY_MAX_ADDR; ++i)
+		pd->mii_bus->irq[i] = PHY_POLL;
+
+	/* Mask all PHYs except ID 1 (internal) */
+	pd->mii_bus->phy_mask = ~(1 << 1);
+
+	if (mdiobus_register(pd->mii_bus)) {
+		SMSC_WARNING("Error registering mii bus");
+		goto err_out_free_bus_2;
+	}
+
+	if (smsc9420_mii_probe(dev) < 0) {
+		SMSC_WARNING("Error probing mii bus");
+		goto err_out_unregister_bus_3;
+	}
+
+	return 0;
+
+err_out_unregister_bus_3:
+	mdiobus_unregister(pd->mii_bus);
+err_out_free_bus_2:
+	mdiobus_free(pd->mii_bus);
+err_out_1:
+	return err;
+}
+
+static int smsc9420_alloc_tx_ring(struct smsc9420_pdata *pd)
+{
+	int i;
+
+	BUG_ON(!pd->tx_ring);
+
+	pd->tx_buffers = kmalloc((sizeof(struct smsc9420_ring_info) *
+		TX_RING_SIZE), GFP_KERNEL);
+	if (!pd->tx_buffers) {
+		SMSC_WARNING("Failed to allocated tx_buffers");
+		return -ENOMEM;
+	}
+
+	/* Initialize the TX Ring */
+	for (i = 0; i < TX_RING_SIZE; i++) {
+		pd->tx_buffers[i].skb = NULL;
+		pd->tx_buffers[i].mapping = 0;
+		pd->tx_ring[i].status = 0;
+		pd->tx_ring[i].length = 0;
+		pd->tx_ring[i].buffer1 = 0;
+		pd->tx_ring[i].buffer2 = 0;
+	}
+	pd->tx_ring[TX_RING_SIZE - 1].length = TDES1_TER_;
+	wmb();
+
+	pd->tx_ring_head = 0;
+	pd->tx_ring_tail = 0;
+
+	smsc9420_reg_write(pd, TX_BASE_ADDR, pd->tx_dma_addr);
+	smsc9420_pci_flush_write(pd);
+
+	return 0;
+}
+
+static int smsc9420_alloc_rx_ring(struct smsc9420_pdata *pd)
+{
+	int i;
+
+	BUG_ON(!pd->rx_ring);
+
+	pd->rx_buffers = kmalloc((sizeof(struct smsc9420_ring_info) *
+		RX_RING_SIZE), GFP_KERNEL);
+	if (pd->rx_buffers == NULL) {
+		SMSC_WARNING("Failed to allocated rx_buffers");
+		goto out;
+	}
+
+	/* initialize the rx ring */
+	for (i = 0; i < RX_RING_SIZE; i++) {
+		pd->rx_ring[i].status = 0;
+		pd->rx_ring[i].length = PKT_BUF_SZ;
+		pd->rx_ring[i].buffer2 = 0;
+		pd->rx_buffers[i].skb = NULL;
+		pd->rx_buffers[i].mapping = 0;
+	}
+	pd->rx_ring[RX_RING_SIZE - 1].length = (PKT_BUF_SZ | RDES1_RER_);
+
+	/* now allocate the entire ring of skbs */
+	for (i = 0; i < RX_RING_SIZE; i++) {
+		if (smsc9420_alloc_rx_buffer(pd, i)) {
+			SMSC_WARNING("failed to allocate rx skb %d", i);
+			goto out_free_rx_skbs;
+		}
+	}
+
+	pd->rx_ring_head = 0;
+	pd->rx_ring_tail = 0;
+
+	smsc9420_reg_write(pd, VLAN1, ETH_P_8021Q);
+	SMSC_TRACE(DBG_INIT, "VLAN1 = 0x%08x", smsc9420_reg_read(pd, VLAN1));
+
+	if (pd->rx_csum) {
+		/* Enable RX COE */
+		u32 coe = smsc9420_reg_read(pd, COE_CR) | RX_COE_EN;
+		smsc9420_reg_write(pd, COE_CR, coe);
+		SMSC_TRACE(DBG_INIT, "COE_CR = 0x%08x", coe);
+	}
+
+	smsc9420_reg_write(pd, RX_BASE_ADDR, pd->rx_dma_addr);
+	smsc9420_pci_flush_write(pd);
+
+	return 0;
+
+out_free_rx_skbs:
+	smsc9420_free_rx_ring(pd);
+out:
+	return -ENOMEM;
+}
+
+static int smsc9420_open(struct net_device *dev)
+{
+	struct smsc9420_pdata *pd;
+	u32 bus_mode, mac_cr, dmac_control, int_cfg, dma_intr_ena, int_ctl;
+	unsigned long flags;
+	int result = 0, timeout;
+
+	BUG_ON(!dev);
+	pd = netdev_priv(dev);
+	BUG_ON(!pd);
+
+	if (!is_valid_ether_addr(dev->dev_addr)) {
+		SMSC_WARNING("dev_addr is not a valid MAC address");
+		result = -EADDRNOTAVAIL;
+		goto out_0;
+	}
+
+	netif_carrier_off(dev);
+
+	/* disable, mask and acknowlege all interrupts */
+	spin_lock_irqsave(&pd->int_lock, flags);
+	int_cfg = smsc9420_reg_read(pd, INT_CFG) & (~INT_CFG_IRQ_EN_);
+	smsc9420_reg_write(pd, INT_CFG, int_cfg);
+	smsc9420_reg_write(pd, INT_CTL, 0);
+	spin_unlock_irqrestore(&pd->int_lock, flags);
+	smsc9420_reg_write(pd, DMAC_INTR_ENA, 0);
+	smsc9420_reg_write(pd, INT_STAT, 0xFFFFFFFF);
+	smsc9420_pci_flush_write(pd);
+
+	if (request_irq(dev->irq, smsc9420_isr, IRQF_SHARED | IRQF_DISABLED,
+			DRV_NAME, pd)) {
+		SMSC_WARNING("Unable to use IRQ = %d", dev->irq);
+		result = -ENODEV;
+		goto out_0;
+	}
+
+	smsc9420_dmac_soft_reset(pd);
+
+	/* make sure MAC_CR is sane */
+	smsc9420_reg_write(pd, MAC_CR, 0);
+
+	smsc9420_set_mac_address(dev);
+
+	/* Configure GPIO pins to drive LEDs */
+	smsc9420_reg_write(pd, GPIO_CFG,
+		(GPIO_CFG_LED_3_ | GPIO_CFG_LED_2_ | GPIO_CFG_LED_1_));
+
+	bus_mode = BUS_MODE_DMA_BURST_LENGTH_16;
+
+#ifdef __BIG_ENDIAN
+	bus_mode |= BUS_MODE_DBO_;
+#endif
+
+	smsc9420_reg_write(pd, BUS_MODE, bus_mode);
+
+	smsc9420_pci_flush_write(pd);
+
+	/* set bus master bridge arbitration priority for Rx and TX DMA */
+	smsc9420_reg_write(pd, BUS_CFG, BUS_CFG_RXTXWEIGHT_4_1);
+
+	smsc9420_reg_write(pd, DMAC_CONTROL,
+		(DMAC_CONTROL_SF_ | DMAC_CONTROL_OSF_));
+
+	smsc9420_pci_flush_write(pd);
+
+	/* test the IRQ connection to the ISR */
+	SMSC_TRACE(DBG_INIT, "Testing ISR using IRQ %d", dev->irq);
+
+	spin_lock_irqsave(&pd->int_lock, flags);
+	/* configure interrupt deassertion timer and enable interrupts */
+	int_cfg = smsc9420_reg_read(pd, INT_CFG) | INT_CFG_IRQ_EN_;
+	int_cfg &= ~(INT_CFG_INT_DEAS_MASK);
+	int_cfg |= (INT_DEAS_TIME & INT_CFG_INT_DEAS_MASK);
+	smsc9420_reg_write(pd, INT_CFG, int_cfg);
+
+	/* unmask software interrupt */
+	int_ctl = smsc9420_reg_read(pd, INT_CTL) | INT_CTL_SW_INT_EN_;
+	smsc9420_reg_write(pd, INT_CTL, int_ctl);
+	spin_unlock_irqrestore(&pd->int_lock, flags);
+	smsc9420_pci_flush_write(pd);
+
+	timeout = 1000;
+	pd->software_irq_signal = false;
+	smp_wmb();
+	while (timeout--) {
+		if (pd->software_irq_signal)
+			break;
+		msleep(1);
+	}
+
+	/* disable interrupts */
+	spin_lock_irqsave(&pd->int_lock, flags);
+	int_cfg = smsc9420_reg_read(pd, INT_CFG) & (~INT_CFG_IRQ_EN_);
+	smsc9420_reg_write(pd, INT_CFG, int_cfg);
+	spin_unlock_irqrestore(&pd->int_lock, flags);
+
+	if (!pd->software_irq_signal) {
+		SMSC_WARNING("ISR failed signaling test");
+		result = -ENODEV;
+		goto out_free_irq_1;
+	}
+
+	SMSC_TRACE(DBG_INIT, "ISR passed test using IRQ %d", dev->irq);
+
+	result = smsc9420_alloc_tx_ring(pd);
+	if (result) {
+		SMSC_WARNING("Failed to Initialize tx dma ring");
+		result = -ENOMEM;
+		goto out_free_irq_1;
+	}
+
+	result = smsc9420_alloc_rx_ring(pd);
+	if (result) {
+		SMSC_WARNING("Failed to Initialize rx dma ring");
+		result = -ENOMEM;
+		goto out_free_tx_ring_2;
+	}
+
+	result = smsc9420_mii_init(dev);
+	if (result) {
+		SMSC_WARNING("Failed to initialize Phy");
+		result = -ENODEV;
+		goto out_free_rx_ring_3;
+	}
+
+	/* Bring the PHY up */
+	phy_start(pd->phy_dev);
+
+	napi_enable(&pd->napi);
+
+	/* start tx and rx */
+	mac_cr = smsc9420_reg_read(pd, MAC_CR) | MAC_CR_TXEN_ | MAC_CR_RXEN_;
+	smsc9420_reg_write(pd, MAC_CR, mac_cr);
+
+	dmac_control = smsc9420_reg_read(pd, DMAC_CONTROL);
+	dmac_control |= DMAC_CONTROL_ST_ | DMAC_CONTROL_SR_;
+	smsc9420_reg_write(pd, DMAC_CONTROL, dmac_control);
+	smsc9420_pci_flush_write(pd);
+
+	dma_intr_ena = smsc9420_reg_read(pd, DMAC_INTR_ENA);
+	dma_intr_ena |=
+		(DMAC_INTR_ENA_TX_ | DMAC_INTR_ENA_RX_ | DMAC_INTR_ENA_NIS_);
+	smsc9420_reg_write(pd, DMAC_INTR_ENA, dma_intr_ena);
+	smsc9420_pci_flush_write(pd);
+
+	netif_wake_queue(dev);
+
+	smsc9420_reg_write(pd, RX_POLL_DEMAND, 1);
+
+	/* enable interrupts */
+	spin_lock_irqsave(&pd->int_lock, flags);
+	int_cfg = smsc9420_reg_read(pd, INT_CFG) | INT_CFG_IRQ_EN_;
+	smsc9420_reg_write(pd, INT_CFG, int_cfg);
+	spin_unlock_irqrestore(&pd->int_lock, flags);
+
+	return 0;
+
+out_free_rx_ring_3:
+	smsc9420_free_rx_ring(pd);
+out_free_tx_ring_2:
+	smsc9420_free_tx_ring(pd);
+out_free_irq_1:
+	free_irq(dev->irq, pd);
+out_0:
+	return result;
+}
+
+#ifdef CONFIG_PM
+
+static int smsc9420_suspend(struct pci_dev *pdev, pm_message_t state)
+{
+	struct net_device *dev = pci_get_drvdata(pdev);
+	struct smsc9420_pdata *pd = netdev_priv(dev);
+	u32 int_cfg;
+	ulong flags;
+
+	/* disable interrupts */
+	spin_lock_irqsave(&pd->int_lock, flags);
+	int_cfg = smsc9420_reg_read(pd, INT_CFG) & (~INT_CFG_IRQ_EN_);
+	smsc9420_reg_write(pd, INT_CFG, int_cfg);
+	spin_unlock_irqrestore(&pd->int_lock, flags);
+
+	if (netif_running(dev)) {
+		netif_tx_disable(dev);
+		smsc9420_stop_tx(pd);
+		smsc9420_free_tx_ring(pd);
+
+		napi_disable(&pd->napi);
+		smsc9420_stop_rx(pd);
+		smsc9420_free_rx_ring(pd);
+
+		free_irq(dev->irq, pd);
+
+		netif_device_detach(dev);
+	}
+
+	pci_save_state(pdev);
+	pci_enable_wake(pdev, pci_choose_state(pdev, state), 0);
+	pci_disable_device(pdev);
+	pci_set_power_state(pdev, pci_choose_state(pdev, state));
+
+	return 0;
+}
+
+static int smsc9420_resume(struct pci_dev *pdev)
+{
+	struct net_device *dev = pci_get_drvdata(pdev);
+	int err;
+
+	pci_set_power_state(pdev, PCI_D0);
+	pci_restore_state(pdev);
+
+	err = pci_enable_device(pdev);
+	if (err)
+		return err;
+
+	pci_set_master(pdev);
+
+	err = pci_enable_wake(pdev, 0, 0);
+	if (err)
+		SMSC_WARNING("pci_enable_wake failed: %d", err);
+
+	if (netif_running(dev)) {
+		err = smsc9420_open(dev);
+		netif_device_attach(dev);
+	}
+	return err;
+}
+
+#endif /* CONFIG_PM */
+
+static int __devinit
+smsc9420_probe(struct pci_dev *pdev, const struct pci_device_id *id)
+{
+	struct net_device *dev;
+	struct smsc9420_pdata *pd;
+	void __iomem *virt_addr;
+	int result = 0;
+	u32 id_rev;
+
+	printk(KERN_INFO DRV_DESCRIPTION " version " DRV_VERSION "\n");
+
+	/* First do the PCI initialisation */
+	result = pci_enable_device(pdev);
+	if (unlikely(result)) {
+		printk(KERN_ERR "Cannot enable smsc9420\n");
+		goto out_0;
+	}
+
+	pci_set_master(pdev);
+
+	dev = alloc_etherdev(sizeof(*pd));
+	if (!dev) {
+		printk(KERN_ERR "ether device alloc failed\n");
+		goto out_disable_pci_device_1;
+	}
+
+	SET_NETDEV_DEV(dev, &pdev->dev);
+
+	if (!(pci_resource_flags(pdev, SMSC_BAR) & IORESOURCE_MEM)) {
+		SMSC_WARNING("Cannot find PCI device base address");
+		goto out_free_netdev_2;
+	}
+
+	if ((pci_request_regions(pdev, DRV_NAME))) {
+		SMSC_WARNING("Cannot obtain PCI resources, aborting.\n");
+		goto out_free_netdev_2;
+	}
+
+	if (pci_set_dma_mask(pdev, DMA_32BIT_MASK)) {
+		SMSC_WARNING("No usable DMA configuration, aborting.\n");
+		goto out_free_regions_3;
+	}
+
+	virt_addr = ioremap(pci_resource_start(pdev, SMSC_BAR),
+		pci_resource_len(pdev, SMSC_BAR));
+	if (!virt_addr) {
+		SMSC_WARNING("Cannot map device registers, aborting.\n");
+		goto out_free_regions_3;
+	}
+
+	/* registers are double mapped with 0 offset for LE and 0x200 for BE */
+	virt_addr += LAN9420_CPSR_ENDIAN_OFFSET;
+
+	dev->base_addr = (ulong)virt_addr;
+	SMSC_TRACE(DBG_INIT, "lan_base=0x%08lx", (ulong)virt_addr);
+
+	pd = netdev_priv(dev);
+
+	/* pci descriptors are created in the PCI consistent area */
+	pd->rx_ring = pci_alloc_consistent(pdev,
+		sizeof(struct smsc9420_dma_desc) * RX_RING_SIZE +
+		sizeof(struct smsc9420_dma_desc) * TX_RING_SIZE,
+		&pd->rx_dma_addr);
+
+	if (!pd->rx_ring)
+		goto out_free_io_4;
+
+	/* descriptors are aligned due to the nature of pci_alloc_consistent */
+	pd->tx_ring = (struct smsc9420_dma_desc *)
+	    (pd->rx_ring + RX_RING_SIZE);
+	pd->tx_dma_addr = pd->rx_dma_addr +
+	    sizeof(struct smsc9420_dma_desc) * RX_RING_SIZE;
+
+	pd->pdev = pdev;
+	pd->dev = dev;
+	pd->base_addr = virt_addr;
+	pd->debug_mode = debug_mode;
+	pd->rx_csum = true;
+
+	id_rev = smsc9420_reg_read(pd, ID_REV);
+	switch (id_rev & 0xFFFF0000) {
+	case 0x94200000:
+		SMSC_TRACE(DBG_INIT, "LAN9420 identified, "
+			"ID_REV=0x%08X", id_rev);
+		break;
+	default:
+		SMSC_WARNING("LAN9420 NOT identified");
+		SMSC_WARNING("ID_REV=0x%08X", id_rev);
+		goto out_free_dmadesc_5;
+	}
+
+	smsc9420_dmac_soft_reset(pd);
+	smsc9420_eeprom_reload(pd);
+	smsc9420_check_mac_address(dev);
+
+	dev->open = smsc9420_open;
+	dev->stop = smsc9420_stop;
+	dev->hard_start_xmit = smsc9420_hard_start_xmit;
+	dev->get_stats = smsc9420_get_stats;
+	dev->do_ioctl = smsc9420_do_ioctl;
+	dev->ethtool_ops = &smsc9420_ethtool_ops;
+	dev->set_multicast_list = smsc9420_set_multicast_list;
+	dev->irq = pdev->irq;
+
+	netif_napi_add(dev, &pd->napi, smsc9420_rx_poll, NAPI_WEIGHT);
+
+	result = register_netdev(dev);
+	if (result) {
+		SMSC_WARNING("error %i registering device", result);
+		goto out_free_dmadesc_5;
+	}
+
+	pci_set_drvdata(pdev, dev);
+
+	spin_lock_init(&pd->int_lock);
+	spin_lock_init(&pd->phy_lock);
+
+	dev_info(&dev->dev, "MAC Address: %pM\n", dev->dev_addr);
+
+	return 0;
+
+out_free_dmadesc_5:
+	pci_free_consistent(pdev, sizeof(struct smsc9420_dma_desc) *
+		(RX_RING_SIZE + TX_RING_SIZE), pd->rx_ring, pd->rx_dma_addr);
+out_free_io_4:
+	iounmap(virt_addr - LAN9420_CPSR_ENDIAN_OFFSET);
+out_free_regions_3:
+	pci_release_regions(pdev);
+out_free_netdev_2:
+	free_netdev(dev);
+out_disable_pci_device_1:
+	pci_disable_device(pdev);
+out_0:
+	return -ENODEV;
+}
+
+static void __devexit smsc9420_remove(struct pci_dev *pdev)
+{
+	struct net_device *dev;
+	struct smsc9420_pdata *pd;
+
+	dev = pci_get_drvdata(pdev);
+	if (!dev)
+		return;
+
+	pci_set_drvdata(pdev, NULL);
+
+	pd = netdev_priv(dev);
+	unregister_netdev(dev);
+
+	/* tx_buffers and rx_buffers are freed in stop */
+	BUG_ON(pd->tx_buffers);
+	BUG_ON(pd->rx_buffers);
+
+	BUG_ON(!pd->tx_ring);
+	BUG_ON(!pd->rx_ring);
+
+	pci_free_consistent(pdev, sizeof(struct smsc9420_dma_desc) *
+		(RX_RING_SIZE + TX_RING_SIZE), pd->rx_ring, pd->rx_dma_addr);
+
+	iounmap(pd->base_addr - LAN9420_CPSR_ENDIAN_OFFSET);
+	pci_release_regions(pdev);
+	free_netdev(dev);
+	pci_disable_device(pdev);
+}
+
+static struct pci_driver smsc9420_driver = {
+	.name = DRV_NAME,
+	.id_table = smsc9420_id_table,
+	.probe = smsc9420_probe,
+	.remove = __devexit_p(smsc9420_remove),
+#ifdef CONFIG_PM
+	.suspend = smsc9420_suspend,
+	.resume = smsc9420_resume,
+#endif /* CONFIG_PM */
+};
+
+static int __init smsc9420_init_module(void)
+{
+	return pci_register_driver(&smsc9420_driver);
+}
+
+static void __exit smsc9420_exit_module(void)
+{
+	pci_unregister_driver(&smsc9420_driver);
+}
+
+module_init(smsc9420_init_module);
+module_exit(smsc9420_exit_module);
diff --git a/drivers/net/smsc9420.h b/drivers/net/smsc9420.h
new file mode 100644
index 0000000..2a686a2
--- /dev/null
+++ b/drivers/net/smsc9420.h
@@ -0,0 +1,304 @@
+ /***************************************************************************
+ *
+ * Copyright (C) 2007,2008  SMSC
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
+ *
+ ***************************************************************************
+ */
+
+#ifndef _SMSC9420_H
+#define _SMSC9420_H
+
+#define USE_TRACE
+
+#define DBG_INIT        (0x80000000)
+#define DBG_CLOSE       (0x40000000)
+#define DBG_PWR         (0x10000000)
+#define DBG_LINK        (0x04000000)
+#define DBG_RX          (0x02000000)
+#define DBG_TX          (0x01000000)
+#define DBG_MCAST       (0x00800000)
+#define DBG_WARNING     (0x00000002)
+
+#ifdef USE_TRACE
+#define SMSC_TRACE(dbgBit, msg, args...) \
+	({if (debug_mode & dbgBit) \
+		printk(KERN_INFO "SMSC_ETH: " msg "\n", ## args); \
+	})
+#else
+#define SMSC_TRACE(dbgBit, msg, args...) \
+	({if (debug_mode & dbgBit && 0) \
+		printk(KERN_INFO "SMSC_ETH: " msg "\n", ## args); \
+	})
+#endif
+
+#define SMSC_WARNING(msg, args...) \
+	({if (debug_mode & DBG_WARNING) \
+		printk(KERN_WARNING "SMSC_ETH_WARNING: %s: " msg "\n", \
+			__func__, ## args); \
+	})
+
+#define TX_RING_SIZE			(32)
+#define RX_RING_SIZE			(128)
+
+/* interrupt deassertion in multiples of 10us */
+#define INT_DEAS_TIME			(50)
+
+#define NAPI_WEIGHT			(64)
+#define SMSC_BAR			(3)
+
+#ifdef __BIG_ENDIAN
+/* Register set is duplicated for BE at an offset of 0x200 */
+#define LAN9420_CPSR_ENDIAN_OFFSET	(0x200)
+#else
+#define LAN9420_CPSR_ENDIAN_OFFSET	(0)
+#endif
+
+#define PCI_VENDOR_ID_9420		(0x1055)
+#define PCI_DEVICE_ID_9420		(0xE420)
+
+#define LAN_REGISTER_EXTENT		(0x400)
+
+#define FLOW_CTRL_TX			(1)
+#define FLOW_CTRL_RX			(2)
+
+#define PKT_BUF_SZ			(VLAN_ETH_FRAME_LEN + NET_IP_ALIGN + 4)
+
+/***********************************************/
+/* DMA Controller Control and Status Registers */
+/***********************************************/
+#define BUS_MODE			(0x00)
+#define BUS_MODE_SWR_			(BIT(0))
+#define BUS_MODE_DMA_BURST_LENGTH_1	(BIT(8))
+#define BUS_MODE_DMA_BURST_LENGTH_2	(BIT(9))
+#define BUS_MODE_DMA_BURST_LENGTH_4	(BIT(10))
+#define BUS_MODE_DMA_BURST_LENGTH_8	(BIT(11))
+#define BUS_MODE_DMA_BURST_LENGTH_16	(BIT(12))
+#define BUS_MODE_DMA_BURST_LENGTH_32	(BIT(13))
+#define BUS_MODE_DBO_			(BIT(20))
+
+#define TX_POLL_DEMAND			(0x04)
+
+#define RX_POLL_DEMAND			(0x08)
+
+#define RX_BASE_ADDR			(0x0C)
+
+#define TX_BASE_ADDR			(0x10)
+
+#define DMAC_STATUS			(0x14)
+#define DMAC_STS_TS_			(7 << 20)
+#define DMAC_STS_RS_ 			(7 << 17)
+#define DMAC_STS_NIS_			(BIT(16))
+#define DMAC_STS_AIS_			(BIT(15))
+#define DMAC_STS_RWT_			(BIT(9))
+#define DMAC_STS_RXPS_			(BIT(8))
+#define DMAC_STS_RXBU_			(BIT(7))
+#define DMAC_STS_RX_			(BIT(6))
+#define DMAC_STS_TXUNF_			(BIT(5))
+#define DMAC_STS_TXBU_			(BIT(2))
+#define DMAC_STS_TXPS_			(BIT(1))
+#define DMAC_STS_TX_			(BIT(0))
+
+#define DMAC_CONTROL			(0x18)
+#define DMAC_CONTROL_TTM_		(BIT(22))
+#define DMAC_CONTROL_SF_		(BIT(21))
+#define DMAC_CONTROL_ST_		(BIT(13))
+#define DMAC_CONTROL_OSF_		(BIT(2))
+#define DMAC_CONTROL_SR_		(BIT(1))
+
+#define DMAC_INTR_ENA			(0x1C)
+#define DMAC_INTR_ENA_NIS_		(BIT(16))
+#define DMAC_INTR_ENA_AIS_		(BIT(15))
+#define DMAC_INTR_ENA_RWT_		(BIT(9))
+#define DMAC_INTR_ENA_RXPS_		(BIT(8))
+#define DMAC_INTR_ENA_RXBU_		(BIT(7))
+#define DMAC_INTR_ENA_RX_		(BIT(6))
+#define DMAC_INTR_ENA_TXBU_		(BIT(2))
+#define DMAC_INTR_ENA_TXPS_		(BIT(1))
+#define DMAC_INTR_ENA_TX_		(BIT(0))
+
+#define MISS_FRAME_CNTR			(0x20)
+
+#define TX_BUFF_ADDR			(0x50)
+
+#define RX_BUFF_ADDR			(0x54)
+
+/* Transmit Descriptor Bit Defs */
+#define TDES0_OWN_			(0x80000000)
+#define TDES0_ERROR_SUMMARY_		(0x00008000)
+#define TDES0_LOSS_OF_CARRIER_		(0x00000800)
+#define TDES0_NO_CARRIER_		(0x00000400)
+#define TDES0_LATE_COLLISION_		(0x00000200)
+#define TDES0_EXCESSIVE_COLLISIONS_	(0x00000100)
+#define TDES0_HEARTBEAT_FAIL_		(0x00000080)
+#define TDES0_COLLISION_COUNT_MASK_	(0x00000078)
+#define TDES0_COLLISION_COUNT_SHFT_	(3)
+#define TDES0_EXCESSIVE_DEFERRAL_	(0x00000004)
+#define TDES0_DEFERRED_			(0x00000001)
+
+#define TDES1_IC_			0x80000000
+#define TDES1_LS_			0x40000000
+#define TDES1_FS_			0x20000000
+#define TDES1_TXCSEN_			0x08000000
+#define TDES1_TER_			(BIT(25))
+#define TDES1_TCH_			0x01000000
+
+/* Receive Descriptor 0 Bit Defs */
+#define RDES0_OWN_			(0x80000000)
+#define RDES0_FRAME_LENGTH_MASK_	(0x07FF0000)
+#define RDES0_FRAME_LENGTH_SHFT_	(16)
+#define RDES0_ERROR_SUMMARY_		(0x00008000)
+#define RDES0_DESCRIPTOR_ERROR_		(0x00004000)
+#define RDES0_LENGTH_ERROR_		(0x00001000)
+#define RDES0_RUNT_FRAME_		(0x00000800)
+#define RDES0_MULTICAST_FRAME_		(0x00000400)
+#define RDES0_FIRST_DESCRIPTOR_		(0x00000200)
+#define RDES0_LAST_DESCRIPTOR_		(0x00000100)
+#define RDES0_FRAME_TOO_LONG_		(0x00000080)
+#define RDES0_COLLISION_SEEN_		(0x00000040)
+#define RDES0_FRAME_TYPE_		(0x00000020)
+#define RDES0_WATCHDOG_TIMEOUT_		(0x00000010)
+#define RDES0_MII_ERROR_		(0x00000008)
+#define RDES0_DRIBBLING_BIT_		(0x00000004)
+#define RDES0_CRC_ERROR_		(0x00000002)
+
+/* Receive Descriptor 1 Bit Defs */
+#define RDES1_RER_			(0x02000000)
+
+/***********************************************/
+/*       MAC Control and Status Registers      */
+/***********************************************/
+#define MAC_CR				(0x80)
+#define MAC_CR_RXALL_			(0x80000000)
+#define MAC_CR_DIS_RXOWN_		(0x00800000)
+#define MAC_CR_LOOPBK_			(0x00200000)
+#define MAC_CR_FDPX_			(0x00100000)
+#define MAC_CR_MCPAS_			(0x00080000)
+#define MAC_CR_PRMS_			(0x00040000)
+#define MAC_CR_INVFILT_			(0x00020000)
+#define MAC_CR_PASSBAD_			(0x00010000)
+#define MAC_CR_HFILT_			(0x00008000)
+#define MAC_CR_HPFILT_			(0x00002000)
+#define MAC_CR_LCOLL_			(0x00001000)
+#define MAC_CR_DIS_BCAST_		(0x00000800)
+#define MAC_CR_DIS_RTRY_		(0x00000400)
+#define MAC_CR_PADSTR_			(0x00000100)
+#define MAC_CR_BOLMT_MSK		(0x000000C0)
+#define MAC_CR_MFCHK_			(0x00000020)
+#define MAC_CR_TXEN_			(0x00000008)
+#define MAC_CR_RXEN_			(0x00000004)
+
+#define ADDRH				(0x84)
+
+#define ADDRL				(0x88)
+
+#define HASHH				(0x8C)
+
+#define HASHL				(0x90)
+
+#define MII_ACCESS			(0x94)
+#define MII_ACCESS_MII_BUSY_		(0x00000001)
+#define MII_ACCESS_MII_WRITE_		(0x00000002)
+#define MII_ACCESS_MII_READ_		(0x00000000)
+#define MII_ACCESS_INDX_MSK_		(0x000007C0)
+#define MII_ACCESS_PHYADDR_MSK_		(0x0000F8C0)
+#define MII_ACCESS_INDX_SHFT_CNT	(6)
+#define MII_ACCESS_PHYADDR_SHFT_CNT	(11)
+
+#define MII_DATA			(0x98)
+
+#define FLOW				(0x9C)
+
+#define VLAN1				(0xA0)
+
+#define VLAN2				(0xA4)
+
+#define WUFF				(0xA8)
+
+#define WUCSR				(0xAC)
+
+#define COE_CR				(0xB0)
+#define TX_COE_EN			(0x00010000)
+#define RX_COE_MODE			(0x00000002)
+#define RX_COE_EN			(0x00000001)
+
+/***********************************************/
+/*     System Control and Status Registers     */
+/***********************************************/
+#define ID_REV				(0xC0)
+
+#define INT_CTL				(0xC4)
+#define INT_CTL_SW_INT_EN_		(0x00008000)
+#define INT_CTL_SBERR_INT_EN_		(1 << 12)
+#define INT_CTL_MBERR_INT_EN_		(1 << 13)
+#define INT_CTL_GPT_INT_EN_		(0x00000008)
+#define INT_CTL_PHY_INT_EN_		(0x00000004)
+#define INT_CTL_WAKE_INT_EN_		(0x00000002)
+
+#define INT_STAT			(0xC8)
+#define INT_STAT_SW_INT_		(1 << 15)
+#define INT_STAT_MBERR_INT_		(1 << 13)
+#define INT_STAT_SBERR_INT_		(1 << 12)
+#define INT_STAT_GPT_INT_		(1 << 3)
+#define INT_STAT_PHY_INT_		(0x00000004)
+#define INT_STAT_WAKE_INT_		(0x00000002)
+#define INT_STAT_DMAC_INT_		(0x00000001)
+
+#define INT_CFG				(0xCC)
+#define INT_CFG_IRQ_INT_		(0x00080000)
+#define INT_CFG_IRQ_EN_			(0x00040000)
+#define INT_CFG_INT_DEAS_CLR_		(0x00000200)
+#define INT_CFG_INT_DEAS_MASK		(0x000000FF)
+
+#define GPIO_CFG			(0xD0)
+#define GPIO_CFG_LED_3_			(0x40000000)
+#define GPIO_CFG_LED_2_			(0x20000000)
+#define GPIO_CFG_LED_1_			(0x10000000)
+
+#define GPT_CFG				(0xD4)
+#define GPT_CFG_TIMER_EN_		(0x20000000)
+
+#define GPT_CNT				(0xD8)
+
+#define BUS_CFG				(0xDC)
+#define BUS_CFG_RXTXWEIGHT_1_1		(0 << 25)
+#define BUS_CFG_RXTXWEIGHT_2_1		(1 << 25)
+#define BUS_CFG_RXTXWEIGHT_3_1		(2 << 25)
+#define BUS_CFG_RXTXWEIGHT_4_1		(3 << 25)
+
+#define PMT_CTRL			(0xE0)
+
+#define FREE_RUN			(0xF4)
+
+#define E2P_CMD				(0xF8)
+#define E2P_CMD_EPC_BUSY_		(0x80000000)
+#define E2P_CMD_EPC_CMD_		(0x70000000)
+#define E2P_CMD_EPC_CMD_READ_		(0x00000000)
+#define E2P_CMD_EPC_CMD_EWDS_		(0x10000000)
+#define E2P_CMD_EPC_CMD_EWEN_		(0x20000000)
+#define E2P_CMD_EPC_CMD_WRITE_		(0x30000000)
+#define E2P_CMD_EPC_CMD_WRAL_		(0x40000000)
+#define E2P_CMD_EPC_CMD_ERASE_		(0x50000000)
+#define E2P_CMD_EPC_CMD_ERAL_		(0x60000000)
+#define E2P_CMD_EPC_CMD_RELOAD_		(0x70000000)
+#define E2P_CMD_EPC_TIMEOUT_		(0x00000200)
+#define E2P_CMD_MAC_ADDR_LOADED_	(0x00000100)
+#define E2P_CMD_EPC_ADDR_		(0x000000FF)
+
+#define E2P_DATA			(0xFC)
+#define E2P_DATA_EEPROM_DATA_		(0x000000FF)
+
+#endif /* _SMSC9420_H */
-- 
1.5.6.5


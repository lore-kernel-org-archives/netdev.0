From: Andreas Fenkart <afenkart@gmail.com>
Subject: [PATCH] ARC VMAC driver.
Date: Mon,  5 Mar 2012 10:59:45 +0100
Message-ID: <1330941585-7404-1-git-send-email-afenkart@gmail.com>
Cc: eric.dumazet@gmail.com, Andreas Fenkart <afenkart@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout-de.gmx.net ([213.165.64.22]:51171 "HELO
	mailout-de.gmx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1756525Ab2CEKAJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2012 05:00:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a driver for the MAC IP block from ARC International. It
is based on an existing driver found in ARC Linux distribution,
but essentially, a full rewrite.

Signed-off-by: Andreas Fenkart <afenkart@gmail.com>
---
 drivers/net/ethernet/Kconfig   |    9 +
 drivers/net/ethernet/Makefile  |    1 +
 drivers/net/ethernet/arcvmac.c | 1480 ++++++++++++++++++++++++++++++++++++++++
 drivers/net/ethernet/arcvmac.h |  269 ++++++++
 4 files changed, 1759 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/ethernet/arcvmac.c
 create mode 100644 drivers/net/ethernet/arcvmac.h

diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 597f4d4..4b6baf8 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -23,6 +23,15 @@ source "drivers/net/ethernet/aeroflex/Kconfig"
 source "drivers/net/ethernet/alteon/Kconfig"
 source "drivers/net/ethernet/amd/Kconfig"
 source "drivers/net/ethernet/apple/Kconfig"
+
+config ARCVMAC
+	tristate "ARC VMAC ethernet driver"
+	select MII
+	select PHYLIB
+	select CRC32
+	help
+	  MAC present Zoran43xx, IP from ARC international
+
 source "drivers/net/ethernet/atheros/Kconfig"
 source "drivers/net/ethernet/cadence/Kconfig"
 source "drivers/net/ethernet/adi/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index be5dde0..cb61799 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -9,6 +9,7 @@ obj-$(CONFIG_GRETH) += aeroflex/
 obj-$(CONFIG_NET_VENDOR_ALTEON) += alteon/
 obj-$(CONFIG_NET_VENDOR_AMD) += amd/
 obj-$(CONFIG_NET_VENDOR_APPLE) += apple/
+obj-$(CONFIG_ARCVMAC) += arcvmac.o
 obj-$(CONFIG_NET_VENDOR_ATHEROS) += atheros/
 obj-$(CONFIG_NET_ATMEL) += cadence/
 obj-$(CONFIG_NET_BFIN) += adi/
diff --git a/drivers/net/ethernet/arcvmac.c b/drivers/net/ethernet/arcvmac.c
new file mode 100644
index 0000000..da96d35
--- /dev/null
+++ b/drivers/net/ethernet/arcvmac.c
@@ -0,0 +1,1480 @@
+/*
+ * ARC VMAC Driver
+ *
+ * Copyright (C) 2009-2012 Andreas Fenkart
+ * All Rights Reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ *
+ * Initial work taken from arc linux distribution, any bugs are mine
+ *
+ *	-----<snip>-----
+ * Copyright (C) 2003-2006 Codito Technologies, for linux-2.4 port
+ * Copyright (C) 2006-2007 Celunite Inc, for linux-2.6 port
+ * Authors: amit.bhor@celunite.com, sameer.dhavale@celunite.com
+ *	-----<snip>-----
+ */
+
+#include <linux/clk.h>
+#include <linux/crc32.h>
+#include <linux/delay.h>
+#include <linux/dma-mapping.h>
+#include <linux/etherdevice.h>
+#include <linux/init.h>
+#include <linux/interrupt.h>
+#include <linux/io.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/moduleparam.h>
+#include <linux/netdevice.h>
+#include <linux/phy.h>
+#include <linux/platform_device.h>
+#include <linux/slab.h>
+#include <linux/sched.h>
+#include <linux/types.h>
+
+#include "arcvmac.h"
+
+/* Register access macros */
+#define vmac_writel(port, value, reg)	\
+	writel(cpu_to_le32(value), (port)->regs + VMAC_##reg)
+#define vmac_readl(port, reg)	le32_to_cpu(readl((port)->regs + VMAC_##reg))
+
+static int get_register_map(struct vmac_priv *ap);
+static int put_register_map(struct vmac_priv *ap);
+static void update_vmac_stats_unlocked(struct net_device *dev);
+static int vmac_tx_reclaim_unlocked(struct net_device *dev, int force);
+
+static unsigned char *read_mac_reg(struct net_device *dev,
+		unsigned char hwaddr[ETH_ALEN])
+{
+	struct vmac_priv *ap = netdev_priv(dev);
+	unsigned mac_lo, mac_hi;
+
+	WARN_ON(!hwaddr);
+	mac_lo = vmac_readl(ap, ADDRL);
+	mac_hi = vmac_readl(ap, ADDRH);
+
+	hwaddr[0] = (mac_lo >> 0) & 0xff;
+	hwaddr[1] = (mac_lo >> 8) & 0xff;
+	hwaddr[2] = (mac_lo >> 16) & 0xff;
+	hwaddr[3] = (mac_lo >> 24) & 0xff;
+	hwaddr[4] = (mac_hi >> 0) & 0xff;
+	hwaddr[5] = (mac_hi >> 8) & 0xff;
+	return hwaddr;
+}
+
+static void write_mac_reg(struct net_device *dev, unsigned char* hwaddr)
+{
+	struct vmac_priv *ap = netdev_priv(dev);
+	unsigned mac_lo, mac_hi;
+
+	mac_lo = hwaddr[3] << 24 | hwaddr[2] << 16 | hwaddr[1] << 8 |
+		hwaddr[0];
+	mac_hi = hwaddr[5] << 8 | hwaddr[4];
+
+	vmac_writel(ap, mac_lo, ADDRL);
+	vmac_writel(ap, mac_hi, ADDRH);
+}
+
+static void vmac_mdio_xmit(struct vmac_priv *ap, unsigned val)
+{
+	init_completion(&ap->mdio_complete);
+	vmac_writel(ap, val, MDIO_DATA);
+	wait_for_completion(&ap->mdio_complete);
+}
+
+static int vmac_mdio_read(struct mii_bus *bus, int phy_id, int phy_reg)
+{
+	struct vmac_priv *vmac = bus->priv;
+	unsigned int val;
+
+	/* only 5 bits allowed for phy-addr and reg_offset */
+	WARN_ON(phy_id & ~0x1f || phy_reg & ~0x1f);
+
+	val = MDIO_BASE | MDIO_OP_READ;
+	val |= phy_id << 23 | phy_reg << 18;
+	vmac_mdio_xmit(vmac, val);
+
+	val = vmac_readl(vmac, MDIO_DATA);
+	return val & MDIO_DATA_MASK;
+}
+
+static int vmac_mdio_write(struct mii_bus *bus, int phy_id, int phy_reg,
+			 u16 value)
+{
+	struct vmac_priv *vmac = bus->priv;
+	unsigned int val;
+
+	/* only 5 bits allowed for phy-addr and reg_offset */
+	WARN_ON(phy_id & ~0x1f || phy_reg & ~0x1f);
+
+	val = MDIO_BASE | MDIO_OP_WRITE;
+	val |= phy_id << 23 | phy_reg << 18;
+	val |= (value & MDIO_DATA_MASK);
+	vmac_mdio_xmit(vmac, val);
+
+	return 0;
+}
+
+static void vmac_handle_link_change(struct net_device *dev)
+{
+	struct vmac_priv *ap = netdev_priv(dev);
+	struct phy_device *phydev = ap->phy_dev;
+	unsigned long flags;
+	int report_change = 0;
+
+	spin_lock_irqsave(&ap->lock, flags);
+
+	if (phydev->duplex != ap->duplex) {
+		unsigned tmp;
+
+		tmp = vmac_readl(ap, ENABLE);
+
+		if (phydev->duplex)
+			tmp |= ENFL_MASK;
+		else
+			tmp &= ~ENFL_MASK;
+
+		vmac_writel(ap, tmp, ENABLE);
+
+		ap->duplex = phydev->duplex;
+		report_change = 1;
+	}
+
+	if (phydev->speed != ap->speed) {
+		ap->speed = phydev->speed;
+		report_change = 1;
+	}
+
+	if (phydev->link != ap->link) {
+		ap->link = phydev->link;
+		report_change = 1;
+	}
+
+	spin_unlock_irqrestore(&ap->lock, flags);
+
+	if (report_change)
+		phy_print_status(ap->phy_dev);
+}
+
+static int __devinit vmac_mii_probe(struct net_device *dev)
+{
+	struct vmac_priv *ap = netdev_priv(dev);
+	struct phy_device *phydev = NULL;
+	struct clk *vmac_clk;
+	unsigned long clock_rate;
+	int phy_addr, err;
+
+	/* find the first phy */
+	for (phy_addr = 0; phy_addr < PHY_MAX_ADDR; phy_addr++) {
+		if (ap->mii_bus->phy_map[phy_addr]) {
+			phydev = ap->mii_bus->phy_map[phy_addr];
+			break;
+		}
+	}
+
+	if (!phydev) {
+		dev_err(&ap->pdev->dev, "no PHY found\n");
+		return -ENODEV;
+	}
+
+	/* FIXME: add pin_irq, if avail */
+
+	phydev = phy_connect(dev, dev_name(&phydev->dev),
+			&vmac_handle_link_change, 0,
+			PHY_INTERFACE_MODE_MII);
+
+	if (IS_ERR(phydev)) {
+		err = PTR_ERR(phydev);
+		dev_err(&ap->pdev->dev, "could not attach to PHY %d\n", err);
+		goto err_out;
+	}
+
+	phydev->supported &= PHY_BASIC_FEATURES;
+	phydev->supported |= SUPPORTED_Asym_Pause | SUPPORTED_Pause;
+
+	vmac_clk = clk_get(&ap->pdev->dev, "arcvmac");
+	if (IS_ERR(vmac_clk)) {
+		err = PTR_ERR(vmac_clk);
+		goto err_disconnect;
+	}
+
+	clock_rate = clk_get_rate(vmac_clk);
+	clk_put(vmac_clk);
+
+	dev_dbg(&ap->pdev->dev, "vmac_clk: %lu Hz\n", clock_rate);
+
+	if (clock_rate < 25000000)
+		phydev->supported &= ~(SUPPORTED_100baseT_Half |
+				SUPPORTED_100baseT_Full);
+
+	phydev->advertising = phydev->supported;
+
+	ap->link = 0;
+	ap->speed = 0;
+	ap->duplex = -1;
+	ap->phy_dev = phydev;
+
+	return 0;
+
+err_disconnect:
+	phy_disconnect(phydev);
+err_out:
+	return err;
+}
+
+static int __devinit vmac_mii_init(struct vmac_priv *ap)
+{
+	unsigned long flags;
+	int err, i;
+
+	spin_lock_irqsave(&ap->lock, flags);
+
+	ap->mii_bus = mdiobus_alloc();
+	if (ap->mii_bus == NULL)
+		return -ENOMEM;
+
+	ap->mii_bus->name = "vmac_mii_bus";
+	ap->mii_bus->read = &vmac_mdio_read;
+	ap->mii_bus->write = &vmac_mdio_write;
+
+	snprintf(ap->mii_bus->id, MII_BUS_ID_SIZE, "%x", 0);
+
+	ap->mii_bus->priv = ap;
+
+	err = -ENOMEM;
+	ap->mii_bus->irq = kmalloc(sizeof(int) * PHY_MAX_ADDR, GFP_KERNEL);
+	if (!ap->mii_bus->irq)
+		goto err_out;
+
+	for (i = 0; i < PHY_MAX_ADDR; i++)
+		ap->mii_bus->irq[i] = PHY_POLL;
+
+	spin_unlock_irqrestore(&ap->lock, flags);
+
+	/* locking: mdio concurrency */
+
+	err = mdiobus_register(ap->mii_bus);
+	if (err)
+		goto err_out_free_mdio_irq;
+
+	err = vmac_mii_probe(ap->dev);
+	if (err)
+		goto err_out_unregister_bus;
+
+	return 0;
+
+err_out_unregister_bus:
+	mdiobus_unregister(ap->mii_bus);
+err_out_free_mdio_irq:
+	kfree(ap->mii_bus->irq);
+err_out:
+	mdiobus_free(ap->mii_bus);
+	return err;
+}
+
+static void vmac_mii_exit_unlocked(struct net_device *dev)
+{
+	struct vmac_priv *ap = netdev_priv(dev);
+
+	if (ap->phy_dev)
+		phy_disconnect(ap->phy_dev);
+
+	mdiobus_unregister(ap->mii_bus);
+	kfree(ap->mii_bus->irq);
+	mdiobus_free(ap->mii_bus);
+}
+
+static int vmacether_get_settings(struct net_device *dev,
+		struct ethtool_cmd *cmd)
+{
+	struct vmac_priv *ap = netdev_priv(dev);
+	struct phy_device *phydev = ap->phy_dev;
+
+	if (!phydev)
+		return -ENODEV;
+
+	return phy_ethtool_gset(phydev, cmd);
+}
+
+static int vmacether_set_settings(struct net_device *dev,
+		struct ethtool_cmd *cmd)
+{
+	struct vmac_priv *ap = netdev_priv(dev);
+	struct phy_device *phydev = ap->phy_dev;
+
+	if (!phydev)
+		return -ENODEV;
+
+	return phy_ethtool_sset(phydev, cmd);
+}
+
+static int vmac_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
+{
+	struct vmac_priv *ap = netdev_priv(dev);
+	struct phy_device *phydev = ap->phy_dev;
+
+	if (!netif_running(dev))
+		return -EINVAL;
+
+	if (!phydev)
+		return -ENODEV;
+
+	return phy_mii_ioctl(phydev, rq, cmd);
+}
+
+static void vmacether_get_drvinfo(struct net_device *dev,
+		struct ethtool_drvinfo *info)
+{
+	struct vmac_priv *ap = netdev_priv(dev);
+
+	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
+	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
+	snprintf(info->bus_info, sizeof(info->bus_info),
+			"platform 0x%pP", &ap->mem->start);
+}
+
+static int update_error_counters_unlocked(struct net_device *dev, int status)
+{
+	struct vmac_priv *ap = netdev_priv(dev);
+	dev_dbg(&ap->pdev->dev, "rx error counter overrun. status = 0x%x\n",
+			status);
+
+	/* programming error */
+	WARN_ON(status & TXCH_MASK);
+	WARN_ON(!(status & (MSER_MASK | RXCR_MASK | RXFR_MASK | RXFL_MASK)));
+
+	if (status & MSER_MASK)
+		dev->stats.rx_over_errors += 256; /* ran out of BD */
+	if (status & RXCR_MASK)
+		dev->stats.rx_crc_errors += 256;
+	if (status & RXFR_MASK)
+		dev->stats.rx_frame_errors += 256;
+	if (status & RXFL_MASK)
+		dev->stats.rx_fifo_errors += 256;
+
+	return 0;
+}
+
+static void update_tx_errors_unlocked(struct net_device *dev, int status)
+{
+	struct vmac_priv *ap = netdev_priv(dev);
+
+	if (status & BD_UFLO)
+		dev->stats.tx_fifo_errors++;
+
+	if (ap->duplex)
+		return;
+
+	/* half duplex flags */
+	if (status & BD_LTCL)
+		dev->stats.tx_window_errors++;
+	if (status & BD_RETRY_CT)
+		dev->stats.collisions += (status & BD_RETRY_CT) >> 24;
+	if (status & BD_DROP)  /* too many retries */
+		dev->stats.tx_aborted_errors++;
+	if (status & BD_DEFER)
+		dev_vdbg(&ap->pdev->dev, "\"defer to traffic\"\n");
+	if (status & BD_CARLOSS)
+		dev->stats.tx_carrier_errors++;
+}
+
+static int vmac_rx_reclaim_force_unlocked(struct net_device *dev)
+{
+	struct vmac_priv *ap = netdev_priv(dev);
+	int ct;
+
+	/* locking: no concurrency, runs only during shutdown */
+	WARN_ON(!ap->shutdown);
+
+	dev_dbg(&ap->pdev->dev, "need to release %d rx sk_buff\n",
+			fifo_used(&ap->rx_ring));
+
+	ct = 0;
+	while (!fifo_empty(&ap->rx_ring) && ct++ < ap->rx_ring.size) {
+		struct vmac_buffer_desc *desc;
+		struct sk_buff *skb;
+		int desc_idx;
+
+		desc_idx = ap->rx_ring.tail;
+		desc = &ap->rxbd[desc_idx];
+		fifo_inc_tail(&ap->rx_ring);
+
+		if (!ap->rx_skbuff[desc_idx]) {
+			dev_err(&ap->pdev->dev, "non-populated rx_skbuff found %d\n",
+					desc_idx);
+			continue;
+		}
+
+		skb = ap->rx_skbuff[desc_idx];
+		ap->rx_skbuff[desc_idx] = NULL;
+
+		dma_unmap_single(&ap->pdev->dev, desc->data, skb->len,
+		    DMA_TO_DEVICE);
+
+		dev_kfree_skb(skb);
+	}
+
+	if (!fifo_empty(&ap->rx_ring)) {
+		dev_err(&ap->pdev->dev, "failed to reclaim %d rx sk_buff\n",
+				fifo_used(&ap->rx_ring));
+	}
+
+	return 0;
+}
+
+/* Function refills empty buffer descriptors and passes ownership to DMA */
+static int vmac_rx_refill_unlocked(struct net_device *dev)
+{
+	struct vmac_priv *ap = netdev_priv(dev);
+
+	/* locking: protect from refill_timer */
+	/* locking: fct owns area outside rx_ring, head exclusive tail,
+	 *	modifies head */
+
+	spin_lock(&ap->refill_lock);
+
+	WARN_ON(fifo_full(&ap->rx_ring));
+
+	while (!fifo_full(&ap->rx_ring)) {
+		struct vmac_buffer_desc *desc;
+		struct sk_buff *skb;
+		dma_addr_t p;
+		int desc_idx;
+
+		desc_idx = ap->rx_ring.head;
+		desc = &ap->rxbd[desc_idx];
+
+		/* make sure we read the actual descriptor status */
+		rmb();
+
+		if (ap->rx_skbuff[desc_idx]) {
+			/* dropped packet / buffer chaining */
+			fifo_inc_head(&ap->rx_ring);
+
+			/* return to DMA */
+			wmb();
+			desc->info = cpu_to_le32(BD_DMA_OWN | ap->rx_skb_size);
+			continue;
+		}
+
+		skb = netdev_alloc_skb_ip_align(dev, ap->rx_skb_size);
+		if (!skb) {
+			dev_info(&ap->pdev->dev, "failed to allocate rx_skb, skb's left %d\n",
+					fifo_used(&ap->rx_ring));
+			break;
+		}
+
+		ap->rx_skbuff[desc_idx] = skb;
+
+		p = dma_map_single(&ap->pdev->dev, skb->data, ap->rx_skb_size,
+				DMA_FROM_DEVICE);
+
+		desc->data = p;
+
+		wmb();
+		desc->info = cpu_to_le32(BD_DMA_OWN | ap->rx_skb_size);
+
+		fifo_inc_head(&ap->rx_ring);
+	}
+
+	spin_unlock(&ap->refill_lock);
+
+	/* If rx ring is still empty, set a timer to try allocating
+	 * again at a later time. */
+	if (fifo_empty(&ap->rx_ring) && netif_running(dev)) {
+		dev_warn(&ap->pdev->dev, "unable to refill rx ring\n");
+		ap->refill_timer.expires = jiffies + HZ;
+		add_timer(&ap->refill_timer);
+	}
+
+	return 0;
+}
+
+/*
+ * timer callback to defer refill rx queue in case we're OOM
+ */
+static void vmac_refill_rx_timer(unsigned long data)
+{
+	vmac_rx_refill_unlocked((struct net_device *)data);
+}
+
+/* merge buffer chaining  */
+static struct sk_buff *vmac_merge_rx_buffers_unlocked(struct net_device *dev,
+		struct vmac_buffer_desc *after,
+		int pkt_len) /* data */
+{
+	struct vmac_priv *ap = netdev_priv(dev);
+	struct sk_buff *first_skb, **tail, *cur_skb;
+	struct dma_fifo *rx_ring;
+	struct vmac_buffer_desc *desc;
+
+	/* locking: same as vmac_rx_receive */
+	/* desc->info = le32_to_cpu(desc-info) done */
+
+	first_skb = NULL;
+	tail = NULL;
+	rx_ring = &ap->rx_ring;
+	desc = &ap->rxbd[rx_ring->tail];
+
+	WARN_ON(desc == after);
+
+	pkt_len -= ETH_FCS_LEN; /* this might obsolete 'after' */
+
+	while (desc != after && pkt_len) {
+		int buf_len, valid;
+
+		/* desc needs wrapping */
+		desc = &ap->rxbd[rx_ring->tail];
+		cur_skb = ap->rx_skbuff[rx_ring->tail];
+		ap->rx_skbuff[rx_ring->tail] = NULL;
+		WARN_ON(!cur_skb);
+
+		dma_unmap_single(&ap->pdev->dev, desc->data, ap->rx_skb_size,
+				DMA_FROM_DEVICE);
+
+		/* do not copy FCS */
+		buf_len = desc->info & BD_LEN;
+		valid = min(pkt_len, buf_len);
+		pkt_len -= valid;
+
+		skb_put(cur_skb, valid);
+
+		if (!first_skb) {
+			first_skb = cur_skb;
+			tail = &skb_shinfo(first_skb)->frag_list;
+		} else {
+			first_skb->truesize += cur_skb->truesize;
+			first_skb->data_len += valid;
+			first_skb->len += valid;
+			*tail = cur_skb;
+			tail = &cur_skb->next;
+		}
+
+		fifo_inc_tail(rx_ring);
+	}
+
+	/* merging_pressure++ */
+
+#ifdef DEBUG
+	if (unlikely(pkt_len != 0))
+		dev_err(&ap->pdev->dev, "buffer chaining bytes missing %d\n",
+				pkt_len);
+
+	if (desc != after) {
+		int buf_len = le32_to_cpu(after->info) & BD_LEN;
+		WARN_ON(buf_len > ETH_FCS_LEN);
+	}
+#endif
+
+	return first_skb;
+}
+
+static int vmac_rx_receive(struct net_device *dev, int budget)
+{
+	struct vmac_priv *ap = netdev_priv(dev);
+	struct vmac_buffer_desc *first;
+	int processed, pkt_len, pkt_err;
+	struct dma_fifo lookahead;
+
+	/* true concurrency -> DMA engine running in parallel */
+	/* locking: fct owns rx_ring tail to current DMA read position, alias
+	 * 'received packets'. rx_refill owns area outside rx_ring, doesn't
+	 * modify tail */
+
+	processed = 0;
+
+	first = NULL;
+	pkt_err = pkt_len = 0;
+
+	/* look ahead, till packet complete */
+	lookahead = ap->rx_ring;
+
+	do {
+		struct vmac_buffer_desc *desc; /* cur_ */
+		int desc_idx; /* cur_ */
+		struct sk_buff *skb; /* pkt_ */
+
+		desc_idx = lookahead.tail;
+		desc = &ap->rxbd[desc_idx];
+
+		/* make sure we read the actual descriptor status */
+		rmb();
+
+		/* break if dma ownership belongs to hw */
+		if (desc->info & cpu_to_le32(BD_DMA_OWN)) {
+			/* safe the dma position */
+			ap->dma_rx_head = vmac_readl(ap, MAC_RXRING_HEAD);
+			break;
+		}
+
+		desc->info = le32_to_cpu(desc->info);
+		if (desc->info & BD_FRST) {
+			pkt_len = 0;
+			pkt_err = 0;
+
+			/* free packets up till current */
+			ap->rx_ring.tail = lookahead.tail;
+			first = desc;
+		}
+
+		fifo_inc_tail(&lookahead);
+
+		/* check bd */
+		pkt_len += desc->info & BD_LEN;
+		pkt_err |= desc->info & BD_BUFF;
+
+		if (!(desc->info & BD_LAST))
+			continue;
+
+		/* received complete packet */
+		if (unlikely(pkt_err || !first)) {
+			/* recycle buffers */
+			ap->rx_ring.tail = lookahead.tail;
+			continue;
+		}
+
+#ifdef DEBUG
+		WARN_ON(!(first->info & BD_FRST) || !(desc->info & BD_LAST));
+		WARN_ON(pkt_err);
+#endif
+
+		/* -- valid packet -- */
+
+		if (first != desc) {
+			skb = vmac_merge_rx_buffers_unlocked(dev, desc,
+					pkt_len);
+
+			if (!skb) {
+				/* kill packet */
+				ap->rx_ring.tail = lookahead.tail;
+				ap->rx_merge_error++;
+				continue;
+			}
+		} else {
+			dma_unmap_single(&ap->pdev->dev, desc->data,
+					ap->rx_skb_size, DMA_FROM_DEVICE);
+
+			skb = ap->rx_skbuff[desc_idx];
+			ap->rx_skbuff[desc_idx] = NULL;
+			/* desc->data != skb->data => desc->data is DMA
+			 * mapped */
+
+			/* strip FCS */
+			skb_put(skb, pkt_len - ETH_FCS_LEN);
+		}
+
+		/* free buffers */
+		ap->rx_ring.tail = lookahead.tail;
+
+#ifdef DEBUG
+		WARN_ON(skb->len != pkt_len - ETH_FCS_LEN);
+#endif
+		processed++;
+		skb->protocol = eth_type_trans(skb, dev);
+		dev->stats.rx_packets++;
+		dev->stats.rx_bytes += skb->len;
+		netif_receive_skb(skb);
+
+	} while (!fifo_empty(&lookahead) && (processed < budget));
+
+	dev_vdbg(&ap->pdev->dev, "processed pkt %d, remaining rx buff %d\n",
+			processed,
+			fifo_used(&ap->rx_ring));
+
+	if (processed || fifo_empty(&ap->rx_ring))
+		vmac_rx_refill_unlocked(dev);
+
+	return processed;
+}
+
+static void vmac_toggle_irqmask_unlocked(struct net_device *dev, int enable,
+		int mask)
+{
+	struct vmac_priv *ap = netdev_priv(dev);
+	unsigned long tmp;
+
+	tmp = vmac_readl(ap, ENABLE);
+	if (enable)
+		tmp |= mask;
+	else
+		tmp &= ~mask;
+	vmac_writel(ap, tmp, ENABLE);
+}
+
+static void vmac_toggle_rxint_unlocked(struct net_device *dev, int enable)
+{
+	vmac_toggle_irqmask_unlocked(dev, enable, RXINT_MASK);
+}
+
+static void vmac_toggle_txint_unlocked(struct net_device *dev, int enable)
+{
+	vmac_toggle_irqmask_unlocked(dev, enable, TXINT_MASK);
+}
+
+static int vmac_poll(struct napi_struct *napi, int budget)
+{
+	struct vmac_priv *ap;
+	int rx_work_done;
+
+	ap = container_of(napi, struct vmac_priv, napi);
+
+	vmac_tx_reclaim_unlocked(ap->dev, 0);
+
+	rx_work_done = vmac_rx_receive(ap->dev, budget);
+	if (rx_work_done >= budget) {
+		/* rx queue is not yet empty/clean */
+		return rx_work_done;
+	}
+
+	/* no more packet in rx/tx queue, remove device from poll queue */
+	napi_complete(napi);
+
+	/* clear status, only 1' affect register state */
+	vmac_writel(ap, RXINT_MASK | TXINT_MASK, STAT);
+
+	/* reenable IRQ */
+	vmac_toggle_rxint_unlocked(ap->dev, 1);
+	vmac_toggle_txint_unlocked(ap->dev, 1);
+
+	return rx_work_done;
+}
+
+static irqreturn_t vmac_intr(int irq, void *dev_instance)
+{
+	struct net_device *dev = dev_instance;
+	struct vmac_priv *ap = netdev_priv(dev);
+	unsigned int status;
+
+	spin_lock(&ap->lock);
+
+	status = vmac_readl(ap, STAT);
+	vmac_writel(ap, status, STAT);
+
+	if (unlikely(ap->shutdown))
+		dev_err(&ap->pdev->dev, "ISR during close\n");
+
+	if (unlikely(!status & (RXINT_MASK|MDIO_MASK|ERR_MASK)))
+		dev_err(&ap->pdev->dev, "Spurious IRQ\n");
+
+	if ((status & RXINT_MASK) && (vmac_readl(ap, ENABLE) && RXINT_MASK) &&
+			(ap->dma_rx_head != vmac_readl(ap, MAC_RXRING_HEAD))) {
+		vmac_toggle_rxint_unlocked(dev, 0);
+		napi_schedule(&ap->napi);
+	}
+
+	if ((status & TXINT_MASK) && (vmac_readl(ap, ENABLE) && TXINT_MASK)) {
+		vmac_toggle_txint_unlocked(dev, 0);
+		napi_schedule(&ap->napi);
+	}
+
+	if (status & MDIO_MASK)
+		complete(&ap->mdio_complete);
+
+	if (unlikely(status & ERR_MASK))
+		update_error_counters_unlocked(dev, status);
+
+	spin_unlock(&ap->lock);
+
+	return IRQ_HANDLED;
+}
+
+static int vmac_tx_reclaim_unlocked(struct net_device *dev, int force)
+{
+	struct vmac_priv *ap = netdev_priv(dev);
+	int released = 0;
+
+	/* locking: modifies tx_ring tail, head only during shutdown */
+	/* locking: call with ap->lock held */
+	WARN_ON(force && !ap->shutdown);
+
+	/* buffer chaining not used, see vmac_start_xmit */
+
+	while (!fifo_empty(&ap->tx_ring)) {
+		struct vmac_buffer_desc *desc;
+		struct sk_buff *skb;
+		int desc_idx;
+
+		desc_idx = ap->tx_ring.tail;
+		desc = &ap->txbd[desc_idx];
+
+		/* ensure other field of the descriptor were not read
+		 * before we checked ownership */
+		rmb();
+
+		if ((desc->info & cpu_to_le32(BD_DMA_OWN)) && !force)
+			break;
+
+		if (desc->info & cpu_to_le32(BD_TX_ERR)) {
+			update_tx_errors_unlocked(dev, le32_to_cpu(desc->info));
+			/* recycle packet, let upper level deal with it */
+		}
+
+		skb = ap->tx_skbuff[desc_idx];
+		ap->tx_skbuff[desc_idx] = NULL;
+		WARN_ON(!skb);
+
+		dma_unmap_single(&ap->pdev->dev, desc->data, skb->len,
+				DMA_TO_DEVICE);
+
+		dev_kfree_skb_any(skb);
+
+		released++;
+		fifo_inc_tail(&ap->tx_ring);
+	}
+
+	if (unlikely(netif_queue_stopped(dev)) && released)
+		netif_wake_queue(dev);
+
+	if (unlikely(force && !fifo_empty(&ap->tx_ring))) {
+		dev_err(&ap->pdev->dev, "failed to reclaim %d tx sk_buff\n",
+				fifo_used(&ap->tx_ring));
+	}
+
+	return released;
+}
+
+static int vmac_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct vmac_priv *ap = netdev_priv(dev);
+	struct vmac_buffer_desc *desc;
+
+	/* running under xmit lock */
+	/* locking: modifies tx_ring head, tx_reclaim only tail */
+
+	/* no scatter/gatter see features below */
+	WARN_ON(skb_shinfo(skb)->nr_frags != 0);
+	WARN_ON(skb->len > MAX_TX_BUFFER_LEN);
+
+	if (unlikely(fifo_full(&ap->tx_ring))) {
+		netif_stop_queue(dev);
+		dev_err(&ap->pdev->dev, "xmit called while no tx desc available\n");
+		return NETDEV_TX_BUSY;
+	}
+
+	if (unlikely(skb->len < ETH_ZLEN)) {
+		struct sk_buff *short_skb;
+		short_skb = netdev_alloc_skb(dev, ETH_ZLEN);
+		if (!short_skb)
+			return NETDEV_TX_LOCKED;
+
+		memset(short_skb->data, 0, ETH_ZLEN);
+		memcpy(skb_put(short_skb, ETH_ZLEN), skb->data, skb->len);
+		dev_kfree_skb(skb);
+		skb = short_skb;
+	}
+
+	/* fill descriptor */
+	ap->tx_skbuff[ap->tx_ring.head] = skb;
+	desc = &ap->txbd[ap->tx_ring.head];
+	WARN_ON(desc->info & cpu_to_le32(BD_DMA_OWN));
+
+	desc->data = dma_map_single(&ap->pdev->dev, skb->data, skb->len,
+			DMA_TO_DEVICE);
+
+	/* dma might already be polling */
+	wmb();
+	desc->info = cpu_to_le32(BD_DMA_OWN | BD_FRST | BD_LAST | skb->len);
+
+	/* kick tx dma, only 1' affect register */
+	vmac_writel(ap, TXPL_MASK, STAT);
+
+	dev->stats.tx_packets++;
+	dev->stats.tx_bytes += skb->len;
+	fifo_inc_head(&ap->tx_ring);
+
+	/* stop queue if no more desc available */
+	if (fifo_full(&ap->tx_ring))
+		netif_stop_queue(dev);
+
+	return NETDEV_TX_OK;
+}
+
+static int alloc_buffers_unlocked(struct net_device *dev)
+{
+	struct vmac_priv *ap = netdev_priv(dev);
+	int err = -ENOMEM;
+	int size;
+
+	fifo_init(&ap->rx_ring, RX_BDT_LEN);
+	fifo_init(&ap->tx_ring, TX_BDT_LEN);
+
+	/* initialize skb list */
+	memset(ap->rx_skbuff, 0, sizeof(ap->rx_skbuff));
+	memset(ap->tx_skbuff, 0, sizeof(ap->tx_skbuff));
+
+	/* allocate DMA received descriptors */
+	size = sizeof(*ap->rxbd) * ap->rx_ring.size;
+	ap->rxbd = dma_alloc_coherent(&ap->pdev->dev, size,
+			&ap->rxbd_dma,
+			GFP_KERNEL);
+	if (ap->rxbd == NULL)
+		goto err_out;
+
+	/* allocate DMA transmit descriptors */
+	size = sizeof(*ap->txbd) * ap->tx_ring.size;
+	ap->txbd = dma_alloc_coherent(&ap->pdev->dev, size,
+			&ap->txbd_dma,
+			GFP_KERNEL);
+	if (ap->txbd == NULL)
+		goto err_free_rxbd;
+
+	/* ensure 8-byte aligned */
+	WARN_ON(((uintptr_t)ap->txbd & 0x7) || ((uintptr_t)ap->rxbd & 0x7));
+
+	memset(ap->txbd, 0, sizeof(*ap->txbd) * ap->tx_ring.size);
+	memset(ap->rxbd, 0, sizeof(*ap->rxbd) * ap->rx_ring.size);
+
+	/* allocate rx skb */
+	err = vmac_rx_refill_unlocked(dev);
+	if (err)
+		goto err_free_txbd;
+
+	return 0;
+
+err_free_txbd:
+	dma_free_coherent(&ap->pdev->dev, sizeof(*ap->txbd) * ap->tx_ring.size,
+			ap->txbd, ap->txbd_dma);
+err_free_rxbd:
+	dma_free_coherent(&ap->pdev->dev, sizeof(*ap->rxbd) * ap->rx_ring.size,
+			ap->rxbd, ap->rxbd_dma);
+err_out:
+	return err;
+}
+
+static int free_buffers_unlocked(struct net_device *dev)
+{
+	struct vmac_priv *ap = netdev_priv(dev);
+
+	/* free skbuff */
+	vmac_tx_reclaim_unlocked(dev, 1);
+	vmac_rx_reclaim_force_unlocked(dev);
+
+	/* free DMA ring */
+	dma_free_coherent(&ap->pdev->dev, sizeof(ap->txbd) * ap->tx_ring.size,
+			ap->txbd, ap->txbd_dma);
+	dma_free_coherent(&ap->pdev->dev, sizeof(ap->rxbd) * ap->rx_ring.size,
+			ap->rxbd, ap->rxbd_dma);
+
+	return 0;
+}
+
+static int vmac_hw_init(struct net_device *dev)
+{
+	struct vmac_priv *ap = netdev_priv(dev);
+
+	/* clear IRQ mask */
+	vmac_writel(ap, 0, ENABLE);
+
+	/* clear pending IRQ */
+	vmac_writel(ap, 0xffffffff, STAT);
+
+	/* Initialize logical address filter */
+	vmac_writel(ap, 0x0, LAFL);
+	vmac_writel(ap, 0x0, LAFH);
+
+	return 0;
+}
+
+static int vmac_open(struct net_device *dev)
+{
+	struct vmac_priv *ap = netdev_priv(dev);
+	struct phy_device *phydev;
+	unsigned long flags;
+	unsigned int temp, ctrl;
+	int err = 0;
+
+	/* locking: no concurrency yet */
+
+	if (ap == NULL)
+		return -ENODEV;
+
+	spin_lock_irqsave(&ap->lock, flags);
+	ap->shutdown = 0;
+
+	err = get_register_map(ap);
+	if (err)
+		return err;
+
+	vmac_hw_init(dev);
+
+	/* mac address changed? */
+	write_mac_reg(dev, dev->dev_addr);
+
+	err = alloc_buffers_unlocked(dev);
+	if (err)
+		return err;
+
+	/* install DMA ring pointers */
+	vmac_writel(ap, ap->rxbd_dma, RXRINGPTR);
+	vmac_writel(ap, ap->txbd_dma, TXRINGPTR);
+
+	/* set poll rate to 1 ms */
+	vmac_writel(ap, POLLRATE_TIME, POLLRATE);
+
+	/* Set control */
+	ctrl = (RX_BDT_LEN << 24) | (TX_BDT_LEN << 16) | TXRN_MASK | RXRN_MASK;
+	vmac_writel(ap, ctrl, CONTROL);
+
+	/* make sure we enable napi before rx interrupt  */
+	napi_enable(&ap->napi);
+
+	err = request_irq(dev->irq, &vmac_intr, 0, dev->name, dev);
+	if (err) {
+		dev_err(&ap->pdev->dev, "Unable to request IRQ %d (error %d)\n",
+				dev->irq, err);
+		goto err_free_buffers;
+	}
+
+	/* IRQ mask */
+	temp = RXINT_MASK | MDIO_MASK | TXINT_MASK;
+	temp |= ERR_MASK | TXCH_MASK | MSER_MASK | RXCR_MASK | RXFR_MASK | \
+					RXFL_MASK;
+	vmac_writel(ap, temp, ENABLE);
+
+	/* enable, after all other bits are set */
+	vmac_writel(ap, ctrl | EN_MASK, CONTROL);
+	spin_unlock_irqrestore(&ap->lock, flags);
+
+	/* locking: concurrency */
+
+	netif_start_queue(dev);
+	netif_carrier_off(dev);
+
+	/* register the PHY board fixup, if needed */
+	err = vmac_mii_init(ap);
+	if (err)
+		goto err_free_irq;
+
+	/* schedule a link state check */
+	phy_start(ap->phy_dev);
+
+	phydev = ap->phy_dev;
+	dev_info(&ap->pdev->dev, "PHY driver [%s] (mii_bus:phy_addr=%s, irq=%d)\n",
+	       phydev->drv->name, dev_name(&phydev->dev), phydev->irq);
+
+	return 0;
+
+err_free_irq:
+	free_irq(dev->irq, dev);
+err_free_buffers:
+	napi_disable(&ap->napi);
+	free_buffers_unlocked(dev);
+	return err;
+}
+
+static int vmac_close(struct net_device *dev)
+{
+	struct vmac_priv *ap = netdev_priv(dev);
+	unsigned long flags;
+	unsigned int temp;
+
+	/* locking: protect everything, DMA / IRQ / timer */
+	spin_lock_irqsave(&ap->lock, flags);
+
+	/* complete running transfer, then stop */
+	temp = vmac_readl(ap, CONTROL);
+	temp &= ~(TXRN_MASK | RXRN_MASK);
+	vmac_writel(ap, temp, CONTROL);
+
+	/* save statistics, before unmapping */
+	update_vmac_stats_unlocked(dev);
+
+	/* reenable IRQ, process pending */
+	spin_unlock_irqrestore(&ap->lock, flags);
+
+	set_current_state(TASK_INTERRUPTIBLE);
+	schedule_timeout(msecs_to_jiffies(20));
+
+	/* shut it down now */
+	spin_lock_irqsave(&ap->lock, flags);
+	ap->shutdown = 1;
+
+	netif_stop_queue(dev);
+	napi_disable(&ap->napi);
+
+	/* disable phy */
+	phy_stop(ap->phy_dev);
+	vmac_mii_exit_unlocked(dev);
+	netif_carrier_off(dev);
+
+	/* disable interrupts */
+	vmac_writel(ap, 0, ENABLE);
+	free_irq(dev->irq, dev);
+
+	/* turn off vmac */
+	vmac_writel(ap, 0, CONTROL);
+	/* vmac_reset_hw(vmac) */
+
+	/* locking: concurrency off */
+	spin_unlock_irqrestore(&ap->lock, flags);
+
+	del_timer_sync(&ap->refill_timer);
+	free_buffers_unlocked(dev);
+
+	put_register_map(ap);
+
+	return 0;
+}
+
+static void update_vmac_stats_unlocked(struct net_device *dev)
+{
+	struct net_device_stats *_stats = &dev->stats;
+	struct vmac_priv *ap = netdev_priv(dev);
+	unsigned long miss, rxerr;
+	unsigned long rxfram, rxcrc, rxoflow;
+
+	/* compare with /proc/net/dev,
+	 * see net/core/dev.c:dev_seq_printf_stats */
+
+	if (ap->shutdown) {
+		/* device already unmapped */
+		return;
+	}
+
+	/* rx stats */
+	rxerr = vmac_readl(ap, RXERR);
+	miss = vmac_readl(ap, MISS);
+
+	rxcrc = (rxerr & RXERR_CRC);
+	rxfram = (rxerr & RXERR_FRM) >> 8;
+	rxoflow = (rxerr & RXERR_OFLO) >> 16;
+
+	_stats->rx_length_errors = 0;
+	_stats->rx_over_errors += miss;
+	_stats->rx_crc_errors += rxcrc;
+	_stats->rx_frame_errors += rxfram;
+	_stats->rx_fifo_errors += rxoflow;
+	_stats->rx_missed_errors = 0;
+
+	/* TODO check rx_dropped/rx_errors/tx_dropped/tx_errors have not
+	 * been updated elsewhere */
+	_stats->rx_dropped = _stats->rx_over_errors +
+		_stats->rx_fifo_errors +
+		ap->rx_merge_error;
+
+	_stats->rx_errors = _stats->rx_length_errors + _stats->rx_crc_errors +
+		_stats->rx_frame_errors +
+		_stats->rx_missed_errors +
+		_stats->rx_dropped;
+
+	/* tx stats */
+	_stats->tx_dropped = 0; /* otherwise queue stopped */
+
+	_stats->tx_errors = _stats->tx_aborted_errors +
+		_stats->tx_carrier_errors +
+		_stats->tx_fifo_errors +
+		_stats->tx_heartbeat_errors +
+		_stats->tx_window_errors +
+		_stats->tx_dropped +
+		ap->tx_timeout_error;
+}
+
+static struct net_device_stats *vmac_stats(struct net_device *dev)
+{
+	struct vmac_priv *ap = netdev_priv(dev);
+	unsigned long flags;
+
+	spin_lock_irqsave(&ap->lock, flags);
+	update_vmac_stats_unlocked(dev);
+	spin_unlock_irqrestore(&ap->lock, flags);
+
+	return &dev->stats;
+}
+
+static void vmac_tx_timeout(struct net_device *dev)
+{
+	struct vmac_priv *ap = netdev_priv(dev);
+	unsigned int status;
+	unsigned long flags;
+
+	spin_lock_irqsave(&ap->lock, flags);
+
+	/* queue did not progress for timeo jiffies */
+	WARN_ON(!netif_queue_stopped(dev));
+	WARN_ON(!fifo_full(&ap->tx_ring));
+
+	/* TX IRQ lost? */
+	status = vmac_readl(ap, STAT);
+	if (status & TXINT_MASK) {
+		dev_err(&ap->pdev->dev, "lost tx interrupt, IRQ mask %x\n",
+				vmac_readl(ap, ENABLE));
+		vmac_writel(ap, TXINT_MASK, STAT);
+	}
+
+	/* TODO RX/MDIO/ERR as well? */
+
+	vmac_tx_reclaim_unlocked(dev, 0);
+	if (fifo_full(&ap->tx_ring))
+		dev_err(&ap->pdev->dev, "DMA state machine not active\n");
+
+	/* We can accept TX packets again */
+	ap->tx_timeout_error++;
+	dev->trans_start = jiffies;
+	netif_wake_queue(dev);
+
+	spin_unlock_irqrestore(&ap->lock, flags);
+}
+
+static void create_multicast_filter(struct net_device *dev,
+	int32_t *bitmask)
+{
+	unsigned long crc;
+	char *addrs;
+
+	/* locking: done by net_device */
+
+	WARN_ON(netdev_mc_count(dev) == 0);
+	WARN_ON(dev->flags & IFF_ALLMULTI);
+
+	bitmask[0] = bitmask[1] = 0;
+
+	{
+		struct netdev_hw_addr *ha;
+		netdev_for_each_mc_addr(ha, dev) {
+			addrs = ha->addr;
+
+			/* skip non-multicast addresses */
+			if (!(*addrs & 1))
+				continue;
+
+			/* map to 0..63 */
+			crc = ether_crc_le(ETH_ALEN, addrs) >> 26;
+			bitmask[crc >= 32] |= 1UL << (crc & 31);
+		}
+	}
+}
+
+static void vmac_set_multicast_list(struct net_device *dev)
+{
+	struct vmac_priv *ap = netdev_priv(dev);
+	unsigned long flags;
+	int promisc, reg;
+	int32_t bitmask[2];
+
+	spin_lock_irqsave(&ap->lock, flags);
+
+	promisc = !!(dev->flags & IFF_PROMISC);
+	reg = vmac_readl(ap, ENABLE);
+	if (promisc != !!(reg & PROM_MASK)) {
+		reg ^= PROM_MASK;
+		vmac_writel(ap, reg, ENABLE);
+	}
+
+	if (dev->flags & IFF_ALLMULTI)
+		memset(bitmask, 1, sizeof(bitmask));
+	else if (netdev_mc_count(dev) == 0)
+		memset(bitmask, 0, sizeof(bitmask));
+	else
+		create_multicast_filter(dev, bitmask);
+
+	vmac_writel(ap, bitmask[0], LAFL);
+	vmac_writel(ap, bitmask[1], LAFH);
+
+	spin_unlock_irqrestore(&ap->lock, flags);
+}
+
+static const struct ethtool_ops vmac_ethtool_ops = {
+	.get_settings		= vmacether_get_settings,
+	.set_settings		= vmacether_set_settings,
+	.get_drvinfo		= vmacether_get_drvinfo,
+	.get_link		= ethtool_op_get_link,
+};
+
+static const struct net_device_ops vmac_netdev_ops = {
+	.ndo_open		= vmac_open,
+	.ndo_stop		= vmac_close,
+	.ndo_get_stats		= vmac_stats,
+	.ndo_start_xmit		= vmac_start_xmit,
+	.ndo_do_ioctl		= vmac_ioctl,
+	.ndo_set_mac_address	= eth_mac_addr,
+	.ndo_tx_timeout		= vmac_tx_timeout,
+	.ndo_set_rx_mode	= vmac_set_multicast_list,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_change_mtu		= eth_change_mtu,
+};
+
+static int get_register_map(struct vmac_priv *ap)
+{
+	int err;
+
+	err = -EBUSY;
+	if (!request_mem_region(ap->mem->start, resource_size(ap->mem),
+				DRV_NAME)) {
+		dev_err(&ap->pdev->dev, "no memory region available\n");
+		return err;
+	}
+
+	err = -ENOMEM;
+	ap->regs = ioremap(ap->mem->start, resource_size(ap->mem));
+	if (!ap->regs) {
+		dev_err(&ap->pdev->dev, "failed to map registers, aborting.\n");
+		goto err_out_release_mem;
+	}
+
+	return 0;
+
+err_out_release_mem:
+	release_mem_region(ap->mem->start, resource_size(ap->mem));
+	return err;
+}
+
+static int put_register_map(struct vmac_priv *ap)
+{
+	iounmap(ap->regs);
+	release_mem_region(ap->mem->start, resource_size(ap->mem));
+	return 0;
+}
+
+static int __devinit vmac_probe(struct platform_device *pdev)
+{
+	struct net_device *dev;
+	struct vmac_priv *ap;
+	struct resource *mem;
+	int err;
+
+	/* locking: no concurrency */
+
+	if (dma_get_mask(&pdev->dev) > DMA_BIT_MASK(32) ||
+			pdev->dev.coherent_dma_mask > DMA_BIT_MASK(32)) {
+		dev_err(&pdev->dev, "arcvmac supports only 32-bit DMA addresses\n");
+		return -ENODEV;
+	}
+
+	dev = alloc_etherdev(sizeof(*ap));
+	if (!dev) {
+		dev_err(&pdev->dev, "etherdev alloc failed, aborting.\n");
+		return -ENOMEM;
+	}
+
+	ap = netdev_priv(dev);
+
+	err = -ENODEV;
+	mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	if (!mem) {
+		dev_err(&pdev->dev, "no mmio resource defined\n");
+		goto err_out;
+	}
+	ap->mem = mem;
+
+	err = platform_get_irq(pdev, 0);
+	if (err < 0) {
+		dev_err(&pdev->dev, "no irq found\n");
+		goto err_out;
+	}
+	dev->irq = err;
+
+	spin_lock_init(&ap->lock);
+
+	SET_NETDEV_DEV(dev, &pdev->dev);
+	ap->dev = dev;
+	ap->pdev = pdev;
+
+	/* init rx timeout (used for oom) */
+	init_timer(&ap->refill_timer);
+	ap->refill_timer.function = vmac_refill_rx_timer;
+	ap->refill_timer.data = (unsigned long)dev;
+	spin_lock_init(&ap->refill_lock);
+
+	netif_napi_add(dev, &ap->napi, vmac_poll, 64);
+	dev->netdev_ops = &vmac_netdev_ops;
+	dev->ethtool_ops = &vmac_ethtool_ops;
+
+	dev->flags |= IFF_MULTICAST;
+
+	dev->base_addr = (unsigned long)ap->regs;
+
+	/* prevent buffer chaining, favor speed over space */
+	ap->rx_skb_size = ETH_FRAME_LEN + VMAC_BUFFER_PAD;
+
+	/* private struct functional */
+
+	/* temporarily map registers to fetch mac addr */
+	err = get_register_map(ap);
+	if (err)
+		goto err_out;
+
+	/* mac address intialize, set vmac_open  */
+	read_mac_reg(dev, dev->dev_addr);
+
+	if (!is_valid_ether_addr(dev->dev_addr))
+		random_ether_addr(dev->dev_addr);
+
+	err = register_netdev(dev);
+	if (err) {
+		dev_err(&pdev->dev, "Cannot register net device, aborting.\n");
+		goto err_out;
+	}
+
+	/* release the memory region, till open is called */
+	put_register_map(ap);
+
+	dev_info(&pdev->dev, "ARC VMAC at 0x%pP irq %d %pM\n", &mem->start,
+	    dev->irq, dev->dev_addr);
+	platform_set_drvdata(pdev, ap);
+
+	return 0;
+
+err_out:
+	free_netdev(dev);
+	return err;
+}
+
+static int __devexit vmac_remove(struct platform_device *pdev)
+{
+	struct vmac_priv *ap;
+
+	/* locking: no concurrency */
+
+	ap = platform_get_drvdata(pdev);
+	if (!ap) {
+		dev_err(&pdev->dev, "vmac_remove no valid dev found\n");
+		return 0;
+	}
+
+	/* MAC */
+	unregister_netdev(ap->dev);
+	netif_napi_del(&ap->napi);
+
+	platform_set_drvdata(pdev, NULL);
+	free_netdev(ap->dev);
+	return 0;
+}
+
+static struct platform_driver arcvmac_driver = {
+	.probe		= vmac_probe,
+	.remove		= __devexit_p(vmac_remove),
+	.driver		= {
+		.name		= "arcvmac",
+	},
+};
+
+static int __init vmac_init(void)
+{
+	return platform_driver_register(&arcvmac_driver);
+}
+
+static void __exit vmac_exit(void)
+{
+	platform_driver_unregister(&arcvmac_driver);
+}
+
+module_init(vmac_init);
+module_exit(vmac_exit);
+
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("ARC VMAC Ethernet driver");
+MODULE_AUTHOR("afenkart@gmail.com");
diff --git a/drivers/net/ethernet/arcvmac.h b/drivers/net/ethernet/arcvmac.h
new file mode 100644
index 0000000..6778b2b
--- /dev/null
+++ b/drivers/net/ethernet/arcvmac.h
@@ -0,0 +1,269 @@
+/*
+ * ARC VMAC Driver
+ *
+ * Copyright (C) 2009-2012 Andreas Fenkart
+ * All Rights Reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ *
+ * Initial work taken from arc linux distribution, any bugs are mine
+ *
+ *	-----<snip>-----
+ * Copyright (C) 2003-2006 Codito Technologies, for linux-2.4 port
+ * Copyright (C) 2006-2007 Celunite Inc, for linux-2.6 port
+ * Authors: amit.bhor@celunite.com, sameer.dhavale@celunite.com
+ *	-----<snip>-----
+ */
+
+#ifndef _ARCVMAC_H
+#define _ARCVMAC_H
+
+#define DRV_NAME		"arcvmac"
+#define DRV_VERSION		"1.0"
+
+/* Buffer descriptors */
+#define TX_BDT_LEN		128    /* Number of receive BD's */
+#define RX_BDT_LEN		128    /* Number of transmit BD's */
+
+/* BD poll rate, in 1024 cycles. @100Mhz: x * 1024 cy * 10ns = 1ms */
+#define POLLRATE_TIME		200
+
+/* next power of two, bigger than ETH_FRAME_LEN + VLAN  */
+#define MAX_RX_BUFFER_LEN	0x800	/* 2^11 = 2048 = 0x800 */
+#define MAX_TX_BUFFER_LEN	0x800	/* 2^11 = 2048 = 0x800 */
+
+/* 14 bytes of ethernet header, 4 bytes VLAN, FCS,
+ * plus extra pad to prevent buffer chaining of
+ * maximum sized ethernet packets (1514 bytes) */
+#define	VMAC_BUFFER_PAD		(ETH_HLEN + 4 + ETH_FCS_LEN + 4)
+
+/* VMAC register definitions, offsets in bytes */
+#define VMAC_ID			0x00
+
+/* stat/enable use same bit mask */
+#define VMAC_STAT		0x04
+#define VMAC_ENABLE		0x08
+#  define TXINT_MASK		0x00000001 /* Transmit interrupt */
+#  define RXINT_MASK		0x00000002 /* Receive interrupt */
+#  define ERR_MASK		0x00000004 /* Error interrupt */
+#  define TXCH_MASK		0x00000008 /* Transmit chaining error */
+#  define MSER_MASK		0x00000010 /* Missed packet counter error */
+#  define RXCR_MASK		0x00000100 /* RXCRCERR counter rolled over	 */
+#  define RXFR_MASK		0x00000200 /* RXFRAMEERR counter rolled over */
+#  define RXFL_MASK		0x00000400 /* RXOFLOWERR counter rolled over */
+#  define MDIO_MASK		0x00001000 /* MDIO complete */
+#  define TXPL_MASK		0x80000000 /* TXPOLL */
+
+#define VMAC_CONTROL		0x0c
+#  define EN_MASK		0x00000001 /* VMAC enable */
+#  define TXRN_MASK		0x00000008 /* TX enable */
+#  define RXRN_MASK		0x00000010 /* RX enable */
+#  define DSBC_MASK		0x00000100 /* Disable receive broadcast */
+#  define ENFL_MASK		0x00000400 /* Enable Full Duplex */
+#  define PROM_MASK		0x00000800 /* Promiscuous mode */
+
+#define VMAC_POLLRATE		0x10
+
+#define VMAC_RXERR		0x14
+#  define RXERR_CRC		0x000000ff
+#  define RXERR_FRM		0x0000ff00
+#  define RXERR_OFLO		0x00ff0000 /* fifo overflow */
+
+#define VMAC_MISS		0x18
+#define VMAC_TXRINGPTR		0x1c
+#define VMAC_RXRINGPTR		0x20
+#define VMAC_ADDRL		0x24
+#define VMAC_ADDRH		0x28
+#define VMAC_LAFL		0x2c
+#define VMAC_LAFH		0x30
+#define VMAC_MAC_TXRING_HEAD	0x38
+#define VMAC_MAC_RXRING_HEAD	0x3C
+
+#define VMAC_MDIO_DATA		0x34
+#  define MDIO_SFD		0xC0000000
+#  define MDIO_OP		0x30000000
+#  define MDIO_ID_MASK		0x0F800000
+#  define MDIO_REG_MASK		0x007C0000
+#  define MDIO_TA		0x00030000
+#  define MDIO_DATA_MASK	0x0000FFFF
+/* common combinations */
+#  define MDIO_BASE		0x40020000
+#  define MDIO_OP_READ		0x20000000
+#  define MDIO_OP_WRITE		0x10000000
+
+/* Buffer descriptor INFO bit masks */
+#define BD_DMA_OWN		0x80000000 /* buffer ownership, 0 CPU, 1 DMA */
+#define BD_BUFF			0x40000000 /* buffer invalid, rx */
+#define BD_UFLO			0x20000000 /* underflow, tx */
+#define BD_LTCL			0x10000000 /* late collision, tx  */
+#define BD_RETRY_CT		0x0f000000 /* tx */
+#define BD_DROP			0x00800000 /* drop, more than 16 retries, tx */
+#define BD_DEFER		0x00400000 /* traffic on the wire, tx */
+#define BD_CARLOSS		0x00200000 /* carrier loss while transmission, tx, rx? */
+/* 20:19 reserved */
+#define BD_ADCR			0x00040000 /* add crc, ignored if not disaddcrc */
+#define BD_LAST			0x00020000 /* Last buffer in chain */
+#define BD_FRST			0x00010000 /* First buffer in chain */
+/* 15:11 reserved */
+#define BD_LEN			0x000007FF
+
+/* common combinations */
+#define BD_TX_ERR		(BD_UFLO | BD_LTCL | BD_RETRY_CT | BD_DROP | \
+		BD_DEFER | BD_CARLOSS)
+
+
+/* arcvmac private data structures */
+struct vmac_buffer_desc {
+	__le32 info;
+	__le32 data;
+};
+
+struct dma_fifo {
+	int head; /* head */
+	int tail; /* tail */
+	int size;
+};
+
+struct	vmac_priv {
+	struct net_device *dev;
+	struct platform_device *pdev;
+
+	struct completion mdio_complete;
+	spinlock_t lock; /* protects structure plus hw regs of device */
+
+	/* base address of register set */
+	char *regs;
+	struct resource *mem;
+
+	/* DMA ring buffers */
+	struct vmac_buffer_desc *rxbd;
+	dma_addr_t rxbd_dma;
+
+	struct vmac_buffer_desc *txbd;
+	dma_addr_t txbd_dma;
+
+	/* socket buffers */
+	struct sk_buff *rx_skbuff[RX_BDT_LEN];
+	struct sk_buff *tx_skbuff[TX_BDT_LEN];
+	int rx_skb_size;
+
+	/* skb / dma desc managing */
+	struct dma_fifo rx_ring; /* valid rx buffers */
+	struct dma_fifo tx_ring;
+
+	/* descriptor last polled/processed by the VMAC */
+	unsigned long dma_rx_head;
+
+	/* timer to retry rx skb allocation, if failed during receive */
+	struct timer_list refill_timer;
+	spinlock_t refill_lock;
+
+	struct napi_struct napi;
+
+	/* rx buffer chaining */
+	int rx_merge_error;
+	int tx_timeout_error;
+
+	/* PHY stuff */
+	struct mii_bus *mii_bus;
+	struct phy_device *phy_dev;
+
+	int link;
+	int speed;
+	int duplex;
+
+	/* debug */
+	int shutdown;
+};
+
+/* DMA ring management */
+
+/* for a fifo with size n,
+ * - [0..n] fill levels are n + 1 states
+ * - there are only n different deltas (head - tail) values
+ * => not all fill levels can be represented with head, tail
+ *    pointers only
+ * we give up the n fill level, aka fifo full */
+
+/* sacrifice one elt as a sentinel */
+static inline int fifo_used(struct dma_fifo *f);
+static inline int fifo_inc_ct(int ct, int size);
+static inline void fifo_dump(struct dma_fifo *fifo);
+
+static inline int fifo_empty(struct dma_fifo *f)
+{
+	return f->head == f->tail;
+}
+
+static inline int fifo_free(struct dma_fifo *f)
+{
+	int free;
+
+	free = f->tail - f->head;
+	if (free <= 0)
+		free += f->size;
+
+	return free;
+}
+
+static inline int fifo_used(struct dma_fifo *f)
+{
+	int used;
+
+	used = f->head - f->tail;
+	if (used < 0)
+		used += f->size;
+
+	return used;
+}
+
+static inline int fifo_full(struct dma_fifo *f)
+{
+	return (fifo_used(f) + 1) == f->size;
+}
+
+/* manipulate */
+static inline void fifo_init(struct dma_fifo *fifo, int size)
+{
+	fifo->size = size;
+	fifo->head = fifo->tail = 0; /* empty */
+}
+
+static inline void fifo_inc_head(struct dma_fifo *fifo)
+{
+	BUG_ON(fifo_full(fifo));
+	fifo->head = fifo_inc_ct(fifo->head, fifo->size);
+}
+
+static inline void fifo_inc_tail(struct dma_fifo *fifo)
+{
+	BUG_ON(fifo_empty(fifo));
+	fifo->tail = fifo_inc_ct(fifo->tail, fifo->size);
+}
+
+/* internal funcs */
+static inline void fifo_dump(struct dma_fifo *fifo)
+{
+	pr_info("fifo: head %d, tail %d, size %d\n", fifo->head,
+			fifo->tail,
+			fifo->size);
+}
+
+static inline int fifo_inc_ct(int ct, int size)
+{
+	return (++ct == size) ? 0 : ct;
+}
+
+#endif	  /* _ARCVMAC_H */
-- 
1.7.9.1

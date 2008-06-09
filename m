From: akpm@linux-foundation.org
Subject: [patch 12/13] net: sh_eth: add support for Renesas SuperH Ethernet
Date: Mon, 09 Jun 2008 16:33:56 -0700
Message-ID: <200806092333.m59NXuNA014705@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	iwamatsu.nobuhiro@renesas.com, lethal@linux-sh.org,
	shimoda.yoshihiro@renesas.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:40749 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757027AbYFIXed (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2008 19:34:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nobuhiro Iwamatsu <iwamatsu.nobuhiro@renesas.com>

Add support for Renesas SuperH Ethernet controller.  This driver supports
SH7710 and SH7712.

[akpm@linux-foundation.org: coding-style fixes]
Signed-off-by: Yoshihiro Shimoda <shimoda.yoshihiro@renesas.com>
Signed-off-by: Nobuhiro Iwamatsu <iwamatsu.nobuhiro@renesas.com>
Cc: Paul Mundt <lethal@linux-sh.org>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/Kconfig  |   12 
 drivers/net/Makefile |    1 
 drivers/net/sh_eth.c | 1174 +++++++++++++++++++++++++++++++++++++++++
 drivers/net/sh_eth.h |  464 ++++++++++++++++
 4 files changed, 1651 insertions(+)

diff -puN drivers/net/Kconfig~net-sh_eth-add-support-for-renesas-superh-ethernet drivers/net/Kconfig
--- a/drivers/net/Kconfig~net-sh_eth-add-support-for-renesas-superh-ethernet
+++ a/drivers/net/Kconfig
@@ -524,6 +524,18 @@ config STNIC
 
 	  If unsure, say N.
 
+config SH_ETH
+	tristate "Renesas SuperH Ethernet support"
+	depends on SUPERH && \
+		(CPU_SUBTYPE_SH7710 || CPU_SUBTYPE_SH7712)
+	select CRC32
+	select MII
+	select MDIO_BITBANG
+	select PHYLIB
+	help
+	  Renesas SuperH Ethernet device driver.
+	  This driver support SH7710 and SH7712.
+
 config SUNLANCE
 	tristate "Sun LANCE support"
 	depends on SBUS
diff -puN drivers/net/Makefile~net-sh_eth-add-support-for-renesas-superh-ethernet drivers/net/Makefile
--- a/drivers/net/Makefile~net-sh_eth-add-support-for-renesas-superh-ethernet
+++ a/drivers/net/Makefile
@@ -80,6 +80,7 @@ obj-$(CONFIG_VIA_RHINE) += via-rhine.o
 obj-$(CONFIG_VIA_VELOCITY) += via-velocity.o
 obj-$(CONFIG_ADAPTEC_STARFIRE) += starfire.o
 obj-$(CONFIG_RIONET) += rionet.o
+obj-$(CONFIG_SH_ETH) += sh_eth.o
 
 #
 # end link order section
diff -puN /dev/null drivers/net/sh_eth.c
--- /dev/null
+++ a/drivers/net/sh_eth.c
@@ -0,0 +1,1174 @@
+/*
+ *  SuperH Ethernet device driver
+ *
+ *  Copyright (C) 2006,2007 Nobuhiro Iwamatsu
+ *  Copyright (C) 2008 Renesas Solutions Corp.
+ *
+ *  This program is free software; you can redistribute it and/or modify it
+ *  under the terms and conditions of the GNU General Public License,
+ *  version 2, as published by the Free Software Foundation.
+ *
+ *  This program is distributed in the hope it will be useful, but WITHOUT
+ *  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ *  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ *  more details.
+ *  You should have received a copy of the GNU General Public License along with
+ *  this program; if not, write to the Free Software Foundation, Inc.,
+ *  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+ *
+ *  The full GNU General Public License is included in this distribution in
+ *  the file called "COPYING".
+ */
+
+#include <linux/version.h>
+#include <linux/init.h>
+#include <linux/dma-mapping.h>
+#include <linux/etherdevice.h>
+#include <linux/delay.h>
+#include <linux/platform_device.h>
+#include <linux/mdio-bitbang.h>
+#include <linux/netdevice.h>
+#include <linux/phy.h>
+#include <linux/cache.h>
+#include <linux/io.h>
+
+#include "sh_eth.h"
+
+/*
+ * Program the hardware MAC address from dev->dev_addr.
+ */
+static void update_mac_address(struct net_device *ndev)
+{
+	u32 ioaddr = ndev->base_addr;
+
+	ctrl_outl((ndev->dev_addr[0] << 24) | (ndev->dev_addr[1] << 16) |
+		  (ndev->dev_addr[2] << 8) | (ndev->dev_addr[3]),
+		  ioaddr + MAHR);
+	ctrl_outl((ndev->dev_addr[4] << 8) | (ndev->dev_addr[5]),
+		  ioaddr + MALR);
+}
+
+/*
+ * Get MAC address from SuperH MAC address register
+ *
+ * SuperH's Ethernet device doesn't have 'ROM' to MAC address.
+ * This driver get MAC address that use by bootloader(U-boot or sh-ipl+g).
+ * When you want use this device, you must set MAC address in bootloader.
+ *
+ */
+static void read_mac_address(struct net_device *ndev)
+{
+	u32 ioaddr = ndev->base_addr;
+
+	ndev->dev_addr[0] = (ctrl_inl(ioaddr + MAHR) >> 24);
+	ndev->dev_addr[1] = (ctrl_inl(ioaddr + MAHR) >> 16) & 0xFF;
+	ndev->dev_addr[2] = (ctrl_inl(ioaddr + MAHR) >> 8) & 0xFF;
+	ndev->dev_addr[3] = (ctrl_inl(ioaddr + MAHR) & 0xFF);
+	ndev->dev_addr[4] = (ctrl_inl(ioaddr + MALR) >> 8) & 0xFF;
+	ndev->dev_addr[5] = (ctrl_inl(ioaddr + MALR) & 0xFF);
+}
+
+struct bb_info {
+	struct mdiobb_ctrl ctrl;
+	u32 addr;
+	u32 mmd_msk;/* MMD */
+	u32 mdo_msk;
+	u32 mdi_msk;
+	u32 mdc_msk;
+};
+
+/* PHY bit set */
+static void bb_set(u32 addr, u32 msk)
+{
+	ctrl_outl(ctrl_inl(addr) | msk, addr);
+}
+
+/* PHY bit clear */
+static void bb_clr(u32 addr, u32 msk)
+{
+	ctrl_outl((ctrl_inl(addr) & ~msk), addr);
+}
+
+/* PHY bit read */
+static int bb_read(u32 addr, u32 msk)
+{
+	return (ctrl_inl(addr) & msk) != 0;
+}
+
+/* Data I/O pin control */
+static void sh_mmd_ctrl(struct mdiobb_ctrl *ctrl, int bit)
+{
+	struct bb_info *bitbang = container_of(ctrl, struct bb_info, ctrl);
+	if (bit)
+		bb_set(bitbang->addr, bitbang->mmd_msk);
+	else
+		bb_clr(bitbang->addr, bitbang->mmd_msk);
+}
+
+/* Set bit data*/
+static void sh_set_mdio(struct mdiobb_ctrl *ctrl, int bit)
+{
+	struct bb_info *bitbang = container_of(ctrl, struct bb_info, ctrl);
+
+	if (bit)
+		bb_set(bitbang->addr, bitbang->mdo_msk);
+	else
+		bb_clr(bitbang->addr, bitbang->mdo_msk);
+}
+
+/* Get bit data*/
+static int sh_get_mdio(struct mdiobb_ctrl *ctrl)
+{
+	struct bb_info *bitbang = container_of(ctrl, struct bb_info, ctrl);
+	return bb_read(bitbang->addr, bitbang->mdi_msk);
+}
+
+/* MDC pin control */
+static void sh_mdc_ctrl(struct mdiobb_ctrl *ctrl, int bit)
+{
+	struct bb_info *bitbang = container_of(ctrl, struct bb_info, ctrl);
+
+	if (bit)
+		bb_set(bitbang->addr, bitbang->mdc_msk);
+	else
+		bb_clr(bitbang->addr, bitbang->mdc_msk);
+}
+
+/* mdio bus control struct */
+static struct mdiobb_ops bb_ops = {
+	.owner = THIS_MODULE,
+	.set_mdc = sh_mdc_ctrl,
+	.set_mdio_dir = sh_mmd_ctrl,
+	.set_mdio_data = sh_set_mdio,
+	.get_mdio_data = sh_get_mdio,
+};
+
+static void sh_eth_reset(struct net_device *ndev)
+{
+	u32 ioaddr = ndev->base_addr;
+
+	ctrl_outl(ctrl_inl(ioaddr + EDMR) | EDMR_SRST, ioaddr + EDMR);
+	mdelay(3);
+	ctrl_outl(ctrl_inl(ioaddr + EDMR) & ~EDMR_SRST, ioaddr + EDMR);
+}
+
+/* free skb and descriptor buffer */
+static void sh_eth_ring_free(struct net_device *ndev)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+	int i;
+
+	/* Free Rx skb ringbuffer */
+	if (mdp->rx_skbuff) {
+		for (i = 0; i < RX_RING_SIZE; i++) {
+			if (mdp->rx_skbuff[i])
+				dev_kfree_skb(mdp->rx_skbuff[i]);
+		}
+	}
+	kfree(mdp->rx_skbuff);
+
+	/* Free Tx skb ringbuffer */
+	if (mdp->tx_skbuff) {
+		for (i = 0; i < TX_RING_SIZE; i++) {
+			if (mdp->tx_skbuff[i])
+				dev_kfree_skb(mdp->tx_skbuff[i]);
+		}
+	}
+	kfree(mdp->tx_skbuff);
+}
+
+/* format skb and descriptor buffer */
+static void sh_eth_ring_format(struct net_device *ndev)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+	int i;
+	struct sk_buff *skb;
+	struct sh_eth_rxdesc *rxdesc = NULL;
+	struct sh_eth_txdesc *txdesc = NULL;
+	int rx_ringsize = sizeof(*rxdesc) * RX_RING_SIZE;
+	int tx_ringsize = sizeof(*txdesc) * TX_RING_SIZE;
+
+	mdp->cur_rx = mdp->cur_tx = 0;
+	mdp->dirty_rx = mdp->dirty_tx = 0;
+
+	memset(mdp->rx_ring, 0, rx_ringsize);
+
+	/* build Rx ring buffer */
+	for (i = 0; i < RX_RING_SIZE; i++) {
+		/* skb */
+		mdp->rx_skbuff[i] = NULL;
+		skb = dev_alloc_skb(mdp->rx_buf_sz);
+		mdp->rx_skbuff[i] = skb;
+		if (skb == NULL)
+			break;
+		skb->dev = ndev;	/* Mark as being used by this device. */
+		skb_reserve(skb, RX_OFFSET);
+
+		/* RX descriptor */
+		rxdesc = &mdp->rx_ring[i];
+		rxdesc->addr = (u32)skb->data & ~0x3UL;
+		rxdesc->status = cpu_to_le32(RD_RACT | RD_RFP);
+
+		/* The size of the buffer is 16 byte boundary. */
+		rxdesc->buffer_length = (mdp->rx_buf_sz + 16) & ~0x0F;
+	}
+
+	mdp->dirty_rx = (u32) (i - RX_RING_SIZE);
+
+	/* Mark the last entry as wrapping the ring. */
+	rxdesc->status |= cpu_to_le32(RC_RDEL);
+
+	memset(mdp->tx_ring, 0, tx_ringsize);
+
+	/* build Tx ring buffer */
+	for (i = 0; i < TX_RING_SIZE; i++) {
+		mdp->tx_skbuff[i] = NULL;
+		txdesc = &mdp->tx_ring[i];
+		txdesc->status = cpu_to_le32(TD_TFP);
+		txdesc->buffer_length = 0;
+	}
+
+	txdesc->status |= cpu_to_le32(TD_TDLE);
+}
+
+/* Get skb and descriptor buffer */
+static int sh_eth_ring_init(struct net_device *ndev)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+	int rx_ringsize, tx_ringsize, ret = 0;
+
+	/*
+	 * +26 gets the maximum ethernet encapsulation, +7 & ~7 because the
+	 * card needs room to do 8 byte alignment, +2 so we can reserve
+	 * the first 2 bytes, and +16 gets room for the status word from the
+	 * card.
+	 */
+	mdp->rx_buf_sz = (ndev->mtu <= 1492 ? PKT_BUF_SZ :
+			  (((ndev->mtu + 26 + 7) & ~7) + 2 + 16));
+
+	/* Allocate RX and TX skb rings */
+	mdp->rx_skbuff = kmalloc(sizeof(*mdp->rx_skbuff) * RX_RING_SIZE,
+				GFP_KERNEL);
+	if (!mdp->rx_skbuff) {
+		printk(KERN_ERR "%s: Cannot allocate Rx skb\n", ndev->name);
+		ret = -ENOMEM;
+		return ret;
+	}
+
+	mdp->tx_skbuff = kmalloc(sizeof(*mdp->tx_skbuff) * TX_RING_SIZE,
+				GFP_KERNEL);
+	if (!mdp->tx_skbuff) {
+		printk(KERN_ERR "%s: Cannot allocate Tx skb\n", ndev->name);
+		ret = -ENOMEM;
+		goto skb_ring_free;
+	}
+
+	/* Allocate all Rx descriptors. */
+	rx_ringsize = sizeof(struct sh_eth_rxdesc) * RX_RING_SIZE;
+	mdp->rx_ring = dma_alloc_coherent(NULL, rx_ringsize, &mdp->rx_desc_dma,
+			GFP_KERNEL);
+
+	if (!mdp->rx_ring) {
+		printk(KERN_ERR "%s: Cannot allocate Rx Ring (size %d bytes)\n",
+			ndev->name, rx_ringsize);
+		ret = -ENOMEM;
+		goto desc_ring_free;
+	}
+
+	mdp->dirty_rx = 0;
+
+	/* Allocate all Tx descriptors. */
+	tx_ringsize = sizeof(struct sh_eth_txdesc) * TX_RING_SIZE;
+	mdp->tx_ring = dma_alloc_coherent(NULL, tx_ringsize, &mdp->tx_desc_dma,
+			GFP_KERNEL);
+	if (!mdp->tx_ring) {
+		printk(KERN_ERR "%s: Cannot allocate Tx Ring (size %d bytes)\n",
+			ndev->name, tx_ringsize);
+		ret = -ENOMEM;
+		goto desc_ring_free;
+	}
+	return ret;
+
+desc_ring_free:
+	/* free DMA buffer */
+	dma_free_coherent(NULL, rx_ringsize, mdp->rx_ring, mdp->rx_desc_dma);
+
+skb_ring_free:
+	/* Free Rx and Tx skb ring buffer */
+	sh_eth_ring_free(ndev);
+
+	return ret;
+}
+
+static int sh_eth_dev_init(struct net_device *ndev)
+{
+	int ret = 0;
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+	u32 ioaddr = ndev->base_addr;
+	u_int32_t rx_int_var, tx_int_var;
+	u32 val;
+
+	/* Soft Reset */
+	sh_eth_reset(ndev);
+
+	ctrl_outl(RPADIR_PADS1, ioaddr + RPADIR);	/* SH7712-DMA-RX-PAD2 */
+
+	/* all sh_eth int mask */
+	ctrl_outl(0, ioaddr + EESIPR);
+
+	/* FIFO size set */
+	ctrl_outl(0, ioaddr + EDMR);	/* Endian change */
+
+	ctrl_outl((FIFO_SIZE_T | FIFO_SIZE_R), ioaddr + FDR);
+	ctrl_outl(0, ioaddr + TFTR);
+
+	ctrl_outl(RMCR_RST, ioaddr + RMCR);
+
+	rx_int_var = mdp->rx_int_var = DESC_I_RINT8 | DESC_I_RINT5;
+	tx_int_var = mdp->tx_int_var = DESC_I_TINT2;
+	ctrl_outl(rx_int_var | tx_int_var, ioaddr + TRSCER);
+
+	ctrl_outl((FIFO_F_D_RFF | FIFO_F_D_RFD), ioaddr + FCFTR);
+	ctrl_outl(0, ioaddr + TRIMD);
+
+	/* Descriptor format */
+	sh_eth_ring_format(ndev);
+
+	ctrl_outl((u32)mdp->rx_ring, ioaddr + RDLAR);
+	ctrl_outl((u32)mdp->tx_ring, ioaddr + TDLAR);
+
+	ctrl_outl(ctrl_inl(ioaddr + EESR), ioaddr + EESR);
+	ctrl_outl((DMAC_M_RFRMER | DMAC_M_ECI | 0x003fffff), ioaddr + EESIPR);
+
+	/* PAUSE Prohibition */
+	val = (ctrl_inl(ioaddr + ECMR) & ECMR_DM) |
+		ECMR_ZPF | (mdp->duplex ? ECMR_DM : 0) | ECMR_TE | ECMR_RE;
+
+	ctrl_outl(val, ioaddr + ECMR);
+	ctrl_outl(ECSR_BRCRX | ECSR_PSRTO | ECSR_LCHNG | ECSR_ICD |
+		  ECSIPR_MPDIP, ioaddr + ECSR);
+	ctrl_outl(ECSIPR_BRCRXIP | ECSIPR_PSRTOIP | ECSIPR_LCHNGIP |
+		  ECSIPR_ICDIP | ECSIPR_MPDIP, ioaddr + ECSIPR);
+
+	/* Set MAC address */
+	update_mac_address(ndev);
+
+	/* mask reset */
+#if defined(CONFIG_CPU_SUBTYPE_SH7710)
+	ctrl_outl(APR_AP, ioaddr + APR);
+	ctrl_outl(MPR_MP, ioaddr + MPR);
+	ctrl_outl(TPAUSER_UNLIMITED, ioaddr + TPAUSER);
+	ctrl_outl(BCFR_UNLIMITED, ioaddr + BCFR);
+#endif
+	/* Setting the Rx mode will start the Rx process. */
+	ctrl_outl(EDRRR_R, ioaddr + EDRRR);
+
+	netif_start_queue(ndev);
+
+	return ret;
+}
+
+/* free Tx skb function */
+static int sh_eth_txfree(struct net_device *ndev)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+	struct sh_eth_txdesc *txdesc;
+	int freeNum = 0;
+	int entry = 0;
+
+	for (; mdp->cur_tx - mdp->dirty_tx > 0; mdp->dirty_tx++) {
+		entry = mdp->dirty_tx % TX_RING_SIZE;
+		txdesc = &mdp->tx_ring[entry];
+		if (txdesc->status & cpu_to_le32(TD_TACT))
+			break;
+		/* Free the original skb. */
+		if (mdp->tx_skbuff[entry]) {
+			dev_kfree_skb_irq(mdp->tx_skbuff[entry]);
+			mdp->tx_skbuff[entry] = NULL;
+			freeNum++;
+		}
+		txdesc->status = cpu_to_le32(TD_TFP);
+		if (entry >= TX_RING_SIZE - 1)
+			txdesc->status |= cpu_to_le32(TD_TDLE);
+
+		mdp->stats.tx_packets++;
+		mdp->stats.tx_bytes += txdesc->buffer_length;
+	}
+	return freeNum;
+}
+
+/* Packet receive function */
+static int sh_eth_rx(struct net_device *ndev)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+	struct sh_eth_rxdesc *rxdesc;
+
+	int entry = mdp->cur_rx % RX_RING_SIZE;
+	int boguscnt = (mdp->dirty_rx + RX_RING_SIZE) - mdp->cur_rx;
+	struct sk_buff *skb;
+	u16 pkt_len = 0;
+	u32 desc_status;
+
+	rxdesc = &mdp->rx_ring[entry];
+	while (!(rxdesc->status & cpu_to_le32(RD_RACT))) {
+		desc_status = le32_to_cpu(rxdesc->status);
+		pkt_len = rxdesc->frame_length;
+
+		if (--boguscnt < 0)
+			break;
+
+		if (!(desc_status & RDFEND))
+			mdp->stats.rx_length_errors++;
+
+		if (desc_status & (RD_RFS1 | RD_RFS2 | RD_RFS3 | RD_RFS4 |
+				   RD_RFS5 | RD_RFS6 | RD_RFS10)) {
+			mdp->stats.rx_errors++;
+			if (desc_status & RD_RFS1)
+				mdp->stats.rx_crc_errors++;
+			if (desc_status & RD_RFS2)
+				mdp->stats.rx_frame_errors++;
+			if (desc_status & RD_RFS3)
+				mdp->stats.rx_length_errors++;
+			if (desc_status & RD_RFS4)
+				mdp->stats.rx_length_errors++;
+			if (desc_status & RD_RFS6)
+				mdp->stats.rx_missed_errors++;
+			if (desc_status & RD_RFS10)
+				mdp->stats.rx_over_errors++;
+		} else {
+			swaps((char *)(rxdesc->addr & ~0x3), pkt_len + 2);
+			skb = mdp->rx_skbuff[entry];
+			mdp->rx_skbuff[entry] = NULL;
+			skb_put(skb, pkt_len);
+			skb->protocol = eth_type_trans(skb, ndev);
+			netif_rx(skb);
+			ndev->last_rx = jiffies;
+			mdp->stats.rx_packets++;
+			mdp->stats.rx_bytes += pkt_len;
+		}
+		rxdesc->status |= cpu_to_le32(RD_RACT);
+		entry = (++mdp->cur_rx) % RX_RING_SIZE;
+	}
+
+	/* Refill the Rx ring buffers. */
+	for (; mdp->cur_rx - mdp->dirty_rx > 0; mdp->dirty_rx++) {
+		entry = mdp->dirty_rx % RX_RING_SIZE;
+		rxdesc = &mdp->rx_ring[entry];
+		if (mdp->rx_skbuff[entry] == NULL) {
+			skb = dev_alloc_skb(mdp->rx_buf_sz);
+			mdp->rx_skbuff[entry] = skb;
+			if (skb == NULL)
+				break;	/* Better luck next round. */
+			skb->dev = ndev;
+			skb_reserve(skb, RX_OFFSET);
+			rxdesc->addr = (u32)skb->data & ~0x3UL;
+		}
+		/* The size of the buffer is 16 byte boundary. */
+		rxdesc->buffer_length = (mdp->rx_buf_sz + 16) & ~0x0F;
+		if (entry >= RX_RING_SIZE - 1)
+			rxdesc->status |=
+			cpu_to_le32(RD_RACT | RD_RFP | RC_RDEL);
+		else
+			rxdesc->status |=
+			cpu_to_le32(RD_RACT | RD_RFP);
+	}
+
+	/* Restart Rx engine if stopped. */
+	/* If we don't need to check status, don't. -KDU */
+	ctrl_outl(EDRRR_R, ndev->base_addr + EDRRR);
+
+	return 0;
+}
+
+/* error control function */
+static void sh_eth_error(struct net_device *ndev, int intr_status)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+	u32 ioaddr = ndev->base_addr;
+	u32 felic_stat;
+
+	if (intr_status & EESR_ECI) {
+		felic_stat = ctrl_inl(ioaddr + ECSR);
+		ctrl_outl(felic_stat, ioaddr + ECSR);	/* clear int */
+		if (felic_stat & ECSR_ICD)
+			mdp->stats.tx_carrier_errors++;
+		if (felic_stat & ECSR_LCHNG) {
+			/* Link Changed */
+			u32 link_stat = (ctrl_inl(ioaddr + PSR));
+			if (!(link_stat & PHY_ST_LINK)) {
+				/* Link Down : disable tx and rx */
+				ctrl_outl(ctrl_inl(ioaddr + ECMR) &
+					  ~(ECMR_RE | ECMR_TE), ioaddr + ECMR);
+			} else {
+				/* Link Up */
+				ctrl_outl(ctrl_inl(ioaddr + EESIPR) &
+					  ~DMAC_M_ECI, ioaddr + EESIPR);
+				/*clear int */
+				ctrl_outl(ctrl_inl(ioaddr + ECSR),
+					  ioaddr + ECSR);
+				ctrl_outl(ctrl_inl(ioaddr + EESIPR) |
+					  DMAC_M_ECI, ioaddr + EESIPR);
+				/* enable tx and rx */
+				ctrl_outl(ctrl_inl(ioaddr + ECMR) |
+					  (ECMR_RE | ECMR_TE), ioaddr + ECMR);
+			}
+		}
+	}
+
+	if (intr_status & EESR_TWB) {
+		/* Write buck end. unused write back interrupt */
+		if (intr_status & EESR_TABT)	/* Transmit Abort int */
+			mdp->stats.tx_aborted_errors++;
+	}
+
+	if (intr_status & EESR_RABT) {
+		/* Receive Abort int */
+		if (intr_status & EESR_RFRMER) {
+			/* Receive Frame Overflow int */
+			mdp->stats.rx_frame_errors++;
+			printk(KERN_ERR "Receive Frame Overflow\n");
+		}
+	}
+
+	if (intr_status & EESR_ADE) {
+		if (intr_status & EESR_TDE) {
+			if (intr_status & EESR_TFE)
+				mdp->stats.tx_fifo_errors++;
+		}
+	}
+
+	if (intr_status & EESR_RDE) {
+		/* Receive Descriptor Empty int */
+		mdp->stats.rx_over_errors++;
+
+		if (ctrl_inl(ioaddr + EDRRR) ^ EDRRR_R)
+			ctrl_outl(EDRRR_R, ioaddr + EDRRR);
+		printk(KERN_ERR "Receive Descriptor Empty\n");
+	}
+	if (intr_status & EESR_RFE) {
+		/* Receive FIFO Overflow int */
+		mdp->stats.rx_fifo_errors++;
+		printk(KERN_ERR "Receive FIFO Overflow\n");
+	}
+	if (intr_status &
+	    (EESR_TWB | EESR_TABT | EESR_ADE | EESR_TDE | EESR_TFE)) {
+		/* Tx error */
+		u32 edtrr = ctrl_inl(ndev->base_addr + EDTRR);
+		/* dmesg */
+		printk(KERN_ERR "%s:TX error. status=%8.8x cur_tx=%8.8x ",
+				ndev->name, intr_status, mdp->cur_tx);
+		printk(KERN_ERR "dirty_tx=%8.8x state=%8.8x EDTRR=%8.8x.\n",
+				mdp->dirty_tx, (u32) ndev->state, edtrr);
+		/* dirty buffer free */
+		sh_eth_txfree(ndev);
+
+		/* SH7712 BUG */
+		if (edtrr ^ EDTRR_TRNS) {
+			/* tx dma start */
+			ctrl_outl(EDTRR_TRNS, ndev->base_addr + EDTRR);
+		}
+		/* wakeup */
+		netif_wake_queue(ndev);
+	}
+}
+
+static irqreturn_t sh_eth_interrupt(int irq, void *netdev)
+{
+	struct net_device *ndev = netdev;
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+	u32 ioaddr, boguscnt = RX_RING_SIZE;
+	u32 intr_status = 0;
+
+	ioaddr = ndev->base_addr;
+	spin_lock(&mdp->lock);
+
+	intr_status = ctrl_inl(ioaddr + EESR);
+	/* Clear interrupt */
+	ctrl_outl(intr_status, ioaddr + EESR);
+
+	if (intr_status & (EESR_FRC | EESR_RINT8 |
+			   EESR_RINT5 | EESR_RINT4 | EESR_RINT3 | EESR_RINT2 |
+			   EESR_RINT1))
+		sh_eth_rx(ndev);
+	if (intr_status & (EESR_FTC |
+			   EESR_TINT4 | EESR_TINT3 | EESR_TINT2 | EESR_TINT1)) {
+
+		sh_eth_txfree(ndev);
+		netif_wake_queue(ndev);
+	}
+
+	if (intr_status & EESR_ERR_CHECK)
+		sh_eth_error(ndev, intr_status);
+
+	if (--boguscnt < 0) {
+		printk(KERN_WARNING
+		       "%s: Too much work at interrupt, status=0x%4.4x.\n",
+		       ndev->name, intr_status);
+	}
+
+	spin_unlock(&mdp->lock);
+
+	return IRQ_HANDLED;
+}
+
+static void sh_eth_timer(unsigned long data)
+{
+	struct net_device *ndev = (struct net_device *)data;
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+
+	mod_timer(&mdp->timer, jiffies + (10 * HZ));
+}
+
+/* PHY state control function */
+static void sh_eth_adjust_link(struct net_device *ndev)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+	struct phy_device *phydev = mdp->phydev;
+	u32 ioaddr = ndev->base_addr;
+	int new_state = 0;
+
+	if (phydev->link != PHY_DOWN) {
+		if (phydev->duplex != mdp->duplex) {
+			new_state = 1;
+			mdp->duplex = phydev->duplex;
+		}
+
+		if (phydev->speed != mdp->speed) {
+			new_state = 1;
+			mdp->speed = phydev->speed;
+		}
+		if (mdp->link == PHY_DOWN) {
+			ctrl_outl((ctrl_inl(ioaddr + ECMR) & ~ECMR_TXF)
+					| ECMR_DM, ioaddr + ECMR);
+			new_state = 1;
+			mdp->link = phydev->link;
+			netif_schedule(ndev);
+			netif_carrier_on(ndev);
+			netif_start_queue(ndev);
+		}
+	} else if (mdp->link) {
+		new_state = 1;
+		mdp->link = PHY_DOWN;
+		mdp->speed = 0;
+		mdp->duplex = -1;
+		netif_stop_queue(ndev);
+		netif_carrier_off(ndev);
+	}
+
+	if (new_state)
+		phy_print_status(phydev);
+}
+
+/* PHY init function */
+static int sh_eth_phy_init(struct net_device *ndev)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+	char phy_id[BUS_ID_SIZE];
+	struct phy_device *phydev = NULL;
+
+	snprintf(phy_id, BUS_ID_SIZE, PHY_ID_FMT,
+		mdp->mii_bus->id , mdp->phy_id);
+
+	mdp->link = PHY_DOWN;
+	mdp->speed = 0;
+	mdp->duplex = -1;
+
+	/* Try connect to PHY */
+	phydev = phy_connect(ndev, phy_id, &sh_eth_adjust_link,
+				0, PHY_INTERFACE_MODE_MII);
+	if (IS_ERR(phydev)) {
+		dev_err(&ndev->dev, "phy_connect failed\n");
+		return PTR_ERR(phydev);
+	}
+	dev_info(&ndev->dev, "attached phy %i to driver %s\n",
+	phydev->addr, phydev->drv->name);
+
+	mdp->phydev = phydev;
+
+	return 0;
+}
+
+/* PHY control start function */
+static int sh_eth_phy_start(struct net_device *ndev)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+	int ret;
+
+	ret = sh_eth_phy_init(ndev);
+	if (ret)
+		return ret;
+
+	/* reset phy - this also wakes it from PDOWN */
+	phy_write(mdp->phydev, MII_BMCR, BMCR_RESET);
+	phy_start(mdp->phydev);
+
+	return 0;
+}
+
+/* network device open function */
+static int sh_eth_open(struct net_device *ndev)
+{
+	int ret = 0;
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+
+	ret = request_irq(ndev->irq, &sh_eth_interrupt, 0, ndev->name, ndev);
+	if (ret) {
+		printk(KERN_ERR "Can not assign IRQ number to %s\n", CARDNAME);
+		return ret;
+	}
+
+	/* Descriptor set */
+	ret = sh_eth_ring_init(ndev);
+	if (ret)
+		goto out_free_irq;
+
+	/* device init */
+	ret = sh_eth_dev_init(ndev);
+	if (ret)
+		goto out_free_irq;
+
+	/* PHY control start*/
+	ret = sh_eth_phy_start(ndev);
+	if (ret)
+		goto out_free_irq;
+
+	/* Set the timer to check for link beat. */
+	init_timer(&mdp->timer);
+	mdp->timer.expires = (jiffies + (24 * HZ)) / 10;/* 2.4 sec. */
+	setup_timer(&mdp->timer, sh_eth_timer, ndev);
+
+	return ret;
+
+out_free_irq:
+	free_irq(ndev->irq, ndev);
+	return ret;
+}
+
+/* Timeout function */
+static void sh_eth_tx_timeout(struct net_device *ndev)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+	u32 ioaddr = ndev->base_addr;
+	struct sh_eth_rxdesc *rxdesc;
+	int i;
+
+	netif_stop_queue(ndev);
+
+	/* worning message out. */
+	printk(KERN_WARNING "%s: transmit timed out, status %8.8x,"
+	       " resetting...\n", ndev->name, (int)ctrl_inl(ioaddr + EESR));
+
+	/* tx_errors count up */
+	mdp->stats.tx_errors++;
+
+	/* timer off */
+	del_timer_sync(&mdp->timer);
+
+	/* Free all the skbuffs in the Rx queue. */
+	for (i = 0; i < RX_RING_SIZE; i++) {
+		rxdesc = &mdp->rx_ring[i];
+		rxdesc->status = 0;
+		rxdesc->addr = 0xBADF00D0;
+		if (mdp->rx_skbuff[i])
+			dev_kfree_skb(mdp->rx_skbuff[i]);
+		mdp->rx_skbuff[i] = NULL;
+	}
+	for (i = 0; i < TX_RING_SIZE; i++) {
+		if (mdp->tx_skbuff[i])
+			dev_kfree_skb(mdp->tx_skbuff[i]);
+		mdp->tx_skbuff[i] = NULL;
+	}
+
+	/* device init */
+	sh_eth_dev_init(ndev);
+
+	/* timer on */
+	mdp->timer.expires = (jiffies + (24 * HZ)) / 10;/* 2.4 sec. */
+	add_timer(&mdp->timer);
+}
+
+/* Packet transmit function */
+static int sh_eth_start_xmit(struct sk_buff *skb, struct net_device *ndev)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+	struct sh_eth_txdesc *txdesc;
+	u32 entry;
+	int flags;
+
+	spin_lock_irqsave(&mdp->lock, flags);
+	if ((mdp->cur_tx - mdp->dirty_tx) >= (TX_RING_SIZE - 4)) {
+		if (!sh_eth_txfree(ndev)) {
+			netif_stop_queue(ndev);
+			spin_unlock_irqrestore(&mdp->lock, flags);
+			return 1;
+		}
+	}
+	spin_unlock_irqrestore(&mdp->lock, flags);
+
+	entry = mdp->cur_tx % TX_RING_SIZE;
+	mdp->tx_skbuff[entry] = skb;
+	txdesc = &mdp->tx_ring[entry];
+	txdesc->addr = (u32)(skb->data);
+	/* soft swap. */
+	swaps((char *)(txdesc->addr & ~0x3), skb->len + 2);
+	/* write back */
+	__flush_purge_region(skb->data, skb->len);
+	if (skb->len < ETHERSMALL)
+		txdesc->buffer_length = ETHERSMALL;
+	else
+		txdesc->buffer_length = skb->len;
+
+	if (entry >= TX_RING_SIZE - 1)
+		txdesc->status |= cpu_to_le32(TD_TACT | TD_TDLE);
+	else
+		txdesc->status |= cpu_to_le32(TD_TACT);
+
+	mdp->cur_tx++;
+
+	ctrl_outl(EDTRR_TRNS, ndev->base_addr + EDTRR);
+	ndev->trans_start = jiffies;
+
+	return 0;
+}
+
+/* device close function */
+static int sh_eth_close(struct net_device *ndev)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+	u32 ioaddr = ndev->base_addr;
+	int ringsize;
+
+	netif_stop_queue(ndev);
+
+	/* Disable interrupts by clearing the interrupt mask. */
+	ctrl_outl(0x0000, ioaddr + EESIPR);
+
+	/* Stop the chip's Tx and Rx processes. */
+	ctrl_outl(0, ioaddr + EDTRR);
+	ctrl_outl(0, ioaddr + EDRRR);
+
+	/* PHY Disconnect */
+	if (mdp->phydev) {
+		phy_stop(mdp->phydev);
+		phy_disconnect(mdp->phydev);
+	}
+
+	free_irq(ndev->irq, ndev);
+
+	del_timer_sync(&mdp->timer);
+
+	/* Free all the skbuffs in the Rx queue. */
+	sh_eth_ring_free(ndev);
+
+	/* free DMA buffer */
+	ringsize = sizeof(struct sh_eth_rxdesc) * RX_RING_SIZE;
+	dma_free_coherent(NULL, ringsize, mdp->rx_ring, mdp->rx_desc_dma);
+
+	/* free DMA buffer */
+	ringsize = sizeof(struct sh_eth_txdesc) * TX_RING_SIZE;
+	dma_free_coherent(NULL, ringsize, mdp->tx_ring, mdp->tx_desc_dma);
+
+	return 0;
+}
+
+static struct net_device_stats *sh_eth_get_stats(struct net_device *ndev)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+	u32 ioaddr = ndev->base_addr;
+
+	mdp->stats.tx_dropped += ctrl_inl(ioaddr + TROCR);
+	ctrl_outl(0, ioaddr + TROCR);	/* (write clear) */
+	mdp->stats.collisions += ctrl_inl(ioaddr + CDCR);
+	ctrl_outl(0, ioaddr + CDCR);	/* (write clear) */
+	mdp->stats.tx_carrier_errors += ctrl_inl(ioaddr + LCCR);
+	ctrl_outl(0, ioaddr + LCCR);	/* (write clear) */
+	mdp->stats.tx_carrier_errors += ctrl_inl(ioaddr + CNDCR);
+	ctrl_outl(0, ioaddr + CNDCR);	/* (write clear) */
+
+	return &mdp->stats;
+}
+
+/* ioctl to device funciotn*/
+static int sh_eth_do_ioctl(struct net_device *ndev, struct ifreq *rq,
+				int cmd)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+	struct phy_device *phydev = mdp->phydev;
+
+	if (!netif_running(ndev))
+		return -EINVAL;
+
+	if (!phydev)
+		return -ENODEV;
+
+	return phy_mii_ioctl(phydev, if_mii(rq), cmd);
+}
+
+
+/* Multicast reception directions set */
+static void sh_eth_set_multicast_list(struct net_device *ndev)
+{
+	u32 ioaddr = ndev->base_addr;
+
+	if (ndev->flags & IFF_PROMISC) {
+		/* Set promiscuous. */
+		ctrl_outl((ctrl_inl(ioaddr + ECMR) & ~ECMR_MCT) | ECMR_PRM,
+			  ioaddr + ECMR);
+	} else {
+		/* Normal, unicast/broadcast-only mode. */
+		ctrl_outl((ctrl_inl(ioaddr + ECMR) & ~ECMR_PRM) | ECMR_MCT,
+			  ioaddr + ECMR);
+	}
+}
+
+/* SuperH's TSU register init function */
+static void sh_eth_tsu_init(u32 ioaddr)
+{
+	ctrl_outl(0, ioaddr + TSU_FWEN0);	/* Disable forward(0->1) */
+	ctrl_outl(0, ioaddr + TSU_FWEN1);	/* Disable forward(1->0) */
+	ctrl_outl(0, ioaddr + TSU_FCM);	/* forward fifo 3k-3k */
+	ctrl_outl(0xc, ioaddr + TSU_BSYSL0);
+	ctrl_outl(0xc, ioaddr + TSU_BSYSL1);
+	ctrl_outl(0, ioaddr + TSU_PRISL0);
+	ctrl_outl(0, ioaddr + TSU_PRISL1);
+	ctrl_outl(0, ioaddr + TSU_FWSL0);
+	ctrl_outl(0, ioaddr + TSU_FWSL1);
+	ctrl_outl(TSU_FWSLC_POSTENU | TSU_FWSLC_POSTENL, ioaddr + TSU_FWSLC);
+	ctrl_outl(0, ioaddr + TSU_QTAGM0);	/* Disable QTAG(0->1) */
+	ctrl_outl(0, ioaddr + TSU_QTAGM1);	/* Disable QTAG(1->0) */
+	ctrl_outl(0, ioaddr + TSU_FWSR);	/* all interrupt status clear */
+	ctrl_outl(0, ioaddr + TSU_FWINMK);	/* Disable all interrupt */
+	ctrl_outl(0, ioaddr + TSU_TEN);	/* Disable all CAM entry */
+	ctrl_outl(0, ioaddr + TSU_POST1);	/* Disable CAM entry [ 0- 7] */
+	ctrl_outl(0, ioaddr + TSU_POST2);	/* Disable CAM entry [ 8-15] */
+	ctrl_outl(0, ioaddr + TSU_POST3);	/* Disable CAM entry [16-23] */
+	ctrl_outl(0, ioaddr + TSU_POST4);	/* Disable CAM entry [24-31] */
+}
+
+/* MDIO bus release function */
+static int sh_mdio_release(struct net_device *ndev)
+{
+	struct mii_bus *bus = dev_get_drvdata(&ndev->dev);
+
+	/* unregister mdio bus */
+	mdiobus_unregister(bus);
+
+	/* remove mdio bus info from net_device */
+	dev_set_drvdata(&ndev->dev, NULL);
+
+	/* free bitbang info */
+	free_mdio_bitbang(bus);
+
+	return 0;
+}
+
+/* MDIO bus init function */
+static int sh_mdio_init(struct net_device *ndev, int id)
+{
+	int ret, i;
+	struct bb_info *bitbang;
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+
+	/* create bit control struct for PHY */
+	bitbang = kzalloc(sizeof(struct bb_info), GFP_KERNEL);
+	if (!bitbang) {
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	/* bitbang init */
+	bitbang->addr = ndev->base_addr + PIR;
+	bitbang->mdi_msk = 0x08;
+	bitbang->mdo_msk = 0x04;
+	bitbang->mmd_msk = 0x02;/* MMD */
+	bitbang->mdc_msk = 0x01;
+	bitbang->ctrl.ops = &bb_ops;
+
+	/* MII contorller setting */
+	mdp->mii_bus = alloc_mdio_bitbang(&bitbang->ctrl);
+	if (!mdp->mii_bus) {
+		ret = -ENOMEM;
+		goto out_free_bitbang;
+	}
+
+	/* Hook up MII support for ethtool */
+	mdp->mii_bus->name = "sh_mii";
+	mdp->mii_bus->dev = &ndev->dev;
+	mdp->mii_bus->id = id;
+
+	/* PHY IRQ */
+	mdp->mii_bus->irq = kmalloc(sizeof(int)*PHY_MAX_ADDR, GFP_KERNEL);
+	if (!mdp->mii_bus->irq) {
+		ret = -ENOMEM;
+		goto out_free_bus;
+	}
+
+	for (i = 0; i < PHY_MAX_ADDR; i++)
+		mdp->mii_bus->irq[i] = PHY_POLL;
+
+	/* regist mdio bus */
+	ret = mdiobus_register(mdp->mii_bus);
+	if (ret)
+		goto out_free_irq;
+
+	dev_set_drvdata(&ndev->dev, mdp->mii_bus);
+
+	return 0;
+
+out_free_irq:
+	kfree(mdp->mii_bus->irq);
+
+out_free_bus:
+	kfree(mdp->mii_bus);
+
+out_free_bitbang:
+	kfree(bitbang);
+
+out:
+	return ret;
+}
+
+static int sh_eth_drv_probe(struct platform_device *pdev)
+{
+	int ret, i, devno = 0;
+	struct resource *res;
+	struct net_device *ndev = NULL;
+	struct sh_eth_private *mdp;
+
+	/* get base addr */
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	if (unlikely(res == NULL)) {
+		dev_err(&pdev->dev, "invalid resource\n");
+		ret = -EINVAL;
+		goto out;
+	}
+
+	ndev = alloc_etherdev(sizeof(struct sh_eth_private));
+	if (!ndev) {
+		printk(KERN_ERR "%s: could not allocate device.\n", CARDNAME);
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	/* The sh Ether-specific entries in the device structure. */
+	ndev->base_addr = res->start;
+	devno = pdev->id;
+	if (devno < 0)
+		devno = 0;
+
+	ndev->dma = -1;
+	ndev->irq = platform_get_irq(pdev, 0);
+	if (ndev->irq < 0) {
+		ret = -ENODEV;
+		goto out_release;
+	}
+
+	SET_NETDEV_DEV(ndev, &pdev->dev);
+
+	/* Fill in the fields of the device structure with ethernet values. */
+	ether_setup(ndev);
+
+	mdp = netdev_priv(ndev);
+	spin_lock_init(&mdp->lock);
+
+	/* get PHY ID */
+	mdp->phy_id = (int)pdev->dev.platform_data;
+
+	/* set function */
+	ndev->open = sh_eth_open;
+	ndev->hard_start_xmit = sh_eth_start_xmit;
+	ndev->stop = sh_eth_close;
+	ndev->get_stats = sh_eth_get_stats;
+	ndev->set_multicast_list = sh_eth_set_multicast_list;
+	ndev->do_ioctl = sh_eth_do_ioctl;
+	ndev->tx_timeout = sh_eth_tx_timeout;
+	ndev->watchdog_timeo = TX_TIMEOUT;
+
+	mdp->post_rx = POST_RX >> (devno << 1);
+	mdp->post_fw = POST_FW >> (devno << 1);
+
+	/* read and set MAC address */
+	read_mac_address(ndev);
+
+	/* First device only init */
+	if (!devno) {
+		/* reset device */
+		ctrl_outl(ARSTR_ARSTR, ndev->base_addr + ARSTR);
+		mdelay(1);
+
+		/* TSU init (Init only)*/
+		sh_eth_tsu_init(SH_TSU_ADDR);
+	}
+
+	/* network device register */
+	ret = register_netdev(ndev);
+	if (ret)
+		goto out_release;
+
+	/* mdio bus init */
+	ret = sh_mdio_init(ndev, pdev->id);
+	if (ret)
+		goto out_unregister;
+
+	/* pritnt device infomation */
+	printk(KERN_INFO "%s: %s at 0x%x, ",
+	       ndev->name, CARDNAME, (u32) ndev->base_addr);
+
+	for (i = 0; i < 5; i++)
+		printk(KERN_INFO "%2.2x:", ndev->dev_addr[i]);
+	printk(KERN_INFO "%2.2x, IRQ %d.\n", ndev->dev_addr[i], ndev->irq);
+
+	platform_set_drvdata(pdev, ndev);
+
+	return ret;
+
+out_unregister:
+	unregister_netdev(ndev);
+
+out_release:
+	/* net_dev free */
+	if (ndev)
+		free_netdev(ndev);
+
+out:
+	return ret;
+}
+
+static int sh_eth_drv_remove(struct platform_device *pdev)
+{
+	struct net_device *ndev = platform_get_drvdata(pdev);
+
+	sh_mdio_release(ndev);
+	unregister_netdev(ndev);
+	flush_scheduled_work();
+
+	free_netdev(ndev);
+	platform_set_drvdata(pdev, NULL);
+
+	return 0;
+}
+
+static struct platform_driver sh_eth_driver = {
+	.probe = sh_eth_drv_probe,
+	.remove = sh_eth_drv_remove,
+	.driver = {
+		   .name = CARDNAME,
+	},
+};
+
+static int __init sh_eth_init(void)
+{
+	return platform_driver_register(&sh_eth_driver);
+}
+
+static void __exit sh_eth_cleanup(void)
+{
+	platform_driver_unregister(&sh_eth_driver);
+}
+
+module_init(sh_eth_init);
+module_exit(sh_eth_cleanup);
+
+MODULE_AUTHOR("Nobuhiro Iwamatsu, Yoshihiro Shimoda");
+MODULE_DESCRIPTION("Renesas SuperH Ethernet driver");
+MODULE_LICENSE("GPL v2");
diff -puN /dev/null drivers/net/sh_eth.h
--- /dev/null
+++ a/drivers/net/sh_eth.h
@@ -0,0 +1,464 @@
+/*
+ *  SuperH Ethernet device driver
+ *
+ *  Copyright (C) 2006-2008 Nobuhiro Iwamatsu
+ *  Copyright (C) 2008 Renesas Solutions Corp.
+ *
+ *  This program is free software; you can redistribute it and/or modify it
+ *  under the terms and conditions of the GNU General Public License,
+ *  version 2, as published by the Free Software Foundation.
+ *
+ *  This program is distributed in the hope it will be useful, but WITHOUT
+ *  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ *  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ *  more details.
+ *  You should have received a copy of the GNU General Public License along with
+ *  this program; if not, write to the Free Software Foundation, Inc.,
+ *  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+ *
+ *  The full GNU General Public License is included in this distribution in
+ *  the file called "COPYING".
+ */
+
+#ifndef __SH_ETH_H__
+#define __SH_ETH_H__
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/spinlock.h>
+#include <linux/workqueue.h>
+#include <linux/netdevice.h>
+#include <linux/phy.h>
+
+#define CARDNAME	"sh-eth"
+#define TX_TIMEOUT	(5*HZ)
+
+#define TX_RING_SIZE	128	/* Tx ring size */
+#define RX_RING_SIZE	128	/* Rx ring size */
+#define RX_OFFSET		2	/* skb offset */
+#define ETHERSMALL		60
+#define PKT_BUF_SZ		1538
+
+/* Chip Base Address */
+#define SH_ETH0_BASE 0xA7000000
+#define SH_ETH1_BASE 0xA7000400
+#define SH_TSU_ADDR 0xA7000804
+
+/* Chip Registers */
+/* E-DMAC */
+#define EDMR	0x0000
+#define EDTRR	0x0004
+#define EDRRR	0x0008
+#define TDLAR	0x000C
+#define RDLAR	0x0010
+#define EESR	0x0014
+#define EESIPR	0x0018
+#define TRSCER	0x001C
+#define RMFCR	0x0020
+#define TFTR	0x0024
+#define FDR		0x0028
+#define RMCR	0x002C
+#define EDOCR	0x0030
+#define FCFTR	0x0034
+#define RPADIR	0x0038
+#define TRIMD	0x003C
+#define RBWAR	0x0040
+#define RDFAR	0x0044
+#define TBRAR	0x004C
+#define TDFAR	0x0050
+/* Ether Register */
+#define ECMR	0x0160
+#define ECSR	0x0164
+#define ECSIPR	0x0168
+#define PIR		0x016C
+#define MAHR	0x0170
+#define MALR	0x0174
+#define RFLR	0x0178
+#define PSR		0x017C
+#define TROCR	0x0180
+#define CDCR	0x0184
+#define LCCR	0x0188
+#define CNDCR	0x018C
+#define CEFCR	0x0194
+#define FRECR	0x0198
+#define TSFRCR	0x019C
+#define TLFRCR	0x01A0
+#define RFCR	0x01A4
+#define MAFCR	0x01A8
+#define IPGR	0x01B4
+#if defined(CONFIG_CPU_SUBTYPE_SH7710)
+#define APR		0x01B8
+#define MPR 	0x01BC
+#define TPAUSER 0x1C4
+#define BCFR	0x1CC
+#endif /* CONFIG_CPU_SH7710 */
+
+#define ARSTR	0x0800
+
+/* TSU */
+#define TSU_CTRST	0x004
+#define TSU_FWEN0	0x010
+#define TSU_FWEN1	0x014
+#define TSU_FCM		0x018
+#define TSU_BSYSL0	0x020
+#define TSU_BSYSL1	0x024
+#define TSU_PRISL0	0x028
+#define TSU_PRISL1	0x02C
+#define TSU_FWSL0	0x030
+#define TSU_FWSL1	0x034
+#define TSU_FWSLC	0x038
+#define TSU_QTAGM0	0x040
+#define TSU_QTAGM1	0x044
+#define TSU_ADQT0 	0x048
+#define TSU_ADQT1	0x04C
+#define TSU_FWSR	0x050
+#define TSU_FWINMK	0x054
+#define TSU_ADSBSY	0x060
+#define TSU_TEN		0x064
+#define TSU_POST1	0x070
+#define TSU_POST2	0x074
+#define TSU_POST3	0x078
+#define TSU_POST4	0x07C
+#define TXNLCR0		0x080
+#define TXALCR0		0x084
+#define RXNLCR0		0x088
+#define RXALCR0		0x08C
+#define FWNLCR0		0x090
+#define FWALCR0		0x094
+#define TXNLCR1		0x0A0
+#define TXALCR1		0x0A4
+#define RXNLCR1		0x0A8
+#define RXALCR1		0x0AC
+#define FWNLCR1		0x0B0
+#define FWALCR1		0x0B4
+
+#define TSU_ADRH0	0x0100
+#define TSU_ADRL0	0x0104
+#define TSU_ADRL31	0x01FC
+
+/* Register's bits */
+
+/* EDMR */
+enum DMAC_M_BIT {
+	EDMR_DL1 = 0x20, EDMR_DL0 = 0x10, EDMR_SRST = 0x01,
+};
+
+/* EDTRR */
+enum DMAC_T_BIT {
+	EDTRR_TRNS = 0x01,
+};
+
+/* EDRRR*/
+enum EDRRR_R_BIT {
+	EDRRR_R = 0x01,
+};
+
+/* TPAUSER */
+enum TPAUSER_BIT {
+	TPAUSER_TPAUSE = 0x0000ffff,
+	TPAUSER_UNLIMITED = 0,
+};
+
+/* BCFR */
+enum BCFR_BIT {
+	BCFR_RPAUSE = 0x0000ffff,
+	BCFR_UNLIMITED = 0,
+};
+
+/* PIR */
+enum PIR_BIT {
+	PIR_MDI = 0x08, PIR_MDO = 0x04, PIR_MMD = 0x02, PIR_MDC = 0x01,
+};
+
+/* PSR */
+enum PHY_STATUS_BIT { PHY_ST_LINK = 0x01, };
+
+/* EESR */
+enum EESR_BIT {
+	EESR_TWB = 0x40000000, EESR_TABT = 0x04000000,
+	EESR_RABT = 0x02000000, EESR_RFRMER = 0x01000000,
+	EESR_ADE = 0x00800000, EESR_ECI = 0x00400000,
+	EESR_FTC = 0x00200000, EESR_TDE = 0x00100000,
+	EESR_TFE = 0x00080000, EESR_FRC = 0x00040000,
+	EESR_RDE = 0x00020000, EESR_RFE = 0x00010000,
+	EESR_TINT4 = 0x00000800, EESR_TINT3 = 0x00000400,
+	EESR_TINT2 = 0x00000200, EESR_TINT1 = 0x00000100,
+	EESR_RINT8 = 0x00000080, EESR_RINT5 = 0x00000010,
+	EESR_RINT4 = 0x00000008, EESR_RINT3 = 0x00000004,
+	EESR_RINT2 = 0x00000002, EESR_RINT1 = 0x00000001,
+};
+
+#define EESR_ERR_CHECK	(EESR_TWB | EESR_TABT | EESR_RABT | EESR_RDE \
+		| EESR_RFRMER | EESR_ADE | EESR_TFE | EESR_TDE | EESR_ECI)
+
+/* EESIPR */
+enum DMAC_IM_BIT {
+	DMAC_M_TWB = 0x40000000, DMAC_M_TABT = 0x04000000,
+	DMAC_M_RABT = 0x02000000,
+	DMAC_M_RFRMER = 0x01000000, DMAC_M_ADF = 0x00800000,
+	DMAC_M_ECI = 0x00400000, DMAC_M_FTC = 0x00200000,
+	DMAC_M_TDE = 0x00100000, DMAC_M_TFE = 0x00080000,
+	DMAC_M_FRC = 0x00040000, DMAC_M_RDE = 0x00020000,
+	DMAC_M_RFE = 0x00010000, DMAC_M_TINT4 = 0x00000800,
+	DMAC_M_TINT3 = 0x00000400, DMAC_M_TINT2 = 0x00000200,
+	DMAC_M_TINT1 = 0x00000100, DMAC_M_RINT8 = 0x00000080,
+	DMAC_M_RINT5 = 0x00000010, DMAC_M_RINT4 = 0x00000008,
+	DMAC_M_RINT3 = 0x00000004, DMAC_M_RINT2 = 0x00000002,
+	DMAC_M_RINT1 = 0x00000001,
+};
+
+/* Receive descriptor bit */
+enum RD_STS_BIT {
+	RD_RACT = 0x80000000, RC_RDEL = 0x40000000,
+	RC_RFP1 = 0x20000000, RC_RFP0 = 0x10000000,
+	RD_RFE = 0x08000000, RD_RFS10 = 0x00000200,
+	RD_RFS9 = 0x00000100, RD_RFS8 = 0x00000080,
+	RD_RFS7 = 0x00000040, RD_RFS6 = 0x00000020,
+	RD_RFS5 = 0x00000010, RD_RFS4 = 0x00000008,
+	RD_RFS3 = 0x00000004, RD_RFS2 = 0x00000002,
+	RD_RFS1 = 0x00000001,
+};
+#define RDF1ST	RC_RFP1
+#define RDFEND	RC_RFP0
+#define RD_RFP	(RC_RFP1|RC_RFP0)
+
+/* FCFTR */
+enum FCFTR_BIT {
+	FCFTR_RFF2 = 0x00040000, FCFTR_RFF1 = 0x00020000,
+	FCFTR_RFF0 = 0x00010000, FCFTR_RFD2 = 0x00000004,
+	FCFTR_RFD1 = 0x00000002, FCFTR_RFD0 = 0x00000001,
+};
+#define FIFO_F_D_RFF	(FCFTR_RFF2|FCFTR_RFF1|FCFTR_RFF0)
+#define FIFO_F_D_RFD	(FCFTR_RFD2|FCFTR_RFD1|FCFTR_RFD0)
+
+/* Transfer descriptor bit */
+enum TD_STS_BIT {
+	TD_TACT = 0x80000000, TD_TDLE = 0x40000000, TD_TFP1 = 0x20000000,
+	TD_TFP0 = 0x10000000,
+};
+#define TDF1ST	TD_TFP1
+#define TDFEND	TD_TFP0
+#define TD_TFP	(TD_TFP1|TD_TFP0)
+
+/* RMCR */
+enum RECV_RST_BIT { RMCR_RST = 0x01, };
+/* ECMR */
+enum FELIC_MODE_BIT {
+	ECMR_ZPF = 0x00080000, ECMR_PFR = 0x00040000, ECMR_RXF = 0x00020000,
+	ECMR_TXF = 0x00010000, ECMR_MCT = 0x00002000, ECMR_PRCEF = 0x00001000,
+	ECMR_PMDE = 0x00000200, ECMR_RE = 0x00000040, ECMR_TE = 0x00000020,
+	ECMR_ILB = 0x00000008, ECMR_ELB = 0x00000004, ECMR_DM = 0x00000002,
+	ECMR_PRM = 0x00000001,
+};
+
+/* ECSR */
+enum ECSR_STATUS_BIT {
+	ECSR_BRCRX = 0x20, ECSR_PSRTO = 0x10, ECSR_LCHNG = 0x04,
+	ECSR_MPD = 0x02, ECSR_ICD = 0x01,
+};
+
+/* ECSIPR */
+enum ECSIPR_STATUS_MASK_BIT {
+	ECSIPR_BRCRXIP = 0x20, ECSIPR_PSRTOIP = 0x10, ECSIPR_LCHNGIP = 0x04,
+	ECSIPR_MPDIP = 0x02, ECSIPR_ICDIP = 0x01,
+};
+
+/* APR */
+enum APR_BIT {
+	APR_AP = 0x00000001,
+};
+
+/* MPR */
+enum MPR_BIT {
+	MPR_MP = 0x00000001,
+};
+
+/* TRSCER */
+enum DESC_I_BIT {
+	DESC_I_TINT4 = 0x0800, DESC_I_TINT3 = 0x0400, DESC_I_TINT2 = 0x0200,
+	DESC_I_TINT1 = 0x0100, DESC_I_RINT8 = 0x0080, DESC_I_RINT5 = 0x0010,
+	DESC_I_RINT4 = 0x0008, DESC_I_RINT3 = 0x0004, DESC_I_RINT2 = 0x0002,
+	DESC_I_RINT1 = 0x0001,
+};
+
+/* RPADIR */
+enum RPADIR_BIT {
+	RPADIR_PADS1 = 0x20000, RPADIR_PADS0 = 0x10000,
+	RPADIR_PADR = 0x0003f,
+};
+
+/* FDR */
+enum FIFO_SIZE_BIT {
+	FIFO_SIZE_T = 0x00000700, FIFO_SIZE_R = 0x00000007,
+};
+enum phy_offsets {
+	PHY_CTRL = 0, PHY_STAT = 1, PHY_IDT1 = 2, PHY_IDT2 = 3,
+	PHY_ANA = 4, PHY_ANL = 5, PHY_ANE = 6,
+	PHY_16 = 16,
+};
+
+/* PHY_CTRL */
+enum PHY_CTRL_BIT {
+	PHY_C_RESET = 0x8000, PHY_C_LOOPBK = 0x4000, PHY_C_SPEEDSL = 0x2000,
+	PHY_C_ANEGEN = 0x1000, PHY_C_PWRDN = 0x0800, PHY_C_ISO = 0x0400,
+	PHY_C_RANEG = 0x0200, PHY_C_DUPLEX = 0x0100, PHY_C_COLT = 0x0080,
+};
+#define DM9161_PHY_C_ANEGEN 0	/* auto nego special */
+
+/* PHY_STAT */
+enum PHY_STAT_BIT {
+	PHY_S_100T4 = 0x8000, PHY_S_100X_F = 0x4000, PHY_S_100X_H = 0x2000,
+	PHY_S_10T_F = 0x1000, PHY_S_10T_H = 0x0800, PHY_S_ANEGC = 0x0020,
+	PHY_S_RFAULT = 0x0010, PHY_S_ANEGA = 0x0008, PHY_S_LINK = 0x0004,
+	PHY_S_JAB = 0x0002, PHY_S_EXTD = 0x0001,
+};
+
+/* PHY_ANA */
+enum PHY_ANA_BIT {
+	PHY_A_NP = 0x8000, PHY_A_ACK = 0x4000, PHY_A_RF = 0x2000,
+	PHY_A_FCS = 0x0400, PHY_A_T4 = 0x0200, PHY_A_FDX = 0x0100,
+	PHY_A_HDX = 0x0080, PHY_A_10FDX = 0x0040, PHY_A_10HDX = 0x0020,
+	PHY_A_SEL = 0x001f,
+};
+/* PHY_ANL */
+enum PHY_ANL_BIT {
+	PHY_L_NP = 0x8000, PHY_L_ACK = 0x4000, PHY_L_RF = 0x2000,
+	PHY_L_FCS = 0x0400, PHY_L_T4 = 0x0200, PHY_L_FDX = 0x0100,
+	PHY_L_HDX = 0x0080, PHY_L_10FDX = 0x0040, PHY_L_10HDX = 0x0020,
+	PHY_L_SEL = 0x001f,
+};
+
+/* PHY_ANE */
+enum PHY_ANE_BIT {
+	PHY_E_PDF = 0x0010, PHY_E_LPNPA = 0x0008, PHY_E_NPA = 0x0004,
+	PHY_E_PRX = 0x0002, PHY_E_LPANEGA = 0x0001,
+};
+
+/* DM9161 */
+enum PHY_16_BIT {
+	PHY_16_BP4B45 = 0x8000, PHY_16_BPSCR = 0x4000, PHY_16_BPALIGN = 0x2000,
+	PHY_16_BP_ADPOK = 0x1000, PHY_16_Repeatmode = 0x0800,
+	PHY_16_TXselect = 0x0400,
+	PHY_16_Rsvd = 0x0200, PHY_16_RMIIEnable = 0x0100,
+	PHY_16_Force100LNK = 0x0080,
+	PHY_16_APDLED_CTL = 0x0040, PHY_16_COLLED_CTL = 0x0020,
+	PHY_16_RPDCTR_EN = 0x0010,
+	PHY_16_ResetStMch = 0x0008, PHY_16_PreamSupr = 0x0004,
+	PHY_16_Sleepmode = 0x0002,
+	PHY_16_RemoteLoopOut = 0x0001,
+};
+
+#define POST_RX		0x08
+#define POST_FW		0x04
+#define POST0_RX	(POST_RX)
+#define POST0_FW	(POST_FW)
+#define POST1_RX	(POST_RX >> 2)
+#define POST1_FW	(POST_FW >> 2)
+#define POST_ALL	(POST0_RX | POST0_FW | POST1_RX | POST1_FW)
+
+/* ARSTR */
+enum ARSTR_BIT { ARSTR_ARSTR = 0x00000001, };
+
+/* TSU_FWEN0 */
+enum TSU_FWEN0_BIT {
+	TSU_FWEN0_0 = 0x00000001,
+};
+
+/* TSU_ADSBSY */
+enum TSU_ADSBSY_BIT {
+	TSU_ADSBSY_0 = 0x00000001,
+};
+
+/* TSU_TEN */
+enum TSU_TEN_BIT {
+	TSU_TEN_0 = 0x80000000,
+};
+
+/* TSU_FWSL0 */
+enum TSU_FWSL0_BIT {
+	TSU_FWSL0_FW50 = 0x1000, TSU_FWSL0_FW40 = 0x0800,
+	TSU_FWSL0_FW30 = 0x0400, TSU_FWSL0_FW20 = 0x0200,
+	TSU_FWSL0_FW10 = 0x0100, TSU_FWSL0_RMSA0 = 0x0010,
+};
+
+/* TSU_FWSLC */
+enum TSU_FWSLC_BIT {
+	TSU_FWSLC_POSTENU = 0x2000, TSU_FWSLC_POSTENL = 0x1000,
+	TSU_FWSLC_CAMSEL03 = 0x0080, TSU_FWSLC_CAMSEL02 = 0x0040,
+	TSU_FWSLC_CAMSEL01 = 0x0020, TSU_FWSLC_CAMSEL00 = 0x0010,
+	TSU_FWSLC_CAMSEL13 = 0x0008, TSU_FWSLC_CAMSEL12 = 0x0004,
+	TSU_FWSLC_CAMSEL11 = 0x0002, TSU_FWSLC_CAMSEL10 = 0x0001,
+};
+
+/*
+ * The sh ether Tx buffer descriptors.
+ * This structure should be 20 bytes.
+ */
+struct sh_eth_txdesc {
+	u32 status;		/* TD0 */
+#if defined(CONFIG_CPU_LITTLE_ENDIAN)
+	u16 pad0;		/* TD1 */
+	u16 buffer_length;	/* TD1 */
+#else
+	u16 buffer_length;	/* TD1 */
+	u16 pad0;		/* TD1 */
+#endif
+	u32 addr;		/* TD2 */
+	u32 pad1;		/* padding data */
+};
+
+/*
+ * The sh ether Rx buffer descriptors.
+ * This structure should be 20 bytes.
+ */
+struct sh_eth_rxdesc {
+	u32 status;		/* RD0 */
+#if defined(CONFIG_CPU_LITTLE_ENDIAN)
+	u16 frame_length;	/* RD1 */
+	u16 buffer_length;	/* RD1 */
+#else
+	u16 buffer_length;	/* RD1 */
+	u16 frame_length;	/* RD1 */
+#endif
+	u32 addr;		/* RD2 */
+	u32 pad0;		/* padding data */
+};
+
+struct sh_eth_private {
+	dma_addr_t rx_desc_dma;
+	dma_addr_t tx_desc_dma;
+	struct sh_eth_rxdesc *rx_ring;
+	struct sh_eth_txdesc *tx_ring;
+	struct sk_buff **rx_skbuff;
+	struct sk_buff **tx_skbuff;
+	struct net_device_stats stats;
+	struct timer_list timer;
+	spinlock_t lock;
+	u32 cur_rx, dirty_rx;	/* Producer/consumer ring indices */
+	u32 cur_tx, dirty_tx;
+	u32 rx_buf_sz;		/* Based on MTU+slack. */
+	/* MII transceiver section. */
+	u32 phy_id;					/* PHY ID */
+	struct mii_bus *mii_bus;	/* MDIO bus control */
+	struct phy_device *phydev;	/* PHY device control */
+	enum phy_state link;
+	int msg_enable;
+	int speed;
+	int duplex;
+	u32 rx_int_var, tx_int_var;	/* interrupt control variables */
+	char post_rx;		/* POST receive */
+	char post_fw;		/* POST forward */
+	struct net_device_stats tsu_stats;	/* TSU forward status */
+};
+
+static void swaps(char *src, int len)
+{
+#ifdef __LITTLE_ENDIAN__
+	u32 *p = (u32 *)src;
+	u32 *maxp;
+	maxp = p + ((len + sizeof(u32) - 1) / sizeof(u32));
+
+	for (; p < maxp; p++)
+		*p = swab32(*p);
+#endif
+}
_

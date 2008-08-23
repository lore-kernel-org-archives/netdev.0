From: Guo-Fu Tseng <cooldavid@cooldavid.org>
Subject: [PATCH netdev-2.6] jme: JMicron Gigabit Ethernet Driver
Date: Sat, 23 Aug 2008 14:05:28 +0800
Message-ID: <48AFA8A8.6070604@cooldavid.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ethan <ethanhsiao@jmicron.com>, akeemting <akeem@jmicron.com>,
	netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 220-133-139-86.HINET-IP.hinet.net ([220.133.139.86]:52356 "EHLO
	cooldavid.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751678AbYHWGMc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Aug 2008 02:12:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Jeff:

Here is the full patch of JMicron Gigabit Ethernet driver.
Supporting JMC250, and JMC260.

I'm new in this submitting system, I've tried hard not to done silly errors.
Comments, and corrections are welcome from anyone. Thank you for reviewing it.

The patch is also available at:
http://cooldavid.org/download/jme.netdev-2.6.20080823.patch

Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>
---
diff -uprN -X ./dontdiff netdev-2.6/drivers/net/jme.c linux/drivers/net/jme.c
--- netdev-2.6/drivers/net/jme.c	1970-01-01 08:00:00.000000000 +0800
+++ linux/drivers/net/jme.c	2008-08-23 11:34:57.000000000 +0800
@@ -0,0 +1,3131 @@
+/*
+ * JMicron JMC2x0 series PCIe Ethernet Linux Device Driver
+ *
+ * Copyright 2008 JMicron Technology Corporation
+ * http://www.jmicron.com/
+ *
+ * Author: Guo-Fu Tseng <cooldavid@cooldavid.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+ *
+ */
+
+#include <linux/version.h>
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/pci.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/ethtool.h>
+#include <linux/mii.h>
+#include <linux/crc32.h>
+#include <linux/delay.h>
+#include <linux/spinlock.h>
+#include <linux/in.h>
+#include <linux/ip.h>
+#include <linux/ipv6.h>
+#include <linux/tcp.h>
+#include <linux/udp.h>
+#include <linux/if_vlan.h>
+#include "jme.h"
+
+static int force_pseudohp = -1;
+static int no_pseudohp = -1;
+static int no_extplug = -1;
+module_param(force_pseudohp, int, 0);
+MODULE_PARM_DESC(force_pseudohp,
+	"Enable pseudo hot-plug feature manually by driver instead of BIOS.");
+module_param(no_pseudohp, int, 0);
+MODULE_PARM_DESC(no_pseudohp, "Disable pseudo hot-plug feature.");
+module_param(no_extplug, int, 0);
+MODULE_PARM_DESC(no_extplug,
+	"Do not use external plug signal for pseudo hot-plug.");
+
+static int
+jme_mdio_read(struct net_device *netdev, int phy, int reg)
+{
+	struct jme_adapter *jme = netdev_priv(netdev);
+	int i, val, again = (reg == MII_BMSR) ? 1 : 0;
+
+read_again:
+	jwrite32(jme, JME_SMI, SMI_OP_REQ |
+				smi_phy_addr(phy) |
+				smi_reg_addr(reg));
+
+	wmb();
+	for (i = JME_PHY_TIMEOUT * 50 ; i > 0 ; --i) {
+		udelay(20);
+		val = jread32(jme, JME_SMI);
+		if ((val & SMI_OP_REQ) == 0)
+			break;
+	}
+
+	if (i == 0) {
+		jeprintk(jme->pdev, "phy(%d) read timeout : %d\n", phy, reg);
+		return 0;
+	}
+
+	if (again--)
+		goto read_again;
+
+	return (val & SMI_DATA_MASK) >> SMI_DATA_SHIFT;
+}
+
+static void
+jme_mdio_write(struct net_device *netdev,
+				int phy, int reg, int val)
+{
+	struct jme_adapter *jme = netdev_priv(netdev);
+	int i;
+
+	jwrite32(jme, JME_SMI, SMI_OP_WRITE | SMI_OP_REQ |
+		((val << SMI_DATA_SHIFT) & SMI_DATA_MASK) |
+		smi_phy_addr(phy) | smi_reg_addr(reg));
+
+	wmb();
+	for (i = JME_PHY_TIMEOUT * 50 ; i > 0 ; --i) {
+		udelay(20);
+		if ((jread32(jme, JME_SMI) & SMI_OP_REQ) == 0)
+			break;
+	}
+
+	if (i == 0)
+		jeprintk(jme->pdev, "phy(%d) write timeout : %d\n", phy, reg);
+
+	return;
+}
+
+static void
+jme_spi_start(struct pci_dev *pdev, struct jme_spi_op *spiop)
+{
+	spiop->sr |= SPI_EN;
+	pci_write_config_byte(pdev, PCI_SPI, spiop->sr);
+	ndelay(spiop->halfclk << 2);
+	if (spiop->mode & SPI_MODE_CPOL) {
+		spiop->sr |= SPI_SCLK;
+		pci_write_config_byte(pdev, PCI_SPI, spiop->sr);
+		ndelay(spiop->halfclk << 2);
+	}
+	spiop->sr &= ~SPI_CS;
+	pci_write_config_byte(pdev, PCI_SPI, spiop->sr);
+	ndelay(spiop->halfclk);
+}
+
+static void
+jme_spi_write(struct pci_dev *pdev, struct jme_spi_op *spiop, __u8 byte)
+{
+	int bit;
+
+	for (bit = 0 ; bit < 8 ; ++bit) {
+		if (byte & 0x80)
+			spiop->sr |= SPI_MOSI;
+		else
+			spiop->sr &= ~SPI_MOSI;
+		pci_write_config_byte(pdev, PCI_SPI, spiop->sr);
+
+		byte <<= 1;
+		ndelay(spiop->halfclk);
+		spiop->sr ^= SPI_SCLK;
+		pci_write_config_byte(pdev, PCI_SPI, spiop->sr);
+
+		ndelay(spiop->halfclk);
+		spiop->sr ^= SPI_SCLK;
+		pci_write_config_byte(pdev, PCI_SPI, spiop->sr);
+	}
+}
+
+static void
+jme_spi_read(struct pci_dev *pdev, struct jme_spi_op *spiop, __u8 *byte)
+{
+	int bit;
+	__u8 b;
+
+	spiop->sr &= ~SPI_MOSI;
+	for (bit = 0 ; bit < 8 ; ++bit) {
+		*byte <<= 1;
+		ndelay(spiop->halfclk);
+		spiop->sr ^= SPI_SCLK;
+		pci_write_config_byte(pdev, PCI_SPI, spiop->sr);
+
+		ndelay(spiop->halfclk);
+		pci_read_config_byte(pdev, PCI_SPI, &b);
+		*byte |= !!(b & SPI_MISO);
+		spiop->sr ^= SPI_SCLK;
+		pci_write_config_byte(pdev, PCI_SPI, spiop->sr);
+	}
+}
+
+static void
+jme_spi_stop(struct pci_dev *pdev, struct jme_spi_op *spiop)
+{
+	spiop->sr &= ~SPI_EN;
+	spiop->sr |= SPI_CS;
+	pci_write_config_byte(pdev, PCI_SPI, spiop->sr);
+}
+
+/**
+ * jme_spi_io - SPI Access helper function.
+ * @jme: Adapter informations
+ * @spiop: SPI operation.
+ *
+ * We have a SPI SW Access register in PCI configuration space,
+ * which directly connect to flash controller with SPI interface.
+ * This function is used to communicate with it in SPI protocol.
+ */
+static int
+jme_spi_op(struct jme_adapter *jme, struct jme_spi_op *spiop)
+{
+	int i;
+
+	/*
+	 * Only support 8 bits for now
+	 */
+	if (spiop->bitn != 8)
+		return -EINVAL;
+
+	/*
+	 * Only support half-duplex for now
+	 */
+	if (spiop->mode & SPI_MODE_DUP)
+		return -EINVAL;
+
+	spiop->halfclk	= HALF_US / spiop->spd;
+	spiop->sr	= SPI_CS;
+	jme_spi_start(jme->pdev, spiop);
+
+	for (i = 0 ; i < spiop->wn ; ++i)
+		jme_spi_write(jme->pdev, spiop, spiop->kwbuf[i]);
+
+	for (i = 0 ; i < spiop->rn ; ++i)
+		jme_spi_read(jme->pdev, spiop, spiop->krbuf + i);
+
+	jme_spi_stop(jme->pdev, spiop);
+
+	return 0;
+}
+
+static inline void
+jme_reset_phy_processor(struct jme_adapter *jme)
+{
+	__u32 val;
+
+	jme_mdio_write(jme->dev,
+			jme->mii_if.phy_id,
+			MII_ADVERTISE, ADVERTISE_ALL |
+			ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM);
+
+	if (jme->pdev->device == PCI_DEVICE_ID_JMICRON_JMC250)
+		jme_mdio_write(jme->dev,
+				jme->mii_if.phy_id,
+				MII_CTRL1000,
+				ADVERTISE_1000FULL | ADVERTISE_1000HALF);
+
+	val = jme_mdio_read(jme->dev,
+				jme->mii_if.phy_id,
+				MII_BMCR);
+
+	jme_mdio_write(jme->dev,
+			jme->mii_if.phy_id,
+			MII_BMCR, val | BMCR_RESET);
+
+	return;
+}
+
+static void
+jme_setup_wakeup_frame(struct jme_adapter *jme,
+		__u32 *mask, __u32 crc, int fnr)
+{
+	int i;
+
+	/*
+	 * Setup CRC pattern
+	 */
+	jwrite32(jme, JME_WFOI, WFOI_CRC_SEL | (fnr & WFOI_FRAME_SEL));
+	wmb();
+	jwrite32(jme, JME_WFODP, crc);
+	wmb();
+
+	/*
+	 * Setup Mask
+	 */
+	for (i = 0 ; i < WAKEUP_FRAME_MASK_DWNR ; ++i) {
+		jwrite32(jme, JME_WFOI,
+				((i << WFOI_MASK_SHIFT) & WFOI_MASK_SEL) |
+				(fnr & WFOI_FRAME_SEL));
+		wmb();
+		jwrite32(jme, JME_WFODP, mask[i]);
+		wmb();
+	}
+}
+
+static inline void
+jme_reset_mac_processor(struct jme_adapter *jme)
+{
+	__u32 mask[WAKEUP_FRAME_MASK_DWNR] = {0, 0, 0, 0};
+	__u32 crc = 0xCDCDCDCD;
+	__u32 gpreg0;
+	int i;
+
+	jwrite32(jme, JME_GHC, jme->reg_ghc | GHC_SWRST);
+	udelay(2);
+	jwrite32(jme, JME_GHC, jme->reg_ghc);
+	jwrite32(jme, JME_RXMCHT_LO, 0x00000000);
+	jwrite32(jme, JME_RXMCHT_HI, 0x00000000);
+	for (i = 0 ; i < WAKEUP_FRAME_NR ; ++i)
+		jme_setup_wakeup_frame(jme, mask, crc, i);
+	if (jme->fpgaver)
+		gpreg0 = GPREG0_DEFAULT | GPREG0_LNKINTPOLL;
+	else
+		gpreg0 = GPREG0_DEFAULT;
+	jwrite32(jme, JME_GPREG0, gpreg0);
+	jwrite32(jme, JME_GPREG1, 0);
+}
+
+static inline void
+jme_clear_pm(struct jme_adapter *jme)
+{
+	jwrite32(jme, JME_PMCS, 0xFFFF0000 | jme->reg_pmcs);
+	pci_set_power_state(jme->pdev, PCI_D0);
+	pci_enable_wake(jme->pdev, PCI_D0, false);
+}
+
+static int
+jme_reload_eeprom(struct jme_adapter *jme)
+{
+	__u32 val;
+	int i;
+
+	val = jread32(jme, JME_SMBCSR);
+
+	if (val & SMBCSR_EEPROMD) {
+		val |= SMBCSR_CNACK;
+		jwrite32(jme, JME_SMBCSR, val);
+		val |= SMBCSR_RELOAD;
+		jwrite32(jme, JME_SMBCSR, val);
+		mdelay(12);
+
+		for (i = JME_EEPROM_RELOAD_TIMEOUT; i > 0; --i) {
+			mdelay(1);
+			if ((jread32(jme, JME_SMBCSR) & SMBCSR_RELOAD) == 0)
+				break;
+		}
+
+		if (i == 0) {
+			jeprintk(jme->pdev, "eeprom reload timeout\n");
+			return -EIO;
+		}
+	}
+
+	return 0;
+}
+
+static void
+jme_load_macaddr(struct net_device *netdev)
+{
+	struct jme_adapter *jme = netdev_priv(netdev);
+	unsigned char macaddr[6];
+	__u32 val;
+
+	spin_lock_bh(&jme->macaddr_lock);
+	val = jread32(jme, JME_RXUMA_LO);
+	macaddr[0] = (val >>  0) & 0xFF;
+	macaddr[1] = (val >>  8) & 0xFF;
+	macaddr[2] = (val >> 16) & 0xFF;
+	macaddr[3] = (val >> 24) & 0xFF;
+	val = jread32(jme, JME_RXUMA_HI);
+	macaddr[4] = (val >>  0) & 0xFF;
+	macaddr[5] = (val >>  8) & 0xFF;
+	memcpy(netdev->dev_addr, macaddr, 6);
+	spin_unlock_bh(&jme->macaddr_lock);
+}
+
+static inline void
+jme_set_rx_pcc(struct jme_adapter *jme, int p)
+{
+	switch (p) {
+	case PCC_OFF:
+		jwrite32(jme, JME_PCCRX0,
+			((PCC_OFF_TO << PCCRXTO_SHIFT) & PCCRXTO_MASK) |
+			((PCC_OFF_CNT << PCCRX_SHIFT) & PCCRX_MASK));
+		break;
+	case PCC_P1:
+		jwrite32(jme, JME_PCCRX0,
+			((PCC_P1_TO << PCCRXTO_SHIFT) & PCCRXTO_MASK) |
+			((PCC_P1_CNT << PCCRX_SHIFT) & PCCRX_MASK));
+		break;
+	case PCC_P2:
+		jwrite32(jme, JME_PCCRX0,
+			((PCC_P2_TO << PCCRXTO_SHIFT) & PCCRXTO_MASK) |
+			((PCC_P2_CNT << PCCRX_SHIFT) & PCCRX_MASK));
+		break;
+	case PCC_P3:
+		jwrite32(jme, JME_PCCRX0,
+			((PCC_P3_TO << PCCRXTO_SHIFT) & PCCRXTO_MASK) |
+			((PCC_P3_CNT << PCCRX_SHIFT) & PCCRX_MASK));
+		break;
+	default:
+		break;
+	}
+	wmb();
+
+	if (!(test_bit(JME_FLAG_POLL, &jme->flags)))
+		msg_rx_status(jme, "Switched to PCC_P%d\n", p);
+}
+
+static void
+jme_start_irq(struct jme_adapter *jme)
+{
+	register struct dynpcc_info *dpi = &(jme->dpi);
+
+	jme_set_rx_pcc(jme, PCC_P1);
+	dpi->cur		= PCC_P1;
+	dpi->attempt		= PCC_P1;
+	dpi->cnt		= 0;
+
+	jwrite32(jme, JME_PCCTX,
+			((PCC_TX_TO << PCCTXTO_SHIFT) & PCCTXTO_MASK) |
+			((PCC_TX_CNT << PCCTX_SHIFT) & PCCTX_MASK) |
+			PCCTXQ0_EN
+		);
+
+	/*
+	 * Enable Interrupts
+	 */
+	jwrite32(jme, JME_IENS, INTR_ENABLE);
+}
+
+static inline void
+jme_stop_irq(struct jme_adapter *jme)
+{
+	/*
+	 * Disable Interrupts
+	 */
+	jwrite32f(jme, JME_IENC, INTR_ENABLE);
+}
+
+static inline void
+jme_enable_shadow(struct jme_adapter *jme)
+{
+	jwrite32(jme,
+		 JME_SHBA_LO,
+		 ((__u32)jme->shadow_dma & ~((__u32)0x1F)) | SHBA_POSTEN);
+}
+
+static inline void
+jme_disable_shadow(struct jme_adapter *jme)
+{
+	jwrite32(jme, JME_SHBA_LO, 0x0);
+}
+
+static __u32
+jme_linkstat_from_phy(struct jme_adapter *jme)
+{
+	__u32 phylink, bmsr;
+
+	phylink = jme_mdio_read(jme->dev, jme->mii_if.phy_id, 17);
+	bmsr = jme_mdio_read(jme->dev, jme->mii_if.phy_id, MII_BMSR);
+	if (bmsr & BMSR_ANCOMP)
+		phylink |= PHY_LINK_AUTONEG_COMPLETE;
+
+	return phylink;
+}
+
+static int
+jme_check_link(struct net_device *netdev, int testonly)
+{
+	struct jme_adapter *jme = netdev_priv(netdev);
+	__u32 phylink, ghc, cnt = JME_SPDRSV_TIMEOUT, bmcr;
+	char linkmsg[64];
+	int rc = 0;
+
+	linkmsg[0] = '\0';
+
+	if (jme->fpgaver)
+		phylink = jme_linkstat_from_phy(jme);
+	else
+		phylink = jread32(jme, JME_PHY_LINK);
+
+	if (phylink & PHY_LINK_UP) {
+		if (!(phylink & PHY_LINK_AUTONEG_COMPLETE)) {
+			/*
+			 * If we did not enable AN
+			 * Speed/Duplex Info should be obtained from SMI
+			 */
+			phylink = PHY_LINK_UP;
+
+			bmcr = jme_mdio_read(jme->dev,
+						jme->mii_if.phy_id,
+						MII_BMCR);
+
+
+			phylink |= ((bmcr & BMCR_SPEED1000) &&
+					(bmcr & BMCR_SPEED100) == 0) ?
+					PHY_LINK_SPEED_1000M :
+					(bmcr & BMCR_SPEED100) ?
+					PHY_LINK_SPEED_100M :
+					PHY_LINK_SPEED_10M;
+
+			phylink |= (bmcr & BMCR_FULLDPLX) ?
+					 PHY_LINK_DUPLEX : 0;
+
+			strcat(linkmsg, "Forced: ");
+		} else {
+			/*
+			 * Keep polling for speed/duplex resolve complete
+			 */
+			while (!(phylink & PHY_LINK_SPEEDDPU_RESOLVED) &&
+				--cnt) {
+
+				udelay(1);
+
+				if (jme->fpgaver)
+					phylink = jme_linkstat_from_phy(jme);
+				else
+					phylink = jread32(jme, JME_PHY_LINK);
+			}
+			if (!cnt)
+				jeprintk(jme->pdev,
+					"Waiting speed resolve timeout.\n");
+
+			strcat(linkmsg, "ANed: ");
+		}
+
+		if (jme->phylink == phylink) {
+			rc = 1;
+			goto out;
+		}
+		if (testonly)
+			goto out;
+
+		jme->phylink = phylink;
+
+		ghc = jme->reg_ghc & ~(GHC_SPEED_10M |
+					GHC_SPEED_100M |
+					GHC_SPEED_1000M |
+					GHC_DPX);
+		switch (phylink & PHY_LINK_SPEED_MASK) {
+		case PHY_LINK_SPEED_10M:
+			ghc |= GHC_SPEED_10M;
+			strcat(linkmsg, "10 Mbps, ");
+			break;
+		case PHY_LINK_SPEED_100M:
+			ghc |= GHC_SPEED_100M;
+			strcat(linkmsg, "100 Mbps, ");
+			break;
+		case PHY_LINK_SPEED_1000M:
+			ghc |= GHC_SPEED_1000M;
+			strcat(linkmsg, "1000 Mbps, ");
+			break;
+		default:
+			break;
+		}
+		ghc |= (phylink & PHY_LINK_DUPLEX) ? GHC_DPX : 0;
+
+		strcat(linkmsg, (phylink & PHY_LINK_DUPLEX) ?
+					"Full-Duplex, " :
+					"Half-Duplex, ");
+
+		if (phylink & PHY_LINK_MDI_STAT)
+			strcat(linkmsg, "MDI-X");
+		else
+			strcat(linkmsg, "MDI");
+
+		if (phylink & PHY_LINK_DUPLEX) {
+			jwrite32(jme, JME_TXMCS, TXMCS_DEFAULT);
+		} else {
+			jwrite32(jme, JME_TXMCS, TXMCS_DEFAULT |
+						TXMCS_BACKOFF |
+						TXMCS_CARRIERSENSE |
+						TXMCS_COLLISION);
+			jwrite32(jme, JME_TXTRHD, TXTRHD_TXPEN |
+				((0x2000 << TXTRHD_TXP_SHIFT) & TXTRHD_TXP) |
+				TXTRHD_TXREN |
+				((8 << TXTRHD_TXRL_SHIFT) & TXTRHD_TXRL));
+		}
+
+		jme->reg_ghc = ghc;
+		jwrite32(jme, JME_GHC, ghc);
+
+		msg_link(jme, "Link is up at %s.\n", linkmsg);
+		netif_carrier_on(netdev);
+	} else {
+		if (testonly)
+			goto out;
+
+		msg_link(jme, "Link is down.\n");
+		jme->phylink = 0;
+		netif_carrier_off(netdev);
+	}
+
+out:
+	return rc;
+}
+
+static int
+jme_setup_tx_resources(struct jme_adapter *jme)
+{
+	struct jme_ring *txring = &(jme->txring[0]);
+
+	txring->alloc = dma_alloc_coherent(&(jme->pdev->dev),
+				   TX_RING_ALLOC_SIZE(jme->tx_ring_size),
+				   &(txring->dmaalloc),
+				   GFP_ATOMIC);
+
+	if (!txring->alloc) {
+		txring->desc = NULL;
+		txring->dmaalloc = 0;
+		txring->dma = 0;
+		return -ENOMEM;
+	}
+
+	/*
+	 * 16 Bytes align
+	 */
+	txring->desc		= (void *)ALIGN((unsigned long)(txring->alloc),
+						RING_DESC_ALIGN);
+	txring->dma		= ALIGN(txring->dmaalloc, RING_DESC_ALIGN);
+	txring->next_to_use	= 0;
+	atomic_set(&txring->next_to_clean, 0);
+	atomic_set(&txring->nr_free, jme->tx_ring_size);
+
+	/*
+	 * Initialize Transmit Descriptors
+	 */
+	memset(txring->alloc, 0, TX_RING_ALLOC_SIZE(jme->tx_ring_size));
+	memset(txring->bufinf, 0,
+		sizeof(struct jme_buffer_info) * jme->tx_ring_size);
+
+	return 0;
+}
+
+static void
+jme_free_tx_resources(struct jme_adapter *jme)
+{
+	int i;
+	struct jme_ring *txring = &(jme->txring[0]);
+	struct jme_buffer_info *txbi = txring->bufinf;
+
+	if (txring->alloc) {
+		for (i = 0 ; i < jme->tx_ring_size ; ++i) {
+			txbi = txring->bufinf + i;
+			if (txbi->skb) {
+				dev_kfree_skb(txbi->skb);
+				txbi->skb = NULL;
+			}
+			txbi->mapping		= 0;
+			txbi->len		= 0;
+			txbi->nr_desc		= 0;
+			txbi->start_xmit	= 0;
+		}
+
+		dma_free_coherent(&(jme->pdev->dev),
+				  TX_RING_ALLOC_SIZE(jme->tx_ring_size),
+				  txring->alloc,
+				  txring->dmaalloc);
+
+		txring->alloc		= NULL;
+		txring->desc		= NULL;
+		txring->dmaalloc	= 0;
+		txring->dma		= 0;
+	}
+	txring->next_to_use	= 0;
+	atomic_set(&txring->next_to_clean, 0);
+	atomic_set(&txring->nr_free, 0);
+
+}
+
+static inline void
+jme_enable_tx_engine(struct jme_adapter *jme)
+{
+	/*
+	 * Select Queue 0
+	 */
+	jwrite32(jme, JME_TXCS, TXCS_DEFAULT | TXCS_SELECT_QUEUE0);
+
+	/*
+	 * Setup TX Queue 0 DMA Bass Address
+	 */
+	jwrite32(jme, JME_TXDBA_LO, (__u64)jme->txring[0].dma & 0xFFFFFFFFUL);
+	jwrite32(jme, JME_TXDBA_HI, (__u64)(jme->txring[0].dma) >> 32);
+	jwrite32(jme, JME_TXNDA, (__u64)jme->txring[0].dma & 0xFFFFFFFFUL);
+
+	/*
+	 * Setup TX Descptor Count
+	 */
+	jwrite32(jme, JME_TXQDC, jme->tx_ring_size);
+
+	/*
+	 * Enable TX Engine
+	 */
+	wmb();
+	jwrite32(jme, JME_TXCS, jme->reg_txcs |
+				TXCS_SELECT_QUEUE0 |
+				TXCS_ENABLE);
+
+}
+
+static inline void
+jme_restart_tx_engine(struct jme_adapter *jme)
+{
+	/*
+	 * Restart TX Engine
+	 */
+	jwrite32(jme, JME_TXCS, jme->reg_txcs |
+				TXCS_SELECT_QUEUE0 |
+				TXCS_ENABLE);
+}
+
+static inline void
+jme_disable_tx_engine(struct jme_adapter *jme)
+{
+	int i;
+	__u32 val;
+
+	/*
+	 * Disable TX Engine
+	 */
+	jwrite32(jme, JME_TXCS, jme->reg_txcs | TXCS_SELECT_QUEUE0);
+
+	val = jread32(jme, JME_TXCS);
+	for (i = JME_TX_DISABLE_TIMEOUT ; (val & TXCS_ENABLE) && i > 0 ; --i) {
+		mdelay(1);
+		val = jread32(jme, JME_TXCS);
+	}
+
+	if (!i) {
+		jeprintk(jme->pdev, "Disable TX engine timeout.\n");
+		jme_reset_mac_processor(jme);
+	}
+
+
+}
+
+static void
+jme_set_clean_rxdesc(struct jme_adapter *jme, int i)
+{
+	struct jme_ring *rxring = jme->rxring;
+	register struct rxdesc *rxdesc = rxring->desc;
+	struct jme_buffer_info *rxbi = rxring->bufinf;
+	rxdesc += i;
+	rxbi += i;
+
+	rxdesc->dw[0] = 0;
+	rxdesc->dw[1] = 0;
+	rxdesc->desc1.bufaddrh	= cpu_to_le32((__u64)rxbi->mapping >> 32);
+	rxdesc->desc1.bufaddrl	= cpu_to_le32(
+					(__u64)rxbi->mapping & 0xFFFFFFFFUL);
+	rxdesc->desc1.datalen	= cpu_to_le16(rxbi->len);
+	if (jme->dev->features & NETIF_F_HIGHDMA)
+		rxdesc->desc1.flags = RXFLAG_64BIT;
+	wmb();
+	rxdesc->desc1.flags	|= RXFLAG_OWN | RXFLAG_INT;
+}
+
+static int
+jme_make_new_rx_buf(struct jme_adapter *jme, int i)
+{
+	struct jme_ring *rxring = &(jme->rxring[0]);
+	struct jme_buffer_info *rxbi = rxring->bufinf + i;
+	struct sk_buff *skb;
+
+	skb = netdev_alloc_skb(jme->dev,
+		jme->dev->mtu + RX_EXTRA_LEN);
+	if (unlikely(!skb))
+		return -ENOMEM;
+
+	rxbi->skb = skb;
+	rxbi->len = skb_tailroom(skb);
+	rxbi->mapping = pci_map_page(jme->pdev,
+					virt_to_page(skb->data),
+					offset_in_page(skb->data),
+					rxbi->len,
+					PCI_DMA_FROMDEVICE);
+
+	return 0;
+}
+
+static void
+jme_free_rx_buf(struct jme_adapter *jme, int i)
+{
+	struct jme_ring *rxring = &(jme->rxring[0]);
+	struct jme_buffer_info *rxbi = rxring->bufinf;
+	rxbi += i;
+
+	if (rxbi->skb) {
+		pci_unmap_page(jme->pdev,
+				 rxbi->mapping,
+				 rxbi->len,
+				 PCI_DMA_FROMDEVICE);
+		dev_kfree_skb(rxbi->skb);
+		rxbi->skb = NULL;
+		rxbi->mapping = 0;
+		rxbi->len = 0;
+	}
+}
+
+static void
+jme_free_rx_resources(struct jme_adapter *jme)
+{
+	int i;
+	struct jme_ring *rxring = &(jme->rxring[0]);
+
+	if (rxring->alloc) {
+		for (i = 0 ; i < jme->rx_ring_size ; ++i)
+			jme_free_rx_buf(jme, i);
+
+		dma_free_coherent(&(jme->pdev->dev),
+				  RX_RING_ALLOC_SIZE(jme->rx_ring_size),
+				  rxring->alloc,
+				  rxring->dmaalloc);
+		rxring->alloc    = NULL;
+		rxring->desc     = NULL;
+		rxring->dmaalloc = 0;
+		rxring->dma      = 0;
+	}
+	rxring->next_to_use   = 0;
+	atomic_set(&rxring->next_to_clean, 0);
+}
+
+static int
+jme_setup_rx_resources(struct jme_adapter *jme)
+{
+	int i;
+	struct jme_ring *rxring = &(jme->rxring[0]);
+
+	rxring->alloc = dma_alloc_coherent(&(jme->pdev->dev),
+				   RX_RING_ALLOC_SIZE(jme->rx_ring_size),
+				   &(rxring->dmaalloc),
+				   GFP_ATOMIC);
+	if (!rxring->alloc) {
+		rxring->desc = NULL;
+		rxring->dmaalloc = 0;
+		rxring->dma = 0;
+		return -ENOMEM;
+	}
+
+	/*
+	 * 16 Bytes align
+	 */
+	rxring->desc		= (void *)ALIGN((unsigned long)(rxring->alloc),
+						RING_DESC_ALIGN);
+	rxring->dma		= ALIGN(rxring->dmaalloc, RING_DESC_ALIGN);
+	rxring->next_to_use	= 0;
+	atomic_set(&rxring->next_to_clean, 0);
+
+	/*
+	 * Initiallize Receive Descriptors
+	 */
+	for (i = 0 ; i < jme->rx_ring_size ; ++i) {
+		if (unlikely(jme_make_new_rx_buf(jme, i))) {
+			jme_free_rx_resources(jme);
+			return -ENOMEM;
+		}
+
+		jme_set_clean_rxdesc(jme, i);
+	}
+
+	return 0;
+}
+
+static inline void
+jme_enable_rx_engine(struct jme_adapter *jme)
+{
+	/*
+	 * Setup RX DMA Bass Address
+	 */
+	jwrite32(jme, JME_RXDBA_LO, (__u64)jme->rxring[0].dma & 0xFFFFFFFFUL);
+	jwrite32(jme, JME_RXDBA_HI, (__u64)(jme->rxring[0].dma) >> 32);
+	jwrite32(jme, JME_RXNDA, (__u64)jme->rxring[0].dma & 0xFFFFFFFFUL);
+
+	/*
+	 * Setup RX Descriptor Count
+	 */
+	jwrite32(jme, JME_RXQDC, jme->rx_ring_size);
+
+	/*
+	 * Setup Unicast Filter
+	 */
+	jme_set_multi(jme->dev);
+
+	/*
+	 * Enable RX Engine
+	 */
+	wmb();
+	jwrite32(jme, JME_RXCS, jme->reg_rxcs |
+				RXCS_QUEUESEL_Q0 |
+				RXCS_ENABLE |
+				RXCS_QST);
+}
+
+static inline void
+jme_restart_rx_engine(struct jme_adapter *jme)
+{
+	/*
+	 * Start RX Engine
+	 */
+	jwrite32(jme, JME_RXCS, jme->reg_rxcs |
+				RXCS_QUEUESEL_Q0 |
+				RXCS_ENABLE |
+				RXCS_QST);
+}
+
+static inline void
+jme_disable_rx_engine(struct jme_adapter *jme)
+{
+	int i;
+	__u32 val;
+
+	/*
+	 * Disable RX Engine
+	 */
+	jwrite32(jme, JME_RXCS, jme->reg_rxcs);
+
+	val = jread32(jme, JME_RXCS);
+	for (i = JME_RX_DISABLE_TIMEOUT ; (val & RXCS_ENABLE) && i > 0 ; --i) {
+		mdelay(1);
+		val = jread32(jme, JME_RXCS);
+	}
+
+	if (!i)
+		jeprintk(jme->pdev, "Disable RX engine timeout.\n");
+
+}
+
+static int
+jme_rxsum_ok(struct jme_adapter *jme, __u16 flags)
+{
+	if (!(flags & (RXWBFLAG_TCPON | RXWBFLAG_UDPON | RXWBFLAG_IPV4)))
+		return false;
+
+	if (unlikely(!(flags & RXWBFLAG_MF) &&
+	(flags & RXWBFLAG_TCPON) && !(flags & RXWBFLAG_TCPCS))) {
+		msg_rx_err(jme, "TCP Checksum error.\n");
+		goto out_sumerr;
+	}
+
+	if (unlikely(!(flags & RXWBFLAG_MF) &&
+	(flags & RXWBFLAG_UDPON) && !(flags & RXWBFLAG_UDPCS))) {
+		msg_rx_err(jme, "UDP Checksum error.\n");
+		goto out_sumerr;
+	}
+
+	if (unlikely((flags & RXWBFLAG_IPV4) && !(flags & RXWBFLAG_IPCS))) {
+		msg_rx_err(jme, "IPv4 Checksum error.\n");
+		goto out_sumerr;
+	}
+
+	return true;
+
+out_sumerr:
+	return false;
+}
+
+static void
+jme_alloc_and_feed_skb(struct jme_adapter *jme, int idx)
+{
+	struct jme_ring *rxring = &(jme->rxring[0]);
+	struct rxdesc *rxdesc = rxring->desc;
+	struct jme_buffer_info *rxbi = rxring->bufinf;
+	struct sk_buff *skb;
+	int framesize;
+
+	rxdesc += idx;
+	rxbi += idx;
+
+	skb = rxbi->skb;
+	pci_dma_sync_single_for_cpu(jme->pdev,
+					rxbi->mapping,
+					rxbi->len,
+					PCI_DMA_FROMDEVICE);
+
+	if (unlikely(jme_make_new_rx_buf(jme, idx))) {
+		pci_dma_sync_single_for_device(jme->pdev,
+						rxbi->mapping,
+						rxbi->len,
+						PCI_DMA_FROMDEVICE);
+
+		++(NET_STAT(jme).rx_dropped);
+	} else {
+		framesize = le16_to_cpu(rxdesc->descwb.framesize)
+				- RX_PREPAD_SIZE;
+
+		skb_reserve(skb, RX_PREPAD_SIZE);
+		skb_put(skb, framesize);
+		skb->protocol = eth_type_trans(skb, jme->dev);
+
+		if (jme_rxsum_ok(jme, rxdesc->descwb.flags))
+			skb->ip_summed = CHECKSUM_UNNECESSARY;
+		else
+			skb->ip_summed = CHECKSUM_NONE;
+
+
+		if (rxdesc->descwb.flags & RXWBFLAG_TAGON) {
+			if (jme->vlgrp) {
+				jme->jme_vlan_rx(skb, jme->vlgrp,
+					le32_to_cpu(rxdesc->descwb.vlan));
+				NET_STAT(jme).rx_bytes += 4;
+			}
+		} else {
+			jme->jme_rx(skb);
+		}
+
+		if ((le16_to_cpu(rxdesc->descwb.flags) & RXWBFLAG_DEST) ==
+				RXWBFLAG_DEST_MUL)
+			++(NET_STAT(jme).multicast);
+
+		jme->dev->last_rx = jiffies;
+		NET_STAT(jme).rx_bytes += framesize;
+		++(NET_STAT(jme).rx_packets);
+	}
+
+	jme_set_clean_rxdesc(jme, idx);
+
+}
+
+static int
+jme_process_receive(struct jme_adapter *jme, int limit)
+{
+	struct jme_ring *rxring = &(jme->rxring[0]);
+	struct rxdesc *rxdesc = rxring->desc;
+	int i, j, ccnt, desccnt, mask = jme->rx_ring_mask;
+
+	if (unlikely(!atomic_dec_and_test(&jme->rx_cleaning)))
+		goto out_inc;
+
+	if (unlikely(atomic_read(&jme->link_changing) != 1))
+		goto out_inc;
+
+	if (unlikely(!netif_carrier_ok(jme->dev)))
+		goto out_inc;
+
+	i = atomic_read(&rxring->next_to_clean);
+	while (limit-- > 0) {
+		rxdesc = rxring->desc;
+		rxdesc += i;
+
+		if ((rxdesc->descwb.flags & RXWBFLAG_OWN) ||
+		!(rxdesc->descwb.desccnt & RXWBDCNT_WBCPL))
+			goto out;
+
+		desccnt = rxdesc->descwb.desccnt & RXWBDCNT_DCNT;
+
+		if (unlikely(desccnt > 1 ||
+		rxdesc->descwb.errstat & RXWBERR_ALLERR)) {
+
+			if (rxdesc->descwb.errstat & RXWBERR_CRCERR)
+				++(NET_STAT(jme).rx_crc_errors);
+			else if (rxdesc->descwb.errstat & RXWBERR_OVERUN)
+				++(NET_STAT(jme).rx_fifo_errors);
+			else
+				++(NET_STAT(jme).rx_errors);
+
+			if (desccnt > 1)
+				limit -= desccnt - 1;
+
+			for (j = i, ccnt = desccnt ; ccnt-- ; ) {
+				jme_set_clean_rxdesc(jme, j);
+				j = (j + 1) & (mask);
+			}
+
+		} else {
+			jme_alloc_and_feed_skb(jme, i);
+		}
+
+		i = (i + desccnt) & (mask);
+	}
+
+
+out:
+	atomic_set(&rxring->next_to_clean, i);
+
+out_inc:
+	atomic_inc(&jme->rx_cleaning);
+
+	return limit > 0 ? limit : 0;
+
+}
+
+static void
+jme_attempt_pcc(struct dynpcc_info *dpi, int atmp)
+{
+	if (likely(atmp == dpi->cur)) {
+		dpi->cnt = 0;
+		return;
+	}
+
+	if (dpi->attempt == atmp) {
+		++(dpi->cnt);
+	} else {
+		dpi->attempt = atmp;
+		dpi->cnt = 0;
+	}
+
+}
+
+static void
+jme_dynamic_pcc(struct jme_adapter *jme)
+{
+	register struct dynpcc_info *dpi = &(jme->dpi);
+
+	if ((NET_STAT(jme).rx_bytes - dpi->last_bytes) > PCC_P3_THRESHOLD)
+		jme_attempt_pcc(dpi, PCC_P3);
+	else if ((NET_STAT(jme).rx_packets - dpi->last_pkts) > PCC_P2_THRESHOLD
+	|| dpi->intr_cnt > PCC_INTR_THRESHOLD)
+		jme_attempt_pcc(dpi, PCC_P2);
+	else
+		jme_attempt_pcc(dpi, PCC_P1);
+
+	if (unlikely(dpi->attempt != dpi->cur && dpi->cnt > 5)) {
+		jme_set_rx_pcc(jme, dpi->attempt);
+		dpi->cur = dpi->attempt;
+		dpi->cnt = 0;
+	}
+}
+
+static void
+jme_start_pcc_timer(struct jme_adapter *jme)
+{
+	struct dynpcc_info *dpi = &(jme->dpi);
+	dpi->last_bytes		= NET_STAT(jme).rx_bytes;
+	dpi->last_pkts		= NET_STAT(jme).rx_packets;
+	dpi->intr_cnt		= 0;
+	jwrite32(jme, JME_TMCSR,
+		TMCSR_EN | ((0xFFFFFF - PCC_INTERVAL_US) & TMCSR_CNT));
+}
+
+static inline void
+jme_stop_pcc_timer(struct jme_adapter *jme)
+{
+	jwrite32(jme, JME_TMCSR, 0);
+}
+
+static void
+jme_shutdown_nic(struct jme_adapter *jme)
+{
+	__u32 phylink;
+
+	phylink = jme_linkstat_from_phy(jme);
+
+	if (!(phylink & PHY_LINK_UP)) {
+		/*
+		 * Disable all interrupt before issue timer
+		 */
+		jme_stop_irq(jme);
+		jwrite32(jme, JME_TIMER2, TMCSR_EN | 0xFFFFFE);
+	}
+}
+
+static void
+jme_pcc_tasklet(unsigned long arg)
+{
+	struct jme_adapter *jme = (struct jme_adapter *)arg;
+	struct net_device *netdev = jme->dev;
+
+	if (unlikely(test_bit(JME_FLAG_SHUTDOWN, &jme->flags))) {
+		jme_shutdown_nic(jme);
+		return;
+	}
+
+	if (unlikely(!netif_carrier_ok(netdev) ||
+		(atomic_read(&jme->link_changing) != 1)
+	)) {
+		jme_stop_pcc_timer(jme);
+		return;
+	}
+
+	if (!(test_bit(JME_FLAG_POLL, &jme->flags)))
+		jme_dynamic_pcc(jme);
+
+	jme_start_pcc_timer(jme);
+}
+
+static inline void
+jme_polling_mode(struct jme_adapter *jme)
+{
+	jme_set_rx_pcc(jme, PCC_OFF);
+}
+
+static inline void
+jme_interrupt_mode(struct jme_adapter *jme)
+{
+	jme_set_rx_pcc(jme, PCC_P1);
+}
+
+static inline int
+jme_pseudo_hotplug_enabled(struct jme_adapter *jme)
+{
+	__u32 apmc;
+	apmc = jread32(jme, JME_APMC);
+	return apmc & JME_APMC_PSEUDO_HP_EN;
+}
+
+static void
+jme_start_shutdown_timer(struct jme_adapter *jme)
+{
+	__u32 apmc;
+
+	apmc = jread32(jme, JME_APMC) | JME_APMC_PCIE_SD_EN;
+	apmc &= ~JME_APMC_EPIEN_CTRL;
+	if (!no_extplug) {
+		jwrite32f(jme, JME_APMC, apmc | JME_APMC_EPIEN_CTRL_EN);
+		wmb();
+	}
+	jwrite32f(jme, JME_APMC, apmc);
+
+	jwrite32f(jme, JME_TIMER2, 0);
+	set_bit(JME_FLAG_SHUTDOWN, &jme->flags);
+	jwrite32(jme, JME_TMCSR,
+		TMCSR_EN | ((0xFFFFFF - APMC_PHP_SHUTDOWN_DELAY) & TMCSR_CNT));
+}
+
+static void
+jme_stop_shutdown_timer(struct jme_adapter *jme)
+{
+	__u32 apmc;
+
+	jwrite32f(jme, JME_TMCSR, 0);
+	jwrite32f(jme, JME_TIMER2, 0);
+	clear_bit(JME_FLAG_SHUTDOWN, &jme->flags);
+
+	apmc = jread32(jme, JME_APMC);
+	apmc &= ~(JME_APMC_PCIE_SD_EN | JME_APMC_EPIEN_CTRL);
+	jwrite32f(jme, JME_APMC, apmc | JME_APMC_EPIEN_CTRL_DIS);
+	wmb();
+	jwrite32f(jme, JME_APMC, apmc);
+}
+
+static void
+jme_link_change_tasklet(unsigned long arg)
+{
+	struct jme_adapter *jme = (struct jme_adapter *)arg;
+	struct net_device *netdev = jme->dev;
+	int timeout = WAIT_TASKLET_TIMEOUT;
+	int rc;
+
+	if (!atomic_dec_and_test(&jme->link_changing))
+		goto out;
+
+	if (jme_check_link(netdev, 1) && jme->old_mtu == netdev->mtu)
+		goto out;
+
+	jme->old_mtu = netdev->mtu;
+	netif_stop_queue(netdev);
+	if (jme_pseudo_hotplug_enabled(jme))
+		jme_stop_shutdown_timer(jme);
+
+	while (--timeout > 0 &&
+		(
+		atomic_read(&jme->rx_cleaning) != 1 ||
+		atomic_read(&jme->tx_cleaning) != 1
+		)) {
+
+		mdelay(1);
+	}
+
+	if (netif_carrier_ok(netdev)) {
+		jme_stop_pcc_timer(jme);
+		jme_reset_mac_processor(jme);
+		jme_free_rx_resources(jme);
+		jme_free_tx_resources(jme);
+
+		if (test_bit(JME_FLAG_POLL, &jme->flags))
+			jme_polling_mode(jme);
+	}
+
+	jme_check_link(netdev, 0);
+	if (netif_carrier_ok(netdev)) {
+
+		rc = jme_setup_rx_resources(jme);
+		if (rc) {
+			jeprintk(jme->pdev, "Allocating resources for RX error"
+				", Device STOPPED!\n");
+			goto out;
+		}
+
+
+		rc = jme_setup_tx_resources(jme);
+		if (rc) {
+			jeprintk(jme->pdev, "Allocating resources for TX error"
+				", Device STOPPED!\n");
+			goto err_out_free_rx_resources;
+		}
+
+		jme_enable_rx_engine(jme);
+		jme_enable_tx_engine(jme);
+
+		netif_start_queue(netdev);
+
+		if (test_bit(JME_FLAG_POLL, &jme->flags))
+			jme_interrupt_mode(jme);
+
+		jme_start_pcc_timer(jme);
+	} else if (jme_pseudo_hotplug_enabled(jme)) {
+		jme_start_shutdown_timer(jme);
+	}
+
+	goto out;
+
+err_out_free_rx_resources:
+	jme_free_rx_resources(jme);
+out:
+	atomic_inc(&jme->link_changing);
+}
+
+static void
+jme_rx_clean_tasklet(unsigned long arg)
+{
+	struct jme_adapter *jme = (struct jme_adapter *)arg;
+	struct dynpcc_info *dpi = &(jme->dpi);
+
+	jme_process_receive(jme, jme->rx_ring_size);
+	++(dpi->intr_cnt);
+
+}
+
+static int
+jme_poll(JME_NAPI_HOLDER(holder), JME_NAPI_WEIGHT(budget))
+{
+	struct jme_adapter *jme = jme_napi_priv(holder);
+	struct net_device *netdev = jme->dev;
+	int rest;
+
+	rest = jme_process_receive(jme, JME_NAPI_WEIGHT_VAL(budget));
+
+	while (atomic_read(&jme->rx_empty) > 0) {
+		atomic_dec(&jme->rx_empty);
+		++(NET_STAT(jme).rx_dropped);
+		jme_restart_rx_engine(jme);
+	}
+	atomic_inc(&jme->rx_empty);
+
+	if (rest) {
+		JME_RX_COMPLETE(netdev, holder);
+		jme_interrupt_mode(jme);
+	}
+
+	JME_NAPI_WEIGHT_SET(budget, rest);
+	return JME_NAPI_WEIGHT_VAL(budget) - rest;
+}
+
+static void
+jme_rx_empty_tasklet(unsigned long arg)
+{
+	struct jme_adapter *jme = (struct jme_adapter *)arg;
+
+	if (unlikely(atomic_read(&jme->link_changing) != 1))
+		return;
+
+	if (unlikely(!netif_carrier_ok(jme->dev)))
+		return;
+
+	msg_rx_status(jme, "RX Queue Full!\n");
+
+	jme_rx_clean_tasklet(arg);
+
+	while (atomic_read(&jme->rx_empty) > 0) {
+		atomic_dec(&jme->rx_empty);
+		++(NET_STAT(jme).rx_dropped);
+		jme_restart_rx_engine(jme);
+	}
+	atomic_inc(&jme->rx_empty);
+}
+
+static void
+jme_wake_queue_if_stopped(struct jme_adapter *jme)
+{
+	struct jme_ring *txring = jme->txring;
+
+	smp_wmb();
+	if (unlikely(netif_queue_stopped(jme->dev) &&
+	atomic_read(&txring->nr_free) >= (jme->tx_wake_threshold))) {
+		msg_tx_done(jme, "TX Queue Waked.\n");
+		netif_wake_queue(jme->dev);
+	}
+
+}
+
+static void
+jme_tx_clean_tasklet(unsigned long arg)
+{
+	struct jme_adapter *jme = (struct jme_adapter *)arg;
+	struct jme_ring *txring = &(jme->txring[0]);
+	struct txdesc *txdesc = txring->desc;
+	struct jme_buffer_info *txbi = txring->bufinf, *ctxbi, *ttxbi;
+	int i, j, cnt = 0, max, err, mask;
+
+	if (unlikely(!atomic_dec_and_test(&jme->tx_cleaning)))
+		goto out;
+
+	if (unlikely(atomic_read(&jme->link_changing) != 1))
+		goto out;
+
+	if (unlikely(!netif_carrier_ok(jme->dev)))
+		goto out;
+
+	max = jme->tx_ring_size - atomic_read(&txring->nr_free);
+	mask = jme->tx_ring_mask;
+
+	for (i = atomic_read(&txring->next_to_clean) ; cnt < max ; ) {
+
+		ctxbi = txbi + i;
+
+		if (likely(ctxbi->skb &&
+		!(txdesc[i].descwb.flags & TXWBFLAG_OWN))) {
+
+			err = txdesc[i].descwb.flags & TXWBFLAG_ALLERR;
+
+			for (j = 1 ; j < ctxbi->nr_desc ; ++j) {
+				ttxbi = txbi + ((i + j) & (mask));
+				txdesc[(i + j) & (mask)].dw[0] = 0;
+
+				pci_unmap_page(jme->pdev,
+						 ttxbi->mapping,
+						 ttxbi->len,
+						 PCI_DMA_TODEVICE);
+
+				ttxbi->mapping = 0;
+				ttxbi->len = 0;
+			}
+
+			dev_kfree_skb(ctxbi->skb);
+
+			cnt += ctxbi->nr_desc;
+
+			if (unlikely(err)) {
+				++(NET_STAT(jme).tx_carrier_errors);
+			} else {
+				++(NET_STAT(jme).tx_packets);
+				NET_STAT(jme).tx_bytes += ctxbi->len;
+			}
+
+			ctxbi->skb = NULL;
+			ctxbi->len = 0;
+			ctxbi->start_xmit = 0;
+		} else {
+			break;
+		}
+
+		i = (i + ctxbi->nr_desc) & mask;
+
+		ctxbi->nr_desc = 0;
+	}
+
+	atomic_set(&txring->next_to_clean, i);
+	atomic_add(cnt, &txring->nr_free);
+
+	jme_wake_queue_if_stopped(jme);
+
+out:
+	atomic_inc(&jme->tx_cleaning);
+}
+
+static void
+jme_intr_msi(struct jme_adapter *jme, __u32 intrstat)
+{
+	/*
+	 * Disable interrupt
+	 */
+	jwrite32f(jme, JME_IENC, INTR_ENABLE);
+
+	if (intrstat & (INTR_LINKCH | INTR_SWINTR)) {
+		/*
+		 * Link change event is critical
+		 * all other events are ignored
+		 */
+		jwrite32(jme, JME_IEVE, intrstat);
+		tasklet_schedule(&jme->linkch_task);
+		goto out_reenable;
+	}
+
+	if (intrstat & INTR_TMINTR) {
+		jwrite32(jme, JME_IEVE, INTR_TMINTR);
+		tasklet_schedule(&jme->pcc_task);
+	}
+
+	if (intrstat & (INTR_PCCTXTO | INTR_PCCTX)) {
+		jwrite32(jme, JME_IEVE, INTR_PCCTXTO | INTR_PCCTX | INTR_TX0);
+		tasklet_schedule(&jme->txclean_task);
+	}
+
+	if ((intrstat & (INTR_PCCRX0TO | INTR_PCCRX0 | INTR_RX0EMP))) {
+		jwrite32(jme, JME_IEVE, (intrstat & (INTR_PCCRX0TO |
+						     INTR_PCCRX0 |
+						     INTR_RX0EMP)) |
+					INTR_RX0);
+	}
+
+	if (test_bit(JME_FLAG_POLL, &jme->flags)) {
+		if (intrstat & INTR_RX0EMP)
+			atomic_inc(&jme->rx_empty);
+
+		if ((intrstat & (INTR_PCCRX0TO | INTR_PCCRX0 | INTR_RX0EMP))) {
+			if (likely(JME_RX_SCHEDULE_PREP(jme))) {
+				jme_polling_mode(jme);
+				JME_RX_SCHEDULE(jme);
+			}
+		}
+	} else {
+		if (intrstat & INTR_RX0EMP) {
+			atomic_inc(&jme->rx_empty);
+			tasklet_hi_schedule(&jme->rxempty_task);
+		} else if (intrstat & (INTR_PCCRX0TO | INTR_PCCRX0)) {
+			tasklet_hi_schedule(&jme->rxclean_task);
+		}
+	}
+
+out_reenable:
+	/*
+	 * Re-enable interrupt
+	 */
+	jwrite32f(jme, JME_IENS, INTR_ENABLE);
+
+
+}
+
+static irqreturn_t
+jme_intr(int irq, void *dev_id)
+{
+	struct net_device *netdev = dev_id;
+	struct jme_adapter *jme = netdev_priv(netdev);
+	__u32 intrstat;
+
+	intrstat = jread32(jme, JME_IEVE);
+
+	/*
+	 * Check if it's really an interrupt for us
+	 */
+	if (unlikely(intrstat == 0))
+		return IRQ_NONE;
+
+	/*
+	 * Check if the device still exist
+	 */
+	if (unlikely(intrstat == ~((typeof(intrstat))0)))
+		return IRQ_NONE;
+
+	jme_intr_msi(jme, intrstat);
+
+	return IRQ_HANDLED;
+}
+
+static irqreturn_t
+jme_msi(int irq, void *dev_id)
+{
+	struct net_device *netdev = dev_id;
+	struct jme_adapter *jme = netdev_priv(netdev);
+	__u32 intrstat;
+
+	pci_dma_sync_single_for_cpu(jme->pdev,
+				    jme->shadow_dma,
+				    sizeof(__u32) * SHADOW_REG_NR,
+				    PCI_DMA_FROMDEVICE);
+	intrstat = jme->shadow_regs[SHADOW_IEVE];
+	jme->shadow_regs[SHADOW_IEVE] = 0;
+
+	jme_intr_msi(jme, intrstat);
+
+	return IRQ_HANDLED;
+}
+
+static void
+jme_reset_link(struct jme_adapter *jme)
+{
+	jwrite32(jme, JME_TMCSR, TMCSR_SWIT);
+}
+
+static void
+jme_restart_an(struct jme_adapter *jme)
+{
+	__u32 bmcr;
+
+	spin_lock_bh(&jme->phy_lock);
+	bmcr = jme_mdio_read(jme->dev, jme->mii_if.phy_id, MII_BMCR);
+	bmcr |= (BMCR_ANENABLE | BMCR_ANRESTART);
+	jme_mdio_write(jme->dev, jme->mii_if.phy_id, MII_BMCR, bmcr);
+	spin_unlock_bh(&jme->phy_lock);
+}
+
+static int
+jme_request_irq(struct jme_adapter *jme)
+{
+	int rc;
+	struct net_device *netdev = jme->dev;
+	irq_handler_t handler = jme_intr;
+	int irq_flags = IRQF_SHARED;
+
+	if (!pci_enable_msi(jme->pdev)) {
+		set_bit(JME_FLAG_MSI, &jme->flags);
+		handler = jme_msi;
+		irq_flags = 0;
+	}
+
+	rc = request_irq(jme->pdev->irq, handler, irq_flags, netdev->name,
+			  netdev);
+	if (rc) {
+		jeprintk(jme->pdev,
+			"Unable to request %s interrupt (return: %d)\n",
+			test_bit(JME_FLAG_MSI, &jme->flags) ? "MSI" : "INTx",
+			rc);
+
+		if (test_bit(JME_FLAG_MSI, &jme->flags)) {
+			pci_disable_msi(jme->pdev);
+			clear_bit(JME_FLAG_MSI, &jme->flags);
+		}
+	} else {
+		netdev->irq = jme->pdev->irq;
+	}
+
+	return rc;
+}
+
+static void
+jme_free_irq(struct jme_adapter *jme)
+{
+	free_irq(jme->pdev->irq, jme->dev);
+	if (test_bit(JME_FLAG_MSI, &jme->flags)) {
+		pci_disable_msi(jme->pdev);
+		clear_bit(JME_FLAG_MSI, &jme->flags);
+		jme->dev->irq = jme->pdev->irq;
+	}
+}
+
+static int
+jme_open(struct net_device *netdev)
+{
+	struct jme_adapter *jme = netdev_priv(netdev);
+	int rc, timeout = 10;
+
+	while (
+		--timeout > 0 &&
+		(
+		atomic_read(&jme->link_changing) != 1 ||
+		atomic_read(&jme->rx_cleaning) != 1 ||
+		atomic_read(&jme->tx_cleaning) != 1
+		)
+	)
+		msleep(1);
+
+	if (!timeout) {
+		rc = -EBUSY;
+		goto err_out;
+	}
+
+	jme_clear_pm(jme);
+	jme_reset_mac_processor(jme);
+	JME_NAPI_ENABLE(jme);
+
+	rc = jme_request_irq(jme);
+	if (rc)
+		goto err_out;
+
+	jme_enable_shadow(jme);
+	jme_start_irq(jme);
+
+	if (test_bit(JME_FLAG_SSET, &jme->flags))
+		jme_set_settings(netdev, &jme->old_ecmd);
+	else
+		jme_reset_phy_processor(jme);
+
+	jme_reset_link(jme);
+
+	return 0;
+
+err_out:
+	netif_stop_queue(netdev);
+	netif_carrier_off(netdev);
+	return rc;
+}
+
+static void
+jme_set_100m_half(struct jme_adapter *jme)
+{
+	__u32 bmcr, tmp;
+
+	bmcr = jme_mdio_read(jme->dev, jme->mii_if.phy_id, MII_BMCR);
+	tmp = bmcr & ~(BMCR_ANENABLE | BMCR_SPEED100 |
+		       BMCR_SPEED1000 | BMCR_FULLDPLX);
+	tmp |= BMCR_SPEED100;
+
+	if (bmcr != tmp)
+		jme_mdio_write(jme->dev, jme->mii_if.phy_id, MII_BMCR, tmp);
+
+	if (jme->fpgaver)
+		jwrite32(jme, JME_GHC, GHC_SPEED_100M | GHC_LINK_POLL);
+	else
+		jwrite32(jme, JME_GHC, GHC_SPEED_100M);
+}
+
+#define JME_WAIT_LINK_TIME 2000 /* 2000ms */
+static void
+jme_wait_link(struct jme_adapter *jme)
+{
+	__u32 phylink, to = JME_WAIT_LINK_TIME;
+
+	mdelay(1000);
+	phylink = jme_linkstat_from_phy(jme);
+	while (!(phylink & PHY_LINK_UP) && (to -= 10) > 0) {
+		mdelay(10);
+		phylink = jme_linkstat_from_phy(jme);
+	}
+}
+
+static inline void
+jme_phy_off(struct jme_adapter *jme)
+{
+	jme_mdio_write(jme->dev, jme->mii_if.phy_id, MII_BMCR, BMCR_PDOWN);
+}
+
+static int
+jme_close(struct net_device *netdev)
+{
+	struct jme_adapter *jme = netdev_priv(netdev);
+
+	netif_stop_queue(netdev);
+	netif_carrier_off(netdev);
+
+	jme_stop_irq(jme);
+	jme_disable_shadow(jme);
+	jme_free_irq(jme);
+
+	JME_NAPI_DISABLE(jme);
+
+	tasklet_kill(&jme->linkch_task);
+	tasklet_kill(&jme->txclean_task);
+	tasklet_kill(&jme->rxclean_task);
+	tasklet_kill(&jme->rxempty_task);
+
+	jme_reset_mac_processor(jme);
+	jme_free_rx_resources(jme);
+	jme_free_tx_resources(jme);
+	jme->phylink = 0;
+	jme_phy_off(jme);
+
+	return 0;
+}
+
+static int
+jme_alloc_txdesc(struct jme_adapter *jme,
+			struct sk_buff *skb)
+{
+	struct jme_ring *txring = jme->txring;
+	int idx, nr_alloc, mask = jme->tx_ring_mask;
+
+	idx = txring->next_to_use;
+	nr_alloc = skb_shinfo(skb)->nr_frags + 2;
+
+	if (unlikely(atomic_read(&txring->nr_free) < nr_alloc))
+		return -1;
+
+	atomic_sub(nr_alloc, &txring->nr_free);
+
+	txring->next_to_use = (txring->next_to_use + nr_alloc) & mask;
+
+	return idx;
+}
+
+static void
+jme_fill_tx_map(struct pci_dev *pdev,
+		struct txdesc *txdesc,
+		struct jme_buffer_info *txbi,
+		struct page *page,
+		__u32 page_offset,
+		__u32 len,
+		__u8 hidma)
+{
+	dma_addr_t dmaaddr;
+
+	dmaaddr = pci_map_page(pdev,
+				page,
+				page_offset,
+				len,
+				PCI_DMA_TODEVICE);
+
+	pci_dma_sync_single_for_device(pdev,
+				       dmaaddr,
+				       len,
+				       PCI_DMA_TODEVICE);
+
+	txdesc->dw[0] = 0;
+	txdesc->dw[1] = 0;
+	txdesc->desc2.flags	= TXFLAG_OWN;
+	txdesc->desc2.flags	|= (hidma) ? TXFLAG_64BIT : 0;
+	txdesc->desc2.datalen	= cpu_to_le16(len);
+	txdesc->desc2.bufaddrh	= cpu_to_le32((__u64)dmaaddr >> 32);
+	txdesc->desc2.bufaddrl	= cpu_to_le32(
+					(__u64)dmaaddr & 0xFFFFFFFFUL);
+
+	txbi->mapping = dmaaddr;
+	txbi->len = len;
+}
+
+static void
+jme_map_tx_skb(struct jme_adapter *jme, struct sk_buff *skb, int idx)
+{
+	struct jme_ring *txring = jme->txring;
+	struct txdesc *txdesc = txring->desc, *ctxdesc;
+	struct jme_buffer_info *txbi = txring->bufinf, *ctxbi;
+	__u8 hidma = jme->dev->features & NETIF_F_HIGHDMA;
+	int i, nr_frags = skb_shinfo(skb)->nr_frags;
+	int mask = jme->tx_ring_mask;
+	struct skb_frag_struct *frag;
+	__u32 len;
+
+	for (i = 0 ; i < nr_frags ; ++i) {
+		frag = &skb_shinfo(skb)->frags[i];
+		ctxdesc = txdesc + ((idx + i + 2) & (mask));
+		ctxbi = txbi + ((idx + i + 2) & (mask));
+
+		jme_fill_tx_map(jme->pdev, ctxdesc, ctxbi, frag->page,
+				 frag->page_offset, frag->size, hidma);
+	}
+
+	len = skb_is_nonlinear(skb) ? skb_headlen(skb) : skb->len;
+	ctxdesc = txdesc + ((idx + 1) & (mask));
+	ctxbi = txbi + ((idx + 1) & (mask));
+	jme_fill_tx_map(jme->pdev, ctxdesc, ctxbi, virt_to_page(skb->data),
+			offset_in_page(skb->data), len, hidma);
+
+}
+
+static int
+jme_expand_header(struct jme_adapter *jme, struct sk_buff *skb)
+{
+	if (unlikely(skb_shinfo(skb)->gso_size &&
+			skb_header_cloned(skb) &&
+			pskb_expand_head(skb, 0, 0, GFP_ATOMIC))) {
+		dev_kfree_skb(skb);
+		return -1;
+	}
+
+	return 0;
+}
+
+static int
+jme_tx_tso(struct sk_buff *skb,
+		__u16 *mss, __u8 *flags)
+{
+	*mss = skb_shinfo(skb)->gso_size << TXDESC_MSS_SHIFT;
+	if (*mss) {
+		*flags |= TXFLAG_LSEN;
+
+		if (skb->protocol == htons(ETH_P_IP)) {
+			struct iphdr *iph = ip_hdr(skb);
+
+			iph->check = 0;
+			tcp_hdr(skb)->check = ~csum_tcpudp_magic(iph->saddr,
+								iph->daddr, 0,
+								IPPROTO_TCP,
+								0);
+		} else {
+			struct ipv6hdr *ip6h = ipv6_hdr(skb);
+
+			tcp_hdr(skb)->check = ~csum_ipv6_magic(&ip6h->saddr,
+								&ip6h->daddr, 0,
+								IPPROTO_TCP,
+								0);
+		}
+
+		return 0;
+	}
+
+	return 1;
+}
+
+static void
+jme_tx_csum(struct jme_adapter *jme, struct sk_buff *skb, __u8 *flags)
+{
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
+		__u8 ip_proto;
+
+		switch (skb->protocol) {
+		case htons(ETH_P_IP):
+			ip_proto = ip_hdr(skb)->protocol;
+			break;
+		case htons(ETH_P_IPV6):
+			ip_proto = ipv6_hdr(skb)->nexthdr;
+			break;
+		default:
+			ip_proto = 0;
+			break;
+		}
+
+		switch (ip_proto) {
+		case IPPROTO_TCP:
+			*flags |= TXFLAG_TCPCS;
+			break;
+		case IPPROTO_UDP:
+			*flags |= TXFLAG_UDPCS;
+			break;
+		default:
+			msg_tx_err(jme, "Error upper layer protocol.\n");
+			break;
+		}
+	}
+}
+
+static inline void
+jme_tx_vlan(struct sk_buff *skb, __u16 *vlan, __u8 *flags)
+{
+	if (vlan_tx_tag_present(skb)) {
+		*flags |= TXFLAG_TAGON;
+		*vlan = vlan_tx_tag_get(skb);
+	}
+}
+
+static int
+jme_fill_first_tx_desc(struct jme_adapter *jme, struct sk_buff *skb, int idx)
+{
+	struct jme_ring *txring = jme->txring;
+	struct txdesc *txdesc;
+	struct jme_buffer_info *txbi;
+	__u8 flags;
+
+	txdesc = (struct txdesc *)txring->desc + idx;
+	txbi = txring->bufinf + idx;
+
+	txdesc->dw[0] = 0;
+	txdesc->dw[1] = 0;
+	txdesc->dw[2] = 0;
+	txdesc->dw[3] = 0;
+	txdesc->desc1.pktsize = cpu_to_le16(skb->len);
+	/*
+	 * Set OWN bit at final.
+	 * When kernel transmit faster than NIC.
+	 * And NIC trying to send this descriptor before we tell
+	 * it to start sending this TX queue.
+	 * Other fields are already filled correctly.
+	 */
+	wmb();
+	flags = TXFLAG_OWN | TXFLAG_INT;
+	/*
+	 * Set checksum flags while not tso
+	 */
+	if (jme_tx_tso(skb, &txdesc->desc1.mss, &flags))
+		jme_tx_csum(jme, skb, &flags);
+	jme_tx_vlan(skb, &txdesc->desc1.vlan, &flags);
+	txdesc->desc1.flags = flags;
+	/*
+	 * Set tx buffer info after telling NIC to send
+	 * For better tx_clean timing
+	 */
+	wmb();
+	txbi->nr_desc = skb_shinfo(skb)->nr_frags + 2;
+	txbi->skb = skb;
+	txbi->len = skb->len;
+	txbi->start_xmit = jiffies;
+	if (!txbi->start_xmit)
+		txbi->start_xmit = (0UL-1);
+
+	return 0;
+}
+
+static void
+jme_stop_queue_if_full(struct jme_adapter *jme)
+{
+	struct jme_ring *txring = jme->txring;
+	struct jme_buffer_info *txbi = txring->bufinf;
+
+	txbi += atomic_read(&txring->next_to_clean);
+
+	smp_wmb();
+	if (unlikely(atomic_read(&txring->nr_free) < (MAX_SKB_FRAGS+2))) {
+		netif_stop_queue(jme->dev);
+		msg_tx_queued(jme, "TX Queue Paused.\n");
+		smp_wmb();
+		if (atomic_read(&txring->nr_free)
+			>= (jme->tx_wake_threshold)) {
+			netif_wake_queue(jme->dev);
+			msg_tx_queued(jme, "TX Queue Fast Waked.\n");
+		}
+	}
+
+	if (unlikely(txbi->start_xmit &&
+			(jiffies - txbi->start_xmit) >= TX_TIMEOUT &&
+			txbi->skb)) {
+		netif_stop_queue(jme->dev);
+		msg_tx_queued(jme, "TX Queue Stopped @(%lu).\n", jiffies);
+	}
+}
+
+/*
+ * This function is already protected by netif_tx_lock()
+ */
+
+static int
+jme_start_xmit(struct sk_buff *skb, struct net_device *netdev)
+{
+	struct jme_adapter *jme = netdev_priv(netdev);
+	int idx;
+
+	if (unlikely(jme_expand_header(jme, skb))) {
+		++(NET_STAT(jme).tx_dropped);
+		return NETDEV_TX_OK;
+	}
+
+	idx = jme_alloc_txdesc(jme, skb);
+
+	if (unlikely(idx < 0)) {
+		netif_stop_queue(netdev);
+		msg_tx_err(jme, "BUG! Tx ring full when queue awake!\n");
+
+		return NETDEV_TX_BUSY;
+	}
+
+	jme_map_tx_skb(jme, skb, idx);
+	jme_fill_first_tx_desc(jme, skb, idx);
+
+	jwrite32(jme, JME_TXCS, jme->reg_txcs |
+				TXCS_SELECT_QUEUE0 |
+				TXCS_QUEUE0S |
+				TXCS_ENABLE);
+	netdev->trans_start = jiffies;
+
+	jme_stop_queue_if_full(jme);
+
+	return NETDEV_TX_OK;
+}
+
+static int
+jme_set_macaddr(struct net_device *netdev, void *p)
+{
+	struct jme_adapter *jme = netdev_priv(netdev);
+	struct sockaddr *addr = p;
+	__u32 val;
+
+	if (netif_running(netdev))
+		return -EBUSY;
+
+	spin_lock_bh(&jme->macaddr_lock);
+	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
+
+	val = (addr->sa_data[3] & 0xff) << 24 |
+	      (addr->sa_data[2] & 0xff) << 16 |
+	      (addr->sa_data[1] & 0xff) <<  8 |
+	      (addr->sa_data[0] & 0xff);
+	jwrite32(jme, JME_RXUMA_LO, val);
+	val = (addr->sa_data[5] & 0xff) << 8 |
+	      (addr->sa_data[4] & 0xff);
+	jwrite32(jme, JME_RXUMA_HI, val);
+	spin_unlock_bh(&jme->macaddr_lock);
+
+	return 0;
+}
+
+static void
+jme_set_multi(struct net_device *netdev)
+{
+	struct jme_adapter *jme = netdev_priv(netdev);
+	u32 mc_hash[2] = {};
+	int i;
+
+	spin_lock_bh(&jme->rxmcs_lock);
+
+	jme->reg_rxmcs |= RXMCS_BRDFRAME | RXMCS_UNIFRAME;
+
+	if (netdev->flags & IFF_PROMISC) {
+		jme->reg_rxmcs |= RXMCS_ALLFRAME;
+	} else if (netdev->flags & IFF_ALLMULTI) {
+		jme->reg_rxmcs |= RXMCS_ALLMULFRAME;
+	} else if (netdev->flags & IFF_MULTICAST) {
+		struct dev_mc_list *mclist;
+		int bit_nr;
+
+		jme->reg_rxmcs |= RXMCS_MULFRAME | RXMCS_MULFILTERED;
+		for (i = 0, mclist = netdev->mc_list;
+			mclist && i < netdev->mc_count;
+			++i, mclist = mclist->next) {
+
+			bit_nr = ether_crc(ETH_ALEN, mclist->dmi_addr) & 0x3F;
+			mc_hash[bit_nr >> 5] |= 1 << (bit_nr & 0x1F);
+		}
+
+		jwrite32(jme, JME_RXMCHT_LO, mc_hash[0]);
+		jwrite32(jme, JME_RXMCHT_HI, mc_hash[1]);
+	}
+
+	wmb();
+	jwrite32(jme, JME_RXMCS, jme->reg_rxmcs);
+
+	spin_unlock_bh(&jme->rxmcs_lock);
+}
+
+static int
+jme_change_mtu(struct net_device *netdev, int new_mtu)
+{
+	struct jme_adapter *jme = netdev_priv(netdev);
+
+	if (new_mtu == jme->old_mtu)
+		return 0;
+
+	if (((new_mtu + ETH_HLEN) > MAX_ETHERNET_JUMBO_PACKET_SIZE) ||
+		((new_mtu) < IPV6_MIN_MTU))
+		return -EINVAL;
+
+	if (new_mtu > 4000) {
+		jme->reg_rxcs &= ~RXCS_FIFOTHNP;
+		jme->reg_rxcs |= RXCS_FIFOTHNP_64QW;
+		jme_restart_rx_engine(jme);
+	} else {
+		jme->reg_rxcs &= ~RXCS_FIFOTHNP;
+		jme->reg_rxcs |= RXCS_FIFOTHNP_128QW;
+		jme_restart_rx_engine(jme);
+	}
+
+	if (new_mtu > 1900) {
+		netdev->features &= ~(NETIF_F_HW_CSUM |
+				NETIF_F_TSO |
+				NETIF_F_TSO6);
+	} else {
+		if (test_bit(JME_FLAG_TXCSUM, &jme->flags))
+			netdev->features |= NETIF_F_HW_CSUM;
+		if (test_bit(JME_FLAG_TSO, &jme->flags))
+			netdev->features |= NETIF_F_TSO | NETIF_F_TSO6;
+	}
+
+	netdev->mtu = new_mtu;
+	jme_reset_link(jme);
+
+	return 0;
+}
+
+static int
+jme_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
+{
+	struct jme_adapter *jme = netdev_priv(netdev);
+	struct jme_spi_op spiop;
+	int rc;
+
+	switch (cmd) {
+	case JMESPIIOCTL:
+		copy_from_user(&spiop, ifr->ifr_data,
+				sizeof(struct jme_spi_op));
+		spiop.kwbuf = kmalloc(spiop.wn, GFP_KERNEL);
+		if (!spiop.kwbuf) {
+			rc = -ENOMEM;
+			goto out;
+		}
+		spiop.krbuf = kmalloc(spiop.rn, GFP_KERNEL);
+		if (!spiop.krbuf) {
+			rc = -ENOMEM;
+			goto out_free1;
+		}
+		copy_from_user(spiop.kwbuf, spiop.uwbuf, spiop.wn);
+		rc = jme_spi_op(jme, &spiop);
+		if (rc)
+			goto out_free;
+		copy_to_user(spiop.urbuf, spiop.krbuf, spiop.rn);
+out_free:
+		kfree(spiop.krbuf);
+out_free1:
+		kfree(spiop.kwbuf);
+out:
+		return rc;
+	default:
+		break;
+	}
+
+	return -EOPNOTSUPP;
+}
+
+
+static void
+jme_tx_timeout(struct net_device *netdev)
+{
+	struct jme_adapter *jme = netdev_priv(netdev);
+
+	jme->phylink = 0;
+	jme_reset_phy_processor(jme);
+	if (test_bit(JME_FLAG_SSET, &jme->flags))
+		jme_set_settings(netdev, &jme->old_ecmd);
+
+	/*
+	 * Force to Reset the link again
+	 */
+	jme_reset_link(jme);
+}
+
+static void
+jme_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp)
+{
+	struct jme_adapter *jme = netdev_priv(netdev);
+
+	jme->vlgrp = grp;
+}
+
+static void
+jme_get_drvinfo(struct net_device *netdev,
+		     struct ethtool_drvinfo *info)
+{
+	struct jme_adapter *jme = netdev_priv(netdev);
+
+	strcpy(info->driver, DRV_NAME);
+	strcpy(info->version, DRV_VERSION);
+	strcpy(info->bus_info, pci_name(jme->pdev));
+}
+
+static int
+jme_get_regs_len(struct net_device *netdev)
+{
+	return JME_REG_LEN;
+}
+
+static void
+mmapio_memcpy(struct jme_adapter *jme, __u32 *p, __u32 reg, int len)
+{
+	int i;
+
+	for (i = 0 ; i < len ; i += 4)
+		p[i >> 2] = jread32(jme, reg + i);
+}
+
+static void
+mdio_memcpy(struct jme_adapter *jme, __u32 *p, int reg_nr)
+{
+	int i;
+	__u16 *p16 = (__u16 *)p;
+
+	for (i = 0 ; i < reg_nr ; ++i)
+		p16[i] = jme_mdio_read(jme->dev, jme->mii_if.phy_id, i);
+}
+
+static void
+jme_get_regs(struct net_device *netdev, struct ethtool_regs *regs, void *p)
+{
+	struct jme_adapter *jme = netdev_priv(netdev);
+	__u32 *p32 = (__u32 *)p;
+
+	memset(p, 0xFF, JME_REG_LEN);
+
+	regs->version = 1;
+	mmapio_memcpy(jme, p32, JME_MAC, JME_MAC_LEN);
+
+	p32 += 0x100 >> 2;
+	mmapio_memcpy(jme, p32, JME_PHY, JME_PHY_LEN);
+
+	p32 += 0x100 >> 2;
+	mmapio_memcpy(jme, p32, JME_MISC, JME_MISC_LEN);
+
+	p32 += 0x100 >> 2;
+	mmapio_memcpy(jme, p32, JME_RSS, JME_RSS_LEN);
+
+	p32 += 0x100 >> 2;
+	mdio_memcpy(jme, p32, JME_PHY_REG_NR);
+}
+
+static int
+jme_get_coalesce(struct net_device *netdev, struct ethtool_coalesce *ecmd)
+{
+	struct jme_adapter *jme = netdev_priv(netdev);
+
+	ecmd->tx_coalesce_usecs = PCC_TX_TO;
+	ecmd->tx_max_coalesced_frames = PCC_TX_CNT;
+
+	if (test_bit(JME_FLAG_POLL, &jme->flags)) {
+		ecmd->use_adaptive_rx_coalesce = false;
+		ecmd->rx_coalesce_usecs = 0;
+		ecmd->rx_max_coalesced_frames = 0;
+		return 0;
+	}
+
+	ecmd->use_adaptive_rx_coalesce = true;
+
+	switch (jme->dpi.cur) {
+	case PCC_P1:
+		ecmd->rx_coalesce_usecs = PCC_P1_TO;
+		ecmd->rx_max_coalesced_frames = PCC_P1_CNT;
+		break;
+	case PCC_P2:
+		ecmd->rx_coalesce_usecs = PCC_P2_TO;
+		ecmd->rx_max_coalesced_frames = PCC_P2_CNT;
+		break;
+	case PCC_P3:
+		ecmd->rx_coalesce_usecs = PCC_P3_TO;
+		ecmd->rx_max_coalesced_frames = PCC_P3_CNT;
+		break;
+	default:
+		break;
+	}
+
+	return 0;
+}
+
+static int
+jme_set_coalesce(struct net_device *netdev, struct ethtool_coalesce *ecmd)
+{
+	struct jme_adapter *jme = netdev_priv(netdev);
+	struct dynpcc_info *dpi = &(jme->dpi);
+
+	if (netif_running(netdev))
+		return -EBUSY;
+
+	if (ecmd->use_adaptive_rx_coalesce
+	&& test_bit(JME_FLAG_POLL, &jme->flags)) {
+		clear_bit(JME_FLAG_POLL, &jme->flags);
+		jme->jme_rx = netif_rx;
+		jme->jme_vlan_rx = vlan_hwaccel_rx;
+		dpi->cur		= PCC_P1;
+		dpi->attempt		= PCC_P1;
+		dpi->cnt		= 0;
+		jme_set_rx_pcc(jme, PCC_P1);
+		jme_interrupt_mode(jme);
+	} else if (!(ecmd->use_adaptive_rx_coalesce)
+	&& !(test_bit(JME_FLAG_POLL, &jme->flags))) {
+		set_bit(JME_FLAG_POLL, &jme->flags);
+		jme->jme_rx = netif_receive_skb;
+		jme->jme_vlan_rx = vlan_hwaccel_receive_skb;
+		jme_interrupt_mode(jme);
+	}
+
+	return 0;
+}
+
+static void
+jme_get_pauseparam(struct net_device *netdev,
+			struct ethtool_pauseparam *ecmd)
+{
+	struct jme_adapter *jme = netdev_priv(netdev);
+	__u32 val;
+
+	ecmd->tx_pause = (jme->reg_txpfc & TXPFC_PF_EN) != 0;
+	ecmd->rx_pause = (jme->reg_rxmcs & RXMCS_FLOWCTRL) != 0;
+
+	spin_lock_bh(&jme->phy_lock);
+	val = jme_mdio_read(jme->dev, jme->mii_if.phy_id, MII_ADVERTISE);
+	spin_unlock_bh(&jme->phy_lock);
+
+	ecmd->autoneg =
+		(val & (ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM)) != 0;
+}
+
+static int
+jme_set_pauseparam(struct net_device *netdev,
+			struct ethtool_pauseparam *ecmd)
+{
+	struct jme_adapter *jme = netdev_priv(netdev);
+	__u32 val;
+
+	if (((jme->reg_txpfc & TXPFC_PF_EN) != 0) ^
+		(ecmd->tx_pause != 0)) {
+
+		if (ecmd->tx_pause)
+			jme->reg_txpfc |= TXPFC_PF_EN;
+		else
+			jme->reg_txpfc &= ~TXPFC_PF_EN;
+
+		jwrite32(jme, JME_TXPFC, jme->reg_txpfc);
+	}
+
+	spin_lock_bh(&jme->rxmcs_lock);
+	if (((jme->reg_rxmcs & RXMCS_FLOWCTRL) != 0) ^
+		(ecmd->rx_pause != 0)) {
+
+		if (ecmd->rx_pause)
+			jme->reg_rxmcs |= RXMCS_FLOWCTRL;
+		else
+			jme->reg_rxmcs &= ~RXMCS_FLOWCTRL;
+
+		jwrite32(jme, JME_RXMCS, jme->reg_rxmcs);
+	}
+	spin_unlock_bh(&jme->rxmcs_lock);
+
+	spin_lock_bh(&jme->phy_lock);
+	val = jme_mdio_read(jme->dev, jme->mii_if.phy_id, MII_ADVERTISE);
+	if (((val & (ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM)) != 0) ^
+		(ecmd->autoneg != 0)) {
+
+		if (ecmd->autoneg)
+			val |= (ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM);
+		else
+			val &= ~(ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM);
+
+		jme_mdio_write(jme->dev, jme->mii_if.phy_id,
+				MII_ADVERTISE, val);
+	}
+	spin_unlock_bh(&jme->phy_lock);
+
+	return 0;
+}
+
+static void
+jme_get_wol(struct net_device *netdev,
+		struct ethtool_wolinfo *wol)
+{
+	struct jme_adapter *jme = netdev_priv(netdev);
+
+	wol->supported = WAKE_MAGIC | WAKE_PHY;
+
+	wol->wolopts = 0;
+
+	if (jme->reg_pmcs & (PMCS_LFEN | PMCS_LREN))
+		wol->wolopts |= WAKE_PHY;
+
+	if (jme->reg_pmcs & PMCS_MFEN)
+		wol->wolopts |= WAKE_MAGIC;
+
+}
+
+static int
+jme_set_wol(struct net_device *netdev,
+		struct ethtool_wolinfo *wol)
+{
+	struct jme_adapter *jme = netdev_priv(netdev);
+
+	if (wol->wolopts & (WAKE_MAGICSECURE |
+				WAKE_UCAST |
+				WAKE_MCAST |
+				WAKE_BCAST |
+				WAKE_ARP))
+		return -EOPNOTSUPP;
+
+	jme->reg_pmcs = 0;
+
+	if (wol->wolopts & WAKE_PHY)
+		jme->reg_pmcs |= PMCS_LFEN | PMCS_LREN;
+
+	if (wol->wolopts & WAKE_MAGIC)
+		jme->reg_pmcs |= PMCS_MFEN;
+
+
+	return 0;
+}
+
+static int
+jme_get_settings(struct net_device *netdev,
+		     struct ethtool_cmd *ecmd)
+{
+	struct jme_adapter *jme = netdev_priv(netdev);
+	int rc;
+
+	spin_lock_bh(&jme->phy_lock);
+	rc = mii_ethtool_gset(&(jme->mii_if), ecmd);
+	spin_unlock_bh(&jme->phy_lock);
+	return rc;
+}
+
+static int
+jme_set_settings(struct net_device *netdev,
+		     struct ethtool_cmd *ecmd)
+{
+	struct jme_adapter *jme = netdev_priv(netdev);
+	int rc, fdc = 0;
+
+	if (ecmd->speed == SPEED_1000 && ecmd->autoneg != AUTONEG_ENABLE)
+		return -EINVAL;
+
+	if (jme->mii_if.force_media &&
+	ecmd->autoneg != AUTONEG_ENABLE &&
+	(jme->mii_if.full_duplex != ecmd->duplex))
+		fdc = 1;
+
+	spin_lock_bh(&jme->phy_lock);
+	rc = mii_ethtool_sset(&(jme->mii_if), ecmd);
+	spin_unlock_bh(&jme->phy_lock);
+
+	if (!rc && fdc)
+		jme_reset_link(jme);
+
+	if (!rc) {
+		set_bit(JME_FLAG_SSET, &jme->flags);
+		jme->old_ecmd = *ecmd;
+	}
+
+	return rc;
+}
+
+static __u32
+jme_get_link(struct net_device *netdev)
+{
+	struct jme_adapter *jme = netdev_priv(netdev);
+	return jread32(jme, JME_PHY_LINK) & PHY_LINK_UP;
+}
+
+static __u32
+jme_get_msglevel(struct net_device *netdev)
+{
+	struct jme_adapter *jme = netdev_priv(netdev);
+	return jme->msg_enable;
+}
+
+static void
+jme_set_msglevel(struct net_device *netdev, u32 value)
+{
+	struct jme_adapter *jme = netdev_priv(netdev);
+	jme->msg_enable = value;
+}
+
+static u32
+jme_get_rx_csum(struct net_device *netdev)
+{
+	struct jme_adapter *jme = netdev_priv(netdev);
+	return jme->reg_rxmcs & RXMCS_CHECKSUM;
+}
+
+static int
+jme_set_rx_csum(struct net_device *netdev, u32 on)
+{
+	struct jme_adapter *jme = netdev_priv(netdev);
+
+	spin_lock_bh(&jme->rxmcs_lock);
+	if (on)
+		jme->reg_rxmcs |= RXMCS_CHECKSUM;
+	else
+		jme->reg_rxmcs &= ~RXMCS_CHECKSUM;
+	jwrite32(jme, JME_RXMCS, jme->reg_rxmcs);
+	spin_unlock_bh(&jme->rxmcs_lock);
+
+	return 0;
+}
+
+static int
+jme_set_tx_csum(struct net_device *netdev, u32 on)
+{
+	struct jme_adapter *jme = netdev_priv(netdev);
+
+	if (on) {
+		set_bit(JME_FLAG_TXCSUM, &jme->flags);
+		if (netdev->mtu <= 1900)
+			netdev->features |= NETIF_F_HW_CSUM;
+	} else {
+		clear_bit(JME_FLAG_TXCSUM, &jme->flags);
+		netdev->features &= ~NETIF_F_HW_CSUM;
+	}
+
+	return 0;
+}
+
+static int
+jme_set_tso(struct net_device *netdev, u32 on)
+{
+	struct jme_adapter *jme = netdev_priv(netdev);
+
+	if (on) {
+		set_bit(JME_FLAG_TSO, &jme->flags);
+		if (netdev->mtu <= 1900)
+			netdev->features |= NETIF_F_TSO | NETIF_F_TSO6;
+	} else {
+		clear_bit(JME_FLAG_TSO, &jme->flags);
+		netdev->features &= ~(NETIF_F_TSO | NETIF_F_TSO6);
+	}
+
+	return 0;
+}
+
+static int
+jme_nway_reset(struct net_device *netdev)
+{
+	struct jme_adapter *jme = netdev_priv(netdev);
+	jme_restart_an(jme);
+	return 0;
+}
+
+static __u8
+jme_smb_read(struct jme_adapter *jme, unsigned int addr)
+{
+	__u32 val;
+	int to;
+
+	val = jread32(jme, JME_SMBCSR);
+	to = JME_SMB_BUSY_TIMEOUT;
+	while ((val & SMBCSR_BUSY) && --to) {
+		msleep(1);
+		val = jread32(jme, JME_SMBCSR);
+	}
+	if (!to) {
+		msg_hw(jme, "SMB Bus Busy.\n");
+		return 0xFF;
+	}
+
+	jwrite32(jme, JME_SMBINTF,
+		((addr << SMBINTF_HWADDR_SHIFT) & SMBINTF_HWADDR) |
+		SMBINTF_HWRWN_READ |
+		SMBINTF_HWCMD);
+
+	val = jread32(jme, JME_SMBINTF);
+	to = JME_SMB_BUSY_TIMEOUT;
+	while ((val & SMBINTF_HWCMD) && --to) {
+		msleep(1);
+		val = jread32(jme, JME_SMBINTF);
+	}
+	if (!to) {
+		msg_hw(jme, "SMB Bus Busy.\n");
+		return 0xFF;
+	}
+
+	return (val & SMBINTF_HWDATR) >> SMBINTF_HWDATR_SHIFT;
+}
+
+static void
+jme_smb_write(struct jme_adapter *jme, unsigned int addr, __u8 data)
+{
+	__u32 val;
+	int to;
+
+	val = jread32(jme, JME_SMBCSR);
+	to = JME_SMB_BUSY_TIMEOUT;
+	while ((val & SMBCSR_BUSY) && --to) {
+		msleep(1);
+		val = jread32(jme, JME_SMBCSR);
+	}
+	if (!to) {
+		msg_hw(jme, "SMB Bus Busy.\n");
+		return;
+	}
+
+	jwrite32(jme, JME_SMBINTF,
+		((data << SMBINTF_HWDATW_SHIFT) & SMBINTF_HWDATW) |
+		((addr << SMBINTF_HWADDR_SHIFT) & SMBINTF_HWADDR) |
+		SMBINTF_HWRWN_WRITE |
+		SMBINTF_HWCMD);
+
+	val = jread32(jme, JME_SMBINTF);
+	to = JME_SMB_BUSY_TIMEOUT;
+	while ((val & SMBINTF_HWCMD) && --to) {
+		msleep(1);
+		val = jread32(jme, JME_SMBINTF);
+	}
+	if (!to) {
+		msg_hw(jme, "SMB Bus Busy.\n");
+		return;
+	}
+
+	mdelay(2);
+}
+
+static int
+jme_get_eeprom_len(struct net_device *netdev)
+{
+	struct jme_adapter *jme = netdev_priv(netdev);
+	__u32 val;
+	val = jread32(jme, JME_SMBCSR);
+	return (val & SMBCSR_EEPROMD) ? JME_SMB_LEN : 0;
+}
+
+static int
+jme_get_eeprom(struct net_device *netdev,
+		struct ethtool_eeprom *eeprom, u8 *data)
+{
+	struct jme_adapter *jme = netdev_priv(netdev);
+	int i, offset = eeprom->offset, len = eeprom->len;
+
+	/*
+	 * ethtool will check the boundary for us
+	 */
+	eeprom->magic = JME_EEPROM_MAGIC;
+	for (i = 0 ; i < len ; ++i)
+		data[i] = jme_smb_read(jme, i + offset);
+
+	return 0;
+}
+
+static int
+jme_set_eeprom(struct net_device *netdev,
+		struct ethtool_eeprom *eeprom, u8 *data)
+{
+	struct jme_adapter *jme = netdev_priv(netdev);
+	int i, offset = eeprom->offset, len = eeprom->len;
+
+	if (eeprom->magic != JME_EEPROM_MAGIC)
+		return -EINVAL;
+
+	/*
+	 * ethtool will check the boundary for us
+	 */
+	for (i = 0 ; i < len ; ++i)
+		jme_smb_write(jme, i + offset, data[i]);
+
+	return 0;
+}
+
+static const struct ethtool_ops jme_ethtool_ops = {
+	.get_drvinfo            = jme_get_drvinfo,
+	.get_regs_len		= jme_get_regs_len,
+	.get_regs		= jme_get_regs,
+	.get_coalesce		= jme_get_coalesce,
+	.set_coalesce		= jme_set_coalesce,
+	.get_pauseparam		= jme_get_pauseparam,
+	.set_pauseparam		= jme_set_pauseparam,
+	.get_wol		= jme_get_wol,
+	.set_wol		= jme_set_wol,
+	.get_settings		= jme_get_settings,
+	.set_settings		= jme_set_settings,
+	.get_link		= jme_get_link,
+	.get_msglevel           = jme_get_msglevel,
+	.set_msglevel           = jme_set_msglevel,
+	.get_rx_csum		= jme_get_rx_csum,
+	.set_rx_csum		= jme_set_rx_csum,
+	.set_tx_csum		= jme_set_tx_csum,
+	.set_tso		= jme_set_tso,
+	.set_sg			= ethtool_op_set_sg,
+	.nway_reset             = jme_nway_reset,
+	.get_eeprom_len		= jme_get_eeprom_len,
+	.get_eeprom		= jme_get_eeprom,
+	.set_eeprom		= jme_set_eeprom,
+};
+
+static int
+jme_pci_dma64(struct pci_dev *pdev)
+{
+	if (!pci_set_dma_mask(pdev, DMA_64BIT_MASK))
+		if (!pci_set_consistent_dma_mask(pdev, DMA_64BIT_MASK))
+			return 1;
+
+	if (!pci_set_dma_mask(pdev, DMA_40BIT_MASK))
+		if (!pci_set_consistent_dma_mask(pdev, DMA_40BIT_MASK))
+			return 1;
+
+	if (!pci_set_dma_mask(pdev, DMA_32BIT_MASK))
+		if (!pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK))
+			return 0;
+
+	return -1;
+}
+
+static inline void
+jme_phy_init(struct jme_adapter *jme)
+{
+	__u16 reg26;
+
+	reg26 = jme_mdio_read(jme->dev, jme->mii_if.phy_id, 26);
+	jme_mdio_write(jme->dev, jme->mii_if.phy_id, 26, reg26 | 0x1000);
+}
+
+static inline void
+jme_set_gmii(struct jme_adapter *jme)
+{
+	jme_mdio_write(jme->dev, jme->mii_if.phy_id, 27, 0x0004);
+}
+
+static inline void
+jme_check_hw_ver(struct jme_adapter *jme)
+{
+	__u32 chipmode;
+
+	chipmode = jread32(jme, JME_CHIPMODE);
+
+	jme->fpgaver = (chipmode & CM_FPGAVER_MASK) >> CM_FPGAVER_SHIFT;
+	jme->chipver = (chipmode & CM_CHIPVER_MASK) >> CM_CHIPVER_SHIFT;
+}
+
+static int __devinit
+jme_init_one(struct pci_dev *pdev,
+	     const struct pci_device_id *ent)
+{
+	int rc = 0, using_dac, i;
+	struct net_device *netdev;
+	struct jme_adapter *jme;
+	__u16 bmcr, bmsr;
+	__u32 apmc;
+
+	/*
+	 * set up PCI device basics
+	 */
+	rc = pci_enable_device(pdev);
+	if (rc) {
+		printk(KERN_ERR PFX "Cannot enable PCI device.\n");
+		goto err_out;
+	}
+
+	using_dac = jme_pci_dma64(pdev);
+	if (using_dac < 0) {
+		printk(KERN_ERR PFX "Cannot set PCI DMA Mask.\n");
+		rc = -EIO;
+		goto err_out_disable_pdev;
+	}
+
+	if (!(pci_resource_flags(pdev, 0) & IORESOURCE_MEM)) {
+		printk(KERN_ERR PFX "No PCI resource region found.\n");
+		rc = -ENOMEM;
+		goto err_out_disable_pdev;
+	}
+
+	rc = pci_request_regions(pdev, DRV_NAME);
+	if (rc) {
+		printk(KERN_ERR PFX "Cannot obtain PCI resource region.\n");
+		goto err_out_disable_pdev;
+	}
+
+	pci_set_master(pdev);
+
+	/*
+	 * alloc and init net device
+	 */
+	netdev = alloc_etherdev(sizeof(*jme));
+	if (!netdev) {
+		printk(KERN_ERR PFX "Cannot allocate netdev structure.\n");
+		rc = -ENOMEM;
+		goto err_out_release_regions;
+	}
+	netdev->open			= jme_open;
+	netdev->stop			= jme_close;
+	netdev->hard_start_xmit		= jme_start_xmit;
+	netdev->set_mac_address		= jme_set_macaddr;
+	netdev->set_multicast_list	= jme_set_multi;
+	netdev->change_mtu		= jme_change_mtu;
+	netdev->do_ioctl		= jme_ioctl;
+	netdev->ethtool_ops		= &jme_ethtool_ops;
+	netdev->tx_timeout		= jme_tx_timeout;
+	netdev->watchdog_timeo		= TX_TIMEOUT;
+	netdev->vlan_rx_register	= jme_vlan_rx_register;
+	NETDEV_GET_STATS(netdev, &jme_get_stats);
+	netdev->features		=	NETIF_F_HW_CSUM |
+						NETIF_F_SG |
+						NETIF_F_TSO |
+						NETIF_F_TSO6 |
+						NETIF_F_HW_VLAN_TX |
+						NETIF_F_HW_VLAN_RX;
+	if (using_dac)
+		netdev->features	|=	NETIF_F_HIGHDMA;
+
+	SET_NETDEV_DEV(netdev, &pdev->dev);
+	pci_set_drvdata(pdev, netdev);
+
+	/*
+	 * init adapter info
+	 */
+	jme = netdev_priv(netdev);
+	jme->pdev = pdev;
+	jme->dev = netdev;
+	jme->jme_rx = netif_rx;
+	jme->jme_vlan_rx = vlan_hwaccel_rx;
+	jme->old_mtu = netdev->mtu = 1500;
+	jme->phylink = 0;
+	jme->tx_ring_size = 1 << 10;
+	jme->tx_ring_mask = jme->tx_ring_size - 1;
+	jme->tx_wake_threshold = 1 << 9;
+	jme->rx_ring_size = 1 << 9;
+	jme->rx_ring_mask = jme->rx_ring_size - 1;
+	jme->msg_enable = JME_DEF_MSG_ENABLE;
+	jme->regs = ioremap(pci_resource_start(pdev, 0),
+			     pci_resource_len(pdev, 0));
+	if (!(jme->regs)) {
+		jeprintk(pdev, "Mapping PCI resource region error.\n");
+		rc = -ENOMEM;
+		goto err_out_free_netdev;
+	}
+	jme->shadow_regs = pci_alloc_consistent(pdev,
+						sizeof(__u32) * SHADOW_REG_NR,
+						&(jme->shadow_dma));
+	if (!(jme->shadow_regs)) {
+		jeprintk(pdev, "Allocating shadow register mapping error.\n");
+		rc = -ENOMEM;
+		goto err_out_unmap;
+	}
+
+	if (no_pseudohp) {
+		apmc = jread32(jme, JME_APMC) & ~JME_APMC_PSEUDO_HP_EN;
+		jwrite32(jme, JME_APMC, apmc);
+	} else if (force_pseudohp) {
+		apmc = jread32(jme, JME_APMC) | JME_APMC_PSEUDO_HP_EN;
+		jwrite32(jme, JME_APMC, apmc);
+	}
+
+	NETIF_NAPI_SET(netdev, &jme->napi, jme_poll, jme->rx_ring_size >> 2)
+
+	spin_lock_init(&jme->phy_lock);
+	spin_lock_init(&jme->macaddr_lock);
+	spin_lock_init(&jme->rxmcs_lock);
+
+	atomic_set(&jme->link_changing, 1);
+	atomic_set(&jme->rx_cleaning, 1);
+	atomic_set(&jme->tx_cleaning, 1);
+	atomic_set(&jme->rx_empty, 1);
+
+	tasklet_init(&jme->pcc_task,
+		     &jme_pcc_tasklet,
+		     (unsigned long) jme);
+	tasklet_init(&jme->linkch_task,
+		     &jme_link_change_tasklet,
+		     (unsigned long) jme);
+	tasklet_init(&jme->txclean_task,
+		     &jme_tx_clean_tasklet,
+		     (unsigned long) jme);
+	tasklet_init(&jme->rxclean_task,
+		     &jme_rx_clean_tasklet,
+		     (unsigned long) jme);
+	tasklet_init(&jme->rxempty_task,
+		     &jme_rx_empty_tasklet,
+		     (unsigned long) jme);
+	jme->dpi.cur = PCC_P1;
+
+	if (pdev->device == PCI_DEVICE_ID_JMICRON_JMC250)
+		jme->reg_ghc = GHC_DPX | GHC_SPEED_1000M;
+	else
+		jme->reg_ghc = GHC_DPX | GHC_SPEED_100M;
+	jme->reg_rxcs = RXCS_DEFAULT;
+	jme->reg_rxmcs = RXMCS_DEFAULT;
+	jme->reg_txpfc = 0;
+	jme->reg_pmcs = PMCS_MFEN;
+	set_bit(JME_FLAG_TXCSUM, &jme->flags);
+	set_bit(JME_FLAG_TSO, &jme->flags);
+
+	/*
+	 * Get Max Read Req Size from PCI Config Space
+	 */
+	pci_read_config_byte(pdev, PCI_DCSR_MRRS, &jme->mrrs);
+	jme->mrrs &= PCI_DCSR_MRRS_MASK;
+	switch (jme->mrrs) {
+	case MRRS_128B:
+		jme->reg_txcs = TXCS_DEFAULT | TXCS_DMASIZE_128B;
+		break;
+	case MRRS_256B:
+		jme->reg_txcs = TXCS_DEFAULT | TXCS_DMASIZE_256B;
+		break;
+	default:
+		jme->reg_txcs = TXCS_DEFAULT | TXCS_DMASIZE_512B;
+		break;
+	};
+
+
+	/*
+	 * Must check before reset_mac_processor
+	 */
+	jme_check_hw_ver(jme);
+	jme->mii_if.dev = netdev;
+	if (jme->fpgaver) {
+		jme->mii_if.phy_id = 0;
+		for (i = 1 ; i < 32 ; ++i) {
+			bmcr = jme_mdio_read(netdev, i, MII_BMCR);
+			bmsr = jme_mdio_read(netdev, i, MII_BMSR);
+			if (bmcr != 0xFFFFU && (bmcr != 0 || bmsr != 0)) {
+				jme->mii_if.phy_id = i;
+				break;
+			}
+		}
+
+		if (!jme->mii_if.phy_id) {
+			rc = -EIO;
+			jeprintk(pdev, "Can not find phy_id.\n");
+			 goto err_out_free_shadow;
+		}
+
+		jme->reg_ghc |= GHC_LINK_POLL;
+	} else {
+		jme->mii_if.phy_id = 1;
+	}
+	if (pdev->device == PCI_DEVICE_ID_JMICRON_JMC250)
+		jme->mii_if.supports_gmii = true;
+	else
+		jme->mii_if.supports_gmii = false;
+	jme->mii_if.mdio_read = jme_mdio_read;
+	jme->mii_if.mdio_write = jme_mdio_write;
+
+	jme_clear_pm(jme);
+	if (jme->fpgaver)
+		jme_set_gmii(jme);
+	else
+		jme_phy_init(jme);
+	jme_phy_off(jme);
+
+	/*
+	 * Reset MAC processor and reload EEPROM for MAC Address
+	 */
+	jme_reset_mac_processor(jme);
+	rc = jme_reload_eeprom(jme);
+	if (rc) {
+		jeprintk(pdev,
+			"Reload eeprom for reading MAC Address error.\n");
+		goto err_out_free_shadow;
+	}
+	jme_load_macaddr(netdev);
+
+
+	/*
+	 * Tell stack that we are not ready to work until open()
+	 */
+	netif_carrier_off(netdev);
+	netif_stop_queue(netdev);
+
+	/*
+	 * Register netdev
+	 */
+	rc = register_netdev(netdev);
+	if (rc) {
+		jeprintk(pdev, "Cannot register net device.\n");
+		goto err_out_free_shadow;
+	}
+
+	msg_probe(jme,
+		"JMC250 gigabit%s ver:%u "
+		"macaddr:%02x:%02x:%02x:%02x:%02x:%02x\n",
+		(jme->fpgaver != 0) ? " (FPGA)" : "",
+		(jme->fpgaver != 0) ? jme->fpgaver : jme->chipver,
+		netdev->dev_addr[0],
+		netdev->dev_addr[1],
+		netdev->dev_addr[2],
+		netdev->dev_addr[3],
+		netdev->dev_addr[4],
+		netdev->dev_addr[5]);
+
+	return 0;
+
+err_out_free_shadow:
+	pci_free_consistent(pdev,
+			    sizeof(__u32) * SHADOW_REG_NR,
+			    jme->shadow_regs,
+			    jme->shadow_dma);
+err_out_unmap:
+	iounmap(jme->regs);
+err_out_free_netdev:
+	pci_set_drvdata(pdev, NULL);
+	free_netdev(netdev);
+err_out_release_regions:
+	pci_release_regions(pdev);
+err_out_disable_pdev:
+	pci_disable_device(pdev);
+err_out:
+	return rc;
+}
+
+static void __devexit
+jme_remove_one(struct pci_dev *pdev)
+{
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct jme_adapter *jme = netdev_priv(netdev);
+
+	unregister_netdev(netdev);
+	pci_free_consistent(pdev,
+			    sizeof(__u32) * SHADOW_REG_NR,
+			    jme->shadow_regs,
+			    jme->shadow_dma);
+	iounmap(jme->regs);
+	pci_set_drvdata(pdev, NULL);
+	free_netdev(netdev);
+	pci_release_regions(pdev);
+	pci_disable_device(pdev);
+
+}
+
+static int
+jme_suspend(struct pci_dev *pdev, pm_message_t state)
+{
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct jme_adapter *jme = netdev_priv(netdev);
+	int timeout = 100;
+
+	atomic_dec(&jme->link_changing);
+
+	netif_device_detach(netdev);
+	netif_stop_queue(netdev);
+	jme_stop_irq(jme);
+
+	while (--timeout > 0 &&
+	(
+		atomic_read(&jme->rx_cleaning) != 1 ||
+		atomic_read(&jme->tx_cleaning) != 1
+	)) {
+		mdelay(1);
+	}
+	if (!timeout) {
+		jeprintk(pdev, "Waiting tasklets timeout.\n");
+		return -EBUSY;
+	}
+	jme_disable_shadow(jme);
+
+	if (netif_carrier_ok(netdev)) {
+		if (test_bit(JME_FLAG_POLL, &jme->flags))
+			jme_polling_mode(jme);
+
+		jme_stop_pcc_timer(jme);
+		jme_reset_mac_processor(jme);
+		jme_free_rx_resources(jme);
+		jme_free_tx_resources(jme);
+		netif_carrier_off(netdev);
+		jme->phylink = 0;
+	}
+
+
+	pci_save_state(pdev);
+	if (jme->reg_pmcs) {
+		jme_set_100m_half(jme);
+
+		if (jme->reg_pmcs & (PMCS_LFEN | PMCS_LREN))
+			jme_wait_link(jme);
+
+		jwrite32(jme, JME_PMCS, jme->reg_pmcs);
+
+		pci_enable_wake(pdev, PCI_D3cold, true);
+	} else {
+		jme_phy_off(jme);
+	}
+	pci_set_power_state(pdev, PCI_D3cold);
+
+	return 0;
+}
+
+static int
+jme_resume(struct pci_dev *pdev)
+{
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct jme_adapter *jme = netdev_priv(netdev);
+
+	jme_clear_pm(jme);
+	pci_restore_state(pdev);
+
+	if (test_bit(JME_FLAG_SSET, &jme->flags))
+		jme_set_settings(netdev, &jme->old_ecmd);
+	else
+		jme_reset_phy_processor(jme);
+
+	jme_reset_mac_processor(jme);
+	jme_enable_shadow(jme);
+	jme_start_irq(jme);
+	netif_device_attach(netdev);
+
+	atomic_inc(&jme->link_changing);
+
+	jme_reset_link(jme);
+
+	return 0;
+}
+
+static struct pci_device_id jme_pci_tbl[] = {
+	{ PCI_VDEVICE(JMICRON, PCI_DEVICE_ID_JMICRON_JMC250) },
+	{ PCI_VDEVICE(JMICRON, PCI_DEVICE_ID_JMICRON_JMC260) },
+	{ }
+};
+
+static struct pci_driver jme_driver = {
+	.name           = DRV_NAME,
+	.id_table       = jme_pci_tbl,
+	.probe          = jme_init_one,
+	.remove         = __devexit_p(jme_remove_one),
+#ifdef CONFIG_PM
+	.suspend        = jme_suspend,
+	.resume         = jme_resume,
+#endif /* CONFIG_PM */
+};
+
+static int __init
+jme_init_module(void)
+{
+	printk(KERN_INFO PFX "JMicron JMC250 gigabit ethernet "
+	       "driver version %s\n", DRV_VERSION);
+	return pci_register_driver(&jme_driver);
+}
+
+static void __exit
+jme_cleanup_module(void)
+{
+	pci_unregister_driver(&jme_driver);
+}
+
+module_init(jme_init_module);
+module_exit(jme_cleanup_module);
+
+MODULE_AUTHOR("Guo-Fu Tseng <cooldavid@cooldavid.org>");
+MODULE_DESCRIPTION("JMicron JMC2x0 PCI Express Ethernet driver");
+MODULE_LICENSE("GPL");
+MODULE_VERSION(DRV_VERSION);
+MODULE_DEVICE_TABLE(pci, jme_pci_tbl);
+
diff -uprN -X ./dontdiff netdev-2.6/drivers/net/jme.h linux/drivers/net/jme.h
--- netdev-2.6/drivers/net/jme.h	1970-01-01 08:00:00.000000000 +0800
+++ linux/drivers/net/jme.h	2008-08-23 11:34:57.000000000 +0800
@@ -0,0 +1,1121 @@
+/*
+ * JMicron JMC2x0 series PCIe Ethernet Linux Device Driver
+ *
+ * Copyright 2008 JMicron Technology Corporation
+ * http://www.jmicron.com/
+ *
+ * Author: Guo-Fu Tseng <cooldavid@cooldavid.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+ *
+ */
+
+#ifndef __JME_H_INCLUDED__
+#define __JME_H_INCLUDEE__
+
+#define DRV_NAME	"jme"
+#define DRV_VERSION	"1.0"
+#define PFX		DRV_NAME ": "
+
+/*
+ * Message related definitions
+ */
+#define JME_DEF_MSG_ENABLE \
+	(NETIF_MSG_PROBE | \
+	NETIF_MSG_LINK | \
+	NETIF_MSG_RX_ERR | \
+	NETIF_MSG_TX_ERR | \
+	NETIF_MSG_HW)
+
+#define jeprintk(pdev, fmt, args...) \
+	printk(KERN_ERR PFX fmt, ## args)
+
+#define jme_msg(msglvl, type, priv, fmt, args...) \
+	if (netif_msg_##type(priv)) \
+		printk(msglvl "%s: " fmt, (priv)->dev->name, ## args)
+
+#define msg_probe(priv, fmt, args...) \
+	jme_msg(KERN_INFO, probe, priv, fmt, ## args)
+
+#define msg_link(priv, fmt, args...) \
+	jme_msg(KERN_INFO, link, priv, fmt, ## args)
+
+#define msg_rx_err(priv, fmt, args...) \
+	jme_msg(KERN_ERR, rx_err, priv, fmt, ## args)
+
+#define msg_rx_status(priv, fmt, args...) \
+	jme_msg(KERN_INFO, rx_status, priv, fmt, ## args)
+
+#define msg_tx_err(priv, fmt, args...) \
+	jme_msg(KERN_ERR, tx_err, priv, fmt, ## args)
+
+#define msg_tx_done(priv, fmt, args...) \
+	jme_msg(KERN_INFO, tx_done, priv, fmt, ## args)
+
+#define msg_tx_queued(priv, fmt, args...) \
+	jme_msg(KERN_INFO, tx_queued, priv, fmt, ## args)
+
+#define msg_hw(priv, fmt, args...) \
+	jme_msg(KERN_ERR, hw, priv, fmt, ## args)
+
+/*
+ * Extra PCI Configuration space interface
+ */
+#define PCI_DCSR_MRRS		0x59
+#define PCI_DCSR_MRRS_MASK	0x70
+
+enum pci_dcsr_mrrs_vals {
+	MRRS_128B	= 0x00,
+	MRRS_256B	= 0x10,
+	MRRS_512B	= 0x20,
+	MRRS_1024B	= 0x30,
+	MRRS_2048B	= 0x40,
+	MRRS_4096B	= 0x50,
+};
+
+#define PCI_SPI			0xB0
+
+enum pci_spi_bits {
+	SPI_EN		= 0x10,
+	SPI_MISO	= 0x08,
+	SPI_MOSI	= 0x04,
+	SPI_SCLK	= 0x02,
+	SPI_CS		= 0x01,
+};
+
+struct jme_spi_op {
+	void __user *uwbuf;
+	void __user *urbuf;
+	__u8	wn;	/* Number of write actions */
+	__u8	rn;	/* Number of read actions */
+	__u8	bitn;	/* Number of bits per action */
+	__u8	spd;	/* The maxim acceptable speed of controller, in MHz.*/
+	__u8	mode;	/* CPOL, CPHA, and Duplex mode of SPI */
+
+	/* Internal use only */
+	__u8	*kwbuf;
+	__u8	*krbuf;
+	__u8	sr;
+	__u16	halfclk; /* Half of clock cycle calculated from spd, in ns */
+};
+
+enum jme_pci_op_bits {
+	SPI_MODE_CPHA	= 0x01,
+	SPI_MODE_CPOL	= 0x02,
+	SPI_MODE_DUP	= 0x80,
+};
+
+#define HALF_US 500	/* 500 ns */
+#define JMESPIIOCTL	SIOCDEVPRIVATE
+
+/*
+ * Dynamic(adaptive)/Static PCC values
+ */
+enum dynamic_pcc_values {
+	PCC_OFF		= 0,
+	PCC_P1		= 1,
+	PCC_P2		= 2,
+	PCC_P3		= 3,
+
+	PCC_OFF_TO	= 0,
+	PCC_P1_TO	= 1,
+	PCC_P2_TO	= 64,
+	PCC_P3_TO	= 128,
+
+	PCC_OFF_CNT	= 0,
+	PCC_P1_CNT	= 1,
+	PCC_P2_CNT	= 16,
+	PCC_P3_CNT	= 32,
+};
+struct dynpcc_info {
+	unsigned long	last_bytes;
+	unsigned long	last_pkts;
+	unsigned long	intr_cnt;
+	unsigned char	cur;
+	unsigned char	attempt;
+	unsigned char	cnt;
+};
+#define PCC_INTERVAL_US	100000
+#define PCC_INTERVAL (HZ / (1000000 / PCC_INTERVAL_US))
+#define PCC_P3_THRESHOLD (2 * 1024 * 1024)
+#define PCC_P2_THRESHOLD 800
+#define PCC_INTR_THRESHOLD 800
+#define PCC_TX_TO 1000
+#define PCC_TX_CNT 8
+
+/*
+ * TX/RX Descriptors
+ *
+ * TX/RX Ring DESC Count Must be multiple of 16 and <= 1024
+ */
+#define RING_DESC_ALIGN		16	/* Descriptor alignment */
+#define TX_DESC_SIZE		16
+#define TX_RING_NR		8
+#define TX_RING_ALLOC_SIZE(s)	((s * TX_DESC_SIZE) + RING_DESC_ALIGN)
+
+struct txdesc {
+	union {
+		__u8  all[16];
+		__u32 dw[4];
+		struct {
+			/* DW0 */
+			__u16 vlan;
+			__u8 rsv1;
+			__u8 flags;
+
+			/* DW1 */
+			__u16 datalen;
+			__u16 mss;
+
+			/* DW2 */
+			__u16 pktsize;
+			__u16 rsv2;
+
+			/* DW3 */
+			__u32 bufaddr;
+		} desc1;
+		struct {
+			/* DW0 */
+			__u16 rsv1;
+			__u8 rsv2;
+			__u8 flags;
+
+			/* DW1 */
+			__u16 datalen;
+			__u16 rsv3;
+
+			/* DW2 */
+			__u32 bufaddrh;
+
+			/* DW3 */
+			__u32 bufaddrl;
+		} desc2;
+		struct {
+			/* DW0 */
+			__u8 ehdrsz;
+			__u8 rsv1;
+			__u8 rsv2;
+			__u8 flags;
+
+			/* DW1 */
+			__u16 trycnt;
+			__u16 segcnt;
+
+			/* DW2 */
+			__u16 pktsz;
+			__u16 rsv3;
+
+			/* DW3 */
+			__u32 bufaddrl;
+		} descwb;
+	};
+};
+
+enum jme_txdesc_flags_bits {
+	TXFLAG_OWN	= 0x80,
+	TXFLAG_INT	= 0x40,
+	TXFLAG_64BIT	= 0x20,
+	TXFLAG_TCPCS	= 0x10,
+	TXFLAG_UDPCS	= 0x08,
+	TXFLAG_IPCS	= 0x04,
+	TXFLAG_LSEN	= 0x02,
+	TXFLAG_TAGON	= 0x01,
+};
+
+#define TXDESC_MSS_SHIFT	2
+enum jme_rxdescwb_flags_bits {
+	TXWBFLAG_OWN	= 0x80,
+	TXWBFLAG_INT	= 0x40,
+	TXWBFLAG_TMOUT	= 0x20,
+	TXWBFLAG_TRYOUT	= 0x10,
+	TXWBFLAG_COL	= 0x08,
+
+	TXWBFLAG_ALLERR	= TXWBFLAG_TMOUT |
+			  TXWBFLAG_TRYOUT |
+			  TXWBFLAG_COL,
+};
+
+#define RX_DESC_SIZE		16
+#define RX_RING_NR		4
+#define RX_RING_ALLOC_SIZE(s)	((s * RX_DESC_SIZE) + RING_DESC_ALIGN)
+#define RX_BUF_DMA_ALIGN	8
+#define RX_PREPAD_SIZE		10
+#define ETH_CRC_LEN		2
+#define RX_VLANHDR_LEN		2
+#define RX_EXTRA_LEN		(RX_PREPAD_SIZE + \
+				ETH_HLEN + \
+				ETH_CRC_LEN + \
+				RX_VLANHDR_LEN + \
+				RX_BUF_DMA_ALIGN)
+
+struct rxdesc {
+	union {
+		__u8   all[16];
+		__le32 dw[4];
+		struct {
+			/* DW0 */
+			__le16 rsv2;
+			__u8 rsv1;
+			__u8 flags;
+
+			/* DW1 */
+			__le16 datalen;
+			__le16 wbcpl;
+
+			/* DW2 */
+			__le32 bufaddrh;
+
+			/* DW3 */
+			__le32 bufaddrl;
+		} desc1;
+		struct {
+			/* DW0 */
+			__le16 vlan;
+			__le16 flags;
+
+			/* DW1 */
+			__le16 framesize;
+			__u8 errstat;
+			__u8 desccnt;
+
+			/* DW2 */
+			__le32 rsshash;
+
+			/* DW3 */
+			__u8   hashfun;
+			__u8   hashtype;
+			__le16 resrv;
+		} descwb;
+	};
+};
+
+enum jme_rxdesc_flags_bits {
+	RXFLAG_OWN	= 0x80,
+	RXFLAG_INT	= 0x40,
+	RXFLAG_64BIT	= 0x20,
+};
+
+enum jme_rxwbdesc_flags_bits {
+	RXWBFLAG_OWN		= 0x8000,
+	RXWBFLAG_INT		= 0x4000,
+	RXWBFLAG_MF		= 0x2000,
+	RXWBFLAG_64BIT		= 0x2000,
+	RXWBFLAG_TCPON		= 0x1000,
+	RXWBFLAG_UDPON		= 0x0800,
+	RXWBFLAG_IPCS		= 0x0400,
+	RXWBFLAG_TCPCS		= 0x0200,
+	RXWBFLAG_UDPCS		= 0x0100,
+	RXWBFLAG_TAGON		= 0x0080,
+	RXWBFLAG_IPV4		= 0x0040,
+	RXWBFLAG_IPV6		= 0x0020,
+	RXWBFLAG_PAUSE		= 0x0010,
+	RXWBFLAG_MAGIC		= 0x0008,
+	RXWBFLAG_WAKEUP		= 0x0004,
+	RXWBFLAG_DEST		= 0x0003,
+	RXWBFLAG_DEST_UNI	= 0x0001,
+	RXWBFLAG_DEST_MUL	= 0x0002,
+	RXWBFLAG_DEST_BRO	= 0x0003,
+};
+
+enum jme_rxwbdesc_desccnt_mask {
+	RXWBDCNT_WBCPL	= 0x80,
+	RXWBDCNT_DCNT	= 0x7F,
+};
+
+enum jme_rxwbdesc_errstat_bits {
+	RXWBERR_LIMIT	= 0x80,
+	RXWBERR_MIIER	= 0x40,
+	RXWBERR_NIBON	= 0x20,
+	RXWBERR_COLON	= 0x10,
+	RXWBERR_ABORT	= 0x08,
+	RXWBERR_SHORT	= 0x04,
+	RXWBERR_OVERUN	= 0x02,
+	RXWBERR_CRCERR	= 0x01,
+	RXWBERR_ALLERR	= 0xFF,
+};
+
+/*
+ * Buffer information corresponding to ring descriptors.
+ */
+struct jme_buffer_info {
+	struct sk_buff *skb;
+	dma_addr_t mapping;
+	int len;
+	int nr_desc;
+	unsigned long start_xmit;
+};
+
+/*
+ * The structure holding buffer information and ring descriptors all together.
+ */
+#define MAX_RING_DESC_NR	1024
+struct jme_ring {
+	void *alloc;		/* pointer to allocated memory */
+	void *desc;		/* pointer to ring memory  */
+	dma_addr_t dmaalloc;	/* phys address of ring alloc */
+	dma_addr_t dma;		/* phys address for ring dma */
+
+	/* Buffer information corresponding to each descriptor */
+	struct jme_buffer_info bufinf[MAX_RING_DESC_NR];
+
+	int next_to_use;
+	atomic_t next_to_clean;
+	atomic_t nr_free;
+};
+
+#define NET_STAT(priv) (priv->dev->stats)
+#define NETDEV_GET_STATS(netdev, fun_ptr)
+#define DECLARE_NET_DEVICE_STATS
+
+#define DECLARE_NAPI_STRUCT struct napi_struct napi;
+#define NETIF_NAPI_SET(dev, napis, pollfn, q) \
+	netif_napi_add(dev, napis, pollfn, q);
+#define JME_NAPI_HOLDER(holder) struct napi_struct *holder
+#define JME_NAPI_WEIGHT(w) int w
+#define JME_NAPI_WEIGHT_VAL(w) w
+#define JME_NAPI_WEIGHT_SET(w, r)
+#define JME_RX_COMPLETE(dev, napis) netif_rx_complete(dev, napis)
+#define JME_NAPI_ENABLE(priv) napi_enable(&priv->napi);
+#define JME_NAPI_DISABLE(priv) \
+	if (!napi_disable_pending(&priv->napi)) \
+		napi_disable(&priv->napi);
+#define JME_RX_SCHEDULE_PREP(priv) \
+	netif_rx_schedule_prep(priv->dev, &priv->napi)
+#define JME_RX_SCHEDULE(priv) \
+	__netif_rx_schedule(priv->dev, &priv->napi);
+
+/*
+ * Jmac Adapter Private data
+ */
+#define SHADOW_REG_NR 8
+struct jme_adapter {
+	struct pci_dev          *pdev;
+	struct net_device       *dev;
+	void __iomem            *regs;
+	dma_addr_t		shadow_dma;
+	__u32			*shadow_regs;
+	struct mii_if_info	mii_if;
+	struct jme_ring		rxring[RX_RING_NR];
+	struct jme_ring		txring[TX_RING_NR];
+	spinlock_t		phy_lock;
+	spinlock_t		macaddr_lock;
+	spinlock_t		rxmcs_lock;
+	struct tasklet_struct	rxempty_task;
+	struct tasklet_struct	rxclean_task;
+	struct tasklet_struct	txclean_task;
+	struct tasklet_struct	linkch_task;
+	struct tasklet_struct	pcc_task;
+	unsigned long		flags;
+	__u32			reg_txcs;
+	__u32			reg_txpfc;
+	__u32			reg_rxcs;
+	__u32			reg_rxmcs;
+	__u32			reg_ghc;
+	__u32			reg_pmcs;
+	__u32			phylink;
+	__u32			tx_ring_size;
+	__u32			tx_ring_mask;
+	__u32			tx_wake_threshold;
+	__u32			rx_ring_size;
+	__u32			rx_ring_mask;
+	__u8			mrrs;
+	unsigned int		fpgaver;
+	unsigned int		chipver;
+	__u32			msg_enable;
+	struct ethtool_cmd	old_ecmd;
+	unsigned int		old_mtu;
+	struct vlan_group	*vlgrp;
+	struct dynpcc_info	dpi;
+	atomic_t		intr_sem;
+	atomic_t		link_changing;
+	atomic_t		tx_cleaning;
+	atomic_t		rx_cleaning;
+	atomic_t		rx_empty;
+	int			(*jme_rx)(struct sk_buff *skb);
+	int			(*jme_vlan_rx)(struct sk_buff *skb,
+					  struct vlan_group *grp,
+					  unsigned short vlan_tag);
+	DECLARE_NAPI_STRUCT
+	DECLARE_NET_DEVICE_STATS
+};
+
+enum shadow_reg_val {
+	SHADOW_IEVE = 0,
+};
+
+enum jme_flags_bits {
+	JME_FLAG_MSI		= 1,
+	JME_FLAG_SSET		= 2,
+	JME_FLAG_TXCSUM		= 3,
+	JME_FLAG_TSO		= 4,
+	JME_FLAG_POLL		= 5,
+	JME_FLAG_SHUTDOWN	= 6,
+};
+
+#define WAIT_TASKLET_TIMEOUT	500 /* 500 ms */
+#define TX_TIMEOUT		(5 * HZ)
+#define JME_REG_LEN		0x500
+#define MAX_ETHERNET_JUMBO_PACKET_SIZE 9216
+
+static inline struct jme_adapter*
+jme_napi_priv(struct napi_struct *napi)
+{
+	struct jme_adapter *jme;
+	jme = container_of(napi, struct jme_adapter, napi);
+	return jme;
+}
+
+/*
+ * MMaped I/O Resters
+ */
+enum jme_iomap_offsets {
+	JME_MAC		= 0x0000,
+	JME_PHY		= 0x0400,
+	JME_MISC	= 0x0800,
+	JME_RSS		= 0x0C00,
+};
+
+enum jme_iomap_lens {
+	JME_MAC_LEN	= 0x80,
+	JME_PHY_LEN	= 0x58,
+	JME_MISC_LEN	= 0x98,
+	JME_RSS_LEN	= 0xFF,
+};
+
+enum jme_iomap_regs {
+	JME_TXCS	= JME_MAC | 0x00, /* Transmit Control and Status */
+	JME_TXDBA_LO	= JME_MAC | 0x04, /* Transmit Queue Desc Base Addr */
+	JME_TXDBA_HI	= JME_MAC | 0x08, /* Transmit Queue Desc Base Addr */
+	JME_TXQDC	= JME_MAC | 0x0C, /* Transmit Queue Desc Count */
+	JME_TXNDA	= JME_MAC | 0x10, /* Transmit Queue Next Desc Addr */
+	JME_TXMCS	= JME_MAC | 0x14, /* Transmit MAC Control Status */
+	JME_TXPFC	= JME_MAC | 0x18, /* Transmit Pause Frame Control */
+	JME_TXTRHD	= JME_MAC | 0x1C, /* Transmit Timer/Retry@Half-Dup */
+
+	JME_RXCS	= JME_MAC | 0x20, /* Receive Control and Status */
+	JME_RXDBA_LO	= JME_MAC | 0x24, /* Receive Queue Desc Base Addr */
+	JME_RXDBA_HI	= JME_MAC | 0x28, /* Receive Queue Desc Base Addr */
+	JME_RXQDC	= JME_MAC | 0x2C, /* Receive Queue Desc Count */
+	JME_RXNDA	= JME_MAC | 0x30, /* Receive Queue Next Desc Addr */
+	JME_RXMCS	= JME_MAC | 0x34, /* Receive MAC Control Status */
+	JME_RXUMA_LO	= JME_MAC | 0x38, /* Receive Unicast MAC Address */
+	JME_RXUMA_HI	= JME_MAC | 0x3C, /* Receive Unicast MAC Address */
+	JME_RXMCHT_LO	= JME_MAC | 0x40, /* Recv Multicast Addr HashTable */
+	JME_RXMCHT_HI	= JME_MAC | 0x44, /* Recv Multicast Addr HashTable */
+	JME_WFODP	= JME_MAC | 0x48, /* Wakeup Frame Output Data Port */
+	JME_WFOI	= JME_MAC | 0x4C, /* Wakeup Frame Output Interface */
+
+	JME_SMI		= JME_MAC | 0x50, /* Station Management Interface */
+	JME_GHC		= JME_MAC | 0x54, /* Global Host Control */
+	JME_PMCS	= JME_MAC | 0x60, /* Power Management Control/Stat */
+
+
+	JME_PHY_CS	= JME_PHY | 0x28, /* PHY Ctrl and Status Register */
+	JME_PHY_LINK	= JME_PHY | 0x30, /* PHY Link Status Register */
+	JME_SMBCSR	= JME_PHY | 0x40, /* SMB Control and Status */
+	JME_SMBINTF	= JME_PHY | 0x44, /* SMB Interface */
+
+
+	JME_TMCSR	= JME_MISC | 0x00, /* Timer Control/Status Register */
+	JME_GPREG0	= JME_MISC | 0x08, /* General purpose REG-0 */
+	JME_GPREG1	= JME_MISC | 0x0C, /* General purpose REG-1 */
+	JME_IEVE	= JME_MISC | 0x20, /* Interrupt Event Status */
+	JME_IREQ	= JME_MISC | 0x24, /* Intr Req Status(For Debug) */
+	JME_IENS	= JME_MISC | 0x28, /* Intr Enable - Setting Port */
+	JME_IENC	= JME_MISC | 0x2C, /* Interrupt Enable - Clear Port */
+	JME_PCCRX0	= JME_MISC | 0x30, /* PCC Control for RX Queue 0 */
+	JME_PCCTX	= JME_MISC | 0x40, /* PCC Control for TX Queues */
+	JME_CHIPMODE	= JME_MISC | 0x44, /* Identify FPGA Version */
+	JME_SHBA_HI	= JME_MISC | 0x48, /* Shadow Register Base HI */
+	JME_SHBA_LO	= JME_MISC | 0x4C, /* Shadow Register Base LO */
+	JME_TIMER1	= JME_MISC | 0x70, /* Timer1 */
+	JME_TIMER2	= JME_MISC | 0x74, /* Timer2 */
+	JME_APMC	= JME_MISC | 0x7C, /* Aggressive Power Mode Control */
+	JME_PCCSRX0	= JME_MISC | 0x80, /* PCC Status of RX0 */
+};
+
+/*
+ * TX Control/Status Bits
+ */
+enum jme_txcs_bits {
+	TXCS_QUEUE7S	= 0x00008000,
+	TXCS_QUEUE6S	= 0x00004000,
+	TXCS_QUEUE5S	= 0x00002000,
+	TXCS_QUEUE4S	= 0x00001000,
+	TXCS_QUEUE3S	= 0x00000800,
+	TXCS_QUEUE2S	= 0x00000400,
+	TXCS_QUEUE1S	= 0x00000200,
+	TXCS_QUEUE0S	= 0x00000100,
+	TXCS_FIFOTH	= 0x000000C0,
+	TXCS_DMASIZE	= 0x00000030,
+	TXCS_BURST	= 0x00000004,
+	TXCS_ENABLE	= 0x00000001,
+};
+
+enum jme_txcs_value {
+	TXCS_FIFOTH_16QW	= 0x000000C0,
+	TXCS_FIFOTH_12QW	= 0x00000080,
+	TXCS_FIFOTH_8QW		= 0x00000040,
+	TXCS_FIFOTH_4QW		= 0x00000000,
+
+	TXCS_DMASIZE_64B	= 0x00000000,
+	TXCS_DMASIZE_128B	= 0x00000010,
+	TXCS_DMASIZE_256B	= 0x00000020,
+	TXCS_DMASIZE_512B	= 0x00000030,
+
+	TXCS_SELECT_QUEUE0	= 0x00000000,
+	TXCS_SELECT_QUEUE1	= 0x00010000,
+	TXCS_SELECT_QUEUE2	= 0x00020000,
+	TXCS_SELECT_QUEUE3	= 0x00030000,
+	TXCS_SELECT_QUEUE4	= 0x00040000,
+	TXCS_SELECT_QUEUE5	= 0x00050000,
+	TXCS_SELECT_QUEUE6	= 0x00060000,
+	TXCS_SELECT_QUEUE7	= 0x00070000,
+
+	TXCS_DEFAULT		= TXCS_FIFOTH_4QW |
+				  TXCS_BURST,
+};
+
+#define JME_TX_DISABLE_TIMEOUT 10 /* 10 msec */
+
+/*
+ * TX MAC Control/Status Bits
+ */
+enum jme_txmcs_bit_masks {
+	TXMCS_IFG2		= 0xC0000000,
+	TXMCS_IFG1		= 0x30000000,
+	TXMCS_TTHOLD		= 0x00000300,
+	TXMCS_FBURST		= 0x00000080,
+	TXMCS_CARRIEREXT	= 0x00000040,
+	TXMCS_DEFER		= 0x00000020,
+	TXMCS_BACKOFF		= 0x00000010,
+	TXMCS_CARRIERSENSE	= 0x00000008,
+	TXMCS_COLLISION		= 0x00000004,
+	TXMCS_CRC		= 0x00000002,
+	TXMCS_PADDING		= 0x00000001,
+};
+
+enum jme_txmcs_values {
+	TXMCS_IFG2_6_4		= 0x00000000,
+	TXMCS_IFG2_8_5		= 0x40000000,
+	TXMCS_IFG2_10_6		= 0x80000000,
+	TXMCS_IFG2_12_7		= 0xC0000000,
+
+	TXMCS_IFG1_8_4		= 0x00000000,
+	TXMCS_IFG1_12_6		= 0x10000000,
+	TXMCS_IFG1_16_8		= 0x20000000,
+	TXMCS_IFG1_20_10	= 0x30000000,
+
+	TXMCS_TTHOLD_1_8	= 0x00000000,
+	TXMCS_TTHOLD_1_4	= 0x00000100,
+	TXMCS_TTHOLD_1_2	= 0x00000200,
+	TXMCS_TTHOLD_FULL	= 0x00000300,
+
+	TXMCS_DEFAULT		= TXMCS_IFG2_8_5 |
+				  TXMCS_IFG1_16_8 |
+				  TXMCS_TTHOLD_FULL |
+				  TXMCS_DEFER |
+				  TXMCS_CRC |
+				  TXMCS_PADDING,
+};
+
+enum jme_txpfc_bits_masks {
+	TXPFC_VLAN_TAG		= 0xFFFF0000,
+	TXPFC_VLAN_EN		= 0x00008000,
+	TXPFC_PF_EN		= 0x00000001,
+};
+
+enum jme_txtrhd_bits_masks {
+	TXTRHD_TXPEN		= 0x80000000,
+	TXTRHD_TXP		= 0x7FFFFF00,
+	TXTRHD_TXREN		= 0x00000080,
+	TXTRHD_TXRL		= 0x0000007F,
+};
+
+enum jme_txtrhd_shifts {
+	TXTRHD_TXP_SHIFT	= 8,
+	TXTRHD_TXRL_SHIFT	= 0,
+};
+
+/*
+ * RX Control/Status Bits
+ */
+enum jme_rxcs_bit_masks {
+	/* FIFO full threshold for transmitting Tx Pause Packet */
+	RXCS_FIFOTHTP	= 0x30000000,
+	/* FIFO threshold for processing next packet */
+	RXCS_FIFOTHNP	= 0x0C000000,
+	RXCS_DMAREQSZ	= 0x03000000, /* DMA Request Size */
+	RXCS_QUEUESEL	= 0x00030000, /* Queue selection */
+	RXCS_RETRYGAP	= 0x0000F000, /* RX Desc full retry gap */
+	RXCS_RETRYCNT	= 0x00000F00, /* RX Desc full retry counter */
+	RXCS_WAKEUP	= 0x00000040, /* Enable receive wakeup packet */
+	RXCS_MAGIC	= 0x00000020, /* Enable receive magic packet */
+	RXCS_SHORT	= 0x00000010, /* Enable receive short packet */
+	RXCS_ABORT	= 0x00000008, /* Enable receive errorr packet */
+	RXCS_QST	= 0x00000004, /* Receive queue start */
+	RXCS_SUSPEND	= 0x00000002,
+	RXCS_ENABLE	= 0x00000001,
+};
+
+enum jme_rxcs_values {
+	RXCS_FIFOTHTP_16T	= 0x00000000,
+	RXCS_FIFOTHTP_32T	= 0x10000000,
+	RXCS_FIFOTHTP_64T	= 0x20000000,
+	RXCS_FIFOTHTP_128T	= 0x30000000,
+
+	RXCS_FIFOTHNP_16QW	= 0x00000000,
+	RXCS_FIFOTHNP_32QW	= 0x04000000,
+	RXCS_FIFOTHNP_64QW	= 0x08000000,
+	RXCS_FIFOTHNP_128QW	= 0x0C000000,
+
+	RXCS_DMAREQSZ_16B	= 0x00000000,
+	RXCS_DMAREQSZ_32B	= 0x01000000,
+	RXCS_DMAREQSZ_64B	= 0x02000000,
+	RXCS_DMAREQSZ_128B	= 0x03000000,
+
+	RXCS_QUEUESEL_Q0	= 0x00000000,
+	RXCS_QUEUESEL_Q1	= 0x00010000,
+	RXCS_QUEUESEL_Q2	= 0x00020000,
+	RXCS_QUEUESEL_Q3	= 0x00030000,
+
+	RXCS_RETRYGAP_256ns	= 0x00000000,
+	RXCS_RETRYGAP_512ns	= 0x00001000,
+	RXCS_RETRYGAP_1024ns	= 0x00002000,
+	RXCS_RETRYGAP_2048ns	= 0x00003000,
+	RXCS_RETRYGAP_4096ns	= 0x00004000,
+	RXCS_RETRYGAP_8192ns	= 0x00005000,
+	RXCS_RETRYGAP_16384ns	= 0x00006000,
+	RXCS_RETRYGAP_32768ns	= 0x00007000,
+
+	RXCS_RETRYCNT_0		= 0x00000000,
+	RXCS_RETRYCNT_4		= 0x00000100,
+	RXCS_RETRYCNT_8		= 0x00000200,
+	RXCS_RETRYCNT_12	= 0x00000300,
+	RXCS_RETRYCNT_16	= 0x00000400,
+	RXCS_RETRYCNT_20	= 0x00000500,
+	RXCS_RETRYCNT_24	= 0x00000600,
+	RXCS_RETRYCNT_28	= 0x00000700,
+	RXCS_RETRYCNT_32	= 0x00000800,
+	RXCS_RETRYCNT_36	= 0x00000900,
+	RXCS_RETRYCNT_40	= 0x00000A00,
+	RXCS_RETRYCNT_44	= 0x00000B00,
+	RXCS_RETRYCNT_48	= 0x00000C00,
+	RXCS_RETRYCNT_52	= 0x00000D00,
+	RXCS_RETRYCNT_56	= 0x00000E00,
+	RXCS_RETRYCNT_60	= 0x00000F00,
+
+	RXCS_DEFAULT		= RXCS_FIFOTHTP_128T |
+				  RXCS_FIFOTHNP_128QW |
+				  RXCS_DMAREQSZ_128B |
+				  RXCS_RETRYGAP_256ns |
+				  RXCS_RETRYCNT_32,
+};
+
+#define JME_RX_DISABLE_TIMEOUT 10 /* 10 msec */
+
+/*
+ * RX MAC Control/Status Bits
+ */
+enum jme_rxmcs_bits {
+	RXMCS_ALLFRAME		= 0x00000800,
+	RXMCS_BRDFRAME		= 0x00000400,
+	RXMCS_MULFRAME		= 0x00000200,
+	RXMCS_UNIFRAME		= 0x00000100,
+	RXMCS_ALLMULFRAME	= 0x00000080,
+	RXMCS_MULFILTERED	= 0x00000040,
+	RXMCS_RXCOLLDEC		= 0x00000020,
+	RXMCS_FLOWCTRL		= 0x00000008,
+	RXMCS_VTAGRM		= 0x00000004,
+	RXMCS_PREPAD		= 0x00000002,
+	RXMCS_CHECKSUM		= 0x00000001,
+
+	RXMCS_DEFAULT		= RXMCS_VTAGRM |
+				  RXMCS_PREPAD |
+				  RXMCS_FLOWCTRL |
+				  RXMCS_CHECKSUM,
+};
+
+/*
+ * Wakeup Frame setup interface registers
+ */
+#define WAKEUP_FRAME_NR	8
+#define WAKEUP_FRAME_MASK_DWNR	4
+
+enum jme_wfoi_bit_masks {
+	WFOI_MASK_SEL		= 0x00000070,
+	WFOI_CRC_SEL		= 0x00000008,
+	WFOI_FRAME_SEL		= 0x00000007,
+};
+
+enum jme_wfoi_shifts {
+	WFOI_MASK_SHIFT		= 4,
+};
+
+/*
+ * SMI Related definitions
+ */
+enum jme_smi_bit_mask {
+	SMI_DATA_MASK		= 0xFFFF0000,
+	SMI_REG_ADDR_MASK	= 0x0000F800,
+	SMI_PHY_ADDR_MASK	= 0x000007C0,
+	SMI_OP_WRITE		= 0x00000020,
+	/* Set to 1, after req done it'll be cleared to 0 */
+	SMI_OP_REQ		= 0x00000010,
+	SMI_OP_MDIO		= 0x00000008, /* Software assess In/Out */
+	SMI_OP_MDOE		= 0x00000004, /* Software Output Enable */
+	SMI_OP_MDC		= 0x00000002, /* Software CLK Control */
+	SMI_OP_MDEN		= 0x00000001, /* Software access Enable */
+};
+
+enum jme_smi_bit_shift {
+	SMI_DATA_SHIFT		= 16,
+	SMI_REG_ADDR_SHIFT	= 11,
+	SMI_PHY_ADDR_SHIFT	= 6,
+};
+
+static inline __u32 smi_reg_addr(int x)
+{
+	return (x << SMI_REG_ADDR_SHIFT) & SMI_REG_ADDR_MASK;
+}
+
+static inline __u32 smi_phy_addr(int x)
+{
+	return (x << SMI_PHY_ADDR_SHIFT) & SMI_PHY_ADDR_MASK;
+}
+
+#define JME_PHY_TIMEOUT 100 /* 100 msec */
+#define JME_PHY_REG_NR 32
+
+/*
+ * Global Host Control
+ */
+enum jme_ghc_bit_mask {
+	GHC_SWRST	= 0x40000000,
+	GHC_DPX		= 0x00000040,
+	GHC_SPEED	= 0x00000030,
+	GHC_LINK_POLL	= 0x00000001,
+};
+
+enum jme_ghc_speed_val {
+	GHC_SPEED_10M	= 0x00000010,
+	GHC_SPEED_100M	= 0x00000020,
+	GHC_SPEED_1000M	= 0x00000030,
+};
+
+/*
+ * Power management control and status register
+ */
+enum jme_pmcs_bit_masks {
+	PMCS_WF7DET	= 0x80000000,
+	PMCS_WF6DET	= 0x40000000,
+	PMCS_WF5DET	= 0x20000000,
+	PMCS_WF4DET	= 0x10000000,
+	PMCS_WF3DET	= 0x08000000,
+	PMCS_WF2DET	= 0x04000000,
+	PMCS_WF1DET	= 0x02000000,
+	PMCS_WF0DET	= 0x01000000,
+	PMCS_LFDET	= 0x00040000,
+	PMCS_LRDET	= 0x00020000,
+	PMCS_MFDET	= 0x00010000,
+	PMCS_WF7EN	= 0x00008000,
+	PMCS_WF6EN	= 0x00004000,
+	PMCS_WF5EN	= 0x00002000,
+	PMCS_WF4EN	= 0x00001000,
+	PMCS_WF3EN	= 0x00000800,
+	PMCS_WF2EN	= 0x00000400,
+	PMCS_WF1EN	= 0x00000200,
+	PMCS_WF0EN	= 0x00000100,
+	PMCS_LFEN	= 0x00000004,
+	PMCS_LREN	= 0x00000002,
+	PMCS_MFEN	= 0x00000001,
+};
+
+/*
+ * Giga PHY Status Registers
+ */
+enum jme_phy_link_bit_mask {
+	PHY_LINK_SPEED_MASK		= 0x0000C000,
+	PHY_LINK_DUPLEX			= 0x00002000,
+	PHY_LINK_SPEEDDPU_RESOLVED	= 0x00000800,
+	PHY_LINK_UP			= 0x00000400,
+	PHY_LINK_AUTONEG_COMPLETE	= 0x00000200,
+	PHY_LINK_MDI_STAT		= 0x00000040,
+};
+
+enum jme_phy_link_speed_val {
+	PHY_LINK_SPEED_10M		= 0x00000000,
+	PHY_LINK_SPEED_100M		= 0x00004000,
+	PHY_LINK_SPEED_1000M		= 0x00008000,
+};
+
+#define JME_SPDRSV_TIMEOUT	500	/* 500 us */
+
+/*
+ * SMB Control and Status
+ */
+enum jme_smbcsr_bit_mask {
+	SMBCSR_CNACK	= 0x00020000,
+	SMBCSR_RELOAD	= 0x00010000,
+	SMBCSR_EEPROMD	= 0x00000020,
+	SMBCSR_INITDONE	= 0x00000010,
+	SMBCSR_BUSY	= 0x0000000F,
+};
+
+enum jme_smbintf_bit_mask {
+	SMBINTF_HWDATR	= 0xFF000000,
+	SMBINTF_HWDATW	= 0x00FF0000,
+	SMBINTF_HWADDR	= 0x0000FF00,
+	SMBINTF_HWRWN	= 0x00000020,
+	SMBINTF_HWCMD	= 0x00000010,
+	SMBINTF_FASTM	= 0x00000008,
+	SMBINTF_GPIOSCL	= 0x00000004,
+	SMBINTF_GPIOSDA	= 0x00000002,
+	SMBINTF_GPIOEN	= 0x00000001,
+};
+
+enum jme_smbintf_vals {
+	SMBINTF_HWRWN_READ	= 0x00000020,
+	SMBINTF_HWRWN_WRITE	= 0x00000000,
+};
+
+enum jme_smbintf_shifts {
+	SMBINTF_HWDATR_SHIFT	= 24,
+	SMBINTF_HWDATW_SHIFT	= 16,
+	SMBINTF_HWADDR_SHIFT	= 8,
+};
+
+#define JME_EEPROM_RELOAD_TIMEOUT 2000 /* 2000 msec */
+#define JME_SMB_BUSY_TIMEOUT 20 /* 20 msec */
+#define JME_SMB_LEN 256
+#define JME_EEPROM_MAGIC 0x250
+
+/*
+ * Timer Control/Status Register
+ */
+enum jme_tmcsr_bit_masks {
+	TMCSR_SWIT	= 0x80000000,
+	TMCSR_EN	= 0x01000000,
+	TMCSR_CNT	= 0x00FFFFFF,
+};
+
+/*
+ * General Purpose REG-0
+ */
+enum jme_gpreg0_masks {
+	GPREG0_DISSH		= 0xFF000000,
+	GPREG0_PCIRLMT		= 0x00300000,
+	GPREG0_PCCNOMUTCLR	= 0x00040000,
+	GPREG0_LNKINTPOLL	= 0x00001000,
+	GPREG0_PCCTMR		= 0x00000300,
+	GPREG0_PHYADDR		= 0x0000001F,
+};
+
+enum jme_gpreg0_vals {
+	GPREG0_DISSH_DW7	= 0x80000000,
+	GPREG0_DISSH_DW6	= 0x40000000,
+	GPREG0_DISSH_DW5	= 0x20000000,
+	GPREG0_DISSH_DW4	= 0x10000000,
+	GPREG0_DISSH_DW3	= 0x08000000,
+	GPREG0_DISSH_DW2	= 0x04000000,
+	GPREG0_DISSH_DW1	= 0x02000000,
+	GPREG0_DISSH_DW0	= 0x01000000,
+	GPREG0_DISSH_ALL	= 0xFF000000,
+
+	GPREG0_PCIRLMT_8	= 0x00000000,
+	GPREG0_PCIRLMT_6	= 0x00100000,
+	GPREG0_PCIRLMT_5	= 0x00200000,
+	GPREG0_PCIRLMT_4	= 0x00300000,
+
+	GPREG0_PCCTMR_16ns	= 0x00000000,
+	GPREG0_PCCTMR_256ns	= 0x00000100,
+	GPREG0_PCCTMR_1us	= 0x00000200,
+	GPREG0_PCCTMR_1ms	= 0x00000300,
+
+	GPREG0_PHYADDR_1	= 0x00000001,
+
+	GPREG0_DEFAULT		= GPREG0_PCIRLMT_4 |
+				  GPREG0_PCCTMR_1us |
+				  GPREG0_PHYADDR_1,
+};
+
+/*
+ * Interrupt Status Bits
+ */
+enum jme_interrupt_bits {
+	INTR_SWINTR	= 0x80000000,
+	INTR_TMINTR	= 0x40000000,
+	INTR_LINKCH	= 0x20000000,
+	INTR_PAUSERCV	= 0x10000000,
+	INTR_MAGICRCV	= 0x08000000,
+	INTR_WAKERCV	= 0x04000000,
+	INTR_PCCRX0TO	= 0x02000000,
+	INTR_PCCRX1TO	= 0x01000000,
+	INTR_PCCRX2TO	= 0x00800000,
+	INTR_PCCRX3TO	= 0x00400000,
+	INTR_PCCTXTO	= 0x00200000,
+	INTR_PCCRX0	= 0x00100000,
+	INTR_PCCRX1	= 0x00080000,
+	INTR_PCCRX2	= 0x00040000,
+	INTR_PCCRX3	= 0x00020000,
+	INTR_PCCTX	= 0x00010000,
+	INTR_RX3EMP	= 0x00008000,
+	INTR_RX2EMP	= 0x00004000,
+	INTR_RX1EMP	= 0x00002000,
+	INTR_RX0EMP	= 0x00001000,
+	INTR_RX3	= 0x00000800,
+	INTR_RX2	= 0x00000400,
+	INTR_RX1	= 0x00000200,
+	INTR_RX0	= 0x00000100,
+	INTR_TX7	= 0x00000080,
+	INTR_TX6	= 0x00000040,
+	INTR_TX5	= 0x00000020,
+	INTR_TX4	= 0x00000010,
+	INTR_TX3	= 0x00000008,
+	INTR_TX2	= 0x00000004,
+	INTR_TX1	= 0x00000002,
+	INTR_TX0	= 0x00000001,
+};
+
+static const __u32 INTR_ENABLE = INTR_SWINTR |
+				 INTR_TMINTR |
+				 INTR_LINKCH |
+				 INTR_PCCRX0TO |
+				 INTR_PCCRX0 |
+				 INTR_PCCTXTO |
+				 INTR_PCCTX |
+				 INTR_RX0EMP;
+
+/*
+ * PCC Control Registers
+ */
+enum jme_pccrx_masks {
+	PCCRXTO_MASK	= 0xFFFF0000,
+	PCCRX_MASK	= 0x0000FF00,
+};
+
+enum jme_pcctx_masks {
+	PCCTXTO_MASK	= 0xFFFF0000,
+	PCCTX_MASK	= 0x0000FF00,
+	PCCTX_QS_MASK	= 0x000000FF,
+};
+
+enum jme_pccrx_shifts {
+	PCCRXTO_SHIFT	= 16,
+	PCCRX_SHIFT	= 8,
+};
+
+enum jme_pcctx_shifts {
+	PCCTXTO_SHIFT	= 16,
+	PCCTX_SHIFT	= 8,
+};
+
+enum jme_pcctx_bits {
+	PCCTXQ0_EN	= 0x00000001,
+	PCCTXQ1_EN	= 0x00000002,
+	PCCTXQ2_EN	= 0x00000004,
+	PCCTXQ3_EN	= 0x00000008,
+	PCCTXQ4_EN	= 0x00000010,
+	PCCTXQ5_EN	= 0x00000020,
+	PCCTXQ6_EN	= 0x00000040,
+	PCCTXQ7_EN	= 0x00000080,
+};
+
+/*
+ * Chip Mode Register
+ */
+enum jme_chipmode_bit_masks {
+	CM_FPGAVER_MASK		= 0xFFFF0000,
+	CM_CHIPVER_MASK		= 0x0000FF00,
+	CM_CHIPMODE_MASK	= 0x0000000F,
+};
+
+enum jme_chipmode_shifts {
+	CM_FPGAVER_SHIFT	= 16,
+	CM_CHIPVER_SHIFT	= 8,
+};
+
+/*
+ * Shadow base address register bits
+ */
+enum jme_shadow_base_address_bits {
+	SHBA_POSTEN	= 0x1,
+};
+
+/*
+ * Aggressive Power Mode Control
+ */
+enum jme_apmc_bits {
+	JME_APMC_PCIE_SD_EN	= 0x40000000,
+	JME_APMC_PSEUDO_HP_EN	= 0x20000000,
+	JME_APMC_EPIEN		= 0x04000000,
+	JME_APMC_EPIEN_CTRL	= 0x03000000,
+};
+
+enum jme_apmc_values {
+	JME_APMC_EPIEN_CTRL_EN	= 0x02000000,
+	JME_APMC_EPIEN_CTRL_DIS	= 0x01000000,
+};
+
+#define APMC_PHP_SHUTDOWN_DELAY	(10 * 1000 * 1000)
+
+/*
+ * Read/Write MMaped I/O Registers
+ */
+static inline __u32 jread32(struct jme_adapter *jme, __u32 reg)
+{
+	return le32_to_cpu(readl(jme->regs + reg));
+}
+
+static inline void jwrite32(struct jme_adapter *jme, __u32 reg, __u32 val)
+{
+	writel(cpu_to_le32(val), jme->regs + reg);
+}
+
+static inline void jwrite32f(struct jme_adapter *jme, __u32 reg, __u32 val)
+{
+	/*
+	 * Read after write should cause flush
+	 */
+	writel(cpu_to_le32(val), jme->regs + reg);
+	readl(jme->regs + reg);
+}
+
+/*
+ * PHY Regs
+ */
+enum jme_phy_reg17_bit_masks {
+	PREG17_SPEED		= 0xC000,
+	PREG17_DUPLEX		= 0x2000,
+	PREG17_SPDRSV		= 0x0800,
+	PREG17_LNKUP		= 0x0400,
+	PREG17_MDI		= 0x0040,
+};
+
+enum jme_phy_reg17_vals {
+	PREG17_SPEED_10M	= 0x0000,
+	PREG17_SPEED_100M	= 0x4000,
+	PREG17_SPEED_1000M	= 0x8000,
+};
+
+#define BMSR_ANCOMP               0x0020
+
+/*
+ * Function prototypes
+ */
+static int jme_set_settings(struct net_device *netdev,
+				struct ethtool_cmd *ecmd);
+static void jme_set_multi(struct net_device *netdev);
+
+#endif
diff -uprN -X ./dontdiff netdev-2.6/drivers/net/Kconfig linux/drivers/net/Kconfig
--- netdev-2.6/drivers/net/Kconfig	2008-08-22 07:48:34.000000000 +0800
+++ linux/drivers/net/Kconfig	2008-08-23 01:12:07.000000000 +0800
@@ -2302,6 +2302,18 @@ config ATL1E
 	  To compile this driver as a module, choose M here.  The module
 	  will be called atl1e.
 
+config JME
+	tristate "JMicron(R) PCI-Express Gigabit Ethernet support"
+	depends on PCI
+	select CRC32
+	select MII
+	---help---
+	  This driver supports the PCI-Express gigabit ethernet adapters
+	  based on JMicron JMC250 chipset.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called jme.
+
 endif # NETDEV_1000
 
 #
diff -uprN -X ./dontdiff netdev-2.6/drivers/net/Makefile linux/drivers/net/Makefile
--- netdev-2.6/drivers/net/Makefile	2008-08-22 07:48:34.000000000 +0800
+++ linux/drivers/net/Makefile	2008-08-23 01:12:07.000000000 +0800
@@ -18,6 +18,7 @@ obj-$(CONFIG_ATL1) += atlx/
 obj-$(CONFIG_ATL1E) += atl1e/
 obj-$(CONFIG_GIANFAR) += gianfar_driver.o
 obj-$(CONFIG_TEHUTI) += tehuti.o
+obj-$(CONFIG_JME) += jme.o
 
 gianfar_driver-objs := gianfar.o \
 		gianfar_ethtool.o \
diff -uprN -X ./dontdiff netdev-2.6/include/linux/pci_ids.h linux/include/linux/pci_ids.h
--- netdev-2.6/include/linux/pci_ids.h	2008-08-22 07:48:54.000000000 +0800
+++ linux/include/linux/pci_ids.h	2008-08-23 01:12:07.000000000 +0800
@@ -2224,6 +2224,8 @@
 #define PCI_DEVICE_ID_JMICRON_JMB38X_SD	0x2381
 #define PCI_DEVICE_ID_JMICRON_JMB38X_MMC 0x2382
 #define PCI_DEVICE_ID_JMICRON_JMB38X_MS	0x2383
+#define PCI_DEVICE_ID_JMICRON_JMC250	0x0250
+#define PCI_DEVICE_ID_JMICRON_JMC260	0x0260
 
 #define PCI_VENDOR_ID_KORENIX		0x1982
 #define PCI_DEVICE_ID_KORENIX_JETCARDF0	0x1600
diff -uprN -X ./dontdiff netdev-2.6/MAINTAINERS linux/MAINTAINERS
--- netdev-2.6/MAINTAINERS	2008-08-22 07:48:19.000000000 +0800
+++ linux/MAINTAINERS	2008-08-23 01:12:07.000000000 +0800
@@ -2389,6 +2389,12 @@ L:	video4linux-list@redhat.com
 W:	http://www.ivtvdriver.org
 S:	Maintained
 
+JME NETWORK DRIVER
+P:	Guo-Fu Tseng
+M:	cooldavid@cooldavid.org
+L:	netdev@vger.kernel.org
+S:	Maintained
+
 JOURNALLING FLASH FILE SYSTEM V2 (JFFS2)
 P:	David Woodhouse
 M:	dwmw2@infradead.org


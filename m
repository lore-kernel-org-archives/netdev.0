From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes
Date: Tue, 15 May 2007 19:43:15 -0400
Message-ID: <20070515234314.GA4860@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:58902 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756462AbXEOXnQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 May 2007 19:43:16 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Please pull from 'upstream-linus' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-linus

to receive the following updates:

 drivers/net/pasemi_mac.c   |   45 +++++++++++++++++++++++++++----------------
 drivers/net/pasemi_mac.h   |    4 +-
 drivers/net/smc911x.c      |    6 +---
 drivers/net/ucc_geth.c     |   40 +++++++++++++++-----------------------
 drivers/net/ucc_geth_mii.c |    9 ++++---
 drivers/net/ucc_geth_mii.h |   10 ++++----
 6 files changed, 58 insertions(+), 56 deletions(-)

Kim Phillips (1):
      ucc_geth: eliminate max-speed, change interface-type to phy-connection-type

Olof Johansson (1):
      pasemi_mac: Interrupt ack fixes

Vitaly Wool (1):
      smc911x: fix compilation breakage

olof@lixom.net (3):
      pasemi_mac: Fix register defines
      pasemi_mac: Terminate PCI ID list
      pasemi_mac: Fix local-mac-address parsing

diff --git a/drivers/net/pasemi_mac.c b/drivers/net/pasemi_mac.c
index bc7f3de..8d38425 100644
--- a/drivers/net/pasemi_mac.c
+++ b/drivers/net/pasemi_mac.c
@@ -85,6 +85,7 @@ static int pasemi_get_mac_addr(struct pasemi_mac *mac)
 {
 	struct pci_dev *pdev = mac->pdev;
 	struct device_node *dn = pci_device_to_OF_node(pdev);
+	int len;
 	const u8 *maddr;
 	u8 addr[6];
 
@@ -94,9 +95,17 @@ static int pasemi_get_mac_addr(struct pasemi_mac *mac)
 		return -ENOENT;
 	}
 
-	maddr = of_get_property(dn, "local-mac-address", NULL);
+	maddr = of_get_property(dn, "local-mac-address", &len);
+
+	if (maddr && len == 6) {
+		memcpy(mac->mac_addr, maddr, 6);
+		return 0;
+	}
+
+	/* Some old versions of firmware mistakenly uses mac-address
+	 * (and as a string) instead of a byte array in local-mac-address.
+	 */
 
-	/* Fall back to mac-address for older firmware */
 	if (maddr == NULL)
 		maddr = of_get_property(dn, "mac-address", NULL);
 
@@ -106,6 +115,7 @@ static int pasemi_get_mac_addr(struct pasemi_mac *mac)
 		return -ENOENT;
 	}
 
+
 	if (sscanf(maddr, "%hhx:%hhx:%hhx:%hhx:%hhx:%hhx", &addr[0],
 		   &addr[1], &addr[2], &addr[3], &addr[4], &addr[5]) != 6) {
 		dev_warn(&pdev->dev,
@@ -113,7 +123,8 @@ static int pasemi_get_mac_addr(struct pasemi_mac *mac)
 		return -EINVAL;
 	}
 
-	memcpy(mac->mac_addr, addr, sizeof(addr));
+	memcpy(mac->mac_addr, addr, 6);
+
 	return 0;
 }
 
@@ -384,17 +395,14 @@ static void pasemi_mac_replenish_rx_ring(struct net_device *dev)
 
 static void pasemi_mac_restart_rx_intr(struct pasemi_mac *mac)
 {
-	unsigned int reg, stat;
+	unsigned int reg, pcnt;
 	/* Re-enable packet count interrupts: finally
 	 * ack the packet count interrupt we got in rx_intr.
 	 */
 
-	pci_read_config_dword(mac->iob_pdev,
-			      PAS_IOB_DMA_RXCH_STAT(mac->dma_rxch),
-			      &stat);
+	pcnt = *mac->rx_status & PAS_STATUS_PCNT_M;
 
-	reg = PAS_IOB_DMA_RXCH_RESET_PCNT(stat & PAS_IOB_DMA_RXCH_STAT_CNTDEL_M)
-		| PAS_IOB_DMA_RXCH_RESET_PINTC;
+	reg = PAS_IOB_DMA_RXCH_RESET_PCNT(pcnt) | PAS_IOB_DMA_RXCH_RESET_PINTC;
 
 	pci_write_config_dword(mac->iob_pdev,
 			       PAS_IOB_DMA_RXCH_RESET(mac->dma_rxch),
@@ -403,14 +411,12 @@ static void pasemi_mac_restart_rx_intr(struct pasemi_mac *mac)
 
 static void pasemi_mac_restart_tx_intr(struct pasemi_mac *mac)
 {
-	unsigned int reg, stat;
+	unsigned int reg, pcnt;
 
 	/* Re-enable packet count interrupts */
-	pci_read_config_dword(mac->iob_pdev,
-			      PAS_IOB_DMA_TXCH_STAT(mac->dma_txch), &stat);
+	pcnt = *mac->tx_status & PAS_STATUS_PCNT_M;
 
-	reg = PAS_IOB_DMA_TXCH_RESET_PCNT(stat & PAS_IOB_DMA_TXCH_STAT_CNTDEL_M)
-		| PAS_IOB_DMA_TXCH_RESET_PINTC;
+	reg = PAS_IOB_DMA_TXCH_RESET_PCNT(pcnt) | PAS_IOB_DMA_TXCH_RESET_PINTC;
 
 	pci_write_config_dword(mac->iob_pdev,
 			       PAS_IOB_DMA_TXCH_RESET(mac->dma_txch), reg);
@@ -591,21 +597,24 @@ static irqreturn_t pasemi_mac_tx_intr(int irq, void *data)
 {
 	struct net_device *dev = data;
 	struct pasemi_mac *mac = netdev_priv(dev);
-	unsigned int reg;
+	unsigned int reg, pcnt;
 
 	if (!(*mac->tx_status & PAS_STATUS_CAUSE_M))
 		return IRQ_NONE;
 
 	pasemi_mac_clean_tx(mac);
 
-	reg = PAS_IOB_DMA_TXCH_RESET_PINTC;
+	pcnt = *mac->tx_status & PAS_STATUS_PCNT_M;
+
+	reg = PAS_IOB_DMA_TXCH_RESET_PCNT(pcnt) | PAS_IOB_DMA_TXCH_RESET_PINTC;
 
 	if (*mac->tx_status & PAS_STATUS_SOFT)
 		reg |= PAS_IOB_DMA_TXCH_RESET_SINTC;
 	if (*mac->tx_status & PAS_STATUS_ERROR)
 		reg |= PAS_IOB_DMA_TXCH_RESET_DINTC;
 
-	pci_write_config_dword(mac->iob_pdev, PAS_IOB_DMA_TXCH_RESET(mac->dma_txch),
+	pci_write_config_dword(mac->iob_pdev,
+			       PAS_IOB_DMA_TXCH_RESET(mac->dma_txch),
 			       reg);
 
 	return IRQ_HANDLED;
@@ -974,6 +983,7 @@ static int pasemi_mac_start_tx(struct sk_buff *skb, struct net_device *dev)
 	if (txring->next_to_clean - txring->next_to_use == TX_RING_SIZE) {
 		spin_unlock_irqrestore(&txring->lock, flags);
 		pasemi_mac_clean_tx(mac);
+		pasemi_mac_restart_tx_intr(mac);
 		spin_lock_irqsave(&txring->lock, flags);
 
 		if (txring->next_to_clean - txring->next_to_use ==
@@ -1210,6 +1220,7 @@ static void __devexit pasemi_mac_remove(struct pci_dev *pdev)
 static struct pci_device_id pasemi_mac_pci_tbl[] = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_PASEMI, 0xa005) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_PASEMI, 0xa006) },
+	{ },
 };
 
 MODULE_DEVICE_TABLE(pci, pasemi_mac_pci_tbl);
diff --git a/drivers/net/pasemi_mac.h b/drivers/net/pasemi_mac.h
index 8bc0cea..c29ee15 100644
--- a/drivers/net/pasemi_mac.h
+++ b/drivers/net/pasemi_mac.h
@@ -341,7 +341,7 @@ enum {
 						 PAS_IOB_DMA_TXCH_STAT_CNTDEL_M)
 #define PAS_IOB_DMA_RXCH_RESET(i)	(0x1500 + (i)*4)
 #define    PAS_IOB_DMA_RXCH_RESET_PCNT_M	0xffff0000
-#define    PAS_IOB_DMA_RXCH_RESET_PCNT_S	0
+#define    PAS_IOB_DMA_RXCH_RESET_PCNT_S	16
 #define    PAS_IOB_DMA_RXCH_RESET_PCNT(x)	(((x) << PAS_IOB_DMA_RXCH_RESET_PCNT_S) & \
 						 PAS_IOB_DMA_RXCH_RESET_PCNT_M)
 #define    PAS_IOB_DMA_RXCH_RESET_PCNTRST	0x00000020
@@ -352,7 +352,7 @@ enum {
 #define    PAS_IOB_DMA_RXCH_RESET_PINTC		0x00000001
 #define PAS_IOB_DMA_TXCH_RESET(i)	(0x1600 + (i)*4)
 #define    PAS_IOB_DMA_TXCH_RESET_PCNT_M	0xffff0000
-#define    PAS_IOB_DMA_TXCH_RESET_PCNT_S	0
+#define    PAS_IOB_DMA_TXCH_RESET_PCNT_S	16
 #define    PAS_IOB_DMA_TXCH_RESET_PCNT(x)	(((x) << PAS_IOB_DMA_TXCH_RESET_PCNT_S) & \
 						 PAS_IOB_DMA_TXCH_RESET_PCNT_M)
 #define    PAS_IOB_DMA_TXCH_RESET_PCNTRST	0x00000020
diff --git a/drivers/net/smc911x.c b/drivers/net/smc911x.c
index 81f2484..db43e42 100644
--- a/drivers/net/smc911x.c
+++ b/drivers/net/smc911x.c
@@ -77,7 +77,6 @@ static const char version[] =
 #include <linux/skbuff.h>
 
 #include <asm/io.h>
-#include <asm/irq.h>
 
 #include "smc911x.h"
 
@@ -2084,12 +2083,11 @@ static int __init smc911x_probe(struct net_device *dev, unsigned long ioaddr)
 	lp->ctl_rspeed = 100;
 
 	/* Grab the IRQ */
-	retval = request_irq(dev->irq, &smc911x_interrupt, IRQF_SHARED, dev->name, dev);
+	retval = request_irq(dev->irq, &smc911x_interrupt,
+			IRQF_SHARED | IRQF_TRIGGER_FALLING, dev->name, dev);
 	if (retval)
 		goto err_out;
 
-	set_irq_type(dev->irq, IRQT_FALLING);
-
 #ifdef SMC_USE_DMA
 	lp->rxdma = SMC_DMA_REQUEST(dev, smc911x_rx_dma_irq);
 	lp->txdma = SMC_DMA_REQUEST(dev, smc911x_tx_dma_irq);
diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 0f66765..c2ccbd0 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) Freescale Semicondutor, Inc. 2006. All rights reserved.
+ * Copyright (C) 2006-2007 Freescale Semicondutor, Inc. All rights reserved.
  *
  * Author: Shlomi Gridish <gridish@freescale.com>
  *	   Li Yang <leoli@freescale.com>
@@ -3737,21 +3737,21 @@ static int ucc_geth_close(struct net_device *dev)
 
 const struct ethtool_ops ucc_geth_ethtool_ops = { };
 
-static phy_interface_t to_phy_interface(const char *interface_type)
+static phy_interface_t to_phy_interface(const char *phy_connection_type)
 {
-	if (strcasecmp(interface_type, "mii") == 0)
+	if (strcasecmp(phy_connection_type, "mii") == 0)
 		return PHY_INTERFACE_MODE_MII;
-	if (strcasecmp(interface_type, "gmii") == 0)
+	if (strcasecmp(phy_connection_type, "gmii") == 0)
 		return PHY_INTERFACE_MODE_GMII;
-	if (strcasecmp(interface_type, "tbi") == 0)
+	if (strcasecmp(phy_connection_type, "tbi") == 0)
 		return PHY_INTERFACE_MODE_TBI;
-	if (strcasecmp(interface_type, "rmii") == 0)
+	if (strcasecmp(phy_connection_type, "rmii") == 0)
 		return PHY_INTERFACE_MODE_RMII;
-	if (strcasecmp(interface_type, "rgmii") == 0)
+	if (strcasecmp(phy_connection_type, "rgmii") == 0)
 		return PHY_INTERFACE_MODE_RGMII;
-	if (strcasecmp(interface_type, "rgmii-id") == 0)
+	if (strcasecmp(phy_connection_type, "rgmii-id") == 0)
 		return PHY_INTERFACE_MODE_RGMII_ID;
-	if (strcasecmp(interface_type, "rtbi") == 0)
+	if (strcasecmp(phy_connection_type, "rtbi") == 0)
 		return PHY_INTERFACE_MODE_RTBI;
 
 	return PHY_INTERFACE_MODE_MII;
@@ -3819,29 +3819,21 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 	ug_info->phy_address = *prop;
 
 	/* get the phy interface type, or default to MII */
-	prop = of_get_property(np, "interface-type", NULL);
+	prop = of_get_property(np, "phy-connection-type", NULL);
 	if (!prop) {
 		/* handle interface property present in old trees */
 		prop = of_get_property(phy, "interface", NULL);
-		if (prop != NULL)
+		if (prop != NULL) {
 			phy_interface = enet_to_phy_interface[*prop];
-		else
+			max_speed = enet_to_speed[*prop];
+		} else
 			phy_interface = PHY_INTERFACE_MODE_MII;
 	} else {
 		phy_interface = to_phy_interface((const char *)prop);
 	}
 
-	/* get speed, or derive from interface */
-	prop = of_get_property(np, "max-speed", NULL);
-	if (!prop) {
-		/* handle interface property present in old trees */
-		prop = of_get_property(phy, "interface", NULL);
-		if (prop != NULL)
-			max_speed = enet_to_speed[*prop];
-	} else {
-		max_speed = *prop;
-	}
-	if (!max_speed) {
+	/* get speed, or derive from PHY interface */
+	if (max_speed == 0)
 		switch (phy_interface) {
 		case PHY_INTERFACE_MODE_GMII:
 		case PHY_INTERFACE_MODE_RGMII:
@@ -3854,9 +3846,9 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 			max_speed = SPEED_100;
 			break;
 		}
-	}
 
 	if (max_speed == SPEED_1000) {
+		/* configure muram FIFOs for gigabit operation */
 		ug_info->uf_info.urfs = UCC_GETH_URFS_GIGA_INIT;
 		ug_info->uf_info.urfet = UCC_GETH_URFET_GIGA_INIT;
 		ug_info->uf_info.urfset = UCC_GETH_URFSET_GIGA_INIT;
diff --git a/drivers/net/ucc_geth_mii.c b/drivers/net/ucc_geth_mii.c
index 27a1ef3..f96966d 100644
--- a/drivers/net/ucc_geth_mii.c
+++ b/drivers/net/ucc_geth_mii.c
@@ -1,12 +1,13 @@
 /*
  * drivers/net/ucc_geth_mii.c
  *
- * Gianfar Ethernet Driver -- MIIM bus implementation
- * Provides Bus interface for MIIM regs
+ * QE UCC Gigabit Ethernet Driver -- MII Management Bus Implementation
+ * Provides Bus interface for MII Management regs in the UCC register space
  *
- * Author: Li Yang
+ * Copyright (C) 2007 Freescale Semiconductor, Inc.
  *
- * Copyright (c) 2002-2004 Freescale Semiconductor, Inc.
+ * Authors: Li Yang <leoli@freescale.com>
+ *	    Kim Phillips <kim.phillips@freescale.com>
  *
  * This program is free software; you can redistribute  it and/or modify it
  * under  the terms of  the GNU General  Public License as published by the
diff --git a/drivers/net/ucc_geth_mii.h b/drivers/net/ucc_geth_mii.h
index 98430fe..d834370 100644
--- a/drivers/net/ucc_geth_mii.h
+++ b/drivers/net/ucc_geth_mii.h
@@ -1,13 +1,13 @@
 /*
  * drivers/net/ucc_geth_mii.h
  *
- * Gianfar Ethernet Driver -- MII Management Bus Implementation
- * Driver for the MDIO bus controller in the Gianfar register space
+ * QE UCC Gigabit Ethernet Driver -- MII Management Bus Implementation
+ * Provides Bus interface for MII Management regs in the UCC register space
  *
- * Author: Andy Fleming
- * Maintainer: Kumar Gala
+ * Copyright (C) 2007 Freescale Semiconductor, Inc.
  *
- * Copyright (c) 2002-2004 Freescale Semiconductor, Inc.
+ * Authors: Li Yang <leoli@freescale.com>
+ *	    Kim Phillips <kim.phillips@freescale.com>
  *
  * This program is free software; you can redistribute  it and/or modify it
  * under  the terms of  the GNU General  Public License as published by the

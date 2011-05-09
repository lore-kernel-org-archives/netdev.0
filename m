From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 2/8] r8169: remove some code duplication.
Date: Mon, 9 May 2011 21:03:29 +0200
Message-ID: <20110509190329.GB20687@electric-eye.fr.zoreil.com>
References: <20110509190446.GA6053@electric-eye.fr.zoreil.com> <20110509190205.GA20677@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Hayes Wang <hayeswang@realtek.com>,
	Ciprian Docan <docan@eden.rutgers.edu>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:50155 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753900Ab1EITNI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2011 15:13:08 -0400
Content-Disposition: inline
In-Reply-To: <20110509190205.GA20677@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Realtek linux nic maintainers <nic_swsd@realtek.com>
---
 drivers/net/r8169.c |   42 +++++++++++++++++++-----------------------
 1 files changed, 19 insertions(+), 23 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index c51515f..976bb31 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -3224,6 +3224,22 @@ static void __devinit rtl_init_pll_power_ops(struct rtl8169_private *tp)
 	}
 }
 
+static void rtl_hw_reset(struct rtl8169_private *tp)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+	int i;
+
+	/* Soft reset the chip. */
+	RTL_W8(ChipCmd, CmdReset);
+
+	/* Check that the chip has finished the reset. */
+	for (i = 0; i < 100; i++) {
+		if ((RTL_R8(ChipCmd) & CmdReset) == 0)
+			break;
+		msleep_interruptible(1);
+	}
+}
+
 static int __devinit
 rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
@@ -3323,6 +3339,7 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		rc = -EIO;
 		goto err_out_free_res_3;
 	}
+	tp->mmio_addr = ioaddr;
 
 	tp->pcie_cap = pci_find_capability(pdev, PCI_CAP_ID_EXP);
 	if (!tp->pcie_cap)
@@ -3330,15 +3347,7 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	RTL_W16(IntrMask, 0x0000);
 
-	/* Soft reset the chip. */
-	RTL_W8(ChipCmd, CmdReset);
-
-	/* Check that the chip has finished the reset. */
-	for (i = 0; i < 100; i++) {
-		if ((RTL_R8(ChipCmd) & CmdReset) == 0)
-			break;
-		msleep_interruptible(1);
-	}
+	rtl_hw_reset(tp);
 
 	RTL_W16(IntrStatus, 0xffff);
 
@@ -3409,8 +3418,6 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	spin_lock_init(&tp->lock);
 
-	tp->mmio_addr = ioaddr;
-
 	/* Get MAC address */
 	for (i = 0; i < MAC_ADDR_LEN; i++)
 		dev->dev_addr[i] = RTL_R8(MAC0 + i);
@@ -3658,25 +3665,14 @@ static void rtl_set_rx_tx_config_registers(struct rtl8169_private *tp)
 static void rtl_hw_start(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
-	void __iomem *ioaddr = tp->mmio_addr;
-	unsigned int i;
 
-	/* Soft reset the chip. */
-	RTL_W8(ChipCmd, CmdReset);
-
-	/* Check that the chip has finished the reset. */
-	for (i = 0; i < 100; i++) {
-		if ((RTL_R8(ChipCmd) & CmdReset) == 0)
-			break;
-		msleep_interruptible(1);
-	}
+	rtl_hw_reset(tp);
 
 	tp->hw_start(dev);
 
 	netif_start_queue(dev);
 }
 
-
 static void rtl_set_rx_tx_desc_registers(struct rtl8169_private *tp,
 					 void __iomem *ioaddr)
 {
-- 
1.7.4.4


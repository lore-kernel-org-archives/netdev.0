From: Ondrej Zary <linux@rainbow-software.org>
Subject: [PATCH 2/3] dl2k: Reorder and cleanup initialization
Date: Tue, 17 Nov 2015 18:28:17 +0100
Message-ID: <1447781298-19785-2-git-send-email-linux@rainbow-software.org>
References: <1447781298-19785-1-git-send-email-linux@rainbow-software.org>
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	David Miller <davem@davemloft.net>,
	Kernel development list <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1447781298-19785-1-git-send-email-linux@rainbow-software.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move HW init and stop into separate functions.
Request IRQ only after the HW has been reset (so interrupts are
disabled and no stale interrupts are pending).

Signed-off-by: Ondrej Zary <linux@rainbow-software.org>
---
 drivers/net/ethernet/dlink/dl2k.c |   95 ++++++++++++++++++++++---------------
 1 file changed, 56 insertions(+), 39 deletions(-)

diff --git a/drivers/net/ethernet/dlink/dl2k.c b/drivers/net/ethernet/dlink/dl2k.c
index ec0eb7f..9e9baa0 100644
--- a/drivers/net/ethernet/dlink/dl2k.c
+++ b/drivers/net/ethernet/dlink/dl2k.c
@@ -252,19 +252,6 @@ rio_probe1 (struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (err)
 		goto err_out_unmap_rx;
 
-	if (np->chip_id == CHIP_IP1000A &&
-	    (np->pdev->revision == 0x40 || np->pdev->revision == 0x41)) {
-		/* PHY magic taken from ipg driver, undocumented registers */
-		mii_write(dev, np->phy_addr, 31, 0x0001);
-		mii_write(dev, np->phy_addr, 27, 0x01e0);
-		mii_write(dev, np->phy_addr, 31, 0x0002);
-		mii_write(dev, np->phy_addr, 27, 0xeb8e);
-		mii_write(dev, np->phy_addr, 31, 0x0000);
-		mii_write(dev, np->phy_addr, 30, 0x005e);
-		/* advertise 1000BASE-T half & full duplex, prefer MASTER */
-		mii_write(dev, np->phy_addr, MII_CTRL1000, 0x0700);
-	}
-
 	/* Fiber device? */
 	np->phy_media = (dr16(ASICCtrl) & PhyMedia) ? 1 : 0;
 	np->link_status = 0;
@@ -274,13 +261,11 @@ rio_probe1 (struct pci_dev *pdev, const struct pci_device_id *ent)
 	 	if (np->an_enable == 2) {
 			np->an_enable = 1;
 		}
-		mii_set_media_pcs (dev);
 	} else {
 		/* Auto-Negotiation is mandatory for 1000BASE-T,
 		   IEEE 802.3ab Annex 28D page 14 */
 		if (np->speed == 1000)
 			np->an_enable = 1;
-		mii_set_media (dev);
 	}
 
 	err = register_netdev (dev);
@@ -531,25 +516,13 @@ static int alloc_list(struct net_device *dev)
 	return 0;
 }
 
-static int
-rio_open (struct net_device *dev)
+static void rio_hw_init(struct net_device *dev)
 {
 	struct netdev_private *np = netdev_priv(dev);
 	void __iomem *ioaddr = np->ioaddr;
-	const int irq = np->pdev->irq;
 	int i;
 	u16 macctrl;
 
-	i = alloc_list(dev);
-	if (i)
-		return i;
-
-	i = request_irq(irq, rio_interrupt, IRQF_SHARED, dev->name, dev);
-	if (i) {
-		free_list(dev);
-		return i;
-	}
-
 	/* Reset all logic functions */
 	dw16(ASICCtrl + 2,
 	     GlobalReset | DMAReset | FIFOReset | NetworkReset | HostReset);
@@ -560,6 +533,24 @@ rio_open (struct net_device *dev)
 	/* DebugCtrl bit 4, 5, 9 must set */
 	dw32(DebugCtrl, dr32(DebugCtrl) | 0x0230);
 
+	if (np->chip_id == CHIP_IP1000A &&
+	    (np->pdev->revision == 0x40 || np->pdev->revision == 0x41)) {
+		/* PHY magic taken from ipg driver, undocumented registers */
+		mii_write(dev, np->phy_addr, 31, 0x0001);
+		mii_write(dev, np->phy_addr, 27, 0x01e0);
+		mii_write(dev, np->phy_addr, 31, 0x0002);
+		mii_write(dev, np->phy_addr, 27, 0xeb8e);
+		mii_write(dev, np->phy_addr, 31, 0x0000);
+		mii_write(dev, np->phy_addr, 30, 0x005e);
+		/* advertise 1000BASE-T half & full duplex, prefer MASTER */
+		mii_write(dev, np->phy_addr, MII_CTRL1000, 0x0700);
+	}
+
+	if (np->phy_media)
+		mii_set_media_pcs(dev);
+	else
+		mii_set_media(dev);
+
 	/* Jumbo frame */
 	if (np->jumbo != 0)
 		dw16(MaxFrameSize, MAX_JUMBO+14);
@@ -602,10 +593,6 @@ rio_open (struct net_device *dev)
 		dw32(MACCtrl, dr32(MACCtrl) | AutoVLANuntagging);
 	}
 
-	setup_timer(&np->timer, rio_timer, (unsigned long)dev);
-	np->timer.expires = jiffies + 1*HZ;
-	add_timer (&np->timer);
-
 	/* Start Tx/Rx */
 	dw32(MACCtrl, dr32(MACCtrl) | StatsEnable | RxEnable | TxEnable);
 
@@ -615,6 +602,42 @@ rio_open (struct net_device *dev)
 	macctrl |= (np->tx_flow) ? TxFlowControlEnable : 0;
 	macctrl |= (np->rx_flow) ? RxFlowControlEnable : 0;
 	dw16(MACCtrl, macctrl);
+}
+
+static void rio_hw_stop(struct net_device *dev)
+{
+	struct netdev_private *np = netdev_priv(dev);
+	void __iomem *ioaddr = np->ioaddr;
+
+	/* Disable interrupts */
+	dw16(IntEnable, 0);
+
+	/* Stop Tx and Rx logics */
+	dw32(MACCtrl, TxDisable | RxDisable | StatsDisable);
+}
+
+static int rio_open(struct net_device *dev)
+{
+	struct netdev_private *np = netdev_priv(dev);
+	const int irq = np->pdev->irq;
+	int i;
+
+	i = alloc_list(dev);
+	if (i)
+		return i;
+
+	rio_hw_init(dev);
+
+	i = request_irq(irq, rio_interrupt, IRQF_SHARED, dev->name, dev);
+	if (i) {
+		rio_hw_stop(dev);
+		free_list(dev);
+		return i;
+	}
+
+	setup_timer(&np->timer, rio_timer, (unsigned long)dev);
+	np->timer.expires = jiffies + 1 * HZ;
+	add_timer(&np->timer);
 
 	netif_start_queue (dev);
 
@@ -1764,17 +1787,11 @@ static int
 rio_close (struct net_device *dev)
 {
 	struct netdev_private *np = netdev_priv(dev);
-	void __iomem *ioaddr = np->ioaddr;
-
 	struct pci_dev *pdev = np->pdev;
 
 	netif_stop_queue (dev);
 
-	/* Disable interrupts */
-	dw16(IntEnable, 0);
-
-	/* Stop Tx and Rx logics */
-	dw32(MACCtrl, TxDisable | RxDisable | StatsDisable);
+	rio_hw_stop(dev);
 
 	free_irq(pdev->irq, dev);
 	del_timer_sync (&np->timer);
-- 
Ondrej Zary

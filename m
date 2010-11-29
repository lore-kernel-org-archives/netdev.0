From: Joe Perches <joe@perches.com>
Subject: [PATCH 01/11] forcedeth: Change reg_delay arguments and use
Date: Mon, 29 Nov 2010 09:41:52 -0800
Message-ID: <adc632efef4bb121de84eab108e5bc526a97b81f.1291051316.git.joe@perches.com>
References: <cover.1291051316.git.joe@perches.com>
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Szymon Janc <szymon@janc.net.pl>,
	=?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirqus@gmail.com>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1291051316.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move the printk out of reg_delay and make
the callers emit a message on error.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/forcedeth.c |   30 ++++++++++++++----------------
 1 files changed, 14 insertions(+), 16 deletions(-)

diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 2fd1ae9..e5f9d4b 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -948,7 +948,7 @@ static bool nv_optimized(struct fe_priv *np)
 }
 
 static int reg_delay(struct net_device *dev, int offset, u32 mask, u32 target,
-				int delay, int delaymax, const char *msg)
+		     int delay, int delaymax)
 {
 	u8 __iomem *base = get_hwbase(dev);
 
@@ -956,11 +956,8 @@ static int reg_delay(struct net_device *dev, int offset, u32 mask, u32 target,
 	do {
 		udelay(delay);
 		delaymax -= delay;
-		if (delaymax < 0) {
-			if (msg)
-				printk("%s", msg);
+		if (delaymax < 0)
 			return 1;
-		}
 	} while ((readl(base + offset) & mask) != target);
 	return 0;
 }
@@ -1141,9 +1138,9 @@ static int mii_rw(struct net_device *dev, int addr, int miireg, int value)
 	writel(reg, base + NvRegMIIControl);
 
 	if (reg_delay(dev, NvRegMIIControl, NVREG_MIICTL_INUSE, 0,
-			NV_MIIPHY_DELAY, NV_MIIPHY_DELAYMAX, NULL)) {
+			NV_MIIPHY_DELAY, NV_MIIPHY_DELAYMAX)) {
 		dprintk(KERN_DEBUG "%s: mii_rw of reg %d at PHY %d timed out.\n",
-				dev->name, miireg, addr);
+			dev->name, miireg, addr);
 		retval = -1;
 	} else if (value != MII_READ) {
 		/* it was a write operation - fewer failures are detectable */
@@ -1539,9 +1536,9 @@ static void nv_stop_rx(struct net_device *dev)
 	else
 		rx_ctrl |= NVREG_RCVCTL_RX_PATH_EN;
 	writel(rx_ctrl, base + NvRegReceiverControl);
-	reg_delay(dev, NvRegReceiverStatus, NVREG_RCVSTAT_BUSY, 0,
-			NV_RXSTOP_DELAY1, NV_RXSTOP_DELAY1MAX,
-			KERN_INFO "nv_stop_rx: ReceiverStatus remained busy");
+	if (reg_delay(dev, NvRegReceiverStatus, NVREG_RCVSTAT_BUSY, 0,
+		      NV_RXSTOP_DELAY1, NV_RXSTOP_DELAY1MAX))
+		printk(KERN_INFO "nv_stop_rx: ReceiverStatus remained busy");
 
 	udelay(NV_RXSTOP_DELAY2);
 	if (!np->mac_in_use)
@@ -1574,9 +1571,9 @@ static void nv_stop_tx(struct net_device *dev)
 	else
 		tx_ctrl |= NVREG_XMITCTL_TX_PATH_EN;
 	writel(tx_ctrl, base + NvRegTransmitterControl);
-	reg_delay(dev, NvRegTransmitterStatus, NVREG_XMITSTAT_BUSY, 0,
-			NV_TXSTOP_DELAY1, NV_TXSTOP_DELAY1MAX,
-			KERN_INFO "nv_stop_tx: TransmitterStatus remained busy");
+	if (reg_delay(dev, NvRegTransmitterStatus, NVREG_XMITSTAT_BUSY, 0,
+		      NV_TXSTOP_DELAY1, NV_TXSTOP_DELAY1MAX))
+		printk(KERN_INFO "nv_stop_tx: TransmitterStatus remained busy");
 
 	udelay(NV_TXSTOP_DELAY2);
 	if (!np->mac_in_use)
@@ -5190,9 +5187,10 @@ static int nv_open(struct net_device *dev)
 	writel(np->vlanctl_bits, base + NvRegVlanControl);
 	pci_push(base);
 	writel(NVREG_TXRXCTL_BIT1|np->txrxctl_bits, base + NvRegTxRxControl);
-	reg_delay(dev, NvRegUnknownSetupReg5, NVREG_UNKSETUP5_BIT31, NVREG_UNKSETUP5_BIT31,
-			NV_SETUP5_DELAY, NV_SETUP5_DELAYMAX,
-			KERN_INFO "open: SetupReg5, Bit 31 remained off\n");
+	if (reg_delay(dev, NvRegUnknownSetupReg5,
+		      NVREG_UNKSETUP5_BIT31, NVREG_UNKSETUP5_BIT31,
+		      NV_SETUP5_DELAY, NV_SETUP5_DELAYMAX))
+		printk(KERN_INFO "open: SetupReg5, Bit 31 remained off\n");
 
 	writel(0, base + NvRegMIIMask);
 	writel(NVREG_IRQSTAT_MASK, base + NvRegIrqStatus);
-- 
1.7.3.2.245.g03276.dirty

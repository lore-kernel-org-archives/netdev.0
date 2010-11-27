From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 5/6] forcedeth: use KERN_ facility level in printk
Date: Sat, 27 Nov 2010 11:45:40 -0800
Message-ID: <1290887140.22971.16.camel@Joe-Laptop>
References: <1290883188-2078-1-git-send-email-szymon@janc.net.pl>
	 <1290883188-2078-6-git-send-email-szymon@janc.net.pl>
	 <1290884641.3292.0.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Szymon Janc <szymon@janc.net.pl>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1881 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753004Ab0K0Tpm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Nov 2010 14:45:42 -0500
In-Reply-To: <1290884641.3292.0.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2010-11-27 at 19:04 +0000, Ben Hutchings wrote:
> On Sat, 2010-11-27 at 19:39 +0100, Szymon Janc wrote:
> > diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
> > index 2f092d7..a2b6681 100644
> > --- a/drivers/net/forcedeth.c
> > +++ b/drivers/net/forcedeth.c
> > @@ -958,7 +958,7 @@ static int reg_delay(struct net_device *dev, int offset, u32 mask, u32 target,
> >  		delaymax -= delay;
> >  		if (delaymax < 0) {
> >  			if (msg)
> > -				printk("%s", msg);
> > +				printk(KERN_WARNING "%s", msg);
> No, msg already includes a log level.

True.  The messages are still broken though.
Some have trailing newlines, others not.

It'd be better to move the msg after the reg_delay
call and add the missing newlines.

---

 drivers/net/forcedeth.c |   28 +++++++++++++---------------
 1 files changed, 13 insertions(+), 15 deletions(-)

diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 0fa1776..2d11028f 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -948,7 +948,7 @@ static bool nv_optimized(struct fe_priv *np)
 }
 
 static int reg_delay(struct net_device *dev, int offset, u32 mask, u32 target,
-				int delay, int delaymax, const char *msg)
+				int delay, int delaymax)
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
@@ -1145,7 +1142,7 @@ static int mii_rw(struct net_device *dev, int addr, int miireg, int value)
 	writel(reg, base + NvRegMIIControl);
 
 	if (reg_delay(dev, NvRegMIIControl, NVREG_MIICTL_INUSE, 0,
-			NV_MIIPHY_DELAY, NV_MIIPHY_DELAYMAX, NULL)) {
+			NV_MIIPHY_DELAY, NV_MIIPHY_DELAYMAX)) {
 		dprintk(KERN_DEBUG "%s: mii_rw of reg %d at PHY %d timed out.\n",
 				dev->name, miireg, addr);
 		retval = -1;
@@ -1547,9 +1544,9 @@ static void nv_stop_rx(struct net_device *dev)
 	else
 		rx_ctrl |= NVREG_RCVCTL_RX_PATH_EN;
 	writel(rx_ctrl, base + NvRegReceiverControl);
-	reg_delay(dev, NvRegReceiverStatus, NVREG_RCVSTAT_BUSY, 0,
-			NV_RXSTOP_DELAY1, NV_RXSTOP_DELAY1MAX,
-			KERN_INFO "nv_stop_rx: ReceiverStatus remained busy");
+	if (reg_delay(dev, NvRegReceiverStatus, NVREG_RCVSTAT_BUSY, 0,
+		      NV_RXSTOP_DELAY1, NV_RXSTOP_DELAY1MAX))
+		printk(KERN_INFO "nv_stop_rx: ReceiverStatus remained busy\n");
 
 	udelay(NV_RXSTOP_DELAY2);
 	if (!np->mac_in_use)
@@ -1582,9 +1579,9 @@ static void nv_stop_tx(struct net_device *dev)
 	else
 		tx_ctrl |= NVREG_XMITCTL_TX_PATH_EN;
 	writel(tx_ctrl, base + NvRegTransmitterControl);
-	reg_delay(dev, NvRegTransmitterStatus, NVREG_XMITSTAT_BUSY, 0,
-			NV_TXSTOP_DELAY1, NV_TXSTOP_DELAY1MAX,
-			KERN_INFO "nv_stop_tx: TransmitterStatus remained busy");
+	if (reg_delay(dev, NvRegTransmitterStatus, NVREG_XMITSTAT_BUSY, 0,
+		      NV_TXSTOP_DELAY1, NV_TXSTOP_DELAY1MAX))
+	    printk(KERN_INFO "nv_stop_tx: TransmitterStatus remained busy\n");
 
 	udelay(NV_TXSTOP_DELAY2);
 	if (!np->mac_in_use)
@@ -5216,9 +5213,10 @@ static int nv_open(struct net_device *dev)
 	writel(np->vlanctl_bits, base + NvRegVlanControl);
 	pci_push(base);
 	writel(NVREG_TXRXCTL_BIT1|np->txrxctl_bits, base + NvRegTxRxControl);
-	reg_delay(dev, NvRegUnknownSetupReg5, NVREG_UNKSETUP5_BIT31, NVREG_UNKSETUP5_BIT31,
-			NV_SETUP5_DELAY, NV_SETUP5_DELAYMAX,
-			KERN_INFO "open: SetupReg5, Bit 31 remained off\n");
+	if (reg_delay(dev, NvRegUnknownSetupReg5,
+		      NVREG_UNKSETUP5_BIT31, NVREG_UNKSETUP5_BIT31,
+		      NV_SETUP5_DELAY, NV_SETUP5_DELAYMAX))
+	    printk(KERN_INFO "open: SetupReg5, Bit 31 remained off\n");
 
 	writel(0, base + NvRegMIIMask);
 	writel(NVREG_IRQSTAT_MASK, base + NvRegIrqStatus);



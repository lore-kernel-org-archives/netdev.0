From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 5/5] net: systemport: add Wake-on-LAN support
Date: Tue,  1 Jul 2014 21:08:40 -0700
Message-ID: <1404274120-5717-6-git-send-email-f.fainelli@gmail.com>
References: <1404274120-5717-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f49.google.com ([209.85.216.49]:48837 "EHLO
	mail-qa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751364AbaGBEJN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 00:09:13 -0400
Received: by mail-qa0-f49.google.com with SMTP id w8so8309314qac.22
        for <netdev@vger.kernel.org>; Tue, 01 Jul 2014 21:09:12 -0700 (PDT)
In-Reply-To: <1404274120-5717-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Support for Wake-on-LAN using Magic Packet with or without SecureOn
password is implemented doing the following:

- setting the password to the relevant UniMAC registers
- flagging the device as a wakeup source for the system, as well as
  its Wake-on-LAN interrupt
- prepare the hardware for entering WoL mode
- enabling the MPD interrupt to wake us

The Device Tree binding documentation is also reflected to specify the
third optional Wake-on-LAN interrupt line.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 .../bindings/net/broadcom-systemport.txt           |   3 +-
 drivers/net/ethernet/broadcom/bcmsysport.c         | 155 ++++++++++++++++++++-
 drivers/net/ethernet/broadcom/bcmsysport.h         |  12 ++
 3 files changed, 166 insertions(+), 4 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/broadcom-systemport.txt b/Documentation/devicetree/bindings/net/broadcom-systemport.txt
index c183ea90d9bc..aa7ad622259d 100644
--- a/Documentation/devicetree/bindings/net/broadcom-systemport.txt
+++ b/Documentation/devicetree/bindings/net/broadcom-systemport.txt
@@ -4,7 +4,8 @@ Required properties:
 - compatible: should be one of "brcm,systemport-v1.00" or "brcm,systemport"
 - reg: address and length of the register set for the device.
 - interrupts: interrupts for the device, first cell must be for the the rx
-  interrupts, and the second cell should be for the transmit queues
+  interrupts, and the second cell should be for the transmit queues. An
+  optional third interrupt cell for Wake-on-LAN can be specified
 - local-mac-address: Ethernet MAC address (48 bits) of this adapter
 - phy-mode: Should be a string describing the PHY interface to the
   Ethernet switch/PHY, see Documentation/devicetree/bindings/net/ethernet.txt
diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index f00793e45330..7a1bd2b3bc26 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -384,6 +384,64 @@ static void bcm_sysport_get_stats(struct net_device *dev,
 	}
 }
 
+static void bcm_sysport_get_wol(struct net_device *dev,
+				struct ethtool_wolinfo *wol)
+{
+	struct bcm_sysport_priv *priv = netdev_priv(dev);
+	u32 reg;
+
+	wol->supported = WAKE_MAGIC | WAKE_MAGICSECURE;
+	wol->wolopts = priv->wolopts;
+
+	if (!(priv->wolopts & WAKE_MAGICSECURE))
+		return;
+
+	/* Return the programmed SecureOn password */
+	reg = umac_readl(priv, UMAC_PSW_MS);
+	put_unaligned_be16(reg, &wol->sopass[0]);
+	reg = umac_readl(priv, UMAC_PSW_LS);
+	put_unaligned_be32(reg, &wol->sopass[2]);
+}
+
+static int bcm_sysport_set_wol(struct net_device *dev,
+				struct ethtool_wolinfo *wol)
+{
+	struct bcm_sysport_priv *priv = netdev_priv(dev);
+	struct device *kdev = &priv->pdev->dev;
+	u32 supported = WAKE_MAGIC | WAKE_MAGICSECURE;
+
+	if (!device_can_wakeup(kdev))
+		return -ENOTSUPP;
+
+	if (wol->wolopts & ~supported)
+		return -EINVAL;
+
+	/* Program the SecureOn password */
+	if (wol->wolopts & WAKE_MAGICSECURE) {
+		umac_writel(priv, get_unaligned_be16(&wol->sopass[0]),
+				UMAC_PSW_MS);
+		umac_writel(priv, get_unaligned_be32(&wol->sopass[2]),
+				UMAC_PSW_LS);
+	}
+
+	/* Flag the device and relevant IRQ as wakeup capable */
+	if (wol->wolopts) {
+		device_set_wakeup_enable(kdev, 1);
+		enable_irq_wake(priv->wol_irq);
+		priv->wol_irq_disabled = 0;
+	} else {
+		device_set_wakeup_enable(kdev, 0);
+		/* Avoid unbalanced disable_irq_wake calls */
+		if (!priv->wol_irq_disabled)
+			disable_irq_wake(priv->wol_irq);
+		priv->wol_irq_disabled = 1;
+	}
+
+	priv->wolopts = wol->wolopts;
+
+	return 0;
+}
+
 static void bcm_sysport_free_cb(struct bcm_sysport_cb *cb)
 {
 	dev_kfree_skb_any(cb->skb);
@@ -692,6 +750,20 @@ static int bcm_sysport_poll(struct napi_struct *napi, int budget)
 	return work_done;
 }
 
+static void bcm_sysport_resume_from_wol(struct bcm_sysport_priv *priv)
+{
+	u32 reg;
+
+	/* Stop monitoring MPD interrupt */
+	intrl2_0_mask_set(priv, INTRL2_0_MPD);
+
+	/* Clear the MagicPacket detection logic */
+	reg = umac_readl(priv, UMAC_MPD_CTRL);
+	reg &= ~MPD_EN;
+	umac_writel(priv, reg, UMAC_MPD_CTRL);
+
+	netif_dbg(priv, wol, priv->netdev, "resumed from WOL\n");
+}
 
 /* RX and misc interrupt routine */
 static irqreturn_t bcm_sysport_rx_isr(int irq, void *dev_id)
@@ -722,6 +794,11 @@ static irqreturn_t bcm_sysport_rx_isr(int irq, void *dev_id)
 	if (priv->irq0_stat & INTRL2_0_TX_RING_FULL)
 		bcm_sysport_tx_reclaim_all(priv);
 
+	if (priv->irq0_stat & INTRL2_0_MPD) {
+		netdev_info(priv->netdev, "Wake-on-LAN interrupt!\n");
+		bcm_sysport_resume_from_wol(priv);
+	}
+
 	return IRQ_HANDLED;
 }
 
@@ -757,6 +834,15 @@ static irqreturn_t bcm_sysport_tx_isr(int irq, void *dev_id)
 	return IRQ_HANDLED;
 }
 
+static irqreturn_t bcm_sysport_wol_isr(int irq, void *dev_id)
+{
+	struct bcm_sysport_priv *priv = dev_id;
+
+	pm_wakeup_event(&priv->pdev->dev, 0);
+
+	return IRQ_HANDLED;
+}
+
 static int bcm_sysport_insert_tsb(struct sk_buff *skb, struct net_device *dev)
 {
 	struct sk_buff *nskb;
@@ -1507,6 +1593,8 @@ static struct ethtool_ops bcm_sysport_ethtool_ops = {
 	.get_strings		= bcm_sysport_get_strings,
 	.get_ethtool_stats	= bcm_sysport_get_stats,
 	.get_sset_count		= bcm_sysport_get_sset_count,
+	.get_wol		= bcm_sysport_get_wol,
+	.set_wol		= bcm_sysport_set_wol,
 };
 
 static const struct net_device_ops bcm_sysport_netdev_ops = {
@@ -1548,6 +1636,7 @@ static int bcm_sysport_probe(struct platform_device *pdev)
 
 	priv->irq0 = platform_get_irq(pdev, 0);
 	priv->irq1 = platform_get_irq(pdev, 1);
+	priv->wol_irq = platform_get_irq(pdev, 2);
 	if (priv->irq0 <= 0 || priv->irq1 <= 0) {
 		dev_err(&pdev->dev, "invalid interrupts\n");
 		ret = -EINVAL;
@@ -1600,6 +1689,13 @@ static int bcm_sysport_probe(struct platform_device *pdev)
 	dev->hw_features |= NETIF_F_RXCSUM | NETIF_F_HIGHDMA |
 				NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
 
+	/* Request the WOL interrupt and advertise suspend if available */
+	priv->wol_irq_disabled = 1;
+	ret = devm_request_irq(&pdev->dev, priv->wol_irq,
+				bcm_sysport_wol_isr, 0, dev->name, priv);
+	if (!ret)
+		device_set_wakeup_capable(&pdev->dev, 1);
+
 	/* Set the needed headroom once and for all */
 	BUILD_BUG_ON(sizeof(struct bcm_tsb) != 8);
 	dev->needed_headroom += sizeof(struct bcm_tsb);
@@ -1647,12 +1743,55 @@ static int bcm_sysport_remove(struct platform_device *pdev)
 }
 
 #ifdef CONFIG_PM_SLEEP
+static int bcm_sysport_suspend_to_wol(struct bcm_sysport_priv *priv)
+{
+	struct net_device *ndev = priv->netdev;
+	unsigned int timeout = 1000;
+	u32 reg;
+
+	/* Password has already been programmed */
+	reg = umac_readl(priv, UMAC_MPD_CTRL);
+	reg |= MPD_EN;
+	reg &= ~PSW_EN;
+	if (priv->wolopts & WAKE_MAGICSECURE)
+		reg |= PSW_EN;
+	umac_writel(priv, reg, UMAC_MPD_CTRL);
+
+	/* Make sure RBUF entered WoL mode as result */
+	do {
+		reg = rbuf_readl(priv, RBUF_STATUS);
+		if (reg & RBUF_WOL_MODE)
+			break;
+
+		udelay(10);
+	} while (timeout-- > 0);
+
+	/* Do not leave the UniMAC RBUF matching only MPD packets */
+	if (!timeout) {
+		reg = umac_readl(priv, UMAC_MPD_CTRL);
+		reg &= ~MPD_EN;
+		umac_writel(priv, reg, UMAC_MPD_CTRL);
+		netif_err(priv, wol, ndev, "failed to enter WOL mode\n");
+		return -ETIMEDOUT;
+	}
+
+	/* UniMAC receive needs to be turned on */
+	umac_enable_set(priv, CMD_RX_EN, 1);
+
+	/* Enable the interrupt wake-up source */
+	intrl2_0_mask_clear(priv, INTRL2_0_MPD);
+
+	netif_dbg(priv, wol, ndev, "entered WOL mode\n");
+
+	return 0;
+}
+
 static int bcm_sysport_suspend(struct device *d)
 {
 	struct net_device *dev = dev_get_drvdata(d);
 	struct bcm_sysport_priv *priv = netdev_priv(dev);
 	unsigned int i;
-	int ret;
+	int ret = 0;
 	u32 reg;
 
 	if (!netif_running(dev))
@@ -1681,7 +1820,8 @@ static int bcm_sysport_suspend(struct device *d)
 	}
 
 	/* Flush RX pipe */
-	topctrl_writel(priv, RX_FLUSH, RX_FLUSH_CNTL);
+	if (!priv->wolopts)
+		topctrl_writel(priv, RX_FLUSH, RX_FLUSH_CNTL);
 
 	ret = tdma_enable_set(priv, 0);
 	if (ret) {
@@ -1701,7 +1841,11 @@ static int bcm_sysport_suspend(struct device *d)
 		bcm_sysport_fini_tx_ring(priv, i);
 	bcm_sysport_fini_rx_ring(priv);
 
-	return 0;
+	/* Get prepared for Wake-on-LAN */
+	if (device_may_wakeup(d) && priv->wolopts)
+		ret = bcm_sysport_suspend_to_wol(priv);
+
+	return ret;
 }
 
 static int bcm_sysport_resume(struct device *d)
@@ -1715,6 +1859,11 @@ static int bcm_sysport_resume(struct device *d)
 	if (!netif_running(dev))
 		return 0;
 
+	/* We may have been suspended and never received a WOL event that
+	 * would turn off MPD detection, take care of that now
+	 */
+	bcm_sysport_resume_from_wol(priv);
+
 	/* Initialize both hardware and software ring */
 	for (i = 0; i < dev->num_tx_queues; i++) {
 		ret = bcm_sysport_init_tx_ring(priv, i);
diff --git a/drivers/net/ethernet/broadcom/bcmsysport.h b/drivers/net/ethernet/broadcom/bcmsysport.h
index 20ea7162478f..b08dab828101 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.h
+++ b/drivers/net/ethernet/broadcom/bcmsysport.h
@@ -246,6 +246,15 @@ struct bcm_rsb {
 #define  MIB_RX_CNT_RST			(1 << 0)
 #define  MIB_RUNT_CNT_RST		(1 << 1)
 #define  MIB_TX_CNT_RST			(1 << 2)
+
+#define UMAC_MPD_CTRL			0x620
+#define  MPD_EN				(1 << 0)
+#define  MSEQ_LEN_SHIFT			16
+#define  MSEQ_LEN_MASK			0xff
+#define  PSW_EN				(1 << 27)
+
+#define UMAC_PSW_MS			0x624
+#define UMAC_PSW_LS			0x628
 #define UMAC_MDF_CTRL			0x650
 #define UMAC_MDF_ADDR			0x654
 
@@ -642,6 +651,7 @@ struct bcm_sysport_priv {
 	struct platform_device	*pdev;
 	int			irq0;
 	int			irq1;
+	int			wol_irq;
 
 	/* Transmit rings */
 	struct bcm_sysport_tx_ring tx_rings[TDMA_NUM_RINGS];
@@ -668,6 +678,8 @@ struct bcm_sysport_priv {
 	unsigned int		tsb_en:1;
 	unsigned int		crc_fwd:1;
 	u16			rev;
+	u32			wolopts;
+	unsigned int		wol_irq_disabled:1;
 
 	/* MIB related fields */
 	struct bcm_sysport_mib	mib;
-- 
1.9.1

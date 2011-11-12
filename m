From: Sanjay Hortikar <horti@google.com>
Subject: [PATCH net-next v2] net-forcedeth: Add internal loopback support for forcedeth NICs.
Date: Fri, 11 Nov 2011 18:11:21 -0800
Message-ID: <0a790bcdac9827d6e4a9162cc8f6b5bcb70acd4e.1321063429.git.horti@google.com>
References: <cover.1321063429.git.horti@google.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	David Decotigny <david.decotigny@google.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	Rick Jones <rick.jones2@hp.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Sanjay Hortikar <horti@google.com>,
	Mahesh Bandewar <maheshb@google.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1321063429.git.horti@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Support enabling/disabling/querying internal loopback mode for
forcedeth NICs using ethtool.

Signed-off-by: Sanjay Hortikar <horti@google.com>
Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 drivers/net/ethernet/nvidia/forcedeth.c |  156 ++++++++++++++++++++++++++++++-
 1 files changed, 155 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index d24c45b..e8a5ae3 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -3003,6 +3003,73 @@ static void nv_update_pause(struct net_device *dev, u32 pause_flags)
 	}
 }
 
+static void nv_force_linkspeed(struct net_device *dev, int speed, int duplex)
+{
+	struct fe_priv *np = netdev_priv(dev);
+	u8 __iomem *base = get_hwbase(dev);
+	u32 phyreg, txreg;
+	int mii_status;
+
+	np->linkspeed = NVREG_LINKSPEED_FORCE|speed;
+	np->duplex = duplex;
+
+	/* see if gigabit phy */
+	mii_status = mii_rw(dev, np->phyaddr, MII_BMSR, MII_READ);
+	if (mii_status & PHY_GIGABIT) {
+		np->gigabit = PHY_GIGABIT;
+		phyreg = readl(base + NvRegSlotTime);
+		phyreg &= ~(0x3FF00);
+		if ((np->linkspeed & 0xFFF) == NVREG_LINKSPEED_10)
+			phyreg |= NVREG_SLOTTIME_10_100_FULL;
+		else if ((np->linkspeed & 0xFFF) == NVREG_LINKSPEED_100)
+			phyreg |= NVREG_SLOTTIME_10_100_FULL;
+		else if ((np->linkspeed & 0xFFF) == NVREG_LINKSPEED_1000)
+			phyreg |= NVREG_SLOTTIME_1000_FULL;
+		writel(phyreg, base + NvRegSlotTime);
+	}
+
+	phyreg = readl(base + NvRegPhyInterface);
+	phyreg &= ~(PHY_HALF|PHY_100|PHY_1000);
+	if (np->duplex == 0)
+		phyreg |= PHY_HALF;
+	if ((np->linkspeed & NVREG_LINKSPEED_MASK) == NVREG_LINKSPEED_100)
+		phyreg |= PHY_100;
+	else if ((np->linkspeed & NVREG_LINKSPEED_MASK) ==
+							NVREG_LINKSPEED_1000)
+		phyreg |= PHY_1000;
+	writel(phyreg, base + NvRegPhyInterface);
+
+	if (phyreg & PHY_RGMII) {
+		if ((np->linkspeed & NVREG_LINKSPEED_MASK) ==
+							NVREG_LINKSPEED_1000)
+			txreg = NVREG_TX_DEFERRAL_RGMII_1000;
+		else
+			txreg = NVREG_TX_DEFERRAL_RGMII_10_100;
+	} else {
+		txreg = NVREG_TX_DEFERRAL_DEFAULT;
+	}
+	writel(txreg, base + NvRegTxDeferral);
+
+	if (np->desc_ver == DESC_VER_1) {
+		txreg = NVREG_TX_WM_DESC1_DEFAULT;
+	} else {
+		if ((np->linkspeed & NVREG_LINKSPEED_MASK) ==
+					 NVREG_LINKSPEED_1000)
+			txreg = NVREG_TX_WM_DESC2_3_1000;
+		else
+			txreg = NVREG_TX_WM_DESC2_3_DEFAULT;
+	}
+	writel(txreg, base + NvRegTxWatermark);
+
+	writel(NVREG_MISC1_FORCE | (np->duplex ? 0 : NVREG_MISC1_HD),
+			base + NvRegMisc1);
+	pci_push(base);
+	writel(np->linkspeed, base + NvRegLinkSpeed);
+	pci_push(base);
+
+	return;
+}
+
 /**
  * nv_update_linkspeed: Setup the MAC according to the link partner
  * @dev: Network device to be configured
@@ -3024,11 +3091,25 @@ static int nv_update_linkspeed(struct net_device *dev)
 	int newls = np->linkspeed;
 	int newdup = np->duplex;
 	int mii_status;
+	u32 bmcr;
 	int retval = 0;
 	u32 control_1000, status_1000, phyreg, pause_flags, txreg;
 	u32 txrxFlags = 0;
 	u32 phy_exp;
 
+	/* If device loopback is enabled, set carrier on and enable max link
+	 * speed.
+	 */
+	bmcr = mii_rw(dev, np->phyaddr, MII_BMCR, MII_READ);
+	if (bmcr & BMCR_LOOPBACK) {
+		if (netif_running(dev)) {
+			nv_force_linkspeed(dev, NVREG_LINKSPEED_1000, 1);
+			if (!netif_carrier_ok(dev))
+				netif_carrier_on(dev);
+		}
+		return 1;
+	}
+
 	/* BMSR_LSTATUS is latched, read it twice:
 	 * we want the current value.
 	 */
@@ -4455,6 +4536,61 @@ static int nv_set_pauseparam(struct net_device *dev, struct ethtool_pauseparam*
 	return 0;
 }
 
+static int nv_set_loopback(struct net_device *dev, u32 features)
+{
+	struct fe_priv *np = netdev_priv(dev);
+	unsigned long flags;
+	u32 miicontrol;
+	int err, retval = 0;
+
+	spin_lock_irqsave(&np->lock, flags);
+	miicontrol = mii_rw(dev, np->phyaddr, MII_BMCR, MII_READ);
+	if (features & NETIF_F_LOOPBACK) {
+		if (miicontrol & BMCR_LOOPBACK) {
+			spin_unlock_irqrestore(&np->lock, flags);
+			netdev_info(dev, "Loopback already enabled\n");
+			return 0;
+		}
+		nv_disable_irq(dev);
+		/* Turn on loopback mode */
+		miicontrol |= BMCR_LOOPBACK | BMCR_FULLDPLX | BMCR_SPEED1000;
+		err = mii_rw(dev, np->phyaddr, MII_BMCR, miicontrol);
+		if (err) {
+			retval = PHY_ERROR;
+			spin_unlock_irqrestore(&np->lock, flags);
+			phy_init(dev);
+		} else {
+			if (netif_running(dev)) {
+				/* Force 1000 Mbps full-duplex */
+				nv_force_linkspeed(dev, NVREG_LINKSPEED_1000,
+									 1);
+				/* Force link up */
+				netif_carrier_on(dev);
+			}
+			spin_unlock_irqrestore(&np->lock, flags);
+			netdev_info(dev,
+				"Internal PHY loopback mode enabled.\n");
+		}
+	} else {
+		if (!(miicontrol & BMCR_LOOPBACK)) {
+			spin_unlock_irqrestore(&np->lock, flags);
+			netdev_info(dev, "Loopback already disabled\n");
+			return 0;
+		}
+		nv_disable_irq(dev);
+		/* Turn off loopback */
+		spin_unlock_irqrestore(&np->lock, flags);
+		netdev_info(dev, "Internal PHY loopback mode disabled.\n");
+		phy_init(dev);
+	}
+	msleep(500);
+	spin_lock_irqsave(&np->lock, flags);
+	nv_enable_irq(dev);
+	spin_unlock_irqrestore(&np->lock, flags);
+
+	return retval;
+}
+
 static u32 nv_fix_features(struct net_device *dev, u32 features)
 {
 	/* vlan is dependent on rx checksum offload */
@@ -4490,6 +4626,13 @@ static int nv_set_features(struct net_device *dev, u32 features)
 	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base = get_hwbase(dev);
 	u32 changed = dev->features ^ features;
+	int retval;
+
+	if ((changed & NETIF_F_LOOPBACK) && netif_running(dev)) {
+		retval = nv_set_loopback(dev, features);
+		if (retval != 0)
+			return retval;
+	}
 
 	if (changed & NETIF_F_RXCSUM) {
 		spin_lock_irq(&np->lock);
@@ -5124,6 +5267,12 @@ static int nv_open(struct net_device *dev)
 
 	spin_unlock_irq(&np->lock);
 
+	/* If the loopback feature was set while the device was down, make sure
+	 * that it's set correctly now.
+	 */
+	if (dev->features & NETIF_F_LOOPBACK)
+		nv_set_loopback(dev, dev->features);
+
 	return 0;
 out_drain:
 	nv_drain_rxtx(dev);
@@ -5328,6 +5477,9 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 
 	dev->features |= dev->hw_features;
 
+	/* Add loopback capability to the device. */
+	dev->hw_features |= NETIF_F_LOOPBACK;
+
 	np->pause_flags = NV_PAUSEFRAME_RX_CAPABLE | NV_PAUSEFRAME_RX_REQ | NV_PAUSEFRAME_AUTONEG;
 	if ((id->driver_data & DEV_HAS_PAUSEFRAME_TX_V1) ||
 	    (id->driver_data & DEV_HAS_PAUSEFRAME_TX_V2) ||
@@ -5603,12 +5755,14 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 	dev_info(&pci_dev->dev, "ifname %s, PHY OUI 0x%x @ %d, addr %pM\n",
 		 dev->name, np->phy_oui, np->phyaddr, dev->dev_addr);
 
-	dev_info(&pci_dev->dev, "%s%s%s%s%s%s%s%s%s%sdesc-v%u\n",
+	dev_info(&pci_dev->dev, "%s%s%s%s%s%s%s%s%s%s%sdesc-v%u\n",
 		 dev->features & NETIF_F_HIGHDMA ? "highdma " : "",
 		 dev->features & (NETIF_F_IP_CSUM | NETIF_F_SG) ?
 			"csum " : "",
 		 dev->features & (NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_TX) ?
 			"vlan " : "",
+		 dev->features & (NETIF_F_LOOPBACK) ?
+			"loopback " : "",
 		 id->driver_data & DEV_HAS_POWER_CNTRL ? "pwrctl " : "",
 		 id->driver_data & DEV_HAS_MGMT_UNIT ? "mgmt " : "",
 		 id->driver_data & DEV_NEED_TIMERIRQ ? "timirq " : "",
-- 
1.7.3.1

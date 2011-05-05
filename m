From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCHv2] forcedeth: Allow ethtool to enable/disable loopback.
Date: Wed,  4 May 2011 18:36:40 -0700
Message-ID: <1304559400-16257-1-git-send-email-maheshb@google.com>
References: <1304472127-652-1-git-send-email-maheshb@google.com>
Cc: netdev <netdev@vger.kernel.org>, Tom Herbert <therbert@google.com>,
	Mahesh Bandewar <maheshb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:59840 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752316Ab1EECMJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2011 22:12:09 -0400
In-Reply-To: <1304472127-652-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch updates nv_set_features() to handle loopback mode.
When enabled; it sets internal-PHY loopback.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
Changes since v1:
 Clear the loopback bit in ndo_open callback to avoid features discrepancy.

 drivers/net/forcedeth.c |   61 +++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 61 insertions(+), 0 deletions(-)

diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index d09e8b0..55eb558 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -4474,6 +4474,53 @@ static int nv_set_pauseparam(struct net_device *dev, struct ethtool_pauseparam*
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
+			return retval;
+		}
+		nv_disable_irq(dev);
+		/* Turn on loopback mode */
+		miicontrol |= BMCR_LOOPBACK | BMCR_FULLDPLX;
+		err = mii_rw(dev, np->phyaddr, MII_BMCR, miicontrol);
+		if (err) {
+			err = -EAGAIN;
+			spin_unlock_irqrestore(&np->lock, flags);
+			phy_init(dev);
+		} else {
+			/* Force link up */
+			netif_carrier_on(dev);
+			spin_unlock_irqrestore(&np->lock, flags);
+			netdev_info(dev, "Internal PHY loopback mode enabled.\n");
+		}
+	} else {
+		if (!(miicontrol & BMCR_LOOPBACK)) {
+			spin_unlock_irqrestore(&np->lock, flags);
+			return retval;
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
@@ -4502,6 +4549,9 @@ static int nv_set_features(struct net_device *dev, u32 features)
 
 		spin_unlock_irq(&np->lock);
 	}
+	if ((changed & NETIF_F_LOOPBACK) && netif_running(dev)) {
+		nv_set_loopback(dev, features);
+	}
 
 	return 0;
 }
@@ -5142,6 +5192,14 @@ static int nv_open(struct net_device *dev)
 
 	spin_unlock_irq(&np->lock);
 
+	/* If the loopback feature was set while the device was down, make sure
+	 * that it's cleared to avoid any discrepancy in features reporting.
+	 */
+	if (dev->features & NETIF_F_LOOPBACK) {
+		dev->features &= ~NETIF_F_LOOPBACK;
+		dev->wanted_features &= ~NETIF_F_LOOPBACK;
+	}
+
 	return 0;
 out_drain:
 	nv_drain_rxtx(dev);
@@ -5341,6 +5399,9 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 		dev->features |= dev->hw_features;
 	}
 
+	/* Add loopback capability to the device. */
+	dev->hw_features |= NETIF_F_LOOPBACK;
+
 	np->vlanctl_bits = 0;
 	if (id->driver_data & DEV_HAS_VLAN) {
 		np->vlanctl_bits = NVREG_VLANCONTROL_ENABLE;
-- 
1.7.3.1


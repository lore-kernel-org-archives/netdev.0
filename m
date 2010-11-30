From: =?utf-8?q?Micha=C5=82?= =?utf-8?b?TWlyb3PFgmF3?=
	<mirq-linux@rere.qmqm.pl>
Subject: [PATCH] net: Fix too optimistic NETIF_F_HW_CSUM features
Date: Tue, 30 Nov 2010 15:23:52 +0100
Message-ID: <20101130142352.3936.51663.stgit@rechot.qmqm.pl>
References: <fddashfjkasdhklfjashlkjfs@rechot.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Jesse Gross <jesse@nicira.com>
To: netdev@vget.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:56611 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752246Ab0K3OtS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Nov 2010 09:49:18 -0500
In-Reply-To: <fddashfjkasdhklfjashlkjfs@rechot.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NETIF_F_HW_CSUM is superset of NETIF_F_IP_CSUM+NETIF_F_IPV6_CSUM, but
some drivers miss the difference. Fix this and also fix UFO dependency
on checksumming offload as it makes the same mistake in assumptions.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/benet/be_main.c           |    6 ++++--
 drivers/net/bnx2x/bnx2x_main.c        |    4 ++--
 drivers/net/jme.c                     |   16 +++++++++-------
 drivers/net/pch_gbe/pch_gbe_ethtool.c |   19 +------------------
 drivers/net/pch_gbe/pch_gbe_main.c    |    6 +++---
 drivers/net/sc92031.c                 |    3 ++-
 drivers/net/stmmac/stmmac_ethtool.c   |   12 +-----------
 drivers/net/stmmac/stmmac_main.c      |    5 +++--
 drivers/net/vxge/vxge-ethtool.c       |    2 +-
 drivers/net/vxge/vxge-main.c          |    2 +-
 net/core/dev.c                        |    7 +++++--
 net/core/ethtool.c                    |    4 +++-
 12 files changed, 35 insertions(+), 51 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 102567e..2754280 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -2583,10 +2583,12 @@ static void be_netdev_init(struct net_device *n=
etdev)
 	int i;
=20
 	netdev->features |=3D NETIF_F_SG | NETIF_F_HW_VLAN_RX | NETIF_F_TSO |
-		NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_FILTER | NETIF_F_HW_CSUM |
+		NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_FILTER |
+		NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
 		NETIF_F_GRO | NETIF_F_TSO6;
=20
-	netdev->vlan_features |=3D NETIF_F_SG | NETIF_F_TSO | NETIF_F_HW_CSUM=
;
+	netdev->vlan_features |=3D NETIF_F_SG | NETIF_F_TSO |
+		NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
=20
 	if (lancer_chip(adapter))
 		netdev->vlan_features |=3D NETIF_F_TSO6;
diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_m=
ain.c
index f53edfd..40ce95a 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -8761,7 +8761,7 @@ static int __devinit bnx2x_init_dev(struct pci_de=
v *pdev,
 	dev->netdev_ops =3D &bnx2x_netdev_ops;
 	bnx2x_set_ethtool_ops(dev);
 	dev->features |=3D NETIF_F_SG;
-	dev->features |=3D NETIF_F_HW_CSUM;
+	dev->features |=3D NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
 	if (bp->flags & USING_DAC_FLAG)
 		dev->features |=3D NETIF_F_HIGHDMA;
 	dev->features |=3D (NETIF_F_TSO | NETIF_F_TSO_ECN);
@@ -8769,7 +8769,7 @@ static int __devinit bnx2x_init_dev(struct pci_de=
v *pdev,
 	dev->features |=3D (NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX);
=20
 	dev->vlan_features |=3D NETIF_F_SG;
-	dev->vlan_features |=3D NETIF_F_HW_CSUM;
+	dev->vlan_features |=3D NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
 	if (bp->flags & USING_DAC_FLAG)
 		dev->vlan_features |=3D NETIF_F_HIGHDMA;
 	dev->vlan_features |=3D (NETIF_F_TSO | NETIF_F_TSO_ECN);
diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index c57d9a4..ad0935c 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -2076,12 +2076,11 @@ jme_change_mtu(struct net_device *netdev, int n=
ew_mtu)
 	}
=20
 	if (new_mtu > 1900) {
-		netdev->features &=3D ~(NETIF_F_HW_CSUM |
-				NETIF_F_TSO |
-				NETIF_F_TSO6);
+		netdev->features &=3D ~(NETIF_F_IP_CSUM | NETIFI_F_IPV6_CSUM |
+				NETIF_F_TSO | NETIF_F_TSO6);
 	} else {
 		if (test_bit(JME_FLAG_TXCSUM, &jme->flags))
-			netdev->features |=3D NETIF_F_HW_CSUM;
+			netdev->features |=3D NETIF_F_IP_CSUM | NETIFI_F_IPV6_CSUM;
 		if (test_bit(JME_FLAG_TSO, &jme->flags))
 			netdev->features |=3D NETIF_F_TSO | NETIF_F_TSO6;
 	}
@@ -2514,10 +2513,12 @@ jme_set_tx_csum(struct net_device *netdev, u32 =
on)
 	if (on) {
 		set_bit(JME_FLAG_TXCSUM, &jme->flags);
 		if (netdev->mtu <=3D 1900)
-			netdev->features |=3D NETIF_F_HW_CSUM;
+			netdev->features |=3D
+				NETIF_F_IP_CSUM | NETIFI_F_IPV6_CSUM;
 	} else {
 		clear_bit(JME_FLAG_TXCSUM, &jme->flags);
-		netdev->features &=3D ~NETIF_F_HW_CSUM;
+		netdev->features &=3D
+				~(NETIF_F_IP_CSUM | NETIFI_F_IPV6_CSUM);
 	}
=20
 	return 0;
@@ -2797,7 +2798,8 @@ jme_init_one(struct pci_dev *pdev,
 	netdev->netdev_ops =3D &jme_netdev_ops;
 	netdev->ethtool_ops		=3D &jme_ethtool_ops;
 	netdev->watchdog_timeo		=3D TX_TIMEOUT;
-	netdev->features		=3D	NETIF_F_HW_CSUM |
+	netdev->features		=3D	NETIF_F_IP_CSUM |
+						NETIF_F_IPV6_CSUM |
 						NETIF_F_SG |
 						NETIF_F_TSO |
 						NETIF_F_TSO6 |
diff --git a/drivers/net/pch_gbe/pch_gbe_ethtool.c b/drivers/net/pch_gb=
e/pch_gbe_ethtool.c
index c8cc32c..c8c873b 100644
--- a/drivers/net/pch_gbe/pch_gbe_ethtool.c
+++ b/drivers/net/pch_gbe/pch_gbe_ethtool.c
@@ -469,18 +469,6 @@ static int pch_gbe_set_rx_csum(struct net_device *=
netdev, u32 data)
 }
=20
 /**
- * pch_gbe_get_tx_csum - Report whether transmit checksums are turned =
on or off
- * @netdev:  Network interface device structure
- * Returns
- *	true(1):  Checksum On
- *	false(0): Checksum Off
- */
-static u32 pch_gbe_get_tx_csum(struct net_device *netdev)
-{
-	return (netdev->features & NETIF_F_HW_CSUM) !=3D 0;
-}
-
-/**
  * pch_gbe_set_tx_csum - Turn transmit checksums on or off
  * @netdev: Network interface device structure
  * @data:   Checksum on[true] or off[false]
@@ -493,11 +481,7 @@ static int pch_gbe_set_tx_csum(struct net_device *=
netdev, u32 data)
 	struct pch_gbe_adapter *adapter =3D netdev_priv(netdev);
=20
 	adapter->tx_csum =3D data;
-	if (data)
-		netdev->features |=3D NETIF_F_HW_CSUM;
-	else
-		netdev->features &=3D ~NETIF_F_HW_CSUM;
-	return 0;
+	return ethtool_op_set_tx_ipv6_csum(netdev, data);
 }
=20
 /**
@@ -572,7 +556,6 @@ static const struct ethtool_ops pch_gbe_ethtool_ops=
 =3D {
 	.set_pauseparam =3D pch_gbe_set_pauseparam,
 	.get_rx_csum =3D pch_gbe_get_rx_csum,
 	.set_rx_csum =3D pch_gbe_set_rx_csum,
-	.get_tx_csum =3D pch_gbe_get_tx_csum,
 	.set_tx_csum =3D pch_gbe_set_tx_csum,
 	.get_strings =3D pch_gbe_get_strings,
 	.get_ethtool_stats =3D pch_gbe_get_ethtool_stats,
diff --git a/drivers/net/pch_gbe/pch_gbe_main.c b/drivers/net/pch_gbe/p=
ch_gbe_main.c
index afb7506..58e7903 100644
--- a/drivers/net/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/pch_gbe/pch_gbe_main.c
@@ -2319,7 +2319,7 @@ static int pch_gbe_probe(struct pci_dev *pdev,
 	netdev->watchdog_timeo =3D PCH_GBE_WATCHDOG_PERIOD;
 	netif_napi_add(netdev, &adapter->napi,
 		       pch_gbe_napi_poll, PCH_GBE_RX_WEIGHT);
-	netdev->features =3D NETIF_F_HW_CSUM | NETIF_F_GRO;
+	netdev->features =3D NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM | NETIF_F_GR=
O;
 	pch_gbe_set_ethtool_ops(netdev);
=20
 	pch_gbe_mac_reset_hw(&adapter->hw);
@@ -2358,9 +2358,9 @@ static int pch_gbe_probe(struct pci_dev *pdev,
 	pch_gbe_check_options(adapter);
=20
 	if (adapter->tx_csum)
-		netdev->features |=3D NETIF_F_HW_CSUM;
+		netdev->features |=3D NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
 	else
-		netdev->features &=3D ~NETIF_F_HW_CSUM;
+		netdev->features &=3D ~(NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM);
=20
 	/* initialize the wol settings based on the eeprom settings */
 	adapter->wake_up_evt =3D PCH_GBE_WL_INIT_SETTING;
diff --git a/drivers/net/sc92031.c b/drivers/net/sc92031.c
index 417adf3..76290a8 100644
--- a/drivers/net/sc92031.c
+++ b/drivers/net/sc92031.c
@@ -1449,7 +1449,8 @@ static int __devinit sc92031_probe(struct pci_dev=
 *pdev,
 	dev->irq =3D pdev->irq;
=20
 	/* faked with skb_copy_and_csum_dev */
-	dev->features =3D NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_HIGHDMA;
+	dev->features =3D NETIF_F_SG | NETIF_F_HIGHDMA |
+		NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
=20
 	dev->netdev_ops		=3D &sc92031_netdev_ops;
 	dev->watchdog_timeo	=3D TX_TIMEOUT;
diff --git a/drivers/net/stmmac/stmmac_ethtool.c b/drivers/net/stmmac/s=
tmmac_ethtool.c
index f2695fd..fd719ed 100644
--- a/drivers/net/stmmac/stmmac_ethtool.c
+++ b/drivers/net/stmmac/stmmac_ethtool.c
@@ -197,16 +197,6 @@ static void stmmac_ethtool_gregs(struct net_device=
 *dev,
 	}
 }
=20
-static int stmmac_ethtool_set_tx_csum(struct net_device *netdev, u32 d=
ata)
-{
-	if (data)
-		netdev->features |=3D NETIF_F_HW_CSUM;
-	else
-		netdev->features &=3D ~NETIF_F_HW_CSUM;
-
-	return 0;
-}
-
 static u32 stmmac_ethtool_get_rx_csum(struct net_device *dev)
 {
 	struct stmmac_priv *priv =3D netdev_priv(dev);
@@ -370,7 +360,7 @@ static struct ethtool_ops stmmac_ethtool_ops =3D {
 	.get_link =3D ethtool_op_get_link,
 	.get_rx_csum =3D stmmac_ethtool_get_rx_csum,
 	.get_tx_csum =3D ethtool_op_get_tx_csum,
-	.set_tx_csum =3D stmmac_ethtool_set_tx_csum,
+	.set_tx_csum =3D ethtool_op_set_tx_ipv6_csum,
 	.get_sg =3D ethtool_op_get_sg,
 	.set_sg =3D ethtool_op_set_sg,
 	.get_pauseparam =3D stmmac_get_pauseparam,
diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmm=
ac_main.c
index 730a6fd..bfc2d12 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -1494,7 +1494,8 @@ static int stmmac_probe(struct net_device *dev)
 	dev->netdev_ops =3D &stmmac_netdev_ops;
 	stmmac_set_ethtool_ops(dev);
=20
-	dev->features |=3D (NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_HIGHDMA);
+	dev->features |=3D NETIF_F_SG | NETIF_F_HIGHDMA |
+		NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
 	dev->watchdog_timeo =3D msecs_to_jiffies(watchdog);
 #ifdef STMMAC_VLAN_TAG_USED
 	/* Both mac100 and gmac support receive VLAN tag detection */
@@ -1525,7 +1526,7 @@ static int stmmac_probe(struct net_device *dev)
=20
 	DBG(probe, DEBUG, "%s: Scatter/Gather: %s - HW checksums: %s\n",
 	    dev->name, (dev->features & NETIF_F_SG) ? "on" : "off",
-	    (dev->features & NETIF_F_HW_CSUM) ? "on" : "off");
+	    (dev->features & NETIF_F_IP_CSUM) ? "on" : "off");
=20
 	spin_lock_init(&priv->lock);
=20
diff --git a/drivers/net/vxge/vxge-ethtool.c b/drivers/net/vxge/vxge-et=
htool.c
index bc9bd10..5ece50d 100644
--- a/drivers/net/vxge/vxge-ethtool.c
+++ b/drivers/net/vxge/vxge-ethtool.c
@@ -1177,7 +1177,7 @@ static const struct ethtool_ops vxge_ethtool_ops =
=3D {
 	.get_rx_csum		=3D vxge_get_rx_csum,
 	.set_rx_csum		=3D vxge_set_rx_csum,
 	.get_tx_csum		=3D ethtool_op_get_tx_csum,
-	.set_tx_csum		=3D ethtool_op_set_tx_hw_csum,
+	.set_tx_csum		=3D ethtool_op_set_tx_csum,
 	.get_sg			=3D ethtool_op_get_sg,
 	.set_sg			=3D ethtool_op_set_sg,
 	.get_tso		=3D ethtool_op_get_tso,
diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.=
c
index a21dae1..9f6d379 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -3368,7 +3368,7 @@ static int __devinit vxge_device_register(struct =
__vxge_hw_device *hldev,
=20
 	ndev->features |=3D NETIF_F_SG;
=20
-	ndev->features |=3D NETIF_F_HW_CSUM;
+	ndev->features |=3D NETIF_F_IP_CSUM;
 	vxge_debug_init(vxge_hw_device_trace_level_get(hldev),
 		"%s : checksuming enabled", __func__);
=20
diff --git a/net/core/dev.c b/net/core/dev.c
index 3259d2c..622f85a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5041,10 +5041,13 @@ unsigned long netdev_fix_features(unsigned long=
 features, const char *name)
 	}
=20
 	if (features & NETIF_F_UFO) {
-		if (!(features & NETIF_F_GEN_CSUM)) {
+		/* maybe split UFO into V4 and V6? */
+		if (!((features & NETIF_F_GEN_CSUM) ||
+		    (features & (NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM))
+			    =3D=3D (NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM))) {
 			if (name)
 				printk(KERN_ERR "%s: Dropping NETIF_F_UFO "
-				       "since no NETIF_F_HW_CSUM feature.\n",
+				       "since no checksum offload features.\n",
 				       name);
 			features &=3D ~NETIF_F_UFO;
 		}
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 956a9f4..d5bc2881 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -1171,7 +1171,9 @@ static int ethtool_set_ufo(struct net_device *dev=
, char __user *useraddr)
 		return -EFAULT;
 	if (edata.data && !(dev->features & NETIF_F_SG))
 		return -EINVAL;
-	if (edata.data && !(dev->features & NETIF_F_HW_CSUM))
+	if (edata.data && !((dev->features & NETIF_F_GEN_CSUM) ||
+		(dev->features & (NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM))
+			=3D=3D (NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM)))
 		return -EINVAL;
 	return dev->ethtool_ops->set_ufo(dev, edata.data);
 }


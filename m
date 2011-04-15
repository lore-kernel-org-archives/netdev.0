From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH] net: forcedeth: convert to hw_features
Date: Fri, 15 Apr 2011 16:50:49 +0200 (CEST)
Message-ID: <20110415145049.CC33613A65@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:46535 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756255Ab1DOOuw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Apr 2011 10:50:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This also fixes a race around np->txrxctl_bits while changing RXCSUM of=
fload.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/forcedeth.c |   78 +++++++++++++++------------------------=
-------
 1 files changed, 26 insertions(+), 52 deletions(-)

diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index d5ab4da..ec9a32d 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -774,7 +774,6 @@ struct fe_priv {
 	u32 driver_data;
 	u32 device_id;
 	u32 register_size;
-	int rx_csum;
 	u32 mac_in_use;
 	int mgmt_version;
 	int mgmt_sema;
@@ -4480,58 +4479,36 @@ static int nv_set_pauseparam(struct net_device =
*dev, struct ethtool_pauseparam*
 	return 0;
 }
=20
-static u32 nv_get_rx_csum(struct net_device *dev)
+static u32 nv_fix_features(struct net_device *dev, u32 features)
 {
-	struct fe_priv *np =3D netdev_priv(dev);
-	return np->rx_csum !=3D 0;
+	/* vlan is dependent on rx checksum offload */
+	if (features & (NETIF_F_HW_VLAN_TX|NETIF_F_HW_VLAN_RX))
+		features |=3D NETIF_F_RXCSUM;
+
+	return features;
 }
=20
-static int nv_set_rx_csum(struct net_device *dev, u32 data)
+static int nv_set_features(struct net_device *dev, u32 features)
 {
 	struct fe_priv *np =3D netdev_priv(dev);
 	u8 __iomem *base =3D get_hwbase(dev);
-	int retcode =3D 0;
+	u32 changed =3D dev->features ^ features;
=20
-	if (np->driver_data & DEV_HAS_CHECKSUM) {
-		if (data) {
-			np->rx_csum =3D 1;
+	if (changed & NETIF_F_RXCSUM) {
+		spin_lock_irq(&np->lock);
+
+		if (features & NETIF_F_RXCSUM)
 			np->txrxctl_bits |=3D NVREG_TXRXCTL_RXCHECK;
-		} else {
-			np->rx_csum =3D 0;
-			/* vlan is dependent on rx checksum offload */
-			if (!(np->vlanctl_bits & NVREG_VLANCONTROL_ENABLE))
-				np->txrxctl_bits &=3D ~NVREG_TXRXCTL_RXCHECK;
-		}
-		if (netif_running(dev)) {
-			spin_lock_irq(&np->lock);
+		else
+			np->txrxctl_bits &=3D ~NVREG_TXRXCTL_RXCHECK;
+
+		if (netif_running(dev))
 			writel(np->txrxctl_bits, base + NvRegTxRxControl);
-			spin_unlock_irq(&np->lock);
-		}
-	} else {
-		return -EINVAL;
+
+		spin_unlock_irq(&np->lock);
 	}
=20
-	return retcode;
-}
-
-static int nv_set_tx_csum(struct net_device *dev, u32 data)
-{
-	struct fe_priv *np =3D netdev_priv(dev);
-
-	if (np->driver_data & DEV_HAS_CHECKSUM)
-		return ethtool_op_set_tx_csum(dev, data);
-	else
-		return -EOPNOTSUPP;
-}
-
-static int nv_set_sg(struct net_device *dev, u32 data)
-{
-	struct fe_priv *np =3D netdev_priv(dev);
-
-	if (np->driver_data & DEV_HAS_CHECKSUM)
-		return ethtool_op_set_sg(dev, data);
-	else
-		return -EOPNOTSUPP;
+	return 0;
 }
=20
 static int nv_get_sset_count(struct net_device *dev, int sset)
@@ -4896,15 +4873,10 @@ static const struct ethtool_ops ops =3D {
 	.get_regs_len =3D nv_get_regs_len,
 	.get_regs =3D nv_get_regs,
 	.nway_reset =3D nv_nway_reset,
-	.set_tso =3D nv_set_tso,
 	.get_ringparam =3D nv_get_ringparam,
 	.set_ringparam =3D nv_set_ringparam,
 	.get_pauseparam =3D nv_get_pauseparam,
 	.set_pauseparam =3D nv_set_pauseparam,
-	.get_rx_csum =3D nv_get_rx_csum,
-	.set_rx_csum =3D nv_set_rx_csum,
-	.set_tx_csum =3D nv_set_tx_csum,
-	.set_sg =3D nv_set_sg,
 	.get_strings =3D nv_get_strings,
 	.get_ethtool_stats =3D nv_get_ethtool_stats,
 	.get_sset_count =3D nv_get_sset_count,
@@ -5235,6 +5207,8 @@ static const struct net_device_ops nv_netdev_ops =
=3D {
 	.ndo_start_xmit		=3D nv_start_xmit,
 	.ndo_tx_timeout		=3D nv_tx_timeout,
 	.ndo_change_mtu		=3D nv_change_mtu,
+	.ndo_fix_features	=3D nv_fix_features,
+	.ndo_set_features	=3D nv_set_features,
 	.ndo_validate_addr	=3D eth_validate_addr,
 	.ndo_set_mac_address	=3D nv_set_mac_address,
 	.ndo_set_multicast_list	=3D nv_set_multicast,
@@ -5251,6 +5225,8 @@ static const struct net_device_ops nv_netdev_ops_=
optimized =3D {
 	.ndo_start_xmit		=3D nv_start_xmit_optimized,
 	.ndo_tx_timeout		=3D nv_tx_timeout,
 	.ndo_change_mtu		=3D nv_change_mtu,
+	.ndo_fix_features	=3D nv_fix_features,
+	.ndo_set_features	=3D nv_set_features,
 	.ndo_validate_addr	=3D eth_validate_addr,
 	.ndo_set_mac_address	=3D nv_set_mac_address,
 	.ndo_set_multicast_list	=3D nv_set_multicast,
@@ -5364,11 +5340,10 @@ static int __devinit nv_probe(struct pci_dev *p=
ci_dev, const struct pci_device_i
 		np->pkt_limit =3D NV_PKTLIMIT_2;
=20
 	if (id->driver_data & DEV_HAS_CHECKSUM) {
-		np->rx_csum =3D 1;
 		np->txrxctl_bits |=3D NVREG_TXRXCTL_RXCHECK;
-		dev->features |=3D NETIF_F_IP_CSUM | NETIF_F_SG;
-		dev->features |=3D NETIF_F_TSO;
-		dev->features |=3D NETIF_F_GRO;
+		dev->hw_features |=3D NETIF_F_IP_CSUM | NETIF_F_SG |
+			NETIF_F_TSO | NETIF_F_RXCSUM;
+		dev->features |=3D dev->hw_features;
 	}
=20
 	np->vlanctl_bits =3D 0;
@@ -5384,7 +5359,6 @@ static int __devinit nv_probe(struct pci_dev *pci=
_dev, const struct pci_device_i
 		np->pause_flags |=3D NV_PAUSEFRAME_TX_CAPABLE | NV_PAUSEFRAME_TX_REQ=
;
 	}
=20
-
 	err =3D -ENOMEM;
 	np->base =3D ioremap(addr, np->register_size);
 	if (!np->base)
--=20
1.7.2.5


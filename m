From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [RFC PATCH 08/12] jme: convert offload constraints to ndo_fix_features
Date: Wed, 15 Dec 2010 23:24:30 +0100 (CET)
Message-ID: <9e24e2d831c9aba26a8d6b826d9a28e72f7e255f.1292451560.git.mirq-linux@rere.qmqm.pl>
References: <cover.1292451559.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:53555 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752261Ab0LOWYc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Dec 2010 17:24:32 -0500
In-Reply-To: <cover.1292451559.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/jme.c |   79 +++++++++++++--------------------------------=
-------
 drivers/net/jme.h |    2 -
 2 files changed, 20 insertions(+), 61 deletions(-)

diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index 2411e72..1271109 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -2075,17 +2075,9 @@ jme_change_mtu(struct net_device *netdev, int ne=
w_mtu)
 		jme_restart_rx_engine(jme);
 	}
=20
-	if (new_mtu > 1900) {
-		netdev->features &=3D ~(NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
-				NETIF_F_TSO | NETIF_F_TSO6);
-	} else {
-		if (test_bit(JME_FLAG_TXCSUM, &jme->flags))
-			netdev->features |=3D NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
-		if (test_bit(JME_FLAG_TSO, &jme->flags))
-			netdev->features |=3D NETIF_F_TSO | NETIF_F_TSO6;
-	}
-
 	netdev->mtu =3D new_mtu;
+	netdev_update_features(netdev);
+
 	jme_reset_link(jme);
=20
 	return 0;
@@ -2482,20 +2474,21 @@ jme_set_msglevel(struct net_device *netdev, u32=
 value)
 	jme->msg_enable =3D value;
 }
=20
-static u32
-jme_get_rx_csum(struct net_device *netdev)
+static unsigned long
+jme_fix_features(struct net_device *netdev, unsigned long features)
 {
-	struct jme_adapter *jme =3D netdev_priv(netdev);
-	return jme->reg_rxmcs & RXMCS_CHECKSUM;
+	if (netdev->mtu > 1900)
+		features &=3D ~(NETIF_F_ALL_TSO | NETIF_F_ALL_CSUM);
+	return features;
 }
=20
 static int
-jme_set_rx_csum(struct net_device *netdev, u32 on)
+jme_set_features(struct net_device *netdev, unsigned long features)
 {
 	struct jme_adapter *jme =3D netdev_priv(netdev);
=20
 	spin_lock_bh(&jme->rxmcs_lock);
-	if (on)
+	if (features & NETIF_F_RXCSUM)
 		jme->reg_rxmcs |=3D RXMCS_CHECKSUM;
 	else
 		jme->reg_rxmcs &=3D ~RXMCS_CHECKSUM;
@@ -2506,42 +2499,6 @@ jme_set_rx_csum(struct net_device *netdev, u32 o=
n)
 }
=20
 static int
-jme_set_tx_csum(struct net_device *netdev, u32 on)
-{
-	struct jme_adapter *jme =3D netdev_priv(netdev);
-
-	if (on) {
-		set_bit(JME_FLAG_TXCSUM, &jme->flags);
-		if (netdev->mtu <=3D 1900)
-			netdev->features |=3D
-				NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
-	} else {
-		clear_bit(JME_FLAG_TXCSUM, &jme->flags);
-		netdev->features &=3D
-				~(NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM);
-	}
-
-	return 0;
-}
-
-static int
-jme_set_tso(struct net_device *netdev, u32 on)
-{
-	struct jme_adapter *jme =3D netdev_priv(netdev);
-
-	if (on) {
-		set_bit(JME_FLAG_TSO, &jme->flags);
-		if (netdev->mtu <=3D 1900)
-			netdev->features |=3D NETIF_F_TSO | NETIF_F_TSO6;
-	} else {
-		clear_bit(JME_FLAG_TSO, &jme->flags);
-		netdev->features &=3D ~(NETIF_F_TSO | NETIF_F_TSO6);
-	}
-
-	return 0;
-}
-
-static int
 jme_nway_reset(struct net_device *netdev)
 {
 	struct jme_adapter *jme =3D netdev_priv(netdev);
@@ -2682,11 +2639,6 @@ static const struct ethtool_ops jme_ethtool_ops =
=3D {
 	.get_link		=3D jme_get_link,
 	.get_msglevel           =3D jme_get_msglevel,
 	.set_msglevel           =3D jme_set_msglevel,
-	.get_rx_csum		=3D jme_get_rx_csum,
-	.set_rx_csum		=3D jme_set_rx_csum,
-	.set_tx_csum		=3D jme_set_tx_csum,
-	.set_tso		=3D jme_set_tso,
-	.set_sg			=3D ethtool_op_set_sg,
 	.nway_reset             =3D jme_nway_reset,
 	.get_eeprom_len		=3D jme_get_eeprom_len,
 	.get_eeprom		=3D jme_get_eeprom,
@@ -2744,6 +2696,8 @@ static const struct net_device_ops jme_netdev_ops=
 =3D {
 	.ndo_change_mtu		=3D jme_change_mtu,
 	.ndo_tx_timeout		=3D jme_tx_timeout,
 	.ndo_vlan_rx_register	=3D jme_vlan_rx_register,
+	.ndo_fix_features       =3D jme_fix_features,
+	.ndo_set_features       =3D jme_set_features,
 };
=20
 static int __devinit
@@ -2798,6 +2752,12 @@ jme_init_one(struct pci_dev *pdev,
 	netdev->netdev_ops =3D &jme_netdev_ops;
 	netdev->ethtool_ops		=3D &jme_ethtool_ops;
 	netdev->watchdog_timeo		=3D TX_TIMEOUT;
+	netdev->hw_features		=3D	NETIF_F_IP_CSUM |
+						NETIF_F_IPV6_CSUM |
+						NETIF_F_SG |
+						NETIF_F_TSO |
+						NETIF_F_TSO6 |
+						NETIF_F_RXCSUM;
 	netdev->features		=3D	NETIF_F_IP_CSUM |
 						NETIF_F_IPV6_CSUM |
 						NETIF_F_SG |
@@ -2880,8 +2840,9 @@ jme_init_one(struct pci_dev *pdev,
 	jme->reg_rxmcs =3D RXMCS_DEFAULT;
 	jme->reg_txpfc =3D 0;
 	jme->reg_pmcs =3D PMCS_MFEN;
-	set_bit(JME_FLAG_TXCSUM, &jme->flags);
-	set_bit(JME_FLAG_TSO, &jme->flags);
+
+	if (jme->reg_rxmcs & RXMCS_CHECKSUM)
+		netdev->features |=3D NETIF_F_RXCSUM;
=20
 	/*
 	 * Get Max Read Req Size from PCI Config Space
diff --git a/drivers/net/jme.h b/drivers/net/jme.h
index eac0926..4923376 100644
--- a/drivers/net/jme.h
+++ b/drivers/net/jme.h
@@ -434,8 +434,6 @@ struct jme_adapter {
 enum jme_flags_bits {
 	JME_FLAG_MSI		=3D 1,
 	JME_FLAG_SSET		=3D 2,
-	JME_FLAG_TXCSUM		=3D 3,
-	JME_FLAG_TSO		=3D 4,
 	JME_FLAG_POLL		=3D 5,
 	JME_FLAG_SHUTDOWN	=3D 6,
 };
--=20
1.7.2.3


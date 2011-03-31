From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH] jme: convert offload constraints to ndo_fix_features
Date: Thu, 31 Mar 2011 13:01:35 +0200 (CEST)
Message-ID: <20110331110135.4649B13A66@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Guo-Fu Tseng <cooldavid@cooldavid.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:50956 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757300Ab1CaLBi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Mar 2011 07:01:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/jme.c |   77 +++++++++++++--------------------------------=
--------
 drivers/net/jme.h |    2 -
 2 files changed, 19 insertions(+), 60 deletions(-)

This is an example conversion to hw_features and friends for MTU-based
offload disabling.

If there are some changes needed, I'll leave that to you as I don't hav=
e
the hardware to test this on.

diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index 994c809..be4773f 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -2230,17 +2230,9 @@ jme_change_mtu(struct net_device *netdev, int ne=
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
@@ -2640,19 +2632,20 @@ jme_set_msglevel(struct net_device *netdev, u32=
 value)
 }
=20
 static u32
-jme_get_rx_csum(struct net_device *netdev)
+jme_fix_features(struct net_device *netdev, u32 features)
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
+jme_set_features(struct net_device *netdev, u32 features)
 {
 	struct jme_adapter *jme =3D netdev_priv(netdev);
=20
 	spin_lock_bh(&jme->rxmcs_lock);
-	if (on)
+	if (features & NETIF_F_RXCSUM)
 		jme->reg_rxmcs |=3D RXMCS_CHECKSUM;
 	else
 		jme->reg_rxmcs &=3D ~RXMCS_CHECKSUM;
@@ -2663,42 +2656,6 @@ jme_set_rx_csum(struct net_device *netdev, u32 o=
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
@@ -2839,11 +2796,6 @@ static const struct ethtool_ops jme_ethtool_ops =
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
@@ -2903,6 +2855,8 @@ static const struct net_device_ops jme_netdev_ops=
 =3D {
 	.ndo_change_mtu		=3D jme_change_mtu,
 	.ndo_tx_timeout		=3D jme_tx_timeout,
 	.ndo_vlan_rx_register	=3D jme_vlan_rx_register,
+	.ndo_fix_features       =3D jme_fix_features,
+	.ndo_set_features       =3D jme_set_features,
 };
=20
 static int __devinit
@@ -2957,6 +2911,12 @@ jme_init_one(struct pci_dev *pdev,
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
@@ -3040,8 +3000,9 @@ jme_init_one(struct pci_dev *pdev,
 	jme->reg_txpfc =3D 0;
 	jme->reg_pmcs =3D PMCS_MFEN;
 	jme->reg_gpreg1 =3D GPREG1_DEFAULT;
-	set_bit(JME_FLAG_TXCSUM, &jme->flags);
-	set_bit(JME_FLAG_TSO, &jme->flags);
+
+	if (jme->reg_rxmcs & RXMCS_CHECKSUM)
+		netdev->features |=3D NETIF_F_RXCSUM;
=20
 	/*
 	 * Get Max Read Req Size from PCI Config Space
diff --git a/drivers/net/jme.h b/drivers/net/jme.h
index 8bf3045..e9aaeca 100644
--- a/drivers/net/jme.h
+++ b/drivers/net/jme.h
@@ -468,8 +468,6 @@ struct jme_adapter {
 enum jme_flags_bits {
 	JME_FLAG_MSI		=3D 1,
 	JME_FLAG_SSET		=3D 2,
-	JME_FLAG_TXCSUM		=3D 3,
-	JME_FLAG_TSO		=3D 4,
 	JME_FLAG_POLL		=3D 5,
 	JME_FLAG_SHUTDOWN	=3D 6,
 };
--=20
1.7.2.5


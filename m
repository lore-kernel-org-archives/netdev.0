From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH] net: sky2: convert to hw_features
Date: Sun, 10 Apr 2011 15:13:21 +0200 (CEST)
Message-ID: <20110410131321.8CD9713A64@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@linux-foundation.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:58032 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751356Ab1DJNNX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Apr 2011 09:13:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Caveats:
 - driver modifies vlan_features on HW VLAN TX changes
 - broken RX checksum will be reenabled on features change

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/sky2.c |  165 +++++++++++++++++++-------------------------=
--------
 drivers/net/sky2.h |    1 -
 2 files changed, 61 insertions(+), 105 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index afc925a..b461290 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -1198,12 +1198,12 @@ static void rx_set_checksum(struct sky2_port *s=
ky2)
=20
 	sky2_write32(sky2->hw,
 		     Q_ADDR(rxqaddr[sky2->port], Q_CSR),
-		     (sky2->flags & SKY2_FLAG_RX_CHECKSUM)
+		     (sky2->netdev->features & NETIF_F_RXCSUM)
 		     ? BMU_ENA_RX_CHKSUM : BMU_DIS_RX_CHKSUM);
 }
=20
 /* Enable/disable receive hash calculation (RSS) */
-static void rx_set_rss(struct net_device *dev)
+static void rx_set_rss(struct net_device *dev, u32 features)
 {
 	struct sky2_port *sky2 =3D netdev_priv(dev);
 	struct sky2_hw *hw =3D sky2->hw;
@@ -1216,7 +1216,7 @@ static void rx_set_rss(struct net_device *dev)
 	}
=20
 	/* Program RSS initial values */
-	if (dev->features & NETIF_F_RXHASH) {
+	if (features & NETIF_F_RXHASH) {
 		u32 key[nkeys];
=20
 		get_random_bytes(key, nkeys * sizeof(u32));
@@ -1322,32 +1322,32 @@ static int sky2_ioctl(struct net_device *dev, s=
truct ifreq *ifr, int cmd)
 	return err;
 }
=20
-#define NETIF_F_ALL_VLAN (NETIF_F_HW_VLAN_TX|NETIF_F_HW_VLAN_RX)
+#define SKY2_VLAN_OFFLOADS (NETIF_F_IP_CSUM | NETIF_F_SG | NETIF_F_TSO=
)
=20
-static void sky2_vlan_mode(struct net_device *dev)
+static void sky2_vlan_mode(struct net_device *dev, u32 features)
 {
 	struct sky2_port *sky2 =3D netdev_priv(dev);
 	struct sky2_hw *hw =3D sky2->hw;
 	u16 port =3D sky2->port;
=20
-	if (dev->features & NETIF_F_HW_VLAN_RX)
+	if (features & NETIF_F_HW_VLAN_RX)
 		sky2_write32(hw, SK_REG(port, RX_GMF_CTRL_T),
 			     RX_VLAN_STRIP_ON);
 	else
 		sky2_write32(hw, SK_REG(port, RX_GMF_CTRL_T),
 			     RX_VLAN_STRIP_OFF);
=20
-	dev->vlan_features =3D dev->features &~ NETIF_F_ALL_VLAN;
-	if (dev->features & NETIF_F_HW_VLAN_TX)
+	if (features & NETIF_F_HW_VLAN_TX) {
 		sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T),
 			     TX_VLAN_TAG_ON);
-	else {
+
+		dev->vlan_features |=3D SKY2_VLAN_OFFLOADS;
+	} else {
 		sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T),
 			     TX_VLAN_TAG_OFF);
=20
 		/* Can't do transmit offload of vlan without hw vlan */
-		dev->vlan_features &=3D ~(NETIF_F_TSO | NETIF_F_SG
-					| NETIF_F_ALL_CSUM);
+		dev->vlan_features &=3D ~SKY2_VLAN_OFFLOADS;
 	}
 }
=20
@@ -1463,7 +1463,7 @@ static void sky2_rx_start(struct sky2_port *sky2)
 		rx_set_checksum(sky2);
=20
 	if (!(hw->flags & SKY2_HW_RSS_BROKEN))
-		rx_set_rss(sky2->netdev);
+		rx_set_rss(sky2->netdev, sky2->netdev->features);
=20
 	/* submit Rx ring */
 	for (i =3D 0; i < sky2->rx_pending; i++) {
@@ -1626,7 +1626,8 @@ static void sky2_hw_up(struct sky2_port *sky2)
 	sky2_prefetch_init(hw, txqaddr[port], sky2->tx_le_map,
 			   sky2->tx_ring_size - 1);
=20
-	sky2_vlan_mode(sky2->netdev);
+	sky2_vlan_mode(sky2->netdev, sky2->netdev->features);
+	netdev_update_features(sky2->netdev);
=20
 	sky2_rx_start(sky2);
 }
@@ -2261,12 +2262,9 @@ static int sky2_change_mtu(struct net_device *de=
v, int new_mtu)
 	     hw->chip_id =3D=3D CHIP_ID_YUKON_FE_P))
 		return -EINVAL;
=20
-	/* TSO, etc on Yukon Ultra and MTU > 1500 not supported */
-	if (new_mtu > ETH_DATA_LEN && hw->chip_id =3D=3D CHIP_ID_YUKON_EC_U)
-		dev->features &=3D ~(NETIF_F_TSO|NETIF_F_SG|NETIF_F_ALL_CSUM);
-
 	if (!netif_running(dev)) {
 		dev->mtu =3D new_mtu;
+		netdev_update_features(dev);
 		return 0;
 	}
=20
@@ -2288,6 +2286,7 @@ static int sky2_change_mtu(struct net_device *dev=
, int new_mtu)
 	sky2_rx_clean(sky2);
=20
 	dev->mtu =3D new_mtu;
+	netdev_update_features(dev);
=20
 	mode =3D DATA_BLIND_VAL(DATA_BLIND_DEF) |
 		GM_SMOD_VLAN_ENA | IPG_DATA_VAL(IPG_DATA_DEF);
@@ -2535,8 +2534,11 @@ static void sky2_rx_checksum(struct sky2_port *s=
ky2, u32 status)
 			   "%s: receive checksum problem (status =3D %#x)\n",
 			   sky2->netdev->name, status);
=20
-		/* Disable checksum offload */
-		sky2->flags &=3D ~SKY2_FLAG_RX_CHECKSUM;
+		/* Disable checksum offload
+		 * It will be reenabled on next ndo_set_features, but if it's
+		 * really broken, will get disabled again
+		 */
+		sky2->netdev->features &=3D ~NETIF_F_RXCSUM;
 		sky2_write32(sky2->hw, Q_ADDR(rxqaddr[sky2->port], Q_CSR),
 			     BMU_DIS_RX_CHKSUM);
 	}
@@ -2591,7 +2593,7 @@ static int sky2_status_intr(struct sky2_hw *hw, i=
nt to_do, u16 idx)
=20
 			/* This chip reports checksum status differently */
 			if (hw->flags & SKY2_HW_NEW_LE) {
-				if ((sky2->flags & SKY2_FLAG_RX_CHECKSUM) &&
+				if ((dev->features & NETIF_F_RXCSUM) &&
 				    (le->css & (CSS_ISIPV4 | CSS_ISIPV6)) &&
 				    (le->css & CSS_TCPUDPCSOK))
 					skb->ip_summed =3D CHECKSUM_UNNECESSARY;
@@ -2616,7 +2618,7 @@ static int sky2_status_intr(struct sky2_hw *hw, i=
nt to_do, u16 idx)
 			sky2->rx_tag =3D length;
 			/* fall through */
 		case OP_RXCHKS:
-			if (likely(sky2->flags & SKY2_FLAG_RX_CHECKSUM))
+			if (likely(dev->features & NETIF_F_RXCSUM))
 				sky2_rx_checksum(sky2, status);
 			break;
=20
@@ -3552,28 +3554,6 @@ static const struct sky2_stat {
 	{ "tx_fifo_underrun", GM_TXE_FIFO_UR },
 };
=20
-static u32 sky2_get_rx_csum(struct net_device *dev)
-{
-	struct sky2_port *sky2 =3D netdev_priv(dev);
-
-	return !!(sky2->flags & SKY2_FLAG_RX_CHECKSUM);
-}
-
-static int sky2_set_rx_csum(struct net_device *dev, u32 data)
-{
-	struct sky2_port *sky2 =3D netdev_priv(dev);
-
-	if (data)
-		sky2->flags |=3D SKY2_FLAG_RX_CHECKSUM;
-	else
-		sky2->flags &=3D ~SKY2_FLAG_RX_CHECKSUM;
-
-	sky2_write32(sky2->hw, Q_ADDR(rxqaddr[sky2->port], Q_CSR),
-		     data ? BMU_ENA_RX_CHKSUM : BMU_DIS_RX_CHKSUM);
-
-	return 0;
-}
-
 static u32 sky2_get_msglevel(struct net_device *netdev)
 {
 	struct sky2_port *sky2 =3D netdev_priv(netdev);
@@ -4084,34 +4064,6 @@ static void sky2_get_regs(struct net_device *dev=
, struct ethtool_regs *regs,
 	}
 }
=20
-/* In order to do Jumbo packets on these chips, need to turn off the
- * transmit store/forward. Therefore checksum offload won't work.
- */
-static int no_tx_offload(struct net_device *dev)
-{
-	const struct sky2_port *sky2 =3D netdev_priv(dev);
-	const struct sky2_hw *hw =3D sky2->hw;
-
-	return dev->mtu > ETH_DATA_LEN && hw->chip_id =3D=3D CHIP_ID_YUKON_EC=
_U;
-}
-
-static int sky2_set_tx_csum(struct net_device *dev, u32 data)
-{
-	if (data && no_tx_offload(dev))
-		return -EINVAL;
-
-	return ethtool_op_set_tx_csum(dev, data);
-}
-
-
-static int sky2_set_tso(struct net_device *dev, u32 data)
-{
-	if (data && no_tx_offload(dev))
-		return -EINVAL;
-
-	return ethtool_op_set_tso(dev, data);
-}
-
 static int sky2_get_eeprom_len(struct net_device *dev)
 {
 	struct sky2_port *sky2 =3D netdev_priv(dev);
@@ -4214,31 +4166,36 @@ static int sky2_set_eeprom(struct net_device *d=
ev, struct ethtool_eeprom *eeprom
 	return sky2_vpd_write(sky2->hw, cap, data, eeprom->offset, eeprom->le=
n);
 }
=20
-static int sky2_set_flags(struct net_device *dev, u32 data)
+static u32 sky2_fix_features(struct net_device *dev, u32 features)
+{
+	const struct sky2_port *sky2 =3D netdev_priv(dev);
+	const struct sky2_hw *hw =3D sky2->hw;
+
+	/* In order to do Jumbo packets on these chips, need to turn off the
+	 * transmit store/forward. Therefore checksum offload won't work.
+	 */
+	if (dev->mtu > ETH_DATA_LEN && hw->chip_id =3D=3D CHIP_ID_YUKON_EC_U)
+		features &=3D ~(NETIF_F_TSO|NETIF_F_SG|NETIF_F_ALL_CSUM);
+
+	return features;
+}
+
+static int sky2_set_features(struct net_device *dev, u32 features)
 {
 	struct sky2_port *sky2 =3D netdev_priv(dev);
-	unsigned long old_feat =3D dev->features;
-	u32 supported =3D 0;
-	int rc;
+	u32 changed =3D dev->features ^ features;
=20
-	if (!(sky2->hw->flags & SKY2_HW_RSS_BROKEN))
-		supported |=3D ETH_FLAG_RXHASH;
+	if (changed & NETIF_F_RXCSUM) {
+		u32 on =3D features & NETIF_F_RXCSUM;
+		sky2_write32(sky2->hw, Q_ADDR(rxqaddr[sky2->port], Q_CSR),
+			     on ? BMU_ENA_RX_CHKSUM : BMU_DIS_RX_CHKSUM);
+	}
=20
-	if (!(sky2->hw->flags & SKY2_HW_VLAN_BROKEN))
-		supported |=3D ETH_FLAG_RXVLAN | ETH_FLAG_TXVLAN;
+	if (changed & NETIF_F_RXHASH)
+		rx_set_rss(dev, features);
=20
-	printk(KERN_DEBUG "sky2 set_flags: supported %x data %x\n",
-	       supported, data);
-
-	rc =3D ethtool_op_set_flags(dev, data, supported);
-	if (rc)
-		return rc;
-
-	if ((old_feat ^ dev->features) & NETIF_F_RXHASH)
-		rx_set_rss(dev);
-
-	if ((old_feat ^ dev->features) & NETIF_F_ALL_VLAN)
-		sky2_vlan_mode(dev);
+	if (changed & (NETIF_F_HW_VLAN_TX|NETIF_F_HW_VLAN_RX))
+		sky2_vlan_mode(dev, features);
=20
 	return 0;
 }
@@ -4258,11 +4215,6 @@ static const struct ethtool_ops sky2_ethtool_ops=
 =3D {
 	.get_eeprom_len	=3D sky2_get_eeprom_len,
 	.get_eeprom	=3D sky2_get_eeprom,
 	.set_eeprom	=3D sky2_set_eeprom,
-	.set_sg 	=3D ethtool_op_set_sg,
-	.set_tx_csum	=3D sky2_set_tx_csum,
-	.set_tso	=3D sky2_set_tso,
-	.get_rx_csum	=3D sky2_get_rx_csum,
-	.set_rx_csum	=3D sky2_set_rx_csum,
 	.get_strings	=3D sky2_get_strings,
 	.get_coalesce	=3D sky2_get_coalesce,
 	.set_coalesce	=3D sky2_set_coalesce,
@@ -4273,8 +4225,6 @@ static const struct ethtool_ops sky2_ethtool_ops =
=3D {
 	.set_phys_id	=3D sky2_set_phys_id,
 	.get_sset_count =3D sky2_get_sset_count,
 	.get_ethtool_stats =3D sky2_get_ethtool_stats,
-	.set_flags	=3D sky2_set_flags,
-	.get_flags	=3D ethtool_op_get_flags,
 };
=20
 #ifdef CONFIG_SKY2_DEBUG
@@ -4554,6 +4504,8 @@ static const struct net_device_ops sky2_netdev_op=
s[2] =3D {
 	.ndo_set_mac_address	=3D sky2_set_mac_address,
 	.ndo_set_multicast_list	=3D sky2_set_multicast,
 	.ndo_change_mtu		=3D sky2_change_mtu,
+	.ndo_fix_features	=3D sky2_fix_features,
+	.ndo_set_features	=3D sky2_set_features,
 	.ndo_tx_timeout		=3D sky2_tx_timeout,
 	.ndo_get_stats64	=3D sky2_get_stats,
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -4569,6 +4521,8 @@ static const struct net_device_ops sky2_netdev_op=
s[2] =3D {
 	.ndo_set_mac_address	=3D sky2_set_mac_address,
 	.ndo_set_multicast_list	=3D sky2_set_multicast,
 	.ndo_change_mtu		=3D sky2_change_mtu,
+	.ndo_fix_features	=3D sky2_fix_features,
+	.ndo_set_features	=3D sky2_set_features,
 	.ndo_tx_timeout		=3D sky2_tx_timeout,
 	.ndo_get_stats64	=3D sky2_get_stats,
   },
@@ -4601,7 +4555,7 @@ static __devinit struct net_device *sky2_init_net=
dev(struct sky2_hw *hw,
 	/* Auto speed and flow control */
 	sky2->flags =3D SKY2_FLAG_AUTO_SPEED | SKY2_FLAG_AUTO_PAUSE;
 	if (hw->chip_id !=3D CHIP_ID_YUKON_XL)
-		sky2->flags |=3D SKY2_FLAG_RX_CHECKSUM;
+		dev->hw_features |=3D NETIF_F_RXCSUM;
=20
 	sky2->flow_mode =3D FC_BOTH;
=20
@@ -4620,18 +4574,21 @@ static __devinit struct net_device *sky2_init_n=
etdev(struct sky2_hw *hw,
=20
 	sky2->port =3D port;
=20
-	dev->features |=3D NETIF_F_IP_CSUM | NETIF_F_SG
-		| NETIF_F_TSO | NETIF_F_GRO;
+	dev->hw_features |=3D NETIF_F_IP_CSUM | NETIF_F_SG | NETIF_F_TSO;
=20
 	if (highmem)
 		dev->features |=3D NETIF_F_HIGHDMA;
=20
 	/* Enable receive hashing unless hardware is known broken */
 	if (!(hw->flags & SKY2_HW_RSS_BROKEN))
-		dev->features |=3D NETIF_F_RXHASH;
+		dev->hw_features |=3D NETIF_F_RXHASH;
=20
-	if (!(hw->flags & SKY2_HW_VLAN_BROKEN))
-		dev->features |=3D NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
+	if (!(hw->flags & SKY2_HW_VLAN_BROKEN)) {
+		dev->hw_features |=3D NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
+		dev->vlan_features |=3D SKY2_VLAN_OFFLOADS;
+	}
+
+	dev->features |=3D dev->hw_features;
=20
 	/* read the mac address */
 	memcpy_fromio(dev->dev_addr, hw->regs + B2_MAC_1 + port * 8, ETH_ALEN=
);
diff --git a/drivers/net/sky2.h b/drivers/net/sky2.h
index 6861b0e..f413eaa 100644
--- a/drivers/net/sky2.h
+++ b/drivers/net/sky2.h
@@ -2254,7 +2254,6 @@ struct sky2_port {
 	u8		     wol;		/* WAKE_ bits */
 	u8		     duplex;		/* DUPLEX_HALF, DUPLEX_FULL */
 	u16		     flags;
-#define SKY2_FLAG_RX_CHECKSUM		0x0001
 #define SKY2_FLAG_AUTO_SPEED		0x0002
 #define SKY2_FLAG_AUTO_PAUSE		0x0004
=20
--=20
1.7.2.5


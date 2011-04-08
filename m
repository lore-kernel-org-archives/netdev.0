From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH v2] net: r8169: convert to hw_features
Date: Fri,  8 Apr 2011 18:35:56 +0200 (CEST)
Message-ID: <20110408163556.D8D1213909@rere.qmqm.pl>
References: <1302277067.19764.2.camel@obelisk.thedillows.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	David Dillow <dave@thedillows.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:42343 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757022Ab1DHQf6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Apr 2011 12:35:58 -0400
In-Reply-To: <1302277067.19764.2.camel@obelisk.thedillows.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simple conversion with a bit of needed cleanup.

This also fixes:
 - confusion around vlan_features in rtl8169_vlan_mode(),
 - problem with broken TSO for too big MTU (the limit is set
   at 0xFFF --- max MSS field value).

SG+IP_CSUM+TSO is left disabled by default, based on suggestion by
David Dillow.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/r8169.c |   95 ++++++++++++++++++-------------------------=
--------
 1 files changed, 33 insertions(+), 62 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index caa99cd..058524f 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1286,14 +1286,15 @@ static int rtl8169_set_settings(struct net_devi=
ce *dev, struct ethtool_cmd *cmd)
 	return ret;
 }
=20
-static u32 rtl8169_get_rx_csum(struct net_device *dev)
+static u32 rtl8169_fix_features(struct net_device *dev, u32 features)
 {
-	struct rtl8169_private *tp =3D netdev_priv(dev);
+	if (dev->mtu > MSSMask)
+		features &=3D ~NETIF_F_ALL_TSO;
=20
-	return tp->cp_cmd & RxChkSum;
+	return features;
 }
=20
-static int rtl8169_set_rx_csum(struct net_device *dev, u32 data)
+static int rtl8169_set_features(struct net_device *dev, u32 features)
 {
 	struct rtl8169_private *tp =3D netdev_priv(dev);
 	void __iomem *ioaddr =3D tp->mmio_addr;
@@ -1301,11 +1302,16 @@ static int rtl8169_set_rx_csum(struct net_devic=
e *dev, u32 data)
=20
 	spin_lock_irqsave(&tp->lock, flags);
=20
-	if (data)
+	if (features & NETIF_F_RXCSUM)
 		tp->cp_cmd |=3D RxChkSum;
 	else
 		tp->cp_cmd &=3D ~RxChkSum;
=20
+	if (dev->features & NETIF_F_HW_VLAN_RX)
+		tp->cp_cmd |=3D RxVlan;
+	else
+		tp->cp_cmd &=3D ~RxVlan;
+
 	RTL_W16(CPlusCmd, tp->cp_cmd);
 	RTL_R16(CPlusCmd);
=20
@@ -1321,27 +1327,6 @@ static inline u32 rtl8169_tx_vlan_tag(struct rtl=
8169_private *tp,
 		TxVlanTag | swab16(vlan_tx_tag_get(skb)) : 0x00;
 }
=20
-#define NETIF_F_HW_VLAN_TX_RX	(NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX=
)
-
-static void rtl8169_vlan_mode(struct net_device *dev)
-{
-	struct rtl8169_private *tp =3D netdev_priv(dev);
-	void __iomem *ioaddr =3D tp->mmio_addr;
-	unsigned long flags;
-
-	spin_lock_irqsave(&tp->lock, flags);
-	if (dev->features & NETIF_F_HW_VLAN_RX)
-		tp->cp_cmd |=3D RxVlan;
-	else
-		tp->cp_cmd &=3D ~RxVlan;
-	RTL_W16(CPlusCmd, tp->cp_cmd);
-	/* PCI commit */
-	RTL_R16(CPlusCmd);
-	spin_unlock_irqrestore(&tp->lock, flags);
-
-	dev->vlan_features =3D dev->features &~ NETIF_F_HW_VLAN_TX_RX;
-}
-
 static void rtl8169_rx_vlan_tag(struct RxDesc *desc, struct sk_buff *s=
kb)
 {
 	u32 opts2 =3D le32_to_cpu(desc->opts2);
@@ -1522,28 +1507,6 @@ static void rtl8169_get_strings(struct net_devic=
e *dev, u32 stringset, u8 *data)
 	}
 }
=20
-static int rtl8169_set_flags(struct net_device *dev, u32 data)
-{
-	struct rtl8169_private *tp =3D netdev_priv(dev);
-	unsigned long old_feat =3D dev->features;
-	int rc;
-
-	if ((tp->mac_version =3D=3D RTL_GIGA_MAC_VER_05) &&
-	    !(data & ETH_FLAG_RXVLAN)) {
-		netif_info(tp, drv, dev, "8110SCd requires hardware Rx VLAN\n");
-		return -EINVAL;
-	}
-
-	rc =3D ethtool_op_set_flags(dev, data, ETH_FLAG_TXVLAN | ETH_FLAG_RXV=
LAN);
-	if (rc)
-		return rc;
-
-	if ((old_feat ^ dev->features) & NETIF_F_HW_VLAN_RX)
-		rtl8169_vlan_mode(dev);
-
-	return 0;
-}
-
 static const struct ethtool_ops rtl8169_ethtool_ops =3D {
 	.get_drvinfo		=3D rtl8169_get_drvinfo,
 	.get_regs_len		=3D rtl8169_get_regs_len,
@@ -1552,19 +1515,12 @@ static const struct ethtool_ops rtl8169_ethtool=
_ops =3D {
 	.set_settings		=3D rtl8169_set_settings,
 	.get_msglevel		=3D rtl8169_get_msglevel,
 	.set_msglevel		=3D rtl8169_set_msglevel,
-	.get_rx_csum		=3D rtl8169_get_rx_csum,
-	.set_rx_csum		=3D rtl8169_set_rx_csum,
-	.set_tx_csum		=3D ethtool_op_set_tx_csum,
-	.set_sg			=3D ethtool_op_set_sg,
-	.set_tso		=3D ethtool_op_set_tso,
 	.get_regs		=3D rtl8169_get_regs,
 	.get_wol		=3D rtl8169_get_wol,
 	.set_wol		=3D rtl8169_set_wol,
 	.get_strings		=3D rtl8169_get_strings,
 	.get_sset_count		=3D rtl8169_get_sset_count,
 	.get_ethtool_stats	=3D rtl8169_get_ethtool_stats,
-	.set_flags		=3D rtl8169_set_flags,
-	.get_flags		=3D ethtool_op_get_flags,
 };
=20
 static void rtl8169_get_mac_version(struct rtl8169_private *tp,
@@ -2979,6 +2935,8 @@ static const struct net_device_ops rtl8169_netdev=
_ops =3D {
 	.ndo_tx_timeout		=3D rtl8169_tx_timeout,
 	.ndo_validate_addr	=3D eth_validate_addr,
 	.ndo_change_mtu		=3D rtl8169_change_mtu,
+	.ndo_fix_features	=3D rtl8169_fix_features,
+	.ndo_set_features	=3D rtl8169_set_features,
 	.ndo_set_mac_address	=3D rtl_set_mac_address,
 	.ndo_do_ioctl		=3D rtl8169_ioctl,
 	.ndo_set_multicast_list	=3D rtl_set_rx_mode,
@@ -3425,7 +3383,19 @@ rtl8169_init_one(struct pci_dev *pdev, const str=
uct pci_device_id *ent)
=20
 	netif_napi_add(dev, &tp->napi, rtl8169_poll, R8169_NAPI_WEIGHT);
=20
-	dev->features |=3D NETIF_F_HW_VLAN_TX_RX | NETIF_F_GRO;
+	/* don't enable SG, IP_CSUM and TSO by default - it might not work
+	 * properly for all devices */
+	dev->features |=3D NETIF_F_RXCSUM |
+		NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
+
+	dev->hw_features =3D NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO |
+		NETIF_F_RXCSUM | NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
+	dev->vlan_features =3D NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO |
+		NETIF_F_HIGHDMA;
+
+	if (tp->mac_version =3D=3D RTL_GIGA_MAC_VER_05)
+		/* 8110SCd requires hardware Rx VLAN - disallow toggling */
+		dev->hw_features &=3D ~NETIF_F_HW_VLAN_RX;
=20
 	tp->intr_mask =3D 0xffff;
 	tp->hw_start =3D cfg->hw_start;
@@ -3545,7 +3515,7 @@ static int rtl8169_open(struct net_device *dev)
=20
 	rtl8169_init_phy(dev, tp);
=20
-	rtl8169_vlan_mode(dev);
+	rtl8169_set_features(dev, dev->features);
=20
 	rtl_pll_power_up(tp);
=20
@@ -4318,6 +4288,8 @@ static int rtl8169_change_mtu(struct net_device *=
dev, int new_mtu)
 		return -EINVAL;
=20
 	dev->mtu =3D new_mtu;
+	netdev_update_features(dev);
+
 	return 0;
 }
=20
@@ -4642,12 +4614,11 @@ err_out:
=20
 static inline u32 rtl8169_tso_csum(struct sk_buff *skb, struct net_dev=
ice *dev)
 {
-	if (dev->features & NETIF_F_TSO) {
-		u32 mss =3D skb_shinfo(skb)->gso_size;
+	u32 mss =3D skb_shinfo(skb)->gso_size;
+
+	if (mss)
+		return LargeSend | ((mss & MSSMask) << MSSShift);
=20
-		if (mss)
-			return LargeSend | ((mss & MSSMask) << MSSShift);
-	}
 	if (skb->ip_summed =3D=3D CHECKSUM_PARTIAL) {
 		const struct iphdr *ip =3D ip_hdr(skb);
=20
--=20
1.7.2.5


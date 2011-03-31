From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH v2] net: convert SMSC USB net drivers to hw_features
Date: Thu, 31 Mar 2011 13:39:21 +0200 (CEST)
Message-ID: <20110331113921.8D7CC13909@rere.qmqm.pl>
References: <20110331110135.E66E413A6B@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Steve Glendinning <steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:50189 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752232Ab1CaLjW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Mar 2011 07:39:22 -0400
In-Reply-To: <20110331110135.E66E413A6B@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There's a race (not fixed here) in smsc75xx in setting RFE_CTL that's n=
ot
properly handled via rfe_ctl_lock. Spinlock is not a good tool here, as
this has to wait for URB completion (or maybe just submission) after is=
suing
register write request. Otherwise, the rfe_ctl might be changed just af=
ter
spin_unlock() and device left programmed with other value.

smsc95xx has increased hard_header_len for the case of TX checksumming.

smsc75xx is fixed to advertise IP+IPV6_CSUM instead of HW_CSUM as it do=
es
not use csum_start/csum_offset.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
[v1 introduced some warnings about unused local variables]

 drivers/net/usb/smsc75xx.c |  124 ++++++++++++++++--------------------=
--------
 drivers/net/usb/smsc95xx.c |   83 +++++++-----------------------
 2 files changed, 63 insertions(+), 144 deletions(-)

diff --git a/drivers/net/usb/smsc75xx.c b/drivers/net/usb/smsc75xx.c
index 753ee6e..860a20c 100644
--- a/drivers/net/usb/smsc75xx.c
+++ b/drivers/net/usb/smsc75xx.c
@@ -65,7 +65,6 @@ struct smsc75xx_priv {
 	struct usbnet *dev;
 	u32 rfe_ctl;
 	u32 multicast_hash_table[DP_SEL_VHF_HASH_LEN];
-	bool use_rx_csum;
 	struct mutex dataport_mutex;
 	spinlock_t rfe_ctl_lock;
 	struct work_struct set_multicast;
@@ -548,28 +547,6 @@ static void smsc75xx_status(struct usbnet *dev, st=
ruct urb *urb)
 			"unexpected interrupt, intdata=3D0x%08X", intdata);
 }
=20
-/* Enable or disable Rx checksum offload engine */
-static int smsc75xx_set_rx_csum_offload(struct usbnet *dev)
-{
-	struct smsc75xx_priv *pdata =3D (struct smsc75xx_priv *)(dev->data[0]=
);
-	unsigned long flags;
-	int ret;
-
-	spin_lock_irqsave(&pdata->rfe_ctl_lock, flags);
-
-	if (pdata->use_rx_csum)
-		pdata->rfe_ctl |=3D RFE_CTL_TCPUDP_CKM | RFE_CTL_IP_CKM;
-	else
-		pdata->rfe_ctl &=3D ~(RFE_CTL_TCPUDP_CKM | RFE_CTL_IP_CKM);
-
-	spin_unlock_irqrestore(&pdata->rfe_ctl_lock, flags);
-
-	ret =3D smsc75xx_write_reg(dev, RFE_CTL, pdata->rfe_ctl);
-	check_warn_return(ret, "Error writing RFE_CTL");
-
-	return 0;
-}
-
 static int smsc75xx_ethtool_get_eeprom_len(struct net_device *net)
 {
 	return MAX_EEPROM_SIZE;
@@ -599,34 +576,6 @@ static int smsc75xx_ethtool_set_eeprom(struct net_=
device *netdev,
 	return smsc75xx_write_eeprom(dev, ee->offset, ee->len, data);
 }
=20
-static u32 smsc75xx_ethtool_get_rx_csum(struct net_device *netdev)
-{
-	struct usbnet *dev =3D netdev_priv(netdev);
-	struct smsc75xx_priv *pdata =3D (struct smsc75xx_priv *)(dev->data[0]=
);
-
-	return pdata->use_rx_csum;
-}
-
-static int smsc75xx_ethtool_set_rx_csum(struct net_device *netdev, u32=
 val)
-{
-	struct usbnet *dev =3D netdev_priv(netdev);
-	struct smsc75xx_priv *pdata =3D (struct smsc75xx_priv *)(dev->data[0]=
);
-
-	pdata->use_rx_csum =3D !!val;
-
-	return smsc75xx_set_rx_csum_offload(dev);
-}
-
-static int smsc75xx_ethtool_set_tso(struct net_device *netdev, u32 dat=
a)
-{
-	if (data)
-		netdev->features |=3D NETIF_F_TSO | NETIF_F_TSO6;
-	else
-		netdev->features &=3D ~(NETIF_F_TSO | NETIF_F_TSO6);
-
-	return 0;
-}
-
 static const struct ethtool_ops smsc75xx_ethtool_ops =3D {
 	.get_link	=3D usbnet_get_link,
 	.nway_reset	=3D usbnet_nway_reset,
@@ -638,12 +587,6 @@ static const struct ethtool_ops smsc75xx_ethtool_o=
ps =3D {
 	.get_eeprom_len	=3D smsc75xx_ethtool_get_eeprom_len,
 	.get_eeprom	=3D smsc75xx_ethtool_get_eeprom,
 	.set_eeprom	=3D smsc75xx_ethtool_set_eeprom,
-	.get_tx_csum	=3D ethtool_op_get_tx_csum,
-	.set_tx_csum	=3D ethtool_op_set_tx_hw_csum,
-	.get_rx_csum	=3D smsc75xx_ethtool_get_rx_csum,
-	.set_rx_csum	=3D smsc75xx_ethtool_set_rx_csum,
-	.get_tso	=3D ethtool_op_get_tso,
-	.set_tso	=3D smsc75xx_ethtool_set_tso,
 };
=20
 static int smsc75xx_ioctl(struct net_device *netdev, struct ifreq *rq,=
 int cmd)
@@ -782,6 +725,30 @@ static int smsc75xx_change_mtu(struct net_device *=
netdev, int new_mtu)
 	return usbnet_change_mtu(netdev, new_mtu);
 }
=20
+/* Enable or disable Rx checksum offload engine */
+static int smsc75xx_set_features(struct net_device *netdev, u32 featur=
es)
+{
+	struct usbnet *dev =3D netdev_priv(netdev);
+	struct smsc75xx_priv *pdata =3D (struct smsc75xx_priv *)(dev->data[0]=
);
+	unsigned long flags;
+	int ret;
+
+	spin_lock_irqsave(&pdata->rfe_ctl_lock, flags);
+
+	if (features & NETIF_F_RXCSUM)
+		pdata->rfe_ctl |=3D RFE_CTL_TCPUDP_CKM | RFE_CTL_IP_CKM;
+	else
+		pdata->rfe_ctl &=3D ~(RFE_CTL_TCPUDP_CKM | RFE_CTL_IP_CKM);
+
+	spin_unlock_irqrestore(&pdata->rfe_ctl_lock, flags);
+	/* it's racing here! */
+
+	ret =3D smsc75xx_write_reg(dev, RFE_CTL, pdata->rfe_ctl);
+	check_warn_return(ret, "Error writing RFE_CTL");
+
+	return 0;
+}
+
 static int smsc75xx_reset(struct usbnet *dev)
 {
 	struct smsc75xx_priv *pdata =3D (struct smsc75xx_priv *)(dev->data[0]=
);
@@ -960,11 +927,7 @@ static int smsc75xx_reset(struct usbnet *dev)
 	netif_dbg(dev, ifup, dev->net, "RFE_CTL set to 0x%08x", pdata->rfe_ct=
l);
=20
 	/* Enable or disable checksum offload engines */
-	ethtool_op_set_tx_hw_csum(dev->net, DEFAULT_TX_CSUM_ENABLE);
-	ret =3D smsc75xx_set_rx_csum_offload(dev);
-	check_warn_return(ret, "Failed to set rx csum offload: %d", ret);
-
-	smsc75xx_ethtool_set_tso(dev->net, DEFAULT_TSO_ENABLE);
+	smsc75xx_set_features(dev->net, dev->net->features);
=20
 	smsc75xx_set_multicast(dev->net);
=20
@@ -1037,6 +1000,7 @@ static const struct net_device_ops smsc75xx_netde=
v_ops =3D {
 	.ndo_validate_addr	=3D eth_validate_addr,
 	.ndo_do_ioctl 		=3D smsc75xx_ioctl,
 	.ndo_set_multicast_list =3D smsc75xx_set_multicast,
+	.ndo_set_features	=3D smsc75xx_set_features,
 };
=20
 static int smsc75xx_bind(struct usbnet *dev, struct usb_interface *int=
f)
@@ -1065,10 +1029,17 @@ static int smsc75xx_bind(struct usbnet *dev, st=
ruct usb_interface *intf)
=20
 	INIT_WORK(&pdata->set_multicast, smsc75xx_deferred_multicast_write);
=20
-	pdata->use_rx_csum =3D DEFAULT_RX_CSUM_ENABLE;
+	if (DEFAULT_TX_CSUM_ENABLE) {
+		dev->net->features |=3D NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
+		if (DEFAULT_TSO_ENABLE)
+			dev->net->features |=3D NETIF_F_SG |
+				NETIF_F_TSO | NETIF_F_TSO6;
+	}
+	if (DEFAULT_RX_CSUM_ENABLE)
+		dev->net->features |=3D NETIF_F_RXCSUM;
=20
-	/* We have to advertise SG otherwise TSO cannot be enabled */
-	dev->net->features |=3D NETIF_F_SG;
+	dev->net->hw_features =3D NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
+		NETIF_F_SG | NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_RXCSUM;
=20
 	/* Init all registers */
 	ret =3D smsc75xx_reset(dev);
@@ -1091,10 +1062,11 @@ static void smsc75xx_unbind(struct usbnet *dev,=
 struct usb_interface *intf)
 	}
 }
=20
-static void smsc75xx_rx_csum_offload(struct sk_buff *skb, u32 rx_cmd_a=
,
-				     u32 rx_cmd_b)
+static void smsc75xx_rx_csum_offload(struct usbnet *dev, struct sk_buf=
f *skb,
+				     u32 rx_cmd_a, u32 rx_cmd_b)
 {
-	if (unlikely(rx_cmd_a & RX_CMD_A_LCSM)) {
+	if (!(dev->net->features & NETIF_F_RXCSUM) ||
+	    unlikely(rx_cmd_a & RX_CMD_A_LCSM)) {
 		skb->ip_summed =3D CHECKSUM_NONE;
 	} else {
 		skb->csum =3D ntohs((u16)(rx_cmd_b >> RX_CMD_B_CSUM_SHIFT));
@@ -1104,8 +1076,6 @@ static void smsc75xx_rx_csum_offload(struct sk_bu=
ff *skb, u32 rx_cmd_a,
=20
 static int smsc75xx_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 {
-	struct smsc75xx_priv *pdata =3D (struct smsc75xx_priv *)(dev->data[0]=
);
-
 	while (skb->len > 0) {
 		u32 rx_cmd_a, rx_cmd_b, align_count, size;
 		struct sk_buff *ax_skb;
@@ -1145,11 +1115,8 @@ static int smsc75xx_rx_fixup(struct usbnet *dev,=
 struct sk_buff *skb)
=20
 			/* last frame in this batch */
 			if (skb->len =3D=3D size) {
-				if (pdata->use_rx_csum)
-					smsc75xx_rx_csum_offload(skb, rx_cmd_a,
-						rx_cmd_b);
-				else
-					skb->ip_summed =3D CHECKSUM_NONE;
+				smsc75xx_rx_csum_offload(dev, skb, rx_cmd_a,
+					rx_cmd_b);
=20
 				skb_trim(skb, skb->len - 4); /* remove fcs */
 				skb->truesize =3D size + sizeof(struct sk_buff);
@@ -1167,11 +1134,8 @@ static int smsc75xx_rx_fixup(struct usbnet *dev,=
 struct sk_buff *skb)
 			ax_skb->data =3D packet;
 			skb_set_tail_pointer(ax_skb, size);
=20
-			if (pdata->use_rx_csum)
-				smsc75xx_rx_csum_offload(ax_skb, rx_cmd_a,
-					rx_cmd_b);
-			else
-				ax_skb->ip_summed =3D CHECKSUM_NONE;
+			smsc75xx_rx_csum_offload(dev, ax_skb, rx_cmd_a,
+				rx_cmd_b);
=20
 			skb_trim(ax_skb, ax_skb->len - 4); /* remove fcs */
 			ax_skb->truesize =3D size + sizeof(struct sk_buff);
diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index 727874d..708f208 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -52,8 +52,6 @@ struct smsc95xx_priv {
 	u32 hash_hi;
 	u32 hash_lo;
 	spinlock_t mac_cr_lock;
-	bool use_tx_csum;
-	bool use_rx_csum;
 };
=20
 struct usb_context {
@@ -517,22 +515,24 @@ static void smsc95xx_status(struct usbnet *dev, s=
truct urb *urb)
 }
=20
 /* Enable or disable Tx & Rx checksum offload engines */
-static int smsc95xx_set_csums(struct usbnet *dev)
+static int smsc95xx_set_features(struct net_device *netdev, u32 featur=
es)
 {
-	struct smsc95xx_priv *pdata =3D (struct smsc95xx_priv *)(dev->data[0]=
);
+	struct usbnet *dev =3D netdev_priv(netdev);
 	u32 read_buf;
-	int ret =3D smsc95xx_read_reg(dev, COE_CR, &read_buf);
+	int ret;
+
+	ret =3D smsc95xx_read_reg(dev, COE_CR, &read_buf);
 	if (ret < 0) {
 		netdev_warn(dev->net, "Failed to read COE_CR: %d\n", ret);
 		return ret;
 	}
=20
-	if (pdata->use_tx_csum)
+	if (features & NETIF_F_HW_CSUM)
 		read_buf |=3D Tx_COE_EN_;
 	else
 		read_buf &=3D ~Tx_COE_EN_;
=20
-	if (pdata->use_rx_csum)
+	if (features & NETIF_F_RXCSUM)
 		read_buf |=3D Rx_COE_EN_;
 	else
 		read_buf &=3D ~Rx_COE_EN_;
@@ -576,43 +576,6 @@ static int smsc95xx_ethtool_set_eeprom(struct net_=
device *netdev,
 	return smsc95xx_write_eeprom(dev, ee->offset, ee->len, data);
 }
=20
-static u32 smsc95xx_ethtool_get_rx_csum(struct net_device *netdev)
-{
-	struct usbnet *dev =3D netdev_priv(netdev);
-	struct smsc95xx_priv *pdata =3D (struct smsc95xx_priv *)(dev->data[0]=
);
-
-	return pdata->use_rx_csum;
-}
-
-static int smsc95xx_ethtool_set_rx_csum(struct net_device *netdev, u32=
 val)
-{
-	struct usbnet *dev =3D netdev_priv(netdev);
-	struct smsc95xx_priv *pdata =3D (struct smsc95xx_priv *)(dev->data[0]=
);
-
-	pdata->use_rx_csum =3D !!val;
-
-	return smsc95xx_set_csums(dev);
-}
-
-static u32 smsc95xx_ethtool_get_tx_csum(struct net_device *netdev)
-{
-	struct usbnet *dev =3D netdev_priv(netdev);
-	struct smsc95xx_priv *pdata =3D (struct smsc95xx_priv *)(dev->data[0]=
);
-
-	return pdata->use_tx_csum;
-}
-
-static int smsc95xx_ethtool_set_tx_csum(struct net_device *netdev, u32=
 val)
-{
-	struct usbnet *dev =3D netdev_priv(netdev);
-	struct smsc95xx_priv *pdata =3D (struct smsc95xx_priv *)(dev->data[0]=
);
-
-	pdata->use_tx_csum =3D !!val;
-
-	ethtool_op_set_tx_hw_csum(netdev, pdata->use_tx_csum);
-	return smsc95xx_set_csums(dev);
-}
-
 static const struct ethtool_ops smsc95xx_ethtool_ops =3D {
 	.get_link	=3D usbnet_get_link,
 	.nway_reset	=3D usbnet_nway_reset,
@@ -624,10 +587,6 @@ static const struct ethtool_ops smsc95xx_ethtool_o=
ps =3D {
 	.get_eeprom_len	=3D smsc95xx_ethtool_get_eeprom_len,
 	.get_eeprom	=3D smsc95xx_ethtool_get_eeprom,
 	.set_eeprom	=3D smsc95xx_ethtool_set_eeprom,
-	.get_tx_csum	=3D smsc95xx_ethtool_get_tx_csum,
-	.set_tx_csum	=3D smsc95xx_ethtool_set_tx_csum,
-	.get_rx_csum	=3D smsc95xx_ethtool_get_rx_csum,
-	.set_rx_csum	=3D smsc95xx_ethtool_set_rx_csum,
 };
=20
 static int smsc95xx_ioctl(struct net_device *netdev, struct ifreq *rq,=
 int cmd)
@@ -755,7 +714,6 @@ static int smsc95xx_phy_initialize(struct usbnet *d=
ev)
 static int smsc95xx_reset(struct usbnet *dev)
 {
 	struct smsc95xx_priv *pdata =3D (struct smsc95xx_priv *)(dev->data[0]=
);
-	struct net_device *netdev =3D dev->net;
 	u32 read_buf, write_buf, burst_cap;
 	int ret =3D 0, timeout;
=20
@@ -975,12 +933,7 @@ static int smsc95xx_reset(struct usbnet *dev)
 	}
=20
 	/* Enable or disable checksum offload engines */
-	ethtool_op_set_tx_hw_csum(netdev, pdata->use_tx_csum);
-	ret =3D smsc95xx_set_csums(dev);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Failed to set csum offload: %d\n", ret);
-		return ret;
-	}
+	smsc95xx_set_features(dev->net, dev->net->features);
=20
 	smsc95xx_set_multicast(dev->net);
=20
@@ -1019,6 +972,7 @@ static const struct net_device_ops smsc95xx_netdev=
_ops =3D {
 	.ndo_validate_addr	=3D eth_validate_addr,
 	.ndo_do_ioctl 		=3D smsc95xx_ioctl,
 	.ndo_set_multicast_list =3D smsc95xx_set_multicast,
+	.ndo_set_features	=3D smsc95xx_set_features,
 };
=20
 static int smsc95xx_bind(struct usbnet *dev, struct usb_interface *int=
f)
@@ -1045,8 +999,12 @@ static int smsc95xx_bind(struct usbnet *dev, stru=
ct usb_interface *intf)
=20
 	spin_lock_init(&pdata->mac_cr_lock);
=20
-	pdata->use_tx_csum =3D DEFAULT_TX_CSUM_ENABLE;
-	pdata->use_rx_csum =3D DEFAULT_RX_CSUM_ENABLE;
+	if (DEFAULT_TX_CSUM_ENABLE)
+		dev->net->features |=3D NETIF_F_HW_CSUM;
+	if (DEFAULT_RX_CSUM_ENABLE)
+		dev->net->features |=3D NETIF_F_RXCSUM;
+
+	dev->net->hw_features =3D NETIF_F_HW_CSUM | NETIF_F_RXCSUM;
=20
 	smsc95xx_init_mac_address(dev);
=20
@@ -1056,7 +1014,7 @@ static int smsc95xx_bind(struct usbnet *dev, stru=
ct usb_interface *intf)
 	dev->net->netdev_ops =3D &smsc95xx_netdev_ops;
 	dev->net->ethtool_ops =3D &smsc95xx_ethtool_ops;
 	dev->net->flags |=3D IFF_MULTICAST;
-	dev->net->hard_header_len +=3D SMSC95XX_TX_OVERHEAD;
+	dev->net->hard_header_len +=3D SMSC95XX_TX_OVERHEAD_CSUM;
 	return 0;
 }
=20
@@ -1080,8 +1038,6 @@ static void smsc95xx_rx_csum_offload(struct sk_bu=
ff *skb)
=20
 static int smsc95xx_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 {
-	struct smsc95xx_priv *pdata =3D (struct smsc95xx_priv *)(dev->data[0]=
);
-
 	while (skb->len > 0) {
 		u32 header, align_count;
 		struct sk_buff *ax_skb;
@@ -1123,7 +1079,7 @@ static int smsc95xx_rx_fixup(struct usbnet *dev, =
struct sk_buff *skb)
=20
 			/* last frame in this batch */
 			if (skb->len =3D=3D size) {
-				if (pdata->use_rx_csum)
+				if (dev->net->features & NETIF_F_RXCSUM)
 					smsc95xx_rx_csum_offload(skb);
 				skb_trim(skb, skb->len - 4); /* remove fcs */
 				skb->truesize =3D size + sizeof(struct sk_buff);
@@ -1141,7 +1097,7 @@ static int smsc95xx_rx_fixup(struct usbnet *dev, =
struct sk_buff *skb)
 			ax_skb->data =3D packet;
 			skb_set_tail_pointer(ax_skb, size);
=20
-			if (pdata->use_rx_csum)
+			if (dev->net->features & NETIF_F_RXCSUM)
 				smsc95xx_rx_csum_offload(ax_skb);
 			skb_trim(ax_skb, ax_skb->len - 4); /* remove fcs */
 			ax_skb->truesize =3D size + sizeof(struct sk_buff);
@@ -1174,8 +1130,7 @@ static u32 smsc95xx_calc_csum_preamble(struct sk_=
buff *skb)
 static struct sk_buff *smsc95xx_tx_fixup(struct usbnet *dev,
 					 struct sk_buff *skb, gfp_t flags)
 {
-	struct smsc95xx_priv *pdata =3D (struct smsc95xx_priv *)(dev->data[0]=
);
-	bool csum =3D pdata->use_tx_csum && (skb->ip_summed =3D=3D CHECKSUM_P=
ARTIAL);
+	bool csum =3D skb->ip_summed =3D=3D CHECKSUM_PARTIAL;
 	int overhead =3D csum ? SMSC95XX_TX_OVERHEAD_CSUM : SMSC95XX_TX_OVERH=
EAD;
 	u32 tx_cmd_a, tx_cmd_b;
=20
--=20
1.7.2.5


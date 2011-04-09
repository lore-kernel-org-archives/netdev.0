From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH] net: 8139cp: convert to hw_features
Date: Sat,  9 Apr 2011 12:58:18 +0200 (CEST)
Message-ID: <20110409105818.F217813909@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:38260 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754195Ab1DIK6U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Apr 2011 06:58:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/8139cp.c |   46 +++++++++++++++++-------------------------=
----
 1 files changed, 17 insertions(+), 29 deletions(-)

diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
index dd16e83..10c4505 100644
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -758,8 +758,7 @@ static netdev_tx_t cp_start_xmit (struct sk_buff *s=
kb,
=20
 	entry =3D cp->tx_head;
 	eor =3D (entry =3D=3D (CP_TX_RING_SIZE - 1)) ? RingEnd : 0;
-	if (dev->features & NETIF_F_TSO)
-		mss =3D skb_shinfo(skb)->gso_size;
+	mss =3D skb_shinfo(skb)->gso_size;
=20
 	if (skb_shinfo(skb)->nr_frags =3D=3D 0) {
 		struct cp_desc *txd =3D &cp->tx_ring[entry];
@@ -1416,32 +1415,23 @@ static void cp_set_msglevel(struct net_device *=
dev, u32 value)
 	cp->msg_enable =3D value;
 }
=20
-static u32 cp_get_rx_csum(struct net_device *dev)
+static int cp_set_features(struct net_device *dev, u32 features)
 {
 	struct cp_private *cp =3D netdev_priv(dev);
-	return (cpr16(CpCmd) & RxChkSum) ? 1 : 0;
-}
+	unsigned long flags;
=20
-static int cp_set_rx_csum(struct net_device *dev, u32 data)
-{
-	struct cp_private *cp =3D netdev_priv(dev);
-	u16 cmd =3D cp->cpcmd, newcmd;
+	if (!((dev->features ^ features) & NETIF_F_RXCSUM))
+		return 0;
=20
-	newcmd =3D cmd;
+	spin_lock_irqsave(&cp->lock, flags);
=20
-	if (data)
-		newcmd |=3D RxChkSum;
+	if (features & NETIF_F_RXCSUM)
+		cp->cpcmd |=3D RxChkSum;
 	else
-		newcmd &=3D ~RxChkSum;
+		cp->cpcmd &=3D ~RxChkSum;
=20
-	if (newcmd !=3D cmd) {
-		unsigned long flags;
-
-		spin_lock_irqsave(&cp->lock, flags);
-		cp->cpcmd =3D newcmd;
-		cpw16_f(CpCmd, newcmd);
-		spin_unlock_irqrestore(&cp->lock, flags);
-	}
+	cpw16_f(CpCmd, cp->cpcmd);
+	spin_unlock_irqrestore(&cp->lock, flags);
=20
 	return 0;
 }
@@ -1554,11 +1544,6 @@ static const struct ethtool_ops cp_ethtool_ops =3D=
 {
 	.get_link		=3D ethtool_op_get_link,
 	.get_msglevel		=3D cp_get_msglevel,
 	.set_msglevel		=3D cp_set_msglevel,
-	.get_rx_csum		=3D cp_get_rx_csum,
-	.set_rx_csum		=3D cp_set_rx_csum,
-	.set_tx_csum		=3D ethtool_op_set_tx_csum, /* local! */
-	.set_sg			=3D ethtool_op_set_sg,
-	.set_tso		=3D ethtool_op_set_tso,
 	.get_regs		=3D cp_get_regs,
 	.get_wol		=3D cp_get_wol,
 	.set_wol		=3D cp_set_wol,
@@ -1831,6 +1816,7 @@ static const struct net_device_ops cp_netdev_ops =
=3D {
 	.ndo_do_ioctl		=3D cp_ioctl,
 	.ndo_start_xmit		=3D cp_start_xmit,
 	.ndo_tx_timeout		=3D cp_tx_timeout,
+	.ndo_set_features	=3D cp_set_features,
 #if CP_VLAN_TAG_USED
 	.ndo_vlan_rx_register	=3D cp_vlan_rx_register,
 #endif
@@ -1934,6 +1920,9 @@ static int cp_init_one (struct pci_dev *pdev, con=
st struct pci_device_id *ent)
 	cp->cpcmd =3D (pci_using_dac ? PCIDAC : 0) |
 		    PCIMulRW | RxChkSum | CpRxOn | CpTxOn;
=20
+	dev->features |=3D NETIF_F_RXCSUM;
+	dev->hw_features |=3D NETIF_F_RXCSUM;
+
 	regs =3D ioremap(pciaddr, CP_REGS_SIZE);
 	if (!regs) {
 		rc =3D -EIO;
@@ -1966,9 +1955,8 @@ static int cp_init_one (struct pci_dev *pdev, con=
st struct pci_device_id *ent)
 	if (pci_using_dac)
 		dev->features |=3D NETIF_F_HIGHDMA;
=20
-#if 0 /* disabled by default until verified */
-	dev->features |=3D NETIF_F_TSO;
-#endif
+	/* disabled by default until verified */
+	dev->hw_features |=3D NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO;
=20
 	dev->irq =3D pdev->irq;
=20
--=20
1.7.2.5


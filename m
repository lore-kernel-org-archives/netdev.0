From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH] Fix IXP4xx Ethernet RX with both IFF_ALLMULTI and IFF_PROMISC.
Date: Mon, 09 Mar 2015 23:07:28 +0100
Message-ID: <m3pp8hvn8f.fsf@pm.waw.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from inx.pm.waw.pl ([195.116.170.130]:40850 "EHLO inx.pm.waw.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752377AbbCIWOS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 18:14:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This long standing bug caused IFF_PROMISC to be ignored when
IFF_ALLMULTI was requested.

Also, without any multicast address configured, the driver will use
device MAC address for the multicast filter, instead of accepting all
inbound traffic.

Signed-off-by: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>

--- a/drivers/net/ethernet/xscale/ixp4xx_eth.c
+++ b/drivers/net/ethernet/xscale/ixp4xx_eth.c
@@ -933,40 +933,42 @@ static int eth_xmit(struct sk_buff *skb, struct n=
et_device *dev)
 static void eth_set_mcast_list(struct net_device *dev)
 {
 	struct port *port =3D netdev_priv(dev);
-	struct netdev_hw_addr *ha;
-	u8 diffs[ETH_ALEN], *addr;
 	int i;
 	static const u8 allmulti[] =3D { 0x01, 0x00, 0x00, 0x00, 0x00, 0x00 }=
;
=20
-	if (dev->flags & IFF_ALLMULTI) {
-		for (i =3D 0; i < ETH_ALEN; i++) {
-			__raw_writel(allmulti[i], &port->regs->mcast_addr[i]);
-			__raw_writel(allmulti[i], &port->regs->mcast_mask[i]);
-		}
-		__raw_writel(DEFAULT_RX_CNTRL0 | RX_CNTRL0_ADDR_FLTR_EN,
-			&port->regs->rx_control[0]);
-		return;
-	}
-
-	if ((dev->flags & IFF_PROMISC) || netdev_mc_empty(dev)) {
+	if (dev->flags & IFF_PROMISC) {
 		__raw_writel(DEFAULT_RX_CNTRL0 & ~RX_CNTRL0_ADDR_FLTR_EN,
 			     &port->regs->rx_control[0]);
 		return;
 	}
=20
-	memset(diffs, 0, ETH_ALEN);
+	if (dev->flags & IFF_ALLMULTI) {
+		for (i =3D 0; i < ETH_ALEN; i++) {
+			__raw_writel(allmulti[i], &port->regs->mcast_addr[i]);
+			__raw_writel(allmulti[i], &port->regs->mcast_mask[i]);
+		}
+	} else {
+		struct netdev_hw_addr *ha;
+		u8 diffs[ETH_ALEN], *addr =3D NULL;
+
+		memset(diffs, 0, ETH_ALEN);
+
+		/* calculate bits which differ between multicast addresses */
+		netdev_for_each_mc_addr(ha, dev) {
+			if (!addr)
+				addr =3D ha->addr; /* first multicast address */
+			else
+				for (i =3D 0; i < ETH_ALEN; i++)
+					diffs[i] |=3D addr[i] ^ ha->addr[i];
+		}
=20
-	addr =3D NULL;
-	netdev_for_each_mc_addr(ha, dev) {
-		if (!addr)
-			addr =3D ha->addr; /* first MAC address */
-		for (i =3D 0; i < ETH_ALEN; i++)
-			diffs[i] |=3D addr[i] ^ ha->addr[i];
-	}
+		if (!addr) /* use device MAC address instead */
+			addr =3D dev->dev_addr;
=20
-	for (i =3D 0; i < ETH_ALEN; i++) {
-		__raw_writel(addr[i], &port->regs->mcast_addr[i]);
-		__raw_writel(~diffs[i], &port->regs->mcast_mask[i]);
+		for (i =3D 0; i < ETH_ALEN; i++) {
+			__raw_writel(addr[i], &port->regs->mcast_addr[i]);
+			__raw_writel(~diffs[i], &port->regs->mcast_mask[i]);
+		}
 	}
=20
 	__raw_writel(DEFAULT_RX_CNTRL0 | RX_CNTRL0_ADDR_FLTR_EN,

--=20
Krzysztof Halasa

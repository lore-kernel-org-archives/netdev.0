From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: [PATCH RFT 5/8] net: pxa168_eth: Remove in-driver PHY mangling
Date: Thu,  9 Oct 2014 14:39:03 +0200
Message-ID: <1412858346-11334-6-git-send-email-sebastian.hesselbarth@gmail.com>
References: <1412858346-11334-1-git-send-email-sebastian.hesselbarth@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	=?UTF-8?q?Antoine=20T=C3=A9nart?=
	<antoine.tenart@free-electrons.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Eric Miao <eric.y.miao@gmail.com>,
	Haojian Zhuang <haojian.zhuang@gmail.com>,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1412858346-11334-1-git-send-email-sebastian.hesselbarth@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With properly using libphy PHYs now, remove the in-driver PHY
mangling.

Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
---
Cc: "David S. Miller" <davem@davemloft.net>
Cc: "Antoine T=C3=A9nart" <antoine.tenart@free-electrons.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>
Cc: Eric Miao <eric.y.miao@gmail.com>
Cc: Haojian Zhuang <haojian.zhuang@gmail.com>
Cc: linux-arm-kernel@lists.infradead.org
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 drivers/net/ethernet/marvell/pxa168_eth.c | 126 ----------------------=
--------
 1 file changed, 126 deletions(-)

diff --git a/drivers/net/ethernet/marvell/pxa168_eth.c b/drivers/net/et=
hernet/marvell/pxa168_eth.c
index a406a91812c5..4e77c5142544 100644
--- a/drivers/net/ethernet/marvell/pxa168_eth.c
+++ b/drivers/net/ethernet/marvell/pxa168_eth.c
@@ -177,7 +177,6 @@
 #define LINK_UP			(1 << 3)
=20
 /* Bit definitions for work to be done */
-#define WORK_LINK		(1 << 0)
 #define WORK_TX_DONE		(1 << 1)
=20
 /*
@@ -284,7 +283,6 @@ static void eth_port_reset(struct net_device *dev);
 static void eth_port_start(struct net_device *dev);
 static int pxa168_eth_open(struct net_device *dev);
 static int pxa168_eth_stop(struct net_device *dev);
-static int ethernet_phy_setup(struct net_device *dev);
=20
 static inline u32 rdl(struct pxa168_eth_private *pep, int offset)
 {
@@ -316,26 +314,6 @@ static void abort_dma(struct pxa168_eth_private *p=
ep)
 		netdev_err(pep->dev, "%s : DMA Stuck\n", __func__);
 }
=20
-static int ethernet_phy_get(struct pxa168_eth_private *pep)
-{
-	unsigned int reg_data;
-
-	reg_data =3D rdl(pep, PHY_ADDRESS);
-
-	return (reg_data >> (5 * pep->port_num)) & 0x1f;
-}
-
-static void ethernet_phy_set_addr(struct pxa168_eth_private *pep, int =
phy_addr)
-{
-	u32 reg_data;
-	int addr_shift =3D 5 * pep->port_num;
-
-	reg_data =3D rdl(pep, PHY_ADDRESS);
-	reg_data &=3D ~(0x1f << addr_shift);
-	reg_data |=3D (phy_addr & 0x1f) << addr_shift;
-	wrl(pep, PHY_ADDRESS, reg_data);
-}
-
 static void rxq_refill(struct net_device *dev)
 {
 	struct pxa168_eth_private *pep =3D netdev_priv(dev);
@@ -890,43 +868,9 @@ static int pxa168_eth_collect_events(struct pxa168=
_eth_private *pep,
 	}
 	if (icr & ICR_RXBUF)
 		ret =3D 1;
-	if (icr & ICR_MII_CH) {
-		pep->work_todo |=3D WORK_LINK;
-		ret =3D 1;
-	}
 	return ret;
 }
=20
-static void handle_link_event(struct pxa168_eth_private *pep)
-{
-	struct net_device *dev =3D pep->dev;
-	u32 port_status;
-	int speed;
-	int duplex;
-	int fc;
-
-	port_status =3D rdl(pep, PORT_STATUS);
-	if (!(port_status & LINK_UP)) {
-		if (netif_carrier_ok(dev)) {
-			netdev_info(dev, "link down\n");
-			netif_carrier_off(dev);
-			txq_reclaim(dev, 1);
-		}
-		return;
-	}
-	if (port_status & PORT_SPEED_100)
-		speed =3D 100;
-	else
-		speed =3D 10;
-
-	duplex =3D (port_status & FULL_DUPLEX) ? 1 : 0;
-	fc =3D (port_status & FLOW_CONTROL_DISABLED) ? 0 : 1;
-	netdev_info(dev, "link up, %d Mb/s, %s duplex, flow control %sabled\n=
",
-		    speed, duplex ? "full" : "half", fc ? "en" : "dis");
-	if (!netif_carrier_ok(dev))
-		netif_carrier_on(dev);
-}
-
 static irqreturn_t pxa168_eth_int_handler(int irq, void *dev_id)
 {
 	struct net_device *dev =3D (struct net_device *)dev_id;
@@ -1301,10 +1245,6 @@ static int pxa168_rx_poll(struct napi_struct *na=
pi, int budget)
 	struct net_device *dev =3D pep->dev;
 	int work_done =3D 0;
=20
-	if (unlikely(pep->work_todo & WORK_LINK)) {
-		pep->work_todo &=3D ~(WORK_LINK);
-		handle_link_event(pep);
-	}
 	/*
 	 * We call txq_reclaim every time since in NAPI interupts are disable=
d
 	 * and due to this we miss the TX_DONE interrupt,which is not updated=
 in
@@ -1427,72 +1367,6 @@ static int pxa168_eth_do_ioctl(struct net_device=
 *dev, struct ifreq *ifr,
 	return -EOPNOTSUPP;
 }
=20
-static struct phy_device *phy_scan(struct pxa168_eth_private *pep, int=
 phy_addr)
-{
-	struct mii_bus *bus =3D pep->smi_bus;
-	struct phy_device *phydev;
-	int start;
-	int num;
-	int i;
-
-	if (phy_addr =3D=3D PXA168_ETH_PHY_ADDR_DEFAULT) {
-		/* Scan entire range */
-		start =3D ethernet_phy_get(pep);
-		num =3D 32;
-	} else {
-		/* Use phy addr specific to platform */
-		start =3D phy_addr & 0x1f;
-		num =3D 1;
-	}
-	phydev =3D NULL;
-	for (i =3D 0; i < num; i++) {
-		int addr =3D (start + i) & 0x1f;
-		if (bus->phy_map[addr] =3D=3D NULL)
-			mdiobus_scan(bus, addr);
-
-		if (phydev =3D=3D NULL) {
-			phydev =3D bus->phy_map[addr];
-			if (phydev !=3D NULL)
-				ethernet_phy_set_addr(pep, addr);
-		}
-	}
-
-	return phydev;
-}
-
-static void phy_init(struct pxa168_eth_private *pep)
-{
-	struct phy_device *phy =3D pep->phy;
-
-	phy_attach(pep->dev, dev_name(&phy->dev), pep->phy_intf);
-
-	phy->speed =3D pep->phy_speed;
-	phy->duplex =3D pep->phy_duplex;
-	phy->autoneg =3D AUTONEG_ENABLE;
-	phy->supported &=3D PHY_BASIC_FEATURES;
-	phy->advertising =3D phy->supported | ADVERTISED_Autoneg;
-
-	if (pep->phy_speed !=3D 0) {
-		phy->autoneg =3D AUTONEG_DISABLE;
-		phy->advertising =3D 0;
-	}
-
-	phy_start_aneg(phy);
-}
-
-static int ethernet_phy_setup(struct net_device *dev)
-{
-	struct pxa168_eth_private *pep =3D netdev_priv(dev);
-
-	pep->phy =3D phy_scan(pep, pep->phy_addr & 0x1f);
-	if (pep->phy !=3D NULL)
-		phy_init(pep);
-
-	update_hash_table_mac_address(pep, NULL, dev->dev_addr);
-
-	return 0;
-}
-
 static int pxa168_get_settings(struct net_device *dev, struct ethtool_=
cmd *cmd)
 {
 	struct pxa168_eth_private *pep =3D netdev_priv(dev);
--=20
2.1.1

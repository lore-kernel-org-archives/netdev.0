From: Max Schwarz <max.schwarz@online.de>
Subject: [PATCH] arc_emac: write initial MAC address from devicetree to hw
Date: Fri, 18 Apr 2014 02:17:32 +0200
Message-ID: <1664530.jeK9vBIgft@typ>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey Brodkin <Alexey.Brodkin@synopsys.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Heiko Stuebner <heiko@sntech.de>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The MAC address retrieved from dt was not actually written to the
hardware. This meant proper communication was only possible after
changing the MAC address.

=46ix that by always writing the mac address during probing.

Signed-off-by: Max Schwarz <max.schwarz@online.de>
---

I recently noticed this problem on the Radxa Rock board. I'm not
sure how this has ever worked on other platforms, though. I can
only receive broadcast packets without configuring the address.

Running ifconfig eth0 hw ether XYZ or applying the patch fixes
the problem for me.

CCing Heiko St=FCbner because he has seen the problem as well.

 drivers/net/ethernet/arc/emac_main.c | 21 ++++++++++++++-------
 1 file changed, 14 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/arc/emac_main.c b/drivers/net/etherne=
t/arc/emac_main.c
index eeecc29..9f45782 100644
--- a/drivers/net/ethernet/arc/emac_main.c
+++ b/drivers/net/ethernet/arc/emac_main.c
@@ -574,6 +574,18 @@ static int arc_emac_tx(struct sk_buff *skb, struct=
 net_device *ndev)
 	return NETDEV_TX_OK;
 }
=20
+static void arc_emac_set_address_internal(struct net_device *ndev)
+{
+	struct arc_emac_priv *priv =3D netdev_priv(ndev);
+	unsigned int addr_low, addr_hi;
+
+	addr_low =3D le32_to_cpu(*(__le32 *) &ndev->dev_addr[0]);
+	addr_hi =3D le16_to_cpu(*(__le16 *) &ndev->dev_addr[4]);
+
+	arc_reg_set(priv, R_ADDRL, addr_low);
+	arc_reg_set(priv, R_ADDRH, addr_hi);
+}
+
 /**
  * arc_emac_set_address - Set the MAC address for this device.
  * @ndev:	Pointer to net_device structure.
@@ -587,9 +599,7 @@ static int arc_emac_tx(struct sk_buff *skb, struct =
net_device *ndev)
  */
 static int arc_emac_set_address(struct net_device *ndev, void *p)
 {
-	struct arc_emac_priv *priv =3D netdev_priv(ndev);
 	struct sockaddr *addr =3D p;
-	unsigned int addr_low, addr_hi;
=20
 	if (netif_running(ndev))
 		return -EBUSY;
@@ -599,11 +609,7 @@ static int arc_emac_set_address(struct net_device =
*ndev, void *p)
=20
 	memcpy(ndev->dev_addr, addr->sa_data, ndev->addr_len);
=20
-	addr_low =3D le32_to_cpu(*(__le32 *) &ndev->dev_addr[0]);
-	addr_hi =3D le16_to_cpu(*(__le16 *) &ndev->dev_addr[4]);
-
-	arc_reg_set(priv, R_ADDRL, addr_low);
-	arc_reg_set(priv, R_ADDRH, addr_hi);
+	arc_emac_set_address_internal(ndev);
=20
 	return 0;
 }
@@ -713,6 +719,7 @@ static int arc_emac_probe(struct platform_device *p=
dev)
 	else
 		eth_hw_addr_random(ndev);
=20
+	arc_emac_set_address_internal(ndev);
 	dev_info(&pdev->dev, "MAC address is now %pM\n", ndev->dev_addr);
=20
 	/* Do 1 allocation instead of 2 separate ones for Rx and Tx BD rings =
*/
--=20
1.8.3.2

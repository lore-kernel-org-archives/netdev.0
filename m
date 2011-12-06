From: =?utf-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>
Subject: [PATCH][NET] several cleanups and bugfixes for fec.c: fix the .remove code
Date: Tue,  6 Dec 2011 11:27:15 +0100
Message-ID: <04c11563fee748562d7b53d5e5b3c5cf37fef200.1323163127.git.LW@KARO-electronics.de>
References: <cover.1323163127.git.LW@KARO-electronics.de>
 <bd4415514fa0b40ece04d56b3ac4f549e79d87d7.1323163127.git.LW@KARO-electronics.de>
 <6c28f25c5c6d2f88d0985ce361c5e16f19db27d0.1323163127.git.LW@KARO-electronics.de>
 <0b92136d69e509a6ce49b526e1834f0ec90b04a4.1323163127.git.LW@KARO-electronics.de>
 <6d1e5cdcbfc48df864ec9e0939645c0e95389d2a.1323163127.git.LW@KARO-electronics.de>
 <55b78c1766da5b0d0d679f5eae3fb9fc74a6ceef.1323163127.git.LW@KARO-electronics.de>
 <d6f4de9e4cfb393754b42815a2ef1a59c96eab83.1323163127.git.LW@KARO-electronics.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, Shawn Guo <shawn.guo@linaro.org>,
	linux-arm-kernel@lists.infradead.org,
	=?utf-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <d6f4de9e4cfb393754b42815a2ef1a59c96eab83.1323163127.git.LW@KARO-electronics.de>
In-Reply-To: <cover.1323163127.git.LW@KARO-electronics.de>
References: <cover.1323163127.git.LW@KARO-electronics.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The .remove code is broken in several ways.
 - mdiobus_unregister() is called twice for the same object in case of =
dual FEC
 - phy_disconnect() is being called when the PHY is already disconnecte=
d
 - the requested IRQ(s) are not freed
 - fec_stop() is being called with the inteface already stopped

 All of those lead to kernel crashes if the remove function is actually=
 used.

Signed-off-by: Lothar Wa=C3=9Fmann <LW@KARO-electronics.de>
---
 drivers/net/ethernet/freescale/fec.c |   30 +++++++++++++++++++++-----=
----
 1 files changed, 21 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/etherne=
t/freescale/fec.c
index ab0afb5..70ec7ec 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -235,6 +235,7 @@ struct fec_enet_private {
=20
 	/* Phylib and MDIO interface */
 	struct	mii_bus *mii_bus;
+	int	mii_cnt;
 	struct	phy_device *phy_dev;
 	int	mii_timeout;
 	uint	phy_speed;
@@ -1040,8 +1041,12 @@ static int fec_enet_mii_init(struct platform_dev=
ice *pdev)
 	 */
 	if ((id_entry->driver_data & FEC_QUIRK_ENET_MAC) && pdev->id > 0) {
 		/* fec1 uses fec0 mii_bus */
-		fep->mii_bus =3D fec0_mii_bus;
-		return 0;
+		if (fep->mii_cnt && fec0_mii_bus) {
+			fep->mii_bus =3D fec0_mii_bus;
+			fep->mii_cnt++;
+			return 0;
+		}
+		return -ENOENT;
 	}
=20
 	fep->mii_timeout =3D 0;
@@ -1086,6 +1091,8 @@ static int fec_enet_mii_init(struct platform_devi=
ce *pdev)
 	if (mdiobus_register(fep->mii_bus))
 		goto err_out_free_mdio_irq;
=20
+	fep->mii_cnt++;
+
 	/* save fec0 mii_bus */
 	if (id_entry->driver_data & FEC_QUIRK_ENET_MAC)
 		fec0_mii_bus =3D fep->mii_bus;
@@ -1102,11 +1109,11 @@ err_out:
=20
 static void fec_enet_mii_remove(struct fec_enet_private *fep)
 {
-	if (fep->phy_dev)
-		phy_disconnect(fep->phy_dev);
-	mdiobus_unregister(fep->mii_bus);
-	kfree(fep->mii_bus->irq);
-	mdiobus_free(fep->mii_bus);
+	if (--fep->mii_cnt =3D=3D 0) {
+		mdiobus_unregister(fep->mii_bus);
+		kfree(fep->mii_bus->irq);
+		mdiobus_free(fep->mii_bus);
+	}
 }
=20
 static int fec_enet_get_settings(struct net_device *ndev,
@@ -1646,13 +1653,18 @@ fec_drv_remove(struct platform_device *pdev)
 	struct net_device *ndev =3D platform_get_drvdata(pdev);
 	struct fec_enet_private *fep =3D netdev_priv(ndev);
 	struct resource *r;
+	int i;
=20
-	fec_stop(ndev);
+	unregister_netdev(ndev);
 	fec_enet_mii_remove(fep);
+	for (i =3D 0; i < FEC_IRQ_NUM; i++) {
+		int irq =3D platform_get_irq(pdev, i);
+		if (irq > 0)
+			free_irq(irq, ndev);
+	}
 	clk_disable(fep->clk);
 	clk_put(fep->clk);
 	iounmap(fep->hwp);
-	unregister_netdev(ndev);
 	free_netdev(ndev);
=20
 	r =3D platform_get_resource(pdev, IORESOURCE_MEM, 0);
--=20
1.5.6.5

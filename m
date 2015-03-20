From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH 1/2] bgmac: register fixed PHY for ARM BCM470X / BCM5301X chipsets
Date: Fri, 20 Mar 2015 23:14:31 +0100
Message-ID: <1426889672-4969-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hauke Mehrtens <hauke@hauke-m.de>,
	=?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f171.google.com ([74.125.82.171]:33708 "EHLO
	mail-we0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751321AbbCTWOp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 18:14:45 -0400
Received: by weop45 with SMTP id p45so92226898weo.0
        for <netdev@vger.kernel.org>; Fri, 20 Mar 2015 15:14:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On ARM SoCs with bgmac Ethernet hardware we don't have any normal PHY.
There is always a switch attached but it's not even controlled over MDI=
O
like in case of MIPS devices.
We need a fixed PHY to be able to send/receive packets from the switch.

Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
---
 drivers/net/ethernet/broadcom/bgmac.c | 34 +++++++++++++++++++++++++++=
+++++++
 1 file changed, 34 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethern=
et/broadcom/bgmac.c
index 0469f72..efda7cf 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -14,6 +14,7 @@
 #include <linux/etherdevice.h>
 #include <linux/mii.h>
 #include <linux/phy.h>
+#include <linux/phy_fixed.h>
 #include <linux/interrupt.h>
 #include <linux/dma-mapping.h>
 #include <bcm47xx_nvram.h>
@@ -1330,13 +1331,46 @@ static void bgmac_adjust_link(struct net_device=
 *net_dev)
 	}
 }
=20
+static int bgmac_fixed_phy_register(struct bgmac *bgmac)
+{
+	struct fixed_phy_status fphy_status =3D {
+		.link =3D 1,
+		.speed =3D SPEED_1000,
+		.duplex =3D DUPLEX_FULL,
+	};
+	struct phy_device *phy_dev;
+	int err;
+
+	phy_dev =3D fixed_phy_register(PHY_POLL, &fphy_status, NULL);
+	if (!phy_dev || IS_ERR(phy_dev)) {
+		bgmac_err(bgmac, "Failed to register fixed PHY device\n");
+		return -ENODEV;
+	}
+
+	err =3D phy_connect_direct(bgmac->net_dev, phy_dev, bgmac_adjust_link=
,
+				 PHY_INTERFACE_MODE_MII);
+	if (err) {
+		bgmac_err(bgmac, "Connecting PHY failed\n");
+		return err;
+	}
+
+	bgmac->phy_dev =3D phy_dev;
+
+	return err;
+}
+
 static int bgmac_mii_register(struct bgmac *bgmac)
 {
+	struct bcma_chipinfo *ci =3D &bgmac->core->bus->chipinfo;
 	struct mii_bus *mii_bus;
 	struct phy_device *phy_dev;
 	char bus_id[MII_BUS_ID_SIZE + 3];
 	int i, err =3D 0;
=20
+	if (ci->id =3D=3D BCMA_CHIP_ID_BCM4707 ||
+	    ci->id =3D=3D BCMA_CHIP_ID_BCM53018)
+		return bgmac_fixed_phy_register(bgmac);
+
 	mii_bus =3D mdiobus_alloc();
 	if (!mii_bus)
 		return -ENOMEM;
--=20
1.8.4.5

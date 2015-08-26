From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH] bgmac: support up to 3 cores (devices) on a bus
Date: Wed, 26 Aug 2015 17:53:45 +0200
Message-ID: <1440604425-11094-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hauke Mehrtens <hauke@hauke-m.de>,
	=?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:33717 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751571AbbHZPx4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 11:53:56 -0400
Received: by labns7 with SMTP id ns7so4797467lab.0
        for <netdev@vger.kernel.org>; Wed, 26 Aug 2015 08:53:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Broadcom buses may have more than 1 Ethernet device. This is used e.g.
to have few interfaces connected to different switch ports. So far we
saw chipsets with only 2 devices (e.g. BCM4706) but recent ones have
up to 3 (e.g. Netgear R8000 uses 3rd interface for most of switch
traffic, lower interfaces are for some kind of offloading).

Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
---
 drivers/net/ethernet/broadcom/bgmac.c | 28 +++++++++++++++++++++++----=
-
 1 file changed, 23 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethern=
et/broadcom/bgmac.c
index 21e3c38..d043746 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -1549,11 +1549,20 @@ static int bgmac_probe(struct bcma_device *core=
)
 	struct net_device *net_dev;
 	struct bgmac *bgmac;
 	struct ssb_sprom *sprom =3D &core->bus->sprom;
-	u8 *mac =3D core->core_unit ? sprom->et1mac : sprom->et0mac;
+	u8 *mac;
 	int err;
=20
-	/* We don't support 2nd, 3rd, ... units, SPROM has to be adjusted */
-	if (core->core_unit > 1) {
+	switch (core->core_unit) {
+	case 0:
+		mac =3D sprom->et0mac;
+		break;
+	case 1:
+		mac =3D sprom->et1mac;
+		break;
+	case 2:
+		mac =3D sprom->et2mac;
+		break;
+	default:
 		pr_err("Unsupported core_unit %d\n", core->core_unit);
 		return -ENOTSUPP;
 	}
@@ -1588,8 +1597,17 @@ static int bgmac_probe(struct bcma_device *core)
 	}
 	bgmac->cmn =3D core->bus->drv_gmac_cmn.core;
=20
-	bgmac->phyaddr =3D core->core_unit ? sprom->et1phyaddr :
-			 sprom->et0phyaddr;
+	switch (core->core_unit) {
+	case 0:
+		bgmac->phyaddr =3D sprom->et0phyaddr;
+		break;
+	case 1:
+		bgmac->phyaddr =3D sprom->et1phyaddr;
+		break;
+	case 2:
+		bgmac->phyaddr =3D sprom->et2phyaddr;
+		break;
+	}
 	bgmac->phyaddr &=3D BGMAC_PHY_MASK;
 	if (bgmac->phyaddr =3D=3D BGMAC_PHY_MASK) {
 		bgmac_err(bgmac, "No PHY found\n");
--=20
1.8.4.5

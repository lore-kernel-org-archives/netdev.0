From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH] bgmac: add helper checking for BCM4707 / BCM53018 chip id
Date: Tue,  2 Feb 2016 07:47:14 +0100
Message-ID: <1454395634-11317-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hauke Mehrtens <hauke@hauke-m.de>, Felix Fietkau <nbd@openwrt.org>,
	=?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f44.google.com ([209.85.215.44]:36542 "EHLO
	mail-lf0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752513AbcBBGr3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 01:47:29 -0500
Received: by mail-lf0-f44.google.com with SMTP id 78so63187195lfy.3
        for <netdev@vger.kernel.org>; Mon, 01 Feb 2016 22:47:28 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chipsets with BCM4707 / BCM53018 ID require special handling at a few
places in the code. It's likely there will be more IDs to check in the
future. To simplify it add this trivial helper.

Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
---
It's the same change as sent few days ago, just resending it in a prope=
r time
(with net-next being open).
---
 drivers/net/ethernet/broadcom/bgmac.c | 30 ++++++++++++++++-----------=
---
 1 file changed, 16 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethern=
et/broadcom/bgmac.c
index 06f6cff..230f8e6 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -26,6 +26,17 @@ static const struct bcma_device_id bgmac_bcma_tbl[] =
=3D {
 };
 MODULE_DEVICE_TABLE(bcma, bgmac_bcma_tbl);
=20
+static inline bool bgmac_is_bcm4707_family(struct bgmac *bgmac)
+{
+	switch (bgmac->core->bus->chipinfo.id) {
+	case BCMA_CHIP_ID_BCM4707:
+	case BCMA_CHIP_ID_BCM53018:
+		return true;
+	default:
+		return false;
+	}
+}
+
 static bool bgmac_wait_value(struct bcma_device *core, u16 reg, u32 ma=
sk,
 			     u32 value, int timeout)
 {
@@ -987,11 +998,9 @@ static void bgmac_mac_speed(struct bgmac *bgmac)
 static void bgmac_miiconfig(struct bgmac *bgmac)
 {
 	struct bcma_device *core =3D bgmac->core;
-	struct bcma_chipinfo *ci =3D &core->bus->chipinfo;
 	u8 imode;
=20
-	if (ci->id =3D=3D BCMA_CHIP_ID_BCM4707 ||
-	    ci->id =3D=3D BCMA_CHIP_ID_BCM53018) {
+	if (bgmac_is_bcm4707_family(bgmac)) {
 		bcma_awrite32(core, BCMA_IOCTL,
 			      bcma_aread32(core, BCMA_IOCTL) | 0x40 |
 			      BGMAC_BCMA_IOCTL_SW_CLKEN);
@@ -1055,9 +1064,7 @@ static void bgmac_chip_reset(struct bgmac *bgmac)
 	}
=20
 	/* Request Misc PLL for corerev > 2 */
-	if (core->id.rev > 2 &&
-	    ci->id !=3D BCMA_CHIP_ID_BCM4707 &&
-	    ci->id !=3D BCMA_CHIP_ID_BCM53018) {
+	if (core->id.rev > 2 && !bgmac_is_bcm4707_family(bgmac)) {
 		bgmac_set(bgmac, BCMA_CLKCTLST,
 			  BGMAC_BCMA_CLKCTLST_MISC_PLL_REQ);
 		bgmac_wait_value(bgmac->core, BCMA_CLKCTLST,
@@ -1193,8 +1200,7 @@ static void bgmac_enable(struct bgmac *bgmac)
 		break;
 	}
=20
-	if (ci->id !=3D BCMA_CHIP_ID_BCM4707 &&
-	    ci->id !=3D BCMA_CHIP_ID_BCM53018) {
+	if (!bgmac_is_bcm4707_family(bgmac)) {
 		rxq_ctl =3D bgmac_read(bgmac, BGMAC_RXQ_CTL);
 		rxq_ctl &=3D ~BGMAC_RXQ_CTL_MDP_MASK;
 		bp_clk =3D bcma_pmu_get_bus_clock(&bgmac->core->bus->drv_cc) /
@@ -1472,14 +1478,12 @@ static int bgmac_fixed_phy_register(struct bgma=
c *bgmac)
=20
 static int bgmac_mii_register(struct bgmac *bgmac)
 {
-	struct bcma_chipinfo *ci =3D &bgmac->core->bus->chipinfo;
 	struct mii_bus *mii_bus;
 	struct phy_device *phy_dev;
 	char bus_id[MII_BUS_ID_SIZE + 3];
 	int err =3D 0;
=20
-	if (ci->id =3D=3D BCMA_CHIP_ID_BCM4707 ||
-	    ci->id =3D=3D BCMA_CHIP_ID_BCM53018)
+	if (bgmac_is_bcm4707_family(bgmac))
 		return bgmac_fixed_phy_register(bgmac);
=20
 	mii_bus =3D mdiobus_alloc();
@@ -1539,7 +1543,6 @@ static void bgmac_mii_unregister(struct bgmac *bg=
mac)
 /* http://bcm-v4.sipsolutions.net/mac-gbit/gmac/chipattach */
 static int bgmac_probe(struct bcma_device *core)
 {
-	struct bcma_chipinfo *ci =3D &core->bus->chipinfo;
 	struct net_device *net_dev;
 	struct bgmac *bgmac;
 	struct ssb_sprom *sprom =3D &core->bus->sprom;
@@ -1620,8 +1623,7 @@ static int bgmac_probe(struct bcma_device *core)
 	bgmac_chip_reset(bgmac);
=20
 	/* For Northstar, we have to take all GMAC core out of reset */
-	if (ci->id =3D=3D BCMA_CHIP_ID_BCM4707 ||
-	    ci->id =3D=3D BCMA_CHIP_ID_BCM53018) {
+	if (bgmac_is_bcm4707_family(bgmac)) {
 		struct bcma_device *ns_core;
 		int ns_gmac;
=20
--=20
1.8.4.5

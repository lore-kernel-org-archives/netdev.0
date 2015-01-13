From: Stefan Agner <stefan-XLVq0VzYD2Y@public.gmane.org>
Subject: [PATCH RESEND v2] net: fec: fix MDIO bus assignement for dual fec SoC's
Date: Wed, 14 Jan 2015 00:20:21 +0100
Message-ID: <1421191221-23095-1-git-send-email-stefan@agner.ch>
Cc: shawn.guo-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, u.kleine-koenig-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org,
	fugang.duan-KZfg59tc24xl57MIdRCFDg@public.gmane.org, fabio.estevam-KZfg59tc24xl57MIdRCFDg@public.gmane.org,
	mark.rutland-5wv7dgnIgG8@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, pawel.moll-5wv7dgnIgG8@public.gmane.org,
	ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org, galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	B38611-KZfg59tc24xl57MIdRCFDg@public.gmane.org, LW-bxm8fMRDkQLDiMYJYoSAnRvVK+yQ3ZXh@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, stefan-XLVq0VzYD2Y@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On i.MX28, the MDIO bus is shared between the two FEC instances.
The driver makes sure that the second FEC uses the MDIO bus of the
first FEC. This is done conditionally if FEC_QUIRK_ENET_MAC is set.
However, in newer designs, such as Vybrid or i.MX6SX, each FEC MAC
has its own MDIO bus. Simply removing the quirk FEC_QUIRK_ENET_MAC
is not an option since other logic, triggered by this quirk, is
still needed.

Furthermore, there are board designs which use the same MDIO bus
for both PHY's even though the second bus would be available on the
SoC side. Such layout are popular since it saves pins on SoC side.
Due to the above quirk, those boards currently do work fine. The
boards in the mainline tree with such a layout are:
- Freescale Vybrid Tower with TWR-SER2 (vf610-twr.dts)
- Freescale i.MX6 SoloX SDB Board (imx6sx-sdb.dts)

This patch adds a new quirk FEC_QUIRK_SINGLE_MDIO for i.MX28, which
makes sure that the MDIO bus of the first FEC is used in any case.

However, the boards above do have a SoC with a MDIO bus for each FEC
instance. But the PHY's are not connected in a 1:1 configuration. A
proper device tree description is needed to allow the driver to
figure out where to find its PHY. This patch fixes that shortcoming
by adding a MDIO bus child node to the first FEC instance, along
with the two PHY's on that bus, and making use of the phy-handle
property to add a reference to the PHY's.

Acked-by: Sascha Hauer <s.hauer-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Signed-off-by: Stefan Agner <stefan-XLVq0VzYD2Y@public.gmane.org>
---
Sorry for this resend, I forgot the netdev mailing list...

There are some discussion around this, see:
https://lkml.org/lkml/2015/1/9/338

I prefer to have the changes in one patch since they are inherently
connected to each other. Shawn seems to be ok with that...

 arch/arm/boot/dts/imx6sx-sdb.dts          | 15 +++++++++++++++
 arch/arm/boot/dts/vf610-twr.dts           | 15 +++++++++++++++
 drivers/net/ethernet/freescale/fec.h      |  2 ++
 drivers/net/ethernet/freescale/fec_main.c |  9 +++++----
 4 files changed, 37 insertions(+), 4 deletions(-)

diff --git a/arch/arm/boot/dts/imx6sx-sdb.dts b/arch/arm/boot/dts/imx6sx-sdb.dts
index 1e6e5cc..8c1febd 100644
--- a/arch/arm/boot/dts/imx6sx-sdb.dts
+++ b/arch/arm/boot/dts/imx6sx-sdb.dts
@@ -159,13 +159,28 @@
 	pinctrl-0 = <&pinctrl_enet1>;
 	phy-supply = <&reg_enet_3v3>;
 	phy-mode = "rgmii";
+	phy-handle = <&ethphy1>;
 	status = "okay";
+
+	mdio {
+		#address-cells = <1>;
+		#size-cells = <0>;
+
+		ethphy1: ethernet-phy@0 {
+			reg = <0>;
+		};
+
+		ethphy2: ethernet-phy@1 {
+			reg = <1>;
+		};
+	};
 };
 
 &fec2 {
 	pinctrl-names = "default";
 	pinctrl-0 = <&pinctrl_enet2>;
 	phy-mode = "rgmii";
+	phy-handle = <&ethphy2>;
 	status = "okay";
 };
 
diff --git a/arch/arm/boot/dts/vf610-twr.dts b/arch/arm/boot/dts/vf610-twr.dts
index a0f7621..f2b64b1 100644
--- a/arch/arm/boot/dts/vf610-twr.dts
+++ b/arch/arm/boot/dts/vf610-twr.dts
@@ -129,13 +129,28 @@
 
 &fec0 {
 	phy-mode = "rmii";
+	phy-handle = <&ethphy0>;
 	pinctrl-names = "default";
 	pinctrl-0 = <&pinctrl_fec0>;
 	status = "okay";
+
+	mdio {
+		#address-cells = <1>;
+		#size-cells = <0>;
+
+		ethphy0: ethernet-phy@0 {
+			reg = <0>;
+		};
+
+		ethphy1: ethernet-phy@1 {
+			reg = <1>;
+		};
+	};
 };
 
 &fec1 {
 	phy-mode = "rmii";
+	phy-handle = <&ethphy1>;
 	pinctrl-names = "default";
 	pinctrl-0 = <&pinctrl_fec1>;
 	status = "okay";
diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index 469691a..4013292 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -424,6 +424,8 @@ struct bufdesc_ex {
  * (40ns * 6).
  */
 #define FEC_QUIRK_BUG_CAPTURE		(1 << 10)
+/* Controller has only one MDIO bus */
+#define FEC_QUIRK_SINGLE_MDIO		(1 << 11)
 
 struct fec_enet_priv_tx_q {
 	int index;
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 5ebdf8d..8dc0391 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -91,7 +91,8 @@ static struct platform_device_id fec_devtype[] = {
 		.driver_data = 0,
 	}, {
 		.name = "imx28-fec",
-		.driver_data = FEC_QUIRK_ENET_MAC | FEC_QUIRK_SWAP_FRAME,
+		.driver_data = FEC_QUIRK_ENET_MAC | FEC_QUIRK_SWAP_FRAME |
+				FEC_QUIRK_SINGLE_MDIO,
 	}, {
 		.name = "imx6q-fec",
 		.driver_data = FEC_QUIRK_ENET_MAC | FEC_QUIRK_HAS_GBIT |
@@ -1937,7 +1938,7 @@ static int fec_enet_mii_init(struct platform_device *pdev)
 	int err = -ENXIO, i;
 
 	/*
-	 * The dual fec interfaces are not equivalent with enet-mac.
+	 * The i.MX28 dual fec interfaces are not equal.
 	 * Here are the differences:
 	 *
 	 *  - fec0 supports MII & RMII modes while fec1 only supports RMII
@@ -1952,7 +1953,7 @@ static int fec_enet_mii_init(struct platform_device *pdev)
 	 * mdio interface in board design, and need to be configured by
 	 * fec0 mii_bus.
 	 */
-	if ((fep->quirks & FEC_QUIRK_ENET_MAC) && fep->dev_id > 0) {
+	if ((fep->quirks & FEC_QUIRK_SINGLE_MDIO) && fep->dev_id > 0) {
 		/* fec1 uses fec0 mii_bus */
 		if (mii_cnt && fec0_mii_bus) {
 			fep->mii_bus = fec0_mii_bus;
@@ -2015,7 +2016,7 @@ static int fec_enet_mii_init(struct platform_device *pdev)
 	mii_cnt++;
 
 	/* save fec0 mii_bus */
-	if (fep->quirks & FEC_QUIRK_ENET_MAC)
+	if (fep->quirks & FEC_QUIRK_SINGLE_MDIO)
 		fec0_mii_bus = fep->mii_bus;
 
 	return 0;
-- 
2.2.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

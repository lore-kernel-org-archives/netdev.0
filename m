From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH v2 3/3] net/fec: add device tree probe support
Date: Tue, 5 Jul 2011 11:42:06 -0600
Message-ID: <CACxGe6t3aKD-033Xbr_eWB5z9zSZ0qiuVp5FXXxR1eubBf7LxQ@mail.gmail.com>
References: <1309878839-25743-1-git-send-email-shawn.guo@linaro.org> <1309878839-25743-4-git-send-email-shawn.guo@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	devicetree-discuss@lists.ozlabs.org, patches@linaro.org,
	Jason Liu <jason.hui@linaro.org>,
	"David S. Miller" <davem@davemloft.net>
To: Shawn Guo <shawn.guo@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:47032 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750854Ab1GERm1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 13:42:27 -0400
Received: by gwaa18 with SMTP id a18so2409205gwa.19
        for <netdev@vger.kernel.org>; Tue, 05 Jul 2011 10:42:26 -0700 (PDT)
In-Reply-To: <1309878839-25743-4-git-send-email-shawn.guo@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 5, 2011 at 9:13 AM, Shawn Guo <shawn.guo@linaro.org> wrote:
> It adds device tree probe support for fec driver.
>
> Signed-off-by: Jason Liu <jason.hui@linaro.org>
> Signed-off-by: Shawn Guo <shawn.guo@linaro.org>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Grant Likely <grant.likely@secretlab.ca>
> Acked-by: Grant Likely <grant.likely@secretlab.ca>

Minor comments below, but my Acked-by above still stands.

g.

> ---
> =A0Documentation/devicetree/bindings/net/fsl-fec.txt | =A0 24 +++++
> =A0drivers/net/fec.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 | =A0 99 +++++++++++++++++++-
> =A02 files changed, 118 insertions(+), 5 deletions(-)
> =A0create mode 100644 Documentation/devicetree/bindings/net/fsl-fec.t=
xt
>
> diff --git a/Documentation/devicetree/bindings/net/fsl-fec.txt b/Docu=
mentation/devicetree/bindings/net/fsl-fec.txt
> new file mode 100644
> index 0000000..1dad888
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/fsl-fec.txt
> @@ -0,0 +1,24 @@
> +* Freescale Fast Ethernet Controller (FEC)
> +
> +Required properties:
> +- compatible : Should be "fsl,<soc>-fec"
> +- reg : Address and length of the register set for the device
> +- interrupts : Should contain fec interrupt
> +- phy-mode : String, operation mode of the PHY interface.
> + =A0Supported values are: "mii", "gmii", "sgmii", "tbi", "rmii",
> + =A0"rgmii", "rgmii-id", "rgmii-rxid", "rgmii-txid", "rtbi".
> +- gpios : Should specify the gpio for phy reset

Let's be explicit for the gpio property: phy-reset-gpios.

> +
> +Optional properties:
> +- local-mac-address : 6 bytes, mac address
> +
> +Example:
> +
> +fec@83fec000 {
> + =A0 =A0 =A0 compatible =3D "fsl,imx51-fec", "fsl,imx27-fec";
> + =A0 =A0 =A0 reg =3D <0x83fec000 0x4000>;
> + =A0 =A0 =A0 interrupts =3D <87>;
> + =A0 =A0 =A0 phy-mode =3D "mii";
> + =A0 =A0 =A0 gpios =3D <&gpio1 14 0>; /* phy-reset, GPIO2_14 */
> + =A0 =A0 =A0 local-mac-address =3D [00 04 9F 01 1B B9];
> +};
> diff --git a/drivers/net/fec.c b/drivers/net/fec.c
> index 7ae3f28..dec94f4 100644
> --- a/drivers/net/fec.c
> +++ b/drivers/net/fec.c
> @@ -44,6 +44,10 @@
> =A0#include <linux/platform_device.h>
> =A0#include <linux/phy.h>
> =A0#include <linux/fec.h>
> +#include <linux/of.h>
> +#include <linux/of_device.h>
> +#include <linux/of_gpio.h>
> +#include <linux/of_net.h>
>
> =A0#include <asm/cacheflush.h>
>
> @@ -78,6 +82,17 @@ static struct platform_device_id fec_devtype[] =3D=
 {
> =A0 =A0 =A0 =A0{ }
> =A0};
>
> +enum fec_type {
> + =A0 =A0 =A0 IMX27_FEC,
> + =A0 =A0 =A0 IMX28_FEC,
> +};
> +
> +static const struct of_device_id fec_dt_ids[] =3D {
> + =A0 =A0 =A0 { .compatible =3D "fsl,imx27-fec", .data =3D &fec_devty=
pe[IMX27_FEC], },
> + =A0 =A0 =A0 { .compatible =3D "fsl,imx28-fec", .data =3D &fec_devty=
pe[IMX28_FEC], },
> + =A0 =A0 =A0 { /* sentinel */ }
> +};
> +
> =A0static unsigned char macaddr[ETH_ALEN];
> =A0module_param_array(macaddr, byte, NULL, 0);
> =A0MODULE_PARM_DESC(macaddr, "FEC Ethernet MAC address");
> @@ -734,8 +749,22 @@ static void __inline__ fec_get_mac(struct net_de=
vice *ndev)
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0iap =3D macaddr;
>
> +#ifdef CONFIG_OF
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* 2) from device tree data
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 if (!is_valid_ether_addr(iap)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct device_node *np =3D fep->pdev->d=
ev.of_node;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (np) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 const char *mac =3D of_=
get_mac_address(np);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (mac)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 iap =3D=
 (unsigned char *) mac;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> +#endif
> +
> =A0 =A0 =A0 =A0/*
> - =A0 =A0 =A0 =A0* 2) from flash or fuse (via platform data)
> + =A0 =A0 =A0 =A0* 3) from flash or fuse (via platform data)
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0if (!is_valid_ether_addr(iap)) {
> =A0#ifdef CONFIG_M5272
> @@ -748,7 +777,7 @@ static void __inline__ fec_get_mac(struct net_dev=
ice *ndev)
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0/*
> - =A0 =A0 =A0 =A0* 3) FEC mac registers set by bootloader
> + =A0 =A0 =A0 =A0* 4) FEC mac registers set by bootloader
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0if (!is_valid_ether_addr(iap)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*((unsigned long *) &tmpaddr[0]) =3D
> @@ -1358,6 +1387,53 @@ static int fec_enet_init(struct net_device *nd=
ev)
> =A0 =A0 =A0 =A0return 0;
> =A0}
>
> +#ifdef CONFIG_OF
> +static int __devinit fec_get_phy_mode_dt(struct platform_device *pde=
v)
> +{
> + =A0 =A0 =A0 struct device_node *np =3D pdev->dev.of_node;
> +
> + =A0 =A0 =A0 if (np)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return of_get_phy_mode(np);
> +
> + =A0 =A0 =A0 return -ENODEV;
> +}
> +
> +static int __devinit fec_reset_phy(struct platform_device *pdev)
> +{
> + =A0 =A0 =A0 int err, phy_reset;
> + =A0 =A0 =A0 struct device_node *np =3D pdev->dev.of_node;
> +
> + =A0 =A0 =A0 if (!np)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENODEV;
> +
> + =A0 =A0 =A0 phy_reset =3D of_get_gpio(np, 0);
> + =A0 =A0 =A0 err =3D gpio_request_one(phy_reset, GPIOF_OUT_INIT_LOW,=
 "phy-reset");
> + =A0 =A0 =A0 if (err) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_warn("FEC: failed to get gpio phy-re=
set: %d\n", err);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return err;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 msleep(1);
> + =A0 =A0 =A0 gpio_set_value(phy_reset, 1);
> +
> + =A0 =A0 =A0 return 0;
> +}
> +#else /* CONFIG_OF */
> +static inline int fec_get_phy_mode_dt(struct platform_device *pdev)
> +{
> + =A0 =A0 =A0 return -ENODEV;
> +}
> +
> +static inline int fec_reset_phy(struct platform_device *pdev)
> +{
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* In case of platform probe, the reset has been done
> + =A0 =A0 =A0 =A0* by machine code.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 return 0;

Perhaps platform code should be reworked to use GPIO also.

> +}
> +#endif /* CONFIG_OF */
> +
> =A0static int __devinit
> =A0fec_probe(struct platform_device *pdev)
> =A0{
> @@ -1366,6 +1442,11 @@ fec_probe(struct platform_device *pdev)
> =A0 =A0 =A0 =A0struct net_device *ndev;
> =A0 =A0 =A0 =A0int i, irq, ret =3D 0;
> =A0 =A0 =A0 =A0struct resource *r;
> + =A0 =A0 =A0 const struct of_device_id *of_id;
> +
> + =A0 =A0 =A0 of_id =3D of_match_device(fec_dt_ids, &pdev->dev);
> + =A0 =A0 =A0 if (of_id)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pdev->id_entry =3D of_id->data;
>
> =A0 =A0 =A0 =A0r =3D platform_get_resource(pdev, IORESOURCE_MEM, 0);
> =A0 =A0 =A0 =A0if (!r)
> @@ -1397,9 +1478,16 @@ fec_probe(struct platform_device *pdev)
>
> =A0 =A0 =A0 =A0platform_set_drvdata(pdev, ndev);
>
> - =A0 =A0 =A0 pdata =3D pdev->dev.platform_data;
> - =A0 =A0 =A0 if (pdata)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 fep->phy_interface =3D pdata->phy;
> + =A0 =A0 =A0 fep->phy_interface =3D fec_get_phy_mode_dt(pdev);
> + =A0 =A0 =A0 if (fep->phy_interface < 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pdata =3D pdev->dev.platform_data;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (pdata)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 fep->phy_interface =3D =
pdata->phy;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 fep->phy_interface =3D =
PHY_INTERFACE_MODE_MII;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 fec_reset_phy(pdev);
>
> =A0 =A0 =A0 =A0/* This device has up to three irqs on some platforms =
*/
> =A0 =A0 =A0 =A0for (i =3D 0; i < 3; i++) {
> @@ -1534,6 +1622,7 @@ static struct platform_driver fec_driver =3D {
> =A0#ifdef CONFIG_PM
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.pm =A0 =A0 =3D &fec_pm_ops,
> =A0#endif
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .of_match_table =3D fec_dt_ids,
> =A0 =A0 =A0 =A0},
> =A0 =A0 =A0 =A0.id_table =3D fec_devtype,
> =A0 =A0 =A0 =A0.probe =A0=3D fec_probe,
> --
> 1.7.4.1
>
>
>



--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.

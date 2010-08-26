From: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
Subject: Re: [PATCH] drivers/net/: ll_temac_main.c & ll_temac.h: Adding
	ethtool interface
Date: Thu, 26 Aug 2010 13:26:22 -0600
Message-ID: <AANLkTimrAq_eBjt7h+PQbMuiDYypt7Pd618Xbq0R70HA@mail.gmail.com>
References: <1282846407.2081.79.camel@ville-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: jpirko-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	Joshua Pederson <josh-PRfGYHLb4FmqndwCJWfcng@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dkirjanov-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Ville Sundell <ville.sundell-PRfGYHLb4FmhKNWrAYCRhA@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <1282846407.2081.79.camel@ville-desktop>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 26, 2010 at 12:13 PM, Ville Sundell
<ville.sundell-PRfGYHLb4FmhKNWrAYCRhA@public.gmane.org> wrote:
> This patch adds an interface to the ethtool subsystem and
> implements read/write functionality for handling settings with the
> ethtool_cmd structure. "Speed" is the only setting implemented so far.
> Other settings (like reading the duplex value) can be easily implemented
> later on.
>
> One can read the speed of the link by reading /sys/class/net/eth0/speed.
> It seems that you can't write to /sys/class/net/eth0/speed, so the
> "ethtool" command line utility must be used to set the speed.
>
> So far, it is tested only in the DMA mode, since I don't have hardware
> with DCR available.
>
> Signed-off-by: Ville Sundell <ville.sundell-PRfGYHLb4FmhKNWrAYCRhA@public.gmane.org>

The ll_temac driver uses phylib.  The Ethtool ops should then also be
implemented using phylib and not by writing to the ll_temac registers
directly.  Otherwise changes to the ll_temac speed will not be
reflected in the PHY.

g.


> ---
>
> When using a non-static PHY and 100Mbit connection in Temac, the speed
> is not changed and stays at the reset value (1000Mbit). This leads to a
> situation where data is not sent or received correctly since
> temac_adjust_link() is not called due to lack of static PHY. =A0Therefore
> the link speed retains the reset value.
>
> There is also no possibility to read or set the link speed from the user
> space.
>
> The patch is done against the newest version of ll_temac_main.cc and
> ll_temac.h of the linux-next tree.
>
> Thanks to Michal Simek for his feedback on this patch!
>
> Regards,
> Ville Sundell
> Digilent Inc.
>
> =A0drivers/net/ll_temac.h =A0 =A0 =A0| =A0 =A03 ++
> =A0drivers/net/ll_temac_main.c | =A0 76 +++++++++++++++++++++++++++++++++=
++++++++++
> =A02 files changed, 79 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/ll_temac.h b/drivers/net/ll_temac.h
> index 522abe2..ddd00cc 100644
> --- a/drivers/net/ll_temac.h
> +++ b/drivers/net/ll_temac.h
> @@ -247,6 +247,9 @@ This option defaults to enabled (set) */
> =A0#define XTE_EMCFG_LINKSPD_10 =A0 =A0 =A0 =A0 =A0 0x00000000 /* 10 Mbit=
 LINKSPD_MASK */
> =A0#define XTE_EMCFG_LINKSPD_100 =A0 =A0 =A0 =A0 =A0(1 << 30) =A0/* 100 M=
bit LINKSPD_MASK */
> =A0#define XTE_EMCFG_LINKSPD_1000 =A0 =A0 =A0 =A0 (1 << 31) =A0/* 1000 Mb=
it LINKSPD_MASK */
> +#define XTE_EMCFG_LINKSPD_NA =A0 =A0 =A0 =A0 =A0 0xC0000000 /* For undef=
ined speed */
> +
> +#define TEMAC_SPEED_NA =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 0 /* To indicate =
XTE_EMCFG_LINKSPD_NA */
>
> =A0#define XTE_GMIC_OFFSET =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A00x00000320 /* RGMII/SGMII config */
> =A0#define XTE_MC_OFFSET =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00x00000340 /*=
 MDIO configuration */
> diff --git a/drivers/net/ll_temac_main.c b/drivers/net/ll_temac_main.c
> index bdf2149..ae08fd4 100644
> --- a/drivers/net/ll_temac_main.c
> +++ b/drivers/net/ll_temac_main.c
> @@ -951,6 +951,81 @@ static const struct attribute_group temac_attr_group=
 =3D {
> =A0 =A0 =A0 =A0.attrs =3D temac_device_attrs,
> =A0};
>
> +/* Ethtool interface implementation
> + * SETTINGS
> + * With the following functions below, you can
> + * read and set following settings:
> + * Speed:
> + * =A0 =A0 Speed of the TEMAC controller is indicated by two most signif=
icant bits
> + * =A0 =A0 in the XTE_EMCFG_OFFSET register in the follwoing way:
> + * =A0 =A0 00 =3D 10 Mbit connection
> + * =A0 =A0 01 =3D 100 Mbit connection
> + * =A0 =A0 10 =3D 1000 Mbit connection
> + * =A0 =A0 11 =3D Undefined connection speed
> +*/
> +
> +static int temac_get_settings(struct net_device *ndev, struct ethtool_cm=
d *cmd)
> +{
> + =A0 =A0 =A0 struct temac_local *lp =3D netdev_priv(ndev);
> + =A0 =A0 =A0 u32 reg =3D temac_indirect_in32(lp, XTE_EMCFG_OFFSET);
> +
> + =A0 =A0 =A0 switch (reg & XTE_EMCFG_LINKSPD_MASK) {
> + =A0 =A0 =A0 case XTE_EMCFG_LINKSPD_10:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cmd->speed =3D SPEED_10;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 case XTE_EMCFG_LINKSPD_100:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cmd->speed =3D SPEED_100;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 case XTE_EMCFG_LINKSPD_1000:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cmd->speed =3D SPEED_1000;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 default:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cmd->speed =3D TEMAC_SPEED_NA; /* Undefined=
 speed */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /* TODO: Insert more setting reading code here */
> +
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static int temac_set_settings(struct net_device *ndev, struct ethtool_cm=
d *cmd)
> +{
> + =A0 =A0 =A0 struct temac_local *lp =3D netdev_priv(ndev);
> + =A0 =A0 =A0 u32 reg =3D temac_indirect_in32(lp, XTE_EMCFG_OFFSET);
> +
> + =A0 =A0 =A0 reg &=3D ~XTE_EMCFG_LINKSPD_MASK;
> + =A0 =A0 =A0 switch (cmd->speed) {
> + =A0 =A0 =A0 case SPEED_10:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 reg |=3D XTE_EMCFG_LINKSPD_10;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 case SPEED_100:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 reg |=3D XTE_EMCFG_LINKSPD_100;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 case SPEED_1000:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 reg |=3D XTE_EMCFG_LINKSPD_1000;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 default:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 reg |=3D XTE_EMCFG_LINKSPD_NA; /* Undefined=
 speed */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /* TODO: Insert more setting writing code here */
> +
> + =A0 =A0 =A0 temac_indirect_out32(lp, XTE_EMCFG_OFFSET, reg);
> +
> + =A0 =A0 =A0 return 0;
> +}
> +
> +/*
> + * Defining the ethtool operations.
> + * This will be passed to the ethtool subsystem in the probe function
> + */
> +static const struct ethtool_ops temac_ethtool_ops =3D {
> + =A0 =A0 =A0 .get_settings =3D temac_get_settings,
> + =A0 =A0 =A0 .set_settings =3D temac_set_settings,
> +};
> +
> =A0static int __init
> =A0temac_of_probe(struct platform_device *op, const struct of_device_id *=
match)
> =A0{
> @@ -970,6 +1045,7 @@ temac_of_probe(struct platform_device *op, const str=
uct of_device_id *match)
> =A0 =A0 =A0 =A0ether_setup(ndev);
> =A0 =A0 =A0 =A0dev_set_drvdata(&op->dev, ndev);
> =A0 =A0 =A0 =A0SET_NETDEV_DEV(ndev, &op->dev);
> + =A0 =A0 =A0 SET_ETHTOOL_OPS(ndev, &temac_ethtool_ops);
> =A0 =A0 =A0 =A0ndev->flags &=3D ~IFF_MULTICAST; =A0/* clear multicast */
> =A0 =A0 =A0 =A0ndev->features =3D NETIF_F_SG | NETIF_F_FRAGLIST;
> =A0 =A0 =A0 =A0ndev->netdev_ops =3D &temac_netdev_ops;
>
>
>



-- =

Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.

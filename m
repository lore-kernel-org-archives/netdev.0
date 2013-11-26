From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2 2/6] net: MOXA ART: connect to PHY
Date: Tue, 26 Nov 2013 07:49:17 +0000
Message-ID: <2882257.eZXPo1Jdx9@lenovo>
References: <1385393228-22416-1-git-send-email-jonas.jensen@gmail.com> <1385393228-22416-2-git-send-email-jonas.jensen@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	bhutchings@solarflare.com
To: Jonas Jensen <jonas.jensen@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1385393228-22416-2-git-send-email-jonas.jensen@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 25 novembre 2013, 16:27:04 Jonas Jensen a =E9crit :
> The kernel now has a MDIO bus driver and a phy_driver (RTL8201CP),
> connect to this PHY using OF.
>=20
> Signed-off-by: Jonas Jensen <jonas.jensen@gmail.com>

Looks good:

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

> ---
>=20
> Notes:
>     Thanks for reviewing!
>=20
>     Changes since v1:
>=20
>     1. split ethtool support to separate patch
>     2. changes to devicetree binding document
>     3. add moxart_mac_update_duplex()
>     4. compare previous link state/speed/duplex on link adjust
>     5. use of_get_phy_mode() not PHY_INTERFACE_MODE_MII
>     6. bail on of_parse_phandle() failure
>     7. remove "if (!priv->phy_dev) return -ENODEV;"
>        moxart_do_ioctl()
>     8. remove "if (priv->phy_dev)"
>        moxart_mac_open(), moxart_mac_stop()
>=20
>     Applies to next-20131125
>=20
>  .../devicetree/bindings/net/moxa,moxart-mac.txt    | 47 ++++++++++-
>  drivers/net/ethernet/moxa/moxart_ether.c           | 92
> +++++++++++++++++++++- drivers/net/ethernet/moxa/moxart_ether.h      =
     |
>  2 +
>  3 files changed, 138 insertions(+), 3 deletions(-)
>=20
> diff --git a/Documentation/devicetree/bindings/net/moxa,moxart-mac.tx=
t
> b/Documentation/devicetree/bindings/net/moxa,moxart-mac.txt index
> 583418b..56f0374 100644
> --- a/Documentation/devicetree/bindings/net/moxa,moxart-mac.txt
> +++ b/Documentation/devicetree/bindings/net/moxa,moxart-mac.txt
> @@ -1,21 +1,64 @@
>  MOXA ART Ethernet Controller
>=20
> +Integrated MDIO bus node:
> +
> +- compatible: "moxa,moxart-mdio"
> +- Inherets from MDIO bus node binding[1]
> +
> +[1] Documentation/devicetree/bindings/net/phy.txt
> +
> +
> +Ethernet node:
> +
>  Required properties:
>=20
>  - compatible : Must be "moxa,moxart-mac"
>  - reg : Should contain register location and length
>  - interrupts : Should contain the mac interrupt number
>=20
> +Optional Properties:
> +
> +- phy-handle : the phandle to a PHY node
> +
> +
>  Example:
>=20
> +	mdio0: mdio@90900090 {
> +		compatible =3D "moxa,moxart-mdio";
> +		reg =3D <0x90900090 0x8>;
> +		#address-cells =3D <1>;
> +		#size-cells =3D <0>;
> +
> +		ethphy0: ethernet-phy@1 {
> +			device_type =3D "ethernet-phy";
> +			compatible =3D "moxa,moxart-rtl8201cp", "ethernet-phy-ieee802.3-c=
22";
> +			reg =3D <1>;
> +		};
> +	};
> +
> +	mdio1: mdio@92000090 {
> +		compatible =3D "moxa,moxart-mdio";
> +		reg =3D <0x92000090 0x8>;
> +		#address-cells =3D <1>;
> +		#size-cells =3D <0>;
> +
> +		ethphy1: ethernet-phy@1 {
> +			device_type =3D "ethernet-phy";
> +			compatible =3D "moxa,moxart-rtl8201cp", "ethernet-phy-ieee802.3-c=
22";
> +			reg =3D <1>;
> +		};
> +	};
> +
>  	mac0: mac@90900000 {
>  		compatible =3D "moxa,moxart-mac";
> -		reg =3D	<0x90900000 0x100>;
> +		reg =3D <0x90900000 0x90>;
>  		interrupts =3D <25 0>;
> +		phy-handle =3D <&ethphy0>;
>  	};
>=20
>  	mac1: mac@92000000 {
>  		compatible =3D "moxa,moxart-mac";
> -		reg =3D	<0x92000000 0x100>;
> +		reg =3D <0x92000000 0x90>;
>  		interrupts =3D <27 0>;
> +		phy-handle =3D <&ethphy1>;
>  	};
> diff --git a/drivers/net/ethernet/moxa/moxart_ether.c
> b/drivers/net/ethernet/moxa/moxart_ether.c index 3c14afd..1b87034 100=
644
> --- a/drivers/net/ethernet/moxa/moxart_ether.c
> +++ b/drivers/net/ethernet/moxa/moxart_ether.c
> @@ -26,6 +26,9 @@
>  #include <linux/of_irq.h>
>  #include <linux/crc32.h>
>  #include <linux/crc32c.h>
> +#include <linux/phy.h>
> +#include <linux/of_mdio.h>
> +#include <linux/of_net.h>
>=20
>  #include "moxart_ether.h"
>=20
> @@ -61,6 +64,16 @@ static int moxart_set_mac_address(struct net_devic=
e
> *ndev, void *addr) return 0;
>  }
>=20
> +static int moxart_do_ioctl(struct net_device *ndev, struct ifreq *ir=
, int
> cmd) +{
> +	struct moxart_mac_priv_t *priv =3D netdev_priv(ndev);
> +
> +	if (!netif_running(ndev))
> +		return -EINVAL;
> +
> +	return phy_mii_ioctl(priv->phy_dev, ir, cmd);
> +}
> +
>  static void moxart_mac_free_memory(struct net_device *ndev)
>  {
>  	struct moxart_mac_priv_t *priv =3D netdev_priv(ndev);
> @@ -110,6 +123,19 @@ static void moxart_mac_enable(struct net_device =
*ndev)
>  	writel(priv->reg_maccr, priv->base + REG_MAC_CTRL);
>  }
>=20
> +static void moxart_mac_update_duplex(struct net_device *ndev)
> +{
> +	struct moxart_mac_priv_t *priv =3D netdev_priv(ndev);
> +
> +	priv->reg_maccr &=3D ~(FULLDUP | ENRX_IN_HALFTX);
> +	if (priv->duplex)
> +		priv->reg_maccr |=3D FULLDUP;
> +	else
> +		priv->reg_maccr |=3D ENRX_IN_HALFTX;
> +
> +	writel(priv->reg_maccr, priv->base + REG_MAC_CTRL);
> +}
> +
>  static void moxart_mac_setup_desc_ring(struct net_device *ndev)
>  {
>  	struct moxart_mac_priv_t *priv =3D netdev_priv(ndev);
> @@ -169,6 +195,9 @@ static int moxart_mac_open(struct net_device *nde=
v)
>  	moxart_update_mac_address(ndev);
>  	moxart_mac_setup_desc_ring(ndev);
>  	moxart_mac_enable(ndev);
> +
> +	phy_start(priv->phy_dev);
> +
>  	netif_start_queue(ndev);
>=20
>  	netdev_dbg(ndev, "%s: IMR=3D0x%x, MACCR=3D0x%x\n",
> @@ -184,6 +213,8 @@ static int moxart_mac_stop(struct net_device *nde=
v)
>=20
>  	napi_disable(&priv->napi);
>=20
> +	phy_stop(priv->phy_dev);
> +
>  	netif_stop_queue(ndev);
>=20
>  	/* disable all interrupts */
> @@ -429,12 +460,49 @@ static struct net_device_ops moxart_netdev_ops =
=3D {
>  	.ndo_set_mac_address	=3D moxart_set_mac_address,
>  	.ndo_validate_addr	=3D eth_validate_addr,
>  	.ndo_change_mtu		=3D eth_change_mtu,
> +	.ndo_do_ioctl		=3D moxart_do_ioctl,
>  };
>=20
> +static void moxart_adjust_link(struct net_device *ndev)
> +{
> +	struct moxart_mac_priv_t *priv =3D netdev_priv(ndev);
> +	unsigned long flags;
> +	int status_change =3D 0;
> +
> +	if (priv->phy_dev->link) {
> +		if (priv->speed !=3D priv->phy_dev->speed) {
> +			priv->speed =3D priv->phy_dev->speed;
> +			status_change =3D 1;
> +		}
> +
> +		if (priv->duplex !=3D priv->phy_dev->duplex) {
> +			spin_lock_irqsave(&priv->txlock, flags);
> +
> +			priv->duplex =3D priv->phy_dev->duplex;
> +			moxart_mac_update_duplex(ndev);
> +
> +			spin_unlock_irqrestore(&priv->txlock, flags);
> +			status_change =3D 1;
> +		}
> +	}
> +
> +	if (priv->link !=3D priv->phy_dev->link) {
> +		if (!priv->phy_dev->link) {
> +			priv->speed =3D 0;
> +			priv->duplex =3D -1;
> +		}
> +		priv->link =3D priv->phy_dev->link;
> +		status_change =3D 1;
> +	}
> +
> +	if (status_change)
> +		phy_print_status(priv->phy_dev);
> +}
> +
>  static int moxart_mac_probe(struct platform_device *pdev)
>  {
>  	struct device *p_dev =3D &pdev->dev;
> -	struct device_node *node =3D p_dev->of_node;
> +	struct device_node *node =3D p_dev->of_node, *phy_node;
>  	struct net_device *ndev;
>  	struct moxart_mac_priv_t *priv;
>  	struct resource *res;
> @@ -455,6 +523,28 @@ static int moxart_mac_probe(struct platform_devi=
ce
> *pdev) priv =3D netdev_priv(ndev);
>  	priv->ndev =3D ndev;
>=20
> +	priv->link =3D 0;
> +	priv->speed =3D 0;
> +	priv->duplex =3D -1;
> +
> +	phy_node =3D of_parse_phandle(node, "phy-handle", 0);
> +	if (!phy_node) {
> +		dev_err(p_dev, "of_parse_phandle failed\n");
> +		ret =3D -ENODEV;
> +		goto init_fail;
> +	}
> +
> +	if (phy_node) {
> +		priv->phy_dev =3D of_phy_connect(priv->ndev, phy_node,
> +					       &moxart_adjust_link,
> +					       0, of_get_phy_mode(node));
> +		if (!priv->phy_dev) {
> +			dev_err(p_dev, "of_phy_connect failed\n");
> +			ret =3D -ENODEV;
> +			goto init_fail;
> +		}
> +	}
> +
>  	res =3D platform_get_resource(pdev, IORESOURCE_MEM, 0);
>  	ndev->base_addr =3D res->start;
>  	priv->base =3D devm_ioremap_resource(p_dev, res);
> diff --git a/drivers/net/ethernet/moxa/moxart_ether.h
> b/drivers/net/ethernet/moxa/moxart_ether.h index 2be9280..b8877bf 100=
644
> --- a/drivers/net/ethernet/moxa/moxart_ether.h
> +++ b/drivers/net/ethernet/moxa/moxart_ether.h
> @@ -297,6 +297,8 @@ struct moxart_mac_priv_t {
>  	unsigned int reg_imr;
>  	struct napi_struct napi;
>  	struct net_device *ndev;
> +	struct phy_device *phy_dev;
> +	int speed, duplex, link;
>=20
>  	dma_addr_t rx_base;
>  	dma_addr_t rx_mapping[RX_DESC_NUM];

--=20
=46lorian

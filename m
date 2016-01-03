From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 05/12] net-next: mediatek: add switch driver for mt7621
Date: Sun, 03 Jan 2016 11:18:47 -0800
Message-ID: <1451848727.4334.55.camel@perches.com>
References: <1451834775-15789-1-git-send-email-blogic@openwrt.org>
         <1451834775-15789-5-git-send-email-blogic@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-mips@linux-mips.org,
        linux-mediatek@lists.infradead.org, Felix Fietkau <nbd@nbd.name>,
        Michael Lee <igvtee@gmail.com>,
        Steven Liu =?UTF-8?Q?=28=E5=8A=89=E4=BA=BA=E8=B1=AA=29?=
        <steven.liu@mediatek.com>,
        Fred Chang =?UTF-8?Q?=28=E5=BC=B5=E5=98=89=E5=AE=8F=29?=
        <Fred.Chang@mediatek.com>
To: John Crispin <blogic@openwrt.org>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <1451834775-15789-5-git-send-email-blogic@openwrt.org>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

On Sun, 2016-01-03 at 16:26 +0100, John Crispin wrote:
> This driver is very basic and only provides basic init and irq suppor=
t.
> The SoC and switch core both have support for a special tag making DS=
A
> support possible.

trivia:

> diff --git a/drivers/net/ethernet/mediatek/gsw_mt7621.c b/drivers/net=
/ethernet/mediatek/gsw_mt7621.c
[]
> +static irqreturn_t gsw_interrupt_mt7621(int irq, void *_priv)
> +{
> +	struct fe_priv *priv =3D (struct fe_priv *)_priv;
> +	struct mt7620_gsw *gsw =3D (struct mt7620_gsw *)priv->soc->swpriv;
> +	u32 reg, i;
> +
> +	reg =3D mt7530_mdio_r32(gsw, 0x700c);
> +
> +	for (i =3D 0; i < 5; i++)
> +		if (reg & BIT(i)) {
> +			unsigned int link;
> +
> +			link =3D mt7530_mdio_r32(gsw,
> +					=A0=A0=A0=A0=A0=A0=A00x3008 + (i * 0x100)) & 0x1;
> +
> +			if (link !=3D priv->link[i]) {
> +				priv->link[i] =3D link;
> +				if (link)
> +					netdev_info(priv->netdev,
> +						=A0=A0=A0=A0"port %d link up\n", i);
> +				else
> +					netdev_info(priv->netdev,
> +						=A0=A0=A0=A0"port %d link down\n", i);
> +			}
> +		}

It's more common to use braces after the for loop.
Perhaps this could be written with a continue; to reduce
indentation and also use a single netdev_info().

	for (i =3D 0; i < 5; i++) {
		unsigned int link;

		if (!(reg & BIT(i)))
			continue;

		link =3D=A0mt7530_mdio_r32(gsw, 0x3008 + (i * 0x100)) & 0x1;

		if (link =3D=3D priv->link[i])
			continue;

		priv->link[i] =3D link;
		netdev_info(priv->netdev, "port %d link %s\n",
			    i, link ? "up" : "down");
	}

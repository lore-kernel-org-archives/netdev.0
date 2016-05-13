From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: Re: [patch net-next 05/11] net: hns: add uniform interface for phy
 connection
Date: Fri, 13 May 2016 16:07:25 +0300
Message-ID: <1463144845.17131.342.camel@linux.intel.com>
References: <1463127557-90824-1-git-send-email-Yisen.Zhuang@huawei.com>
	 <1463127557-90824-6-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: arnd@arndb.de, andrew@lunn.ch, geliangtang@163.com,
	ivecera@redhat.com, fengguang.wu@intel.com,
	charles.chenxin@huawei.com, haifeng.wei@huawei.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linuxarm@huawei.com
To: Yisen Zhuang <Yisen.Zhuang@huawei.com>, davem@davemloft.net,
	rjw@rjwysocki.net, lenb@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463127557-90824-6-git-send-email-Yisen.Zhuang@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2016-05-13 at 16:19 +0800, Yisen Zhuang wrote:
> From: Kejian Yan <yankejian@huawei.com>
>=20
> As device_node is only used by OF case, HNS needs to treat the others
> cases including ACPI. It needs to use uniform ways to handle both of
> OF and ACPI. This patch chooses phy_device, and of_phy_connect and
> of_phy_attach are only used by OF case. It needs to add uniform
> interface
> to handle that sequence by both OF and ACPI.

--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
> +++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
> @@ -987,6 +987,41 @@ static void hns_nic_adjust_link(struct net_devic=
e
> *ndev)
> =C2=A0	h->dev->ops->adjust_link(h, ndev->phydev->speed, ndev-
> >phydev->duplex);
> =C2=A0}
> =C2=A0
> +static
> +struct phy_device *hns_nic_phy_attach(struct net_device *dev,
> +				=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0struct phy_device *phy,
> +				=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0u32 flags,
> +				=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0phy_interface_t iface)
> +{
> +	int ret;
> +
> +	if (!phy)
> +		return NULL;

No need to use defensive programming here.

> +
> +	ret =3D phy_attach_direct(dev, phy, flags, iface);
> +
> +	return ret ? NULL : phy;

Shouldn't it return an error?


> +}
> +
> +static
> +struct phy_device *hns_nic_phy_connect(struct net_device *dev,
> +				=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0struct phy_device *phy=
,
> +				=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0void (*hndlr)(struct
> net_device *),
> +				=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0u32 flags,
> +				=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0phy_interface_t iface)
> +{
> +	int ret;
> +
> +	if (!phy)
> +		return NULL;
> +
> +	phy->dev_flags =3D flags;
> +
> +	ret =3D phy_connect_direct(dev, phy, hndlr, iface);
> +
> +	return ret ? NULL : phy;
> +}
> +

=46or now looks that above functions are redundant and you may call the=
m
directly in below code.

> =C2=A0/**
> =C2=A0 *hns_nic_init_phy - init phy
> =C2=A0 *@ndev: net device
> @@ -996,16 +1031,17 @@ static void hns_nic_adjust_link(struct
> net_device *ndev)
> =C2=A0int hns_nic_init_phy(struct net_device *ndev, struct hnae_handl=
e *h)
> =C2=A0{
> =C2=A0	struct hns_nic_priv *priv =3D netdev_priv(ndev);
> -	struct phy_device *phy_dev =3D NULL;
> +	struct phy_device *phy_dev =3D h->phy_dev;
> =C2=A0
> -	if (!h->phy_node)
> +	if (!h->phy_dev)
> =C2=A0		return 0;
> =C2=A0
> =C2=A0	if (h->phy_if !=3D PHY_INTERFACE_MODE_XGMII)
> -		phy_dev =3D of_phy_connect(ndev, h->phy_node,
> -					=C2=A0hns_nic_adjust_link, 0, h-
> >phy_if);
> +		phy_dev =3D hns_nic_phy_connect(ndev, phy_dev,
> +					=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0hns_nic_adjust_link,
> +					=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00, h->phy_if);
> =C2=A0	else
> -		phy_dev =3D of_phy_attach(ndev, h->phy_node, 0, h-
> >phy_if);
> +		phy_dev =3D hns_nic_phy_attach(ndev, phy_dev, 0, h-
> >phy_if);


--=20
Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Intel Finland Oy

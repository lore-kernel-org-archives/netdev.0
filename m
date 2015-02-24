From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH] net: phy: b53: switchdev driver for Broadcom BCM53xx
 switches
Date: Tue, 24 Feb 2015 17:30:39 -0500
Message-ID: <20150224223039.GC1332@gospo.home.greyhouse.net>
References: <1424799727-30946-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Jonas Gorski <jogo@openwrt.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	Felix Fietkau <nbd@openwrt.org>, Jiri Pirko <jiri@resnulli.us>
To: =?utf-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f175.google.com ([209.85.216.175]:45268 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752545AbbBXWan (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 17:30:43 -0500
Received: by qcvp6 with SMTP id p6so19332094qcv.12
        for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 14:30:42 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1424799727-30946-1-git-send-email-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 24, 2015 at 06:42:07PM +0100, Rafa=C5=82 Mi=C5=82ecki wrote=
:
> BCM53xx is series of Broadcom Ethernet switches that can be found in
> various (mostly home) routers.
> They are quite simple switches with mainly just support for:
> 1) Tagging incoming packets (PVID)
> 2) Untagging outgoing packets
> 3) Forwarding all packets across a single VLAN
>=20
> This driver is split into common code (module) and bus specific code.
> Right now only PHY (MDIO) support is included, other could follow aft=
er
> accepting this driver. It was successfully tested on BCM4706 SoC with
> BCM53125.
>=20
> You could notice it's yet another try of submitting b53 driver. This
> time it was modified to use recently introduced switchdev API which
> hopefully make it possible to accept it mainline.

I must confess I do not know the entire history of this driver, but I
have a few comments....

>=20
> Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
> ---
> Example usage. My BCM4706 router has switch with 6 ports:
> 0: WAN port
> 1-4: LAN ports
> 8: CPU connected port (on-SoC Ethernet device)

[...]
> diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
> index 501ea76..3e8b3b7 100644
> --- a/drivers/net/phy/Makefile
> +++ b/drivers/net/phy/Makefile
> @@ -10,6 +10,7 @@ obj-$(CONFIG_LXT_PHY)		+=3D lxt.o
>  obj-$(CONFIG_QSEMI_PHY)		+=3D qsemi.o
>  obj-$(CONFIG_SMSC_PHY)		+=3D smsc.o
>  obj-$(CONFIG_VITESSE_PHY)	+=3D vitesse.o
> +obj-$(CONFIG_B53)		+=3D b53/
Should this be in a different spot than drivers/net/phy?

(Also pointed out by Andrew Lunn and just answered, so I'll read that
response.)

> diff --git a/drivers/net/phy/b53/b53_common.c b/drivers/net/phy/b53/b=
53_common.c
> new file mode 100644
> index 0000000..fce6b71
> --- /dev/null
> +++ b/drivers/net/phy/b53/b53_common.c
[...]
> +
> +/*****************
> + * Net device ops
> + *****************/
> +
> +static netdev_tx_t b53_port_xmit(struct sk_buff *skb, struct net_dev=
ice *dev)
> +{
> +	dev_kfree_skb(skb);
> +	dev->stats.tx_dropped++;
> +
> +	return NETDEV_TX_OK;
> +}
> +
> +static int b53_port_vlan_rx_add_vid(struct net_device *dev,
> +				    __be16 proto, u16 vid)
> +{
> +	struct b53_port *b53_port =3D netdev_priv(dev);
> +	struct b53_device *b53 =3D b53_port->b53;
> +	struct b53_vlan *vlan;
> +
> +	if (vid >=3D b53->chip->vlans)
> +		return -EINVAL;
> +
> +	/* only BCM5325 and BCM5365 supports VID 0 */
> +	if (vid =3D=3D 0 && !is5325(b53) && !is5365(b53))
> +		return -EINVAL;
> +
> +	/* VLAN 4095 needs special handling */
> +	if (vid =3D=3D 4095)
> +		return -EINVAL;
> +
> +	vlan =3D &b53->vlans[vid];
> +
> +	vlan->members |=3D BIT(b53_port->port_number);
> +
> +	/* ignore disabled ports */
> +	vlan->members &=3D b53->enabled_ports;
> +
> +	b53_apply(b53);
> +
> +	return 0;
> +}
> +
> +static int b53_port_vlan_rx_kill_vid(struct net_device *dev,
> +				     __be16 proto, u16 vid)
> +{
> +	struct b53_port *b53_port =3D netdev_priv(dev);
> +	struct b53_device *b53 =3D b53_port->b53;
> +	struct b53_vlan *vlan;
> +
> +	if (vid >=3D b53->chip->vlans)
> +		return -EINVAL;
> +
> +	vlan =3D &b53->vlans[vid];
> +
> +	vlan->members &=3D ~BIT(b53_port->port_number);
> +
> +	b53_apply(b53);
> +
> +	return 0;
> +}
> +
> +static int b53_port_switch_parent_id_get(struct net_device *dev,
> +					 struct netdev_phys_item_id *psid)
> +{
> +	struct b53_port *b53_port =3D netdev_priv(dev);
> +
> +	memcpy(psid->id, b53_port->b53->dev_addr, ETH_ALEN);
> +	psid->id_len =3D ETH_ALEN;
> +
> +	return 0;
> +}
> +
> +static int b53_port_bridge_setlink(struct net_device *dev,
> +				   struct nlmsghdr *nlh, u16 flags)
> +{
> +	struct b53_port *b53_port =3D netdev_priv(dev);
> +	struct b53_device *b53 =3D b53_port->b53;
> +	struct b53_vlan *vlan;
> +	struct nlattr *afspec;
> +	struct nlattr *attr;
> +	struct bridge_vlan_info *vinfo;
> +	int rem;
> +
> +	afspec =3D nlmsg_find_attr(nlh, sizeof(struct ifinfomsg), IFLA_AF_S=
PEC);
> +	if (!afspec)
> +		return -EINVAL;
> +
> +	nla_for_each_nested(attr, afspec, rem) {
> +		if (nla_type(attr) !=3D IFLA_BRIDGE_VLAN_INFO)
> +			continue;
> +		if (nla_len(attr) !=3D sizeof(struct bridge_vlan_info))
> +			return -EINVAL;
> +		vinfo =3D nla_data(attr);
> +	}
> +	if (!vinfo)
> +		return -EINVAL;
> +
> +	if (vinfo->flags & BRIDGE_VLAN_INFO_PVID)
> +		b53_port->pvid =3D vinfo->vid;
> +	else
> +		b53_port->pvid =3D 0;
> +
> +	vlan =3D &b53->vlans[vinfo->vid];
> +	if (vinfo->flags & BRIDGE_VLAN_INFO_UNTAGGED)
> +		vlan->untag |=3D BIT(b53_port->port_number);
> +	else
> +		vlan->untag &=3D ~BIT(b53_port->port_number);
> +
> +	b53_apply(b53);
> +
> +	return 0;
> +}
> +
> +static const struct net_device_ops b53_port_netdev_ops =3D {
> +	.ndo_start_xmit			=3D b53_port_xmit,
> +	.ndo_vlan_rx_add_vid		=3D b53_port_vlan_rx_add_vid,
> +	.ndo_vlan_rx_kill_vid		=3D b53_port_vlan_rx_kill_vid,
> +	.ndo_switch_parent_id_get	=3D b53_port_switch_parent_id_get,
> +	.ndo_bridge_setlink		=3D b53_port_bridge_setlink,
> +};

I see there is an xmit function, but no napi registration at all.

Is this simply because the SoC ethernet dev is doing all the frame rx?
Is is able to demux the frames correctly, so it is clear which swXpY
received the frame?  That will be necessary to ensure that standard
applications that want to open sockets directly on the needed interface=
s
can still function properly.

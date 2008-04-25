From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] via-velocity: fix vlan receipt
Date: Fri, 25 Apr 2008 01:47:29 -0400
Message-ID: <48117071.8040109@garzik.org>
References: <20080424213233.GA23638@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	=?ISO-8859-1?Q?S=E9guier_?= =?ISO-8859-1?Q?R=E9gis?=
	<rseguier@e-teleport.net>, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:46802 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753199AbYDYFri (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Apr 2008 01:47:38 -0400
In-Reply-To: <20080424213233.GA23638@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rancois Romieu wrote:
> - vlans were using a single CAM register (see mac_set_vlan_cam)
> - setting the address filtering registers for vlans is not
>   needed when there is no vlan
>=20
> The non-tagged interface is filtered out as soon as a tagged
> (!=3D 0) interface is created. Its traffic appears again when an
> zero-tagged interface is created.
>=20
> Tested on Via Epia SN (VT6130 chipset) with several vlans whose
> tag was above or beyond 255.
>=20
> Signed-off-by: S=E9guier R=E9gis <rseguier@e-teleport.net>
> Acked-by: Francois Romieu <romieu@fr.zoreil.com>
> ---
>  drivers/net/via-velocity.c |   46 ++++++++++++++++++++++++++--------=
---------
>  1 files changed, 28 insertions(+), 18 deletions(-)
>=20
> diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
> index ed1afaf..036c5c9 100644
> --- a/drivers/net/via-velocity.c
> +++ b/drivers/net/via-velocity.c
> @@ -605,7 +605,6 @@ static void __devinit velocity_get_options(struct=
 velocity_opt *opts, int index,
>  static void velocity_init_cam_filter(struct velocity_info *vptr)
>  {
>  	struct mac_regs __iomem * regs =3D vptr->mac_regs;
> -	unsigned short vid;
> =20
>  	/* Turn on MCFG_PQEN, turn off MCFG_RTGOPT */
>  	WORD_REG_BITS_SET(MCFG_PQEN, MCFG_RTGOPT, &regs->MCFG);
> @@ -617,29 +616,33 @@ static void velocity_init_cam_filter(struct vel=
ocity_info *vptr)
>  	mac_set_vlan_cam_mask(regs, vptr->vCAMmask);
>  	mac_set_cam_mask(regs, vptr->mCAMmask);
> =20
> -	/* Enable first VCAM */
> +	/* Enable VCAMs */
>  	if (vptr->vlgrp) {
> -		for (vid =3D 0; vid < VLAN_VID_MASK; vid++) {
> -			if (vlan_group_get_device(vptr->vlgrp, vid)) {
> -				/* If Tagging option is enabled and
> -				   VLAN ID is not zero, then
> -				   turn on MCFG_RTGOPT also */
> -				if (vid !=3D 0)
> -					WORD_REG_BITS_ON(MCFG_RTGOPT, &regs->MCFG);
> +		unsigned int vid, i =3D 0;
> +
> +		if (!vlan_group_get_device(vptr->vlgrp, 0))
> +			WORD_REG_BITS_ON(MCFG_RTGOPT, &regs->MCFG);
> =20
> -				mac_set_vlan_cam(regs, 0, (u8 *) &vid);
> +		for (vid =3D 1; (vid < VLAN_VID_MASK); vid++) {
> +			if (vlan_group_get_device(vptr->vlgrp, vid)) {
> +				mac_set_vlan_cam(regs, i, (u8 *) &vid);
> +				vptr->vCAMmask[i / 8] |=3D 0x1 << (i % 8);
> +				if (++i >=3D VCAM_SIZE)
> +					break;
>  			}
>  		}
> -		vptr->vCAMmask[0] |=3D 1;
>  		mac_set_vlan_cam_mask(regs, vptr->vCAMmask);
> -	} else {
> -		u16 temp =3D 0;
> -		mac_set_vlan_cam(regs, 0, (u8 *) &temp);
> -		temp =3D 1;
> -		mac_set_vlan_cam_mask(regs, (u8 *) &temp);
>  	}
>  }
> =20
> +static void velocity_vlan_rx_register(struct net_device *dev,
> +				      struct vlan_group *grp)
> +{
> +	struct velocity_info *vptr =3D netdev_priv(dev);
> +
> +	vptr->vlgrp =3D grp;
> +}
> +
>  static void velocity_vlan_rx_add_vid(struct net_device *dev, unsigne=
d short vid)
>  {
>  	struct velocity_info *vptr =3D netdev_priv(dev);
> @@ -959,11 +962,13 @@ static int __devinit velocity_found1(struct pci=
_dev *pdev, const struct pci_devi
> =20
>  	dev->vlan_rx_add_vid =3D velocity_vlan_rx_add_vid;
>  	dev->vlan_rx_kill_vid =3D velocity_vlan_rx_kill_vid;
> +	dev->vlan_rx_register =3D velocity_vlan_rx_register;
> =20
>  #ifdef  VELOCITY_ZERO_COPY_SUPPORT
>  	dev->features |=3D NETIF_F_SG;
>  #endif
> -	dev->features |=3D NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_FILTER;
> +	dev->features |=3D NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_FILTER |
> +		NETIF_F_HW_VLAN_RX;
> =20
>  	if (vptr->flags & VELOCITY_FLAGS_TX_CSUM)
>  		dev->features |=3D NETIF_F_IP_CSUM;
> @@ -1597,8 +1602,13 @@ static int velocity_receive_frame(struct veloc=
ity_info *vptr, int idx)
>  	skb_put(skb, pkt_len - 4);
>  	skb->protocol =3D eth_type_trans(skb, vptr->dev);
> =20
> +	if (vptr->vlgrp && (rd->rdesc0.RSR & RSR_DETAG)) {
> +		vlan_hwaccel_rx(skb, vptr->vlgrp,
> +				swab16(le16_to_cpu(rd->rdesc1.PQTAG));
> +	} else
> +		netif_rx(skb);
> +
>  	stats->rx_bytes +=3D pkt_len;
> -	netif_rx(skb);
> =20

applied



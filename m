From: Jon Mason <jon.mason@exar.com>
Subject: Re: [PATCH] net: Fix too optimistic NETIF_F_HW_CSUM features
Date: Tue, 30 Nov 2010 10:12:33 -0600
Message-ID: <20101130161233.GA26958@exar.com>
References: <20101130142352.3936.51663.stgit@rechot.qmqm.pl>
 <1291130005.21077.18.camel@bwh-desktop>
 <20101130152838.GA26281@rere.qmqm.pl>
 <20101130154123.GA27904@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ramkrishna Vepa <Ramkrishna.Vepa@exar.com>,
	Sivakumar Subramani <Sivakumar.Subramani@exar.com>,
	Sreenivasa Honnur <Sreenivasa.Honnur@exar.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Jesse Gross <jesse@nicira.com>
To: =?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:53532 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751297Ab0K3QMl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 11:12:41 -0500
Received: by yxt3 with SMTP id 3so2281507yxt.19
        for <netdev@vger.kernel.org>; Tue, 30 Nov 2010 08:12:40 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20101130154123.GA27904@rere.qmqm.pl>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 30, 2010 at 07:41:23AM -0800, Micha=C5=82 Miros=C5=82aw wro=
te:
> On Tue, Nov 30, 2010 at 04:28:38PM +0100, Micha=C5=82Miros=C5=82aw wr=
ote:
> > On Tue, Nov 30, 2010 at 03:13:25PM +0000, Ben Hutchings wrote:
> > > On Tue, 2010-11-30 at 15:23 +0100, Micha=C5=82Miros=C5=82aw wrote=
:
> > > > NETIF_F_HW_CSUM is superset of NETIF_F_IP_CSUM+NETIF_F_IPV6_CSU=
M, but
> > > > some drivers miss the difference. Fix this and also fix UFO dep=
endency
> > > > on checksumming offload as it makes the same mistake in assumpt=
ions.
> [...]
> > > > diff --git a/drivers/net/vxge/vxge-ethtool.c b/drivers/net/vxge=
/vxge-ethtool.c
> > > > index bc9bd10..5ece50d 100644
> > > > --- a/drivers/net/vxge/vxge-ethtool.c
> > > > +++ b/drivers/net/vxge/vxge-ethtool.c
> > > > @@ -1177,7 +1177,7 @@ static const struct ethtool_ops vxge_etht=
ool_ops =3D {
> > > >  	.get_rx_csum		=3D vxge_get_rx_csum,
> > > >  	.set_rx_csum		=3D vxge_set_rx_csum,
> > > >  	.get_tx_csum		=3D ethtool_op_get_tx_csum,
> > > > -	.set_tx_csum		=3D ethtool_op_set_tx_hw_csum,
> > > > +	.set_tx_csum		=3D ethtool_op_set_tx_csum,
> > > >  	.get_sg			=3D ethtool_op_get_sg,
> > > >  	.set_sg			=3D ethtool_op_set_sg,
> > > >  	.get_tso		=3D ethtool_op_get_tso,
> > > > diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vx=
ge-main.c
> > > > index a21dae1..9f6d379 100644
> > > > --- a/drivers/net/vxge/vxge-main.c
> > > > +++ b/drivers/net/vxge/vxge-main.c
> > > > @@ -3368,7 +3368,7 @@ static int __devinit vxge_device_register=
(struct __vxge_hw_device *hldev,
> > > > =20
> > > >  	ndev->features |=3D NETIF_F_SG;
> > > > =20
> > > > -	ndev->features |=3D NETIF_F_HW_CSUM;
> > > > +	ndev->features |=3D NETIF_F_IP_CSUM;
> > > >  	vxge_debug_init(vxge_hw_device_trace_level_get(hldev),
> > > >  		"%s : checksuming enabled", __func__);
> > > > =20
> > > Why are you disabling IPv6 checksum offload?  From a quick look a=
t the
> > > driver, I think the hardware does support it.
> >=20
> > In vxge_xmit() (at drivers/net/vxge/vxge-main.c:922 in net-next) th=
ere
> > is the following code, that suggested otherwise:
> >=20
> >         if (skb->ip_summed =3D=3D CHECKSUM_PARTIAL)
> >                 vxge_hw_fifo_txdl_cksum_set_bits(dtr,
> >                                         VXGE_HW_FIFO_TXD_TX_CKO_IPV=
4_EN |
> >                                         VXGE_HW_FIFO_TXD_TX_CKO_TCP=
_EN |
> >                                         VXGE_HW_FIFO_TXD_TX_CKO_UDP=
_EN);
> >=20
>=20
> Lets ask vxge driver maintainters on this.
>=20
> Does vxge support IPv6 TCP/UDP checksumming offload?

Yes, the underlying hardware can handle checksumming TCP/UDP in an
IPv6 frame.  So the change in the former code above would revert this.
The latter piece of code is for inserting the IPv4 checksum.

Thanks,
Jon

>=20
> Best Regards,
> Micha=C5=82 Miros=C5=82aw

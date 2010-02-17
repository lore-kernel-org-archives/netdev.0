From: Anatolij Gustschin <agust@denx.de>
Subject: Re: [net-next-2.6 PATCH v2 3/3] fs_enet: add FEC TX buffer
 alignment workaround for MPC5121
Date: Wed, 17 Feb 2010 22:31:04 +0100
Message-ID: <20100217223104.41d91a83@wker>
References: <1266418530-2727-1-git-send-email-agust@denx.de>
	<1266418530-2727-2-git-send-email-agust@denx.de>
	<1266418530-2727-3-git-send-email-agust@denx.de>
	<1266418530-2727-4-git-send-email-agust@denx.de>
	<1266419836.3075.12.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	"David S. Miller" <davem@davemloft.net>,
	Grant Likely <grant.likely@secretlab.ca>,
	Detlev Zundel <dzu@denx.de>, Wolfgang Denk <wd@denx.de>,
	John Rigby <jcrigby@gmail.com>,
	Piotr Ziecik <kosmo@semihalf.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:45622 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754175Ab0BQVb3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 16:31:29 -0500
In-Reply-To: <1266419836.3075.12.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 17 Feb 2010 16:17:16 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le mercredi 17 f=C3=A9vrier 2010 =C3=A0 15:55 +0100, Anatolij Gustsch=
in a =C3=A9crit :
=2E..
> > +static struct sk_buff *tx_skb_align_workaround(struct net_device *=
dev,
> > +					       struct sk_buff *skb)
> > +{
> > +	struct sk_buff *new_skb;
> > +	struct fs_enet_private *fep =3D netdev_priv(dev);
> > +
> > +	/* Alloc new skb */
> > +	new_skb =3D dev_alloc_skb(ENET_RX_FRSIZE + 4);
>=20
>=20
> ENET_RX_FRSIZE looks strange in TX path
>=20
> Why not using skb->len + 4 instead of ENET_RX_FRSIZE + 4 ?

I will fix it.

> > +	if (!new_skb) {
> > +		dev_warn(fep->dev, "Memory squeeze, dropping tx packet.\n");
>=20
> I am just wondering if this is ratelimited ?

Right, it should be ratelimited, will fix it, too.

=2E..
> >  static int fs_enet_start_xmit(struct sk_buff *skb, struct net_devi=
ce *dev)
> >  {
> >  	struct fs_enet_private *fep =3D netdev_priv(dev);
> > @@ -588,6 +619,19 @@ static int fs_enet_start_xmit(struct sk_buff *=
skb, struct net_device *dev)
> >  	u16 sc;
> >  	unsigned long flags;
> > =20
> > +#ifdef CONFIG_FS_ENET_MPC5121_FEC
> > +	if (((unsigned long)skb->data) & 0x3) {
> > +		skb =3D tx_skb_align_workaround(dev, skb);
> > +		if (!skb) {
> > +			/*
> > +			 * We have lost packet due to memory allocation error
> > +			 * in tx_skb_align_workaround(). Hopefully original
> > +			 * skb is still valid, so try transmit it later.
> > +			 */
>=20
> Could you define 'try to transmit later' ?
> Who is responsible to trigger this event ?

The function returns NETDEV_TX_BUSY here, skb is not
consumed and will be requeued by sch_direct_xmit(), so
it is scheduled for resending later.

Thanks,
Anatolij

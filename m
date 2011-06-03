From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] bonding: reset queue mapping prior to transmission to
 physical device (v4)
Date: Fri, 03 Jun 2011 22:05:53 +0200
Message-ID: <1307131553.2600.14.camel@edumazet-laptop>
References: <1307123978.2789.53.camel@bwh-desktop>
	 <1307129073-3769-1-git-send-email-nhorman@tuxdriver.com>
	 <1307130531.2600.8.camel@edumazet-laptop>
	 <20110603195700.GC16656@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:49190 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751707Ab1FCUF5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2011 16:05:57 -0400
Received: by wwa36 with SMTP id 36so2030847wwa.1
        for <netdev@vger.kernel.org>; Fri, 03 Jun 2011 13:05:55 -0700 (PDT)
In-Reply-To: <20110603195700.GC16656@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 03 juin 2011 =C3=A0 15:57 -0400, Neil Horman a =C3=A9crit :
> On Fri, Jun 03, 2011 at 09:48:51PM +0200, Eric Dumazet wrote:
> > Le vendredi 03 juin 2011 =C3=A0 15:24 -0400, Neil Horman a =C3=A9cr=
it :
> > > The bonding driver is multiqueue enabled, in which each queue rep=
resents a slave
> > > to enable optional steering of output frames to given slaves agai=
nst the default
> > > output policy.  However, it needs to reset the skb->queue_mapping=
 prior to
> > > queuing to the physical device or the physical slave (if it is mu=
ltiqueue) could
> > > wind up transmitting on an unintended tx queue
> > >=20
> > > Change Notes:
> > > v2) Based on first pass review, updated the patch to restore the =
origional queue
> > > mapping that was found in bond_select_queue, rather than simply r=
esetting to
> > > zero.  This preserves the value of queue_mapping when it was set =
on receive in
> > > the forwarding case which is desireable.
> > >=20
> > > v3) Fixed spelling an casting error in skb->cb
> > >=20
> > > v4) fixed to store raw queue_mapping to avoid double decrement
> > >=20
> > > Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> > > CC: Jay Vosburgh <fubar@us.ibm.com>
> > > CC: Andy Gospodarek <andy@greyhouse.net>
> > > CC: "David S. Miller" <davem@davemloft.net>
> > > ---
> > >  drivers/net/bonding/bond_main.c |    8 ++++++++
> > >  1 files changed, 8 insertions(+), 0 deletions(-)
> > >=20
> > > diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bondin=
g/bond_main.c
> > > index 17b4dd9..76adf27 100644
> > > --- a/drivers/net/bonding/bond_main.c
> > > +++ b/drivers/net/bonding/bond_main.c
> > > @@ -400,6 +400,9 @@ int bond_dev_queue_xmit(struct bonding *bond,=
 struct sk_buff *skb,
> > >  {
> > >  	skb->dev =3D slave_dev;
> > >  	skb->priority =3D 1;
> > > +
> > > +	skb->queue_mapping =3D ((u16 *)skb->cb)[0];
> >=20
> > Please dont do that. Use a helper.
> >=20
> Why?  It seems to be reasonably common practice for drivers to access
> queue_mapping directly.
>=20
> Examples can be found in:
> ixgbe_xmit_frame
> mlx4_en_xmit
> qlge_send
> igb_xmit_frame_adv
> gfar_start_xmit
>=20
> among others.
>=20
> Not saying its correct to do so necessecarily, but it seems a helper =
doesn't buy
> us much here, particularly a per-driver helper.  If a helper really s=
hould be
> used, why not just consistently use skb_get_queue_mapping?
> Neil

I was speaking of skb->cb access, of course, sorry if you missed my
point ;)

Please take a look at various files using helpers for this.

=46or example : net/ipv4/igmp.c

#define igmp_skb_size(skb) (*(unsigned int *)((skb)->cb))




From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] bonding: reset queue mapping prior to transmission to
 physical device (v4)
Date: Fri, 3 Jun 2011 15:57:00 -0400
Message-ID: <20110603195700.GC16656@hmsreliant.think-freely.org>
References: <1307123978.2789.53.camel@bwh-desktop>
 <1307129073-3769-1-git-send-email-nhorman@tuxdriver.com>
 <1307130531.2600.8.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:59737 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754865Ab1FCT5K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2011 15:57:10 -0400
Content-Disposition: inline
In-Reply-To: <1307130531.2600.8.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 03, 2011 at 09:48:51PM +0200, Eric Dumazet wrote:
> Le vendredi 03 juin 2011 =E0 15:24 -0400, Neil Horman a =E9crit :
> > The bonding driver is multiqueue enabled, in which each queue repre=
sents a slave
> > to enable optional steering of output frames to given slaves agains=
t the default
> > output policy.  However, it needs to reset the skb->queue_mapping p=
rior to
> > queuing to the physical device or the physical slave (if it is mult=
iqueue) could
> > wind up transmitting on an unintended tx queue
> >=20
> > Change Notes:
> > v2) Based on first pass review, updated the patch to restore the or=
igional queue
> > mapping that was found in bond_select_queue, rather than simply res=
etting to
> > zero.  This preserves the value of queue_mapping when it was set on=
 receive in
> > the forwarding case which is desireable.
> >=20
> > v3) Fixed spelling an casting error in skb->cb
> >=20
> > v4) fixed to store raw queue_mapping to avoid double decrement
> >=20
> > Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> > CC: Jay Vosburgh <fubar@us.ibm.com>
> > CC: Andy Gospodarek <andy@greyhouse.net>
> > CC: "David S. Miller" <davem@davemloft.net>
> > ---
> >  drivers/net/bonding/bond_main.c |    8 ++++++++
> >  1 files changed, 8 insertions(+), 0 deletions(-)
> >=20
> > diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/=
bond_main.c
> > index 17b4dd9..76adf27 100644
> > --- a/drivers/net/bonding/bond_main.c
> > +++ b/drivers/net/bonding/bond_main.c
> > @@ -400,6 +400,9 @@ int bond_dev_queue_xmit(struct bonding *bond, s=
truct sk_buff *skb,
> >  {
> >  	skb->dev =3D slave_dev;
> >  	skb->priority =3D 1;
> > +
> > +	skb->queue_mapping =3D ((u16 *)skb->cb)[0];
>=20
> Please dont do that. Use a helper.
>=20
Why?  It seems to be reasonably common practice for drivers to access
queue_mapping directly.

Examples can be found in:
ixgbe_xmit_frame
mlx4_en_xmit
qlge_send
igb_xmit_frame_adv
gfar_start_xmit

among others.

Not saying its correct to do so necessecarily, but it seems a helper do=
esn't buy
us much here, particularly a per-driver helper.  If a helper really sho=
uld be
used, why not just consistently use skb_get_queue_mapping?
Neil

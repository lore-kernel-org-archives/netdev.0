From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] Fix deadlock between boomerang_interrupt and
 boomerang_start_tx in 3c59x
Date: Mon, 23 Aug 2010 16:24:52 -0400
Message-ID: <20100823202452.GC12906@hmsreliant.think-freely.org>
References: <20100811151257.GB23317@hmsreliant.think-freely.org>
 <1282593694.2378.230.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:40417 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754405Ab0HWUab (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 16:30:31 -0400
Content-Disposition: inline
In-Reply-To: <1282593694.2378.230.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 23, 2010 at 10:01:34PM +0200, Eric Dumazet wrote:
> Le mercredi 11 ao=FBt 2010 =E0 11:12 -0400, Neil Horman a =E9crit :
> > If netconsole is in use, there is a possibility for deadlock in 3c5=
9x between
> > boomerang_interrupt and boomerang_start_xmit.  Both routines take t=
he vp->lock,
> > and if netconsole is in use, a pr_* call from the boomerang_interru=
pt routine
> > will result in the netconsole code attempting to trnasmit an skb, w=
hich can try
> > to take the same spin lock, resulting in deadlock.
> >=20
> > The fix is pretty straightforward.  This patch allocats a bit in th=
e 3c59x
> > private structure to indicate that its handling an interrupt.  If w=
e get into
> > the transmit routine and that bit is set, we can be sure that we ha=
ve recursed
> > and will deadlock if we continue, so instead we just return NETDEV_=
TX_BUSY, so
> > the stack requeues the skb to try again later.
> >=20
> > Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> > ---
> >  drivers/net/3c59x.c |   15 ++++++++++++++-
> >  1 files changed, 14 insertions(+), 1 deletions(-)
> >=20
> > diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
> > index c754d88..c685a55 100644
> > --- a/drivers/net/3c59x.c
> > +++ b/drivers/net/3c59x.c
> > @@ -633,7 +633,8 @@ struct vortex_private {
> >  		open:1,
> >  		medialock:1,
> >  		must_free_region:1,				/* Flag: if zero, Cardbus owns the I/O re=
gion */
> > -		large_frames:1;			/* accept large frames */
> > +		large_frames:1,			/* accept large frames */
> > +		handling_irq:1;			/* private in_irq indicator */
>=20
>=20
> It would be safer and faster to use a dedicated 'int' instead of a
> bitfield.
>=20
>=20
>=20
>=20


=46aster I agree with, although I'm not sure if speed is really a big i=
ssue here,
given that this is a ancient (but fairly well used) 10/100 adapter.  An=
d we
still have space in the octet that that bitfield is living in, so I fig=
ured I'd
use that anyway.

As for safe, I'm not sure I follow you on that point.  Is there somethi=
ng
inherently dangerous about using a bitfield in this case?

Neil


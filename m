From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next-2.6 2/2] 3c59x: Use fine-grained locks for MII
 and windowed register access
Date: Thu, 24 Jun 2010 13:57:19 +0100
Message-ID: <1277384239.26161.162.camel@localhost>
References: <1277337161.26161.14.camel@localhost>
	 <1277337341.26161.18.camel@localhost>  <20100624120517.GI5570@secunet.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-1UPfDNOyuy5unMLAvJS3"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Chase Douglas <chase.douglas@canonical.com>,
	Arne Nordmark <nordmark@mech.kth.se>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:60937 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752381Ab0FXM5a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jun 2010 08:57:30 -0400
In-Reply-To: <20100624120517.GI5570@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-1UPfDNOyuy5unMLAvJS3
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2010-06-24 at 14:05 +0200, Steffen Klassert wrote:
> Hi.
>=20
> On Thu, Jun 24, 2010 at 12:55:41AM +0100, Ben Hutchings wrote:
> > This avoids scheduling in atomic context and also means that IRQs
> > will only be deferred for relatively short periods of time.
> >=20
> > Previously discussed in:
> > http://article.gmane.org/gmane.linux.network/155024
> >=20
> > Reported-by: Arne Nordmark <nordmark@mech.kth.se>
> > Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> > Tested-by: Arne Nordmark <nordmark@mech.kth.se> [against 2.6.32]
> > ---
> >  drivers/net/3c59x.c |   66 ++++++++++++++++++++++++++++++-------------=
--------
> >  1 files changed, 39 insertions(+), 27 deletions(-)
> >=20
> > diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
> > index beddef9..f4a3fb1 100644
> > --- a/drivers/net/3c59x.c
> > +++ b/drivers/net/3c59x.c
> > @@ -644,9 +644,15 @@ struct vortex_private {
> >  	u16 deferred;						/* Resend these interrupts when we
> >  										 * bale from the ISR */
> >  	u16 io_size;						/* Size of PCI region (for release_region) */
> > -	spinlock_t lock;					/* Serialise access to device & its vortex_priva=
te */
> > -	struct mii_if_info mii;				/* MII lib hooks/info */
> > -	int window;					/* Register window */
> > +
> > +	/* Serialises access to hardware other than MII and variables below.
> > +	 * The lock hierarchy is rtnl_lock > lock > mii_lock > window_lock. *=
/
> > +	spinlock_t lock;
> > +
> > +	spinlock_t mii_lock;		/* Serialises access to MII */
> > +	struct mii_if_info mii;		/* MII lib hooks/info */
> > +	spinlock_t window_lock;		/* Serialises access to windowed regs */
>=20
> You should initialize the new locks properly with spin_lock_init().

Oops, yes, obviously.

> > +	int window;			/* Register window */
> >  };
> > =20
> >  static void window_set(struct vortex_private *vp, int window)
> > @@ -661,15 +667,23 @@ static void window_set(struct vortex_private *vp,=
 int window)
> >  static u ## size							\
> >  window_read ## size(struct vortex_private *vp, int window, int addr)	\
> >  {									\
> > +	unsigned long flags;						\
> > +	u ## size ret;							\
> > +	spin_lock_irqsave(&vp->window_lock, flags);			\
> >  	window_set(vp, window);						\
> > -	return ioread ## size(vp->ioaddr + addr);			\
> > +	ret =3D ioread ## size(vp->ioaddr + addr);			\
> > +	spin_unlock_irqrestore(&vp->window_lock, flags);		\
> > +	return ret;							\
> >  }									\
> >  static void								\
> >  window_write ## size(struct vortex_private *vp, u ## size value,	\
> >  		     int window, int addr)				\
> >  {									\
> > +	unsigned long flags;						\
> > +	spin_lock_irqsave(&vp->window_lock, flags);			\
> >  	window_set(vp, window);						\
> >  	iowrite ## size(value, vp->ioaddr + addr);			\
> > +	spin_unlock_irqrestore(&vp->window_lock, flags);		\
> >  }
>=20
> This adds a lot of calls to spin_lock_irqsave/spin_unlock_irqrestore to m=
any
> places where this is not necessary at all. For example during device prob=
e and
> device open, window_read/window_write are called multiple times, each tim=
e
> disabling the interrupts. I'd suggest to have unlocked, locked and irqsav=
e
> versions of window_read/window_write and use them in appropriate places.

So what?  These are not speed-critical.  The fast-path functions do
acquire the lock just once.

> >  DEFINE_WINDOW_IO(8)
> >  DEFINE_WINDOW_IO(16)
> > @@ -1784,7 +1798,6 @@ vortex_timer(unsigned long data)
> >  		pr_debug("dev->watchdog_timeo=3D%d\n", dev->watchdog_timeo);
> >  	}
> > =20
> > -	disable_irq_lockdep(dev->irq);
> >  	media_status =3D window_read16(vp, 4, Wn4_Media);
> >  	switch (dev->if_port) {
> >  	case XCVR_10baseT:  case XCVR_100baseTx:  case XCVR_100baseFx:
> > @@ -1805,10 +1818,7 @@ vortex_timer(unsigned long data)
> >  	case XCVR_MII: case XCVR_NWAY:
> >  		{
> >  			ok =3D 1;
> > -			/* Interrupts are already disabled */
> > -			spin_lock(&vp->lock);
> >  			vortex_check_media(dev, 0);
> > -			spin_unlock(&vp->lock);
> >  		}
> >  		break;
> >  	  default:					/* Other media types handled by Tx timeouts. */
> > @@ -1827,6 +1837,8 @@ vortex_timer(unsigned long data)
> >  	if (!ok) {
> >  		unsigned int config;
> > =20
> > +		spin_lock_irq(&vp->lock);
>=20
> This can still happen every 5 seconds if the NIC has no link beat and
> medialock is not set. So what about defering this locked codepath to
> a workqueue, or moving the whole vortex_timer to a delayed workqueue?
> In this case we don't need to disable all the interrups on the cpu, we
> could still use disable_irq then.

This locked section is now very short - 5 or 6 register read/writes and
no delays.  We might even be able to get away without locking here as
the only software state this accesses is dev->if_port and I don't think
it can race with anything except SIOCGIFMAP (which seems harmless).

Ben.

> The rest looks quite good to me.
>=20
> Thanks,
>=20
> Steffen
>=20

--=20
Ben Hutchings
Once a job is fouled up, anything done to improve it makes it worse.

--=-1UPfDNOyuy5unMLAvJS3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUATCNWJee/yOyVhhEJAQJF1g/+MHSlowUydXB2Lia8EVu1YGz842D+VImP
aFCR4FRHik3LNQBfNiHNTLe+SE31qXder+ergDZCLoUwL68MW7I5D4qMv0YVThMR
21i3k+Gm3VvQMb2xDlotEIe4DVfw081Ey6vbw6Z8shMS3JdJux9duY9DvALzC0FU
Pi51QqKO8ZufeN9In+RZ39PIqOl2q25OL6YBawM0+WwEcz2qya85P4efUvxipU9p
1ZCDbRFEi31/hd61r2jCFumGCIjqlf8pfONlHINTR1KYTFMYVqnKO/DrnDB1Ywjg
dtNWHXnIwnBrSBVW24N7K2fOG0QwoIndf9gX5+qQdyGN25VrxD4I2RnYKjKAVa3w
7xLCTPnm4KN/UDMQfS/cCytMGkFNGSK+LTYoG/RshbtG/f+B7BEEgiU1cIalMu0V
+MSUcSq6tzsjVv2NG13IUL5J9ey/8nbbi4srKK917LJyDrIhYeR6LmkVlfxRaq2W
RzmNALPb+xRKHBbfF0tuTV1GMnlKtYLAvfVohkEhOggyl+E2R0vg2H6e6kzDZ1KN
EDcIHaM7fV0Vfe5iQlHUfDP5TgIElkdZIkSh6j/AEzP+DtKcY+NDMk2KvxEChWOQ
f5tUYirBQHcd2EZ0vMSP7ppOhrDQVxyBcP3ZSqzKZDUXbMdOSi3MQSNRob826omI
VbvUKCMER5M=
=ODfw
-----END PGP SIGNATURE-----

--=-1UPfDNOyuy5unMLAvJS3--

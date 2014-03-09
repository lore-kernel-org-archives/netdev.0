From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] net: sched: dev_deactivate_many(): use msleep(1)
 instead of yield() to wait for outstanding qdisc_run calls
Date: Sun, 09 Mar 2014 23:17:52 +0000
Message-ID: <1394407072.15968.81.camel@deadeye.wl.decadent.org.uk>
References: <1393976987-23555-1-git-send-email-mkl@pengutronix.de>
	 <20140306.160622.59358366688518505.davem@davemloft.net>
	 <1394392160.15968.13.camel@deadeye.wl.decadent.org.uk>
	 <20140309.185338.2057082497431220324.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-2/ULzx60VvtLiA8I9fzc"
Cc: mkl@pengutronix.de, linux-rt-users@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	kernel@pengutronix.de
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140309.185338.2057082497431220324.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-2/ULzx60VvtLiA8I9fzc
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2014-03-09 at 18:53 -0400, David Miller wrote:
> From: Ben Hutchings <ben@decadent.org.uk>
> Date: Sun, 09 Mar 2014 19:09:20 +0000
>=20
> > On Thu, 2014-03-06 at 16:06 -0500, David Miller wrote:
> >> From: Marc Kleine-Budde <mkl@pengutronix.de>
> >> Date: Wed,  5 Mar 2014 00:49:47 +0100
> >>=20
> >> > @@ -839,7 +839,7 @@ void dev_deactivate_many(struct list_head *head)
> >> >       /* Wait for outstanding qdisc_run calls. */
> >> >       list_for_each_entry(dev, head, unreg_list)
> >> >               while (some_qdisc_is_busy(dev))
> >> > -                     yield();
> >> > +                     msleep(1)
> >> >  }
> >>=20
> >> I don't understand this.
> >>=20
> >> yield() should really _mean_ yield.
> >>=20
> >> The intent of a yield() call, like this one here, is unambiguously
> >> that the current thread cannot do anything until some other thread
> >> gets onto the cpu and makes forward progress.
> >>
> >> Therefore it should allow lower priority threads to run, not just
> >> equal or higher priority ones.
> >=20
> > Until when?
> >=20
> > yield() is not a sensible operation in a preemptive multitasking system=
,
> > regardless of RT.
>=20
> To me it means "I've got nothing to do if other tasks want to run right
> now"  Yes, I even see it having this meaning when an RT task executes
> it.
>=20
> How else can you interpret the intent above?

The problem is that 'I've got nothing to do ... now' is information
about a *point* in time, which gives the scheduler no clue as to when
this task might be ready again.  So far as task *state* goes, it never
ceases to be ready.

> If you change it to msleep(1), you're assigning an extra completely
> arbitrary time limit to the yield.  The code doesn't want to sleep
> for 1ms, that's not what it's asking for.
[...]

I think you want to give up a 'time slice' to any task that's available.
But that's not a meaningful concept for all schedulers.  If your task is
highest priority and is ready, it must run.  You could drop priority
temporarily, but then you need it to somehow be bumped up again at some
time in the future.  Well, sleeping effectively does that.

I do understand that unconditionally sleeping also isn't ideal - the
task that unblocks this one might already be running on another CPU and
able to finish sooner than the sleep timeout.

Maybe the answer is a yield_for(time) which sleeps for the given time or
until there's an idle CPU, whichever is sooner.  But I don't know how
hard that would be to implement or how widely useful it would be.

Ben.

--=20
Ben Hutchings
I say we take off; nuke the site from orbit.  It's the only way to be sure.

--=-2/ULzx60VvtLiA8I9fzc
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUxz2oOe/yOyVhhEJAQqEdRAAmXlGXs+/789OBmNlwKat0bSr4q2U2SN5
Uxqe98KE18Khv6egE6yNenOyCVOMkIcEwrLQUoCFlm0mwA/oNBtQvGVCeP5mkSW4
zmNUH7mxWP2gNMEy6g5BOTprz7fEmjuVhF7L3f3HeASglWld6y8TPllEccM3Tlvx
9kwYlMi0A9hOxT4/0HWH/7ACRTkA8zOskaqFtBDyHpZgOj6Rrot+Gw4uStqDI7K8
/e+nYG5g/Knk/FRy5YjWIpJxX121B77ie6PdDKNsX48/RlFizHbjuxVrKyAQTiOw
2lGJGzgY+TythQbyavIICBGDeApFFfl1MDcEBottvUXjyHTLrgqpzR7bs/Ix3AS5
sx+U6ojBTa/yAgOobHwnGQ+nv3zzUlFRBDTTjASDiVKjE47o4HCm3q3rFkcqRbLZ
uOUjKQ5hV2fk2fWEVv6SX7qAeaBjlnKs3HsqW1ruSWH7fxfjIadTxFyi8xLZUIAH
7nxO1kN47/YUSQmHK7TlvOoJGlxo7jrP6DO3oZyEolbJbca2+Y7JVQAatmeblwu8
m1OKKfqDF0ZRN77Bn1SPQNNbajqviO5Ld0c/EKCxnvpKgwwly8qWfSRIO6Xbji1b
Oj/0zTbGBJ1BAYXfB3kocz/a/FPtTT/SrIBozfm1i6yDIkDViKGvu9svrZ7w38BW
teeIcMU74g8=
=ymAx
-----END PGP SIGNATURE-----

--=-2/ULzx60VvtLiA8I9fzc--

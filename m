From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [setsockopt] WARNING: CPU: 0 PID: 1444 at
 kernel/sched/core.c:7088 __might_sleep+0x51/0x16f()
Date: Thu, 7 Aug 2014 19:25:14 +0200
Message-ID: <20140807172514.GY9918@twins.programming.kicks-ass.net>
References: <20140805214624.GA9973@localhost>
 <20140807151741.GP19379@twins.programming.kicks-ass.net>
 <20140807125948.2b7f1472@thirdoffive.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="+jeX5HKdKiEmzpj5"
Cc: Fengguang Wu <fengguang.wu@intel.com>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>, lkp@01.org,
	linux-atm-general@lists.sourceforge.net
To: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140807125948.2b7f1472@thirdoffive.cmf.nrl.navy.mil>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--+jeX5HKdKiEmzpj5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Aug 07, 2014 at 12:59:48PM -0400, chas williams - CONTRACTOR wrote:
> On Thu, 7 Aug 2014 17:17:41 +0200
> Peter Zijlstra <peterz@infradead.org> wrote:
>=20
> > Subject: atm: Fix blocking in wait loop
> >=20
> > One should not call blocking primitives inside a wait loop, since both
> > require task_struct::state to sleep, so the inner will destroy the outer
> > state.
> >=20
> > In this instance sigd_enq() will possible sleep for alloc_skb(), now if
> > I understand the code right, we do not actually need to call sigd_enq()
> > after the initial prepare_to_wait(), because we test the termination
> > condition before schedule() anyhow.
> >=20
> > So we can simply move it up a bit and avoid the entire confusion.
> >=20
> > Signed-off-by: Peter Zijlstra <peterz@infradead.org>
> > ---
> >  net/atm/svc.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> >=20
> > diff --git a/net/atm/svc.c b/net/atm/svc.c
> > index d8e5d0c2ebbc..445ac238b69b 100644
> > --- a/net/atm/svc.c
> > +++ b/net/atm/svc.c
> > @@ -297,8 +297,8 @@ static int svc_listen(struct socket *sock, int back=
log)
> >  		goto out;
> >  	}
> >  	set_bit(ATM_VF_WAITING, &vcc->flags);
> > -	prepare_to_wait(sk_sleep(sk), &wait, TASK_UNINTERRUPTIBLE);
> >  	sigd_enq(vcc, as_listen, NULL, NULL, &vcc->local);
> > +	prepare_to_wait(sk_sleep(sk), &wait, TASK_UNINTERRUPTIBLE);
> >  	while (test_bit(ATM_VF_WAITING, &vcc->flags) && sigd) {
> >  		schedule();
> >  		prepare_to_wait(sk_sleep(sk), &wait, TASK_UNINTERRUPTIBLE);
>=20
>=20
> This isn't the only place that we queue a message for the signalling
> daemon after a prepare_to_wait() uninterruptibly so this patch would
> be incomplete as is.

I'm not sure I follow, this is the only place you do so while then going
to sleep. All other sites don't sleep while they're enqueued on the
waitqueue.

> What bothers me is the TASK_UNINTERRUPTIBLE -- I don't have a good
> reason why any of these should be sleeping uninterruptibly.

That's a whole different story, there's tons of ugly in there, but its
all ancient code.

--+jeX5HKdKiEmzpj5
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJT47Z6AAoJEHZH4aRLwOS6y6IQAK1xhnP5tHh2CuxFrnvnNUzj
1YNk95EsKaRo66kK4iAjAt0j1c8QRiLWa7AkJRT8SxLL/r8oGRNUIsD0VfpVNPpU
Q/LcGYMqIT9Pcr8gaA5zG0poUj4S7Xc0m2aGgu6VL4InojjQ8QAbsfFOf9aYxRU+
358f6XPO/7rsarpwhyZpA6c6FbEJGAFLsSVq+GgacjL/1Mwjqz/Mx+8C4muK+tmw
vgcPOAwsG9yTxpu8gZgyf44FQW9RoOL/zqZcrPCyhkMfpo2vzf+DJdWGJBIVtqui
6a5PYTWVnsVfrWOhYcfuztGdB9VeECcCZlxOpQvt3D3mv/2LJg6IYGxyFlomtd4g
e2F7ood7wd+25m2OB69Ne46dkchVFM8P8oJH4NK0oXrSWadscEKRtn9iJguUNX2D
Pzzr0zrq9kUSlrjiIkeNH3798ylsDEGeuFtfL+QQH7mRTqASU0cxBD5rPjsQyzdD
MjigPDHVVrKaSyn0f3c2aXyyL9ndds66ilQrlE9n9NMJxPOys23+MSmkVd+fjD8w
KskrxX4u6FEfM14UOhai127HdeNuaqpjHdBcFWOQUXpbO+ueunoMWNx0PS83UPjK
i7g64iyj+wjyuvpIwYqt3dPKv/13HqHBZiTlnN1FoWfQSOODj0IJBG+X+VWIVJdd
gxA30clfeiNzO/MnzzE1
=DbFs
-----END PGP SIGNATURE-----

--+jeX5HKdKiEmzpj5--

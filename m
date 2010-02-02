From: Yury Polyanskiy <ypolyans@princeton.edu>
Subject: Re: [BUG]? xfrm: INFO: inconsistent lock state
Date: Tue, 2 Feb 2010 08:51:17 -0500
Message-ID: <20100202085117.7a5c3530@penta.localdomain>
References: <4B66A670.70503@cn.fujitsu.com>
	<20100202074914.GD11081@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/1GKAPjUtZCYOkGDprOEtjiv"; protocol="application/pgp-signature"
Cc: Wei Yongjun <yjwei@cn.fujitsu.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, peterz@infradead.org,
	polyanskiy@gmail.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ppa02.Princeton.EDU ([128.112.128.216]:48487 "EHLO
	ppa02.Princeton.EDU" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755974Ab0BBOAs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2010 09:00:48 -0500
In-Reply-To: <20100202074914.GD11081@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/1GKAPjUtZCYOkGDprOEtjiv
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 2 Feb 2010 18:49:14 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Mon, Feb 01, 2010 at 06:01:20PM +0800, Wei Yongjun wrote:
> > I got following lock INFO in my Fedora12 box uner 2.6.33-rc6.
> > Is this a BUG?
>=20
> Apparently.
>=20
> This is introduced by
>=20
> commit 9e0d57fd6dad37d72a3ca6db00ca8c76f2215454
> Author: Yury Polyanskiy <polyanskiy@gmail.com>
> Date:   Sun Nov 8 20:58:41 2009 -0800
>=20
>     xfrm: SAD entries do not expire correctly after suspend-resume
> =20
> Whether this is a real dead-lock depends on whether hrtimers
> behave as real hard IRQs.  If they do then yes it can deadlock.

If hrtimer_tasklet interface functions properly, the
xfrm_timer_handler should be called in softirq context (and thus is
never in parallel with xfrm_input()). The deadlock isn't possible then.

In this case it seems that for some reason xfrm_timer_handler() is
called in the hardirq context. The relevant code in hrtimer_tasklet:

static enum hrtimer_restart __hrtimer_tasklet_trampoline(struct hrtimer *ti=
mer)
{
	struct tasklet_hrtimer *ttimer =3D
		container_of(timer, struct tasklet_hrtimer, timer);

	if (hrtimer_is_hres_active(timer)) {
		tasklet_hi_schedule(&ttimer->tasklet);
		return HRTIMER_NORESTART;
	}
	return ttimer->function(timer);
}

I am copying Peter on this. Peter, how is it possible that
ttimer->function() is called in hardirq?

Could it be that switch from hres_active happened after the call to
trampoline and before the if() above?

Best,
Yury

--Sig_/1GKAPjUtZCYOkGDprOEtjiv
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAktoLdUACgkQemuRe3zuqORBbwCeI3RPpDPpnpCnQdZYbi9MDH8L
DOgAn0FJ8N6JZ9H5DhKoAyzhY/kcD1AW
=K3SY
-----END PGP SIGNATURE-----

--Sig_/1GKAPjUtZCYOkGDprOEtjiv--

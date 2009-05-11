From: Yury Polyanskiy <ypolyans@Princeton.EDU>
Subject: Re: [PATCH] xfrm: SAD entries do not expire after suspend-resume
Date: Mon, 11 May 2009 16:50:24 -0400
Message-ID: <20090511165024.5da4e3f2@penta.localdomain>
References: <20090511142101.639cb5d6@penta.localdomain>
	<1242066617.6656.1311.camel@laptop>
	<ea182b20905111307w2cdbe18dw9f9fde474216c219@mail.gmail.com>
	<1242073557.8257.116.camel@laptop>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/IyhsDX9ZSFZG4+LLTNEqE=Y"; protocol="application/pgp-signature"
Cc: netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	yoshfuji@linux-ipv6.org, mingo@elte.hu,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Thomas Gleixner <tglx@linutronix.de>,
	john stultz <johnstul@us.ibm.com>
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postoffice05.Princeton.EDU ([128.112.133.189]:35886 "EHLO
	Princeton.EDU" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751636AbZEKVAo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2009 17:00:44 -0400
In-Reply-To: <1242073557.8257.116.camel@laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/IyhsDX9ZSFZG4+LLTNEqE=Y
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 11 May 2009 22:25:57 +0200
Peter Zijlstra <peterz@infradead.org> wrote:

> > >>   Due to (2) I am copying the authors of the hrtimer's patch.
> > >> Unless there is an alternative (to hrtimer_start) way of
> > >> requesting a CLOCK_REALTIME softirq callback the only solution I
> > >> could think of is to hook into
> > >> PM_POST_HIBERNATION+PM_POST_SUSPEND and force all of the timers
> > >> on xfrm_state_all list to go off after resume.
> > >
> > > Given that the whole problem is suspend related, this last option
> > > sounds like the best thing.
> > >
> >=20
> > Can somebody from the Networking Team please confirm that the other
> > sources of time leaps can indeed be neglected? (such as ntp
> > corrections e.g.)
>=20
> ntp time adjustments are very fine grained and should not distort
> time. Setting the system clock otoh might screw you over though.

Isn't ntp sometimes used for initial clock setting? (i.e. host boots
with sysclock set to 1971 and then ntp makes it to the correct 2009).

Another reason for not doing it pm_notify()-wise is to reduce the
amount of resume code running in the system: why run a user-specific
O(N) post-suspend code if there is already an O(1) one in the
hres_timers_resume()?

>=20
> What I'm not quite getting is though, if we have a real-time timer 8h
> in the future, and we suspend for 10h, the timer should fire the
> moment we resume and readjust the clock, finding this -2h expired
> timer.
>=20
> Since they're realtime timers and we don't know what they're used for,
> we cannot handle this time lapse in the generic code, hence its users
> are stuck with dealing with this.
>=20


The problem is that the current code simply arms a usual timer_list
timer, which remains stopped during suspend. So how do you set up a
CLOCK_REALTIME timer w/o using hrtimer_start()?

Thanks in advance,
Yury.


--Sig_/IyhsDX9ZSFZG4+LLTNEqE=Y
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkoIj5AACgkQemuRe3zuqORzTgCfVBzce5olghdbk7xcJaaYaHfo
AtgAnAwTpQ9UxS1XotU2qOHzZsYUfv2J
=8a4m
-----END PGP SIGNATURE-----

--Sig_/IyhsDX9ZSFZG4+LLTNEqE=Y--

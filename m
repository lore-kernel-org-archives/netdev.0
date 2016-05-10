From: Rik van Riel <riel@redhat.com>
Subject: Re: [RFC PATCH 0/2] net: threadable napi poll loop
Date: Tue, 10 May 2016 17:35:21 -0400
Message-ID: <1462916121.16365.14.camel@redhat.com>
References: <cover.1462886866.git.pabeni@redhat.com>
	 <1462890590.23934.68.camel@edumazet-glaptop3.roam.corp.google.com>
	 <90f3db8c-c30c-b204-576a-454939ac93ce@stressinduktion.org>
	 <CANn89i+YKrVOgfFwW-2psfCzq5_YLdmbV06-H-1FCOwXdMBuzQ@mail.gmail.com>
	 <1462915900.23934.99.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-+Hp82MwztQaz4s3S4XK7"
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Paolo Abeni <pabeni@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jiri@mellanox.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Alexander Duyck <aduyck@mirantis.com>,
	Tom Herbert <tom@herbertland.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59845 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751479AbcEJVf0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 May 2016 17:35:26 -0400
In-Reply-To: <1462915900.23934.99.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-+Hp82MwztQaz4s3S4XK7
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2016-05-10 at 14:31 -0700, Eric Dumazet wrote:
> On Tue, 2016-05-10 at 14:09 -0700, Eric Dumazet wrote:
> >=20
> > On Tue, May 10, 2016 at 1:46 PM, Hannes Frederic Sowa
> > <hannes@stressinduktion.org> wrote:
> >=20
> > >=20
> > > I agree here, but I don't think this patch particularly is a lot
> > > of
> > > bloat and something very interesting people can play with and
> > > extend upon.
> > >=20
> > Sure, very rarely patch authors think their stuff is bloat.
> >=20
> > I prefer to fix kernel softirq.c, or at least show me that you
> > tried
> > hard enough.
> >=20
> > I am pretty sure that the following would work :
> >=20
> > When ksoftirqd is scheduled, remember this in a per cpu variable
> > (ksoftiqd_scheduled)
> >=20
> > When enabling BH , do not call do_softirq() if this variable is
> > set.
> >=20
> > ksoftirqd would clear the variable at the right place (probably in
> > run_ksoftirqd())
> >=20
> > Sure, this might add a lot of latency regressions, but lets fix
> > them.
> Only to give the idea (it is completely untested and probably buggy)
>=20
> diff --git a/kernel/softirq.c b/kernel/softirq.c
> index 17caf4b63342..cb30cfd76687 100644
> --- a/kernel/softirq.c
> +++ b/kernel/softirq.c
> @@ -56,6 +56,7 @@ EXPORT_SYMBOL(irq_stat);
> =C2=A0static struct softirq_action softirq_vec[NR_SOFTIRQS]
> __cacheline_aligned_in_smp;
> =C2=A0
> =C2=A0DEFINE_PER_CPU(struct task_struct *, ksoftirqd);
> +DEFINE_PER_CPU(bool, ksoftirqd_scheduled);
> =C2=A0
> =C2=A0const char * const softirq_to_name[NR_SOFTIRQS] =3D {
> =C2=A0	"HI", "TIMER", "NET_TX", "NET_RX", "BLOCK", "BLOCK_IOPOLL",
> @@ -73,8 +74,10 @@ static void wakeup_softirqd(void)
> =C2=A0	/* Interrupts are disabled: no need to stop preemption */
> =C2=A0	struct task_struct *tsk =3D __this_cpu_read(ksoftirqd);
> =C2=A0
> -	if (tsk && tsk->state !=3D TASK_RUNNING)
> +	if (tsk && tsk->state !=3D TASK_RUNNING) {
> +		__this_cpu_write(ksoftirqd_scheduled, true);
> =C2=A0		wake_up_process(tsk);
> +	}
> =C2=A0}
> =C2=A0
> =C2=A0/*
> @@ -162,7 +165,9 @@ void __local_bh_enable_ip(unsigned long ip,
> unsigned int cnt)
> =C2=A0	=C2=A0*/
> =C2=A0	preempt_count_sub(cnt - 1);
> =C2=A0
> -	if (unlikely(!in_interrupt() && local_softirq_pending())) {
> +	if (unlikely(!in_interrupt() &&
> +		=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0local_softirq_pending() &&
> +		=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0!__this_cpu_read(ksoftirqd_scheduled))) =
{
> =C2=A0		/*
>=20

You might need another one of these in invoke_softirq()

--=20
All Rights Reversed.


--=-+Hp82MwztQaz4s3S4XK7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJXMlQZAAoJEM553pKExN6DeEQIAIOLcR7dEj2Iz6Xul5O06A6t
d5D3bDJI1fqktmpqAiHKJDYjMX+xcet6iehL0RNol2fdxvnXCXerl1h0n8WhYu21
5TYWHNSuLukK4H/Cc3Cj3gK37YggYqTmfOduGgBORdcrnyzRU1Hg5JgtYq4UkmW/
GD/zskSRtS5EcbIvIMGcAEeWNd8ohK5YPX5Yyca4+9Dtn5sctU9SPGpd1AKQKuer
nlxHBCYweu9F+ULOC/xpugN0KT0GLNQEXYhTDKgONU1OdiyAxcNFVbjLtKfSW5OW
VO943rzAoWiADEX9RYOd4TKYqQdg+WXM8JhPUlqzBcgiN0P7m28VLI4DyTn0mdE=
=Hsnj
-----END PGP SIGNATURE-----

--=-+Hp82MwztQaz4s3S4XK7--

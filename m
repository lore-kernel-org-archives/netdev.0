From: Oleksandr Natalenko <oleksandr@natalenko.name>
Subject: Re: [REGRESSION] tcp/ipv4: kernel panic because of (possible) division by zero
Date: Sun, 10 Jan 2016 23:56:54 +0200
Message-ID: <3240923.Qg3kfz0Bvr@spock>
References: <26396443.iDTTxgChSj@spock> <1562805.Wa36G0OKaZ@spock> <CADVnQykPOVf7PoK8-6Mvbmbcpe1eYY=cfKHgiNGDNSFfCDPb-A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Yuchung Cheng <ycheng@google.com>, netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	James Morris <jmorris@namei.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"David S. Miller" <davem@davemloft.net>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CADVnQykPOVf7PoK8-6Mvbmbcpe1eYY=cfKHgiNGDNSFfCDPb-A@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

OK, it seems the assumption about YeAH is correct. Here is stacktrace f=
ired by=20
WARN_ON_ONCE():

https://gist.github.com/851cedcfca60d6120035

Is there sufficient info for you to prepare upstream patch?

On =D0=BD=D0=B5=D0=B4=D1=96=D0=BB=D1=8F, 10 =D1=81=D1=96=D1=87=D0=BD=D1=
=8F 2016 =D1=80. 12:29:17 EET Neal Cardwell wrote:
> On Sun, Jan 10, 2016 at 9:57 AM, Oleksandr Natalenko
>=20
> <oleksandr@natalenko.name> wrote:
> > I use YeAH. But YeAH code wasn't touched between 4.2 and 4.3.
>=20
> Oh, interesting. Looks like tcp_yeah_ssthresh() has a bug where its
> intended reduction can be bigger than tp->snd_cwnd, leading to it
> return a zero ssthresh (or even an ssthresh that underflows to ~4
> billion). If tcp_yeah_ssthresh() returns an ssthresh of 0 then PRR
> will try to pull the cwnd down to 0.
>=20
> Can you please leave ECN and Yeah enabled and run something like the
> following patch, to verify this conjecture? If the conjecture is
> right, then the tcp_yeah warning should fire but not the new
> tcp_cwnd_reduction() warning:
>=20
> -----------
> diff --git a/net/ipv4/tcp_yeah.c b/net/ipv4/tcp_yeah.c
> index 17d3566..ef60cba 100644
> --- a/net/ipv4/tcp_yeah.c
> +++ b/net/ipv4/tcp_yeah.c
> @@ -206,6 +206,7 @@ static u32 tcp_yeah_ssthresh(struct sock *sk)
>         const struct tcp_sock *tp =3D tcp_sk(sk);
>         struct yeah *yeah =3D inet_csk_ca(sk);
>         u32 reduction;
> +       s32 ssthresh;
>=20
>         if (yeah->doing_reno_now < TCP_YEAH_RHO) {
>                 reduction =3D yeah->lastQ;
> @@ -219,7 +220,9 @@ static u32 tcp_yeah_ssthresh(struct sock *sk)
>         yeah->fast_count =3D 0;
>         yeah->reno_count =3D max(yeah->reno_count>>1, 2U);
>=20
> -       return tp->snd_cwnd - reduction;
> +       ssthresh =3D tp->snd_cwnd - reduction;
> +       if (WARN_ON_ONCE(ssthresh <=3D 0))
> +               ssthresh =3D 1;
>  }
>=20
>  static struct tcp_congestion_ops tcp_yeah __read_mostly =3D {
> -----------
>=20
> If that works, then we may just want a version of this patch without
> the warning.
>=20
> Thanks!
> neal

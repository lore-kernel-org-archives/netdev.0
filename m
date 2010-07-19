From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCHv2] tcp: fix crash in tcp_xmit_retransmit_queue
Date: Mon, 19 Jul 2010 16:09:15 +0200
Message-ID: <1279548555.2553.51.camel@edumazet-laptop>
References: <4C358AAA.9080400@kernel.org>
	 <alpine.DEB.2.00.1007111825510.15736@melkinpaasi.cs.helsinki.fi>
	 <4C3EF7EA.2040900@nets.rwth-aachen.de>
	 <1279195528.2496.2.camel@edumazet-laptop>
	 <4C3F053F.7090704@nets.rwth-aachen.de>
	 <alpine.DEB.2.00.1007161448330.13946@melkinpaasi.cs.helsinki.fi>
	 <4C404FC5.6040107@nets.rwth-aachen.de>
	 <alpine.DEB.2.00.1007161602510.13946@melkinpaasi.cs.helsinki.fi>
	 <4C440771.7080107@nets.rwth-aachen.de>
	 <alpine.DEB.2.00.1007191319010.13002@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Lennart Schulte <lennart.schulte@nets.rwth-aachen.de>,
	David Miller <davem@davemloft.net>, Tejun Heo <tj@kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Fehrmann, Henning" <henning.fehrmann@aei.mpg.de>,
	Carsten Aulbert <carsten.aulbert@aei.mpg.de>
To: Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.1007191319010.13002@wel-95.cs.helsinki.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 19 juillet 2010 =C3=A0 14:16 +0300, Ilpo J=C3=A4rvinen a =C3=A9=
crit :

> Thanks for testing.
>=20
> DaveM, I think this oops was introduced for 2.6.28 (in=20
> 08ebd1721ab8fd362e90ae17b461c07b23fa2824 it seems, to be exact) so to=
=20
> stables it should go too please. I've only tweaked the message (so no=
 need=20
> for Lennart to retest v2 :-)).
>=20
> --
> [PATCHv2] tcp: fix crash in tcp_xmit_retransmit_queue
>=20
> It can happen that there are no packets in queue while calling
> tcp_xmit_retransmit_queue(). tcp_write_queue_head() then returns
> NULL and that gets deref'ed to get sacked into a local var.
>=20
> There is no work to do if no packets are outstanding so we just
> exit early.
>=20
> This oops was introduced by 08ebd1721ab8fd (tcp: remove tp->lost_out
> guard to make joining diff nicer).
>=20

But prior to commit 08ebd1721ab8fd3, we were not testing
tp->packets_out, but tp->lost_out

if it was 0, we were not doing the tcp_for_write_queue_from() loop.

Not sure it makes a difference ?

> Signed-off-by: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
> Reported-by: Lennart Schulte <lennart.schulte@nets.rwth-aachen.de>
> Tested-by: Lennart Schulte <lennart.schulte@nets.rwth-aachen.de>
> ---
>  net/ipv4/tcp_output.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
>=20
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index b4ed957..7ed9dc1 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -2208,6 +2208,9 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
>  	int mib_idx;
>  	int fwd_rexmitting =3D 0;
> =20
> +	if (!tp->packets_out)
> +		return;
> +
>  	if (!tp->lost_out)
>  		tp->retransmit_high =3D tp->snd_una;
> =20

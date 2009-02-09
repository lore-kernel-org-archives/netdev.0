From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: commit 64ff3b938ec6782e6585a83d5459b98b0c3f6eb8 breaks rlogin
Date: Mon, 9 Feb 2009 18:28:06 +1100
Message-ID: <20090209072806.GB4380@gondor.apana.org.au>
References: <20090206054541.GA4954@gondor.apana.org.au> <b6a2187b0902060335h646e8d86pf00773035f577665@mail.gmail.com> <20090209055848.GA3889@gondor.apana.org.au> <20090208.220357.261414983.davem@davemloft.net> <20090209061151.GA3982@gondor.apana.org.au> <Pine.LNX.4.64.0902090853360.20576@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, jeff.chua.linux@gmail.com,
	rjw@sisk.pl, torvalds@linux-foundation.org,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:40969 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754001AbZBIH20 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 02:28:26 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0902090853360.20576@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 09, 2009 at 09:13:00AM +0200, Ilpo J=E4rvinen wrote:
>=20
> Hmm, what happens if a opposite dir ACK gets sent (it's zero sized se=
qno
> range will be above urgent sequence when urg is not yet acknowledged)=
? So
> we'll take the later branch after your change and send bogus 0xffff u=
rg?
> I think you're change might have actually broken bidir tcp completely=
 (and
> probably window probing as well under some conditions). Congraz, two =
flies
> with a single stroke :-). You would have needed an additional check t=
hat
> the tcb->seq is below urg...
>=20
> ...Below is a patch but Jeff might need to revert the revert first if
> he tests with the latest Linus' tree.

Good point! That would definitely explain this.
=20
> [PATCH] tcp: check that we're still < urg instead of sending a bogus =
one
>=20
> Opposite dir ACK with zero sized seqno range can go into the
> later condition once urg is in the outstanding window not
> yet acknowledge (we're still in urg mode but seqno we sent in
> the ack won't be below snd_up). Need to check that we never
> advertize bogus urg for a segment which is after the snd_up.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
> ---
>  net/ipv4/tcp_output.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
>=20
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index 557fe16..c808d73 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -667,7 +667,8 @@ static int tcp_transmit_skb(struct sock *sk, stru=
ct sk_buff *skb, int clone_it,
>  		if (between(tp->snd_up, tcb->seq + 1, tcb->seq + 0xFFFF)) {
>  			th->urg_ptr =3D htons(tp->snd_up - tcb->seq);
>  			th->urg =3D 1;
> -		} else if (after(tcb->seq + 0xFFFF, tp->snd_nxt)) {
> +		} else if (after(tcb->seq + 0xFFFF, tp->snd_nxt) &&
> +			   before(tcb->seq, tcp->snd_up)) {
>  			th->urg_ptr =3D 0xFFFF;
>  			th->urg =3D 1;
>  		}

We could rewrite this as

	if (unlikely(tcp_urg_mode(tp) && before(tcb->seq, tcp->snd_up))) {
		if (before(tp->sndup, tcb->seq + 0x10000)) {
			th->urg_ptr =3D htons(tp->snd_up - tcb->seq);
			th->urg =3D 1;
		} else if (after(tcb->seq + 0xFFFF, tp->snd_nxt)) {
			th->urg_ptr =3D 0xFFFF;
			th->urg =3D 1;
		}
	}

Thanks,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

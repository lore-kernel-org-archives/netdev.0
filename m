From: John Heffner <jheffner@psc.edu>
Subject: Re: [RFC PATCH 1/2] [TCP]: MTUprobe: receiver window & data available
 checks fixed
Date: Wed, 21 Nov 2007 11:25:19 -0500
Message-ID: <47445BEF.4090002@psc.edu>
References: <11956608882424-git-send-email-ilpo.jarvinen@helsinki.fi> <11956608882602-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.psc.edu ([128.182.66.106]:54814 "EHLO mailer2.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756584AbXKUQpg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Nov 2007 11:45:36 -0500
In-Reply-To: <11956608882602-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ilpo J=E4rvinen wrote:
> It seems that the checked range for receiver window check should
> begin from the first rather than from the last skb that is going
> to be included to the probe. And that can be achieved without
> reference to skbs at all, snd_nxt and write_seq provides the
> correct seqno already. Plus, it SHOULD account packets that are
> necessary to trigger fast retransmit [RFC4821].
>=20
> Location of snd_wnd < probe_size/size_needed check is bogus
> because it will cause the other if() match as well (due to
> snd_nxt >=3D snd_una invariant).
>=20
> Removed dead obvious comment.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Acked-by: John Heffner <jheffner@psc.edu>


> ---
>  net/ipv4/tcp_output.c |   17 ++++++++---------
>  1 files changed, 8 insertions(+), 9 deletions(-)
>=20
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index 30d6737..ff22ce8 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -1289,6 +1289,7 @@ static int tcp_mtu_probe(struct sock *sk)
>  	struct sk_buff *skb, *nskb, *next;
>  	int len;
>  	int probe_size;
> +	int size_needed;
>  	unsigned int pif;
>  	int copy;
>  	int mss_now;
> @@ -1307,6 +1308,7 @@ static int tcp_mtu_probe(struct sock *sk)
>  	/* Very simple search strategy: just double the MSS. */
>  	mss_now =3D tcp_current_mss(sk, 0);
>  	probe_size =3D 2*tp->mss_cache;
> +	size_needed =3D probe_size + (tp->reordering + 1) * mss_now;
>  	if (probe_size > tcp_mtu_to_mss(sk, icsk->icsk_mtup.search_high)) {
>  		/* TODO: set timer for probe_converge_event */
>  		return -1;
> @@ -1316,18 +1318,15 @@ static int tcp_mtu_probe(struct sock *sk)
>  	len =3D 0;
>  	if ((skb =3D tcp_send_head(sk)) =3D=3D NULL)
>  		return -1;
> -	while ((len +=3D skb->len) < probe_size && !tcp_skb_is_last(sk, skb=
))
> +	while ((len +=3D skb->len) < size_needed && !tcp_skb_is_last(sk, sk=
b))
>  		skb =3D tcp_write_queue_next(sk, skb);
> -	if (len < probe_size)
> +	if (len < size_needed)
>  		return -1;
> =20
> -	/* Receive window check. */
> -	if (after(TCP_SKB_CB(skb)->seq + probe_size, tp->snd_una + tp->snd_=
wnd)) {
> -		if (tp->snd_wnd < probe_size)
> -			return -1;
> -		else
> -			return 0;
> -	}
> +	if (tp->snd_wnd < size_needed)
> +		return -1;
> +	if (after(tp->snd_nxt + size_needed, tp->snd_una + tp->snd_wnd))
> +		return 0;
> =20
>  	/* Do we need to wait to drain cwnd? */
>  	pif =3D tcp_packets_in_flight(tp);


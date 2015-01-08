From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2] tcp: avoid reducing cwnd when ACK+DSACK is
 received
Date: Thu, 08 Jan 2015 07:19:56 -0800
Message-ID: <1420730396.5947.55.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1420719609-18638-1-git-send-email-sebastien.barre@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Gregory Detal <gregory.detal@uclouvain.be>,
	Nandita Dukkipati <nanditad@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: =?ISO-8859-1?Q?S=E9bastien_Barr=E9?= <sebastien.barre@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:35645 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753877AbbAHPT7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 10:19:59 -0500
Received: by mail-ig0-f175.google.com with SMTP id h15so3221815igd.2
        for <netdev@vger.kernel.org>; Thu, 08 Jan 2015 07:19:58 -0800 (PST)
In-Reply-To: <1420719609-18638-1-git-send-email-sebastien.barre@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-01-08 at 13:20 +0100, S=C3=A9bastien Barr=C3=A9 wrote:
> When the peer has delayed ack enabled, it may reply to a probe with a=
n
> ACK+D-SACK, with ack value set to tlp_high_seq. In the current code,
> such ACK+DSACK will be missed and only at next, higher ack will the T=
LP
> episode be considered done. Since the DSACK is not present anymore,
> this will cost a cwnd reduction.
>=20
=2E..
>  net/ipv4/tcp_input.c | 30 +++++++++++++-----------------
>  1 file changed, 13 insertions(+), 17 deletions(-)
>=20
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 075ab4d..cf63a29 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -3363,29 +3363,25 @@ static void tcp_replace_ts_recent(struct tcp_=
sock *tp, u32 seq)
>  static void tcp_process_tlp_ack(struct sock *sk, u32 ack, int flag)
>  {
>  	struct tcp_sock *tp =3D tcp_sk(sk);
> -	bool is_tlp_dupack =3D (ack =3D=3D tp->tlp_high_seq) &&
> -			     !(flag & (FLAG_SND_UNA_ADVANCED |
> -				       FLAG_NOT_DUP | FLAG_DATA_SACKED));
> =20

No idea why you removed this bool, it really helped to understand the
code. This makes your patch looks more complex than needed.

>  	/* Mark the end of TLP episode on receiving TLP dupack or when
>  	 * ack is after tlp_high_seq.
> +	 * With delayed acks, we may also get a regular ACK+DSACK, in which
> +	 * case we don't want to reduce the cwnd either.
>  	 */
> -	if (is_tlp_dupack) {
> +	if (((ack =3D=3D tp->tlp_high_seq) &&
> +	     !(flag & (FLAG_SND_UNA_ADVANCED |
> +		       FLAG_NOT_DUP | FLAG_DATA_SACKED))) ||
> +	    (!before(ack, tp->tlp_high_seq) && (flag & FLAG_DSACKING_ACK)))=
 {
>  		tp->tlp_high_seq =3D 0;
> -		return;
> -	}

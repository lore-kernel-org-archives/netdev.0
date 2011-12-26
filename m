From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] unix_diag: Fix incoming connections nla length
Date: Mon, 26 Dec 2011 20:36:12 +0100
Message-ID: <1324928172.2599.3.camel@edumazet-laptop>
References: <4EF7804D.4050300@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:48011 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752636Ab1LZTgR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Dec 2011 14:36:17 -0500
Received: by wgbdr13 with SMTP id dr13so20272227wgb.1
        for <netdev@vger.kernel.org>; Mon, 26 Dec 2011 11:36:16 -0800 (PST)
In-Reply-To: <4EF7804D.4050300@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 25 d=C3=A9cembre 2011 =C3=A0 23:58 +0400, Pavel Emelyanov a=
 =C3=A9crit :
> The NLA_PUT macro should accept the actual attribute length, not
> the amount of elements in array :(
>=20
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
>=20
> ---
>  net/unix/diag.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
>=20
> diff --git a/net/unix/diag.c b/net/unix/diag.c
> index 91d5782..39e44c9 100644
> --- a/net/unix/diag.c
> +++ b/net/unix/diag.c
> @@ -72,7 +72,8 @@ static int sk_diag_dump_icons(struct sock *sk, stru=
ct sk_buff *nlskb)
> =20
>  	if (sk->sk_state =3D=3D TCP_LISTEN) {
>  		spin_lock(&sk->sk_receive_queue.lock);
> -		buf =3D UNIX_DIAG_PUT(nlskb, UNIX_DIAG_ICONS, sk->sk_receive_queue=
=2Eqlen);
> +		buf =3D UNIX_DIAG_PUT(nlskb, UNIX_DIAG_ICONS,
> +				sk->sk_receive_queue.qlen * sizeof(u32));
>  		i =3D 0;
>  		skb_queue_walk(&sk->sk_receive_queue, skb) {
>  			struct sock *req, *peer;

Hmm, I must say sk_diag_dump_icons() looks buggy, since it does :


if (peer)
	buf[i++] =3D sock_i_ino(peer);

So we probably leak kernel memory content to user for the (!peer) case,
since we did :

UNIX_DIAG_PUT(nlskb, UNIX_DIAG_ICONS,
		sk->sk_receive_queue.qlen * sizeof(u32));

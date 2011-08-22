From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] fix pushed_seq in keepalive / zero window probe timer
Date: Mon, 22 Aug 2011 13:25:22 +0200
Message-ID: <1314012322.2307.16.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4E51FDD1.2010607@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	davem@davemloft.net, ilpo.jarvinen@helsinki.fi
To: Li Yu <raise.sail@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:43197 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751022Ab1HVLZV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2011 07:25:21 -0400
Received: by wwf5 with SMTP id 5so5103882wwf.1
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2011 04:25:20 -0700 (PDT)
In-Reply-To: <4E51FDD1.2010607@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 22 ao=C3=BBt 2011 =C3=A0 14:57 +0800, Li Yu a =C3=A9crit :
> In tcp_write_wakeup(), we may split the probe segment since send wind=
ow or mss is larger than it.
> so I think that we should update tp->pushed_seq after tcp_fragment(),=
 is it right? thanks.
>=20

I am not sure what you want to fix.

=46act is the skb has the TCPHDR_PSH, even if tcp_transmit_skb() (or
tcp_fragment()) is/are not able to clone/split it.


> Signed-off-by: Li Yu <raise.sail@gmail.com>
> CC: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
> CC: David S. Miller <davem@davemloft.net>
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index 882e0b0..659a71f 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -2784,9 +2784,6 @@ int tcp_write_wakeup(struct sock *sk)
>  		unsigned int mss =3D tcp_current_mss(sk);
>  		unsigned int seg_size =3D tcp_wnd_end(tp) - TCP_SKB_CB(skb)->seq;
> =20
> -		if (before(tp->pushed_seq, TCP_SKB_CB(skb)->end_seq))
> -			tp->pushed_seq =3D TCP_SKB_CB(skb)->end_seq;
> -
>  		/* We are probing the opening of a window
>  		 * but the window size is !=3D 0
>  		 * must have been a result SWS avoidance ( sender )
> @@ -2803,8 +2800,11 @@ int tcp_write_wakeup(struct sock *sk)
>  		TCP_SKB_CB(skb)->flags |=3D TCPHDR_PSH;
>  		TCP_SKB_CB(skb)->when =3D tcp_time_stamp;
>  		err =3D tcp_transmit_skb(sk, skb, 1, GFP_ATOMIC);
> -		if (!err)
> +		if (!err) {
>  			tcp_event_new_data_sent(sk, skb);
> +			if (before(tp->pushed_seq, TCP_SKB_CB(skb)->end_seq))
> +				tp->pushed_seq =3D TCP_SKB_CB(skb)->end_seq;
> +		}
>  		return err;
>  	} else {
>  		if (between(tp->snd_up, tp->snd_una + 1, tp->snd_una + 0xFFFF))
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH] tcp: fix incorrect LOCKDROPPEDICMPS counter
Date: Sat, 19 Jan 2013 18:47:05 -0800
Message-ID: <CAHo-OoyFbUiFJMHCGdd=cC9RwaXbccwgzhKp7mBTPiQGZz0NAQ@mail.gmail.com>
References: <1358647837.3464.1050.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f170.google.com ([209.85.220.170]:52133 "EHLO
	mail-vc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752184Ab3ATCrI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jan 2013 21:47:08 -0500
Received: by mail-vc0-f170.google.com with SMTP id fl11so4772587vcb.15
        for <netdev@vger.kernel.org>; Sat, 19 Jan 2013 18:47:05 -0800 (PST)
In-Reply-To: <1358647837.3464.1050.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Maciej =C5=BBenczykowski <maze@google.com>

On Sat, Jan 19, 2013 at 6:10 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> commit 563d34d057 (tcp: dont drop MTU reduction indications)
> added an error leading to incorrect accounting of
> LINUX_MIB_LOCKDROPPEDICMPS
>
> If socket is owned by the user, we want to increment
> this SNMP counter, unless the message is a
> (ICMP_DEST_UNREACH,ICMP_FRAG_NEEDED) one.
>
> Reported-by: Maciej =C5=BBenczykowski <maze@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> ---
>  net/ipv4/tcp_ipv4.c |    9 ++++-----
>  1 file changed, 4 insertions(+), 5 deletions(-)
>
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index 54139fa..70b09ef 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -369,11 +369,10 @@ void tcp_v4_err(struct sk_buff *icmp_skb, u32 i=
nfo)
>          * We do take care of PMTU discovery (RFC1191) special case :
>          * we can receive locally generated ICMP messages while socke=
t is held.
>          */
> -       if (sock_owned_by_user(sk) &&
> -           type !=3D ICMP_DEST_UNREACH &&
> -           code !=3D ICMP_FRAG_NEEDED)
> -               NET_INC_STATS_BH(net, LINUX_MIB_LOCKDROPPEDICMPS);
> -
> +       if (sock_owned_by_user(sk)) {
> +               if (!(type =3D=3D ICMP_DEST_UNREACH && code =3D=3D IC=
MP_FRAG_NEEDED))
> +                       NET_INC_STATS_BH(net, LINUX_MIB_LOCKDROPPEDIC=
MPS);
> +       }
>         if (sk->sk_state =3D=3D TCP_CLOSE)
>                 goto out;
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

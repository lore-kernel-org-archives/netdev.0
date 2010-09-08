From: =?UTF-8?Q?=E3=83=84_Leandro_Melo_de_Sales?= <leandroal@gmail.com>
Subject: Re: TCP packet size and delivery packet decisions
Date: Wed, 8 Sep 2010 11:06:43 -0300
Message-ID: <AANLkTind7xGeYWOOdf1xnsZoJ5aFaChpD=fU7yFU2f-T@mail.gmail.com>
References: <AANLkTikMPENe011GxK15TNTXwdckZSSYfb=3pdDwfUeG@mail.gmail.com>
 <20100906.221644.123986391.davem@davemloft.net> <AANLkTik75BGz=csDKVRk+Ni9__MqXMpHeqi_sHniu09A@mail.gmail.com>
 <20100906.223010.173858342.davem@davemloft.net> <1283859552.2338.402.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	=?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:59217 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752264Ab0IHOHT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 10:07:19 -0400
Received: by gyd8 with SMTP id 8so29486gyd.19
        for <netdev@vger.kernel.org>; Wed, 08 Sep 2010 07:07:18 -0700 (PDT)
In-Reply-To: <1283859552.2338.402.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 7, 2010 at 8:39 AM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> Le lundi 06 septembre 2010 =C3=A0 22:30 -0700, David Miller a =C3=A9c=
rit :
>
>
>> The small 78 byte window is why the sending system is splitting up t=
he
>> writes into smaller pieces.
>>
>> I presume that the system advertises exactly a 78 byte window becaus=
e
>> this is how large the commands are. =C2=A0But this is an extremely f=
oolish
>> and baroque thing to do, and it's why you are having problems.
>
> I am not sure why TSO added a "Bound mss with half of window"
> requirement for tcp_sync_mss()
>
> I tried with MSS=3D1000 and WIN=3D1000, and segment size chosen is 50=
0
>
> With WIN=3D78, 78/2->39 is then capped to 48 (68U - tp->tcp_header_le=
n)
>
> Is there a hard requirement about segment size being at most half the
> window ?
>
> Following patch solves the problem for me :
>
> [PATCH] tcp: bound mss to window in tcp_sync_mss()
>
> Leandro Melo de Sales noticed that if a peer announces a very small
> initial tcp window (78 in his case), first sent frames have unnecessa=
ry
> small lengths (48 in his case)
>
> CLNT->SRV =C2=A0 =C2=A0[SYN] Seq=3D0 Win=3D5840 Len=3D0 MSS=3D1460
> SRV->CLNT =C2=A0 =C2=A0[SYN, ACK] Seq=3D0 Ack=3D1 Win=3D78 Len=3D0 MS=
S=3D78
> CLNT->SRV =C2=A0 =C2=A0[ACK] Seq=3D1 Ack=3D1 Win=3D5840 Len=3D0
> CLNT->SRV =C2=A0 =C2=A0[PSH, ACK] Seq=3D1 Ack=3D1 Win=3D5840 Len=3D48
> CLNT->SRV =C2=A0 =C2=A0[PSH, ACK] Seq=3D49 Ack=3D1 Win=3D5840 Len=3D3=
0
> SRV->CLNT =C2=A0 =C2=A0[ACK] Seq=3D1 Ack=3D49 Win=3D78 Len=3D0
> SRV->CLNT =C2=A0 =C2=A0[RST, ACK] Seq=3D1 Ack=3D79 Win=3D78 Len=3D0
>
> tcp_sync_mss() bounds mss to half the window, while it could use full
> window:
>
> CLNT->SRV =C2=A0 =C2=A0[SYN] Seq=3D0 Win=3D5840 Len=3D0 MSS=3D1460
> SRV->CLNT =C2=A0 =C2=A0[SYN, ACK] Seq=3D0 Ack=3D1 Win=3D78 Len=3D0 MS=
S=3D78
> CLNT->SRV =C2=A0 =C2=A0[ACK] Seq=3D1 Ack=3D1 Win=3D5840 Len=3D0
> CLNT->SRV =C2=A0 =C2=A0[PSH, ACK] Seq=3D1 Ack=3D1 Win=3D5840 Len=3D78
> SRV->CLNT =C2=A0 =C2=A0[ACK] Seq=3D1 Ack=3D79 Win=3D78 Len=3D0
>
> Reported-by: =E3=83=84 Leandro Melo de Sales <leandroal@gmail.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
> ---
> =C2=A0include/net/tcp.h =C2=A0 =C2=A0 | =C2=A0 =C2=A09 +++++++++
> =C2=A0net/ipv4/tcp_output.c | =C2=A0 =C2=A02 +-
> =C2=A02 files changed, 10 insertions(+), 1 deletion(-)
>
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index eaa9582..c262676 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -481,6 +481,15 @@ static inline int tcp_bound_to_half_wnd(struct t=
cp_sock *tp, int pktsize)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return pktsize=
;
> =C2=A0}
>
> +/* Bound MSS / TSO packet size with the window */
> +static inline int tcp_bound_to_wnd(struct tcp_sock *tp, int pktsize)
> +{
> + =C2=A0 =C2=A0 =C2=A0 if (tp->max_window && pktsize > tp->max_window=
)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return max(tp->max=
_window, 68U - tp->tcp_header_len);
> + =C2=A0 =C2=A0 =C2=A0 else
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return pktsize;
> +}
> +
> =C2=A0/* tcp.c */
> =C2=A0extern void tcp_get_info(struct sock *, struct tcp_info *);
>
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index de3bd84..49cdbe4 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -1224,7 +1224,7 @@ unsigned int tcp_sync_mss(struct sock *sk, u32 =
pmtu)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0icsk->icsk_mtu=
p.search_high =3D pmtu;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0mss_now =3D tcp_mtu_to_mss(sk, pmtu);
> - =C2=A0 =C2=A0 =C2=A0 mss_now =3D tcp_bound_to_half_wnd(tp, mss_now)=
;
> + =C2=A0 =C2=A0 =C2=A0 mss_now =3D tcp_bound_to_wnd(tp, mss_now);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* And store cached results */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0icsk->icsk_pmtu_cookie =3D pmtu;
>
>
>


Hi Eric and others,
   Good. I have tested and it is working... This is the exactly
translation for code what I mentioned. Very nice...

   Will this patch be applied?

Thank you,
Leandro.

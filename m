From: Li Yu <raise.sail@gmail.com>
Subject: Re: [PATCH] fix pushed_seq in keepalive / zero window probe timer
Date: Mon, 22 Aug 2011 21:41:04 +0800
Message-ID: <CA+WLrf-0pPPmoCqo4na1btnOwEkupgcKWwGJ5AVBnxRUYx0YEA@mail.gmail.com>
References: <4E51FDD1.2010607@gmail.com>
	<1314012322.2307.16.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	davem@davemloft.net, ilpo.jarvinen@helsinki.fi
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:64348 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752457Ab1HVNlG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2011 09:41:06 -0400
Received: by wyg24 with SMTP id 24so3491917wyg.19
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2011 06:41:05 -0700 (PDT)
In-Reply-To: <1314012322.2307.16.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/8/22 Eric Dumazet <eric.dumazet@gmail.com>:
> Le lundi 22 ao=FBt 2011 =E0 14:57 +0800, Li Yu a =E9crit :
>> In tcp_write_wakeup(), we may split the probe segment since send win=
dow or mss is larger than it.
>> so I think that we should update tp->pushed_seq after tcp_fragment()=
, is it right? thanks.
>>
>
> I am not sure what you want to fix.
>
> Fact is the skb has the TCPHDR_PSH, even if tcp_transmit_skb() (or
> tcp_fragment()) is/are not able to clone/split it.
>
>

Indeed, you are right. The goal of this patch is to fix tp->pushed_seq
may point to unsent byte seq number.

>> Signed-off-by: Li Yu <raise.sail@gmail.com>
>> CC: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
>> CC: David S. Miller <davem@davemloft.net>
>> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
>> index 882e0b0..659a71f 100644
>> --- a/net/ipv4/tcp_output.c
>> +++ b/net/ipv4/tcp_output.c
>> @@ -2784,9 +2784,6 @@ int tcp_write_wakeup(struct sock *sk)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned int mss =3D tcp_current_mss(sk)=
;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned int seg_size =3D tcp_wnd_end(tp=
) - TCP_SKB_CB(skb)->seq;
>>
>> - =A0 =A0 =A0 =A0 =A0 =A0 if (before(tp->pushed_seq, TCP_SKB_CB(skb)=
->end_seq))
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tp->pushed_seq =3D TCP_SKB=
_CB(skb)->end_seq;
>> -
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* We are probing the opening of a windo=
w
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* but the window size is !=3D 0
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* must have been a result SWS avoidan=
ce ( sender )
>> @@ -2803,8 +2800,11 @@ int tcp_write_wakeup(struct sock *sk)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 TCP_SKB_CB(skb)->flags |=3D TCPHDR_PSH;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 TCP_SKB_CB(skb)->when =3D tcp_time_stamp=
;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D tcp_transmit_skb(sk, skb, 1, GFP=
_ATOMIC);
>> - =A0 =A0 =A0 =A0 =A0 =A0 if (!err)
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (!err) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tcp_event_new_data_sent(=
sk, skb);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (before(tp->pushed_seq,=
 TCP_SKB_CB(skb)->end_seq))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tp->pushed=
_seq =3D TCP_SKB_CB(skb)->end_seq;
>> + =A0 =A0 =A0 =A0 =A0 =A0 }
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return err;
>> =A0 =A0 =A0 } else {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (between(tp->snd_up, tp->snd_una + 1,=
 tp->snd_una + 0xFFFF))
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
>
>

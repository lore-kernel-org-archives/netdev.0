From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] [RFC] IPv4 TCP fails to send window scale option when
 window scale is zero
Date: Wed, 30 Sep 2009 09:16:15 +0200
Message-ID: <4AC305BF.6080306@gmail.com>
References: <4AC22250.7060301@codefidence.com> <4AC241BA.8040608@gmail.com> <4AC2FA7C.6030901@codefidence.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Ori Finkalman <ori@comsleep.com>
To: Gilad Ben-Yossef <gilad@codefidence.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:39472 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753424AbZI3HQR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2009 03:16:17 -0400
In-Reply-To: <4AC2FA7C.6030901@codefidence.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gilad Ben-Yossef a =E9crit :
> Hi,
>=20
>=20
> [ Resending reply due to Android Gmail client sorry state. My apologi=
es
> if you got it twice. ]
>=20
>=20
> Eric Dumazet wrote:
>=20
>> Gilad Ben-Yossef a =E9crit :
>> =20
>>> From: Ori Finkalman <ori@comsleep.com>
>>>
>>>
>>> Acknowledge TCP window scale support by inserting the proper option=
 in
>>> SYN/ACK header
>>> even if our window scale is zero.
>>>
>>>
>>> This fixes the following observed behavior:
>>>
>>>
>>> 1. Client sends a SYN with TCP window scaling option and non zero w=
indow
>>> scale value to a Linux box.
>>>
>>> 2. Linux box notes large receive window from client.
>>>
>>> 3. Linux decides on a zero value of window scale for its part.
>>>
>>> 4. Due to compare against requested window scale size option, Linux=
 does
>>> not to send windows scale
>>>
>>> TCP option header on SYN/ACK at all.
>>>
>>>
>>> Result:
>>>
>>>
>>> Client box thinks TCP window scaling is not supported, since SYN/AC=
K had
>>> no TCP window scale option,
>>> while Linux thinks that TCP window scaling is supported (and scale =
might
>>> be non zero), since SYN had
>>>
>>> TCP window scale option and we have a mismatched idea between the c=
lient
>>> and server regarding window sizes.
>>>
>>>
>>> Please comment and/or apply.
>>> ...
>>>
>>>
>>> Signed-off-by: Gilad Ben-Yossef <gilad@codefidence.com>
>>> Signed-off-by: Ori Finkelman <ori@comsleep.com>
>>>
>>>
>>> Index: net/ipv4/tcp_output.c
>>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>>> --- net/ipv4/tcp_output.c    (revision 46)
>>> +++ net/ipv4/tcp_output.c    (revision 210)
>>> @@ -353,6 +353,7 @@ static void tcp_init_nondata_skb(struct
>>> #define OPTION_SACK_ADVERTISE    (1 << 0)
>>> #define OPTION_TS        (1 << 1)
>>> #define OPTION_MD5        (1 << 2)
>>> +#define OPTION_WSCALE        (1 << 3)
>>>
>>> struct tcp_out_options {
>>>     u8 options;        /* bit field of OPTION_* */
>>> @@ -417,7 +418,7 @@ static void tcp_options_write(__be32 *pt
>>>                    TCPOLEN_SACK_PERM);
>>>     }
>>>
>>> -    if (unlikely(opts->ws)) {
>>> +    if (unlikely(OPTION_WSCALE & opts->options)) {
>>>         *ptr++ =3D htonl((TCPOPT_NOP << 24) |
>>>                    (TCPOPT_WINDOW << 16) |
>>>                    (TCPOLEN_WINDOW << 8) |
>>> @@ -530,8 +531,8 @@ static unsigned tcp_synack_options(struc
>>>
>>>     if (likely(ireq->wscale_ok)) {
>>>         opts->ws =3D ireq->rcv_wscale;
>>> -        if(likely(opts->ws))
>>> -            size +=3D TCPOLEN_WSCALE_ALIGNED;
>>> +        opts->options |=3D OPTION_WSCALE;
>>> +        size +=3D TCPOLEN_WSCALE_ALIGNED;
>>>     }
>>>     if (likely(doing_ts)) {
>>>         opts->options |=3D OPTION_TS;
>>>
>>>
>>>
>>>    =20
>>
>> Seems not the more logical places to put this logic...
>>
>> How about this instead ?
>>
>> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
>> index 5200aab..b78c084 100644
>> --- a/net/ipv4/tcp_output.c
>> +++ b/net/ipv4/tcp_output.c
>> @@ -216,6 +216,11 @@ void tcp_select_initial_window(int __space, __u=
32
>> mss,
>>              space >>=3D 1;
>>              (*rcv_wscale)++;
>>          }
>> +        /*
>> +         * Set a minimum wscale of 1
>> +         */
>> +        if (*rcv_wscale =3D=3D 0)
>> +            *rcv_wscale =3D 1;
>>         }
>>
>>         /* Set initial window to value enough for senders,
>>
>>  =20
>=20
> Thank you for the patch review. The suggested replacement patch
> certainly is shorter, code wise, which is an advantage.
>=20
> I cant help but feel though, that it is less readable - a window scal=
e
> of zero is a perfectly legit value. Adding special logic to rule it o=
ut
> just because we chose to overload this setting for something else
> (whether window scaling is supported or not) seems like an invitation
> for someone to get it wrong again down the line, in my opinion.

As a matter of fact I didnot test your patch.

My reaction was driven by :

Your version slows down the tcp_options_write() function, once per tx p=
acket.

tcp_options_write() should not change socket state, while
tcp_select_initial_window() is the exact place where we are supposed to
compute wscale.=20

Also how is managed tcp_syn_options() case (for outgoing connections ?)

        if (likely(sysctl_tcp_window_scaling)) {
                opts->ws =3D tp->rx_opt.rcv_wscale;
                if (likely(opts->ws))
                        size +=3D TCPOLEN_WSCALE_ALIGNED;
        }

Dont you need to patch it as well ?

>=20
> Also note that the suggested fix is in line with how other TCP option=
s
> are handled, e.g. TCP timestamp.
>=20
> Anyone else wants to chime in on that?
>=20
> PS. I also managed to to get the patch author name spelling wrong. It=
 is
> Ori Finkelman and not as written.
>=20
> Thanks!
> Gilad
>=20
>=20


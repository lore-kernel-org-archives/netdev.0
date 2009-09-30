From: Gilad Ben-Yossef <gilad@codefidence.com>
Subject: Re: [PATCH] [RFC] IPv4 TCP fails to send window scale option when
 window scale is zero
Date: Wed, 30 Sep 2009 08:28:12 +0200
Message-ID: <4AC2FA7C.6030901@codefidence.com>
References: <4AC22250.7060301@codefidence.com> <4AC241BA.8040608@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Ori Finkalman <ori@comsleep.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenbox.codefidence.com ([92.48.73.16]:38071 "EHLO
	xenbox.codefidence.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751405AbZI3G2L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2009 02:28:11 -0400
In-Reply-To: <4AC241BA.8040608@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,


[ Resending reply due to Android Gmail client sorry state. My apologies=
=20
if you got it twice. ]


Eric Dumazet wrote:

> Gilad Ben-Yossef a =E9crit :
>  =20
>> From: Ori Finkalman <ori@comsleep.com>
>>
>>
>> Acknowledge TCP window scale support by inserting the proper option =
in
>> SYN/ACK header
>> even if our window scale is zero.
>>
>>
>> This fixes the following observed behavior:
>>
>>
>> 1. Client sends a SYN with TCP window scaling option and non zero wi=
ndow
>> scale value to a Linux box.
>>
>> 2. Linux box notes large receive window from client.
>>
>> 3. Linux decides on a zero value of window scale for its part.
>>
>> 4. Due to compare against requested window scale size option, Linux =
does
>> not to send windows scale
>>
>> TCP option header on SYN/ACK at all.
>>
>>
>> Result:
>>
>>
>> Client box thinks TCP window scaling is not supported, since SYN/ACK=
 had
>> no TCP window scale option,
>> while Linux thinks that TCP window scaling is supported (and scale m=
ight
>> be non zero), since SYN had
>>
>> TCP window scale option and we have a mismatched idea between the cl=
ient
>> and server regarding window sizes.
>>
>>
>> Please comment and/or apply.
>> ...
>>
>>
>> Signed-off-by: Gilad Ben-Yossef <gilad@codefidence.com>
>> Signed-off-by: Ori Finkelman <ori@comsleep.com>
>>
>>
>> Index: net/ipv4/tcp_output.c
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> --- net/ipv4/tcp_output.c    (revision 46)
>> +++ net/ipv4/tcp_output.c    (revision 210)
>> @@ -353,6 +353,7 @@ static void tcp_init_nondata_skb(struct
>> #define OPTION_SACK_ADVERTISE    (1 << 0)
>> #define OPTION_TS        (1 << 1)
>> #define OPTION_MD5        (1 << 2)
>> +#define OPTION_WSCALE        (1 << 3)
>>
>> struct tcp_out_options {
>>     u8 options;        /* bit field of OPTION_* */
>> @@ -417,7 +418,7 @@ static void tcp_options_write(__be32 *pt
>>                    TCPOLEN_SACK_PERM);
>>     }
>>
>> -    if (unlikely(opts->ws)) {
>> +    if (unlikely(OPTION_WSCALE & opts->options)) {
>>         *ptr++ =3D htonl((TCPOPT_NOP << 24) |
>>                    (TCPOPT_WINDOW << 16) |
>>                    (TCPOLEN_WINDOW << 8) |
>> @@ -530,8 +531,8 @@ static unsigned tcp_synack_options(struc
>>
>>     if (likely(ireq->wscale_ok)) {
>>         opts->ws =3D ireq->rcv_wscale;
>> -        if(likely(opts->ws))
>> -            size +=3D TCPOLEN_WSCALE_ALIGNED;
>> +        opts->options |=3D OPTION_WSCALE;
>> +        size +=3D TCPOLEN_WSCALE_ALIGNED;
>>     }
>>     if (likely(doing_ts)) {
>>         opts->options |=3D OPTION_TS;
>>
>>
>>
>>    =20
>
> Seems not the more logical places to put this logic...
>
> How about this instead ?
>
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index 5200aab..b78c084 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -216,6 +216,11 @@ void tcp_select_initial_window(int __space, __u3=
2 mss,
>  			space >>=3D 1;
>  			(*rcv_wscale)++;
>  		}
> +		/*
> +		 * Set a minimum wscale of 1
> +		 */
> +		if (*rcv_wscale =3D=3D 0)
> +			*rcv_wscale =3D 1;
>         }
>
>         /* Set initial window to value enough for senders,
>
>  =20

Thank you for the patch review. The suggested replacement patch=20
certainly is shorter, code wise, which is an advantage.

I cant help but feel though, that it is less readable - a window scale=20
of zero is a perfectly legit value. Adding special logic to rule it out=
=20
just because we chose to overload this setting for something else=20
(whether window scaling is supported or not) seems like an invitation=20
for someone to get it wrong again down the line, in my opinion.

Also note that the suggested fix is in line with how other TCP options=20
are handled, e.g. TCP timestamp.

Anyone else wants to chime in on that?

PS. I also managed to to get the patch author name spelling wrong. It i=
s=20
Ori Finkelman and not as written.

Thanks!
Gilad


--=20
Gilad Ben-Yossef
Chief Coffee Drinker & CTO
Codefidence Ltd.

Web:   http://codefidence.com
Cell:  +972-52-8260388
Skype: gilad_codefidence
Tel:   +972-8-9316883 ext. 201
=46ax:   +972-8-9316884
Email: gilad@codefidence.com

Check out our Open Source technology and training blog - http://tuxolog=
y.net

	"Now the world has gone to bed
	 Darkness won't engulf my head
	 I can see by infra-red
	 How I hate the night."


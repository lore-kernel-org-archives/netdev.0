From: Nelson Elhage <nelhage@ksplice.com>
Subject: Re: NULL dereference in econet AUN-over-UDP receive
Date: Wed, 8 Dec 2010 23:18:22 -0500
Message-ID: <AANLkTimdN2LkEpyWV0bsdfVVvnsQOaLGYmm_0ostrjFM@mail.gmail.com>
References: <20101209003015.GA27906@ksplice.com>
	<1291858667.2795.16.camel@edumazet-laptop>
	<20101208.180215.193709862.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f45.google.com ([209.85.214.45]:62628 "EHLO
	mail-bw0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753631Ab0LIESY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 23:18:24 -0500
Received: by bwz16 with SMTP id 16so2196932bwz.4
        for <netdev@vger.kernel.org>; Wed, 08 Dec 2010 20:18:22 -0800 (PST)
In-Reply-To: <20101208.180215.193709862.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yep, that fixes the crash.

Tested-by: Nelson Elhage <nelhage@ksplice.com>

On Wed, Dec 8, 2010 at 9:02 PM, David Miller <davem@davemloft.net> wrot=
e:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 09 Dec 2010 02:37:47 +0100
>
>> Le mercredi 08 d=E9cembre 2010 =E0 19:30 -0500, Nelson Elhage a =E9c=
rit :
>>> While testing one of my econet reproducers on a patched kernel, I t=
riggered a
>>> NULL pointer dereference in the econet AUN-over-UDP receive path. U=
pon further
>>> investigation, I now suspect that this code path hasn't worked at a=
ll in years.
>>>
>>> A copy of the oops is below for your reference, but here's my analy=
sis:
>>>
>>> When aun_data_available receives a data packet (ah->code =3D=3D 2),=
 it calls
>>> aun_incoming to process the skb. The start of aun_incoming looks li=
ke:
>>>
>>> static void aun_incoming(struct sk_buff *skb, struct aunhdr *ah, si=
ze_t len)
>>> {
>>> =A0 =A0 =A0struct iphdr *ip =3D ip_hdr(skb);
>>> =A0 =A0 =A0unsigned char stn =3D ntohl(ip->saddr) & 0xff;
>>> =A0 =A0 =A0struct sock *sk =3D NULL;
>>> =A0 =A0 =A0struct sk_buff *newskb;
>>> ---> =A0 =A0 =A0 =A0 struct ec_device *edev =3D skb->dev->ec_ptr;
>>>
>>
>> This can be changed to use skb_dst(skb)->dev instead
>>
>> struct dst *dst =3D skb_dst(skb);
>>
>> if (dst) {
>> =A0 =A0 =A0 dev =3D dst->dev;
>> =A0 =A0 =A0 ...
>> }
>
> Nelson please test if this patch fixes your crash:
>
> econet: Fix crash in aun_incoming().
>
> Unconditional use of skb->dev won't work here,
> try to fetch the econet device via skb_dst()->dev
> instead.
>
> Suggested by Eric Dumazet.
>
> Reported-by: Nelson Elhage <nelhage@ksplice.com>
> Signed-off-by: David S. Miller <davem@davemloft.net>
>
> diff --git a/net/econet/af_econet.c b/net/econet/af_econet.c
> index f180371..15dcc1a 100644
> --- a/net/econet/af_econet.c
> +++ b/net/econet/af_econet.c
> @@ -851,9 +851,13 @@ static void aun_incoming(struct sk_buff *skb, st=
ruct aunhdr *ah, size_t len)
> =A0{
> =A0 =A0 =A0 =A0struct iphdr *ip =3D ip_hdr(skb);
> =A0 =A0 =A0 =A0unsigned char stn =3D ntohl(ip->saddr) & 0xff;
> + =A0 =A0 =A0 struct dst_entry *dst =3D skb_dst(skb);
> + =A0 =A0 =A0 struct ec_device *edev =3D NULL;
> =A0 =A0 =A0 =A0struct sock *sk =3D NULL;
> =A0 =A0 =A0 =A0struct sk_buff *newskb;
> - =A0 =A0 =A0 struct ec_device *edev =3D skb->dev->ec_ptr;
> +
> + =A0 =A0 =A0 if (dst)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 edev =3D dst->dev->ec_ptr;
>
> =A0 =A0 =A0 =A0if (! edev)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto bad;
>

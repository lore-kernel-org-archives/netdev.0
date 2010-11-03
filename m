From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH] xfrm: use gre key as flow upper protocol info
Date: Wed, 3 Nov 2010 14:35:41 -0700
Message-ID: <AANLkTimmu+R=37tgctZNMchCdyUwbxo7S8ZT0ZX9Gpte@mail.gmail.com>
References: <1288795298-323-1-git-send-email-timo.teras@iki.fi>
	<AANLkTi=JF6q49dqzUsTMmubMhVZooe-WaCBKL+DT5FQy@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>,
	netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>
To: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:51265 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751323Ab0KCVfn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Nov 2010 17:35:43 -0400
Received: by wyf28 with SMTP id 28so1085998wyf.19
        for <netdev@vger.kernel.org>; Wed, 03 Nov 2010 14:35:42 -0700 (PDT)
In-Reply-To: <AANLkTi=JF6q49dqzUsTMmubMhVZooe-WaCBKL+DT5FQy@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2010/11/3 Micha=B3 Miros=B3aw <mirqus@gmail.com>:
> 2010/11/3 Timo Ter=E4s <timo.teras@iki.fi>:
>> The GRE Key field is intended to be used for identifying an individu=
al
>> traffic flow within a tunnel. It is useful to be able to have XFRM
>> policy selector matches to have different policies for different
>> GRE tunnels.
> [...]
>> diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
>> index 4464f3b..57af4bd 100644
>> --- a/net/ipv4/xfrm4_policy.c
>> +++ b/net/ipv4/xfrm4_policy.c
>> @@ -158,6 +159,20 @@ _decode_session4(struct sk_buff *skb, struct fl=
owi *fl, int reverse)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0fl->f=
l_ipsec_spi =3D htonl(ntohs(ipcomp_hdr[1]));
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case IPPROTO_GRE:
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (pskb_may_pull(skb,=
 xprth + 12 - skb->data)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __be16=
 *greflags =3D (__be16 *)xprth;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __be32=
 *gre_hdr =3D (__be32 *)xprth;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (gr=
eflags[0] & GRE_KEY) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 if (greflags[0] & GRE_CSUM)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 gre_hdr++;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 fl->fl_gre_key =3D gre_hdr[1];
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> +
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0default:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0fl->fl_ipsec_spi =3D =
0;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
>
> I would expect that keyless tunnel would be separate from key 0 tunne=
l.

No key and key 0 are generally treated the same.  Both will match the
same tunnel when doing the lookup in the GRE receive path.

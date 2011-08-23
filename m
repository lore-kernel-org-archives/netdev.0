From: Ang Way Chuang <wcang@sfc.wide.ad.jp>
Subject: Re: IPv6 multicast snooping behaviour on 2.6.39-rc2 and later
Date: Wed, 24 Aug 2011 02:24:07 +0900
Message-ID: <4E53E237.1060401@sfc.wide.ad.jp>
References: <4E5367CA.3090005@sfc.wide.ad.jp>  <1314093424.2219.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <4E539DA8.1070504@sfc.wide.ad.jp> <1314105027.2219.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <4E53B360.8090107@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?UTF-8?B?TGludXMgTMO8c3Npbmc=?= <linus.luessing@web.de>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shonan.sfc.wide.ad.jp ([203.178.142.130]:52618 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755591Ab1HWRYK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2011 13:24:10 -0400
In-Reply-To: <4E53B360.8090107@sfc.wide.ad.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is what I found so far from debugging.

The packet is not forwarded due to the failed checksum at br_multicast.=
c:1533

         case CHECKSUM_NONE:
                 skb2->csum =3D 0;
                 if (skb_checksum_complete(skb2))
                         goto out;
         }

Contrary to description of commit ff9a57a6, when the patch of commit ff=
9a57a6 is applied,
pskb_trim_rcsum is never called at all on my testbed. When commit ff9a5=
7a6 is reverted,
pskb_trim_rcsum will be called. The difference is:

with commit ff9a57a6,
    pskb_trim_rcsum is never called, br_multicast_ipv6_rcv returns -EIN=
VAL which causes
    br_handle_frame_finish to drop the packet

without commit ff9a57a6,
    pskb_trim_rcsum is called overwriting err with 0. br_multicast_ipv6=
_rcv still fails on the
    same line (skb_checksum_complete). But the difference is err is set=
 to 0 this time. Thereby,
    allowing the packet to be forwarded.

Anyway, I don't think the behaviour is correct with or without commit f=
f9a57a6



On 23/08/11 23:04, Ang Way Chuang wrote:
> Tough luck :( Got no love from bridge. It still doesn't work with you=
r latest patch. Please keep sending those patches.
>
> On 23/08/11 22:10, Eric Dumazet wrote:
>> Le mardi 23 ao=C3=BBt 2011 =C3=A0 21:31 +0900, Ang Way Chuang a =C3=A9=
crit :
>>> Sorry for the blurb. I hope I've configured thunderbird properly to
>>> send in plain text. Hope you received my reply. I tried your patch =
on
>>> 3.0.3 and it didn't fix the problem.
>>
>> Thanks for trying !
>>
>> Ok could you please try following patch then ?
>>
>> diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
>> index 2d85ca7..e9b32a3 100644
>> --- a/net/bridge/br_multicast.c
>> +++ b/net/bridge/br_multicast.c
>> @@ -1497,7 +1497,7 @@ static int br_multicast_ipv6_rcv(struct net_br=
idge *br,
>>       if (!pskb_may_pull(skb2, offset + sizeof(struct icmp6hdr)))
>>           goto out;
>>
>> -    len -=3D offset - skb_network_offset(skb2);
>> +    len -=3D offset;
>>
>>       __skb_pull(skb2, offset);
>>       skb_reset_transport_header(skb2);
>> @@ -1520,6 +1520,7 @@ static int br_multicast_ipv6_rcv(struct net_br=
idge *br,
>>           err =3D pskb_trim_rcsum(skb2, len);
>>           if (err)
>>               goto out;
>> +        icmp6h =3D icmp6_hdr(skb2);
>>       }
>>
>>       switch (skb2->ip_summed) {
>>
>>
>>
>
> --=20
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>


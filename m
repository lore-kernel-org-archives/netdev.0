From: RongQing Li <roy.qing.li@gmail.com>
Subject: Re: [RFC PATCH] fix IP_ECN_set_ce
Date: Wed, 19 Dec 2012 16:41:24 +0800
Message-ID: <CAJFZqHyhMS22pKuW50D0uZLA5-WDUYBEZurPGCW6gSyRY-6JHg@mail.gmail.com>
References: <1355898095-7444-1-git-send-email-roy.qing.li@gmail.com>
	<alpine.LFD.2.00.1212191001530.1620@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f170.google.com ([209.85.220.170]:43931 "EHLO
	mail-vc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752273Ab2LSIl1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2012 03:41:27 -0500
Received: by mail-vc0-f170.google.com with SMTP id fl11so2017408vcb.1
        for <netdev@vger.kernel.org>; Wed, 19 Dec 2012 00:41:26 -0800 (PST)
In-Reply-To: <alpine.LFD.2.00.1212191001530.1620@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/12/19 Julian Anastasov <ja@ssi.bg>:
>
>         Hello,
>
> On Wed, 19 Dec 2012, roy.qing.li@gmail.com wrote:
>
>> From: Li RongQing <roy.qing.li@gmail.com>
>>
>> 1. ECN uses the two least significant (right-most) bits of the DiffS=
erv
>> field in the IPv4, so it should be in iph->tos, not in (iph->tos+1)
>>
>> 2. When setting CE, we should check if ECN Capable Transport support=
s,
>> both 10 and 01 mean ECN Capable Transport, so only check 10 is not e=
nough
>>     00: Non ECN-Capable Transport =97 Non-ECT
>>     10: ECN Capable Transport =97 ECT(0)
>>     01: ECN Capable Transport =97 ECT(1)
>>     11: Congestion Encountered =97 CE
>>
>> 3. Remove the misunderstand comment
>>
>> 4. fix the checksum computation
>>
>> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
>> ---
>>  include/net/inet_ecn.h |   22 ++++------------------
>>  1 file changed, 4 insertions(+), 18 deletions(-)
>>
>> diff --git a/include/net/inet_ecn.h b/include/net/inet_ecn.h
>> index aab7375..545a683 100644
>> --- a/include/net/inet_ecn.h
>> +++ b/include/net/inet_ecn.h
>> @@ -73,27 +73,13 @@ static inline void INET_ECN_dontxmit(struct sock=
 *sk)
>>
>>  static inline int IP_ECN_set_ce(struct iphdr *iph)
>>  {
>> -     u32 check =3D (__force u32)iph->check;
>> -     u32 ecn =3D (iph->tos + 1) & INET_ECN_MASK;
>> -
>> -     /*
>> -      * After the last operation we have (in binary):
>> -      * INET_ECN_NOT_ECT =3D> 01
>> -      * INET_ECN_ECT_1   =3D> 10
>> -      * INET_ECN_ECT_0   =3D> 11
>> -      * INET_ECN_CE      =3D> 00
>> -      */
>
>         I think, the above comment explains how an
> increment (iph->tos + 1) serves the purpose to check
> for ECT_1 and ECT_0, there is no such thing as
> addressing the next byte from header. It is just an
> optimized logic that avoids complex INET_ECN_is_XXX
> checks.
Thanks for your reply.
Do you mean this comment are valuable?


>
>> -     if (!(ecn & 2))
>> +     u32 ecn =3D iph->tos & INET_ECN_MASK;
>> +
>> +     if (INET_ECN_is_ce(ecn) || INET_ECN_is_not_ect(ecn))
>>               return !ecn;
>
>         May be return INET_ECN_is_ce(ecn) ?
>

I like to set the return value to void, since noone cares about the
return value.

-Roy

>>
>> -     /*
>> -      * The following gives us:
>> -      * INET_ECN_ECT_1 =3D> check +=3D htons(0xFFFD)
>> -      * INET_ECN_ECT_0 =3D> check +=3D htons(0xFFFE)
>> -      */
>> -     check +=3D (__force u16)htons(0xFFFB) + (__force u16)htons(ecn=
);
>> +     csum_replace2(&iph->check, iph->tos, iph->tos|INET_ECN_CE);
>>
>> -     iph->check =3D (__force __sum16)(check + (check>=3D0xFFFF));
>>       iph->tos |=3D INET_ECN_CE;
>>       return 1;
>>  }
>> --
>> 1.7.10.4
>
> Regards
>
> --
> Julian Anastasov <ja@ssi.bg>

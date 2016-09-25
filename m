From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net v2 0/2] Fix tc-ife bugs
Date: Sun, 25 Sep 2016 19:17:10 -0400
Message-ID: <098a8df2-aa3e-04a5-143b-a6946c9ece59@mojatatu.com>
References: <1474806711-64660-1-git-send-email-yotamg@mellanox.com>
 <2b01c982-76b7-d380-807c-1fe1df62d285@mojatatu.com>
 <DB3PR05MB07647722715384C174CC52D2ACCA0@DB3PR05MB0764.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@mellanox.com>, Elad Raz <eladr@mellanox.com>,
        mlxsw <mlxsw@mellanox.com>, Roman Mashak <mrv@mojatatu.com>
To: Yotam Gigi <yotamg@mellanox.com>, Yotam Gigi <yotam.gi@gmail.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:34829 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751990AbcIYXRN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 25 Sep 2016 19:17:13 -0400
Received: by mail-io0-f194.google.com with SMTP id 92so4777372iom.2
        for <netdev@vger.kernel.org>; Sun, 25 Sep 2016 16:17:12 -0700 (PDT)
In-Reply-To: <DB3PR05MB07647722715384C174CC52D2ACCA0@DB3PR05MB0764.eurprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-09-25 11:55 AM, Yotam Gigi wrote:
>> -----Original Message-----
>> From: Jamal Hadi Salim [mailto:jhs@mojatatu.com]
>> Sent: Sunday, September 25, 2016 4:46 PM
>> To: Yotam Gigi <yotam.gi@gmail.com>; davem@davemloft.net;
>> netdev@vger.kernel.org; Yotam Gigi <yotamg@mellanox.com>
>> Subject: Re: [PATCH net v2 0/2] Fix tc-ife bugs
>>
>> On 16-09-25 08:31 AM, Yotam Gigi wrote:
>>> This patch-set contains two bugfixes in the tc-ife action, one fixing some
>>> random behaviour in encode side, and one fixing the decode side packet
>>> parsing logic.
>>>
>>> Yotam Gigi (2):
>>>   act_ife: Fix external mac header on encode
>>>   act_ife: Fix false parsing on decode side
>>>
>>>  net/sched/act_ife.c | 9 ++++-----
>>>  1 file changed, 4 insertions(+), 5 deletions(-)
>>>
>>
>> Yotam, did you run the test i proposed? I am worried about the TLV one.
>> Note:
>> Encoder includes the length of the TLV header length in the L part.
>> If you are reaching a conclusion that you need this in the decoding:
>> +              tlvdata += alen + sizeof(struct meta_tlvhdr);
>>
>> then very likely whoever is sending that packet is not encoding
>> correctly.
>
> The one encoding the packets I get is the ife action. You can look at the code:
>
>   int ife_tlv_meta_encode(void *skbdata, u16 attrtype, u16 dlen, const void *dval)
>   {
>         u32 *tlv = (u32 *)(skbdata);
>         u16 totlen = nla_total_size(dlen);      /*alignment + hdr */
>         char *dptr = (char *)tlv + NLA_HDRLEN;
>         u32 htlv = attrtype << 16 | dlen;
>
>         *tlv = htonl(htlv);
>         memset(dptr, 0, totlen - NLA_HDRLEN);
>         memcpy(dptr, dval, dlen);
>
>         return totlen;
>   }
>
> As you can see, the data that is actually written into the packet is the htlv
> var, which has the 'dlen' in it, and not the totlen which corresponds the tlv
> header size. You can see that in the following example:
>
> I ran the tc command you proposed:
>   $TC filter add dev $ETH parent 1: protocol ip prio 10 \
>         u32 match ip protocol 1 0xff flowid 1:2 \
>         action skbedit prio 33 \
>         action ife encode \
>         type 0xDEAD \
>         use mark 12 \
>         allow prio \
>         dst 02:15:15:15:15:15
>
> And this is the packet I got:
>   0x0000:  0215 1515 1515 da23 d209 8644 dead 0012
>   0x0010:  0001 0004 0000 000c 0003 0004 0000 0033
>   0x0020:  fa30 7418 593a da23 d209 8644 0800 4500
>   0x0030:  0054 da3c 4000 4001 486a 0c00 0001 0c00
>   0x0040:  0002 0800 9fa2 1562 0008 aeec e757 0000
>   0x0050:  0000 ecdb 0100 0000 0000 1011 1213 1415
>   0x0060:  1617 1819 1a1b 1c1d 1e1f 2021 2223 2425
>   0x0070:  2627 2829 2a2b 2c2d 2e2f 3031 3233 3435
>   0x0080:  3637
>
> You can see that there are two tlvs there, one for mark (with value 0xc=12) and
> one for prio (with value 0x33). In the packets, you can see the on offsets 0x12
> and 0x1a, that the size in the tlv is 4 which is the datalen and not 8 which is
> the total tlv size.
>

Indeed.
We cant use totlen because that for non-32-bit aligned data will also
include the padding (I just fixed that in commit:
a823f93750e341bc0d6829a00019435b96830fd4)


> When I ran the decode without the fix, my kernel went into infinite loop which
> was caused by:
>  - The loop stopping condition was checking that an unsigned variable is greater
>    than zero.
>  - The parsing assumes that in the tlv header, the size refers to the whole tlv
>    size, but it refers to the size of the data only.
>
> To fix those problems, I fixed the decode side to assume that the tlv->size
> refers to the data len and not the whole tlv, and changed the variable to be
> signed.
>
> Do you prefer that I will fix the encode side to encode the whole tlv header
> size instead of fixing the decode side?

Yes please - Add NLA_HDRLEN to the dlen on the encode you showed above.

cheers,
jamal
> Thanks :)
>
>>
>> cheers,
>> jamal

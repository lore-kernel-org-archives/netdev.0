From: Jacek Luczak <difrost.kernel@gmail.com>
Subject: Re: [PATCH] SCTP: fix race between sctp_bind_addr_free() and sctp_bind_addr_conflict()
Date: Wed, 18 May 2011 15:39:14 +0200
Message-ID: <BANLkTi=7T5-mGCWv_ge=HSGALVp4HpUsiA@mail.gmail.com>
References: <BANLkTikeWzuE-384uT6RhZR6Wn=DBK+CNQ@mail.gmail.com>
	<1305704885.2983.4.camel@edumazet-laptop>
	<BANLkTik75iqfgvWGKLJYu6E7mheOwOZX+A@mail.gmail.com>
	<1305707358.2983.14.camel@edumazet-laptop>
	<4DD38B30.9090601@cn.fujitsu.com>
	<4DD3BC8F.9050802@hp.com>
	<BANLkTinQAy+jq_VUwky2rxchomuN3avPQg@mail.gmail.com>
	<1305723046.2991.19.camel@edumazet-laptop>
	<BANLkTi=cDwLFSqaBt5szaFOaWmxYzkya9g@mail.gmail.com>
	<4DD3CA57.5060709@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Wei Yongjun <yjwei@cn.fujitsu.com>, netdev@vger.kernel.org
To: Vladislav Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:61445 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932778Ab1ERNjP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 09:39:15 -0400
Received: by pvg12 with SMTP id 12so706273pvg.19
        for <netdev@vger.kernel.org>; Wed, 18 May 2011 06:39:15 -0700 (PDT)
In-Reply-To: <4DD3CA57.5060709@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/5/18 Vladislav Yasevich <vladislav.yasevich@hp.com>:
> On 05/18/2011 09:11 AM, Jacek Luczak wrote:
>> 2011/5/18 Eric Dumazet <eric.dumazet@gmail.com>:
>>> Le mercredi 18 mai 2011 =E0 14:47 +0200, Jacek Luczak a =E9crit :
>>>
>>>> OK then, at the end what Eric suggested is IMO valid:
>>>>
>>>> diff --git a/net/sctp/bind_addr.c b/net/sctp/bind_addr.c
>>>> index faf71d1..0025d90 100644
>>>> --- a/net/sctp/bind_addr.c
>>>> +++ b/net/sctp/bind_addr.c
>>>> @@ -144,10 +144,9 @@ static void sctp_bind_addr_clean(struct sctp_=
bind_addr *bp)
>>>> =A0 =A0 =A0 =A0 struct list_head *pos, *temp;
>>>>
>>>> =A0 =A0 =A0 =A0 /* Empty the bind address list. */
>>>> - =A0 =A0 =A0 list_for_each_safe(pos, temp, &bp->address_list) {
>>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 addr =3D list_entry(pos, struct sctp=
_sockaddr_entry, list);
>>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_del(pos);
>>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(addr);
>>>> + =A0 =A0 =A0 list_for_each_entry(pos, &bp->address_list, list) {
>>>
>>> a 'safe' version is needed here, since we remove items in iterator.
>>
>> Yep.
>>
>> diff --git a/net/sctp/bind_addr.c b/net/sctp/bind_addr.c
>> index faf71d1..6150ac5 100644
>> --- a/net/sctp/bind_addr.c
>> +++ b/net/sctp/bind_addr.c
>> @@ -140,14 +140,12 @@ void sctp_bind_addr_init(struct sctp_bind_addr
>> *bp, __u16 port)
>> =A0/* Dispose of the address list. */
>> =A0static void sctp_bind_addr_clean(struct sctp_bind_addr *bp)
>> =A0{
>> - =A0 =A0 =A0 struct sctp_sockaddr_entry *addr;
>> - =A0 =A0 =A0 struct list_head *pos, *temp;
>> + =A0 =A0 =A0 struct sctp_sockaddr_entry *addr, *temp;
>>
>> =A0 =A0 =A0 =A0 /* Empty the bind address list. */
>> - =A0 =A0 =A0 list_for_each_safe(pos, temp, &bp->address_list) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 addr =3D list_entry(pos, struct sctp_s=
ockaddr_entry, list);
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_del(pos);
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(addr);
>> + =A0 =A0 =A0 list_for_each_entry_safe(addr, temp, &bp->address_list=
, list) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_del_rcu(&addr->list);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 call_rcu(&addr->rcu, sctp_local_addr_f=
ree);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 SCTP_DBG_OBJCNT_DEC(addr);
>> =A0 =A0 =A0 =A0 }
>> =A0}
>>
>> Does it now look good?
>
> Yes. =A0It should the fix the race.
>

Thanks guys then for your guidance. I will repost final patch.

-Jacek

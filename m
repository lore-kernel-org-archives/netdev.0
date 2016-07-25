From: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kv5ZCJ6Jek6Iux5piO?=
	<hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH] net: neigh: disallow state transition DELAY->STALE in
 neigh_update()
Date: Mon, 25 Jul 2016 14:20:29 +0900
Message-ID: <e0d3e238-312e-a0e2-9501-29beb7e2ef27@miraclelinux.com>
References: <1469123890-2715-1-git-send-email-hchunhui@mail.ustc.edu.cn>
 <alpine.LFD.2.11.1607220954060.1764@ja.home.ssi.bg>
 <20160722.124757.283248020246505940.hchunhui@mail.ustc.edu.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hideaki.yoshifuji@miraclelinux.com, davem@davemloft.net,
	dsa@cumulusnetworks.com, nicolas.dichtel@6wind.com,
	roopa@cumulusnetworks.com, rshearma@brocade.com,
	dbarroso@fastly.com, martinbj2008@gmail.com, rick.jones2@hp.com,
	koct9i@gmail.com, edumazet@google.com, tgraf@suug.ch,
	ebiederm@xmission.com, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Chunhui He <hchunhui@mail.ustc.edu.cn>, ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:34016 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750793AbcGYFUf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jul 2016 01:20:35 -0400
Received: by mail-pa0-f48.google.com with SMTP id fi15so57577950pac.1
        for <netdev@vger.kernel.org>; Sun, 24 Jul 2016 22:20:35 -0700 (PDT)
In-Reply-To: <20160722.124757.283248020246505940.hchunhui@mail.ustc.edu.cn>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Chunhui He wrote:
> Hi,
>=20
> On Fri, 22 Jul 2016 10:20:01 +0300 (EEST), Julian Anastasov <ja@ssi.b=
g> wrote:
>>
>> 	Hello,
>>
>> On Thu, 21 Jul 2016, Chunhui He wrote:
>>
>>> If neigh entry was CONNECTED and address is not changed, and if new=
 state is
>>> STALE, entry state will not change. Because DELAY is not in CONNECT=
ED, it's
>>> possible to change state from DELAY to STALE.
>>>
>>> That is bad. Consider a host in IPv4 nerwork, a neigh entry in STAL=
E state
>>> is referenced to send packets, so goes to DELAY state. If the entry=
 is not
>>> confirmed by upper layer, it goes to PROBE state, and sends ARP req=
uest.
>>> The neigh host sends ARP reply, then the entry goes to REACHABLE st=
ate.
>>> But the entry state may be reseted to STALE by broadcast ARP packet=
s, before
>>> the entry goes to PROBE state. So it's possible that the entry will=
 never go
>>> to REACHABLE state, without external confirmation.
>>>
>>> In my case, the gateway refuses to send unicast packets to me, befo=
re it sees
>>> my ARP request. So it's critical to enter REACHABLE state by sendin=
g ARP
>>> request, but not by external confirmation.
>>>
>>> This fixes neigh_update() not to change to STALE if old state is CO=
NNECTED or
>>> DELAY.
>>>
>>> Signed-off-by: Chunhui He <hchunhui@mail.ustc.edu.cn>
>>> ---
>>>  net/core/neighbour.c | 2 +-
>>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>>
>>> diff --git a/net/core/neighbour.c b/net/core/neighbour.c
>>> index 510cd62..29429eb 100644
>>> --- a/net/core/neighbour.c
>>> +++ b/net/core/neighbour.c
>>> @@ -1152,7 +1152,7 @@ int neigh_update(struct neighbour *neigh, con=
st u8 *lladdr, u8 new,
>>>  		} else {
>>>  			if (lladdr =3D=3D neigh->ha && new =3D=3D NUD_STALE &&
>>>  			    ((flags & NEIGH_UPDATE_F_WEAK_OVERRIDE) ||
>>> -			     (old & NUD_CONNECTED))
>>> +			     (old & (NUD_CONNECTED | NUD_DELAY)))
>>>  			    )
>>>  				new =3D old;
>>>  		}
>>
>> 	You change looks correct to me. But this place
>> has more problems. There is no good reason to set NUD_STALE
>> for any state that is NUD_VALID if address is not changed.
>> This matches perfectly the comment above this code:
>> NUD_STALE should change a NUD_VALID state only when
>> address changes. It also means that IPv6 does not need
>> to provide NEIGH_UPDATE_F_WEAK_OVERRIDE anymore when
>> NEIGH_UPDATE_F_OVERRIDE is also present.
>>
>=20
> The NEIGH_UPDATE_F_WEAK_OVERRIDE is confusing to me, so I choose not =
to deal
> with the flag.

IPv6 depends on WEAK_OVERRIDE.  Please do not change.

>=20
>> 	By this way the state machine can continue with
>> the resolving: NUD_STALE -> NUD_DELAY (traffic) ->
>> NUD_PROBE (retries) -> NUD_REACHABLE (unicast reply)
>> while the address is not changed. Your change covers only
>> NUD_DELAY, not NUD_PROBE, so it is better to allow more
>> retries to send. We should not give up until success (NUD_REACHABLE)=
=2E
>>
>=20
> I have thought about this.
> The origin code allows NUD_DELAY -> NUD_STALE and NUD_PROBE -> NUD_ST=
ALE.
> This part was imported to kernel since v2.1.79, I don't know clearly =
why it
> allows that.
>=20
> My analysis:
> (1) As shown in my previous mail, NUD_DELAY -> NUD_STALE may cause "d=
ead loop",
> so it should be fixed.
>=20
> (2) But NUD_PROBE -> NUD_STALE is acceptable, because in NUD_PROBE, A=
RP request
> has been sent, it is sufficient to break the "dead loop".
> More attempts are accomplished by the following sequence:
> NUD_STALE --> NUD_DELAY -(sent req)-> NUD_PROBE -(reset by neigh_upda=
te())->
> NUD_STALE --> NUD_DELAY -(send req again)-> ... -->
> NUD_REACHABLE
>=20
>=20
> But I also agree your change.
>=20
>> 	Second problem: NEIGH_UPDATE_F_WEAK_OVERRIDE has no
>> priority over NEIGH_UPDATE_F_ADMIN. For example, now I can not
>> change from NUD_PERMANENT to NUD_STALE:
>>
>> # ip neigh add 192.168.168.111 lladdr 00:11:22:33:44:55 nud perm dev=
 wlan0
>> # ip neigh show to 192.168.168.111
>> 192.168.168.111 dev wlan0 lladdr 00:11:22:33:44:55 PERMANENT
>> # ip neigh change 192.168.168.111 lladdr 00:11:22:33:44:55 nud stale=
 dev wlan0
>> # ip neigh show to 192.168.168.111
>> 192.168.168.111 dev wlan0 lladdr 00:11:22:33:44:55 PERMANENT
>>
>> 	IMHO, here is how this place should look:
>>
>> diff --git a/net/core/neighbour.c b/net/core/neighbour.c
>> index 5cdc62a..2b1cb91 100644
>> --- a/net/core/neighbour.c
>> +++ b/net/core/neighbour.c
>> @@ -1151,10 +1151,8 @@ int neigh_update(struct neighbour *neigh, con=
st u8 *lladdr, u8 new,
>>  				goto out;
>>  		} else {
>>  			if (lladdr =3D=3D neigh->ha && new =3D=3D NUD_STALE &&
>> -			    ((flags & NEIGH_UPDATE_F_WEAK_OVERRIDE) ||
>> -			     (old & NUD_CONNECTED))
>> -			    )
>> -				new =3D old;
>> +			    !(flags & NEIGH_UPDATE_F_ADMIN))
>> +				goto out;
>>  		}
>>  	}
>>
>> 	Any thoughts?
>> =20
>> Regards
>>
>> --
>> Julian Anastasov <ja@ssi.bg>
>=20
> Regards,
> Chunhui He
>=20

--=20
=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E <hideaki.yoshifuji@miraclelinux.co=
m>
=E3=83=9F=E3=83=A9=E3=82=AF=E3=83=AB=E3=83=BB=E3=83=AA=E3=83=8A=E3=83=83=
=E3=82=AF=E3=82=B9=E6=A0=AA=E5=BC=8F=E4=BC=9A=E7=A4=BE =E6=8A=80=E8=A1=93=
=E6=9C=AC=E9=83=A8 =E3=82=B5=E3=83=9D=E3=83=BC=E3=83=88=E9=83=A8
